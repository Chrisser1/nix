{ self, inputs, ... }: {
  flake.nixosModules.sddm = {pkgs, ...}: {
    imports = [inputs.qylock.nixosModules.default];

    services.xserver.enable = true;

    services.displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
        autoNumlock = true;
        enableHidpi = true;
      };

      defaultSession = "hyprland";
    };

    programs.qylock = {
      enable = true;
      theme = "pixel-night-city";
    };
  };
}
