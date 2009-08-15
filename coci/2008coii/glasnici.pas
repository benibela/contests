program glasnici;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils,math
  { you can add units after this };
const epsilon=1e-9;

var k,d0,t,d,deltaT:extended;
    n,i:longint;
begin
  readln(k);
  readln(n);
  readln(d0);
  t:=0;
  for i:=2 to n do begin
    readln(d);
    if d-t-d0>k then begin
      t:=t+(d-t-d0-k)/2;
      d0:=d-t;
    end else d0:=min(d+t,d0+k);
  end;
  writeln(trunc(t),'.',round(t*1000)-trunc(t)*1000);
end.

