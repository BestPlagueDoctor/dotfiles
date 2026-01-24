{
  description = "Nix-based config";

  inputs = {
    armeenm-dotfiles.url = "github:armeenm/dotfiles";
  };

  outputs = { self, armeenm-dotfiles, ... }: let
    inherit (armeenm-dotfiles) inputs lib nixosModules;
    inherit (inputs) deploy-rs nixpkgs;

    config = {
      allowUnfree = true;
      contentAddressedByDefault = false;
    };
    overlays = [ armeenm-dotfiles.overlays.default ];
    forAllSystems = lib.forAllSystems;

    root = ./.;
    user = {
      login = "sam";
      name = "Sam Knight";
      email = "samuelk@ami.com";
    };

    baseModules = [
      { _module.args = { inherit root user inputs; }; }
      { nixpkgs = { inherit config overlays; }; }
    ];
    hmModules = baseModules;

  in {
    nixosConfigurations = {
      lithium = nixpkgs.lib.nixosSystem {
        modules = baseModules ++ [
          nixosModules.nixosInteractive
          ./hosts/lithium
        ];
      };

      magi = nixpkgs.lib.nixosSystem {
        modules = baseModules ++ [
          nixosModules.nixosBase
          ./hosts/magi
        ];
      };

      navi = nixpkgs.lib.nixosSystem {
        modules = baseModules ++ [
          nixosModules.nixosInteractive
          ./hosts/navi
        ];
      };
      motherbrain = nixpkgs.lib.nixosSystem {
        modules = baseModules ++ [
          nixosModules.nixosInteractive
          ./hosts/motherbrain
        ];
      };
    };

    homeConfigurations = forAllSystems (system: pkgs: with pkgs; {
      default = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = hmModules ++ [ 
	        { nixpkgs = { inherit config overlays; }; }
	        ./home 
	        {
	          home = {
	            homeDirectory = "/home/${user.login}";
	            username = "${user.login}";
	          };
	        }
	      ];

	      extraSpecialArgs = {
	        stateVersion = "24.11";
	        isHeadless = false;
	        osConfig.nixpkgs = pkgs;
	      };
      };
    });

    deploy = {
      nodes = {
        lithium = {
          hostname = "lithium";
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.lithium;
          };
        };
      };

      nodes = {
        navi = {
          hostname = "navi";
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.navi;
          };
        };
      };

      nodes = {
        magi = {
          hostname = "magi";
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.magi;
          };
        };
      };
      nodes = {
        motherbrain = {
          hostname = "motherbrain";
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.magi;
          };
        };
      };
    };

    devShells = armeenm-dotfiles.devShells;
    checks =
      builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) inputs.deploy-rs.lib;
  };
} 
