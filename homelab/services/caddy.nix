_: {
  services.caddy = {
    enable = false;
    extraConfig = ''
      :1313 {
        root * /var/www/mysite
        file_server
      }
    '';
  };
}
