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

#
# Deaktivierte Bereinigungen
#   -d "/_:gpx/_:trk/_:type" \
#   -u "/_:gpx/@creator" -v "gpx-clean" \
#
xmlstarlet ed \
  -d "//_:trkpt/_:extensions" \
  -d "/_:gpx/_:metadata/_:time" \
  -d "//_:trkpt/_:time" \
  -d "//_:trkpt/_:hdop" \
  -d "//_:trkpt/_:vdop" \
  -d "//_:trkpt/_:pdop" \
  "$1" \
  | xmlstarlet tr "${DD}/etc/remove-unused-namespaces.xslt" - \
  | xmlstarlet ed -u "/_:gpx/@xsi:schemaLocation" -v "http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd" \
  | xmllint --c14n11 --pretty 2 - >"${TMPDIR}/clean.gpx"

grep -v "^\s*#" "${DD}/etc/gpx-clean-regions.conf"\
    |while IFS=":" read lat lon; do
      lat_min="$(echo "${lat}"|cut -d"-" -f1)"
      lat_max="$(echo "${lat}"|cut -d"-" -f2)"
      lon_min="$(echo "${lon}"|cut -d"-" -f1)"
      lon_max="$(echo "${lon}"|cut -d"-" -f2)"
      xmlstarlet ed -d "//_:trkpt[@lat>${lat_min} and @lat<${lat_max} and @lon>${lon_min} and @lon<${lon_max}]" "${TMPDIR}/clean.gpx" >"${TMPDIR}/clean-pos.gpx"||exit 1
      mv "${TMPDIR}/clean-pos.gpx" "${TMPDIR}/clean.gpx"
    done
RC=$?

test "${RC}" -eq 0 && cat "${TMPDIR}/clean.gpx"
cleanUp
