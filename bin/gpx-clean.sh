#!/bin/sh
#
# https://oleb.net/2020/sanitizing-gpx/
#
# find . -name "*gpx.xz"|while read f; do b="$(echo "$f"|sed -e 's/.xz$//')"; xz -d "${f}"; ./bin/gpx-clean.sh "${b}" >"${b}~"; mv "${b}~" "${b}"; xz -9 "${b}"; done
#
D="$(dirname "$0")"
D="$(cd "${D}" && pwd)"
DD="$(dirname "${D}")"
BN="$(basename "$0")"

RC=0

TMPDIR="/tmp/${BN}.$({ date; ps waux; }|sha256sum|cut -f1 -d" ").$$~"

cleanUp () {
    rm -rf "${TMPDIR}"
    exit "${RC}"
}

trap cleanUp 0 1 2 3 4 5 6 7 8 9 10 12 13 14 15

mkdir "${TMPDIR}"

STDIN=
test $# -eq 0 && {
    cat >"${TMPDIR}/stdin"
    eval set -- "${TMPDIR}/stdin"
    STDIN=y
}

while [ $# -gt 0 ]; do
    GPX_FILE="$1"
    GPX_BASE="$(basename "${GPX_FILE}")"
    XZ=
    MODIFIED=
    GPX_BASE_WITHOUT_XZ="$(basename "${GPX_BASE}" .xz)"
    if [ "${GPX_BASE}" != "${GPX_BASE_WITHOUT_XZ}" ]; then
	XZ=y
	xz -cd "${GPX_FILE}" >"${TMPDIR}/source.gpx"
    else
	XZ=
	cp "${GPX_FILE}" "${TMPDIR}/source.gpx"
    fi
    cp "${TMPDIR}/source.gpx" "${TMPDIR}/${GPX_BASE_WITHOUT_XZ}"
    #
    # Deaktivierte Bereinigungen
    #   -d "/_:gpx/_:metadata/_:time"
    #   -d "/_:gpx/_:trk/_:type"
    #   -u "/_:gpx/@creator" -v "gpx-clean"
    #
    xmlstarlet ed \
	       -d "//_:trkpt/_:extensions" \
	       -d "//_:trkpt/_:time" \
	       -d "//_:trkpt/_:hdop" \
	       -d "//_:trkpt/_:vdop" \
	       -d "//_:trkpt/_:pdop" \
	       "${TMPDIR}/source.gpx" \
	| xmlstarlet tr "${DD}/etc/remove-unused-namespaces.xslt" - \
	| xmlstarlet ed -u "/_:gpx/@xsi:schemaLocation" -v "http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd" \
	| xmllint --c14n11 --pretty 2 - >"${TMPDIR}/${GPX_BASE_WITHOUT_XZ}"
    "${D}/gpx-color.sh" "${TMPDIR}/${GPX_BASE_WITHOUT_XZ}"
    grep -v "^\s*#" "${DD}/etc/gpx-clean-regions.conf"\
    |while read line; do
	  "${D}/gpx-region.sh" --exclude "${line}" "${TMPDIR}/${GPX_BASE_WITHOUT_XZ}"
    done
    cmp "${TMPDIR}/source.gpx" "${TMPDIR}/${GPX_BASE_WITHOUT_XZ}" >/dev/null 2>&1 || MODIFIED=y    
    test -n "${MODIFIED}" && {
	if [ -n "${XZ}" ]; then
	    xz -c9 "${TMPDIR}/${GPX_BASE_WITHOUT_XZ}" >"${GPX_FILE}"
	else
	    cp "${TMPDIR}/${GPX_BASE_WITHOUT_XZ}" "${GPX_FILE}"
	fi	
    }
    shift
done

test -n "${STDIN}" && {
    cat "${TMPDIR}/stdin"
}
cleanUp
exit $RC
