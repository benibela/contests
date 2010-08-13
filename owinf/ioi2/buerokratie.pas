{$define d}
program buerokratie;
type plongword=^longword;
pli=^tli;
     tli=record
       r,p,c:longint;
       next:pli;
     end;
var knot: array[1..10,1..30000,1..3] of longint;
    bc,bk: longint;
    bcr,tcr: array[1..10] of longint;
    beamten: array[1..10] of array of record
               c: longint;
               links: array[1..20] of record
                 r,p,c:longint;
               end;
             end;
    brang: array[1..30000] of longint;
    bpos: array[1..30000] of longint;
    tc: char;
    s,e,cg,i,j,k:longint;
    mr: longint;
    temp:longword;
    fin,fout:textfile;
    tr1,tp1,tr2,tp2: longint;

    wP,nf:longint;

    visited: array[1..10] of array of longint;
    kip: aRRAY[1..10] OF Record
          cost,count:LONGint;
         end;
    list:array[1..30000] of tli;
    sli,tsli,psli:^tli;
    
const PROBLEM_NAME='buerokratie';
begin
{  if sizeof(longword)<>sizeof(pointer) then begin
    writeln('error pointer size');
    halt;
  end;}
  if paramCount()=0 then begin
    assign(fin,PROBLEM_NAME+'.in');
    reset(fin);
    assign(fout,PROBLEM_NAME+'.out');
    rewrite(fout);
  end else begin
    assign(fin,ParamStr(1));
    reset(fin);
    fout:=stdout;
  end;

  fillchar(bcr,sizeof(bcr),0);
  fillchar(beamten,sizeof(beamten),0);
  fillchar(tcr,sizeof(tcr),0);
{$ifdef d}writeln('a');{$endif}
  mr:=0;
  readln(fin,bc,tc,bk);
  for i:=1 to bc do begin
    readln(fin,brang[i]);
    inc(bcr[brang[i]]);
    bpos[i]:=bcr[brang[i]]-1;
    if brang[i]>mr then mr:=brang[i];
  end;

  for i:=1 to 10 do begin
    setlength(beamten[i],bcr[i]);
    setlength(visited[i],bcr[i]);
    for j:=0 to high(beamten[i]) do
      beamten[i,j].c:=0;
  end;
  
{$ifdef d}writeln('c');{$endif}
  for i:=0 to bk-1 do begin
    readln(fin,s,e,cg);
{$ifdef d}writeln(S,' ',E);{$endif}
    
    tr1:=brang[s];
    tp1:=bpos[s];
    tr2:=brang[e];
    tp2:=bpos[e];
    inc(beamten[tr1,tp1].c);
    with beamten[tr1,tp1].links[beamten[tr1,tp1].c] do begin
      r:=tr2;
      p:=tp2;
      c:=cg;
    end;

{$ifdef d}writeln(' ok ');{$endif}
    inc(beamten[tr2,tp2].c);
    with beamten[tr2,tp2].links[beamten[tr2,tp2].c] do begin
      r:=tr1;
      p:=tp1;
      c:=cg;
    end;
  end;

  close(fin);


{$ifdef d}writeln('e');{$endif}

  wp:=length(beamten[mr]);

  for i:=1 to mr-1 do begin
{$ifdef d}writeln('ränge: i ');{$endif}
    for j:=0 to high(beamten[i]) do begin
      for k:=i+1 to 10 do kip[k].cost:=$EFFFFFFF;
      for k:=1 to 10 do fillchar(visited[i,0],length(VIsited[i])*sizeof(VIsited[i,0]),0);
      sli:=@list[1];
      sli^.r:=i;
      sli^.p:=j;
      sli^.c:=0;
      sli^.next:=nil;
      visited[i,j]:=1;
      nf:=2;
      while (sli<>nil) do begin
{$ifdef d}writeln('  sli: ',sli^.r,',',sli^.p);{$endif}
        visited[sli^.r,sli^.p]:=2;
{$ifdef d}writeln('  r1');{$endif}
        if sli^.c<kip[sli^.r].cost then begin
{$ifdef d}writeln('  r2');{$endif}
          kip[sli^.r].cost:=sli^.c;
{$ifdef d}writeln('  r3');{$endif}
          kip[sli^.r].count:=1;
{$ifdef d}writeln('  r4');{$endif}
        end else if sli^.c=kip[sli^.r].cost then begin
{$ifdef d}writeln('  r5');{$endif}
          inc(kip[sli^.r].count);
{$ifdef d}writeln('  r6');{$endif}
        end;
        for k:=1 to beamten[sli^.r,sli^.p].c do
          with beamten[sli^.r,sli^.p].links[k] do
            case visited[r,p] of
              0: begin
{$ifdef d}writeln('  add:',r,'.',p);{$endif}
                   visited[r,p]:=1;
                   psli:=sli;
                   tsli:=sli^.next;
{$ifdef d}writeln(tsli<>nil);{$endif}

                   while (tsli<>nil) and (tsli^.c<c+sli^.c) do begin
                     psli:=tsli;
                     tsli:=tsli^.next;
//{$ifdef d}writeln('  adding:',r,'.',p,': ',tsli^.r,' ',tsli^.p);{$endif}
                   end;
                   list[nf].next:=tsli;
                   if psli=nil then sli^.next:=@list[nf]
                   else psli^.next:=@list[nf];
                   list[nf].r:=r;
                   list[nf].p:=p;
                   list[nf].c:=c+sli^.c;
                   inc(nf);
{$ifdef d}writeln('  added:',r,'.',p);{$endif}
                 end;
              1: begin
                   tsli:=sli;
                   while (tsli<>nil) do begin
                     if (tsli^.r=r)and(tsli^.p=p) then begin
                       if tsli^.c>c+sli^.c then tsli^.c:=c+sli^.c;
                       break;
                     end;
                   end;
                 end;
            end;
        sli:=sli^.next;
      end;
      for k:=i+1 to mr do
        wp:=wp+kip[k].count;
      inc(wp);
    end;
  end;

  writeln(fout,wp);
  
  if paramCount()=0 then close(fout);
end.
