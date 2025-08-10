#!/usr/bin/env bash

install_gh_cli() {
    local repo="cli/cli"
    local version="${GH_VERSION:-$(get_latest_release "${repo}")}"
    local version_num="${version#v}"
    local archive="gh_${version_num}_linux_amd64.tar.gz"
    local binary_path="gh_${version_num}_linux_amd64/bin/gh"

    install_binary_from_github "${repo}" "${version}" "${archive}" "${binary_path}"
}


install_gh_cli