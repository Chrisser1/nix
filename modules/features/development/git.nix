{ self, ... }: {
  
  flake.homeModules.git = { secrets, pkgs, ... }: {
    programs.git = {
      enable = true;
      lfs.enable = true;
      settings = {
        user = {
          name = "Chrisser1";
          email = "chrisgthomsen0310@gmail.com";
        };
      };
    };

    home.file.".netrc".text = ''
      machine github.com
      login Chrisser1
      password ${secrets.githubToken}
    '';
  };
}