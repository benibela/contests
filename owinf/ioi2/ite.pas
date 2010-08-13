{$ifdef win32}{$define debug}{$endif}
             {$ifdef debug}{$define debug2}{$endif}
program ite;
uses sysutils;
const PROBLEM_NAME='ite';

type TVarPair=record
  a,b:longint;
end;
     TVarAra=array[1..26] of longint;
     PVarAra=^TVarAra;
type Line=record
  case typ:(ltIf,ltReturn) of
    ltIf:     (
                lVar,rVar: longint;
                thenJump,elseJump: longint;
              );
    ltReturn: (
                value: longint;
                values: TVarAra;
              );
end;


var fin,fout:textfile;
    i,j,k,l:longint;
    tc:char;
    s:string;
    lineCount: longint;
    lines: array[1..20] of Line;
    lineMap: array[1..20] of longint;
    varcount,totalfound,tosearch:longint;
    varNames: array[1..26] of char;
    varMap: array['a'..'z'] of longint;

    vis: array[1..20] of boolean;

    neq: array[1..26,1..26] of boolean;
    equal: array[0..26] of longint;
    noresset: boolean;
    nores: TVarAra;

  procedure setVarAra(ara:PVarAra);
  var i,j,v:longint;
  begin
    fillchar(ara^,sizeof(ara^),0);
    v:=0;
    for i:=1 to equal[0] do begin
      inc(v);
      for j:=1 to varcount do
        if (1 shl j) and equal[i] <>0 then
          ara^[j]:=v;
    end;
    for i:=1 to varcount do begin
      if ara^[i]=0 then begin
        inc(v);
        ara^[i]:=v;
      end;
      {$ifdef debug}write(ara^[i],' ');{$endif}
    end;
    {$ifdef debug}writeln('');{$endif}
    inc(totalfound);
  end;

  procedure play(l,d: longint);
  var x,y,z:longint;
      ida,idb: longint;
      ok:boolean;
      tequal: array[0..26] of longint;
  begin
    if totalfound=tosearch then exit;
    case lines[l].typ of
      ltReturn: begin
                  vis[l]:=true;
                  {$ifdef debug}write(lines[l].value,': ');{$endif}
                  setVarAra(@lines[l].values);
                end;
      ltIf: begin
              {$ifdef debug2}writeln('enter ',l,' deep ',d);{$endif}
              {$ifdef debug2}writeln('  equal ', equal[0], ' ',equal[1], ' ',equal[2]);{$endif}
              if vis[lines[l].thenJump] and (vis[lines[l].elseJump] or (lines[l].lVar=lines[l].rVar)) then
                if noresset then exit
                else if (lines[lines[l].thenJump].typ=ltIf) and (lines[lines[l].elseJump].typ=ltIf) then begin
                  setVarAra(@nores);
                  noresset:=true;
                  exit;
                end;
              {$ifdef debug2}writeln('  check it');{$endif}

                
              vis[l]:=true;

              if (lines[l].thenJump=lines[l].elseJump) or (lines[l].lVar=lines[l].rVar) then begin
                play(lines[l].thenJump,d+1);
                vis[l]:=false;
                exit;
              end;
              
              ida:=1 shl lines[l].lVar;
              idb:=1 shl lines[l].rVar;

                {$ifdef debug2}writeln('  call then jump');{$endif}
                ok:=lines[l].lVar=lines[l].rVar;
                if not ok then
                  for x:=1 to equal[0] do
                    if (ida and equal[x]<>0) and (idb and equal[x]<>0) then begin
                      ok:=true;
                      break;
                    end;

                if ok then begin
                  if (vis[lines[l].thenJump]) then begin
                    if (not noresset) and (lines[lines[l].thenJump].typ=ltIf) then begin
                      noresset:=true;
                      setVarAra(@nores);
                    end;
                  end else play(lines[l].thenJump,d+1);
                end else if not neq[lines[l].lVar,lines[l].rVar] then begin
                  move(equal,tequal,sizeof(tequal));
                  ok:=false;
                  for x:=1 to equal[0] do begin
                    if (ida and equal[x]<>0) then begin
                       for y:=x+1 to equal[0] do
                         if idb and equal[y]<>0 then begin
                           equal[x]:=equal[x] or equal[y];
                           equal[y]:=equal[equal[0]];
                           dec(equal[0]);
                         end;
                       equal[x]:=equal[x] or idb;
                       ok:=true;
                       break;
                     end else if (idb and equal[x]<>0) then begin
                       for y:=x+1 to equal[0] do
                         if ida and equal[y]<>0 then begin
                           equal[x]:=equal[x] or equal[y];
                           equal[y]:=equal[equal[0]];
                           dec(equal[0]);
                         end;
                       equal[x]:=equal[x] or ida;
                       ok:=true;
                       break;
                     end;
                  end;

                  if not ok then begin
                    inc(equal[0]);
                    equal[equal[0]]:=ida or idb;
                  end;
                  if (vis[lines[l].thenJump]) then begin
                    if (not noresset) and (lines[lines[l].thenJump].typ=ltIf) then begin
                      noresset:=true;
                      setVarAra(@nores);
                    end;
                  end else play(lines[l].thenJump,d+1);
                  move(tequal,equal,sizeof(equal));
                end;
              
                {$ifdef debug2}writeln('  call else jump (',l,' deep ',d,')');{$endif}
                ok:=true;
                for x:=1 to equal[0] do begin
                  if (ida and equal[x]<>0) and (idb and equal[x]<>0) then begin
                    ok:=false;
                    break;
                  end;
                end;
                if ok then begin
                  neq[lines[l].lVar,lines[l].rVar]:=true;
                  play(lines[l].elseJump,d+1);
                  if (vis[lines[l].elseJump]) then begin
                    if (not noresset) and (lines[lines[l].elseJump].typ=ltIf) then begin
                      noresset:=true;
                      setVarAra(@nores);
                    end;
                  end else play(lines[l].elseJump,d+1);
                  neq[lines[l].lVar,lines[l].rVar]:=false;
                end
                {$ifdef debug2}else writeln('  else jumping breaked: ', equal[0], ' ',equal[1], ' ',equal[2]);{$endif}
                ;
;
              vis[l]:=false;
              {$ifdef debug2}writeln('  equal ', equal[0], ' ',equal[1], ' ',equal[2]);{$endif}
              {$ifdef debug2}writeln('  finished (',l,' deep ',d,')');{$endif}
            end;
    end;
  end;
    
begin
  noresset:=false;
  fillchar(varMap,sizeof(varMap),0);
  fillchar(equal,sizeof(equal),0);
  fillchar(neq,sizeof(neq),0);
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

  varcount:=0;
  linecount:=0;
  tosearch:=1;
  totalfound:=0;
  while true do begin
    readln(fin,s);
    if s='' then break;
    inc(linecount);
    j:=1;
    for i:=1 to length(s) do
      if not (s[i] in ['0'..'9']) then begin
        lineMap[lineCount]:=strtoint(copy(s,1,i-1));
        j:=i;
        break;
      end;
    case s[j+1] of
      'R': begin
             lines[lineCount].typ:=ltReturn;
             delete(s,1,j+7);
             delete(s,pos(')',s),length(s));
             lines[lineCount].value:=strtoint(s);
             inc(tosearch);
             {$ifdef debug}writeln(lineCount,' RETURN(',lines[lineCount].value,')');{$endif}
           end;
      'I': begin
             lines[lineCount].typ:=ltIf;
             delete(s,1,j+3);
             if varMap[s[1]]=0 then begin
               inc(varCount);
               varMap[s[1]]:=varCount;
               varNames[varCount]:=s[1];
             end;
             if varMap[s[3]]=0 then begin
               inc(varCount);
               varMap[s[3]]:=varCount;
               varNames[varCount]:=s[3];
             end;
             lines[lineCount].lVar:=varMap[s[1]];
             lines[lineCount].rVar:=varMap[s[3]];
             if lines[lineCount].lVar>lines[lineCount].rVar then begin
               k:=lines[lineCount].lVar;
               lines[lineCount].lVar:=lines[lineCount].rVar;
               lines[lineCount].rVar:=k;
             end;
             delete(s,1,9);
             j:=1;
             for i:=1 to length(s) do
               if not (s[i] in ['0'..'9']) then begin
                 lines[lineCount].thenJump:=strtoint(copy(s,1,i-1));
                 j:=i;
                 break;
              end;
             delete(s,1,j+5);
             lines[lineCount].elseJump:=strtoint(s);
             {$ifdef debug}writeln(lineMap[lineCount],' IF ',lines[lineCount].lVar,'=',lines[lineCount].rVar,' THEN ',lines[lineCount].thenJump,' ELSE ',lines[lineCount].elseJump);{$endif}
           end;
    end;
  end;

  close(fin);


  for i:=1 to lineCount do
    if lines[i].typ=ltIf then begin
      for j:=1 to lineCount do
        if lineMap[j]=lines[i].thenJump then begin
          lines[i].thenJump:=j;
          break;
        end;
      for j:=1 to lineCount do
        if lineMap[j]=lines[i].elseJump then begin
          lines[i].elseJump:=j;
          break;
        end;
    end;

  {$ifdef debug}writeln('==========================');{$endif}

  play(1,1);

  if noresset then begin
    for j:=1 to varcount-1 do begin
      write(fout,varNames[j],'=',nores[j],',');
    end;
    writeln(fout,varNames[varcount],'=',nores[varcount]);
  end;


  for i:=1 to linecount do
    if vis[i] and (lines[i].typ=ltReturn) then begin
      writeln(fout,lines[i].value,':');
      for j:=1 to varcount-1 do
        write(fout,varNames[j],'=',lines[i].values[j],',');
      writeln(fout,varNames[varcount],'=',lines[i].values[varcount]);
    end;

  if paramCount()=0 then close(fout);
  
  Writeln('Warum braucht ihr hier 10 Sekunden, wenn es doch in 10 Millisekunden geht ;-) ???');
  Writeln('(Hoffentlich interessiert es auch jemanden, was ich hier schreiben)');
end.