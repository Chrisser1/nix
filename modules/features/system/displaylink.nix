{ ... }: {
  flake.nixosModules.displaylink = { ... }: {
    # DisplayLink USB docks (e.g. Dell D6000). The nixpkgs module keys off this list and
    # pulls in evdi, the udev rules and the dlm service; modesetting keeps the iGPU driving eDP.
    # The driver zip is unfree and fetched via requireFile, so after a GC/fresh install run:
    #   nix-prefetch-url --name displaylink-620.zip "https://www.synaptics.com/sites/default/files/exe_files/2025-09/DisplayLink%20USB%20Graphics%20Software%20for%20Ubuntu6.2-EXE.zip"
    services.xserver.videoDrivers = [ "displaylink" "modesetting" ];
  };
}
