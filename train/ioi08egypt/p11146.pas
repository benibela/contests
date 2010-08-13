program p11146;
{$mode objfpc}
const myinf=1e30;
var i,j,k,c,t,n,m,a,b:longint;
    vc: array[1..100] of single;
    tc:array[1..60,1..60] of single;
    con: array[1..60,1..60] of boolean;
    flow: array[0..100,0..100] of single;
    q,path: array[1..100] of longint;
    qs,qe,plen:longint;
    current: single;
    visit:array[0..100] of longint;

    
    
 function findPath:boolean;
 var p:longint;
 begin
   qs:=1;
   qe:=1;
   q[1]:=2;
   result:=false;
   fillchar(visit,sizeof(visit),0);
   visit[q[1]]:=-1;
   while qs<=qe do begin
     p:=q[qs];inc(qs);
     if p=2*n then begin
       path[1]:=p;
       plen:=1;
       current:=myinf;
       while visit[p]<>-1 do begin
         if flow[p,visit[p]]<current then current:=flow[p,visit[p]];
         inc(plen);
         path[plen]:=visit[p];
         p:=visit[p];
       end;       
       exit(true);
     end;
     for i:=0 to 2*n do 
       if (visit[i]=0) and (flow[i,p]>0)  then begin
         visit[i]:=p;
         qe+=1;
         q[qe]:=i;
       end;
   end;
 end;
  var money,maxf:single; changed: boolean; maxi: longint;
begin 
  readln(t);
  for c:=1 to t  do begin
    fillchar(con,sizeof(con),0);
    readln(n,m);
    for i:=1 to n do
      for j:=1 to n do
        tc[i,j]:=myinf;
    vc[1]:=0;
    vc[n]:=0;
    for i:=2 to n-1 do begin
      read(vc[i]);
    end;
    for i:=1 to m do begin
      readln(a,b);
      con[a,b]:=true;
      con[b,a]:=true;
      tc[a,b]:=vc[b];
      tc[b,a]:=vc[a];
    end;
    if con[1,n] then begin 
      writeln('"No Solution!"');
      continue;
    end;
    for i:=1 to n do tc[i,i]:=0;
    for i:=1 to n  do
      for j:=1 to n do
        for k:=1 to n do
          if tc[j,i] + tc[i,k] < tc[j,k] then
            tc[j,k]:=tc[j,i]+tc[i,k];
    {for i:=1 to n do
      for j:=1 to n do
        if tc[i,j]+vc[i]<>tc[j,i]+vc[j] then 
          writeln('assert failed: ',i,' ',j,' ',tc[i,j],' ',tc[j, i]);}
    for i:=2 to n-1 do
      vc[i]:=tc[1,i]+tc[n,i];
    (*for i:=1 to n do begin
    writeln(tc[1,i],',',tc[n,i ],'->',vc[i]);
      {for j:=1 to n do 
        write(tc [i,j]:10:2,' ');
      writeln;}
    end;//*)
    changed:=true;
    money:=0;
    //while changed do begin  
      changed:=false;
      fillchar(flow,sizeof(flow),0);
      for i:=1 to n do 
        for j:=1 to n do 
          if con[i,j] then begin //von 2j+1 -> 2i
            flow[2*i,2*j+1]:=myinf;
            flow[2*j,2*i+1]:=myinf;
          end;
      vc[1]:=myinf;
      vc[n]:=myinf;
      for i:=1 to n do begin //von 2i->2i+1
        flow[i*2+1,i*2]:=vc[i];
        //flow[i*2,i*2+1]:=0;
      end;
      
      while findPath do begin 
//        changed:=true;//
//writeln(' ',current:1:4);
        money+=current;
        for i:=plen-1 downto 1 do begin
          flow[path[i],path[i+1]]-=current;
          flow[path[i+1],path[i]]+=current;
       //   writeln(path[i] shr 1,   ' ' ,path[i] and 1);
        end;
      end;//writeln('y');
    //end;
   // writeln('res:');
    writeln(money:1:4);
  end;
  
end.
