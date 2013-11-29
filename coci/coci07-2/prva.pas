program prva;

 {$mode delphi}
var board: array[-2..22,-2..22] of char;
    i,j,k,r,c:longint;
    ts,s:string;
    
  function getword(i,j,ip,jp:longint):string;
  begin
    result:='';
    if board[i,j]<>'#' then exit('');
    i+=ip;j+=jp;
    while board[i,j]<>'#' do begin
      result+=board[i,j];
      i+=ip;j+=jp;
    end;
  end;
begin
  fillchar(board,sizeof(board),ord('#'));
  readln(r,c);
  for i:=1 to r do begin
    readln(s);  
    for j:=1 to c do
      board[i,j]:=s[j];
  end;
  
  s:=#255#255#255#255;
  for i:=0 to 20 do 
    for j:=0 to 20 do  begin
      ts:=getword(i,j,1,0);
      if (length(ts)>=2) and (ts<s) then 
        s:=ts;
      ts:=getword(j,i,0,1);
      if (length(ts)>=2) and (ts<s) then 
        s:=ts;
    end;
    
  writeln(s);
end.