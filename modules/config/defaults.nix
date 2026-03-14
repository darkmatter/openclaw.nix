# Agent defaults
{ models }:

model: {
  compaction.mode = "safeguard";
  contextPruning = {
    mode = "cache-ttl";
    ttl = "1h";
  };
  heartbeat.every = "1h";
  maxConcurrent = 4;
  model = {
    fallbacks = [
      "anthropic/claude-sonnet-4-6"
      "openai/gpt-5.4"
    ];
    primary = model;
  };
  models = {
    "anthropic/claude-sonnet-4-6" = {};
    "openai/gpt-5.4" = { alias = "GPT"; };
    "openrouter/auto" = { alias = "Auto"; };
  };
}
