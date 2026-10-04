# Sinh hình tạm SVG cho công trình Đợt 3 (5 công trình × 3 cấp, móng 3 cỡ) và vài icon.
# Chạy lại khi muốn chỉnh màu / chi tiết: python tools/gen_building_art.py
# Quy ước (khớp ASSET_SPEC.md + data/art_specs.gd): vẽ 2×; rộng = số ô ngang × 128; mép dưới
# hình = mép dưới diện tích công trình; điểm neo cách mép dưới 24 px (= Building.FOOT_INSET ×2).
import kitchen_art
import math
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
    # Góp ý mới ưu tiên da thú + ít rơm, dáng thuôn nhọn; giữ cửa trước-phải.
    tip_y = (76, 69, 61)[level-1]
    skin = ("#B69A76", "#DDC099", "#E4C8A1")[level-1]
    front = ("#A88B69", "#C9AA82", "#D2B489")[level-1]
    ground = rect(5,47,246,249,"#C8A27A",24,0)
    ground += rect(12,54,232,235,"#B99A72",19,0)
    b = ""
    # Nền elip sâu đọc thành chân lều nằm trên đất, không phải đường mép trước.
    b += ellipse(128,247,112,43,"#AA8E69",0)
    for x,y in ((28,249),(65,278),(219,266),(235,229)):
        b += ellipse(x,y,9 if level>1 else 6,5,"#C4BDAA",2)
    # Hai đầu tre ngắn/dây mây thay chùm cọc dài hoặc biểu tượng văn hoá khác.
    b += line(109,tip_y+8,100,tip_y-19,"#4E342E",7)
    b += line(110,tip_y+5,118,tip_y-26,"#4E342E",7)
    b += line(108,tip_y+6,101,tip_y-17,"#C6A46B",3)
    b += line(111,tip_y+4,117,tip_y-24,"#C6A46B",3)
    outline=f"M110 {tip_y} C82 111 43 161 18 240 Q16 257 42 267 C107 309 212 290 238 253 Q244 245 235 227 C213 161 154 106 110 {tip_y} Z"
    if level == 1:
        outline = f"M110 {tip_y} C82 111 43 161 18 240 Q16 257 42 267 L54 260 L57 278 L80 281 L88 271 L95 287 Q160 301 213 276 L208 267 L224 269 L238 253 Q244 245 235 227 C213 161 154 106 110 {tip_y} Z"
    b += path(outline,skin,6)
    b += path(f"M110 {tip_y} C151 117 189 181 238 253 C211 282 183 288 145 290 C139 208 128 132 110 {tip_y} Z",front,0)
    # Nếp da ôm khối và đường ghép xiên thể hiện mặt bên, tránh mặt cửa chính diện.
    b += path("M85 123 C63 166 43 207 35 243","none",0,
              ' stroke="#EDDBC0" stroke-width="7" stroke-linecap="round"')
    b += path("M123 126 C136 164 144 209 145 285","none",0,
              ' stroke="#967452" stroke-width="3" stroke-linecap="round"')
    for y in range(145,270,22):
        x=129+(y-145)*0.12
        b += line(round(x-4,1),y,round(x+7,1),y-3,"#775A3F",2)
    b += path("M53 261 Q91 278 131 281","none",0,
              ' stroke="#AF8B65" stroke-width="3" stroke-linecap="round"')
    # Cửa quay chếch phải: chân cửa xiên lên bên phải, khe mở nằm trong lớp da.
    b += path("M158 279 L157 238 Q159 215 181 207 Q203 201 208 229 L218 261 Q194 275 158 279 Z",LINE,3)
    b += path("M181 202 Q149 213 145 266 L159 277 Q166 250 167 233 Q167 215 181 202 Z","#E9D2AE",3)
    b += path("M181 202 Q215 211 223 256 L211 266 Q209 239 200 222 Q193 211 181 202 Z","#B28D65",3)
    b += line(149,253,164,248,"#6D5737",3)
    b += line(206,244,219,239,"#6D5737",3)
    b += path("M159 280 Q184 280 216 263","none",0,
              ' stroke="#DEBF8F" stroke-width="6" stroke-linecap="round"')
    if level==1:
        # Mảnh da vá và nút khâu thô giúp chất liệu đọc rõ khi zoom gần.
        b += path("M62 194 Q80 190 95 198 L99 226 Q80 240 59 227 Z","#C1A078",3)
        for x,y in ((64,202),(63,218),(77,231),(92,224),(94,206),(77,195)):
            b += line(x-3,y-2,x+3,y+2,"#806045",2)
    if level == 1:
        b += path("M66 159 L78 167 L69 175 L74 184 L60 178 L55 168 Z","#6F573F",2)
        b += path("M101 239 L117 244 L112 256 L98 251 Z","#6F573F",2)
        b += path("M75 166 L85 162 L80 181 L72 175 Z","#C8AB84",2)
        b += path("M45 240 Q60 230 64 244","none",0,' stroke="#8A6B4C" stroke-width="4" stroke-linecap="round"')
    if level==3:
        # Chim Lạc/mặt trời cách điệu và dải răng cưa, vẽ màu đất/đồng trên da.
        b += path("M48 181 Q68 190 83 183 L95 174 L107 176 L98 180 L93 190 Q73 205 56 191 L44 190","none",0,
                  ' stroke="#A46F3F" stroke-width="4" stroke-linejoin="round" stroke-linecap="round"')
        b += path("M65 188 L55 170 L81 184 L67 184 Z","#BD8950",2)
        b += line(79,193,77,202,"#A46F3F",2)
        for x in range(47,127,14):
            y=260+(x-47)*0.16
            b += path(f"M{x} {y:.1f} l6 -6 l6 8","none",0,' stroke="#AC7B43" stroke-width="3" stroke-linejoin="round"')
        # Mặt trời đủ lớn để nhìn khi thu nhỏ, cùng tông hoa văn trên da.
        for i in range(12):
            angle=i*math.tau/12
            b += line(round(87+math.cos(angle)*12,1),round(221+math.sin(angle)*10,1),
                      round(87+math.cos(angle)*18,1),round(221+math.sin(angle)*16,1),"#996B38",2.5)
        b += ellipse(87,221,9,8,"#C49450",2)
        b += ellipse(87,221,4,3,"#E9C583",0)
    # Chỉ phủ rơm ở chóp; phần lớn thân vẫn là da thú. Mép bó rơm tơi, không mái nhà.
    cap=f"M110 {tip_y-3} Q92 99 68 128 L83 122 L90 137 L101 130 L110 142 L123 132 L139 146 L146 132 L163 139 Q138 95 110 {tip_y-3} Z"
    if level == 1:
        cap=f"M110 {tip_y-3} Q92 99 77 120 L92 114 L89 131 L106 122 L116 136 L125 122 L145 132 Q133 96 110 {tip_y-3} Z"
    elif level == 3:
        cap=f"M110 {tip_y-3} Q87 96 56 143 L74 136 L79 151 L91 142 L99 158 L111 145 L127 161 L137 148 L151 162 L158 147 L177 155 Q141 96 110 {tip_y-3} Z"
    b += path(cap,("#A5A36A","#AAB779","#B1BA76")[level-1],3)
    tufts = [(77,124),(89,129),(101,133),(112,134),(124,126),(138,137),(150,130)]
    if level == 1:
        tufts = [(87,117),(99,123),(114,129),(129,120),(140,127)]
    elif level == 3:
        tufts = [(68,140),(82,145),(94,151),(108,144),(123,154),(139,149),(152,155),(164,146)]
    for x,y in tufts:
        b += path(f"M110 {tip_y+6} Q{(110+x)/2:.1f} 104 {x} {y}","none",0,
                  ' stroke="#E7CD87" stroke-width="2.5" stroke-linecap="round"')
    b += path("M91 110 Q112 121 133 112","none",0,
              ' stroke="#8E7246" stroke-width="4" stroke-linecap="round"')
    b += line(112,115,110,132,"#8E7246",3)
    b += line(112,115,121,131,"#8E7246",3)
    if level == 3:
        # Bó rơm trang trí ở hai bên cửa, khác rõ cấp thấp khi nhìn xa.
        for cx,cy in ((140,252),(225,237)):
            b += path(f"M{cx} {cy-22} q-6 12 -9 26 l8 -5 l5 6 l4 -6 l5 1 Z","#CDAE68",2)
            b += line(cx,cy-20,cx-2,cy+2,"#F0D594",2)
            b += line(cx-6,cy-9,cx+4,cy-9,"#886B42",2)
    # Dây neo nhẹ và cọc tre, chân lều bám đất thay sàn/cột nhà.
    for x,y,tx,ty in ((24,265,49,222),(232,271,215,230)):
        b += line(x,y-9,tx,ty,"#CBB58A",3)
        b += line(x,y+3,x,y-12,"#70583F",5)
    # Thu nhỏ quanh cùng chân/neo, sân và diện tích gameplay vẫn 2×2.
    size = (0.76, 0.89, 1.0)[level-1]
    b = ground + f'<g transform="translate(128 276) scale({size}) translate(-128 -276)">{b}</g>'
    return svg(256,300,b,f"Lều da/cỏ cấp {level}: cỡ {size}, cửa phải, cũ rách → lành → hoa văn Lạc Việt")


# --- Bếp (2×2: 256 × 320) ---

def kitchen_trial():
    # Góc lều mẫu: mái nhìn từ trên, mặt mở trước-phải, cọc vẫn đứng thẳng.
    b=rect(5,68,246,247,'#C8A27A',24,0)+rect(12,75,232,234,'#B99A72',19,0)
    b+=ellipse(130,269,106,30,'#AA8E69',0)
    for x,y,top in [(101,221,102),(222,249,135)]:
        b+=line(x,top,x,y,LINE,12)+line(x-1,top+2,x-1,y-2,'#A28B54',6)
        for cy in range(top+18,y,29):b+=ellipse(x,cy,4,2,'#D2BA75',0)
    # Nền bếp/nồi có miệng elip lớn, tay cầm và cạnh đá cùng góc xiên.
    b+=path('M90 253 Q99 234 130 232 L173 247 L182 272 Q173 286 140 289 L103 277 Z','#929481',5)
    b+=path('M95 250 L120 235 L151 239 L174 251 L151 267 L118 262 Z','#C7C5AC',3)
    for x,y in [(107,268),(129,278),(162,275)]:b+=ellipse(x,y,9,5,'#B6B6A0',0)
    b+=flame(140,272,.48)
    b+=path('M111 236 Q109 261 132 266 Q158 276 168 250 L171 237 Z','#8A5944',5)
    b+=path('M151 243 L171 237 Q169 260 155 266 L146 265 Z','#684331',0)
    b+=ellipse(140,236,31,15,'#AC7651',4)
    b+=ellipse(140,236,24,10,'#E7B574',0)
    b+=ellipse(137,233,15,4,'#F0CA8A',0)
    b+=path('M111 233 Q100 229 100 239 Q102 248 113 249 M168 239 Q179 238 176 247 Q174 253 165 253','none',4)
    # Cọc gần vẽ sau nồi, chừa hai bên/mép trước cho món chín do game bày.
    for x,y,top in [(28,271,166),(166,286,216)]:
        b+=line(x,top,x,y,LINE,12)+line(x-1,top+2,x-1,y-2,'#B29860',6)
        for cy in range(top+14,y,24):b+=ellipse(x,cy,4,2,'#D8C389',0)
        b+=line(x-7,top+9,x+6,top+15,'#CFB47B',3)
        b+=line(x-6,top+16,x+6,top+9,'#CFB47B',2)
    # Mái một dốc đơn sơ, có chiều sâu ngang; không vẽ đầu hồi đối xứng.
    b+=path('M24 162 L162 210 L230 124 L224 141 L172 224 L160 227 L151 219 L138 220 L125 212 L112 214 L99 205 L86 205 L74 195 L62 198 L51 187 L39 187 L26 178 Z','#858953',5)
    b+=path('M25 159 Q52 137 78 103 L99 76 Q131 81 164 97 L229 119 Q216 138 204 158 L164 216 L151 211 L140 215 L126 205 L112 206 L100 196 L86 197 L75 187 L62 189 L52 180 L39 180 L24 167 Z','#B7B06E',6)
    b+=path('M99 81 Q128 85 159 102 L224 121 L211 141 Q164 117 87 100 Z','#C8BE7C',0)
    for i in range(9):
        t=(i+.5)/9
        x=99+125*t;y=81+40*t;ex=27+135*t;ey=164+48*t
        b+=path(f'M{x:.1f} {y+5:.1f} Q{x-27:.1f} {y+32:.1f} {ex:.1f} {ey-9:.1f}','none',0,' stroke="#8F9459" stroke-width="3" stroke-linecap="round"')
        b+=line(x-3,y+15,ex-3,ey-18,'#D6C783',1.8)
    b+=path('M36 151 Q97 168 174 202','none',0,' stroke="#7F8450" stroke-width="3" stroke-linecap="round"')
    for x,y in [(56,158),(111,179),(165,198)]:
        b+=line(x-5,y-5,x+6,y+5,'#DCCA91',3)+line(x-5,y+5,x+6,y-5,'#DCCA91',2)
    # Hơi nước ở phần mở, không vượt mái hay che vùng icon cảnh báo.
    b+=path('M131 218 q-5 -9 1 -18 q5 -8 0 -14 M151 224 q6 -8 0 -16','none',0,' stroke="#FFF3D7" stroke-width="3" stroke-linecap="round" opacity="0.85"')
    return svg(256,320,b,'Bếp cấp1 thử: mái cỏ/tre thấp 3/4 trước-phải, nồi đất/bếp đá, giữ khung và neo')



def kitchen(level):
    return kitchen_art.composite(level)


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
    w,h=cols*128,rows*128
    # Toàn nền giữ footprint vuông; bố cục thi công nằm xiên bên trong.
    b=rect(4,4,w-8,h-8,'#C8A27A',20,0)+rect(11,11,w-22,h-22,'#D4B28A',16,0)
    b+=path(f'M17 {h-19} Q{w*.5} {h-4} {w-17} {h-19}','none',0,' stroke="#B08B66" stroke-width="4" stroke-linecap="round"')
    corners=[(.43*w,.23*h),(.87*w,.43*h),(.59*w,.85*h),(.13*w,.64*h)]
    back,side,front,left=corners
    # Dây ở đầu cọc: các đoạn xa ở sau, các cọc gần che lên dây.
    b+=path('M'+' L'.join(f'{x:.1f} {y-22:.1f}' for x,y in corners)+' Z','none',0,' stroke="#D6BD86" stroke-width="3" stroke-linejoin="round"')
    for i in range(5):
        x=w*(.24+i*.11);y=h*(.26+(i%3)*.17)
        b+=line(x,y,x+23,y+10,'#B08B66',3)+line(x+7,y+11,x+23,y+18,'#B08B66',2)
    # Vật liệu nhỏ có mặt trên/hông, không biến móng thành nền bê tông.
    for x,y in [(w*.30,h*.55),(w*.68,h*.64)]:
        b+=path(f'M{x-10:.1f} {y-3:.1f} L{x-3:.1f} {y-10:.1f} L{x+10:.1f} {y-5:.1f} L{x+11:.1f} {y+5:.1f} L{x:.1f} {y+9:.1f} L{x-10:.1f} {y+4:.1f} Z','#A3A591',2.5)
        b+=path(f'M{x-10:.1f} {y-3:.1f} L{x-3:.1f} {y-10:.1f} L{x+10:.1f} {y-5:.1f} L{x:.1f} {y+2:.1f} Z','#D1CDB6',1.5)
    for i in range(3):
        x=w*.62+i*6;y=h*.28+i*6
        b+=line(x,y,x+37,y+17,LINE,6)+line(x,y,x+37,y+17,'#A38A57',3)
        b+=ellipse(x+37,y+17,2,3,'#D7BD82',1)
    for x,y in sorted(corners,key=lambda p:p[1]):
        b+=rect(round(x-6,1),round(y-23,1),12,24,'#9B7A50',3,3)
        b+=line(x+3,y-19,x+3,y-1,'#77583E',2)
        b+=ellipse(round(x,1),round(y-23,1),7,4,'#D7B88A',3)
        b+=line(x-6,y-14,x+6,y-10,'#CFB47B',2)
    return svg(w,h,b,f'Móng{cols}×{rows}: nền phủ ô vuông, cọc/dây/vật liệu bên trong 3/4 trước-phải')



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


# --- Dãy vách đá: khối đá chồng lên nhau (mỗi ô một khối, to hơn ô để liền thành dãy) ---

import math
import random


def boulder_path(cx, cy, rx, ry, rng, points=11):
    """Đường viền tròn méo mó của một tảng đá (đáy phẳng hơn)."""
    pts = []
    for i in range(points):
        a = math.tau * i / points - math.pi / 2
        k = rng.uniform(0.82, 1.08)
        x = cx + math.cos(a) * rx * k
        y = cy + math.sin(a) * ry * k
        if math.sin(a) > 0.3:
            y = min(y, cy + ry * 0.92)
        pts.append((x, y))
    d = f"M{(pts[0][0] + pts[-1][0]) / 2:.1f} {(pts[0][1] + pts[-1][1]) / 2:.1f}"
    for i in range(points):
        p0 = pts[i]
        p1 = pts[(i + 1) % points]
        d += f" Q{p0[0]:.1f} {p0[1]:.1f} {(p0[0] + p1[0]) / 2:.1f} {(p0[1] + p1[1]) / 2:.1f}"
    return d + " Z"


def main():
    kitchen_art.generate(write)
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
