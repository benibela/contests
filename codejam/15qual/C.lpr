program C;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes , sysutils,strutils,bbutils,math
  { you can add units after this };

var i,j,l,t,d,n:longint;
    x: int64;
    s,pres: string;
    ok: Boolean;

type TQ = (q1, qI, qJ, qK,
           qm1, qmI, qmJ, qmK);

const Ms = [qm1, qmI, qmJ, qmK];
      NEG: array[TQ] of TQ = (qm1, qmI, qmJ, qmK, q1, qI, qJ, qK);

  function multiplyUnsigned(p, q: TQ): TQ;
  begin
    if p = q1 then exit(q);
    if q = q1 then exit(p);
    if p = q then exit(qm1);
    case p of
    qI: case q of
      qJ: result := qK;
      qK: result := qmJ;
    end;
    qJ: case q of
      qI: result := qmK;
      qK: result := qI;
    end;
    qK: case q of
      qI: result := qJ;
      qJ: result := qmI;
    end;
    end;
  end;

  function multiply(p, q: TQ): TQ;
  var
    nega: Boolean;
  begin
    nega := false;
    if p in Ms then begin
      p := NEG[p];
      nega := not nega;
    end;
    if q in Ms then begin
      q := NEG[q];
      nega := not nega;
    end;

    result := multiplyUnsigned(p,q);
    if nega then result := NEG[result];
  end;

  function power(q: TQ; e: int64): TQ;
  var i:integer;
  begin
    e := e mod 8;
    result := q1;
    for i := 1 to e do
      result := multiply(result, q);
  end;

var m: array[0..10000] of tq;
    mblocks: array[0..10000] of tq;
    blocks: Integer;
    idx: Integer;
    blocks2: Integer;
begin
  {writeln(power(qI, 8));
  writeln(power(qJ, 8));
  writeln(power(qK, 8));
  writeln(power(qmI, 8));
  writeln(power(qmJ, 8));
  writeln(power(qmK, 8));
  writeln(power(qmK, 9));
  writeln(power(qmK, 10));
  writeln(power(qmK, 11));     }
  //writeln(multiply(qI, qJ));
  //writeln(multiply(multiply(qI, qJ),qK));
  readln(n);
  for T:=1 to n do begin
    readln(L, X);
    readln(pres);
    assert(length(pres) = l);

    s := pres;

    m[0] := q1;
    for i := 1 to length(s) do
      case s[i] of
        'i': m[i] := multiply(m[i-1],qI);
        'j': m[i] := multiply(m[i-1],qJ);
        'k': m[i] := multiply(m[i-1],qK);
      end;

    mblocks[0] := q1;
    for i := 1 to 8 do
      mblocks[i] := multiply(mblocks[i-1], m[length(s)]) ;

    ok := false;
    if power(m[length(s)], x) = qm1 then
    for blocks := 0 to min(7, x-1) do begin
      for i := 1 to length(s) do begin
        if multiply(mblocks[Blocks], m[i]) = qI then begin
          for j := i+1 to length(s) do
            if (multiply(mblocks[Blocks], m[j]) = qK) then begin
              ok := true;
              break
            end;

          for blocks2 := 1 to 7 do begin
            for j := 1 to length(s) do
              if (blocks+blocks2<x) and (multiply(mblocks[Blocks+blocks2], m[j]) = qK) then begin
                ok := true;
                break
              end;
            if ok then break;
          end;
          if ok then break;
        end;
        if ok then break;
      end;
      if ok then break;
    end;
   {
    for i := 1 to length(s) do begin
      if m[i] = qI  then
      for j := i+1 to length(s) do
        if (m[j] = qK) then begin
          ok := true;
          break
        end;
      if ok then break;
    end;}



    writeln('Case #',T,': ',IfThen(ok, 'YES', 'NO'));
  end;

end.

