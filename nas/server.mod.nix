{
  insomniac.modules = [

    # dns server
    {
      # these hostnames return these ip addresses by the dns server.
      networking.hosts = {
        #"127.0.0.1" = [ "foo.bar.baz" ];
        "192.168.50.8" = [
          "jellyfin.local"
          "reader.local"
        ];
      };

      services.dnsmasq.enable = true;
      services.dnsmasq.alwaysKeepRunning = true;
      services.dnsmasq.settings.server = [
        "8.8.8.8"
        "1.1.1.1"
      ];
      services.dnsmasq.settings = {
        cache-size = 500;
      };
    }

    # nginx server
    {
      services.nginx = {
        enable = true;
        recommendedProxySettings = true;
        recommendedTlsSettings = true;
        # other Nginx options
        virtualHosts."jellyfin.local" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:8096";
            proxyWebsockets = true; # needed if you need to use WebSocket
            extraConfig =
              # required when the target is also TLS server with multiple hosts
              "proxy_ssl_server_name on;"
              +
                # required when the server wants to use HTTP Authentication
                "proxy_pass_header Authorization;";
          };
        };
      };
    }

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
