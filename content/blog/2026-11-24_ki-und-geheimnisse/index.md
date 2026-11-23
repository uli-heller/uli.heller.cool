+++
date = '2026-11-24'
draft = false
title = 'Linux: Git-Projekte, KI und Geheimnisse'
categories = [ 'KI' ]
tags = [ 'ki', 'linux', 'ubuntu' ]
+++

<!--
Linux: Git-Projekte, KI und Geheimnisse
=======================================
-->

Auch wenn ich der künstlichen Intelligenz ein
wenig reserviert gegenüber stehe, so ist nicht von der
Hand zu weisen, dass sie bei vielen Arbeiten
hilfreich ist. Das schafft neue Herausforderungen
bei der Handhabung von Geheimnissen wie API-Keys,
Kennworte, usw.

<!--more-->

Software-Entwicklung mit Geheimnissen
-------------------------------------

Meine Arbeit als Entwicklungs- und
Infrastruktur-Berater erfolgt überwiegend mittels
GIT-Projekten - die Daten, die ich "erzeuge", landen
typischerweise in Versionierungsspeichern wie
GitHub, GitLab, BitBucket, Forgejo
oder ähnlichem - je nach Kundenwunsch.

Nachfolgend verwende ich GitHub  stellvertretend für
alle diese Versionierungsspeicher.

Klar: Wenn die GIT-Projekte mit Geheimnissen arbeiten,
dann dürfen diese Geheimnisse nicht in GitHub landen.
Dies ist eine Praxis, die seit Jahren etabliert ist
und meiner Erfahrung nach zumeist eingehalten wird.

Erreicht wird dies typischerweise mit Techniken wie:

- GIT-Speicherung von ".env.example" (enthält Beispiele der Geheimnisse
  und meist auch eine Anleitung, wie man die "richtigen" Geheimnisse einträgt),
  Arbeit mit ".env" (enthält die "richtigen" Geheimnisse und wird niemals eingecheckt)

- Verwendung von verschlüsselten Properties bei SpringBoot-Anwendungen
  (siehe [Spring Cloud Config - Encryption and Decryption](https://docs.spring.io/spring-cloud-config/reference/server/encryption-and-decryption.html)).

- GIT-Speicherung mittels "git-crypt" - dabei werden ganze Dateien
  verschlüsselt, bevor sie im Versionierungsspeicher abgelegt werden

Die Umgebung sieht dann so aus:

- In GitHub liegt eine Datei ".env.example", die
  keine realen Geheimnisse enthält
- Die Datei ".env" mit realen Geheimnissen liegt nur im lokalen Arbeitsverzeichnis
- In GitHub liegt eine Datei "application.properties" mit vielen Konfigurationsparametern.
  Die Werte der geheimen Parameter sind verschlüsselt
- Der zur Entschlüsselung notwendige ENCRYPT_KEY liegt nur im lokalen Arbeitsverzeichnis
  (oder steht anderweitig auf dem Arbeitsplatzrechner zur Verfügung)
- In GitHub liegt eine Datei "secret.key", die komplett verschlüsselt ist

![GIT-Geheimnisse](git-geheimnisse.png)

Grundsätzlicher Ablauf
----------------------


Versionen
---------

- Getestet mit Ubuntu-2404

Links
-----

- [Spring Cloud Config - Encryption and Decryption](https://docs.spring.io/spring-cloud-config/reference/server/encryption-and-decryption.html)

Historie
--------

- 2026-11-24: Erste Version
