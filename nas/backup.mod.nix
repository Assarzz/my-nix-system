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
        ];
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
