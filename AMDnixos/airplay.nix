{pkgs, ...}: {
  services.avahi = {
    enable = true;
    nssmdns4 = true; # Risoluzione dei nomi di dominio .local
    publish = {
      enable = true;
      userServices = true;
    };
  };

  # 2. Installa il pacchetto UxPlay
  environment.systemPackages = with pkgs; [
    uxplay
  ];

  # 3. Apri le porte del firewall necessarie per AirPlay e mDNS
  networking.firewall.allowedTCPPorts = [7000 7001 7100];
  networking.firewall.allowedUDPPorts = [5353 7000 7001 7100];
}
