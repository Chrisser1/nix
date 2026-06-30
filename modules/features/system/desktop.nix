{ self, ... }: {
  flake.nixosModules.desktop = {pkgs, ...}: {
    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.permittedInsecurePackages = ["pnpm-10.29.2"];
    hardware.enableRedistributableFirmware = true;
  };
}
