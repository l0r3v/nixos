{lib, ...}: {
  programs.qutebrowser.keyBindings = {
    normal = {
      "xx" = "hint links spawn --detach mpv {hint-url}";
      "ò" = "cmd-set-text :";
      "xo" = "cmd-set-text -s :open -bs";
      "wo" = "cmd-set-text -s :open -ws";
      "ga" = "open -t";
      "d" = "tab-close";
      "D" = "tab-only";
      "PP" = "open -ts -- {primary}";
      "pp" = "open -s -- {primary}";
      "Pp" = "open -ws -- {primary}";
      "pP" = "open -bs -- {primary}";
      "o" = "cmd-set-text -s :open -s ";
      "O" = "cmd-set-text -s :open -ts ";
      "co" = "spawn -u open_download";
      "<Ctrl-v>" = lib.mkMerge [
        "config-cycle tabs.show never always"
        "config-cycle statusbar.show in-mode always"
        "config-cycle scrolling.bar never always"
      ];
      "tt" = lib.mkMerge [
        "config-cycle colors.webpage.darkmode.enabled true false"
      ];
    };
    prompt = {
      "<Ctrl-y>" = "prompt-yes";
    };
  };
}
