_: {
  programs.mpv = {
    enable = true;
    config = {
      gpu-api = "opengl";
      gpu-context = "wayland";
    };
  };
}
