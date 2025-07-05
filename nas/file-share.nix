# make server have static ip

/*
  mkdir /export and changing ownership:
  This is a preparatory step on the server to create a common base directory for your NFS exports.
*/


# backup+share : like document files, and media files
# share : for things that are temporary and i just want universal access to.
# backup+sync : password file, git server maybe

/* {
  insomniac.modules = [
    {
      fileSystems."/export/mafuyu" = {
        device = "/mnt/mafuyu";
        options = [ "bind" ];
      };

    }

    # server setup
    {
      services.nfs.server.enable = true;
      services.nfs.server.exports = ''
        /export         192.168.1.10(rw,fsid=0,no_subtree_check) 192.168.1.15(rw,fsid=0,no_subtree_check)
        /export/kotomi  192.168.1.10(rw,nohide,insecure,no_subtree_check) 192.168.1.15(rw,nohide,insecure,no_subtree_check)
        /export/mafuyu  192.168.1.10(rw,nohide,insecure,no_subtree_check) 192.168.1.15(rw,nohide,insecure,no_subtree_check)
        /export/sen     192.168.1.10(rw,nohide,insecure,no_subtree_check) 192.168.1.15(rw,nohide,insecure,no_subtree_check)
        /export/tomoyo  192.168.1.10(rw,nohide,insecure,no_subtree_check) 192.168.1.15(rw,nohide,insecure,no_subtree_check)
      '';
    }
  ];
}
 */