{...}: {
  programs.ghostty = {
    enable = true;
    settings = {
      confirm-close-surface = true;
      quit-after-last-window-closed-delay = "1h";
    };
  };
}
