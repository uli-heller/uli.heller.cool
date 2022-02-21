#!/bin/sh
#
# https://shondalai.com/topic/use-track-colors-from-gpx/
#   The color names used by Mapsource and BaseCamp are:
#     Default
#     Black
#     Dark Red
#     Dark Green
#     Dark Yellow
#     Dark Blue
#     Dark Magenta
#     Dark Cyan
#     Light Gray
#     Dark Gray
#     Red
#     Green
#     Yellow
#     Blue
#     Magenta
#     Cyan
#     White
#     Transparent
#
D="$(dirname "$0")"
D="$(cd "${D}" && pwd)"
DD="$(dirname "${D}")"
BN="$(basename "$0")"

COLOR="$1"

RC=0

TMPDIR="/tmp/${BN}.$({ date; ps waux; }|sha256sum|cut -f1 -d" ").$$~"

cleanUp () {
    rm -rf "${TMPDIR}"
    exit "${RC}"
}

trap cleanUp 0 1 2 3 4 5 6 7 8 9 10 12 13 14 15

mkdir "${TMPDIR}"

cat >"${TMPDIR}/source.gpx"

#
# Check for GPX standard elements
#
XPATH_TRACK='/_:gpx/_:trk'
GPX_EXTENSIONS_NAMESPACE_URL='http://www.garmin.com/xmlschemas/GpxExtensions/v3'
TRACK="$(xmlstarlet sel -N "gpxx=${GPX_EXTENSIONS_NAMESPACE_URL}" -T -t -v "${XPATH_TRACK}" "${TMPDIR}/source.gpx"|cut -c-10)"
test -z "${TRACK}" && {
    echo >&2 "${BN}: Kein GPX-Track!"
    RC=1
    cleanUp
    exit $RC
}

#
# Check for GPX extensions
#
XPATH_DISPLAY_COLOR="${XPATH_TRACK}/_:extensions/gpxx:TrackExtension/gpxx:DisplayColor"
DISPLAY_COLOR="$(xmlstarlet sel -N "gpxx=${GPX_EXTENSIONS_NAMESPACE_URL}" -T -t -v "${XPATH_DISPLAY_COLOR}" "${TMPDIR}/source.gpx"|cut -c-10)"
test -z "${DISPLAY_COLOR}" && {
    #
    # Create nodes and namespaces
    #
    (
	XPATH_BASE="${XPATH_TRACK}"
	while true; do
	    NEXT_ELEMENT="$(echo "${XPATH_DISPLAY_COLOR}"|sed -e "s,^${XPATH_BASE}/,,"|cut -d/ -f1)"
	    test -z "${NEXT_ELEMENT}" && break;
	    NEXT_ELEMENT_WITHOUT_DEFAULT_NS="$(echo "${NEXT_ELEMENT}"|sed -e "s/^_://")"
	    NAMESPACE="$(echo "${NEXT_ELEMENT_WITHOUT_DEFAULT_NS}"|cut -d':' -f1)"
	    test -n "${NAMESPACE}" && {
		xmlstarlet ed --inplace -N "gpxx=${GPX_EXTENSIONS_NAMESPACE_URL}"\
			   -i "${XPATH_BASE}" -t attr -n "xmlns:${NAMESPACE}" -v "${GPX_EXTENSIONS_NAMESPACE_URL}"\
			   "${TMPDIR}/source.gpx"
	    }
	    xmlstarlet ed --inplace -N "gpxx=${GPX_EXTENSIONS_NAMESPACE_URL}"\
	       -s "${XPATH_BASE}" -t elem -n "${NEXT_ELEMENT_WITHOUT_DEFAULT_NS}"\
	       "${TMPDIR}/source.gpx"
	    XPATH_BASE="${XPATH_BASE}/${NEXT_ELEMENT}"
	done
    )
}
xmlstarlet ed --inplace -N "gpxx=${GPX_EXTENSIONS_NAMESPACE_URL}"\
 -u "${XPATH_DISPLAY_COLOR}" \
 -v "${COLOR}" \
 "${TMPDIR}/source.gpx"

cat "${TMPDIR}/source.gpx"
cleanUp
exit $RC
