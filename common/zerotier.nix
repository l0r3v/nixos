{config, ...}: {
  services.zerotierone = {
    enable = true;
    joinNetworks = [
      "E3918DB4838B3BBC"
    ];
  };
}
