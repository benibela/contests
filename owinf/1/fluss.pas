program fluss;
uses sysutils;
var products:array of array of longint;
  procedure readFile(n:string);
  var f:TextFile;
      temp:string;
      i,j,k:longint;
  begin
    Assign(f,n);
    Reset(f);
    Readln(f,temp);i:=strtoint(temp);
    setLength(products,i);
    for j:=0 to i-1 do begin
      Readln(f,temp);i:=strtoint(temp);
      setLength(products[j],i);
      for k:=0 to i-1 do begin
        Readln(f,temp);i:=strtoint(temp);
        products[j][k]:=i;
      end;
    end;
    close(f);
  end;
type TAra=array of longint;
var start,ziel:Tara;
     temp1,temp2:tara;
    ls,lz,l1,l2:longint;
     i,j,k:longint;
     result:TextFile;

     procedure error;
     begin
       Close(result);
       assign(result,'fluss.out');
       Rewrite(result);
       Writeln(result,'F');
       Close(result);
       halt;
     end;

  function searchEater(ara:TAra;len:longint):longint;
  var i,j,k:longint;
  begin
    fillchar(temp1[0],len*sizeof(longint),0);
    fillchar(temp2[0],len*sizeof(longint),0);
    l1:=len;
    l2:=len;
    for i:=0 to len-1 do begin
      for j:=0 to len-1 do begin
        for k:=0 to high(products[ara[i]]) do begin
          if products[ara[i]][k]=ara[j] then begin
            inc(temp1[i]);   //fresser
            inc(temp2[j]);           //beute
            break;
          end;
        end;
      end;
    end;
    j:=0;
    for i:=0 to len-1 do begin
      if temp1[i]>temp1[j] then begin
        j:=i;
      end else if (temp1[i]=temp1[j])and(temp2[i]>temp2[j]) then begin
        j:=i;
      end;
    end;
    searchEater:=j;
  end;
  function searchEated(ara:TAra;len:longint):longint;
  var i,j,k:longint;
  begin
    fillchar(temp1[0],len*sizeof(longint),0);
    fillchar(temp2[0],len*sizeof(longint),0);
    l1:=len;
    l2:=len;
    for i:=0 to len-1 do begin
      for j:=0 to len-1 do begin
        for k:=0 to high(products[ara[i]]) do begin
          if products[ara[i]][k]=ara[j] then begin
            inc(temp1[i]);   //fresser
            inc(temp2[j]);           //beute
            break;
          end;
        end;
      end;
    end;
    j:=0;
    for i:=1 to len-1 do begin
      if temp2[i]>temp2[j] then begin
        j:=i;
      end else if (temp2[i]=temp2[j])and(temp1[i]>temp1[j]) then begin
        j:=i;
      end;
    end;
    searchEated:=j;
  end;
begin
  readFile('fluss.in');
  assign(result,'fluss.out');
  Rewrite(result);

  SetLength(start,length(products));
  for i:=0 to high(products) do
    start[i]:=i;
  setLength(ziel,length(products));
  fillchar(ziel[0],length(products)*sizeof(longint),$FF);
  setLength(temp1,length(products));
  setLength(temp2,length(products));
  ls:=length(products);lz:=0;l1:=0;l2:=0;

    fillchar(temp1[0],ls*sizeof(longint),0);
    fillchar(temp2[0],ls*sizeof(longint),0);
    for i:=0 to ls-1 do begin
      for j:=0 to ls-1 do begin
        for k:=0 to high(products[start[i]]) do begin
          if products[start[i]][k]=start[j] then begin
            inc(temp2[j]);
          end;
        end;
      end;
    end;
    for i:=0 to ls-1 do
      if temp2[j]>1 then error;

  while (ls>0) do begin
    i:=searchEater(start,ls);
    Writeln(result,start[i]);
    ziel[lz]:=start[i];
    inc(lz);
    start[i]:=start[ls-1];
    dec(ls);

    j:=searchEated(ziel,lz);
    if temp2[j]=0 then begin
      Writeln(result,'L');
    end else begin
      if j=lz-1 then j:=searchEater(ziel,lz);
      Writeln(result,ziel[j]);
      start[ls]:=ziel[j];
      inc(ls);
      ziel[j]:=ziel[lz-1];
      dec(lz);
    end;
  end;
  Writeln(result,'F');
  Close(result);
end.
