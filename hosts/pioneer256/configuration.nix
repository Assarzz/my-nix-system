{ config, lib, pkgs, ... }:
let portssd = "/mnt/portssd";
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
      enable = true;
      settings = {
      global = {
        "invalid users" = [
          "root"
        ];
        #"passwd program" = "/run/wrappers/bin/passwd %u";
        security = "user";
      };
      public = {
        browseable = "yes";
        comment = "Public samba share.";
        "guest ok" = "yes";
        path = "${portssd}";
        "read only" = "yes";
      };
    };
  };
}