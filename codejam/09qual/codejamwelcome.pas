program Project1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes ,sysutils
  { you can add units after this };

const searched='welcome to code jam';
var map: array[1..1000,0..length(searched)] of longint;
    reps:longint;
    rep: Integer;
    s:string;
    i: Integer;
    p: Integer;
begin
  readln(reps);
  for rep:=1 to reps do begin
    readln(s);
    map[length(s)+1,0]:=1;
    for i:=1 to length(searched) do map[length(s)+1,i]:=0;
    for p:=length(s) downto 1 do begin
      map[p]:=map[p+1];
      for i:=1 to length(searched) do
        if s[p]=searched[length(searched)-i+1] then map[p,i]:=(map[p+1,i]+map[p+1,i-1]) mod 10000;
    end;
    write('Case #',rep,': ');
    s:=IntToStr(map[1,length(searched)]);
    while length(s)<4 do s:='0'+s;
    writeln(s);
  end;

end.

