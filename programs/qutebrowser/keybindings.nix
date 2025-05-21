{lib, ...}: {
  programs.qutebrowser.keyBindings = {
    normal = {
      "X" = "hint links spawn --detach mpv {hint-url}";
      "ò" = "cmd-set-text :";
      "xo" = "cmd-set-text -s :open -b";
      "wo" = "cmd-set-text -s :open -w";
      "ga" = "open -t";
      "d" = "tab-close";
      "D" = "tab-only";
      "PP" = "open -t -- {clipboard}";
      "pp" = "open -- {clipboard}";
      "Pp" = "open -t -- {primary}";
      "pP" = "open -- {primary}";
      "o" = "cmd-set-text -s :open -s ";
      "O" = "cmd-set-text -s :open -ts ";
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
