{
  config,
  lib,
  ...
}: let
  cfg = config.modules.programs.obsidian;
in {
  options.modules.programs.obsidian = {
    enable = lib.mkEnableOption "Whether to install obsidian";
  };
  config = lib.mkIf cfg.enable {
    home-manager.users.lorev = {pkgs, ...}: {
      programs.obsidian = {
        enable = true;
        vaults.Studio = {
          enable = true;
          settings = {
            app = {
              showLineNumber = true;
              vimMode = true;
              newFileLocation = "current";
            };
            appearance = {
              baseFontSize = 16;
              enabledCssSnippets = [
                "Stylix Config"
              ];
              interfaceFontFamily = "Courier New";
              textFontFamily = "Courier New";
              monospaceFontFamily = "Courier New";
            };
            communityPlugins = [
              # --- 1. LATEX SUITE ---
              {
                enable = true;
                pkg = pkgs.fetchzip {
                  url = "https://github.com/artisticat1/obsidian-latex-suite/releases/download/1.9.8/obsidian-latex-suite-1.9.8.zip";
                  hash = "sha256-sg+GwsWfkczPgtMh+xkwd49+HLui755QRNe7RygLe18=";
                };
                settings = {
                  snippetsEnabled = true;
                  snippetsTrigger = "Tab";
                  suppressSnippetTriggerOnIME = true;
                  removeSnippetWhitespace = true;
                  loadSnippetsFromFile = true;
                  loadSnippetVariablesFromFile = true;
                  snippetsFileLocation = "latex_snippets";
                  snippetVariablesFileLocation = "latex_snippets_var";
                  concealEnabled = true;
                  concealRevealTimeout = 0;
                  colorPairedBracketsEnabled = true;
                  highlightCursorBracketsEnabled = true;
                  mathPreviewEnabled = true;
                  mathPreviewPositionIsAbove = true;
                  autofractionEnabled = true;
                  autofractionSymbol = "\\frac";
                  autofractionBreakingChars = "+-=\t";
                  matrixShortcutsEnabled = true;
                  taboutEnabled = true;
                  autoEnlargeBrackets = true;
                  wordDelimiters = "., +-\\n\t:;!?\\/{}[]()=~$";
                  autofractionExcludedEnvs = "[\n\t\t[\"^{\", \"}\"],\n\t\t[\"\\\\pu{\", \"}\"]\n\t]";
                  matrixShortcutsEnvNames = "pmatrix, cases, align, gather, bmatrix, Bmatrix, vmatrix, Vmatrix, array, matrix";
                  autoEnlargeBracketsTriggers = "sum, int, frac, prod, bigcup, bigcap";
                  forceMathLanguages = "math";
                };
              }

              # --- 2. REMOTELY SAVE ---
              {
                enable = true;
                pkg = pkgs.runCommand "remotely-save" {} ''
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
                '';
              }

              # --- 3. VIMRC SUPPORT ---
              {
                enable = true;
                pkg = pkgs.runCommand "obsidian-vimrc-support" {} ''
                  mkdir -p $out
                  cp ${pkgs.fetchurl {
                    url = "https://github.com/esm7/obsidian-vimrc-support/releases/download/0.10.1/main.js";
                    hash = "sha256-E6Dn7winau0X5SB4VSiapkS0MXKV3qDVX4laZG8Oyrw=";
                  }} $out/main.js
                  cp ${pkgs.fetchurl {
                    url = "https://github.com/esm7/obsidian-vimrc-support/releases/download/0.10.1/manifest.json";
                    hash = "sha256-ZrGbYp+bVXlqPRUuUD5rg1SscYlhDGJ3fRt0bCKE/84=";
                  }} $out/manifest.json
                '';
                settings = {
                  vimrcFileName = ".obsidian.vimrc";
                  displayChord = true;
                  displayVimMode = true;
                  fixedNormalModeLayout = false;
                  capturedKeyboardMap = {};
                  supportJsCommands = false;
                  vimStatusPromptMap = {
                    "normal" = "🟢";
                    "insert" = "🟠";
                    "visual" = "🟡";
                    "replace" = "🔴";
                  };
                };
              }
            ];
          };
        };
      };
    };
  };
}
