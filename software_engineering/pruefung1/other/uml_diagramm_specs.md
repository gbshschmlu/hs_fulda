# UML-Diagramm Spezifikationen für Musikautomat

## Skizze des Musikautomaten
### TODO: Technische Skizze erstellen
Erstelle eine detaillierte technische Skizze mit folgenden Elementen:
- (1) Großes Touchscreen-Display (ca. 21-24 Zoll) mit Benutzeroberfläche zur Songauswahl
- (2) Coin-Einwurfschlitz mit Validierungseinheit
- (3) Hochwertige Stereo-Lautsprecher
- (4) Verschließbare Service-Zugangsklappe für Wartungspersonal
- (5) Netzwerkanschluss/WLAN-Antenne
- (6) Status-LED-Anzeigen
- Zeige sowohl Frontal- als auch Seitenansicht

---

## Aktivitätsdiagramm: Songauswahl und -wiedergabe

### Zweck
Darstellung des kompletten Nutzungsprozesses von Coin-Einwurf bis zur Songwiedergabe

### Swimlanes
- **Nutzer**: Alle Benutzerinteraktionen
- **Jukebox-System**: Systemverarbeitung und -reaktionen

### Syntaktische Elemente (zu verwenden)
- **Startknoten** (gefüllter Kreis)
- **Endknoten** (gefüllter Kreis mit Ring)
- **Aktivitäten** (abgerundete Rechtecke)
- **Entscheidungsknoten** (Rauten) mit Bedingungen
- **Merge-Knoten** (Rauten zum Zusammenführen)
- **Fork/Join** (schwarze Balken für parallele Abläufe)
- **Objektknoten** (Rechtecke für Datenobjekte)
- **Kontrollflüsse** (Pfeile mit Bedingungen)

### Detaillierter Ablauf

#### Nutzer-Swimlane
1. **Coin einwerfen** (Aktivität)
2. **Songs durchsuchen** (Aktivität)
    - Navigation durch Kategorien (Genre, Künstler, Charts)
    - Suchfunktion nutzen
3. **Song auswählen** (Aktivität)
4. **[Entscheidung] Weiteren Song wählen?** (Entscheidungsknoten)
    - Ja → zurück zu "Songs durchsuchen"
    - Nein → Ende der Auswahl

#### Jukebox-System-Swimlane
1. **Coin validieren** (Aktivität)
2. **[Entscheidung] Coin gültig?** (Entscheidungsknoten)
    - Nein → **Coin zurückgeben** → **Fehlermeldung anzeigen** → Ende
    - Ja → **Auswahlmodus aktivieren**
3. **Song-Verfügbarkeit prüfen** (Aktivität)
4. **[Entscheidung] Song verfügbar und Queue nicht voll?** (Entscheidungsknoten)
    - Nein → **Fehlermeldung anzeigen** → zurück zu Nutzer-Auswahl
    - Ja → **Song zu Queue hinzufügen**
5. **Queue abarbeiten** (Aktivität mit Schleife)
    - **Fork zu parallelen Aktivitäten:**
        - **Song abspielen**
        - **Metadaten anzeigen**
        - **Status an Zentrale melden**
    - **[Entscheidung] Weitere Songs in Queue?**
6. **Zum Leerlauf zurückkehren** (Endknoten)

### Objektknoten
- **Coin** (als Input)
- **Song-Queue** (als Zwischenspeicher)
- **Ausgewählter Song** (als Output)

---

## Sequenzdiagramm: Songwiedergabe und Zentrale-Kommunikation

### Zweck
Zeitliche Darstellung der Komponenten-Interaktionen bei Songwiedergabe mit Fokus auf Zentrale-Kommunikation

### Lifelines (von links nach rechts)
1. **Nutzer** (Akteur)
2. **Jukebox-UI** (Boundary)
3. **Jukebox-Steuerung** (Control)
4. **LokaleMusikdatenbank** (Entity)
5. **Verbundenes Gerät** (External System)

### Syntaktische Elemente (zu verwenden)
- **Lifelines** mit Aktivierungsbalken
- **Synchrone Nachrichten** (Vollpfeil)
- **Asynchrone Nachrichten** (Linienpfeil)
- **Rückantworten** (gestrichelte Pfeile)
- **Selbstaufrufe** (Schleife zur eigenen Lifeline)
- **Alt-Fragment** (Alternative)
- **Opt-Fragment** (Optional)
- **Loop-Fragment** (Schleife)
- **Par-Fragment** (Parallel)

### Nachrichtensequenz

#### 1. Songauswahl-Phase
```
Nutzer -> Jukebox-UI: songAuswählen(SongID)
Jukebox-UI -> Jukebox-Steuerung: spieleSongAnfrage(SongID)
```

#### 2. Datenabfrage und Validierung
```
Jukebox-Steuerung -> LokaleMusikdatenbank: getSongStream(SongID)
LokaleMusikdatenbank --> Jukebox-Steuerung: songDatenLiefern(AudioStream, Metadaten)

[alt Lizenzvalidierung]
    Jukebox-Steuerung -> Verbundenes Gerät: validiereLizenz(SongID)
    Verbundenes Gerät --> Jukebox-Steuerung: lizenzBestätigung(Status)
    
    [opt Lizenz gültig]
        Jukebox-Steuerung -> Jukebox-Steuerung: addToQueue(SongID)
    [else]
        Jukebox-Steuerung -> Jukebox-UI: showError("Lizenz ungültig")
[else Song nicht verfügbar]
    Jukebox-Steuerung -> Jukebox-UI: showError("Song nicht verfügbar")
```

#### 3. Wiedergabe-Phase
```
[loop Queue nicht leer]
    Jukebox-Steuerung -> Jukebox-Steuerung: startAudioWiedergabe(AudioStream)
    
    par [parallele Aktivitäten]
        Jukebox-Steuerung -> Jukebox-UI: zeigeAktuellenSong(Metadaten)
        Jukebox-Steuerung -> Verbundenes Gerät: meldeSongGespielt(SongID, Zeitstempel)
    end par
    
    Verbundenes Gerät --> Jukebox-Steuerung: bestätigungEmpfang()
```

#### 4. Status-Update (Asynchron)
```
Jukebox-Steuerung ->> Verbundenes Gerät: sendeStatusUpdate(SystemHealth)
Verbundenes Gerät ->> Jukebox-Steuerung: konfigurationsUpdate(Parameter)
```

### Kombinierte Fragmente
- **Alt**: Lizenzvalidierung vs. Fehlerbehandlung
- **Opt**: Erfolgreiche Queue-Addition
- **Loop**: Queue-Abarbeitung
- **Par**: Parallele Wiedergabe-Aktivitäten

---

## Konsistenz-Checkliste

### Zwischen den Diagrammen
- [ ] Gleiche Terminologie (Song, Queue, Zentrale, Jukebox-Steuerung)
- [ ] Konsistente Akteure (Nutzer, System-Komponenten)
- [ ] Übereinstimmende Geschäftslogik (Coin → Auswahl → Wiedergabe)
- [ ] Identische Fehlerfälle (ungültiger Coin, Song nicht verfügbar)
- [ ] Parallele Aktivitäten (Abspielen, Metadaten anzeigen, Status melden)

### Mit Funktionsbeschreibung
- [ ] Alle beschriebenen Features sind modelliert
- [ ] Zentrale-Kommunikation ist in beiden Diagrammen präsent
- [ ] Queue-Mechanismus ist dargestellt
- [ ] Coin-Validierung ist abgebildet
- [ ] Touchscreen-Navigation ist berücksichtigt

### Komplexität
- [ ] Ausreichend syntaktische Elemente pro Diagramm (min. 6-8 verschiedene)
- [ ] Realistische Geschäftslogik ohne künstliche Verkomplizierung
- [ ] Klare Lesbarkeit trotz notwendiger Detaillierung
- [ ] Konsistente Namensgebung zwischen LaTeX und Markdown
