program pointpacking;

{$mode objfpc}{$H+}

uses    Interfaces, forms, LResources,
  Classes, SysUtils,bbutils,math, bbutilsgeometry, pointpacking_form;
  {

var a:tpointarray;
    l,i,cur,j,k,x,y,d,dx,dy:longint;
    usedlengths,newlengths:  TIntSet;
    ok: Boolean;
 }
{$IFDEF WINDOWS}{$R pointpacking.rc}{$ENDIF}

begin
  {$I pointpacking.lrs}
  Application.Initialize;
  Application.CreateForm(TForm1,Form1);
  Application.Run;
{
  setlength(a,26);
  a[1].x:=0;
  a[1].y:=0;
  cur:=1;
  usedlengths:=TIntSet.create();
  usedlengths.insert(0);
  newlengths:=TIntSet.create();
  x:=0;
  y:=0;
  l:=0;
  d:=-1;
  while cur<27 do begin
    l+=1;
    for j:=1 to 2 do begin
      d+=1;
      if d>3 then d:=0;
      dx:=bdx[d];
      dy:=bdy[d];
      for k:=1 to l do begin
        x+=dx;
        y+=dy;
        //writeln('(',x,',',y,')');

        ok:=true;
        newlengths.clear();
        for i:=1 to cur do
          if usedlengths.contains(sqr(a[i].x-x)+sqr(a[i].y-y)) then begin
            ok:=false;
            break;
          end else newlengths.insert(sqr(a[i].x-x)+sqr(a[i].y-y));
        if ok and (newlengths.count()=cur) then begin
          for i:=1 to cur do
            usedlengths.insert(sqr(a[i].x-x)+sqr(a[i].y-y));
          cur+=1;
          a[cur].x:=x;
          a[cur].y:=y;
        end;
      end;
    end;
  end;
  for i:=1 to cur do begin
    write('(',a[1].x+10000,',',a[1].y+10000,')');
    for j:=2 to i do
      write(',(',a[j].x+10000,',',a[j].y+10000,')');
    writeln(';');
  end;}
end.


