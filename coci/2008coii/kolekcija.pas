program kolekcija;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils,math
  { you can add units after this };

var i,j,k,l,m,n:longint;
    s,ts,index,tindex:array[1..500000] of longint;
  procedure mergeSort(f,t:longint);
  var  a,b,d,p: longint;
  begin
    if f>=t then exit;
    d:=(f+t) div 2;
    mergeSort(f,d);
    mergeSort(d+1,t);
    move(s[f],ts[f],sizeof(s[f])*(t-f+1));
    move(index[f],tindex[f],sizeof(index[f])*(t-f+1));
    a:=f;b:=d+1;
    p:=f;
    while (a<=d) and (b<=t) do begin
      if ts[a]<ts[b] then begin
        s[p]:=ts[a];
        index[p]:=tindex[a];
        inc(a);
      end else begin
        s[p]:=ts[b];
        index[p]:=tindex[b];
        inc(b);
      end;
      inc(p);
    end;
    while a<=d do begin
      s[p]:=ts[a];
      index[p]:=tindex[a];
      inc(a);inc(p);
    end;
    while b<=t do begin
      s[p]:=ts[b];
      index[p]:=tindex[p];
      inc(b);inc(p);
    end;
  end;
const mnan=1000*1000*1000+9999;
var fl,fr,flo,fro,res,grenze:longint;
    lastr:boolean;
    prr,plr,tr:array[1..500000] of boolean;
    aint,bint: array[1..500000] of longint;
begin
  readln(n,k);
  readln(m);
  for i:=1 to m do begin
    readln(s[i]);
    index[i]:=i;
  end;


  mergeSort(1,m);

  for i:=1 to m do
    tindex[index[i]]:=i;

  fl:=mnan;
  fr:=k;
  for i:=2 to m do begin
    flo:=fl;
    fro:=fr;
    if s[i]<k then fl:=mnan
    else begin
      grenze:=s[i]-k+1;
      plr[i]:=false;
      if s[i-1]<grenze then fl:=flo+k
      else fl:=flo+s[i]-s[i-1];
      if s[i-1]+k-1<grenze then begin
        if fro+k<fl then begin
          plr[i]:=true;
          fl:=fro+k;
        end;
      end else
        if fro+s[i]-(s[i-1]+k-1)<fl then begin
          fl:=fro+s[i]-(s[i-1]+k-1);
          plr[i]:=true;
        end;
    end;
    if s[i]>n-k then fr:=mnan
    else begin
      prr[i]:=false;
      if s[i-1]<s[i] then fr:=flo+k
      else continue;
      if s[i-1]+k-1<s[i] then begin
        if fr <fro+k then begin
          fr:=fro+k;
          prr[i]:=true;
        end;
      end else
        if fro+k-(s[i-1]+k-1  -  s[i] + 1) < fr then begin
          prr[i]:=true;
          fr:=fro+k-(s[i-1]+k-1  -  s[i] + 1);
        end;
    end;
  end;
  

  if fl=mnan then res:=fr
  else if fr=mnan then res:=fl
  else if fl<fr then res:=fl
  else res:=fr;
  writeln(res);

  if fl=mnan then lastr:=true
  else if fr=mnan then lastr:=false
  else if fl<fr then lastr:=false
  else lastr:=true;

  for i:=m downto 2 do begin
    tr[i]:=lastr;
    if lastr then lastr:=prr[i]
    else lastr:=plr[i];
  end;
  tr[1]:=true;
  
  aint[1]:=s[1];
  bint[1]:=s[1]+k-1;
  for i:=2 to m do begin
    if (aint[i-1]<=s[i]) and (s[i]<=bint[i-1]) then begin
      aint[i]:=aint[i-1];
      bint[i]:=bint[i-1];
    end else if tr[i] then begin
      aint[i]:=s[i];
      bint[i]:=s[i]+k-1;
    end else begin
      aint[i]:=s[i]-k+1;
      bint[i]:=s[i];
    end;

  end;
  
  
  
  for i:=1 to m do
    WriteLn(aint[tindex[i]],' ',bint[tindex[i]])

end.

