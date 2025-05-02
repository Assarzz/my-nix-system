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
      };
    };
  };
  systemd.tmpfiles.rules = [
    # Format: "d <path> <mode> <owner> <group> <age> <argument>"
    "d ${public} 0777 nobody nobody - -"
  ];
}