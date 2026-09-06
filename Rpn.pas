unit rpn;

interface

uses
  graph, drivers;

const
{  operators : set of char = ['^', '˝', '˚', '*', '/', '+', '-'];{}
  unaryoperators : set of char = ['˝', 'A', 'S', 'C', 'T', 's', 'c', 't', 'l'];
{  binaryoperators: set of char = ['^', '*', '/', '+', '-'];{}

var _debug, _graphneg: boolean;


    function sign(nu: real): shortint;
    procedure ratio(var u, v: longint; n: real);
    function rpn_eval(equ: string;
         x, z: real;
         var error: boolean): real;
    function nextpos(sub, S: string; start: byte): byte;
    function level(S: string; cur: byte): byte;
    function plevel(S: string): string;
    procedure order(var S: string);
    function odor(S: string): string;
    function operator(S: string): byte;
    function std2rpn(S: string): string;
    procedure rpn2std(R: string; var S: string);
    procedure reads(var S: string);
    procedure readsxy(col, row: integer; prompt: string; var S: string);

implementation

        function sign(nu: real): shortint;
        begin
          sign := 0;
          if nu > 0 then sign :=  1
          else
          if nu < 0 then sign := -1;
        end;{}
    procedure ratio(var u, v: longint; n: real);
    begin
      u := 1;
      v := 1;
      while abs((u / v) - n) > 0.000001 do {0.001}
      begin
        if u / v < n then
          inc(u)
        else
          inc(v);
      end;
    end;

    function rpn_eval(equ: string;
         x, z: real;
         var error: boolean): real;
      var
        stack: array[0..255] of real;
        sp, eb, ep: byte;
        temp1, temp2: real;
        code: integer;
      procedure push(pp: real);
        begin
{          if sp = 255 then RunError(202);{200  0^-1}{201 Range check}{202 stack 203 heap overflow}
          inc(sp);
          stack[sp] := pp;
        end;
      procedure pop(var pp: real);
        begin
{         if sp = 0 then RunError(202);}
          pp := stack[sp];
          dec(sp);
        end;
      function power(nu, ex: real; var imaginary: boolean): real;
        var pwr: real;
            u, v: longint;
        begin
          if ex = 0 then
          begin
            pwr := 1;
            if nu = 0 then
              imaginary := true;
          end

          ELSE

          if nu = 0 then
            pwr := 0

          ELSE

          begin
            pwr := exp(ex*ln(abs(nu)));
            if nu < 0 then
            begin
              ratio(u, v, abs(ex));
              if odd(v) then
              begin
                if odd(u) then pwr := -pwr;
              end

              ELSE

                imaginary := true;
            end;
          end;
          power := pwr;
        end;
      begin
        error := false;
        temp1 := 0;
        temp2 := 0;
        for sp := 255 downto 0 do stack[sp] := 0;
        ep := 0;
        while (not error) and (ep < length(equ)) do
        begin
          inc(ep);
          case equ[ep] of
            '˝': stack[sp] := sqr(stack[sp]);
            'x': push(x);
            'z': push(z);
            '^': begin
                   pop(temp1);
                   pop(temp2);

                   push(power(temp2,temp1, error));
                 end;
            '*': begin
                   pop(temp1);
                   pop(temp2);
                   push(temp2*temp1);
                 end;
            '/': begin
                   pop(temp1);
                   pop(temp2);
                   if temp1 <> 0 then
                     push(temp2/temp1)
                   else
                     error := true;
                 end;
            '+': begin
                   pop(temp1);
                   pop(temp2);
                   push(temp1+temp2);
                 end;
            '-': begin
                   pop(temp1);
                   pop(temp2);
                   push(temp2-temp1);
                 end;
       '0'..'9','.': begin
                   eb := ep;
                   while (equ[ep+1] in ['0'..'9', '.']) and (ep < length(equ)) do inc(ep);
                   val(copy(equ, eb, ep-eb+1), temp1, code);
                   push(temp1);
                 end;
            '„': push(pi);
            'A': stack[sp] := abs(stack[sp]);
            'S': stack[sp] := sin(stack[sp]);
            'C': stack[sp] := cos(stack[sp]);
            'T': begin
                   if cos(stack[sp]) <> 0 then
                     stack[sp] := sin(stack[sp]) / cos(stack[sp])
                   else
                     error := true;
                 end;
            's': begin
                   if stack[sp] < 1 then
                     stack[sp] := ArcTan (stack[sp]/sqrt (1-sqr (stack[sp])))
                   else
                     error := true;
                 end;
            'c': begin
                   if (abs(stack[sp]) < 1) and (stack[sp] <> 0) then
                     stack[sp] := ArcTan (sqrt (1-sqr (stack[sp])) /stack[sp])
                   else
                     error := true;
                 end;
            't': stack[sp] := ArcTan(stack[sp]);
            'l': if stack[sp] > 0 then
                   stack[sp] := ln(stack[sp])
                 else
                   error := true;

          end;
        end;
        if sp <> 1 then error := true;
        rpn_eval := stack[sp];
      end;

    function nextpos(sub, S: string; start: byte): byte;
    var nxtp: byte;
    begin
      nxtp := pos(sub, copy(S, start, 255));
      if nxtp = start then
        nextpos := 0
      else
        nextpos := nxtp + start - 1;
    end;

    function prepos(sub, S: string; done: byte): byte;
    var prep: byte;
        revs: string;
    begin
      revs := '';
      for prep := done downto 1 do
        revs := revs + S[prep];
      prep := pos(sub, revs);
      if prep = 0 then
        prepos := 0
      else
        prepos := done - prep;
    end;

    function level(S: string; cur: byte): byte;
    var i, lvl: byte;
    begin
      lvl := 0;
      for i := 1 to cur do
      case S[i] of
        '(': inc(lvl);
        ')': dec(lvl);
      end;
      if S[cur] = ')' then inc(lvl);
      if S[cur] = '(' then dec(lvl);
      level := lvl;
    end;

    function plevel(S: string): string;
    var
      i: byte;
      pl: string;
    begin
      pl := S;
      for i := 1 to length(pl) do
      begin
        if pl[i] = '(' then
          pl[i] := chr(level(S, i)+ord('A'))
        else
        if pl[i] = ')' then
          pl[i] := chr(level(S, i)+ord('@'))
        else
          pl[i] := ' ';
      end;
      plevel := pl;
    end;

    procedure rexpar(var S: string);
    var openp, closep, i: byte;
      pal: string;
    begin {BEGIN -- REXPAR}
      i := 0;
      while i < length(S) - 6 do
      begin
        inc(i);
        while (copy(S, i, 2) = '((') and
              (nextpos(copy(plevel(S), i, 1), plevel(S), i + 1) =
               nextpos(copy(plevel(S), i + 1, 1), plevel(S), i + 2) + 1) do
        begin
          delete(S, nextpos(copy(plevel(S), i, 1), plevel(S), i + 1), 1);
          delete(S, i, 1);
        end;
      end;
    end; {END -- REXPAR}

    procedure order(var S: string);
      function occur(ch: char; S: string): byte;
      var occurances, i: byte;
      begin {BEGIN -- OCCUR}
        occurances := 0;
        for i := 1 to length(S) do
          if S[i] = ch then inc(occurances);
        occur := occurances;
      end; {END -- OCCUR}

      procedure poperat(operator1, operator2: char);
      var
        position, term1, term2, level1, level2: integer;
      begin {BEGIN -- POPERAT}
        position := 1;
        if (pos(operator1, S) <> 0) or (pos(operator2, S) <> 0) then
        while position < length(S) do
        begin
          inc(position);
          if S[position] in [operator1, operator2] then
          begin
            term2 := position + 1;
            term1 := position - 1;
            level1 := 1;
            level2 := 1;
            while ((not (S[term1] in ['^', '*', '/', '+', '-', '(']))
                or (level1 <> 1))
               and (term1 > 0)
                do
            begin {while}
              case S[term1] of
                '(': dec(level1);
                ')': inc(level1);
              end;
              dec(term1);
            end;  {while}
            while ((not (S[term2] in ['^', '*', '/', '+', '-', ')']))
                or (level2 <> 1))
               and (term2 <= length(S))
                do
            begin {while}
              case S[term2] of
                '(': inc(level2);
                ')': dec(level2);
              end;
              inc(term2);
            end;  {while}
            insert(')', S, term2);
            insert('(', S, term1 + 1);
            inc(position);
          end; {if}
        end;
      end;  {END -- POPERAT}
    begin   {BEGIN -- ORDER}
      S := '(' + S + ')';
{      poperat('˝', '˚');{}
      poperat('^', '˝');
      poperat('*', '/');
      poperat('+', '-');
      rexpar(S);
    end;    {END -- ORDER}

    function odor(S: string): string;
    var stringtemp: string;
    begin
      stringtemp := S;
      order(stringtemp);
      odor := stringtemp;
    end;

    function operator(S: string): byte;
    var i: byte;
    begin
      i := length(S);
{      while not ((i = 0) or ((S[i] in ['^', '˝', '*', '/', '+', '-']) and (level(S, i) = 0))) do(*{}
      while not ((i = 0) or ((S[i] in ['^', '˝', '*', '/', '+', '-', 's', 'c', 't', 'A', 'S', 'C', 'T', 'l'])(**)
             and (level(S, i) = 0))) do
        dec(i);
      operator := i;
    end;

{    procedure commacomplex2i(var S: string);
    var posn: byte;
    begin
      posn := pos(',', S);
      while posn <> 0 do
      begin
        S[posn] := '*';
        insert('+i', S, posn);
        posn := pos(',', S);
      end;
    end;{}

    procedure u_swap(var S: string;
                     old, new: string);
    var lp: byte;
        plev: string;
    begin
      while pos(old + '(', S) <> 0 do
      begin
        plev := plevel(S);
        lp := pos(old + '(', S);                                                {+2}
        insert(new + ')', S, nextpos(chr(ord('A')+level(S,lp+length(old))), plev, lp + length(old)+2)+1);
        S[lp] := '(';
        if length(old) > 1 then
          delete(S, lp + 1, length(old) - 1);{}
      end;
    end;

    procedure unary(var S: string);
    begin
      {don't swap the unary terms any more

       when converting to rpn check to see
       if the first part is a unary operator
       then if it is:

       std2rpn := std2rpn(termAfterOperator) + str2char(operator);
                                                lookup table

      -=- NEVER MIND!!! -=-
      }

      u_swap(S, '˚', '^0.5');
      u_swap(S, 'sqrt', '^0.5');
      u_swap(S, 'sqr', '˝');
      u_swap(S, 'arcsin', 's');(*arc??? MUST go first!*)
      u_swap(S, 'arccos', 'c');
      u_swap(S, 'arctan', 't');
      u_swap(S, 'abs', 'A');
      u_swap(S, 'sin', 'S');
      u_swap(S, 'cos', 'C');
      u_swap(S, 'tan', 'T');
      u_swap(S, 'ln', 'l');{}
    end;

    function std_str(S: string): boolean;
    begin
      std_str := false;
      if ((length(S) > 0) and (not (S[length(S)] in ['^', '˝', '*', '/', '+', '-'])))
         or ((pos('(', S) <> 0)and (pos(')', S) <> 0)) then
        std_str := true;
    end;

    function std2rpn(S: string): string;
      function s2rpn(S: string): string;
(*        function unary_op(uop: string): string;
        var optype: byte;
        begin
          for optype := 1 to length(uop) do
            uop[optype] := upcase(uop[optype]);
                             {0    1     2     3     4     5     6     7     8     9     10    }
          optype := pos(uop, '     SQR   ˚     SQRT  SIN   COS   TAN   ARCSINARCCOSARCTANLN    ') div 6;

          case optype of
            0: unary_op := '?';
            1: unary_op := '˝';
            2: unary_op := '0.5, ^';
            3: unary_op := '0.5, ^';
            4: unary_op := 'S';
            5: unary_op := 'C';
            6: unary_op := 'T';
            7: unary_op := 's';
            8: unary_op := 'c';
            9: unary_op := 't';
           10: unary_op := 'l';
          end;
        end;(**)
      begin
        while ((S[1] = '(') and (S[length(S)] = ')')) and (nextpos('A', plevel(S), 2) = length(S)) do
        begin
          S := copy(S, 2, length(S) -2);
        end;{}

{        if (S[length(S)] = ')') and (prepos('A', S, length(s) - 1) = pos('(', S)) then
          s2rpn := s2rpn(copy(S, pos('(', S), 255)) + ', ' + unary_op(copy(S, 1, pos('(', S)-1))
        else
{        if S[1] = '˚' then
        begin
          s2rpn := s2rpn(copy(
        end

        else
        if S[length(S)] = '˝' then
        begin
          s2rpn := s2rpn(copy(S, 1, length(S) - 1)) + ', ˝'

        end

        else{}
        if operator(S) = 0 then
          s2rpn := S
        else
         if S[operator(S)] in unaryoperators then
          s2rpn := s2rpn(copy(S, 1, operator(S) - 1))
                 + ', '
                 + S[operator(S)]
         else
          s2rpn := s2rpn(copy(S, 1, operator(S) - 1))
                 + ', '
                 + s2rpn(copy(S, operator(S) + 1, 255))
                 + ', '
                 + S[operator(S)];
      end;
    begin
{      commacomplex2i(S);{}
      unary(S);
      order(S);
      std2rpn := s2rpn(S);
    end;

    procedure rpn2std(R: string; var S: string);
    begin

    end;

  {*******************************************}
  {*******************************************}
  {************* READS PROCEDURE *************}
  {*******************************************}
  {*******************************************}
  {reads in a string that can be edited}

  procedure reads(var S: string);
    var
      ch: char;
      col, row: integer;
      event: tevent;
      plev: string;
      cur, temp: byte;
      cursorcolorcounter: word;

    procedure debug;
      var view,db: viewporttype;
          tmpS: string;
      procedure getstor;
      begin
        getviewsettings(view);
        setviewport(0, 360, 639, 439, true);
      end;
      function text(num: integer): string;
      var Strin: string;
      begin
        str(num, Strin);
        text := Strin;
      end;
    begin
      getstor;
      clearviewport;
      outtextxy( 50,  0,'Debug Window');
{      outtextxy(  0,  8,'ch code: '+ text(ord(ch)));}
      outtextxy(  0, 16,'cur pos: '+ text(cur) + '/' + text(length(S)));
      outtextxy( 00, 24,'p level: '+ text(level(S, cur)));
      tmpS := S;
      if std_str(tmpS) then
      begin
        unary(tmpS);
        outtextxy( 00, 48,'unary  : '+ tmpS);
        order(tmpS);
        outtextxy( 00, 32,'       : '+ plevel(tmpS));
        outtextxy( 00, 40,'()opera: '+ tmpS);
        outtextxy( 00, 56,'rpn    : '+ std2rpn(tmpS));
      end else
      begin
        outtextxy( 00, 40,'rpn    : '+ tmpS);
      end;

      with view do
        setviewport(x1, y1, x2, y2, clip);
    end;{}

    procedure stats;
    begin
      setcolor(0);
      outtextxy(138,16,'€€€€€');{y=30}
      outtextxy(66,25,'€€€€€');{y=30}
      setcolor(temp);
      outtextxy(2,16,'graph negative =');
      outtextxy(2,25,'debug =');
      setcolor(temp);
      if _graphneg then
        outtextxy(138,16,'true')
      else
        outtextxy(138,16,'false');
      if _debug then
        outtextxy(66,25,'true')
      else
        outtextxy(66,25,'false');
{      outtextxy(164,12,'            RPN                      STANDARD');
      outtextxy(164,20,'F1 : sin     F3 : dome     Ù   F5 : sin     F7 : dome ');
      outtextxy(164,28,'F2 : sphere  F4 : torus    ı   F6 : sphere  F8 : torus');{}
      outtextxy(255,12,'       STANDARD');
      outtextxy(255,20,'F5 : sin     F7 : dome ');
      outtextxy(255,28,'F6 : sphere  F8 : torus');
    end;

    procedure del(var S: string; var cur: byte);
    begin
      plev := plevel(S);
      if S[cur] = ')' then
      begin
        delete(S, prepos(plev[cur], plev, cur-1)+1, 1);
        dec(cur);
      end
      ELSE
      if S[cur] = '(' then
        delete(S, nextpos(plev[cur], plev, cur+1), 1);
      delete(S, cur, 1);
    end;

  begin  {BEGIN -- READS}
    cursorcolorcounter := 0;
    col := getx;
    row := gety;
    cur := length(S)+1;
    temp := getcolor;
    stats;{}
    if S[length(S)] <> #13 then
    repeat
      moveto(col, row);
      outtext(S);
      if _debug then
        debug;{}
      moveto(col + 8*(cur - 1), row);
      temp := getcolor;
      stats;
      repeat
        cursorcolorcounter := (cursorcolorcounter + 1) mod 1536;{1024}
        setcolor(7 * (cursorcolorcounter div 768));{512}
        outtextxy(col + 8*(cur - 1), row+1, '_');
        outtextxy(col + 8*(cur - 1), row+2, '_');
        getKeyEvent(event);
      until event.what <> evNothing;
        setcolor(0);
        outtextxy(col + 8*(cur - 1), row+1, '_');
        outtextxy(col + 8*(cur - 1), row+2, '_');
      moveto(col, row);
      if (event.keyCode <> kbEnter)
         and (event.keyCode <> kbHome) and (event.keyCode <> kbEnd)
         and (event.keyCode <> kbLeft) and (event.keyCode <> kbRight)
         and (event.keyCode <> kbCtrlLeft) and (event.keyCode <> kbCtrlRight)  then
        outtext(S);
      setcolor(temp);
      case event.keyCode of
        kbEsc: begin
                 _graphneg := _graphneg xor true;
               end;
        kbTab: begin
                 _debug := _debug xor true;
               end;
(*        kbF1 : S := '„x*120/S„z*120/S+50*';{'sin;    „x*120/S„z*120/S+50*';{}
        kbF2 : S := '40500x2^-z2^-0.5^';{'sphere; 40500x2^-z2^-0.5^';{}
        kbF3 : S := '30000x1.5/2^-z2^-0.5^';{'dome;   30000x1.5/2^-z2^-0.5^';{}(**)
        kbF4 : S := '˚(3000-(˚(x˝+(abs(z)-100)˝)-100)˝)';{'torus;  5000 200x2^z2^+0.5^-2^-0.5^';{}
        kbF5 : S := '50*(sin(„*x/120)+sin(„*z/120))';
        kbF6 : S := '˚(40500-x˝-z˝)';
        kbF7 : S := '˚(30000-(x/1.5)˝-z˝)';
        kbF8 : S := '˚(5000-(200-˚(x˝+z˝))˝)';{}
        kbF9 : S := '75*(sin(„*x/120)*sin(„*z/120))';
        kbF10: S := '4*(sin(„*x/120)/sin(„*z/120))';
        kbDel   : begin
                    if cur <= length(S) then
                      del(S, cur);
                  end;
        kbBack  : begin
                    if cur > 1 then
                    begin
                      dec(cur);
                      del(S, cur);
                    end;
                  end;
        kbLeft  : begin
                    if cur > 1 then
                      dec(cur);
                  end;
        kbRight : begin
                    if cur < length(S)+1 then
                      inc(cur);
                  end;
        kbEnd   : cur := length(S)+1;
        kbHome  : cur := 1;
     kbCtrlLeft : begin
                    if cur > 1 then
                    begin
                      while (S[cur-1] in ['(', ')', '^', '*', '/', '+', '-', ',', ':', '{', '}']) and (cur > 1) do
                        dec(cur);
                      while (not (S[cur-1] in ['(', ')', '^', '*', '/', '+', '-', ',', ':', '{', '}'])) and (cur > 1) do
                        dec(cur);
                    end;
                  end;
     kbCtrlRight: begin
                    if cur < length(S) then
                    begin
                      while (not (S[cur] in ['(', ')', '^', '*', '/', '+', '-', ',', ':', '{', '}'])) and (cur < length(S)) do
                        inc(cur);
                      while (S[cur] in ['(', ')', '^', '*', '/', '+', '-', ',', ':', '{', '}']) and (cur < length(S)) do
                        inc(cur);
                    end;
                  end;
        kbUp    : order(S);
        kbAltEqual: S := std2rpn(S);
        kbDown  : begin
                    while pos('(', S) <> 0 do
                      delete(S, pos('(', S), 1);
                    while pos(')', S) <> 0 do
                      delete(S, pos(')', S), 1);
                    cur := length(S) + 1;
                  end;
       kbCtrlBack: begin
                    S := '';
                    cur := 1;
                  end;
       kbAlt2: begin
                   insert('˚', S, cur);
                   inc(cur);
                 end;
       kbAltP: begin
                   insert('„', S, cur);
                   inc(cur);
                 end;

        Else
        ch := event.charCode;
        case ch of
          '@': begin
                 insert('˝', S, cur);
                 inc(cur);
               end;
     ' ', '!',
     '*'..':',
     'A'..'Z',
     '^',
     'a'..'{',
     '}'     : begin
                 insert(ch, S, cur);
                 inc(cur);
               end;
          '(': begin
                 temp := cur;
                 repeat
                   inc(temp)
                 until (temp > length(S)) or (level(S, temp) < level(S, cur));
                 insert(')', S, temp);
                 insert('(', S, cur);
                 inc(cur);
               end;
          ')': begin
                 if (prepos('(', S, cur) <> 0) and (nextpos(')', S, cur+1) <> 0) and (cur < length(S))
                   and (level(S, cur) > 0) then
                 begin
                   temp := cur;
                   repeat
                     inc(temp)
                   until (temp >= length(S)) or (level(S, temp+1) < level(S, cur));
                   delete(S, temp, 1);
                   insert(')', S, cur);
                   inc(cur);
                 end;
               end;
        end;
      end;
      if cur > length(S) then cur := length(S) + 1;
    until event.charCode = #13
    ELSE
      S := copy(S, 1, length(S) - 1);
  end;  {*** reads procedure ***}

  procedure readsxy(col, row: integer; prompt: string; var S: string);
  begin
    outtextxy(col, row, prompt);
    moveto(col + 8 * length(prompt), row);
    reads(S);
  end;
begin
  _debug := false;
  _graphneg := false;
end.
(*     ASCII  CHART

     0123456789ABCDEF

00    ???     0   valid chars:
10       16
20    !"#$%&'()*+,-./    32        32,33,40..43,45..57,65..90,94,97..122
30   0123456789:;<=>?    48         _, !, (..+ , -..9,  A..Z,  ^, a..z
40   @ABCDEFGHIJKLMNO    64
50   PQRSTUVWXYZ[\]^_    80
60   `abcdefghijklmno    96
70   pqrstuvwxyz{|}~   112
80   ÄÅÇÉÑÖÜáàâäãåçéè   128
90   êëíìîïñóòôöõúùûü   144
A0   †°¢£§•¶ß®©™´¨≠ÆØ   160
B0   ∞±≤≥¥µ∂∑∏π∫ªºΩæø   176
C0   ¿¡¬√ƒ≈∆«»… ÀÃÕŒœ   192
D0   –—“”‘’÷◊ÿŸ⁄€‹›ﬁﬂ   208
E0   ‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔ   224
F0   ÒÚÛÙıˆ˜¯˘˙˚¸˝˛ˇ   240
*)


