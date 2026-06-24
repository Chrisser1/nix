{ self, inputs, ... }: 
let
    system = "aarch64-linux";
    commonArgs = { 
        inherit inputs; 
        secrets = import "/home/chris/nixos/secrets.nix";
    };
in {
    flake.nixosConfigurations.oracle = inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = commonArgs;
    modules = [
        self.nixosModules.oracle-configuration
        self.nixosModules.cli 
        
        # Kubernetes Features
        self.nixosModules.kubernetes-server
        self.nixosModules.kubernetes-deployments

        inputs.home-manager.nixosModules.home-manager
            {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                
                home-manager.users.root = {
                    home.stateVersion = "25.05";
                    
                    imports = [
                    self.homeModules.cli
                    self.homeModules.shell-aliases
                    ];
                };
            }
        ];
    };
}