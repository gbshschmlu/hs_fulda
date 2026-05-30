# Theorierahmen – Verfügbarkeit und Fehlertoleranz im industriellen Dauerbetrieb

> Fallstudie AI3955 | Luca Michael Schmidt | SoSe26  
> Basis für Kapitel 2 der Ausarbeitung  
> Zitationsstil: IEEE (nummeriert)

---

## 1. Verfügbarkeit im 24/7-Betrieb

Verfügbarkeit (*Availability*) ist eine zentrale Eigenschaft zuverlässiger Systeme (*Dependable Systems*). Avizienis et al. definieren Verfügbarkeit als die Bereitschaft eines Systems, seinen spezifizierten Dienst korrekt zu erbringen [1]. Formal ergibt sich:

```
A = MTTF / (MTTF + MTTR)
```

- **MTTF** (Mean Time to Failure): durchschnittliche Zeit zwischen zwei Ausfällen
- **MTTR** (Mean Time to Repair): durchschnittliche Zeit zur Wiederherstellung nach einem Ausfall

Industrielle Systeme im 24/7-Betrieb stellen besondere Anforderungen an beide Größen. Während Entwicklungsumgebungen typischerweise täglich neu gestartet werden und Fehler durch manuelle Beobachtung sichtbar sind, akkumulieren sich im Dauerbetrieb Effekte, die über kurze Beobachtungsfenster unsichtbar bleiben: schleichende Ressourcenerschöpfung, veraltete Verbindungszustände und stille Prozessausfälle. Ein System, das im Entwicklungsbetrieb stabil läuft, kann daher im 24/7-Betrieb durch eine völlig andere Klasse von Fehlern ausfallen.

Die vorliegende Fallstudie fokussiert genau diese Fehlerklasse: Fehler, die Zeit als Faktor benötigen und deshalb im Labor selten auftreten.

---

## 2. Fehlerklassifikation

### 2.1 Fail-Fast vs. Fail-Silent

Cristian unterscheidet grundlegende Verhaltensklassen bei Prozessausfällen in verteilten Systemen [2]. Für diese Fallstudie relevant sind:

- **Fail-Stop (Fail-Fast):** Ein fehlerhafter Prozess bricht sofort ab und signalisiert seinen Ausfall unmissverständlich. Für das Gesamtsystem ist der Fehler sichtbar und adressierbar.
- **Fail-Silent:** Ein fehlerhafter Prozess stellt seine Funktion ein, ohne einen Fehler zu melden. Das Gesamtsystem läuft scheinbar weiter – ohne Alarm, ohne Neustart, ohne Log.

Fail-Silent-Verhalten ist in industriellen Systemen besonders gefährlich, weil der Ausfall nicht durch technische Signale, sondern erst durch ausbleibende Produktionsergebnisse sichtbar wird. Im ROSI-Kontext zeigen drei von vier Service-Prozessen bei einem Absturz Fail-Silent-Verhalten.

### 2.2 Schleichende Fehler (*Creeping Failures*)

Schleichende Fehler entstehen nicht durch ein singuläres Ereignis, sondern durch die kontinuierliche Akkumulation eines Ressourcenverbrauchs oder Zustandsverfalls. Typische Ausprägungen sind:

- **Speichererschöpfung:** Logs, Queues oder Bilddaten wachsen bis Schreiboperationen systemweit scheitern
- **Verbindungsverfall:** Persistente TCP-Verbindungen werden von der Gegenseite getrennt, ohne dass der Client dies bemerkt
- **Queue-Akkumulation:** Eine blockierende Queue füllt sich, bis alle schreibenden Prozesse einfrieren

Charakteristisch für schleichende Fehler ist, dass zwischen Ursache und sichtbarem Symptom eine erhebliche Zeitspanne liegt. Im 24/7-Betrieb kann diese Zeitspanne Stunden oder Schichten betragen. Birman beschreibt diesen Sachverhalt als "silent degradation" – ein System, das nominal läuft, aber seinen eigentlichen Zweck nicht mehr erfüllt [3].

### 2.3 Kaskadeneffekte

Ein Kaskadeneffekt entsteht, wenn der Ausfall oder die Verlangsamung einer Komponente über gemeinsame Schnittstellen (Queues, Shared Memory, Datenbankverbindungen) den Ausfall weiterer Komponenten verursacht [4]. Im Gegensatz zu einem isolierten Ausfall ist ein Kaskadeneffekt schwerer zu diagnostizieren, weil das sichtbare Symptom (z.B. Prozess-Freeze) nicht die Ursache (z.B. blockierende Log-Queue) widerspiegelt. Das System kollabiert an einer anderen Stelle als die ursprüngliche Schwachstelle liegt.

---

## 3. Prozesssupervision und das Watchdog-Pattern

### 3.1 Das Supervisor-Modell

In langlebigen Multiprocessing-Systemen ist es unzureichend, Prozesse nur beim Start zu überprüfen. Das **Supervisor-Modell** sieht vor, dass ein dedizierter Überwachungsprozess (*Supervisor*) den Laufzeitstatus aller untergeordneten Prozesse kontinuierlich beobachtet und bei Ausfall automatisch reagiert – durch Neustart, Alarm oder geordnetes Herunterfahren. Dieses Konzept ist u.a. im Erlang/OTP-Framework als *Supervision Tree* implementiert, wo Supervisoren ihre Child-Prozesse überwachen und bei Crash automatisch neu starten [5].

Das **Watchdog-Pattern** ist eine konkrete Implementierung dieses Modells: der Supervisor erwartet in regelmäßigen Abständen ein Lebenszeichen (*Heartbeat*) des überwachten Prozesses. Bleibt das Signal aus, gilt der Prozess als ausgefallen. Für eingebettete und industrielle Systeme beschreiben Baker und Pont sieben Varianten des Watchdog-Patterns mit unterschiedlichen Reaktionsstrategien [6].

### 3.2 Folgen fehlender Supervision

Ohne Supervisor-Logik entstehen zwei kritische Szenarien:

- **Deadlock ohne Erkennung:** Ein abgestürzter Prozess, dessen Ausgang von anderen Prozessen erwartet wird, hält das System in einem wartenden Zustand gefangen – ohne Timeout, ohne Alarm.
- **Stiller Betrieb ohne Funktion:** Ein Prozess fällt aus, das System läuft scheinbar weiter. Fehler werden erst durch ausbleibende Ausgaben sichtbar – zu spät für automatische Fehlerreaktionen.

Beide Szenarien sind für Produktionssysteme inakzeptabel, da sie einen manuellen Eingriff erfordern, der im 24/7-Betrieb ohne Bereitschaft nicht zeitnah erfolgen kann.

---

## 4. Ressourcenerschöpfung und Backpressure

### 4.1 Bounded vs. Unbounded Queues

Eine **unbounded Queue** wächst ohne Obergrenze. Bei anhaltender Produktionsrate und gedrosseltem Konsum akkumuliert sie Einträge bis der verfügbare Speicher erschöpft ist – ein schleichender Fehler mit hartem Endpunkt.

Eine **bounded Queue** (mit `maxsize`) begrenzt das Wachstum, erzeugt dafür aber **Backpressure**: Produzenten, die in eine volle Queue schreiben wollen, werden blockiert. Kleppmann beschreibt Backpressure als notwendigen, aber oft fehlerhaft implementierten Mechanismus: blockierendes `put()` ohne Timeout überträgt den Stau transitiv auf alle upstream-Komponenten [7]. In einem Multiprocessing-System mit gemeinsamer Queue kann ein einzelner langsamer Konsument so das gesamte System zum Einfrieren bringen.

### 4.2 Flüchtiger Speicher (tmpfs/RAM-Disk)

Flüchtige Dateisysteme wie `tmpfs` und RAM-Disks leben ausschließlich im RAM. Sie bieten hohe I/O-Geschwindigkeit, haben aber zwei charakteristische Eigenschaften, die im Dauerbetrieb relevant werden:

1. **Begrenzte Kapazität:** Im Gegensatz zu einer Festplatte ist eine RAM-Disk auf einen festen Größenwert konfiguriert. Überschreitet das Schreibvolumen diese Grenze, schlagen Schreiboperationen mit `OSError: No space left on device` fehl.
2. **Kein Monitoring by Default:** Betriebssystem-Tools wie `df` erfassen RAM-Disks, aber Anwendungen enthalten selten proaktive Füllstandsüberwachung für `tmpfs`-Mounts.

Eine RAM-Disk, die als Puffer zwischen schnellem Schreiben und langsamem Lesen dient, ist strukturell ein **Single Point of Failure** für alle Komponenten, die auf sie angewiesen sind.

---

## 5. Dev/Prod-Parity und Konfigurationsgefälle

Das Prinzip der **Dev/Prod-Parity** (Faktor X des *Twelve-Factor App*-Manifests) beschreibt die Anforderung, Entwicklungs- und Produktionsumgebung so ähnlich wie möglich zu halten [8]. Abweichungen zwischen beiden Umgebungen – insbesondere in Konfigurationsparametern – können dazu führen, dass Fehler in der Entwicklung nicht reproduzierbar sind, die in Produktion deterministisch auftreten.

Ein häufiges Muster ist das **Konfigurationsgefälle bei Verbindungs-Pooling**: Entwicklungsumgebungen verwenden oft keine persistenten Verbindungen (jede Anfrage öffnet eine frische Verbindung), während Produktionsumgebungen aus Performance-Gründen persistente Verbindungen mit langen Lebensdauern nutzen. Damit verhält sich die Fehlerklasse *stale connection* (veraltete Verbindung nach Idle-Timeout) im Entwicklungsbetrieb strukturell anders als in Produktion – sie tritt schlicht nicht auf.

Die Konsequenz: Fehlerbehandlungscode kann weggelassen werden, ohne dass Tests oder Entwicklungsbetrieb darauf hinweisen. In Produktion führt das erste Auftreten der Fehlerbedingung zu einem unkontrollierten Systemabsturz.

---

## Referenzen (IEEE-Stil)

> Diese Referenzen sind in `ausarbeitung/bib/references.bib` als BibTeX-Einträge hinterlegt.

| Nr. | BibTeX-Key | Vollständige Angabe |
|-----|------------|---------------------|
| [1] | `avizienis2004` | A. Avizienis, J.-C. Laprie, B. Randell, and C. Landwehr, "Basic concepts and taxonomy of dependable and secure computing," *IEEE Trans. Dependable Secure Comput.*, vol. 1, no. 1, pp. 11–33, Jan. 2004. DOI: 10.1109/TDSC.2004.2 |
| [2] | `cristian1991` | F. Cristian, "Understanding fault-tolerant distributed systems," *Commun. ACM*, vol. 34, no. 2, pp. 56–78, Feb. 1991. DOI: 10.1145/102792.102801 |
| [3] | `birman2012` | K. P. Birman, *Guide to Reliable Distributed Systems: Building High-Assurance Applications and Cloud-Hosted Services*. Springer, 2012. ISBN: 978-1-4471-2415-3 |
| [4] | `ieee_cascade2016` | H. Qi, S. Bhatt, and A. Bhatt, "System reliability under cascading failure models," *IEEE Trans. Rel.*, 2016. DOI: 10.1109/TR.2015.2500283 |
| [5] | `armstrong2007` | J. Armstrong, *Programming Erlang: Software for a Concurrent World*. Pragmatic Bookshelf, 2007. ISBN: 978-1-934356-00-5 |
| [6] | `pont_watchdog` | A. Baker and M. Pont, "Using watchdog timers to improve the reliability of single-processor embedded systems: Seven new patterns and a case study," ResearchGate. [Online]. Available: https://www.researchgate.net/publication/255621935. Zuletzt abgerufen: 30. Mai 2026 |
| [7] | `kleppmann2017` | M. Kleppmann, *Designing Data-Intensive Applications: The Big Ideas Behind Reliable, Scalable, and Maintainable Systems*. O'Reilly Media, 2017. ISBN: 978-1-4493-7332-0 |
| [8] | `wiggins2011` | A. Wiggins, "The Twelve-Factor App," 2011. [Online]. Available: https://www.12factor.net/. Zuletzt abgerufen: 30. Mai 2026 |

---

## Zuordnung Theorie → Cases

| Theorieblock | Relevante Cases | Referenzen |
|---|---|---|
| MTTF/MTTR/Availability | Alle (Messgröße Time-to-Detection) | [1] |
| Fail-Silent | Case 1 (Logger, FrameGrabber, IDH) | [2] |
| Schleichende Fehler | Case 2 (RAM-Disk-Overflow), Case 3 (DB-Log-Wachstum) | [3] |
| Kaskadeneffekte | Case 3 (Log-Queue → Pipeline-Freeze) | [4] |
| Supervisor/Watchdog-Pattern | Case 1 (Hauptprozesse unsupervised) | [5] [6] |
| Bounded Queue + Backpressure | Case 3 (blockierendes `log_queue.put()`) | [7] |
| tmpfs als SPOF | Case 2 (RAM-Disk) | – |
| Dev/Prod-Parity | Case 4 (CONN_MAX_AGE-Gefälle) | [8] |
| Hypothesenprüfung | Case 5 (GC-Race widerlegt) | – |

---

## Quellenbedarf in anderen Bereichen der Ausarbeitung

| Bereich | Empfohlene Quelle |
|---|---|
| Einleitung: KI-basierte Qualitätskontrolle in der Industrie | Paper zu AI/CV in industrial inspection – noch zu recherchieren |
| Methodik: Fault Injection als empirische Methode | M. C. Hsueh, T. K. Tsai, and R. K. Iyer, "Fault injection techniques and tools," *IEEE Computer*, vol. 30, no. 4, pp. 75–82, 1997 |
| Case 4: Django ORM `close_old_connections()` | Django Documentation – persistent connections. [Online]. Available: https://docs.djangoproject.com/en/stable/ref/databases/#persistent-connections. Zuletzt abgerufen: 30. Mai 2026 |
| Case 2: Linux `tmpfs` Charakteristika | Linux Kernel Documentation – tmpfs. [Online]. Available: https://www.kernel.org/doc/html/latest/filesystems/tmpfs.html. Zuletzt abgerufen: 30. Mai 2026 |
| Case 5: Python `multiprocessing.shared_memory` | Python Software Foundation, "multiprocessing.shared_memory," Python 3 Docs. [Online]. Available: https://docs.python.org/3/library/multiprocessing.shared_memory.html. Zuletzt abgerufen: 30. Mai 2026 |
