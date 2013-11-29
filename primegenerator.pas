program primegenerator;

{$mode objfpc}{$H+}

uses
  classes, sysutils;

{$IFDEF WINDOWS}{$R primegenerator.rc}{$ENDIF}
var a: TBits;
    maxprime, n,i,j,maxindex : cardinal;
begin
  maxprime:= StrToIntDef(ParamStr(1), 100);
  a := TBits.Create(maxprime div 2+10);
  a.ClearAll;
  writeln(2);
  n := 1;
  maxindex := maxprime div 2;
  i:=0;
  while (i < maxindex) do begin
    n += 2;
    if a.Get(i) then begin
      i += 1;
      continue;
    end;
    writeln(n);
    j := i;
    while (j < maxindex) do begin
      a.SetOn(j);
      j := j + n;
    end;
    i += 1;
  end;
end.

