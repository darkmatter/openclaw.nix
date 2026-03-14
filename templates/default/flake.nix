{
  description = "My OpenClaw setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    openclaw-config.url = "github:coopmoney/openclaw";
    # Your darwin/home-manager flake
    # darwin.url = "github:LnL7/nix-darwin";
    # home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { nixpkgs, openclaw-config, ... }: {
    # Add to your home-manager config:
    #
    # imports = [ openclaw-config.homeManagerModules.default ];
    #
    # openclaw-team = {
    #   enable = true;
    #   hostId = "my-macbook";
    #   role = "remote";
    #   primaryUrl = "wss://my-gateway.tail12345.ts.net";
    #   agents = [ "main" ];
    #   model = "anthropic/claude-sonnet-4-6";
    #   identity = {
    #     name = "My Agent";
    #     emoji = "🤖";
    #   };
    #   secrets = {
    #     passwordPath = "/run/agenix/openclaw-gateway-password";
    #   };
    # };
  };
}
