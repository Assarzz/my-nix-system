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
          device = "${nasMountPoint}/share"; # Treats the directory as a device. Basically creates a portal
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
            };

            share = {
              comment = "Samba share/service called share";
              "guest ok" = "yes";
              "read only" = "no"; # "If this parameter is yes, then users of a service may not create or modify files in the service's directory.", indicating that share and service are the same thing.
              path = "/export/share"; # "This parameter specifies a directory to which the user of the service is to be given access. In the case of printable services, this is where print data will spool prior to being submitted to the host for printing."
              "create mask" = "0666"; # For file. Basically guarantees you cant create executable files.
              "directory mask" = "0777"; # For directory. Leaves permissions unchanged from created once. Or perhaps it removes the special byte i guess?
              # for ios
              "vfs objects" = "catia fruit streams_xattr";

            };
          };
        };

      }

    ];
}
