# Sinh hình tạm SVG cho công trình Đợt 3 (5 công trình × 3 cấp, móng 3 cỡ) và vài icon.
# Chạy lại khi muốn chỉnh màu / chi tiết: python tools/gen_building_art.py
# Quy ước (khớp ASSET_SPEC.md + data/art_specs.gd): vẽ 2×; rộng = số ô ngang × 128; mép dưới
# hình = mép dưới diện tích công trình; điểm neo cách mép dưới 24 px (= Building.FOOT_INSET ×2).
import os

OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "placeholder")
LINE = "#4E342E"
SW = 6


def svg(w, h, body, comment=""):
    note = f"  <!-- {comment} -->\n" if comment else ""
    return f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">\n{note}{body}</svg>\n'


def write(key, text):
    path = os.path.join(OUT, key + ".svg")
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write(text)


def shadow(cx, cy, rx, ry):
    return f'  <ellipse cx="{cx}" cy="{cy}" rx="{rx}" ry="{ry}" fill="#3E2723" opacity="0.18"/>\n'


def path(d, fill, sw=SW, extra=""):
    stroke = f' stroke="{LINE}" stroke-width="{sw}" stroke-linejoin="round" stroke-linecap="round"' if sw else ""
    return f'  <path d="{d}" fill="{fill}"{stroke}{extra}/>\n'


def rect(x, y, w, h, fill, rx=8, sw=SW):
    stroke = f' stroke="{LINE}" stroke-width="{sw}"' if sw else ""
    return f'  <rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{rx}" fill="{fill}"{stroke}/>\n'


def circle(cx, cy, r, fill, sw=SW):
    stroke = f' stroke="{LINE}" stroke-width="{sw}"' if sw else ""
    return f'  <circle cx="{cx}" cy="{cy}" r="{r}" fill="{fill}"{stroke}/>\n'


def ellipse(cx, cy, rx, ry, fill, sw=SW):
    stroke = f' stroke="{LINE}" stroke-width="{sw}"' if sw else ""
    return f'  <ellipse cx="{cx}" cy="{cy}" rx="{rx}" ry="{ry}" fill="{fill}"{stroke}/>\n'


def line(x1, y1, x2, y2, color, width):
    return f'  <path d="M{x1} {y1} L{x2} {y2}" stroke="{color}" stroke-width="{width}" stroke-linecap="round" fill="none"/>\n'


def stones(points, fill="#9E9E9E"):
    out = ""
    for (x, y, r) in points:
        out += ellipse(x, y, r, r * 0.7, fill, 4)
        out += ellipse(x - r * 0.3, y - r * 0.25, r * 0.35, r * 0.2, "#BDBDBD", 0)
    return out


def flame(x, y, s=1.0):
    return (path(f"M{x} {y} C{x-14*s} {y-10*s} {x-10*s} {y-30*s} {x} {y-44*s} C{x+4*s} {y-30*s} {x+16*s} {y-22*s} {x+12*s} {y-6*s} Z", "#FF8A65", 4)
            + path(f"M{x} {y-4*s} C{x-6*s} {y-10*s} {x-4*s} {y-20*s} {x+1*s} {y-28*s} C{x+4*s} {y-18*s} {x+8*s} {y-14*s} {x+6*s} {y-6*s} Z", "#FFD54F", 0))


# --- Lều ngủ (2×2: 256 × 300) ---

def tent(level):
    w, h = 256, 300
    hide = ["#BCAAA4", "#D7A86E", "#E8B07A"][level - 1]
    b = shadow(128, 284, 118, 14)
    if level >= 2:
        b += stones([(26, 278, 12), (62, 286, 11), (100, 290, 10), (156, 290, 10), (194, 286, 11), (230, 278, 12)])
    top = [96, 70, 44][level - 1]
    # Cọc chĩa lên khỏi đỉnh lều.
    b += line(118, top - 26, 128, top + 30, "#6D4C41", 12) + line(118, top - 26, 128, top + 30, "#8D6E63", 6)
    b += line(140, top - 24, 128, top + 30, "#6D4C41", 12) + line(140, top - 24, 128, top + 30, "#8D6E63", 6)
    b += path(f"M16 272 Q70 {top + 90} 128 {top} Q186 {top + 90} 240 272 Z", hide)
    # Sọc / mảng vá.
    if level >= 2:
        b += path(f"M44 230 Q86 {top + 110} 128 {top + 40} Q170 {top + 110} 212 230", "none", 0,
                  f' stroke="#A1887F" stroke-width="10" stroke-linecap="round"')
        b += path("M58 196 l24 -6 l6 22 l-24 6 Z", "#FFB74D", 4)
        b += path("M176 206 l22 4 l-4 22 l-22 -4 Z", "#E57373", 4)
    if level >= 3:
        for i, c in enumerate(["#E57373", "#FFD54F", "#81C784", "#64B5F6"]):
            x = 64 + i * 42
            b += path(f"M{x} 248 l10 -14 l10 14 Z", c, 3)
        # Lông chim cắm trên đỉnh.
        b += path(f"M120 {top - 20} C108 {top - 52} 118 {top - 70} 126 {top - 74} C128 {top - 54} 130 {top - 36} 124 {top - 20} Z", "#FFF8E1", 4)
        b += path(f"M136 {top - 18} C150 {top - 46} 148 {top - 62} 142 {top - 70} C136 {top - 50} 132 {top - 34} 132 {top - 18} Z", "#E57373", 4)
    # Cửa lều tối, mép vén lên.
    b += path("M100 272 Q112 200 128 182 Q144 200 156 272 Z", "#4E342E", 5)
    b += path("M128 182 Q120 214 96 236 L100 272 Q108 220 128 182 Z", hide, 4)
    b += line(30, 270, 226, 270, LINE, 6)
    return svg(w, h, b, f"Lều ngủ cấp {level}")


# --- Bếp (2×2: 256 × 320) ---

def kitchen(level):
    w, h = 256, 320
    b = shadow(128, 302, 120, 14)
    roof = ["#D7B46A", "#E0BE70", "#C9A55A"][level - 1]
    # Cột.
    for x in (28, 228):
        b += rect(x - 9, 120, 18, 172, "#8D6E63", 6)
    roof_top = [110, 92, 80][level - 1]
    b += path(f"M4 150 L128 {roof_top - 40} L252 150 L236 168 L20 168 Z", roof)
    for x in range(30, 230, 26):
        b += line(x, 158, x + 6, 140, "#B8954F", 4)
    if level >= 2:
        b += path(f"M58 {roof_top - 6} L128 {roof_top - 52} L198 {roof_top - 6}", "none", 0, f' stroke="#A67C3D" stroke-width="8" stroke-linecap="round"')
    # Bếp đá + nồi.
    hearth_w = [120, 150, 170][level - 1]
    x0 = 128 - hearth_w // 2
    b += rect(x0, 236, hearth_w, 48, "#9E9E9E", 14)
    for i in range(hearth_w // 30):
        b += ellipse(x0 + 18 + i * 30, 252, 10, 6, "#BDBDBD", 0)
    b += flame(128, 250, 0.7)
    b += path("M92 210 Q92 248 128 248 Q164 248 164 210 Z", "#5D4037")
    b += ellipse(128, 210, 38, 10, "#8D6E63")
    b += ellipse(128, 210, 28, 6, "#FFCC80", 0)
    # Hơi bốc lên.
    b += path("M116 196 q-8 -12 0 -24 q8 -12 0 -24", "none", 0, ' stroke="#FFFFFF" stroke-width="5" stroke-linecap="round" opacity="0.8"')
    b += path("M140 196 q8 -12 0 -24 q-8 -12 0 -24", "none", 0, ' stroke="#FFFFFF" stroke-width="5" stroke-linecap="round" opacity="0.8"')
    if level >= 2:
        # Kệ hũ.
        b += rect(196, 196, 44, 10, "#8D6E63", 4)
        b += path("M200 196 q-2 -22 10 -22 q12 0 10 22 Z", "#FFB74D", 4)
        b += path("M222 196 q-2 -18 8 -18 q10 0 8 18 Z", "#E57373", 4)
    if level >= 3:
        # Lò nướng đá có ống khói.
        b += path("M16 288 L16 210 Q16 180 46 180 Q76 180 76 210 L76 288 Z", "#9E9E9E")
        b += path("M30 288 L30 228 Q30 214 46 214 Q62 214 62 228 L62 288 Z", "#4E342E", 4)
        b += flame(46, 282, 0.5)
        b += rect(36, 120, 22, 64, "#8D8D8D", 4)
        b += path("M40 112 q-8 -14 4 -24 q12 -10 4 -26", "none", 0, ' stroke="#ECEFF1" stroke-width="7" stroke-linecap="round" opacity="0.85"')
    b += line(20, 292, 236, 292, LINE, 6)
    return svg(w, h, b, f"Bếp cấp {level}")


# --- Kho (3×3: 384 × 380) ---

def logs(x, y, n, rows):
    out = ""
    for r in range(rows):
        for i in range(n - r):
            cx = x + i * 30 + r * 15
            cy = y - r * 22
            out += ellipse(cx, cy, 15, 12, "#FFCC80", 4) + ellipse(cx, cy, 6, 5, "none", 0).replace('fill="none"', 'fill="none" stroke="#BF8A5A" stroke-width="2"')
    return out


def storage(level):
    w, h = 384, 380
    b = shadow(192, 362, 176, 16)
    if level == 1:
        # Mái che dựa (lean-to) trên 3 cột, đống gỗ + đá bên dưới.
        for x in (34, 192, 350):
            b += rect(x - 9, 170, 18, 184, "#8D6E63", 6)
        b += path("M10 196 L374 150 L374 176 L10 222 Z", "#D7B46A")
        for x in range(30, 360, 28):
            b += line(x, 210 - (x - 10) * 0.126, x + 6, 190 - (x - 10) * 0.126, "#B8954F", 4)
        b += logs(70, 330, 4, 3)
        b += stones([(250, 336, 22), (290, 340, 20), (272, 310, 18), (316, 326, 16)])
    else:
        wall = "#A1887F" if level == 2 else "#8D6E63"
        top = 150 if level == 2 else 110
        if level == 3:
            b += rect(16, 300, 352, 56, "#9E9E9E", 12)
            for i in range(7):
                b += ellipse(44 + i * 50, 328, 16, 10, "#BDBDBD", 0)
        b += rect(30, top + 60, 324, (300 if level == 3 else 350) - top - 60, wall, 10)
        for x in range(54, 340, 30):
            b += line(x, top + 70, x, (296 if level == 3 else 346), "#795548", 4)
        b += path(f"M8 {top + 76} L192 {top - 20} L376 {top + 76} L352 {top + 92} L32 {top + 92} Z", "#C9A55A")
        for x in range(40, 350, 30):
            b += line(x, top + 84, x + 8, top + 62, "#A67C3D", 4)
        door_h = 110 if level == 2 else 120
        door_y = (350 if level == 2 else 300) - door_h
        if level == 3:
            b += rect(132, door_y, 120, door_h, "#5D4037", 10)
            b += line(192, door_y + 4, 192, door_y + door_h - 4, LINE, 5)
            b += line(140, door_y + 20, 244, door_y + door_h - 14, "#8D6E63", 8)
            b += path("M176 120 L192 98 L208 120 Z", "#FFD54F", 4)
        else:
            b += rect(150, door_y, 84, door_h, "#5D4037", 10)
            b += line(156, door_y + 16, 228, door_y + door_h - 12, "#8D6E63", 8)
        # Đồ chất ngoài cho thấy là kho.
        b += logs(20, 352, 3, 2)
        b += stones([(330, 350, 18), (360, 356, 14), (346, 330, 13)])
    return svg(w, h, b, f"Kho cấp {level}")


# --- Lò rèn (3×2: 384 × 320) ---

def forge(level):
    w, h = 384, 320
    b = shadow(192, 302, 178, 14)
    if level >= 2:
        for x in (30, 354):
            b += rect(x - 9, 110, 18, 184, "#8D6E63", 6)
        top = 80 if level == 3 else 96
        b += path(f"M6 130 L192 {top - 20} L378 130 L360 148 L24 148 Z", "#C9A55A" if level == 3 else "#D7B46A")
        for x in range(30, 360, 28):
            b += line(x, 140, x + 6, 122, "#A67C3D", 4)
    # Lò đá vòm bên trái, miệng lò đỏ rực.
    dome_h = [120, 140, 160][level - 1]
    b += path(f"M30 292 L30 {292 - dome_h + 50} Q30 {292 - dome_h} 96 {292 - dome_h} Q162 {292 - dome_h} 162 {292 - dome_h + 50} L162 292 Z", "#9E9E9E")
    for (x, y) in [(52, 250), (130, 240), (70, 200), (140, 196)]:
        b += ellipse(x, y, 12, 7, "#BDBDBD", 0)
    b += path("M64 292 L64 252 Q64 226 96 226 Q128 226 128 252 L128 292 Z", "#4E342E", 5)
    b += path("M72 292 L72 258 Q72 236 96 236 Q120 236 120 258 L120 292 Z", "#FF7043", 0)
    b += flame(96, 288, 0.6)
    chimney_top = [292 - dome_h - 30, 292 - dome_h - 60, 292 - dome_h - 90][level - 1]
    b += rect(80, chimney_top, 32, 292 - dome_h - chimney_top + 12, "#8D8D8D", 6)
    b += path(f"M96 {chimney_top - 8} q-10 -14 2 -26 q12 -12 2 -28", "none", 0, ' stroke="#ECEFF1" stroke-width="7" stroke-linecap="round" opacity="0.8"')
    # Đe đá ở giữa.
    b += path("M180 290 L190 252 L232 252 L242 290 Z", "#757575")
    b += path("M168 252 L176 232 L252 232 L262 252 Z", "#9E9E9E")
    if level >= 2:
        # Ống bễ da.
        b += path("M150 250 L136 232 Q120 220 116 240 Q118 258 136 260 Z", "#A1887F", 5)
    if level >= 3:
        b += path("M290 120 L290 200 L330 186 L370 200 L370 120 Z", "#E57373", 5)
        b += path("M318 150 l12 -14 l12 14 l-12 14 Z", "#FFD54F", 4)
    b += line(20, 292, 364, 292, LINE, 6)
    return svg(w, h, b, f"Lò rèn cấp {level}")


# --- Sân nhảy (3×3: 384 × 400, phẳng) ---

def dance_floor(level):
    w, h = 384, 400
    b = ""
    floor = ["#D7B48A", "#BCAAA4", "#B0BEC5"][level - 1]
    b += ellipse(192, 270, 176, 112, floor)
    if level == 1:
        b += ellipse(192, 270, 130, 80, "#C8A27A", 0)
        b += stones([(28, 270, 14), (60, 196, 13), (124, 166, 12), (260, 166, 12), (324, 196, 13), (356, 270, 14),
                     (324, 344, 13), (260, 372, 12), (124, 372, 12), (60, 344, 13)])
    elif level == 2:
        for i in range(-4, 5):
            x = 192 + i * 38
            half = (1 - (i * 38 / 176) ** 2) ** 0.5 * 108
            b += line(x, 270 - half, x, 270 + half, "#8D6E63", 4)
        # Dây cờ.
        b += path("M30 120 Q192 190 354 120", "none", 0, f' stroke="{LINE}" stroke-width="4"')
        for i, c in enumerate(["#E57373", "#FFD54F", "#81C784", "#64B5F6", "#BA68C8", "#FFB74D", "#E57373"]):
            x = 60 + i * 44
            y = 120 + 70 * (1 - ((x - 192) / 162) ** 2) * 0.85
            b += path(f"M{x - 12} {y - 4} L{x + 12} {y - 4} L{x} {y + 20} Z", c, 3)
    else:
        colors = ["#E57373", "#FFD54F", "#81C784", "#64B5F6", "#BA68C8", "#FFB74D"]
        k = 0
        for row in range(-2, 3):
            for col in range(-3, 4):
                x = 192 + col * 44
                y = 270 + row * 36
                if ((x - 192) / 160) ** 2 + ((y - 270) / 100) ** 2 > 0.85:
                    continue
                b += f'  <path d="M{x} {y - 15} L{x + 20} {y} L{x} {y + 15} L{x - 20} {y} Z" fill="{colors[k % 6]}" opacity="0.85"/>\n'
                k += 1
        # Trống da.
        b += path("M318 360 L318 320 Q340 310 362 320 L362 360 Q340 370 318 360 Z", "#A1887F", 5)
        b += ellipse(340, 320, 22, 8, "#FFF8E1", 4)
    # Đuốc hai bên.
    torches = [(30, 180), (354, 180)] if level < 3 else [(30, 180), (354, 180), (110, 130), (274, 130)]
    for (x, y) in torches:
        b += rect(x - 6, y, 12, 90, "#8D6E63", 4)
        b += flame(x, y + 4, 0.6)
    return svg(w, h, b, f"Sân nhảy cấp {level} (phẳng, đi lên được)")


def foundation(cols, rows):
    w, h = cols * 128, rows * 128
    b = rect(10, 10, w - 20, h - 20, "#C8A27A", 18, 0)
    b += f'  <rect x="10" y="10" width="{w - 20}" height="{h - 20}" rx="18" fill="none" stroke="#A1887F" stroke-width="5" stroke-dasharray="16 12"/>\n'
    # Vạch đất cào.
    for i in range(1, cols * 2):
        x = i * 64
        b += line(x - 14, h * 0.35, x + 6, h * 0.35 + 18, "#B08B66", 4)
        b += line(x + 4, h * 0.7, x + 24, h * 0.7 + 14, "#B08B66", 4)
    # Cọc + dây căng ở 4 góc.
    corners = [(22, 22), (w - 22, 22), (22, h - 22), (w - 22, h - 22)]
    b += path(f"M22 14 L{w - 22} 14 L{w - 22} {h - 30} L22 {h - 30} Z", "none", 0, ' stroke="#FFF8E1" stroke-width="3"')
    for (x, y) in corners:
        b += rect(x - 6, y - 30, 12, 34, "#8D6E63", 4, 4)
    b += stones([(w * 0.3, h * 0.55, 10), (w * 0.72, h * 0.4, 8)])
    return svg(w, h, b, f"Móng {cols}×{rows} ô (phủ đúng diện tích)")


def hard_hat():
    b = path("M10 30 Q10 0 40 -2 Q70 0 70 30 Z", "#FFD54F", 5)
    b += path("M4 32 Q40 22 76 32 L76 36 Q40 30 4 36 Z", "#FFB300", 4)
    b += path("M34 2 L46 2 L46 28 L34 28 Z", "#FFE082", 0)
    return svg(80, 80, f'  <g transform="translate(0 6)">\n{b}  </g>\n', "Mũ công trường của thợ xây (khung đầu 80×80, neo ở cổ như tóc)")


def icons():
    write("icons/warning", svg(48, 48, path("M24 4 L45 42 L3 42 Z", "#FFD54F", 3.5)
                                + path("M24 16 L24 29", "none", 0, f' stroke="{LINE}" stroke-width="5" stroke-linecap="round"')
                                + circle(24, 36, 3, LINE, 0), "Cảnh báo (thiếu người phụ trách)"))
    write("icons/storage", svg(48, 48, path("M6 20 L24 6 L42 20 Z", "#C9A55A", 3)
                                + rect(9, 20, 30, 22, "#A1887F", 3, 3)
                                + rect(19, 28, 10, 14, "#5D4037", 2, 2.5)
                                + ellipse(6, 40, 5, 4, "#FFCC80", 2.5) + ellipse(42, 40, 5, 4, "#9E9E9E", 2.5),
                                "Kho (vẽ trên biển 'kho đầy')"))
    write("icons/upgrade", svg(48, 48, path("M24 6 L42 26 L32 26 L32 42 L16 42 L16 26 L6 26 Z", "#81C784", 3.5), "Nâng cấp"))
    write("icons/check", svg(48, 48, circle(24, 24, 20, "#81C784", 3.5)
                              + path("M14 25 L21 32 L35 17", "none", 0, f' stroke="{LINE}" stroke-width="5" stroke-linecap="round" stroke-linejoin="round"'),
                              "Xác nhận"))
    write("icons/save", svg(48, 48, path("M8 8 L36 8 L42 14 L42 42 L8 42 Z", "#64B5F6", 3.5)
                             + rect(15, 8, 18, 12, "#FFF8E1", 2, 3) + rect(14, 27, 20, 15, "#FFF8E1", 2, 3), "Lưu game"))
    write("icons/load", svg(48, 48, path("M6 16 L18 16 L22 12 L42 12 L42 40 L6 40 Z", "#FFB74D", 3.5)
                             + path("M24 18 L24 34 M17 27 L24 34 L31 27", "none", 0, f' stroke="{LINE}" stroke-width="4.5" stroke-linecap="round" stroke-linejoin="round"'),
                             "Tải ván đã lưu"))
    rays = "".join(line(24 + 15 * c, 24 + 15 * s, 24 + 21 * c, 24 + 21 * s, "#FFB300", 4)
                   for (c, s) in [(1, 0), (-1, 0), (0, 1), (0, -1), (0.7, 0.7), (-0.7, 0.7), (0.7, -0.7), (-0.7, -0.7)])
    write("ui/sun", svg(48, 48, rays + circle(24, 24, 11, "#FFD54F", 3.5), "Mặt trời (đồng hồ mặt trời)"))
    write("ui/moon", svg(48, 48, path("M30 6 A18 18 0 1 0 42 32 A14 14 0 1 1 30 6 Z", "#FFF59D", 3.5), "Mặt trăng"))
    write("fx/confetti", svg(16, 24, rect(2, 2, 12, 20, "#FFFFFF", 3, 0), "Mảnh pháo giấy (tô màu bằng code)"))


def main():
    for level in (1, 2, 3):
        write(f"buildings/tent_{level}", tent(level))
        write(f"buildings/kitchen_{level}", kitchen(level))
        write(f"buildings/storage_{level}", storage(level))
        write(f"buildings/forge_{level}", forge(level))
        write(f"buildings/dance_floor_{level}", dance_floor(level))
    write("buildings/foundation_2x2", foundation(2, 2))
    write("buildings/foundation_3x2", foundation(3, 2))
    write("buildings/foundation_3x3", foundation(3, 3))
    write("villager/hard_hat", hard_hat())
    icons()


main()
