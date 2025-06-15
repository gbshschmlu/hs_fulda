# Fragen und Antworten zum Fazit

## Abschnitt 6.1: Zusammenfassung der Kernerkenntnisse

Dieser Teil soll die wichtigsten Ergebnisse deiner gesamten Arbeit (Analyse und Optimierungsvorschläge) kurz und
prägnant zusammenfassen. Es ist keine detaillierte Wiederholung, sondern eine pointierte Darstellung der Highlights.

1. **Ausgangssituation (kurz): Was war die Kernaussage deiner Analyse der Dokumentationspraxis bei GBSH (Kapitel 3)? Gab
   es ein, zwei besonders hervorstechende Stärken oder Schwächen, die du hier noch einmal nennen möchtest?**

   *Antwort:* Insgesamt eine solide Praxis mit viel Potential. Schlecht finde ich vor allem die fehlende
   Standardisierung. Gut finde ich vor allem die idee hinter dem Workflow mit der Doku generierung aus dem code heraus
   mit einbindung der test, linting und security checks.

2. **Ausgangssituation VCS (kurz): Analog dazu, was war die Kernaussage deiner Evaluation der Versionskontrollpraxis bei
   GBSH (Kapitel 4)? Ein, zwei zentrale Stärken oder Schwächen?**

   *Antwort:* Insgesamt sehr solide. Sehr gut finde ich wieder den Workflow als gesamtes (linting, security, tests,
   doku, update der readme, release erstellung). Das git-template ist mega. Richtig müll finde ich die Standardisierung
   der Code commentare - Wir haben branch-namen standaardisiert also warum nicht auch commit nachrichten?

3. **Wichtigste Optimierungsvorschläge (Dokumentation): Welche 2-3 deiner Handlungsempfehlungen aus 5.1 hältst du für
   die absolut wichtigsten oder wirkungsvollsten für GBSH? (Denke an die Priorisierung aus 5.3).**

   *Antwort:*
    - Einführung eines einheitlichen Templates für Confluence-Seiten, um die Konsistenz zu erhöhen.
    - Standardisierung der Code-Kommentare, um die Lesbarkeit und Nachvollziehbarkeit zu verbessern.

4. **Wichtigste Optimierungsvorschläge (Versionskontrolle): Welche 2-3 deiner Optimierungsansätze aus 5.2 siehst du als
   besonders zentral oder vielversprechend für GBSH an?**

   *Antwort:*
    - Standardisierung der Commit-Nachrichten, um die Nachvollziehbarkeit der Änderungen zu erhöhen.
    - Bessere Workflows für die Dokumentation, tests, security checks, coverage, audits etc zu schaffen, um die Qualität
      und Konsistenz der Dokumentation und des gesamten projekts zu gewährleisten.

5. **Übergeordnete Erkenntnis: Gibt es eine übergeordnete Erkenntnis oder einen roten Faden, der sich durch deine
   gesamte Untersuchung zieht? (z.B. "Die Studie hat gezeigt, dass bei GBSH zwar gute Grundlagen vorhanden sind, aber
   eine stärkere Standardisierung und Integration der Prozesse zu deutlichen Verbesserungen führen kann.")**

   *Antwort:* Ich finde es hat sich heraus kristallisiert, dass wir eine solide Basis haben, aber die Standardisierung
   in beiden bereichen mangelhaft ist und die motivation der mitarbeiter bei der doku zu wünschen übrig lässt.

6. **Beantwortung der Forschungsfrage(n): Wie würdest du basierend auf deinen Ergebnissen die Forschungsfrage(n)
   beantworten, die du dir in der Einleitung (Abschnitt 1.3) implizit oder explizit gestellt hast? (z.B. "Wie können die
   Prozesse... optimiert werden?" -> Durch X, Y, Z. "Welche Tools und Methoden eignen sich...?" -> A, B, C unter
   Berücksichtigung von...)**

   *Antwort:* Es ging um konkrete Optimierungsvorschläge, die ich in den Kapiteln 5.1 und 5.2 gemacht habe. Ich habe
   welche gefunden die ich sehr sinnvoll finde und die ich auch umsetzen würde, wenn ich die Möglichkeit hätte.

## Abschnitt 6.2: Zukunftsausblick und persönliches Resümee

Hier geht es darum, über den Tellerrand der aktuellen Arbeit hinauszublicken und deine persönliche Erfahrung zu
reflektieren.

### Zukunftsausblick:

1. **Weiterführende Schritte bei GBSH: Welche der vorgeschlagenen, aber vielleicht als langfristig eingestuften
   Maßnahmen (z.B. tiefere Atlassian-Integration, Anschaffung mehr Runner) siehst du als
   logische nächste Schritte für GBSH, nachdem die dringenderen Punkte umgesetzt wurden?**

   *Antwort:* Anschaffung von mehr Runnern, um die CI/CD-Prozesse zu beschleunigen und die Qualitätssicherung zu
   verbessern. Dies ist am logischsten, da es die Effizienz der gesamten Entwicklungs- und Dokumentationsprozesse
   steigern würde. Die Atlassian-Integration könnte ebenfalls sinnvoll sein, aber das müsste im Team ordentlich
   diskutiert und evaluiert werden.

2. **Generelle Trends: Gibt es aktuelle oder zukünftige Trends in der Softwareentwicklung (z.B. KI-gestützte
   Dokumentationstools, Weiterentwicklung von DevOps-Praktiken, neue VCS-Features), die deiner Meinung nach die
   Dokumentations- und Versionskontrollprozesse bei GBSH (oder allgemein) in Zukunft beeinflussen könnten und die man im
   Auge behalten sollte?**

   *Antwort:*  KI-gestütze Dokumentationstools könnten die Effizienz und Konsistenz der Dokumentation erheblich
   verbessern aber auch verschlechtern, wenn sie nicht richtig eingesetzt werden, weshalb man dies im Auge behalten
   sollte. DevOps-Praktiken sind aktuell gut aber könnten durch mehr wissen und erfahrung im Team und durch neue/bessere
   tools noch weiter optimiert werden.

3. **Weitere Forschung: Siehst du Bereiche, in denen nach deiner Arbeit noch weiterer Untersuchungs- oder
   Forschungsbedarf bestehen könnte, sei es spezifisch bei GBSH oder allgemeiner zum Thema? (z.B. detaillierte
   ROI-Analyse der vorgeschlagenen Maßnahmen, Untersuchung der Akzeptanz von KI-Tools für Doku im Team etc.)**

   *Antwort:* KI-Tool wäre sicher interessant, vor allem da sie immer mehr Einzug in die Softwareentwicklung halten.

### Persönliches Resümee:

1. **Eigene Lernerfahrung: Was war für dich persönlich der größte Lerneffekt oder die wichtigste Erkenntnis während der
   Bearbeitung dieser Hausarbeit?**

   *Antwort:* Ich war mir zwar bewusst, dass die Konsistenz der dokumentation zwischen entwickler nicht gegeben ist,
   aber
   erst nach meiner recherche und analyse habe oich festgestellt, was dies für ein Problem ist und wie sehr es die
   Dokumentation beeinflusst. Ich habe auch gelernt, wie wichtig es ist, Standards zu setzen und diese konsequent
   umzusetzen, um die Qualität der Dokumentation zu verbessern. Im VSC bereich habe ich nicht viel neues gelernt. Ich
   habe nur wieder mal festgestellt, das ich den Workflow nochmal überarbeiten sollte, um debugging und modularität zu
   verbessern.

2. **Herausforderungen: Was waren die größten Herausforderungen bei der Analyse und der Erstellung der Arbeit?**

   *Antwort:* Die dokumentations praktiken vollständig zu verstehen und zu analysieren, war eine Herausforderung. Am
   schwersten war es, alles in worte zu fassen und die richtigen Prioritäten zu setzen.

3. **Ausblick auf eigene Entwicklung: Haben die Erkenntnisse aus dieser Arbeit deine Sichtweise auf Dokumentation und
   Versionskontrolle verändert oder dich für bestimmte Aspekte sensibilisiert, die du in deiner zukünftigen Tätigkeit
   als Entwickler besonders beachten möchtest?**

   *Antwort:* Ja, ich werde in Zukunft mehr Wert auf Konsistenz und Standardisierung legen, sowohl in der Dokumentation
   als auch der Versionskontrolle. Ich habe auch erkannt, wie wichtig es ist, die Dokumentation als integralen
   Bestandteil des Entwicklungsprozesses zu betrachten und nicht als nachträgliche Pflicht.
