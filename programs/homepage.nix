{config, ...}: {
  sops.secrets = {
    "homepage/ha/key" = {};
    "homepage/ha/url" = {};
    "homepage/tailscale/key" = {};
    "homepage/tailscale/deviceid" = {};
    "homepage/immich/key" = {};
    "homepage/immich/url" = {};
    "homepage/gitea/key" = {};
    "homepage/gitea/url" = {};
    "homepage/miniflux/key" = {};
    "homepage/miniflux/url" = {};
    "homepage/uptimekuma/url" = {};
    "homepage/uptimekuma/slug" = {};
    "homepage/borg/key" = {};
  };
  sops.templates."homepage-dashboard.env".content = ''
    HOMEPAGE_VAR_TAILSCALE_KEY=${config.sops.placeholder."homepage/tailscale/key"}
    HOMEPAGE_VAR_TAILSCALE_DEVICE_ID=${config.sops.placeholder."homepage/tailscale/deviceid"}
    HOMEPAGE_VAR_GITEA_KEY=${config.sops.placeholder."homepage/gitea/key"}
    HOMEPAGE_VAR_GITEA_URL=${config.sops.placeholder."homepage/gitea/url"}
    HOMEPAGE_VAR_IMMICH_KEY=${config.sops.placeholder."homepage/immich/key"}
    HOMEPAGE_VAR_IMMICH_URL=${config.sops.placeholder."homepage/immich/url"}
    HOMEPAGE_VAR_MINIFLUX_KEY=${config.sops.placeholder."homepage/miniflux/key"}
    HOMEPAGE_VAR_MINIFLUX_URL=${config.sops.placeholder."homepage/miniflux/url"}
    HOMEPAGE_VAR_HA_KEY=${config.sops.placeholder."homepage/ha/key"}
    HOMEPAGE_VAR_HA_URL=${config.sops.placeholder."homepage/ha/url"}
    HOMEPAGE_VAR_UPTIMEKUMA_URL=${config.sops.placeholder."homepage/uptimekuma/url"}
    HOMEPAGE_VAR_UPTIMEKUMA_SLUG=${config.sops.placeholder."homepage/uptimekuma/slug"}
    HOMEPAGE_VAR_BORG_KEY=${config.sops.placeholder."homepage/borg/key"}
  '';

  services.homepage-dashboard = {
    enable = true;
    environmentFile = config.sops.templates."homepage-dashboard.env".path;

    settings = {
      title = "Homepage";
      theme = "dark";
      layout = {
        "homelab" = {
          style = "row";
          columns = 3;
        };
        "bookmarks" = {
          style = "row";
          columns = 3;
        };
      };
    };

    widgets = [
      {
        resources = {
          cpu = true;
          memory = true;
          disk = ["/" "/home/lorev/archive/"];
          units = "metric"; # o "imperial"
        };
        resources = {
        };
      }
      {
        search = {
          provider = "duckduckgo";
          target = "_blank";
        };
      }
      {
        openmeteo = {
          latitude = 45.0703; # Cambia con la tua posizione
          longitude = 7.6869;
          timezone = "Europe/Rome";
          units = "metric";
        };
      }
      {
        datetime = {
          format = "dd/MM/yyyy HH:mm";
          locale = "it-IT";
        };
      }
    ];
    services = [
      {
        bookmarks = [
          {
            "BorgBackups" = {
              icon = "borgmatic";
              href = "http://borgbase.com";
              description = "Borg Backups";
              widget = {
                type = "customapi";
                url = "https://api.borgbase.com/graphql";
                method = "POST";
                headers = {
                  Authorization = "Bearer {{HOMEPAGE_VAR_BORG_KEY}}";
                  Content-Type = "application/json";
                };
                requestBody = {
                  query = ''
                    {
                      repoList{
                        name
                        lastModified
                        currentUsage
                      }
                    }
                  '';
                };
                display = "list";
                mappings = [
                  {
                    field = "data.repoList.0.currentUsage";
                    label = "Immich";
                    format = "bytes";
                    scale = 1000000;
                    additionalField = {
                      field = "data.repoList.0.lastModified";
                      label = "Last Backup";
                      format = "relativeDate";
                      style = "short";
                    };
                  }
                  {
                    field = "data.repoList.1.currentUsage";
                    label = "Gitea";
                    format = "bytes";
                    scale = 1000000;
                    additionalField = {
                      field = "data.repoList.1.lastModified";
                      label = "Last Backup";
                      format = "relativeDate";
                      style = "short";
                    };
                  }
                  {
                    field = "data.repoList.2.currentUsage";
                    label = "Owncloud";
                    format = "bytes";
                    scale = 1000000;
                    additionalField = {
                      field = "data.repoList.2.lastModified";
                      label = "Last Backup";
                      format = "relativeDate";
                      style = "short";
                    };
                  }
                ];
              };
            };
          }
          {
            "Tailscale" = {
              icon = "tailscale";
              href = "https://login.tailscale.com/admin/machines";
              description = "tailscale network";
              widget = {
                type = "tailscale";
                deviceid = "{{HOMEPAGE_VAR_TAILSCALE_DEVICE_ID}}";
                key = "{{HOMEPAGE_VAR_TAILSCALE_KEY}}";
              };
            };
          }
        ];
      }
      {
        homelab = [
          {
            "Home Assistant" = {
              icon = "home-assistant";
              href = "{{HOMEPAGE_VAR_HA_URL}}";
              description = "Controllo domotico";
              widget = {
                type = "homeassistant";
                url = "{{HOMEPAGE_VAR_HA_URL}}";
                key = "{{HOMEPAGE_VAR_HA_KEY}}";
                custom = {
                  template = "{{ states.switch|selectattr('state','equalto','on')|list|length }}";
                  label = "switches on";
                };
              };
            };
          }

          {
            "Miniflux" = {
              icon = "miniflux";
              href = "{{HOMEPAGE_VAR_MINIFLUX_URL}}";
              description = "RSS feed";
              widget = {
                type = "miniflux";
                url = "{{HOMEPAGE_VAR_MINIFLUX_URL}}";
                key = "{{HOMEPAGE_VAR_MINIFLUX_KEY}}";
              };
            };
          }

          {
            "UptimeKuma" = {
              icon = "uptime-kuma";
              href = "{{HOMEPAGE_VAR_UPTIMEKUMA_URL}}";
              description = "Homelab Status";
              widget = {
                type = "uptimekuma";
                url = "{{HOMEPAGE_VAR_UPTIMEKUMA_URL}}";
                slug = "{{HOMEPAGE_VAR_UPTIMEKUMA_SLUG}}";
              };
            };
          }
          {
            "Immich" = {
              icon = "immich";
              href = "{{HOMEPAGE_VAR_IMMICH_URL}}";
              widget = {
                type = "immich";
                url = "{{HOMEPAGE_VAR_IMMICH_URL}}";
                key = "{{HOMEPAGE_VAR_IMMICH_KEY}}";
                version = 2;
              };
            };
          }

          {
            "Gitea" = {
              icon = "gitea";
              href = "{{HOMEPAGE_VAR_GITEA_URL}}";
              widget = {
                type = "gitea";
                url = "{{HOMEPAGE_VAR_GITEA_URL}}";
                key = "{{HOMEPAGE_VAR_GITEA_KEY}}";
              };
            };
          }
        ];
      }
    ];
  };
}
