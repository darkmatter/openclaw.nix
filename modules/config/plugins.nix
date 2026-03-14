# Default plugin configuration
{
  allow = [
    "acpx"
  ];
  entries = {
    acpx = {
      enabled = true;
      config = {
        permissionMode = "approve-all";
        nonInteractivePermissions = "deny";
      };
    };
  };
}
