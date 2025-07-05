{
  insomniac.modules = [
    ({pkgs, lib, ...}:{
      services.udev.extraRules =
        let
          mkRule = as: lib.concatStringsSep ", " as;
          mkRules = rs: lib.concatStringsSep "\n" rs;
        in
        mkRules ([

          # nas
          (mkRule [
            ''ACTION=="add|change"''
            ''ENV{ID_WWN}==0x5000039dc8cb3799''
            ''RUN+="${pkgs.hdparm}/bin/hdparm -B 90 $devnode"''
          ])
          # backup
          (mkRule [
            ''ACTION=="add|change"''
            ''ENV{ID_WWN}==0x5000039dc8cb1e82''
            ''RUN+="${pkgs.hdparm}/bin/hdparm -Y $devnode"''
          ])
        ]);
    })
  ];
}


