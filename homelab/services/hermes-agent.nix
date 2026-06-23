{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Piper voice model — scaricato nel nix store
  piperItalianVoice = pkgs.runCommand "piper-voice-it_IT-paola-medium" {
    srcOnnx = pkgs.fetchurl {
      url = "https://huggingface.co/rhasspy/piper-voices/resolve/main/it/it_IT/paola/medium/it_IT-paola-medium.onnx";
      hash = "sha256-b8kYtaDqYTc4KDPd36Vnv/vmpQYMAgQ8hxku5ZwEIQw=";
    };
    srcJson = pkgs.fetchurl {
      url = "https://huggingface.co/rhasspy/piper-voices/resolve/main/it/it_IT/paola/medium/it_IT-paola-medium.onnx.json";
      hash = "sha256-rqGcCn/OKfvDWbk/EOeQKFRAHkyVri6jKK5RaxXSls8=";
    };
  } ''
    mkdir -p $out
    cp "$srcOnnx" $out/it_IT-paola-medium.onnx
    cp "$srcJson" $out/it_IT-paola-medium.onnx.json
  '';
in {
  sops.secrets = {
    "hermes/opencode_api" = {};
    "hermes/telegrambot_api" = {};
    "hermes/hass_token" = {};
    "hermes/forgejo_token" = {};
    "hermes/vault_pass" = {};
    "hermes/paperless_token" = {};
    "hermes/groq_key" = {};
    "hermes/sparky_key" = {};
    "uptime_kuma/api_key" = {};
  };
  sops.templates."hermes-env".content = ''
    OPENCODE_GO_API_KEY=${config.sops.placeholder."hermes/opencode_api"}
    HASS_TOKEN=${config.sops.placeholder."hermes/hass_token"}
    HASS_URL=http://192.168.1.65:8123
    TELEGRAM_BOT_TOKEN=${config.sops.placeholder."hermes/telegrambot_api"}
    FORGEJO_TOKEN=${config.sops.placeholder."hermes/forgejo_token"}
    VAULTWARDEN_PASS=${config.sops.placeholder."hermes/vault_pass"}
    PAPERLESS_TOKEN=${config.sops.placeholder."hermes/paperless_token"}
    GROQ_API_KEY=${config.sops.placeholder."hermes/groq_key"}
    UPTIME_KUMA_API_KEY=${config.sops.placeholder."uptime_kuma/api_key"}
    UPTIME_KUMA_URL=https://status.pasqui.casa
    SPARKYFITNESS_API_KEY=${config.sops.placeholder."hermes/sparky_key"}
    TERMINAL_ENV=local
  '';
  services.hermes-agent = {
    enable = true;
    addToSystemPackages = true;
    stateDir = "/home/hspasqui";
    user = "hspasqui";
    group = "users";
    createUser = false;
    settings = {
      model = {
        default = "deepseek-v4-flash";
        provider = "opencode-go";
        base_url = "https://opencode.ai/zen/go/v1";
        api_mode = "chat_completions";
      };
      display.language = "en";
      terminal.backend = "local";
      agent = {
        max_turns = 150;
        gateway_timeout = 1800;
      };
      stt = {
        enabled = true;
        provider = "groq";
      };
      tts = {
        provider = "piper-italian";
        use_gateway = true;
        providers = {
          piper-italian = {
            type = "command";
            command = "${pkgs.piper-tts}/bin/piper -m ${piperItalianVoice}/it_IT-paola-medium.onnx -f {output_path}.wav < {input_path} && ${pkgs.ffmpeg}/bin/ffmpeg -i {output_path}.wav -y -loglevel error -c:a libopus {output_path}";
            output_format = "ogg";
          };
        };
      };
      voice = {
        auto_tts = false;
      };
      mcp_servers = {
        sparkyfitness = {
          url = "http://localhost:3002/mcp";
          headers = {
            Authorization = "Bearer \${SPARKYFITNESS_API_KEY}";
          };
        };
      };
    };
    environmentFiles = [config.sops.templates."hermes-env".path];
    environment = {
      TELEGRAM_HOME_CHANNEL = "157797551";
      TELEGRAM_ALLOWED_USERS = "157797551";
    };
    extraDependencyGroups = ["messaging"];
  };
}
