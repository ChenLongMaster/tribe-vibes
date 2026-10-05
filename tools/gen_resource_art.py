# Sinh hình SVG cho cây lá rộng/tre/gốc và các mỏ theo lượng (GAME_DESIGN mục 7, 9.2):
# bụi quả, bãi sỏi, đống củi, đá tảng (to / nhỏ) — mỗi loại 3 mức: _100 (còn > 50%),
# _50 (20–50%), _20 (< 20%); bụi quả thêm _empty (trụi, chờ ra quả lại).
# Cùng một loại giữ nguyên dáng / khung hình giữa các mức để đổi hình không bị nhảy.
#   python tools/gen_resource_art.py
import os
import random
import re

OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "placeholder", "env")
OUTLINE = "#4E342E"


def write(name, body, w, h, comment):
    path = os.path.join(OUT, name + ".svg")
    text = (f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">\n'
            f"  <!-- {comment} -->\n" + "".join("  " + line + "\n" for line in body) + "</svg>\n")
    with open(path, "w", encoding="utf-8") as f:
        f.write(text)


# --- Bụi quả to: dâu tây cách điệu, từng quả riêng lẻ tròn mọng ---

BUSH_W, BUSH_H = 192, 160


# --- Bãi sỏi: nền sỏi vụn + nhiều viên đá cuội to nhỏ ---

PATCH_W, PATCH_H = 160, 96


def art_path(d, fill, width=6, color=OUTLINE):
    return f'<path d="{d}" fill="{fill}" stroke="{color}" stroke-width="{width}" stroke-linejoin="round" stroke-linecap="round"/>'


def oval(x,y,rx,ry,fill,width=0,color=OUTLINE):
    return f'<ellipse cx="{x}" cy="{y}" rx="{rx}" ry="{ry}" fill="{fill}" stroke="{color}" stroke-width="{width}"/>'


def branch(x,y,tx,ty,color,width=3):
    return art_path(f'M{x} {y} L{tx} {ty}','none',width,color)


def ground(u, v, height=0, origin=(0, 0)):
    # Hai trục mặt đất xiên trong hình; phương đứng vẫn thẳng, không xoay sprite.
    return (round(origin[0] + 0.86*u - 0.65*v, 2),
            round(origin[1] + 0.40*u + 0.50*v - height, 2))


def leaf_mass(x, y, rx, ry, depth, details=True):
    # Mặt trên là một khối lá nằm trên mặt phẳng xiên, hông trước-phải thấp/tối.
    shape='M-1 0 Q-1.12 -.3 -.86 -.5 Q-.85 -.85 -.52 -.82 Q-.28 -1.12 0 -.94 Q.33 -1.05 .52 -.81 Q.9 -.8 .89 -.48 Q1.13 -.22 1 0 Q1.07 .3 .8 .47 Q.77 .82 .44 .77 Q.12 1.04 -.12 .87 Q-.47 1 -.64 .72 Q-1 .64 -.92 .35 Q-1.09 .22 -1 0 Z'
    b=[]
    # Tọa độ cuối cùng để viền không bị co/giãn theo mặt phẳng tán.
    for offset,fill,width in [(depth,'#506E37',4.5),(0,'#89A951',3.2)]:
        values=[float(v) for v in re.findall(r'[-+]?(?:\d*\.\d+|\d+)',shape)]
        projected=[]
        for u,v in zip(values[::2],values[1::2]):
            projected += [x+rx*u-ry*.32*v,y+offset+rx*.23*u+ry*v]
        numbers=iter(projected)
        path=re.sub(r'[-+]?(?:\d*\.\d+|\d+)',lambda _:f'{next(numbers):.2f}',shape)
        b.append(art_path(path,fill,width))
    if not details:return b
    for dx,dy,turn in [(-.45,-.2,-16),(.05,-.44,18),(.46,.12,-10),(-.2,.42,20)]:
        px=x+rx*dx-ry*.32*dy;py=y+rx*.23*dx+ry*dy
        b.append(f'<g transform="translate({px:.1f} {py:.1f}) rotate({turn+13}) scale(1 .65)">'+art_path('M-11 2 Q-6 -10 12 -5 Q7 7 -11 2 Z','#A5BD68',0)+branch(-6,1,6,-3,'#739247',1.5)+'</g>')
    return b


def tree():
    b=[oval(96,235,54,15,'#6E7541')]
    b += [art_path('M86 149 L101 147 Q96 192 108 218 L132 237 Q115 245 99 233 L87 243 L65 236 L82 224 Q89 201 83 180 L53 160 L61 149 L90 171 Z','#98754F'),
          art_path('M100 163 Q93 199 103 221 L123 235 L110 234 Q97 222 96 203 Z','#795C41',0),
          art_path('M101 190 Q118 158 144 138','none',9),
          art_path('M91 196 Q89 213 93 226 L80 233','none',3,'#C9A675')]
    # Các chạc ở xa vẽ trước, tán gần đè lên: nhìn cả mái tán lẫn hông phải.
    for x,y,rx,ry,depth in [(105,62,48,33,13),(55,103,43,32,14),(142,115,40,32,14),(85,145,48,30,13)]:
        b += leaf_mass(x,y,rx,ry,depth)
    write('tree_01',b,192,256,'Cây lá rộng 3/4 xiên trước-phải: mái tán co chiều sâu, hông thấp, chạc trước/sau')


def bamboo():
    b=[oval(88,250,58,15,'#73804B')]
    # Gốc xếp hai hàng sâu trên đất, thân xa ngắn/mảnh hơn, không thành hàng ngang.
    stalks=[(-24,-24,-18,153),(10,-25,9,192),(27,-8,21,165),(-30,8,-23,172),(4,13,4,206)]
    for u,v,lean,height in stalks:
        bx,by=ground(u,v,0,(88,249));tx=bx+lean;top=by-height
        width=10 if v<0 else 12
        b += [art_path(f'M{bx} {by} Q{bx} {by-height*.6} {tx} {top}','none',width),
              art_path(f'M{bx} {by} Q{bx} {by-height*.6} {tx} {top}','none',width-5,'#8E9E59')]
        for y in range(int(top)+20,int(by)-5,30):
            t=(by-y)/height;x=bx+lean*t*t
            b.append(oval(round(x,1),y,(width-2)/2,2,'#D7C582',1,'#6A7548'))
        b.append(oval(tx,top,4,2.8,'#C5BF7F',1.5))
        b.append(branch(bx-1,by-3,tx-1,top+5,'#B8BA70',1.2))
        # Cành từ nhiều tầng, lá được co theo mặt phẳng xiên thay vì quạt phẳng.
        for t,sign in [(.83,-1),(.69,1)]:
            cy=by-height*t;cx=bx+lean*t*t
            b.append(branch(cx,cy,cx+sign*23,cy-11,'#4E342E',2.5))
            for i in range(3):
                x=cx+sign*i*7;y=cy-i*3
                for flip in (-1,1):
                    dx=sign*(17+i*2);dy=flip*(7+i*2)+dx*.23
                    b.append(art_path(f'M{x:.1f} {y:.1f} Q{x+dx*.25:.1f} {y+dy*1.2:.1f} {x+dx:.1f} {y+dy:.1f} Q{x+dx*.55:.1f} {y-2:.1f} {x:.1f} {y:.1f} Z','#769447' if flip==1 else '#9BAF5C',1.7))
    write('tree_03',b,176,272,'Tre 3/4: gốc trước/sau trên đất xiên, đốt và miệng thân nhìn từ trên, lá co chiều sâu')


def stumps():
    b=[oval(48,58,36,10,'#928660')]
    b += [art_path('M23 23 L72 24 L73 46 L87 59 L64 60 L54 54 L43 63 L21 59 L12 51 L25 44 Z','#957149',4),
          art_path('M54 27 L72 24 L73 46 L85 57 L65 58 L56 49 Z','#795C41',0)]
    b.append('<g transform="translate(47 24) rotate(15)">')
    b += [oval(0,0,27,15,'#D9B783',4),oval(0,0,17,9,'none',2,'#AD8551'),oval(0,0,8,4,'none',2,'#AD8551'),branch(7,3,23,7,'#AD8551',2),'</g>',branch(32,37,30,49,'#BC9865',2)]
    write('tree_stump',b,96,72,'Gốc cây 3/4: mặt cắt xiên rộng, hông phải tối và rễ trước/sau')
    b=[oval(48,58,34,10,'#81895A')]
    stems=[(-15,-15,20),(8,-14,27),(-13,12,24),(15,7,35)]
    for u,v,height in stems:
        x,y=ground(u,v,0,(48,56));top=y-height
        b += [art_path(f'M{x-5} {y} L{x-5} {top} L{x+5} {top} L{x+5} {y} Z','#9FA76B',3),branch(x+3,y-2,x+3,top+2,'#6F7C4A',2),oval(x,top,6,4,'#DBC78C',2),oval(x,top,3,2,'#655C3A'),oval(x,y-7,5,2,'#CDBD7D',1,'#6A7548')]
    write('bamboo_stump',b,96,72,'Gốc tre 3/4: thân trước/sau, miệng rỗng nhìn từ trên')


def bush(stage):
    # Người dùng chọn lại dáng bụi mềm v5; giữ riêng ngoại lệ này với góc v6.
    b=[oval(96,146,76,12,'#657443'),art_path('M67 139 L83 118 M99 143 L106 117 M121 139 L124 115','none',7,'#806443')]
    shape='M21 111 Q9 88 30 75 Q27 52 52 48 Q65 24 91 31 Q114 19 135 43 Q163 40 169 68 Q189 84 174 109 Q178 132 151 138 Q132 150 110 140 Q80 152 61 140 Q33 143 21 111 Z'
    b.append(art_path(shape,'#506E37',5))
    for x,y,rx,ry in [(53,80,31,26),(94,64,36,29),(135,79,31,27),(87,105,40,26),(146,110,20,19)]:
        b.append(oval(x,y,rx,ry,'#799845'))
    # Lá ba chét và quả đỏ có đài xanh giúp đọc được dâu tây ở cỡ nhỏ.
    for x,y,angle in [(39,87,-25),(78,43,20),(121,54,-15),(106,103,25),(157,91,-20),(54,119,15)]:
        b.append(f'<g transform="translate({x} {y}) rotate({angle})">')
        for turn in (-55,0,55):
            b.append(f'<g transform="rotate({turn})">'+art_path('M0 4 L-8 -1 L-10 -6 L-8 -10 L-9 -14 L-4 -16 L0 -20 L4 -16 L9 -14 L8 -10 L10 -6 L8 -1 Z','#96AF5E',1.5,'#5E793E')+branch(0,2,0,-15,'#66843C',1.5)+'</g>')
        b.append('</g>')
    # Từng quả có khoảng lá ở giữa, không ghép đôi; dáng đầy và bóng nhẹ.
    fruits=[(59,56,-12),(137,56,10),(38,78,15),(121,77,-8),(27,104,12),(98,101,-15),(172,106,8),(78,129,6),(154,129,-10),(103,46,12),(80,77,-6),(158,81,10),(59,100,-12),(139,101,8),(40,126,-8),(116,127,12),(78,54,5),(101,77,-10)]
    count={'100':18,'50':9,'20':4,'empty':0}[stage]
    for i,(x,y,angle) in enumerate(fruits[:count]):
        fill='#DF3235' if i%3 else '#C4262E'
        b.append(f'<g transform="translate({x} {y}) rotate({angle}) scale(.65)">')
        b.append(branch(0,-19,1,-12,'#635635',2))
        b.append(art_path('M0 -10 Q11 -15 13 -5 Q16 3 9 10 Q5 14 0 15 Q-6 14 -11 8 Q-17 1 -13 -7 Q-9 -15 0 -10 Z',fill,2.5))
        b.append(art_path('M-9 -5 Q-9 -11 -2 -10 Q5 -11 9 -5 Q11 0 6 5 Q-1 10 -7 4 Q-11 1 -9 -5 Z','#F1534A',0))
        b.append(art_path('M-8 -5 Q-6 -9 -2 -8','none',3,'#FFE1B2'))
        b.append(oval(-9,-1,1.4,1.8,'#FFD4A2'))
        for bx,by in [(4,-5),(-3,1),(6,3),(-5,7),(1,10)]:
            b.append(oval(bx,by,1,1.5,'#F5D382'))
        b.append(art_path('M0 -10 L-7 -13 L-5 -8 L-11 -6 L-4 -5 L0 -2 L4 -6 L10 -8 L4 -9 L6 -15 Z','#769147',1.3,'#506E37'))
        b.append('</g>')
    if stage=='empty':
        for x,y,_ in fruits[:5]:
            b.append(branch(x,y-4,x+3,y+4,'#586D34',2))
    write(f'bush_{stage}',b,192,160,'Bụi dâu tây dáng mềm v5, quả nhỏ/nhiều hơn; từng quả riêng lẻ đỏ tròn đầy, bóng mọng/hạt vàng/đài xanh; sinh đầy, quả giảm khi hái')




def twigs(stage):
    sticks=[(-45,-17,38,-17),(-10,-30,5,30),(-42,13,31,15),(-25,24,46,20),(-30,-25,26,22),(-50,3,24,-1),(25,-25,-12,26),(-47,-8,18,-1),(-12,-15,42,4),(-40,25,15,-26),(-42,20,22,5),(-4,-26,43,-20)]
    keep={'100':12,'50':6,'20':3}[stage]
    scale={'100':1,'50':.8,'20':.6}[stage]
    b=[oval(80,70,62*scale,20*scale,'#948466')]
    for i,(u,v,tu,tv) in sorted(enumerate(sticks[:keep]),key=lambda item:item[1][1]):
        x,y=ground(u,v,3+i*.6,(80,67));tx,ty=ground(tu,tv,3+i*.6,(80,67))
        d=f'M{x} {y} Q{(x+tx)/2:.1f} {(y+ty)/2-3:.1f} {tx} {ty}'
        b += [art_path(d,'none',9),art_path(d,'none',4.5,'#98764F')]
        if i%3==0:
            mx,my=(x+tx)/2,(y+ty)/2
            b += [branch(mx,my,mx-7,my-9,'#4E342E',6),branch(mx,my,mx-7,my-9,'#98764F',3)]
        b.append(oval(tx,ty,3,3.5,'#D6B787',1.5))
    write(f'twigs_{stage}',b,160,96,'Đống củi 3/4: cành nằm theo hai trục đất xiên, chồng trước/sau, đầu gỗ quay trước-phải')


def rock(size,stage):
    w,h=(160,128) if size=='big' else (112,88)
    s={'100':1,'50':.79,'20':.56}[stage];foot=h*.88
    b=[oval(w/2,foot-2,w*.42,h*.085,'#8C8A70')]
    b.append(f'<g transform="translate({w/2*(1-s):.2f} {foot*(1-s):.2f}) scale({s*w/160:.3f} {s*h/128:.3f})">')
    b.append(art_path('M16 70 Q13 56 30 43 L47 28 Q70 18 102 27 L132 44 Q147 53 145 72 L139 96 Q132 109 105 115 L60 111 L32 97 Q17 89 16 70 Z','#A09E8D',6/s))
    b.append(art_path('M100 87 L144 62 L139 96 Q132 109 105 115 L100 102 Z','#858978',0))
    b.append(art_path('M18 65 Q22 48 34 44 L50 30 Q75 23 100 30 L130 47 Q143 54 140 63 L101 90 Q82 98 61 88 L30 76 Q19 73 18 65 Z','#C4C3AF',3/s))
    b.append(art_path('M40 48 L64 33 Q79 29 98 34 L115 45 L91 54 L60 63 Z','#DBD8C0',0))
    b += [branch(101,90,105,112,'#717866',2/s),art_path('M34 91 Q44 83 57 90 L50 97 L39 98 Z','#7B8C57',0)]
    if stage!='100':b.append(art_path('M91 49 L77 60 L85 72 L69 86','none',3/s,'#828676'))
    b.append('</g>')
    if stage!='100':
        for dx,r in [(-.35,4),(.32,5),(-.18,3)]:b.append(oval(round(w/2+dx*w,1),round(foot-1,1),r*1.5,r,'#B3B19E',2))
    write(f'rock_{size}_{stage}',b,w,h,'Đá 3/4 trước-phải: mặt trên rộng xiên, mặt hông phải và mặt trước thấp khác sắc')


def pebbles(stage):
    # Mép không có vòng elip: các hạt/viên rải tới rìa để nhiều bãi kề nhau hòa vào nhau.
    rng=random.Random(19)
    count={'100':54,'50':30,'20':14}[stage]
    b=[]
    for i in range(58):
        x=rng.uniform(8,248);y=rng.uniform(32,137)
        if ((x-128)/120)**2+((y-85)/53)**2 > 1.12: continue
        b.append(oval(round(x,2),round(y,2),rng.uniform(1,2.6),1,'#918C76'))
    spots=[]
    while len(spots)<count:
        x=rng.uniform(10,246);y=rng.uniform(25,127);r=rng.uniform(3,9)
        if ((x-128)/116)**2+((y-79)/50)**2 > 1.0: continue
        spots.append((x,y,r))
    for x,y,r in sorted(spots,key=lambda p:p[1]):
        b.append(f'<g transform="translate({x:.2f} {y:.2f})">')
        b += [art_path(f'M{-r} -2 Q{-r-1} 4 {-r*.3} {r*.6} Q{r} {r*.9} {r} 1 L{r*.8} {-r*.4} Z','#969888',2),
              art_path(f'M{-r} -2 L{-r*.4} {-r*.8} Q{r*.3} {-r} {r*.8} {-r*.4} L{r} 0 L0 {r*.25} Z','#C4C3AF',1.2),'</g>']
    write(f'pebbles_{stage}',b,256,144,'Sỏi rải mép tự do, nhiều bãi kề nhau hòa thành một bãi lớn; neo128,108')


def rock_cluster(stage):
    # Một khối đá liền, nhiều đỉnh và mặt vỡ. Không dùng texture của ảnh tham khảo.
    b=[]
    factor={'100':1.0,'50':.82,'30':.64}[stage]
    b.append(f'<g transform="translate(128,200) scale({factor}) translate(-128,-200)">')
    b.append(art_path('M10 159 Q11 128 17 121 Q28 114 39 111 Q38 87 44 71 Q59 51 69 53 Q82 55 89 69 Q94 40 103 31 Q122 21 134 23 Q150 29 157 59 L173 77 Q186 66 198 69 Q215 80 220 106 L221 128 Q239 134 241 144 Q252 163 247 177 Q236 192 219 195 L174 204 L131 202 Q106 211 83 207 Q48 203 36 190 Q17 182 10 159 Z','#94988A',6/factor))
    # Khối xa cao và mặt bên tối gợi cùng hướng trước-phải với lều.
    b += [art_path('M44 71 Q60 50 69 53 Q80 54 88 70 L92 113 L61 129 Q37 128 38 112 Z','#B8BBA6',3),
          art_path('M103 31 Q122 21 134 23 Q152 31 157 59 L147 99 L116 118 Q95 104 91 82 Z','#CAC8B0',4),
          art_path('M134 26 L154 60 L147 99 L132 110 L130 57 Z','#8D9384',0),
          art_path('M171 80 Q188 67 198 69 Q216 78 219 106 L216 140 L181 154 Q158 145 156 124 Z','#AFB4A1',3),
          art_path('M196 74 L215 108 L214 139 L200 145 L190 112 Z','#818B7C',0),
          art_path('M18 124 L51 112 L82 138 L80 178 L46 186 L12 162 Z','#BBC0AB',3),
          art_path('M62 122 L107 101 L139 124 L149 159 L133 194 L83 203 L56 171 Z','#B3B5A1',4),
          art_path('M107 104 L137 126 L146 159 L133 192 L113 192 L117 141 Z','#8C9584',0),
          art_path('M151 148 L189 133 L223 141 L243 165 L219 190 L172 201 L144 185 Z','#B8BBA5',4),
          art_path('M153 148 L189 136 L218 145 L230 163 L193 174 L164 164 Z','#D5D2B7',2),
          art_path('M63 126 L102 108 L128 126 L109 142 L79 152 Z','#D7D3B8',2),
          art_path('M108 34 L129 29 L140 45 L128 64 L109 72 L99 61 Z','#E0DAC0',0)]
    for d in ('M72 69 L64 91 L74 103','M125 46 L119 70 L125 86','M186 87 L179 103 L187 118','M101 145 L90 164 L95 184','M203 174 L195 188'):
        b.append(art_path(d,'none',2,'#737F70'))
    if stage!='100':
        b.append(art_path('M83 127 L90 149 L79 166 L92 181','none',4,'#677666'))
    b.append('</g>')
    rng=random.Random(53)
    for i in range(13):
        x=rng.uniform(13,243);y=rng.uniform(185,217)
        b.append(oval(round(x,1),round(y,1),rng.uniform(2,6),rng.uniform(1.5,3.2),'#B6B6A0',1.5))
    write(f'rock_cluster_{stage}',b,256,224,'Mỏ đá liền2×2, mức100/50/30; mặt trên rộng, hông thấp, neo128,200')


def main():
    for stage in ("100", "50", "30"):
        rock_cluster(stage)
    tree()
    bamboo()
    stumps()
    for stage in ("100", "50", "20", "empty"):
        bush(stage)
    for stage in ("100", "50", "20"):
        pebbles(stage)
        twigs(stage)
        rock("big", stage)
        rock("small", stage)


main()
