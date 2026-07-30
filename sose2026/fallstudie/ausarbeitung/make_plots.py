from __future__ import annotations

import csv
from pathlib import Path

import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch, FancyBboxPatch


ROOT = Path(__file__).resolve().parent

# Farbpalette (identisch zu den Mess-Plots)
BLUE = "#1f4e79"
BLUE_BG = "#f4f7fb"
BLUE_EDGE = "#b9c7d6"
RED = "#902020"
RED_BG = "#fff4f4"
RED_EDGE = "#d49a9a"
GRAY = "#8a97a3"
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


LOGC = "#6b7887"


def save_topology() -> None:
    fig, ax = plt.subplots(figsize=(7.0, 4.6))
    ax.set_xlim(0, 10)
    ax.set_ylim(-0.3, 6)
    ax.axis("off")

    def box(cx, cy, w, h, text, *, fill, edge, tc, bold=False):
        ax.add_patch(
            FancyBboxPatch(
                (cx - w / 2, cy - h / 2),
                w,
                h,
                boxstyle="round,pad=0.02,rounding_size=0.10",
                linewidth=1.2,
                facecolor=fill,
                edgecolor=edge,
                mutation_aspect=0.7,
            )
        )
        ax.text(
            cx,
            cy,
            text,
            ha="center",
            va="center",
            fontsize=9.5,
            color=tc,
            fontweight="bold" if bold else "normal",
        )

    def arrow(p0, p1, color, *, style="-", lw=1.6, rad=0.0):
        ax.add_patch(
            FancyArrowPatch(
                p0,
                p1,
                arrowstyle="-|>",
                mutation_scale=12,
                linewidth=lw,
                linestyle=style,
                color=color,
                connectionstyle=f"arc3,rad={rad}",
                shrinkA=0,
                shrinkB=0,
            )
        )

    def flabel(x, y, text, color, size=8):
        ax.text(
            x,
            y,
            text,
            ha="center",
            va="center",
            fontsize=size,
            color=color,
            bbox={"boxstyle": "round,pad=0.15", "fc": "white", "ec": "none"},
        )

    # Supervisor
    box(5.0, 5.05, 2.5, 0.8, "main.py\nSupervisor", fill=BLUE, edge=BLUE, tc="white", bold=True)
    # Service-Prozesse (Reihenfolge = Datenfluss von links nach rechts)
    box(1.4, 3.0, 2.2, 0.95, "Inspection-\nDataHandler", fill=RED_BG, edge=RED_EDGE, tc=RED, bold=True)
    box(3.8, 3.0, 2.2, 0.95, "Frame-\nGrabber", fill=RED_BG, edge=RED_EDGE, tc=RED, bold=True)
    box(6.2, 3.0, 2.2, 0.95, "Pipeline-\nManager", fill=BLUE_BG, edge=BLUE_EDGE, tc=BLUE, bold=True)
    box(8.6, 3.0, 2.2, 0.95, "Logger-\nProcess", fill=RED_BG, edge=RED_EDGE, tc=RED, bold=True)
    # Worker-Pool
    box(6.2, 1.35, 3.6, 0.9, "MPWorkerPool: 12 Worker\nPipeline Steps 1–6 (sequenziell)", fill="white", edge=BLUE_EDGE, tc=BLUE)

    # Datenfluss (grau), Labels unter den Pfeilen
    arrow((2.5, 3.0), (2.7, 3.0), GRAY, lw=1.4)
    arrow((4.9, 3.0), (5.1, 3.0), GRAY, lw=1.4)
    arrow((6.2, 2.525), (6.2, 1.80), GRAY, lw=1.4)
    flabel(2.6, 2.55, "leere\nContainer", GRAY, size=7.5)
    flabel(5.0, 2.55, "SM-Ref.", GRAY, size=7.5)
    flabel(6.95, 2.15, "Map / Reduce", BLUE, size=7.5)

    # Gemeinsame Log-Queue: alle Prozesse (inkl. Worker) schreiben in denselben Bus,
    # der Logger-Process konsumiert daraus (siehe Pipeline.md, Abschnitt 2.4)
    bus_y = 2.15
    ax.plot([1.4, 8.6], [bus_y, bus_y], color=LOGC, lw=1.3, linestyle=(0, (4, 2.5)), zorder=1)
    for sx in (1.4, 3.8, 5.9):
        ax.plot([sx, sx], [2.525, bus_y], color=LOGC, lw=1.1, linestyle=(0, (4, 2.5)), zorder=1)
    ax.plot([6.5, 6.5], [1.80, bus_y], color=LOGC, lw=1.1, linestyle=(0, (4, 2.5)), zorder=1)
    arrow((8.6, bus_y), (8.6, 2.525), LOGC, lw=1.5)
    flabel(2.2, 1.93, "gemeinsame\nLog-Queue", LOGC, size=7.5)

    # Supervision: blau durchgezogen = ueberwacht, rot gestrichelt = keine Supervision
    arrow((5.3, 4.65), (6.2, 3.48), BLUE, lw=1.8, rad=-0.15)
    arrow((4.5, 4.65), (1.55, 3.48), RED, style=(0, (5, 3)), lw=1.4, rad=0.18)
    arrow((4.7, 4.65), (3.8, 3.48), RED, style=(0, (5, 3)), lw=1.4, rad=0.12)
    arrow((5.7, 4.65), (8.55, 3.48), RED, style=(0, (5, 3)), lw=1.4, rad=-0.18)
    flabel(6.35, 4.05, "1 s-Poll", BLUE)
    flabel(2.55, 4.35, "keine Laufzeit-\nSupervision", RED)

    # Legende (zwei Zeilen)
    y1, y2 = 0.55, 0.10
    ax.plot([0.4, 1.0], [y1, y1], color=BLUE, lw=1.8)
    ax.text(1.1, y1, "Supervision (1 s-Poll)", va="center", fontsize=8, color="#444")
    ax.plot([4.2, 4.8], [y1, y1], color=RED, lw=1.4, linestyle=(0, (5, 3)))
    ax.text(4.9, y1, "keine Supervision", va="center", fontsize=8, color="#444")
    ax.plot([0.4, 1.0], [y2, y2], color=GRAY, lw=1.4)
    ax.text(1.1, y2, "Datenfluss", va="center", fontsize=8, color="#444")
    ax.plot([4.2, 4.8], [y2, y2], color=LOGC, lw=1.3, linestyle=(0, (4, 2.5)))
    ax.text(4.9, y2, "Log-Queue (alle Prozesse)", va="center", fontsize=8, color="#444")

    fig.tight_layout()
    fig.savefig(OUT / "topology.pdf")
    plt.close(fig)


def main() -> None:
    save_case2()
    save_case3()
    save_topology()
    print(f"plots written to {OUT}")


if __name__ == "__main__":
    main()
