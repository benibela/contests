program borg;
	{$ifdef win32}uses sysutils,windows;{$endif}
type tt=record
  x,y,d:longint;
end;
var ship: array[1..50,1..50] of longint;
//    dist: array[1..50,1..50,1..50,1..50] of longint;
    w,h,i,j:longint;

function na(sx,sy,md,id:longint):tt;
var q:array[1..2500] of tt;
	qe,qs,x,y: longint;
begin
  q[1].x:=sx;
  q[1].y:=sy;
  q[1].d:=0;
  qe:=1;
  qs:=1;
  na.d:=9999;
  while (qs<=qe) do begin
    if q[qs].d>=md-1 then exit;
	x:=q[qs].x;
	y:=q[qs].y;
    if x>0 then
	  if ship[x-1,y]<id then begin
	    inc(qe);
		q[qe].d:=q[qs].d+1;
		q[qe].x:=x-1;
		q[qe].y:=y;
		ship[x-1,y]:=id;
	  end else if ship[x-1,y]=6250001 then begin
	    na.x:=q[qs].x-1;
		na.y:=q[qs].y;
		na.d:=q[qs].d+1;
		exit;
	  end;
    if x<w then
	  if ship[x+1,y]<id then begin
	    inc(qe);
		q[qe].d:=q[qs].d+1;
		q[qe].x:=x+1;
		q[qe].y:=y;
		ship[x+1,y]:=id;
	  end else if ship[x+1,y]=6250001 then begin
	    na.x:=q[qs].x+1;
		na.y:=q[qs].y;
		na.d:=q[qs].d+1;
		exit;
	  end;
    if y>0 then
	  if ship[x,y-1]<id then begin
	    inc(qe);
		q[qe].d:=q[qs].d+1;
		q[qe].x:=x;
		q[qe].y:=y-1;
		ship[x,y-1]:=id;
	  end else if ship[x,y-1]=6250001 then begin
	    na.x:=q[qs].x;
		na.y:=q[qs].y-1;
		na.d:=q[qs].d+1;
		exit;
	  end;
    if q[qs].y<h then
	  if ship[x,y+1]<id then begin
	    inc(qe);
		q[qe].d:=q[qs].d+1;
		q[qe].x:=x;
		q[qe].y:=y+1;
		ship[x,y+1]:=id;
	  end else if ship[x,y+1]=6250001 then begin
	    na.x:=q[qs].x;
		na.y:=q[qs].y+1;
		na.d:=q[qs].d+1;
		exit;
	  end;
	inc(qs);
  end;
end;

var fin, fout: Textfile;
	s:string;
	{alien,}bor: array[1..2500] of record
	        x,y:longint;
	      end;
    bc,ac,id,midi,bb: longint; 
	best,temp: tt;
	{$ifdef win32}time:cardinal;{$endif}
begin
	{$ifdef win32}time:=gettickcount;{$endif}
  bc:=1;
  ac:=1;
  //fillchar(dist,sizeof(dist),$FF);
  assign(fin,'borg.in');
  reset(fin);
  readln(fin,w,h);
  for j:=1 to h do begin
	readln(fin,s);
    for i:=1 to w do begin
	  case s[i] of
	    'A': begin
		    {   alien[ac].x:=i;
		       alien[ac].y:=j;}
		       inc(ac);
	           ship[i,j]:=6250001;
		     end; 
	    'S': begin
		       bor[bc].x:=i;
		       bor[bc].y:=j;
		       inc(bc);
	           ship[i,j]:=0;
		     end; 
	     ' ':ship[i,j]:=0;
	     '#':ship[i,j]:=6250010;
	  end;
	end;
  end;
  close(fin);
  
  id:=1;
  midi:=0;
  while (ac>1) do begin
    bb:=1;
    best:=na(bor[bc-1].x,bor[bc-1].y,9999,id);
	//writeln('  |',best.d);
	inc(id);
	for i:=bc-2 downto 1 do begin
      temp:=na(bor[i].x,bor[i].y,best.d,id);
	  inc(id);
	  if temp.d<best.d then begin
	    bb:=i;
	    best:=temp;
	  end;
	end;
  //writeln(bb,'/',bc,' ',bor[bb].x,' ',bor[bb].y,'->',best.x,' ',best.y,'  |',bor[1].x,' ',bor[1].y);
	bor[bb].x:=best.x;
	bor[bb].y:=best.y;
	bor[bc].x:=best.x;
	bor[bc].y:=best.y;
	inc(bc);
	inc(midi,best.d);
	ship[best.x,best.y]:=0;
	dec(ac);
  end;
  
  assign(fout,'borg.out');
  rewrite(fout);
  writeln(fout,midi);
  writeln(midi);
  close(fout);
	{$ifdef win32}writeln('t:',gettickcount-time);{$endif}
end.
