# Sinh hình tạm (SVG) cho các mỏ tài nguyên theo lượng còn lại (GAME_DESIGN mục 9.2):
# bụi quả, bãi sỏi, đống củi, đá tảng (to / nhỏ) — mỗi loại 3 mức: _100 (còn > 50%),
# _50 (20–50%), _20 (< 20%); bụi quả thêm _empty (trụi, chờ ra quả lại).
# Cùng một loại giữ nguyên dáng / khung hình giữa các mức để đổi hình không bị nhảy.
#   python tools/gen_resource_art.py
import math
import os
import random

OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "placeholder", "env")
OUTLINE = "#4E342E"


def write(name, body, w, h, comment):
    path = os.path.join(OUT, name + ".svg")
    text = (f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">\n'
            f"  <!-- {comment} -->\n" + "".join("  " + line + "\n" for line in body) + "</svg>\n")
    with open(path, "w", encoding="utf-8") as f:
        f.write(text)


# --- Bụi quả to: tán lá nhiều khối, quả mọc thành chùm 3 quả ---

BUSH_W, BUSH_H = 192, 160
BUSH_BLOBS = [(52, 104, 40), (140, 104, 40), (96, 70, 50), (96, 108, 44), (64, 74, 34), (130, 72, 34)]
BUSH_CLUSTERS = [(58, 78), (96, 52), (132, 70), (146, 108), (74, 120), (110, 100), (40, 112), (100, 132), (122, 46)]


def bush(stage):
    body = [f'<ellipse cx="96" cy="146" rx="78" ry="12" fill="#3E2723" opacity="0.18"/>']
    for fill, grow in ((OUTLINE, 6), ("#558B2F", 0), ("#7CB342", -14)):
        body.append(f'<g fill="{fill}">')
        for x, y, r in BUSH_BLOBS:
            if r + grow > 4:
                dx, dy = (-4, -6) if grow < 0 else (0, 0)
                body.append(f'  <circle cx="{x + dx}" cy="{y + dy}" r="{r + grow}"/>')
        body.append("</g>")
    # Mức quả: đầy 9 chùm, vừa 4 chùm, ít 2 chùm, trụi thì chỉ còn cuống.
    count = {"100": 9, "50": 4, "20": 2, "empty": 0}[stage]
    order = [0, 4, 1, 6, 2, 7, 3, 5, 8]
    for index in order[:count]:
        cx, cy = BUSH_CLUSTERS[index]
        for dx, dy in ((-6, 0), (6, 0), (0, 9)):
            body.append(f'<circle cx="{cx + dx}" cy="{cy + dy}" r="7.5" fill="#E53935" stroke="{OUTLINE}" stroke-width="3"/>')
            body.append(f'<circle cx="{cx + dx - 2}" cy="{cy + dy - 2.5}" r="2" fill="#FFFFFF" opacity="0.85"/>')
    if stage == "empty":
        for cx, cy in BUSH_CLUSTERS[:6]:
            body.append(f'<circle cx="{cx}" cy="{cy}" r="2.5" fill="#33691E"/>')
    names = {"100": "đầy quả", "50": "còn nửa", "20": "còn ít", "empty": "đã hái trụi, chờ ra quả lại"}
    write(f"bush_{stage}", body, BUSH_W, BUSH_H, f"Bụi quả to — {names[stage]}")


# --- Bãi sỏi: nền sỏi vụn + nhiều viên đá cuội to nhỏ ---

PATCH_W, PATCH_H = 160, 96


def pebbles(stage):
    rng = random.Random(7)
    spots = []
    while len(spots) < 18:
        angle = rng.uniform(0, math.tau)
        dist = math.sqrt(rng.random())
        x = 80 + math.cos(angle) * dist * 60
        y = 58 + math.sin(angle) * dist * 22
        if all((x - a) ** 2 + ((y - b) * 1.8) ** 2 > 150 for a, b, _ in spots):
            spots.append((x, y, rng.uniform(6, 11)))
    # Viên gần tâm còn lại lâu nhất (nhặt dần từ rìa vào).
    spots.sort(key=lambda s: (s[0] - 80) ** 2 + ((s[1] - 58) * 2.5) ** 2)
    keep = {"100": 18, "50": 9, "20": 4}[stage]
    scale = {"100": 1.0, "50": 0.72, "20": 0.45}[stage]
    body = [f'<ellipse cx="80" cy="62" rx="{70 * scale:.1f}" ry="{26 * scale:.1f}" fill="#A1887F" opacity="0.35"/>']
    for i in range(int(30 * scale)):
        x = 80 + rng.uniform(-62, 62) * scale
        y = 60 + rng.uniform(-20, 20) * scale
        body.append(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="{rng.uniform(1.2, 2.4):.1f}" fill="#8D8D8D"/>')
    colors = ["#9E9E9E", "#BDBDBD", "#B0A89F", "#A8A29A"]
    for x, y, r in sorted(spots[:keep], key=lambda s: s[1]):
        fill = colors[int(x + y) % len(colors)]
        body.append(f'<ellipse cx="{x:.1f}" cy="{y:.1f}" rx="{r:.1f}" ry="{r * 0.68:.1f}" fill="{fill}" stroke="{OUTLINE}" stroke-width="2.6"/>')
        body.append(f'<ellipse cx="{x - r * 0.3:.1f}" cy="{y - r * 0.28:.1f}" rx="{r * 0.32:.1f}" ry="{r * 0.17:.1f}" fill="#FFFFFF" opacity="0.6"/>')
    write(f"pebbles_{stage}", body, PATCH_W, PATCH_H, f"Bãi sỏi (đá cuội, nhặt tay) — còn {stage}%")


# --- Đống củi: nhiều cành khô bắt chéo, vài lá xanh ---

def twigs(stage):
    rng = random.Random(11)
    sticks = []
    for i in range(12):
        cx = 80 + rng.uniform(-38, 38)
        cy = 60 + rng.uniform(-14, 14)
        angle = rng.uniform(-0.5, 0.5) + (math.pi / 2 if i % 3 == 2 else 0) * 0.55
        length = rng.uniform(34, 56)
        sticks.append((cx, cy, angle, length))
    sticks.sort(key=lambda s: (s[0] - 80) ** 2 + ((s[1] - 60) * 2.5) ** 2)
    keep = {"100": 12, "50": 6, "20": 3}[stage]
    scale = {"100": 1.0, "50": 0.75, "20": 0.5}[stage]
    chosen = sticks[:keep]
    body = [f'<ellipse cx="80" cy="70" rx="{64 * scale:.1f}" ry="{14 * scale:.1f}" fill="#3E2723" opacity="0.22"/>']
    for color, width in ((OUTLINE, 9), ("#8D6E63", 4.6)):
        body.append(f'<g stroke="{color}" stroke-width="{width}" stroke-linecap="round">')
        for cx, cy, angle, length in chosen:
            dx = math.cos(angle) * length / 2
            dy = math.sin(angle) * length / 2 * 0.6
            body.append(f'  <path d="M{cx - dx:.1f} {cy - dy:.1f} L{cx + dx:.1f} {cy + dy:.1f}"/>')
        body.append("</g>")
    for cx, cy, angle, length in chosen[: max(1, keep // 4)]:
        lx = cx + math.cos(angle) * length * 0.42
        ly = cy + math.sin(angle) * length * 0.25 - 6
        body.append(f'<ellipse cx="{lx:.1f}" cy="{ly:.1f}" rx="6" ry="3.5" fill="#7CB342" stroke="{OUTLINE}" stroke-width="2"/>')
    write(f"twigs_{stage}", body, 160, 96, f"Đống củi (cành khô rụng dưới tán cây, nhặt tay) — còn {stage}%")


# --- Đá tảng: cùng dáng, càng đập càng nhỏ và sứt mẻ, đá vụn dưới chân ---

ROCKS = {
    "big": (160, 128, "M22 100 C10 80 18 50 44 38 C58 18 96 14 116 30 C140 38 152 66 144 92 C140 108 120 114 80 114 C50 114 30 112 22 100 Z",
            "M46 46 C60 30 92 26 108 38 C96 40 70 44 58 60 C52 56 48 52 46 46 Z", 114),
    "small": (112, 88, "M16 70 C8 54 16 32 36 26 C48 12 76 12 88 26 C102 34 106 54 98 68 C92 78 76 80 56 80 C36 80 22 78 16 70 Z",
              "M34 34 C44 22 66 20 76 28 C66 30 50 34 42 44 C38 42 35 38 34 34 Z", 80),
}


def rock(size, stage):
    w, h, shape, light, foot = ROCKS[size]
    scale = {"100": 1.0, "50": 0.8, "20": 0.58}[stage]
    cx = w / 2
    body = [f'<ellipse cx="{cx}" cy="{foot - 2}" rx="{w * 0.4:.1f}" ry="{h * 0.08:.1f}" fill="#3E2723" opacity="0.18"/>']
    transform = f'transform="translate({cx * (1 - scale):.1f} {foot * (1 - scale):.1f}) scale({scale})"'
    body.append(f'<g {transform}>')
    body.append(f'  <path d="{shape}" fill="#9E9E9E" stroke="{OUTLINE}" stroke-width="{6 / scale:.1f}" stroke-linejoin="round"/>')
    body.append(f'  <path d="{light}" fill="#BDBDBD"/>')
    if stage != "100":
        # Chỗ sứt mẻ: một mảng tối + vết nứt.
        body.append(f'  <path d="M{w * 0.62:.0f} {h * 0.3:.0f} l{w * 0.14:.0f} {h * 0.06:.0f} l-{w * 0.04:.0f} {h * 0.16:.0f} Z" fill="#757575"/>')
        body.append(f'  <path d="M{w * 0.45:.0f} {h * 0.45:.0f} l{w * 0.08:.0f} {h * 0.1:.0f} l-{w * 0.05:.0f} {h * 0.12:.0f}" fill="none" '
                    f'stroke="#616161" stroke-width="{4 / scale:.1f}" stroke-linecap="round" stroke-linejoin="round"/>')
    body.append("</g>")
    rubble = {"100": [], "50": [(-0.36, 3), (0.34, 4)], "20": [(-0.38, 4), (0.3, 5), (0.4, 3), (-0.22, 3)]}[stage]
    for dx, r in rubble:
        x = cx + dx * w
        y = foot - 4
        body.append(f'<ellipse cx="{x:.1f}" cy="{y:.1f}" rx="{r * 1.4:.1f}" ry="{r:.1f}" fill="#9E9E9E" stroke="{OUTLINE}" stroke-width="2.5"/>')
    names = {"big": "Tảng đá lớn", "small": "Tảng đá nhỏ"}
    write(f"rock_{size}_{stage}", body, w, h, f"{names[size]} (cần cuốc) — còn {stage}%")


def main():
    for stage in ("100", "50", "20", "empty"):
        bush(stage)
    for stage in ("100", "50", "20"):
        pebbles(stage)
        twigs(stage)
        rock("big", stage)
        rock("small", stage)


main()
