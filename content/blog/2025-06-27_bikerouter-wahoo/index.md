+++
date = '2025-06-27'
draft = true
title = 'Wahoo Element Ace: Übertragen vou Routen klappt nicht'
categories = [ 'fahrrad' ]
tags = [ 'routenplanung', 'wahoo' ]
+++

<!--Wahoo Element Ace: Übertragen vou Routen klappt nicht-->
<!--======================================-->

Meine geplanten Touren kann ich zwar problemlos in die
Wahoo-App importieren, das Übertragen an meinen Wahoo-ACE
klappt aber nicht.

<!-- more -->

Details - Mai 2025
------------------

Hier mehr Details zum Problem:

- Route planen in [https://bikerouter.de](https://bikerouter.de)
- Route exportieren: [br-300-00.gpx](br-300-00.gpx)
- Route importieren in die Wahoo App:
  [wahoo-app.png](wahoo-app.png) und [routen-liste.png](routen-liste.png)
- Wahoo Element Ace einschalten
- Nach ein paar Minuten erscheint: “Synchronisierung im Gange” -> abwarten
- Im ACE erscheint zeitweise das Telefon-Piktogramm,
  zeitweise auch WIFI, zeitweise beides
- In der Wahoo App: WIFI für ACE aktivieren
- In der Wahoo App: Route anwählen
- In der Wahoo App: "An ELEMNT senden" anwählen -> nichts passiert
  - [senden.png](senden.png)
- Auf dem Wahoo Element ACE erscheinen keinerlei Routen
  - [keine-routen.png](keine-routen.png)

Juni 2025
---------

Im Juni 2025 hat sich die Situation verbessert.
Die Übertragung klappt nun. Einzig die Routen-Vorschau
fehlt:

![Routen ohne Vorschau](wahoo-app-ohne-vorschau.jpg)

Vergleich Kopfzeilen
--------------------

### Rohdateien

bikerouter.de:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!-- track-length = 66312 filtered ascend = 495 plain-ascend = 15 cost=75512 energy=0.4kwh time=3h 37m 37s -->
<gpx 
 xmlns="http://www.topografix.com/GPX/1/1" 
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
 xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd" 
 version="1.1" 
 creator="bikerouter.de 2025.45">
 <trk>
  <name>Kornwestheim - 66,3 km, 495 hm</name>
  <link href="https://bikerouter.de/#map=14/48.8617/9.1327/osm-mapnik-german_style,Waymarked_Trails-Cycling&amp;lonlats=9.182458,48.870317;9.131003,48.95027;9.140616,48.998154;9.150827,49.0088;9.11247,49.014376;9.021516,48.998516;9.006242,48.957488;9.055223,48.940076;9.053231,48.915696;9.072796,48.902039;9.070309,48.879643;9.087213,48.858915;9.097425,48.865072;9.167445,48.868179&amp;profile=trekking">
   <text>bikerouter.de</text>
  </link>
  <trkseg>
   <trkpt lat="48.870304" lon="9.182487"><ele>308.5</ele></trkpt>
```

garminconnect:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<gpx creator="Garmin Connect" version="1.1"
  xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/11.xsd"
  xmlns:ns3="http://www.garmin.com/xmlschemas/TrackPointExtension/v1"
  xmlns="http://www.topografix.com/GPX/1/1"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns2="http://www.garmin.com/xmlschemas/GpxExtensions/v3">
  <metadata>
    <name>Kornwestheim - 66,3 km, 495 hm</name>
    <link href="connect.garmin.com">
      <text>Garmin Connect</text>
    </link>
    <time>2025-06-25T16:51:52.000Z</time>
  </metadata>
  <trk>
    <name>Kornwestheim - 66,3 km, 495 hm</name>
    <trkseg>
      <trkpt lat="48.87030397541821" lon="9.182486990466714">
        <ele>309.52</ele>
        <time>2025-06-25T16:51:52.000Z</time>
      </trkpt>
```

### Formatiert

bikerouter.de:

```xml
<gpx xmlns="http://www.topografix.com/GPX/1/1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd" version="1.1" creator="bikerouter.de 2025.45">
  <trk>
    <name>Kornwestheim - 66,3 km, 495 hm</name>
    <link href="https://bikerouter.de/#map=14/48.8617/9.1327/osm-mapnik-german_style,Waymarked_Trails-Cycling&lonlats=9.182458,48.870317;9.131003,48.95027;9.140616,48.998154;9.150827,49.0088;9.11247,49.014376;9.021516,48.998516;9.006242,48.957488;9.055223,48.940076;9.053231,48.915696;9.072796,48.902039;9.070309,48.879643;9.087213,48.858915;9.097425,48.865072;9.167445,48.868179&profile=trekking">
      <text>bikerouter.de</text>
    </link>
    <trkseg>
      <trkpt lat="48.870304" lon="9.182487">
      <ele>308.5</ele>
    </trkpt>
```

garminconnect:

```xml
<gpx xmlns:ns3="http://www.garmin.com/xmlschemas/TrackPointExtension/v1" xmlns="http://www.topografix.com/GPX/1/1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns2="http://www.garmin.com/xmlschemas/GpxExtensions/v3" creator="Garmin Connect" version="1.1" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/11.xsd">
  <metadata>
    <name>Kornwestheim - 66,3 km, 495 hm</name>
    <link href="connect.garmin.com">
      <text>Garmin Connect</text>
    </link>
    <time>2025-06-25T16:51:52.000Z</time>
  </metadata>
  <trk>
    <name>Kornwestheim - 66,3 km, 495 hm</name>
    <trkseg>
      <trkpt lat="48.87030397541821" lon="9.182486990466714">
        <ele>309.52</ele>
        <time>2025-06-25T16:51:52.000Z</time>
      </trkpt>
```

Tests
-----

- Original-Track von bikerouter.de: [br-300-00.gpx](br-300-00.gpx)
- Ohne "link" bei "trk": [br-300-01.gpx](br-300-01.gpx) -> damit klappt's

Hier die Unterschiede:

```diff
--- br-300-00.gpx	2025-06-27 20:14:11.700102852 +0200
+++ br-300-01.gpx	2025-06-27 20:14:11.702102866 +0200
@@ -8,9 +8,6 @@
  creator="bikerouter.de 2025.45">
  <trk>
   <name>Kornwestheim -&gt; Tamm - 302,8 km, 734 hm</name>
-  <link href="https://bikerouter.de/#map=15/48.9270/9.1624/osm-mapnik-german_style,Waymarked_Trails-Cycling&amp;lonlats=9.185763,48.868796;8.592838,49.124742;8.376726,49.228749;8.436111,49.266606;8.412426,49.548609;8.470781,49.523667;8.557645,49.473829;8.62853,49.443941;8.670165,49.411899;8.692649,49.413629;8.79565,49.397699;8.822168,49.394153;8.850959,49.394739;8.920023,49.439144;8.990307,49.455542;9.040953,49.415716;9.069702,49.391991;9.087568,49.365543;9.107906,49.32368;9.152022,49.298424;9.133056,49.286282;9.156656,49.24704;9.195016,49.227211;9.207983,49.182768;9.200947,49.142582;9.152718,49.100418;9.155809,49.074476;9.149631,49.034321;9.153407,49.014689;9.140277,48.998144;9.138732,48.967347;9.138646,48.948533;9.148131,48.927264&amp;profile=trekking">
-   <text>bikerouter.de</text>
-  </link>
   <trkseg>
    <trkpt lat="48.868833" lon="9.185966"><ele>304.25</ele></trkpt>
    <trkpt lat="48.868896" lon="9.185947"><ele>304.5</ele></trkpt>
```

Links
-----

- [Wahoo Element ACE](https://de-eu.wahoofitness.com/devices/bike-computers/elemnt-ace-buy)

Versionen
---------

Getestet mit TBD

Historie
--------

- 2025-06-27: Erste Version
