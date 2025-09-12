+++
date = '2025-09-12'
draft = false
title = 'Ubuntu: Zurücksetzen der USB-Geräte'
categories = [ 'Ubuntu' ]
tags = [ 'linux', 'ubuntu' ]
+++

<!--
Ubuntu: Zurücksetzen der USB-Geräte
===================================
-->

Diese Woche habe ich es nun schon zweimal erlebt, dass
meine USB-Webcam in Teams plötzlich nicht mehr funktioniert.
Aus- und Einstecken hilft, Neustart des Rechners auch.
Beides ist aber sehr unkomfortabel, es muß anders gehen!

<!--more-->

Ich bin über diesen Artikel gestolpert:

- [Wesley Aptekar-Cassels - How to reset the USB stack on Linux](https://blog.wesleyac.com/posts/linux-reset-usb)

Das habe ich gleich in ein Skript namens "reset-usb.sh"
verpackt:

```
for d in $(lspci -Dm | grep "USB controller" | cut -f1 -d' '); do
    echo "$d"|sudo tee /sys/bus/pci/drivers/xhci_hcd/unbind >/dev/null
    echo "$d"|sudo tee /sys/bus/pci/drivers/xhci_hcd/bind >/dev/null
done
```

Test:

- USB-Webcam funktioniert nicht ("Schnee")
- `sudo reset-usb.sh`
- Danach klappts's wieder!

Getestet mit Ubuntu-24.04.3.

Links
-----

- [Wesley Aptekar-Cassels - How to reset the USB stack on Linux](https://blog.wesleyac.com/posts/linux-reset-usb)

Historie
--------

- 2025-09-12: Erste Version
