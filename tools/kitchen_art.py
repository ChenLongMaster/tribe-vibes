# Bếp4×3 ô, mái chếch phải, bàn dọc; bố cục raw2× trước khi kéo khung512×504.
import random

LINE = "#4E342E"
SW = 6


def svg(w, h, body, comment=''):
    note = f'  <!-- {comment} -->\n' if comment else ''
    return f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">\n{note}{body}</svg>\n'

def path(d, fill, sw=SW, extra=''):
    stroke = f' stroke="{LINE}" stroke-width="{sw}" stroke-linejoin="round" stroke-linecap="round"' if sw else ''
    return f'  <path d="{d}" fill="{fill}"{stroke}{extra}/>\n'

def rect(x, y, w, h, fill, rx=8, sw=SW):
    stroke = f' stroke="{LINE}" stroke-width="{sw}"' if sw else ''
    return f'  <rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{rx}" fill="{fill}"{stroke}/>\n'

def ellipse(cx, cy, rx, ry, fill, sw=SW):
    stroke = f' stroke="{LINE}" stroke-width="{sw}"' if sw else ''
    return f'  <ellipse cx="{cx}" cy="{cy}" rx="{rx}" ry="{ry}" fill="{fill}"{stroke}/>\n'

def line(x1, y1, x2, y2, color, width):
    return f'  <path d="M{x1} {y1} L{x2} {y2}" stroke="{color}" stroke-width="{width}" stroke-linecap="round" fill="none"/>\n'

def contact_shadow(x, y, rx, ry):
    return f'<ellipse cx="{x}" cy="{y}" rx="{rx}" ry="{ry}" fill="{LINE}" opacity="0.16"/>\n'


def stone(x, y, index, width=20, rise=25):
    # Vai bo, đỉnh bè và méo nhẹ; không có đỉnh tam giác như đá dựng.
    w, h = width, min(rise, width * 1.15)
    left = (.70, .82, .74, .66, .78)[index % 5]
    right = (.66, .73, .81, .75, .69)[index % 5]
    crown = (.82, .76, .86, .80, .74)[index % 5]
    body = contact_shadow(w * .12, 3, w * .98, 4)
    body += path(f'M{-w} {-h*.20} Q{-w*1.03} {-h*.62} {-w*.62} {-h*left} Q{-w*.35} {-h*.94} {w*.02} {-h*crown} Q{w*.48} {-h*.94} {w*.73} {-h*right} Q{w*1.05} {-h*.40} {w*.95} {-h*.04} Q{w*.89} {h*.18} {w*.45} {h*.16} L{-w*.55} {h*.14} Q{-w*.93} {h*.11} {-w} {-h*.20} Z', ('#90998D', '#A0A696', '#949B90')[index % 3], 3)
    body += path(f'M{-w*.89} {-h*.36} Q{-w*.86} {-h*.65} {-w*.59} {-h*left*.93} Q{-w*.28} {-h*.88} {w*.03} {-h*crown*.94} Q{w*.43} {-h*.85} {w*.66} {-h*right*.94} Q{w*.85} {-h*.49} {w*.86} {-h*.30} Q{w*.23} {-h*.12} {-w*.47} {-h*.21} Z', ('#C6C8B5', '#D2D0BB', '#B9C0AF')[index % 3], 0)
    body += path(f'M{w*.23} {-h*.13} Q{w*.67} {-h*.19} {w*.88} {-h*.31} L{w*.93} {-h*.07} Q{w*.84} {h*.09} {w*.45} {h*.10} L{w*.24} {h*.09} Z', '#7F897F', 0)
    body += path(f'M{-w*.45} {-h*.70} Q{-w*.12} {-h*.83} {w*.13} {-h*.74}', 'none', 0, ' stroke="#E0DDC8" stroke-width="1.8" stroke-linecap="round"')
    return f'<g transform="translate({x},{y})">' + body + '</g>'


def fence_layout(x1, y1, x2, y2, level):
    # Cọc chia từng khoang; đá nằm GIỮA cọc, không lấy cùng tâm như bản cũ.
    rng = random.Random(int(x1 * 739 + y1 * 337 + x2 * 73 + y2 * 41 + level * 991))
    horizontal = y1 == y2
    length = abs(x2 - x1) + abs(y2 - y1)
    pitch = 34 if level == 1 else (52 if level == 2 else 59)
    count = max(1, round(length / pitch))
    gap = length / count
    posts = [(x1 + (x2 - x1) * i / count, y1 + (y2 - y1) * i / count) for i in range(count + 1)]
    stones = []
    if level > 1:
        # Đá lấp từng khoang, chừa khe ở cọc và nối gần nhau thay một viên lẻ.
        margin = 5.5 if level == 2 else 8.0
        for bay in range(count):
            usable = gap - margin * 2
            pieces = max(2, round(usable / (20 if horizontal else 14)))
            weights = [rng.uniform(.70, 1.45) for _ in range(pieces)]
            cursor = bay * gap + margin
            for part, weight in enumerate(weights):
                step = usable * weight / sum(weights)
                along = cursor + step * .5
                cursor += step
                index = bay * 7 + part * 3 + int(x1 + y1)
                if horizontal:
                    x = min(x1, x2) + along
                    y = y1 + rng.uniform(4, 7)
                    width = step * .5 - .8
                    rise = rng.uniform(17, 25)
                else:
                    width = rng.uniform(13, 15)
                    rise = min(step * 1.03, width * 1.15)
                    x = x1 + (3 if x1 < 192 else -3) + rng.uniform(-.5, .5)
                    y = min(y1, y2) + along + rise * .36
                stones.append((x, y, index, width, rise))
        return posts, stones
    for i in range(count):
        t = (i + .5) / count
        x, y = x1 + (x2 - x1) * t, y1 + (y2 - y1) * t
        if horizontal:
            margin = 0 if level == 1 else (5 if level == 2 else 8)
            limit = gap * .64 if level == 1 else gap / 2 - margin
            width = min(gap * rng.uniform(.34, .61), limit, 24)
            jitter = rng.uniform(-4, 4) if level == 1 else rng.uniform(-2, 2)
            x += jitter
            width = min(width, limit - abs(jitter))
            y += rng.uniform(3, 7)
            rise = rng.uniform(16, 32)
            # Khoang rộng hoặc vài khoang chọn sẵn có đá lớn/nhỏ kê cạnh nhau.
            if gap > 72 or (i % 3 == 1 and gap > 45):
                offset = min(13, gap * .18)
                half = min(14, limit - offset - abs(jitter))
                stones.append((x - offset, y - 1, i * 5 + int(x1 + y1), half, rise))
                stones.append((x + offset, y + 2, i * 5 + 3 + int(x1 + y1), half * .82, rise * .67))
                continue
        else:
            # Hai cạnh bên vẫn nằm trong khung, chừa chân cọc ở hai đầu khoang.
            x += (3 if x1 < 192 else -3) + rng.uniform(-1, 1)
            y += gap * .24
            width = rng.uniform(12, 15)
            rise = min(rng.uniform(24, 34), gap * .60)
        stones.append((x, y, i * 3 + int(x1 + y1), width, rise))
    return posts, stones


def fence(x1, y1, x2, y2, level):
    posts, stones = fence_layout(x1, y1, x2, y2, level)
    b = ''
    if level > 1:
        wood = level == 3
        height = 36 if wood else 29
        for offset in (height - 7, 12):
            b += line(x1, y1 - offset, x2, y2 - offset, LINE, 9 if wood else 5)
            b += line(x1, y1 - offset - 1, x2, y2 - offset - 1, '#B49466' if wood else '#C8B27A', 4 if wood else 2)
        for i, (x, y) in enumerate(posts):
            top = y - height + ((i % 3 - 1) * (1 if wood else 2))
            b += contact_shadow(x + 2, y + 2, 7 if wood else 4, 3)
            b += line(x, top, x, y, LINE, 10 if wood else 5)
            b += line(x - 1, top + 1, x - 1, y - 2, '#AC8559' if wood else '#C9B77D', 6 if wood else 2)
            b += ellipse(x, top, 3.5 if wood else 2, 2, '#DDC296', 1)
            b += line(x - 4 if wood else x - 2, y - 14, x + 4 if wood else x + 2, y - 16, '#E0C590', 2)
            if wood:
                b += line(x + 1, top + 7, x + 1, y - 6, '#795437', 1)
            else:
                for joint in (9, 21):
                    b += line(x - 2, y - joint, x + 2, y - joint, '#9A8454', 1)
        if wood:
            for (ax, ay), (bx, by) in zip(posts, posts[1:]):
                b += line(ax + 3, ay - 12, bx - 3, by - height + 7, LINE, 5)
                b += line(ax + 3, ay - 13, bx - 3, by - height + 8, '#B79766', 2)
    # Đá che nhẹ phần sát đất của cọc; thân cọc đi xuống khe chứ không xuyên mặt đá.
    for x, y, index, width, rise in stones:
        b += stone(x, y, index, width, rise)
    return b

def bowl(x, y):
    return path(f'M{x - 8} {y} Q{x - 6} {y + 9} {x} {y + 10} Q{x + 6} {y + 8} {x + 8} {y} Z', '#AA7650', 2) + ellipse(x, y, 8, 5, '#D5A16A', 2) + ellipse(x, y, 6, 3, '#EAC079', 0) + ellipse(x - 2, y - 1, 1.5, 1, '#9CB35E', 0)

def log_seat():
    # Khúc gỗ nằm dọc: mặt vỏ cong rộng, hai đầu cắt có vòng tuổi.
    b = contact_shadow(3, 16, 15, 6)
    b += path('M-13 -13 Q0 -19 13 -13 L13 15 Q0 23 -13 15 Z', '#92633D', 2.5)
    b += path('M-12 -13 Q0 -20 12 -13 L12 11 Q0 17 -12 11 Z', '#B18451', 2)
    for dx in (-8, -2, 6):
        b += path(f'M{dx} -9 q-3 7 0 13 l-1 7', 'none', 0, ' stroke="#765137" stroke-width="1.5"')
    b += ellipse(0, 14, 13, 7, '#DCB47B', 2) + ellipse(0, 14, 8, 4, 'none', 1)
    b += ellipse(1, 14, 3, 1.6, '#A27A4B', 0)
    b += line(-10, -10, -10, 7, '#CBA366', 1.5)
    return b


def wooden_chair(facing):
    # Tựa phía ngoài bàn; mặt ghế rộng, chân đứng thẳng theo chiều cao.
    b = contact_shadow(3, 15, 15, 6)
    for dx in (-9, 9):
        b += line(dx, -8, dx, 15, LINE, 4) + line(dx - 1, -7, dx - 1, 14, '#A58050', 1.5)
    b += line(-9, 9, 9, 9, '#8F6C46', 3)
    for dx in (-13, -5):
        b += line(dx, -29, dx, 13, LINE, 4) + line(dx - 1, -28, dx - 1, 12, '#B08A56', 1.5)
    b += path('M-16 -31 L-2 -31 L-2 -16 L-16 -16 Z', '#B9905B', 2)
    b += line(-12, -29, -12, -18, '#DFC08A', 1.5) + line(-7, -29, -7, -18, '#8E693D', 1)
    b += path('M-14 -11 L12 -11 L14 0 L-12 1 Z', '#936C43', 2)
    b += path('M-14 -13 Q0 -17 12 -13 L14 -5 Q0 -1 -12 -4 Z', '#D5B57E', 2)
    b += line(-9, -11, 9, -11, '#A58050', 1.5)
    return f'<g transform="scale({facing},1)">' + b + '</g>'


def serving_table(x, y, wood):
    # Quầy dọc: đổi hình mặt/chân thay xoay cả bát và trục đứng của chân bàn.
    b = contact_shadow(x + 5, y + 33, 24, 11)
    if wood:
        for dx in (-16, 16):
            for dy in (-19, 25):
                b += line(x + dx, y + dy, x + dx, y + dy + 15, LINE, 6)
                b += line(x + dx - 1, y + dy + 1, x + dx - 1, y + dy + 13, '#A58050', 2)
        b += path(f'M{x-22} {y+24} L{x+22} {y+24} L{x+21} {y+35} L{x-21} {y+35} Z', '#81633F', 3)
        b += path(f'M{x+17} {y-31} L{x+22} {y+24} L{x+21} {y+35} L{x+17} {y-20} Z', '#987649', 2)
        b += path(f'M{x-18} {y-32} Q{x} {y-35} {x+18} {y-32} L{x+23} {y+24} Q{x} {y+28} {x-23} {y+24} Z', '#C29E65', 4)
        for dx in (-7, 7):
            b += line(x + dx * .8, y - 29, x + dx, y + 22, '#9D7A47', 1.5)
    else:
        b += stone(x, y + 39, 0, 15, 28)
        b += path(f'M{x-19} {y-29} L{x+18} {y-29} L{x+24} {y+22} L{x+20} {y+35} L{x-20} {y+35} L{x-24} {y+23} Z', '#949D8A', 3)
        b += path(f'M{x-17} {y-33} Q{x} {y-36} {x+16} {y-32} L{x+23} {y+21} Q{x} {y+28} {x-23} {y+23} Z', '#C3C6AE', 4)
        b += path(f'M{x+12} {y-26} l-5 7 l3 6', 'none', 0, ' stroke="#A2AA95" stroke-width="2"')
    return b

back = '  <path d="M70 89 L70 213" stroke="#4E342E" stroke-width="10" stroke-linecap="round" fill="none"/>\n  <path d="M69 91 L69 211" stroke="#AE925A" stroke-width="5" stroke-linecap="round" fill="none"/>\n  <ellipse cx="70" cy="104" rx="3" ry="2" fill="#D7BD82"/>\n  <ellipse cx="70" cy="128" rx="3" ry="2" fill="#D7BD82"/>\n  <ellipse cx="70" cy="152" rx="3" ry="2" fill="#D7BD82"/>\n  <ellipse cx="70" cy="176" rx="3" ry="2" fill="#D7BD82"/>\n  <ellipse cx="70" cy="200" rx="3" ry="2" fill="#D7BD82"/>\n  <path d="M198 125 L198 245" stroke="#4E342E" stroke-width="10" stroke-linecap="round" fill="none"/>\n  <path d="M197 127 L197 243" stroke="#AE925A" stroke-width="5" stroke-linecap="round" fill="none"/>\n  <ellipse cx="198" cy="140" rx="3" ry="2" fill="#D7BD82"/>\n  <ellipse cx="198" cy="164" rx="3" ry="2" fill="#D7BD82"/>\n  <ellipse cx="198" cy="188" rx="3" ry="2" fill="#D7BD82"/>\n  <ellipse cx="198" cy="212" rx="3" ry="2" fill="#D7BD82"/>\n  <ellipse cx="198" cy="236" rx="3" ry="2" fill="#D7BD82"/>\n  <path d="M24 154 L24 274" stroke="#4E342E" stroke-width="10" stroke-linecap="round" fill="none"/>\n  <path d="M23 156 L23 272" stroke="#AE925A" stroke-width="5" stroke-linecap="round" fill="none"/>\n  <ellipse cx="24" cy="169" rx="3" ry="2" fill="#D7BD82"/>\n  <ellipse cx="24" cy="193" rx="3" ry="2" fill="#D7BD82"/>\n  <ellipse cx="24" cy="217" rx="3" ry="2" fill="#D7BD82"/>\n  <ellipse cx="24" cy="241" rx="3" ry="2" fill="#D7BD82"/>\n  <ellipse cx="24" cy="265" rx="3" ry="2" fill="#D7BD82"/>\n  <path d="M48 173 L105 197 L96 205 L40 181 Z" fill="#9C7C4D" stroke="#4E342E" stroke-width="4" stroke-linejoin="round" stroke-linecap="round"/>\n  <path d="M48 165 Q43 147 50 140 L62 140 Q70 155 64 165 Z" fill="#B98254" stroke="#4E342E" stroke-width="3" stroke-linejoin="round" stroke-linecap="round"/>\n  <ellipse cx="56" cy="140" rx="6" ry="3" fill="#74513B" stroke="#4E342E" stroke-width="2"/>\n  <path d="M74 176 Q69 158 76 151 L88 151 Q96 166 90 176 Z" fill="#B98254" stroke="#4E342E" stroke-width="3" stroke-linejoin="round" stroke-linecap="round"/>\n  <ellipse cx="82" cy="151" rx="6" ry="3" fill="#74513B" stroke="#4E342E" stroke-width="2"/>\n<g transform="translate(-18,0)">  <path d="M91 230 L111 210 L143 215 L163 232 L164 253 L141 269 L105 260 L88 245 Z" fill="#9D9F8B" stroke="#4E342E" stroke-width="4" stroke-linejoin="round" stroke-linecap="round"/>\n  <path d="M92 229 L112 212 L142 217 L160 232 L133 245 L105 239 Z" fill="#CDC8AD" stroke="#4E342E" stroke-width="3" stroke-linejoin="round" stroke-linecap="round"/>\n  <path d="M124 248 L150 239 L152 254 L131 262 Z" fill="#684B34" stroke="#4E342E" stroke-width="3" stroke-linejoin="round" stroke-linecap="round"/>\n  <path d="M141 259 C135.96 255.4 137.4 248.2 141 243.16 C142.44 248.2 146.76 251.08 145.32 256.84 Z" fill="#FF8A65" stroke="#4E342E" stroke-width="4" stroke-linejoin="round" stroke-linecap="round"/>\n  <path d="M141 257.56 C138.84 255.4 139.56 251.8 141.36 248.92 C142.44 252.52 143.88 253.96 143.16 256.84 Z" fill="#FFD54F"/>\n  <path d="M97 215 Q97 242 119 246 Q146 251 153 225 L154 216 Z" fill="#8A5944" stroke="#4E342E" stroke-width="4" stroke-linejoin="round" stroke-linecap="round"/>\n  <path d="M140 224 L153 219 Q150 243 136 245 Z" fill="#684331"/>\n  <ellipse cx="126" cy="214" rx="29" ry="14" fill="#AF7954" stroke="#4E342E" stroke-width="4"/>\n  <ellipse cx="126" cy="214" rx="22" ry="9" fill="#E7B574"/>\n  <ellipse cx="120" cy="211" rx="10" ry="3" fill="#F0CA8A"/>\n  <path d="M98 217 Q88 208 86 219 Q86 231 100 230 M151 219 Q165 217 160 229 L149 235" fill="none" stroke="#4E342E" stroke-width="3" stroke-linejoin="round" stroke-linecap="round"/>\n  <path d="M125 214 L76 255" stroke="#6C5136" stroke-width="5" stroke-linecap="round" fill="none"/>\n  <path d="M126 213 L77 254" stroke="#C5A270" stroke-width="2" stroke-linecap="round" fill="none"/>\n</g>'

roof = '\n  <!-- Phác khu bếp3×3; layer để thử người trong khu, chưa phải asset game -->\n  <path d="M20 143 L133 179 L204 109 L199 122 L143 195 L132 198 L121 190 L111 192 L99 183 L88 185 L78 176 L66 178 L56 168 L43 169 L32 160 L20 161 Z" fill="#858953" stroke="#4E342E" stroke-width="4" stroke-linejoin="round" stroke-linecap="round"/>\n  <path d="M19 143 Q45 118 66 77 Q99 84 126 94 L202 109 Q181 137 155 165 L134 185 L122 180 L111 184 L99 175 L88 176 L77 168 L65 170 L55 161 L43 162 L31 151 Z" fill="#B7B06E" stroke="#4E342E" stroke-width="5" stroke-linejoin="round" stroke-linecap="round"/>\n  <path d="M66 80 Q104 87 127 98 L197 110 L185 123 L54 96 Z" fill="#C8BE7C"/>\n  <path d="M73.33333333333333 86.61111111111111 L28.11111111111111 137.16666666666666" stroke="#90945A" stroke-width="3" stroke-linecap="round" fill="none"/>\n  <path d="M70.33333333333333 92.61111111111111 L25.11111111111111 132.16666666666666" stroke="#D6C783" stroke-width="1.5" stroke-linecap="round" fill="none"/>\n  <path d="M88.0 89.83333333333333 L40.33333333333333 141.5" stroke="#90945A" stroke-width="3" stroke-linecap="round" fill="none"/>\n  <path d="M85.0 95.83333333333333 L37.33333333333333 136.5" stroke="#D6C783" stroke-width="1.5" stroke-linecap="round" fill="none"/>\n  <path d="M102.66666666666667 93.05555555555556 L52.55555555555556 145.83333333333334" stroke="#90945A" stroke-width="3" stroke-linecap="round" fill="none"/>\n  <path d="M99.66666666666667 99.05555555555556 L49.55555555555556 140.83333333333334" stroke="#D6C783" stroke-width="1.5" stroke-linecap="round" fill="none"/>\n  <path d="M117.33333333333334 96.27777777777777 L64.77777777777777 150.16666666666666" stroke="#90945A" stroke-width="3" stroke-linecap="round" fill="none"/>\n  <path d="M114.33333333333334 102.27777777777777 L61.77777777777777 145.16666666666666" stroke="#D6C783" stroke-width="1.5" stroke-linecap="round" fill="none"/>\n  <path d="M132.0 99.5 L77.0 154.5" stroke="#90945A" stroke-width="3" stroke-linecap="round" fill="none"/>\n  <path d="M129.0 105.5 L74.0 149.5" stroke="#D6C783" stroke-width="1.5" stroke-linecap="round" fill="none"/>\n  <path d="M146.66666666666669 102.72222222222223 L89.22222222222223 158.83333333333334" stroke="#90945A" stroke-width="3" stroke-linecap="round" fill="none"/>\n  <path d="M143.66666666666669 108.72222222222223 L86.22222222222223 153.83333333333334" stroke="#D6C783" stroke-width="1.5" stroke-linecap="round" fill="none"/>\n  <path d="M161.33333333333331 105.94444444444444 L101.44444444444444 163.16666666666666" stroke="#90945A" stroke-width="3" stroke-linecap="round" fill="none"/>\n  <path d="M158.33333333333331 111.94444444444444 L98.44444444444444 158.16666666666666" stroke="#D6C783" stroke-width="1.5" stroke-linecap="round" fill="none"/>\n  <path d="M176.0 109.16666666666667 L113.66666666666667 167.5" stroke="#90945A" stroke-width="3" stroke-linecap="round" fill="none"/>\n  <path d="M173.0 115.16666666666667 L110.66666666666667 162.5" stroke="#D6C783" stroke-width="1.5" stroke-linecap="round" fill="none"/>\n  <path d="M190.66666666666666 112.38888888888889 L125.88888888888889 171.83333333333334" stroke="#90945A" stroke-width="3" stroke-linecap="round" fill="none"/>\n  <path d="M187.66666666666666 118.38888888888889 L122.88888888888889 166.83333333333334" stroke="#D6C783" stroke-width="1.5" stroke-linecap="round" fill="none"/>\n  <path d="M31 132 Q73 143 147 174" fill="none" stroke="#7F8450" stroke-width="3"/>\n  <path d="M50 136 L59 144" stroke="#DCCA91" stroke-width="2" stroke-linecap="round" fill="none"/>\n  <path d="M93 150 L102 158" stroke="#DCCA91" stroke-width="2" stroke-linecap="round" fill="none"/>\n  <path d="M127 163 L136 171" stroke="#DCCA91" stroke-width="2" stroke-linecap="round" fill="none"/>\n'

steam = '<g transform="translate(-18,0)">\n  <!-- Phác khu bếp3×3; layer để thử người trong khu, chưa phải asset game -->\n  <path d="M126 195 q-5 -8 1 -14 M139 202 q5 -8 0 -14" fill="none" stroke="#FFF3D7" stroke-width="3" stroke-linecap="round" opacity="0.8"/>\n</g>'

pole = '  <path d="M140 192 L140 312" stroke="#4E342E" stroke-width="10" stroke-linecap="round" fill="none"/>\n  <path d="M139 194 L139 310" stroke="#AE925A" stroke-width="5" stroke-linecap="round" fill="none"/>\n  <ellipse cx="140" cy="210" rx="3" ry="2" fill="#D7BD82"/>\n  <ellipse cx="140" cy="234" rx="3" ry="2" fill="#D7BD82"/>\n  <ellipse cx="140" cy="258" rx="3" ry="2" fill="#D7BD82"/>\n  <ellipse cx="140" cy="282" rx="3" ry="2" fill="#D7BD82"/>\n  <ellipse cx="140" cy="306" rx="3" ry="2" fill="#D7BD82"/>\n  <ellipse cx="140" cy="313" rx="7" ry="3" fill="#AE966C"/>\n'

SCALES = {1: 0.76, 2: 0.89, 3: 1.0}

CENTERS = {1: [(258, 141), (258, 234)], 2: [(239, 141), (319, 188), (239, 234)], 3: [(234, 115), (326, 115), (234, 234), (326, 234)]}

SEAT_OFFSET = {1: 51, 2: 31, 3: 31}

CANOPY_SCALES = {1: 0.60, 2: 0.69, 3: 0.77}
CANOPY_ORIGINS = {1: (34, -24), 2: (33, -43), 3: (32, -60)}
SERVING_CENTERS = {1: (54, 238), 2: (54, 238), 3: (54, 238)}

def shrink(body, level):
    s = SCALES[level]
    return f'<g transform="translate(192,192) scale({s}) translate(-192,-192)">' + body + '</g>'

def canopy(body, level):
    return f'<g transform="translate({CANOPY_ORIGINS[level][0]},{CANOPY_ORIGINS[level][1]}) scale({CANOPY_SCALES[level]})"><g transform="translate(210,0) scale(-1,1)">' + body + '</g></g>'

def canopy_roof(body, level):
    # Chỉ nới nửa sau mái; mép trước và các đầu cọc trước vẫn khớp như cũ.
    mirrored = '<g transform="translate(210,0) scale(-1,1)">' + body + '</g>'
    clips = f'<defs><clipPath id="roof_front_{level}"><rect x="-200" y="125" width="800" height="500"/></clipPath><clipPath id="roof_back_{level}"><rect x="-200" y="-200" width="800" height="325"/></clipPath></defs>'
    front = f'<g clip-path="url(#roof_front_{level})">' + mirrored + '</g>'
    rear = f'<g transform="matrix(1 0 0.4 1.35 -50 -43.75)"><g clip-path="url(#roof_back_{level})">' + mirrored + '</g></g>'
    return f'<g transform="translate({CANOPY_ORIGINS[level][0]},{CANOPY_ORIGINS[level][1]}) scale({CANOPY_SCALES[level]})">' + clips + front + rear + '</g>'

def dining(body, x, y, factor):
    return f'<g transform="translate({x},{y}) scale({factor})">' + body + '</g>'

def banana_leaf(x, y, food=True):
    b = path(f'M{x-13} {y} Q{x-17} {y-10} {x+10} {y-9} Q{x+17} {y-2} {x+11} {y+6} Q{x-1} {y+10} {x-13} {y} Z', '#789950', 1.6)
    b += line(x-11, y+2, x+12, y-5, '#CFD58A', 1.2)
    for dx in (-5, 1, 7):
        b += line(x+dx, y-1, x+dx-2, y-6, '#ABC072', .7)
    if food:
        b += ellipse(x-3, y-1, 4.5, 2.4, '#BD763F', 1)
        b += ellipse(x+5, y-3, 3, 2, '#D49953', .8)
    return b

def mat(x, y, serving=False):
    b = contact_shadow(x + 4, y + 5, 30, 33)
    b += path(f'M{x-25} {y-32} Q{x} {y-35} {x+25} {y-32} L{x+30} {y+33} Q{x} {y+37} {x-30} {y+33} Z', '#AA8954', 3)
    b += path(f'M{x-24} {y-33} Q{x} {y-36} {x+24} {y-33} L{x+29} {y+29} Q{x+4} {y+33} {x-29} {y+29} Z', '#D8BC7D', 2)
    for dy in range(-28, 29, 5):
        width = 22 + (dy + 28) / 56 * 4
        b += line(x - width, y + dy, x + width, y + dy, '#B99A60', 1)
    for dx in range(-18, 19, 6):
        b += line(x + dx, y - 29, x + dx * 1.2, y + 27, '#EBD49C', 1)
    for dx in range(-24, 25, 6):
        b += line(x + dx, y + 33, x + dx + 1, y + 38, '#AA8954', 1.5)
    b += path(f'M{x-29} {y+25} Q{x-18} {y+23} {x-17} {y+29} L{x-29} {y+29} Z', '#E4CA91', 1)
    if serving:
        b += path(f'M{x-23} {y-29} L{x+23} {y-29} L{x+25} {y-23} L{x-25} {y-23} Z', '#9A6B42', 0)
        b += path(f'M{x-27} {y+19} L{x+27} {y+19} L{x+28} {y+25} L{x-28} {y+25} Z', '#9A6B42', 0)
        return b
    return b + banana_leaf(x, y - 13) + banana_leaf(x, y + 13)

def table(x, y, wood, index=0):
    b = contact_shadow(x + 7, y + 40, 33, 14)
    if wood:
        for dx in (-22, 22):
            for dy in (-24, 38):
                b += line(x + dx, y + dy - 4, x + dx, y + dy + 17, '#4E342E', 7) + line(x + dx - 1, y + dy - 3, x + dx - 1, y + dy + 15, '#A58050', 3)
        b += path(f'M{x - 30} {y + 27} L{x + 30} {y + 27} L{x + 29} {y + 43} L{x - 29} {y + 43} Z', '#81633F', 3)
        b += path(f'M{x + 23} {y-35} L{x+29} {y+29} L{x+29} {y+42} L{x+23} {y-24} Z', '#987649', 2)
        b += path(f'M{x - 24} {y - 35} Q{x} {y - 37} {x + 24} {y - 35} L{x + 30} {y + 29} Q{x} {y + 32} {x - 30} {y + 29} Z', '#CEAE75', 4)
        for dx in (-9, 9):
            b += line(x + dx * .8, y - 32, x + dx, y + 27, '#9D7A47', 1.5)
        b += line(x - 25, y + 26, x + 25, y + 26, '#E5CB94', 1.5)
    else:
        b += stone(x, y + 46, 0, 20, 28)
        b += path(f'M{x - 25} {y - 31} L{x + 23} {y - 31} L{x + 32} {y + 25} L{x + 28} {y + 43} L{x - 27} {y + 42} L{x - 32} {y + 27} Z', '#8E988B', 3)
        b += path(f'M{x + 12} {y + 26} L{x+31} {y+23} L{x+28} {y+39} L{x+10} {y+40} Z', '#778276', 0)
        b += path(f'M{x - 23} {y - 35} Q{x} {y - 40} {x + 22} {y - 34} L{x + 31} {y + 24} Q{x+2} {y + 33} {x - 31} {y + 26} Z', '#C9CBB7', 4)
        b += path(f'M{x - 19} {y - 30} L{x + 16} {y - 31} L{x+22} {y-17} L{x-21} {y-21} Z', '#DDDDC7', 0)
        b += path(f'M{x + 19} {y - 28} l-6 8 l4 9', 'none', 0, ' stroke="#A2AA95" stroke-width="2"')
    b += bowl(x, y - 13) + bowl(x, y + 13)
    if not wood:
        # Hai đôi lệch hướng/độ mở nhẹ, tránh xếp như một mẫu đóng dấu.
        for row, dy in enumerate((-13, 13)):
            angle = (-12, 9, 17, -6, 4, -15)[(index*2+row) % 6]
            sticks = line(-9, -5, 10, 1, '#855D38', 1.6) + line(-8, -2, 11, 4, '#BA8D53', 1.4)
            b += f'<g transform="translate({x+11} {y+dy+7}) rotate({angle})">{sticks}</g>'
    return b

def chopstick_holder():
    b = ellipse(0, 5, 6, 2, '#73533B', 1)
    b += path('M-6 -9 L6 -9 L5 5 Q0 8 -5 5 Z', '#B89251', 1.5)
    b += ellipse(0, -9, 6, 2.5, '#6F5135', 1)
    for x, y, tilt in [(-3,-21,-2), (0,-24,1), (3,-22,2), (1,-20,0)]:
        b += line(x+tilt,y,x,-7,'#D7B577',1.5)
    b += line(-5,-2,5,-2,'#E2C795',1)
    return b

def smoked_rack():
    b = ''
    for x, y in [(72, 243), (181, 265)]:
        b += line(x,y,x,y-108,LINE,7) + line(x-1,y-2,x-1,y-107,'#AA9259',3)
        for dy in (22,46,70,94):
            b += line(x-3,y-dy,x+3,y-dy,'#DCC792',1.5)
    b += line(70,139,184,161,LINE,7) + line(71,137,184,159,'#C0A774',3)
    for i, (x,y) in enumerate([(89,143),(112,148),(136,153),(160,158)]):
        b += line(x,y,x-2,y+9,'#DCC594',2)
        b += path(f'M{x-5} {y+8} Q{x+2} {y+5} {x+7} {y+10} L{x+4} {y+44-i*3} Q{x-3} {y+52-i*3} {x-8} {y+41-i*3} Z', '#8B5135' if i%2 else '#A96540', 2)
        b += line(x-3,y+13,x-4,y+35,'#D49B6C',1.5)
        b += path(f'M{x} {y+18} l3 3 l-4 6 l3 4', 'none', 1)
    return b

def stone_prep():
    b = contact_shadow(109,244,39,11)
    b += path('M70 213 Q87 197 114 199 L144 213 L148 232 Q121 249 80 236 L68 225 Z', '#8E988C',3)
    b += path('M72 212 Q88 200 113 201 L142 214 Q112 232 72 223 Z', '#CDD0B9',3)
    b += path('M88 213 Q95 204 111 210 Q125 211 122 220 Q106 228 92 222 Z','#B77551',2)
    b += path('M92 213 Q102 211 114 215 L111 218 Q100 215 94 218 Z','#E6BD8D',0)
    b += path('M125 209 L138 212 L127 223 L120 219 Z','#AAB3A1',1.5)
    b += line(138,213,146,206,'#9C764B',4)
    return b

def pot(x, y, size=1):
    b = path('M-15 0 Q-14 19 0 21 Q14 19 15 0 Z', '#97613F', 3)
    b += ellipse(0, 0, 15, 7, '#C18B57', 3) + ellipse(0, 0, 10, 4, '#E8BB79', 0)
    b += path('M-15 3 q-9 -4 -8 4 q0 7 9 5 M15 3 q9 -4 8 4 q0 7 -9 5', 'none', 2)
    return dining(b, x, y, size)

def jar(x, y):
    return path(f'M{x - 12} {y} Q{x - 20} {y - 18} {x - 9} {y - 31} L{x + 9} {y - 31} Q{x + 20} {y - 18} {x + 12} {y} Z', '#B98254', 3) + ellipse(x, y - 31, 9, 4, '#74513B', 2) + path(f'M{x - 10} {y - 16} Q{x} {y - 11} {x + 10} {y - 16}', 'none', 1.5)

def utensils(level):
    b = line(63, 171, 154, 207, '#4E342E', 6) + line(64, 170, 154, 206, '#B49C6A', 2)
    for i, (x, y) in enumerate([(74, 180), (103, 191)] if level == 2 else [(63, 174), (89, 184), (116, 195)]):
        b += line(x, y, x, y + 22, '#6D5237', 3)
        if i == 0:
            b += ellipse(x, y + 24, 5, 7, '#C19B61', 2)
        elif i == 1:
            b += rect(x - 4, y + 18, 8, 12, '#C4AD75', 2, 2) + line(x - 1, y + 20, x - 1, y + 28, '#907346', 1)
        else:
            b += ellipse(x, y + 24, 8, 7, '#BEA66C', 2)
            for dx in (-4, 0, 4):
                b += line(x + dx, y + 20, x + dx, y + 28, '#8B7548', 1)
    return b

def upgraded_cooking(level):
    cook = back
    top = roof
    front_pole = pole
    if level == 1:
        cook = stone_prep()
        top = ''
        front_pole = ''
    elif level == 2:
        cook += utensils(level) + jar(188, 280)
        cook += path('M171 248 Q167 266 184 268 Q202 266 197 248 Z', '#A97850', 3) + ellipse(184, 248, 13, 5, '#D4A876', 2)
        cook += line(182, 249, 189, 232, '#6D5136', 5) + line(181, 247, 188, 232, '#C4A374', 2)
        for x, y in [(68, 207), (188, 201)]:
            cook += line(x - 5, y - 4, x + 5, y + 4, '#DEC58C', 3)
        top += path('M30 134 Q81 143 147 172', 'none', 0, ' stroke="#D2C187" stroke-width="3"')
    else:
        cook = cook.replace('#AE925A', '#AB8455').replace('stroke-width="10"', 'stroke-width="14"')
        front_pole = front_pole.replace('#AE925A', '#AB8455').replace('stroke-width="10"', 'stroke-width="14"')
        cook += utensils(level)
        cook += path('M175 252 L204 246 L220 257 L218 281 L187 287 L173 275 Z', '#969B87', 3)
        cook += path('M190 278 L205 274 L205 285 L191 288 Z', '#71543B', 2)
        cook += pot(195, 249, 1.15)
        cook += path('M163 209 L196 222 L195 239 L161 226 Z', '#8F7149', 3)
        cook += path('M164 204 L196 217 L190 225 L159 213 Z', '#CAAB70', 3)
        cook += ellipse(174, 212, 8, 4, '#A7834D', 1.5) + ellipse(187, 219, 5, 3, '#9CB45F', 0)
        cook += jar(187, 308)
        cook += rect(155, 274, 22, 22, '#AA8751', 5, 2)
        for dx in range(159, 175, 5):
            cook += line(dx, 278, dx, 293, '#D0B077', 1)
        # Gian chắc chắn: vách đan thấp/giằng khung, mái lá xếp hàng và diềm gỗ.
        panel = path('M73 164 L189 192 L189 218 L73 192 Z', '#B2945F', 3)
        for x in range(78, 187, 9):
            y = 165 + (x-73)*.24
            panel += line(x,y,x,y+25,'#DDC792',1)
        for dy in (7,15,23):
            panel += line(74,164+dy,188,191+dy,'#886D42',1)
        cook = panel + cook
        cook += line(70,165,91,185,'#8F7049',7) + line(198,198,176,210,'#8F7049',7)
        cook += line(70,142,198,174,LINE,8) + line(70,140,198,172,'#B49663',3)
        top = path('M20 141 L132 181 L202 110 L201 124 L137 195 L20 154 Z', '#7C754D', 4)
        top += path('M20 140 Q44 108 66 77 Q109 79 202 107 Q176 143 135 183 Q75 168 20 140 Z', '#B9B77B', 5)
        for i in range(3):
            top += path(f'M{35+i*15} {119-i*17} Q{86+i*4} {134-i*18} {151+i*16} {154-i*17}', 'none', 0, ' stroke="#7D8954" stroke-width="3"')
        for i in range(9):
            x, y = 70+i*14, 83+i*3
            top += line(x,y,x-39,y+51,'#D9D397',1.8)
        top += line(66,78,200,108,LINE,6) + line(67,77,200,107,'#CFB57B',2)
        top += path('M20 143 Q77 163 133 183 L134 193 Q76 176 20 153 Z','#986F43',3)
        for i in range(8):
            x,y = 30+i*13, 150+i*4.5
            top += path(f'M{x} {y} l4 1 l-3 3 l4 1', 'none', 0, ' stroke="#E0C586" stroke-width="1.2"')
        top += ellipse(176,116,9,7,'#C69B5E',2)
        for dx,dy in [(0,-10),(0,10),(-11,0),(11,0)]:
            top += line(176+dx*.7,116+dy*.7,176+dx,116+dy,'#785637',1.5)
    return (cook, top, front_pole)

ROAST_CENTERS = {1: (158, 210), 2: (154, 210), 3: (282, 187)}


def roast_parts(level):
    # Bếp than thấp; giá tre/gỗ chếch nhẹ như gian nấu, không thêm một nền đất riêng.
    base = contact_shadow(3, 14, 31, 10)
    if level > 1:
        for i, (x, y) in enumerate([(-24, -2), (-13, -8), (5, -8), (23, -2)]):
            base += stone(x, y, i, 8, 8)
    base += ellipse(0, 6, 22, 10, '#655044', 2)
    for i, (x, y) in enumerate([(-14, 3), (-5, 8), (7, 3), (16, 8), (0, 0)]):
        base += ellipse(x, y, 5, 3, '#755041', 1.5)
        base += ellipse(x - 1, y - 1, 2.5, 1.2, '#DE7845' if i % 2 else '#F0A34C', 0)
    if level > 1:
        for i, (x, y) in enumerate([(-26, 9), (-18, 16), (-3, 19), (12, 18), (26, 11)]):
            base += stone(x, y, i + 3, 8, 9)
    wood = '#B39962' if level == 1 else '#AB8050'
    for x, top, ground in [(-25, -21, 12), (25, -15, 16)]:
        base += line(x, ground, x, top, LINE, 5 if level < 3 else 7)
        base += line(x - 1, ground - 1, x - 1, top + 1, wood, 2 if level < 3 else 3)
        if level == 1:
            base += line(x, top, x - 5, top - 6, wood, 3) + line(x, top, x + 4, top - 6, wood, 3)
        else:
            base += line(x - 5, top + 3, x + 5, top + 1, '#D8BF87', 2)
            base += line(x - 5, ground - 2, x, top + 10, wood, 3)
    base += line(-31, -21, 31, -15, LINE, 4) + line(-30, -22, 31, -16, '#C3A06B', 1.5)
    if level == 3:
        base += line(30, -15, 35, -11, wood, 3) + line(35, -11, 35, -5, LINE, 4)
        base += ellipse(35, -4, 3, 2, '#D4B179', 1.5)
        base += path('M-15 18 Q0 15 15 19 L12 26 Q0 29 -13 25 Z', '#9C6D47', 2)
        base += ellipse(0, 21, 10, 2.5, '#D6A15B', 0)
        base += ellipse(32, 20, 7, 4, '#B98A59', 2) + ellipse(31, 19, 5, 2, '#869A52', 0)
        base += line(28, 19, 34, 17, '#C1CE81', 1)
    # Con quay riêng có trục giữa thân; giữ key cũ để scene/animation vẫn tương thích.
    chicken = path('M-13 -8 Q-3 -15 9 -10 Q18 -7 17 1 Q15 11 4 11 Q-10 12 -16 4 Q-19 -2 -13 -8 Z', '#CF8A44', 2.5)
    chicken += path('M-12 -8 Q0 -13 10 -7 Q16 -5 13 -1 Q1 -6 -12 -2 Z', '#EAB368', 0)
    chicken += path('M-2 -2 Q8 -8 10 1 Q8 8 -1 4 Q-5 1 -2 -2 Z', '#B87639', 1.5)
    chicken += path('M-10 5 Q-21 3 -20 9 Q-17 15 -9 10 Z', '#DB9C51', 2)
    chicken += line(-20, 9, -25, 10, '#E5D3A4', 2.5) + ellipse(-26, 10, 2, 2, '#F0DFB4', 0)
    for x, y in [(-7, -4), (7, -5), (13, 2)]:
        chicken += ellipse(x, y, 1, 1.5, '#A86A36', 0)
    if level == 1:
        chicken = '<g transform="scale(.60)">' + chicken + '</g>'
    elif level == 3:
        # Heo rừng quay: mõm bè/ngà nhỏ, tai nhọn mềm, chân gập và đuôi cong.
        chicken = path('M-22 -6 Q-18 -15 -3 -13 Q12 -15 19 -5 L19 5 Q10 15 -6 12 Q-23 12 -22 -6 Z', '#AA693D', 2.5)
        chicken += path('M-20 -6 Q-13 -13 0 -10 Q10 -12 16 -5 Q1 -8 -18 -1 Z', '#D69A57', 0)
        chicken += path('M-17 -10 l3 -5 l4 2 l4 -3 l5 3 l5 -1 l3 4', 'none', 0, ' stroke="#75472E" stroke-width="2" stroke-linejoin="round"')
        chicken += path('M14 -5 Q24 -8 28 1 L32 3 L32 9 Q25 15 16 10 Q10 6 14 -5 Z', '#BB7946', 2)
        chicken += path('M16 -5 Q12 -16 21 -12 L23 -4 Z', '#975734', 2)
        chicken += ellipse(29, 6, 7, 4.5, '#D09865', 1.7)
        chicken += ellipse(29, 5.5, 1.2, 1.4, '#674331', 0) + ellipse(33, 6, 1, 1.3, '#674331', 0)
        chicken += path('M21 9 Q28 14 28 5 Q30 16 22 14 Z', '#EAD5AA', 1)
        chicken += line(20, 1, 23, 2, '#674331', 1.5)
        for x in (-15, 7):
            chicken += path(f'M{x} 7 Q{x-5} 15 {x+1} 17 L{x+6} 15 L{x+3} 10 Z', '#9A5E38', 1.7)
            chicken += line(x+1,16,x+4,15,'#674331',2)
        chicken += path('M-21 1 Q-32 -4 -28 -9 Q-23 -12 -24 -7', 'none', 0, ' stroke="#975734" stroke-width="3" stroke-linecap="round"')
        chicken += path('M-12 -2 Q-8 1 -5 -2 M0 3 l5 -2', 'none', 0, ' stroke="#DFAC72" stroke-width="1.5"')
    fire = path('M-8 8 Q-12 0 -6 -7 Q-6 -1 -2 -3 Q2 -6 2 -13 Q12 -1 8 7 Q2 14 -8 8 Z', '#EE9644', 1.5)
    fire += path('M-4 7 Q-5 2 -1 -3 Q0 1 3 0 Q7 6 2 9 Z', '#FFD56D', 0)
    x, y = ROAST_CENTERS[level]
    return dining(base, x, y, 1), dining(chicken, x, y - 18, 1), dining(fire, x, y + 3, 1)


def layers(level):
    result = {}
    def put(name, body):
        result[name] = body
    # Giữ lớp trống cho hợp đồng asset; sân dùng đất chung của map, không nền riêng.
    put('floor_' + str(level), '')
    rear = fence(14, 88, 370, 88, level) + fence(14, 88, 14, 302, level) + fence(370, 88, 370, 302, level)
    front = fence(14, 302, 100, 302, level) + fence(176, 302, 370, 302, level)
    if level == 3:
        rear += ellipse(273, 55, 9, 7, '#C19B61', 2)
        for dx, dy in [(0, -11), (0, 11), (-12, 0), (12, 0)]:
            rear += line(273 + dx * 0.7, 55 + dy * 0.7, 273 + dx, 55 + dy, '#80633E', 1.5)
    put('fence_back_' + str(level), shrink(rear, level))
    put('fence_front_' + str(level), shrink(front, level))
    cook, top, front_pole = upgraded_cooking(level)
    put('cook_' + str(level), shrink(canopy(cook, level), level))
    if level <= 2:
        put('rack_' + str(level), shrink(canopy(smoked_rack(), level), level))
    put('roof_' + str(level), shrink(canopy_roof(top, level), level))
    put('pole_' + str(level), shrink(canopy(front_pole, level), level))
    put('steam_' + str(level), '' if level == 1 else shrink(canopy(steam, level), level))
    if level == 1:
        serving = mat(0, 0, True)
    else:
        serving = serving_table(0, 0, level != 2) + bowl(0, -20) + bowl(-6, -3) + bowl(7, 11)
        serving += ellipse(0, 22, 9, 4, '#A47748', 2) + ellipse(-1, 21, 6, 2, '#91AA56', 0)
    put('serving_' + str(level), shrink(dining(serving, *SERVING_CENTERS[level], 0.7), level))
    roast_base, roast_chicken, roast_fire = roast_parts(level)
    put('roast_base_' + str(level), shrink(roast_base, level))
    put('roast_chicken_' + str(level), shrink(roast_chicken, level))
    put('roast_fire_' + str(level), shrink(roast_fire, level))
    seats = ''
    for index, (x, y) in enumerate(CENTERS[level]):
        pair = ''
        offset = SEAT_OFFSET[level]
        if level == 1:
            surface = dining(mat(0, 0), x, y, 0.76)
        else:
            surface = dining(table(0, 0, level == 3, index), x, y, 0.6)
            for side, sx in enumerate((x - offset, x + offset)):
                seat = log_seat() if level == 2 else wooden_chair(1 if side == 0 else -1)
                pair += dining(seat, sx, y + 12, 0.85)
            seats += pair
        put(f'seating_{level}_{index}', shrink(pair, level))
        put(f'dining_{level}_{index}', shrink(surface, level))
        if level == 3:
            put(f'chopsticks_3_{index}', shrink(dining(chopstick_holder(), x-8, y, .6), level))
    put('seats_' + str(level), shrink(seats, level))
    return result


def enlarge(body):
    return '<g transform="translate(0,48)"><g transform="scale(1.3333333333333333,1.5)">' + body + '</g></g>'

def composite(level):
    parts = layers(level)
    names = [f"floor_{level}", f"fence_back_{level}", f"cook_{level}", f"roof_{level}", f"steam_{level}", f"pole_{level}", f"serving_{level}", f"roast_base_{level}", f"roast_fire_{level}", f"roast_chicken_{level}", f"seats_{level}"]
    names += [f"dining_{level}_{i}" for i in range(len(CENTERS[level]))]
    if level <= 2:
        names.insert(names.index(f'roof_{level}'), f'rack_{level}')
    else:
        names += [f'chopsticks_3_{i}' for i in range(4)]
    names += [f"fence_front_{level}"]
    return svg(512, 552, enlarge("".join(parts[n] for n in names)), "Bếp4×3, neo256,504; mái nghiêng phải, bàn dọc")

def generate(write):
    # Muôi thật để đầu bếp khuấy, icon nồi chỉ dùng trên đầu/bảng thông tin.
    write("props/cooking_spoon", svg(20, 80, line(10, 6, 10, 62, LINE, 7) + line(9, 6, 9, 61, "#C3A375", 3) + ellipse(10, 68, 7, 9, "#AD8954", 3)))
    write('props/stone_kitchen_knife', svg(24, 60, rect(8, 3, 7, 24, '#A28254', 3, 2) + path('M8 24 L18 25 L20 47 Q12 53 5 55 L5 29 Z', '#AEB7A6', 2) + path('M7 28 L9 47 L7 51 Z', '#E0DECA', 0)))
    leaf = '<g transform="translate(32 28) scale(1.4) translate(-32 -28)">' + banana_leaf(32, 28, False) + '</g>'
    smoked = leaf + path('M19 19 Q30 13 40 19 L45 28 Q34 39 20 32 Z', '#9B5A38', 2)
    for x in (25, 31, 37):
        smoked += line(x,20,x-2,29,'#DBA173',1.5)
    bird = leaf + ellipse(32,24,12,8,'#CB8843',2) + ellipse(35,24,5,4,'#AD6B35',1)
    bird += line(22,28,16,32,'#DECBA3',2) + path('M20 25 Q14 24 16 30 L22 30 Z','#DCA456',1.5)
    write('props/meal_smoked_meat', svg(64,48,smoked))
    write('props/meal_roast_bird', svg(64,48,bird))
    for level in (1,2,3):
        for name, body in layers(level).items():
            write("buildings/kitchen/" + name, svg(512,552,enlarge(body)))

