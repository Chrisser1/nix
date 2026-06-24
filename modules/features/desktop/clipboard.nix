{ self, ... }: {
  flake.homeModules.clipboard = { pkgs, ... }: {
    home.packages = with pkgs; [
      wl-clipboard
    ];

    services.cliphist = {
      enable = true;
      allowImages = true;
      extraOptions = [ "-max-items" "500" ];
    };
  };
}
