program bgen;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes  , math
  { you can add units after this };


var
  i: Integer;
begin
  writeln(100);
  for i := 1 to 100 do
    writeln(Random(1000000000),' ',Random(1000000000),' ',Random(1000000000));
end.

