program sequences;

{$mode objfpc}{$H+}

uses
  Classes, sysutils,
  calculation,  generating, searching,math;

var outputMode: TOutputMode=omNormal;

//Ruft die Erzeugung eines Folgenlexikons auf
procedure generate(count,len:longint);
var seqGen:TSequenceGenerator;
begin
  WriteLn('Berechne ',count,' Folgen der Länge ',len);;
  seqGen:=TSequenceGenerator.create(count,len);
  seqGen.generateWithSequenceOperators(max(100,count div 50));
  seqGen.generateWithRecursion(2*(count div 25));
  seqGen.generateWithSequenceOperators(count);
  writeln('Sortiere alle Suffixfolgen');
  seqGen.close;
  seqGen.saveToFile('sequences.dat');
  seqGen.Free;
  writeln('Abgeschlossen');
end;







//Ruft die Suche nach einer Folge  auf
procedure find(firstParam: longint;ex:boolean);
var seq: array of intnumber;
    seqSearcher: TSequenceSearcher;
    i:longint;
    found:TFPList;
begin
  //Laden
  seqSearcher:=TSequenceSearcher.Create;
  seqSearcher.loadFile('sequences.dat');
  //Werte ins Array
  setlength(seq,Paramcount-firstParam+1);
  for i:=firstParam to Paramcount do
    seq[i-firstParam]:=StrToInt(ParamStr(i));
  //Suchen
  found:=TFPList.Create;
  if ex then seqSearcher.extendedFindAll(seq,found,5)
  else seqSearcher.findAll(seq,found);
  //Ausgeben
  if found.count = 0 then
    writeln('Keine passende Folge gefunden');
  for i:=0 to found.Count-1 do begin
    TSequenceInfo(found[i]).print(outputMode);
    TSequenceInfo(found[i]).free;
    writeln;
  end;
  found.free;
  seqSearcher.free;
end;

//Anzeigen aller Folgen
procedure viewAll();
var i:longint;
    seqSearcher: TSequenceSearcher;
begin
  seqSearcher:=TSequenceSearcher.Create;
  seqSearcher.loadFile('sequences.dat');
  for i:=0 to seqSearcher.count-1 do
    with seqSearcher.getSequenceInfo(i) do begin
      print(outputMode);
      free;
    end;
  seqSearcher.Free;
end;








//Hauptprogramm
begin
  //Ausgabeart erkennen
  if ParamStr(1)='--output-normal' then outputMode:=omNormal
  else if ParamStr(1)='--output-derive' then outputMode:=omDerive
  else if ParamStr(1)='--output-latex' then outputMode:=omLatex;
  
  //Aufgabe erkennen
  if ParamStr(1)='--generate' then
    generate(StrToIntDef(ParamStr(2),1000),StrToIntDef(ParamStr(3),50))
  else if ParamStr(1)='--find' then find(2,false)
  else if ParamStr(2)='--find' then find(3,false)
  else if ParamStr(1)='--extended-find' then find(2,true)
  else if ParamStr(2)='--extended-find' then find(3,true)
  else if (ParamStr(1)='--view') or (ParamStr(2)='--view') then viewAll()
  else writeln('Unbekannter Parameter. Benutze --generate, --find oder --view');
end.

