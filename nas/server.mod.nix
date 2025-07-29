{
  insomniac.modules = [

    # dns server
    {
      # Clients connect to the dns server over these ports
      networking.firewall.allowedTCPPorts = [ 53 ];
      networking.firewall.allowedUDPPorts = [ 53 ];
      networking.hosts = {
        #"127.0.0.1" = [ "foo.bar.baz" ];

        # IMPORTANT for some reason ios devices don't work with the .local extension so i use .an (assar network) instead
        "192.168.50.8" = [
          "jellyfin.an"
          "reader.an"
          "qbittorrent.an"
        ];
      };

      services.dnsmasq.enable = true;
      services.dnsmasq.alwaysKeepRunning = true;

      # I don't know my isp's dns server ip so i just use the classics. My router's backup dns server uses my isp's dns automatically. it can be configured in the WAN settings.
      services.dnsmasq.settings.server = [
        "8.8.8.8" # google dns server
        "1.1.1.1" # cloudflare dns server
      ];
      services.dnsmasq.settings = {
        cache-size = 500;
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
          # other Nginx options
          virtualHosts =
            let
              domains = {
                "jellyfin.an" = "8096"; # default jellyfin port
                "reader.an" = "8081";
                
              };
            in
            (builtins.mapAttrs (_: port: {
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
            }) domains);
        };
      }
    )

    # jellyfin server
    (
      { pkgs, ... }:
      {
        services.jellyfin.enable = true;
        environment.systemPackages = [
          pkgs.jellyfin
          pkgs.jellyfin-web
          pkgs.jellyfin-ffmpeg
        ];
      }
    )
  ];
}
