#!/bin/sh
jq -r '["type","ref","group", "name", "version"], (
             .components[]
             | (
                 [
                   .type,
                   (."bom-ref"|split("/")[0]),
                   .group,
                   .name,
                   .version
                 ]
               )
       ) | @csv'
