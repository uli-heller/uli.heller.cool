+++
date = '2025-01-16'
draft = false
title = 'Hugo-Clarity: Webseiten-Icon'
categories = [ 'Hugo' ]
tags = [ 'hugo', 'clarity' ]
toc = true
+++

<!--
Hugo-Clarity: Webseiten-Icon
============================
-->

Ich würde gerne das Stuttgarter Rößle in der Titelzeile sehen!

<!--more-->

Bisherige Anzeige
-----------------

![Bisheriges Webseiten-Icon](images/bisher-abgerissen.png?width=500px)

Änderung
--------

"stuttgart.svg" ablegen unter "static/icons/stuttgart.svg". Zusätzlich nachfolgende Anpassungen:

```diff
diff --git a/themes/hugo-clarity/layouts/partials/favicon.html b/themes/hugo-clarity/layouts/partials/favicon.html
index 98bc0ab..51e1908 100644
--- a/themes/hugo-clarity/layouts/partials/favicon.html
+++ b/themes/hugo-clarity/layouts/partials/favicon.html
@@ -1,6 +1,6 @@
 {{- $iconsDir := default "icons/" .Site.Params.iconsDir }}
 {{- $appleTouch := absURL (printf "%s%s" $iconsDir "apple-touch-icon.png") }}
-{{- $favicon := absURL (printf "%s%s" $iconsDir "favicon-32x32.png" ) }}
+{{- $favicon := absURL (printf "%s%s" $iconsDir "stuttgart.svg" ) }}
 {{- $manifest := absURL (printf "%s%s" $iconsDir "site.webmanifest" ) }}
 <link rel="apple-touch-icon" sizes="180x180" href="{{ $appleTouch }}">
 <link rel="icon" type="image/png" sizes="32x32" href="{{ $favicon }}">
```

Neue Anzeige
------------

![Korrigiertes Webseiten-Icon](images/korrigiert-abgerissen.png?width=500px)

Links
-----

- [Github - Hugo-Clarity](https://github.com/chipzoller/hugo-clarity)

Historie
--------

- 2025-01-16: Erste Version
