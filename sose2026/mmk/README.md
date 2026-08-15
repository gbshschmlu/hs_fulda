# Video Codec Project

**Course:** Multimedia-Kommunikation (AI1033)

**Term:** Summer Semester 2026

**Group:** Gruppe 4

**Members:** Thomas Krasel, Florian Ruppel, Luca Michael Schmidt, Roman Walter Sippel

This project implements a small educational video codec for `C420jpeg` Y4M files. It uses a custom binary container, periodic intra-coded frames, predicted frames, and self-written residual coding. No general-purpose compressor or external video codec is used by the pipeline.

## Running the project

Place the official input at `source.y4m` in the project root and run:

```bash
uv run main.py
```

The program creates `output/` automatically and writes:

- `lossless.bin`
- `lossless_reconstructed.y4m`
- `lossy.bin`
- `lossy_reconstructed.y4m`

Both reconstructed Y4M files can be opened in VLC. The implementation requires Python 3.14 and obtains NumPy and tqdm through `uv`. Matplotlib and Ruff are optional development dependencies and can be installed with `uv sync --extra dev`; they are not used for compression.

## 1. Architecture

All integer fields use little-endian byte order. Text is ASCII and consists of a 32-bit byte count followed by that number of bytes.

### 1.1 File header

| Field              |     Size | Description                                                   |
| ------------------ | -------: | ------------------------------------------------------------- |
| Magic              |  4 bytes | `LS01` for lossless or `LY01` for lossy                       |
| Width              |  4 bytes | Luma width in samples                                         |
| Height             |  4 bytes | Luma height in samples                                        |
| FPS                | variable | Length-prefixed Y4M frame-rate text                           |
| Interlacing        | variable | Length-prefixed Y4M interlacing text                          |
| Aspect ratio       | variable | Length-prefixed Y4M aspect-ratio text                         |
| Chroma             | variable | Length-prefixed chroma identifier; only `420jpeg` is accepted |
| Frame count        |  4 bytes | Number of encoded frames                                      |
| GOP size           |  4 bytes | Distance between I-frames; currently 30 frames                |
| Quantization steps |  8 bytes | Lossy only: 32-bit Y step followed by 32-bit chroma step      |

The metadata is sufficient to restore a standards-compliant Y4M header. Unknown magic values, invalid dimensions, unsupported chroma layouts, malformed payload lengths, unexpected frame types, and trailing bytes are rejected by the decoder.

### 1.2 Frame organization and payload

Each Group of Pictures starts with an I-frame. At 30 fps and a GOP size of 30, every second begins with an independently decodable reference frame. All frames between two I-frames are P-frames predicted from the immediately preceding reconstructed frame.

```text
frame type (1 byte: 0 = I, 1 = P)
├── Y payload length (4 bytes)  + Y payload
├── Cb payload length (4 bytes) + Cb payload
└── Cr payload length (4 bytes) + Cr payload
```

Every plane payload begins with a one-byte coding method:

- `0` stores all residual bytes directly.
- `1` stores a one-bit non-zero mask for every residual sample, followed by only the non-zero bytes in raster order.
- `2` uses a PackBits-style run-length representation with repeated runs and literal blocks.
- `3` applies canonical Huffman coding to the RLE byte stream. Its header stores the RLE length, 256 code lengths, the encoded bit count, and the packed bits.

The encoder creates these candidates and selects the smallest representation independently for each plane. Huffman is only used when its code table is worth the overhead; trees requiring codes longer than 15 bits are skipped. Raw storage bounds the worst case for noisy data. All four representations are self-written and lossless. Plane dimensions are derived from the header, so sample counts do not need to be repeated in each frame.

## 2. Algorithms

### 2.1 Lossless mode

For an I-frame, each sample is predicted from its left neighbour. The first sample of each row is predicted from zero. The stored residual is

```text
residual = (current - prediction) modulo 256
```

This is spatial compression because smooth horizontal areas produce many zero residuals inside one image. The decoder restores a row using a cumulative sum modulo 256.

For a P-frame, the sample at the same position in the previous frame is the prediction. Unchanged image areas therefore become zero. The previous frame is always an already reconstructed reference, and unsigned modulo-256 arithmetic makes subtraction and addition exactly reversible. Periodic I-frames bound dependencies and allow decoding to recover at the next GOP after damaged data.

The residual is then encoded with the adaptive representation described above. RLE groups repeated residual bytes, and optional canonical Huffman coding gives frequent RLE symbols shorter codes. This final stage is lossless and was implemented directly rather than delegated to `zlib`, `gzip`, FFmpeg, or another codec.

![Lossless original on the left and reconstruction on the right](assets/lossless_comparison.png)

![Lossless reconstruction difference map](assets/lossless_diff.png)

The lossless error map is completely black because the reconstructed Y plane has zero absolute difference from the original frame. The image is included as a visual check in addition to the byte-exact round-trip test.

### 2.2 Lossy mode

The input already uses YCbCr 4:2:0, so chroma has one quarter of the spatial resolution of luma. The lossy encoder additionally performs uniform scalar quantization:

```text
Y code     = round(Y / 8)
Cb/Cr code = round(Cb/Cr / 16)
```

The decoder multiplies these codes by their steps and clips the result to the byte range. Chroma receives the coarser step because human vision is generally more sensitive to luminance detail than to small colour differences. Quantization also makes neighbouring and consecutive samples more likely to share the same code, which improves RLE and Huffman coding.

Spatial and temporal differencing are then applied to the quantized codes exactly as in lossless mode. P-frames reference the previous quantized code planes, not the original input. Encoder and decoder therefore use identical references and do not accumulate quantization drift. This intentionally simple design uses no DCT, transform blocks, motion estimation, motion vectors, or B-frames.

## 3. Evaluation

The following measurements use the official 300-frame, 1280×720, 30 fps `source.y4m`. The Y4M container stores uncompressed sample planes, but its `C420jpeg` input already has 4:2:0 chroma subsampling and therefore only one Cb and one Cr sample per 2×2 luma area. Compression ratio is defined as `original size / encoded size`; MB uses 1,000,000 bytes.

All benchmarks and performance evaluations were executed on an Apple Mac mini M4 (24 GB RAM) under macOS and Python 3.14 via `uv`. Processing times on other hardware configurations may vary accordingly.

### 3.1 Size comparison

| File / mode    | Size (bytes) | Size (MB) | Compression ratio | Size reduction |
| -------------- | -----------: | --------: | ----------------: | -------------: |
| `source.y4m`   |  414,721,883 |    414.72 |            1.00:1 |          0.00% |
| `lossless.bin` |  113,359,496 |    113.36 |            3.66:1 |         72.67% |
| `lossy.bin`    |   54,748,873 |     54.75 |            7.57:1 |         86.80% |

A streaming byte comparison confirmed that all 300 decoded lossless Y, Cb, and Cr planes exactly match the source. The reconstructed Y4M file is 35 bytes smaller only because the writer normalizes the Y4M header and omits optional source tags; its actual frame payload is identical.

The lossy reconstruction produced these objective sample-domain results:

| Plane |    MSE |     PSNR | Maximum absolute error |
| ----- | -----: | -------: | ---------------------: |
| Y     |  5.536 | 40.70 dB |                      4 |
| Cb    | 23.263 | 34.46 dB |                      8 |
| Cr    | 21.742 | 34.76 dB |                      8 |

MSE and PSNR were calculated over every sample of every reconstructed plane as full-reference metrics:

```text
MSE  = sum((source - reconstruction)²) / sample count
PSNR = 10 × log10(255² / MSE)
```

The maximum errors follow directly from rounding to the nearest quantization level: half of step 8 for Y and half of step 16 for Cb/Cr. PSNR quantifies sample error but does not fully describe human perception, so the objective values are complemented by side-by-side images and difference maps. No MOS is reported because no controlled test with multiple participants was performed.

### 3.2 Visual artifact analysis

![Original on the left and lossy reconstruction on the right](assets/lossy_comparison.png)

The original is shown on the left and the lossy reconstruction on the right. The most noticeable artifacts are posterization and colour banding in smooth gradients, especially in the tree and dark green background. Fine colour texture is simplified, and some coloured edges look harsher. These effects follow from the 16-value chroma quantization step combined with the source's existing 4:2:0 chroma subsampling. Luma retains more detail because its step is only 8.

Classical 8×8 blocking is not expected because this codec performs no block transform. Temporal ghosting is also limited: prediction changes representation and file size but does not discard additional temporal residuals. This trades compression efficiency for a simple, stable, and explainable I/P-frame pipeline.

![Lossy reconstruction difference map](assets/lossy_diff.png)

The Lossy difference map shows the quantization error in the reconstructed Y plane. Unlike the lossless map, it contains visible values because the lossy mode intentionally changes samples to reduce the payload size.

### 3.3 Experimental Design Rationale & Benchmarks

The first 12 frames of the official source were used as a common development sample. They contain 16,588,800 bytes of Y, Cb, and Cr payload. The first frame used left-neighbour spatial differencing and later frames used same-position differences to their predecessors. Container metadata and chunk length fields were excluded so the comparison isolates the plane payloads. The complete 300-frame video was then used for the authoritative measurements in section 3.1.

All benchmarks and performance evaluations were executed on an Apple Mac mini M4 (24 GB RAM) under macOS and Python 3.14 via `uv`. Processing times on other hardware configurations may vary accordingly.

#### Adaptive residual coding

The self-written PackBits-style RLE stores runs of at least three equal bytes as a control byte and one value; other values are grouped into literal blocks. The zero mask is effective for sparse residuals, while RLE can also represent repeated non-zero values. Canonical Huffman coding is tested only after RLE and stores its code lengths in the payload, allowing the decoder to reconstruct the same codes without an external table.

| Residual method                         | Encoded payload | Compression ratio |
| --------------------------------------- | --------------: | ----------------: |
| Zero-mask only                          | 5,629,568 bytes |            2.95:1 |
| RLE only                                | 4,912,592 bytes |            3.38:1 |
| Adaptive raw / mask / RLE               | 4,732,192 bytes |            3.51:1 |
| Adaptive raw / mask / RLE / RLE-Huffman | 4,426,508 bytes |            3.75:1 |

On the 36 planes in this excerpt, the final encoder selected the zero mask 13 times, plain RLE 7 times, and RLE-Huffman 16 times. Raw storage was not needed for this source excerpt but remains a safe fallback for other material. Huffman reduced the adaptive payload by another 305,684 bytes (6.46%) without changing reconstruction quality.

![Residual payload comparison](assets/performance_comparison.png)

#### Quantization-step sweep

Three luma/chroma step pairs were tested for lossy mode. For each pair, the planes were rounded to the nearest quantization level, reconstructed, and evaluated with PSNR. The payload estimates use the final adaptive residual representation; container overhead is excluded from this small comparison.

| Y / chroma step | Estimated payload |   Y PSNR |  Cb PSNR |  Cr PSNR | Assessment                              |
| --------------: | ----------------: | -------: | -------: | -------: | --------------------------------------- |
|           4 / 8 |   2,655,094 bytes | 46.37 dB | 40.48 dB | 40.35 dB | High quality, but the payload is larger |
|          8 / 16 |   1,962,209 bytes | 40.73 dB | 34.66 dB | 34.98 dB | Balanced middle setting                 |
|         16 / 32 |   1,349,213 bytes | 34.89 dB | 27.94 dB | 29.93 dB | Strong posterization and colour loss    |

The 4/8 setting had the best objective quality, but its payload was 35.3% larger than the 8/16 result. The 16/32 setting saved another 612,996 bytes (31.2%), while luma PSNR dropped by nearly 6 dB and chroma PSNR reached only about 28–30 dB. Steps 8 for Y and 16 for Cb/Cr were selected as the middle rate-distortion trade-off: luma stays above 40 dB PSNR while the coarser chroma step improves entropy coding without excessive visible colour contouring.

![Quantization payload and PSNR trade-off](assets/quantization_tradeoff.png)

The experiments have limits. They use one early 12-frame excerpt, so videos with more noise, camera movement, or scene cuts may favour another residual representation. The adaptive raw fallback reduces this dependency but does not remove it. Both the excerpt and full-video measurements are full-reference tests because the complete source samples are available; the excerpt is only a smaller development sample. The final measurements in section 3.1 remain authoritative.

## 4. Verification

The implementation was checked with synthetic round-trip tests across a GOP boundary, dedicated RLE and canonical Huffman round-trips, malformed payload tests, a complete run on the official source, byte-exact lossless payload hashing, and full-video lossy MSE/PSNR calculation. The codec itself only uses Python, NumPy, and tqdm; Matplotlib is used solely by the optional asset-generation script.

```bash
uv run --extra dev python -m unittest discover -s tests -p 'test_*.py'
uv run --extra dev ruff check main.py tests
uv run --extra dev python tests/generate_assets.py source.y4m
```
