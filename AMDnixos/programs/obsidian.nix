{
  pkgs,
  lib,
  ...
}: {
  programs.obsidian = {
    enable = true;
    vaults.Studio = {
      enable = true;
      settings = {
        communityPlugins = [
          # 1. LATEX SUITE
          (pkgs.fetchzip {
            url = "https://github.com/artisticat1/obsidian-latex-suite/releases/download/1.9.8/obsidian-latex-suite-1.9.8.zip";
            hash = "sha256-sg+GwsWfkczPgtMh+xkwd49+HLui755QRNe7RygLe18=";
          })

          # 2. REMOTELY SAVE
          (pkgs.runCommand "remotely-save" {} ''
            mkdir -p $out
            cp ${pkgs.fetchurl {
              url = "https://github.com/remotely-save/remotely-save/releases/download/0.5.25/main.js";
              hash = "sha256-s6+9J/FRiLl4RhjJWGB4abqkNNwKvPByd0+ZNiwR+gQ=";
            }} $out/main.js
            cp ${pkgs.fetchurl {
              url = "https://github.com/remotely-save/remotely-save/releases/download/0.5.25/manifest.json";
              hash = "sha256-cdnAthYAPzppaIDnqogpblsxVVdX6TOhLSkAuWxMqpA=";
            }} $out/manifest.json
            cp ${pkgs.fetchurl {
              url = "https://github.com/remotely-save/remotely-save/releases/download/0.5.25/styles.css";
              hash = "sha256-h1hOfVOMpYxSevuyYlsJ6igryue/eEt8zjPKkung37M=";
            }} $out/styles.css
          '')

          # 3. VIMRC SUPPORT
          (pkgs.runCommand "obsidian-vimrc-support" {} ''
            mkdir -p $out
            cp ${pkgs.fetchurl {
              url = "https://github.com/esm7/obsidian-vimrc-support/releases/download/0.10.1/main.js";
              hash = "sha256-E6Dn7winau0X5SB4VSiapkS0MXKV3qDVX4laZG8Oyrw=";
            }} $out/main.js
            cp ${pkgs.fetchurl {
              url = "https://github.com/esm7/obsidian-vimrc-support/releases/download/0.10.1/manifest.json";
              hash = "sha256-ZrGbYp+bVXlqPRUuUD5rg1SscYlhDGJ3fRt0bCKE/84=";
            }} $out/manifest.json
          '')
        ];
      };
    };
  };
}
