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

Ergänzung um KI-Agenten
-----------------------

Eine gängige Praxis ist die Erweiterung von vorigem Arbeitsablauf
um einen KI-Agenten:

![Ergänzung um KI-Agent](git-ki-agent.png)

Er wird entweder per Kommandozeile gestartet oder innerhalb der Entwicklungsumgebung.
Typischerweise hat er Zugriff auf das Arbeitsverzeichnis und damit "sieht" er auch
quasi alle Geheimnisse. Das ist aus verschiedenen Gründen potentiell ein Problem:

- Manche KI-Nutzungspläne nutzen alle verfügbaren Daten zur Erweiterung/zum Training der
  zugrunde liegenden KI-Modelle. Das bedeutet letztlich, dass die Geheimnisse
  in neueren Versionen des Modelles landen und damit potentiell anderen Nutzern
  zur Verfügung stehen können

- Auch ohne Training-Verwendung gibt es Berichte von Geheimnissen, die nach
  Übermittlung an eine KI-Infrastruktur "ausgenutzt" werden - siehe
  [arsTechnica - Researcher plants 2m canaries into the AI supply chain. A privacy disaster surfaced.](https://arstechnica.com/security/2026/11/a-leaky-ai-supply-chain-is-exposing-secret-user-data-at-an-alarming-rate/)
  und [dragos - Three breaches, endless leaks: Your AI supply chain needs canaries](https://www.dragos.com/blog/ai-supply-chain-security-canary-tokens#how-do-canary-tokens-detect-prompt-leaks)

Also: Geheimnisse und KI-Infrastruktur müssen strikt getrennt werden!

Zusätzlich gibt es auch ein Problem mit Umgebungsmodifikationen:
COPILOT führt bei der Ermittlung von Problemlösungen immer mal wieder
Kommandos in seiner Laufzeitumgebung aus. Bei der Nutzung im letzten Team
waren das sehr häufig kleine Python-Skripts, die üblicherweise vor der
Ausführung gesichtet und freigegeben werden müssen. Leider ist dies
oftmals sehr lästig, besonders, wenn man die Python-Skripts nicht
versteht. Dann ist es naheliegend, Python-Skript-Ausführung einfach
generell freizugeben, was im Endeffekt bedeutet, dass man quasi seinen
Benutzer für COPILOT frei gibt und später nicht mehr so richtig nachvollziehen
kann, welche Änderungen COPILOT durchgeführt hat.

Bei OPENCODE habe ich noch deutlich aggressiveres Verhalten beobachtet.
OPENCODE hat bei mir in einer Testumgebung ohne Rückfrage Zusatztools
installiert. Für die Problemlösung durchaus förderlich, für den Zustand
der Testumgebung eher nicht.

Also: Die übliche Laufzeitumgebung und der KI-Agent müssen strikt getrennt werden!

Versionen
---------

- Getestet mit Ubuntu-2404

Links
-----

- [Spring Cloud Config - Encryption and Decryption](https://docs.spring.io/spring-cloud-config/reference/server/encryption-and-decryption.html)
- [arsTechnica - Researcher plants 2m canaries into the AI supply chain. A privacy disaster surfaced.](https://arstechnica.com/security/2026/11/a-leaky-ai-supply-chain-is-exposing-secret-user-data-at-an-alarming-rate/)
- [dragos - Three breaches, endless leaks: Your AI supply chain needs canaries](https://www.dragos.com/blog/ai-supply-chain-security-canary-tokens#how-do-canary-tokens-detect-prompt-leaks)

Historie
--------

- 2026-11-24: Erste Version
