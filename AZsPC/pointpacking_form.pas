unit pointpacking_form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls,bbutils,math,bbutilsgeometry,LCLIntf,windows;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button10: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    btnchoosebest: TButton;
    Button5: TButton;
    Button6: TButton;
    btnextend2: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    drawcheck: TCheckBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    pointlengthlabel: TLabel;
    radlabel: TLabel;
    sizelabel: TLabel;
    Memo1: TMemo;
    PaintBox1: TPaintBox;
    Panel1: TPanel;
    procedure Button10Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure btnchoosebestClick(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure btnextend2Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1Paint(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    procedure callCheckPoint(version: longint);
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
  pointlengthlabel.Caption:=IntToStr(length(points));
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

procedure TForm1.PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  paintbox1.hint:=IntToStr((x+displayDistance div 2) div displayDistance) +':'+IntToStr((y+displayDistance div 2) div displayDistance);
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  i: Integer;
begin
  memo1.lines.text:=pointArrayToString(points);
end;

type TMoveInCircleData=record
//public
  x,y: longint;
//private
  d,l,rl: longint;
end;

procedure moveInCircle(var data: TMoveInCircleData);
const bdx:array[0..3] of longint=(0,1,0,-1);
const bdy:array[0..3] of longint=(-1,0,1,0);
begin
  with data do begin
    if l=0 then begin
      l:=1;
      d:=0;
      rl:=3;
    end;
    rl-=1;
    if rl=l then begin
      d+=1;
      if d>3 then d:=0;
    end else if rl=0 then begin
      d+=1;
      if d>3 then d:=0;
      l+=1;
      rl:=l*2;
    end;
    x+=bdx[d];
    y+=bdy[d];
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var a,temp: TPointArray;
    x,y:longint;
    j: Integer;
    i: Integer;
    usedlengths, newlengths:TIntSet;
    k: Integer;
    ok: Boolean;
    circel: TMoveInCircleData;
begin
  FillChar(circel,sizeof(circel),0);
  a:=points;
  circel.x:=(cx+displayDistance div 2) div displayDistance;
  circel.y:=(cy+displayDistance div 2) div displayDistance;
  a:=points;
  usedlengths:=TIntSet.create();
  usedlengths.insert(0);
  for i:=0 to high(a) do
    for j:=0 to i-1 do
      usedlengths.insert(sqr(a[i].x-a[j].x)+sqr(a[i].y-a[j].y));
  newlengths:=TIntSet.create();
  while length(a)<26 do begin
    moveInCircle(circel);

    ok:=true;
    x:=circel.x;
    y:=circel.y;
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

procedure TForm1.Button10Click(Sender: TObject);
var sl:tstringlist;
  p: LongInt;
  i: Integer;
  s: String;
begin
  sl:=TStringList.create;
  sl.assign(memo1.Lines);
  memo1.Lines.Clear;
  for i:=0 to sl.count- 1do begin
    p:=pos('(',sl[i]);
    if p<=0 then continue;
    s:=copy(sl[i],p+1,length(sl[i]));
    if s='' then continue;
    points:=pointArrayFromString(s);
    pointsChanged;
    Application.ProcessMessages;
    btnextend2.Click;
    btnchoosebest.Click

  end;
end;

(*
var bestPoints: array of TPoint;
    realBestPoints: array of TPoint;
    pointN,bestDSqr: longint;
    bestRSqr: float;
    curUsedLengths: array of longint;
    newlengths:array of array of longint;
    areaSize,calls: longint;

procedure checkPoints(deep:longint);
var x,y,i:longint;
    ok:longint;
    l,minx,maxx:longint;
    cx,cy,crsqrt: float;
    mylengths:array of longint;
    j: Integer;
begin
  calls+=1;
  if deep=pointN then begin
    crsqrt:=-1;
    smallestCircel(cx,cy,crsqrt,bestPoints);
    if crsqrt<bestRSqr then begin
      bestRSqr:=crsqrt;
      bestDSqr:=trunc(4*bestRSqr);
      move(bestPoints[0],realBestPoints[0],SizeOf(bestPoints[0])*length(bestPoints));
    end;     {
    SetLength(form1.points,pointN);
    move(realBestPoints[0],form1.points[0],sizeof(form1.points[0])*length(form1.points));
    for i:=0 to  high(form1.points) do begin
      form1.points[i].x+=7;
      form1.points[i].y+=7;
    end;
    form1.pointsChanged;
    Application.ProcessMessages;
    sleep(500);         }
    exit;
  end;
  if bestRSqr<Infinity then exit;
  mylengths:=newlengths[deep];
  minx:=0;
  maxx:=areaSize;
  for y:=bestPoints[deep-1].y to areaSize do begin
    if y=bestPoints[deep-1].y then bestPoints[deep].x:=bestPoints[deep-1].x+1
    else bestPoints[deep].x:=minx;
    bestPoints[deep].y:=y;
    for x:=bestPoints[deep].x to maxx do begin
      ok:=-1;
      for i:=0 to deep-1 do begin
        l:=sqr(x-bestPoints[i].x)+sqr(y-bestPoints[i].y);
        if (l > bestDSqr)  then begin
          ok:=i;
          break;
        end;
        if curUsedLengths[l]<>0 then begin
          ok:=-2;
          break;
        end;
        mylengths[i]:=l;
      end;
      if ok<>-1 then begin
        if (ok=-2) then continue;
        {if bestRSqr<Infinity then begin
          if (deep and 3 = 0) or (calls and 1023 = 0) then begin
            //ShowMessage(IntToStr(PCardinal(bestPoints)[-1]));
            PCardinal(bestPoints)[-1]:=deep-1;
            crsqrt:=-1;
            smallestCircel(cx,cy,crsqrt,bestPoints);
            PCardinal(bestPoints)[-1]:=pointN-1;
            if crsqrt>=bestRSqr then exit;

          end;
        end;      }
        //assert:bestPoints[ok].y<=y
        if bestPoints[ok].x<x then begin
          maxx:=x-1;
          //bestPoints[ok].x- (x-bestPoints[ok].x)
          if 2*bestPoints[ok].x- x+1>minx then minx:=2*bestPoints[ok].x- x+1;
          break;
        end else if bestPoints[ok].x>x then begin
          minx:=x+1;
          //bestPoints[ok].x + (bestPoints[ok].x-x)
          if 2*bestPoints[ok].x- x-1<maxx then maxx:=2*bestPoints[ok].x- x+1;
          continue;
        end else exit;
      end;
      if ok<>-1 then continue;
      for i:=0 to deep-1 do
        for j:=0 to i-1 do
          if mylengths[i] = mylengths[j] then begin
            ok:=0;
            break;
          end;
      if ok<>-1 then continue;
      bestPoints[deep].x:=x;
      for i:=0 to deep-1 do
        curUsedLengths[mylengths[i]]:=1;
      checkPoints(deep+1);
      for i:=0 to deep-1 do
        curUsedLengths[mylengths[i]]:=0;
    end;
  end;
end;
  *)
var bestPoints: array of TPoint;
    realBestPoints: array of TPoint;
    pointN,bestDSqr: longint;
    bestRSqr: float;
    curUsedLengths: array of longint;
    newlengths:array of array of longint;
    usedPoints: array of array of longint;
    firstUsablePoint: array of longint;
    blockedPoints: array of array of record
      x,y,n:longint;
    end;
    avaiblePoints:longint;
    avaiblePointsCheck: longint;
    areaSize,calls: longint;
    maxtreewidth:longint;

procedure checkPoints(deep:longint);
var x,y,i,x2,ox2,y2,blocked:longint;
    ok:longint;
    l:longint;
    cx,cy,crsqrt: float;
    mylengths:array of longint;
    j: Integer;
    maxc: integer;
  //  oldAvaiblePoints:longint;
begin
  calls+=1;
  if deep=pointN then begin
    crsqrt:=-1;
    smallestCircel(cx,cy,crsqrt,bestPoints);
    if crsqrt<bestRSqr then begin
      bestRSqr:=crsqrt;
      bestDSqr:=trunc(4*bestRSqr);
      move(bestPoints[0],realBestPoints[0],SizeOf(bestPoints[0])*length(bestPoints));
    SetLength(form1.points,pointN);
    move(realBestPoints[0],form1.points[0],sizeof(form1.points[0])*length(form1.points));
    for i:=0 to  high(form1.points) do begin
      form1.points[i].x+=5;
      form1.points[i].y+=5;
    end;
    form1.pointsChanged;
    OutputDebugString(pchar(Form1.sizelabel.Caption+ '  '+pointArrayToString(bestPoints)));
    Application.ProcessMessages;
    sleep(500);
    Application.ProcessMessages;
    end;
    exit;
  end;
                                               {
  s:='';
  for i:=0 to areaSize do
    s+=IntToStr(firstUsablePoint[i])+' ';
  s+=':';
  for i:=0 to deep-1 do
    s+=' ('+IntToStr(bestPoints[i].x)+','+IntToStr(bestPoints[i].y)+'), ';
  form1.Memo1.lines.add(inttostr(deep)+' '+s);}
//  if bestRSqr<Infinity then exit;
  mylengths:=newlengths[deep];
  if avaiblePointsCheck = 2 then begin
    if avaiblePoints<sqr(pointN - deep) div 2 then exit;
    maxc:=maxtreewidth shr (deep-1);
    //if maxc>50 then maxc:=50;
    if (maxc<=0) then maxc:=1;
  end else
    if avaiblePoints<pointN - deep then exit;
  for y:=bestPoints[deep-1].y to areaSize do begin
    bestPoints[deep].y:=y;
    x:=firstUsablePoint[y];
    if y=bestPoints[deep-1].y then begin
      bestPoints[deep].x:=bestPoints[deep-1].x+1;
      while (x < bestPoints[deep].x) and (x <= areaSize) do x:=usedPoints[y,x];
    end;
    while (x <= areaSize) do begin
      ok:=-1;
      for i:=0 to deep-1 do begin
        l:=sqr(x-bestPoints[i].x)+sqr(y-bestPoints[i].y);
        if (l > bestDSqr)  then begin
          ok:=i;
          break;
        end;
        mylengths[i]:=l;
      end;
      if ok<>-1 then begin
        x:=usedPoints[y,x];
        continue;
      end;
      for i:=0 to deep-1 do
        for j:=0 to i-1 do
          if mylengths[i] = mylengths[j] then begin
            ok:=0;
            break;
          end;
      if ok<>-1 then begin
        x:=usedPoints[y,x];
        continue;
      end;
      blocked:=0;
      bestPoints[deep].x:=x;
      for i:=0 to deep-1 do
        curUsedLengths[mylengths[i]]:=1;
      avaiblePoints:=0;
      for y2:=y to areaSize do begin
        x2:=firstUsablePoint[y2];
        ox2:=-1;
        if y2=y then
          while (x2 < x+1) and (x2 <= areaSize) do begin
            ox2:=x2;
            x2:=usedPoints[y2,x2];
          end;
        if x2<=areaSize then avaiblePoints+=1;
        while x2<=areaSize do begin
          ok:=-1;
          for i:=0 to deep do begin
            if curUsedLengths[sqr(bestPoints[i].x-x2)+sqr(bestPoints[i].y-y2)]<>0 then begin
              if blocked>=length(blockedPoints[deep]) then
                setlength(blockedPoints[deep],length(blockedPoints[deep])*2);
              blockedPoints[deep][blocked].x:=ox2;
              blockedPoints[deep][blocked].y:=y2;
              if ox2>=0 then begin
                //Form1.Memo1.Lines.add('  block: '+IntToStr(ox2)+' '+IntToStr(y2) + ': '+IntToStr(usedPoints[y2,ox2])+'->'+inttostr(usedPoints[y2,x2]));
                blockedPoints[deep][blocked].n:=usedPoints[y2,ox2];
                usedPoints[y2,ox2]:=usedPoints[y2,x2]
              end else begin
                //Form1.Memo1.Lines.add('  block: f '+IntToStr(y2) + ': '+IntToStr(firstUsablePoint[y2])+'->'+inttostr(usedPoints[y2,x2]));
                blockedPoints[deep][blocked].n:=firstUsablePoint[y2];
                firstUsablePoint[y2]:=usedPoints[y2,x2];
              end;
              blocked+=1;
              ok:=0;
              break;
            end;
          end;
          if ok=-1 then begin
            avaiblePoints+=1;
            ox2:=x2;
          end;
          x2:=usedPoints[y2,x2];
        end;
      end;
      checkPoints(deep+1);
      for i:=0 to deep-1 do
        curUsedLengths[mylengths[i]]:=0;
      for i:=blocked-1 downto 0 do begin
        if blockedPoints[deep,i].x>=0 then begin
          //Form1.Memo1.Lines.add('  unblock: '+IntToStr(blockedPoints[deep,i].x)+' '+IntToStr(blockedPoints[deep,i].y) + ': '+IntToStr(usedPoints[blockedPoints[deep,i].y,blockedPoints[deep,i].x])+'<-'+inttostr(blockedPoints[deep,i].n));
          usedPoints[blockedPoints[deep,i].y,blockedPoints[deep,i].x]:=blockedPoints[deep,i].n
        end else begin
          //Form1.Memo1.Lines.add('  unblock: f '+IntToStr(blockedPoints[deep,i].y) + ': '+IntToStr(firstUsablePoint[blockedPoints[deep,i].y])+'<-'+inttostr(blockedPoints[deep,i].n));
          firstUsablePoint[blockedPoints[deep,i].y]:=blockedPoints[deep,i].n;
        end;
      end;
      x:=usedPoints[y,x];
      maxc-=1;
      if (maxc<=0) then exit;
    end;
  end;
end;

var globalPositions: array of record
      x,y,n: longint;
    end;

procedure checkPoints2(deep,startPos:longint);
var p,p2,op2,x,y,i,x2,y2,blocked:longint;
    ok:boolean;
    l:longint;
    cx,cy,crsqrt: float;
    mylengths:array of longint;
    j: Integer;
  //  oldAvaiblePoints:longint;
begin
  calls+=1;
  if deep=pointN then begin
    crsqrt:=-1;
    smallestCircel(cx,cy,crsqrt,bestPoints);
    if crsqrt<bestRSqr then begin
      bestRSqr:=crsqrt;
      bestDSqr:=trunc(4*bestRSqr);
      move(bestPoints[0],realBestPoints[0],SizeOf(bestPoints[0])*length(bestPoints));
      SetLength(form1.points,pointN);
      move(realBestPoints[0],form1.points[0],sizeof(form1.points[0])*length(form1.points));
      for i:=0 to  high(form1.points) do begin
        form1.points[i].x+=5;
        form1.points[i].y+=5;
      end;
      form1.pointsChanged;
      OutputDebugString(pchar(Form1.sizelabel.Caption+ '  '+pointArrayToString(bestPoints)));
      Application.ProcessMessages;
      sleep(500);
      Application.ProcessMessages;
    end;
    exit;
  end;
                                               {
  s:='';
  for i:=0 to areaSize do
    s+=IntToStr(firstUsablePoint[i])+' ';
  s+=':';
  for i:=0 to deep-1 do
    s+=' ('+IntToStr(bestPoints[i].x)+','+IntToStr(bestPoints[i].y)+'), ';
  form1.Memo1.lines.add(inttostr(deep)+' '+s);}
//  if bestRSqr<Infinity then exit;
  mylengths:=newlengths[deep];
  if avaiblePoints<pointN - deep then exit;
  p:=startPos;
  while p<=high(globalPositions) do begin
    x:=globalPositions[p].x;
    if (deep=1) and (x<bestPoints[0].x) then begin
      p:=globalPositions[p].n;
      continue;
    end;
    y:=globalPositions[p].y;

    ok:=true;
    for i:=0 to deep-1 do begin
      l:=sqr(x-bestPoints[i].x)+sqr(y-bestPoints[i].y);
      if (l > bestDSqr)  then begin
        ok:=false;
        break;
      end;
      mylengths[i]:=l;
    end;
    if not ok then begin
      p:=globalPositions[p].n;
      continue;
    end;
    for i:=0 to deep-1 do
      for j:=0 to i-1 do
        if mylengths[i] = mylengths[j] then begin
          ok:=false;
          break;
        end;
    if not ok then begin
      p:=globalPositions[p].n;
      continue;
    end;
    blocked:=0;
    bestPoints[deep].y:=y;
    bestPoints[deep].x:=x;
    for i:=0 to deep-1 do
      curUsedLengths[mylengths[i]]:=1;
    avaiblePoints:=1;
    op2:=p;
    p2:=globalPositions[p].n;
    while p2 <= high(globalPositions) do begin
      ok:=true;
      x2:=globalPositions[p2].x;
      y2:=globalPositions[p2].y;
      for i:=0 to deep do begin
        if curUsedLengths[sqr(bestPoints[i].x-x2)+sqr(bestPoints[i].y-y2)]<>0 then begin
          if blocked>=length(blockedPoints[deep]) then
            setlength(blockedPoints[deep],length(blockedPoints[deep])*2);
          blockedPoints[deep][blocked].x:=op2;
          blockedPoints[deep][blocked].n:=globalPositions[op2].n;
          globalPositions[op2].n:=globalPositions[p2].n;
          blocked+=1;
          ok:=false;
          break;
        end;
      end;
      if ok then begin
        avaiblePoints+=1;
        op2:=p2;
      end;
      p2:=globalPositions[p2].n;
    end;
    checkPoints2(deep+1,globalPositions[p].n);
    for i:=0 to deep-1 do
      curUsedLengths[mylengths[i]]:=0;
    for i:=blocked-1 downto 0 do
      globalPositions[blockedPoints[deep][i].x].n:=blockedPoints[deep][i].n;

    p:=globalPositions[p].n;
  end;
end;


{


P * m * (m^2 + m + m) + FP * m * REK

treeset: P * m * (log m^2 + log m + log m) + FP * m * REK
hashset: P * m + FP * m * REK
         = s^2 * m + (s^2-s*m^2) * m * REK
         = s^2 * m + s*(s-m^2) * m * REK

sieb: FP  +  FP * s * m^2 * REK
      = s*(s-m^2) ( 1 + s*m^2)}
procedure TForm1.callCheckPoint(version: longint);
var
  i: Integer;
  time:Cardinal;
  j: Integer;
  circel:TMoveInCircleData;
  k: LongInt;
  splitted: TStringArray;
begin
  SetLength(realBestPoints,StrToInt(edit1.text));
  SetLength(bestPoints,StrToInt(edit1.text));
  pointN:=length(bestPoints);
  setlength(newlengths,pointN,pointN);
  areaSize:=StrToInt(edit2.text);
  SetLength(curUsedLengths, 2*(areaSize+2)*(areaSize+2));
  FillChar(curUsedLengths[0],sizeof(curUsedLengths)*length(curUsedLengths),0);
  SetLength(blockedPoints,pointN,areaSize);
  SetLength(firstUsablePoint,areaSize+1);
  FillChar(firstUsablePoint[0],length(firstUsablePoint)*sizeof(firstUsablePoint[0]),0);
  bestRSqr:=Infinity;
  bestDSqr:=areaSize*areaSize*10;

  calls:=0;
  time:=GetTickCount;
  if (version=0) or (version=1) then begin
    SetLength(usedPoints,areaSize+1,areaSize+1);
    for i:=0 to high(usedPoints) do
      for j:=0 to high(usedPoints[i]) do
        usedPoints[i,j]:=j+1;
    if pos(',', edit4.text)>0 then begin
      strSplit(splitted, edit4.text,',');
      for i:=0 to high(splitted) do begin
        bestPoints[i].x:=StrToInt(trim(splitted[i]));
        bestPoints[i].y:=0;
      end;
      for i:=0 to high(splitted) do
        for j:=0 to high(splitted) do
          curUsedLengths[sqr(bestPoints[i].x-bestPoints[j].x)]:=1;
      j:=length(splitted);
      usedPoints[0,0]:=bestPoints[j-1].x+1;
    end else begin
      bestPoints[0].x:=StrToInt(edit4.text);
      bestPoints[0].y:=0;
      usedPoints[0,0]:=bestPoints[0].x+1;
      j:=1;
    end;

    avaiblePoints:=length(usedPoints)*Length(usedPoints)-1;
    avaiblePointsCheck:=1;
    if version=0 then begin
      avaiblePointsCheck:=2;
      maxtreewidth:=strtoint(edit5.text);
    end;
    checkPoints(j);
  end else if version=2 then begin
    SetLength(globalPositions,(areaSize+1)*(areaSize+1));
    fillchar(circel,sizeof(circel),0);
    circel.x:=areaSize div 2+1;
    circel.y:=areaSize div 2+1;
    bestPoints[0].x:=circel.x;
    bestPoints[0].y:=circel.y;
    globalPositions[0].x:=circel.x;
    globalPositions[0].y:=circel.x;
    globalPositions[0].n:=1;
    for i:=1 to high(globalPositions) do begin
      moveInCircle(circel);
      globalPositions[i].x:=circel.x;
      globalPositions[i].y:=circel.y;
      globalPositions[i].n:=i+1;
    end;
    avaiblePoints:=length(globalPositions)-1;
    checkPoints2(1,1);

    for i:=1 to areaSize div 2 do begin
      bestPoints[0].x:=0;
      bestPoints[0].y:=0;
      k:=-1;
      for j:=1 to high(globalPositions) do
        if (globalPositions[j].x=i) and (globalPositions[j].y=i) then begin
          globalPositions[j-1].n:=j+1;
          k:=j;
        end;
      if k=-1 then continue;
      checkPoints2(1,0);
      globalPositions[k-1].n:=k;
    end;
  end else if version=3 then begin
    SetLength(globalPositions,(areaSize+1)*(areaSize+1));
    fillchar(circel,sizeof(circel),0);
    circel.x:=areaSize div 2+1;
    circel.y:=areaSize div 2+1;
    globalPositions[high(globalPositions)].x:=circel.x;
    globalPositions[high(globalPositions)].y:=circel.x;
    globalPositions[0].n:=1;
    for i:=1 to high(globalPositions) do begin
      moveInCircle(circel);
      globalPositions[high(globalPositions)- i].x:=circel.x;
      globalPositions[high(globalPositions)-i].y:=circel.y;
      globalPositions[i].n:=i+1;
    end;
    avaiblePoints:=length(globalPositions);
    checkPoints2(0,1);
  end;
//    FillDWord(usedPoints[i,0],sizeof(usedPoints[0,0])*length(usedPoints[i]),1);
  //bestPoints[1].y:=0;

  label3.Caption:='time: '+IntToStr(GetTickCount-time)+ ' calls: '+IntToStr(calls);
  {for i:=1 to areaSize do begin
    //bestPoints[1].y:=i;
    curUsedLengths.insert(i);
    checkPoints(2);
  end;}


  if bestRSqr< Infinity then begin
    SetLength(points,pointN);
    move(realBestPoints[0],points[0],sizeof(points[0])*length(points));
    for i:=0 to  high(points) do begin
      points[i].x+=5;
      points[i].y+=5;
    end;
    pointsChanged;
  end;

end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  callCheckPoint(StrToInt(edit3.text));
end;


procedure optimize2;
var minx, miny, maxx, maxy: longint;
    tx,ty,tc,bestc: float;
    newpos: tpointarray;
    intset:TIntSet;
    i: Integer;
    ok: Boolean;
    j: Integer;
    x: Integer;
    y: Integer;
begin
  if length(bestPoints)>26 then exit;
  bestc:=9999999;
  minx:=9999999;miny:=999999999;
  maxx:=-9999999;maxy:=-99999999;
  for i:=0 to high(bestPoints) do begin
    if bestPoints[i].x<minx then minx:=bestPoints[i].x;
    if bestPoints[i].y<miny then miny:=bestPoints[i].y;
    if bestPoints[i].x>maxx then maxx:=bestPoints[i].x;
    if bestPoints[i].y>maxy then maxy:=bestPoints[i].y;
  end;
  tc:=0;
  intset:=TIntSet.Create;
  for i:=0 to high(bestPoints) do
    for j:=0 to high(bestPoints) do
      intset.insert(sqr(bestPoints[i].x-bestPoints[j].x)+sqr(bestPoints[i].y-bestPoints[j].y));
  setlength(bestPoints,length(bestPoints)+1);
  for x:=minx-20 to maxx+20 do
    for y:=miny-20 to maxy+20 do begin
      ok:=true;
      for i:=0 to high(bestPoints)-1 do
        if intset.contains(sqr(bestPoints[i].x-x)+sqr(bestPoints[i].y-y)) then begin
          ok:=false;
          break;
        end;
      if not ok then continue;
      for i:=0 to high(bestPoints)-1 do
        for j:=0 to high(bestPoints)-1 do
          if (i<>j) and (sqr(bestPoints[i].x-x)+sqr(bestPoints[i].y-y)=sqr(bestPoints[j].x-x)+sqr(bestPoints[j].y-y)) then begin
            ok:=false;
            break;
          end;
      if not ok then continue;
      bestPoints[high(bestPoints)].x:=x;
      bestPoints[high(bestPoints)].y:=y;
      smallestCircel(tx,ty,tc,bestPoints);
      if abs(bestc-tc)<0.1 then begin
        SetLength(newpos,length(newpos)+1);
        newpos[high(newpos)].x:=x;
        newpos[high(newpos)].y:=y;
      end else if tc<bestc then begin
        setlength(newpos,1);
        bestc:=tc;
        newpos[high(newpos)].x:=x;
        newpos[high(newpos)].y:=y;
      end;
    end;
  for i:=0 to high(newpos) do begin
    bestPoints[high(bestPoints)]:=newpos[i];
    form1.addToMemo(bestPoints);
    optimize2;
  end;
  setlength(bestPoints,length(bestPoints)-1);

  intset.free;
end;

const op3s:longint=30;
procedure optimize3;
var //minx, miny, maxx, maxy: longint;
    intset:TIntSet;
function posplaces:longint;
var
  x: Integer;
  y: Integer;
  ok: Boolean;
  i: Integer;
  j: Integer;
begin
  result:=0;
  for x:=-2*op3s to 4*op3s do
    for y:=-2*op3s to 4*op3s do begin
      ok:=true;
      for i:=0 to high(bestPoints)-1 do
        if intset.contains(sqr(bestPoints[i].x-x)+sqr(bestPoints[i].y-y)) then begin
          ok:=false;
          break;
        end;
      if not ok then continue;
      for i:=0 to high(bestPoints)-1 do
        for j:=0 to high(bestPoints)-1 do
          if (i<>j) and (sqr(bestPoints[i].x-x)+sqr(bestPoints[i].y-y)=sqr(bestPoints[j].x-x)+sqr(bestPoints[j].y-y)) then begin
            ok:=false;
            break;
          end;
      if ok then result+=1;
    end;
end;

var
    tx,ty,tc,bestc: float;
    newpos: tpointarray;
    i: Integer;
    ok: Boolean;
    j: Integer;
    x: Integer;
    y: Integer;
    bestfreep,newfreep: longint;
begin
  if length(bestPoints)>=26 then exit;
  bestc:=9999999;
 { minx:=9999999;miny:=999999999;
  maxx:=-9999999;maxy:=-99999999;
  for i:=0 to high(bestPoints) do begin
    if bestPoints[i].x<minx then minx:=bestPoints[i].x;
    if bestPoints[i].y<miny then miny:=bestPoints[i].y;
    if bestPoints[i].x>maxx then maxx:=bestPoints[i].x;
    if bestPoints[i].y>maxy then maxy:=bestPoints[i].y;
  end;            }
  tc:=0;
  intset:=TIntSet.Create;
  for i:=0 to high(bestPoints) do
    for j:=0 to high(bestPoints) do
      intset.insert(sqr(bestPoints[i].x-bestPoints[j].x)+sqr(bestPoints[i].y-bestPoints[j].y));
  setlength(bestPoints,length(bestPoints)+1);
  bestfreep:=0;
  for x:=0 to op3s do
    for y:=0 to op3s do begin
      ok:=true;
      for i:=0 to high(bestPoints)-1 do
        if intset.contains(sqr(bestPoints[i].x-x)+sqr(bestPoints[i].y-y)) then begin
          ok:=false;
          break;
        end;
      if not ok then continue;
      for i:=0 to high(bestPoints)-1 do
        for j:=0 to high(bestPoints)-1 do
          if (i<>j) and (sqr(bestPoints[i].x-x)+sqr(bestPoints[i].y-y)=sqr(bestPoints[j].x-x)+sqr(bestPoints[j].y-y)) then begin
            ok:=false;
            break;
          end;
      if not ok then continue;
      bestPoints[high(bestPoints)].x:=x;
      bestPoints[high(bestPoints)].y:=y;
      newfreep:=posplaces();
      if newfreep=bestfreep then begin
        SetLength(newpos,length(newpos)+1);
        newpos[high(newpos)].x:=x;
        newpos[high(newpos)].y:=y;
      end else if newfreep>bestfreep then begin
        setlength(newpos,1);
        newpos[high(newpos)].x:=x;
        newpos[high(newpos)].y:=y;
      end;
    end;
  for i:=0 to high(newpos) do begin
    bestPoints[high(bestPoints)]:=newpos[i];
    form1.addToMemo(bestPoints);
    optimize3;
  end;
  setlength(bestPoints,length(bestPoints)-1);

  intset.free;
end;


procedure TForm1.btnextend2Click(Sender: TObject);
begin
  bestPoints:=points;
  setlength(bestPoints,length(bestPoints));
  optimize2();
end;

procedure TForm1.Button7Click(Sender: TObject);
const fullSearch:longint =6;
var
  i: Integer;
  time:Cardinal;
  deep,x,y,use,j: Integer;
  circel:TMoveInCircleData;
  k: LongInt;
  splitted: TStringArray;
  mylengths:array of longint;
  l: longint;
  ok: LongInt;
  y2: LongInt;
  x2: LongInt;
  ox2: Integer;
  choose: Integer;
begin
  SetLength(realBestPoints,StrToInt(edit1.text));
  SetLength(bestPoints,StrToInt(edit1.text));
  pointN:=length(bestPoints);
  setlength(newlengths,pointN,pointN);
  areaSize:=StrToInt(edit2.text);
  SetLength(curUsedLengths, 2*(areaSize+2)*(areaSize+2));
  SetLength(blockedPoints,pointN,areaSize);
  SetLength(firstUsablePoint,areaSize+1);
  bestRSqr:=Infinity;
  bestDSqr:=areaSize*areaSize*10;

  calls:=0;
  time:=GetTickCount;
  SetLength(usedPoints,areaSize+1,areaSize+1);
  avaiblePoints:=length(usedPoints)*Length(usedPoints)-1;
  Randomize;
  avaiblePointsCheck:=1;
  setlength(mylengths,pointn);
  for k:=1 to StrToInt(edit5.text) do begin
    for i:=0 to high(usedPoints) do
      for j:=0 to high(usedPoints[i]) do
        usedPoints[i,j]:=j+1;
    FillChar(curUsedLengths[0],sizeof(curUsedLengths)*length(curUsedLengths),0);
    FillChar(firstUsablePoint[0],length(firstUsablePoint)*sizeof(firstUsablePoint[0]),0);
    bestPoints[0].x:=random(areaSize);
    bestPoints[0].y:=0;
    firstUsablePoint[0]:=bestPoints[0].x+1;
    for deep:=1 to pointN-fullSearch-1 do begin
      choose:=random(max(areaSize+areaSize div 2,avaiblePoints-1));//random(avaiblePoints) div (pointN - deep - fullSearch);
//      choose:=random(avaiblePoints) div (pointN - deep - fullSearch);
      for y:=bestPoints[deep-1].y to areaSize do begin
        bestPoints[deep].y:=y;
        x:=firstUsablePoint[y];
        if y=bestPoints[deep-1].y then begin
          bestPoints[deep].x:=bestPoints[deep-1].x+1;
          while (x < bestPoints[deep].x) and (x <= areaSize) do x:=usedPoints[y,x];
        end;
        while (x <= areaSize) do begin
          ok:=-1;
          for i:=0 to deep-1 do begin
            l:=sqr(x-bestPoints[i].x)+sqr(y-bestPoints[i].y);
            if (l > bestDSqr)  then begin
              ok:=i;
              break;
            end;
            mylengths[i]:=l;
          end;
          if ok<>-1 then begin
            x:=usedPoints[y,x];
            continue;
          end;
          for i:=0 to deep-1 do
            for j:=0 to i-1 do
              if mylengths[i] = mylengths[j] then begin
                ok:=0;
                break;
              end;
          if ok<>-1 then begin
            x:=usedPoints[y,x];
            continue;
          end;
          choose-=1;
          if choose>0 then begin
            x:=usedPoints[y,x];
            continue;
          end;
          //blocked:=0;
          bestPoints[deep].x:=x;
          for i:=0 to deep-1 do
            curUsedLengths[mylengths[i]]:=1;
          avaiblePoints:=0;
          for y2:=y to areaSize do begin
            x2:=firstUsablePoint[y2];
            ox2:=-1;
            if y2=y then
              while (x2 < x+1) and (x2 <= areaSize) do begin
                ox2:=x2;
                x2:=usedPoints[y2,x2];
              end;
            if x2<=areaSize then avaiblePoints+=1;
            while x2<=areaSize do begin
              ok:=-1;
              for i:=0 to deep do begin
                if curUsedLengths[sqr(bestPoints[i].x-x2)+sqr(bestPoints[i].y-y2)]<>0 then begin
                  {if blocked>=length(blockedPoints[deep]) then
                    setlength(blockedPoints[deep],length(blockedPoints[deep])*2);
                  blockedPoints[deep][blocked].x:=ox2;
                  blockedPoints[deep][blocked].y:=y2;}
                  if ox2>=0 then begin
                    //Form1.Memo1.Lines.add('  block: '+IntToStr(ox2)+' '+IntToStr(y2) + ': '+IntToStr(usedPoints[y2,ox2])+'->'+inttostr(usedPoints[y2,x2]));
//                    blockedPoints[deep][blocked].n:=usedPoints[y2,ox2];
                    usedPoints[y2,ox2]:=usedPoints[y2,x2]
                  end else begin
                    //Form1.Memo1.Lines.add('  block: f '+IntToStr(y2) + ': '+IntToStr(firstUsablePoint[y2])+'->'+inttostr(usedPoints[y2,x2]));
  //                  blockedPoints[deep][blocked].n:=firstUsablePoint[y2];
                    firstUsablePoint[y2]:=usedPoints[y2,x2];
                  end;
    //              blocked+=1;}
                  ok:=0;
                  break;
                end;
              end;
              if ok=-1 then begin
                avaiblePoints+=1;
                ox2:=x2;
              end;
              x2:=usedPoints[y2,x2];
            end;
          end;
          break;
          x:=usedPoints[y,x];
        end;
        if choose<=0 then
          break;
      end;
      if choose>0 then begin
        break
      end;
    end;
    if choose>0 then
      continue;
    checkPoints(pointN - fullSearch);
  end;
//    FillDWord(usedPoints[i,0],sizeof(usedPoints[0,0])*length(usedPoints[i]),1);
  //bestPoints[1].y:=0;

  label3.Caption:='time: '+IntToStr(GetTickCount-time)+ ' calls: '+IntToStr(calls);
  {for i:=1 to areaSize do begin
    //bestPoints[1].y:=i;
    curUsedLengths.insert(i);
    checkPoints(2);
  end;}


  if bestRSqr< Infinity then begin
    SetLength(points,pointN);
    move(realBestPoints[0],points[0],sizeof(points[0])*length(points));
    for i:=0 to  high(points) do begin
      points[i].x+=5;
      points[i].y+=5;
    end;
    pointsChanged;
  end;


end;

var circel:TMoveInCircleData;
procedure TForm1.Button8Click(Sender: TObject);
begin
  moveInCircle(circel);
  PaintBox1.Canvas.Pen.color:=rgb(random(192)+32, random(192)+32, random(192)+32);
  PaintBox1.Canvas.EllipseC(circel.x*displayDistance,circel.y*displayDistance,5,5);
end;

procedure TForm1.Button9Click(Sender: TObject);
begin
 memo1.lines.text:=StringReplace(StringReplace(memo1.lines.text, '\n"','',[rfReplaceAll]),'&"warning:','',[rfReplaceAll]);
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  points:=pointArrayFromString(memo1.lines.text);
  pointsChanged;
end;

procedure TForm1.btnchoosebestClick(Sender: TObject);
var temp:array of TPointArray;
    rsqrs: array of float;
    line: string;
    cur:TPointArray;
    tx,ty,currsqr:float;
    i,j,k: Integer;
begin
  setlength(temp,max(30,memo1.lines.count+10));
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

procedure TForm1.Button5Click(Sender: TObject);
begin
  bestPoints:=points;
  setlength(bestPoints,length(bestPoints));
  optimize3();
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

