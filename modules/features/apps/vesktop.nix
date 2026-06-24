{ self, ... }: {
  flake.nixosModules.vesktop = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.vesktop ];
  };
}
