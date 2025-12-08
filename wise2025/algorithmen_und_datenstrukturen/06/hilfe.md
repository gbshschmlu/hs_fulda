# Hilfe: Übungsblatt 6 - Spickzettel für die Präsentation

## 📋 Schnellübersicht

| Aufgabe | Thema           | Methode                   | Ergebnis-Typ            |
| :------ | :-------------- | :------------------------ | :---------------------- |
| **6.1** | Nullen & Neunen | Queue (Breitensuche)      | Zahl (z.B. 90)          |
| **6.2** | Fibonacci       | Queue (Sliding Window)    | Zahl                    |
| **6.3** | Hashing         | Offen (Verkettung/Listen) | Tabelle mit Listen      |
| **6.4** | Hashing         | Geschlossen (Sondieren)   | Tabelle mit Kollisionen |

---

## 🔢 Aufgabe 6.1: Nullen und Neunen

**Ziel:** Kleinste positive Zahl aus nur `0` und `9`, die durch `N` teilbar ist.

### 🗣️ Was du sagen musst:

1.  **Warum Queue?** Wir nutzen eine Queue für eine **Breitensuche (BFS)**.
2.  **Das Prinzip:** Wir generieren Zahlen nach Länge sortiert: erst 9, dann 90, 99, dann 900...
3.  **Ablauf:**
    - Nimm Zahl aus Queue (z.B. "9").
    - Teste: `9 % N == 0`? Wenn ja: Fertig!
    - Wenn nein: Hänge "0" und "9" an und packe beide zurück in die Queue (`90`, `99`).
4.  **Garantie:** Da wir systematisch immer breiter werden, finden wir garantiert die **kleinste** Zahl zuerst.

---

## 📊 Aufgabe 6.2: Fibonacci-Folge

**Ziel:** `f(n)` berechnen mit `f(n) = f(n-1) + f(n-2)`.

### 🗣️ Was du sagen musst:

1.  **Idee:** Wir nutzen die Queue als **"Rutschfenster" (Sliding Window)** der Größe 2.
2.  **Speicher:** Statt alle Zahlen in einem Array zu speichern, merken wir uns nur die letzten zwei.
3.  **Der Algorithmus:**
    - Queue Start: `[1, 1]` (für `f(1), f(2)`).
    - Berechne `New = Vorne + Zweiter`.
    - `remove()` (das Alte wegwerfen).
    - `add(New)` (das Neue hinten dran).
4.  **Beispiel n=4:**
    - Start: `[1, 1]`
    - Schritt 1: `1+1=2` → `[1, 2]`
    - Schritt 2: `1+2=3` → `[2, 3]` → Ergebnis ist 3.

---

## #️⃣ Aufgabe 6.3: Offenes Hashing (Verkettung)

**Hashfunktion:** `h(s) = (Vokale + Länge) mod 8`

### 🗣️ Was du sagen musst:

1.  **Verfahren:** Bei Kollisionen bilden wir eine **Liste** am Index (Chaining).
2.  **Beispielrechnung:**
    - "Patrizia": 4 Vokale + 8 Zeichen = 12. `12 mod 8 = 4`.
    - "Maike": 3 Vokale + 5 Zeichen = 8. `8 mod 8 = 0`.
3.  **Die Kollision:**
    - "Lukas" landet auf Index **7**.
    - "Sarah" landet auch auf Index **7** (`2+5=7`).
    - **Lösung:** Sarah wird einfach in die Liste bei Index 7 hinter Lukas gehängt.
4.  **Fazit:** Die Tabelle wird nie "voll", aber die Listen können lang werden (langsamere Suche).

### 📝 Tabellen-Check

- **Index 7:** `[Lukas, Sarah]`
- **Index 5:** `[Sebastian]`
- **Index 0:** `[Maike]`

---

## 🔍 Aufgabe 6.4: Geschlossenes Hashing (Sondieren)

**Hashfunktion:** `h(x) = ⌊x/100⌋ mod 10` (Hunderterstelle)
**Wichtig:** Tabellengröße `N=10` (keine Primzahl!).

### 1. Lineares Sondieren

**Formel:** `(Start + i) mod 10`

- **Ablauf:** Wenn Platz besetzt, gehe einfach eins weiter.
- **Ergebnis:** Alle Zahlen passen rein. Die Tabelle ist am Ende voll bis auf Index 8.
- **Beispiel 1920:** Will auf die 9. 9, 0, 1 besetzt → landet auf **2**.

### 2. Quadratisches Sondieren (Der Problemfall)

**Formel:** `(Start + i²) mod 10` → Schritte: `+1, +4, +9, +16...`

- **Das Problem:** Wir wollen **1920** einfügen.
    - Start: Index **9** (besetzt durch 900).
    - `i=1`: `9+1 = 10 ≡ 0` (besetzt durch 1001).
    - `i=2`: `9+4 = 13 ≡ 3` (besetzt durch 1320).
    - `i=3`: `9+9 = 18 ≡ 8` (besetzt durch 417).
    - `i=4`: `9+16 = 25 ≡ 5` (besetzt durch 1542).
    - `i=5`: `9+25 = 34 ≡ 4` (besetzt durch 429).
    - `i=6`: `9+36 = 45 ≡ 5` (Wiederholung!).
- **Fazit:** Wir drehen uns im Kreis. Obwohl die Plätze **2 und 6 frei** sind, erreicht das quadratische Sondieren sie ausgehend von der 9 niemals.
- **Antwort auf "Was passiert?":** Die Zahl 1920 kann **nicht eingefügt** werden (Endlosschleife/Abbruch), obwohl die Tabelle nicht voll ist.

### 💡 Warum passiert das?

Das liegt daran, dass die Tabellengröße **10 keine Primzahl** ist. Quadratisches Sondieren garantiert nur dann das Finden eines freien Platzes (wenn Tabelle ≤ 50% gefüllt), wenn `N` eine Primzahl der Form `4k+3` ist. Hier versagt das Verfahren.
