+++
date = '2024-12-03'
draft = false
title = 'JQ: JSON nach CSV wandeln'
categories = [ 'JQ' ]
tags = [ 'jq', 'json', 'csv' ]
+++

<!--
JQ: JSON nach CSV wandeln
=========================
-->

Hier beschreibe ich, wie man eine JSON-Datei
mit JQ in's CSV-Format wandelt.

<!--more-->

Einfache JSON-Datei
-------------------

```
[
    { "Name": "Uli", "Year": 1965 },
    { "Name": "Andrea", "Year": 1971 },
    { "Name": "Lilly", "Year": 2002 }
]
```

[simple.json](simple.json)

Einfache Wandlung mit festen Feldern
------------------------------------

```
$ jq -r '["Name","Year"],(.[]|[.Name,.Year])|@csv' <simple.json 
"Name","Year"
"Uli",1965
"Andrea",1971
"Lilly",2002
```

[simple.csv](simple.csv)

Generische Wandlung mit variablen Feldern
-----------------------------------------

```
$ jq -r '(map(keys) | add | unique) as $cols | map(. as $row | $cols | map($row[.])) as $rows | $cols, $rows[] | @csv' <simple.json
"Name","Year"
"Uli",1965
"Andrea",1971
"Lilly",2002
```

[simple.csv](simple.csv)

Multi-level JSON-Datei
----------------------

```
[
  {
    "type": "human",
    "individuals":
    [
      { "Name": "Uli", "Year": 1965 },
      { "Name": "Andrea", "Year": 1971 },
      { "Name": "Lilly", "Year": 2002 }
    ]
  },
  {
    "type": "dog",
    "individuals":
    [
      { "Name": "Rusty", "Year": 2015 },
      { "Name": "Shadow", "Year": 2001 },
      { "Name": "Copper", "Year": 2022 }
    ]
  }
]
```

[multi.json](multi.json)

Wandlung mit festen Feldern
---------------------------

```
$ jq -r '["type","Name","Year"],(.[]|.type as $type|.individuals|.[]|[$type,.Name,.Year])|@csv' <multi.json
"type","Name","Year"
"human","Uli",1965
"human","Andrea",1971
"human","Lilly",2002
"dog","Rusty",2015
"dog","Shadow",2001
"dog","Copper",2022
```

[multi.csv](multi.csv)

Historie
--------

- 2024-12-03: Erste Version
