/* 
Shell script derivation to:
1. spin up and mount backup drive
2. make sure the borg repo exists
2. back up designated directories
*/ 
pkgs:
let
  conf = import ./conf.nix;
  borgRepoName = "bokuborgbackup2";
  mnt = conf.nasMountPoint;

  # This line here depends on every other mod file to make sure the entries specified actually exists.
  whatToBackup = [ "${mnt}/share/backup" "${mnt}/share/sync/backup" "${mnt}/share/sync/general" ]; 
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
      # "the reason borg (and other software) don't accept passwords as args in commands is because other users on the system would be able to see the password in the process list."
      BORG_PASSPHRASE = "akf481mvn1xlzle074hevmyVUwdvQKX2343968dhREUIKNMCetb643gg6v84v22gafvGUITNHVF";
    };
    text = ''

      set -euo pipefail # exit immediately on error, unset variable, or error if any command in a pipeline fails
      echo "mounting and spinning up drive"
      mount ${conf.backupMountPoint}


      # Every command has an exit code we can act on. 0 = success and anything else = failure.
      # After a command echo $? will display the exit code of the previous command.
      # Backwards, here true for the if statement equals exist code 0
      if borg info "${conf.backupMountPoint}/${borgRepoName}" &> /dev/null; then
        echo "Borg repository already exists."
      else
          echo "Borg repository not found! Creating it now..."
          # It will use the PASSPHRASE env variable.
          borg init --encryption repokey "${conf.backupMountPoint}/${borgRepoName}"
      fi

      echo "doing borg backup"
      DATE=$(date --iso-8601)
      borg create "${conf.backupMountPoint}/${borgRepoName}::$DATE" ${builtins.concatStringsSep " " whatToBackup}

      # NOTE if the previous command fails, for example if a backup has already been done with that name (like if you run the script twice a day), this unmount will not happen because the script terminates midway.
      echo "unmounting and spinning down drive"
      umount ${conf.backupMountPoint}
      hdparm -Y ${conf.backupDevice}

    '';
  };

in
do-backup
