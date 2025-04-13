{pkgs, ...}:
{
  xdg.userDirs.enable = true;
  xdg.userDirs.createDirectories = true;

  home = {
    packages = with pkgs; [ hello ];
    username = "assar";
    homeDirectory = "/home/assar";
    stateVersion = "25.05";
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
      
    };
  };
}