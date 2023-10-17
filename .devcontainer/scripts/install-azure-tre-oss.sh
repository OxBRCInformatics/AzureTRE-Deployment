#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
# Uncomment this line to see each command for debugging (careful: this will show secrets!)
# set -o xtrace

oss_version="$1"
oss_home="$2"
archive=/tmp/AzureTRE.tar.gz

wget -O "$archive" "http://github.com/microsoft/AzureTRE/archive/${oss_version}.tar.gz" --progress=dot:giga

mkdir -p "$oss_home"
tar -xzf "$archive" -C "$oss_home" --strip-components=1
rm "$archive"

echo "${oss_version}" > "$oss_home/version.txt"
