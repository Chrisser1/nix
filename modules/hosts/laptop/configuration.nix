{self, ...}: {
  flake.nixosModules.laptop-configuration = {
    config,
    pkgs,
    inputs,
    lib,
    ...
  }: {
    networking.hostName = "laptop";
    system.stateVersion = "25.05";

    imports = [
      self.nixosModules.laptop-hardware
    ];

    # Bootloader
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.grub = {
      enable = true;
      devices = ["nodev"];
      efiSupport = true;
      useOSProber = true;
      gfxmodeEfi = "1920x1080";
      fontSize = 24;
    };
  };
}
