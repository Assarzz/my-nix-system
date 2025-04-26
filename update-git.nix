{ pkgs }: let
git = "${pkgs.git}/bin/git";
bash = "${pkgs.bash}/bin/bash";
in pkgs.writeShellScriptBin "update-git" ''
      #!${bash}
      ${git} add .
      ${git} commit -m "update"
      ${git} push
''