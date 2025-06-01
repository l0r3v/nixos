{pkgs, ...}: {
  programs.mpv = {
    enable = true;
    config = {
      gpu-api = "opengl";
      gpu-context = "wayland";
    };
    package = (
      pkgs.mpv-unwrapped.wrapper {
        scripts = with pkgs.mpvScripts; [
          uosc
          sponsorblock
          skipsilence
        ];

        mpv = pkgs.mpv-unwrapped.override {
          waylandSupport = true;
        };
      }
    );
  };
}
