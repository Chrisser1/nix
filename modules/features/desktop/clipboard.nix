{ self, ... }: {
  flake.homeModules.clipboard = { pkgs, lib, ... }: {
    home.packages = with pkgs; [
      wl-clipboard
    ];

    services.cliphist = {
      # nyx runs its own watchers.
      enable = lib.mkDefault true;
      allowImages = true;
      extraOptions = [ "-max-items" "500" ];
    };
  };
}
