
let conf = import ./conf.nix; in {
  # Server configuration
  insomniac.modules =
    let
      nasDevice = "/dev/disk/by-label/nas";
      nasMountPoint = "/mnt/nas";
    in
    [
      {

        # IMPORTANT: for some reason shutting down while nautilus is in a folder of the nas, will stall the shutdown for like 2 minutes. Make sure to close Nautilus GUI app before shutdown!
        fileSystems.${conf.nasMountPoint} = {
          device = conf.nasDevice;
          fsType = "ext4";
        };
        fileSystems.${conf.nasExportSharePath} = {
          device = "${conf.nasMountPoint}/share"; # Treats the directory as a device. Basically creates a portal
          depends = [ "${conf.nasMountPoint}"];
          options = [ "bind" ];
        };

        services.samba = {
          enable = true;
          openFirewall = true;

          settings = {
            global = {
              security = "user"; # Is the default, "With user-level security a client must first "log-on" with a valid username and password"

              #"Tell smbd what to do with user login requests that don't match a valid UNIX user in some way."
              # "Bad User - Means user logins with an invalid password are rejected, unless the username does not exist, in which case it is treated as a guest login and mapped into the guest account."
              "map to guest" = "Bad User";

              # "This is a username which will be used for access to services which are specified as guest ok"
              "guest account" = "assar";

              #"smb3 unix extensions" = "yes"; # Otherwise: [   11.762263] CIFS: VFS: Server does not support mounting with posix SMB3.11 extensions
            };

            share = {
              comment = "Samba share/service called share";
              "force user" = "assar";  # guest account + guest ok is not enough apparently. Need this otherwise Permission denied when creating files on linux.(either way it works on ipad)
              "guest ok" = "yes";
              "read only" = "no"; # "If this parameter is yes, then users of a service may not create or modify files in the service's directory.", indicating that share and service are the same thing.
              path = "${conf.nasExportSharePath}"; # "This parameter specifies a directory to which the user of the service is to be given access."
              "create mask" = "0666"; # For file. Basically guarantees you cant create executable files. " Any bit not set here will be removed from the modes set on a file when it is created."
              "directory mask" = "0777"; # For directory. Leaves permissions unchanged from created once. Or perhaps it removes the special byte i guess?
              # for ios
              "vfs objects" = "catia fruit streams_xattr";

            };
          };
        };

      }

    ];

  # Client configuration
  personal.modules = [
    {
      fileSystems.${conf.nasCifsMountPoint} = {
        device = "//192.168.50.8/share";
        fsType = "cifs";
        # Boot options for fstab.
        options =
          let
            # this line prevents hanging on network split? It does not solve system stalling on shutdown
            automount_opts = "x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
            
          in
          [

            #"${automount_opts}"
            # When x-systemd.automount is used, systemd will enable an "automount unit", also known as a automount trap,
            # or a mount point (path) where a file system may later be mounted.  
            # The file system itself is a separate unit (a "mount unit") and will only be mounted if there is a subsequent demand to use that path.
            # "fstab is turned into systemd-mount units automatically and as root the mounts are performed. So setuid is not required."
            # For me fstab can mount cifs device as it is running as root, and so only trying to access it with cd will mount it.
            # But gnome files presumably does not have root access, so it can't mount cifs devices without the setuid bit.
            #"x-systemd.automount"

            "nofail" # Prevent system from failing if this drive doesn't mount
            "auto" # until automount is fixed
            # "x-gvfs-show"

            # For cifs
            "guest" # "don't prompt for a password "
            "uid=assar" # Which user to own the files on the nixos client system. Defaults to root.
            #"uid=1000" # Is this correct instead? "assar" works, so don't fix what isn't broken.
            #"gid=100"
            "rw"
          ];
      };
    }
  ];
}
