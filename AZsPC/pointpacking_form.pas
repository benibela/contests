unit pointpacking_form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls,bbutils,bbutilsgeometry,math;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    drawcheck: TCheckBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    radlabel: TLabel;
    sizelabel: TLabel;
    Memo1: TMemo;
    PaintBox1: TPaintBox;
    Panel1: TPanel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1Paint(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    procedure pointsChanged;
    procedure addToMemo(plist:TPointArray);
    points: TPointArray;
    cx,cy,cr: integer;
    hull: tlongintarray;
  end; 

  const displayDistance:Integer=20;

var
  Form1: TForm1; 

implementation

{ TForm1 }

procedure TForm1.PaintBox1Paint(Sender: TObject);
var
  i: Integer;
  j: Integer;
  l: Integer;
  k: Integer;
begin
  paintbox1.Canvas.Pen.Width:=1;
  PaintBox1.Canvas.brush.Style:=bsSolid;
  PaintBox1.Canvas.FillRect(0,0,width,height);
  PaintBox1.Canvas.pen.Color:=clBlack;
  for i:=0 to width div displayDistance do
    PaintBox1.Canvas.Line(i*displayDistance,0,i*displayDistance,height);
  for i:=0 to height div displayDistance do
    PaintBox1.Canvas.Line(0,i*displayDistance,width,i*displayDistance);
  PaintBox1.Canvas.pen.Color:=clGreen;
  PaintBox1.Canvas.brush.Style:=bsClear;
  PaintBox1.Canvas.EllipseC(cx,cy,cr,cr);
  if length(hull)>2 then begin
    PaintBox1.Canvas.pen.Color:=clBlue;
    PaintBox1.Canvas.MoveTo(points[hull[high(hull)]].x*displayDistance,points[hull[high(hull)]].y*displayDistance);
    for i:=0 to high(hull) do
      PaintBox1.Canvas.LineTo(points[hull[i]].x*displayDistance,points[hull[i]].y*displayDistance);
  end;
  PaintBox1.Canvas.brush.Style:=bsSolid;
  PaintBox1.Canvas.pen.Color:=clRed;
  for i:=0 to high(points) do begin
    PaintBox1.Canvas.EllipseC(points[i].x*displayDistance,points[i].y*displayDistance,displayDistance div 4,displayDistance div 4);
  end;

  paintbox1.Canvas.Pen.Width:=2;
  if drawcheck.Checked then
    for i:=0 to high(points) do
      for j:=0 to i-1 do
        for k:=0 to high(points) do
          for l:=0 to k-1 do
            if ((i<>k) or (j<>l)) and ( sqr(points[i].x-points[j].x)+sqr(points[i].y-points[j].y)=
               sqr(points[k].x-points[l].x)+sqr(points[k].y-points[l].y)) then begin
                  paintbox1.canvas.Line(points[i].x*displayDistance,points[i].y*displayDistance,points[j].x*displayDistance,points[j].y*displayDistance);
                  paintbox1.canvas.Line(points[k].x*displayDistance,points[k].y*displayDistance,points[l].x*displayDistance,points[l].y*displayDistance);
               end;
end;

procedure TForm1.pointsChanged;
var
  rsqr,nx,ny: float;
begin
  rsqr:=cr;
  nx:=cx;
  ny:=cy;
  convexHull(points,hull);
  smallestCircel(nx,ny,rsqr,points);
  if not IsNan(rsqr) then begin
    cx:=round(nx*displayDistance);
    cy:=round(ny*displayDistance);
    radlabel.Caption:=FloatToStr(sqrt(rsqr));
    sizelabel.Caption:=FloatToStr(rsqr);
    cr:=round(sqrt(rsqr)*displayDistance);
  end;
  PaintBox1Paint(self);
end;

procedure TForm1.addToMemo(plist: TPointArray);
var tx,ty,tr: float;
    temp:TPointArray;
    i,minx,miny: Integer;
begin
  tr:=-1;
  smallestCircel(tx,ty,tr,plist);
  temp:=plist;
  minx:=0;
  miny:=0;
  for i:=0 to high(temp) do begin
    if temp[i].x<minx then minx:=temp[i].x;
    if temp[i].y<miny then miny:=temp[i].y;
  end;
  if (minx < 0) or (miny<0) then begin
    setlength(temp,length(temp));
    for i:=0 to high(temp) do temp[i].x-=minx;
    for i:=0 to high(temp) do temp[i].y-=miny;
  end;
  memo1.lines.add(IntToStr(length(plist))+' points '+FloatToStr(tr)+' '+pointArrayToString(temp));
end;


procedure TForm1.PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  i: Integer;
  nx,ny,rsqr:float;

begin
  x:=(x+displayDistance div 2) div displayDistance;
  y:=(y+displayDistance div 2) div displayDistance;
  if button=mbLeft then begin
    SetLength(points,length(Points)+1);
    Points[high(points)].x:=x;
    Points[high(points)].y:=y;

  end else begin
    for i:=high(points) downto 0 do
      if (points[i].x=x) and (points[i].y=y) then begin
        points[i]:=points[high(points)];
        SetLength(points,high(points));
      end;
  end;
  pointsChanged;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
end;
procedure TForm1.Button2Click(Sender: TObject);
var
  i: Integer;
begin
  memo1.lines.text:=pointArrayToString(points);
end;

procedure TForm1.Button1Click(Sender: TObject);
const bdx:array[0..3] of longint=(0,1,0,-1);
const bdy:array[0..3] of longint=(-1,0,1,0);
var a,temp: TPointArray;
    x,y:longint;
    j: Integer;
    i: Integer;
    usedlengths, newlengths:TIntSet;
    l: Integer;
    d: Integer;
    dx: LongInt;
    dy: LongInt;
    k: Integer;
    ok: Boolean;
begin
  a:=points;
  x:=(cx+displayDistance div 2) div displayDistance;
  y:=(cy+displayDistance div 2) div displayDistance;
  a:=points;
  usedlengths:=TIntSet.create();
  usedlengths.insert(0);
  for i:=0 to high(a) do
    for j:=0 to i-1 do
      usedlengths.insert(sqr(a[i].x-a[j].x)+sqr(a[i].y-a[j].y));
  newlengths:=TIntSet.create();
  l:=0;
  d:=-1;
  while length(a)<26 do begin
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
        for i:=0 to high(a) do
          if usedlengths.contains(sqr(a[i].x-x)+sqr(a[i].y-y)) then begin
            ok:=false;
            break;
          end else newlengths.insert(sqr(a[i].x-x)+sqr(a[i].y-y));
        if ok and (newlengths.count()=length(a)) then begin
          for i:=0 to high(a) do
            usedlengths.insert(sqr(a[i].x-x)+sqr(a[i].y-y));
          setlength(a,length(a)+1);
          a[high(a)].x:=x;
          a[high(a)].y:=y;
          addToMemo(a);
        end;
      end;
    end;
  end;
end;

var bestPoints: array of TPoint;
    realBestPoints: array of TPoint;
    pointN: longint;
    bestRSqr,bestDSqr: float;
    curUsedLengths: TIntSet;
    newlengths:array of TIntSet;
    areaSize: longint;

procedure checkPoints(deep:longint);
var x,y,i:longint;
    ok:boolean;
    l:longint;
    cx,cy,crsqrt: float;
    myset:TIntSet;
begin
  if deep=pointN then begin
    crsqrt:=-1;
    smallestCircel(cx,cy,crsqrt,bestPoints);
    if crsqrt<bestRSqr then begin
      bestRSqr:=crsqrt;
      bestDSqr:=4*bestRSqr;
      move(bestPoints[0],realBestPoints[0],SizeOf(bestPoints[0])*length(bestPoints));
    end;
    exit;
  end;
  myset:=newlengths[deep];
  for y:=bestPoints[deep-1].y to areaSize do begin
    if y=bestPoints[deep-1].y then bestPoints[deep].x:=bestPoints[deep-1].x+1
    else bestPoints[deep].x:=0;
    bestPoints[deep].y:=y;
    for x:=bestPoints[deep].x to areaSize do begin
      ok:=not curUsedLengths.contains(sqr(x-bestPoints[deep-1].x) + sqr(y-bestPoints[deep-1].y));
      if not ok then continue;
      myset.clear();
      myset.insert(sqr(x-bestPoints[deep-1].x) + sqr(y-bestPoints[deep-1].y));
      for i:=0 to deep-2 do begin
        l:=sqr(x-bestPoints[i].x)+sqr(y-bestPoints[i].y);
        if (l > bestDSqr) or (curUsedLengths.contains(l)) or myset.contains(l) then begin
          ok:=false;
          break;
        end;
        myset.insert(l);
      end;
      if not ok then continue;
      bestPoints[deep].x:=x;
      setInsertAll(curUsedLengths,myset);
      checkPoints(deep+1);
      setRemoveAll(curUsedLengths,myset);
    end;
  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  i: Integer;
begin
  SetLength(realBestPoints,StrToInt(edit1.text));
  SetLength(bestPoints,StrToInt(edit1.text));
  pointN:=length(bestPoints);
  setlength(newlengths,pointN);
  areaSize:=StrToInt(edit2.text);
  curUsedLengths:=TIntSet.create;
  for i:=0 to high(newlengths) do
    newlengths[i]:=TIntSet.Create;

  bestPoints[0].x:=0;
  bestPoints[0].y:=0;
  //bestPoints[1].y:=0;
  bestRSqr:=Infinity;
  bestDSqr:=Infinity;
  checkPoints(1);
  {for i:=1 to areaSize do begin
    //bestPoints[1].y:=i;
    curUsedLengths.insert(i);
    checkPoints(2);
  end;}

  curUsedLengths.Free;
  for i:=0 to high(newlengths) do
    newlengths[i].free;

  if bestRSqr< Infinity then begin
    SetLength(points,pointN);
    move(realBestPoints[0],points[0],sizeof(points[0])*length(points));
    for i:=0 to  high(points) do begin
      points[i].x+=7;
      points[i].y+=7;
    end;
    pointsChanged;
  end;

end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  points:=pointArrayFromString(memo1.lines.text);
  pointsChanged;
end;

procedure TForm1.Button5Click(Sender: TObject);
var temp:array of TPointArray;
    rsqrs: array of float;
    line: string;
    cur:TPointArray;
    tx,ty,currsqr:float;
    i,j,k: Integer;
begin
  setlength(temp,memo1.lines.count+10);
  setlength(rsqrs,length(temp));
  for i:=0 to memo1.lines.count-1 do begin
    line:=trim(memo1.lines[i]);
    j:=pos('(',line);
    if j<1 then continue;
    cur:=pointArrayFromString(copy(line,j,length(line)));
    if length(cur)=0 then continue;
    currsqr:=-1;
    smallestCircel(tx,ty,currsqr,cur);
    if (length(temp[length(cur)]) = 0)
       or (rsqrs[length(cur)]>currsqr) then begin
      temp[length(cur)]:=cur;
      rsqrs[length(cur)]:=currsqr;
    end
  end;
  memo1.Clear;
  for i:=0 to high(temp) do
    if length(temp[i]) > 0 then
      memo1.lines.add(IntToStr(i)+' points '+FloatToStr(rsqrs[i])+'  '+pointArrayToString(temp[i]));
end;

procedure TForm1.Button6Click(Sender: TObject);
var i:longint;
begin
  if memo1.lines.count=0 then exit;
  for i:=0 to memo1.lines.count-1 do
    memo1.lines[i]:=copy(memo1.lines[i],pos('(',memo1.lines[i]),length(memo1.lines[i]))+';';
  memo1.lines[memo1.lines.count-1]:=copy(memo1.lines[memo1.lines.count-1],1,length(memo1.lines[memo1.lines.count-1])-1);
end;



initialization
  {$I pointpacking_form.lrs}

end.

