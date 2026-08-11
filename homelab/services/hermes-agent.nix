{
  config,
  lib,
  pkgs,
  ...
}: let
  # Piper voice model — scaricato nel nix store
  piperItalianVoice =
    pkgs.runCommand "piper-voice-it_IT-paola-medium" {
      srcOnnx = pkgs.fetchurl {
        url = "https://huggingface.co/rhasspy/piper-voices/resolve/main/it/it_IT/paola/medium/it_IT-paola-medium.onnx";
        hash = "sha256-b8kYtaDqYTc4KDPd36Vnv/vmpQYMAgQ8hxku5ZwEIQw=";
      };
      srcJson = pkgs.fetchurl {
        url = "https://huggingface.co/rhasspy/piper-voices/resolve/main/it/it_IT/paola/medium/it_IT-paola-medium.onnx.json";
        hash = "sha256-rqGcCn/OKfvDWbk/EOeQKFRAHkyVri6jKK5RaxXSls8=";
      };
    } ''
      mkdir -p $out
      cp "$srcOnnx" $out/it_IT-paola-medium.onnx
      cp "$srcJson" $out/it_IT-paola-medium.onnx.json
    '';
in {
  sops.secrets = {
    "hermes/opencode_api" = {};
    "hermes/telegrambot_api" = {};
    "hermes/hass_token" = {};
    "hermes/forgejo_token" = {};
    "hermes/vault_pass" = {};
    "hermes/paperless_token" = {};
    "hermes/groq_key" = {};
    "hermes/sparky_key" = {};
    "hermes/mealie_token" = {};
    "hermes/strava_client_id" = {};
    "hermes/strava_client_secret" = {};
    "hermes/strava_access_token" = {};
    "hermes/strava_refresh_token" = {};
    "hermes/gemini_key" = {};
    "uptime_kuma/api_key" = {};
    "hermes/hevy_key" = {};
    "hermes/intervals_api_key" = {};
  };
  sops.templates."hermes-env".content = ''
    OPENCODE_GO_API_KEY=${config.sops.placeholder."hermes/opencode_api"}
    HASS_TOKEN=${config.sops.placeholder."hermes/hass_token"}
    HASS_URL=http://192.168.1.65:8123
    TELEGRAM_BOT_TOKEN=${config.sops.placeholder."hermes/telegrambot_api"}
    FORGEJO_ACCESS_TOKEN=${config.sops.placeholder."hermes/forgejo_token"}
    VAULTWARDEN_PASS=${config.sops.placeholder."hermes/vault_pass"}
    PAPERLESS_TOKEN=${config.sops.placeholder."hermes/paperless_token"}
    GROQ_API_KEY=${config.sops.placeholder."hermes/groq_key"}
    GEMINI_API_KEY=${config.sops.placeholder."hermes/gemini_key"}
    STRAVA_CLIENT_ID=${config.sops.placeholder."hermes/strava_client_id"}
    STRAVA_CLIENT_SECRET=${config.sops.placeholder."hermes/strava_client_secret"}
    STRAVA_ACCESS_TOKEN=${config.sops.placeholder."hermes/strava_access_token"}
    STRAVA_REFRESH_TOKEN=${config.sops.placeholder."hermes/strava_refresh_token"}
    UPTIME_KUMA_API_KEY=${config.sops.placeholder."uptime_kuma/api_key"}
    UPTIME_KUMA_URL=https://status.pasqui.casa
    SPARKYFITNESS_API_KEY=${config.sops.placeholder."hermes/sparky_key"}
    HEVY_API_KEY=${config.sops.placeholder."hermes/hevy_key"}
    INTERVALS_API_KEY=${config.sops.placeholder."hermes/intervals_api_key"}
    MEALIE_API_KEY=${config.sops.placeholder."hermes/mealie_token"}
    MEALIE_BASE_URL=https://ricette.pasqui.casa
    TERMINAL_ENV=local
  '';
  services.hermes-agent = {
    enable = true;
    addToSystemPackages = true;
    stateDir = "/home/hspasqui";
    user = "hspasqui";
    group = "users";
    createUser = false;
    settings = {
      model = {
        default = "deepseek-v4-flash";
        provider = "opencode-go";
        base_url = "https://opencode.ai/zen/go/v1";
        api_mode = "chat_completions";
      };
      display.language = "en";
      terminal.backend = "local";
      agent = {
        max_turns = 150;
        gateway_timeout = 1800;
      };
      compression = {
        enabled = true;
        threshold = 0.85;
        target_ratio = 0.2;
        protect_last_n = 20;
        hygiene_hard_message_limit = 400;
        protect_first_n = 3;
        abort_on_summary_failure = false;
        codex_gpt55_autoraise = true;
        summary_model = "deepseek-v4-pro";
        in_place = true;
      };
      stt = {
        enabled = true;
        provider = "groq";
      };
      tts = {
        provider = "piper-italian";
        use_gateway = true;
        providers = {
          piper-italian = {
            type = "command";
            command = "${pkgs.piper-tts}/bin/piper -m ${piperItalianVoice}/it_IT-paola-medium.onnx -f {output_path}.wav < {input_path} && ${pkgs.ffmpeg}/bin/ffmpeg -i {output_path}.wav -y -loglevel error -c:a libopus {output_path}";
            output_format = "ogg";
          };
        };
      };
      voice = {
        auto_tts = false;
      };
      auxiliary = {
        compression = {
          provider = "auto";
          model = "deepseek-v4-flash";
          timeout = 600;
        };
        web_extract = {
          provider = "groq";
          model = "llama-3.3-70b-versatile";
        };
        title_generation = {
          provider = "groq";
          model = "llama-3.3-70b-versatile";
        };
        vision = {
          provider = "gemini";
          model = "gemini-3-flash-preview";
        };
      };
      mcp_servers = {
        sparkyfitness = {
          url = "http://localhost:3004/mcp";
          headers = {
            Authorization = "Bearer \${SPARKYFITNESS_API_KEY}";
          };
        };
        mealie = {
          command = "${pkgs.mealie-mcp-server}/bin/mealie-mcp-server";
          env = {
            MEALIE_API_KEY = "\${MEALIE_API_KEY}";
            MEALIE_BASE_URL = "\${MEALIE_BASE_URL}";
          };
        };
        revolutx = {
          command = "${pkgs.nodejs}/bin/node";
          args = ["/home/hspasqui/revolut-x-api/mcp/dist/index.js"];
        };
        forgejo = {
          command = "${pkgs.forgejo-mcp}/bin/forgejo-mcp";
          env = {
            FORGEJO_URL = "https://forge.pasqui.casa";
            FORGEJO_ACCESS_TOKEN = "\${FORGEJO_ACCESS_TOKEN}";
          };
        };
        strava = {
          command = "${pkgs.nodejs}/bin/npx";
          args = ["-y" "@r-huijts/strava-mcp-server"];
          env = {
            STRAVA_CLIENT_ID = "\${STRAVA_CLIENT_ID}";
            STRAVA_CLIENT_SECRET = "\${STRAVA_CLIENT_SECRET}";
            STRAVA_ACCESS_TOKEN = "\${STRAVA_ACCESS_TOKEN}";
            STRAVA_REFRESH_TOKEN = "\${STRAVA_REFRESH_TOKEN}";
            ROUTE_EXPORT_PATH = "/home/hspasqui/workspace/strava-exports";
          };
        };
        intervalsicu = {
          command = "${pkgs.nodejs}/bin/npx";
          args = ["-y" "intervals-icu-mcp"];
          env = {
            INTERVALS_API_KEY = "\${INTERVALS_API_KEY}";
            INTERVALS_ATHLETE_ID = "i670124";
            TRANSPORT = "stdio";
          };
        };
      };
      telegram = {
        channel_prompts = {
          "1" = "Questo è il topic per domande rapide e conversazioni disparate. Rispondi in modo sintetico, diretto e in italiano naturale. Le conversazioni sono spesso brevi e scollegate: non forzare correlazioni con domande precedenti. Vai dritto al punto. Se la domanda meriterebbe un approfondimento in un altro topic (allenamento, studio, NixOS), accennalo brevemente.";
          "2" = "Sei un coach di triathlon data-driven. Prima di ogni risposta: verifica i dati reali da Strava, Intervals.icu, Hevy, SparkyFitness. Rispondi con numeri, non sensazioni. Sii proattivo: nota pattern, anticipa sovrallenamento, suggerisci aggiustamenti. Vincoli: ginocchio DX TA-GT 18mm.";
          "3" = "Assisti Lorenzo nello studio di Ingegneria Aerospaziale. Esami: Fisica Tecnica, Meccanica Applicata 1, Strutture, Elettrotecnica, Meccanica Applicata 2. Sii preciso e rigoroso: cita formule, definizioni, riferimenti. Costruisci continuità tra sessioni: ricorda cosa hai spiegato e dove eravate arrivati. Usa vault Obsidian (~/notes) e skill fisica-tecnica per materiale di riferimento. Italiano chiaro, accademico ma non pomposo.";
          "4" = "Assisti Lorenzo con NixOS, homelab e infrastruttura. Preferisce soluzioni dichiarative: ogni modifica nel repo ~/nixos, nei file .nix, mai comandi imperativi a mano. Hermes è NixOS-managed: niente `hermes config set`, si modifica hermes-agent.nix + deploy. Segreti via sops. Gateway: `systemctl restart hermes-agent` (MAI `hermes gateway restart`). 3 macchine: homelab, XPSnixos, AMDnixos. Servizi self-hosted: SparkyFitness, Mealie, Forgejo, Navidrome, Actual Budget, Kavita, Uptime Kuma. Proponi sempre la via dichiarativa. Tecnico, preciso, niente giri di parole.";
        };
      };
    };
    environmentFiles = [config.sops.templates."hermes-env".path];
    environment = {
      TELEGRAM_HOME_CHANNEL = "157797551";
      TELEGRAM_ALLOWED_USERS = "157797551";
    };
    extraDependencyGroups = ["messaging"];
  };
}
