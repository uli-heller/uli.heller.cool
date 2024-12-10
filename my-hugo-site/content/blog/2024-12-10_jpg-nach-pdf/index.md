+++
date = '2024-12-10'
draft = false
title = 'JPG nach PDF wandeln'
categories = [ 'Bildchen' ]
tags = [ 'jpg', 'pdf', 'imagemagick' ]
toc=false
+++

<!--
JPG nach PDF wandeln
====================
-->

Manchmal habe ich eine Reihe von JPG-Dateien, die ich
gerne als PDF weiterverarbeiten und/oder archivieren
möchte. Beispielsweise dann, wenn ich einen mehrseitigen
Brief abfotografiert habe.

<!--more-->

Ablauf:

- Seiten sortieren: s1.jpg, s2.jpg, s3.jpg
- Wandeln: `convert s1.jpg s2.jpg s3.jpg -auto-orient brief.pdf`

Links
-----

- [Convert a directory of JPEG files to a single PDF document](https://askubuntu.com/questions/246647/convert-a-directory-of-jpeg-files-to-a-single-pdf-document)

Historie
--------

- 2024-12-10: Erste Version
