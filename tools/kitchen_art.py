# Hình bếp đã duyệt: 3×2 ô, mái chéo phải, bàn dọc; tất cả toạ độ ở 2×.
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

def stone(x, y, index):
    width = (12, 14, 11, 13)[index % 4]
    rise = (14, 12, 15)[index % 3]
    return path(f'M{x - width} {y - 3} Q{x - width - 2} {y - 10} {x - width + 5} {y - rise} L{x + width - 5} {y - rise - 1} Q{x + width + 3} {y - 9} {x + width} {y - 1} Q{x} {y + 5} {x - width} {y - 3} Z', ('#989E8A', '#A5AA96', '#929B8C')[index % 3], 3) + ellipse(x - 2, y - rise + 5, width * 0.6, 3, '#C7C7AF', 0)

def fence(x1, y1, x2, y2, level):
    length = abs(x2 - x1) + abs(y2 - y1)
    count = max(1, int(length / 25))
    b = ''
    for i in range(count + 1):
        t = i / count
        b += stone(x1 + (x2 - x1) * t, y1 + (y2 - y1) * t + 4, i)
    if level == 1:
        return b
    wood = level == 3
    height = 28 if wood else 24
    for offset in (height - 6, 11):
        b += line(x1, y1 - offset, x2, y2 - offset, '#4E342E', 10 if wood else 5)
        b += line(x1, y1 - offset - 1, x2, y2 - offset - 1, '#A98153' if wood else '#B9A16A', 5 if wood else 2)
    for i in range(count + 1):
        t = i / count
        x = x1 + (x2 - x1) * t
        y = y1 + (y2 - y1) * t
        top = y - height + (0 if wood else (i % 3 - 1) * 3)
        b += line(x, top, x, y, '#4E342E', 13 if wood else 5)
        b += line(x - 1, top + 1, x - 1, y - 2, '#A98153' if wood else '#C9B77D', 8 if wood else 2)
        b += ellipse(x, top, 5 if wood else 2, 2, '#D0B180', 1)
        b += line(x - 4 if wood else x - 2, y - 15, x + 4 if wood else x + 2, y - 15, '#DCC18B', 2)
        if wood:
            b += line(x + 2, top + 7, x + 2, y - 8, '#795437', 1.5)
    if wood and y1 == y2:
        for x in range(int(x1) + 10, int(x2) - 45, 65):
            b += line(x, y1 - 9, x + 44, y1 - 30, '#4E342E', 5) + line(x, y1 - 10, x + 44, y1 - 31, '#B79766', 2)
    return b

def bowl(x, y):
    return path(f'M{x - 8} {y} Q{x - 6} {y + 9} {x} {y + 10} Q{x + 6} {y + 8} {x + 8} {y} Z', '#AA7650', 2) + ellipse(x, y, 8, 5, '#D5A16A', 2) + ellipse(x, y, 6, 3, '#EAC079', 0) + ellipse(x - 2, y - 1, 1.5, 1, '#9CB35E', 0)

def stool(x, y, wood):
    return path(f'M{x - 11} {y - 9} L{x + 11} {y - 9} L{x + 10} {y + 5} Q{x} {y + 10} {x - 10} {y + 4} Z', '#98764F' if wood else '#8F9683', 2) + ellipse(x, y - 9, 11, 6, '#D1B080' if wood else '#C0C3AC', 2)

def serving_table(x, y, wood):
    b = ''
    if wood:
        for dx in (-37, 37):
            for dy in (-8, 25):
                b += line(x + dx, y + dy - 13, x + dx, y + dy + 12, '#4E342E', 7) + line(x + dx - 1, y + dy - 12, x + dx - 1, y + dy + 10, '#A58050', 3)
        b += rect(x - 47, y - 10, 94, 36, '#81633F', 4, 3)
        b += path(f'M{x - 43} {y - 18} Q{x} {y - 20} {x + 43} {y - 18} L{x + 47} {y + 17} Q{x} {y + 20} {x - 47} {y + 17} Z', '#C29E65', 4)
        for dy in (-6, 6):
            b += line(x - 43, y + dy, x + 43, y + dy, '#9D7A47', 1.5)
    else:
        b += rect(x - 29, y + 2, 58, 30, '#8E9787', 5, 3)
        b += path(f'M{x - 47} {y - 13} L{x + 44} {y - 13} L{x + 49} {y + 12} L{x + 43} {y + 24} L{x - 43} {y + 24} L{x - 49} {y + 14} Z', '#949D8A', 3)
        b += path(f'M{x - 43} {y - 20} Q{x} {y - 23} {x + 41} {y - 19} L{x + 48} {y + 10} Q{x} {y + 15} {x - 48} {y + 10} Z', '#C3C6AE', 4)
        b += path(f'M{x + 29} {y - 14} l-8 7 l5 5', 'none', 0, ' stroke="#A2AA95" stroke-width="2"')
    return b + bowl(x + 10, y - 3)

back = '  <path d="M70 89 L70 213" stroke="#4E342E" stroke-width="10" stroke-linecap="round" fill="none"/>\n  <path d="M69 91 L69 211" stroke="#AE925A" stroke-width="5" stroke-linecap="round" fill="none"/>\n  <ellipse cx="70" cy="104" rx="3" ry="2" fill="#D7BD82"/>\n  <ellipse cx="70" cy="128" rx="3" ry="2" fill="#D7BD82"/>\n  <ellipse cx="70" cy="152" rx="3" ry="2" fill="#D7BD82"/>\n  <ellipse cx="70" cy="176" rx="3" ry="2" fill="#D7BD82"/>\n  <ellipse cx="70" cy="200" rx="3" ry="2" fill="#D7BD82"/>\n  <path d="M198 125 L198 245" stroke="#4E342E" stroke-width="10" stroke-linecap="round" fill="none"/>\n  <path d="M197 127 L197 243" stroke="#AE925A" stroke-width="5" stroke-linecap="round" fill="none"/>\n  <ellipse cx="198" cy="140" rx="3" ry="2" fill="#D7BD82"/>\n  <ellipse cx="198" cy="164" rx="3" ry="2" fill="#D7BD82"/>\n  <ellipse cx="198" cy="188" rx="3" ry="2" fill="#D7BD82"/>\n  <ellipse cx="198" cy="212" rx="3" ry="2" fill="#D7BD82"/>\n  <ellipse cx="198" cy="236" rx="3" ry="2" fill="#D7BD82"/>\n  <path d="M24 154 L24 274" stroke="#4E342E" stroke-width="10" stroke-linecap="round" fill="none"/>\n  <path d="M23 156 L23 272" stroke="#AE925A" stroke-width="5" stroke-linecap="round" fill="none"/>\n  <ellipse cx="24" cy="169" rx="3" ry="2" fill="#D7BD82"/>\n  <ellipse cx="24" cy="193" rx="3" ry="2" fill="#D7BD82"/>\n  <ellipse cx="24" cy="217" rx="3" ry="2" fill="#D7BD82"/>\n  <ellipse cx="24" cy="241" rx="3" ry="2" fill="#D7BD82"/>\n  <ellipse cx="24" cy="265" rx="3" ry="2" fill="#D7BD82"/>\n  <path d="M48 173 L105 197 L96 205 L40 181 Z" fill="#9C7C4D" stroke="#4E342E" stroke-width="4" stroke-linejoin="round" stroke-linecap="round"/>\n  <path d="M48 165 Q43 147 50 140 L62 140 Q70 155 64 165 Z" fill="#B98254" stroke="#4E342E" stroke-width="3" stroke-linejoin="round" stroke-linecap="round"/>\n  <ellipse cx="56" cy="140" rx="6" ry="3" fill="#74513B" stroke="#4E342E" stroke-width="2"/>\n  <path d="M74 176 Q69 158 76 151 L88 151 Q96 166 90 176 Z" fill="#B98254" stroke="#4E342E" stroke-width="3" stroke-linejoin="round" stroke-linecap="round"/>\n  <ellipse cx="82" cy="151" rx="6" ry="3" fill="#74513B" stroke="#4E342E" stroke-width="2"/>\n<g transform="translate(-18,0)">  <path d="M91 230 L111 210 L143 215 L163 232 L164 253 L141 269 L105 260 L88 245 Z" fill="#9D9F8B" stroke="#4E342E" stroke-width="4" stroke-linejoin="round" stroke-linecap="round"/>\n  <path d="M92 229 L112 212 L142 217 L160 232 L133 245 L105 239 Z" fill="#CDC8AD" stroke="#4E342E" stroke-width="3" stroke-linejoin="round" stroke-linecap="round"/>\n  <path d="M124 248 L150 239 L152 254 L131 262 Z" fill="#684B34" stroke="#4E342E" stroke-width="3" stroke-linejoin="round" stroke-linecap="round"/>\n  <path d="M141 259 C135.96 255.4 137.4 248.2 141 243.16 C142.44 248.2 146.76 251.08 145.32 256.84 Z" fill="#FF8A65" stroke="#4E342E" stroke-width="4" stroke-linejoin="round" stroke-linecap="round"/>\n  <path d="M141 257.56 C138.84 255.4 139.56 251.8 141.36 248.92 C142.44 252.52 143.88 253.96 143.16 256.84 Z" fill="#FFD54F"/>\n  <path d="M97 215 Q97 242 119 246 Q146 251 153 225 L154 216 Z" fill="#8A5944" stroke="#4E342E" stroke-width="4" stroke-linejoin="round" stroke-linecap="round"/>\n  <path d="M140 224 L153 219 Q150 243 136 245 Z" fill="#684331"/>\n  <ellipse cx="126" cy="214" rx="29" ry="14" fill="#AF7954" stroke="#4E342E" stroke-width="4"/>\n  <ellipse cx="126" cy="214" rx="22" ry="9" fill="#E7B574"/>\n  <ellipse cx="120" cy="211" rx="10" ry="3" fill="#F0CA8A"/>\n  <path d="M98 217 Q88 208 86 219 Q86 231 100 230 M151 219 Q165 217 160 229 L149 235" fill="none" stroke="#4E342E" stroke-width="3" stroke-linejoin="round" stroke-linecap="round"/>\n  <path d="M125 214 L76 255" stroke="#6C5136" stroke-width="5" stroke-linecap="round" fill="none"/>\n  <path d="M126 213 L77 254" stroke="#C5A270" stroke-width="2" stroke-linecap="round" fill="none"/>\n</g>'

roof = '\n  <!-- Phác khu bếp3×3; layer để thử người trong khu, chưa phải asset game -->\n  <path d="M20 143 L133 179 L204 109 L199 122 L143 195 L132 198 L121 190 L111 192 L99 183 L88 185 L78 176 L66 178 L56 168 L43 169 L32 160 L20 161 Z" fill="#858953" stroke="#4E342E" stroke-width="4" stroke-linejoin="round" stroke-linecap="round"/>\n  <path d="M19 143 Q45 118 66 77 Q99 84 126 94 L202 109 Q181 137 155 165 L134 185 L122 180 L111 184 L99 175 L88 176 L77 168 L65 170 L55 161 L43 162 L31 151 Z" fill="#B7B06E" stroke="#4E342E" stroke-width="5" stroke-linejoin="round" stroke-linecap="round"/>\n  <path d="M66 80 Q104 87 127 98 L197 110 L185 123 L54 96 Z" fill="#C8BE7C"/>\n  <path d="M73.33333333333333 86.61111111111111 L28.11111111111111 137.16666666666666" stroke="#90945A" stroke-width="3" stroke-linecap="round" fill="none"/>\n  <path d="M70.33333333333333 92.61111111111111 L25.11111111111111 132.16666666666666" stroke="#D6C783" stroke-width="1.5" stroke-linecap="round" fill="none"/>\n  <path d="M88.0 89.83333333333333 L40.33333333333333 141.5" stroke="#90945A" stroke-width="3" stroke-linecap="round" fill="none"/>\n  <path d="M85.0 95.83333333333333 L37.33333333333333 136.5" stroke="#D6C783" stroke-width="1.5" stroke-linecap="round" fill="none"/>\n  <path d="M102.66666666666667 93.05555555555556 L52.55555555555556 145.83333333333334" stroke="#90945A" stroke-width="3" stroke-linecap="round" fill="none"/>\n  <path d="M99.66666666666667 99.05555555555556 L49.55555555555556 140.83333333333334" stroke="#D6C783" stroke-width="1.5" stroke-linecap="round" fill="none"/>\n  <path d="M117.33333333333334 96.27777777777777 L64.77777777777777 150.16666666666666" stroke="#90945A" stroke-width="3" stroke-linecap="round" fill="none"/>\n  <path d="M114.33333333333334 102.27777777777777 L61.77777777777777 145.16666666666666" stroke="#D6C783" stroke-width="1.5" stroke-linecap="round" fill="none"/>\n  <path d="M132.0 99.5 L77.0 154.5" stroke="#90945A" stroke-width="3" stroke-linecap="round" fill="none"/>\n  <path d="M129.0 105.5 L74.0 149.5" stroke="#D6C783" stroke-width="1.5" stroke-linecap="round" fill="none"/>\n  <path d="M146.66666666666669 102.72222222222223 L89.22222222222223 158.83333333333334" stroke="#90945A" stroke-width="3" stroke-linecap="round" fill="none"/>\n  <path d="M143.66666666666669 108.72222222222223 L86.22222222222223 153.83333333333334" stroke="#D6C783" stroke-width="1.5" stroke-linecap="round" fill="none"/>\n  <path d="M161.33333333333331 105.94444444444444 L101.44444444444444 163.16666666666666" stroke="#90945A" stroke-width="3" stroke-linecap="round" fill="none"/>\n  <path d="M158.33333333333331 111.94444444444444 L98.44444444444444 158.16666666666666" stroke="#D6C783" stroke-width="1.5" stroke-linecap="round" fill="none"/>\n  <path d="M176.0 109.16666666666667 L113.66666666666667 167.5" stroke="#90945A" stroke-width="3" stroke-linecap="round" fill="none"/>\n  <path d="M173.0 115.16666666666667 L110.66666666666667 162.5" stroke="#D6C783" stroke-width="1.5" stroke-linecap="round" fill="none"/>\n  <path d="M190.66666666666666 112.38888888888889 L125.88888888888889 171.83333333333334" stroke="#90945A" stroke-width="3" stroke-linecap="round" fill="none"/>\n  <path d="M187.66666666666666 118.38888888888889 L122.88888888888889 166.83333333333334" stroke="#D6C783" stroke-width="1.5" stroke-linecap="round" fill="none"/>\n  <path d="M31 132 Q73 143 147 174" fill="none" stroke="#7F8450" stroke-width="3"/>\n  <path d="M50 136 L59 144" stroke="#DCCA91" stroke-width="2" stroke-linecap="round" fill="none"/>\n  <path d="M93 150 L102 158" stroke="#DCCA91" stroke-width="2" stroke-linecap="round" fill="none"/>\n  <path d="M127 163 L136 171" stroke="#DCCA91" stroke-width="2" stroke-linecap="round" fill="none"/>\n'

steam = '<g transform="translate(-18,0)">\n  <!-- Phác khu bếp3×3; layer để thử người trong khu, chưa phải asset game -->\n  <path d="M126 195 q-5 -8 1 -14 M139 202 q5 -8 0 -14" fill="none" stroke="#FFF3D7" stroke-width="3" stroke-linecap="round" opacity="0.8"/>\n</g>'

pole = '  <path d="M140 192 L140 312" stroke="#4E342E" stroke-width="10" stroke-linecap="round" fill="none"/>\n  <path d="M139 194 L139 310" stroke="#AE925A" stroke-width="5" stroke-linecap="round" fill="none"/>\n  <ellipse cx="140" cy="210" rx="3" ry="2" fill="#D7BD82"/>\n  <ellipse cx="140" cy="234" rx="3" ry="2" fill="#D7BD82"/>\n  <ellipse cx="140" cy="258" rx="3" ry="2" fill="#D7BD82"/>\n  <ellipse cx="140" cy="282" rx="3" ry="2" fill="#D7BD82"/>\n  <ellipse cx="140" cy="306" rx="3" ry="2" fill="#D7BD82"/>\n  <ellipse cx="140" cy="313" rx="7" ry="3" fill="#AE966C"/>\n'

SCALES = {1: 0.76, 2: 0.89, 3: 1.0}

CENTERS = {1: [(254, 141), (254, 234)], 2: [(211, 141), (319, 188), (211, 234)], 3: [(201, 141), (310, 141), (201, 234), (310, 234)]}

SEAT_OFFSET = {1: 51, 2: 38, 3: 38}

CANOPY_SCALES = {1: 0.52, 2: 0.6, 3: 0.67}

def shrink(body, level):
    s = SCALES[level]
    return f'<g transform="translate(192,192) scale({s}) translate(-192,-192)">' + body + '</g>'

def canopy(body, level):
    return f'<g transform="translate(12,20) scale({CANOPY_SCALES[level]})"><g transform="translate(210,0) scale(-1,1)">' + body + '</g></g>'

def dining(body, x, y, factor):
    return f'<g transform="translate({x},{y}) scale({factor})">' + body + '</g>'

def mat(x, y):
    b = rect(x - 29, y - 43, 58, 86, '#C2A36C', 4, 3) + rect(x - 25, y - 39, 50, 78, '#D7BC82', 3, 0)
    for dy in range(-35, 39, 6):
        b += line(x - 23, y + dy, x + 23, y + dy, '#B89A63', 1.2)
    for dx in range(-20, 23, 7):
        b += line(x + dx, y - 37, x + dx, y + 37, '#E5CE99', 1)
    for dx in range(-24, 29, 6):
        b += line(x + dx, y + 43, x + dx, y + 47, '#AC8B55', 2) + line(x + dx, y - 43, x + dx, y - 47, '#AC8B55', 2)
    return b + bowl(x, y - 18) + bowl(x, y + 18)

def table(x, y, wood):
    b = ''
    if wood:
        for dx in (-22, 22):
            for dy in (-24, 38):
                b += line(x + dx, y + dy - 4, x + dx, y + dy + 17, '#4E342E', 7) + line(x + dx - 1, y + dy - 3, x + dx - 1, y + dy + 15, '#A58050', 3)
        b += path(f'M{x - 30} {y + 30} L{x + 30} {y + 30} L{x + 29} {y + 47} L{x - 29} {y + 47} Z', '#81633F', 3)
        b += path(f'M{x - 26} {y - 39} Q{x} {y - 41} {x + 26} {y - 39} L{x + 30} {y + 39} Q{x} {y + 42} {x - 30} {y + 39} Z', '#C29E65', 4)
        for dx in (-9, 9):
            b += line(x + dx, y - 36, x + dx, y + 38, '#9D7A47', 1.5)
        b += line(x - 24, y + 36, x + 24, y + 36, '#DABD81', 1.5)
    else:
        b += rect(x - 18, y + 17, 36, 36, '#8E9787', 5, 3)
        b += path(f'M{x - 30} {y - 31} L{x + 29} {y - 31} L{x + 33} {y + 35} L{x + 27} {y + 48} L{x - 27} {y + 48} L{x - 33} {y + 36} Z', '#949D8A', 3)
        b += path(f'M{x - 26} {y - 40} Q{x} {y - 43} {x + 25} {y - 39} L{x + 32} {y + 34} Q{x} {y + 41} {x - 32} {y + 35} Z', '#C3C6AE', 4)
        b += path(f'M{x + 20} {y - 30} l-6 8 l4 9', 'none', 0, ' stroke="#A2AA95" stroke-width="2"')
    return b + bowl(x, y - 17) + bowl(x, y + 19)

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
        top = top.replace('#B7B06E', '#AAA267').replace('#C8BE7C', '#BDB67B')
        top += path('M52 115 l17 5 l-12 20 l-16 -5 Z', '#A2945C', 1.5)
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
        top = top.replace('#B7B06E', '#C5B676').replace('#858953', '#91834F')
        top += path('M23 142 Q78 152 136 184 L135 194 Q76 162 23 152 Z', '#AD9C63', 2)
        for i in range(7):
            x = 32 + i * 15
            y = 149 + i * 5.6
            top += line(x, y, x - 3, y + 12, '#DDCA89', 2)
        top += line(67, 79, 201, 110, '#4E342E', 6) + line(68, 78, 201, 109, '#D1B984', 2)
        top += ellipse(179, 112, 9, 7, '#AD8951', 2)
        for dx, dy in [(0, -11), (0, 11), (-12, 0), (12, 0)]:
            top += line(179 + dx * 0.7, 112 + dy * 0.7, 179 + dx, 112 + dy, '#7A603D', 1.5)
    return (cook, top, front_pole)

def layers(level):
    result = {}
    def put(name, body):
        result[name] = body
    ground = rect(4, 65, 376, 254, '#C8A27A', 20, 0) + rect(11, 72, 362, 240, '#CBA979', 17, 0)
    ground += ellipse(78, 178, 58, 28, '#B99B70', 0)
    ground += ellipse(139, 303, 24, 12, '#D2B588', 0)
    for x, y in [(140, 219), (161, 256), (286, 193), (279, 281)]:
        ground += line(x, y, x + 7, y, '#B99569', 1.5)
    put('floor_' + str(level), shrink(ground, level))
    rear = fence(14, 88, 370, 88, level) + fence(14, 88, 14, 302, level) + fence(370, 88, 370, 302, level)
    front = fence(14, 302, 100, 302, level) + fence(176, 302, 370, 302, level) + ellipse(138, 311, 33, 5, '#DDC198', 0)
    if level == 3:
        rear += ellipse(273, 55, 9, 7, '#C19B61', 2)
        for dx, dy in [(0, -11), (0, 11), (-12, 0), (12, 0)]:
            rear += line(273 + dx * 0.7, 55 + dy * 0.7, 273 + dx, 55 + dy, '#80633E', 1.5)
    put('fence_back_' + str(level), shrink(rear, level))
    put('fence_front_' + str(level), shrink(front, level))
    cook, top, front_pole = upgraded_cooking(level)
    put('cook_' + str(level), shrink(canopy(cook, level), level))
    put('roof_' + str(level), shrink(canopy(top, level), level))
    put('pole_' + str(level), shrink(canopy(front_pole, level), level))
    put('steam_' + str(level), shrink(canopy(steam, level), level))
    serving = serving_table(0, 0, level != 2) + bowl(-23, -4) + bowl(25, -5)
    serving += ellipse(0, 5, 9, 4, '#A47748', 2) + ellipse(-1, 4, 6, 2, '#91AA56', 0)
    put('serving_' + str(level), shrink(dining(serving, 58, 257, 0.7), level))
    seats = ''
    for index, (x, y) in enumerate(CENTERS[level]):
        offset = SEAT_OFFSET[level]
        if level == 1:
            surface = dining(mat(0, 0), x, y, 0.76)
        else:
            surface = dining(table(0, 0, level == 3), x, y, 0.6)
            for sx in (x - offset, x + offset):
                seats += dining(stool(0, 0, level == 3), sx, y + 12, 0.72)
        put(f'dining_{level}_{index}', shrink(surface, level))
    put('seats_' + str(level), shrink(seats, level))
    return result


def composite(level):
    parts = layers(level)
    names = [f"floor_{level}", f"fence_back_{level}", f"cook_{level}", f"roof_{level}", f"steam_{level}", f"pole_{level}", f"serving_{level}", f"seats_{level}"]
    names += [f"dining_{level}_{i}" for i in range(len(CENTERS[level]))]
    names += [f"fence_front_{level}"]
    return svg(384, 336, "".join(parts[n] for n in names), "Bếp3×2, neo192,296; mái nghiêng phải, bàn dọc")

def generate(write):
    # Muôi thật để đầu bếp khuấy, icon nồi chỉ dùng trên đầu/bảng thông tin.
    write("props/cooking_spoon", svg(20, 80, line(10, 6, 10, 62, LINE, 7) + line(9, 6, 9, 61, "#C3A375", 3) + ellipse(10, 68, 7, 9, "#AD8954", 3)))
    for level in (1,2,3):
        for name, body in layers(level).items():
            write("buildings/kitchen/" + name, svg(384,336,body))

