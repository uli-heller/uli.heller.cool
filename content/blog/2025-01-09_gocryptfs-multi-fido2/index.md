+++
date = '2025-01-09'
draft = false
title = 'Verschlüsseltes Dateisystem mit GOCRYPTFS - mehrere Fido2-Geräte'
categories = [ 'Verschlüsselung' ]
tags = [ 'crypto', 'linux', 'ubuntu' ]
+++

<!--Verschlüsseltes Dateisystem mit GOCRYPTFS - mehrere Fido2-Geräte-->
<!--================================================================-->

GOCRYPTFS kann auch in Verbindung mit
Fido2-Geräten verwendet werden.
Das ist sehr komfortabel, man muß sich
keine Kennworte merken sondern nur
auf sein Fido2-Gerät "aufpassen".

Ich habe mehrere Fido2-Geräte: Einen Solokey, den
ich primär an meinem Arbeitsplatzrechner nutze
und einen Nitrokey für den Laptop.

Ich würde das verschlüsselte Dateisystem gerne mit
beiden Fido2-Geräten entsperren können!

<!--more-->

Grundlegende Idee
-----------------

- Konfigurieren für ein Fido2-Gerät
- Zweites Fido2-Gerät hinzufügen ähnlich wie
  [Verschlüsseltes Dateisystem mit GOCRYPTFS - Fido2 und kompliziertes Kennwort]({{< ref  "/blog/2025-01-08_gocryptfs-multi" >}}):

Dateisystem mit einem Fido2-Gerät
---------------------------------

- Ich verwende das Dateisystem von [Verschlüsseltes Dateisystem mit GOCRYPTFS - Fido2 und kompliziertes Kennwort]({{< ref  "/blog/2025-01-08_gocryptfs-multi" >}})
- Verschlüsselt: [encrypted](encrypted) (... auf der Webseite vermutlich nicht sinnvoll weiterverwendbar)
  - `git mv encrypted/gocryptfs.conf  encrypted/gocryptfs-nitro.conf`
  - `git rm encrypted/gocryptfs-password.conf`
- Geheimnis und MasterKey:  [secret](secret) (... auf der Webseite vermutlich nicht sinnvoll weiterverwendbar)

Erweitern um zweites Fido2-Gerät
--------------------------------

```
$ mkdir encrypted-s
$ gocryptfs --init --fido2 /dev/hidraw2 --config encrypted/gocryptfs-solo.conf encrypted-s
Using config file at custom location /home/uli/git/github/uli-heller/uli.heller.cool/content/blog/2025-01-09_gocryptfs-multi-fido2/encrypted/gocryptfs-solo.conf
FIDO2 Register: interact with your device ...
FIDO2 Secret: interact with your device ...
...
  # Angezeigter Masterkey wird nicht benötigt!
$ rm -rf encrypted-s

$ gocryptfs --passwd --masterkey 3eca91ba-52c4391d-5d7ce783-b07e40f2-a3808dfd-a08c7ee5-a9577f97-cc6085d3 \
  --fido2 /dev/hidraw2 \
  --config encrypted/gocryptfs-solo.conf \
  encrypted
Using config file at custom location /home/uli/git/github/uli-heller/uli.heller.cool/content/blog/2025-01-09_gocryptfs-multi-fido2/encrypted/gocryptfs-solo.conf
Using explicit master key.
THE MASTER KEY IS VISIBLE VIA "ps ax" AND MAY BE STORED IN YOUR SHELL HISTORY!
ONLY USE THIS MODE FOR EMERGENCIES
Password change is not supported on FIDO2-enabled filesystems.
```

So einfach geht es also leider nicht!

Anpassungen an GOCRYPTFS
------------------------

```diff
diff --git a/main.go b/main.go
index cd643b5..9bd76dd 100644
--- a/main.go
+++ b/main.go
@@ -78,15 +78,19 @@ func changePassword(args *argContainer) {
                if len(masterkey) == 0 {
                        log.Panic("empty masterkey")
                }
+               var newPw []byte
                if confFile.IsFeatureFlagSet(configfile.FlagFIDO2) {
-                       tlog.Fatal.Printf("Password change is not supported on FIDO2-enabled filesystems.")
-                       os.Exit(exitcodes.Usage)
-               }
-               tlog.Info.Println("Please enter your new password.")
-               newPw, err := readpassword.Twice(nil, nil)
-               if err != nil {
-                       tlog.Fatal.Println(err)
-                       os.Exit(exitcodes.ReadPassword)
+                       var fido2CredentialID, fido2HmacSalt []byte
+                       fido2CredentialID = confFile.FIDO2.CredentialID //fido2.Register(args.fido2, filepath.Base(args.cipherdir))
+                       fido2HmacSalt = confFile.FIDO2.HMACSalt //cryptocore.RandBytes(32)
+                       newPw = fido2.Secret(args.fido2, args.fido2_assert_options, fido2CredentialID, fido2HmacSalt)
+               } else {
+                       tlog.Info.Println("Please enter your new password.")
+                       newPw, err = readpassword.Twice(nil, nil)
+                       if err != nil {
+                          tlog.Fatal.Println(err)
+                          os.Exit(exitcodes.ReadPassword)
+                       }
                }
                logN := confFile.ScryptObject.LogN()
                if args._explicitScryptn {
```

Damit:

- Bauen: `./build.bash`
- Verwenden: `.../gocryptfs --version` -> gocryptfs v2.4.0-51-g55ef2f0.multi-fido2; go-fuse v2.5.0; 2025-01-02 go1.23.2 linux/amd64

Erweitern um zweites Fido2-Gerät mit neuer Version von GOCRYPTFS
----------------------------------------------------------------

```
$ mkdir encrypted-s
$ .../gocryptfs --init --fido2 /dev/hidraw2 --config encrypted/gocryptfs-solo.conf encrypted-s
Using config file at custom location /home/uli/git/github/uli-heller/uli.heller.cool/content/blog/2025-01-09_gocryptfs-multi-fido2/encrypted/gocryptfs-solo.conf
FIDO2 Register: interact with your device ...
Enter PIN for /dev/hidraw2: 1111
  # Pin eingeben
  # Solokey drücken
FIDO2 Secret: interact with your device ...
  # Solokey drücken
...
  # Angezeigter Masterkey wird nicht benötigt!

$ rm -rf encrypted-s

$ .../gocryptfs --passwd --masterkey 3eca91ba-52c4391d-5d7ce783-b07e40f2-a3808dfd-a08c7ee5-a9577f97-cc6085d3 \
  --fido2 /dev/hidraw2 \
  --config encrypted/gocryptfs-solo.conf \
  encrypted
Using config file at custom location /home/uli/git/github/uli-heller/uli.heller.cool/content/blog/2025-01-09_gocryptfs-multi-fido2/encrypted/gocryptfs-solo.conf
Using explicit master key.
THE MASTER KEY IS VISIBLE VIA "ps ax" AND MAY BE STORED IN YOUR SHELL HISTORY!
ONLY USE THIS MODE FOR EMERGENCIES
FIDO2 Secret: interact with your device ...
  # Solokey drücken
A copy of the old config file has been created at "/home/uli/git/github/uli-heller/uli.heller.cool/content/blog/2025-01-09_gocryptfs-multi-fido2/encrypted/gocryptfs-solo.conf.bak".
Delete it after you have verified that you can access your files with the new password.
Password changed.

$ rm -f encrypted/gocryptfs-solo.conf.bak
```

Jetzt hat es geklappt!

Dateisystem verwenden mit Nitrokey
----------------------------------

```
$ mkdir /tmp/decrypted-uli
$ gocryptfs --fido2 /dev/hidraw2 --config encrypted/gocryptfs-nitro.conf encrypted /tmp/decrypted-uli
Using config file at custom location /home/uli/git/github/uli-heller/uli.heller.cool/content/blog/2025-01-09_gocryptfs-multi-fido2/encrypted/gocryptfs-nitro.conf
FIDO2 Secret: interact with your device ...
  # Nitrokey leuchtet - berühren!
Decrypting master key
Filesystem mounted and ready.

$ ls /tmp/decrypted-uli/
secret.txt

$ cat /tmp/decrypted-uli/secret.txt
Das ist ein geheimer Satz

$ fusermount -u /tmp/decrypted-uli
$ rmdir /tmp/decrypted-uli
```

Dateisystem verwenden mit Solokey
---------------------------------

```
$ mkdir /tmp/decrypted-uli
$ gocryptfs --fido2 /dev/hidraw2 --config encrypted/gocryptfs-solo.conf encrypted /tmp/decrypted-uli
Using config file at custom location /home/uli/git/github/uli-heller/uli.heller.cool/content/blog/2025-01-09_gocryptfs-multi-fido2/encrypted/gocryptfs-solo.conf
FIDO2 Secret: interact with your device ...
  # Solokey drücken
Decrypting master key
Filesystem mounted and ready.

$ ls /tmp/decrypted-uli/
secret.txt

$ cat /tmp/decrypted-uli/secret.txt 
Das ist ein geheimer Satz

$ fusermount -u /tmp/decrypted-uli
$ rmdir /tmp/decrypted-uli
```

Links
-----

- [Homepage: gocryptfs](https://nuetzlich.net/gocryptfs/)
- [GITHUB: gocryptfs](https://github.com/rfjakob/gocryptfs)
- [GITHUB: Mein Fork mit der Multi-Fido-Korrektur](https://github.com/uli-heller/gocryptfs/tree/multi-fido2)

Versionen
---------

Getestet mit

- Ubuntu-22.04 und gocryptfs-2.4.0.1
- Ubuntu-20.04 und gocryptfs-2.4.0.1

Historie
--------

- 2025-01-09: Erste Version
