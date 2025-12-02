{...}: {
  programs.thunderbird = {
    enable = true;
    profiles = {
      lorev = {
        isDefault = true;
      };
    };
  };
}
