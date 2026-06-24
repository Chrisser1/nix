{ self, ... }: {
  flake.nixosModules.fonts = { pkgs, ... }: {
    fonts.packages = with pkgs; [
      nerd-fonts.caskaydia-cove
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      font-awesome
    ];
  };
}