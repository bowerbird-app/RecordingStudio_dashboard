#!/usr/bin/env bash
# Bundler git clones pass --hardlinks. Parallel jobs then race on the same
# inode on GitHub-hosted runners. Put a git wrapper first on PATH that drops
# that flag and calls /usr/bin/git.
set -euo pipefail

install_dir="${RUNNER_TEMP:-/tmp}/git-no-hardlinks"
mkdir -p "$install_dir"

cat > "${install_dir}/git" <<'EOF'
#!/usr/bin/env bash
args=()
for arg in "$@"; do
  if [[ "$arg" == "--hardlinks" ]]; then
    continue
  fi
  args+=("$arg")
done
exec /usr/bin/git "${args[@]}"
EOF
chmod +x "${install_dir}/git"

if [[ -n "${GITHUB_PATH:-}" ]]; then
  echo "$install_dir" >> "$GITHUB_PATH"
fi
export PATH="${install_dir}:${PATH}"
