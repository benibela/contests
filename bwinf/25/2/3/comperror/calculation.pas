unit calculation;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils; 

  { TSequence }
type intnumber=int64; //Ermöglicht einfache Umstellung auf andere Wertbereiche
  TSequence=class
    values:array of intnumber;
    constructor create;
    procedure print;
  end;


implementation
const SEQ_LEN=100;    //Zahl der zu berechnenden Folgenwerte
      TREE_DEEP=10;

{ TSequence }

constructor TSequence.create;
begin
  setlength(values,SEQ_LEN);
end;

procedure TSequence.print;
var i:longint;
begin
  for i:=0 to high(values)-1 do
    write(values[i],',');
  writeln(values[high(values)]);
  //readln;
end;
end.

