{...}: {
  services.ntfy-sh = {
    enable = true;
    settings = {
      listen-http = ":3434";
      base-url = "https://ntfy.pasqui.casa";
    };
  };
}
