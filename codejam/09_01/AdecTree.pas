program AdecTree;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils ,math ,
  bbutils //get strSplit function from www.benibela.de
  { you can add units after this };




var testcases,l:longint;
  testcase: Integer;
  i,a,j: Integer;
  s,st,cur:string;
  dectree: array[0..100000] of record
    p:float;
    feature:string;
    has,hasnot:longint;
  end;
  dtstack: array[0..100000] of longint;
  dtc,dtsu: longint;
  splitted: TStringArray;
  p: float;
  sl:TStringList;
  posi: Integer;
begin
      sl:=TStringList.create;
  readln(testcases);
  for testcase:=1 to testcases do begin
    readln(l);
    s:='';
    for i:=1 to l do begin
      readln(st);
      s+=st+'    ';
    end;
    dtc:=0;
    dtsu:=0;
    dtstack[0]:=0;
    dectree[0].p:=1;
    dectree[0].feature:='start';
    dectree[0].has:=-1;
    dectree[0].hasnot:=-1;
    i:=1;
    while i<=length(s) do begin
      case s[i] of
        '(': begin
          dtsu+=1;
          if (dectree[dtstack[dtc]].p<0) or (dectree[dtstack[dtc]].feature='') then
            raise Exception.create('??');
          if dectree[dtstack[dtc]].has=-1 then dectree[dtstack[dtc]].has:=dtsu
          else if dectree[dtstack[dtc]].hasnot=-1 then dectree[dtstack[dtc]].hasnot:=dtsu
          else raise exception.create('wtf?');
          dtc+=1;
          dtstack[dtc]:=dtsu;
          dectree[dtsu].p:=-1;
          dectree[dtsu].feature:='';
          dectree[dtsu].hasnot:=-1;
          dectree[dtsu].has:=-1;
        end;
        ')': begin
          dtc-=1;
        end;
        ' ',#9,#13,#10: ;
        else begin
          cur:='';
          while not (s[i] in [' ',#9,#13,#10,'(',')']) do begin
            cur+=s[i];
            i+=1;
          end;
          if dectree[dtstack[dtc]].p<0 then dectree[dtstack[dtc]].p:=StrToFloat(cur)
          else if dectree[dtstack[dtc]].feature='' then dectree[dtstack[dtc]].feature:=cur
          else raise exception.create('oh no');
          i-=1;
        end;
      end;
      i+=1;
    end;


    readln(a);
    writeln('Case #',testcase,':');
    for i:=1 to a do begin
      readln(s);
      strSplit(splitted,s,' ');
      if length(splitted) <> StrToInt(splitted[1])+2 then
        raise exception.create('wrong input');
      sl.clear;
      for j:=2 to high(splitted) do sl.add(splitted[j]);
      p:=1;
      posi:=1;
      while true do begin
        p:=p*dectree[posi].p;
        if dectree[posi].feature='' then break;
        if sl.IndexOf(dectree[posi].feature)>-1 then begin
          posi:=dectree[posi].has;
        end else posi:=dectree[posi].hasnot;
      end;
      writeln(p:10:10);
    end;
  end;

end.

