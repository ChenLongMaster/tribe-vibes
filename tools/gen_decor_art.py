# Sinh hình tạm (SVG) cho cây cỏ trang trí phủ kín map kiểu Prehistoric Tribes: dương xỉ, cỏ cao,
# bụi lá, lau sậy (ven hồ), nấm (dưới tán cây). Chỉ để trang trí — KHÔNG chạm được, không phải
# tài nguyên — nên cố ý vẽ khác hẳn mỏ tài nguyên: màu xanh chìm, viền xanh đậm (không viền
# nâu đậm), không có quả, không có đá.
#   python tools/gen_decor_art.py
import math
import os
import random

OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "placeholder", "env")
EDGE = "#4F7A2A"


def write(name, body, w, h, comment):
    with open(os.path.join(OUT, name + ".svg"), "w", encoding="utf-8") as f:
        f.write(f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">\n'
                f"  <!-- {comment} -->\n" + "".join("  " + line + "\n" for line in body) + "</svg>\n")


def leaf(x, y, angle, length, width, fill):
    # Lá dương xỉ: một cuống cong + răng lá hai bên.
    dx, dy = math.cos(angle), math.sin(angle)
    nx, ny = -dy, dx
    tip = (x + dx * length, y + dy * length)
    points = [(x, y)]
    steps = 6
    for i in range(1, steps):
        t = i / steps
        px, py = x + dx * length * t, y + dy * length * t
        w = width * (1 - t) * (1.15 if i % 2 else 0.8)
        points.append((px + nx * w, py + ny * w))
    points.append(tip)
    for i in range(steps - 1, 0, -1):
        t = i / steps
        px, py = x + dx * length * t, y + dy * length * t
        w = width * (1 - t) * (1.15 if i % 2 else 0.8)
        points.append((px - nx * w, py - ny * w))
    d = "M" + " L".join(f"{px:.1f} {py:.1f}" for px, py in points) + " Z"
    return f'<path d="{d}" fill="{fill}" stroke="{EDGE}" stroke-width="2.4" stroke-linejoin="round"/>'


def fern(variant):
    rng = random.Random(variant * 13)
    body = []
    base = (48, 66)
    angles = [-2.6, -2.15, -1.75, -1.4, -1.0, -0.55]
    for i, a in enumerate(angles):
        fill = "#6E9B3A" if i % 2 else "#5F8C33"
        body.append(leaf(base[0], base[1], a + rng.uniform(-0.12, 0.12), rng.uniform(36, 48), 10, fill))
    write(f"fern_{variant:02d}", body, 96, 72, "Dương xỉ trang trí (không chạm được)")


def tall_grass(variant):
    rng = random.Random(variant * 29)
    body = ['<g stroke="{0}" stroke-width="2.2" stroke-linejoin="round">'.format(EDGE)]
    for i in range(7):
        x = 14 + i * 7 + rng.uniform(-2, 2)
        top = rng.uniform(10, 30)
        lean = rng.uniform(-10, 10)
        fill = ["#7DA544", "#6E9B3A", "#88AE4C"][i % 3]
        body.append(f'  <path d="M{x - 4:.1f} 78 Q{x + lean * 0.3:.1f} {top + 20:.1f} {x + lean:.1f} {top:.1f} '
                    f'Q{x + 2 + lean * 0.2:.1f} {top + 30:.1f} {x + 4:.1f} 78 Z" fill="{fill}"/>')
    body.append("</g>")
    if variant == 2:
        # Vài bông cỏ lau khô ở ngọn.
        for x, y in ((24, 16), (44, 10), (58, 20)):
            body.append(f'<ellipse cx="{x}" cy="{y}" rx="3" ry="6" fill="#D7C78A" stroke="{EDGE}" stroke-width="1.5"/>')
    write(f"tall_grass_{variant:02d}", body, 72, 80, "Cỏ cao trang trí (không chạm được)")


def shrub(variant):
    rng = random.Random(variant * 41)
    blobs = [(30, 42, 18), (52, 36, 22), (72, 44, 17), (48, 50, 18)]
    if variant == 2:
        blobs = [(36, 40, 20), (60, 42, 20), (48, 32, 16)]
    body = [f'<g fill="{EDGE}">'] + [f'  <circle cx="{x}" cy="{y}" r="{r + 3}"/>' for x, y, r in blobs] + ["</g>"]
    body += ['<g fill="#5F8C33">'] + [f'  <circle cx="{x}" cy="{y}" r="{r}"/>' for x, y, r in blobs] + ["</g>"]
    body += ['<g fill="#76A143">'] + [f'  <circle cx="{x - 4}" cy="{y - 5}" r="{r * 0.55:.1f}"/>' for x, y, r in blobs] + ["</g>"]
    for i in range(5):
        x, y = rng.uniform(20, 80), rng.uniform(26, 54)
        body.append(f'<path d="M{x:.1f} {y:.1f} l4 -3" stroke="#4F7A2A" stroke-width="1.6" stroke-linecap="round"/>')
    write(f"shrub_{variant:02d}", body, 96, 64, "Bụi lá trang trí — không quả, không chạm được")


def reeds():
    rng = random.Random(5)
    body = []
    for i in range(6):
        x = 14 + i * 7 + rng.uniform(-2, 2)
        top = rng.uniform(12, 30)
        body.append(f'<path d="M{x:.1f} 94 L{x + rng.uniform(-4, 4):.1f} {top:.1f}" stroke="{EDGE}" stroke-width="5" stroke-linecap="round"/>')
        body.append(f'<path d="M{x:.1f} 94 L{x + rng.uniform(-4, 4):.1f} {top:.1f}" stroke="#88AE4C" stroke-width="2.4" stroke-linecap="round"/>')
        if i % 2 == 0:
            body.append(f'<ellipse cx="{x:.1f}" cy="{top + 6:.1f}" rx="3.5" ry="8" fill="#8D6E63" stroke="#5D4037" stroke-width="1.8"/>')
    write("reeds_01", body, 64, 96, "Lau sậy ven hồ (trang trí)")


def mushroom():
    body = [
        '<path d="M14 34 L14 24 L20 24 L20 34 Z" fill="#EFE6D6" stroke="#8D7B6A" stroke-width="2"/>',
        '<path d="M6 25 Q17 8 28 25 Z" fill="#C9A27A" stroke="#8D6E63" stroke-width="2.2"/>',
        '<path d="M26 34 L26 28 L30 28 L30 34 Z" fill="#EFE6D6" stroke="#8D7B6A" stroke-width="1.8"/>',
        '<path d="M22 29 Q28 18 34 29 Z" fill="#C9A27A" stroke="#8D6E63" stroke-width="2"/>',
    ]
    write("mushroom_01", body, 40, 36, "Nấm nhỏ dưới tán cây (trang trí)")


def main():
    fern(1)
    fern(2)
    tall_grass(1)
    tall_grass(2)
    shrub(1)
    shrub(2)
    reeds()
    mushroom()


main()
