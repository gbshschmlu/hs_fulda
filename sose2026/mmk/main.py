from __future__ import annotations

import struct
from dataclasses import dataclass
from pathlib import Path

import numpy as np
from tqdm import tqdm

SOURCE_FILE = Path("source.y4m")
OUTPUT_DIR = Path("output")

LOSSLESS_BIN_FILE = OUTPUT_DIR / "lossless.bin"
LOSSLESS_Y4M_FILE = OUTPUT_DIR / "lossless_reconstructed.y4m"

LOSSY_BIN_FILE = OUTPUT_DIR / "lossy.bin"
LOSSY_Y4M_FILE = OUTPUT_DIR / "lossy_reconstructed.y4m"


# ============================================================================
# Data model
# Students edit: no | purpose: store metadata and decoded frame planes
# ============================================================================


@dataclass
class Y4MMetadata:
    width: int
    height: int
    fps: str
    interlacing: str
    aspect_ratio: str
    chroma: str

    @property
    def y_plane_size(self) -> int:
        return self.width * self.height

    @property
    def uv_plane_size(self) -> int:
        if self.chroma != "420jpeg":
            raise ValueError("This scaffold only supports C420jpeg")
        return (self.width // 2) * (self.height // 2)


@dataclass
class Frame:
    y: bytes
    cb: bytes
    cr: bytes


# ============================================================================
# File system
# Students edit: no | purpose: create the output directory
# ============================================================================


def ensure_output_directory() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)


# ============================================================================
# Y4M I/O
# Students edit: no | purpose: read input Y4M and write reconstructed Y4M
# ============================================================================


def parse_y4m_header(header_line: str) -> Y4MMetadata:
    parts = header_line.strip().split()

    if not parts or parts[0] != "YUV4MPEG2":
        raise ValueError("Invalid Y4M header")

    values: dict[str, str] = {
        "F": "25:1",
        "I": "p",
        "A": "1:1",
        "C": "420jpeg",
    }

    for part in parts[1:]:
        values[part[0]] = part[1:]

    if "W" not in values or "H" not in values:
        raise ValueError("Missing width or height in Y4M header")

    return Y4MMetadata(
        width=int(values["W"]),
        height=int(values["H"]),
        fps=values["F"],
        interlacing=values["I"],
        aspect_ratio=values["A"],
        chroma=values["C"],
    )


def read_y4m(path: Path) -> tuple[Y4MMetadata, list[Frame]]:
    with path.open("rb") as file:
        metadata = parse_y4m_header(file.readline().decode("ascii"))
        frames: list[Frame] = []

        while True:
            frame_marker = file.readline()
            if not frame_marker:
                break

            if not frame_marker.startswith(b"FRAME"):
                raise ValueError("Invalid frame marker in Y4M file")

            y = file.read(metadata.y_plane_size)
            cb = file.read(metadata.uv_plane_size)
            cr = file.read(metadata.uv_plane_size)

            if len(y) != metadata.y_plane_size:
                raise ValueError("Unexpected end of file while reading Y plane")
            if len(cb) != metadata.uv_plane_size:
                raise ValueError("Unexpected end of file while reading Cb plane")
            if len(cr) != metadata.uv_plane_size:
                raise ValueError("Unexpected end of file while reading Cr plane")

            frames.append(Frame(y=y, cb=cb, cr=cr))

    return metadata, frames


def write_y4m(path: Path, metadata: Y4MMetadata, frames: list[Frame]) -> None:
    header = (
        f"YUV4MPEG2 "
        f"W{metadata.width} "
        f"H{metadata.height} "
        f"F{metadata.fps} "
        f"I{metadata.interlacing} "
        f"A{metadata.aspect_ratio} "
        f"C{metadata.chroma}\n"
    )

    with path.open("wb") as file:
        file.write(header.encode("ascii"))

        for frame in frames:
            file.write(b"FRAME\n")
            file.write(frame.y)
            file.write(frame.cb)
            file.write(frame.cr)


# ============================================================================
# Bitstream I/O
# Students edit: no | purpose: save and load encoded binary data
# ============================================================================


def write_bitstream(path: Path, bitstream: bytes) -> None:
    path.write_bytes(bitstream)


def read_bitstream(path: Path) -> bytes:
    return path.read_bytes()


# ============================================================================
# Binary helpers
# Students edit: no | purpose: simplify custom container parsing
# ============================================================================


class ByteReader:
    def __init__(self, data: bytes) -> None:
        self.data = data
        self.offset = 0

    def read_bytes(self, length: int) -> bytes:
        chunk = self.data[self.offset : self.offset + length]
        if len(chunk) != length:
            raise ValueError("Unexpected end of bitstream")
        self.offset += length
        return chunk

    def read_u32(self) -> int:
        return struct.unpack("<I", self.read_bytes(4))[0]

    def read_u8(self) -> int:
        return self.read_bytes(1)[0]

    def read_text(self) -> str:
        return self.read_bytes(self.read_u32()).decode("ascii")


def append_u32(buffer: bytearray, value: int) -> None:
    buffer.extend(struct.pack("<I", value))


def append_text(buffer: bytearray, value: str) -> None:
    encoded = value.encode("ascii")
    append_u32(buffer, len(encoded))
    buffer.extend(encoded)


def pack_metadata(buffer: bytearray, metadata: Y4MMetadata) -> None:
    append_u32(buffer, metadata.width)
    append_u32(buffer, metadata.height)
    append_text(buffer, metadata.fps)
    append_text(buffer, metadata.interlacing)
    append_text(buffer, metadata.aspect_ratio)
    append_text(buffer, metadata.chroma)


def unpack_metadata(reader: ByteReader) -> Y4MMetadata:
    return Y4MMetadata(
        width=reader.read_u32(),
        height=reader.read_u32(),
        fps=reader.read_text(),
        interlacing=reader.read_text(),
        aspect_ratio=reader.read_text(),
        chroma=reader.read_text(),
    )


# ============================================================================
# Student helpers
# Students edit: yes | purpose: add helper functions for your codec
# ============================================================================

GOP_SIZE = 30
LOSSY_Y_STEP = 8
LOSSY_CHROMA_STEP = 16

I_FRAME = 0
P_FRAME = 1

RAW_PAYLOAD = 0
ZERO_MASK_PAYLOAD = 1


def append_chunk(buffer: bytearray, payload: bytes) -> None:
    append_u32(buffer, len(payload))
    buffer.extend(payload)


def read_chunk(reader: ByteReader) -> bytes:
    return reader.read_bytes(reader.read_u32())


def plane_layout(metadata: Y4MMetadata) -> tuple[tuple[int, int], ...]:
    """Return ``(sample count, row width)`` for Y, Cb and Cr."""
    return (
        (metadata.y_plane_size, metadata.width),
        (metadata.uv_plane_size, metadata.width // 2),
        (metadata.uv_plane_size, metadata.width // 2),
    )


def spatial_residual(values: np.ndarray, row_width: int) -> np.ndarray:
    """Predict each sample from its left neighbour, wrapping modulo 256."""
    # The left value is simple, but it gives many zeros in flat picture areas
    rows = values.reshape(-1, row_width)
    residual = np.empty_like(rows)
    residual[:, 0] = rows[:, 0]
    np.subtract(rows[:, 1:], rows[:, :-1], out=residual[:, 1:])
    return residual.reshape(-1)


def reconstruct_spatial(residual: np.ndarray, row_width: int) -> np.ndarray:
    rows = residual.reshape(-1, row_width)
    reconstructed = np.cumsum(rows, axis=1, dtype=np.uint32)
    return np.bitwise_and(reconstructed, 0xFF).astype(np.uint8).reshape(-1)


def temporal_residual(values: np.ndarray, reference: np.ndarray) -> np.ndarray:
    """Subtract the previous reconstructed frame modulo 256."""
    # P-frames use the last reconstructed frame, so both sides use same data
    residual = np.empty_like(values)
    np.subtract(values, reference, out=residual)
    return residual


def reconstruct_temporal(residual: np.ndarray, reference: np.ndarray) -> np.ndarray:
    reconstructed = np.empty_like(residual)
    np.add(residual, reference, out=reconstructed)
    return reconstructed


def encode_plane_payload(values: np.ndarray) -> bytes:
    """Choose raw bytes or a bitmap followed by only non-zero samples."""
    # Bitmap is normally smaller for prediction residuals, raw is safer for noise
    nonzero = values != 0
    mask = np.packbits(nonzero, bitorder="little").tobytes()
    sparse_values = values[nonzero].tobytes()

    if len(mask) + len(sparse_values) < values.size:
        return bytes((ZERO_MASK_PAYLOAD,)) + mask + sparse_values
    return bytes((RAW_PAYLOAD,)) + values.tobytes()


def decode_plane_payload(payload: bytes, sample_count: int) -> np.ndarray:
    if not payload:
        raise ValueError("Empty plane payload")

    payload_type = payload[0]
    if payload_type == RAW_PAYLOAD:
        if len(payload) != sample_count + 1:
            raise ValueError("Invalid raw plane payload size")
        return np.frombuffer(payload, dtype=np.uint8, offset=1).copy()

    if payload_type != ZERO_MASK_PAYLOAD:
        raise ValueError(f"Unknown plane payload type: {payload_type}")

    mask_size = (sample_count + 7) // 8
    if len(payload) < 1 + mask_size:
        raise ValueError("Truncated zero-mask payload")

    packed_mask = np.frombuffer(payload, dtype=np.uint8, count=mask_size, offset=1)
    nonzero = np.unpackbits(packed_mask, bitorder="little", count=sample_count).astype(
        bool
    )
    sparse_values = np.frombuffer(payload, dtype=np.uint8, offset=1 + mask_size)
    if sparse_values.size != np.count_nonzero(nonzero):
        raise ValueError("Zero-mask payload contains the wrong number of samples")

    values = np.zeros(sample_count, dtype=np.uint8)
    values[nonzero] = sparse_values
    return values


def quantize_plane(plane: bytes, step: int) -> np.ndarray:
    values = np.frombuffer(plane, dtype=np.uint8).astype(np.uint16)
    return ((values + step // 2) // step).astype(np.uint8)


def dequantize_plane(codes: np.ndarray, step: int) -> bytes:
    values = np.minimum(codes.astype(np.uint16) * step, 255)
    return values.astype(np.uint8).tobytes()


def validate_codec_metadata(metadata: Y4MMetadata) -> None:
    if metadata.chroma != "420jpeg":
        raise ValueError("Only C420jpeg input is supported")
    if metadata.width <= 0 or metadata.height <= 0:
        raise ValueError("Frame dimensions must be positive")
    if metadata.width % 2 or metadata.height % 2:
        raise ValueError("C420jpeg requires even frame dimensions")


# ============================================================================
# Student bitstream
# Students edit: yes | purpose: define your own binary format
# ============================================================================


def pack_lossless_bitstream(metadata: Y4MMetadata, frames: list[Frame]) -> bytes:
    """Encode I/P frames using spatial/temporal prediction without loss."""
    validate_codec_metadata(metadata)
    output = bytearray()
    output.extend(b"LS01")
    pack_metadata(output, metadata)
    append_u32(output, len(frames))
    append_u32(output, GOP_SIZE)

    previous_planes: tuple[np.ndarray, ...] | None = None
    layout = plane_layout(metadata)
    for frame_index, frame in enumerate(
        tqdm(frames, desc="Lossless encode", unit="frame")
    ):
        frame_type = I_FRAME if frame_index % GOP_SIZE == 0 else P_FRAME
        output.append(frame_type)
        current_planes = tuple(
            np.frombuffer(plane, dtype=np.uint8)
            for plane in (frame.y, frame.cb, frame.cr)
        )

        for plane_index, (values, (_, row_width)) in enumerate(
            zip(current_planes, layout)
        ):
            if frame_type == I_FRAME:
                residual = spatial_residual(values, row_width)
            else:
                if previous_planes is None:
                    raise ValueError("P-frame has no reference frame")
                residual = temporal_residual(values, previous_planes[plane_index])
            append_chunk(output, encode_plane_payload(residual))

        previous_planes = current_planes

    return bytes(output)


def unpack_lossless_bitstream(data: bytes) -> tuple[Y4MMetadata, list[Frame]]:
    """Decode and validate the custom lossless container."""
    reader = ByteReader(data)
    if reader.read_bytes(4) != b"LS01":
        raise ValueError("Invalid lossless container")

    metadata = unpack_metadata(reader)
    validate_codec_metadata(metadata)
    frame_count = reader.read_u32()
    gop_size = reader.read_u32()
    if gop_size == 0:
        raise ValueError("Invalid GOP size")

    frames: list[Frame] = []
    previous_planes: tuple[np.ndarray, ...] | None = None
    layout = plane_layout(metadata)
    for frame_index in tqdm(range(frame_count), desc="Lossless decode", unit="frame"):
        frame_type = reader.read_u8()
        expected_type = I_FRAME if frame_index % gop_size == 0 else P_FRAME
        if frame_type != expected_type:
            raise ValueError("Unexpected frame type in lossless bitstream")

        decoded_planes: list[np.ndarray] = []
        for plane_index, (sample_count, row_width) in enumerate(layout):
            residual = decode_plane_payload(read_chunk(reader), sample_count)
            if frame_type == I_FRAME:
                values = reconstruct_spatial(residual, row_width)
            else:
                if previous_planes is None:
                    raise ValueError("P-frame has no reference frame")
                values = reconstruct_temporal(residual, previous_planes[plane_index])
            decoded_planes.append(values)

        previous_planes = tuple(decoded_planes)
        frames.append(Frame(*(plane.tobytes() for plane in decoded_planes)))

    if reader.offset != len(data):
        raise ValueError("Trailing data in lossless bitstream")

    return metadata, frames


def pack_lossy_bitstream(metadata: Y4MMetadata, frames: list[Frame]) -> bytes:
    """Encode quantized I/P frames using the same prediction structure."""
    validate_codec_metadata(metadata)
    output = bytearray()
    output.extend(b"LY01")
    pack_metadata(output, metadata)
    append_u32(output, len(frames))
    append_u32(output, GOP_SIZE)
    append_u32(output, LOSSY_Y_STEP)
    append_u32(output, LOSSY_CHROMA_STEP)

    previous_codes: tuple[np.ndarray, ...] | None = None
    layout = plane_layout(metadata)
    steps = (LOSSY_Y_STEP, LOSSY_CHROMA_STEP, LOSSY_CHROMA_STEP)
    for frame_index, frame in enumerate(
        tqdm(frames, desc="Lossy encode", unit="frame")
    ):
        frame_type = I_FRAME if frame_index % GOP_SIZE == 0 else P_FRAME
        output.append(frame_type)
        # Quantize first, otherwise encoder and decoder would not share P-frame references
        current_codes = tuple(
            quantize_plane(plane, step)
            for plane, step in zip((frame.y, frame.cb, frame.cr), steps)
        )

        for plane_index, (codes, (_, row_width)) in enumerate(
            zip(current_codes, layout)
        ):
            if frame_type == I_FRAME:
                residual = spatial_residual(codes, row_width)
            else:
                if previous_codes is None:
                    raise ValueError("P-frame has no reference frame")
                residual = temporal_residual(codes, previous_codes[plane_index])
            append_chunk(output, encode_plane_payload(residual))

        previous_codes = current_codes

    return bytes(output)


def unpack_lossy_bitstream(data: bytes) -> tuple[Y4MMetadata, list[Frame]]:
    """Decode quantized I/P frames and reconstruct valid Y4M samples."""
    reader = ByteReader(data)
    if reader.read_bytes(4) != b"LY01":
        raise ValueError("Invalid lossy container")

    metadata = unpack_metadata(reader)
    validate_codec_metadata(metadata)
    frame_count = reader.read_u32()
    gop_size = reader.read_u32()
    y_step = reader.read_u32()
    chroma_step = reader.read_u32()
    if gop_size == 0 or not 1 <= y_step <= 255 or not 1 <= chroma_step <= 255:
        raise ValueError("Invalid lossy codec parameters")

    frames: list[Frame] = []
    previous_codes: tuple[np.ndarray, ...] | None = None
    layout = plane_layout(metadata)
    steps = (y_step, chroma_step, chroma_step)
    for frame_index in tqdm(range(frame_count), desc="Lossy decode", unit="frame"):
        frame_type = reader.read_u8()
        expected_type = I_FRAME if frame_index % gop_size == 0 else P_FRAME
        if frame_type != expected_type:
            raise ValueError("Unexpected frame type in lossy bitstream")

        decoded_codes: list[np.ndarray] = []
        for plane_index, (sample_count, row_width) in enumerate(layout):
            residual = decode_plane_payload(read_chunk(reader), sample_count)
            if frame_type == I_FRAME:
                codes = reconstruct_spatial(residual, row_width)
            else:
                if previous_codes is None:
                    raise ValueError("P-frame has no reference frame")
                codes = reconstruct_temporal(residual, previous_codes[plane_index])
            decoded_codes.append(codes)

        previous_codes = tuple(decoded_codes)
        reconstructed = tuple(
            dequantize_plane(codes, step) for codes, step in zip(decoded_codes, steps)
        )
        frames.append(Frame(*reconstructed))

    if reader.offset != len(data):
        raise ValueError("Trailing data in lossy bitstream")

    return metadata, frames


# ============================================================================
# Student codec
# Students edit: yes | purpose: implement lossless and lossy coding
# ============================================================================


def encode_lossless(metadata: Y4MMetadata, frames: list[Frame]) -> bytes:
    """Encode frames without changing a single sample."""
    return pack_lossless_bitstream(metadata, frames)


def decode_lossless(bitstream: bytes) -> tuple[Y4MMetadata, list[Frame]]:
    """Reconstruct the exact original frames."""
    return unpack_lossless_bitstream(bitstream)


def encode_lossy(metadata: Y4MMetadata, frames: list[Frame]) -> bytes:
    """Encode frames with coarser chroma than luma quantization."""
    return pack_lossy_bitstream(metadata, frames)


def decode_lossy(bitstream: bytes) -> tuple[Y4MMetadata, list[Frame]]:
    """Reconstruct playable, quantized Y4M frames."""
    return unpack_lossy_bitstream(bitstream)


# ============================================================================
# Pipeline
# Students edit: no | purpose: run both encode/decode pipelines automatically
# ============================================================================


def run_lossless_pipeline(metadata: Y4MMetadata, frames: list[Frame]) -> None:
    bitstream = encode_lossless(metadata, frames)
    write_bitstream(LOSSLESS_BIN_FILE, bitstream)

    decoded_metadata, decoded_frames = decode_lossless(
        read_bitstream(LOSSLESS_BIN_FILE)
    )
    write_y4m(LOSSLESS_Y4M_FILE, decoded_metadata, decoded_frames)


def run_lossy_pipeline(metadata: Y4MMetadata, frames: list[Frame]) -> None:
    bitstream = encode_lossy(metadata, frames)
    write_bitstream(LOSSY_BIN_FILE, bitstream)

    decoded_metadata, decoded_frames = decode_lossy(read_bitstream(LOSSY_BIN_FILE))
    write_y4m(LOSSY_Y4M_FILE, decoded_metadata, decoded_frames)


# ============================================================================
# Entry point
# Students edit: no | purpose: execute the full workflow
# ============================================================================


def main() -> None:
    ensure_output_directory()

    metadata, frames = read_y4m(SOURCE_FILE)

    run_lossless_pipeline(metadata, frames)
    run_lossy_pipeline(metadata, frames)

    print("Finished.")
    print(f"Created: {LOSSLESS_BIN_FILE}")
    print(f"Created: {LOSSLESS_Y4M_FILE}")
    print(f"Created: {LOSSY_BIN_FILE}")
    print(f"Created: {LOSSY_Y4M_FILE}")


if __name__ == "__main__":
    main()
