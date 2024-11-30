+++
date = '2024-11-01'
draft = false
title = 'Hugo: Interner Bereich'
categories = [ 'Hugo' ]
tags = [ 'hugo' ]
+++

<!--
Hugo: Interner Bereich
======================
-->

Der interne Bereich dient der Ablage
von Informationen, die nur für mich persönlich
interessant sind. Er ist nicht via
Menü oder Links erreichbar und taucht hoffentlich
auch nicht bei der Google-Suche auf!

<!--more-->

Sichtung interner Bereich
-------------------------

Den internen Bereich kann ich wie folgt sichten:

- Navigation auf die [Grundseite](/)
- Anpassen der Adresszeile
- Anhängen von "/i"
- Eingabetaste -> interner Bereich wird angezeigt

Aufbau interner Bereich
-----------------------

- content
  - i
    - index.md
    - anleitungen
      - _index.md
      - erstes-dokument.pdf
      - zweites-dokument.pdf

content/i/index.md
------------------

```
Interner Bereich
================

- [Anleitungen](anleitungen)
```

content/i/anleitungen/_index.md
-------------------------------

```
---
title: Anleitungen
description: Diverse Anleitungen zu technischen Geräten
#menu: main
#weight: 2
---

Bose Ultra Open Earbuds
-----------------------

- [Bedienungsanleitung (deutsch) 2024-11](889371_OG_ULT-HEADPHONEOPN_de.pdf)
- [Kurzanleitung (mehrsprachig) 2024-11](886741_QSG_CMWB-ULT-CASEPWR_ml.pdf)

Openshokz Openrun Pro 2
-----------------------

- [Bedienungsanleitung (deutsch) 2024-11](OpenRun_Pro_2_Benutzerhandbuch-DE.pdf)
```

Historie
--------

- 2024-11-01: Erste Version
