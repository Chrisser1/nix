{ self, inputs, ... }: {
  flake.nixosModules.sddm = { pkgs, ... }: {
    imports = [ inputs.qylock.nixosModules.default inputs.sigil-sddm.nixosModules.default ];

    services.xserver.enable = true;

    services.displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
        autoNumlock = true;
        enableHidpi = true;
        
        package = pkgs.kdePackages.sddm;
        
        extraPackages = with pkgs.kdePackages; [
          qtdeclarative   
          qt5compat        
          qtsvg           
          qtmultimedia    
        ];
      };

      defaultSession = "hyprland";
    };

    # Only for the qylock-lock lockscreen; the login screen is Sigil's.
    programs.qylock = {
      enable = true;
      theme = "pixel-sakura";
      sddm.enable = false;
    };

    programs.sigil-sddm = {
      enable = true;
      # systemInfo = true;                           # the system panel down the left
      # settings.effects.lightning.enabled = false;  # anything from the theme's figure.json5
    };
  };
}