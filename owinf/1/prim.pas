program prim;

uses
//  windows,
  sysutils;


function readNumbers(const str:string;var pos:longint):longint;
const DIGIT=['0'..'9'];
      WHITESPACE=[' ',#13,#10,#9];
var start:longint;
begin
  while (pos<=length(str))and
       not  (str[pos] in DIGIT) do inc(pos);
  start:=pos;
  while (pos<=length(str))and
       (str[pos] in DIGIT) do inc(pos);
  readNumbers:=strtoint64(copy(str,start,pos-start));
end;


var a:longint=1999000000;
    b:longint= 1999999999;

procedure readFile(n:string);
var f:TextFile;
     temp:string;
     i:longint;
begin
  Assign(f,n);
  Reset(f);
  Readln(f,temp);
  Close(f);
  i:=1;
  a:=readNumbers(temp,i);
  b:=readNumbers(temp,i);
  Writeln(a);
  Writeln(b);
end;
    
var prims:array[0..1000000] of boolean;
    highestIndex:longint; 
procedure writeFile(n:string);
var f:TextFile;
     i:longint;
begin
  Assign(f,n);
  Rewrite(f);
  for i:=0 to highestIndex do
    if prims[i] then
      Writeln(f,i+a);
  Close(f);
end;

var i,maxToCheck,index:longint;
    twoOrFour:boolean;
   // c:cardinal;
begin
  //c:=gettickcount;
  readFile('prim.in');
  if a<2 then a:=2;
  highestIndex:=b-a;
  FillChar(prims,highestIndex*sizeof(boolean),$FF);
  //          2
  if a mod 2= 0 then index:=0
  else index:=2-a mod 2;
  if a+index=2 then inc(index,2);
  while index<=highestIndex do begin
    prims[index]:=false;
    inc(index,2);
  end;
  //          3
  if a mod 3= 0 then index:=0
  else index:=3-a mod 3;
  if a+index=3 then inc(index,3);
  while index<=highestIndex do begin
    prims[index]:=false;
    inc(index,3);
  end;
  //          5
  if a mod 5= 0 then index:=0
  else index:=5-a mod 5;
  if a+index=5 then inc(index,5);
  while index<=highestIndex do begin
    prims[index]:=false;
    inc(index,5);
  end;
  //          7
  if a mod 7= 0 then index:=0
  else index:=7-a mod 7;
  if a+index=7 then inc(index,7);
  while index<=highestIndex do begin
    prims[index]:=false;
    inc(index,7);
  end;
  //          11
  if a mod 11= 0 then index:=0
  else index:=11-a mod 11;
  if a+index=11 then inc(index,11);
  while index<=highestIndex do begin
    prims[index]:=false;
    inc(index,11);
  end;
  //          13
  if a mod 13= 0 then index:=0
  else index:=13-a mod 13;
  if a+index=13 then inc(index,13);
  while index<=highestIndex do begin
    prims[index]:=false;
    inc(index,13);
  end;
  //          17
  if a mod 17= 0 then index:=0
  else index:=17-a mod 17;
  if a+index=17 then inc(index,17);
  while index<=highestIndex do begin
    prims[index]:=false;
    inc(index,17);
  end;
  //          19
  if a mod 19= 0 then index:=0
  else index:=19-a mod 19;
  if a+index=19 then inc(index,19);
  while index<=highestIndex do begin
    prims[index]:=false;
    inc(index,19);
  end;
  //          23
  if a mod 23= 0 then index:=0
  else index:=23-a mod 23;
  if a+index=23 then inc(index,23);
  while index<=highestIndex do begin
    prims[index]:=false;
    inc(index,23);
  end;
  //          29
  if a mod 29= 0 then index:=0
  else index:=29-a mod 29;
  if a+index=29 then inc(index,29);
  while index<=highestIndex do begin
    prims[index]:=false;
    inc(index,29);
  end;
  //          31
  if a mod 31= 0 then index:=0
  else index:=31-a mod 31;
  if a+index=31 then inc(index,31);
  while index<=highestIndex do begin
    prims[index]:=false;
    inc(index,31);
  end;

  i:=37;
  twoOrFour:=false;
  maxToCheck:=trunc(sqrt(b));
  while i<=maxToCheck do begin
    if not ((i mod 5=0)  or
            (i mod 7=0)  or
            (i mod 11=0) or
            (i mod 13=0) or
            (i mod 17=0) or
            (i mod 19=0) or
            (i mod 23=0) or
            (i mod 29=0) or
            (i mod 31=0)  ) then begin
      if a mod i= 0 then index:=0
      else index:=i-a mod i;
      if a+index=i then inc(index,i);
      while index<=highestIndex do begin
        prims[index]:=false;
        inc(index,i);
      end;
    end;
    if twoOrFour then inc(i,2)
    else inc(i,4);
    twoOrFour:=not twoOrFour;
  end;
  //writeln('Time priming:'+inttostr(gettickcount-c));
  
  
  //c:=gettickcount;
  writeFile('prim.out');
{  for toCheck:=a+1 to b-1 do begin
    for i:=2 to trunc(sqrt(toCheck)) do
      if toCheck mod i=0 then goto next;
    Writeln(toCheck);
    next:
  end;}
 // writeln('Time saving:'+inttostr(gettickcount-c));
  
end.
