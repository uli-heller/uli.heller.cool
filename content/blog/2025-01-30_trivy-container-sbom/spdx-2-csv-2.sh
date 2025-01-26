#!/bin/sh
jq -r '["type","ref","group", "name", "version"], (
             .packages[]
             | (
                 [
                   .primaryPackagePurpose,
                   (
                     .externalRefs|..|.referenceLocator?|strings|split("/")[0]
                   ),
                   (
                     .name|split(":") as $splitted|($splitted[-2], $splitted[-1])
                   ), .versionInfo
                 ]
               )
       ) | @csv'
