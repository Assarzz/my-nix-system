let
  conf = import ./conf.nix;
in
{
  insomniac.modules = [
    (
      { pkgs, ... }:
      let
        do-backup = import ./do-backup.nix pkgs;
      in
      {
        fileSystems.${conf.backupMountPoint} = {
          device = conf.nasDevice;
          fsType = "ext4";
          options =
            [
              "nofail" # Prevent system from failing if this drive doesn't mount
              "user"
            ];
        };

        environment.systemPackages = [
          do-backup
        ];
        /*
          systemd.timers."daily-backup" = {
                 wantedBy = [ "timers.target" ];
                 timerConfig = {
                   OnCalendar = "daily";
                   Persistent = true;
                 };
               };

               systemd.services."daily-backup" = {
                 script = ''
                   set -eu
                   ${do-backup}/bin/do-backup"
                 '';
                 serviceConfig = {
                   Type = "oneshot";
                   User = "root";
                 };
               };
        */
      }
    )
  ];
}
