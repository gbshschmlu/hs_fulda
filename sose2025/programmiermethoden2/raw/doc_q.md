# Fragen und Antworten zu Dokumentationspraktiken

## Abschnitt 3.2: Stärken und Schwächen der bisherigen Praxis

Basierend auf deiner Beschreibung in 3.1 und deinen Erfahrungen:

### Stärken:

#### Zweigeteilter Ansatz (Confluence/GitHub):

1. **Empfindest du die Aufgabenteilung (Confluence für Konzeptionelles, GitHub für Technisches) tatsächlich als klare Stärke? Wo siehst du die Vorteile im täglichen Arbeiten? Finden die Entwickler schnell, was sie suchen?**
   
   *Antwort:* Naja, in Confluence ist es auch modulübergreifend. Manche Dinge sind relevant für mehrere Module in einem Projekt, die je separate Repos haben. Manche Dinge passen auch einfach nicht in die Doku von einem Modul.

2. **Confluence-Vorlagen: Wie gut funktionieren diese Vorlagen in der Praxis? Führen sie wirklich zu Einheitlichkeit und erleichtern sie die Erstellung, oder werden sie manchmal als Korsett empfunden?**
   
   *Antwort:* Die Vorlagen sind nur rudimentär für Berichte etc.

3. **GitHub Actions für Doku: Wie groß ist der Nutzen der automatischen HTML-Generierung und der Status-Badges? Spart das spürbar Zeit oder erhöht es die Transparenz merklich?**
   
   *Antwort:* Sie wird aktuell kaum genutzt, wird aber immer mehr.

4. **Scrum-Meetings & Doku: Führt die Besprechung von Doku-Themen in Scrum-Meetings tatsächlich zu Verbesserungen, oder ist es eher ein formaler Punkt? Gibt es konkrete Beispiele, wo das schon mal positiv gewirkt hat?**
   
   *Antwort:* Ja schon, aber wir besprechen die Doku selbst nicht so viel und es geht meist eher um Tests. Manche Teammitglieder kümmern sich auch gar nicht um die Doku.

5. **Verlinkung GitHub -> Confluence: Funktioniert das gut? Wird es konsequent genutzt? Ist es hilfreich, um nicht zwischen den Systemen verloren zu gehen?**
   
   *Antwort:* Naja, bei manchen Sachen hilft es schon. Man klickt in einem Code-Comment auf den Link und bekommt auf Confluence eine Grafik dazu, was das macht bzw. was versucht wird zu implementieren und verlinkt evtl. noch auf andere Quellen, was sehr angenehm ist.

#### Allgemeine positive Aspekte:

1. **Gibt es Aspekte im Dokumentationsprozess, die du persönlich oder das Team als besonders effizient, hilfreich oder gut gelöst empfindet, die vielleicht noch nicht explizit genannt wurden?**
   
   *Antwort:* Die generierte Doku ist mega, wird aber wenig genutzt. Die Badges sind geil und sieht auch jeder Entwickler und es wird darauf geachtet, alle "grün" zu halten.

2. **Fühlen sich die Entwickler durch die aktuelle Dokumentationspraxis insgesamt gut unterstützt?**
   
   *Antwort:* Ja.

### Schwächen:

#### Zweigeteilter Ansatz & Synchronisation:

1. **Du hast Inkonsistenzen und Redundanzen als Gefahr genannt. Gibt es konkrete Beispiele oder typische Situationen, wo das bei GBSH auftritt? (z.B. veraltete Infos in Confluence, während die GitHub-Doku aktueller ist, oder umgekehrt?)**
   
   *Antwort:* Manchmal sind die Code-Comments veraltet und keiner aktualisiert sie. Selbiges gilt für die README oder Confluence-Seiten existieren nicht mehr.

2. **Wie wird entschieden, welche Information wo die "führende" ist? Gibt es da klare Regeln oder oft Verwirrung?**
   
   *Antwort:* Keine Regel - Confluence eher allgemein und GitHub speziell halt auf den Code.

3. **Fehlende automatisierte Verknüpfung Confluence/GitHub: Welche konkreten Nachteile oder Mehraufwände ergeben sich daraus im Alltag? (z.B. manuelles Übertragen von Infos, Suchen an zwei Orten etc.)**
   
   *Antwort:* Eine Prüfung, ob Quellen existieren und sie anständig zu verlinken wäre schön.

#### Qualität und Vollständigkeit:

1. **Code-Kommentare: Wie ist dein Gefühl zur Qualität der Code-Kommentare? Sind sie meist hilfreich oder oft oberflächlich/veraltet? Gibt es informelle "Helden", die super kommentieren, und andere, die es vernachlässigen?**
   
   *Antwort:* Code-Comments sind je nach Mitglied okay. Manche machen auch gar keine, manche richtig gute.

2. **Confluence-Pflege: Wie diszipliniert werden die Confluence-Seiten tatsächlich von den Teams aktuell gehalten? Gibt es "Karteileichen"?**
   
   *Antwort:* Confluence wird eigentlich sehr gut gepflegt.

3. **Auffindbarkeit: Wie leicht oder schwer ist es für dich/euch, spezifische Informationen zu finden, wenn man sie braucht? Musst du oft mehrere Stellen durchsuchen?**
   
   *Antwort:* Relativ easy.

4. **Abdeckung aller Doku-Arten: Dein Gefühl: Welche der in 2.1 genannten Doku-Arten (z.B. detaillierte Architekturdoku, Testdoku für Endanwender) kommen deiner Meinung nach im aktuellen Prozess zu kurz oder fehlen ganz? Warum ist das so?**
   
   *Antwort:* Endanwender fehlt komplett, der Rest ist gut bis sehr gut.

#### Allgemeine negative Aspekte/Frustrationen:

1. **Gibt es bestimmte Werkzeuge oder Prozessschritte in der Dokumentation, die du oder Kollegen als umständlich, zeitaufwendig oder ineffektiv empfinden?**
   
   *Antwort:* Manche mögen unsere Tests nicht, da wenn diese fehlschlagen, keine neue Version herausgegeben werden kann.

2. **Führt die aktuelle Dokumentationspraxis manchmal zu Missverständnissen oder Fehlern in der Entwicklung?**
   
   *Antwort:* Manchmal fehlt halt wichtige Doku und wird auf Rückfrage auch nicht hinzugefügt.

## Abschnitt 3.3: Vergleich mit Branchenstandards

Basierend auf den in Kapitel 2.3 diskutierten Standards und deinen Erfahrungen bei GBSH:

### Documentation as Code (Docs-as-Code):

1. **Du sagst, Elemente davon werden aufgegriffen. Wie tief geht das deiner Meinung nach? Ist der "Doc-Branch" mit HTML/JSON wirklich schon "Docs-as-Code" im Sinne von textbasierten, leicht reviewbaren Quellen (wie Markdown/AsciiDoc), die dann generiert werden? Oder ist der Doc-Branch eher das Ergebnis einer Generierung, die woanders passiert?**
   
   *Antwort:* Docs as Code passt. Ein Tool extrahiert Code und Kommentare für bessere Doku.

2. **Werden Änderungen an der HTML/JSON-Doku im Doc-Branch genauso einem Review (z.B. Pull Request) unterzogen wie Code-Änderungen?**
   
   *Antwort:* Sie werden automatisch aus dem develop-Branch erstellt und dürfen nicht manuell überarbeitet werden. Wenn im develop-Branch, der reviewed wird.

### Single Source of Truth:

1. **Wie stark empfindest du das Problem, dass Confluence und die GitHub-Doku potenziell zwei "Wahrheiten" darstellen könnten? Ist das ein reales Problem oder eher eine theoretische Gefahr, die durch die Verlinkung gut gemanagt wird?**
   
   *Antwort:* Dazu kann ich nichts sagen.

### Agile Dokumentation:

1. **Abgesehen von der Erwähnung in Scrum-Meetings: Wie "agil" ist die Dokumentationserstellung? Wird wirklich nur "gerade genug" dokumentiert? Orientiert sich die Doku stark an User Stories und deren Akzeptanzkriterien?**
   
   *Antwort:* Es wird manchmal zu viel, manchmal zu wenig dokumentiert. Kommt auf das Teammitglied an.

### Standardisierte Notationen (UML, BPMN etc.):

1. **Werden solche standardisierten Diagrammtypen in Confluence (oder anderswo) verwendet? Wenn ja, wie konsequent und einheitlich? Wenn nein, wird ihr Fehlen manchmal als Mangel empfunden (z.B. um komplexe Architekturen oder Prozesse zu verstehen)?**
   
   *Antwort:* Nur in Confluence; konsequent einheitlich wenn selbiger Typ.

### Qualitätssicherung der Dokumentation:

1. **Du erwähnst Proofreading. Gibt es darüber hinaus Prozesse, um die Qualität der Doku systematisch zu prüfen (z.B. auf Vollständigkeit, Korrektheit, Verständlichkeit, Zielgruppenorientierung – im Sinne der Kriterien aus der ISO/IEC/IEEE 26514, die du über styrz2022normen zitierst)?**
   
   *Antwort:* Nein.

### Tooling für technische Dokumentation:

1. **Ist der aktuelle Prozess zur Generierung der HTML-Doku aus dem Doc-Branch und den READMEs als optimal anzusehen, oder siehst du hier Verbesserungspotenzial durch andere Werkzeuge, die vielleicht eine stärkere Integration oder bessere Navigations-/Strukturierungsmöglichkeiten bieten würden (z.B. Sphinx, MkDocs etc., die direkt mit Markdown arbeiten könnten)?**
   
   *Antwort:* Es könnte noch ein ordentlicher Webserver für die HTML-Dateien gehostet werden oder man generiert einfach Markdown-Dateien und nutzt das integrierte GitHub Wiki für ein Repo.
