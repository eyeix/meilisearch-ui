#!/bin/bash
set -e

# The Docker image is built once with placeholder values for the
# SINGLETON_* env vars and BASE_PATH (see Dockerfile / vite.config.ts).
# At container start we substitute the real values from the runtime
# environment into the prebuilt `dist/` bundle, then serve. This keeps
# container boot O(seconds) instead of the 2-5 min a fresh `vite build`
# takes on a constrained pod, and makes secret rotation / rolling
# updates viable in clusters.
#
# Backwards compatibility: if `dist/` does not exist yet (e.g. someone
# runs `cmd.sh` outside a built image, or against a base image without
# the pre-build step), we fall back to the old behavior — build at
# start with the runtime env vars baked in.
#
# sed -i.bak is used for GNU/BSD portability (macOS BSD sed requires a
# backup-suffix argument).

DIST_DIR="${DIST_DIR:-/opt/meilisearch-ui/dist}"

# Escape for sed replacement text when the delimiter is `|`.
sed_escape_repl() {
  printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/[&|]/\\&/g'
}

# Prepare a value for splicing into a JS string literal via sed.
# Rejects `"` and ASCII control characters (would break/inject the
# bundle). Escapes `\` for JS first, then applies sed_escape_repl.
js_string_escape_for_sed() {
  local val="$1"
  local name="$2"
  if printf '%s' "$val" | grep -qE '["[:cntrl:]]'; then
    echo "ERROR: ${name} contains unsupported characters (quotes or control chars)." >&2
    exit 1
  fi
  # JS string escape (\ → \\), then sed-escape the result so the file
  # ends up with the JS-escaped form (e.g. one input \ → \\ in the bundle).
  sed_escape_repl "$(printf '%s' "$val" | sed -e 's/\\/\\\\/g')"
}

# Resolve BASE_PATH early so the prebuilt substitution path can apply it.
# Same idea as docker-entrypoint.d/30-basepath-subst.sh (lite image), but
# treat `/` like empty so `MEILI_UI_REPLACE_BASE_PATH/` → `` (not `/`,
# which would turn `/PLACEHOLDER/assets` into `//assets`).
export BASE_PATH="${BASE_PATH:-/}"
case "$BASE_PATH" in
  "" | "/")
    FINAL_REPLACE_PATH=""
    ;;
  *)
    REPLACE_PATH=$(printf '%s' "$BASE_PATH" | sed 's:/*$::' | sed 's:^/*::')
    FINAL_REPLACE_PATH="${REPLACE_PATH}/"
    ;;
esac
BASE_PATH_BARE="${FINAL_REPLACE_PATH%/}"

if [ "$BASE_PATH" != "/" ]; then
  echo "Custom base path: $BASE_PATH"
fi

if [ -d "$DIST_DIR" ] && [ -n "$(ls -A "$DIST_DIR" 2>/dev/null)" ]; then
  echo "Prebuilt dist/ detected — substituting runtime config."

  # Default unset placeholders to empty so the bundle resolves to
  # multi-instance mode rather than crashing on a literal placeholder
  # string in the browser.
  : "${SINGLETON_MODE:=}"
  : "${SINGLETON_HOST:=}"
  : "${SINGLETON_API_KEY:=}"

  ESC_MODE=$(js_string_escape_for_sed "$SINGLETON_MODE" "SINGLETON_MODE")
  ESC_HOST=$(js_string_escape_for_sed "$SINGLETON_HOST" "SINGLETON_HOST")
  ESC_API_KEY=$(js_string_escape_for_sed "$SINGLETON_API_KEY" "SINGLETON_API_KEY")
  # BASE_PATH lands in HTML/asset paths, not JS string literals.
  ESC_BASE_SLASH=$(sed_escape_repl "$FINAL_REPLACE_PATH")
  ESC_BASE_BARE=$(sed_escape_repl "$BASE_PATH_BARE")

  # Write the sed script to a temp file so SINGLETON_API_KEY does not
  # appear in process argv (visible via `ps` inside the container).
  SED_SCRIPT=$(mktemp)
  trap 'rm -f "$SED_SCRIPT"' EXIT
  {
    printf 's|__MEILI_UI_REPLACE_SINGLETON_MODE__|%s|g\n' "$ESC_MODE"
    printf 's|__MEILI_UI_REPLACE_SINGLETON_HOST__|%s|g\n' "$ESC_HOST"
    printf 's|__MEILI_UI_REPLACE_SINGLETON_API_KEY__|%s|g\n' "$ESC_API_KEY"
    # Slash form first, then bare — same order as 30-basepath-subst.sh.
    printf 's|MEILI_UI_REPLACE_BASE_PATH/|%s|g\n' "$ESC_BASE_SLASH"
    printf 's|MEILI_UI_REPLACE_BASE_PATH|%s|g\n' "$ESC_BASE_BARE"
  } >"$SED_SCRIPT"

  # Scope the sed pass to the JS, CSS, and HTML emitted by Vite.
  # -i.bak works on both GNU sed (Linux containers) and BSD sed (macOS).
  find "$DIST_DIR" -type f \( -name '*.js' -o -name '*.css' -o -name '*.html' \) \
    -exec sed -i.bak -f "$SED_SCRIPT" {} +
  find "$DIST_DIR" -type f -name '*.bak' -delete
  rm -f "$SED_SCRIPT"
  trap - EXIT

  # Safety net: refuse to start if any placeholder slipped through
  # (e.g. the bundler emitted an escaped form sed missed). Better a
  # crash-loop than serving sentinel strings to the browser.
  if grep -rqE '__MEILI_UI_REPLACE_SINGLETON_(MODE|HOST|API_KEY)__|MEILI_UI_REPLACE_BASE_PATH' "$DIST_DIR"; then
    echo "ERROR: placeholder still present in $DIST_DIR after substitution." >&2
    grep -rlE '__MEILI_UI_REPLACE_SINGLETON_(MODE|HOST|API_KEY)__|MEILI_UI_REPLACE_BASE_PATH' "$DIST_DIR" >&2 || true
    exit 1
  fi

  if [ "$SINGLETON_MODE" = "true" ]; then
    echo "Singleton mode enabled (host: ${SINGLETON_HOST:-<unset>})"
  fi
else
  echo "No prebuilt dist/ found — building at start with current env."

  # Legacy build-at-start path. Mirrors the previous behavior of this
  # script: copy SINGLETON_* into the VITE_-namespaced env vars Vite
  # expects, then build + preview. (BASE_PATH is already exported above
  # and is picked up by vite.config.ts / loadEnv.)
  if [ -n "${SINGLETON_HOST:-}" ]; then
    export VITE_SINGLETON_HOST="$SINGLETON_HOST"
  fi
  if [ -n "${SINGLETON_API_KEY:-}" ]; then
    export VITE_SINGLETON_API_KEY="$SINGLETON_API_KEY"
  fi
  if [ -n "${SINGLETON_MODE:-}" ]; then
    export VITE_SINGLETON_MODE="$SINGLETON_MODE"
    if [ "$SINGLETON_MODE" = "true" ]; then
      echo "Singleton mode enabled"
    fi
  fi

  pnpm run build
fi

pnpm run preview
