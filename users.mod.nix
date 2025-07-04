{
  universal.modules = [
    ({
      
      users.mutableUsers = true; # Not planning on mutating users, but being able to accidentaly change my password seems scary
      users.users.assar = {
        isNormalUser = true;
        home = "/home/assar";
        description = "Assar Lannerborn";
        extraGroups = [
          "wheel"
          "networkmanager"
          "plugdev"
        ];
        hashedPassword = "$y$j9T$mxvQmMdU/WfPfvnh4f1xk1$g0on.Tq4lJWy43YN9ok/GQ6bufbeG45NCax3HrI1sa6";
        openssh.authorizedKeys.keys = [ "ssh-dss AAAAB3Nza... assar@foobar" ]; # dont know what this does. TODO test removing it.
      };
      users.users.root = {
        hashedPassword = "$y$j9T$mxvQmMdU/WfPfvnh4f1xk1$g0on.Tq4lJWy43YN9ok/GQ6bufbeG45NCax3HrI1sa6";
      };
    })
  ];

  igniter.modules = [{networking.hostName = "igniter";}];
  pioneer.modules = [{networking.hostName = "pioneer";}];
  strategist.modules = [{networking.hostName = "strategist";}];
  insomniac.modules = [{networking.hostName = "insomniac";}];

  igniter.system = "x86_64-linux";
  pioneer.system = "x86_64-linux";
  strategist.system = "x86_64-linux";
  insomniac.system = "x86_64-linux";


}
