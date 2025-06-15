# Ablauf der Versionskontrolle bei GBSH-Projekten

## Quellen

- Git als Versionskontrollsystem
- GitHub als Hosting-Plattform
- GitHub Actions für CI/CD
- Jira für Projektmanagement

## Ablauf (neue Projekte):

- Git Template herunterladen
- Setup des Git-Templates ausführen
    - Generierung der Git-Umgebung
    - Erstellung des GitHub-Repos
    - Erstellung des Doc-Branches
    - Einrichtung der GitHub Actions
    - Anpassung der README.md

## Kontinuierliche Integration (CI):

- GitHub Actions für automatisierte Tests und Builds
- Commit/Push `develop`
    - Projekt Informationen ziehen
    - README.md aktualisieren
    - Code Linting und Formatierung
    - Code auf Sicherheit prüfen
    - Tests ausführen
    - Dokumentation generieren (pdoc)

## Kontinuierliche Bereitstellung (CD):

- GitHub Actions für automatisierte Bereitstellung
- Commit/Push `develop`
    - Deployment auf internen Server
    - Release-Tag erstellen
    - Deployment auf internen PyPi Server

## GitHub

- Branches/Tags
    - `develop` für Entwicklung
    - `vx.x.x` für Releases
    - `GBV-xxx` für Jira-Tickets
- Pull Requests
    - CI/CD-Workflow
    - Code-Review einer Person
    - Merge in `develop`
