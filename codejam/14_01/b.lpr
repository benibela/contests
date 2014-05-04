program bprog;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes , sysutils,math
  { you can add units after this };

var T:longint;
    tt: longint;
    a, b, k: cardinal;
    res: int64;

  function prefixmatch(x, y: cardinal; bit: integer): boolean; inline;
  begin
    result := (x shr bit) = (y shr bit);
  end;

  function prefixlarger(x, y: cardinal; bit: integer): boolean; inline;
  begin
    result := (x shr bit) > (y shr bit);
  end;

  function prefixsmaller(x, y: cardinal; bit: integer): boolean; inline;
  begin
    result := (x shr bit) < (y shr bit);
  end;

  procedure rec(ap, bp: cardinal; bit: longint);
  var
    bitcheck: Integer;
    afree: Boolean;
    bfree: Boolean;
    notaprefixmatch: Boolean;
    notbprefixmatch: Boolean;
    afac, bfac: int64;
  begin
    if bit < 0 then begin
   //   writeln(ap, ' ',bp, ' ',k);
      if (ap and bp) < k then res+=1;
      exit;
    end;
    bitcheck := 1 shl bit;

    if prefixlarger(ap and bp, k, bit+1) then exit;
    notaprefixmatch := not prefixmatch(ap, a, bit+1);
    notbprefixmatch := not prefixmatch(bp, b, bit+1);
    if prefixsmaller(ap and bp, k, bit+1) then begin
      if notaprefixmatch then afac := int64(2) shl bit
      else afac := (a and ((bitcheck shl 1) - 1))  + 1;
      if notbprefixmatch then bfac := int64(2) shl bit
      else bfac := (b and ((bitcheck shl 1) - 1)) + 1;
      {if notaprefixmatch  and notbprefixmatch then begin
        res += (int64(2) shl bit) * (int64(2) shl bit);
        exit;
      end else if notaprefixmatch then begin
      end; }
      //writeln(bit, ' ', notaprefixmatch, ' ', ap, ' ', afac, ' :: ', notbprefixmatch, ' ', bp, ' ', bfac, ' => ',res);
      res += afac * bfac;
      exit;
    end;

    afree := (a and bitcheck <> 0) or notaprefixmatch;
    bfree := (b and bitcheck <> 0) or notbprefixmatch;


    rec(ap, bp, bit-1);
    if afree then rec(ap or bitcheck, bp, bit-1);
    if bfree then rec(ap, bp or bitcheck, bit-1);

    if afree and bfree then begin
      if prefixmatch(ap and bp, k, bit+1) and (k and bitcheck = 0) then exit;
      rec(ap or bitcheck, bp or bitcheck, bit-1);
    end;
  end;

begin
  readln(T);

  for tt:=1 to T do begin
    readln(a, b, k);
    dec(a); dec(b);
    res := 0;
    rec(0,0,30);
    writeln('Case #',tt,': ',res);
  end;
end.


