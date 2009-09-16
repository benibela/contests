program Project1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes , regex,sysutils
  { you can add units after this };

var re: TRegexEngine;
    i,j,l,t,d,n:longint;
    w:TStringList;
    s:string;
    c,o: Integer;

begin
  readln(l,d,n);
  w:=TStringList.create;
  for i:=1 to d do begin
    readln(s);
    w.add(s);
    if length(s) <> l then raise exception.create('???');
  end;
  for i:=1 to n do begin
    readln(s);
    s:=StringReplace(s,'(','[',[rfReplaceAll]);
    s:=StringReplace(s,')',']',[rfReplaceAll]);
    re:=TRegexEngine.Create(s); //that's the easiest way :-)
    c:=0;
    for j:=0 to w.count-1 do begin
      o:=0;
      if re.MatchString(w[j],t,o) then c+=1;
    end;
    writeln('Case #',i,': ',c);
    re.free;
  end;
end.

