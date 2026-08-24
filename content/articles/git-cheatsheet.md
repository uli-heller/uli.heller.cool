---
date: 2025-09-09
draft: false
title: 'Git: Tipps und Tricks'
categories:
  - Git
tags:
  - git
---

<!--Git: Tipps und Tricks-->
<!--=========================-->

Ich arbeite seit Jahren mit Git. Manche Dinge
"erforsche" ich gefühlt zum zehnten mal. Um das
künftig zu vermeiden sammle ich hier alle möglichen Kniffe, die mir
über den Weg laufen.

<!--more-->

Eltern-Branch ermitteln
-----------------------

```
git log --pretty=format:'%D' HEAD^ | grep 'origin/' | head -n1 | sed 's@origin/@@' | sed 's@,.*@@'
git log --pretty=format:'%D' "${BRANCH_NAME}^" | grep 'origin/' | head -n1 | sed -e 's@origin/@@' -e 's@,.*@@'
```

Quelle: [StackOverflow - How to get git parent branch name from current branch?](https://stackoverflow.com/questions/38495989/how-to-get-git-parent-branch-name-from-current-branch/60034993)

Ersten Commit eines Branches anzeigen
-------------------------------------

```
git log master..branch --oneline | tail -1
git log "${PARENT_BRANCH_NAME}..${BRANCH_NAME}" --oneline --reverse |head -1
```

Quelle: [StackOverflow - Git - how to find first commit of specific branch](https://stackoverflow.com/questions/18407526/git-how-to-find-first-commit-of-specific-branch)

Merge: Konflikte ignorieren und alle Änderungen übernehmen
----------------------------------------------------------

Manchmal kommt es vor, dass man einen anderen Entwicklungszweig mit dem
aktuellen zusammenführen möchte und dabei "überraschende" Konflikte
auftreten. Das passiert insbesondere dann gerne, wenn einzelne Änderungen
per Cherry-Picking übernommen wurden.

Angenommen, ich bin mir SICHER, dass der andere Entwicklungszweig die
"richtigen" Änderungen enthält und im Konliktfall immer die Variante
vom anderen Zweig greift, dann kann ich den Merge-Vorgang aufrufen mit

```
git merge --strategy-option theirs (other-branch)
```

Quelle: [StackOverflow - Resolve Git merge conflicts in favor of their changes during a pull](https://stackoverflow.com/a/10697551)

Historie
--------

- 2026-08-24: Merge
- 2025-09-09: Erste Version
