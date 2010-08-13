{$define Verbose}
{$define debug}
program dressing;
{$mode objfpc}

uses classes,sysutils;
const NEWLINE={$ifdef debug}'\n'{$else}' '{$endif};
var names:TStringList;
    line:string;  //read line
    garment1,garment2: longint; 
    spacePos: longint;
    i,j,k,l,m,oldlen,current:longint;
    //adjListNeed[i][j]=k, iff i needs k
    adjListNeed:array of array of longint; 
    //adjListAllow[i][j]=k, iff k needs i
    adjListAllow:array of array of longint;
    canBeUsedNow: boolean;
    
    singleSequenceIndex: longint; //index in the next array
    singleSequence: array of longint; //begin of a sequence
    singleSequenceReaded: array of boolean;//is something read
    
  //searches a sequence
  procedure generateSingleSequence(pos: longint);
  var i:longint;
  begin
    {$ifdef debug}writeln('    gen.single.seq.:',pos,':',names[pos],' visited: ',singleSequenceReaded[pos],NEWLINE);{$endif}
    if singleSequenceReaded[pos] then exit; //already visited?
    singleSequenceReaded[pos]:=true;
    //check everything needed for the current garment
    for i:=1 to adjListNeed[pos][0] do 
      generateSingleSequence(adjListNeed[pos][i]);
    //write it in the list
    singleSequence[singleSequenceIndex]:=pos;
    inc(singleSequenceIndex);
  end;
   
//list of every sequence   
var sequences: array of record
      seq: array of longint; //begin of a sequence
      next: array of longint; //which can be taken next
      used: array of boolean; //already weared
    end;
   
begin
  //=====================read clothes (sec.1)========================
  {$ifdef verbose}writeln('==== Eingabe ====',NEWLINE);{$endif}
  names:=TStringList.create;
  readln(line); line:=line+' ';
  {$ifdef verbose}writeln(line,NEWLINE);{$endif}
  while line<>'' do begin
    spacePos:=pos(' ',line);
    names.add(copy(line,1,spacePos-1));
    delete(line,1,spacePos);
    line:=trimleft(line);
  end;
  
  //reserve memory for adjacent list
  setlength(adjListNeed, names.count, names.count+1);
  for i:=0 to names.count-1 do adjListNeed[i][0]:=0;
  setlength(adjListAllow, names.count, names.count+1);
  for i:=0 to names.count-1 do adjListAllow[i][0]:=0;
  
  //read order
  readln(line); 
  while line<>'' do begin
    {$ifdef verbose}writeln(line,NEWLINE);{$endif}
    spacePos:=pos(' ',line);
    garment1:=names.indexOf(copy(line,1,spacePos-1));
    if garment1=-1 then 
      raise exception.create('Invalid Garment at line start');
    delete(line,1,spacePos);
    garment2:=names.indexOf(trimleft(line));
    if garment2=-1 then 
      raise exception.create('Invalid Garment at line start');
    //insert garment1,2 in graphs
    inc(adjListNeed[garment2][0]);
    adjListNeed[garment2][adjListNeed[garment2][0]]:=garment1;
    inc(adjListAllow[garment1][0]);
    adjListAllow[garment1][adjListAllow[garment1][0]]:=garment2;
    
    readln(line);
  end;
  
  {$ifdef verbose}writeln(#13#10'==== Ausgabe ====',NEWLINE);{$endif}

  
  //================find a single sequence (sec. 2)==================
  if (paramcount=0) or (paramstr(1)='--only-one') then begin
    setlength(singleSequence,names.count);
    setlength(singleSequenceReaded,names.count);
    fillchar(singleSequenceReaded[0],sizeof(singleSequenceReaded[0])*length(singleSequenceReaded),0);
    singleSequenceIndex:=0;
    for i:=0 to names.count-1 do
      generateSingleSequence(i);
    for i:=0 to names.count-1 do
      write(names[singleSequence[i]],' ');
    writeln(NEWLINE);
  end;
  
   //=================find all sequences (sec. 3)====================
  if (paramcount=0) or (paramstr(1)='--all') then begin
    if paramcount=0 then writeln(NEWLINE);
    //init
    setlength(sequences,1);
    with sequences[0] do begin
      setlength(seq,names.count);
      setlength(next,0);
      setlength(used,names.count);
    end;
    for i:=0 to names.count-1 do
      if adjListNeed[i][0]=0 then begin
        setlength(sequences[0].next,length(sequences[0].next)+1);
        sequences[0].next[high(sequences[0].next)]:=i;
      end;
    //search
    for i:=0 to names.count-1 do begin
      {$ifdef debug}
        writeln('loop: ',i,NEWLINE);
        writeln('  current sequences and next arrays: ',NEWLINE);
        //print all sequences
        for k:=0 to high(sequences) do begin
          for j:=0 to i-1 do
            write(names[sequences[k].seq[j]],' ');
          write(' + ');
          for j:=0 to high(sequences[k].next) do
            write(names[sequences[k].next[j]],' ');
          writeln(NEWLINE);
        end;{$endif}
      //create a sequence for every possible appending
      //to any known sequence
      for j:=0 to high(sequences) do begin
        oldlen:=length(sequences);
        setlength(sequences,length(sequences)+length(sequences[j].next)-1);
        for k:=oldlen to high(sequences) do begin
          sequences[k]:=sequences[j];
          //copy arrays
          setlength(sequences[k].seq,length(sequences[k].seq));
          setlength(sequences[k].used,length(sequences[k].used));
          setlength(sequences[k].next,length(sequences[k].next));
          
          //add to sequence
          sequences[k].seq[i]:=sequences[j].next[k-oldlen]; 
          //remove from next
          sequences[k].next[k-oldlen]:=sequences[k].next[high(sequences[k].next)];
          setlength(sequences[k].next,high(sequences[k].next));
        end;
        //add last possibility to current sequence
        sequences[j].seq[i]:=sequences[j].next[high(sequences[j].next)];
        setlength(sequences[j].next,high(sequences[j].next));
      end;

      //search all new nodes that can be used now
      for j:=0 to high(sequences) do begin
        sequences[j].used[sequences[j].seq[i]]:=true; 
        for k:=1 to adjListAllow[sequences[j].seq[i]][0] do begin
          current:=adjListAllow[sequences[j].seq[i]][k];
          //current is the only thing which was earlier not allowed, 
          //but can it be now.
          //Check if current can really used:
          canBeUsedNow:=true;
          for l:=1 to adjListNeed[current][0] do
            if not sequences[j].used[adjListNeed[current][l]] then begin
              canBeUsedNow:=false;
              break;
            end;
          //if it can be used, add to next
          if canBeUsedNow then begin 
            setlength(sequences[j].next,length(sequences[j].next)+1);
            sequences[j].next[high(sequences[j].next)]:=current;
          end;
        end;
      end;
    end;

    //print all sequences
    for i:=0 to high(sequences) do begin
      for j:=0 to names.count-1 do
        write(names[sequences[i].seq[j]],' ');
      writeln(NEWLINE);
    end;
  end;
  names.free;
end.
