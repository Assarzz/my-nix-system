{
  insomniac.modules =
    let
      port = "8080";
    in
    [

      {

        services.nginx.virtualHosts."qbittorrent.an" = {
          enableACME = false;
          forceSSL = false;
          locations."/" = {
            proxyPass = "http://192.168.100.11:${port}";
            proxyWebsockets = true; # needed if you need to use WebSocket
            extraConfig =
              # required when the target is also TLS server with multiple hosts
              "proxy_ssl_server_name on;"
              +
                # required when the server wants to use HTTP Authentication
                "proxy_pass_header Authorization;";
          };
        };
        networking.nat = {
          enable = true;
          internalInterfaces = [ "ve-+" ];
          externalInterface = "ens3";
          # Lazy IPv6 connectivity for the container
          enableIPv6 = true;
        };

        containers.qbittorrent = {
          autoStart = true; # Starts the container automatically when the host boots up.
          privateNetwork = true; # Creates a separate network namespace for the container, ensuring network isolation.

          # ip address of the virtual network
          hostAddress = "192.168.100.10";
          localAddress = "192.168.100.11";
          hostAddress6 = "fc00::1";
          localAddress6 = "fc00::2";
          config =
            {
              config,
              lib,
              pkgs,
              ...
            }:

            with lib;

            let
              cfg = config.services.qbittorrent;
              UID = 888;
              GID = 888;
            in
            {

              services.qbittorrent = {
                enable = true;
                inherit port;
              };

              networking = {
                firewall.allowedTCPPorts = [ port ];

                # Use systemd-resolved inside the container
                # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
                # "Gemini: This is an important networking detail. It tells the container not to simply copy the host's DNS settings.
                # Instead, it runs its own DNS resolver (systemd-resolved) inside the container. This improves isolation and prevents certain network-related bugs."
                useHostResolvConf = lib.mkForce false;
              };

              services.resolved.enable = true;

              system.stateVersion = "24.11";

            # Qbittorrent option setup. Code from: https://github.com/pceiley/nix-config/blob/3854c687d951ee3fe48be46ff15e8e094dd8e89f/hosts/common/modules/qbittorrent.nix
              options.services.qbittorrent = {
                enable = mkEnableOption (lib.mdDoc "qBittorrent headless");

                dataDir = mkOption {
                  type = types.path;
                  default = "/var/lib/qbittorrent";
                  description = lib.mdDoc ''
                    The directory where qBittorrent stores its data files.
                  '';
                };

                user = mkOption {
                  type = types.str;
                  default = "qbittorrent";
                  description = lib.mdDoc ''
                    User account under which qBittorrent runs.
                  '';
                };

                group = mkOption {
                  type = types.str;
                  default = "qbittorrent";
                  description = lib.mdDoc ''
                    Group under which qBittorrent runs.
                  '';
                };

                port = mkOption {
                  type = types.port;
                  default = 8080;
                  description = lib.mdDoc ''
                    qBittorrent web UI port.
                  '';
                };

                openFirewall = mkOption {
                  type = types.bool;
                  default = false;
                  description = lib.mdDoc ''
                    Open services.qBittorrent.port to the outside network.
                  '';
                };

                package = mkOption {
                  type = types.package;
                  default = pkgs.qbittorrent-nox;
                  defaultText = literalExpression "pkgs.qbittorrent-nox";
                  description = lib.mdDoc ''
                    The qbittorrent package to use.
                  '';
                };
              };

              config = mkIf cfg.enable {
                networking.firewall = mkIf cfg.openFirewall {
                  allowedTCPPorts = [ cfg.port ];
                };

                systemd.services.qbittorrent = {
                  # based on the plex.nix service module and
                  # https://github.com/qbittorrent/qBittorrent/blob/master/dist/unix/systemd/qbittorrent-nox%40.service.in
                  description = "qBittorrent-nox service";
                  documentation = [ "man:qbittorrent-nox(1)" ];
                  after = [ "network.target" ];
                  wantedBy = [ "multi-user.target" ];

                  serviceConfig = {
                    Type = "simple";
                    User = cfg.user;
                    Group = cfg.group;

                    # Run the pre-start script with full permissions (the "!" prefix) so it
                    # can create the data directory if necessary.
                    ExecStartPre =
                      let
                        preStartScript = pkgs.writeScript "qbittorrent-run-prestart" ''
                          #!${pkgs.bash}/bin/bash

                          # Create data directory if it doesn't exist
                          if ! test -d "$QBT_PROFILE"; then
                            echo "Creating initial qBittorrent data directory in: $QBT_PROFILE"
                            install -d -m 0755 -o "${cfg.user}" -g "${cfg.group}" "$QBT_PROFILE"
                          fi
                        '';
                      in
                      "!${preStartScript}";

                    #ExecStart = "${pkgs.qbittorrent-nox}/bin/qbittorrent-nox";
                    ExecStart = "${cfg.package}/bin/qbittorrent-nox";
                    # To prevent "Quit & shutdown daemon" from working; we want systemd to
                    # manage it!
                    #Restart = "on-success";
                    #UMask = "0002";
                    #LimitNOFILE = cfg.openFilesLimit;
                  };

                  environment = {
                    QBT_PROFILE = cfg.dataDir;
                    QBT_WEBUI_PORT = toString cfg.port;
                  };
                };

                users.users = mkIf (cfg.user == "qbittorrent") {
                  qbittorrent = {
                    group = cfg.group;
                    uid = UID;
                  };
                };

                users.groups = mkIf (cfg.group == "qbittorrent") {
                  qbittorrent = {
                    gid = GID;
                  };
                };
              };
            };
        };
      }
    ];
}
