{
  description = "My NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Declarative KDE Plasma settings (themes, window decorations, apps)
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { nixpkgs, home-manager, plasma-manager, nixvim, ... }: {
    # Build:  sudo nixos-rebuild switch --flake .#nixos
    # Test:   nixos-rebuild build-vm --flake .#nixos && ./result/bin/run-*-vm
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        home-manager.nixosModules.home-manager
        { home-manager.sharedModules = [
            plasma-manager.homeModules.plasma-manager
            nixvim.homeModules.nixvim
          ]; }
        ./configuration.nix
      ];
    };
  };
}
