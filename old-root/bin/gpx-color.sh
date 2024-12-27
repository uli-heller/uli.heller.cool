#!/bin/bash
###
### gpx-color.sh
###
### Aufruf:
###  gpx-color.sh --color Black <source.gpx >with-color.gpx
###  gpx-color.sh data/2022-02-14_7x.gpx
###
### Beschreibung:
###  Dieses Skript fügt einer GPX-Datei eine Farbe für den GPX-Track
###  hinzu oder ändert die bestehende Farbe ab.
###
### Optionen:
###  -h|--help ........... Hilfe anzeigen (dieser Text)
###  -c|--color color .... Farbe für den GPX-Track
###
### Beispiele:
###  gpx-color.sh --color Black <source.gpx >with-color.gpx
###    ... färbt den GPX-Track schwarz
###  gpx-color.sh data/2022-02-14_7x.gpx
###    ... färbt den GPX-Track rot (hinterlegt in etc/gpx-color.conf)
###
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

XPATH_TRACK='/_:gpx/_:trk'
GPX_EXTENSIONS_NAMESPACE_URL='http://www.garmin.com/xmlschemas/GpxExtensions/v3'
XPATH_DISPLAY_COLOR="${XPATH_TRACK}/_:extensions/gpxx:TrackExtension/gpxx:DisplayColor"

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
TEMP="$(getopt -o hc: --long help,color: -- "$@")"
if [ $? != 0 ] ; then usage >&2; echo "Terminating..." >&2 ; exit 1 ; fi

eval set -- "${TEMP}"

USAGE=
HELP=
COLOR_OPT=

while true; do
  case "$1" in
    -h|--help)
      HELP=y
      ;;
    -c|--color)
      COLOR_OPT="$2"
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
    test -z "${COLOR_OPT}" && {
	echo >&1 "${BN}: Weder Dateiname noch Farbe ist angegeben!"
	COLOR_OPT=Magenta
    }
    cat >"${TMPDIR}/stdin"
    eval set -- "${TMPDIR}/stdin"
    STDIN=y
}

determineColor () {
    (
	FILENAME="$1"
	while read line; do
	    FILENAME_PATTERN="$(echo "${line}"|grep -v "^\s*#"|cut -d"=" -f1|tr -d ' ')"
	    COLOR="$(echo "${line}"|grep -v "^\s*#"|cut -d"=" -f2|tr -d ' ')"
	    expr "${FILENAME}" : ".*${FILENAME_PATTERN}" >/dev/null && {
		echo "${COLOR}"
		exit 0
	    }
	done <"${DD}/etc/gpx-color.conf"
	exit 1
    )
}

addOrSetColor () {
    (
	GPX="$1"
	COLOR="$2"
	#
	# Check for GPX standard elements
	#
	TRACK="$(xmlstarlet sel -N "gpxx=${GPX_EXTENSIONS_NAMESPACE_URL}" -T -t -v "${XPATH_TRACK}" "${GPX}"|cut -c-10)"
	test -z "${TRACK}" && {
	    echo >&2 "${BN}: '${GPX}' ist kein GPX-Track!"
	    RC=1
	    cleanUp
	    exit $RC
	}

	#
	# Check for GPX extensions
	#
	DISPLAY_COLOR="$(xmlstarlet sel -N "gpxx=${GPX_EXTENSIONS_NAMESPACE_URL}" -T -t -v "${XPATH_DISPLAY_COLOR}" "${GPX}"|cut -c-10)"
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
				   "${GPX}"
		    }
		    xmlstarlet ed --inplace -N "gpxx=${GPX_EXTENSIONS_NAMESPACE_URL}"\
			       -s "${XPATH_BASE}" -t elem -n "${NEXT_ELEMENT_WITHOUT_DEFAULT_NS}"\
			       "${GPX}"
		    XPATH_BASE="${XPATH_BASE}/${NEXT_ELEMENT}"
		done
	    )
	}
	xmlstarlet ed --inplace -N "gpxx=${GPX_EXTENSIONS_NAMESPACE_URL}"\
		   -u "${XPATH_DISPLAY_COLOR}" \
		   -v "${COLOR}" \
		   "${GPX}"
    )
}

while [ $# -gt 0 ]; do
    GPX_FILE="$1"
    GPX_BASE="$(basename "${GPX_FILE}")"
    COLOR="${COLOR_OPT}"
    test -z "${COLOR}" && COLOR="$(determineColor "${GPX_BASE}")"
    test -z "${COLOR}" && {
	echo >&2 "${BN}: Keine Farbe für '${GPX_BASE}'"
	shift
	continue
    }
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
    addOrSetColor  "${TMPDIR}/result.gpx" "${COLOR}"
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
