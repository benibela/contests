program wirtschaft;
{$mode objfpc}
{$COPERATORS ON}
uses sysutils;
var budget,maxbudget,currentbudget:longint;
    owned,buy,sell: array of boolean; //owned, bought and sold items
    ownedCount,sellCount: longint; //count of true-values in owned & sell
    objects: array of longint;
    line:string;
    i,j,months: longint;
begin
  writeln('==Närrische Wirtschaft==');
  //read input
  setlength(objects,0);
  readln(budget);
  maxbudget:=budget;
  readln(line);
  while line<>'' do begin
    setlength(objects,length(objects)+1);
    objects[high(objects)]:=strtoint(line);
    if objects[high(objects)]>maxbudget then begin
      //if the file is ordered ascending, every following 
      //object is also too expensive
      writeln('you can''t buy:');
      while line<>'' do begin
        write(' ',line);
        readln(line);
      end;
      setlength(objects,high(objects));
      break;
    end;
    //max budget if every object is sold
    maxbudget+=objects[high(objects)];
    readln(line);
  end;



  //init arrays
  setlength(owned,length(objects));
  setlength(buy,length(objects));
  setlength(sell,length(objects));
  fillchar(owned[0],sizeof(owned[0])*length(owned),0);
  ownedCount:=0;
  //count months
  months:=1;
  while ownedCount<length(objects) do begin
    fillchar(buy[0],sizeof(owned[0])*length(owned),0);
    fillchar(sell[0],sizeof(owned[0])*length(owned),0);
    sellcount:=0;
    //calculate the highest usable amount of money
    maxbudget:=budget;
    for i:=0 to high(objects) do 
      if owned[i] then  
        maxbudget+=objects[i];
    currentbudget:=budget;
    //search most expensive object which can be bought
    for i:=high(objects) downto 0 do begin
      if owned[i] then 
        maxbudget-=objects[i] //don't use an object to buy a cheaper one
      else if (not owned[i]) and (objects[i]<=maxbudget) then begin
        //objects[i] can be bought
        //search cheapest to sold
        if objects[i]>currentbudget then 
          for j:=0 to i-1 do 
            if owned[j] then begin
              //it isn't owned anymore
              owned[j]:=false;
              dec(ownedCount);
              sell[j]:=true;
              sellcount+=1;
              //recalculate budget
              currentbudget+=objects[j]; 
              if objects[i]<=currentbudget then break;
            end;
        //recalculate budgets
        currentbudget-=objects[i];
        maxbudget:=maxbudget-objects[i];
        //i is now owned
        owned[i]:=true;
        inc(ownedCount);
        if sell[i] then begin
          sell[i]:=false;
          sellcount-=1;
        end else buy[i]:=true;
      end;
    end;
    //print month
    writeln('Month: ',months);
    if sellcount>0 then begin 
      write('  sell:');
      for i:=0 to high(objects) do
        if sell[i] then
          write(' ',objects[i]);
      writeln();
    end;
    write('  buy:');
    for i:=0 to high(objects) do
      if buy[i] then
        write(' ',objects[i]);
    if currentbudget<>0 then
      write('  (',currentbudget,')');
    writeln();
    months+=1;
  end;
end. 