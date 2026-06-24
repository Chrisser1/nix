{self, ...}: {
  # Shared config for graphical desktop hosts (laptop, pc):
  # bluetooth and Wayland session environment.
  flake.nixosModules.desktop = {pkgs, ...}: {
    nixpkgs.config.allowUnfree = true;
    hardware.enableRedistributableFirmware = true;

    environment.sessionVariables = {
      USE_WAYLAND_GRIM = "1";
      NIXOS_OZONE_WL = "1";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      _JAVA_OPTIONS = "-Dawt.toolkit.name=WLToolkit";
      ADW_DISABLE_PORTAL = "1";
    };

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    services.blueman.enable = true;
  };
}
