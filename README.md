# OpenClaw Team Configuration

Nix flake for sharing a consistent OpenClaw setup across team members and machines.

## Quick Start

### 1. Add to your flake inputs

```nix
inputs.openclaw-config.url = "github:coopmoney/openclaw";
```

### 2. Import the home-manager module

```nix
imports = [ openclaw-config.homeManagerModules.default ];
```

### 3. Configure

```nix
openclaw-team = {
  enable = true;
  hostId = "my-macbook";
  role = "remote";              # "primary" for the gateway host, "remote" for others
  primaryUrl = "wss://gateway-host.tail12345.ts.net";
  agents = [ "main" "coder" ]; # which agents to enable
  model = "anthropic/claude-sonnet-4-6";

  identity = {
    name = "My Agent";
    emoji = "🤖";
  };

  # Point to your decrypted secret files (agenix, sops-nix, etc.)
  secrets = {
    passwordPath = "/run/agenix/openclaw-gateway-password";
    # tokenPath = "/run/agenix/openclaw-gateway-token";
  };

  # Optional: enable ACP for remote coding agents
  acp = {
    enable = true;
    defaultAgent = "volt-1";
    allowedAgents = [ "volt-1" "volt-2" "codex" "claude" ];
  };
};
```

## Architecture

```
┌─────────────────────────────────────────────────┐
│  Primary Host (Mac Studio / always-on server)    │
│  role = "primary"                                │
│  ┌──────────────────────┐                        │
│  │  OpenClaw Gateway    │◄── Tailscale Funnel    │
│  │  (local mode)        │    wss://host.ts.net   │
│  └──────────────────────┘                        │
│           ▲                                      │
│           │ ACP                                  │
│  ┌────────┴─────────┐                            │
│  │ Volt VMs (acpx)  │                            │
│  │ volt-1..4        │                            │
│  └──────────────────┘                            │
└─────────────────────────────────────────────────┘
          ▲              ▲              ▲
          │              │              │
   ┌──────┴──┐    ┌──────┴──┐    ┌──────┴──┐
   │ MacBook │    │ Mac Pro │    │ Phone   │
   │ remote  │    │ remote  │    │ remote  │
   └─────────┘    └─────────┘    └─────────┘
```

## Roles

| Role | Gateway | Funnel | Use Case |
|------|---------|--------|----------|
| `primary` | local mode, binds loopback | enabled | Always-on server, Mac Studio |
| `remote` | remote mode, connects to primary | off | Laptops, phones, other machines |

## Agents

| ID | Profile | Description |
|----|---------|-------------|
| `main` | coding | Primary agent — your default AI assistant |
| `coder` | coding | Dedicated coding agent for development tasks |
| `assistant` | messaging | Executive assistant for scheduling, comms |

## ACP (Remote Coding Agents)

When `acp.enable = true`, the primary gateway can delegate tasks to remote coding agents via the Agent Client Protocol. Agents like `volt-1` run on separate machines (microVMs, cloud servers) and connect back via Tailscale Funnel.

## Secret Management

This flake doesn't manage secrets directly — point `secrets.tokenPath` and `secrets.passwordPath` to wherever your secret manager places them:

- **agenix**: `/run/agenix/openclaw-gateway-password`
- **sops-nix**: `/run/secrets/openclaw-gateway-password`
- **1Password CLI**: pipe from `op read`
- **Plain file**: any readable path

## Templates

```bash
# Basic single-agent setup
nix flake init -t github:coopmoney/openclaw#default

# Multi-agent team setup
nix flake init -t github:coopmoney/openclaw#team
```
