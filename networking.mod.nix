# General networking settings for the different machines
# Networking settings special to the nas are kept beside related settings.
# Do 'ls /sys/class/net' and 'ip link' to see info on network interfaces.
{
  universal.modules = [
    (
      { lib, ... }:
      {
        networking.nftables.enable = true; # to manage firewall. It's newer than iptables

        # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
        # (the default) this is the recommended approach. When using systemd-networkd it's
        # still possible to use this option, but it's recommended to use it in conjunction
        # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
        networking.useDHCP = lib.mkDefault true;
        # networking.interfaces.enp6s0.useDHCP = lib.mkDefault true;

      }
    )

    {
      # "The usbmuxd package also includes an udev rule that automatically starts and stops the daemon whenever a device is connected or disconnected.", See arch wiki on iphone tethering.
      # To actually see the ethernet interface with "ip link" I had to "trust" the computer on the iPhone.
      services.usbmuxd.enable = true;
    }

/*     (
      { config, ... }:
      {
        sops.secrets."eduroam/id" = { };
        sops.secrets."eduroam/pass" = { };

        sops.templates.eduroam-env.content = ''
          EDUROAM_IDENTITY=${config.sops.placeholder."eduroam/id"}
          EDUROAM_PASSWORD=${config.sops.placeholder."eduroam/pass"}
        '';

        networking.networkmanager.ensureProfiles.environmentFiles = [
          config.sops.templates.eduroam-env.path
        ];
        networking.networkmanager.ensureProfiles.profiles = {
          eduroam = {
            connection = {
              id = "eduroam";
              uuid = "74c15b1e-64d6-4eb8-86fc-8b683157b497";
              type = "802-11-wireless";
            };
            "802-11-wireless" = {
              ssid = "eduroam";
              security = "802-11-wireless-security";
            };
            "802-11-wireless-security" = {
              key-mgmt = "wpa-eap";
              proto = "rsn";
              pairwise = "ccmp";
              group = "ccmp;tkip";
            };
            "802-1x" = {
              eap = "peap";
              phase2-auth = "mschapv2";
              ca-cert = "${./eduroam-chalmers.crt}";
              altsubject-matches = "DNS:eduroam.chalmers.se";
              identity = "$EDUROAM_IDENTITY";
              password = "$EDUROAM_PASSWORD";
            };
            ipv4.method = "auto";
            ipv6.method = "auto";
          };
        };
      }
    ) */
  ];

  igniter.modules = [ { networking.hostName = "igniter"; } ];
  pioneer.modules = [ { networking.hostName = "pioneer"; } ];
  strategist.modules = [ { networking.hostName = "strategist"; } ];
  insomniac.modules = [ { networking.hostName = "insomniac"; } ];
}
