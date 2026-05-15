{
  inputs = {
    # Use `nix flake update` to update the flake to the latest revision of the chosen release channel.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    nixos-hardware,
    home-manager,
    ...
  }: {
    nixosConfigurations.combobulator = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        nixos-hardware.nixosModules.dell-xps-15-9530-nvidia
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.f1sty = import ./home.nix;
            backupFileExtension = "backup";
          };
        }
      ];
    };
  };
}
