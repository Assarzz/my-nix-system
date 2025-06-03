{pkgs, lib, inputs,  ...}:let 
ssh-keyname = "id_ed25519";
in
{
  
  imports = [
    ./niri.nix
    ./theme.nix
    inputs.ags.homeManagerModules.default
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
    firefox.enable = true;
    vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        rust-lang.rust-analyzer
        #dracula-theme.theme-dracula
        jnoortheen.nix-ide
        #gruntfuggly.todo-tree
        #llvm-vs-code-extensions.vscode-clangd
        #ms-vscode-remote.remote-ssh
        #ms-vscode.makefile-tools
        #ms-vsliveshare.vsliveshare
        #ms-python.python
        #mechatroner.rainbow-csv
      ];
    };
    neovim.enable = true;
    alacritty.enable = true;
    fuzzel.enable = true;
    yazi = {
      enable = true;
      enableBashIntegration = true;

    };
    ags = {
      enable = true;

      # null or path, leave as null if you don't want hm to manage the config
      configDir = ../ags;

      # additional packages to add to gjs's runtime
      extraPackages = with pkgs; [
        gtksourceview
        webkitgtk
        accountsservice
      ];
    };
  };
}
