+++
date = '2024-11-22'
draft = true
title = 'Hugo: Breitenlimitierung aufheben'
categories = [ "Hugo" ]
+++

<!--
Hugo: Breitenlimitierung aufheben
=================================
-->

Meine Webseite verhält sich aus meiner Sicht ungünstig,
wenn man das Browserfenster verbreitert. Es wird dann links
und rechts ein leerer Bereich eingeblendet. Der Nutztext
bleibt schmal.



Meine mit Hugo erstellte Webseite eignet sich ideal
zur Veröffentlichung auf Github. Den auf OctoPress basierenden
Vorgänger habe ich veröffentlicht als statische Webapp auf
dem Webserver meiner Firma "daemons-point.com".

Dazu braucht's:

- Einen Rechner, der die Seite zusammenbaut
- Einen Rechner, der als Webserver fungiert

Für meine private Seite möchte ich möglichst wenig
Infrastruktur-Komponenten verwenden, also versuche
ich mich an Github und Github-Pages. Mal sehen, wie's läuft!

<!--more-->

Vorbedingungen
--------------

- Nutzer auf Github: uli-heller
- Repository auf Github: uli.heller.cool

Ablauf
------

- Repository öffnen - [uli.heller.cool](https://github.com/uli-heller/uli.heller.cool)
- Settings
- Pages
- Traditioneller Weg
  - Build and deployment
    - Source: Deploy from a branch
    - Branch: gh-pages
    - Custom domain: uli.heller.cool
  - Danach: Lokal bauen und "my-hugo-site/pubic" in den Branch "gh-pages" ausrollen
- Neuer Weg
  - Workflow-Datei anlegen - .github/workflows/hugo.yaml
    - Die Workflow-Datei muß in "main" landen!
    - Die Pfade werden angepasst (zumindest vorerst)
    - hugo.yaml:
      ```
      # Sample workflow for building and deploying a Hugo site to GitHub Pages
      name: Deploy Hugo site to Pages
      
      on:
        # Runs on pushes targeting the default branch
        push:
          branches:
            - main	    
      
        # Allows you to run this workflow manually from the Actions tab
        workflow_dispatch:
      
      # Sets permissions of the GITHUB_TOKEN to allow deployment to GitHub Pages
      permissions:
        contents: read
        pages: write
        id-token: write
      
      # Allow only one concurrent deployment, skipping runs queued between the run in-progress and latest queued.
      # However, do NOT cancel in-progress runs as we want to allow these production deployments to complete.
      concurrency:
        group: "pages"
        cancel-in-progress: false
      
      # Default to bash
      defaults:
        run:
          shell: bash
      
      jobs:
        # Build job
        build:
          runs-on: ubuntu-latest
          env:
            HUGO_VERSION: 0.137.1
          steps:
            - name: Install Hugo CLI
              run: |
                wget -O ${{ runner.temp }}/hugo.deb https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.deb \
                && sudo dpkg -i ${{ runner.temp }}/hugo.deb          
            - name: Install Dart Sass
              run: sudo snap install dart-sass
            - name: Checkout
              uses: actions/checkout@v4
              with:
                submodules: recursive
                fetch-depth: 0
            - name: Setup Pages
              id: pages
              uses: actions/configure-pages@v5
            - name: Install Node.js dependencies
              run: "[[ -f package-lock.json || -f npm-shrinkwrap.json ]] && npm ci || true"
            - name: Build with Hugo
              env:
                HUGO_CACHEDIR: ${{ runner.temp }}/hugo_cache
                HUGO_ENVIRONMENT: production
                TZ: America/Los_Angeles
              run: |
                hugo \
                  --gc \
                  --minify \
		  --source my-hugo-site \
                  --baseURL "${{ steps.pages.outputs.base_url }}/"          
            - name: Upload artifact
              uses: actions/upload-pages-artifact@v3
              with:
                path: ./my-hugo-site/public
      
        # Deployment job
        deploy:
          environment:
            name: github-pages
            url: ${{ steps.deployment.outputs.page_url }}
          runs-on: ubuntu-latest
          needs: build
          steps:
            - name: Deploy to GitHub Pages
              id: deployment
              uses: actions/deploy-pages@v4
	```

  - Build and deployment
    - Source: Github Actions
    - Branch: gh-pages
    - Custom domain: uli.heller.cool

  - Sichten: Wie sehen die [Actions von uli.heller.cool](https://github.com/uli-heller/uli.heller.cool/actions) aus?
    Idealerweise ist alles "grün"!

  - Sichten: Wie sieht [https://uli.heller.cool](https://uli.heller.cool) aus? Idealerweise ähnlich zur lokalen Sichtung!

Links:
------

- [Host on GitHub Pages](https://gohugo.io/hosting-and-deployment/hosting-on-github/)

Historie
--------

- 2024-11-21: Erste Version
