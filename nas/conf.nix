/*
This is a centralized way to provide all the my-system specific option values that I have set imperatively and are unique to my system.
If somebody wants to use my system they will have to change these
*/
{
  # All nixos devices will "send a friend request" to these. If both send to each other they automatically become "friends"
  syncthingDeviceIds = {
    strategistCachyos = "45V7I3Q-UYQFOSR-KIBI7YV-4ZJE34V-5V7XC4O-N3SPF2U-ORBQHHM-R4QZLA5";
    igniter = "7XU7UBV-ZSRGC6E-EM4RED5-JBT2G6A-NWR6SC7-SOU7VHW-HOWSLDH-7IIQMAL";
    insomniac = "RXXPAHH-HSQVIND-4TP6R5A-34M66WJ-MGY3EYB-PF3F2YX-U2J5CUZ-PZBNMAR";
    ipad = "SY6MX4U-JEM472A-NB623ZI-63QZVEH-SKDYROS-3Y2GQRL-4PQPYRS-BKI5IAC";
    nothingPhone = "UXVYCSO-IF4CF4M-OQNSKXY-4VLO3ZM-FFRK4EL-ARN6B3X-RCZAMEJ-XSPWDQK";
  };

  nasDevice = "/dev/disk/by-label/nas";
  nasIP = "192.168.50.8";
  nasMountPoint = "/mnt/nas";
  nasCifsMountRoot = "/home/assar/mnt";

  backupDevice = "/dev/disk/by-label/backup";
  backupMountPoint = "/mnt/backup";

}