# DB-Case: `CONN_MAX_AGE` und stale Connections

## Ursache

- In Produktion ist `CONN_MAX_AGE = 6000` gesetzt.
- Django hält DB-Verbindungen dadurch bis zu 100 Minuten offen.
- Nach Produktionspausen kann PostgreSQL oder eine Firewall die inaktive
  Verbindung schließen.
- Django merkt das erst beim nächsten ORM-Zugriff.
- In der Entwicklung tritt das kaum auf, weil dort `CONN_MAX_AGE = 0` gilt.
- `CONN_MAX_AGE = 0` bedeutet: Verbindung nach jedem DB-Zugriff schließen,
  nächster Zugriff öffnet eine frische Verbindung.

## Problem

- Kritische Stelle: `convert_inspection_to_model()`.
- Dort werden Inspektionsergebnisse per Django-ORM gespeichert.
- Es fehlt aktuell:
    - `close_old_connections()` vor dem DB-Zugriff
    - `try/except OperationalError`
    - Retry nach Verbindungsfehler
- Fehlerkette:
    1. ROSI läuft weiter, aber es kommen keine Inspektionen.
    2. DB-Verbindung wird idle.
    3. PostgreSQL/Firewall trennt die Verbindung.
    4. Erste Inspektion nach Pause schreibt in die DB.
    5. Django nutzt stale Verbindung.
    6. `OperationalError`.
    7. Unbehandelte Exception.
    8. Worker/PipelineManager kann crashen.

## Warum im Labor nicht reproduziert

- Entwicklung nutzt `CONN_MAX_AGE = 0`.
- Dadurch gibt es keine langlebige idle Verbindung.
- Der Test mit `pg_terminate_backend` erzeugt deshalb keinen Crash.
- Das ist ein Dev/Prod-Parity-Problem.

## Lösung

- Minimalfix:

```python
from django.db import close_old_connections

def convert_inspection_to_model(...):
    close_old_connections()
    ...
```

- Besser zusätzlich:
    - `OperationalError` abfangen
    - `close_old_connections()` erneut ausführen
    - DB-Schreibvorgang einmal retryen

- Alternative:
    - `CONN_MAX_AGE = 0` auch in Produktion prüfen
    - Vorteil: stale Connections strukturell vermieden
    - Nachteil: mehr DB-Verbindungsaufbau, vermutlich geringer Overhead bei lokaler DB

## Empfehlung

- `close_old_connections()` vor `convert_inspection_to_model()` einbauen.
- Danach optional Retry für `OperationalError`.
- Produktionsnahen Test mit `CONN_MAX_AGE = 60` ergänzen.
