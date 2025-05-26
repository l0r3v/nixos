{...}: {
  services.nixos-cli = {
    enable = true;
    config = {
      aliases = {
        list = ["generation" "list"];
        switch = ["generation" "switch"];
        rollback = ["generation" "rollback"];
        delete = ["generation" "delete"];
        clean = ["generation" "delete" "-k" "3"];
        build = ["apply" "--no-activate" "--no-boot" "--output" "result"];
        opt = ["option" "-i"];
        test = ["apply" "--no-boot" "--no-activate"];
      };

      config_location = "/home/lorev/nixos/";
    };
  };
}
