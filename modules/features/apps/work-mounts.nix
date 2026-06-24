{ self, ... }: {
  flake.homeModules.work-mounts = { pkgs, ... }: {
    home.packages = with pkgs; [
      rclone
      fuse3
    ];

    # Setup the directories
    xdg.userDirs = {
      enable = true;
      createDirectories = true;
      setSessionVariables = true;
      extraConfig = {
        SHAREPOINT_TEAM = "$HOME/WavepistonTeamFolder";
        SHAREPOINT_DATA = "$HOME/WavepistonDataWarehouse";
      };
    };

    # Background systemd services to mount them automatically
    systemd.user.services = {
      WavepistonTeamFolder-mount = {
        Unit = {
          Description = "Mount Wavepiston Team Folder";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
        Service = {
          ExecStart = "${pkgs.rclone}/bin/rclone mount WavepistonTeamFolder: %h/WavepistonTeamFolder --vfs-cache-mode writes";
          ExecStop = "${pkgs.fuse3}/bin/fusermount3 -u %h/WavepistonTeamFolder";
          Restart = "on-failure";
        };
      };

      WavepistonDataWarehouse-mount = {
        Unit = {
          Description = "Mount Wavepiston DataWarehouse";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
        Service = {
          ExecStart = "${pkgs.rclone}/bin/rclone mount WavepistonDataWarehouse: %h/WavepistonDataWarehouse --vfs-cache-mode writes";
          ExecStop = "${pkgs.fuse3}/bin/fusermount3 -u %h/WavepistonDataWarehouse";
          Restart = "on-failure";
        };
      };
    };
    
  };
}