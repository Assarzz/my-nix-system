/*
  No Imperative steps needed.
  You can reference data directories from the different services in the backup mod file if you want to back them up. This is not done automatically.
*/
let

  conf = import ./conf.nix;
  serverIP = conf.nasIP;
  servicesDataDir = conf.nasMountPoint;

  # IMPORTANT for some reason ios devices don't work with the .local extension so i use .an (assar network) instead
  # Domain names hardcoded but ports can be changed here.
  dns_domains = {
    "jellyfin.an" = "8096"; # default jellyfin port
    "kavita.an" = "8081";
    "forgejo.an" = "8082";
    "qbittorrent.an" = "8080";
    "audiobookshelf.an" = "8084";
  };
  excludeFromAutoGen = [
    "qbittorrent.an"
  ];
  # dnsmasq option format : -A, --address=/<domain>[/<domain>...]/[<ipaddr>]
  dns_addresses =
    "/" + builtins.concatStringsSep "/" ((builtins.attrNames dns_domains) ++ [ serverIP ]);
in
{
  insomniac.modules = [

    # dns server
    {
      # Clients connect to the dns server over these ports
      networking.firewall.allowedTCPPorts = [ 53 ];
      networking.firewall.allowedUDPPorts = [ 53 ];

      services.dnsmasq = {
        enable = true;
        alwaysKeepRunning = true;

        settings = {
          address = dns_addresses;
          cache-size = 500;

          # I don't know my isp's dns server ip so i just use the classics. My router's backup dns server uses my isp's dns automatically. it can be configured in the WAN settings.
          server = [
            "8.8.8.8" # google dns server
            "1.1.1.1" # cloudflare dns server
          ];
        };
      };

    }

    # nginx server
    (
      { lib, ... }:
      {
        # A benefit of using a reverse proxy is that i only need to is expose these ports on the firewall for all server services using nginx.
        networking.firewall.allowedTCPPorts = [
          80
          443
        ];

        services.nginx = {
          enable = true;
          recommendedProxySettings = true;
          recommendedTlsSettings = true;

          # virtual hosts that dont require any custom configuration.
          # Explanation for how nginx know what request to send to which port : so even though all the domains get turned into the same ip, after the browser has received the ip from the dns server of the specified domain it THEN creates its finished request to the nginx server in which the originally specified domain is included as the Host header, which presumably nginx maps to virtualHosts.
          virtualHosts = (
            builtins.mapAttrs (_: port: {
              enableACME = false;
              forceSSL = false;
              locations."/" = {
                # If you include extra after the domain name, you can add extra functionality. "/" is a catch all.
                proxyPass = "http://127.0.0.1:${port}";
                proxyWebsockets = true; # needed if you need to use WebSocket
                extraConfig =
                  # required when the target is also TLS server with multiple hosts
                  "proxy_ssl_server_name on;"
                  +
                    # required when the server wants to use HTTP Authentication
                    "proxy_pass_header Authorization;";
              };
            }) (lib.filterAttrs (name: _: !builtins.elem name excludeFromAutoGen) dns_domains)
          );
        };
      }
    )

    # jellyfin server
    (
      { config, ... }:
      {
        services.jellyfin = {
          enable = true;
          dataDir = "${servicesDataDir}/jellyfin";
          user = "jellyfin";
          group = "jellyfin";
        };
        users.users.jellyfin.extraGroups = [ "samba-media" ];
        # Jellyfin source code hardcodes the root dataDir to permissions 700, which would mean that no matter what another group would not be able to read files in that directory. However since jellyfin works by having paths to media and not store it itself, it does not matter.

      }
    )
    # kavita reader server
    (
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        # pkgs.runCommand : https://ryantm.github.io/nixpkgs/builders/trivial-builders/
        # The result is a path in the /nix/store, e.g., /nix/store/....-kavita-token-key
        kavitaTokenFile = pkgs.runCommand "kavita-token-key" { } ''
          head -c 64 /dev/urandom | base64 --wrap=0 > $out
        '';
      in
      {
        services.kavita = {
          enable = true;
          dataDir = "${servicesDataDir}/kavita";
          settings.Port = lib.toInt dns_domains."kavita.an";
          tokenKeyFile = kavitaTokenFile;

          # Add this block to fix the error
        };
        # Without this kavita fails to create this directory and fails with "cannot create regular file '/mnt/nas/share/kavita/config/appsettings.json': No such file or directory"
        systemd.services.kavita.preStart = lib.mkBefore ''
          mkdir -p ${config.services.kavita.dataDir}/config
        '';
        # Adds kavita user to users samba-media
        # This means that kavita will only ever be able to get its media from files with this group.
        users.users.kavita.extraGroups = [ "samba-media" ];
      }
    )

    (
      { lib, ... }:
      {
        services.audiobookshelf.enable = true;
        services.audiobookshelf.dataDir = "${servicesDataDir}/audiobookshelf";
        services.audiobookshelf.user = "audiobookshelf";
        services.audiobookshelf.group = "audiobookshelf";
        services.audiobookshelf.port = lib.toInt dns_domains."audiobookshelf.an";
        systemd.tmpfiles.rules = [
          "d ${servicesDataDir}/audiobookshelf 0755 audiobookshelf audiobookshelf -"
        ];
      }
    )

    # forgejo software forge server
    (
      { lib, config, ... }:
      let
        cfg = config.services.forgejo;
        srv = cfg.settings.server;
      in
      {

        services.forgejo = {
          enable = true;
          stateDir = "${servicesDataDir}/forgejo";
          database.type = "postgres";
          user = "forgejo";
          group = "forgejo";
          # Enable support for Git Large File Storage
          lfs.enable = true;
          settings = {
            server = {
              DOMAIN = "127.0.0.1"; # This should by all means be allowed to be localhost since i am using a reverse proxy, however for some reason the ssh/http link for cloning the repo uses this specified domain options which means that i will have to modify the cloning path manually.
              # You need to specify this to remove the port from URLs in the web UI.
              ROOT_URL = "https://${srv.DOMAIN}/";
              HTTP_PORT = lib.toInt dns_domains."forgejo.an";
            };
            # You can temporarily allow registration to create an admin user.
            service.DISABLE_REGISTRATION = false;
            # Add support for actions, based on act: https://github.com/nektos/act
            actions = {
              ENABLED = true;
              DEFAULT_ACTIONS_URL = "github";
            };
          };
        };
      }
    )

    # qbittorrent server
    {
      services.nginx.virtualHosts."qbittorrent.an" = {
        enableACME = false;
        forceSSL = false;
        locations."/" = {
          proxyPass = "http://192.168.100.11:${dns_domains."qbittorrent.an"}";
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
        internalInterfaces = [ "ve-+" ]; # This is a wildcard that tells the NAT system: "Watch for traffic coming from any interface that starts with ve-."
        externalInterface = "ens3";
        # Lazy IPv6 connectivity for the container
        enableIPv6 = true;
      };

      containers.qbittorrent = {
        autoStart = true; # Starts the container automatically when the host boots up.
        privateNetwork = true; # Creates a separate network namespace for the container, ensuring network isolation.

        # ip address of the virtual
        hostAddress = "192.168.100.10";
        localAddress = "192.168.100.11";
        hostAddress6 = "fc00::1";
        localAddress6 = "fc00::2";
        config =
          {
            lib,
            ...
          }:
          {

            services.qbittorrent = {
              enable = true;
              user = "qbittorrent";
              group = "qbittorrent";
              webuiPort = lib.toInt dns_domains."qbittorrent.an";
            };
            networking = {
              # This inner container must be accessible from the outside.
              firewall.allowedTCPPorts = [ (lib.toInt dns_domains."qbittorrent.an") ];

              # Use systemd-resolved inside the container
              # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
              # "Gemini: This is an important networking detail. It tells the container not to simply copy the host's DNS settings.
              # Instead, it runs its own DNS resolver (systemd-resolved) inside the container. This improves isolation and prevents certain network-related bugs."
              useHostResolvConf = lib.mkForce false;
            };

            services.resolved.enable = true;

            system.stateVersion = "25.05";

          };
      };
    }

  ];
}
