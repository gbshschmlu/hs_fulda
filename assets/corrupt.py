import re
import sys


def nuke_pdf(path: str):
    with open(path, "rb") as f:
        data = bytearray(f.read())

    size = len(data)

    # 1. PDF-Header killen
    data[0:8] = b"\x00" * 8

    # 2. xref + trailer am Ende zerstören
    match = re.search(rb"startxref\s+(\d+)", data)
    if match:
        xref_offset = int(match.group(1))
        corrupt_len = size - xref_offset
        data[xref_offset:] = b"\x00" * corrupt_len

    # 3. Alle "obj"-Einträge im Body mit Müll füllen
    for m in re.finditer(rb"\d+ \d+ obj", data):
        start = m.start()
        end = min(start + 64, size)
        data[start:end] = b"\xff" * (end - start)

    # 4. %%EOF wegmachen
    eof_idx = data.rfind(b"%%EOF")
    if eof_idx != -1:
        data[eof_idx : eof_idx + 5] = b"\x00" * 5

    out = path.replace(".pdf", "_nuked.pdf")
    with open(out, "wb") as f:
        f.write(data)

    print(f"Fertig: {out}")


nuke_pdf(sys.argv[1])
