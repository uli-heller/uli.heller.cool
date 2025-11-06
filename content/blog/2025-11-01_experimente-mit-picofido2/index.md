+++
date = '2025-11-01'
draft = false
title = 'Experimente mit PICO-FIDO2'
categories = [ 'linux' ]
tags = [ 'fido2', 'linux', 'ubuntu', 'debian' ]
+++

<!--
Experimente mit PICO-FIDO2
==========================
-->

Ich habe mir ein [Waveshare RP2350-One](https://www.berrybase.de/waveshare-rp2350-one-dual-core-arm-cortex-m33-hazard-3-risc-v-4mb-flash-520kb-sram-150-mhz)
gekauft und spiele nun ein wenig damit herum!
Hier erste Erkenntnisse!

<!--more-->

Erstsichtung
------------

Für die Erstsichtung habe ich das Teil einfach an meinen
Rechner angeschlossen - es blinkt lustig vor sich hin!

Firmware aufspielen und konfigurieren
-------------------------------------

- Firmware herunterladen von [Github - pico-fido2](https://github.com/polhenarejos/pico-fido2)
  - [pico_fido2_waveshare_rp2350_one-6.6.uf2](https://github.com/polhenarejos/pico-fido2/releases/download/v6.6/pico_fido2_waveshare_rp2350_one-6.6.uf2)
- Virencheck via [VirusTotal](https://virustotal.com)
- Waveshare RP2350-One abziehen
- Knopf "BOOTSEL" drücken und einstecken -> der USB-Stick erscheint als "Laufwerk"
- pico_fido2_waveshare_rp2350_one-6.6.uf2 auf's Laufwerk kopieren -> Laufwerk wird getrennt
- [PicoCommissioner](https://www.picokeys.com/pico-commissioner/) im Browser aufrufen
- Dabei auswählen:
  - Select a known vendor: Yubikey 4/5
  - Rest: Unverändert
  - Commission via WebUSB
    - Pico auswählen -> klappt

Sichtung
--------

### fido2-ls.sh

dev         |type   |vendor|product|serial          |comment               
------------|-------|------|-------|----------------|----------------------
/dev/hidraw7|generic|0x1050|0x0407 |7971524AF195DE53|Pol Henarejos Pico Key

### lsusb

```
...
Bus 005 Device 028: ID 1050:0407 Yubico.com Yubikey 4/5 OTP+U2F+CCID
Device Descriptor:
  bLength                18
  bDescriptorType         1
  bcdUSB               2.00
  bDeviceClass            0 [unknown]
  bDeviceSubClass         0 [unknown]
  bDeviceProtocol         0 
  bMaxPacketSize0        64
  idVendor           0x1050 Yubico.com
  idProduct          0x0407 Yubikey 4/5 OTP+U2F+CCID
  bcdDevice            7.00
  iManufacturer           1 Pol Henarejos
  iProduct                2 Pico Key
  iSerial                 3 7971524AF195DE53
  bNumConfigurations      1
...
```

### Beobachtung

Der USB-Stick nervt! Die LED blinkt dauernd (ein- bis zweimal pro Sekunde)
uns ist sehr hell!

Links
-----

- [Berrybase - Waveshare RP2350-One](https://www.berrybase.de/waveshare-rp2350-one-dual-core-arm-cortex-m33-hazard-3-risc-v-4mb-flash-520kb-sram-150-mhz)
- [Github - pico-fido2](https://github.com/polhenarejos/pico-fido2)
- [PicoCommissioner](https://www.picokeys.com/pico-commissioner/)
- [PicoKeys](https://www.picokeys.com/)

Versionen
---------

- Getestet mit Ubuntu 24.04.3 LTS

Historie
--------

- 2025-11-01: Erste Version
