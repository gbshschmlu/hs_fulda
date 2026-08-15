# Codec Experiments and Design Decisions

This document records the alternatives tested during development and explains why some of them were discarded. It is self-contained: the experimental development directories and scripts are not required to understand, run, or submit the final codec.

## 1. Experimental setup

The first 12 frames of the official 1280×720 Y4M source were used as a common sample. They contain 16,588,800 bytes of uncompressed Y, Cb, and Cr payload. Using the same excerpt made size and runtime differences directly comparable without repeatedly processing the full video.

For the residual-coding comparison, the first frame was stored without a temporal reference. Later frames were subtracted from their predecessors at the same sample positions. Container metadata and length fields were excluded because they are identical or nearly identical for both methods. The experiment therefore isolates the actual residual representation.

The full 300-frame video was used after selecting the final design. Full-video file sizes and quality measurements are reported in the README.

All benchmarks and performance evaluations were executed on an Apple Mac mini M4 (24 GB RAM) under macOS and Python 3.14 via `uv`. Processing times on other hardware configurations may vary accordingly.

## 2. Attempt 1: PackBits-style run-length encoding

### Idea

The first implementation used a self-written PackBits-style run-length encoder. A run of at least three identical bytes was represented by a control byte and the repeated value. Values that did not form useful runs were grouped into literal blocks.

Unlike zero-only RLE, this method can compress repeated residual values other than zero. This is useful in areas with constant brightness changes or repeated spatial gradients.

### Result

|       Raw sample | Encoded payload | Compression ratio | Processing time |
| ---------------: | --------------: | ----------------: | --------------: |
| 16,588,800 bytes | 4,849,259 bytes |            3.42:1 |         0.974 s |

### Why it was discarded

PackBits produced the smallest residual payload in this comparison, but the implementation had to inspect runs byte by byte in Python. The 12-frame excerpt already required almost one second for this single stage. Extrapolated to 300 frames and both codec modes, this would noticeably slow the otherwise simple pipeline.

The additional compression did not justify the much higher processing cost for this assignment, whose goal is a clear and reliable demonstration of spatial and temporal compression rather than maximum efficiency. PackBits was therefore rejected as the final entropy representation.

## 3. Attempt 2: Fixed non-zero bitmap

### Idea

The second implementation creates one bit for every residual sample. A set bit means that the residual is non-zero. The mask is followed by the non-zero residual bytes in raster order. NumPy can create the mask and select the residuals using vectorized operations, so no Python-level sample loop is necessary.

### Result

|       Raw sample | Encoded payload | Compression ratio | Processing time |
| ---------------: | --------------: | ----------------: | --------------: |
| 16,588,800 bytes | 6,098,886 bytes |            2.72:1 |         0.004 s |

The bitmap payload was about 25.8% larger than the PackBits result, but the measured processing time was roughly 240 times lower. It is particularly effective for temporal residuals because unchanged samples become zero.

### Problem found during testing

A fixed bitmap always costs one additional bit per sample. It can therefore enlarge noisy I-frames or residual planes with few zero values. This behaviour would make the codec less robust on source material different from the official video.

### Final modification

The final codec encodes each plane both conceptually as raw residual bytes and as a bitmap payload, compares their exact sizes, and writes the smaller representation. A one-byte method field tells the decoder which representation was selected. This adaptive fallback retains the bitmap's speed while guaranteeing that the mask itself cannot enlarge a plane by more than the one-byte method identifier.

This modified bitmap approach was selected for the final implementation.

## 4. Attempt 3: Quantization-step comparison

Three luma/chroma quantization pairs were tested for the lossy mode. Each plane was rounded to the nearest quantization level, reconstructed, and compared with the original. Estimated payload sizes use temporal prediction and the adaptive bitmap representation selected above.

| Y / chroma step | Estimated payload |   Y PSNR |  Cb PSNR |  Cr PSNR | Assessment                                           |
| --------------: | ----------------: | -------: | -------: | -------: | ---------------------------------------------------- |
|           4 / 8 |   4,593,578 bytes | 46.37 dB | 40.48 dB | 40.35 dB | High quality, but smallest additional size reduction |
|          8 / 16 |   4,145,621 bytes | 40.73 dB | 34.66 dB | 34.98 dB | Balanced middle setting                              |
|         16 / 32 |   3,828,914 bytes | 34.89 dB | 27.94 dB | 29.93 dB | Strong posterization and colour loss                 |

### Why 4/8 was not selected

This setting gave the best objective quality. However, its estimated payload was about 10.8% larger than the 8/16 result. The visual improvement was less important than demonstrating a clearly measurable difference between the lossless and lossy outputs.

### Why 16/32 was discarded

Compared with 8/16, the coarsest setting saved only another 316,707 bytes, or about 7.6%, in the sample. At the same time, luma PSNR fell by nearly 6 dB and chroma PSNR reached only about 28–30 dB. The resulting colour contouring and detail loss were too distracting for the modest additional reduction.

### Selected setting

Steps 8 for Y and 16 for Cb/Cr were chosen as the middle trade-off. Luma remains above 40 dB PSNR in both the sample and full-video evaluation, while coarser chroma quantization creates enough repeated codes to improve compression noticeably. The larger chroma step also reflects the lower sensitivity of human vision to fine chrominance differences.

## 5. Final decision summary

| Decision           | Selected solution                                       | Alternative considered                     | Main reason                                                               |
| ------------------ | ------------------------------------------------------- | ------------------------------------------ | ------------------------------------------------------------------------- |
| Temporal structure | Previous-frame P-frames with an I-frame every 30 frames | More complex motion estimation or B-frames | A simple I/P structure fully meets the assignment and is easier to verify |
| Spatial prediction | Left-neighbour residuals for I-frames                   | Storing complete I-frames unchanged        | Prediction creates more zero and small residuals without information loss |
| Residual payload   | Adaptive raw/bitmap representation                      | PackBits-style RLE                         | Much faster execution and bounded worst-case overhead                     |
| Lossy quantization | Y step 8, chroma step 16                                | Steps 4/8 and 16/32                        | Best measured compromise between size and visible quality                 |

## 6. Limitations of the experiments

The development comparisons use one early 12-frame excerpt. Different videos may contain more noise, camera motion, or scene cuts and may therefore favour another residual representation. The final adaptive raw fallback reduces this dependency but does not eliminate it.

The payload experiments also omit container overhead and are not intended as full codec benchmarks. They were used to choose between implementation alternatives. The authoritative final values remain the complete 300-frame measurements in the README.
