# volt — CLI helper for connecting to remote OpenClaw coding VMs
{ writeShellApplication, openclaw-gateway ? null }:

writeShellApplication {
  name = "volt";

  runtimeInputs = [];

  text = ''
    set -euo pipefail

    VOLT_CONFIG_DIR="''${HOME}/.config/volt"
    TAILNET_SUFFIX="''${VOLT_TAILNET:-tail6277a6.ts.net}"
    VM_IDS=(''${VOLT_VM_IDS:-1 2 3 4})

    usage() {
      cat <<EOF
    Usage: volt <id> <openclaw subcommand ...>
           volt ls
           volt setup [token]

    Commands:
      volt <id> tui          Open TUI connected to volt-<id>
      volt <id> health       Health check volt-<id>
      volt <id> <cmd> ...    Run any openclaw subcommand against volt-<id>
      volt ls                List all Volt VMs and their URLs
      volt setup <token>     Store shared auth password

    Environment:
      VOLT_TAILNET     Override tailnet suffix (default: tail6277a6.ts.net)
      VOLT_VM_IDS      Override VM IDs (default: 1 2 3 4)
      VOLT_PASSWORD    Password (overrides token file)

    Token resolution (first match wins):
      1. ~/.config/volt/volt-<id>.token
      2. ~/.config/volt/token
      3. VOLT_PASSWORD env var
    EOF
      exit 1
    }

    get_token() {
      local id="$1"
      local per_vm="''${VOLT_CONFIG_DIR}/volt-''${id}.token"
      local shared="''${VOLT_CONFIG_DIR}/token"

      if [[ -f "$per_vm" ]]; then
        cat "$per_vm"
      elif [[ -f "$shared" ]]; then
        cat "$shared"
      elif [[ -n "''${VOLT_PASSWORD:-}" ]]; then
        echo "$VOLT_PASSWORD"
      else
        echo "Error: No token found. Run: volt setup <token>" >&2
        exit 1
      fi
    }

    cmd_ls() {
      echo "Volt MicroVMs:"
      for id in "''${VM_IDS[@]}"; do
        local url="https://volt-''${id}.''${TAILNET_SUFFIX}"
        local token_status="✗ no token"
        if [[ -f "''${VOLT_CONFIG_DIR}/volt-''${id}.token" ]] || \
           [[ -f "''${VOLT_CONFIG_DIR}/token" ]] || \
           [[ -n "''${VOLT_PASSWORD:-}" ]]; then
          token_status="✓ token set"
        fi
        printf "  volt-%-2s  %s  (%s)\n" "$id" "$url" "$token_status"
      done
    }

    cmd_setup() {
      local token="''${1:-}"
      if [[ -z "$token" ]]; then
        echo "Usage: volt setup <token>" >&2
        exit 1
      fi
      mkdir -p "$VOLT_CONFIG_DIR"
      echo -n "$token" > "''${VOLT_CONFIG_DIR}/token"
      chmod 600 "''${VOLT_CONFIG_DIR}/token"
      echo "Token saved to ''${VOLT_CONFIG_DIR}/token"
    }

    # --- Main ---
    if [[ $# -lt 1 ]]; then
      usage
    fi

    case "$1" in
      ls|list)  cmd_ls; exit 0 ;;
      setup)    shift; cmd_setup "$@"; exit 0 ;;
      -h|--help|help) usage ;;
    esac

    VM_ID="$1"
    shift

    if [[ $# -lt 1 ]]; then
      echo "Error: Missing openclaw subcommand. e.g.: volt $VM_ID tui" >&2
      exit 1
    fi

    if ! [[ "$VM_ID" =~ ^[0-9]+$ ]]; then
      echo "Error: VM ID must be a number, got '$VM_ID'" >&2
      exit 1
    fi

    TOKEN="$(get_token "$VM_ID")"
    URL="https://volt-''${VM_ID}.''${TAILNET_SUFFIX}"

    export OPENCLAW_GATEWAY_URL="$URL"
    export OPENCLAW_GATEWAY_PASSWORD="$TOKEN"

    exec openclaw "$@"
  '';
}
