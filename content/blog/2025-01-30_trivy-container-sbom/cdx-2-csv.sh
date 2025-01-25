#!/bin/sh
jq -r '[ "group", "name", "version" ] as $cols | .components | map(. as $row | $cols | map($row[.])) as $rows | $cols, $rows[] | @csv'
