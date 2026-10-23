{
  description = "junjie's NixOS configuration";

  inputs = {
    nixpkgs.url = "git+https://github.com/NixOS/nixpkgs.git?ref=nixpkgs-unstable&shallow=1";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llm-agents.url = "github:numtide/llm-agents.nix";
    omni-code = {
      url = "git+file:///data/code/code/omni-code";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    omni-code-bridge = {
      url = "git+file:///data/code/code/omni-code-bridge";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, llm-agents, omni-code, omni-code-bridge, ... }:
    {
      nixosConfigurations.junjiepc = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/junjiepc
          home-manager.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = { inherit llm-agents omni-code omni-code-bridge; };
            # ZeroClaw is not in nixpkgs yet, so surface the locally packaged
            # release binary as `pkgs.zeroclaw`.
            nixpkgs.overlays = [
              (final: prev: {
                zeroclaw = prev.callPackage ./pkgs/zeroclaw.nix { };
              })
            ];
          }
        ];
      };
    };
}
