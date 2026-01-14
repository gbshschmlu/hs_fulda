# Fragebogen zur GBI-Anwendung & Story

## 1. Kontext & Name
*   **Wofür steht „GBI“ eigentlich?** (Falls es kein echtes Akronym ist: Was sagen wir, wofür es steht?)
    *   *Antwort:* Grenzebach BOM Importer
*   **Wer ist der typische Nutzer?** (z.B. „Herbert, 50, Qualitätsmanager beim Lieferanten, nutzt Windows 10, ist genervt von Technik“ oder „Junger Vertriebler, muss es schnell nebenbei machen“)
    *   *Antwort:* Gute frage. Das füllt Personal bei dem jeweiligem Lieferanten aus. In der Regel sind das Mitarbeiter im Qualitätsmanagement. Alter und technisches Verständnis variiert stark.

## 2. Der alte Workflow (Das Problem)
*   **Wie haben die Lieferanten das FRÜHER gemacht?** (Excel-Listen? Word? Händisch E-Mails getippt?)
    *   *Antwort:* Wir haben von ihnen Excel listen oder PDFs zu den Anlagen bekommen und mussten diese dann manuell in unser System einpflegen. Dem Kunden der unsere Anlagen kauft mussten wir dann zum einem Teil unsere eigene Dokumenation liefern und zum anderen Teil die Dokumentation des Lieferanten, was dadurch nicht einheitlich war.
*   **Was waren die schlimmsten Fehler/Nerv-Faktoren?** (z.B. „Haben ständig vergessen, die Zeichnung anzuhängen“, „Haben Text in Zahlenfelder geschrieben“, „E-Mail war zu groß und kam zurück“)
    *   *Antwort:* Man musste sich oft wieder beim Lieferanten melden, weil Daten gefehlt haben. Darüber hinaus hat das portieren in unser System (Windchill) sehr viel Zeit in Anspruch genommen, weil die Daten nicht im richtigen Format vorlagen oder nicht unseren Normen entsprochen haben.
*   **Was war die Folge für euch/das Unternehmen?** (Muss man nachtelefonieren? Daten händisch abtippen?)
    *   *Antwort:* Daten Manuell und Maschinell in unser System einpflegen. Dadurch sind oft Fehler entstanden, die dann später zu Problemen geführt haben. Für unsere Kunden war es auch nicht optimal, weil die Dokumentation uneinheitlich war und teilweise Informationen gefehlt haben.

## 3. Die GBI-App (Die Lösung)
*   **Wie fühlt sich die App an?** (Ist es ein Schritt-für-Schritt-Wizard? Ein One-Page-Dashboard? Wie modern sieht es aus?)
    *   *Antwort:* Die App erlaubt es einem PSP Elemente anzulegen mit vorgefertigen definition und richtlinien aus unserem windchill system. Unter jedem PSP erstellt man dann teile, wartungslisten und wartungschritte plus welche materialien, welche art von personal benötigt wird etc über unsere vordefinierten typen und kann das ganze dann am ende exportieren, was dann als zip datei per email zu uns kommt, welche dann perfekt ausgelesen werden kann
*   **Das „Killer-Feature“ (Validierung):** (Was passiert, wenn der Nutzer Unsinn eingibt? Werden Felder rot? Gibt es Fehlermeldungen? Kann er erst exportieren, wenn alles grün ist?)
    *   *Antwort:* Meist kann man schon keine fehler machen weil diese felder mit einem vordefiniertem select auszuwähölen sind. in texteingabe feldern wird lose geprüft ob das sinn ergibt und gewarnt vor dem exportieren (und am rand steht auch immer ein icon zum aktuellen PSP ob es gültig ist).
*   **Der Output:** (Was genau purzelt am Ende raus? Ein verschlüsseltes ZIP? Ein JSON? Wohin wird es geschickt?)
    *   *Antwort:*Es kommt ne zip raus die per email an uns geschickt wird. in der zip sind dann die ganzen daten in einer json datei plus angehängte zeichnungen im pdf format.

## 4. Technik & Vergleich (Für den Aha-Effekt)
*   **Größenvergleich:**
    *   Größe der jetzigen Tauri-App (ca.): Der Installer ist 194.274kb und die installierte .exe ist 2kb
    *   Geschätzte Größe, wenn es Electron wäre (ca.): (Kann nur schätzen da nicht genau getestet) ca. 50-80mn installer und 120-200mb installiert
*   **Das Admin-Problem:** (Gab es mal eine Situation, wo ein Lieferant Software nicht installieren durfte? Warum ist der „Portable Mode“ / NSIS Installer hier so wichtig?)
    *   *Antwort:* Wir haben generell die erfahrung wenn wir software an unsere Kunden (NICHT Lieferanten, das ist das erste mal) verteilen, dass diese aus sicherheitsgründen keine software installieren dürfen die admin rechte benötigt. Daher ist es wichtig, dass die software entweder portabel ist oder ohne admin rechte installiert werden kann.
*   **Offline-Faktor:** (Muss die App komplett offline funktionieren? Warum?)
    *   *Antwort:* Aktuell ja, weil nicht jeder Lieferant eine stabile Internetverbindung hat. Daher ist es wichtig, dass die App auch offline funktioniert und die Daten erst beim Exportieren per Email verschickt werden.

## 5. Status Quo
*   **Wie weit seid ihr?** (Wird es schon produktiv genutzt? Pilotphase? Oder nur interner Test?)
    *   *Antwort:* Die App ist fertig und wird als pilotphase aktuell mit einem Deutschen Lieferanten getestet.
    * #

Nochmal über unser unternhemen:
Wir sind Grenzebach BSH und produzieren Industrieanlange für die Herstellung von Gipskartonplatten (Handling, Schere, Stapler, Trockner -> Hauptprodukt) und dinge für Holzfuniere.
