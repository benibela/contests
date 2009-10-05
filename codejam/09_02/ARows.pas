program ARows;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils
  { you can add units after this };

var swaps,x,i,j,k,tc,t,n:longint;
    data: array[1..100] of longint;
    s:string;

{$IFDEF WINDOWS}{$R ARows.rc}{$ENDIF}

begin
  readln(tc);
  for t:=1 to tc do begin
    readln(n);
    for i:=1 to n do begin
      readln(s);
      data[i]:=0;
      for j:=1 to n do
        if s[j]='1' then data[i]:=j;
      //writeln(data[i]);
    end;

    swaps:=0;
    for i:=1 to n do begin
      if data[i]>i then begin
        for j:=i+1 to n do begin
          if data[j]<=i then begin
            for k:=j-1 downto i do begin
              x:=data[k+1];
              data[k+1]:=data[k];
              data[k]:=x;
              swaps+=1;
            end;
            break;
          end;
        end;
      end;
    end;

    writeln('Case #',t,': ',swaps);
  end;
end.

