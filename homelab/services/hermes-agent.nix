{config, ...}: {
  sops.secrets = {
    "hermes/opencode_api" = {};
    "hermes/telegrambot_api" = {};
    "hermes/hass_token" = {};
  };
  sops.templates."hermes-env".content = ''
    OPENCODE_GO_API_KEY=${config.sops.placeholder."hermes/opencode_api"}
    HASS_TOKEN=${config.sops.placeholder."hermes/hass_token"}
    TELEGRAM_BOT_TOKEN=${config.sops.placeholder."hermes/telegrambot_api"}
    TERMINAL_ENV=local
  '';
  services.hermes-agent = {
    enable = true;
    addToSystemPackages = true;
    settings.model = {
      default = "qwen3.7-plus";
      provider = "opencode-go";
      base_url = "https://opencode.ai/zen/go/v1";
      api_mode = "chat_completions";
    };
    environmentFiles = [config.sops.templates."hermes-env".path];

    extraDependencyGroups = ["messaging"];
  };
}
