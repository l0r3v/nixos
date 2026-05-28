{pkgs, ...}: {
  # 1. Abilita Ollama con supporto ROCm per la tua Radeon RX 6700
  services.ollama = {
    enable = true;

    environmentVariables = {
      OLLAMA_NUM_PARALLEL = "1";
      # Sblocca questa variabile se Ollama non rileva la GPU nativamente:
      # HSA_OVERRIDE_GFX_VERSION = "10.3.0";
    };
  };

  systemd.services.ollama = {
    wantedBy = pkgs.lib.mkForce []; # Rimuove l'avvio automatico al boot
    serviceConfig = {
      Environment = "OLLAMA_KEEP_ALIVE=30s";
    };
  };

  # 2. Open WebUI (Interfaccia Grafica)
  services.open-webui = {
    enable = true;
    # Punta all'istanza locale di Ollama
    environment = {
      OLLAMA_BASE_URL = "http://127.0.0.1:11434";
      WEBUI_AUTH = false; # Disabilita il login se lo usi solo tu sul PC locale
      ENABLE_SIGNUP = false;
    };
  };

  # Anche Open WebUI non partirà al boot, lasciando il sistema leggero
  systemd.services.open-webui.wantedBy = pkgs.lib.mkForce [];

  # 3. Pacchetti utili e script di gestione rapida
  environment.systemPackages = [
    pkgs.ollama # Per avere il CLI 'ollama' a disposizione

    # Comodi script per accendere e spegnere tutto l'ambiente LLM al volo
    (pkgs.writeShellScriptBin "llm-start" ''
      echo "Avvio di Ollama e Open WebUI..."
      sudo systemctl start ollama open-webui
      echo "Pronto! Puoi scaricare e avviare DeepSeek con: ollama run deepseek-r1:8b"
      echo "Interfaccia web disponibile su: http://localhost:8080"
    '')

    (pkgs.writeShellScriptBin "llm-stop" ''
      echo "Arresto dell'ambiente LLM per liberare risorse..."
      sudo systemctl stop open-webui ollama
      echo "Risorse liberate al 100%."
    '')
  ];
}
