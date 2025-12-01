# SparseVector - Cheat-Sheet für Präsentation

## Was ist ein Sparse Vector?

- Vektor der nur Nicht-Null-Werte speichert
- Spart Speicher bei vielen Nullen (z.B. Vektor mit 1000 Elementen, aber nur 3 sind != 0)
- Beispiel: [0, 0, 3.5, 0, 0, 7.2, 0, 0] wird intern nur als [(2, 3.5), (5, 7.2)] gespeichert

## Implementierung

### Datenstruktur
- Verkettete Liste (Linked List) von Nodes
- Jeder Node hat: Index, Wert, Pointer zum nächsten Node
- Head-Node als Dummy (Index -1)
- Nodes sind nach Index sortiert

### Konstruktoren
- `SparseVector()`: Leerer Vektor (Länge 0)
- `SparseVector(int n)`: Vektor mit Länge n (alle Werte initial 0)
- Exception bei negativer Länge

### Kernmethoden

**setElement(int index, double value)**
- Setzt Wert an Index
- Bei value = 0.0: Element wird entfernt (Sparse-Eigenschaft)
- Sortierte Einfügung in Liste
- Update wenn Index schon existiert

**getElement(int index)**
- Gibt Wert an Index zurück
- Wenn Index nicht in Liste: return 0.0
- Durchläuft Liste bis Index gefunden oder übersprungen

**removeElement(int index)**
- Entfernt Node an Index aus Liste
- Keine Aktion wenn Index nicht existiert

**equals(SparseVector other)**
- Vergleicht zwei Vektoren auf Gleichheit
- Prüft: Länge, Indizes, Werte
- null-safe

**add(SparseVector other)**
- Addiert anderen Vektor zu diesem
- Vektoren müssen gleiche Länge haben
- Bei Summe = 0.0: Element wird entfernt
- Komplexe Pointer-Manipulation für sortierte Einfügung

## Test-Übersicht

### Test 1 (Flo): Konstruktor & getLength
- Testet Vektor-Erstellung
- Prüft Länge bei normalem und leerem Vektor

### Test 2 (Joshi): setElement & getElement
- Setzt einzelnes Element
- Prüft Abrufen von gesetztem und nicht-gesetztem Element

### Test 3 (Roman): removeElement
- Setzt Element, entfernt es wieder
- Prüft ob getElement danach 0.0 zurückgibt

### Test 4 (Luca): equals
- Leere Vektoren
- Gleiche Elemente
- Unterschiedliche Werte
- Unterschiedliche Anzahl Elemente
- Unterschiedliche Längen
- null-Vergleich

### Test 5 (Roman): Sortierung
- Setzt Elemente in "falscher" Reihenfolge (8, 3, 5)
- Prüft ob alle Indizes korrekt abrufbar sind
- Verifiziert interne Sortierung

### Test 6 (Flo): add - Überlappend
- Beide Vektoren haben Werte an gleichen Indizes
- Prüft Addition: 3.0 + 4.0 = 7.0
- Prüft Entfernung bei 0: -2.0 + 2.0 = 0.0 (muss entfernt werden)

### Test 7 (Joshi): add - Nicht-überlappend
- Vektoren mit komplett unterschiedlichen Indizes
- vec1: [1, 3, 5], vec2: [2, 4, 6]
- Prüft ob alle Elemente übernommen werden

### Test 8 (Luca): Exceptions & Edge Cases
- Negative Indizes
- Index >= length
- add(null)
- add() mit unterschiedlichen Längen
- Negativer Konstruktor-Parameter
- setElement mit 0.0 (muss entfernen)

## Wichtige Punkte für Präsentation

### Vorteile
- Speichereffizient bei vielen Nullen
- O(k) Speicher statt O(n), wobei k = Anzahl Nicht-Null-Elemente

### Nachteile
- Langsamerer Zugriff als Array: O(k) statt O(1)
- Overhead durch Node-Objekte bei vielen Nicht-Null-Elementen

### Anwendungsfälle
- Große Matrizen in wissenschaftlichen Berechnungen
- Machine Learning (viele Features, wenige aktiv)
- Graphen-Repräsentation (Adjacency Matrix)

### Komplexität
- getElement: O(k) - muss Liste durchlaufen
- setElement: O(k) - muss richtige Position finden
- add: O(k1 + k2) - muss beide Listen durchlaufen
- Speicher: O(k) statt O(n)
