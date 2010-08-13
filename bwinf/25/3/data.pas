unit data;

{$mode objfpc}{$H+}

interface

uses
  windows,Classes, SysUtils,FPimage, Graphics,math;

type

{ TMap }
T2DArray=array of array of longint;
TMap=class
  map,water: T2DArray;
  procedure setSize(x,y:longint);
  procedure loadFromImageFile256(fileName: string);
  procedure loadFromImage256(bmp: tbitmap);
  procedure displayWater256(bmp: TBitmap);

  //Löscht die mask-Bits im Wasser
  procedure smooth(mask:longint);

  //Algorithmen sind von Lilli Kaufhold, Martin Maas,
  //Ulrich Mierendorff und Benito van der Zander
  procedure completeFill;
  procedure rainFill(R: longint;prec:longint=1);
end;

type THeapElement=record
  x,y,h:longint;
end;

PHeapElement=^THeapElement;
{ TMapHeap }

TMapHeap=class
private
  heap:array of THeapElement;
  len:cardinal;
  inheap: array of array of boolean;
  procedure movedown(p:cardinal);
public
  invertedPriority,removeNever,allowMultiples:boolean;
  procedure push(x,y,h:longint);
  procedure pop;
  function get: PHeapElement;
  constructor create(w,h:longint);
end;

implementation

{ TMap }

procedure TMap.setSize(x, y: longint);
begin
  SetLength(map,x,y);
  SetLength(water,x,y);
end;

procedure TMap.loadFromImageFile256(fileName: string);
var bmp:TBitmap;
begin
  bmp:=TBitmap.Create;
  bmp.LoadFromFile(fileName);
  loadFromImage256(bmp);
  bmp.free;
end;

procedure TMap.loadFromImage256(bmp: tbitmap);
var x,y:longint;
begin
  SetLength(map,bmp.Width,bmp.Height);
  SetLength(water,bmp.Width,bmp.Height);
  bmp.Canvas.LockCanvas;
  try
    for x:=0 to high(map) do
      for y:=0 to high(map[x]) do begin
        map[x,y]:=bmp.Canvas.Colors[x,y].green;
        water[x,y]:=0;
      end;
  finally
    bmp.Canvas.UnlockCanvas;
  end;
end;

procedure TMap.displayWater256(bmp: TBitmap);
var x,y:longint;
    fpcol: TFPColor;
begin
  if length(water)=0 then exit;
  bmp.Width:=length(water);
  bmp.height:=Length(water[0]);
  bmp.Canvas.LockCanvas;
  try
    for x:=0 to high(map) do
      for y:=0 to high(map[x]) do begin
        fpcol:=bmp.Canvas.Colors[x,y];
        fpcol.blue:=word(water[x,y]);
        bmp.Canvas.Colors[x,y]:=fpcol;
      end;
  finally
    bmp.Canvas.UnlockCanvas;
  end;
end;

procedure TMap.smooth(mask: longint);
var x,y,notmask:longint;
    canIncrease:boolean;
begin
  if mask=0 then exit;
  notmask:=not mask;
  for x:=0 to high(water) do
    for y:=0 to high(water[x]) do begin
      if water[x,y]<$10000 then begin
      {if water[x,y] and mask>=mask shr 1 then water[x,y]:=water[x,y]+mask;
      water[x,y]:=water[x,y] and notmask;}
        canIncrease:=water[x,y] and $FF >= $FF div 2;
        water[x,y]:=water[x,y] and not $FF;
        water[x,y]:=water[x,y] or (water[x,y] shr 8);
        if canIncrease then
          if water[x,y]<>map[x,y] then water[x,y]+=$101;
      end else if water[x,y]<$100FF then
        water[x,y]:=$FFFF;
      
    end;

end;

procedure TMap.completeFill;
var i,x,y:longint;
    heap:TMapHeap;
begin
  heap:=TMapHeap.Create(length(map),length(map[0]));
  heap.invertedPriority:=true;
  heap.removeNever:=true;
  
  for i:=0 to high(map) do begin
    heap.push(i,0,map[i,0]);
    heap.push(i,high(map[0]),map[i,high(map[0])]);
  end;
  for i:=0 to high(map[0]) do begin
    heap.push(0,i,map[0,i]);
    heap.push(high(map[0]),i,map[high(map[0]),i]);
  end;
  
  while heap.len>0 do begin
    x:=heap.get^.x;
    y:=heap.get^.y;
    water[x,y]:=heap.get^.h;
    heap.pop();
    if x>0 then
      heap.push(x-1,y,max(map[x-1,y],water[x,y]));
    if y>0 then
      heap.push(x,y-1,max(map[x,y-1],water[x,y]));
    if x<high(map) then
      heap.push(x+1,y,max(map[x+1,y],water[x,y]));
    if y<high(map[0]) then
      heap.push(x,y+1,max(map[x,y+1],water[x,y]));
  end;
  
  heap.free;
end;

procedure TMap.rainFill(R: longint;prec:longint=1);
var i,x,y,h,u,v,j,ganzweg,neighbourCount,maxtrans,gesamt,minn:longint;
    heap:TMapHeap;
    old:array[1..4] of longint;
const neighbours:array[0..4] of array[1..2] of longint=((0,0),(1,0),(-1,0),(0,1),(0,-1));
begin
  heap:=TMapHeap.Create(length(map),length(map[0]));
  heap.allowMultiples:=true;
  for x:=0 to high(map) do
    for y:=0 to high(map[x]) do begin
      heap.push(x,y,map[x,y]+r);
      water[x,y]:=map[x,y]+r;
    end;
  while heap.len>0 do begin
    x:=heap.get^.x;
    y:=heap.get^.y;
    h:=heap.get^.h;
    heap.pop;
    if abs(h-water[x,y])>prec then continue; //objekt veraltet
    h:=water[x,y];
    if water[x,y]=map[x,y] then continue; //kein Wasser mehr
    ganzweg:=0;



    //Wasser umfüllen, das komplett passt
    neighbourCount:=0;
    for i:=1 to 4 do begin
      u:=x+neighbours[i,1];
      v:=y+neighbours[i,2];
      if (u<0) or (v<0) or (u>high(map)) or (v>high(map[0])) then continue;
      old[i]:=water[u,v];

      if water[u,v]<map[x,y] then begin
        ganzweg+=map[x,y]-water[u,v];
        neighbourCount+=1;
      end;
    end;

    if ganzweg>=water[x,y]-map[x,y] then
      ganzweg:=water[x,y]-map[x,y];
    if ganzweg>0 then begin
      maxtrans:=ganzweg div neighbourCount;
      if ganzweg mod neighbourCount <>0 then
        maxtrans+=1;

      for j:=1 to 4 do begin
        minn:=0;
        for i:=2 to 4 do begin
          u:=x+neighbours[i,1];
          v:=y+neighbours[i,2];
          if (u<0) or (v<0) or (u>high(map)) or (v>high(map[0])) then continue;
          if (water[u,v]<map[x,y]) and (old[i]=water[u,v]) then
            if (minn=0) or
               (water[u,v]>water[x+neighbours[minn,1],y+neighbours[minn,2]]) then
              minn:=i;
              
        end;
        if minn=0 then break;
        u:=x+neighbours[minn,1];
        v:=y+neighbours[minn,2];
        if (u<0) or (v<0) or (u>high(map)) or (v>high(map[0])) then break;
        if water[u,v]<map[x,y] then begin
          if map[x,y]-water[u,v]<maxtrans then begin
            ganzweg-=map[x,y]-water[u,v];
            water[x,y]-=map[x,y]-water[u,v];
            water[u,v]:=map[x,y];
          end else begin
            water[u,v]+=maxtrans;
            water[x,y]-=maxtrans;
            ganzweg-=maxtrans;
          end;
          if ganzweg=0 then break;
          neighbourCount-=1;
          maxtrans:=ganzweg div neighbourCount;
          if ganzweg mod neighbourCount <>0 then
            maxtrans+=1;
        end else break;
      end;
    end;
    
    //Umgebung anpassen
    if water[x,y]>map[x,y] then begin
      gesamt:=water[x,y]-map[x,y];
      water[x,y]:=map[x,y];
      neighbourCount:=1;
      for i:=1 to 4 do begin
        u:=x+neighbours[i,1];
        v:=y+neighbours[i,2];
        if (u<0) or (v<0) or (u>high(map)) or (v>high(map[0])) then continue;
        if map[x,y]>=map[u,v] then begin
          neighbourCount+=1;
          if (water[u,v]>map[x,y])  then begin
            gesamt+=water[u,v]-map[x,y];
            water[u,v]:=map[x,y];
          end;
        end;
      end;
      
      maxtrans:=gesamt div neighbourCount;
      gesamt:=gesamt mod neighbourCount;
      for i:=4 downto 0 do begin
        u:=x+neighbours[i,1];
        v:=y+neighbours[i,2];
        if (u<0) or (v<0) or (u>high(map)) or (v>high(map[0])) then continue;
{        if maxtrans > 2*r then
          maxtrans:=r; }
        if map[x,y]>=map[u,v] then begin
          water[u,v]+=maxtrans;
          if gesamt>0 then begin
            water[u,v]+=1;
            gesamt-=1;
          end;
        end;
      end;
    end;
    
    for i:=1 to 4 do begin
      u:=x+neighbours[i,1];
      v:=y+neighbours[i,2];
      if (u<0) or (v<0) or (u>high(map)) or (v>high(map[0])) then begin
        water[x,y]:=map[x,y];
        break;
      end;
    end;
    
    for i:=1 to 4 do begin
      u:=x+neighbours[i,1];
      v:=y+neighbours[i,2];
      if (u<0) or (v<0) or (u>high(map)) or (v>high(map[0])) then continue;
      if abs(water[u,v]-old[i]) >prec then
        heap.push(u,v,water[u,v]);
    end;
  end;

  heap.free;
end;

procedure TMapHeap.movedown(p: cardinal);
var tempHeap: THeapElement;
    modifier:longint;
    c:cardinal;
begin
  if invertedPriority then modifier:=-1
  else modifier:=1;

  while 2*p<=len do begin
    c:=2*p;
    if (c+1<=len) and (heap[c+1].h*modifier>heap[c].h*modifier) then c:=c+1;
    if heap[p].h*modifier>heap[c].h*modifier then break;

    tempHeap:=heap[p];
    heap[p]:=heap[c];
    heap[c]:=tempHeap;
    p:=c;
  end;
end;

procedure TMapHeap.push(x,y,h:longint);
var p:cardinal;
    tempHeap: THeapElement;
    modifier:longint;
begin
  if (x<0) or (y<0) then exit;
  if (x>high(inheap)) or (y>high(inheap)) then exit;
  if inheap[x,y] and not allowMultiples then exit;
  len+=1;
  inheap[x,y]:=true;
  if len>=cardinal(length(heap)) then
    setlength(heap,length(heap)*2);
  heap[len].x:=x;
  heap[len].y:=y;
  heap[len].h:=h;

  if invertedPriority then modifier:=-1
  else modifier:=1;

  p:=len;
  while (p>1) and (heap[p shr 1].h*modifier<heap[p].h*modifier) do begin
    tempHeap:=heap[p];
    heap[p]:=heap[p shr 1];
    heap[p shr 1]:=tempHeap;
    p:=p shr 1;
  end;
  movedown(p);
end;

procedure TMapHeap.pop;
begin
  if len=0 then exit;
  if not removeNever then inheap[heap[1].x,heap[1].y]:=false;
  heap[1]:=heap[len];
  len-=1;
  
  movedown(1);

end;

function TMapHeap.get: PHeapElement;
begin
  result:=@heap[1];
end;

constructor TMapHeap.create(w, h: longint);
var x:longint;
begin
  len:=0;
  SetLength(heap,w*h+1);
  setlength(inheap,w,h);
  for x:=0 to high(inheap) do
    FillChar(inheap[x,0],length(inheap[x])*sizeof(inheap[x,0]),0);
end;


procedure heapTest();
var heap: TMapHeap;
  procedure check(val: array of longint);
  var i,j,k,l:longint;
      val2:array of longint;
      heapstr:string;
  begin
    RandSeed:=2;
    for i:=1 to 200 do begin
      l:=0;
      setlength(val2,length(val));
      move(val[0],val2[0],sizeof(val[0])*length(val));

      while length(val2) >0 do begin
        l+=1;
        j:=random(length(val2));
        heap.push(l,l,val2[j]);
        val2[j]:=val2[high(val2)];
        setlength(val2,length(val2)-1);
     {   heapstr:='';
        for l:=1 to heap.len do
          heapstr:=heapstr+inttostr(heap.heap[l].h)+' ';
        OutputDebugString(pchar(heapstr));               }
      end;
      if heap.len<>cardinal(length(val)) then
        raise exception.create('ungültige Länge: '+IntToStr(heap.len));
      for k:=0 to high(val) do begin
{        heapstr:='';
        for l:=1 to heap.len do
          heapstr:=heapstr+inttostr(heap.heap[l].h)+' ';
        OutputDebugString(pchar(heapstr));}
        if heap.get^.h<>val[k] then
          raise exception.Create('heap test failed: '+inttostr(heap.get^.h)+'<>'+inttostr(val[k])+' (pos: '+inttostr(i)+'/'+inttostr(k)+'): ');
        heap.pop;
      end;
      if heap.len<>0 then
        raise exception.create('ungültige Länge2: '+IntToStr(heap.len));
    end;
  end;
begin
  heap:=TMapHeap.Create(100,100);
  heap.invertedPriority:=false;
  heap.removeNever:=false;
  check([100,90,80,70,60,50,40,30,20,10]);
  check([866,436,324,244,243,123,122,87,24,12,8,4]); // }
  heap.invertedPriority:=true;
  check([10,20,30,40,50]);
  check([1,14,24,63,245,266,345,445,564,667,789,808,920,1000,2003,3123,3242,3456,4607,4700,4909,5000]);
  heap.free;
end;

initialization
  heapTest()
  
end.



    
