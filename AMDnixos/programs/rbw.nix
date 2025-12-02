{pkgs, ...}: {
  programs.rbw = {
    enable = true;
    settings = {
      email = "lorenzopasqui@gmail.com";
      base_url = "https://vault.pasqui.casa";
      pinentry = pkgs.pinentry-curses;
    };
  };
}
