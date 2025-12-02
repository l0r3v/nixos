{...}: {
  services.kanshi = {
    enable = false;

    # 1️⃣ Entrambi i monitor, portatile aperto
    profiles."dual-open".outputs = [
      {
        criteria = "eDP-1";
        position = "0,0";
      }
      {
        criteria = "DP-2";
        position = "1920,0";
        mode = "2560x1440@59.95";
      }
    ];

    # 2️⃣ Solo monitor esterno (portatile chiuso)
    profiles."external-only".outputs = [
      {
        criteria = "eDP-1";
        status = "disable";
      }
      {
        criteria = "DP-2";
        position = "0,0";
        mode = "2560x1440@59.95";
      }
    ];

    # 3️⃣ Solo schermo interno (niente cavo DP)
    profiles."internal-only".outputs = [
      {
        criteria = "eDP-1";
        position = "0,0";
      } # puoi aggiungere scale/mode se ti servono
    ];
  };
}
