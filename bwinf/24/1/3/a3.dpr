program a3;

uses windows,sysutils,utils in '..\common\utils.pas';

//Typen für die PBM-Dateien
type TPBM_raw=array of boolean;
     PPBM_raw=^TPBM_raw;

//Lädt eine PBM Datei
//  filename; enthält den Dateinamen
//  size: gibt die Größe der anderen Faxe an (beim ersten gilt size.cx=-1)
//        Bei unterschiedlichen Größen stoppt das Programm.
function loadPBM(const fileName:string; var size:TSize): TPBM_raw;
var loadedFile:file; //geladene Datei
    fileContent:string; //Inhalt der Datei
    i:integer; //Position im String (nachher im Ergebnis)
    imageSize:TSize; //Größe des Bildes in der Datei
    strEnd,strPos:pchar; //Zeiger auf die Positionen im String
begin
  //Datei mit standard IO-Funktionen laden
  AssignFile(loadedFile,fileName);
  reset(loadedFile,1);
  SetLength(fileContent,fileSize(loadedFile));
  BlockRead(loadedFile,fileContent[1],length(filecontent)); //jetzt ham wir se !
  CloseFile(loadedFile);
  
  //Ist es eine P1 Datei
  if copy(fileContent,1,2)<>'P1' then
    raise Exception('Error: no PBM file: '+fileName);
  //Größe?
  i:=3;
  imageSize.cx:=readNumber(fileContent,i);
  imageSize.cy:=readNumber(fileContent,i);
  if (size.cx<>-1) and ((size.cx<>imageSize.cx) or (size.cy<>imageSize.cy)) then
    raise Exception('Error: wrong size in: '+fileName);
  size:=imageSize;
  //Ergebnisarray entsprechend skalieren
  SetLength(result,size.cx*size.cy);
  ZeroMemory(result,size.cx*size.cy);
  //Pixel einlesen
  strEnd:=@fileContent[length(fileContent)]; //Letzter Pixel
  strPos:=@fileContent[i]; //Aktuelle Position im String
  i:=0; //Position im Ergebnisarray
  while (strPos<strEnd) and (i<length(Result))  do begin
    case strPos^ of//Zeichen lesen
      '0': inc(i); //0: Nächster Pixel in result (Zeromemory, s.o.)
      '1': begin
             Result[i]:=true; //Schwarzen Pixel speichern
             inc(i); //0: Nächster Pixel in result
           end;
    end;
    inc(strPos); //Nächstes Zeichen
  end;
end;

var i,j:integer; //Schleifenvariablen
    pbm_size:TSize; //Größe der PBM-Dateien
    pbm_data: array of TPBM_raw; //PBM-Dateien
    pbm_decode:array of cardinal; //Berechnete Folie; Anzahl der schwarzen Pixel
    output:textfile; //Ergebnisdatei
begin
  //Dateien laden
  pbm_size.cx:=-1;
  SetLength(pbm_data,ParamCount);
  for i:=1 to ParamCount do
    pbm_data[i-1]:=loadPBM(ParamStr(i),pbm_size);

  //Entschlüsseln
  //Anzahl aller schwarzen Bits an einer Stelle zählen
  SetLength(pbm_decode,pbm_size.cx*pbm_size.cy);
  ZeroMemory(pbm_decode,length(pbm_decode));
  for i:=0 to high(pbm_data) do
    for j:=0 to high(pbm_data[i]) do
      if pbm_data[i][j] then //schwarzer Pixel
          inc(pbm_decode[j]); //=> merken

  //Folie generieren
  for i:=0 to high(pbm_decode) do
    //Alle Pixel, die in mindesten der Hälfte aller Fälle schwarz sind, suchen
    pbm_decode[i]:=cardinal(pbm_decode[i]>cardinal(length(pbm_data)) div 2 );

  //Faxe entschlüsseln und abspeichern
  for i:=0 to high(pbm_data) do begin
    //Neue Datei erzeugen/überschreiben
    AssignFile(output,paramStr(i+1)+'_dec.pbm');
    Rewrite(output);
    writeln(output,'P1');
    writeln(output,inttostr(pbm_size.cx)+' '+inttostr(pbm_size.cy));
    for j:=0 to high(pbm_data[i]) do
      if pbm_data[i][j] = boolean(pbm_decode[j]) then //Folienpixel = Fax
        write(output,'0')
       else
        write(output,'1');
    CloseFile(output);
  end;
end.
