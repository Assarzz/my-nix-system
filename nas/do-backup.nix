pkgs:
let
  mountPoint = "/mnt/backup";
  repoName = "bokuborgbackup";
  device = "/dev/disk/by-label/backup";
  whatToBackup = "";
  do-backup = pkgs.writeShellApplication {
    name = "do-backup";
    runtimeInputs = with pkgs; [
      borgbackup
      hdparm
    ];
    runtimeEnv = {
      BORG_KEY_FILE = "/root/.config/borg/keys/${repoName}";
      BORG_PASSPHRASE = "akf481mvn1xlzle074hevmyVUwdvQKX2343968dhREUIKNMCetb643gg6v84v22gafvGUITNHVF";
      BORG_REPO = "${mountPoint}/${repoName}";
    };
    text = ''
      set -euo pipefail # exit immediately on error, unset variable, or error if any command in a pipeline fails

      echo "mounting and spinning up drive"
      mount --mkdir ${device} ${mountPoint}

      echo "doing borg backup"
      DATE=$(date --iso-8601)
      borg create ::$DATE ${whatToBackup}

      echo "unmounting and spinning down drive"
      umount ${mountPoint}
      hdparm -Y ${device}

    '';
  };

in do-backup