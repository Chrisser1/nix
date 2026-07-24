{self, ...}: {
  flake.nixosModules.laptop-configuration = { config, pkgs, inputs, lib, ... }: {
    networking.hostName = "laptop";
    system.stateVersion = "26.05";

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
      theme = "${inputs.grubermeister.packages.${pkgs.stdenv.hostPlatform.system}.default}";

      entryOptions    = "--unrestricted --class nixos";
      subEntryOptions = "--unrestricted --class nixos-generation";
    };
  };
}
