{...}: {
  programs.zathura = {
    enable = true;
    mappings = {
      "<C-l>" = "feedkeys :blist <Tab>";
      "<C-m>" = "feedkeys :bmark";
    };
    options = {
      recolor = true;
      #enable copy to clipboard
      selection-clipboard = "clipboard";
    };
  };
}
