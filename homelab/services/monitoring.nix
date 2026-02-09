{ config, pkgs, ... }:

{
  services.prometheus = {
    enable = true;
    port = 9090;
    
    # Raccoglitori di metriche (Exporters)
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 9100;
      };
    };

    # Configurazione di scraping (chi ascoltare)
    scrapeConfigs = [
      {
        job_name = "homelab";
        static_configs = [{
          targets = [ "127.0.0.1:9100" ];
        }];
      }
    ];
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        # Indirizzo e porta di ascolto
        http_addr = "0.0.0.0";
        http_port = 3000;
      };
    };
  };
}
