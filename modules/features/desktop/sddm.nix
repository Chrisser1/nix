{ self, ... }: {
  flake.nixosModules.sddm = { pkgs, ... }: 
  let
    custom-sddm-astronaut = pkgs.sddm-astronaut.override {
        embeddedTheme = "pixel_sakura";
    };
  in {
    services.xserver.enable = true;

    services.displayManager = {
      sddm = {
        enable = true;
        wayland.enable = false;
        autoNumlock = true;
        enableHidpi = true;
        package = pkgs.kdePackages.sddm;
        theme = "sddm-astronaut-theme";
        extraPackages = with pkgs; [
          custom-sddm-astronaut
          kdePackages.qtsvg
          kdePackages.qtvirtualkeyboard
          kdePackages.qtmultimedia
        ];
      };
      
      defaultSession = "hyprland"; 
    };

    environment.systemPackages = [
      custom-sddm-astronaut
    ];
  };
}