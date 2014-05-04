program a;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes , sysutils,math
  { you can add units after this };

var T:longint;
    w:TStringList;
    s:string;
    c,o: Integer;
    fail: Boolean;
    i,j,n: Integer;
    table: array[1..100, 1..100] of integer;
    table2: array[1..100, 1..100] of char;
    p, pmax: Integer;
    last: char;
    tt: Integer;
    sum: Integer;
    g: Integer;
    local: Integer;
    res: Integer;
    guess: integer;

begin
  readln(T);
  w:=TStringList.create;
  for tt:=1 to T do begin
    readln(N);
    w.Clear;
    for i := 1 to  n do begin
      readln(s);
      w.add(s);
    end;

    fail := false;
    for i := 0 to w.Count - 1 do begin
      last := w[i][1];
      p := 1;
      table[i+1, p] := 0;
      table2[i+1, p] := last;
      for j := 1 to length( w[i]) do
        if w[i][j] = last then table[i+1, p] += 1
        else begin
          p += 1;
          last := w[i][j];
          table[i+1, p] := 1;
          table2[i+1, p] := last;
        end;
      if i = 0 then pmax := p
      else if pmax <> p then fail := true;
    end;

    for i := 1 to n do begin
      for j := 1 to pmax do
        if table2[i, j] <> table2[1, j] then begin fail := true; break; end;
      if fail then Break;
    end;

    if fail then begin writeln('Case #',tt,': ','Fegla Won'); continue; end;

    res := 0;
    for j := 1 to pmax do begin
      local := 100*100*100*100;
      sum := 0;
      for i := 1 to n do sum += table[i,j];
      for guess := 1 to 100 do begin// max(1, sum div n - 2) to sum div n + 2 do begin
        g := 0;
        for i := 1 to n do
          g += abs(table[i,j]-guess);
        if g < local then local := g;
      end;
      res += local;
    end;

    writeln('Case #',tt,': ',res);
  end;
end.

