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
    # Shared config module — import this into your own darwin/home-manager/NixOS config
    openclawModule = import ./modules/openclaw.nix;

    # Convenience: pre-built overlay that provides openclaw-gateway package
    overlay = nix-openclaw.overlays.default;
  in {
    # Home-manager module for personal machines (macOS / Linux desktop)
    homeManagerModules = {
      openclaw = openclawModule;
      default = openclawModule;
    };

    # NixOS module for headless servers / VMs
    nixosModules = {
      openclaw-gateway = nix-openclaw.nixosModules.openclaw-gateway;
      default = nix-openclaw.nixosModules.openclaw-gateway;
    };

    # Re-export the overlay
    overlays.default = overlay;

    # Templates for quick-start
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
