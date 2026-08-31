"""Convert the single supplied case-study PDF asset for PowerPoint.

The presentation intentionally contains no generated diagram bitmaps.  All
visuals are native PowerPoint objects; this small helper only rasterizes the
original Case 2 figure mechanically so PowerPoint can embed it without a PDF
viewer dependency.  No crop, recolour, redraw or aspect-ratio change is made.
"""

from __future__ import annotations

from pathlib import Path

try:
    import pymupdf
except ImportError:  # PyMuPDF 1.x exposes the legacy module name.
    import fitz as pymupdf


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "ausarbeitung" / "assets" / "img" / "case2_image_out_usage.pdf"
OUT = Path(__file__).resolve().parent / "diagrams" / "case2_image_out_usage.png"


def main() -> None:
    if not SOURCE.exists():
        raise FileNotFoundError(SOURCE)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    document = pymupdf.open(SOURCE)
    try:
        if len(document) != 1:
            raise ValueError(f"Erwartet genau eine PDF-Seite, gefunden: {len(document)}")
        page = document[0]
        # 4x is a mechanical, high-resolution rasterization of the original.
        pixmap = page.get_pixmap(matrix=pymupdf.Matrix(4, 4), alpha=False)
        pixmap.save(OUT)
    finally:
        document.close()
    print(f"converted {SOURCE.name} -> {OUT.name}")


if __name__ == "__main__":
    main()
