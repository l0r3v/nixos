{lib, ...}: {
  programs.qutebrowser = {
    enable = true;
    searchEngines = {
      w = "https://en.wikipedia.org/wiki/Special:Search?search={}&go=Go&ns0=1";
      aw = "https://wiki.archlinux.org/?search={}";
      nw = "https://wiki.nixos.org/index.php?search={}";
      g = "https://www.google.com/search?hl=it&q={}";
      ddg = "https://duckduckgo.com/?t=h_&q={}";
      np = "https://search.nixos.org/packages?type=packages&query={}";
      mynix = "https://mynixos.com/search?q={}";
    };
    keyBindings = {
      normal = {
        "X" = "hint links spawn mpv {hint-url}";
        "ò" = "cmd-set-text :";
        "<Ctrl-v>" = lib.mkMerge [
          "config-cycle tabs.show never always"
          "config-cycle statusbar.show in-mode always"
          "config-cycle scrolling.bar never always"
        ];
      };
      prompt = {
        "<Ctrl-y>" = "prompt-yes";
      };
    };
    settings = {
      colors.webpage.darkmode.enabled = true;
      statusbar.show = "in-mode";
      completion = {
        height = "20%";
        show = "auto";
      };
      auto_save.session = true;
      editor.command = ["alacritty" "-e" "vim" "{file}"];
      input = {
        media_keys = true;
        mode_override = "normal";
      };
      tabs = {
        close_mouse_button_on_bar = "ignore";
      };
      url = {
        start_pages = "http://localhost:8082";
      };
      confirm_quit = ["always"];
    };
  };
}
