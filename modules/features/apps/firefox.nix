{ self, ... }: {
  flake.homeModules.firefox = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.firefox-devedition ];
  };
}