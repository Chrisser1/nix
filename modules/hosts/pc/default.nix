{ self, inputs, ... }: {
  flake.nixosConfigurations.pc = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs;
      secrets = import "/home/chris/nixos/secrets.nix";
    };
    modules = [
      self.nixosModules.pc-configuration
      self.nixosModules.desktop-host
      {home-manager.sharedModules = [self.homeModules.pc-home];}
    ];
  };
}
