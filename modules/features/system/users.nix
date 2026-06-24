{self, ...}: {
  # Shared user accounts for desktop hosts (laptop, pc)
  flake.nixosModules.users = {pkgs, ...}: let
    passwordHash = "$6$fVHOWpCZkfMidTuo$EFKQAqNuBzvUDl4hxACBbZzgYYO18yBw6/u.e8nIjHckpgFqmHRj4qh/UjrxKyH2lzUNQU41FcYaX3T0Jm1j70";
  in {
    programs.fish.enable = true;

    users.users.chris = {
      isNormalUser = true;
      description = "Chris";
      extraGroups = ["networkmanager" "wheel" "video" "audio"];
      shell = pkgs.fish;
      hashedPassword = passwordHash;
    };

    users.users.work = {
      isNormalUser = true;
      description = "Work";
      extraGroups = ["networkmanager" "wheel" "video" "audio"];
      shell = pkgs.fish;
      hashedPassword = passwordHash;
    };
  };
}
