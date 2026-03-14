# OpenClaw home-manager module
# Import this into your home-manager config:
#   imports = [ openclaw.homeManagerModules.default ];
#
# Then configure:
#   openclaw-team = {
#     enable = true;
#     hostId = "my-hostname";
#     role = "primary";  # or "remote"
#     primaryUrl = "wss://my-host.tail12345.ts.net";
#     agents = [ "main" "coder" ];
#     model = "anthropic/claude-sonnet-4-6";
#   };
{ config, lib, pkgs, ... }:

let
  cfg = config.openclaw-team;

  models = import ./config/models.nix;
  mkAgent = import ./config/agents.nix { inherit lib models; };
  mkGateway = import ./config/gateway.nix { inherit lib; };
  mkPlugins = import ./config/plugins.nix;
  mkTools = import ./config/tools.nix;
  mkDefaults = import ./config/defaults.nix { inherit models; };
in {
  options.openclaw-team = {
    enable = lib.mkEnableOption "OpenClaw team configuration";

    hostId = lib.mkOption {
      type = lib.types.str;
      description = "Unique identifier for this host (used for gateway routing)";
    };

    role = lib.mkOption {
      type = lib.types.enum [ "primary" "remote" ];
      default = "remote";
      description = ''
        primary: runs the gateway locally with Tailscale Funnel
        remote: connects to a primary gateway
      '';
    };

    primaryUrl = lib.mkOption {
      type = lib.types.str;
      description = "WebSocket URL of the primary gateway (e.g. wss://host.tail12345.ts.net)";
    };

    tailnet = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Tailnet suffix (e.g. tail12345.ts.net) — auto-derived from primaryUrl if unset";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 18789;
      description = "Gateway port";
    };

    agents = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "main" ];
      description = "Which agents to enable: main, coder, assistant";
    };

    model = lib.mkOption {
      type = lib.types.str;
      default = "anthropic/claude-sonnet-4-6";
      description = "Default model for agents";
    };

    identity = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "OpenClaw";
        description = "Agent display name";
      };
      emoji = lib.mkOption {
        type = lib.types.str;
        default = "🦞";
        description = "Agent emoji";
      };
    };

    secrets = {
      tokenPath = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Path to gateway auth token file";
      };
      passwordPath = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Path to gateway auth password file";
      };
    };

    acp = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable ACP for remote coding agents";
      };
      allowedAgents = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "ACP agent IDs to allow (e.g. volt-1, codex, claude)";
      };
      defaultAgent = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Default ACP agent ID";
      };
    };

    extraConfig = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Extra config merged into openclaw.json";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.openclaw = {
      instances.default = {
        enable = true;

        config = lib.recursiveUpdate {
          agents = {
            list = mkAgent.buildAgentList {
              inherit (cfg) agents model;
              inherit (cfg.identity) name emoji;
            };
            defaults = mkDefaults cfg.model;
          };

          gateway = mkGateway {
            inherit (cfg) role primaryUrl port;
            inherit (cfg.secrets) tokenPath passwordPath;
            hostId = cfg.hostId;
          };

          tools = mkTools;
          plugins = mkPlugins;

          channels = {};
          bindings = [];
          skills.entries = {};
          messages.tts.auto = "off";
          cron.enabled = true;
          env.shellEnv.enabled = true;
          session.dmScope = "per-channel-peer";
        } // (lib.optionalAttrs cfg.acp.enable {
          acp = {
            enabled = true;
            backend = "acpx";
            defaultAgent = cfg.acp.defaultAgent;
            allowedAgents = cfg.acp.allowedAgents;
            maxConcurrentSessions = 8;
            stream = { coalesceIdleMs = 300; maxChunkChars = 1200; };
            runtime.ttlMinutes = 120;
          };
        }) // cfg.extraConfig;
      };
    };
  };
}
