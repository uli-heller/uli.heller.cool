#!/bin/sh
#
# Beispielaufrufe:
#   ./auslagern.sh gradle-artifactory
#   ./auslagern.sh gradle-artifactory /home/uli/git/uli.heller.cool 
#   ./auslagern.sh gradle-artifactory /home/uli/git/uli.heller.cool git@github.com:uli-heller/mein-projekt.git
#
set -x
D="$(dirname "$0")"
D="$(cd "${D}" && pwd)"
DD="$(dirname "${D}")"
DDD="$(dirname "${DD}")"
DDDD="$(dirname "${DDD}")"
BN="$(basename "$0")"

GITHUB_URL=
ULI_HELLER_COOL_PATH=

NAME="${1}"
test -n "${2}" && GITHUB_URL="${2}"
test -n "${3}" && ULI_HELLER_COOL_PATH="${3}"
test -z "${GITHUB_URL}" && GITHUB_URL="git@github.com:uli-heller/java-example-${NAME}.git"
test -z "${ULI_HELLER_COOL_PATH}" && ULI_HELLER_COOL_PATH="${DDDD}"
#exit 1

test -d "${ULI_HELLER_COOL_PATH}" || {
    echo >&2 "${BN}: Verzeichnis '${ULI_HELLER_COOL_PATH}' nicht gefunden!"
    exit 1
}
test -d "${ULI_HELLER_COOL_PATH}/.git" || {
    echo >&2 "${BN}: Verzeichnis '${ULI_HELLER_COOL_PATH}/.git' nicht gefunden!"
    exit 1
}

rm -rf /tmp/git-separation
mkdir /tmp/git-separation
cp -a "${ULI_HELLER_COOL_PATH}/."  /tmp/git-separation/. || exit 1
(
    cd /tmp/git-separation || exit 1
    rm -rf .git/filter-repo
    rm -rf .git/modules/*
    rm -f .gitmodules
    git checkout .
    git clean -fdx
#    git status
    git filter-repo --force --path "static/${NAME}/" --path-rename "static/${NAME}/:"
    git clean -fdx
#    git status
#)
#(
#    cd /tmp/git-separation
    git remote add new "${GITHUB_URL}"
    git push new main:main
)
rm -rf /tmp/git-separation
(
  cd "${ULI_HELLER_COOL_PATH}" || exit 1

  for f in $(find . -type f -name "*.md"|xargs grep -l "${NAME}"); do
    sed -i -e "s,\[\([^]]*\)\](/${NAME}),[github:java-example-\1](${GITHUB_URL})," "${f}"
  done
  #git status
  #git diff
  git commit -m "Java-Beispiel '${NAME}' ausgelagert - Verweise" .
  git rm -r "static/${NAME}"
  git commit -m "Java-Beispiel '${NAME}' ausgelagert - Löschen" static
)
