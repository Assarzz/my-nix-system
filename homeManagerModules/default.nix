{pkgs, lib,  ...}:let 
ssh-keyname = "id_ed25519";
in
{
  
  imports = [
    ./niri.nix
    ./theme.nix
  ];
  xdg.userDirs.enable = true;
  xdg.userDirs.createDirectories = true;

  home = {
    packages = with pkgs; [ hello ];
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
      # generate-ssh-keys= lib.hm.dag.entryAfter ["myActivationAction1"] ''
      # <command1>
      # '';
    };
  };

  programs = {
    git = {
      enable = true;
      # Set your personal information.
      userName = "Assarzz";
      userEmail = "assarlannerbornzz@gmail.com";
    };
    ssh = {
      enable = true;
      #addKeysToAgent
    };
    chromium = {
      enable = true;
      commandLineArgs = [
        "--ozone-platform=wayland"
      ];
    };
    vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        rust-lang.rust-analyzer
      ];
    };

  };
}
