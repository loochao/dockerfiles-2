#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"

docker create \
    --volume="${CONFIGPATH}:${PRIMPATH}/config:ro" \
    --volume="${GNUPGHOME}:${PRIMPATH}/crypto/gnupg:rw" \
    --volume="${LOGPATH}:${PRIMPATH}/logs:rw" \
    --volume="${SRCDEST}:${PRIMPATH}/srcdest:rw" \
    --volume="${PKGBUILDPATH}:${PRIMPATH}/host/pkgbuild:ro" \
    --volume="${PKGCACHE}:/var/cache/pacman/pkg:rw" \
    --volume="${PKGDEST}:${PRIMPATH}/pkgdest:rw" \
    --cap-drop 'ALL' \
    --cap-add 'FOWNER' \
    --cap-add 'SETGID' \
    --cap-add 'SETUID' \
    --cap-add 'SYS_CHROOT' \
    --net='bridge' \
    --name="${CNAME}" \
    --hostname="${CNAME}" \
    --memory="${MEMORY}" \
    --memory-swap='-1' \
    --cpu-shares="${CPU_SHARES}" \
    nfnty/arch-builder:latest \
    ${@:2}

CID="$( docker inspect --format='{{.Id}}' "${CNAME}" )"
cd "${BTRFSPATH}/${CID}"
setfattr --name=user.pax.flags --value=em usr/bin/python3