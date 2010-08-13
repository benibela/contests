program p11162;
{$mode objfpc}{$h+}
uses classes;
var cache:tstringlist;
    modcache: array[0..100] of boolean;
  function count(s:string):longint;
  var i,j,n,new,rc,bc:longint;
  begin
    //writeln(s);
    n:=length(s);
    i:=cache.indexof(s);
    if i>=0 then exit(longint(cache.objects[i]));
    bc:=0;rc:=0;
    for i:=1 to n do 
      if s[i] = 'B' then bc+=1
      else rc+=1;
    if 2*bc<rc then exit(0);
    result:=0;
    i:=2;
    while i<=n do begin
      j:=i+1-3;
      while true do begin
        j:=j+3;
        if j>n then break;
        //if not modcache[i-1-1] then continue;
        //if not modcache[j-i-1] then continue;
        //if not modcache[n-j] then continue;
        if s[1]='B' then begin  
          if (s[i]='R') and (s[j] = 'R') then continue
        end else if (s[i]<>'B') and (s[j] <> 'B') then continue;
        new:=1;
        
        if i<>2 then new:=new*count(copy(s,2,i - 2));
        if j<>i+1 then new:=new*count(copy(s,i+1,j - i - 1));
        if j<>n then new:=new*count(copy(s,j+1,n - j));        
        //writeln(s,':',i,',',j,':',new);
        result:=result+new;
      end;
      i:=i+3;
    end;
    
    cache.addObject(s,tobject(result));
  end;

var i,c,t,j,l:longint;
    s:string;
begin
  for i:=0 to high(modcache) do
    modcache[i]:=i mod 3 = 0;
  cache:=tstringlist.create;
  cache.sorted:=true;
  readln(t);
  for c:=1 to t do begin
    readln(l);
    readln(s);
    setlength(s,l);
    writeln('Case ',c,': ',count(s));
  end;
end.
