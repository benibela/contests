program bijele;
uses sysutils;
const need: array[1..6] of longint = (1,1,2,2,2,8);
var i,j:longint;
    s:string;
begin
  s:='';
  for i:=1 to 6 do begin
    read(j);
    s:=s+inttostr(need[i]-j);
    if i<>6 then s:=s+' ';
  end;
  writeln(s);
end.