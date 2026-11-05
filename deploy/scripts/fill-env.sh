#!/usr/bin/env bash
# Guided filling of the deployment settings files on the server. For every setting that is still
# empty or CHANGE_ME it explains what the value is and where to find it, then asks for it with
# hidden input (Enter = leave as is, or use the suggested standard value). Values are never shown
# and are written safely whatever characters they contain. Files stay chmod 600.
#   bash /home/deploy/app/deploy/scripts/fill-env.sh
#
# Files (override for testing): PROD_ENV, DEV_ENV, PROXY_ENV, BACKUP_ENV.
# FILL_ENV_INPUT=<file> reads answers from a file instead of the keyboard (tests only).
set -euo pipefail
umask 077

PROD_ENV="${PROD_ENV:-/home/deploy/app/deploy/.env}"
DEV_ENV="${DEV_ENV:-/home/deploy/app-dev/deploy/.env}"
PROXY_ENV="${PROXY_ENV:-/home/deploy/app/deploy/proxy/.env}"
BACKUP_ENV="${BACKUP_ENV:-/home/deploy/backup.env}"

[ "${FILL_ENV_SKIP_HOST_CHECK:-}" = 1 ] || [ "$(hostname)" = srv2131878 ] \
  || { echo "Wrong server: $(hostname). Nothing changed."; exit 1; }
if [ -n "${FILL_ENV_INPUT:-}" ]; then exec 3<"$FILL_ENV_INPUT"; else exec 3</dev/tty; fi

# ---- writing values ----------------------------------------------------------------------------

# Docker Compose .env format: plain when the value is simple, single quotes (taken literally)
# otherwise, double quotes with escapes only when the value itself contains a single quote.
compose_format() {
  local v="$1"
  if [[ "$v" =~ ^[A-Za-z0-9._@:/+=,-]*$ ]]; then printf '%s' "$v"
  elif [[ "$v" != *"'"* ]]; then printf "'%s'" "$v"
  else
    v="${v//\\/\\\\}"; v="${v//\"/\\\"}"; v="${v//\$/\$\$}"
    printf '"%s"' "$v"
  fi
}

# set_value <file> <key> <already formatted value>: replace KEY=..., or append it if missing
set_value() {
  local file="$1" key="$2" tmp
  tmp="$(mktemp "$(dirname "$file")/.fill-env.XXXXXX")"
  NEWVAL="$3" awk -v k="$key" '
    BEGIN { v = ENVIRON["NEWVAL"] }
    !done && index($0, k "=") == 1 { print k "=" v; done = 1; next }
    { print }
    END { if (!done) print k "=" v }' "$file" > "$tmp"
  chmod 600 "$tmp"
  mv "$tmp" "$file"
}

current() { grep -E "^$2=" "$1" | tail -1 | cut -d= -f2- || true; }
needs_value() { local v; v="$(current "$1" "$2")"; [ -z "$v" ] || [[ "$v" == *CHANGE_ME* ]]; }

# ---- asking ------------------------------------------------------------------------------------

ask_hidden() {  # ask_hidden <prompt>  -> REPLY (never echoed)
  local line
  printf '%s' "$1" >/dev/tty 2>/dev/null || printf '%s' "$1"
  IFS= read -rs -u 3 line || line=""
  printf '\n'
  REPLY="${line%$'\r'}"
}

ask_pem() {  # multi-line private key -> REPLY as one line with \n between lines
  local line lines=() started=0
  echo "  Paste the whole private key (BEGIN and END lines included), then press Enter."
  echo "  Press Enter on an empty line to leave it empty. Nothing is shown while you paste."
  while IFS= read -rs -u 3 line; do
    line="${line%$'\r'}"
    if [ "$started" = 0 ]; then
      [ -z "$line" ] && { REPLY=""; echo; return; }
      # Already in one-line form (\n written out): take it as it is
      if [[ "$line" == *'-----BEGIN'*'\n'* ]]; then lines=("${line//\\n/$'\n'}"); break; fi
      [[ "$line" == -----BEGIN* ]] || { echo; echo "  That does not start with -----BEGIN ... KEY-----. Try again."; continue; }
      started=1
    fi
    lines+=("$line")
    [[ "$line" == -----END* ]] && break
  done
  echo
  local pem; pem="$(printf '%s\n' "${lines[@]}")"; pem="${pem%$'\n'}"
  if command -v openssl >/dev/null && ! printf '%s\n' "$pem" | openssl pkey -noout >/dev/null 2>&1; then
    echo "  WARNING: openssl could not read this as a private key. Saved anyway; check you copied all of it."
  fi
  REPLY="${pem//$'\n'/\\n}"   # one line, \n between lines (the app turns them back into line breaks)
}

# ---- what each setting is ----------------------------------------------------------------------
# kind: required | optional | default:<value> | random:<openssl args> | pem | skip | r2account | email

describe() {  # describe <scope prod|dev|proxy|backup> <key>  -> KIND, HELP
  KIND="optional"; HELP=""
  case "$2" in
    POSTGRES_PASSWORD|JWT_SECRET_KEY|FIELD_ENCRYPTION_KEY|GARAGE_RPC_SECRET)
      KIND="random:hex32"; HELP="Random secret, generated for you." ;;
    SWAGGER_PASSWORD) KIND="random:hex16"; HELP="Password for the API docs page, generated for you." ;;
    AWS_ACCESS_KEY_ID)
      if [ "$1" = backup ]; then KIND="required"
        HELP="R2 backup token: Access Key ID. Cloudflare -> R2 -> Manage API tokens -> the
  'omlapay-vps-backups' token (Object Read & Write, only bucket omlapay-backups)."
      else KIND="random:garagekey"; HELP="Garage storage key, generated for you."; fi ;;
    AWS_SECRET_ACCESS_KEY)
      if [ "$1" = backup ]; then KIND="required"
        HELP="R2 backup token: Secret Access Key (shown once when the token was created)."
      else KIND="random:hex32"; HELP="Garage storage secret, generated for you."; fi ;;
    RESTIC_PASSWORD) KIND="random:hex32"
      HELP="Backup encryption password, generated for you. Save backup.env in your password manager." ;;
    RESTIC_REPOSITORY) KIND="r2account"
      HELP="Your Cloudflare Account ID (32 characters): Cloudflare -> R2 Object Storage -> overview
  page, right side 'Account Details'. The backup address is built from it." ;;
    ACME_EMAIL) KIND="email"
      HELP="Your email address for HTTPS certificate notices from Let's Encrypt (expiry warnings)." ;;
    SWAGGER_USER) KIND="required"
      HELP="A username you choose for the API docs page (https://api.omlapay.org/docs), e.g. admin." ;;
    SUPPORT_EMAIL)
      if [ "$1" = prod ]; then KIND="required"; else KIND="optional"; fi
      HELP="Your support email address, shown to users and used for account-block notices.
  Required in production (blocking a user fails without it)." ;;
    APP_INVITE_URL) KIND="default:https://omlapay.com/download"
      HELP="Link sent in invite SMS (App Store / Play Store or your download page)." ;;
    TAQNYAT_API_URL)
      if [ "$1" = prod ]; then KIND="default:https://api.taqnyat.sa/v1"; else KIND="skip"; fi
      HELP="Taqnyat SMS API address. The standard value is right unless Taqnyat told you otherwise." ;;
    TAQNYAT_API_KEY)
      if [ "$1" = prod ]; then KIND="optional"; else KIND="skip"; fi
      HELP="Taqnyat Bearer token: Taqnyat portal (portal.taqnyat.sa) -> Developers -> Application ->
  your application's Bearer Token. Without it no SMS is sent (login codes!)." ;;
    TAQNYAT_SENDER_NAME)
      if [ "$1" = prod ]; then KIND="optional"; else KIND="skip"; fi
      HELP="Approved sender name in Taqnyat: portal -> Senders (exactly as approved, e.g. OmlaPay)." ;;
    TAQNYAT_BEARER_TOKEN|TAQNYAT_FROM_EMAIL|TAQNYAT_FROM_NAME) KIND="skip" ;;  # not used by the app
    SUMSUB_BASE_URL) KIND="default:https://api.sumsub.com"
      HELP="Sumsub API address. The standard value is right for both live and sandbox." ;;
    SUMSUB_APP_TOKEN)
      HELP="Sumsub App Token: Sumsub dashboard -> Dev space -> App tokens -> Generate
  (production token for prod, sandbox 'sbx:' token for dev). Shown once." ;;
    SUMSUB_SECRET_KEY)
      HELP="The Secret key shown together with that App Token. Also set it as the webhook secret:
  Dev space -> Webhooks -> your webhook -> Secret key (the app checks webhooks with this value)." ;;
    SUMSUB_LEVEL_NAME)
      HELP="Name of the verification level users go through: Sumsub -> Levels (e.g. basic-kyc-level)." ;;
    SUMSUB_DEFAULT_LEVEL_NAME)
      HELP="Default level name (Sumsub -> Levels). Enter to leave empty: SUMSUB_LEVEL_NAME is used." ;;
    BINANCE_API_BASE_URL) KIND="default:https://api.binance.com"
      HELP="Binance API address. Standard value for real accounts; https://testnet.binance.vision for testnet." ;;
    BINANCE_API_KEY)
      HELP="Binance API Key: Binance -> Account -> API Management -> your API (self-generated key type).
  For a broker account, the key from the Broker portal." ;;
    BINANCE_API_PRIVATE_KEY_PEM) KIND="pem"
      HELP="The PRIVATE key that belongs to that API key: the file you generated (Ed25519 or RSA)
  before uploading its public key to Binance, e.g. a .pem file. Never the public key." ;;
    BINANCE_RECV_WINDOW) KIND="default:5000"
      HELP="Binance request time window in milliseconds. The standard value 5000 is right." ;;
    BINANCE_BROKER_MAIN_ACCOUNT_ID)
      HELP="Your Binance Broker main account ID: Binance Broker portal -> Account / Sub-account management." ;;
    BINANCE_DEV_SUBACCOUNT_EMAIL|BINANCE_DEV_SUBACCOUNT_ID)
      if [ "$1" = dev ]; then KIND="optional"; else KIND="skip"; fi
      HELP="Dev only: a Binance sub-account (email / ID) used for all users on the dev stack.
  Binance Broker portal -> Sub-accounts. Enter to leave empty." ;;
    BINANCE_TESTNET_API_KEY)
      if [ "$1" = dev ]; then KIND="optional"; else KIND="skip"; fi
      HELP="Dev only: Binance Spot Testnet API key (testnet.binance.vision). Only used by dev tools." ;;
    BINANCE_TESTNET_PRIVATE_KEY_PEM)
      if [ "$1" = dev ]; then KIND="pem"; else KIND="skip"; fi
      HELP="Dev only: private key for the Binance testnet API key." ;;
    BINANCE_KYC_BASE_URL)
      HELP="Binance KYC-sharing API address, given by your Binance account manager (Broker KYC program)." ;;
    BINANCE_KYC_BIZ_ENTITY_KEY)
      HELP="Binance KYC-sharing business entity key, from your Binance account manager." ;;
    BINANCE_KYC_SECRET)
      HELP="Binance KYC-sharing secret (also checks Binance KYC webhooks), from your Binance account manager." ;;
    MAILGUN_*|POSTMARK_*|MAIL_FROM_*|COMPOSE_PROFILES|CORS_ORIGINS) KIND="skip" ;;  # empty on purpose
    *) KIND="optional"; HELP="(No description for this setting.)" ;;
  esac
}

# ---- per file ----------------------------------------------------------------------------------

fill_file() {  # fill_file <scope> <file> <title> <format compose|raw>
  local scope="$1" file="$2" title="$3" fmt="$4" key value n=0
  [ -f "$file" ] || { echo "== $title: $file not found, skipped"; return; }
  echo; echo "================ $title ($file) ================"
  for key in $(grep -oE '^[A-Z][A-Z0-9_]*=' "$file" | tr -d '=' | awk '!seen[$0]++'); do
    needs_value "$file" "$key" || continue
    describe "$scope" "$key"
    case "$KIND" in
      skip) continue ;;
      random:*)
        case "$KIND" in
          random:hex16) value="$(openssl rand -hex 16)" ;;
          random:garagekey) value="GK$(openssl rand -hex 12)" ;;
          *) value="$(openssl rand -hex 32)" ;;
        esac
        set_value "$file" "$key" "$value"; n=$((n + 1))
        echo "  $key: generated a random value. $HELP"; continue ;;
    esac
    echo; echo "-- $key"; echo "  $HELP"
    while :; do
      case "$KIND" in
        pem) ask_pem ;;
        r2account) ask_hidden "  Account ID (Enter = leave for later): " ;;
        default:*) ask_hidden "  Value (Enter = use the standard value ${KIND#default:}): " ;;
        required|email) ask_hidden "  Value (Enter = leave for later): " ;;
        *) ask_hidden "  Value (Enter = leave empty): " ;;
      esac
      value="$REPLY"
      if [ -z "$value" ]; then
        case "$KIND" in default:*) value="${KIND#default:}" ;; esac
      fi
      if [ -z "$value" ]; then echo "  left as it is"; break; fi
      if [ "$KIND" = r2account ]; then
        [[ "$value" =~ ^[0-9a-fA-F]{32}$ ]] || { echo "  An Account ID is 32 letters/digits (0-9, a-f). Try again."; continue; }
        value="s3:https://${value,,}.r2.cloudflarestorage.com/omlapay-backups"
      fi
      if [ "$KIND" = email ] && ! [[ "$value" =~ ^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$ ]]; then
        echo "  That does not look like an email address. Try again."; continue
      fi
      if [ "$fmt" = raw ]; then
        [[ "$value" != *$'\n'* && "$value" != *\'* && "$value" != *\"* ]] || { echo "  Quotes are not allowed in this file. Try again."; continue; }
        set_value "$file" "$key" "$value"
      elif [ "$KIND" = pem ]; then
        set_value "$file" "$key" "\"$value\""
      else
        set_value "$file" "$key" "$(compose_format "$value")"
      fi
      echo "  saved (${#value} characters)"; n=$((n + 1)); break
    done
  done
  chmod 600 "$file"
  echo "  -> $n setting(s) written in $title"
}

echo "Values are hidden while you type or paste. Press Enter to skip a setting; run this again any time."
fill_file prod   "$PROD_ENV"   "PRODUCTION settings" compose
fill_file dev    "$DEV_ENV"    "DEV settings"        compose
fill_file proxy  "$PROXY_ENV"  "Caddy (HTTPS) settings" compose
fill_file backup "$BACKUP_ENV" "Off-server backup settings" raw

echo; echo "================ Summary (no values shown) ================"
for f in "$PROD_ENV" "$DEV_ENV" "$PROXY_ENV" "$BACKUP_ENV"; do
  [ -f "$f" ] || continue
  printf '%-45s CHANGE_ME left: %s  perms: %s\n' "$f" "$(grep -c CHANGE_ME "$f" || true)" "$(stat -c %a "$f")"
done
missing=""
for k in SUPPORT_EMAIL TAQNYAT_API_KEY TAQNYAT_SENDER_NAME; do
  [ -f "$PROD_ENV" ] && needs_value "$PROD_ENV" "$k" && missing="$missing $k"
done
[ -z "$missing" ] || echo "Production still empty:$missing (needed for SMS login codes and account-block emails)"
echo "Now copy these files into your password manager (FIELD_ENCRYPTION_KEY and RESTIC_PASSWORD especially)."
