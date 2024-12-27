uli.heller.cool
===============

Vorbemerkungen und Rechtliches
------------------------------

- [Lizenz](LICENSE.md)
- [Impressum](impressum.md)

Technisches
-----------

### Artikel erstellen

1. Erstelle/Editiere die ".md"-Dateien
2. Sorge dafür, dass sie im "main"-Zweig landen
   - `git checkout main`
   - `git add ...`
   - `git commit ...`
   - `git push`
3. Sichte die Änderungen
   - `python3 -m http.server 8000 -d .`
   - Browser starten mit [http://localhost:8000][LOCALHOST]
4. Überführe die Änderungen in den "gh-pages"-Zweig
   - `git checkout gh-pages`
   - `git rebase main`
   - `git push`
5. Warte grob 15 Minuten
6. Sichte die Änderungen auf [https://uli.heller.cool](https://uli.heller.cool)

[LOCALHOST]: http://localhost:8000
