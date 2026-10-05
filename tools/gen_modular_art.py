"""Sinh hình mảnh trang trí dùng chung; không ghi đè scene ráp tay."""
from pathlib import Path

OUT = Path(__file__).resolve().parents[1] / 'assets/placeholder/props/modular'
LINE = '#4E342E'

def path(d, fill, width=6):
    return f'<path d="{d}" fill="{fill}" stroke="{LINE}" stroke-width="{width}" stroke-linejoin="round" stroke-linecap="round"/>'

def line(x1,y1,x2,y2,color,width):
    return f'<path d="M{x1},{y1} L{x2},{y2}" fill="none" stroke="{color}" stroke-width="{width}" stroke-linecap="round"/>'

def ellipse(x,y,rx,ry,fill):
    return f'<ellipse cx="{x}" cy="{y}" rx="{rx}" ry="{ry}" fill="{fill}"/>'

def svg(name,w,h,body):
    OUT.mkdir(parents=True,exist_ok=True)
    (OUT/f'{name}.svg').write_text(f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">{body}</svg>\n',encoding='utf-8')

def stone(index):
    # Mặt trên rộng, vai mềm, hông thấp và tối hơn ở phía phải.
    w = [32,27,35,23,31,25,33,22][index]
    h = [25,30,22,20,28,23,26,19][index]
    shift = [-5,4,-2,3,-4,2,5,-2][index]
    top = ['#C6C8B5','#D2D0BB','#B9C0AF'][index%3]
    b = ellipse(50,55,w+3,5,'#4E342E22')
    b += path(f'M{48-w},46 Q{45-w},{38-h*.2} {48-w*.7},{45-h*.72} Q{43-w*.4},{43-h} {48+shift},{45-h} Q{48+w*.45},{42-h} {48+w*.8},{43-h*.57} Q{50+w},38 {48+w},46 L{47+w},52 Q{48+w*.7},59 47,57 Q{48-w*.75},58 {48-w},51 Z','#929B8C')
    b += path(f'M{48-w},45 Q{47-w},36 {48-w*.7},{45-h*.72} Q{43-w*.4},{43-h} {48+shift},{45-h} Q{48+w*.45},{42-h} {48+w*.8},{43-h*.57} Q{49+w},37 {48+w},45 Q{48+w*.5},49 45,48 Q{48-w*.6},50 {48-w},45 Z',top,3)
    b += path(f'M52,49 Q{48+w*.55},49 {48+w},45 L{47+w},52 Q{48+w*.72},57 53,57 Z','#7E897D',0)
    b += line(48-w*.42,43-h*.64,49+shift,42-h*.74,'#E6E1CC',3)
    if index in (2,5):
        b += line(61,35,65,40,'#9EA58F',2)
    svg(f'stone_{index+1:02}',96,64,b)

def post(material,decor=False):
    wood = material == 'wood'
    x1,x2 = (20,44) if wood else (24,40)
    b=ellipse(32,105,19 if wood else 13,5,'#4E342E22')
    b+=path(f'M{x1},17 Q{x1-1},11 32,10 Q{x2+1},11 {x2},17 L{x2-1},104 Q32,110 {x1+1},104 Z','#A97949' if wood else '#C3AC6A')
    b+=path(f'M{x1},17 Q32,23 {x2},17 Q{x2},9 32,10 Q{x1},9 {x1},17 Z','#D5B57B' if wood else '#E5D099',3)
    b+=line(x1+5,26,x1+5,96,'#D5B57B' if wood else '#E5D099',3)
    if wood:
        b+=path('M34,29 Q29,43 35,55 Q39,66 34,82','none',2)
    else:
        for y in (39,69,92): b+=line(25,y,39,y,'#907947',3)
    if decor:
        for y in (45,50,55): b+=line(x1-2,y,x2+2,y,'#DBC38B',4)
        b+=path('M23,54 Q12,62 19,68 Q27,70 31,54','none',3)
    svg(f'{material}_post'+('_tied' if decor else ''),64,112,b)

def rail(material,axis,length):
    wood=material=='wood'
    fill='#A97949' if wood else '#C3AC6A'
    bright='#D5B57B' if wood else '#E5D099'
    n=length*2
    if axis=='h':
        width=n+32; anchor=width/2
        left,right=anchor-n/2,anchor+n/2
        b=''
        for y,thick in ((33,12 if wood else 8),(62,10 if wood else 7)):
            b+=path(f'M{left},{y} Q{anchor},{y-3} {right},{y-1} L{right},{y+thick} Q{anchor},{y+thick-1} {left},{y+thick} Z',fill)
            b+=line(left+5,y+3,right-5,y+2,bright,3)
        if wood:
            b+=path(f'M{left+4},63 L{right-4},37 L{right-4},44 L{left+4},71 Z',fill,4)
            b+=line(left+12,62,right-12,44,bright,2)
        else:
            for x in (left+12,anchor,right-12):
                b+=line(x,35,x,42,'#917A4C',2)
                b+=line(x+2,63,x+2,68,'#917A4C',2)
        for x in (left,right):
            for y in (35,62):
                b+=line(x-4,y+1,x+5,y+8,'#DBC38B',3)
        svg(f'{material}_h_{length}',width,96,b)
    else:
        # Trục sâu thẳng theo Y; mặt trên và cạnh phải vẽ riêng, không xoay ảnh ngang.
        height=n+72; near=height-8; far=near-n
        b=''
        for x,yoff,thick in ((25,55,12 if wood else 8),(38,26,10 if wood else 7)):
            b+=path(f'M{x},{far-yoff} L{x+thick},{far-yoff+3} L{x+thick},{near-yoff+3} L{x},{near-yoff} Z',fill,4)
            b+=line(x+3,far-yoff+7,x+3,near-yoff-5,bright,2.5)
        if wood:
            b+=path(f'M27,{far-45} L45,{near-23} L39,{near-21} L21,{far-43} Z',fill,3)
        else:
            for y in (far+8,(far+near)/2,near-8):
                b+=line(24,y-47,34,y-45,'#917A4C',2)
                b+=line(38,y-23,45,y-21,'#917A4C',2)
        for y in (far,near):
            b+=line(23,y-44,35,y-40,'#DBC38B',3)
            b+=line(36,y-22,46,y-18,'#DBC38B',3)
        svg(f'{material}_v_{length}',64,height,b)

def main():
    for i in range(8): stone(i)
    for material in ('bamboo','wood'):
        post(material)
        post(material,True)
        for axis in ('h','v'):
            for length in (32,64): rail(material,axis,length)
    print('Generated 20 modular SVG parts; authored scenes untouched.')

if __name__=='__main__': main()
