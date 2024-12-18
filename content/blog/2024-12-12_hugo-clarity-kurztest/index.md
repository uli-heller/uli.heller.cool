+++
date = '2024-12-12'
draft = false
title = 'Hugo: Kurztest vom Theme Clarity'
categories = [ 'Hugo' ]
tags = [ 'hugo', 'clarity' ]
+++

<!--
Hugo: Kurztest vom Theme Clarity
================================
-->

Ich stelle meine Webseite kurz um auf das Theme "Clarity"
und schaue, wie's aussieht.

<!--more-->

Theme herunterladen
-------------------

```
git submodule add https://github.com/chipzoller/hugo-clarity themes/hugo-clarity.orig
mkdir themes/hugo-clarity
(cd themes/hugo-clarity.orig && git archive HEAD)|(cd themes/hugo-clarity && tar xf -)
```

Theme einfach aktivieren
------------------------

- Ändern in hugo.toml: theme="hugo-clarity"
- Test mit: `hugo -D -E -F server` -> bricht ab mit Fehlern

```
uli@uliip5:~/git/github/uli-heller/uli.heller.cool/my-hugo-site$ hugo -D -E -F server
Watching for changes in /home/uli/git/github/uli-heller/uli.heller.cool/my-hugo-site/{archetypes,assets,content,data,i18n,layouts,static,themes}
Watching for config changes in /home/uli/git/github/uli-heller/uli.heller.cool/my-hugo-site/hugo.toml
Start building sites … 
hugo v0.136.5-46cccb021bc6425455f4eec093f5cc4a32f1d12c+extended linux/amd64 BuildDate=2024-10-24T12:26:27Z VendorInfo=gohugoio

ERROR render of "section" failed: "/home/uli/git/github/uli-heller/uli.heller.cool/my-hugo-site/themes/hugo-clarity/layouts/_default/baseof.html:21:8": execute of template failed: template: _default/list.html:21:8: executing "_default/list.html" at <partial "head" .>: error calling partial: "/home/uli/git/github/uli-heller/uli.heller.cool/my-hugo-site/themes/hugo-clarity/layouts/partials/head.html:24:4": execute of template failed: template: partials/head.html:24:4: executing "partials/head.html" at <partial "opengraph" .>: error calling partial: "/home/uli/git/github/uli-heller/uli.heller.cool/my-hugo-site/themes/hugo-clarity/layouts/partials/opengraph.html:26:13": execute of template failed: template: partials/opengraph.html:26:13: executing "partials/opengraph.html" at <absURL $s.logo>: error calling absURL: unable to cast maps.Params{"image":"images/stuttgart.svg", "subtitle":"... da läuft was!", "title":"Ulis Welt"} of type maps.Params to string
ERROR render of "home" failed: "/home/uli/git/github/uli-heller/uli.heller.cool/my-hugo-site/themes/hugo-clarity/layouts/_default/baseof.html:21:8": execute of template failed: template: index.html:21:8: executing "index.html" at <partial "head" .>: error calling partial: "/home/uli/git/github/uli-heller/uli.heller.cool/my-hugo-site/themes/hugo-clarity/layouts/partials/head.html:24:4": execute of template failed: template: partials/head.html:24:4: executing "partials/head.html" at <partial "opengraph" .>: error calling partial: "/home/uli/git/github/uli-heller/uli.heller.cool/my-hugo-site/themes/hugo-clarity/layouts/partials/opengraph.html:26:13": execute of template failed: template: partials/opengraph.html:26:13: executing "partials/opengraph.html" at <absURL $s.logo>: error calling absURL: unable to cast maps.Params{"image":"images/stuttgart.svg", "subtitle":"... da läuft was!", "title":"Ulis Welt"} of type maps.Params to string
ERROR render of "page" failed: "/home/uli/git/github/uli-heller/uli.heller.cool/my-hugo-site/themes/hugo-clarity/layouts/_default/baseof.html:21:8": execute of template failed: template: _default/single.html:21:8: executing "_default/single.html" at <partial "head" .>: error calling partial: "/home/uli/git/github/uli-heller/uli.heller.cool/my-hugo-site/themes/hugo-clarity/layouts/partials/head.html:24:4": execute of template failed: template: partials/head.html:24:4: executing "partials/head.html" at <partial "opengraph" .>: error calling partial: "/home/uli/git/github/uli-heller/uli.heller.cool/my-hugo-site/themes/hugo-clarity/layouts/partials/opengraph.html:26:13": execute of template failed: template: partials/opengraph.html:26:13: executing "partials/opengraph.html" at <absURL $s.logo>: error calling absURL: unable to cast maps.Params{"image":"images/stuttgart.svg", "subtitle":"... da läuft was!", "title":"Ulis Welt"} of type maps.Params to string
Built in 200 ms
Error: error building site: render: failed to render pages: render of "404" failed: "/home/uli/git/github/uli-heller/uli.heller.cool/my-hugo-site/themes/hugo-clarity/layouts/_default/baseof.html:21:8": execute of template failed: template: 404.html:21:8: executing "404.html" at <partial "head" .>: error calling partial: "/home/uli/git/github/uli-heller/uli.heller.cool/my-hugo-site/themes/hugo-clarity/layouts/partials/head.html:24:4": execute of template failed: template: partials/head.html:24:4: executing "partials/head.html" at <partial "opengraph" .>: error calling partial: "/home/uli/git/github/uli-heller/uli.heller.cool/my-hugo-site/themes/hugo-clarity/layouts/partials/opengraph.html:26:13": execute of template failed: template: partials/opengraph.html:26:13: executing "partials/opengraph.html" at <absURL $s.logo>: error calling absURL: unable to cast maps.Params{"image":"images/stuttgart.svg", "subtitle":"... da läuft was!", "title":"Ulis Welt"}
...
```

Nachtrag 2024-12-18: Für mich sieht es so aus, als gäbe es Probleme mit dem Logo.

Theme aktivieren mit Zusatzdateien
----------------------------------

```
cp -a themes/hugo-clarity/exampleSite/* . && rm -f config.toml
```

Test mit: `hugo -D -E -F server` -> bricht ab mit Fehlern

```
uli@uliip5:~/git/github/uli-heller/uli.heller.cool/my-hugo-site$ hugo -D -E -F server
Watching for changes in /home/uli/git/github/uli-heller/uli.heller.cool/my-hugo-site/{archetypes,assets,content,data,i18n,layouts,static,themes}
Watching for config changes in /home/uli/git/github/uli-heller/uli.heller.cool/my-hugo-site/hugo.toml, /home/uli/git/github/uli-heller/uli.heller.cool/my-hugo-site/config/_default, /home/uli/git/github/uli-heller/uli.heller.cool/my-hugo-site/config/_default/menus
Start building sites … 
hugo v0.136.5-46cccb021bc6425455f4eec093f5cc4a32f1d12c+extended linux/amd64 BuildDate=2024-10-24T12:26:27Z VendorInfo=gohugoio

ERROR render of "term" failed: "/home/uli/git/github/uli-heller/uli.heller.cool/my-hugo-site/themes/hugo-clarity/layouts/_default/list.html:2:6": execute of template failed: template: _default/list.html:2:6: executing "main" at <partial "archive" .>: error calling partial: "/home/uli/git/github/uli-heller/uli.heller.cool/my-hugo-site/themes/hugo-clarity/layouts/partials/archive.html:16:11": execute of template failed: template: partials/archive.html:16:11: executing "partials/archive.html" at <partial "excerpt" .>: error calling partial: execute of template failed: template: partials/excerpt.html:12:12: executing "partials/excerpt.html" at <partial "image" (dict "file" . "alt" $.Title "type" "thumbnail" "Page" $.Page)>: error calling partial: "/home/uli/git/github/uli-heller/uli.heller.cool/my-hugo-site/themes/hugo-clarity/layouts/partials/image.html:29:14": execute of template failed: template: partials/image.html:29:14: executing "partials/image.html" at <strings.HasPrefix>: error calling HasPrefix: unable to cast maps.Params{"src":"img/placeholder.png", "visibility":[]interface {}{"list"}} of type maps.Params to string
ERROR render of "page" failed: "/home/uli/git/github/uli-heller/uli.heller.cool/my-hugo-site/themes/hugo-clarity/layouts/_default/baseof.html:21:8": execute of template failed: template: _default/single.html:21:8: executing "_default/single.html" at <partial "head" .>: error calling partial: "/home/uli/git/github/uli-heller/uli.heller.cool/my-hugo-site/themes/hugo-clarity/layouts/partials/head.html:24:4": execute of template failed: template: partials/head.html:24:4: executing "partials/head.html" at <partial "opengraph" .>: error calling partial: "/home/uli/git/github/uli-heller/uli.heller.cool/my-hugo-site/themes/hugo-clarity/layouts/partials/opengraph.html:37:21": execute of template failed: template: partials/opengraph.html:37:21: executing "partials/opengraph.html" at <add $relpath .>: error calling add: can't apply the operator to the values
Built in 1093 ms
Error: error building site: render: failed to render pages: render of "section" failed: "/home/uli/git/github/uli-heller/uli.heller.cool/my-hugo-site/themes/hugo-clarity/layouts/_default/list.html:2:6": execute of template failed: template: _default/list.html:2:6: executing "main" at <partial "archive" .>: error calling partial: "/home/uli/git/github/uli-heller/uli.heller.cool/my-hugo-site/themes/hugo-clarity/layouts/partials/archive.html:16:11": execute of template failed: template: partials/archive.html:16:11: executing "partials/archive.html" at <partial "excerpt" .>: error calling partial: execute of template failed: template: partials/excerpt.html:12:12: executing "partials/excerpt.html" at <partial "image" (dict "file" . "alt" $.Title "type" "thumbnail" "Page" $.Page)>: error calling partial: "/home/uli/git/github/uli-heller/uli.heller.cool/my-hugo-site/themes/hugo-clarity/layouts/partials/image.html:29:14": execute of template failed: template: partials/image.html:29:14: executing "partials/image.html" at <strings.HasPrefix>: error calling HasPrefix: unable to cast maps.Params{"src":"img/placeholder.png", "visibility":[]interface {}{"list"}} of type maps.Params to string
```

Links
-----

- [Github - Hugo-Clarity](https://github.com/chipzoller/hugo-clarity)
- [Getting Up And Running](https://github.com/chipzoller/hugo-clarity?tab=readme-ov-file#getting-up-and-running)

Historie
--------

- 2024-12-18: Kurzanalyse Logo-Probleme
- 2024-12-12: Erste Version
