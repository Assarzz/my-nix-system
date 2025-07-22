{

  universal.modules = [

    (
      { pkgs, ... }:
      {
        # Gnome files.
        environment.systemPackages = with pkgs; [

          nautilus
          # Particularily to get gnome files to recognize USB devices (1)
          usbutils # Tools for working with USB devices, such as lsusb
          udiskie # Removable disk automounter for udisks
          udisks # Daemon, tools and libraries to access and manipulate disks, storage devices and technologies
        ];
        # particularly to be able to unzip files in gnome files
        programs.file-roller.enable = true;

        services = {
          gvfs.enable = true;
          udisks2.enable = true;
          devmon.enable = true;

        };
      }
    )

  ];
}
