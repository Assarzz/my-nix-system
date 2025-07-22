# every device on my network should have one general folder that is synced in common

{ lib, ... }: let
  
  conf = import ./conf.nix;
  # A function to generate the Syncthing configuration for a given device.
  mkConf =
    # The name of the current device (must be a key in device_ids).
    currentDeviceName: let
      # Get all devices EXCEPT the current one.
      otherDevices = lib.filterAttrs (name: _: name != currentDeviceName) conf.syncthingDeviceIds;
    in {
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
            "General" = {
              # This ID must be IDENTICAL on all devices for the folder to sync.
              id = "general-shared-folder";

              # The local path to the folder. `~` expands to the user's home.
              path = if currentDeviceName == "insomniac" then "${conf.nasExportSyncPath}/General" else "~/Sync/General";

              # The folder label that appears in the Syncthing GUI.
              label = "General";

              #It gets the names of all other devices and shares this folder with them.
              devices = lib.attrNames otherDevices;

              # Is default already. Standard two-way sync. Can also be "sendonly" or "receiveonly".
              type = "sendreceive";
            };
          };
        };
      };
    };
in {

  strategist.home_modules = [(mkConf "strategist")];
  insomniac.home_modules = [(mkConf "insomniac")];
  pioneer.home_modules = [(mkConf "pioneer")];
  igniter.home_modules = [(mkConf "igniter")];

}
