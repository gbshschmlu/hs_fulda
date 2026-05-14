# HS Fulda Unterlagen

Alle Aufgaben, Lösungen und Unterlagen zu den Modulen meines dualen Studiums an der Hochschule Fulda.

**Dualer Student bei:** Grenzebach BSH GmbH

---

## Struktur

```
├── sose2025/              # Sommersemester 2025
├── sose2026/              # Sommersemester 2026
├── wise2025/              # Wintersemester 2025/26
├── convert/               # Branding-Assets für PDF-Konvertierung
│   └── layout/Luca_Schmidt/   # Logo und Assets
├── assets/                # Scripts und sonstige Assets
└── typos.toml             # PDF-Branding-Konfiguration (Profile & Schriften)
```

Jedes Semester ist nach Modulen gegliedert. Innerhalb eines Moduls gibt es Unterordner für Aufgaben, Lösungen, Skripte und sonstige Unterlagen.

---

## Markdown → PDF

Die Konvertierung erfolgt mit **[typos](https://github.com/LuMiSxh/typos)** — ein selbstständiges CLI-Tool, das Markdown-Dateien ohne externe Abhängigkeiten (kein LaTeX, kein Pandoc) direkt in gebrandete PDFs umwandelt.

### Installation

```bash
cargo install --git https://github.com/LuMiSxh/typos
```

Oder lokal aus dem Quellcode:

```bash
cargo install --path /pfad/zu/typos
```

### Verwendung

```bash
# Einzelne Datei mit einem Profil
typos convert sose2026/modul/datei.md --profile luca

# Mehrere Profile gleichzeitig
typos convert sose2026/modul/datei.md --profile luca,gb

# Alle Profile auf einmal
typos convert sose2026/modul/datei.md --profile all

# Interaktiver Modus (kein Argument nötig)
typos
```

Das PDF wird standardmäßig neben der Quelldatei abgelegt.

### Profile

Die Branding-Konfiguration steht in `typos.toml` im Repo-Root und wird automatisch gefunden, egal aus welchem Unterordner `typos` aufgerufen wird.

| Profil | Branding |
|---|---|
| `luca` | Grenzebach BSH — Rot `#ED1B24` |
| `gb` | Grenzebach BSH (generisch) — Rot `#ED1B24` |

Alle konfigurierten Profile anzeigen:

```bash
typos list
```
