{...}:
{
  users.mutableUsers = false;
  users.users.assar = {
    isNormalUser  = true;
    home  = "/home/assar";
    description  = "Assar Lannerborn";
    extraGroups  = [ "wheel" "networkmanager" ];
    hashedPassword = "$y$j9T$mxvQmMdU/WfPfvnh4f1xk1$g0on.Tq4lJWy43YN9ok/GQ6bufbeG45NCax3HrI1sa6";
    openssh.authorizedKeys.keys  = [ "ssh-dss AAAAB3Nza... assar@foobar" ];
  };
  users.users.root = {
    hashedPassword = "$y$j9T$mxvQmMdU/WfPfvnh4f1xk1$g0on.Tq4lJWy43YN9ok/GQ6bufbeG45NCax3HrI1sa6";
  };
}