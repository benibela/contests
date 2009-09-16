program Bnumber;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils
  { you can add units after this };

var testcases:longint;
    s:string;
    tesc: Integer;
    pfound,found: Integer;
    sortfrom: longint;
    ctemp: Char;
    i: Integer;
    j: Integer;
begin
  readln(testcases);
  for tesc:=1 to testcases do begin
    readln(s);
    found:=-1;
    for i:=length(s) downto 1 do begin
      for j:=i+1 to length(s) do
        if s[j]>s[i] then begin
          found:=i;
          break;
        end;
      if found<>-1 then break;
    end;
    if found<>-1 then begin
      pfound:=found;
      found:=-1;
      for i:=pfound+1 to length(s) do
        if (s[i]>s[pfound]) and  ((found=-1) or (s[i]<s[found])) then
          found:=i;
      if found=-1 then
        raise exception.create('fffff???');
      ctemp:=s[found];
      s[found]:=s[pfound];
      s[pfound]:=ctemp;
      sortfrom:=pfound+1;
    end else begin
      for i:=1 to length(s) do
        if (s[i]<>'0') and  ((found=-1) or (s[i]<s[found])) then
          found:=i;
      if found=-1 then
        raise exception.create('???');
      s:=s[found]+s;
      s[found+1]:='0';
      sortfrom:=2;
    end;
    for i:=sortfrom to length(s) do
      for j:=i downto sortfrom+1 do begin
        if s[j-1]>s[j] then begin
          ctemp:=s[j-1];
          s[j-1]:=s[j];
          s[j]:=ctemp;
        end else break;
      end;
    writeln('Case #',tesc,': ',s);
  end;
end.

