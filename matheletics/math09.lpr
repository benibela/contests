program math09;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes,eulerhelp
  { you can add units after this };

const n: integer = 10000000;
var
  pf: TPrimFactorizations;
  ok: Boolean;
  res: int64;
  i: Integer;
  j: Integer;
  pt: int64;
  needed: Integer;
begin
  intSieveFactorizeAll(n+1, pf);
  res := 0;
  for i:= 1 to n do begin
    ok := true;
    for j := high(pf[i+1]) downto 0 do begin
      if pf[i+1][j].prime*pf[i+1][j].count*2 > i then begin
        needed := pf[i+1][j].count*2;
        pt := pf[i+1][j].prime;
        needed -= i div pt;
        while pt * pf[i+1][j].prime < i do begin
          pt *= pf[i+1][j].prime;
          needed -= i div pt;
        end;
        if needed <= 0 then continue;
        ok := false;
        break;
      end;
    end;
    if not ok then begin res += i;{ writeln(i); }end;
  end;
  writeln(res);
end.

