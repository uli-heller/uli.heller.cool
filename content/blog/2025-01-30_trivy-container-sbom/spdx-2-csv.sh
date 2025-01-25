#!/bin/sh
jq -r '["type","group", "name", "version"], (
             .packages[]
             | (
                 [
                   .primaryPackagePurpose,
                   (
                     .name|split(":") as $splitted|($splitted[-2], $splitted[-1])
                   ), .versionInfo
                 ]
               )
       ) | @csv'
