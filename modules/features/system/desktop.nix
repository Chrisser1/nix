{ self, ... }: {
  flake.nixosModules.desktop = {pkgs, ...}: {
    nixpkgs.config.allowUnfree = true;
    hardware.enableRedistributableFirmware = true;
  };
}
