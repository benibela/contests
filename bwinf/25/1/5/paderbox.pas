program paderbox;
{$mode objfpc}
uses crt;
const CHANGE_LIGHTS:array[0..2,0..1] of longint=
           ((0,1),(0,2),(1,2)); //lights to change in 
           
var states: array[0..2] of record //Liste der Zustände
      changes:array[0..1] of longint; //Übergänge
      lightsID: longint; //damit verbundene Lampen
    end;
    //(start) light-status
    slights,lights: array[0..2] of boolean;
    //current state
    state:longint;

  //---------print the status of the lights------------
  procedure printStatus();
  const LIGHTSTATE:array[boolean] of char = ('O','X');
  var i:longint;
  begin
    for i:=0 to 2 do
      write(LIGHTSTATE[lights[i]]);
    write(' ');
  end;

  //--------print the programming of the box-----------
  procedure printSolution();
  const LIGHT_NAMES: array[0..2] of string=('++_','+_+','_++');
  var i:integer;
  begin
    writeln();
    writeln('Printing solution:');
    for i:=0 to 2 do 
      writeln('  ',LIGHT_NAMES[states[i].lightsID],': ',
              ' 0->',LIGHT_NAMES[states[states[i].changes[0]].lightsID],
              ' 1->',LIGHT_NAMES[states[states[i].changes[1]].lightsID]);
     writeln();
  end;
    
  //----------creates a random programming------------
  procedure init();
    //creates a connection to new, from old or state 0
    procedure addLink(new, old: longint);
    begin
      if (random(1000)<500) then begin
        //link from start state 
        if (states[new].changes[0]=old)or(states[new].changes[1]=old) or 
           ((states[0].changes[0]=old)and(states[0].changes[1]=old)) then 
            states[0].changes[random(2)]:=new 
        else if states[0].changes[0]=old then states[0].changes[1]:=new
        else states[0].changes[0]:=new;
      end else //link from old
        states[old].changes[random(2)]:=new;
    end;    
    
  var i,j,k:integer;
      freeLightConfig: array[0..2] of longint;
      visitable: array[0..2] of boolean;
  begin
    randomize;
    fillchar(visitable,sizeof(visitable),0);
    visitable[0]:=true;
    for i:=0 to 2 do 
      freeLightConfig[i]:=i; 
    //init states
    for i:=0 to 2 do begin
      //get light pair id
      j:=random(3-i);
      //save light id
      states[i].lightsID:=freeLightConfig[j];
      //remove light pair from freeLightConfig
      freeLightConfig[j]:=freeLightConfig[2-i];
      
      //creates random links
      for j:=0 to 1 do begin
        states[i].changes[j]:=random(3);
        if visitable[i] then //if j can be visited, the new, too
          visitable[states[i].changes[j]]:=true;
      end;
    end;
    //check states which cann't be visited
    if paramstr(1)<>'--allow-not-visitable-states' then begin
      //both are not visitable
      if (not visitable[1]) and (not visitable[2]) then begin
        //link to one
        j:=random(2);
        states[0].changes[j]:=random(2)+1;
        //update visit status
        visitable[states[0].changes[j]]:=true;
        visitable[states[states[0].changes[j]].changes[0]]:=true;
        visitable[states[states[0].changes[j]].changes[0]]:=true;
      end;
      //if one is not visitable call addLink
      if not visitable[1] then addLink(1,2)
      else if not visitable[2] then addLink(2,1);
    end;
    //random lights
    for i:=0 to 2 do 
      slights[i]:=random(1000)<500;
  end;
  
  //----------change to start status-----------
  procedure reset();
  begin
    state:=0;
    lights:=slights;
    printStatus();
  end;
      
  //change status
  procedure change(number: longint);
  var i:integer;
  begin
   state:=states[state].changes[number]; 
   with states[state] do 
     for i:=0 to 1 do
       lights[CHANGE_LIGHTS[lightsId][i]]:=not lights[CHANGE_LIGHTS[lightsId][i]];
   printStatus();
  end;

//-----------main program------------
var key:char;
    i:integer;
begin
  writeln('========Die Paderbox========');
  init();
  reset();
  
  while true do begin
    key:=ReadKey;
    writeln(key);
    case lowercase(key) of 
      '0','1': change(ord(key)-ord('0'));
      'r': reset();
      's': begin
        printSolution();
        printStatus();
      end;
      'q': begin //quit
        printSolution();
        exit;
      end;
    end;
  end;
end.
