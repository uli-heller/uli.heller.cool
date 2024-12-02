#!/bin/bash

#
# "VulnerabilityID": "CVE-2016-2781"
# 
jq -r '["score","severity","cve","pkgname","title","description","installed_version","fixed_version","target","class","type"],
       ( .Results[]
         |.Target as $target
         |.Class as $class
         |.Type as $type
         |.Vulnerabilities
           |select(.!=null)
           | .[]
           | [ ([ .CVSS|..|.V3Score?|select(. != null) ]|first), .Severity, .VulnerabilityID, .PkgName, .Title, .Description, .InstalledVersion, .FixedVersion, $target, $class, $type ]
       )|@csv'
