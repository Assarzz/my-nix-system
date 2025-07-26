# Shell script derivation to turn on backup hard drive and backup with borg.
pkgs:
let
  conf = import ./conf.nix;
  do-backup = pkgs.writeShellApplication {
    name = "do-backup";

    # "packages to be made available to the shell application’s PATH".
    # Since we are not writing like "${pkgs.coreutils}/bin/date" they are not included automatically.
    # Note that it initially worked without mount, unmount, date when script ran manually from a interactive shell because they are naturally in the PATH there.
    runtimeInputs = with pkgs; [
      borgbackup
      hdparm
      util-linux # Provides mount and umount
      coreutils  # Provides date
    ];
    runtimeEnv = {
      # Just hack into my machine and you have access to all my precious ebooks!
      # The key to decrypt is stored in the backup directory itself!
      BORG_PASSPHRASE = "akf481mvn1xlzle074hevmyVUwdvQKX2343968dhREUIKNMCetb643gg6v84v22gafvGUITNHVF";
    };
    text = ''
      set -euo pipefail # exit immediately on error, unset variable, or error if any command in a pipeline fails

      echo "mounting and spinning up drive"
      mount ${conf.backupMountPoint}

      echo "doing borg backup"
      DATE=$(date --iso-8601)
      borg create "${conf.backupMountPoint}/${conf.borgRepoName}::$DATE" ${builtins.concatStringsSep " " conf.whatToBackup}

      # NOTE if the previous command fails, for example if a backup has already been done with that name (like if you run the script twice a day), this unmount will not happen because the script terminates midway.
      echo "unmounting and spinning down drive"
      umount ${conf.backupMountPoint}
      hdparm -Y ${conf.backupDevice}

    '';
  };

in
do-backup
