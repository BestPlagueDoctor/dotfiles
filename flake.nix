{
  description = "Nix-based config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixgl.url = "github:nix-community/nixGL";

    armeenm-dotfiles = {
      url = "github:armeenm/dotfiles";
      #inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, ... }: let
    inherit ( inputs.armeenm-dotfiles.inputs ) nixpkgs;
    config = {
      allowUnfree = true;
      contentAddressedByDefault = false;
    };

    overlays = [ inputs.armeenm-dotfiles.overlays.default ];

    forAllSystems = inputs.armeenm-dotfiles.lib.forAllSystems;

    root = ./.;
    user = {
      login = "sam";
      name = "Sam Knight";
      email = "ksam1337@gmail.com";
    };

    baseModules = [
      { _module.args = {
          inherit root user;
          inputs = inputs.armeenm-dotfiles.inputs;
        }; }
      { nixpkgs = { inherit config overlays; }; }
    ];

    hmModules = baseModules;

    modules = hmModules ++ [
      inputs.home-manager.nixosModules.home-manager
      inputs.lanzaboote.nixosModules.lanzaboote
      inputs.ragenix.nixosModules.default
      ./modules
    ];

  in {
    nixosConfigurations = {
      lithium = nixpkgs.lib.nixosSystem {
        modules = baseModules ++ [
          inputs.armeenm-dotfiles.nixosModules.nixosInteractive
          ./hosts/lithium
        ];
      };

      magi = nixpkgs.lib.nixosSystem {
        modules = baseModules ++ [
          inputs.armeenm-dotfiles.nixosModules.nixosBase
          ./hosts/magi
        ];
      };

      navi = nixpkgs.lib.nixosSystem {
        modules = baseModules ++ [
          inputs.armeenm-dotfiles.nixosModules.nixosInteractive
          ./hosts/navi
        ];
      };
    };

    homeConfigurations = forAllSystems (system: pkgs: with pkgs; {
      default = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = hmModules ++ [ 
	  { nixpkgs = {inherit config overlays;}; }
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
            sudo = "doas -u";
            path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.lithium;
          };
        };
      };

      nodes = {
        navi = {
          hostname = "navi";
          profiles.system = {
            user = "root";
            sudo = "doas -u";
            path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.navi;
          };
        };
      };

      nodes = {
        magi = {
          hostname = "magi";
          profiles.system = {
            user = "root";
            sudo = "doas -u";
            path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.magi;
          };
        };
      };
    };

    devShells = inputs.armeenm-dotfiles.devShells;
    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) inputs.deploy-rs.lib;
  };
} 
