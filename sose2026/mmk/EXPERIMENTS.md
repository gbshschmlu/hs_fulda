# Codec Experiments and Design Decisions

This document records the small experiments used to choose the final codec parameters. The final design deliberately stays within the course scope: modulo differencing, simple I/P frames, scalar quantization, RLE, and optional Huffman coding. It uses no DCT, motion estimation, motion vectors, or B-frames.

## 1. Experimental setup

The first 12 frames of the official 1280×720 Y4M source were used as a common development sample. Together, their Y, Cb, and Cr planes contain 16,588,800 bytes. The first frame used left-neighbour spatial residuals; later frames used same-position differences to the previous frame. Container metadata and chunk length fields were excluded from the payload comparison.

The complete 300-frame video was used for the final file-size and quality measurements in the README. Measurements were run on an Apple Mac mini M4 with 24 GB RAM under macOS and Python 3.14 via `uv`.

## 2. Residual coding comparison

The zero mask writes one bit per residual and then only non-zero bytes. The PackBits-style RLE writes repeated runs of at least three equal bytes as a control byte plus one value; other bytes are grouped into literal blocks. The canonical Huffman stage is applied to the RLE byte stream and stores a 256-entry code-length table in each selected payload.

| Residual method                         | Encoded payload | Compression ratio |
| --------------------------------------- | --------------: | ----------------: |
| Zero-mask only                          | 5,629,568 bytes |            2.95:1 |
| RLE only                                | 4,912,592 bytes |            3.38:1 |
| Adaptive raw / mask / RLE               | 4,732,192 bytes |            3.51:1 |
| Adaptive raw / mask / RLE / RLE-Huffman | 4,426,508 bytes |            3.75:1 |

The final encoder calculates all valid candidates per plane and writes the smallest. On the 36 planes in this excerpt, it chose the zero mask 13 times, plain RLE 7 times, and RLE-Huffman 16 times. Huffman reduced the adaptive payload by 305,684 bytes, or 6.46%. Raw storage was not selected for this source excerpt but remains a bounded fallback for noisy inputs where the other methods would grow.

## 3. Quantization-step comparison

Three luma/chroma step pairs were tested. Each plane was quantized, reconstructed, and evaluated with full-reference PSNR. Payload sizes use the final adaptive residual coding and omit container overhead.

| Y / chroma step | Estimated payload |   Y PSNR |  Cb PSNR |  Cr PSNR | Assessment                           |
| --------------: | ----------------: | -------: | -------: | -------: | ------------------------------------ |
|           4 / 8 |   2,655,094 bytes | 46.37 dB | 40.48 dB | 40.35 dB | High quality, larger payload         |
|          8 / 16 |   1,962,209 bytes | 40.73 dB | 34.66 dB | 34.98 dB | Selected middle setting              |
|         16 / 32 |   1,349,213 bytes | 34.89 dB | 27.94 dB | 29.93 dB | Strong posterization and colour loss |

The 4/8 setting costs 35.3% more payload than 8/16. The 16/32 setting saves another 31.2%, but luma PSNR falls by nearly 6 dB and chroma reaches only about 28–30 dB. Steps 8 for Y and 16 for Cb/Cr therefore provide the clearest middle rate-distortion trade-off. The maximum rounding errors are 4 for Y and 8 for Cb/Cr.

## 4. Final design

| Decision           | Selected solution                                       | Reason                                                                 |
| ------------------ | ------------------------------------------------------- | ---------------------------------------------------------------------- |
| Temporal structure | Previous-frame differences; I-frame every 30 frames     | Demonstrates temporal compression without motion estimation or B-frames |
| Spatial coding     | Left-neighbour modulo-256 residuals for I-frames         | Simple, reversible, and produces repeated small residuals              |
| Entropy coding     | Smallest of raw, zero mask, RLE, and RLE-Huffman         | Uses only self-written methods and avoids a poor fixed choice           |
| Lossy quantization | Y step 8, chroma step 16                                 | Measured compromise between payload size and visible quality           |

## 5. Limitations

The development comparison uses one early 12-frame excerpt. Different material with more noise, movement, or scene cuts can select other payload methods and may favour other quantization steps. The raw fallback limits expansion but does not make this sample representative of all video. For that reason, the complete 300-frame measurements in the README are the authoritative final evaluation.
