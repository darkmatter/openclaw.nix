# Gateway configuration builder
{ lib }:

{ role, primaryUrl, port, tokenPath, passwordPath, hostId }:

let
  authBlock = {
    mode = "password";
    allowTailscale = true;
  } // lib.optionalAttrs (tokenPath != null) {
    token = tokenPath;
  } // lib.optionalAttrs (passwordPath != null) {
    password = passwordPath;
  };
in
{
  auth = authBlock;
  inherit port;
}
// (
  if role == "primary" then {
    mode = "local";
    bind = "loopback";
    tailscale = {
      mode = "funnel";
      resetOnExit = true;
    };
    remote = {
      transport = "direct";
      url = primaryUrl;
    } // lib.optionalAttrs (tokenPath != null) {
      token = tokenPath;
    } // lib.optionalAttrs (passwordPath != null) {
      password = passwordPath;
    };
    controlUi.allowedOrigins = [ primaryUrl ];
  }
  else {
    mode = "remote";
    bind = "loopback";
    tailscale.mode = "off";
    remote = {
      transport = "direct";
      url = primaryUrl;
    } // lib.optionalAttrs (tokenPath != null) {
      token = tokenPath;
    } // lib.optionalAttrs (passwordPath != null) {
      password = passwordPath;
    };
  }
)
