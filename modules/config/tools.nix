# Default tool configuration
{
  agentToAgent = {
    allow = [ "*" ];
    enabled = true;
  };
  elevated.enabled = true;
  exec = {
    ask = "off";
    host = "gateway";
    security = "full";
  };
  links.enabled = true;
  sessions.visibility = "all";
  profile = "full";
}
