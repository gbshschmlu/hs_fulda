# 2 Theoretische Grundlagen

Dieses Kapitel legt das Fundament für die spätere Analyse und die Entwicklung von Optimierungsvorschlägen, indem es die zentralen Konzepte, Methoden und Werkzeuge im Bereich der Softwaredokumentation und Versionskontrolle erläutert.

## 2.1 Dokumentation in der Softwareentwicklung

*   **Mögliche Inhalte / Leitfragen:**
    *   Definition, Notwendigkeit und Ziele von Softwaredokumentation (Kommunikation, Wissensmanagement, Qualitätssicherung, Wartung, rechtliche Aspekte).
    *   Überblick über gängige Arten der Softwaredokumentation:
        *   Prozess- vs. Produktdokumentation.
        *   Wichtige Produktdokumentationsarten: Anforderungen (z.B. User Stories, Spezifikationen), Architektur/Design, Quellcode-Kommentare/APIs, Testdokumentation, Benutzer- und Betriebsdokumentation.
    *   Typische Herausforderungen (Aktualität, Umfang, Akzeptanz).
    *   Qualitätskriterien für gute Softwaredokumentation.

*   **Mögliche Quellen:**
    *   **Standardwerk:** Ludewig, Jochen & Lichter, Horst. *Software Engineering – Grundlagen, Menschen, Prozesse, Techniken*. (Aktuelle Auflage, dpunkt.verlag) – Bietet eine solide deutschsprachige Grundlage zu Softwareprozessen und der Rolle der Dokumentation.
    *   **Normenüberblick:** Informiere dich über die Relevanz von Normen wie der **ISO/IEC/IEEE 2651x Reihe** (speziell für Benutzerinformationen) oder **ISO/IEC/IEEE 15289** (Inhalte von Software-Lebenszyklus-Dokumenten). Die Tekom-Webseite (tekom.de) kann hier als Ausgangspunkt dienen.
    *   **Praxisbezug (Agil):** [Fraunhofer IESE - Herausforderungen bei Dokumentation agiler Anforderungen](https://www.iese.fraunhofer.de/blog/anforderungsdokumentation-3-herausforderungen-bei-dokumentation-agiler-anforderungen/) – Vertieft spezifische Herausforderungen und Notwendigkeiten.
    *   **Grundlegende Bedeutung:** [WebMakers - The importance of documentation in software projects](https://webmakers.expert/en/blog/the-importance-of-documentation-in-software-projects) – Zur allgemeinen Wichtigkeit und Vermeidung von Chaos.

## 2.2 Versionskontrollsysteme und -prozesse

*   **Mögliche Inhalte / Leitfragen:**
    *   Definition und grundlegende Aufgaben von Versionskontrollsystemen (VCS).
    *   Kernkonzepte: Repository, Commit, Branch, Merge, Tag, Diff, Rollback.
    *   Typen von VCS: Zentralisiert (z.B. SVN) vs. Verteilt (z.B. Git) – Fokus auf Funktionsweise und Vor-/Nachteile von DVCS.
    *   Grundlegende Git-Workflows: Klonen, Staging (add), Commit, Push, Pull/Fetch.

*   **Mögliche Quellen:**
    *   **Standardwerk Git:** Chacon, Scott and Straub, Ben. *Pro Git*. (Kostenlos online verfügbar: [https://git-scm.com/book/de/v2](https://git-scm.com/book/de/v2)) – Das umfassendste Werk zu Git, sehr detailliert und praxisnah.
    *   **Praxisnahe Tutorials:** [Atlassian Git Tutorial](https://www.atlassian.com/de/git/tutorials) – Sehr gute Erklärungen zu grundlegenden und fortgeschrittenen Git-Konzepten und Workflows.
    *   **Allgemeine Bedeutung:** [MoldStud - The Importance of Version Control Systems](https://moldstud.com/articles/p-the-importance-of-version-control-systems-in-software-development) – Hebt die Wichtigkeit für Zusammenarbeit und Fehlervermeidung hervor.

## 2.3 Aktuelle Standards und Best Practices in der Industrie

*   **Mögliche Inhalte / Leitfragen:**
    *   **Dokumentation:**
        *   Prinzipien agiler Dokumentation ("Just Enough", User Stories).
        *   "Documentation as Code" (Docs-as-Code): Konzept, Werkzeuge (z.B. Sphinx, MkDocs mit Markdown), Vorteile.
    *   **Versionskontrolle:**
        *   Etablierte Branching-Modelle:
            *   Gitflow (Vorstellung und typische Anwendungsfälle).
            *   Trunk-Based Development (als modernerer Ansatz für CI/CD).
        *   Best Practices für Commit-Nachrichten (z.B. "Conventional Commits").
        *   Code Reviews mittels Pull/Merge Requests.
        *   Semantic Versioning (SemVer) für Releases.
        *   Integration von VCS in CI/CD-Prozesse.

*   **Mögliche Quellen:**
    *   **Agile Dokumentation:**
        *   [Manifesto for Agile Software Development](https://agilemanifesto.org/iso/de/manifesto.html)
        *   [Fraunhofer IESE - Der Mythos „Keine Dokumentation“ für agile Anforderungen](https://www.iese.fraunhofer.de/blog/anforderungsmanagement-2-der-mythos-keine-dokumentation-fuer-agile-anforderungen/)
    *   **Docs-as-Code:**
        *   [Informatik Aktuell - Docs-as-Code – Die Grundlagen](https://www.informatik-aktuell.de/entwicklung/methoden/docs-as-code-die-grundlagen.html) (Teil einer Serie)
    *   **Branching-Modelle & Workflows:**
        *   [Atlassian - Comparing Workflows (Gitflow, Trunk-Based etc.)](https://www.atlassian.com/de/git/tutorials/comparing-workflows)
    *   **Commit-Nachrichten & Versionierung:**
        *   [Conventional Commits](https://www.conventionalcommits.org/de/v1.0.0/)
        *   [Semantic Versioning (SemVer)](https://semver.org/lang/de/)
    *   **Code Reviews:**
        *   [Atlassian - Using pull requests in Bitbucket Server (Konzept übertragbar)](https://confluence.atlassian.com/bitbucketserver/using-pull-requests-in-bitbucket-server-776639983.html) (Prinzipien von Pull Requests)

## 2.4 Relation zwischen Dokumentation und Versionskontrolle

*   **Mögliche Inhalte / Leitfragen:**
    *   Synergien: Wie unterstützt VCS die Dokumentationserstellung und -pflege?
    *   Versionierung von Dokumentationsartefakten (insb. bei Docs-as-Code).
    *   Nachvollziehbarkeit: Verknüpfung von Dokumentationsänderungen mit Code-Änderungen (Commit-Historie, Verlinkung zu Issues/Tickets).
    *   Verbesserung von Wartbarkeit und Onboarding durch die Kombination beider Praktiken.
    *   Herausforderung der Synchronisation und wie VCS hier helfen kann (z.B. Dokumentation in denselben Branches wie Code-Features).

*   **Mögliche Quellen:**
    *   Viele der Quellen unter **2.3 (Docs-as-Code)** sind hier direkt wiederverwendbar, da sie die Kernidee der Integration behandeln.
    *   **Synthese:** Dieser Abschnitt erfordert oft eine stärkere Eigenleistung durch die Verknüpfung der Erkenntnisse aus den vorherigen Abschnitten und den Docs-as-Code-Quellen.
    *   [Martin Fowler - TechnicalDebt (und verwandte Artikel)](https://martinfowler.com/bliki/TechnicalDebt.html) – Fowler diskutiert oft ganzheitliche Aspekte der Softwareentwicklung, wo auch die Pflege von Wissen (Dokumentation) und Code-Qualität eine Rolle spielt.
