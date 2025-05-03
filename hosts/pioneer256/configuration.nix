{ config, lib, pkgs, ... }:
let portssd = "/mnt/portssd";
 public = "${portssd}/public";
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
    system.stateVersion = "24.11"; # Did you read the comment?

    # /dev/disk/by-label/portssd
     fileSystems."${portssd}" = {
      device = "/dev/disk/by-label/portssd";
      fsType = "ext4";
      options = [ # If you don't have this options attribute, it'll default to "defaults" 
        # boot options for fstab. Search up fstab mount options you can use
        "users" # Allows any user to mount and unmount
        "nofail" # Prevent system from failing if this drive doesn't mount
      ];
    };
  services.samba = {
    enable       = true;
    openFirewall = true;

    settings = {
      global = {
        security       = "user";
        "map to guest"   = "Bad User";
        "guest account"  = "nobody";
        # … any hosts allow/deny you already have …
      };

      public = {
        browseable     = "yes";
        comment        = "Public samba share.";
        "guest ok"       = "yes";
        "read only"      = "no";
        writable       = "yes";
        path           = "${public}";
        "force user"     = "nobody";
        "create mask"    = "0666";
        "directory mask" = "0777";
        # for ios
        "vfs objects" = "catia fruit streams_xattr";

      };
    };
  };
  systemd.tmpfiles.rules = [
    # Format: "d <path> <mode> <owner> <group> <age> <argument>"
    "d ${public} 0777 nobody nobody - -"
  ];
}


# 84 watt no changes with no monitor
# 88 watt no changes with monitor but no window manager
# 88 watt SVID communication turned off
# 88 watt INTEL turbo boost turned off
# 88 watt All the voltage options with a "offset mode" i put to "-" (bruh)
# 88  CPU IOA/IOD Voltage Boost set all the way to -150mV (fuck all is happening)
# 88 c-states cpu feature set to ENABLED FROM AUTO
# 88 ??? changed cpu cores to 1 (brother in christ wtf)
# 88 clicking so neither XMP nor OC Geni was highlighted
# 52 watt removed dedicated graphics card, both power and from motherboard
# 51 watt maybe. I went through ALL the bios settings and turned off AUDIO CARD and EPET and some other stuff.
# 47 watt lets  go. Changed "Package C State Limit" from "Auto" to "C7s"