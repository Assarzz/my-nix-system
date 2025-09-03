/*
  No Imperative steps needed to use this mod file.
  However when it comes to creating future folders imperatively on the nas, they will have to be manually added for backup.

  Sets up the nas file system on the nas.
  Sets up samba file sharing for both client and server.
  Sets up the cifs file system that automatically mounts the nas on the clients.
*/

let
  conf = import ./conf.nix;
  samba-general = "samba-general"; # The reason for using a variable is to avoid spelling mistakes when i type things often.
  samba-media = "samba-media";
in
{
  # Server configuration
  insomniac.modules = [
    {

      # IMPORTANT: for some reason shutting down while nautilus is in a folder of the nas, will stall the shutdown for like 2 minutes. Make sure to close Nautilus GUI app before shutdown!
      fileSystems.${conf.nasMountPoint} = {
        device = conf.nasDevice;
        fsType = "ext4";
      };

      users.users."${samba-media}" = {
        isSystemUser = true;
        group = samba-media;
      };
      users.groups."${samba-media}" = {};
      # "If set to `"-"` no automatic clean-up is done."

      users.users."${samba-general}" = {
        isSystemUser = true; # The difference between normal and system user is purely organizational. System users should not need to show up when you log in for example.
        group = samba-general;
      };
      users.groups."${samba-general}" = {};
      
      systemd.tmpfiles.rules = [
        "d ${conf.nasMountPoint}/${samba-media} 0755 ${samba-media} ${samba-media} -"
        "d ${conf.nasMountPoint}/${samba-general} 0755 ${samba-general} ${samba-general} -"
      ];

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

          "${samba-general}" = {
            comment = "General samba share";
            "force user" = samba-general; # guest account + guest ok is not enough apparently. Need this otherwise Permission denied when creating files on linux.(either way it works on ipad)
            "guest ok" = "yes";
            "read only" = "no"; # "If this parameter is yes, then users of a service may not create or modify files in the service's directory.", indicating that share and service are the same thing.
            path = "${conf.nasMountPoint}/${samba-general}"; # "This parameter specifies a directory to which the user of the service is to be given access."
            "create mask" = "0666"; # For file. Basically guarantees you cant create executable files. " Any bit not set here will be removed from the modes set on a file when it is created."
            "directory mask" = "0777"; # For directory. Leaves permissions unchanged from created once. Or perhaps it removes the special byte i guess?
            # for ios
            "vfs objects" = "catia fruit streams_xattr";

          };
          "${samba-media}" = {
            comment = "Samba share for media";
            "force user" = samba-media; # guest account + guest ok is not enough apparently. Need this otherwise Permission denied when creating files on linux.(either way it works on ipad)
            "guest ok" = "yes";
            "read only" = "no"; # "If this parameter is yes, then users of a service may not create or modify files in the service's directory.", indicating that share and service are the same thing.
            path = "${conf.nasMountPoint}/${samba-media}"; # "This parameter specifies a directory to which the user of the service is to be given access."
            "create mask" = "0666"; # For file. Basically guarantees you cant create executable files. " Any bit not set here will be removed from the modes set on a file when it is created."
            "directory mask" = "0777"; # For directory. Leaves permissions unchanged from created once. Or perhaps it removes the special byte i guess?
            # for ios
            "vfs objects" = "catia fruit streams_xattr";

          };

          # NOTE it assumes that nixos configuration is in /etc/nixos and owned by assar
          "nas-nixos-config" = {
            comment = "Samba share for making it easier for working on my nixos config on my nas";
            "force user" = "assar"; 
            "guest ok" = "yes";
            "read only" = "no"; 
            #path = "/etc/nixos"; 
            path = "${conf.nasMountPoint}/samba-test-nasmnt";
            "create mask" = "0666";
            "directory mask" = "0777"; 
            # for ios
            "vfs objects" = "catia fruit streams_xattr";

          };
        };
      };

    }

  ];

  # Client configuration
  personal.modules = [
    (
      { pkgs, ... }:
      let 
        mkCifsMount = share : {
          device = "//${conf.nasIP}/${share}";
          fsType = "cifs";
          # Boot options for fstab.
          options =
            let
            in
            [
              # When x-systemd.automount is used, systemd will enable an "automount unit", also known as a automount trap,
              # or a mount point (path) where a file system may later be mounted.
              # The file system itself is a separate unit (a "mount unit") and will only be mounted if there is a subsequent demand to use that path.
              # "fstab is turned into systemd-mount units automatically and as root the mounts are performed. So setuid is not required."
              # For me fstab can mount cifs device as it is running as root, and so only trying to access it with cd will mount it.
              # But gnome files does not trigger the same automount mechanism and tries to mount it iself however it does not have root access, so it can't mount cifs devices without the setuid bit.
              #"x-systemd.automount"

              "nofail" # Prevent system from failing if this drive doesn't mount
              "auto" # until automount is fixed
              # "x-gvfs-show"

              # For cifs
              "guest" # "don't prompt for a password "
              "uid=assar" # Which user to own the files on the nixos client system. Defaults to root.
              #"uid=1000" # Is this correct instead? "assar" works, so don't fix what isn't broken.
              "gid=assar"
              "rw"
            ];
        };
      in {
        # For mount.cifs, required unless domain name resolution is not needed.
        # this line is needed otherwise "Error: Failed to open unit file /nix/store/w...5/etc/systemd/system/home-assar-mnt-nas.mount"
        environment.systemPackages = [ pkgs.cifs-utils ]; 
        fileSystems."${conf.nasCifsMountRoot}/${samba-general}" = mkCifsMount samba-general;
        fileSystems."${conf.nasCifsMountRoot}/${samba-media}" = mkCifsMount samba-media;
        fileSystems."${conf.nasCifsMountRoot}/nas-nixos-config" = mkCifsMount "nas-nixos-config";


      }
    )
  ];
}
