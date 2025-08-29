/*
  No Imperative steps needed in this mod file. But remember to add correct device ids in the conf.nix file.
  Depends on the files-share mod file and can't be used without it.

  Sets up syncthing on all nixos devices and so they connect to each other including to non nixos devices whose device ids have also been added to syncthingDeviceIds.
  Set up a general folder that every device on my network have and is synced in common.

  # NOTE on the second revision of the sync setup we had following name changes: General -> general, and general-shared-folder -> general-shared-folder2.
*/

{ lib, ... }:
let

  conf = import ./conf.nix;
  # A function to generate the Syncthing configuration for a given device.
  mkConf =
    # The name of the current device (must be a key in device_ids).
    currentDeviceName:
    let
      # Get all devices EXCEPT the current one.
      otherDevices = lib.filterAttrs (name: _: name != currentDeviceName) conf.syncthingDeviceIds;
      # sync with syncthing should mean that we dont need to include the folder in file share
      syncDirPath =
        if currentDeviceName == "insomniac" then "${conf.nasMountPoint}syncthing" else "~/syncthing";
    in
    {
      home_modules = [
        {

          services.syncthing = {

            guiAddress = if currentDeviceName == "insomniac" then "0.0.0.0:8384" else "127.0.0.1:8384";
            enable = true;
            settings = {
              # 1. DEFINE PEER DEVICES
              #    This takes the `otherDevices` map and creates an entry for each,
              #    setting its device ID.
              devices = lib.mapAttrs (name: id: { inherit id; }) otherDevices;

              # 2. DEFINE THE SHARED FOLDER
              #    This creates a folder and shares it with the peer devices.
              folders = {
                # The name here ("General") becomes the default path and label.
                "general" = {
                  # This ID must be IDENTICAL on all devices for the folder to sync.
                  id = "general-shared-folder2";

                  # The local path to the folder. `~` expands to the user's home.
                  path = "${syncDirPath}/general";

                  # The folder label that appears in the Syncthing GUI.
                  label = "general";

                  #It gets the names of all other devices and shares this folder with them.
                  devices = lib.attrNames otherDevices;

                  # Is default already. Standard two-way sync. Can also be "sendonly" or "receiveonly".
                  type = "sendreceive";
                };
              };
            };
          };
        }
      ];
      modules = [
        {
          # Note that the share folder is assumed to exist so we don't add it. TODO is it even necessary to specify each individual path like this or would general be enough?
          systemd.tmpfiles.rules = [
            "d ${syncDirPath} 0755 assar assar -"
            "d ${syncDirPath}/general 0755 assar assar -"
          ];
          networking.firewall.allowedTCPPorts = if currentDeviceName == "insomniac" then [ 8384 ] else [ ];
        }
      ];
    };
in
{

  strategist = mkConf "strategist";
  insomniac = mkConf "insomniac";
  pioneer = mkConf "pioneer";
  igniter = mkConf "igniter";

}
