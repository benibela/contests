unit generating;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,calculation;

type
  //Knoten des Folgenbaumes
  PTreeNode=^TTreeNode;
  TTreeNode=record
    s: longint;      //Sequenzsuffixindex
    l,r: PTreeNode;  //Kindbäume
  end;

  { TSequenceGenerator }

  //Folgengenerator
  TSequenceGenerator=class
  private
    seqCount,seqLen: longint; //Anzahl und Länge der Folgen
    seqMaxCount: longint;     //Maximale Folgenanzahl
    seqTree: PTreeNode;       //Suchbaum aller Folgen
    seqInformation: array of TSequenceInfo; //Liste aller Folgendefinitionen
    seqValues: array of intnumber; //Alle Folgenwerte
    suffixs: array of longint;     //Startindizes aller Folgensuffixe
    progress:longint;         //Letzter ausgegebener Fortschritt
    sortLen:longint;          //bereits sortierter Suffixbereich

    //Gibt eine Fortschrittsanzeige aus
    procedure writeSequenceProgress;

    //Vergleicht zwei Folgensuffixe
    function cmpSuffix(i,j:longint;ignoreNan: boolean=false):longint;
    function cmpSuffixIgnoreLen(i, j: longint): longint;

    //Fügt eine Folge ein und sucht alte
    function treeInsert(var node: PTreeNode;out insertedAt: PTreeNode):boolean;
    function treeFind(node: PTreeNode;seq:longint):boolean;

    //Sortiert alle Suffixfolgen
    procedure sortSuffix(f,t: longint);

    //Gibt Speicher für die aktuelle Folge zurück
    function currentSequence: PSequenceValueBlock;inline;
    //Speichert die Folgendefinition node und die dadurch definierte Folge
    function addCreationInfo(node: TSequenceCreator):boolean;


  public
    //Erzeugt ein Objekt und reserviert den gesamten benötigten Speicher
    constructor create(maxCount,len:longint);
    //Erzeugt Folgen mit der jeweiligen Methode, bis es insgesamt aimcount viele gibt.
    procedure generateWithRecursion(aimcount:longint);
    procedure generateWithSequenceOperators(aimcount:longint);
    procedure close;                  //Schließt den Erstellungsvorgang ab
    procedure saveToFile(fn:string);  //Speichert die Folgen
    destructor destroy;override;
  end;

implementation

{ TSequenceGenerator }

//Fortschrittanzeige jeweils nach 5% aller Folgen
procedure TSequenceGenerator.writeSequenceProgress;
begin
  if 20*(seqCount - progress)>=seqMaxCount then begin
    writeln(seqCount,'/',seqMaxCount);
    progress:=seqCount;
  end;
end;

//Vergleicht zwei Folgensuffixe
function TSequenceGenerator.cmpSuffix(i, j: longint;ignoreNan: boolean=false): longint;
var k,il,jl,minl:longint;
begin
  //Länge ermitteln
  il:=seqLen-i mod seqLen-1;
  jl:=seqLen-j mod seqLen-1;
  if il>jl then begin
    result:=-1;
    minl:=jl;
  end else if il<jl then begin
    result:=1;
    minl:=il;
  end else begin
    result:=0;
    minl:=il;
  end;
  //Vergleichen
  if (seqValues[i]=INT_NAN) and (seqValues[i]=seqValues[j]) then exit();
  for k:=0 to minl do
    if seqValues[k+i]<>seqValues[k+j] then
      if ignoreNan and ((seqValues[k+i]=INT_NAN) or (seqValues[k+j]=INT_NAN)) then
        exit(0)
      else if seqValues[k+i]>seqValues[k+j] then exit(-1)
      else exit(1);
end;




//Vergleicht zwei Folgensuffixe und ignoriert die Länge
function TSequenceGenerator.cmpSuffixIgnoreLen(i, j: longint): longint;
var k,il,jl,minl:longint; //Schleifenvariable, Längen, minimale Länge
begin
  if (seqValues[i]=INT_NAN) and (seqValues[i]=seqValues[j]) then exit(0);
  //Länge ermitteln
  il:=seqLen-i mod seqLen-1;
  jl:=seqLen-j mod seqLen-1;
  if il>jl then  minl:=jl
  else minl:=il;
  result:=0;
  //Vergleichen
  for k:=0 to minl do
    if seqValues[k+i]<>seqValues[k+j] then
      if (seqValues[k+i]=INT_NAN) or (seqValues[k+j]=INT_NAN) then exit(0)
      else if seqValues[k+i]>seqValues[k+j] then exit(-1)
      else exit(1);
end;

//Sucht den Suffix seq im Baum
function TSequenceGenerator.treeFind(node: PTreeNode; seq: longint): boolean;
begin
  if node = nil then exit(false); //Baum zu Ende
  case cmpSuffixIgnoreLen(node^.s+1,seq+1) of //Knoten vergleichen
    0: exit(true); //Gefunden
    -1: exit(treeFind(node^.r,seq)); //passendes Kind vergleichen
    1: exit(treeFind(node^.l,seq));  //  "       "     "
  end;
end;

//Aktuelle Folge einfügen
function TSequenceGenerator.treeInsert(var node: PTreeNode;
                                   out insertedAt: PTreeNode):boolean;
begin
  if node=nil then begin
    //Baum zu Ende, neues Blatt einfügen
    new(node);
    FillChar(node^,sizeof(node^),0);
    node^.s:=seqLen*seqCount;
    insertedAt:=node;
    exit(true); //eingefügt
  end else
    case cmpSuffix(node^.s+1,seqLen*seqCount+1,true) of //Knoten vergleichen
      0: begin
        //Sind auch die Anfangswerte gleich?
        if (seqValues[node^.s]=seqValues[seqLen*seqCount]) and
           (seqValues[node^.s+1]=seqValues[seqLen*seqCount+1]) then
          insertedAt:=node //Knoten zurückgeben
         else
          insertedAt:=nil; //Nicht   "
        exit(false); //nicht eingefügt
      end;
      -1: exit(treeInsert(node^.r,insertedAt));
      1: exit(treeInsert(node^.l,insertedAt));
    end;
end;

//Alle Teilfolgen zwischen f und t per Quicksort sortieren
procedure TSequenceGenerator.sortSuffix(f, t: longint);
var pivot,temp: longint;
    i,j:longint;
begin
  if f>=t then exit;
  //Pivotelement wählen
  pivot:=suffixs[(f+t) div 2];
  //In kleinere und größere Suffixe zerlegen
  i:=f-1;
  j:=t+1;
  while true do begin
    repeat i+=1; until cmpSuffix(pivot,suffixs[i])>=0;
    repeat j-=1; until cmpSuffix(pivot,suffixs[j])<=0;
    if i<j then begin
      temp:=suffixs[i];
      suffixs[i]:=suffixs[j];
      suffixs[j]:=temp;
    end else break;
  end;
  //Teilbereiche sortieren
  sortSuffix(f,j);
  sortSuffix(j+1,t);
  //Fortschritt nach allen um 5% sortierten Bereichsänderungen ausgeben
  if (f<=sortLen+1) and (t>sortLen) then begin
    sortLen:=t;
    if (20*(t-progress)>=seqLen*seqCount) then begin
      progress:=t;
      writeln(t,'/',seqLen*seqCount);
    end;
  end;
end;

//Speicher reservieren
constructor TSequenceGenerator.create(maxCount,len:longint);
begin
  seqMaxCount:=maxCount;
  seqLen:=len;
  SetLength(seqValues,seqMaxCount*seqLen);
  SetLength(suffixs,seqMaxCount*seqLen);
  SetLength(seqInformation,seqMaxCount);
end;

//Gibt Speicher für die aktuelle Folge zurück
function TSequenceGenerator.currentSequence: PSequenceValueBlock;inline;
begin
  result:=@seqValues[seqLen*seqCount];
end;

//Speichert die Folgendefinition node und die dadurch definierte Folge
function TSequenceGenerator.addCreationInfo(node: TSequenceCreator): boolean;
var seqNode: PTreeNode;
begin
  //Korrektheit überprüfen
  if (seqCount>=seqMaxCount) then exit(false);
  if node.realLen<MIN_SEQ_LEN then exit(false);
  //Leicht verschobene Folge suchen
  if treeFind(seqTree,seqCount*seqLen+1) or
     treeFind(seqTree,seqCount*seqLen-1) then exit(false);
  //Folge selbst suchen bzw. einfügen
  if (not treeInsert(seqTree,seqNode)) then begin
    if seqNode=nil then exit(false); //Praktisch identische Folge existiert
    //Erstellungsinformationen hinzufügen
    with seqInformation[seqNode^.s div seqLen] do begin
      if node is TSequenceOperator then begin
        result:=sequenceOperator=nil;
        if result then sequenceOperator:=TSequenceOperator(node)
      end else if node is TRecursiveExpression then begin
        result:=recursive = nil;
        if result then recursive:=TRecursiveExpression(node)
      end else raise Exception.Create('Ungültiger Erzeuger');
    end;
    exit(true);
  end;
  //Erstellungsinformationen  neu hinzufügen
  seqInformation[seqCount]:=TSequenceInfo.create;
  seqInformation[seqCount].len:=seqLen;
  seqInformation[seqCount].values:=@seqValues[seqCount*seqLen];
  with seqInformation[seqCount] do
    if node is TSequenceOperator then sequenceOperator:=TSequenceOperator(node)
    else if node is TRecursiveExpression then recursive:=TRecursiveExpression(node)
    else raise Exception.Create('Ungültiger Erzeuger');
  seqCount+=1;
  result:=true;
end;

//Erzeugt rekursiv definierte Folgen, bis es insgesamt aimcount viele gibt.
procedure TSequenceGenerator.generateWithRecursion(aimcount:longint);
var mnode: TMathExpressionNode; //Aktueller Syntaxbaumknoten
    mnodeList: TFPList;         //Liste aller bisherigen rekursiven Ausdrücke
    recex: TRecursiveExpression;//Folgendefinition mit Startwerten und Rekursion
    
  //Fügt, wenn sinnvoll, Folgen ein, die durch die Anwendung des Operators auf
  //die Knoten a und b enstehen
  procedure addSequences(typ: TMathFunction;a,b:TMathExpressionNode);
  var i,j: longint;
      added: boolean;
  begin
    //Überprüft die Sinnmäßigkeit dieser Definition
    case typ of
      mfbinarySub: if a=b then exit;     //ergäbe nur 0
      mfbinaryMul: begin
        if a.seqRealLen<seqLen then exit;//ergäbe wahrscheinlich zu kurze Folgen
        if b.seqRealLen<seqLen then exit;
      end;
    end;
    added:=false;
    //4 Anfangswerte durchprobieren
    for i:=0 to 3 do
      for j:=0 to 3 do begin
        if seqCount>=aimcount then exit;//Abbruch bei zu vielen Folgen
        if not mnode.make(typ,a,b) then exit; //Weitere Überprüfungen
        if (mnode.initSize=1) then
          if (i<>j) then break;         //Es zählt nur ein Anfangswert
        //Einfügen der Werte und der Definition in rnode
        recex.expr:=mnode;
        recex.values:=currentSequence; //aktueller Speicherplatz für eine Folge
        recex.valueStart[0]:=i;
        recex.valueStart[1]:=j;
        //Folge berechnen
        recex.calculate(seqLen);
        //Einfügen der Folge
        if addCreationInfo(recex) then begin
          mnode.seqRealLen:=recex.realLen;
          if not added then begin
            added:=true;
            //Bei einer neuen Folge ist auch der rekursive Ausdruck neu
            //Also in mnodeList speichern und neuen Speicher reservieren
            mnodeList.add(mnode);
            //mnode.make(typ,a,b);
          end;
          mnode:=TMathExpressionNode.create;
          recex:=TRecursiveExpression.create; //Neuen Speicher reservieren
        end;
      end;
  end;
  
var i,j,                             //Schleifenvariable
    lastCount,nextLastCount:longint; //Anzahl an rekursiven Definitionen
    mbase: TMathFunction;            //Operatortyp
begin
  //Basiswerte in mnodeList speichern
  mnodeList:=TFPList.create;
  mnodeList.Capacity:=aimcount;
  for mbase:=mfbase1 to mfbasePre2 do
    mnodeList.Add(TMathExpressionNode.Create(mbase));
  //Speicher reservieren
  mnode:=TMathExpressionNode.create();
  recex:=TRecursiveExpression.Create;
  //Solange wiederholen, wie neue rekursive Definitionen entstehen (bzw. Abbruch)
  lastCount:=0;
  while lastCount<>mnodeList.Count do begin
    nextLastCount:=mnodeList.count;
    for mbase:=mfbinaryAdd to mfbinaryMul do //Alle Operatoren durchlaufen
      for i:=lastCount to nextLastCount-1 do //Alle neuen Definition durchlaufen
        for j:=0 to i do begin               //Alle älteren
          //Neue Sequenz mit den ausgewählten Werten erzeugen
          addSequences(mbase,TMathExpressionNode(mnodeList[i]),
                             TMathExpressionNode(mnodeList[j]));
          //Fortschritt ausgeben
          writeSequenceProgress;
          //Abbruch, wenn genügend Folgen vorhanden sind
          if seqCount>=aimcount then begin
            recex.free;
            mnode.free;
            exit;
          end;
        end;
    lastCount:=nextLastCount;
  end;
end;

//Erzeugt Folgen durch Folgenoperatoren, bis es insgesamt aimcount viele gibt.
procedure TSequenceGenerator.generateWithSequenceOperators(aimcount:longint);
var snode: TSequenceOperator; //Aktueller Baum von Folgenoperationen
  //Fügt eine Folgenoperation neu hinzu
  procedure addSNode(typ: TSeqFunction;i,j:longint);
  var soa,sob: TSequenceOperator; //Konvertierte Teilausrücke (falls möglich)
  begin
    if seqCount>=aimcount then exit;
    //Umwandlung der Teilausdrücke in TSequenceOperator, wenn möglich
    snode.typ:=typ;
    soa:=seqInformation[i].sequenceOperator;
    if soa<>nil then begin
      if soa.numberValue=0 then exit;
      snode.a:=soa;
    end else snode.a:=seqInformation[i].recursive;
    if j=-1 then sob:=nil
    else begin
      sob:=seqInformation[j].sequenceOperator;
      if sob<>nil then snode.b:=sob
      else snode.b:=seqInformation[j].recursive;
    end;
    //Überprüfung, auf Nützlichkeit
    snode.update;
    if (soa<>nil) and (sob<>nil) then
      case typ of
        sfbinaryAdd:
          if soa.typ=sfunarySum then begin
            if sob.typ=sfunarySum then exit; //Keine Summen addieren
            if (soa.a is TSequenceOperator) and
               TSequenceOperator(soa.a).numberOnly and sob.numberOnly then
              exit;//Nur Index Verschiebung
          end else if sob.typ=sfunarySum then
            if (sob.a is TSequenceOperator) and
               TSequenceOperator(sob.a).numberOnly and soa.numberOnly then
              exit;//Nur Index Verschiebung
        sfbinarySub: begin
          if i=j then exit; //=>0
          if soa.typ=sfunarySum then begin
            if sob.typ=sfunarySum then exit; //Keine Summen subtrahieren
            if (soa.a is TSequenceOperator) and
               TSequenceOperator(soa.a).numberOnly and sob.numberOnly then exit;
          end else if sob.typ=sfunarySum then
            if (sob.a is TSequenceOperator) and
               TSequenceOperator(sob.a).numberOnly and soa.numberOnly then
              exit;//Nur Index Verschiebung
        end;
        sfbinaryMul: begin
          if soa.typ=sfUnaryMul then begin
            if sob.typ=sfUnaryMul then exit; //Keine Produkte multiplizieren
            if (soa.a is TSequenceOperator) and
               TSequenceOperator(soa.a).numberOnly and sob.numberOnly then exit;
          end else if sob.typ=sfUnaryMul then
            if (sob.a is TSequenceOperator) and
               TSequenceOperator(sob.a).numberOnly and soa.numberOnly then
              exit;//Nur Index Verschiebung
        end;
        sfbinaryPower: if sob.realLen<seqLen then exit; //=>wahrscheinlich Überlauf
      end;
    //Hinzufügen
    snode.values:=currentSequence;
    snode.calculate(seqLen);
    if addCreationInfo(snode) then
      snode:=TSequenceOperator.create;
  end;

var i,j,                             //Schleifenvariable
    lastCount,nextLastCount:longint; //Anzahl an Folgen
    sbase: TSeqFunction;             //Operatortyp
begin
  //Basisausdrücke einfügen, wenn noch nicht vorhanden
  if seqCount=0 then begin
    for sbase:=sfbase1 to sfbase5 do begin
      snode:=TSequenceOperator.create;
      snode.typ:=sbase;
      snode.values:=currentSequence;
      snode.update;
      snode.calculate(seqLen);
      addCreationInfo(snode);
    end;
    //Null einfügen
    snode:=TSequenceOperator.create(sfbinarySub,
                                    seqInformation[0].sequenceOperator,
                                    seqInformation[0].sequenceOperator);
    snode.values:=currentSequence;
    snode.calculate(seqLen);
    addCreationInfo(snode);
  end;
  snode:=TSequenceOperator.create; //Speicher reservieren
  lastCount:=0;
  //Solange neue Folgen entstanden sind, oder abgebrochen wird
  while lastCount<>seqCount do begin
    nextLastCount:=seqCount;
    //Alle unären Operatoren auf alle neuen Folgen anwenden
    for i:=lastCount to nextLastCount-1 do
      for sbase:=sfunarySum to sfUnaryMul do begin
        if seqCount>=aimcount then begin
          snode.free;
          exit;
        end;
        addSNode(sbase,i,-1);
        writeSequenceProgress;
      end;
    //Alle binären Operatoren auf alle Folgenpaare mit einer neuer Folge anwenden
    for i:=lastCount to nextLastCount-1 do
      for j:=0 to i do
        for sbase:=sfbinaryAdd to sfbinaryPower do begin
          if seqCount>=aimcount then begin
            snode.free;
            exit;
          end;
          addSNode(sbase,i,j);
          if sbase in [sfbinaryPower,sfbinarySub] then
            addSNode(sbase,j,i);
          writeSequenceProgress;
        end;
    lastCount:=nextLastCount;
  end;
  snode.free;
end;



//Erstellungsvorgang abschließen, also Suffixe sortieren
procedure TSequenceGenerator.close;
var i:longint;
begin
  //writeln('suflen: ',length(suffixs));
  assert(seqCount=seqMaxCount,'Zu viele oder zu wenige Folgen erzeugt');
  for i:=0 to high(seqValues) do
    suffixs[i]:=i;
  progress:=0;
  sortLen:=0;
  sortSuffix(0,high(suffixs));
end;







//Speichert die Folgen, die Suffixe und die Definitionen
procedure TSequenceGenerator.saveToFile(fn: string);
var fs: TFileStream;
    temp: TMemoryStream;
    p: int64;
    i:longint;
begin
  fs:=TFileStream.Create(fn,fmCreate);
  //Header
  fs.WriteDWord(1); //Version
  fs.WriteDWord(20); //Headergröße
  fs.WriteDWord(sizeof(intnumber));
  fs.WriteDWord(seqLen);
  fs.WriteDWord(seqCount);
  //Folgenwerte
  fs.WriteBuffer(seqValues[0],sizeof(seqValues[0])*Length(seqValues));
  //Suffixstartindizes
  fs.WriteBuffer(suffixs[0],sizeof(suffixs[0])*Length(seqValues));
  //Startposition der Definitionen in fs und Definitionen selber in temp
  p:=fs.Position+seqCount*4;
  temp:=TMemoryStream.create;
  for i:=0 to seqCount-1 do begin
    fs.WriteDWord(dword(p));
    //seqInformation[i].print(omNormal);
    p+=seqInformation[i].writeToStream(temp);
  end;
  //Definitionen in fs schreiben
  fs.WriteBuffer(temp.Memory[0],dword(temp.GetSize));

  temp.free;
  fs.free;
end;

destructor TSequenceGenerator.destroy;
  procedure deleteTree(node:ptreeNODE);
  begin
    if node=nil then exit;
    deleteTree(node^.l);
    deleteTree(node^.r);
    dispose(node);
  end;
begin
  deleteTree(seqTree);
  inherited;
end;

end.

