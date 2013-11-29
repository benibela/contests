program crne;
uses sysutils;
var n,h,v,m:longint;
    
begin
  readln(n);
  m:=1;
  for h:=1 to n do begin
    v:=n-h;
    if (h+1)*(v+1)>m then
      m:=(h+1)*(v+1);
  end;
  writeln(m);
end.