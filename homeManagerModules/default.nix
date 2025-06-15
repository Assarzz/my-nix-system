{
  pkgs,
  lib,
  inputs,
  ...
}:
let
  ssh-keyname = "id_ed25519";
in
{

  imports = [
    ./niri.nix
    ./theme.nix
    ./ags.nix
    ./nvim.nix
  ];

  stylix.targets.vscode.enable = false;
  stylix.targets.niri.enable = false;

  xdg.userDirs.enable = true;
  xdg.userDirs.createDirectories = true;

  home = {
    packages = with pkgs; [ 
    hello
    ];
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

  services.mako.enable = true;
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
    firefox.enable = true;
    vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        rust-lang.rust-analyzer
        jnoortheen.nix-ide
        sumneko.lua
        # default jedi was garbage
        ms-python.vscode-pylance
      ];
    };
    alacritty.enable = true;
    fuzzel.enable = true;
    yazi = {
      enable = true;
      enableBashIntegration = true;
    };
  };
}
