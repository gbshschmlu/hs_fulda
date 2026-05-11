# LaTeX Template

A clean, professional LaTeX template for academic papers and theses at Hochschule Fulda.

## Structure

```
.
├── main.tex              # Main document file
├── preamble.sty         # Package configuration and setup
├── frontpage.tex        # Title page
├── abstract.tex         # Abstract section
├── declaration.tex      # Declaration of authorship
├── README.md            # This file
├── chapters/            # Chapter files
│   ├── ch1_introduction.tex
│   └── ch2_content.tex
├── bib/                 # Bibliography
│   └── references.bib
└── assets/              # Images and other assets
    └── img/
```

## Usage

1. Update `preamble.sty` with your document metadata (title, author, keywords, etc.)
2. Customize `frontpage.tex` with your document details
3. Add your content to chapter files in the `chapters/` folder
4. Add bibliography entries to `bib/references.bib`
5. Compile with: `pdflatex main.tex` or `lualatex main.tex`

## Features

- Professional typography with Libertine font
- 25mm margins (standard for German academic documents)
- 1.5-line spacing
- IEEE bibliography style
- Proper German language support
- PDF metadata support
- Customizable header/footer

## Requirements

- LaTeX distribution (TeX Live, MiKTeX, or similar)
- Biber for bibliography processing
- Python packages: `pdfx` (for PDF/A compliance)

## Notes

- All paths reference the `hs_fulda_logo.png` in the `assets/img/` folder
- Uncomment additional chapters in `main.tex` as needed
- The template uses 12pt font size and A4 paper format
