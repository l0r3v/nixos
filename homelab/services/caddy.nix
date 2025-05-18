{...}:
{
  services.caddy = {
    enable = true;
    extraConfig = ''
      :1313 {
        root * /var/www/mysite
        file_server
      }
      '';
  };
}
