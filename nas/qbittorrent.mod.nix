{
  insomniac.modules =
    let
      port = 8080;
    in
    [
      {
        services.nginx.virtualHosts."qbittorrent.an" = {
          enableACME = false;
          forceSSL = false;
          locations."/" = {
            proxyPass = "http://192.168.100.11:${builtins.toString port}";
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
              config,
              lib,
              pkgs,
              ...
            }:
            {

              services.qbittorrent = {
                enable = true;
                inherit port;
              };
              imports = [ ./qbittorrent-options.nix ];
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

            };
        };
      }
    ];
}
