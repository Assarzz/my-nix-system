{
  insomniac.modules = [
    (
      { pkgs, ... }:
      let
        conf = import ./conf.nix;

        # borg list <backupMountPoint>/bokuborgbackup::2025-07-24 to look at backup content
        do-backup = import ./do-backup.nix pkgs;
      in
      {
        fileSystems.${conf.backupMountPoint} = {
          device = conf.backupDevice;
          fsType = "ext4";
          options = [
            "nofail"
            "user"
            "noauto"
          ];
        };

        environment.systemPackages = [
          do-backup
          pkgs.borgbackup
        ];
        systemd.timers."daily-backup" = {
          wantedBy = [ "timers.target" ];
          # The following example starts once a day (at 12:00am). When activated, it triggers the service immediately if it missed the last start time (option Persistent=true), for example due to the system being powered off. 
          timerConfig = {
            OnCalendar = "daily";
            Persistent = true; 
          };
        };

        systemd.services."daily-backup" = {
          script = ''
            set -eu
            "${do-backup}/bin/do-backup"
          '';
          serviceConfig = {
            Type = "oneshot";
            User = "root";
          };
        };
      }
    )
  ];
}
