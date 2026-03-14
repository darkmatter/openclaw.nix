{
  description = "OpenClaw team configuration flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-openclaw = {
      url = "github:openclaw/nix-openclaw";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-openclaw, agenix, sops-nix, ... }:
  let
    openclawModule = import ./modules/openclaw.nix;
    overlay = nix-openclaw.overlays.default;

    supportedSystems = [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux" ];
    forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
      pkgs = import nixpkgs { inherit system; overlays = [ overlay ]; };
      inherit system;
    });
  in {
    # Home-manager module
    homeManagerModules = {
      openclaw = openclawModule;
      default = openclawModule;
    };

    # NixOS module for servers / VMs
    nixosModules = {
      openclaw-gateway = nix-openclaw.nixosModules.openclaw-gateway;
      default = nix-openclaw.nixosModules.openclaw-gateway;
    };

    # Overlay
    overlays.default = overlay;

    # Packages
    packages = forAllSystems ({ pkgs, ... }: {
      volt = pkgs.callPackage ./packages/volt.nix {};
      default = pkgs.callPackage ./packages/volt.nix {};
    });

    # Templates
    templates = {
      default = {
        path = ./templates/default;
        description = "Basic OpenClaw setup with one agent";
      };
      team = {
        path = ./templates/team;
        description = "Multi-agent team setup with coding + assistant agents";
      };
    };
  };
}
