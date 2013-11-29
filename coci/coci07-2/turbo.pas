program turbo;
var i,j,n,t,k:longint;
    v: array[0..200000] of longint;
    p: array[0..200000] of longint;
    
begin
  readln(n);
  for i:=1 to n do begin
    read(v[i]);
    p[v[i]]:=i;
  end;
  
  for k:=1 to n do begin
    if odd(k) then i:=k div 2 + 1
    else i:=n-k div 2+1;
    writeln(abs(p[i]-i));
    
    {writeln(i);
    for j:=1 to n do
      write('   ',v[j]);
    writeln;}
    
    for j:=p[i] to i-1 do begin
      t:=v[j];
      v[j]:=v[j+1];
      v[j+1]:=t;
      p[v[j]]:=j;
      p[v[j+1]]:=j+1;
    end;
    for j:=p[i]-1 downto i do begin
      t:=v[j];
      v[j]:=v[j+1];
      v[j+1]:=t;
      p[v[j]]:=j;
      p[v[j+1]]:=j+1;
    end;
  end;
end.