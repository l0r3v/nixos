{
  config,
  pkgs,
  ...
}: let
  user = "lorev";
in {
  # =================================================================
  # MODULO VACANZE: Tailscale, Sunshine, Autologin & SSH
  # =================================================================

  # Considera l'interfaccia di Tailscale "sicura" per il firewall
  networking.firewall.trustedInterfaces = ["tailscale0"];

  # Apri le porte necessarie per Sunshine (per LAN o Direct Connect)
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [47984 47989 47990 48010];
    allowedUDPPorts = [47998 47999 48000 48002 48010];
  };

  # --- 2. ACCESSO DI EMERGENZA (SSH) ---
  services.openssh = {
    enable = true;
    # Per sicurezza massima usa le chiavi SSH.
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  # --- 3. AUTOLOGIN (Per avviare l'interfaccia grafica al boot) ---
  # Necessario affinché Sunshine parta senza che nessuno sia fisicamente davanti al PC
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = user;

  # Workaround per GDM: evita che il servizio di login vada in loop con l'autologin
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # --- 4. SUNSHINE (Streaming Desktop) ---
  environment.systemPackages = [pkgs.sunshine];

  # Permessi Kernel/Udev per simulare Mouse/Tastiera virtuali
  boot.kernelModules = ["uinput"];
  services.udev.extraRules = ''
    KERNEL=="uinput", SUBSYSTEM=="misc", OPTIONS+="static_node=uinput", TAG+="uaccess"
  '';

  # Servizio Utente: Avvia Sunshine automaticamente DOPO il login grafico
  systemd.user.services.sunshine = {
    description = "Sunshine Game Stream Server";
    wantedBy = ["graphical-session.target"];
    partOf = ["graphical-session.target"];

    serviceConfig = {
      ExecStart = "${pkgs.sunshine}/bin/sunshine";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
}
