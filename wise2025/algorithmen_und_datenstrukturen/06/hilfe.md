# Hilfe: Übungsblatt 6 - Schnellreferenz für Präsentationen

## 📋 Überblick

- **Aufgabe 1 & 2**: Programmieraufgaben (siehe `06.java`)
- **Aufgabe 3 & 4**: Papieraufgaben (siehe `06.md`)

---

## 🔢 Aufgabe 6.1: Nullen und Neunen

### Was ist das Ziel?
Finde die **kleinste Zahl**, die nur aus `0` und `9` besteht und durch N teilbar ist.

### Wie funktioniert's?
- **Breitensuche (BFS)** mit einer Queue
- Start: `["9"]`
- Generiere systematisch: 9 → 90, 99 → 900, 909, 990, 999 → ...
- Teste jede Zahl: `zahl % N == 0`?
- Die erste passende Zahl ist automatisch die kleinste (wegen BFS)

### Kerncode
```
Queue: ["9"]
while (!queue.isEmpty()) {
    String zahl = queue.remove();
    if (Long.parseLong(zahl) % N == 0) → GEFUNDEN!
    else: queue.add(zahl + "0") und queue.add(zahl + "9")
}
```

### Beispiel
N = 6 → Antwort: 90 (weil 90 / 6 = 15)

---

## 📊 Aufgabe 6.2: Fibonacci mit Queue

### Was ist das Ziel?
Berechne f(n) der Fibonacci-Folge: `f(n) = f(n-1) + f(n-2)`

### Wie funktioniert's?
- Queue als **"sliding window"** für die letzten 2 Werte
- Start: `[1, 1]` (f(1), f(2))
- In jedem Schritt:
  1. `remove()` → ältesten Wert entfernen
  2. `peek()` → aktuellen Wert anschauen
  3. Summe bilden und `add(summe)`

### Ablauf für n=5
```
Init:    [1, 1]
i=3:     [1, 2]  (1+1=2)
i=4:     [2, 3]  (1+2=3)
i=5:     [3, 5]  (2+3=5)
Ergebnis: 5
```

### Warum Queue?
- Speichereffizient: Nur 2 Werte statt ganzes Array
- Demonstriert Queue-Prinzip: FIFO (First In, First Out)

---

## #️⃣ Aufgabe 6.3: Offenes Hashing (Chaining)

### Was ist das?
**Kollisionsauflösung durch Verkettung** – jeder Tabellenplatz ist eine Liste

### Hashfunktion
`f(s) = (AnzahlVokale + AnzahlZeichen) mod 8`

### Beispielrechnung
- Martha: (2 Vokale + 6 Zeichen) mod 8 = **0**
- Sarah: (2 Vokale + 5 Zeichen) mod 8 = **7**

### Was passiert bei Kollision?
Element wird **an die Liste angehängt**

### Ergebnis
```
0: [Maike]
1: [Manuel]
2: []
3: [Matthias]
4: [Patrizia]
5: [Sebastian]
6: [Nele]
7: [Lukas, Sarah]  ← Kollision! Beide Hash=7
```

### Vorteil
- **Immer** Platz für alle Elemente
- Einfach zu implementieren

---

## 🔍 Aufgabe 6.4: Geschlossenes Hashing (Probing)

### Was ist das?
**Kollisionsauflösung durch Sondierung** – suche einen anderen freien Platz

### Hashfunktion
`f(x) = ⌊x/100⌋ mod 10` (Hunderterstelle)

### 1. Lineares Sondieren
**Formel:** `(home + i) mod N` mit i = 1, 2, 3, ...

**Beispiel:**
- 417 will nach Index 4 → besetzt
- Versuche: 4 → 5 (besetzt) → 6 ✓

**Ergebnis:** Alle 9 Schlüssel passen rein

### 2. Quadratisches Sondieren
**Formel:** `(home + i²) mod N` mit i = 1, 2, 3, ...

**Beispiel:**
- 417 will nach Index 4 → besetzt
- Versuche: (4+1)=5 (besetzt) → (4+4)=8 ✓

**Problem:** Schlüssel **1920 kann nicht eingefügt werden!**

### Was passiert?
```
1920: Hash=9
Versuche: 9 → 0 → 3 → 8 → 5 → 4 → 5 → ...
Zyklus! Felder 2, 6, 7 werden NIE erreicht!
```

### Warum?
- Tabellengröße 10 ist **keine Primzahl**
- Quadratisches Sondieren erreicht nicht alle Felder
- → **Sekundäres Clustering**

### Lösung
- Primzahl als Tabellengröße wählen
- Füllgrad < 50% halten
- Oder: Double Hashing verwenden

---

## 🎯 Präsentations-Tipps

### Aufgabe 1 & 2 (Code)
- Zeige BFS-Baum an der Tafel (9 → 90/99 → ...)
- Demonstriere Queue-Operationen live
- Erkläre WARUM Queue besser ist als Stack/Rekursion

### Aufgabe 3 (Offenes Hashing)
- Zeichne Tabelle mit Listen
- Markiere Kollision farbig
- Vorteil: **Immer einfügbar!**

### Aufgabe 4 (Geschlossenes Hashing)
- Zeige beide Tabellen nebeneinander
- **Dramatisch:** "1920 passt nicht mehr!" 
- Erkläre Unterschied: Linear findet immer Platz, Quadratisch nicht immer!

---

## ⚡ Quick Facts

| Aufgabe | Datenstruktur    | Kernkonzept           | Schwierigkeit |
| :------ | :--------------- | :-------------------- | :-----------: |
| 6.1     | Queue            | BFS                   |      ⭐⭐      |
| 6.2     | Queue            | Sliding Window        |       ⭐       |
| 6.3     | ArrayList-Array  | Chaining              |      ⭐⭐      |
| 6.4     | Array (Integer)  | Probing + Clustering  |     ⭐⭐⭐      |
