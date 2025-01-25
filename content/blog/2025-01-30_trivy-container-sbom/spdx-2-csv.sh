#!/bin/sh
jq -r '["group", "name", "version"], (
             .packages[]
             | (
                 [
                   (
                     .name|split(":") as $splitted|($splitted[-2], $splitted[-1])
                   ), .versionInfo
                 ]
               )
       ) | @csv'
