{
  config,
  pkgs,
  ...
}: {
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    theme = let
      # Use `mkLiteral` for string-like values that should show without
      # quotes, e.g.:
      # {
      #   foo = "abc"; => foo: "abc";
      #   bar = mkLiteral "abc"; => bar: abc;
      # };
      inherit (config.lib.formats.rasi) mkLiteral;
    in {
      "#inputbar" = {
        children = map mkLiteral ["prompt" "entry" "textbox-prompt-colon" "case-indicator"];
      };

      "#textbox-prompt-colon" = {
        expand = false;
        str = ":";
        margin = mkLiteral "0px 0.3em 0em 0em";
      };
      "#listview" = {
        fixed-height = 0;
        border = mkLiteral "2px 0px 0px";
        spacing = "2px";
        scrollbar = true;
        padding = mkLiteral "2px 0px 0px";
      };
    };
  };
}
