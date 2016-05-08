program Csmall;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes,
  bigdecimalmath, bbutils, eulerhelp
  { you can add units after this };

const caseN = 32;
const caseJ = 500;

var primes: array[1..100] of BigDecimal;
    bases: array[2..10,0..50] of BigDecimal;
    jamInBases: array[2..10] of BigDecimal;
    jam: array[1..50] of boolean;
    witness: array[2..10] of integer;
    usedPrimes: integer;


function isJam(): boolean;
var
  b, i: Integer;
  okInBase: Boolean;
begin
  for b := 2 to 10 do begin
    okInBase := false;

    setZero(jamInBases[b]);

    for i := 1 to caseN do
      if jam[i] then
        jamInBases[b] := jamInBases[b] + bases[b, i - 1];

    for i := 1 to usedPrimes do
      if jamInBases[b] mod primes[i] = 0 then begin
        witness[b] := i;
        okInBase := true;
        break;
      end;
    if not okInBase then exit(false);
  end;
  result := true;
end;

var
  p: Integer;
  foundJ , i, j, b: integer;
  temps: string;
begin
  p := 1;
  for i := 2 to 10000 do
    if intIsProbablePrime(i) then begin
      primes[p] := i;
      inc(p);
      if p > high(primes) then break;
    end;

  for i := 2 to 10 do begin
    bases[i, 0] := 1;
    for j := 1 to high(bases[i]) do
      bases[i, j] := bases[i, j - 1] * i;
  end;

  FillChar(jam, sizeof(jam), 0);
  jam[1] := true;
  jam[caseN] := true;

  writeln('Case #1:');
  foundJ := 0;
  usedPrimes := 5;
  while foundj < caseJ do begin
    if isJam then begin
      write(BigDecimalToStr(jamInBases[10]));
      for b := 2 to 10 do
        write(' ', BigDecimalToStr(primes[witness[b]]));
      writeln();
      inc(foundJ)
      {for b := 2 to 10 do
        write(' ', BigDecimalToStr(jamInBases[b]));
      writeln();}
    end;
   { for b := 2 to 10 do
        write(' ', BigDecimalToStr(jamInBases[b]));
      writeln();}

    i := 2;
    while (i < caseN) and jam[i] do inc(i);
    if i <> caseN then begin
      for j := 2 to i do jam[j] := false;
      jam[i] := true;
    end else break
  end;

end.

