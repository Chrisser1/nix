{ self, inputs, ...}: {
  flake.nixosModules.desktop-host = { ... }: {
    imports = [
      self.nixosModules.base-system
      self.nixosModules.desktop
      self.nixosModules.users
      self.nixosModules.docker
      self.nixosModules.gaming

      # System requirements for packages
      self.nixosModules.hyprland
      self.nixosModules.niri
      self.nixosModules.noctalia
      self.nixosModules.core-packages
      self.nixosModules.vesktop
      self.nixosModules.noise-cancellation
      self.nixosModules.fonts
      self.nixosModules.sddm
      self.nixosModules.cli

      # External flake modules
      inputs.nvf.nixosModules.default
      inputs.home-manager.nixosModules.home-manager
    ];

    nixpkgs.overlays = [inputs.nix-vscode-extensions.overlays.default];

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
