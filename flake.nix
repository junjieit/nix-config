{
  description = "junjie's NixOS configuration";

  inputs = {
    nixpkgs.url = "git+https://mirrors.tuna.tsinghua.edu.cn/git/nixpkgs.git?ref=nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    {
      nixosConfigurations.junjiepc = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit self home-manager; };
        modules = [
          ./hosts/junjiepc
        ];
      };

      homeConfigurations.junjie =
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          modules = [ ./home/junjie.nix ];
        };
    };
}
