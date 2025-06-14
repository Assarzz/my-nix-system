{ pkgs, ... }:
{
/*   nixpkgs.overlays = [
    (final: prev: {
      anki-bin-with-mpv = prev.anki-bin.override {
        #targetPkgs = [ prev.mpv ];
      };
    })
  ]; */
  # incredibly confused it seems anki package has mpv as a dependency but not anki-bin. But you can get anki-bin to work if you just add mpv to system pacakges also
  environment.systemPackages = [ pkgs.anki ];
}
