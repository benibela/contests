program kemija;

var v:array[1..10000] of longint;
    gauss: array of array of array of longint;
    n,i,j,k,l:longint;
    r: array[1..100000] of longint;
    
begin
  readln(n);
  for i:=1 to n do 
    read(v[i]);
  if n mod 3 = 0 then begin
    r[n-1]:=(v[n]+v[1]+v[n-1]) div 6-1;
    r[n]:=(v[n]+v[1]+v[n-1]) div 6;
    if r[n-1]<=0 then begin
      r[n-1]:=1;
      r[n]:=1;
    end;
    
    r[1]:=v[n]-r[n-1]-r[n];
    r[2]:=v[1]-v[n]+r[n-1];
    r[3]:=-v[1]+v[2]+r[n];
    for i:=1 to n div 3 -1 do begin
      if 1+i*3>=n-1 then break;
      r[1+3*i] := r[-2+3*i] -  v[i*3-1] + v[i*3];
    end;
    for i:=1 to n div 3 -1 do begin
      if 2+i*3>=n-1 then break;
      r[2+3*i] := r[-1+3*i] -  v[i*3] + v[i*3+1];
    end;
    for i:=1 to n div 3 -1 do begin
      if 3+i*3>=n-1 then break;
      r[3+3*i] := r[3*i] -  v[i*3+1] + v[i*3+2];
    end;
    for i:=1 to n do 
      writeln(r[i]);
  end else begin
    setlength(gauss,2,n+1,n+1);
    for i:=0 to 1 do
      for j:=0 to n do
        fillchar(gauss[i,j,0],length(gauss[i,j])*sizeof(gauss[i,j,0]),0);
        
    gauss[0,1,1]:=1;   gauss[0,1,n-1]:=1;gauss[0,1,n]:=1;
    gauss[0,2,1]:=1;gauss[0,2,2]:=1;     gauss[0,2,n]:=1;
    for i:=3 to n do begin 
      gauss[0,i,i-1]:=1;gauss[0,i,i-2]:=1;gauss[0,i,i]:=1;
    end;
      
     
    gauss[1,1,n]:=1;
    for i:=2 to n do
      gauss[1,i,i-1]:=1;
     
    
    for i:=1 to n-2 do 
      for j:=1 to 2 do begin
        if j+i>n then break;
        for k:=0 to 1 do 
          for l:=1 to n do 
             gauss[k,i+j,l]:=gauss[k,i+j,l]-gauss[k,i,l];
    
      end;
    for i:=1 to n do  begin
      for j:=1 to n do 
        write(gauss[0,i,j]:2,'  ');
      write(#9);
      for j:=1 to n do 
        write(gauss[1,i,j]:2,'  ');
      writeln;
    end;
  end;
 end.