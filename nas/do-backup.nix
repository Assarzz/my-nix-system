pkgs:
let
  conf = import ./conf.nix;
  do-backup = pkgs.writeShellApplication {
    name = "do-backup";
    runtimeInputs = with pkgs; [
      borgbackup
      hdparm
    ];
    runtimeEnv = {
      # Just hack into my machine and you have access to all my precious ebooks!
      BORG_PASSPHRASE = "akf481mvn1xlzle074hevmyVUwdvQKX2343968dhREUIKNMCetb643gg6v84v22gafvGUITNHVF";
    };
    text = ''
      set -euo pipefail # exit immediately on error, unset variable, or error if any command in a pipeline fails

      echo "mounting and spinning up drive"
      mount ${conf.backupMountPoint}

      echo "doing borg backup"
      DATE=$(date --iso-8601)
      borg create "${conf.backupMountPoint}/${conf.borgRepoName}::$DATE" ${builtins.concatStringsSep " " conf.whatToBackup}

      echo "unmounting and spinning down drive"
      umount ${conf.backupMountPoint}
      hdparm -Y ${conf.backupDevice}

    '';
  };

in
do-backup
