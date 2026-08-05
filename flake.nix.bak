{
  description = "junjie's NixOS configuration";

  inputs = {
    nixpkgs.url = "tarball+https://mirrors.ustc.edu.cn/nix-channels/nixos-unstable/nixexprs.tar.xz";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    {
      nixosConfigurations.junjiepc = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit self; };
        modules = [
          home-manager.nixosModules.home-manager
          ./hosts/junjiepc
        ];
      };
    };
}
