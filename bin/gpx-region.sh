#!/bin/bash
###
### gpx-region.sh
###
### Aufruf:
###  gpx-region.sh --exclude 48.86784-48.871654:9.182696-9.189369 <source.gpx >with-color.gpx
###  gpx-region.sh --include 48.86942-48.890733:9.140969-9.191738 <source.gpx >with-color.gpx
###
### Beschreibung:
###  Dieses Skript klammert eine Region aus einem GPX-Track aus (--exclude) oder
###  beschränkt den GPX-Track auf die angegebene Region (--include)
###
### Optionen:
###  -h|--help ............. Hilfe anzeigen (dieser Text)
###  -e|--exclude region ... Region, die ausgeklammert werden soll
###  -i|--include region ... Region, auf die der Track beschränkt werden soll
###
### Region:
###  min_latitude-max_latitude:min_longitude-max_longitude
###
### Beispiele:
###  gpx-region.sh --exclude 48.86784-48.871654:9.182696-9.189369 <source.gpx >with-color.gpx
###  gpx-region.sh --include 48.86942-48.890733:9.140969-9.191738 <source.gpx >with-color.gpx
###
#
D="$(dirname "$0")"
D="$(cd "${D}" && pwd)"
DD="$(dirname "${D}")"
BN="$(basename "$0")"

help () {
   sed -rn 's/^### ?//;T;p' "$0"
}

usage () {
    help|sed -n "/^Aufruf:/,/^\s*$/p"
}

ORIG_ARGS=("$@")

TEMP="$(getopt -o l --long long -- --long 2>/dev/null)"
if [ "${TEMP}" != " --long --" ]; then
  echo >&2 "${BN}: Please install GNU getopt - terminating..."
  exit 1
fi
TEMP="$(getopt -o he:i: --long help,exclude:,include: -- "$@")"
if [ $? != 0 ] ; then usage >&2; echo "Terminating..." >&2 ; exit 1 ; fi

eval set -- "${TEMP}"

USAGE=
HELP=
INCLUDE=
EXCLUDE=

while true; do
  case "$1" in
    -h|--help)
      HELP=y
      ;;
    -e|--exclude)
      EXCLUDE="$2"
      shift
      ;;
    -i|--include)
      INCLUDE="$2"
      shift
      ;;
    \?)
      echo >&2 "Invalid option: -${OPTARG}"
      USAGE=y
      ;;
    --)
      shift
      break
      ;;
    *)
      break
      ;;
  esac
  shift
done

if [ -n "${USAGE}" ]; then
  usage >&2
  exit 1
fi

if [ -n "${HELP}" ]; then
  help
  exit 0
fi

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

exclude () {
    (
	lat="$(echo "$1"|cut -d":" -f1)"
	lon="$(echo "$1"|cut -d":" -f2)"
	lat_min="$(echo "${lat}"|cut -d"-" -f1)"
	lat_max="$(echo "${lat}"|cut -d"-" -f2)"
	lon_min="$(echo "${lon}"|cut -d"-" -f1)"
	lon_max="$(echo "${lon}"|cut -d"-" -f2)"
	xmlstarlet ed --inplace -d "//_:trkpt[@lat>${lat_min} and @lat<${lat_max} and @lon>${lon_min} and @lon<${lon_max}]" "$2"||exit 1
    )
}

include () {
    (
	lat="$(echo "$1"|cut -d":" -f1)"
	lon="$(echo "$1"|cut -d":" -f2)"
	lat_min="$(echo "${lat}"|cut -d"-" -f1)"
	lat_max="$(echo "${lat}"|cut -d"-" -f2)"
	lon_min="$(echo "${lon}"|cut -d"-" -f1)"
	lon_max="$(echo "${lon}"|cut -d"-" -f2)"
	xmlstarlet ed --inplace -d "//_:trkpt[@lat<${lat_min} or @lat>${lat_max} or @lon<${lon_min} or @lon>${lon_max}]" "$2"||exit 1
    )
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
    cp "${TMPDIR}/source.gpx" "${TMPDIR}/result.gpx"
    test -n "${EXCLUDE}" && include "${EXCLUDE}" "${TMPDIR}/result.gpx"
    test -n "${INCLUDE}" && include "${INCLUDE}" "${TMPDIR}/result.gpx"
    cmp "${TMPDIR}/source.gpx" "${TMPDIR}/result.gpx" >/dev/null 2>&1 || MODIFIED=y    
    test -n "${MODIFIED}" && {
	if [ -n "${XZ}" ]; then
	    xz -c9 "${TMPDIR}/result.gpx" >"${GPX_FILE}"
	else
	    cp "${TMPDIR}/result.gpx" "${GPX_FILE}"
	fi	
    }
    shift
done

test -n "${STDIN}" && {
    cat "${TMPDIR}/stdin"
}
cleanUp
exit $RC
