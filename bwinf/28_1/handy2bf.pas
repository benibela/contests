program bruteforce;
var n:longint=26;
const      k=8;
var s:longint;
	i,j,b,l,m,c,bestc:longint;
	fkey,curpos:longint;
	h:array[1..26] of longint;
	i2b: array[1..26] of char;
	cur: char;
	bests:array[1..100] of longint;
	bestsc:longint;
begin
	i:=1;
	cur:='A';
	while (i<=n) do begin
		readln(h[i]);
		if h[i]=0 then begin
		  n-=1;
		end else begin
		  i2b[i]:=cur;
		  i+=1;
		end;
		inc(cur);
	end;
	bestc:=26000000;
	for s:=1 shl k -1 to 1 shl n - 1 do begin
		c:=0;
		fkey:=1;
		curpos:=0;
		for i:=1 to n do 
			if s and (1 shl (i-1)) <> 0 then begin
				fkey+=1;
				curpos:=1;
				c+=curpos*h[i];
				if fkey>k then 
					break;
			end else begin
				curpos+=1;
				c+=curpos*h[i];
			end;
		if fkey<>k then continue;
		if c<bestc then begin
			bestc:=c;
			bests[1]:=s;
			bestsc:=1;
		end else if c=bestc then begin
			bests[bestsc+1]:=s;
			bestsc+=1;
		end;
	end;
	writeln('Best: ',bestc);
	writeln();
	for j:=1 to bestsc do begin
		for i:=1 to n do
			if bests[j] and (1 shl (i-1)) <> 0 then begin
				writeln();
				write(i);
			end else 
				write(' ',i);
		writeln();
		writeln();
		for i:=1 to n do
			if bests[j] and (1 shl (i-1)) <> 0 then begin
				writeln();
				write(i2b[i]);
			end else 
				write(i2b[i]);
		writeln();
		writeln();
		writeln();
	end;
end.