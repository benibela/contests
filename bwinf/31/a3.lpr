program a3;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes
  { you can add units after this };


var tikzOutput: boolean;

var w, h, n: integer;
    x, y: integer;
    map: array[0..1000, 0..1000] of integer; //0, 1=wall, 2=out, 3=robot
procedure fillRect(v: integer);
var x,y,x1,y1,x2,y2: integer;
begin
  readln(x1,y1,x2,y2);
  for x := x1 to x2 do
    for y := y1 to y2 do
      map[x,y] := v;
  if tikzOutput then
    if v = 2 then
      writeln('\fill[white] (',x1,', ',y1,') rectangle (',x2+1,',',y2+1,');')
     else
      writeln('\fill[blue!60] (',x1,', ',y1,') rectangle (',x2+1,',',y2+1,');');
end;

var rot: integer = 0;

procedure dreheLinks; begin rot -= 1; end;
procedure dreheRechts; begin rot += 1; end;
function amZiel: boolean;
begin
  result := map[x,y] = 2;
end;
function fahre: boolean;
var dx: array[0..3] of integer = (0, 1, 0, -1);
    dy: array[0..3] of integer = (1, 0, -1, 0);
    effrot: Integer;
begin
  effrot := (40000000 + rot) mod 4;
  result := map[x+dx[effrot], y+dy[effrot]] <> 1;
  if result then begin
    x += dx[effrot];
    y += dy[effrot];
    if not amZiel then map[x,y] := 3;
    if tikzOutput then
      write('-- (',x+0.5:2:2, ', ',y+0.5:2:2,')');
    //writeln(effrot, ' ',x, ' ',y, ' ',map[x,y]);
  end;
end;

procedure geheZumFreienQuadrat;
begin
  dreheLinks;
  if not amZiel and not fahre then dreheRechts;
end;

procedure pledge;
var
  oldRot: Integer;
begin
  while not amZiel do begin
    while not amZiel and fahre do ;
    oldRot := rot;
    dreheRechts;
    while (not amZiel) and (oldRot <> rot) do begin
      if fahre then geheZumFreienQuadrat
      else dreheRechts;
    end;
  end;

end;

var   i: Integer;
      nicemap: array[0..3] of char = (' ', 'H', '2', 'r');
begin
  tikzOutput:=paramstr(1) = '--tikz';


  FillChar(map, sizeof(map), 0);
  readln(w, h);
  readln(x, y);

  if tikzOutput then begin
    writeln('\begin{tikzpicture}[scale=0.3]');
    write('\foreach \i in {0'); for i:= 1 to w do write(', ',i); writeln('}');
    writeln('{	\draw[thick,orange,dashed] (\i, 0) -- (\i, ',h,'); }');
    write('\foreach \i in {0'); for i:= 1 to h do write(', ',i); writeln('}');
    writeln('{	\draw[thick,orange,dashed] (0, \i) -- (',w,', \i); }');
    writeln('\fill[gray] (0, 0) rectangle (',w,', 1);');
    writeln('\fill[gray] (0, 0) rectangle (1, ',h,');');
    writeln('\fill[gray] (',w,', ',h,') rectangle (',w-1,', 1);');
    writeln('\fill[gray] (',w,', ',h,') rectangle (1, ',h-1,');');
  end;

  map[x,y] := 3;
  for i := 0 to w-1 do begin map[i, 0] := 1; map[i, h-1] := 1; end;
  for i := 0 to h-1 do begin map[0, i] := 1; map[w-1, i] := 1; end;
  fillRect(2);
  readln(n);
  for i:= 1 to n do fillRect(1);

  if tikzOutput then begin
    writeln('\fill[red] (',x+0.5:2:2, ', ',y+0.5:2:2,') circle (0.4);');
    writeln('\draw[red,very thick,->] (',x+0.5:2:2, ', ',y+0.5:2:2,')');
  end;

  pledge;

  if tikzOutput then begin
    writeln(';');
    writeln('\end{tikzpicture}');
    exit;
  end;



  for y := 0 to h-1 do begin
    for x := 0 to w-1 do
      write(nicemap[map[x,y]]);
    writeln;
  end;

end.

