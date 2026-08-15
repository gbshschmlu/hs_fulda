from __future__ import annotations

import unittest

import numpy as np

from main import (
    Frame,
    Y4MMetadata,
    decode_lossless,
    decode_lossy,
    decode_plane_payload,
    encode_lossless,
    encode_lossy,
    encode_plane_payload,
)


class CodecTests(unittest.TestCase):
    def setUp(self) -> None:
        self.metadata = Y4MMetadata(8, 4, "30:1", "p", "1:1", "420jpeg")
        rng = np.random.default_rng(42)
        sample_count = self.metadata.y_plane_size + 2 * self.metadata.uv_plane_size
        base = rng.integers(0, 256, sample_count, dtype=np.uint8)
        self.frames = []
        for frame_index in range(35):
            samples = ((base.astype(np.uint16) + frame_index) % 256).astype(np.uint8)
            y_end = self.metadata.y_plane_size
            cb_end = y_end + self.metadata.uv_plane_size
            self.frames.append(
                Frame(
                    y=samples[:y_end].tobytes(),
                    cb=samples[y_end:cb_end].tobytes(),
                    cr=samples[cb_end:].tobytes(),
                )
            )

    def test_lossless_round_trip_across_gop_boundary(self) -> None:
        metadata, frames = decode_lossless(encode_lossless(self.metadata, self.frames))
        self.assertEqual(metadata, self.metadata)
        self.assertEqual(frames, self.frames)

    def test_lossy_round_trip_has_bounded_quantization_error(self) -> None:
        metadata, frames = decode_lossy(encode_lossy(self.metadata, self.frames))
        self.assertEqual(metadata, self.metadata)
        self.assertEqual(len(frames), len(self.frames))

        for source, reconstructed in zip(self.frames, frames):
            for source_plane, decoded_plane, bound in zip(
                (source.y, source.cb, source.cr),
                (reconstructed.y, reconstructed.cb, reconstructed.cr),
                (4, 8, 8),
            ):
                difference = np.frombuffer(source_plane, dtype=np.uint8).astype(
                    np.int16
                )
                difference -= np.frombuffer(decoded_plane, dtype=np.uint8).astype(
                    np.int16
                )
                self.assertLessEqual(int(np.max(np.abs(difference))), bound)

    def test_sparse_and_raw_plane_payloads_round_trip(self) -> None:
        for values in (
            np.zeros(64, dtype=np.uint8),
            np.arange(64, dtype=np.uint8),
        ):
            payload = encode_plane_payload(values)
            np.testing.assert_array_equal(
                decode_plane_payload(payload, values.size), values
            )

    def test_truncated_bitstream_is_rejected(self) -> None:
        bitstream = encode_lossless(self.metadata, self.frames[:1])
        with self.assertRaises(ValueError):
            decode_lossless(bitstream[:-1])


if __name__ == "__main__":
    unittest.main()
