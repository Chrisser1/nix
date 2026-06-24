{ self, ... }: {
  flake.nixosModules.oracle-configuration = { config, pkgs, secrets, ... }: {
    imports = [ self.nixosModules.oracle-hardware ];

    networking.hostName = "oracle";
    system.stateVersion = "25.05";

    services.tailscale.enable = true;

    # Ensure SSH is running and strictly allows your key
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "prohibit-password";
      };
    };

    environment.systemPackages = with pkgs; [
      fastfetch
    ];

    users.users.root.openssh.authorizedKeys.keys = secrets.sshKeys;
    users.users.root.shell = pkgs.fish;
  };
}