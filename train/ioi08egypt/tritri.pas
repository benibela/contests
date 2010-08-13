program tritri;

{$mode objfpc}
type ttri= record
  x1,y1,x2,y2,x3,y3: longint;
end;
var tri1,tri2:ttri;
procedure deb(s:string);
begin
write(s);
end;
  function leftSide(x,y:longint;x1,y1,x2,y2:longint): boolean;
  begin
    result:=(y-y2)*(x1-x2) -  (x-x2)*(y1-y2) < 0;
  end;

  function rightSide(x,y:longint;x1,y1,x2,y2:longint): boolean;
  begin
    result:=(y-y2)*(x1-x2) -  (x-x2)*(y1-y2) > 0;
  end;
  

  function isInnerPoint(x,y:longint; const tri: TTri): boolean;
  begin 
    result:=leftSide(x,y,tri.x1,tri.y1,tri.x2,tri.y2) and leftSide(x,y,tri.x2,tri.y2,tri.x3,tri.y3) and leftSide(x,y,tri.x3,tri.y3,tri.x1,tri.y1);
    if not result then 
      result:=rightSide(x,y,tri.x1,tri.y1,tri.x2,tri.y2) and rightSide(x,y,tri.x2,tri.y2,tri.x3,tri.y3) and rightSide(x,y,tri.x3,tri.y3,tri.x1,tri.y1);
  end;

  function leftSideF(x,y:single;x1,y1,x2,y2:single): boolean;
  begin
    result:=(y-y2)*(x1-x2) -  (x-x2)*(y1-y2) < -1e-9;
  end;

  function rightSideF(x,y:single;x1,y1,x2,y2:single): boolean;
  begin
    result:=(y-y2)*(x1-x2) -  (x-x2)*(y1-y2) > 1e-9;
  end;
  

  function isInnerPointF(x,y:single; const tri: TTri): boolean;
  begin 
    result:=leftSideF(x,y,tri.x1,tri.y1,tri.x2,tri.y2) and leftSideF(x,y,tri.x2,tri.y2,tri.x3,tri.y3) and leftSideF(x,y,tri.x3,tri.y3,tri.x1,tri.y1);
    if not result then 
      result:=rightSideF(x,y,tri.x1,tri.y1,tri.x2,tri.y2) and rightSideF(x,y,tri.x2,tri.y2,tri.x3,tri.y3) and rightSideF(x,y,tri.x3,tri.y3,tri.x1,tri.y1);
  end;
  
  
  function possibleintersection(x1,y1,x2,y2: longint; x3,y3,x4,y4: longint): boolean;
  begin
    if leftSide(x1,y1,x3,y3,x4,y4) and leftSide(x2,y2,x3,y3,x4,y4) then exit(false);
    if rightSide(x1,y1,x3,y3,x4,y4) and rightSide(x2,y2,x3,y3,x4,y4) then exit(false);

    if leftSide(x3,y3,x1,y1,x2,y2) and leftSide(x4,y4,x1,y1,x2,y2) then exit(false);
    if rightSide(x3,y3,x1,y1,x2,y2) and rightSide(x4,y4,x1,y1,x2,y2) then exit(false);
    
    result:=true;
  end;
  
  function isparallel(x1,y1,x2,y2: longint; x3,y3,x4,y4: longint): boolean;
  begin
    x2:=x2-x1;
    y2:=y2-y1;
    x4:=x4-x3;
    y4:=y4-y3;
    result:=y2*x4-x2*y4 = 0;    
  end;
   
  function multipointintersection(x1,y1,x2,y2: longint; x3,y3,x4,y4: longint): boolean;
  var u,v:single;
  begin
{    if (x1=x3) and (y1 = y3) then
      if (x2=x4) and (y2 = y4) then exit(true) //identical
      else exit(false); //continued
    if (x2=x4) and (y2 = y4) then exit(false);}
    if x3 = x4 then exit(false);
    if x2 = x1 then exit(false);
    //x1 = x3 + (x4 - x3)* u;
    u := (x1 - x3) / (x4 - x3);
    if (u>1e-9) and (u<1-1e-9) then exit(true);
    u := (x2 - x3) / (x4 - x3);
    if (u>1e-9) and (u<1-1e-9) then exit(true);
    v := (x3 - x1) / (x2 - x1);
    if (v>1e-9) and (v<1-1e-9) then exit(true);
    v := (x4 - x1) / (x2 - x1);
    if (v>1e-9) and (v<1-1e-9) then exit(true);
    result:=false;
  end;  
  
  function reallineIntersection(x1,y1,x2,y2: longint; x3,y3,x4,y4: longint): boolean;
  var u,v:single;
  begin
    {x = x1 + (x2-x1)*u = x3 + (x4 - x3)*v;
      y = y1 + (y2-y1)*u = y3 + (y4 - y3)*v;

      x = x1 - x3 = (x2-x1)*u - (x4 - x3)*v ;
      y = y1 - y3 = (y2-y1)*u - (y4 - y3)*v;
     }
     if x1 = x2 then exit(false);
     { - * (y2-y1) / (x2-x1)
      x = x1 - x3 = (x2-x1)*u - (x4 - x3)*v ;
      y = y1 - y3 - (x1 - x3)*(y2-y1) / (x2-x1)= - (y4 - y3)*v + (x4 - x3)*v*(y2-y1) / (x2-x1) = ( (x4 - x3)*(y2-y1) / (x2-x1) - (y4 - y3) ) * v
      
      => v = (y1 - y3 - (x1 - x3)*(y2-y1) / (x2-x1)) / ( (x4 - x3)*(y2-y1) / (x2-x1) - (y4 - y3) )
           = (y1 - y3 - (x1 - x3)*(y2-y1) / (x2-x1))*(x2-x1) / ( (x4 - x3)*(y2-y1) - (y4 - y3)*(x2-x1))
           = ((y1 - y3)*(x2-x1) - (x1 - x3)*(y2-y1)) / ( (x4 - x3)*(y2-y1) - (y4 - y3)*(x2-x1))
     }
    if (x4 - x3)*(y2-y1) - (y4 - y3)* (x2-x1) = 0 then exit(false);
    v:=-((y1 - y3)*(x2-x1) - (x1 - x3)*(y2-y1)) / ( (x4 - x3)*(y2-y1) - (y4 - y3)*(x2-x1));
    //writeln(v);
    if (v<=1e-9) or (v+1e-9>=1) then exit(false);
    // x = x3 + (x4 - x3)*v = x1 + (x2-x1)*u
    // =>  u = (x3 - x1 + (x4 - x3)*v)/(x2-x1) 
    u:=(x3 - x1 + (x4 - x3)*v)/(x2-x1);
    if (u<=1e-6) or (u+1e-9>=1) then exit(false);
    result:=true;
  end;
  
  
  function pointIntersection(x1,y1,x2,y2: longint; x3,y3,x4,y4: longint): boolean;
  var u,v:single;
  begin
     if x1 = x2 then exit(false);
    if (x4 - x3)*(y2-y1) - (y4 - y3)* (x2-x1) = 0 then exit(false);
    v:=-((y1 - y3)*(x2-x1) - (x1 - x3)*(y2-y1)) / ( (x4 - x3)*(y2-y1) - (y4 - y3)*(x2-x1));
    // x = x3 + (x4 - x3)*v = x1 + (x2-x1)*u
    // =>  u = (x3 - x1 + (x4 - x3)*v)/(x2-x1) 
    u:=(x3 - x1 + (x4 - x3)*v)/(x2-x1);
    result:=(u>1e-6) and (u<1-1e-6) and ((abs(v)<=1e-9) or (abs(v-1)<=1e-9));
    result:=result or ((v>1e-6) and (v<1-1e-6) and ((abs(u)<=1e-9) or (abs(u-1)<=1e-9)));
  end;
  
var i,j,c,intersections,t:longint;
    ok:boolean;
    sada:String;
    procedure checkLS(x1,y1,x2,y2: longint; x3,y3,x4,y4: longint);
    begin
      if possibleintersection(x1,y1,x2,y2,x3,y3,x4,y4) then 
        if isparallel(x1,y1,x2,y2,x3,y3,x4,y4) then begin
          if multipointintersection(x1,y1,x2,y2,x3,y3,x4,y4) then begin
            intersections+=2;
            deb('#');
          end;
        end else begin 
          if reallineIntersection(x1,y1,x2,y2,x3,y3,x4,y4) then begin
            intersections+=4;
            deb('+');
          end else if pointIntersection(x1,y1,x2,y2,x3,y3,x4,y4) then begin
            //intersections+=1;
            deb('.');
          end;
        end;
    end;
    
    function areInnerPointsNear(x,y:single;const tri:ttri):boolean;
    var i,j:longint;
    begin
      for i:=-10 to 10 do
        for j:=-10 to 10 do  
          if (isInnerPointF(x+i/10,y+j/10,tri1) and isInnerPointF(x+i/10,y+j/10,tri2)) then exit(true);
      result:=false;
    end;
   
begin
  readln(t);
  for c:=1 to t do begin
    repeat readln(sada); until POS('#',sada)<=0;
    readln(tri1.x1,tri1.y1,tri1.x2,tri1.y2,tri1.x3,tri1.y3);
    readln(tri2.x1,tri2.y1,tri2.x2,tri2.y2,tri2.x3,tri2.y3);
    write('pair ',c,': ');
    //write(tri1.x1);
    ok:=isInnerPoint(tri1.x1,tri1.y1,tri2) or isInnerPoint(tri1.x2,tri1.y2,tri2) or isInnerPoint(tri1.x3,tri1.y3,tri2) or 
        isInnerPoint(tri2.x1,tri2.y1,tri1) or isInnerPoint(tri2.x2,tri2.y2,tri1) or isInnerPoint(tri2.x3,tri2.y3,tri1);

    if not ok then begin
      ok:=areInnerPointsNear(tri1.x1,tri1.y1,tri2) or areInnerPointsNear(tri1.x2,tri1.y2,tri2) or areInnerPointsNear(tri1.x3,tri1.y3,tri2) or 
          areInnerPointsNear(tri2.x1,tri2.y1,tri1) or areInnerPointsNear(tri2.x2,tri2.y2,tri1) or areInnerPointsNear(tri2.x3,tri2.y3,tri1);
    end;    
    if not ok then begin
      intersections:=0;
      checkLS(tri1.x1,tri1.y1,tri1.x2,tri1.y2,  tri2.x1,tri2.y1,tri2.x2,tri2.y2);
      checkLS(tri1.x1,tri1.y1,tri1.x2,tri1.y2,  tri2.x2,tri2.y2,tri2.x3,tri2.y3);
      checkLS(tri1.x1,tri1.y1,tri1.x2,tri1.y2,  tri2.x3,tri2.y3,tri2.x1,tri2.y1);

      checkLS(tri1.x2,tri1.y2,tri1.x3,tri1.y3,  tri2.x1,tri2.y1,tri2.x2,tri2.y2);
      checkLS(tri1.x2,tri1.y2,tri1.x3,tri1.y3,  tri2.x2,tri2.y2,tri2.x3,tri2.y3);
      checkLS(tri1.x2,tri1.y2,tri1.x3,tri1.y3,  tri2.x3,tri2.y3,tri2.x1,tri2.y1);

      checkLS(tri1.x3,tri1.y3,tri1.x1,tri1.y1,  tri2.x1,tri2.y1,tri2.x2,tri2.y2);
      checkLS(tri1.x3,tri1.y3,tri1.x1,tri1.y1,  tri2.x2,tri2.y2,tri2.x3,tri2.y3);
      checkLS(tri1.x3,tri1.y3,tri1.x1,tri1.y1,  tri2.x3,tri2.y3,tri2.x1,tri2.y1);
      
      ok:=intersections>4;
    end;
       
    if ok then writeln('yes')
    else writeln('no');
  end;
end.
