final: _prev: {
  factorio = final.callPackage ./factorio_overlay/package.nix {
    releaseType = "headless";
  };
}
