#!/usr/bin/env bash
set -euo pipefail

# Configurazione dei target
# Formato: "host:flake_path:hostname"
# - host: dove fare il deploy (localhost, homelab.lan, xpsnixos.lan)
# - flake_path: percorso al flake (es: ./AMDnixos)
# - hostname: nome della configurazione nel flake (es: AMDnixos)
declare -A TARGETS=(
    ["AMDnixos"]="localhost:.:AMDnixos"
    ["XPSnixos"]="xpsnixos.lan:.:XPSnixos"
    ["homelab"]="homelab.lan:.:homelab"
)

# User per il rebuild remoto
REBUILD_USER="nixos-builder"

# Directory per le build lockate
BUILDS_DIR="./builds"

# Configurazione Git commits
GIT_ENABLED=true
COMMIT_STYLE="conventional"  # Opzioni: conventional, simple, detailed

# Colori per l'output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Funzione per stampare messaggi colorati
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✅${NC} $1"
}

log_error() {
    echo -e "${RED}❌${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Funzione per generare il commit message
generate_commit_message() {
    local name=$1
    local flake_path=$2
    local style=${3:-$COMMIT_STYLE}
    
    # Normalizza il nome per il prefix (lowercase, rimuovi "nixos")
    local prefix=$(echo "$name" | sed 's/nixos//gi' | tr '[:upper:]' '[:lower:]')
    
    case "$style" in
        conventional)
            # Conventional Commits: type(scope): description
            echo "chore(${prefix}): update flake dependencies"
            ;;
        simple)
            # Semplice e diretto
            echo "Update ${name} flake.lock"
            ;;
        detailed)
            # Con più dettagli
            local date=$(date +%Y-%m-%d)
            echo "chore(${prefix}): update flake dependencies [${date}]"
            ;;
        *)
            echo "chore(${prefix}): update flake dependencies"
            ;;
    esac
}

# Funzione per fare commit del flake.lock aggiornato
commit_flake_update() {
    local name=$1
    local flake_path=$2
    
    if [ "$GIT_ENABLED" != "true" ]; then
        return 0
    fi
    
    # Verifica se siamo in un repo git
    if [ ! -d ".git" ]; then
        log_warning "No git repository found, skipping commit"
        return 0
    fi
    
    # Verifica se flake.lock è stato modificato
    if ! git diff --quiet "${flake_path}/flake.lock" 2>/dev/null; then
        log_info "Committing flake.lock changes for ${name}..."
        
        # Genera il commit message
        local commit_msg=$(generate_commit_message "$name" "$flake_path")
        
        # Stage solo flake.lock
        git add "${flake_path}/flake.lock"
        
        # Commit
        if git commit -m "$commit_msg" 2>&1 | tee /tmp/git-commit-${name}.log; then
            log_success "Committed: ${commit_msg}"
            
            # Mostra info sul commit
            local commit_hash=$(git rev-parse --short HEAD)
            echo -e "   ${MAGENTA}→${NC} Commit: ${commit_hash}"
        else
            log_error "Failed to commit flake.lock for ${name}"
            return 1
        fi
    else
        log_info "No changes to flake.lock for ${name}"
    fi
    
    return 0
}

# Funzione per aggiornare un singolo flake
update_flake() {
    local name=$1
    local config=$2
    
    # Estrai il flake_path dalla configurazione
    local host=$(echo "$config" | cut -d: -f1)
    local flake_path=$(echo "$config" | cut -d: -f2)
    local hostname=$(echo "$config" | cut -d: -f3)
    
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}🔄 Updating flake for ${name}${NC}"
    echo -e "${CYAN}   Path: ${flake_path}${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    if [ ! -f "${flake_path}/flake.nix" ]; then
        log_error "No flake.nix found in ${flake_path}"
        return 1
    fi
    
    # Backup del vecchio flake.lock se esiste
    if [ -f "${flake_path}/flake.lock" ]; then
        cp "${flake_path}/flake.lock" "${flake_path}/flake.lock.backup"
        log_info "Backed up current flake.lock"
    fi
    
    # Update del flake usando il path
    log_info "Running nix flake update..."
    if nix flake update --flake "${flake_path}" 2>&1 | tee /tmp/flake-update-${name}.log; then
        log_success "Flake updated successfully"
        
        # Mostra le differenze se possibile
        if [ -f "${flake_path}/flake.lock.backup" ]; then
            echo ""
            log_info "Changes in flake.lock:"
            if command -v jq &> /dev/null; then
                # Mostra un riassunto delle modifiche con jq
                echo -e "${MAGENTA}Updated inputs:${NC}"
                diff <(jq -r '.nodes | keys[]' "${flake_path}/flake.lock.backup" 2>/dev/null | sort) \
                     <(jq -r '.nodes | keys[]' "${flake_path}/flake.lock" 2>/dev/null | sort) \
                     | grep "^>" | sed 's/^> /  • /' || echo "  (no new inputs)"
            else
                # Fallback: conta le righe modificate
                local changes=$(diff "${flake_path}/flake.lock.backup" "${flake_path}/flake.lock" 2>/dev/null | wc -l)
                echo "  ${changes} lines changed"
            fi
            rm -f "${flake_path}/flake.lock.backup"
        fi
        
        # Commit automatico
        commit_flake_update "$name" "$flake_path"
        
        return 0
    else
        log_error "Failed to update flake for ${name}"
        
        # Ripristina il backup in caso di errore
        if [ -f "${flake_path}/flake.lock.backup" ]; then
            mv "${flake_path}/flake.lock.backup" "${flake_path}/flake.lock"
            log_warning "Restored previous flake.lock"
        fi
        
        return 1
    fi
}

# Funzione per fare rebuild su un target
rebuild_target() {
    local name=$1
    local config=$2
    
    # Parse della configurazione: "host:flake_path:hostname"
    local host=$(echo "$config" | cut -d: -f1)
    local flake_path=$(echo "$config" | cut -d: -f2)
    local hostname=$(echo "$config" | cut -d: -f3)
    
    # Costruisci il riferimento completo al flake
    local flake="${flake_path}/.#${hostname}"
    
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}🔨 Building ${name} (${host})${NC}"
    echo -e "${CYAN}   Flake: ${flake}${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Crea la directory delle build se non esiste
    mkdir -p "${BUILDS_DIR}/${name}"
    
    # Timestamp per questa build
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local build_dir="${BUILDS_DIR}/${name}/${timestamp}"
    
    log_info "Build directory: ${build_dir}"
    mkdir -p "${build_dir}"
    
    # Copia il lock file corrente dalla directory specifica
    if [ -f "${flake_path}/flake.lock" ]; then
        cp "${flake_path}/flake.lock" "${build_dir}/flake.lock"
        log_success "Locked flake.lock saved from ${flake_path}"
    fi
    
    # Salva il commit hash se è un repo git
    if [ -d ".git" ]; then
        git rev-parse HEAD > "${build_dir}/git-commit" 2>/dev/null || true
        git describe --always --dirty > "${build_dir}/git-describe" 2>/dev/null || true
    fi
    
    # Esegui il rebuild
    local build_result=0
    
    if [ "${host}" = "localhost" ]; then
        log_info "Building locally from ${flake_path}..."
        sudo nixos-rebuild switch --flake "${flake}" \
            --show-trace \
            2>&1 | tee "${build_dir}/build.log" || build_result=$?
    else
        log_info "Building on AMDnixos, deploying to ${host}..."
        
        # Verifica prima che sudo funzioni senza password
        log_info "Testing sudo access on ${host}..."
        if ! ssh "${REBUILD_USER}@${host}" "sudo -n true" 2>/dev/null; then
            log_error "Sudo without password not configured on ${host}"
            log_warning "Make sure remote-builder-config.nix is applied on ${host}"
            return 1
        fi
        
        # Build locale, deploy remoto
        # --build-host non specificato = build su questa macchina
        # --target-host = deploy sulla macchina remota
        NIX_SSHOPTS="-o StrictHostKeyChecking=accept-new -o ServerAliveInterval=60" \
        nixos-rebuild switch \
            --flake "${flake}" \
            --target-host "${REBUILD_USER}@${host}" \
            --sudo \
            --show-trace \
            2>&1 | tee "${build_dir}/build.log" || build_result=$?
    fi
    
    # Salva informazioni sulla build
    cat > "${build_dir}/build-info.json" <<EOF
{
  "target": "${name}",
  "host": "${host}",
  "flake_path": "${flake_path}",
  "flake": "${flake}",
  "timestamp": "${timestamp}",
  "date": "$(date -Iseconds)",
  "result": ${build_result},
  "user": "$(whoami)",
  "hostname": "$(hostname)"
}
EOF
    
    if [ ${build_result} -eq 0 ]; then
        log_success "Build successful for ${name}"
        
        # Crea un link simbolico all'ultima build riuscita
        ln -sfn "${build_dir}" "${BUILDS_DIR}/${name}/latest"
        
        # Salva il system profile path se disponibile (solo locale)
        if [ "${host}" = "localhost" ] && [ -L /nix/var/nix/profiles/system ]; then
            readlink /nix/var/nix/profiles/system > "${build_dir}/system-profile"
        fi
        
        return 0
    else
        log_error "Build failed for ${name} (exit code: ${build_result})"
        echo "${build_result}" > "${build_dir}/FAILED"
        return 1
    fi
}

# Funzione per mostrare lo stato delle build
show_status() {
    echo ""
    echo -e "${BLUE}╔═══════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║        BUILD STATUS REPORT                ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════╝${NC}"
    echo ""
    
    for name in "${!TARGETS[@]}"; do
        local config="${TARGETS[$name]}"
        local host=$(echo "$config" | cut -d: -f1)
        local flake_path=$(echo "$config" | cut -d: -f2)
        
        echo -e "${CYAN}🖥️  ${name}${NC} (${host})"
        echo "   Flake: ${flake_path}"
        
        if [ -d "${BUILDS_DIR}/${name}" ]; then
            local total=$(find "${BUILDS_DIR}/${name}" -maxdepth 1 -type d | wc -l)
            total=$((total - 1))
            
            echo "   Total builds: ${total}"
            
            if [ -L "${BUILDS_DIR}/${name}/latest" ]; then
                local latest=$(readlink "${BUILDS_DIR}/${name}/latest")
                local latest_name=$(basename "${latest}")
                
                if [ -f "${latest}/build-info.json" ]; then
                    local result=$(grep -oP '"result":\s*\K\d+' "${latest}/build-info.json" || echo "unknown")
                    local date=$(grep -oP '"date":\s*"\K[^"]+' "${latest}/build-info.json" || echo "unknown")
                    
                    if [ "${result}" = "0" ]; then
                        echo -e "   Latest: ${latest_name} ${GREEN}✅${NC}"
                    else
                        echo -e "   Latest: ${latest_name} ${RED}❌${NC}"
                    fi
                    echo "   Date: ${date}"
                fi
            else
                echo "   No builds found"
            fi
        else
            echo "   No build directory found"
        fi
        
        echo ""
    done
}

# Funzione per pulire vecchie build
cleanup_builds() {
    local keep_last=${1:-1}
    
    echo ""
    log_info "Cleaning up old builds (keeping last ${keep_last} per target)..."
    echo ""
    
    for name in "${!TARGETS[@]}"; do
        if [ -d "${BUILDS_DIR}/${name}" ]; then
            # Lista le directory ordinate per data, escludi 'latest'
            local count=0
            ls -1dt "${BUILDS_DIR}/${name}"/*/ 2>/dev/null | grep -v '/latest/' | while read dir; do
                count=$((count + 1))
                if [ ${count} -gt ${keep_last} ] && [ -d "${dir}" ]; then
                    log_warning "Removing ${name}/$(basename "${dir}")"
                    rm -rf "${dir}"
                fi
            done
        fi
    done
    
        log_success "Cleanup complete!"
    
    }
    
    
    
    # Funzione per il menu di selezione target
    
    select_target_menu() {
    
        local action=    
    
    
        echo ""
    
        echo -e "${CYAN}Select target to ${action}:${NC}"
    
        
    
        local i=1
    
        local targets_array=()
    
        for name in "${!TARGETS[@]}"; do
    
            echo -e "  ${YELLOW}${i})${NC} ${name}"
    
            targets_array+=("$name")
    
            ((i++))
    
        done
    
        echo -e "  ${YELLOW}0)${NC} Cancel"
    
        
    
        echo ""
    
        local choice
    
        read -p "Enter number: " choice
    
        
    
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -gt 0 ] && [ "$choice" -le "${#targets_array[@]}" ]; then
    
            local selected="${targets_array[$((choice-1))]}"
    
            main "$action" "$selected"
    
            echo ""
    
            read -p "Press Enter to continue..."
    
        elif [ "$choice" -eq 0 ]; then
    
            return
    
        else
    
            log_error "Invalid selection"
    
            sleep 1
    
        fi
    
    }
    
    
    
    # Menu Interattivo (TUI)
    
    interactive_menu() {
    
        while true; do
    
            clear
    
            echo -e "${BLUE}╔═══════════════════════════════════════════╗${NC}"
    
            echo -e "${BLUE}║   NixOS Distributed Manager               ║${NC}"
    
            echo -e "${BLUE}╚═══════════════════════════════════════════╝${NC}"
    
            echo ""
    
            echo -e " ${CYAN}1)${NC} 🔨 Build All"
    
            echo -e " ${CYAN}2)${NC} 🔨 Build Specific Target..."
    
            echo -e " ${CYAN}3)${NC} 🔄 Update All Flakes"
    
            echo -e " ${CYAN}4)${NC} 🔄 Update Specific Flake..."
    
            echo -e " ${CYAN}5)${NC} 📊 Show Status"
    
            echo -e " ${CYAN}6)${NC} 🧹 Cleanup Old Builds"
    
            echo -e " ${CYAN}0)${NC} ❌ Exit"
    
            echo ""
    
            
    
            local choice
    
            read -p "Select option: " choice
    
            
    
            case $choice in
    
                1) main build; echo ""; read -p "Press Enter to continue..." ;;
    
                2) select_target_menu "build" ;;
    
                3) main update; echo ""; read -p "Press Enter to continue..." ;;
    
                4) select_target_menu "update" ;;
    
                5) main status; echo ""; read -p "Press Enter to continue..." ;;
    
                6) main cleanup; echo ""; read -p "Press Enter to continue..." ;;
    
                0) exit 0 ;;
    
                *) log_error "Invalid option"; sleep 1 ;;
    
            esac
    
        done
    
    }
    # Main
    
    main() {
    
        case "${1:-build}" in
    
            update)
    
                echo -e "${BLUE}╔═══════════════════════════════════════════╗${NC}"
    
                echo -e "${BLUE}║   NixOS Flake Update Manager              ║${NC}"
    
                echo -e "${BLUE}╚═══════════════════════════════════════════╝${NC}"
    
                
    
                local failed_updates=()
    
                local success_updates=()
    
                
    
                # Opzione per specificare un singolo target
    
                if [ -n "${2:-}" ]; then
    
                    local target_name="$2"
    
                    if [ -z "${TARGETS[$target_name]:-}" ]; then
    
                        log_error "Unknown target: $target_name"
    
                        echo "Available targets: ${!TARGETS[@]}"
    
                        exit 1
    
                    fi
    
                    
    
                    local config="${TARGETS[$target_name]}"
    
                    
    
                    if update_flake "$target_name" "$config"; then
    
                        success_updates+=("$target_name")
    
                    else
    
                        failed_updates+=("$target_name")
    
                    fi
    
                else
    
                    # Update di tutti i target
    
                    for name in "${!TARGETS[@]}"; do
    
                        if update_flake "$name" "${TARGETS[$name]}"; then
    
                            success_updates+=("$name")
    
                        else
    
                            failed_updates+=("$name")
    
                        fi
    
                    done
    
                fi
    
                
    
                # Report finale
    
                echo ""
    
                echo -e "${BLUE}═══════════════════════════════════════════${NC}"
    
                echo -e "${BLUE}         UPDATE SUMMARY                    ${NC}"
    
                echo -e "${BLUE}═══════════════════════════════════════════${NC}"
    
                echo ""
    
                
    
                if [ ${#success_updates[@]} -gt 0 ]; then
    
                    echo -e "${GREEN}✅ Successfully updated (${#success_updates[@]}):${NC}"
    
                    for target in "${success_updates[@]}"; do
    
                        echo -e "   ${GREEN}●${NC} ${target}"
    
                    done
    
                    echo ""
    
                fi
    
                
    
                if [ ${#failed_updates[@]} -gt 0 ]; then
    
                    echo -e "${RED}❌ Failed updates (${#failed_updates[@]}):${NC}"
    
                    for target in "${failed_updates[@]}"; do
    
                        echo -e "   ${RED}●${NC} ${target}"
    
                    done
    
                    echo ""
    
                    exit 1
    
                fi
    
                
    
                log_success "All flakes updated successfully!"
    
                echo ""
    
                ;;
    
                
    
            build)
    
                echo -e "${BLUE}╔═══════════════════════════════════════════╗${NC}"
    
                echo -e "${BLUE}║   NixOS Distributed Rebuild Manager       ║${NC}"
    
                echo -e "${BLUE}╚═══════════════════════════════════════════╝${NC}"
    
                
    
                local failed_targets=()
    
                local success_targets=()
    
                
    
                # Opzione per specificare un singolo target
    
                if [ -n "${2:-}" ]; then
    
                    local target_name="$2"
    
                    if [ -z "${TARGETS[$target_name]:-}" ]; then
    
                        log_error "Unknown target: $target_name"
    
                        echo "Available targets: ${!TARGETS[@]}"
    
                        exit 1
    
                    fi
    
                    
    
                    if rebuild_target "${target_name}" "${TARGETS[$target_name]}"; then
    
                        success_targets+=("${target_name}")
    
                    else
    
                        failed_targets+=("${target_name}")
    
                    fi
    
                else
    
                    # Build di tutti i target
    
                    for name in "${!TARGETS[@]}"; do
    
                        if rebuild_target "${name}" "${TARGETS[$name]}"; then
    
                            success_targets+=("${name}")
    
                        else
    
                            failed_targets+=("${name}")
    
                        fi
    
                    done
    
                fi
    
                
    
                # Report finale
    
                echo ""
    
                echo -e "${BLUE}═══════════════════════════════════════════${NC}"
    
                echo -e "${BLUE}           BUILD SUMMARY                   ${NC}"
    
                echo -e "${BLUE}═══════════════════════════════════════════${NC}"
    
                echo ""
    
                
    
                if [ ${#success_targets[@]} -gt 0 ]; then
    
                    echo -e "${GREEN}✅ Successful builds (${#success_targets[@]}):${NC}"
    
                    for target in "${success_targets[@]}"; do
    
                        echo -e "   ${GREEN}●${NC} ${target}"
    
                    done
    
                    echo ""
    
                fi
    
                
    
                if [ ${#failed_targets[@]} -gt 0 ]; then
    
                    echo -e "${RED}❌ Failed builds (${#failed_targets[@]}):${NC}"
    
                    for target in "${failed_targets[@]}"; do
    
                        echo -e "   ${RED}●${NC} ${target}"
    
                    done
    
                    echo ""
    
                    exit 1
    
                fi
    
                
    
                log_success "All builds completed successfully!"
    
                echo ""
    
                log_info "Build logs saved in: ${BUILDS_DIR}"
    
                echo ""
    
                ;;
    
                
    
            status)
    
                show_status
    
                ;;
    
                
    
            cleanup)
    
                cleanup_builds "${2:-1}"
    
                ;;
    
            
    
            help|--help|-h)
    
                echo "Usage: $0 [command] [options]"
    
                echo ""
    
                echo "Commands:"
    
                echo "  (no args)         Open interactive menu"
    
                echo "  update [target]   Update flake(s) and commit changes"
    
                echo "  build [target]    Build target(s) (default)"
    
                echo "  status            Show build status"
    
                echo "  cleanup [N]       Clean old builds"
    
                echo "  help              Show this help"
    
                ;;
    
                
    
            *)
    
                log_error "Unknown command:     
    "
    
                echo "Use '$0 help' for usage information"
    
                exit 1
    
                ;;
    
        esac
    
    }
    
    
    
    if [ $# -eq 0 ]; then
    
        interactive_menu
    
    else
    
        main "$@"
    
    fi
