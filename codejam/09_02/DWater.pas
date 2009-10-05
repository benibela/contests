program DWater;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils ,math
  { you can add units after this };

var i,j,k,l,m,n,tcases,test:longint;
    s:string;
    x,y,r:array[1..100] of longint;
    br: float;
begin
  readln(tcases);
  for test:=1 to tcases do begin
    readln(n);
    for i:=1 to n do begin
      readln(x[i],y[i],r[i]);
    end;
    br:=1000*1000*1000;
    if n=1 then
      br:=r[1]
    else if n=2 then begin
      br:=max(r[1],r[2]);
      br:=min(br, (sqrt(sqr(x[1]-x[2])+sqr(y[1]-y[2]))+r[1]+r[2])/2);
    end else
      for i:=1 to n do begin
        for j:=1 to n do
          if j<>i then k:=j;
        for j:=1 to n do
          if (j<>i) and (j<>k) then l:=j;
        j:=l;
        //i alone
        //j,k together
        br:=min(br,max(r[i], (sqrt(sqr(x[j]-x[k])+sqr(y[j]-y[k]))+r[j]+r[k]))/2);
      end;
    writeln('Case #',test,': ',br:7:7);
  end;
end.

