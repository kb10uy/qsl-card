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
        work=$(mktemp -d)
        trap 'rm -rf "$work"' EXIT
        cp -R "$root/qsl-card.typ" "$root/parts" "$work/"
        cp "$json" "$work/data.json"
        typst compile --input "data_json=data.json" "$work/qsl-card.typ" "$json.pdf"
        ;;
    *)
        usage
        ;;
esac
