{ config, lib, pkgs, ... }:
let portssd = "/mnt/portssd";
public = "${portssd}/public";
cfg = config.nas;
in {
  options.nas = {
    server.enable = lib.mkEnableOption "enable nas server";
    client.enable = lib.mkEnableOption "enable nas client";
  };
  config = lib.mkIf cfg.client.enable {
    environment.systemPackages = [ pkgs.cifs-utils ];
    fileSystems."/home/assar/mnt/nas" = {
    device = "//192.168.50.10/public";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

    in [# If you don't have this options attribute, it'll default to "defaults"
          # boot options for fstab. Search up fstab mount options you can use
          "users" # Allows any user to mount and unmount
          "nofail" # Prevent system from failing if this drive doesn't mount
          "guest,vers=3.0,uid=$(id -u),gid=$(id -g),file_mode=0666,dir_mode=0777"
          "${automount_opts},credentials=/etc/nixos/smb-secrets"];
    };
  } // lib.mkIf cfg.server.enable {

    # /dev/disk/by-label/portssd
    fileSystems."${portssd}" = {
      device = "/dev/disk/by-label/portssd";
      fsType = "ext4";
      options =
        [ # If you don't have this options attribute, it'll default to "defaults"
          # boot options for fstab. Search up fstab mount options you can use
          "users" # Allows any user to mount and unmount
          "nofail" # Prevent system from failing if this drive doesn't mount
        ];
    };
    services.samba = {
      enable = true;
      openFirewall = true;

      settings = {
        global = {
          security = "user";
          "map to guest" = "Bad User";
          "guest account" = "nobody";
          # … any hosts allow/deny you already have …
        };

        public = {
          browseable = "yes";
          comment = "Public samba share.";
          "guest ok" = "yes";
          "read only" = "no";
          writable = "yes";
          path = "${public}";
          "force user" = "nobody";
          "create mask" = "0666";
          "directory mask" = "0777";
          # for ios
          "vfs objects" = "catia fruit streams_xattr";

        };
      };
    };
    systemd.tmpfiles.rules = [
      # Format: "d <path> <mode> <owner> <group> <age> <argument>"
      "d ${public} 0777 nobody nobody - -"
    ];
  };
}
