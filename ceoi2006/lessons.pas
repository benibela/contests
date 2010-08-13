{
PROG: lessons
LANG: PASCAL
}
//- - - - - < old code > - - - - -
{$IFDEF WIN32}{$DEFINE DEBUG}{$ENDIF}

{$IFDEF DELPHICOMPILED}
  unit ;
  interface implementation
{$ELSE}
  program lessons;
{$ENDIF}

uses {$IFDEF DEBUG}windows,{$ENDIF}sysutils; 
const PROBLEM_NAME='lessons'; 
// - - - - - </ old code > - - - - -
  

type tt=record
	   r,z:longint;
	   desc:string;
	 end;
     tts=array[1..400] of tt;

	 procedure sorttop (var topics:tts; n:longint);
	 var i,j,sel:integer;
	 temp:tt;
	 begin
	   for i:=1 to n do begin
	     sel:=i;
	     for j:=i+1 to n do 
		   if (topics[j].r>topics[sel].r) or ((topics[j].r=topics[sel].r)and(topics[j].z<topics[sel].z)) then 
		     sel:=j;
		 if sel<>i then begin
		   temp:=topics[sel];
		   topics[sel]:=topics[i];
		   topics[i]:=temp;
		   
		 end;
		 //writeln(topics[i].r,' ',topics[i].desc);
	   end;
	 end;
	 
var {$IFDEF DEBUG}exectime:cardinal;{$ENDIF} //old code
     fin,fout:TextFile;
	 i,j,k,l,n,s: longint;
	 topics:tts;
	 c:char;
	 toptime:array[0..400] of record
	   c:longint;
	   top:array[1..400] of boolean;
	   et,rc:longint;
	   
	 end;
	 
begin
  //- - - - - < old code > - - - - -
  {$IFDEF DEBUG}exectime:=GetTickCount;{$ENDIF} 

  if paramcount()=0 then begin
    Assign(fin,PROBLEM_NAME+'.in');
    Reset(fin);
    Assign(fout,PROBLEM_NAME+'.out');
    Rewrite(fout);
  end else begin
    Assign(fin,paramstr(1));
    Reset(fin);
    fout:=stdout;
  end;
  // - - - - - </ old code > - - - - -
fillchar(toptime,sizeof(toptime),0);
  readln(fin,s,n);
  for i:=1 to n do 
    readln(fin,topics[i].r,topics[i].z,c,topics[i].desc);
    
  sorttop(topics,n);
  
  //for i:=1 to n do writeln(topics[i].desc);
  
  for i:=1 to s do begin
    toptime[i]:=toptime[i-1];
    for j:=1 to n do begin
	  if (topics[j].z<=i)and (not topTime[i-topics[j].z].top[j])and(
	       (toptime[i].rc<toptime[i-topics[j].z].rc+topics[j].r) {or 
		   ((toptime[i].rc=toptime[i-topics[j].z].rc+topics[j].r)and(toptime[i].et<i-topics[j].z))} ) then begin
	    toptime[i].rc:=toptime[i-topics[j].z].rc+topics[j].r;
		toptime[i].top:=topTime[i-topics[j].z].top;
		topTime[i].top[j]:=true;
		toptime[i].et:=i-topics[j].z;
	  end;
	end;
	{writeln(#13#10,i,': ');
    for j:=1 to n do 
	  if toptime[i].top[j] then 
	    writeln('  ',topics[j].r,' ',topics[j].z,' ',topics[j].desc);}
		
  end;
  
  k:=s;
  j:=0;
  for i:=1 to n do
    if topTime[s].top[i] then  begin
	  dec(k,topics[i].z);
	  inc(j);
	end;
  if j=0 then writeln(fout,'Es können keine Themen behandelt werden. Gehen Sie schnell zur Videothek!')
  else begin
    writeln(fout,j);
    for i:=1 to n do
      if topTime[s].top[i] then  
	    writeln(fout,topics[i].desc);
    writeln(fout);
    writeln(fout,'Es müssen noch ',k,' Videos besorgt werden.');
  end;
  
  //topTime[i-topics[j].z].top[j]sorttop(toptime[s].top,toptime[s].c);
  
  //- - - - - < old code > - - - - -
  close(fin);
  if paramcount=0 then
    close(fout);
  {$IFDEF DEBUG}writeln (GetTickCount-exectime);{$ENDIF} //old code
  // - - - - - </ old code > - - - - -
end.
        