/*
  Naturally everything in nioxs could be considered as initial setup.
  But here it about configuration that configures some further initial setup that is only done once.
*/
let
  ssh-keyname = "id_ed25519";
in
{
  universal.home_modules = [
    (
      {
        pkgs,
        lib, ...
      }:
      {
        # Create user directories.
        xdg.userDirs.enable = true;
        xdg.userDirs.createDirectories = true;

        home = {
          username = "assar";
          homeDirectory = "/home/assar";
          stateVersion = "25.05";

          activation = {
            generate-ssh-keys = lib.hm.dag.entryAfter [ "writeBoundary" "installPackages" ] ''
              if [ ! -f "$HOME/.ssh/${ssh-keyname}" ]; then
                mkdir -p $HOME/.ssh
                ${pkgs.openssh}/bin/ssh-keygen -f $HOME/.ssh/${ssh-keyname} -N ""
              fi
            '';
          };
        };
      }
    )
  ];
}
