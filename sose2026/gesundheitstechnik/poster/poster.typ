// ==========================================
// POSTER KONFIGURATION (A0 Querformat)
// ==========================================
#set page(
  paper: "a0",
  flipped: true,
  margin: (x: 4cm, y: 4cm),
  fill: rgb("f4f7fb"), // Sehr helles, kühles Grau-Blau für modernen Look
)

// Universelles Font-Setup (vermeidet OS-Warnungen)
#set text(
  font: ("Arial", "Helvetica"),
  fill: rgb("1e293b"),
  size: 24pt,
  lang: "de",
)
#set par(justify: false, leading: 1.3em)

// ==========================================
// FARBPALETTE
// ==========================================
#let hs-green = rgb("61BD1A")   // Hochschul-Grün (Zentrum)
#let text-dark = rgb("0f172a")

// Farben für die 3 Ebenen (Cards)
#let col-ebene1 = rgb("0284c7") // Blau (Modell)
#let col-ebene2 = rgb("ea580c") // Orange (Klinik)
#let col-ebene3 = rgb("7c3aed") // Lila (IT)

// ==========================================
// HILFSFUNKTIONEN (Icons & Cards)
// ==========================================
#let lucide(name) = box(
  baseline: 20%,
  image("icons/" + name + ".svg", height: 1.4em),
)

// Moderne Card mit farbigem Balken links
#let mm-node(icon, title, metrics, color: gray) = block(
  fill: white,
  stroke: (left: 10pt + color, rest: 1.5pt + rgb("e2e8f0")),
  radius: 0.5cm,
  inset: 1.5cm,
  width: 100%,
  spacing: 1em,
)[
  #grid(columns: (auto, 1fr), gutter: 1em, align: horizon)[
    #box(image("icons/" + icon + ".svg", height: 1.8em))
  ][
    #text(size: 28pt, weight: "bold", fill: text-dark, title)
  ]
  #v(0.5em)
  #list(
    marker: text(fill: color, size: 28pt)[•],
    ..metrics.map(m => text(size: 22pt, m)),
  )
]

// ==========================================
// HEADER
// ==========================================
#align(center)[
  #text(size: 75pt, weight: "bold", fill: hs-green)[Messbarkeit der Vorteile in der Gesundheitstechnik] \
  #v(0.5cm)
  #text(size: 42pt, weight: "medium", fill: rgb("475569"))[Evidenzprüfung und Evaluierungsmetriken auf drei Ebenen] \
  #v(0.8cm)
  #text(size: 28pt, weight: "bold", fill: text-dark)[Luca Michael Schmidt]
  #text(size: 28pt, fill: rgb("64748b"))[ | Seminar Gesundheitstechnik | Hochschule Fulda]
]

#v(3cm)

// ==========================================
// HAUPT-LAYOUT (3 Spalten)
// ==========================================
#grid(
  columns: (1fr, 1.4fr, 1fr),
  // Die Mitte ist deutlich breiter
  gutter: 3cm,

  // ------------------------------------------
  // LINKE SPALTE: Ebene 1 (Modell)
  // ------------------------------------------
  block[
    #align(center)[
      #text(size: 36pt, weight: "bold", fill: col-ebene1)[Ebene 1: Modell-Genauigkeit] \
      #text(size: 22pt, fill: rgb("64748b"))[Algorithmische Basisleistung]
    ]
    #v(2cm)

    #mm-node(
      "image",
      "Röntgen, CT & MRT",
      (
        [Sensitivität (Kranke korrekt erkannt)],
        [Spezifität (Gesunde korrekt erkannt)],
        [AUC-ROC (Gesamte Trennschärfe)],
      ),
      color: col-ebene1,
    )

    #v(1.5cm)
    #mm-node(
      "eye",
      "KI-Endoskopie",
      (
        [Live-Bild Analyse der KI-Erkennung],
        [Adenomdetektionsrate (Krebsvorstufen)],
      ),
      color: col-ebene1,
    )

    #v(1.5cm)
    #mm-node(
      "brain",
      "Sprachmodelle (LLM)",
      (
        [MedGPTEval (Medizin-Benchmark)],
        [Fehlerraten-Messung der Antworten],
      ),
      color: col-ebene1,
    )

    #v(1.5cm)
    // WICHTIG: Das Komma nach dem Text macht es zu einem Array!
    #mm-node(
      "message-square",
      "Chatbots",
      (
        [MedGPTEval (Ergebnisqualität)],
      ),
      color: col-ebene1,
    )
  ],

  // ------------------------------------------
  // MITTLERE SPALTE: Fokus-Thema (Das Zentrum!)
  // ------------------------------------------
  block[
    // ZENTRALES THEMA (Hervorgehoben durch dicken Rahmen statt Volltonfarbe)
    #block(
      fill: white,
      inset: 3cm,
      radius: 1.5cm,
      width: 100%,
      stroke: 8pt + hs-green, // Sehr dicker grüner Rahmen für den Fokus
    )[
      #align(center)[
        // Das neue Lucide-Icon (aperture), passend zu Ihrem Proposal-Logo!
        #box(image("icons/aperture.svg", height: 4em)) \
        #v(1em)
        #text(size: 48pt, weight: "bold", fill: hs-green)[KI-Bildanalyse in \ Industrie & Medizin] \
        #v(0.5em)
        #text(size: 30pt, fill: hs-green, weight: "medium")[Modelltraining & Inhouse-Architekturen]
      ]

      #v(2.5cm)

      #text(size: 32pt, weight: "bold", fill: text-dark)[1. Industrie-Transfer („ROSI“)] \
      #text(
        fill: rgb("334155"),
        size: 26pt,
      )[Die KI lernt in der Industrie, Defekte auf Baustoffen zu erkennen (Grenzebach BSH). Dieses Wissen wird transferiert, um Tumore in Röntgen & CTs zu identifizieren.]

      #v(2cm)

      #text(size: 32pt, weight: "bold", fill: text-dark)[2. Messbare Evidenz]
      #v(0.5em)
      #list(
        marker: text(fill: hs-green, size: 30pt)[✓],
        [ #text(fill: rgb("334155"), size: 26pt)[*Modell:* $F_1$-Score ($0,435$ vs. $0,387$ vom Arzt).] ],
        [ #text(fill: rgb("334155"), size: 26pt)[*Klinik:* Sensitivität $+12%$, Befundungszeit $-44%$.] ],
        [ #text(fill: rgb("334155"), size: 26pt)[*Infrastruktur:* Latenz & lokaler Datenverbleib (DSGVO Art. 9).] ],
      )
    ]

    #v(4cm)

    // UNTER DEM ZENTRUM: Ebene 3 (IT)
    #align(center)[
      #text(size: 36pt, weight: "bold", fill: col-ebene3)[Ebene 3: IT & Infrastruktur] \
      #text(size: 22pt, fill: rgb("64748b"))[Technische Umsetzung und Latenz]
    ]
    #v(1.5cm)

    #grid(
      columns: (1fr, 1fr),
      gutter: 2cm,
      mm-node(
        "message-square",
        "Chatbots",
        (
          [RAGAS (Retrieval Gen.)],
        ),
        color: col-ebene3,
      ),

      mm-node(
        "brain",
        "Sprachmodelle",
        (
          [Technology Acceptance Model (TAM)],
        ),
        color: col-ebene3,
      ),
    )
  ],

  // ------------------------------------------
  // RECHTE SPALTE: Ebene 2 (Klinik)
  // ------------------------------------------
  block[
    #align(center)[
      #text(size: 36pt, weight: "bold", fill: col-ebene2)[Ebene 2: Klinische Ebene] \
      #text(size: 22pt, fill: rgb("64748b"))[Workflow und Prozessqualität]
    ]
    #v(2cm)

    #mm-node(
      "heart-handshake",
      "Pflege-Roboter",
      (
        [Arbeitszeitentlastung (Quote)],
        [Körperliche Entlastung (Heben)],
        [Pflegequalität (Zufriedenheit)],
      ),
      color: col-ebene2,
    )

    #v(1.5cm)
    #mm-node(
      "smartphone",
      "Wearables & Apps",
      (
        [PPG (Puls/$"SpO"_2$) & EKG],
        [Akzelerometer & Temperatur],
        [EQ-5D (Lebensqualität)],
      ),
      color: col-ebene2,
    )

    #v(1.5cm)
    #mm-node(
      "bell",
      "Erinnerungssysteme",
      (
        [Adhärenzrate & Pünktlichkeit],
        [Vergessene Dosen],
      ),
      color: col-ebene2,
    )

    #v(1.5cm)
    #mm-node(
      "eye",
      "KI-Endoskopie",
      (
        [Zäkumintubationsrate (CIR)],
        [Rückzugszeit & Vorbereitung],
      ),
      color: col-ebene2,
    )

    #v(1.5cm)
    #mm-node(
      "brain",
      "Sprachmodelle",
      (
        [Klinische Validierungsstudien],
        [(Verblindet durch Fachpersonal)],
      ),
      color: col-ebene2,
    )
  ],
)
