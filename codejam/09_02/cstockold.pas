program CStock;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils
  { you can add units after this };
function bitCount(test:longint):longint;
begin
  result:=0;
  while test>0 do begin
    result+=1;
    test:=test and (test - 1)
  end;
end;

var i,j,k,l,m,n,tcases,test,result:longint;
    s:string;
    ok:boolean;
    pos:array[1..200,1..200] of boolean;
    points:array[1..200,1..200] of longint;
    plist: array[1..200,0..200] of longint;
    list:array[0..200] of longint;
    used:array[0..200] of boolean;
    best: Integer;
    bestc: Integer;
    sel: Integer;
    //mat:array[1..200,1..200] of boolean;
begin
  readln(tcases);
{  for i:=1 to 20 do
    writeln(i,':',bitcount(i));
    halt;                 }
  for test:=1 to tcases do begin
    readln(n,k);
    fillchar(pos,sizeof(pos),0);
    for i:=1 to n do
      for j:=1 to k do
        read(points[i,j]);

    for i:=1 to n do begin
      for j:=1 to i-1 do begin
        ok:=true;
        for l:=1 to k-1 do begin
          if (points[i,l]=points[j,l]) or
             (points[i,l+1]=points[j,l+1]) or
             ((points[i, l] < points[j,l]) <> (points[i, l+1] < points[j,l+1])) then begin
               ok:=false;
               break;
             end;
        end;
        if ok then begin
          pos[i,j]:=true;
          pos[j,i]:=true;
        end;
        pos[i,i]:=true;
      end;
    end;
      {
    for i:=1 to n do
      plist[i,0]:=0;
    for i:=1 to n do
      for j:=1 to n do
        if pos[i,j] then begin
          plist[i,0]+=1;
          plist[i,plist[i,0]]:=j;
        end;                  }

    result:=0;
    fillchar(used,sizeof(used),0);
    for i:=1 to n do begin
      if used[i] then continue;
      list[0]:=0;
      used[i]:=true;
//      list[1]:=i;
      for j:=1 to n do
        if (i<>j) and pos[i,j] and not used[j] then begin
          list[0]+=1;
          list[list[0]]:=j;
        end;
        {write(i,' ',list[0],': ');
        for k:=1 to list[0] do
          write(list[k], ' ');
        writeln();            }
      result+=1;
      if list[0]>0 then begin
        ok:=true;
        for j:=1 to list[0] do
          for k:=1 to list[0] do
            if not pos[list[j],list[k]] then begin
              ok:=false;
              break;
            end;
        if ok then begin
          for j:=1 to list[0] do
            used[list[j]]:=true;
        end else begin
          best:=0;
          bestc:=0;
          for sel:=1 to 1 shl (list[0]) -1  do begin
            if bitCount(sel)<=bestc then continue;
            ok:=true;
            for j:=1 to list[0] do begin
              if (1 shl (j-1)) and sel<>0 then
                for k:=1 to list[0] do
                  if (1 shl (k-1)) and sel<>0 then
                    if not pos[list[j],list[k]] then begin
                      ok:=false;
                      break;
                    end;
            end;
            if ok then begin
              best:=sel;
              bestc:=bitCount(best);
            end;
          end;
          if bestc<>0 then
            for j:=1 to list[0] do
              if (1 shl (j-1)) and best<>0 then
                used[list[j]]:=true;
        end;
      end;
    end;
    writeln('Case #',test,': ',result);
  end;
end.

