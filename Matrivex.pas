unit matrivex;

interface
{uses crt;{}

type
  vector   = array[0..2] of real;
  vec4     = array[0..3] of real;
  matrix   = array[0..2, 0..2] of real;
  mat4     = array[0..3, 0..3] of real;


const
  _id_m : matrix = ((1,0,0),(0,1,0),(0,0,1));
  _id_m4: mat4   = ((1,0,0,0),(0,1,0,0),(0,0,1,0),(0,0,0,1));

  procedure v_fill (var     v1: vector;      f: real);
  procedure v_rand (var     v1: vector);
  function  v_norm (        v1: vector): real;
  function  v_dot  (     v1,v2: vector): real;

  procedure v_add  (var result: vector;      v: vector;  sc: real);
  procedure v_sub  (var result: vector;      v: vector;  sc: real);
  procedure v_mul  (var result: vector;      v: vector;  sc: real);
  procedure v_div  (var result: vector;      v: vector;  sc: real);

  procedure v_cross(var result: vector; v1, v2: vector);
  procedure vv_add (var result: vector; v1, v2: vector);
  procedure vv_sub (var result: vector; v1, v2: vector);
  procedure vv_mul (var result: vector; v1, v2: vector);
  procedure vv_div (var result: vector; v1, v2: vector);

  procedure m_fill (var     m1: matrix;      f: real);
  procedure m_rand (var     m1: matrix);
  function  m_norm (        m1: matrix): real;

  procedure m_add  (var result: matrix;      m: matrix;  sc: real);
  procedure m_sub  (var result: matrix;      m: matrix;  sc: real);
  procedure m_mul  (var result: matrix;      m: matrix;  sc: real);
  procedure m_div  (var result: matrix;      m: matrix;  sc: real);

  procedure mv_mul (var result: vector;      m: matrix;   v: vector);

  procedure mm_add (var result: matrix; m1, m2: matrix);
  procedure mm_sub (var result: matrix; m1, m2: matrix);
  procedure mm_mul (var result: matrix; m1, m2: matrix);
{  procedure mwrite(xc, yc: integer;
                   m: matrix);
  procedure vwrite(xc, yc: integer;
                   v: vector);
{}

implementation

  {
   VECTOR
  }

  procedure v_fill(var v1: vector;
                        f: real);
    var t1: byte;
    begin
      for t1 := 0 to 2 do
        v1[t1] := f;
    end;

  procedure v_rand(var v1: vector);
    var t1: byte;
    begin
      for t1 := 0 to 2 do
        v1[t1] := random(99);
    end;

  function v_norm(v1: vector): real;
  begin
    v_norm := sqrt(sqr(v1[0]) + sqr(v1[1]) + sqr(v1[2]));
  end;

  function v_dot(v1, v2: vector): real;
  begin
    v_dot := v1[0] * v2[0] + v1[1] * v2[1] + v1[2] * v2[2];
  end;

  {VECTOR - SCALAR}

  procedure v_add(var result: vector;
                  v: vector;
                  sc: real);
  begin
    result[0] := v[0] + sc;
    result[1] := v[1] + sc;
    result[2] := v[2] + sc;
  end;

  procedure v_sub(var result: vector;
                  v: vector;
                  sc: real);
  begin
    result[0] := v[0] - sc;
    result[1] := v[1] - sc;
    result[2] := v[2] - sc;
  end;

  procedure v_mul(var result: vector;
                  v: vector;
                  sc: real);
  begin
    result[0] := v[0] * sc;
    result[1] := v[1] * sc;
    result[2] := v[2] * sc;
  end;

  procedure v_div(var result: vector;
                  v: vector;
                  sc: real);
  begin
    result[0] := v[0] / sc;
    result[1] := v[1] / sc;
    result[2] := v[2] / sc;
  end;


  {VECTOR - VECTOR}

  procedure v_cross(var result: vector; v1, v2: vector);
  begin
    result[0] := v1[1] * v2[2] - v1[2] * v2[1];
    result[1] := v1[2] * v2[0] - v1[0] * v2[2];
    result[2] := v1[0] * v2[1] - v1[1] * v2[0];
  end;

  procedure vv_add(var result: vector;
                   v1, v2: vector);
  begin
    result[0] := v1[0] + v2[0];
    result[1] := v1[1] + v2[1];
    result[2] := v1[2] + v2[2];
  end;

  procedure vv_sub(var result: vector;
                   v1, v2: vector);
  begin
    result[0] := v1[0] - v2[0];
    result[1] := v1[1] - v2[1];
    result[2] := v1[2] - v2[2];
  end;

  {item to item multiplication}
  procedure vv_mul(var result: vector;
                   v1, v2: vector);
  begin
    result[0] := v1[0] * v2[0];
    result[1] := v1[1] * v2[1];
    result[2] := v1[2] * v2[2];
  end;

  {item to item division}
  procedure vv_div(var result: vector;
                   v1, v2: vector);
  begin
    result[0] := v1[0] / v2[0];
    result[1] := v1[1] / v2[1];
    result[2] := v1[2] / v2[2];
  end;


  {4 - VECTOR}

  procedure v4_mul(var result: vec4; v: vec4; m: mat4);
  begin
  end;


  {
   MATRIX
  }

  procedure m_fill(var m1: matrix;
                        f: real);
    var t1, t2: byte;
    begin
      for t1 := 0 to 2 do
        for t2 := 0 to 2 do
          m1[t1, t2] := f;
    end;

  procedure m_rand(var m1: matrix);
    var t1, t2: byte;
    begin
      for t1 := 0 to 2 do
        for t2 := 0 to 2 do
          m1[t1, t2] := random(99);
    end;

  function  m_norm (m1: matrix): real;
    var t1, t2: byte;
        tmp: real;
    begin
      tmp := 0;
      for t1 := 0 to 2 do
        for t2 := 0 to 2 do
          tmp := tmp + sqr(m1[t1, t2]);
      m_norm := sqrt(tmp);
    end;


  {MATRIX - SCALAR}

  procedure m_add(var result: matrix;
                  m: matrix;
                  sc: real);
    var t1, t2: byte;
    begin
      for t1 := 0 to 2 do
        for t2 := 0 to 2 do
          result[t1, t2] := m[t1, t2] + sc;
    end;

  procedure m_sub(var result: matrix;
                  m: matrix;
                  sc: real);
    var t1, t2: byte;
    begin
      for t1 := 0 to 2 do
        for t2 := 0 to 2 do
          result[t1, t2] := m[t1, t2] - sc;
    end;

  procedure m_mul(var result: matrix;
                  m: matrix;
                  sc: real);
    var t1, t2: byte;
    begin
      for t1 := 0 to 2 do
        for t2 := 0 to 2 do
          result[t1, t2] := m[t1, t2] * sc;
    end;

  procedure m_div(var result: matrix;
                  m: matrix;
                  sc: real);
    var t1, t2: byte;
    begin
      for t1 := 0 to 2 do
        for t2 := 0 to 2 do
          result[t1, t2] := m[t1, t2] / sc;
    end;


  {MATRIX - VECTOR}
  procedure mv_mul(var result: vector;
                   m: matrix;
                   v: vector);
    var r, c: byte;
    begin
      v_fill(result, 0);
      for r := 0 to 2 do
        for c := 0 to 2 do
          result[r] := result[r] + m[r, c] * v[c];
    end;


  {MATRIX - MATRIX}

  procedure mm_add(var result: matrix;
                       m1, m2: matrix);
    var t1, t2: byte;
    begin
      for t1 := 0 to 2 do
        for t2 := 0 to 2 do
          result[t1, t2] := m1[t1, t2] + m2[t1, t2];
    end;

  procedure mm_sub(var result: matrix;
                   m1, m2: matrix);
    var t1, t2: byte;
    begin
      for t1 := 0 to 2 do
        for t2 := 0 to 2 do
          result[t1, t2] := m1[t1, t2] - m2[t1, t2];
    end;

  procedure mm_mul(var result: matrix;
                   m1, m2: matrix);
    var c, r, c2r3: byte;
    begin
      m_fill(result, 0);
      for c := 0 to 2 do
        for r := 0 to 2 do
          for c2r3 := 0 to 2 do
            result[r, c] := result[r, c] + m1[r, c2r3] * m2[c2r3, c];
    end;

{  procedure mwrite(xc, yc: integer;
                   m: matrix);
    var x1, y1: integer;
    begin
      for x1 := 0 to 2 do
        for y1 := 0 to 2 do
        begin
          gotoxy(6 * x1 + xc, 1 * y1 + yc);
          write(m[x1, y1]:3:0);
        end;
    end;

  procedure vwrite(xc, yc: integer;
                   v: vector);
    var x1, y1: integer;
    begin
      for x1 := 0 to 2 do
      begin
        gotoxy(6 * x1 + xc, yc);
        write(v[x1]:3:0);
      end;
    end;{}
end.