from __future__ import annotations

import csv
from pathlib import Path

import matplotlib.pyplot as plt


ROOT = Path(__file__).resolve().parent
CASES = ROOT.parent / "sammelsorium" / "cases"
OUT = ROOT / "assets" / "img"
OUT.mkdir(parents=True, exist_ok=True)


def read_csv(path: Path) -> list[dict[str, str]]:
    with path.open(newline="", encoding="utf-8") as f:
        return list(csv.DictReader(f))


def save_case2() -> None:
    rows = read_csv(
        CASES
        / "case2_ram_disk_spof"
        / "results"
        / "case2_disk_usage_timeseries.csv"
    )
    t = [float(r["t_rel_s"]) for r in rows]
    usage = [float(r["images_out_mb"]) for r in rows]
    baseline = usage[0]
    growth = [u - baseline for u in usage]

    fig, ax = plt.subplots(figsize=(6.6, 3.7))
    ax.plot(t, growth, color="#1f4e79", linewidth=2.2)
    ax.fill_between(t, growth, color="#1f4e79", alpha=0.10)

    ax.set_title("Case 2: Bildverzeichnis wächst kontinuierlich", pad=10)
    ax.set_xlabel("Zeit seit Messbeginn [s]")
    ax.set_ylabel("Zuwachs Images/Out [MB]")
    ax.grid(axis="y", color="#d9d9d9", linewidth=0.8)
    ax.spines[["top", "right"]].set_visible(False)
    ax.set_xlim(0, max(t))
    ax.set_ylim(0, max(growth) * 1.18)

    end_x = t[-1]
    end_y = growth[-1]
    ax.scatter([end_x], [end_y], color="#1f4e79", s=28, zorder=3)
    ax.annotate(
        f"+{end_y:.1f} MB im Messfenster",
        xy=(end_x, end_y),
        xytext=(end_x - 20, end_y * 0.78),
        arrowprops={"arrowstyle": "->", "color": "#1f4e79", "lw": 1},
        fontsize=9,
        color="#1f4e79",
    )
    ax.text(
        0.02,
        0.94,
        "Relevanter Befund: keine Begrenzung/Rotation sichtbar",
        transform=ax.transAxes,
        fontsize=9,
        va="top",
        bbox={"boxstyle": "round,pad=0.3", "fc": "#f4f7fb", "ec": "#b9c7d6"},
    )

    fig.tight_layout()
    fig.savefig(OUT / "case2_image_out_usage.pdf")
    plt.close(fig)


def save_case3() -> None:
    rows = read_csv(
        CASES
        / "case3_log_queue_cascade"
        / "results"
        / "queue_depth_timeseries.csv"
    )
    t = [float(r["t_rel_s"]) for r in rows]
    q = [float(r["qsize"]) for r in rows]

    freeze_start = 9.6
    freeze_end = 40.0
    queue_max = 1000

    fig, ax = plt.subplots(figsize=(6.6, 3.7))
    ax.axvspan(freeze_start, freeze_end, color="#f2c0c0", alpha=0.45, linewidth=0)
    ax.plot(t, q, color="#1f4e79", linewidth=1.8, marker="o", markersize=2.5)
    ax.hlines(
        queue_max,
        freeze_start,
        freeze_end,
        color="#902020",
        linewidth=2.4,
        linestyles="--",
    )
    ax.vlines(
        [freeze_start, freeze_end],
        0,
        queue_max,
        color="#902020",
        linewidth=0.9,
        alpha=0.7,
    )

    ax.set_title("Case 3: blockierendes Logging hält die Pipeline an", pad=10)
    ax.set_xlabel("Zeit seit Messbeginn [s]")
    ax.set_ylabel("Log-Queue-Tiefe")
    ax.set_xlim(0, max(t))
    ax.set_ylim(0, 1080)
    ax.grid(axis="y", color="#d9d9d9", linewidth=0.8)
    ax.spines[["top", "right"]].set_visible(False)

    ax.text(
        (freeze_start + freeze_end) / 2,
        900,
        "Logger angehalten\nQueue voll (abgeleitet)\nPipeline blockiert",
        ha="center",
        va="center",
        fontsize=9,
        color="#902020",
        bbox={"boxstyle": "round,pad=0.35", "fc": "#fff4f4", "ec": "#d49a9a"},
    )
    ax.annotate(
        "nach Freigabe\nschnell wieder leer",
        xy=(40.2, 6),
        xytext=(32, 230),
        arrowprops={"arrowstyle": "->", "color": "#1f4e79", "lw": 1},
        fontsize=9,
        color="#1f4e79",
    )
    ax.text(
        0.02,
        0.08,
        "Messpunkte nahe 0: Normalbetrieb",
        transform=ax.transAxes,
        fontsize=9,
        color="#1f4e79",
        bbox={"boxstyle": "round,pad=0.3", "fc": "#f4f7fb", "ec": "#b9c7d6"},
    )

    fig.tight_layout()
    fig.savefig(OUT / "case3_queue_depth.pdf")
    plt.close(fig)


def main() -> None:
    save_case2()
    save_case3()
    print(f"plots written to {OUT}")


if __name__ == "__main__":
    main()
