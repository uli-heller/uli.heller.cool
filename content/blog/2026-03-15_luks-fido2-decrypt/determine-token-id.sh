#!/bin/sh
#
# determine-token-id.sh /dev/luks
#
# Ideen übernommen aus https://github.com/bertogg/fido2luks/blob/main/keyscript.sh
# Ideas taken from     https://github.com/bertogg/fido2luks/blob/main/keyscript.sh
#
BN="$(basename "$0")"
#set -x

TMPDIR="/tmp/${BN}-$({ echo "$$"; date +%s%N; }|md5sum|cut -d " " -f 1)-$$~"

test "$(id -u)" != 0 && {
    echo >&2 "${BN}: Dieses Skript muß mit 'sudo' ausgeführt werden!"
    exit 1
}

LUKS_DEVICE="$1"
test -e "$1" || {
    echo >&2 "${BN}: Gerät '${LUKS_DEVICE}' existiert nicht"
    exit 1
}
test -r "$1" || {
    echo >&2 "${BN}: Gerät '${LUKS_DEVICE}' nicht lesbar"
    exit 1
}

FIDO2_DEVICES="$(fido2-token -L|cut -d ":" -f 1)"

RC=0
cleanUp () {
    rm -rf "${TMPDIR}"
    exit "${RC}"
}

trap cleanUp 01 2 3 4 5 6 7 8 9 10 12 13 14 15

mkdir "${TMPDIR}"

cryptsetup luksDump --dump-json-metadata "${LUKS_DEVICE}" >"${TMPDIR}/luksdump.json"
jq -e '[.tokens[] | select(."fido2-credential" != null)] | sort_by(."fido2-uv-required")' <"${TMPDIR}/luksdump.json" >"${TMPDIR}/tokens.json"
TOKEN_CNT="$(jq length <"${TMPDIR}/tokens.json")"
test "${TOKEN_CNT}" -lt 1 && {
    echo >&2 "${BN}: Kein FIDO2-Token hinterlegt für '${LUKS_DEVICE}'"
    exit 1
}

TOKEN_MAX="$(expr "${TOKEN_CNT}" - 1)"

for t in $(seq 0 "${TOKEN_MAX}"); do
    jq ".[$t]" <"${TMPDIR}/tokens.json" >"${TMPDIR}/current-token.json"
    jq -r '"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=",
               ."fido2-rp",
               ."fido2-credential",
               ."fido2-salt"' <"${TMPDIR}/current-token.json" >"${TMPDIR}/assert-params.txt"
    for dev in ${FIDO2_DEVICES}; do
        fido2-assert -G -t up=false -t pin=false -i "${TMPDIR}/assert-params.txt" -o /dev/null "${dev}" 2>/dev/null && {
            echo "$t"
            RC=0
            cleanUp
            exit $RC
        }
    done
done

RC=1
cleanUp
exit $RC
