# Configuration that while it is necessary to get some specific feature working, it fundamentally has to do with wayland itself.

{
  universal.moduels = [
    (
      { pkgs, ... }:
      {
        # Wayland support for vscode in particular.
        # TODO: potentially remove this and use xwayland instead on some machines, because i heard it was the cause of the studdors when using nvidia gpu.
        environment.sessionVariables.NIXOS_OZONE_WL = "1";

        # For steam in particular.
        environment.systemPackages = with pkgs; [
          xwayland-satellite
        ];
      }
    )
  ];
}
