{...}: {
  nix = {
    gc = {
      automatic = true;
      dates = "Mon *-*-* 05:00:00";
      options = "--delete-older-than +3";
    };
    optimise = {
      automatic = true;
      persistent = true;
      dates = "6:00";
    };
  };
}
