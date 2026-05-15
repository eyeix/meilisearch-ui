#!/bin/bash
set -e

# The Docker image is built once with placeholder values for the
# SINGLETON_* env vars (see Dockerfile). At container start we substitute
# the real values from the runtime environment into the prebuilt `dist/`
# bundle, then serve. This keeps container boot O(seconds) instead of
# the 2-5 min a fresh `vite build` takes on a constrained pod, and
# makes secret rotation / rolling updates viable in clusters.
#
# Backwards compatibility: if `dist/` does not exist yet (e.g. someone
# runs `cmd.sh` outside a built image, or against a base image without
# the pre-build step), we fall back to the old behavior — build at
# start with the runtime env vars baked in.

DIST_DIR="${DIST_DIR:-/opt/meilisearch-ui/dist}"

if [ -d "$DIST_DIR" ] && [ -n "$(ls -A "$DIST_DIR" 2>/dev/null)" ]; then
  echo "Prebuilt dist/ detected — substituting runtime singleton config."

  # Default unset placeholders to empty so the bundle resolves to
  # multi-instance mode rather than crashing on a literal placeholder
  # string in the browser.
  : "${SINGLETON_MODE:=}"
  : "${SINGLETON_HOST:=}"
  : "${SINGLETON_API_KEY:=}"

  # The placeholders are sentinel strings unique to this entrypoint;
  # they appear in the bundle exactly where the build resolved
  # `import.meta.env.VITE_SINGLETON_*`. Scope the sed pass to the JS,
  # CSS, and HTML emitted by Vite to avoid touching node_modules.
  find "$DIST_DIR" -type f \( -name '*.js' -o -name '*.css' -o -name '*.html' \) \
    -exec sed -i \
      -e "s|__MEILI_UI_REPLACE_SINGLETON_MODE__|${SINGLETON_MODE}|g" \
      -e "s|__MEILI_UI_REPLACE_SINGLETON_HOST__|${SINGLETON_HOST}|g" \
      -e "s|__MEILI_UI_REPLACE_SINGLETON_API_KEY__|${SINGLETON_API_KEY}|g" \
      {} +

  # Safety net: refuse to start if any placeholder slipped through
  # (e.g. the bundler emitted an escaped form sed missed). Better a
  # crash-loop than serving sentinel strings to the browser.
  if grep -rqE '__MEILI_UI_REPLACE_SINGLETON_(MODE|HOST|API_KEY)__' "$DIST_DIR"; then
    echo "ERROR: singleton placeholder still present in $DIST_DIR after substitution." >&2
    grep -rlE '__MEILI_UI_REPLACE_SINGLETON_(MODE|HOST|API_KEY)__' "$DIST_DIR" >&2 || true
    exit 1
  fi

  if [ "$SINGLETON_MODE" = "true" ]; then
    echo "Singleton mode enabled (host: ${SINGLETON_HOST:-<unset>})"
  fi
else
  echo "No prebuilt dist/ found — building at start with current env."

  # Legacy build-at-start path. Mirrors the previous behavior of this
  # script: copy SINGLETON_* into the VITE_-namespaced env vars Vite
  # expects, then build + preview.
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

export BASE_PATH="${BASE_PATH:-/}"
if [ "$BASE_PATH" != "/" ]; then
  echo "Custom base path: $BASE_PATH"
fi

pnpm run preview
