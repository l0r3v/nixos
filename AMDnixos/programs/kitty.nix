{...}: {
  programs.kitty = {
    enable = true;
    settings = {
      enable_audio_bell = false;
      open_url_with = "default";
      url_prefixes = "file ftp ftps gemini git gopher http https irc ircs kitty mailto news sftp ssh";
      detect_urls = true;
      confirm_os_window_close = -1;
    };
  };
}
