from __future__ import annotations

import sys
from pathlib import Path

import matplotlib

matplotlib.use("Agg")

import matplotlib.pyplot as plt
import numpy as np

PROJECT_ROOT = Path(__file__).resolve().parents[1]
ASSET_DIR = PROJECT_ROOT / "assets"
DEFAULT_SOURCE_FILE = PROJECT_ROOT / "source.y4m"
LOSSLESS_RECONSTRUCTION = PROJECT_ROOT / "output" / "lossless_reconstructed.y4m"
LOSSY_RECONSTRUCTION = PROJECT_ROOT / "output" / "lossy_reconstructed.y4m"


def read_first_frame(path: Path) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    with path.open("rb") as file:
        header = file.readline().decode("ascii").split()
        if not header or header[0] != "YUV4MPEG2":
            raise ValueError(f"Invalid Y4M header in {path}")

        fields = {part[0]: part[1:] for part in header[1:]}
        width = int(fields["W"])
        height = int(fields["H"])
        if not file.readline().startswith(b"FRAME"):
            raise ValueError(f"Missing first frame in {path}")

        y_size = width * height
        uv_size = (width // 2) * (height // 2)
        y_plane = file.read(y_size)
        cb_plane = file.read(uv_size)
        cr_plane = file.read(uv_size)
        if (
            len(y_plane) != y_size
            or len(cb_plane) != uv_size
            or len(cr_plane) != uv_size
        ):
            raise ValueError(f"Incomplete first Y plane in {path}")
        return (
            np.frombuffer(y_plane, dtype=np.uint8).reshape(height, width),
            np.frombuffer(cb_plane, dtype=np.uint8).reshape(height // 2, width // 2),
            np.frombuffer(cr_plane, dtype=np.uint8).reshape(height // 2, width // 2),
        )


def read_first_y_plane(path: Path) -> np.ndarray:
    return read_first_frame(path)[0]


def ycbcr_to_rgb(frame: tuple[np.ndarray, np.ndarray, np.ndarray]) -> np.ndarray:
    y_plane, cb_plane, cr_plane = frame
    cb_up = np.repeat(np.repeat(cb_plane, 2, axis=0), 2, axis=1).astype(np.float32)
    cr_up = np.repeat(np.repeat(cr_plane, 2, axis=0), 2, axis=1).astype(np.float32)
    y_values = y_plane.astype(np.float32)
    red = y_values + 1.402 * (cr_up - 128.0)
    green = y_values - 0.344136 * (cb_up - 128.0) - 0.714136 * (cr_up - 128.0)
    blue = y_values + 1.772 * (cb_up - 128.0)
    return np.clip(np.stack((red, green, blue), axis=-1), 0, 255).astype(np.uint8)


def create_comparison(
    original_path: Path, reconstruction_path: Path, output_name: str
) -> None:
    original = ycbcr_to_rgb(read_first_frame(original_path))
    reconstructed = ycbcr_to_rgb(read_first_frame(reconstruction_path))
    comparison = np.concatenate((original, reconstructed), axis=1)
    plt.imsave(ASSET_DIR / output_name, comparison)


def create_diff_image(
    original_path: Path,
    reconstruction_path: Path,
    output_name: str,
    mode_name: str,
    require_zero: bool,
) -> None:
    original = read_first_y_plane(original_path)
    reconstructed = read_first_y_plane(reconstruction_path)
    if original.shape != reconstructed.shape:
        raise ValueError("Original and reconstructed frame shapes differ")

    difference = np.abs(original.astype(np.int16) - reconstructed.astype(np.int16))
    maximum_difference = int(np.max(difference))
    if require_zero and maximum_difference != 0:
        raise ValueError("Lossless difference image is not zero")

    figure, axes = plt.subplots(1, 3, figsize=(14, 4), constrained_layout=True)
    axes[0].imshow(original, cmap="gray", vmin=0, vmax=255)
    axes[0].set_title(f"{mode_name} original Y plane")
    axes[1].imshow(reconstructed, cmap="gray", vmin=0, vmax=255)
    axes[1].set_title(f"{mode_name} reconstructed Y plane")
    difference_limit = 1 if require_zero else max(1, maximum_difference)
    axes[2].imshow(difference, cmap="magma", vmin=0, vmax=difference_limit)
    axes[2].set_title(f"{mode_name} absolute difference max = {maximum_difference}")
    for axis in axes:
        axis.axis("off")
    figure.savefig(ASSET_DIR / output_name, dpi=160)
    plt.close(figure)


def create_performance_comparison() -> None:
    methods = ["Zero mask", "RLE", "Adaptive", "+ Huffman"]
    payload_mb = np.array([5.629568, 4.912592, 4.732192, 4.426508])
    compression_ratios = np.array([2.9467, 3.3768, 3.5055, 3.7476])
    colors = ["#4C78A8", "#F58518", "#54A24B", "#B279A2"]

    figure, axes = plt.subplots(1, 2, figsize=(10, 4.5), constrained_layout=True)
    payload_bars = axes[0].bar(methods, payload_mb, color=colors)
    axes[0].set_title("Encoded residual payload")
    axes[0].set_ylabel("MB")
    axes[0].tick_params(axis="x", rotation=18)

    ratio_bars = axes[1].bar(methods, compression_ratios, color=colors)
    axes[1].set_title("Compression ratio")
    axes[1].set_ylabel("Original / encoded size")
    axes[1].tick_params(axis="x", rotation=18)

    for axis, bars, values, suffix in (
        (axes[0], payload_bars, payload_mb, " MB"),
        (axes[1], ratio_bars, compression_ratios, ":1"),
    ):
        for bar, value in zip(bars, values):
            axis.text(
                bar.get_x() + bar.get_width() / 2,
                bar.get_height(),
                f"{value:g}{suffix}",
                ha="center",
                va="bottom",
                fontsize=9,
            )

    figure.savefig(ASSET_DIR / "performance_comparison.png", dpi=160)
    plt.close(figure)


def create_quantization_tradeoff() -> None:
    labels = np.array(["4 / 8", "8 / 16", "16 / 32"])
    payload_mb = np.array([2.655094, 1.962209, 1.349213])
    psnr_values = {
        "Y": np.array([46.37, 40.73, 34.89]),
        "Cb": np.array([40.48, 34.66, 27.94]),
        "Cr": np.array([40.35, 34.98, 29.93]),
    }

    figure, axis = plt.subplots(figsize=(8, 5), constrained_layout=True)
    for plane, values in psnr_values.items():
        axis.plot(payload_mb, values, marker="o", linewidth=2, label=plane)
        if plane == "Y":
            for x_value, y_value, label in zip(payload_mb, values, labels):
                axis.annotate(
                    label,
                    (x_value, y_value),
                    textcoords="offset points",
                    xytext=(0, 7),
                    ha="center",
                    fontsize=8,
                )

    axis.set_title("Quantization payload and PSNR trade-off")
    axis.set_xlabel("Estimated payload size (MB)")
    axis.set_ylabel("PSNR (dB)")
    axis.grid(True, alpha=0.3)
    axis.legend(title="Plane")
    figure.savefig(ASSET_DIR / "quantization_tradeoff.png", dpi=160)
    plt.close(figure)


def main() -> None:
    source_file = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_SOURCE_FILE
    ASSET_DIR.mkdir(parents=True, exist_ok=True)
    create_comparison(source_file, LOSSLESS_RECONSTRUCTION, "lossless_comparison.png")
    create_comparison(source_file, LOSSY_RECONSTRUCTION, "lossy_comparison.png")
    create_diff_image(
        source_file,
        LOSSLESS_RECONSTRUCTION,
        "lossless_diff.png",
        "Lossless",
        require_zero=True,
    )
    create_diff_image(
        source_file,
        LOSSY_RECONSTRUCTION,
        "lossy_diff.png",
        "Lossy",
        require_zero=False,
    )
    create_performance_comparison()
    create_quantization_tradeoff()
    print("Created benchmark assets")


if __name__ == "__main__":
    main()
