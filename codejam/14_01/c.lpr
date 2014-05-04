program c;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes , sysutils,math,bbutils
  { you can add units after this };

type TCity = record
      zip: integer;
      oldi: integer;
    end;
  PCity = ^TCity;

function citycomp (data: TObject; a, b: pointer): longint;
begin
  if PCity(a)^.zip < PCity(b)^.zip then exit(-1);
  if PCity(a)^.zip = PCity(b)^.zip then exit(0);
  exit(1);
end;

var T:longint;
    tt, tempi, tempj: longint;
    n, m: longint;

    cities: array[1..100] of TCity;
    links: array[1..100*100] of TLongintArray;
    oldid: array[1..100] of integer;
    connected: array[1..100, 1..100] of boolean;

    stack: TLongintArray;
    stackSize: integer;
    visited: array[1..100] of boolean;

function allowedToSkip(idx: integer): boolean;
var tempStack: TLongintArray;
    tempStackSize: integer;
    tempVisited: array[1..100] of boolean;

  procedure skipVisit(c: integer);
  var
    i: Integer;
  begin
    tempVisited[c] := true;
    for i := 1 to n do begin
      if tempVisited[i] or not connected[c, i] then continue;
      skipVisit(i);
    end;
  end;

var     i: Integer;

begin
  tempVisited := visited;
  for i := 0 to idx do
    skipVisit(stack[i]);
  result := true;
  for i := 1 to n do
    result := result and tempVisited[i];
end;

procedure rec(c: integer);
var
  i: Integer;
  j: Integer;
begin
  write(cities[c].zip);
  visited[c] := true;
  arrayAddFast(stack, stackSize, c);

  for i := 1 to n do
    if not visited[i] then begin
      for j := stackSize - 1 downto 0 do
        if connected[stack[j], i] and allowedToSkip(j) then begin
          stackSize := j + 1;
          rec(i);
          break;
        end;
    end;
  stackSize -= 1;
end;

var    p: Integer;
  i: Integer;
  j: Integer;
begin
  readln(T);

  for tt:=1 to T do begin
    readln(n, m);

    for i := 1 to n do begin
      readln(tempi);
      cities[i].zip:=tempi;
      cities[i].oldi:=i;
    end;

    stableSort(@cities[1], @cities[n], sizeof(cities[1]), @citycomp);

{    write('sorted :');
    for i:=1 to n do write(cities[i].zip , ' ');
    writeln;}

    for i := 1to n do oldid[cities[i].oldi] := i;

    for i := 1 to n do begin
      SetLength(links[i], 0);
      for j := 1 to n do connected[i,j] := false;
    end;

    for j := 1 to m do begin
      readln(tempi, tempj);
      tempi := oldid[tempi];
      tempj := oldid[tempj];
 {     arrayAdd(links[tempi], oldid[tempj]);
      arrayAdd(links[oldid[tempj]], oldid[tempi]);}

      connected[tempi, tempj]:= true;
      connected[tempj, tempi]:= true;
    end;

    for i := 1 to n do begin
      visited[i] := false;

    end;

    stackSize:=0;
    write('Case #',tt,': ');

    rec(1);


    writeln();
  end;
end.


