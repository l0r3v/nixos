{lib, ...}: {
  services.postgresql = {
    enable = true;
    settings = {
      max_connections = 300;
      shared_buffers = "4GB";
    };
    authentication = lib.mkForce ''
      # TYPE  DATABASE        USER            ADDRESS                 METHOD

      local   all             all                                     peer

      host    all             all             127.0.0.1/32            scram-sha-256
      host    all             all             ::1/128                 scram-sha-256
    '';
  };
}
