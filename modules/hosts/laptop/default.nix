{ self, inputs, ... }: {
  flake.nixosConfigurations.laptop = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs;
      secrets = import "/home/chris/nixos/secrets.nix";
    };
    modules = [
      self.nixosModules.laptop-configuration
      self.nixosModules.desktop-host
      {home-manager.sharedModules = [self.homeModules.laptop-home];}
    ];
  };
}
