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
    "komga.an" = "8085";
    "calibre.an" = "8883";
  };
  excludeFromAutoGen = [
    "qbittorrent.an"
    "calibre.an"
    "forgejo.an"
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
        # A benefit of using a reverse proxy is that i only need to expose these ports on the firewall because all requests to server services go via nginx, and then over localhost to reach the services.
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

              # If you include extra after the domain name, you can add extra functionality. "/" is a catch all.
              locations."/" = {
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
          user = "jellyfin";
          group = "jellyfin";
        };
        users.users.jellyfin.extraGroups = [ "samba-general" ];
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
        # Adds kavita user to users samba-general
        # This means that kavita will only ever be able to get its media from files with this group.
        users.users.kavita.extraGroups = [ "samba-general" ];
      }
    )

    (
      { lib, ... }:
      let
        web_data_dir = "calibre-web";
      in
      {
        services.calibre-web = {
          enable = true;

          dataDir = web_data_dir;
          listen = {
            port = lib.toInt dns_domains."calibre.an";
            ip = "127.0.0.1";
          };

          options = {
            enableBookUploading = true;
          };
        };
        services.nginx.virtualHosts."calibre.an" = {
          enableACME = false;
          forceSSL = false;

          # If you include extra after the domain name, you can add extra functionality. "/" is a catch all.
          locations."/" = {
            proxyPass = "http://127.0.0.1:${dns_domains."calibre.an"}";
            proxyWebsockets = true; # needed if you need to use WebSocket
            extraConfig =
              # required when the target is also TLS server with multiple hosts
              "proxy_ssl_server_name on;"
              +
                # required when the server wants to use HTTP Authentication
                "proxy_pass_header Authorization;"

              # No limit to how large files i can pass. Before this, i got an error where i could not upload large files to calibre.
              + "client_max_body_size 0;";
          };
        };
      }

    )

    # forgejo software forge server
    (
      { lib, config, ... }:
      let
        cfg = config.services.forgejo;
        srv = cfg.settings.server;
        forgejoan = "forgejo.an";
      in
      {

        # We don't have it behind nginx because then the DOMAIN would technically be localhost, which forgejo uses to generate git clone urls, which would not work outside the nas, i can't clone or push with ssh://forgejo@127.0.0.1/assar/testerdel.git
        # We need to open ports in the firewall since we aren't using nginx reverse proxy for forgejo.
        networking.firewall.allowedTCPPorts = [
          lib.toInt dns_domains.${forgejoan}
        ];
        networking.firewall.allowedUDPPorts = [
          lib.toInt dns_domains.${forgejoan}
        ];
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
              DOMAIN = forgejoan;
              # You need to specify this to remove the port from URLs in the web UI.
              ROOT_URL = "https://${srv.DOMAIN}/";
              HTTP_PORT = lib.toInt dns_domains.${forgejoan};
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
    (
      { pkgs, ... }:
      let
        externalInterface = "enp2s0";

        # When interface is setup in container this needs to be a path inside the container, but when we move it to the container network namespace it should be defined globally.
        myMullvadPrivateKeyFile = "/home/assar/mullvad-private-key";
        mullvadServerPublicKey = "MkP/Jytkg51/Y/EostONjIN6YaFRpsAYiNKMX27/CAY=";
        mullvadServerIP = "185.195.233.76";
        myMullvadServerIPIdentification = "10.68.117.34/32";
        wgNamespace = "qbittorrent";
      in
      {
        services.nginx.virtualHosts."qbittorrent.an" = {
          enableACME = false;
          forceSSL = false;
          locations."/" = {

            # The veth pair creates a network, and we target the ip in the container network namespace not even the hosts veth ip.
            # A little bit confused how this works without NAT.
            proxyPass = "http://192.168.200.2:${dns_domains."qbittorrent.an"}";
            proxyWebsockets = true; # needed if you need to use WebSocket
            extraConfig =
              # required when the target is also TLS server with multiple hosts
              "proxy_ssl_server_name on;"
              +
                # required when the server wants to use HTTP Authentication
                "proxy_pass_header Authorization;";
          };
        };

        # One part of NAT is IP forwarding.
        # Without a firewall, enabling IP forwarding would mean that any device on your LAN (192.168.50.x) could potentially send packets to your NAS and have them forwarded into your container's private network
        #networking.firewall.trustedInterfaces = [ "ve-qbittorrent" ];
        networking.firewall.logRefusedPackets = true;
        # Since its in a container its sneaky. Things don't work the way they normally work with systemd, like tmpfiles path being altered to be be under var/lib/nixos-containers and journalctl not working normally.
        # sudo journalctl -M qbittorrent

        # Magic, this line turned red errors into white calming beautiful text! The problem was that wg0 setup ran before the container had set up networking namespace
        systemd.services.wireguard-wg0 = {
          after = [ "container@qbittorrent.service" ];
          requires = [ "container@qbittorrent.service" ];
        };
        systemd.services.create-wireguard-namespace = {
          description = "Create WireGuard network namespace";
          wantedBy = [ "multi-user.target" ];
          before = [
            "wireguard-wg0.service"
            "container@qbittorrent.service"
          ];

          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };

          script = ''
            ${pkgs.iproute2}/bin/ip netns add ${wgNamespace} || true
          '';

          preStop = ''
            ${pkgs.iproute2}/bin/ip netns del ${wgNamespace} || true
          '';
        };
        systemd.services.setup-container-bridge = {

          # Without this, it wont automatically start since you have not specified when systemd should start it.
          wantedBy = [ "multi-user.target" ];
          requires = [ "create-wireguard-namespace.service" ];

          # Unsure if this is needed.
          partOf = [ "container@qbittorrent.service" ];

          serviceConfig = {
            Type = "oneshot";

            # Keep the service marked as active after the script exits. So the preStop script is not run immediately after the script has run.
            RemainAfterExit = true;
          };
          script = ''
            # Create veth pair
            ${pkgs.iproute2}/bin/ip link add veth-qb type veth peer name veth-qb-ns

            # Move one end to namespace
            ${pkgs.iproute2}/bin/ip link set veth-qb-ns netns ${wgNamespace}

            # Configure host side
            ${pkgs.iproute2}/bin/ip addr add 192.168.200.1/24 dev veth-qb
            ${pkgs.iproute2}/bin/ip link set veth-qb up

            # Configure namespace side (only local route, no default)
            ${pkgs.iproute2}/bin/ip netns exec ${wgNamespace} ${pkgs.iproute2}/bin/ip addr add 192.168.200.2/24 dev veth-qb-ns
            ${pkgs.iproute2}/bin/ip netns exec ${wgNamespace} ${pkgs.iproute2}/bin/ip link set veth-qb-ns up

            # Shenanigans to activate the loopback interface in the namespace (idk why its not up by default, perhaps because of no privateNetwork).
            ${pkgs.iproute2}/bin/ip netns exec ${wgNamespace} ${pkgs.iproute2}/bin/ip link set lo up
          '';
          # Clean up when service stops
          # Deleting the main veth interface also deletes the peer interface.
          preStop = ''
            ${pkgs.iproute2}/bin/ip link delete veth-qb || true
          '';
        };
        networking.wireguard.interfaces = {
          # "wg0" is the network interface name. You can name the interface arbitrarily.
          wg0 = {

            # The interface is moved into this network namespace, leaving the original socket behind. Allowing for teleportation!
            interfaceNamespace = wgNamespace;
            # Determines the IP address and subnet of the client's end of the tunnel interface.
            # Mullvad needs to distinguish users using the same mullvad server. It does this via this peer-to-peer ip.
            # I got it by this, it was found in a script from their wireguard linux tutorial: curl -sSL https://api.mullvad.net/wg -d account="<account-number>" --data-urlencode pubkey="$(wg pubkey <<<"<private-key>")"
            ips = [
              myMullvadServerIPIdentification
              #"fc00:bbbb:bbbb:bb01::5:7521/128"
            ];
            listenPort = 51820; # to match firewall allowedUDPPorts (without this wg uses random port numbers)

            # Path to the private key file. Remember that its run in a container. We can't access a path outside the container.
            privateKeyFile = myMullvadPrivateKeyFile;

            peers = [
              # For a client configuration, one peer entry for the server will suffice.

              {
                # Public key of the server (not a file path).
                publicKey = mullvadServerPublicKey;

                # Forward all the traffic via VPN. The value 0.0.0.0/0 is a special notation that means "all possible IPv4 addresses"
                # This sets up the routing entry in the container.
                allowedIPs = [ "0.0.0.0/0" ];
                # Or forward only particular subnets
                #allowedIPs = [ "10.100.0.1" "91.108.12.0/22" ];

                # Set this to the server IP and port.
                endpoint = "${mullvadServerIP}:51820"; # ToDo: route to endpoint not automatically configured https://wiki.archlinux.org/index.php/WireGuard#Loop_routing https://discourse.nixos.org/t/solved-minimal-firewall-setup-for-wireguard-client/7577
                # Send keepalives every 25 seconds. Important to keep NAT tables alive.
                persistentKeepalive = 25;
              }
            ];
          };

        };

        containers.qbittorrent =
          let
            qbittorrentDownloadsDir = "/qbittorrent-downloads";
          in
          {

            bindMounts.samba-share = {
              mountPoint = qbittorrentDownloadsDir;
              hostPath = "${conf.nasMountPoint}/samba-general/qbittorrent";
              isReadOnly = false;
            };
            autoStart = true; # Starts the container automatically when the host boots up.
            networkNamespace = "/var/run/netns/${wgNamespace}";

            config =
              {
                lib,
                ...
              }:
              {
                environment.systemPackages = with pkgs; [
                  dnslookup
                ];
                users.users."samba-general" = {
                  isSystemUser = true; # The difference between normal and system user IN LINUX is purely organizational. UID bellow 1000 is for normal users. However i don't think it has an effect since i set UID explicitly.
                  group = "samba-general";
                  # Aligns with the host samba-general user because the bindmounted directory is owned by this uid even in the container.
                  uid = 991; 
                };
                # Note you need this line, because this is the line that creates the group.
                users.groups."samba-general" = {};

                services.qbittorrent = {
                  enable = true;
                  user = "samba-general";
                  group = "samba-general";
                  webuiPort = lib.toInt dns_domains."qbittorrent.an";
                  serverConfig = {
                    Preferences = {
                      WebUI = {
                        AlternativeUIEnabled = true;
                        RootFolder = "${pkgs.vuetorrent}/share/vuetorrent";
                        Username = "assar";
                        # generated with:
                        # nix run 'git+https://codeberg.org/feathecutie/qbittorrent_password' -- -p password
                        Password_PBKDF2 = "yaBixdwgdNiw8NOsrwzAmg==:i6oS+jX70/srRxhi8pfQf68fTbEDQLYsL2MGTB8bcsJ4qUHemYLGTEKAoR7MGgrj0sg6kqPhTrl/919ZEp3WMw==";
                      };
                      Downloads.SavePath = qbittorrentDownloadsDir;
                    };
                  };
                };
                networking = {
                  # This inner container must be accessible from the outside.
                  firewall.allowedTCPPorts = [ (lib.toInt dns_domains."qbittorrent.an") ];

                  # By default all forwarded traffic are blocked by the firewall. This makes any traffic coming from the container allowed
                  #firewall.trustedInterfaces = [ "ve-qbittorrent" ]; # should not be needed

                  # Use systemd-resolved inside the container
                  # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
                  # "Gemini: This is an important networking detail. It tells the container not to simply copy the host's DNS settings.
                  # Instead, it runs its own DNS resolver (systemd-resolved) inside the container. This improves isolation and prevents certain network-related bugs."
                  # See https://discourse.nixos.org/t/what-does-mkdefault-do-exactly/9028 for explanation on mkForce
                  useHostResolvConf = lib.mkForce false;
                };

                services.resolved.enable = true;

                # Before i was using sytemd.network, but since i am not managing the interfaces with systemd-networkd, i think thats why it didn't work.
                # These entries are added to /etc/systemd/resolved.conf, and not /etc/resolv.conf because we abstract away with resolved and in fact you can see that the only entry in /etc/resolv.conf is 127.0.0.53, pointing to resolved dns resolver (treated as a dns server) itself.
                networking.nameservers = [
                  "1.1.1.1" # Cloudflare
                  "8.8.8.8" # Google
                ];

                system.stateVersion = "25.05";

                # "This should not be needed i think unless the vpn want to be the one to initiate traffic." Indeed but its peer-to-peer so there will be incoming traffic.
                # Opening a port is down for the whole namespace. Also you should think of ports as tied to process. Only open firewall if process is listening on a port, in that case there is incoming traffic.
                # In this case wireguard service connects to the network via this port.
                networking.firewall = {
                  allowedUDPPorts = [ 51820 ]; # Clients and peers can use the same port, see listenport
                };

                # Enable WireGuard
                networking.wireguard.enable = true;

                # This one made ping request be able to leave the container. the difference in routing table seem to be an added "proto static" for the wg0 interface
                #networking.wireguard.useNetworkd = true;

              };
          };
      }
    )
  ];
}
