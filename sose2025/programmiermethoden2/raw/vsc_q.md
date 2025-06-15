# Fragen und Antworten zu Versionskontrollsystemen

## Abschnitt 4.1: Eingesetzte Versionskontrollsysteme und Workflows

### Kernwerkzeuge:
1. **Git und GitHub sind als Kernwerkzeuge genannt. Gibt es andere VCS-bezogene Tools, die regelmäßig im Einsatz sind (z.B. spezielle Git-Clients wie Sourcetree, GitKraken, Diff-Tools jenseits der Standard-GitHub-Ansicht etc.)?**
   
   *Antwort:* Ne, nur das was die ide mitliefert (jetbrains / vscode)

2. **Wie gut ist das allgemeine Verständnis und die Akzeptanz von Git und den GitHub-spezifischen Funktionen (wie Actions, Pull Requests) im Team? Gibt es hier Einarbeitungsbedarf oder fühlen sich alle sicher im Umgang?**
   
   *Antwort:* Wird alles so wie vorgesehen vom team genutzt.

### Projekterstellung und Setup:
1. **Der Ablauf für neue Projekte (Git Template herunterladen, Setup-Skript ausführen) klingt sehr standardisiert. Funktioniert dieser Prozess in der Praxis reibungslos und konsistent? Spart er tatsächlich Zeit bei der initialen Einrichtung?**
   
   *Antwort:* Er funktionert ohne probleme

2. **Was genau beinhaltet die "Generierung der Git-Umgebung" durch das Template/Setup-Skript? (z.B. vordefinierte Branch-Struktur, Hooks, Konfigurationsdateien?)**
   
   *Antwort:* Vorgefgertigte readme, branches, gitignore, license und halt das git repo mit rechten etc

### Branching-Modell und Tagging:
1. **Das Branching-Modell (`develop` für Entwicklung, `vx.x.x` für Releases, `GBV-xxx` für Jira-Tickets) – ist dieser Workflow allen im Team klar und wird er konsequent eingehalten? Gibt es Abweichungen oder "inoffizielle" Branch-Namen?**
   
   *Antwort:* Ja es ist alels klar und wird eingehalten.

2. **Wie genau werden die `vx.x.x` Release-Tags erstellt und verwendet? Ist das ein manueller Prozess oder Teil der CD-Pipeline?**
   
   *Antwort:* Die vx.x.x tags werden manuell gesetztt aber ci/cd prüft diese auf validität und erstellt dann den release tag

### Pull Requests (PRs):
1. **Der PR-Prozess (Review durch eine Person, Merge in `develop`) – Ist dieser Prozess klar definiert und wird er immer eingehalten? Gibt es Ausnahmen?**
   
   *Antwort:* Ja, der Prozess ist klar und wird eingehalten.

2. **Wer initiiert PRs? Wer ist typischerweise der Reviewer?**
   
   *Antwort:* PRs werden von den Entwicklern initiiert, die an dem Feature arbeiten. Der Reviewer ist meist ein Kollege aus dem Team, der sich mit dem Feature auskennt oder es implementiert hat.

### Continuous Integration (CI) mit GitHub Actions:
1. **Die CI-Pipeline auf `develop` (Infos ziehen, README aktualisieren, Linting, Security Check, Tests, Doku-Generierung mit `pdoc`) – Laufen diese Actions zuverlässig und sind sie schnell genug, oder gibt es oft Wartezeiten oder Fehlschläge bei bestimmten Schritten?**
   
   *Antwort:* Es läuft alles gut - Manche beschweren sich nur über die strengen linting-Regeln, aber die sind ja auch so gewollt.

2. **Wie detailliert sind die Rückmeldungen der CI-Pipeline im Fehlerfall? Helfen sie, Probleme schnell zu identifizieren?**
   
   *Antwort:* Die probleme sind oft meist gefunden in anderen fällen muss sich der Entrwickler der Pipeline selbst kümmern und schauen, was schief gelaufen ist (In dem Fall ich)

### Continuous Delivery/Deployment (CD) mit GitHub Actions:
1. **Die CD-Pipeline auf `develop` (Deployment auf internen Server, Release-Tag erstellen, Deployment auf internen PyPi Server) – Funktioniert dieser Prozess zuverlässig?**
   
   *Antwort:* Ja

2. **Wie ist der interne PyPi-Server in den Gesamtprozess eingebunden und welchen Zweck erfüllt er genau?**
   
   *Antwort:* Er wird durch ci/cd nach einem release benachrichtigt und aktualisiert sich dann selbst mit dem neuen release. Er dient als zusätzlichen host damit wir nicht über github selbst gehen müssen, um requirements zu installieren.

### Jira-Integration:
1. **Jira wird als Projektmanagement-Tool genannt, und Branches werden nach Jira-Tickets benannt (`GBV-xxx`). Wie gut funktioniert diese Verknüpfung in der Praxis? Hilft sie bei der Nachverfolgbarkeit von Änderungen zu Tickets? Gibt es eine automatisierte Verknüpfung (z.B. Kommentare in GitHub aktualisieren Jira-Tickets oder umgekehrt)?**
   
   *Antwort:* Ja, es funktioniert gut. Die Branches sind klar benannt und helfen bei der Nachverfolgung. Es gibt keine automatisierte Verknüpfung, aber der reviewer sieht ja im PR welches ticket und es wird ja bescheid gegeben, sobald ein PR erstellt wird, sodass der Kollege das Ticket auch sieht und ggf. kommentieren kann.

## Abschnitt 4.2: Stärken und Schwächen der aktuellen Prozesse (VCS)

### Stärken:

1. **Git/GitHub als Basis: Empfindest du die Wahl von Git und GitHub als Plattform grundsätzlich als eine Stärke? Welche Vorteile siehst du darin für GBSH (z.B. Verbreitung, Community, Funktionsumfang)?**
   
   *Antwort:* VSC ist auf github mega. ci/cd mit eigenem runner in der firma ist mega und kostet nichts. Die integration in die IDEs ist auch super

2. **Standardisierter Projektstart: Ist das Git-Template und das Setup-Skript eine echte Erleichterung und sorgt es für Konsistenz, die positiv hervorzuheben ist?**
   
   *Antwort:* Ja, es ist eine echte Erleichterung. Es spart Zeit und sorgt dafür, dass alle Projekte von Anfang an die gleiche Struktur haben. Jedoch aktuell nur für Python-Projekte.

3. **Branching-Modell: Siehst du das aktuelle Branching-Modell (`develop`, `vx.x.x`, `GBV-xxx`) als eine Stärke? Ermöglicht es eine klare Trennung der Arbeiten und ein stabiles Release-Management?**
   
   *Antwort:* Ja, das Modell ist klar und ermöglicht eine gute Trennung zwischen Entwicklung und Releases. Es hilft, die Arbeit an Features zu organisieren und gleichzeitig den `develop`-Branch stabil zu halten.

4. **Automatisierung durch GitHub Actions (CI/CD):**
   
   **Welche Aspekte der CI/CD-Pipeline empfindest du als besonders hilfreich oder als klare Stärke für den Entwicklungsprozess (z.B. frühes Feedback durch Tests, automatische Doku-Generierung, zuverlässige Deployments)?**
   
   *Antwort:* Die CI/CD-Pipeline ist sehr hilfreich, da sie automatisierte Tests und Linting durchführt, was die Code-Qualität erhöht. Die automatische Doku-Generierung ist auch ein großer Pluspunkt, da sie sicherstellt, dass die Dokumentation immer aktuell ist.
   
   **Die automatische Aktualisierung der READMEs (Infos, Badges) – ist das ein spürbarer Vorteil für die Transparenz?**
   
   *Antwort:* Ja, die automatische Aktualisierung der READMEs ist ein großer Vorteil. Es spart Zeit und stellt sicher, dass alle wichtigen Informationen immer auf dem neuesten Stand sind. Vor allem da jeder Entwickler die Badges sieht und darauf achtet, dass alles "grün" ist.

5. **Pull Request und Code Review Prozess: Auch wenn es nur eine Person ist – siehst du den Zwang zum PR und Review prinzipiell als eine Stärke zur Qualitätssicherung?**
   
   *Antwort:* Ja, der PR-Prozess ist eine klare Stärke. Er fördert die Code-Qualität und ermöglicht es, dass Änderungen von einem anderen Entwickler überprüft werden, bevor sie in den `develop`-Branch gemerged werden. Das hilft, Fehler frühzeitig zu erkennen und zu beheben.

6. **Jira-Ticket-Branching: Hilft die Benennung der Branches nach Jira-Tickets maßgeblich bei der Organisation und Nachverfolgung?**
   
   *Antwort:* Jein. Meist hilft es da man dann weiß worum es geht aber einzelheiten erfährt man nur vom entwickler selbst

7. **Allgemein: Gibt es sonstige Aspekte im Umgang mit der Versionskontrolle, die du oder das Team als besonders positiv oder effizient empfindet? Fühlen sich die Entwickler durch die VCS-Prozesse gut unterstützt?**
   
   *Antwort:* Ja, die Entwickler fühlen sich durch die VCS-Prozesse gut unterstützt. Die klare Struktur und die Automatisierung der Prozesse helfen, den Fokus auf die eigentliche Entwicklung zu legen, ohne sich um die Infrastruktur kümmern zu müssen. Auch die Integration in die IDEs ist sehr hilfreich.
   Nur der Entwickler der Pipeline muss sich um die Infrastruktur kümmern, da er die GitHub Actions konfiguriert und wartet. Aber das ist auch okay, da er dafür zuständig ist und es gut funktioniert.

### Schwächen:

1. **Git/GitHub Nutzung: Gibt es wiederkehrende Probleme im Umgang mit Git selbst (z.B. komplexe Merge-Konflikte, falsche Verwendung von `rebase` vs. `merge`, große Repositories, die langsam werden)?**
   
   *Antwort:* Nein eigentlich nicht, außer bei riesen Merges, die dann auch mal länger dauern können. Aber das ist eher selten und wird in der Regel gut gelöst.

2. **Branching-Modell:**
   
   **Führt das aktuelle Modell manchmal zu Verwirrung, unnötig vielen Branches oder aufwendigen Merges?**
   
   **Bleiben `GBV-xxx` Feature-Branches manchmal sehr lange offen und weichen stark vom `develop`-Branch ab, was zu schwierigen Merges führt?**
   
   *Antwort:* Nein, das Modell ist klar und führt nicht zu Verwirrung. Die `GBV-xxx` Branches werden in der Regel zeitnah gemerged, sodass sie nicht lange offen bleiben. Wenn doch, dann wird das Problem schnell erkannt und gelöst.

3. **Automatisierung durch GitHub Actions (CI/CD):**
   
   **Wo siehst du Schwächen oder Frustrationspunkte in den CI/CD-Prozessen? (z.B. komplexe Konfiguration der Actions, schwer zu debuggende Fehler in der Pipeline, langsame Ausführungszeiten bestimmter Schritte, "flaky" Tests, die die Pipeline unnötig blockieren?)**
   
   *Antwort:* Es läuft alles gut bis es nicht mehr gut läuft - Debuggen ist scheiße aber der Pipeline Entwickler (ich) kümmert sich meist schnell darum. Tests könntent schneller laufen indem man workflows mehr parallelisiert, dafür fehlt aber die Zeit.
   
   **Ist die Doku-Generierung via `pdoc` immer zuverlässig und liefert sie das gewünschte Ergebnis?**
   
   *Antwort:* Ja, die Doku-Generierung via `pdoc` ist zuverlässig und liefert in der Regel das gewünschte Ergebnis.

4. **Pull Request und Code Review Prozess:**
   
   **Reicht ein Review durch nur *eine* Person deiner Meinung nach immer aus, um eine hohe Code-Qualität sicherzustellen? Gibt es Bedenken bezüglich "Betriebsblindheit" oder unterschiedlicher Erfahrungslevel der Reviewer?**
   
   *Antwort:* Ja, ein Review durch eine Person reicht in der Regel aus, da die Entwickler gut geschult sind und die Qualität hoch ist. Es gibt aber auch Fälle, wo mehrere Reviews sinnvoll wären, z.B. bei kritischen Änderungen.
   
   **Wird der Review-Prozess manchmal als Flaschenhals empfunden?**
   
   *Antwort:* Nein, der Review-Prozess wird nicht als Flaschenhals empfunden. Die Entwickler sind schnell und effizient im Reviewen.
   
   **Gibt es klare Richtlinien oder Checklisten für Code-Reviews, oder hängt die Qualität stark vom jeweiligen Reviewer ab?**
   
   *Antwort:* Es gibt keine formalen Richtlinien oder Checklisten für Code-Reviews. Es gilt nur: Der Workflow (tests etc) darf nicht failen

5. **Commit-Hygiene: Wie ist die Qualität der Commit-Nachrichten im Team? Sind sie meist aussagekräftig und atomar, oder oft vage, zu umfangreich oder werden Commits zu selten gemacht?**
   
   *Antwort:* Solala - Es gibt keine formalen Regeln für Commit-Nachrichten, aber die meisten Entwickler bemühen sich um aussagekräftige Nachrichten. Es gibt aber auch Fälle, wo die Nachrichten zu vage sind oder zu viele Änderungen in einem Commit zusammengefasst werden.

6. **Release-Prozess (`vx.x.x` Tags, PyPi Deployment): Gibt es hier manuelle Schritte, die fehleranfällig sind oder den Prozess verlangsamen? Ist immer klar, wann und wie ein Release-Tag gesetzt wird?**
   
   *Antwort:* Nein, der Release-Prozess ist klar definiert und funktioniert gut. Es gibt keine manuellen Schritte, die fehleranfällig sind. Der Prozess ist automatisiert und läuft reibungslos.

7. **Jira-Integration: Gibt es Reibungspunkte bei der Verknüpfung oder dem Informationsfluss zwischen Jira und GitHub?**
   
   *Antwort:* Naja, tote links erkennen, tickets automatisch schließen, wenn PRs gemerged werden etc. Das wäre schon nice to have, aber aktuell gibt es keine automatisierte Verknüpfung

8. **Allgemein: Gibt es "ungeschriebene Gesetze", Workarounds oder Frustrationen im Umgang mit dem VCS, die nicht offiziell adressiert werden, aber den Alltag erschweren? Werden bestimmte Git-Features, die nützlich sein könnten (z.B. `git bisect`, interaktives Rebase für saubere Historien), kaum genutzt?**
   
   *Antwort:* Nein, es gibt keine nennenswerten Frustrationen oder Workarounds im Umgang mit dem VCS. Die Entwickler nutzen die verfügbaren Git-Features gut und es gibt keine nennenswerten Probleme mit der Nutzung von `git bisect` oder interaktivem Rebase.

## Abschnitt 4.3: Vergleich mit Branchenstandards (VCS)

1. **Branching-Modell:**
   
   **Euer Modell (`develop`, `vx.x.x`, `GBV-xxx`) – wie würdest du es im Vergleich zu Gitflow oder Trunk-Based Development einordnen? Hat es Ähnlichkeiten? Wo sind die Hauptunterschiede?**
   
   *Antwort:* Unser Modell ist eine Mischung aus Gitflow und Trunk-Based Development. Es hat die Vorteile von Gitflow (klare Trennung zwischen Entwicklung und Releases) und die Einfachheit von Trunk-Based Development (keine langen Feature-Branches).
   
   **Welche Vor- und Nachteile seht ihr in eurem Modell im direkten Vergleich zu diesen etablierten Standards?**
   
   *Antwort:* Die Vorteile sind die klare Struktur und die einfache Handhabung. Nachteile könnten sein, dass es nicht so flexibel ist wie Trunk-Based Development, da wir immer noch auf `develop` mergen müssen, bevor wir in einen Release erstellen können.

2. **Commit-Nachrichten:**
   
   **Werden bei GBSH (auch unbewusst) Prinzipien von "Conventional Commits" befolgt? Gibt es eine einheitliche Struktur für Commit-Nachrichten oder ist das eher dem einzelnen Entwickler überlassen?**
   
   *Antwort:* Nein, es gibt keine verbindlichen Regeln für Commit-Nachrichten. Die Entwickler bemühen sich zwar um aussagekräftige Nachrichten, aber es gibt keine einheitliche Struktur.
   
   **Wie groß wäre der Aufwand bzw. der Nutzen, wenn man verbindlich auf einen Standard wie Conventional Commits umsteigen würde?**
   
   *Antwort:* Der Aufwand wäre wahrscheinlich gering, da die Entwickler bereits gute Commit-Nachrichten schreiben. Der Nutzen wäre, dass die Historie klarer und verständlicher wird und ich wäre für eine vereinheitlichung offen

3. **Code Reviews:**
   
   **Branchenstandards empfehlen oft klare Kriterien für Reviews und manchmal auch Reviews durch mehr als eine Person (z.B. "Four-Eyes-Principle" zumindest für kritische Änderungen). Wie bewertest du euren Prozess mit einem Reviewer im Licht dieser Empfehlungen?**
   
   *Antwort:* Unser Prozess mit einem Reviewer ist in der Regel ausreichend, da die Entwickler gut geschult sind und die Qualität hoch ist. Für kritische Änderungen könnte es sinnvoll sein, ein "Four-Eyes-Prinzip" einzuführen, aber das ist aktuell nicht notwendig.

4. **Semantic Versioning (SemVer):**
   
   **Die `vx.x.x`-Tags deuten auf eine Form der Versionierung hin. Folgt diese Benennung (bewusst oder unbewusst) den Regeln von SemVer (MAJOR.MINOR.PATCH)? Wird die Semantik (Breaking Change, Feature, Bugfix) bei der Vergabe von Versionsnummern berücksichtigt und kommuniziert?**
   
   *Antwort:* Ja, die `vx.x.x`-Tags folgen den Regeln von SemVer. Die Entwickler sind sich der Semantik bewusst und kommunizieren Breaking Changes, Features und Bugfixes entsprechend.

5. **CI/CD-Integration:**
   
   **Wie bewertest du den Reifegrad eurer CI/CD-Integration im Vergleich zu dem, was als moderne Best Practice gilt (z.B. Testabdeckung, Geschwindigkeit der Pipelines, Automatisierungsgrad des Deployments)?**
   
   *Antwort:* Unsere CI/CD-Integration ist gut und entspricht modernen Best Practices. Die Pipelines sind schnell und zuverlässig, die Testabdeckung ist hoch und das Deployment ist automatisiert. Es gibt jedoch immer Raum für Verbesserungen, z.B. durch Parallelisierung von Tests oder Optimierung der Pipelines.

6. **Tool-Nutzung (GitHub):**
   
   **Schöpft GBSH deiner Meinung nach die Möglichkeiten von GitHub (z.B. GitHub Projects für Projektmanagement direkt in GitHub, detailliertere Nutzung von Issue-Templates, Code-Owner-Features für Reviews etc.) voll aus oder gibt es hier ungenutztes Potenzial im Vergleich zu dem, was die Plattform bietet?**
   
   *Antwort:* GBSH nutzt GitHub gut, aber es gibt sicherlich ungenutztes Potenzial. Features wie GitHub Projects oder detaillierte Issue-Templates könnten besser genutzt werden, um den Workflow zu optimieren und die Zusammenarbeit zu verbessern. Code-Owner-Features für Reviews könnten auch hilfreich sein, um die Verantwortlichkeiten klarer zu definieren.
