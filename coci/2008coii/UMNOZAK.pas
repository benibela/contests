program UMNOZAK;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils
  { you can add units after this };
var i,j:cardinal;
    res,a,b,k,temp,temp2,preprod:cardinal;
begin
  res:=0;
  readln(a,b);
  for i:=0 to 9 do
    if (a<=i*i) and (i*i<=b) then
      inc(res);
  for i:=10 to 99 do
    if (a<=i*(i div 10)*(i mod 10)) and (i*(i div 10)*(i mod 10)<=b) then
      inc(res);

  if b>=100 then begin
    k:=1;
    while 100*k<=b do begin
      preprod:=1;
      temp2:=k;
      while (temp2>0) and (preprod>0) do begin
        preprod:=preprod*(temp2 mod 10);
        temp2:=temp2 div 10;
      end;
      if preprod=0 then begin
        inc(k);
        continue;
      end;
      for i:=1 to 9 do begin
        temp:=(100*k+10*i)*i*preprod;
        if temp>=b then break;
        for j:=1 to 9 do begin
          temp:=(temp+i*j*preprod)*j;
          if temp>b then break;
          if temp>=a then inc(res);
        end;
      end;
      inc(k);
    end;
  end;

  writeln(res);
end.

