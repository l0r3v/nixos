{...}: {
  services.wyoming.piper = {
    servers.piper = {
      enable = true;
      voice = "it_IT-paola-medium";
      uri = "tcp://0.0.0.0:10200";
      # Zeroconf attivo così HA lo scopre automaticamente
      zeroconf = {
        enable = true;
        name = "piper-homelab";
      };
    };
  };
}
