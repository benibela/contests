program dp;
const n=26;
      k=8;
var s:longint;
	cur,i,j,b,l,m,c,bestc:longint;
	fkey,curpos:longint;
	h:array[1..n] of longint;
	costs:array[1..K,1..N] of longint;
	choosen:array[1..k,1..n]of longint;
	bestsc:longint;
begin
	for i:=1 to n do
		readln(h[i]);
	bestc:=26000000;
	for j:=1 to n do begin
		costs[k][j]:=0;
		for l:=j to n do 
			costs[k][j]-=j*h[l];
		choosen[k][j]:=27;
	end;
	for i:=k-1 downto 1 do begin
		for j:=1 to n do begin
			costs[i][j]:=0;
			for l:=j+1 to n do begin
				c:=costs[i+1][l];
				for m:=j to l-1 do 
					c-=j*h[m];
				if c<=costs[i][j] then begin
					costs[i][j]:=c;
					choosen[i][j]:=l;
				end;
			end;
		end;
	end;{
	for i:=1 to k do begin
		for j:=1 to n do 
			write(costs[i][j],#9);
		writeln();
		for j:=1 to n do 
			write(chr(ord('A')+choosen[i][j]-1),#9);
		writeln();
	end;}
	writeln('(base)COSTS:',costs[1][1]);
	for i:=1 to n do
		costs[1][1]+=(i+1)*h[i];
	writeln('COSTS:',costs[1][1]);
	cur:=1;
	for i:=1 to k do begin
		for j:=cur to choosen[i][cur]-1 do 
			write(chr(ord('A')+j-1));
		writeln();
		cur:=choosen[i][cur];
	end;
end.