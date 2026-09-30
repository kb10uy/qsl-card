#!/usr/bin/env zsh
set -euo pipefail

root=${0:A:h}

usage() {
    print -u2 "Usage: generate.zsh json [wavelog-tools export options...]"
    print -u2 "       generate.zsh pdf <JSON_FILE>"
    exit 1
}

case ${1:-} in
    json)
        shift
        wavelog-tools export "$@" |
            qso-tools qcgen --lenient codepoints "$root/qcgen-single.lua"
        ;;
    pdf)
        (( $# == 2 )) || usage
        json=${2:A}
        if [[ $json != "$root"/* ]]; then
            print -u2 "JSON file must be under $root"
            exit 1
        fi
        typst compile --input "data_json=${json#"$root"/}" "$root/qsl-card.typ" "$json.pdf"
        ;;
    *)
        usage
        ;;
esac
