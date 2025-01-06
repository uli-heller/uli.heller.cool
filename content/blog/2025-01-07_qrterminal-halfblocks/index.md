+++
date = '2025-01-07'
draft = false
title = 'QRTERMINAL: QR-Codes auf dem Terminal ausgeben'
categories = [ 'Kommandozeile' ]
tags = [ 'linux', 'ubuntu' ]
+++

<!--QRTERMINAL: QR-Codes auf dem Terminal ausgeben-->
<!--==============================================-->

Manchmal brauche ich die Möglichkeit, auf der
Kommandozeile einen QR-Code zu erzeugen. Klar:
Eine PNG-Datei damit ist kein Problem.
Ich hätte idealerweise den QR-Code gerne als Text.
Da hilft [QRTERMINAL](https://github.com/mdp/qrterminal)!

<!--more-->

Einspielen
----------

### Mittels Paketmanager

```
sudo apt update
sudo apt install qrterminal
```

Funktioniert mit Ubuntu-24.04

### Aus den Quellen

```
git clone https://github.com/mdp/qrterminal.git
cd qrterminal
make
```

Funktioniert mit allen Ubuntu-Varianten. Man benötigt
zusätzlich diverse Entwicklerwerkzeuge, beispielsweise
den Go-Compiler.

Verwendung
----------

```
qrterminal (zeichenkette)
qrterminal https://uli.heller.cool
```

Probleme: Die Ausgaben können nicht ohne weiteres kopiert
und in ein Textdokument eingefügt werden. Nachfolgende
Passage habe ich erzeugt via Gnome-Terminal und "Als HTML kopieren".
Die vertikalen Abstände erscheinen wegen dem dafür ungünstigen
Styling meiner Webseite. Davon abgesehen sieht die Ausgabe
hier auf der Webseite ganz OK aus, leider ist die im Quellformat
quasi unlesbar - das gefällt mir nicht!

<pre><font color="#26A269"><b>uli@uli-laptop</b></font>:<font color="#12488B"><b>~</b></font>$ qrterminal https://uli.heller.cool

<span style="background-color:#D0CFCC">                                                          </span>
<span style="background-color:#D0CFCC">                                                          </span>
<span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">              </span><span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">              </span><span style="background-color:#D0CFCC">    </span>
<span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">          </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">      </span><span style="background-color:#171421">      </span><span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">    </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">          </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">    </span>
<span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">      </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">      </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">      </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">      </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">    </span>
<span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">      </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">      </span><span style="background-color:#D0CFCC">      </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">      </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">    </span>
<span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">      </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">      </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">      </span><span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">      </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">    </span>
<span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">          </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">        </span><span style="background-color:#171421">    </span><span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">          </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">    </span>
<span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">              </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">              </span><span style="background-color:#D0CFCC">    </span>
<span style="background-color:#D0CFCC">                    </span><span style="background-color:#171421">      </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">    </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">    </span><span style="background-color:#D0CFCC">                    </span>
<span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">      </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">          </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">    </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">        </span><span style="background-color:#D0CFCC">      </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">        </span>
<span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">    </span><span style="background-color:#D0CFCC">      </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">        </span><span style="background-color:#171421">    </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">      </span><span style="background-color:#D0CFCC">          </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">    </span>
<span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">    </span><span style="background-color:#D0CFCC">      </span><span style="background-color:#171421">          </span><span style="background-color:#D0CFCC">      </span><span style="background-color:#171421">    </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">    </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">    </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">      </span><span style="background-color:#D0CFCC">    </span>
<span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">      </span><span style="background-color:#D0CFCC">          </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">          </span><span style="background-color:#D0CFCC">          </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">      </span>
<span style="background-color:#D0CFCC">            </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">          </span><span style="background-color:#171421">    </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">          </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">    </span><span style="background-color:#D0CFCC">    </span>
<span style="background-color:#D0CFCC">      </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">      </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">    </span><span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">    </span><span style="background-color:#D0CFCC">      </span><span style="background-color:#171421">      </span><span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">    </span>
<span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">        </span><span style="background-color:#D0CFCC">      </span><span style="background-color:#171421">        </span><span style="background-color:#D0CFCC">          </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">      </span><span style="background-color:#D0CFCC">    </span>
<span style="background-color:#D0CFCC">      </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">          </span><span style="background-color:#171421">    </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">          </span><span style="background-color:#D0CFCC">      </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">      </span>
<span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">    </span><span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">            </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">            </span><span style="background-color:#D0CFCC">          </span>
<span style="background-color:#D0CFCC">                    </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">      </span><span style="background-color:#171421">    </span><span style="background-color:#D0CFCC">      </span><span style="background-color:#171421">    </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">    </span><span style="background-color:#D0CFCC">    </span>
<span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">              </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">        </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">    </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">    </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">    </span><span style="background-color:#D0CFCC">    </span>
<span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">          </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">    </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">    </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">      </span><span style="background-color:#171421">    </span><span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">    </span>
<span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">      </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">    </span><span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">    </span><span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">            </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">    </span><span style="background-color:#D0CFCC">    </span>
<span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">      </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">        </span><span style="background-color:#171421">    </span><span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">        </span><span style="background-color:#D0CFCC">        </span>
<span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">      </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">          </span><span style="background-color:#D0CFCC">              </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">      </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">    </span>
<span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">          </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">    </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">    </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">    </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">      </span>
<span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">              </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">      </span><span style="background-color:#D0CFCC">  </span><span style="background-color:#171421">      </span><span style="background-color:#D0CFCC">    </span><span style="background-color:#171421">  </span><span style="background-color:#D0CFCC">      </span><span style="background-color:#171421">    </span><span style="background-color:#D0CFCC">    </span>
<span style="background-color:#D0CFCC">                                                          </span>
<span style="background-color:#D0CFCC">                                                          </span>
</pre>

Erweiterung um Halfblocks
-------------------------

[Mein Fork mit dem Branch der Halfblock-Erweiterung](https://github.com/uli-heller/qrterminal/tree/halfblocks)

```diff
diff --git a/cmd/qrterminal/main.go b/cmd/qrterminal/main.go
index 767b8ec..8073af5 100644
--- a/cmd/qrterminal/main.go
+++ b/cmd/qrterminal/main.go
@@ -14,6 +14,7 @@ import (
 )
 
 var verboseFlag bool
+var halfblocksFlag bool
 var levelFlag string
 var quietZoneFlag int
 var sixelDisableFlag bool
@@ -33,6 +34,7 @@ func getLevel(s string) qr.Level {
 
 func main() {
        flag.BoolVar(&verboseFlag, "v", false, "Output debugging information")
+       flag.BoolVar(&halfblocksFlag, "H", false, "Activate halfblocks")
        flag.StringVar(&levelFlag, "l", "L", "Error correction level")
        flag.IntVar(&quietZoneFlag, "q", 2, "Size of quietzone border")
        flag.BoolVar(&sixelDisableFlag, "s", false, "disable sixel format for output")
@@ -78,6 +80,14 @@ func main() {
                cfg.WhiteChar = qrterminal.WHITE
        }

+       if halfblocksFlag {
+               cfg.HalfBlocks = true
+               cfg.BlackChar      = qrterminal.BLACK_BLACK
+               cfg.BlackWhiteChar = qrterminal.BLACK_WHITE
+               cfg.WhiteBlackChar = qrterminal.WHITE_BLACK
+               cfg.WhiteChar      = qrterminal.WHITE_WHITE
+       }
+
        fmt.Fprint(os.Stdout, "\n")
        qrterminal.GenerateWithConfig(content, cfg)
 }
```

Die Erweiterung ist sehr einfach. Die Halfblock-Funktionialität ist
grundsätzlich schon in QRTERMINAL enthalten. Man kann sie nur via
Kommandozeile nicht aktivieren. Das rüstet mein PullRequest nach.
Dazu muß man dann die Option "-H" beim Aufruf angeben.

Kopierbare Ausgabe
------------------

```
$ qrterminal -H https://uli.heller.cool

█████████████████████████████
██ ▄▄▄▄▄ ██▄▀▀ ██ ▀█ ▄▄▄▄▄ ██
██ █   █ █▄  ▀▄█▄▀██ █   █ ██
██ █▄▄▄█ ██▀▄██▄  ██ █▄▄▄█ ██
██▄▄▄▄▄▄▄█ ▀ █ ▀▄▀ █▄▄▄▄▄▄▄██
██  ▄█▄ ▄▄▄█  █ █▄   ███▄█▀██
██ ▄█▀▀ ▄▄▄▄█▀█  ▀  █▄▄█▄ ▄██
███▀█▀ ▀▄▀▀██▀ ▄█▄   ▄█ █▄ ██
██▄▀█ ▄▄▄██▀ ▄  ▀▀▀██▄▀█▄ ▄██
██▄█▄▄██▄▄ ▄▄ █▄█▀ ▄▄▄  █▀▀██
██ ▄▄▄▄▄ █ █▀▀█ ▀▄ █▄█  █▄ ██
██ █   █ █▄▄█▀ ▄█▀▄ ▄   ▀▄▄██
██ █▄▄▄█ █ ▄ ▄ ▀█▀▀█▀█ ▀█▀▄██
██▄▄▄▄▄▄▄█▄█▄▄▄█▄▄▄██▄███▄▄██
▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
```

Die Ausgabe ist wesentlich kleiner
und kann relativ problemlos kopiert werden!

Links
-----

- [Github: QRTERMINAL](https://github.com/mdp/qrterminal)
- [Mein Fork mit dem Branch der Halfblock-Erweiterung](https://github.com/uli-heller/qrterminal/tree/halfblocks)

Versionen
---------

Getestet mit

- Ubuntu-22.04
- Ubuntu-20.04

Historie
--------

- 2025-01-07: Erste Version
