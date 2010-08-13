unit searching;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,calculation;

type
  //Folgensuchklasse

  { TSequenceSearcher }

  TSequenceSearcher=class
  private
    seqCount,seqLen: longint;//Anzahl und Länge der Folgen
    database: TFileStream;   //Folgenlexikon
    fileValueStart: longint; //Beginn des Folgenwerteblocks
    fileSuffixStart: longint;//Beginn des Suffixindexblocks
    fileInfoStart: longint;  //Beginn des Blocks mit den Positionen der Definition
    //Liefert die Startposition des Suffix i zurück
    function getSuffix(i: longint):longint;
    //Liefert die Werte des angegebenen Suffix zurück
    procedure getValues(i: longint; values: PSequenceValueBlock; len: longint=-1);
    //Vergleicht die Werte mit dem angegebenen Suffix
    function cmpSuffix(suffix:longint;v: array of intnumber):longint;
    //Sucht mit binärer Suche values im Suffixarray
    function findStartMatch(values: array of intnumber):longint;
  public
    //Benutzt die angegebene Datei als Folgenlexikon
    procedure loadFile(fn:string);
    //Sucht alle passenden Folgen, die values enthalten
    procedure findAll(values: array of intnumber; resultList: TFPList);
    //Versucht die Folge aus ihrer Differenzsumme zu erzeugen
    procedure extendedFindAll(values: array of intnumber; resultList: TFPList;
                              maxdeep:longint);
    //Lädt die entsprechende Folge und Folgendefinition aus der Datei
    function getSequenceInfo(id: longint):TSequenceInfo;
    destructor destroy;override;
    property count: longint read seqCount;
  end;




implementation




{ TSequenceSearcher }

//Lädt den Wert i des Suffixarrays aus der Datei
function TSequenceSearcher.getSuffix(i: longint): longint;
begin
  database.Seek(fileSuffixStart+i*sizeof(longint),soBeginning);
  result:=database.ReadDWord;
end;

//Liest die Werte der Folge i aus der Datei
procedure TSequenceSearcher.getValues(i: longint; values: PSequenceValueBlock;
  len: longint=-1);
begin
  database.Seek(fileValueStart+i*sizeof(intnumber),soBeginning);
  if len=-1 then len:=seqLen;
  database.ReadBuffer(values^[0],len*sizeof(intnumber));
end;

//Vergleich den Suffix mit den angegebenen Werten
function TSequenceSearcher.cmpSuffix(suffix: longint; v: array of intnumber): longint;
var k,svi,il,minl:longint;
    temp: array of intnumber;
begin
  svi:=getSuffix(suffix); //Suffixposition laden
  //Länge berechnen
  il:=seqLen-svi mod seqLen-1;
  if high(v)<=il then minl:=high(v)
  else minl:=il;

  //Werte laden
  setlength(temp,minl+1);
  getValues(svi,@temp[0],minl+1);

  //Werte vergleichen
  for k:=0 to minl do
    if temp[k]<>v[k] then
      if temp[k]>v[k] then exit(-1)
      else exit(1);
  //Überprüfen, ob die gespeicherte Folge zu kurz ist
  if minl<high(v) then exit(1)
  else exit(0);
end;

//Einfache binäre Suche nach values
function TSequenceSearcher.findStartMatch(values: array of intnumber): longint;
var l,r,p:longint;
begin
  l:=0;
  r:=seqLen*seqCount-1;
  while l<=r do begin
    p:=(l+r) div 2;
    case cmpSuffix(p,values) of
      0: exit(p);
      -1: r:=p-1;
      1: l:=p+1;
    end;
  end;
  exit(-1);
end;

//Lädt die entsprechende Folgendefinition
function TSequenceSearcher.getSequenceInfo(id: longint):TSequenceInfo;
begin
  //Speicher reservieren
  result:=TSequenceInfo.Create;
  result.len:=seqLen;
  result.id:=id;
  result.values:=GetMem(sizeof(intnumber)*seqLen);
  result.standAlone:=true;
  //Laden
  getValues(id*seqLen,result.values);
  database.Seek(fileInfoStart+id*sizeof(longint),soBeginning);
  database.Seek(database.ReadDWord,soBeginning);
  Result.readFromStream(database);
end;

//Freigeben
destructor TSequenceSearcher.destroy;
begin
  if database<>nil then database.free;
  inherited;
end;

//Sucht alle passenden Folgen, die values enthalten
procedure TSequenceSearcher.findAll(values: array of intnumber; resultList: TFPList);
  //Fügt die Folge, die das Suffix-id enthält zu resultList hinzu
  procedure add(id:longint);
  var pos,seqID,i:longint;
      seqInfo: TSequenceInfo;
  begin
    pos:=getSuffix(id);   //Suffixstartposition ermitteln
    seqID:=pos div seqLen;//Folgen-id ermitteln
    //Mit allen alten schon gefundenen vergleichen
    for i:=0 to resultList.count-1 do
      if TSequenceInfo(resultList[i]).id=seqID then begin
        if TSequenceInfo(resultList[i]).suffixStart=0 then
          TSequenceInfo(resultList[i]).suffixStart:=pos mod seqLen;
        exit;
      end;
    //hinzufügen
    seqInfo:=getSequenceInfo(seqID);
    //writeln('pos:',pos,'->',pos mod seqLen);
    seqInfo.suffixStart:=pos mod seqLen;
    resultList.Add(seqInfo);
  end;

var i,pos:longint;
begin
  //Ein passendes Suffix finden
  pos:=findStartMatch(values);
  if pos=-1 then
    exit;
  add(pos);
  //Nachbarn überprüfen
  for i:=pos+1 to seqCount*seqLen-1 do
    if cmpSuffix(i,values)<>0 then break
    else add(i);
  for i:=pos-1 downto 0 do
    if cmpSuffix(i,values)<>0 then break
    else add(i);
end;

procedure TSequenceSearcher.extendedFindAll(values: array of intnumber;
  resultList: TFPList; maxdeep:longint);
var diffValues: array of intnumber;  //Differenzfolge
    seq:TSequenceInfo;               //Gefundene Differenzfolge im Lexikon
    seqDef:TSequenceCreator;         //Definition der Folge
    number: TSequenceOperator;       //konstante Folge
    seqMove: TSequenceOperator;      //Folge zur Verschiebung der Elemente
    i,j:longint;
begin
  if (maxdeep<=0) then exit;
  findAll(values,resultList);
  if resultList.count>0 then exit;
  if (length(values)<=2) then exit;

  //Differenzsumme bilden
  SetLength(diffValues,length(values)-1);
  for i:=0 to high(diffValues) do
    diffValues[i]:=values[i+1]-values[i];

  //Suchen
  extendedFindAll(diffValues,resultList,maxdeep-1);
  if resultList.Count>0 then begin
    //Wenn gefunden, Definition der originalen Folge ermitteln
    for i:=0 to resultList.Count-1 do begin
      //Definition der Differenzfolge ermitteln und Folgenoperatoren bevorzugen
      seq:=TSequenceInfo(resultList[i]);
      if seq.sequenceOperator<>nil then begin
        seqDef:=seq.sequenceOperator;
        if seq.recursive<>nil then begin
          seq.recursive.freeChildren;
          seq.recursive.free;
        end;
      end else seqDef:=seq.recursive;
      seq.recursive:=nil;




      //Konstante Folge erzeugen, die zur Summe der Differenzfolge addiert werden
      //muss, um den Originalwert zu erhalten
      number:=TSequenceOperator.create;
      number.numberValue:=values[0];
      number.numberOnly:=true;

      //Summe der Differenzfolge bilden
      seq.sequenceOperator:=TSequenceOperator.create(sfunarySum,seqDef,nil);
      seq.sequenceOperator.values:=seq.values;
      seq.sequenceOperator.calculate(seqLen);
      if seq.suffixStart=0 then begin
        //Frühere Elemente sind nicht bekannt
        //Alle Elemente um eins nach rechts verschieben
        move(seq.values^[0],seq.values^[1],(seqLen-1)*sizeof(intnumber));
        seq.values^[0]:=0;
        //Nach rechts verschiebende Folgendefinition erzeugen
        seqDef.refcount+=1;
        seqMove:=TSequenceOperator.create(sfbinarySub,number,seqDef);
      end else begin
        //Frühere Elemente sind bekannt
        //Wert der zur Summe addiert werden muss, um die Originalfolge zu kriegen
        number.numberValue-=seq.values^[seq.suffixStart-1];
        seqMove:=number;
        seq.suffixStart-=1; //Folge beginnt am vorherigen Element
      end;

      //Wert addieren, um die Originalfolge zu erhalten
      for j:=0 to seqLen-1 do
        try
          if seq.values^[j] = INT_NAN then break;
          seq.values^[j]+=number.numberValue;
        except
          seq.values^[j]:=INT_NAN;
          break;
        end;

      //Definition erweitern
      seq.sequenceOperator:=TSequenceOperator.create(
                              sfbinaryAdd,
                              seq.sequenceOperator,
                              seqMove
                            );
      seq.sequenceOperator.values:=seq.values;
    end;

  end;

end;




//Folgenlexikon laden
procedure TSequenceSearcher.loadFile(fn: string);
begin
  if database<>nil then database.Free;
  database:=TFileStream.Create(fn,fmOpenRead);
  //Header laden
  if database.ReadDWord<>1 then raise Exception.Create('Ungültige Version');
  if database.ReadDWord<>20 then raise Exception.Create('Ungültiger Header');
  if database.ReadDWord<>sizeof(intnumber) then raise Exception.Create('Ungültige Zahlengröße');
  seqLen:=database.ReadDWord;
  seqCount:=database.ReadDWord;
  //Positionen initialisieren
  fileValueStart:=20;
  fileSuffixStart:=fileValueStart+seqLen*seqCount*sizeof(intnumber);
  fileInfoStart:=fileSuffixStart+seqLen*seqCount*sizeof(longint);
  writeln(seqCount,' Folgen mit ',seqLen,' Elementen' );
end;

end.

