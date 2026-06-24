{ self, ... }: {
  
  flake.homeModules.git = { pkgs, ... }: {
    
    programs.git = {
      enable = true;
      lfs.enable = true;
      settings = {
        user = {
          name = "Chrisser1";
          email = "chrisgthomsen0310@gmail.com";
        };

        url."git@github.com:" = {
          pushInsteadOf = "https://github.com/";
        };
      };
    };

    programs.lazygit = {
      enable = true;
      settings = {
        gui.theme = {
          activeBorderColor = [ "#7F0909" "bold" ];
          inactiveBorderColor = [ "#a6adc8" ];
          selectedLineBgColor = [ "#2B2B2B" ];
        };
      };
    };
    
  };
}