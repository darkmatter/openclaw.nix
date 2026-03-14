# Agent definitions
{ lib, models }:

let
  mkBaseAgent = { id, name, emoji, model, profile ? "coding", tools ? {} }:
  {
    agentDir = "~/.openclaw/agents/${id}/agent";
    default = false;
    inherit id;
    identity = {
      inherit emoji name;
      theme = "ayu";
    };
    inherit model;
    inherit name;
    sandbox.mode = "off";
    subagents.allowAgents = [ "*" ];
    tools = {
      allow = [ "*" ];
      deny = [ "canvas" ];
      elevated.enabled = true;
      inherit profile;
    } // tools;
    workspace = "~/.openclaw/workspace";
  };

  agentDefs = {
    main = { name, emoji, model }: mkBaseAgent {
      id = "main";
      inherit name emoji model;
      profile = "coding";
    } // { default = true; };

    coder = { model, ... }: mkBaseAgent {
      id = "coder";
      name = "Coding Agent";
      emoji = "⚡";
      inherit model;
      profile = "coding";
    };

    assistant = { model, ... }: mkBaseAgent {
      id = "assistant";
      name = "Executive Assistant";
      emoji = "👩‍💼";
      inherit model;
      profile = "messaging";
      tools = {
        deny = [ "canvas" "sudo" "git" ];
        elevated.enabled = false;
      };
    };
  };

in {
  buildAgentList = { agents, model, name, emoji }:
    map (agentId:
      let
        builder = agentDefs.${agentId} or (throw "Unknown agent: ${agentId}");
      in builder { inherit model name emoji; }
    ) agents;
}
