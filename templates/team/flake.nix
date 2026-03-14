{
  description = "Team OpenClaw setup with coding agents + ACP";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    openclaw-config.url = "github:coopmoney/openclaw";
  };

  outputs = { nixpkgs, openclaw-config, ... }: {
    # Primary gateway host (e.g. Mac Studio / always-on server):
    #
    # openclaw-team = {
    #   enable = true;
    #   hostId = "mac-studio";
    #   role = "primary";
    #   primaryUrl = "wss://mac-studio.tail12345.ts.net";
    #   agents = [ "main" "coder" "assistant" ];
    #   model = "anthropic/claude-opus-4-6";
    #   identity = {
    #     name = "Sotheby";
    #     emoji = "🎩";
    #   };
    #   acp = {
    #     enable = true;
    #     defaultAgent = "volt-1";
    #     allowedAgents = [ "volt-1" "volt-2" "codex" "claude" ];
    #   };
    #   secrets = {
    #     tokenPath = "/run/agenix/openclaw-gateway-token";
    #     passwordPath = "/run/agenix/openclaw-gateway-password";
    #   };
    # };
    #
    # Remote machines (laptops, etc.):
    #
    # openclaw-team = {
    #   enable = true;
    #   hostId = "macbook-pro";
    #   role = "remote";
    #   primaryUrl = "wss://mac-studio.tail12345.ts.net";
    #   agents = [ "main" ];
    #   model = "anthropic/claude-sonnet-4-6";
    #   secrets = {
    #     passwordPath = "/run/agenix/openclaw-gateway-password";
    #   };
    # };
  };
}
