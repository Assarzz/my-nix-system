# This is a centralized way to provide all the my-system specific option values, that:
# I have set imperatively, unique to my system or used multiple times.
# If somebody wants to use my system they will have to change these
rec{
  syncthingDeviceIds = {
    strategist = "YZRLEMP-ANN4RMR-DYKDALY-LDWZU5J-SK7TPV6-WBSNZXS-UKDFJEY-AFDXWAT";
    igniter = "7XU7UBV-ZSRGC6E-EM4RED5-JBT2G6A-NWR6SC7-SOU7VHW-HOWSLDH-7IIQMAL";
    insomniac = "RXXPAHH-HSQVIND-4TP6R5A-34M66WJ-MGY3EYB-PF3F2YX-U2J5CUZ-PZBNMAR";
    tablet = "SY6MX4U-JEM472A-NB623ZI-63QZVEH-SKDYROS-3Y2GQRL-4PQPYRS-BKI5IAC";
    phone = "XH3VAJR-FTKFAHV-YXNDZDM-3VENQAZ-5Z3FYJW-72ZDHVZ-CGKBFW6-KGNJEQB"; 
  };

  nasDevice = "/dev/disk/by-label/nas";
  nasMountPoint = "/mnt/nas";
  nasExportSharePath = "/export/share";
  nasExportSyncPath = "/export/share/sync";

  nasCifsMountPoint = "/home/assar/mnt/nas";

  backupDevice = "/dev/disk/by-label/backup";
  backupMountPoint = "/mnt/backup";
  borgRepoName = "bokuborgbackup";

  # Add directories that should be backed up  
  whatToBackup = [ "/export/share/backup" "/export/share/sync/backup" "/export/share/sync/General" ];
  

}