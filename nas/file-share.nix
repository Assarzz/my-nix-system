# make server have static ip

/*
  mkdir /export and changing ownership:
  This is a preparatory step on the server to create a common base directory for your NFS exports.
*/

# backup+share : like document files, and media files
# share : for things that are temporary and i just want universal access to.
# backup+sync : password file, git server maybe

{
  insomniac.modules =
    let
      nasDevice = "/dev/disk/by-label/nas";
      nasMountPoint = "/mnt/nas";
    in
    [
      {

        fileSystems.${nasMountPoint} = {
          device = nasDevice;
          fsType = "ext4";
        };
        fileSystems."/export/share" = {
          device = nasMountPoint;
          options = [ "bind" ];
        };

        services.samba = {
          enable = true;
          openFirewall = true;

          settings = {
            global = {
              security = "user";
              "map to guest" = "Bad User";
              "guest account" = "nobody";
              # … any hosts allow/deny you already have …
            };

            public = {
              browseable = "yes";
              comment = "Public samba share.";
              "guest ok" = "yes";
              "read only" = "no";
              writable = "yes";
              path = "/export/share";
              "force user" = "nobody";
              "create mask" = "0666";
              "directory mask" = "0777";
              # for ios
              "vfs objects" = "catia fruit streams_xattr";

            };
          };
        };

      }

    ];
}
