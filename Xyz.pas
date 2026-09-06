{$M 16384, 0, 655360}
{$M 65521, 0, 655360}

{********************************
 *** rpn2std needs HUGE stack ***

 8192 gives a stack overflow for
 Torus:
 (๛(5000-((200-(๛((xý)+(zý))))ý)))

 16384 has been plenty for
 everything so far, but:
 (๛(5000-((200-(๛((xý)+(zý))))ý))) + 1

 so I've decided to use the maximum
 stack TP will let me compile under
}

program xyz;

uses rpn, graph, matrivex, views;

const
  fmax = 329;{329x7}
  pspace = 7;{ fmax / frange;{ 5}  {frange * pspace}
  frange = fmax div pspace;{50}  {maxx and maxz are equal to:}
      e   = 2.71828182845905;
      xp  = 320;{320}
      yp  = 220;{200}
      pov = 400*e;{fmax*e}
{  pal : array[0..15] of byte = (64,63,62,61,60,59,58,57,56,7,20,5,4,3,2,1);{}
  pal : array[0..15] of byte = (1,2,3,4,5,20,7,56,57,58,59,60,61,62,63,64);{}
{  pc  : array[0..15] of byte = (0,1,2,4,6,9,12,16,20,25,30,36,42,49,56,64);{}


var
  mat1, mat2, mat3, rot: matrix;
  cv, _vec: vector;
  gm, gd{, code}: integer;
  i: word;
  axis, _x, _z: longint;
  ch: char;
  xr, yr, x, z, colr: real;
  yequ, plev: string;
  lp: byte;
  error1, error2: boolean;
  view: viewporttype;
  txt : textsettingstype;
  curs: tview;

  procedure v_line(_v1, _v2: vector;
                   rotate: matrix;
                   _graphneg: boolean);
    var v1, v2, fm: vector;
    begin
{      if (sign(_v1[1]) = -sign(_v2[1])) and (abs(_v1[1] - _v2[1]) > 10 ) then
            exit;{}
     v1[0] := fmax;
     v1[1] := 0;
     v1[2] := fmax;
     mv_mul(fm, rot, v1);
     mv_mul(v1, rotate, _v1);
     mv_mul(v2, rotate, _v2);
     setcolor(round(15-(    15*sqrt(sqr(v1[0]-fm[0]) + sqr(v1[2]-fm[2])) / (sqrt(sqr(2*fm[0]) + sqr(2*fm[2])) + $54)    )));{}
{     setcolor(round(15-(sqrt(sqr(x-fmax) + sqr(z-fmax)) / (colr+15))));{}
     v1[0] :=  round(v1[0] * pov / (pov - v1[2])) + xp;
     v1[1] := -round(v1[1] * pov / (pov - v1[2])) + yp;
     v2[0] :=  round(v2[0] * pov / (pov - v2[2])) + xp;
     v2[1] := -round(v2[1] * pov / (pov - v2[2])) + yp;
     if abs(v1[1]) > 32000 then
     begin
       v1[0] := (v1[0] - v2[0]) / (v1[1] - v2[1]) * (sign(v1[1])*32000 - v1[1]) + v1[0];
       v1[1] := sign(v1[1]) * 32000;
     end;
     if abs(v2[1]) > 32000 then
     begin
       v2[0] := (v1[0] - v2[0]) / (v1[1] - v2[1]) * (sign(v2[1])*32000 - v2[1]) + v2[0];
       v2[1] := sign(v2[1]) * 32000;
     end;
     line(round(v1[0]),
          round(v1[1]),
          round(v2[0]),
          round(v2[1])){};
     if _graphneg then
     begin
       _v1[1] := -_v1[1];
       _v2[1] := -_v2[1];
       v_line(_v1, _v2, rotate, false);
     end;
    end;

  procedure x_rot_matrix(var m: matrix; xm: real);
  begin
      m_fill(m, 0);
      m[0, 0] := 1;
      m[1, 1] := cos(xm);
      m[1, 2] := -sin(xm);
      m[2, 1] := sin(xm);
      m[2, 2] := cos(xm);
  end;

  procedure y_rot_matrix(var m: matrix; ym: real);
  begin
      m_fill(m, 0);
      m[0, 0] := cos(ym);
      m[0, 2] := sin(ym);
      m[1, 1] := 1;
      m[2, 0] := -sin(ym);
      m[2, 2] := cos(ym);
  end;

  procedure z_rot_matrix(var m: matrix; zm: real);
  begin
      m_fill(m, 0);
      m[0, 0] := cos(zm);
      m[0, 1] := -sin(zm);
      m[1, 1] := cos(zm);
      m[1, 0] := sin(zm);
      m[2, 2] := 1;
  end;

  procedure init_rot(var ro: matrix; xm, ym: real);
    var xaxis, yaxis: matrix;
    begin
      x_rot_matrix(xaxis, xm * pi / 180);
      y_rot_matrix(yaxis, ym * pi / 180);
      mm_mul(ro, xaxis, yaxis);
    end;

  procedure dispaxis(axiz: integer);
  var v1, v2: vector;
    begin
      clearviewport;
{      outtextxy(160, 0, 'Reverse Polish Notation 3D Graphing Utility');
      outtextxy(260, 8, 'by, Jared Ivey');{}
      setcolor(15);
      for i := 0 to 2 do
      begin
        v_fill(_vec, 0);
        _vec[i] :=  axiz;
     mv_mul(v1, rot, _vec);
        v_fill(_vec, 0);
        _vec[i] := -axiz;
     mv_mul(v2, rot, _vec);
(*        x := fmax;{v_line uses these values to determine color}
        z := fmax;{"                                       "}
        v_line(vec1, vec2, rot, _graphneg);*)
     v1[0] :=  round(v1[0] * pov / (pov - v1[2])) + xp;
     v1[1] := -round(v1[1] * pov / (pov - v1[2])) + yp;
     v2[0] :=  round(v2[0] * pov / (pov - v2[2])) + xp;
     v2[1] := -round(v2[1] * pov / (pov - v2[2])) + yp;
     line(round(v1[0]),
          round(v1[1]),
          round(v2[0]),
          round(v2[1])){};

      end;
    end;

  procedure dispgraph(yequ: string);
  var vec1, vec2: vector;
    function y(x, z: real; var error: boolean): real;
    begin
      y := rpn_eval(yequ, x, z, error);
    end;

  begin
    if ((length(yequ) > 0) and (not (yequ[length(yequ)] in ['^', 'ý', '*', '/', '+', '-']))) or (pos(')', yequ) <> 0) then
      yequ := std2rpn(yequ);
    error1 := false;
    error2 := false;
    cv[0] := fmax;
    cv[2] := fmax;
    cv[1] := y(cv[0], cv[2], error1);
    mv_mul(cv, rot, cv);
    for _z := -frange to frange - 1 do
    begin
      z := _z * pspace;
      for _x := -frange to frange - 1 do
      begin
          x := _x * pspace;
          vec1[0] := x;
          vec1[2] := z;
          vec1[1] := y(vec1[0], vec1[2], error1);
        if not error1 then
        begin
{          mv_mul(vec1, rot, _vec1);{}
           vec2[2] := z + pspace;
           vec2[0] := x;{}
           vec2[1] := y(vec2[0], vec2[2], error2);
{          mv_mul(vec2, rot, _vec2);{}
          if not error2 then
          begin
            v_line(vec1, vec2, rot, _graphneg);
          end;
           vec2[0] := x + pspace;
           vec2[2] := z;
           vec2[1] := y(vec2[0], vec2[2], error2);
{          mv_mul(vec2, rot, _vec);{}
          if not error2 then
            v_line(vec1, vec2, rot, _graphneg);
        end;  {END -- error1}
      end;
      vec1[2] := z + pspace;
      vec1[0] := fmax;{}
      vec1[1] := y(vec1[0], vec1[2], error1);
{      mv_mul(vec1, rot, _vec);{}
      if not (error1 or error2) then
        v_line(vec1, vec2, rot, _graphneg);
    end;

    for _x := -frange to frange - 1 do
      begin
          x := _x * pspace;
          vec1[0] := x;
          vec1[2] := fmax;
          vec1[1] := y(vec1[0], vec1[2], error1);
{         mv_mul(vec1, rot, _vec);{}
          vec2[0] := x + pspace;
          vec2[2] := fmax;{}
          vec2[1] := y(vec2[0], vec2[2], error2);
{         mv_mul(vec2, rot, _vec);{}
        if not (error1 or error2) then
          v_line(vec1, vec2, rot, _graphneg);
    end;
  end;

  procedure title;
  begin
    setcolor(5);      {5566778899aabbccddeefffeeddccbbaa9988776655{}
    outtextxy(160, 0, 'Reverse Polish Notation 3D Graphing Utility');
                                  {abcdeffffedcba{}
    outtextxy(260, 8,             'by, Jared Ivey');
    setcolor(6);
    outtextxy(160, 0, '  verse Polish Notation 3D Graphing Utili');
    outtextxy(260, 8,             'by, Jared Ivey');
    setcolor(7);
    outtextxy(160, 0, '    rse Polish Notation 3D Graphing Uti');
    outtextxy(260, 8,             'by, Jared Ivey');
    setcolor(8);
    outtextxy(160, 0, '      e Polish Notation 3D Graphing U');
    outtextxy(260, 8,             'by, Jared Ivey');
    setcolor(9);
    outtextxy(160, 0, '        Polish Notation 3D Graphing');
    outtextxy(260, 8,             'by, Jared Ivey');
    setcolor(10);
    outtextxy(160, 0, '          lish Notation 3D Graphi');
    outtextxy(260, 8,             'by, Jared Ivey');
    setcolor(11);
    outtextxy(160, 0, '            sh Notation 3D Grap');
    outtextxy(260, 8,             ' y, Jared Ive');
    setcolor(12);
    outtextxy(160, 0, '               Notation 3D Gr');
    outtextxy(260, 8,             '  , Jared Iv');
    setcolor(13);
    outtextxy(160, 0, '                otation 3D');
    outtextxy(260, 8,             '    Jared I');
    setcolor(14);
    outtextxy(160, 0, '                  ation 3D');
    outtextxy(260, 8,             '    Jared ');
    setcolor(15);
    outtextxy(160, 0, '                    ion');
    outtextxy(260, 8,             '     ared');
  end;

  procedure fade(x1, y1, x2, y2: integer; style: byte);
  var i, sh, sl: byte;
  begin
    sh := style div 16;
    sl := style mod 16;
{    if sh < sl then
    begin
      for i := sh to sl do
      begin
        setcolor(i);
        if y1 = y2 then
        begin
          line(x1+round((i-sh)*(x2-x1)/(sl-sh)),y1,x2, y2)
        end
        else
        begin
          line(x1,y1+round((i-sh)*(y2-y1)/(sl-sh)),x2, y2);
        end;
      end;
    end;(*{}
    if sh < sl then
    begin
      for i := sh to sl do
      begin
        setcolor(i);
        line(x1+round((i-sh)*(x2-x1)/(sl-sh)),y1+round((i-sh)*(y2-y1)/(sl-sh)),x2, y2);
      end;
    end;(**)
  end;

begin
{  clrscr;{}
  gd := detect;
  initgraph(gm, gd, '');
  xr := 22.5;{-22.5}
  yr := -45;{45}
  init_rot(rot, xr, yr);
  axis := fmax+25;
  colr := 72{sqrt(sqr(2*fmax)+sqr(2*fmax)){};
      for i := 0 to 15 do
      begin
        gm := round(sqr(i+1)*colr/256){pc[i]{};
        setrgbpalette(pal[i], gm, gm, gm);
      end;

  yequ := 'bx*c+Sbz*c+S+a*d+';
  yequ := 'x100/S50*z100/S50*+';
  yequ := '50*(sin(x/100)+sin(z/100))';
{  yequ := 'x+z';
  yequ := '0';{}
  yequ := yequ + #13;{}
  getviewsettings(view);
{  gettextsettings(txt);
    SetTextJustify(txt.Horiz, txt.Vert);
    SetTextStyle(txt.Font, txt.Direction, txt.CharSize);{}
  repeat
    setviewport(0, 440, 639, 479, true);{0..639, 0..39}

    clearviewport;

    fade(  0,  0, 319,  0, $4e); {} {3d}
    fade(639,  0, 319,  0, $4e); {} {3d}

    fade(  0,  0,   0, 19, $4e); {}
    fade(  0, 39,   0, 19, $4e); {}

    fade(  0, 39, 159, 39, $4e); {}
    fade(319, 39, 159, 39, $4e); {}
    fade(319, 39, 479, 39, $4e); {}
    fade(639, 39, 479, 39, $4e); {}

    fade(639,  0, 639, 19, $4e); {}
    fade(639, 39, 639, 19, $4e); {}
(*    fade(  0,  0, 639,  0, $4e); {} {3d}
    fade(  0,  0,   0, 39, $4e); {}
    fade(  0, 39, 639, 39, $4e); {}
    fade(639,  0, 639, 39, $4e); {}(**)

    setcolor(15);
    readsxy(2, 2, 'y(x,z) = ', yequ);

    if length(yequ) <> 0 then
    begin
      with view do
        setviewport(x1, y1, x2, y2, clip);
      title;
      setviewport(0, 24, 639, 439, true);

      dispaxis(axis);
      dispgraph(yequ);
      v_fill(cv, 0);
    end;


  until length(yequ) = 0;

  closegraph;
end.
    251 - ๛
    253 - ý
    if yequ = 'sin' then yequ := 'ใx*120/Sใz*120/S+50*';
    if yequ = 'sphere' then yequ := '40500x2^-z2^-0.5^';
    (40500-x^2-z^2)^0.5
    if yequ = 'dome' then yequ := '30000x1.5/2^-z2^-0.5^';
    if yequ = 'torus' then yequ := '5000 200x2^z2^+0.5^-2^-0.5^';

{ THIS was just so I could see if the axis looked OK.
  repeat
    ch := readkey;
    case ch of
      '4': yr := yr - 1;
      '6': yr := yr + 1;
      '8': xr := xr + 1;
      '2': xr := xr - 1;
      '+': axis := axis + 1;
      '-': axis := axis - 1;
    end;
    init_rot(rot, xr, yr);
    cleardevice;
    dispaxis(axis);
  until ch in ['q','Q'];}

{  for x := -frange to frange do
    for z := -frange to frange do
      func[x, z] := y(x * pspace, z * pspace);{}

{
ด180
ต181
ถ182
ท183
ธ184

น185
บ186
ป187
ผ188
ฝ189

พ190
ฟ191
ภ192
ม193
ย194

ร195
ฤ196
ล197
ฦ198
ว199

ศ200
ษ201
ส202
ห203
ฬ204

อ205
ฮ206
ฯ207
ะ208
ั209
า210


Input box.

/----------+----------+----------\   ษออออออออออหออออออออออหออออออออออป
|          |          |          |   บ          บ          บ          บ
+----------+----------+----------+   ฬออออออออออฮออออออออออฮออออออออออน
|          |          |          |   บ          บ          บ          บ
+----------+----------+----------+   ฬออออออออออฮออออออออออฮออออออออออน
|          |          |          |   บ          บ          บ          บ
\----------+----------+----------/   ศออออออออออสออออออออออสออออออออออผ

}
{mwrite(1,1,_id_m);
m_fill(mat1, 0);
m_fill(mat2, 0);
m_fill(mat3, 0);
v_fill(vec1, 0);
v_fill(vec2, 0);
v_fill(_vec, 0);

m_rand(mat1);
mwrite(30,1,mat1);
mm_mul(mat2, _id_m, mat1);
mwrite(60,1,mat2);

mwrite(1,5,_id_m);
v_rand(vec1);
mv_mul(vec2, _id_m, vec1);
vwrite(30,5,vec1);
vwrite(60,5,vec2);}

