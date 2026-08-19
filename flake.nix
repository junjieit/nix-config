{
  description = "junjie's NixOS configuration";

  inputs = {
    nixpkgs.url = "git+https://mirrors.tuna.tsinghua.edu.cn/git/nixpkgs.git?ref=nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs = { nixpkgs, home-manager, llm-agents, ... }:
    {
      nixosConfigurations.junjiepc = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/junjiepc
          home-manager.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = { inherit llm-agents; };
          }
        ];
      };
    };
}
