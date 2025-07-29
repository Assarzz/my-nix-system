# General networking settings for the different machines
# Networking settings special to the nas are kept beside related settings.
# Do 'ls /sys/class/net' and 'ip link' to see info on network interfaces.
{
  universal.modules = [
    ({lib, ...}: {
      networking.nftables.enable = true; # to manage firewall. It's newer than iptables

      # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
      # (the default) this is the recommended approach. When using systemd-networkd it's
      # still possible to use this option, but it's recommended to use it in conjunction
      # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
      networking.useDHCP = lib.mkDefault true;
      # networking.interfaces.enp6s0.useDHCP = lib.mkDefault true;

    })
  ];

  igniter.modules = [ { networking.hostName = "igniter"; } ];
  pioneer.modules = [ { networking.hostName = "pioneer"; } ];
  strategist.modules = [ { networking.hostName = "strategist"; } ];
  insomniac.modules = [ { networking.hostName = "insomniac"; } ];
}
