#!/usr/bin/env bash

#######################################
# Prints a message in bold
# Arguments:
#   Message string
#######################################
log() {
    echo -e "\033[1m$1\033[0m"
}

#######################################
# Fetches the latest release tag from a GitHub repo
# Globals:
#   None
# Arguments:
#   $1 - GitHub repo in "owner/repo" format
# Outputs:
#   Echoes latest release tag
#######################################
get_latest_release() {
    local repo="$1"
    curl -ns "https://api.github.com/repos/${repo}/releases/latest" \
        | grep tag_name \
        | cut -d '"' -f 4
}

#######################################
# Downloads and extracts a tar.gz binary from a GitHub release
# Globals:
#   None
# Arguments:
#   $1 - GitHub repo in "owner/repo" format
#   $2 - Release tag (e.g., "v2.64.0")
#   $3 - Archive filename pattern (must match release asset exactly)
#   $4 - Path inside the archive to the binary
#######################################
install_binary_from_github() {
    local repo="$1"
    local version="$2"
    local archive="$3"
    local binary_path="$4"

    local url="https://github.com/${repo}/releases/download/${version}/${archive}"
    local tmpdir
    tmpdir="$(mktemp -d)"

    log "Downloading ${repo} ${version}..."
    curl -L -n -o "${tmpdir}/${archive}" "${url}"

    log "Extracting..."
    tar -xzf "${tmpdir}/${archive}" -C "${tmpdir}"

    log "Installing binary to /usr/local/bin..."
    mv "${tmpdir}/${binary_path}" /usr/local/bin/
    chmod +x /usr/local/bin/$(basename "${binary_path}")

    rm -rf "${tmpdir}"
    log "✅ Installed $(basename "${binary_path}") from ${repo} ${version}"
}
