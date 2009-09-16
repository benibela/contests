program basin;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes
  { you can add units after this };

{$IFDEF WINDOWS}{$R basin.rc}{$ENDIF}

const dirY:array[1..4] of longint=(0,-1,1,0);
      dirX:array[1..4] of longint=(-1,0,0,1);
var map:array[0..200,0..200] of longint;
    res:array[0..200,0..200] of char;
    stack: array[1..1000000] of tpoint;
    i,j,k,l,reps,cs,h,w: longint;
    s:string;
    curbas:char;
    ca: LongInt;
    bestD: Integer;
    rep: Integer;
begin
  readln(reps);
  for rep:=1 to reps do begin
    curbas:='a';
    readln(h,w);
    for i:=0 to h+1 do
      for j:=0 to w+1 do begin
        map[i,j]:=999999999;
        res[i,j]:=#0;
      end;

    for i:=1 to h do begin
      for j:=1 to w do begin
        read(k);
        map[i,j]:=k;
      end;
    end;
    for i:=1 to h do
      for j:=1 to w do begin
        cs:=1;
        stack[1].x:=i;
        stack[1].y:=j;
        while true do begin
          ca:=map[stack[cs].x,stack[cs].y];
          bestD:=-1;
          for k:=1 to 4 do
            if map[stack[cs].x+dirX[k],stack[cs].y+dirY[k]]<ca then
              if (bestD<1) or (map[stack[cs].x+dirX[k],stack[cs].y+dirY[k]]<map[stack[cs].x+dirX[bestD],stack[cs].y+dirY[bestD]]) then
                bestD:=k;
          if bestD<1 then break;
          stack[cs+1].x:=stack[cs].x+dirX[bestD];
          stack[cs+1].y:=stack[cs].y+dirY[bestD];
          cs+=1;
        end;
        if res[stack[cs].x,stack[cs].y]=#0 then begin
          res[stack[cs].x,stack[cs].y]:=curbas;
          curbas:=chr(ord(curbas)+1);
        end;
        for k:=1 to cs-1 do
          res[stack[k].x,stack[k].y]:=res[stack[cs].x,stack[cs].y];
      end;
    writeln('Case #',rep,':');
    for i:=1 to h do begin
      write(res[i,1]);
      for j:=2 to w do begin
        write(' ',res[i,j]);
      end;
      writeln();

    end;
  end;
end.

