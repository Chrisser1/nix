{ self, inputs, ... }: {
  flake.nixosModules.desktop-host = {...}: {
    imports = [
      self.nixosModules.base-system
      self.nixosModules.tailscale
      self.nixosModules.bluetooth
      self.nixosModules.desktop
      self.nixosModules.users
      self.nixosModules.docker
      self.nixosModules.gaming

      # System requirements for packages
      self.nixosModules.hyprland
      self.nixosModules.noctalia
      self.nixosModules.core-packages
      self.nixosModules.vesktop
      self.nixosModules.noise-cancellation
      self.nixosModules.fonts
      self.nixosModules.sddm
      self.nixosModules.cli

      # External flake modules
      inputs.home-manager.nixosModules.home-manager
      self.nixosModules.vscode
    ];

    home-manager = {
      useUserPackages = true;
      useGlobalPkgs = true;
      extraSpecialArgs = {
        inherit inputs;
        secrets = import "/home/chris/nixos/secrets.nix";
      };

      users.chris.imports = [self.homeModules.profile-chris];
      users.work.imports = [self.homeModules.profile-work];
    };
  };
}
