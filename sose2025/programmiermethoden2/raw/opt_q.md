# Fragen und Antworten zu Optimierungsvorschlägen

## Abschnitt 5.1: Handlungsempfehlungen zur Dokumentation

Basierend auf den in 3.2 und 3.3 identifizierten Schwächen und Abweichungen bei der Dokumentationspraxis:

### Zwei Systeme (Confluence/GitHub) & potenzielle Inkonsistenzen:

1. **Welche konkreten Maßnahmen könnten helfen, die Konsistenz zwischen Confluence und der GitHub-basierten
   Dokumentation zu verbessern?**

   *Antwort:* Eine API integration, die links etc prüft und richtig verknüpft. Bpsw. Wenn die confluence seite unten
   verweise auf das/die GitHub Repositorys hätte, wäre es ja schon mal ein Anfang. Auch eine Art "Linkchecker" der prüft
   ob die Links noch aktuell sind und ggf. anzeigt, dass sie nicht mehr aktuell sind.

2. **Gibt es Ideen, wie eine "Single Source of Truth" für bestimmte Informationstypen klarer definiert und durchgesetzt
   werden könnte?**

   *Antwort:* Man könnte z.B. für bestimmte Informationstypen (wie API-Dokumentation) festlegen, dass diese
   ausschließlich in GitHub gepflegt werden, während Confluence für andere Arten von Dokumentation (wie
   Prozessbeschreibungen) genutzt wird. Eine klare trennung der Verantwortlichkeiten und Inhalte könnte helfen

3. **Wäre eine stärkere Verlagerung hin zu einem umfassenderen "Docs-as-Code"-Ansatz (z.B. mehr Inhalte als Markdown
   direkt im Code-Repository) eine Lösung? Welche Vor- und Nachteile siehst du dabei für GBSH?**

   *Antwort:* Der Ansatz wäre über unseren Aktuellen Workflow schon möglich und die idee ist sehr gut, es hat aber noch
   keiner angesprochen und die motivation für dokumentation ist wie gesagt nicht gerade hoch

4. **Welche Werkzeuge oder Prozessanpassungen könnten die Verknüpfung (ggf. auch teil-automatisiert) zwischen Confluence
   und GitHub verbessern (z.B. bessere Suchfunktionen, die beide Systeme einbeziehen, Plugins, Skripte)?**

   *Antwort:* [GitHub links for Confluence](https://marketplace.atlassian.com/apps/1216106/github-links-for-confluence) [broken-link-checker](https://github.com/stevenvachon/broken-link-checker);
   Der workflow an sich könnte auch modularer und flexibler gestaltet werden, sodass er nicht nur von einem entwickler
   gedebugged werden muss und man ihn an jedes projekt besser anpassen kann.

### Variable Qualität von Code-Kommentaren und Confluence-Inhalten:

1. **Welche Art von Richtlinien oder Checklisten für Code-Kommentare könnten sinnvoll sein? Wie könnte deren Einhaltung
   gefördert werden?**

   *Antwort:* Ich hab keine ahnung aber sowas wie die gegebene quelle klingt okay. Ich weiß nur nicht ob sich der
   aufwandt lohnt. [Coding and Comment Style](https://mitcommlab.mit.edu/broad/commkit/coding-and-comment-style/)

2. **Wie könnte die Motivation und das Verantwortungsbewusstsein für die Pflege von Confluence-Seiten im Team gestärkt
   werden? (z.B. klare Verantwortlichkeiten pro Seite/Modul, Doku-Sprints, Integration in Definition of Done?)**

   *Antwort:* Eine klare Verantwortlichkeit pro Seite/Modul könnte helfen, dass jeder weiß, wer für welche Seite
   zuständig ist.
   Darüber hinaus hätte man dann einen Ansprechpartner für Fragen und Anregungen. Doku-Sprints bzw Jira-Tickets für Doku
   könnten helfen, dass die Doku nicht in Vergessenheit gerät und regelmäßig aktualisiert wird.

3. **Welche Rolle könnten Schulungen oder Workshops zur Verbesserung der Dokumentationsfähigkeiten spielen?**

   *Antwort:* Nicht viel würde ich sagen. Kompetenz etc ist nicht das Problem, sondern die Motivation

### Fehlende Endanwenderdokumentation:

1. **Welche ersten Schritte könnten unternommen werden, um eine Basis für Endanwenderdokumentation zu schaffen?**

   *Antwort:* Wenn das Projekt so weit ist, sollte man eine Art "Endanwender-Doku" erstellen, die die wichtigsten
   Funktionen und Anwendungsfälle beschreibt. Das könnte in Form von
   einer einfachen Markdown-Datei im GitHub-Repository oder in Confluence geschehen. Wichtig wäre, dass diese Doku
   auch regelmäßig aktualisiert wird und nicht nur einmalig erstellt wird. Eine Art "FAQ" oder "Häufig gestellte Fragen"
   könnte auch hilfreich sein, um häufige Probleme oder Fragen der Endanwender zu adressieren.
   Nutzer umfragen und tests dieser doku innerhalb des teams / der firma kann helfen, diese doku zu verbessern, bis man
   diese in eine "Offizielle" Endanwenderdoku umwandelt.

2. **Welche Formate und Werkzeuge wären dafür bei GBSH denkbar? (z.B. separate Confluence-Bereiche, Integration in die
   Software selbst, FAQ-Bereiche?)**

   *Antwort:*  Confluence-Bereiche wären eine Möglichkeit da wir dies ja schon nutzen. Markdown wäre aber auch gut, da
   man dies via woprkflow in html / github doku umwandeln kann oder es bei web (oder graphischen) anwendungen direkt in
   die Software integrieren kann.

### Auffindbarkeit von Informationen:

1. **Welche Maßnahmen könnten die Navigation und das Auffinden von Informationen in Confluence und der generierten
   HTML-Doku verbessern? (z.B. bessere Verschlagwortung, einheitliche Strukturierungsprinzipien, verbesserte
   Suchkonfiguration?)**

   *Antwort:* Eine bessere Verschlagwortung und einheitliche Strukturierungsprinzipien könnten helfen. Eine geeinte
   Nomenklatur für Fachbegriffe würde aktuell am meisten helfen (Bei unserem Holz Projekt verwenden wir viele
   verschiedene Wörter für die gleiche Sache)

### Abdeckung aller Doku-Arten:

1. **Welche konkreten Schritte schlägst du vor, um sicherzustellen, dass wichtige Dokumentationsarten wie Architektur-
   oder detaillierte Testdokumentation systematischer erstellt und gepflegt werden? (z.B. feste Vorlagen, Integration in
   den Entwicklungsprozess an bestimmten Stellen?)**

   *Antwort:* Eine feste Vorlage für Architektur- und Testdokumentation würde helfen, ähnlich wie das aktuelle Template
   für Code-Projekte.

### Allgemeine Prozessverbesserungen:

1. **Wie könnte die Thematisierung der Dokumentation in Scrum-Meetings effektiver gestaltet werden, um über reine
   Testergebnisse hinauszugehen und tatsächliche Doku-Verbesserungen anzustoßen?**

   *Antwort:* Eine regelmäßige Besprechung der Dokumentationsfortschritte in den Scrum-Meetings könnte helfen, so wie
   wir den Test-Montag haben wo jeder kurz berichtet, was er getestet hat und ob es
   Probleme gab. So könnte man auch regelmäßig die Fortschritte bei der Dokumentation besprechen (Doku-Montag? bzw.
   Doku-Mittwoch?).

## Abschnitt 5.2: Optimierungsansätze für die Versionskontrolle

Basierend auf den in 4.2 und 4.3 identifizierten Schwächen und Abweichungen bei der Versionskontrollpraxis:

### Debugging von CI/CD-Pipelines, Geschwindigkeit der Tests:

1. **Welche konkreten Ansätze siehst du, um das Debugging von GitHub Actions zu erleichtern? (z.B. bessere
   Logging-Strategien, lokale Testmöglichkeiten für Actions?)**

   *Antwort:* Eine bessere Logging-Strategie könnte helfen, z.B. durch detailliertere Logs, die auch die Ausgaben der
   einzelnen Schritte beinhaltet. Lokale Testmöglichkeiten für Actions könnten auch helfen oder immerhin ein Pre-Commit
   hook der linting und tests lokal ausführt, bevor man einen Commit macht. Ein flexiblerer und modularer Workflow
   könnte auch helfen ihn besser auf die jeweiligen Projekte anzupassen und so das Debugging zu erleichtern.

2. **Hast du Ideen, wie die Testausführung beschleunigt werden könnte (z.B. durch stärkere Parallelisierung,
   Optimierung
   der Tests selbst, selektive Testausführung)?**

   *Antwort:* Wenn wir mehrere eigene Code-Runner hätten, könnten die Projekte ihre Pipelines parallel laufen lassen
   und auch ggf. die Steps parallelisieren. Alternativ könnte eventuell auch eine Art "Cache" oder Matrix für die
   Tests helfen, sodass nicht immer
   alle Tests für jedes Projekt laufen müssen, sondern nur die relevanten. Eine Optimierung der Tests selbst könnte
   auch helfen, z.B. durch das Entfernen von redundanten Tests oder das Zusammenfassen von ähnlichen Tests.

### Gelegentlich als streng empfundene Linting-Regeln:

1. **Gibt es hier einen Mittelweg? Könnten die Regeln flexibler gestaltet oder besser im Team kommuniziert und begründet
   werden, um die Akzeptanz zu erhöhen?**

   *Antwort:* Naja ein regel die sehr gehasst wird ist, dass in python alle funktionen einen return-typehint haben
   müssen und alle "öffentlichen" funktionen und klassen eine docstring haben müssen. Wie man die Akzeptanz erhöhen kann
   weiß ich nicht

### Code-Reviews:

1. **Welche konkreten Vorschläge hast du, um den Review-Prozess zu stärken? (z.B. Einführung von optionalen oder
   verpflichtenden Zweit-Reviewern für bestimmte Code-Teile, Erstellung einer einfachen Review-Checkliste mit Fokus auf
   kritische Aspekte?)**

   *Antwort:* Ein Extra Workflow-Check für Code-Reviews könnte helfen, der dann auch eine Art "Review-Checkliste"
   enthält, die der Reviewer abhaken muss, bevor er den PR freigibt.
   Man könnte auch pro Grenzebach Projekt (Aka. Alle github repos/projekte die zu einem Gesamten Projekt gehören) eine
   Checkliste auf confluence erstellen, die dann für alle PRs in diesem Projekt gilt.

2. **Wie könnte die Qualität und Konsistenz von Reviews verbessert werden?**

   *Antwort:* Ich hab keine Ahnung, ich glaube das ist ein generelles Problem, das nicht nur bei uns besteht.

### Qualität von Commit-Nachrichten:

1. **Schlägst du die verbindliche Einführung eines Standards wie "Conventional Commits" vor? Wie könnte das im Team
   eingeführt und unterstützt werden (z.B. durch Tools wie Commitizen, Schulungen)?**

   *Antwort:* Ja, ich denke das wäre eine gute Idee. Unsere IDEs unterstützen sowas ja schon über plugins. Schulungen
   wären dadurch hinfällig.

2. **Welchen konkreten Nutzen versprichst du dir davon für GBSH?**

   *Antwort:* Das würde die Nachvollziehbarkeit von Änderungen erhöhen und es einfacher machen, den Überblick über die
   Zeit zu behalten.
   Maschinelle auswertung von Commits wäre auch einfacher und man kann Grafiken etc. generieren, die den Verlauf
   darstellen.

### Fehlende tiefere Jira-GitHub-Integration:

1. **Welche spezifischen Automatisierungen (z.B. automatische Ticket-Updates, Verlinkung von Commits/PRs in Jira) wären
   am nützlichsten und mit vertretbarem Aufwand umsetzbar? Gibt es dafür ggf. vorhandene GitHub Apps oder Actions?**

   *Antwort:* Eine automatische Verlinkung von Commits/PRs in Jira wäre sehr nützlich. Wird ein PR erstellt, könnte man
   das ticket automatisch auf "In Progress" setzen und wenn der PR geschlossen wird, auf "Done".

### Nutzung von GitHub-Features:

1. **Welche der in 4.3 genannten, potenziell ungenutzten GitHub-Features (GitHub Projects, Issue Templates, Code Owners
   etc.) hältst du für GBSH für besonders relevant und empfehlenswert zur Einführung?**

   *Antwort:* Github wiki. Mehr nicht. Dadurch wäre keine eigene html doku seite mehr nötig und es wäre zentral am
   selben Ort wie der source code.

### Standardisierung von Templates:

1. **Das Git-Template existiert aktuell primär für Python-Projekte. Schlägst du vor, ähnliche Templates auch für andere
   Projekttypen/Programmiersprachen zu entwickeln, die bei GBSH zum Einsatz kommen?**

   *Antwort:* Aktuell haben wir nur Python-Projekte, aber wenn wir mal andere Projekte haben, wäre es sinnvoll, auch
   dafür Templates zu erstellen. Das würde die Konsistenz erhöhen und die Einarbeitung neuer Entwickler erleichtern.

## Abschnitt 5.3: Integrierte Implementierungsstrategie

Hier geht es darum, wie die vorgeschlagenen Änderungen tatsächlich umgesetzt werden könnten.

### Priorisierung:

1. **Welche der von dir vorgeschlagenen Optimierungen (sowohl für Doku als auch für VCS) haben deiner Meinung nach die
   höchste Priorität (größter Nutzen oder dringendste Notwendigkeit)?**

   *Antwort:*
    - Konsistenz der Commits ist nicht am nötigsten, aber am einfachsten und schnellsten umzusetzen ("Conventional
      Commits").
    - Mehr Code-Runner für parallele Pipelines wäre sehr nützlich, aber auch aufwändig. Daher wäre ein besserer
      Workflow und eine bessere Logging-Strategie für GitHub Actions am sinnvollsten.
    - Die erhöhung der Wichtigkeit der Dokumentation durch Doku-Sprint bzw ansprechen in den Scrum-Meetings wäre
      schon mal
      ein anfang. Auch das Abmahnen von Entwicklern, die keine Doku schreiben, wäre sinnvoll.
    - Eine bessere konsistenz zwischen Confluence und GitHub wäre sehr nützlich, aber auch aufwändig. Daher wäre
      eine
      bessere Verschlagwortung und einheitliche Strukturierungsprinzipien ein guter Anfang.
    - Eine Endanwender doku ist aktuell komplett unnötig, da sich die projekte ohne noch in der Entwicklung befinden
      und
      es keine Endanwender gibt. Daher wäre dies erstmal nicht nötig.
    - Jira-GitHub-Integration wäre sehr nützlich, aber auch aufwändig. Das würde daher erstmal wegfallen.


2. **Welche wären vergleichsweise einfach umzusetzen ("Quick Wins")?**

   *Antwort:*
    - Die Einführung von "Conventional Commits" wäre ein Quick Win, da es einfach umzusetzen ist und sofortige
      Vorteile bringt.
    - Eine bessere Nomenklatur und einheitliche Strukturierungsprinzipien in Confluence und GitHub wäre
      ebenfalls ein Quick Win, da es einfach umzusetzen ist und sofortige Vorteile bringt.
    - Die Einführung von Doku-Sprints bzw. das Ansprechen der Dokumentation in den Scrum-Meetings wäre ein Quick Win,
      da es einfach umzusetzen ist und sofortige Vorteile bringt.

### Vorgehensweise der Einführung:

1. **Schlägst du eine schrittweise Einführung (z.B. Pilotprojekte, Fokus auf einzelne Aspekte) oder einen
   umfassenderen "Big Bang"-Ansatz vor? Warum?**

   *Antwort:* Ich würde es erstmal schrittweise bei 1-2 Projekten einführen und schauen, wie es läuft. Wenn es
   gut läuft, würde ich es auf alle Projekte ausweiten. Ein "Big Bang"-Ansatz wäre zu riskant, da es zu viele
   Änderungen auf einmal geben würde und es bei fehlern (in bpsw. des Workflows) zu großen Problemen kommen könnte.

2. **Wie könnte man das Team am besten in den Veränderungsprozess einbinden und Akzeptanz schaffen?**

   *Antwort:* Das Team sollte von Anfang an in den Veränderungsprozess einbezogen werden, z.B. durch regelmäßige
   updates und Feedback in den "Daily" Meetings Montags und Mittwochs.

### Verantwortlichkeiten:

1. **Wer sollte für die Umsetzung der einzelnen Maßnahmen verantwortlich sein? (z.B. dedizierte Personen, das Team als
   Ganzes, spezielle Arbeitsgruppen?)**

   *Antwort:* Das Team sollte als Ganzes für die Planung der Maßnahmen verantwortlich sein. Die umsetzung selbst kann
   dann an die am besten geingneten Personen delegiert werden.

### Schulung und Unterstützung:

1. **Welche Art von Schulungen oder Support wären notwendig, um die neuen Prozesse und Werkzeuge erfolgreich
   einzuführen? (z.B. interne Workshops, externe Schulungen, Erstellung von Anleitungen?)**

   *Antwort:* Interne Workshops wären sinnvoll, um die neuen Prozesse und Werkzeuge vorzustellen und zu erklären.
   Anleitung für Workflow etc. wären auch gut. Externe Schulungen wären ncith wirklich nötig-

### Messung des Erfolgs:

1. **Wie könnte der Erfolg der umgesetzten Optimierungsmaßnahmen gemessen und bewertet werden? (z.B. durch Umfragen im
   Team, Analyse von Fehlerquoten, Zeitersparnis, verbesserte Doku-Qualität – auch wenn letzteres schwer messbar ist?)**

   *Antwort:* Eine Umfrage im Team könnte helfen, die Zufriedenheit mit den neuen Prozessen und Werkzeugen zu messen.
   Auch wie oft dann der Workflow aufgrund fehlender docstrings oder fehlender Doku nicht funktioniert hat.

### Zeitlicher Rahmen:

1. **Hast du eine grobe Vorstellung, welcher zeitliche Rahmen für die Umsetzung bestimmter Maßnahmen realistisch wäre (
   kurzfristig, mittelfristig, langfristig)?**

   *Antwort:* Die Einführung von "Conventional Commits" könnte kurzfristig (innerhalb von 1-2 Wochen) umgesetzt werden.
   Die Verbesserung der Konsistenz zwischen Confluence und GitHub könnte mittelfristig (innerhalb von 1-2 Monaten)
   Der Workflow für GitHub Actions könnte mittelfristig (innerhalb von 1-2 Monaten) umgesetzt werden.
   Die Atlassian integration könnte langfristig (innerhalb von 3-6 Monaten) umgesetzt werden.

### Tool-Unterstützung für die Strategie:

1. **Könnten bestimmte Projektmanagement-Tools (vielleicht sogar Jira selbst) genutzt werden, um die Umsetzung der
   Optimierungsstrategie zu planen und zu verfolgen?**

   *Antwort:* Ja, Jira könnte genutzt werden, um die Umsetzung der Optimierungsstrategie zu planen und zu verfolgen.
