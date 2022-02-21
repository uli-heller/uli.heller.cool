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

xmlstarlet sel -T -t -v "//_:trk/_:extensions"
