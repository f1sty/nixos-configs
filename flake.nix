{
  inputs = {
    # Use `nix flake update` to update the flake to the latest revision of the chosen release channel.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    nixos-hardware,
    home-manager,
    nix-index-database,
    ...
  }: {
    nixosConfigurations.combobulator = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        nixos-hardware.nixosModules.dell-xps-15-9530-nvidia
        ({ pkgs, ... }: {
          nixpkgs.overlays = [
            (final: prev: {
              python313Packages = prev.python313Packages.overrideScope (
                pyfinal: pyprev: {
                  uefi-firmware-parser =
                    pyprev.uefi-firmware-parser.overridePythonAttrs (old: {
                      nativeBuildInputs =
                        (old.nativeBuildInputs or [])
                        ++ [ pyfinal.setuptools-scm ];
                    });
                }
              );
            })
          ];
        })
        ./configuration.nix
        nix-index-database.nixosModules.default
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
