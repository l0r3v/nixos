{config, ...}: {
  services.headscale = {
    enable = true;
    port = 5423;
    settings = {
      ip_prefixes = [
        "100.64.0.0/10"
      ];
      listen_addr = "0.0.0.0:5423";
      server_url = "https://headscale.pasqui.casa";
      dns = {
        base_domain = "pasqui.lan";
        nameservers.global = [
          "1.1.1.1" # Cloudflare
          "9.9.9.9" # Quad9
        ];
      };
    };
  };
}
