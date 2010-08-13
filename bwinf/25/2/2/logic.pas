unit logic;

{$mode objfpc}{$H+}
//{$define debug}
interface

uses
  Classes, SysUtils,windows;
type
  trilean=(triUnset, tri0, tri1); //wie boolean für ein Feld
const
  TRI_NOT:array[trilean] of trilean=(triUnset,tri1,tri0); //not-Operator
type
  { TBidoku }
  //Speichert das Ergebnis einer Lösungssuche
  TSolveResult=record
    solved: boolean;       //Wurde es gelöst
    solutioncount: longint;//Zahl der Lösungen
    solutions:TFPList;     //Alle Lösungen, nil, wenn nur eine gesucht wurde
  end;
  PSolveResult=^tsolveResult;

  //Ist das Bidoku unvollständig, gelöst oder fehlerhaft?
  TSolveStatus=(ssPartly,ssSolved,ssWrong);
  //Die Art wie ein Feld belegt wurde
  TSolutionMethod=(smUnknown,smUser, //unbekannt; vom Benutzer;
                   smFixed,          //gar nicht, sondern vorgegeben;
                   smBacktracking1,  //durch Raten, es gibt nur eine Möglichkeit
                   smBacktracking2,  //durch Raten, es gibt zwei Möglichkeiten
                   smLogicTrivial,   //durch vervollständigen einer Reihe/Quadrat
                   smLogicCombined); //Durch den Schnitt einer Reihe mit Quadrat

const
  //Lösungen durch Raten
  BACKTRACKING_SOLUTION=[smBacktracking1,smBacktracking2];
  //Logische Lösung
  LOGICAL_SOLUTION=[smLogicTrivial,smLogicCombined];
  //Eindeutige Lösung
  UNIQUE_SOLUTION=[smBacktracking1,smLogicTrivial,smLogicCombined];
  //Eindeutiges Feld (eindeutig gelöst, oder vorgegeben)
  UNIQUE_FIELD=UNIQUE_SOLUTION + [smFixed];
type
  TDifficulty=(dEasy,dNormal,dHard); //Schwierigkeitsgrad
  
  //Liste von Feldern, die eine Gruppe bilden
  TPositionGroup=array of record
    u,v: longint;    //Feldkoordinate
    negate: boolean; //Feldwert ist der umgekehrte Basiswert
  end;
  TPositionsArray=array of TPositionGroup;

  TBidoku=class
  private
    changed: boolean;  //wird bei Änderungen auf true gesetzt
    n,maxcount:longint;//Größe des Bidokus und Anzahl der Felder einer Zahl
    time:longint;      //Wird bei jedem put-Aufruf inkrementiert
    
    //Bidokufeld
    data:array of array of trilean;
    //Anzahl der gefüllten Felder pro Reihe und Zahl
    rows,cols:array of array[trilean] of longint;
    //Anzahl der gefüllten Felder pro Quadrat und Zahl
    quadrates: array of array of array[trilean] of longint;
    //Lösungsmethode für ein Feld
    solutionMethod: array of array of TSolutionMethod;
    //Zeiten, wann das Feld belegt wurde
    putTimes: array of array of longint;

    //Löst das Rätsel und gibt die Anzahl der gefundenen Lösungen zurück
    //allSolutions: sollen alle Lösungen gefunden werden
    //deep: Rekursionstiefe
    //solutions: Speichert die Lösungen (kann nil sein)
    //Ist allSolutions=false, wird die Lösung im Bidoku selbst gespeichert
    function _solve(allSolutions: boolean;deep:longint;solutions:TFPList):longint;

    //Setzt das Feld x,y auf den Wert c und speichert dafür die Lösungsmethode
    //rows,cols und fields werden auch entsprechend angepasst
    procedure put(x,y:longint; c: trilean; method: TSolutionMethod);
    //Setzt nur leere Felder
    procedure tryput(x,y:longint; c: trilean; method: TSolutionMethod);inline;
  public
    //Wie oben, nur gilt hier immer method=smUser
    procedure put(x,y:longint; c: trilean);inline;
    procedure tryput(x,y:longint; c: trilean);inline;
    //Übernimmt ein Feld von einem anderen Bidoku
    procedure copyField(x,y:longint; bidoku: TBidoku);
    //Gibt den Wert eines Feldes zurück
    function get(x,y:longint): trilean;inline;
    //Gibt die Lösungsmethode für ein Feld zurück
    function getSolutionMethod(x,y:longint):TSolutionMethod;inline;
    //Gibt den Lösungszeitpunkt für ein Feld zurück
    function getSolutionTime(x,y:longint):longint;inline;

    //Erzeugt leers ein Bidoku. asize ist die Zahl der Quadrate pro Reihe
    //und die Zahl der Felder in einer Reihe eines Quadrates
    constructor create(asize:longint=4);
    procedure updateSize();
    destructor destroy();override; //Löscht das Bidoku
    function clone(): TBidoku;     //Kopiert das Bidoku
    //Berechnet ein Bidoku mit bestimmter Schwierigkeit und Muster
    procedure generate(difficulty: TDifficulty;
                       positions: TPositionsArray);
    //Erzeugt ein Bidoku das einen Text repräsentiert
    procedure generateEncryption(s:string);
    //Minimiert das Bidoku
    procedure minimize;

    //Findet den Text heraus, der in dem Bidoku verborgen ist
    function decode():string;

    //Liefert eine Zahl, die die Schwierigkeit angibt, zurück
    function rateDifficulty: longint;
    //Zählt Symmetriefehler
    function symmetricErrors(const pos:TPositionsArray):longint;

    //Lösung mittels einfacher logischer Regeln
    procedure logicalSolve();
    //Löst das Bidoku vollständig
    function solve(allSolutions,list: boolean):TSolveResult;
    //Überprüft, ob es eine Lösung gibt, indem das Rätsel geklont und gelöst wird
    function isSolvable():boolean;
    //Gibt den Lösungsstatus (noch nicht, gelöst, fehlerhaft) zurück
    function solved(): TSolveStatus;

    function toString():string;         //Wandelt das Bidoku in einen String um
    procedure saveToFile(fn: string);   //Speichert es
    procedure loadFromFile(fn: string); //Lädt es
    
    //Erzeugt eine horizontale/vertikale Spiegelung um die Bidokumitte
    function makeMirrorSymmetryH(invert: boolean):TPositionsArray;
    function makeMirrorSymmetryV(invert: boolean):TPositionsArray;
    //Erzeugt eine horizontale/vertikale Spiegelung um die Mitte der einen und
    //der anderen Hälft des Bidokus
    function makeMirrorSymmetrySubH(invert: boolean):TPositionsArray;
    function makeMirrorSymmetrySubV(invert: boolean):TPositionsArray;
    //Verbindet zwei Symmetrien
    function mergeSymmetry(a,b:TPositionsArray):TPositionsArray;
    
    property size: longint read n;
  end;

  { TBidoku }
const MAX_SOLUTIONS=10000; //Maximale Anzahl von Lösungen
implementation

{ TBidoku }

//Liefert eine Zahl, die die Schwierigkeit angibt, zurück
function TBidoku.rateDifficulty: longint;
var i,j:longint;
begin
  result:=0;
  for i:=0 to high(data) do
    for j:=0 to high(data[i]) do
      case solutionMethod[i,j] of
        smUnknown,smUser: raise exception.create('Fehler');
        smBacktracking1: result+=50;
        smLogicCombined: result+=5;
        smLogicTrivial: result+=1;
      end;
end;

//Zählt Symmetriefehler
function TBidoku.symmetricErrors(const pos:TPositionsArray):longint;
var i,j,k:longint;
begin
  if not assigned(pos) then result:=0;
  result:=0;
  for i:=0 to high(pos) do
    for j:=0 to high(pos[i]) do
      for k:=0 to high(pos[i]) do
        if (data[pos[i,j].u,pos[i,j].v]<>data[pos[i,k].u,pos[i,k].v]) xor
           (pos[i,j].negate xor pos[i,k].negate) then
            result+=1;

end;

//Löst das Rätsel und gibt die Anzahl der gefundenen Lösungen zurück
//allSolutions: sollen alle Lösungen gefunden werden
//deep: Rekursionstiefe
//solutions: Speichert die Lösungen (kann nil sein)
//Ist allSolutions=false, wird die Lösung im Bidoku selbst gespeichert
function TBidoku._solve(allSolutions: boolean;deep:longint;
                        solutions: TFPList):longint;
var i,k,l,maxR,maxC: longint;
    temp:TBidoku;
    newSolutions,oldCount: longint;
    tri,triUsed: trilean;
begin
  result:=0;
  //OutputDebugString(pchar(toString()));

  //Logisches Lösen
  logicalSolve;
  //Test auf korrekte Lösung
  case solved() of
    ssWrong: exit(0);
    ssSolved: begin
      if assigned(solutions) then
        solutions.Add(self);
      exit(1);
    end;
  end;
  //Abbruch bei zu vielen Lösungen
  if (solutions<>nil)and (solutions.Count>=MAX_SOLUTIONS)and allSolutions then
    exit;
  //Rest per BF Lösung
  //Auswahl eines Feldes mit maximaler Füllungsdichte
  maxR:=-1;
  for i:=0 to high(rows) do
    if (rows[i][tri0]+rows[i][tri1]<2*maxcount)and ((maxR=-1) or
       (rows[i][tri0]+rows[i][tri1]+deep and 1>
                                        rows[maxR][tri0]+rows[maxR][tri1])) then
      maxR:=i;
  assert(maxR>-1,'Keine Zeile vorhanden');

  maxC:=-1;
  for i:=0 to high(data) do
    if (data[i,maxR]=triUnset) and ((maxC=-1) or
          (cols[i][tri0]+cols[i][tri1]+(deep and 2)shr 1>
                                       cols[maxC][tri0]+cols[maxC][tri1])) then
      maxC:=i;

  assert(maxC>-1,'Keine Spalte vorhanden');

  if allSolutions and assigned(solutions) then
    oldCount:=solutions.Count;
  for tri:=tri0 to tri1 do begin
    temp:=clone();
    //smBacktracking1 wird im zweiten Durchlauf verwendet, wenn der andere Wert
    //unmöglich ist
    if deep and 4=0 then triUsed:=tri
    else triUsed:=TRI_NOT[tri];
    if (tri=tri1) and (result=0) then
      temp.put(maxC,maxR,triUsed,smBacktracking1)
     else
      temp.put(maxC,maxR,triUsed,smBacktracking2);
    //Rekursiver Aufruf
    newSolutions:=temp._solve(allSolutions,deep+1,solutions);
    //Lösungen verarbeiten
    if newSolutions>0 then begin
      result+=newSolutions;  //Zahl speichern
      if not allSolutions then begin
        //Bei einer Einzellösung alle Werte in self speichern
        for k:=0 to high(data) do
          for l:=0 to high(data[k]) do begin
            if (solutionMethod[k,l]=smUnknown) then
              put(k,l,temp.data[k,l],temp.solutionMethod[k,l])
             else
              put(k,l,temp.data[k,l],solutionMethod[k,l]);
           end;
        //und zufrieden beenden
        temp.free;
        exit;
      end else if (solutions=nil) or (solutions.count=0)
                  or (solutions.Last<>pointer(temp))  then
        temp.free; //Nur freigeben, wenn nicht in der Liste
    end else begin
      //Bei einer unmöglichen zweiten Lösung (bei der ersten läuft die Schleife
      //nicht) alle Lösungswege auf smBacktracking1 setzen
      if allSolutions and assigned(solutions) then
        for i:=oldCount to solutions.count-1 do
          TBidoku(solutions[i]).solutionMethod[maxC,maxR]:=smBacktracking1;

      temp.free;
    end;
  end;
end;

//Setzt das Feld x,y auf den Wert c und speichert dafür die Lösungsmethode
//rows,cols und fields werden auch entsprechend angepasst
procedure TBidoku.put(x, y: longint; c: trilean; method: TSolutionMethod);
begin
  time+=1;
  if solutionMethod<>nil then solutionMethod[x,y]:=method ;
  putTimes[x,y]:=time;
  if data[x,y]=c then exit;

  //Alten Wert entfernen
  cols[x,data[x,y]]-=1;
  rows[y,data[x,y]]-=1;
  quadrates[x div n,y div n,data[x,y]]-=1;

  //Neuen Wert einfügen
  data[x,y]:=c;
  cols[x,c]+=1;
  rows[y,c]+=1;
  quadrates[x div n,y div n,c]+=1;
  changed:=true;
end;

//Setzt nur leere Felder
procedure TBidoku.tryput(x, y: longint; c: trilean; method: TSolutionMethod);
begin
  if data[x,y]=triUnset then put(x,y,c,method);
end;

//Setzt ein Feld durch den Benutzer
procedure TBidoku.put(x, y: longint; c: trilean); //inline;
begin
  put(x,y,c,smUser);
end;

//Setzt nur leere Felder
procedure TBidoku.tryput(x, y: longint; c: trilean); inline;
begin
  if data[x,y]=triUnset then put(x,y,c);
end;

//Übernimmt ein Feld von einem anderen Bidoku
//(einzige Möglichkeit von außen den Lösungsweg zu setzen)
procedure TBidoku.copyField(x, y: longint; bidoku: TBidoku);
begin
  put(x,y,bidoku.data[x,y],bidoku.solutionMethod[x,y]);
  putTimes[x,y]:=bidoku.putTimes[x,y];
end;

//Auslesen
function TBidoku.get(x, y: longint): trilean;inline;
begin
  exit(data[x,y]);
end;

//Auslesen
function TBidoku.getSolutionMethod(x, y: longint): TSolutionMethod; inline;
begin
  result:=solutionMethod[x,y];
end;


//Gibt den Lösungszeitpunkt für ein Feld zurück
function TBidoku.getSolutionTime(x, y: longint): longint; inline;
begin
  result:=putTimes[x,y];
end;

//Alle Spalten, Zeilen, Quadrate enthalten genau maxcount Zahlen von jeder Sorte
function TBidoku.solved():TSolveStatus;
var count: array[trilean] of longint;
    i,j,fi,fj:longint; //fi,fj: Feld
begin
  result:=ssSolved;
  for i:=0 to high(data) do begin
    //Spalten überprüfen
    FillChar(count,sizeof(count),0);
    for j:=0 to high(data) do
      inc(count[data[i,j]]);
    if (count[tri1]>maxcount) or (count[tri0]>maxcount) then exit(ssWrong);
    if (count[tri1]<maxcount) or (count[tri0]<maxcount) then result:=ssPartly;
    //Zeilen überprüfen
    FillChar(count,sizeof(count),0);
    for j:=0 to high(data) do
      inc(count[data[j,i]]);
    if (count[tri1]>maxcount) or (count[tri0]>maxcount) then exit(ssWrong);
    if (count[tri1]<maxcount) or (count[tri0]<maxcount) then result:=ssPartly;
  end;
  //Quadrate überprüfen
  for i:=0 to n-1 do
    for j:=0 to n-1 do begin
      FillChar(count,sizeof(count),0);
      for fi:=n*i to n*i +n-1 do
        for fj:=n*j to n*j +n-1 do
          inc(count[data[fi,fj]]);
      if (count[tri1]>maxcount) or (count[tri0]>maxcount) then exit(ssWrong);
      if (count[tri1]<maxcount) or (count[tri0]<maxcount) then result:=ssPartly;
    end;
end;

//Erzeugt ein leeres Bidoku
constructor TBidoku.create(asize: longint=4);
var i,j:longint;
begin
  n:=asize;
  updateSize();
  changed:=false;
  for i:=0 to high(rows) do begin
    rows[i][triUnset]:=2*maxcount;
    rows[i][tri0]:=0; rows[i][tri1]:=0;
    cols[i][triUnset]:=2*maxcount;
    cols[i][tri0]:=0;
    cols[i][tri1]:=0;
  end;
  for i:=0 to high(quadrates) do
    for j:=0 to high(quadrates[i]) do begin
      quadrates[i,j][triUnset]:=2*maxcount;
      quadrates[i,j][tri0]:=0; quadrates[i,j][tri1]:=0;
    end;
end;

//Reserviert den Speicher für ein Bidoku einer bestimmten Größe
procedure TBidoku.updateSize();
begin
  SetLength(data,n*n,n*n);
  SetLength(rows,n*n);
  SetLength(cols,n*n);
  SetLength(quadrates,n,n);
  SetLength(solutionMethod,n*n,n*n);;
  SetLength(putTimes,n*n,n*n);;
  maxcount:=n*n div 2;
end;

destructor TBidoku.destroy();
begin
  inherited destroy();
end;

//Kopiert dass Bidoku
function TBidoku.clone(): TBidoku;
begin
  Result:=TBidoku.create();
  Result.n:=n;
  result.maxcount:=maxcount;
  result.changed:=false;
  Result.rows:=rows;
  Result.cols:=cols;
  Result.quadrates:=quadrates;
  Result.data:=data;
  Result.solutionMethod:=solutionMethod;
  Result.putTimes:=putTimes;
  result.time:=time;
  SetLength(Result.rows,length(Result.rows));;
  SetLength(Result.cols,length(Result.cols));;
  SetLength(Result.quadrates,length(Result.quadrates),length(Result.quadrates));;
  SetLength(Result.data,length(Result.data),length(Result.data));;
  SetLength(Result.solutionMethod,length(Result.data),length(Result.data));;
  SetLength(result.putTimes,n*n,n*n);
end;

//Berechnet ein Bidoku mit bestimmter Schwierigkeit und Muster
procedure TBidoku.generate(difficulty: TDifficulty;positions: TPositionsArray);
var i,j:longint; //Schleifenvariablen
    c,p:longint; //Anzahl verwendeter Gruppen und aktuelle Gruppe
    fieldCount,maxFieldCount: longint; //gefüllte Felder und maximal erwünschte
    fixedTri: boolean;    //Stehen die Gruppenwerte fest?
    bestDiff,value: longint;//Beste bekannte Abweichung vom Optimum
    twin,bidoku: TBidoku; //Kopie und neues Bidoku
    solutions: TFPList;   //Liste aller Lösungen
    tri: trilean;         //Grundwert für eine Gruppe

  //Überprüft, ob die Gruppe benutzbar ist
  function freeFields(p:longint;out base: trilean):boolean;
  var i,c:longint;  //Schleifenvariable und Zahl der belegten Felder
  begin
    c:=0;
    base:=triUnset;
    for i:=0 to high(positions[p]) do
      with positions[p,i] do
        if twin.solutionMethod[u,v] in UNIQUE_SOLUTION then begin
          //Feld ist belegt
          if c=0 then begin //Erstes belegtes Feld?
            base:=twin.data[u,v];  //=> Basiswert ermitteln
            if negate then base:=TRI_NOT[base];
          end else if (base=twin.data[u,v]) xor negate then//gleicher Basiswert?
            exit(false); //Wenn nicht => Abbruch
          c+=1;
        end;
    exit(c<length(positions[p]));
  end;
    
begin
  //Initialisieren
  Randomize;
  for i:=0 to high(data) do
    for j:=0 to high(data[i]) do
      put(i,j,triUnset,smFixed);
  if not assigned(positions) then begin
    SetLength(positions,n*n*n*n,1);
    for i:=0 to high(data) do
      for j:=0 to high(data[i]) do
        with positions[n*n*i+j,0] do begin
          u:=i;
          v:=j;
        end;
  end;
  c:=0;
  fieldCount:=0;
  maxFieldCount:=n*n*n*n;
  twin:=clone;
  p:=high(positions);
  //Generieren
  repeat
    //Auswahl einer freien Gruppe
    repeat
      positions[p]:=positions[high(positions)-c];
      p:=random(length(positions)-c);
      fieldCount+=length(positions[p]);
      c+=1;
    until (freeFields(p,tri)) or (c>high(positions));
    fixedTri:=tri<>triUnset;
    if not fixedTri then tri:=trilean(random(2)+1);
    //Einfügen der Werte
    for i:=0 to high(positions[p]) do
      with positions[p,i] do
        if not (twin.solutionMethod[u,v] in UNIQUE_SOLUTION) then begin
          if negate then put(u,v,TRI_NOT[tri], smFixed)
          else put(u,v,tri,smFixed);
        end;
    //Lösbarkeit überprüfen
    twin.free;twin:=clone();
    twin.logicalSolve();
    if fieldCount>=n*n*n*n div 4 then
      if twin._solve(false,0,nil) = 0 then
        for i:=0 to high(positions[p]) do
          with positions[p,i] do
            put(u,v,triUnset,smUnknown);
  until (c>=high(positions)) or (fieldCount>=maxFieldCount);
  //Alle Lösungen berechnen und eine wählen
  saveToFile('T:\temp');
  solutions:=TFPList.Create;
  twin:=clone;
  twin._solve(true,0,solutions);
  assert(solutions.count>0,'Ungültige Lösung generiert');
  //Besten Schwierigkeitswert suchen
  j:=0;
  case difficulty of
    dEasy: begin //Minimum
      bestDiff:=TBidoku(solutions[0]).rateDifficulty;
      for i:=1 to solutions.count-1 do
        if TBidoku(solutions[i]).rateDifficulty<bestDiff then
          bestDiff:=TBidoku(solutions[i]).rateDifficulty;
    end;
    dHard: begin //Maximum
      bestDiff:=TBidoku(solutions[0]).rateDifficulty;
      for i:=1 to solutions.count-1 do
        if TBidoku(solutions[i]).rateDifficulty>bestDiff then
          bestDiff:=TBidoku(solutions[i]).rateDifficulty;
    end;
    dNormal: begin
      //Mittelwert suchen
      bestDiff:=TBidoku(solutions[0]).rateDifficulty;
      for i:=1 to solutions.count-1 do
        bestDiff+=TBidoku(solutions[i]).rateDifficulty;
      bestDiff:=bestDiff div solutions.count;
    end;
  end;
  //Minimale Abweichung von Symmetrie und Schwierigkeitsgrad
  value:=abs(TBidoku(solutions[0]).rateDifficulty-bestDiff)+
         TBidoku(solutions[0]).symmetricErrors(positions);
  for i:=0 to solutions.count-1 do
    if abs(TBidoku(solutions[i]).rateDifficulty-bestDiff)+
          TBidoku(solutions[i]).symmetricErrors(positions)<value then begin
      value:=abs(TBidoku(solutions[i]).rateDifficulty-bestDiff)+
             TBidoku(solutions[i]).symmetricErrors(positions);
      j:=i;
    end;
  //Bidoku wurde gewählt
  bidoku:=TBidoku(solutions[j]);
  for i:=0 to high(data) do
    for j:=0 to high(data[i]) do
      if (bidoku.solutionMethod[i,j] = smBacktracking2) or
         ((bidoku.solutionMethod[i,j] = smBacktracking1) and
          (solutions.count>=MAX_SOLUTIONS)) then
        put(i,j,bidoku.data[i,j],smFixed);

  //Schwierigkeitsgrad anpassen
  case difficulty of
    dHard: minimize;
    dEasy: begin
      //Feldpositionen und leere Felder ermitteln
      fieldCount:=0;
      SetLength(positions,n*n*n*n,1);
      for i:=0 to high(data) do
        for j:=0 to high(data[i]) do begin
          if data[i,j]=triUnset then fieldCount+=1;
          with positions[n*n*i+j,0] do begin
            u:=i;
            v:=j;
          end;
      end;
      //Zufällig schwere Felder füllen
      c:=0;
      while (fieldCount>100) and (c<high(positions)) do begin
        p:=random(length(positions)-c);
        with positions[p,0] do
          if (data[u,v]=triUnset) then begin
            put(u,v,bidoku.data[u,v],smFixed);
            fieldCount-=1;
          end;
        positions[p]:=positions[high(positions)-c];
        c+=1;
      end;
    end;
  end;

  //Bidokus löschen
  for i:=0 to solutions.count-1 do
    if TBidoku(solutions[i])<>twin then
      TBidoku(solutions[i]).free;
  solutions.free;
  twin.free;
end;

procedure TBidoku.generateEncryption(s: string);
var sAsNumber: array of longint; //String im 32er System
    sAsBits: array of boolean;   //String im 2er System
    i,j,bit:longint;             //Schleifenvariablen und aktuelles Bit
begin
  //String in Zahl im 32er System umwandeln
  s+='  ';
  SetLength(sAsNumber,length(s));
  for i:=0 to high(sAsNumber) do
    case s[i+1] of
      'a'..'z': sAsNumber[i]:=ord(s[i+1])-ord('a')+1;
      'A'..'Z': sAsNumber[i]:=ord(s[i+1])-ord('A')+1;
      '-': sAsNumber[i]:=27;
      '.': sAsNumber[i]:=28;
      ',': sAsNumber[i]:=29;
      '?': sAsNumber[i]:=30;
      '!': sAsNumber[i]:=31;
      else sAsNumber[i]:=0;
    end;
    
  //String in Binärzahl umwandeln
  SetLength(sAsBits,length(s)*5);
  for i:=0 to high(sAsNumber) do begin
    bit:=0;
    while sAsNumber[i] > 0 do begin
      if sAsNumber[i] and 1 = 1 then
        sAsBits[5*i+bit]:=true;
      sAsNumber[i]:=sAsNumber[i] shr 1;
      bit+=1;
    end;
  end;
  
  //Generieren, so dass alle freien Felder den entsprechenden Wert
  //erhalten
  for i:=0 to high(data) do
    for j:=0 to high(data) do
      put(i,j,triUnset,smUnknown);
  bit:=0;
  for i:=0 to high(data) do begin
    for j:=0 to high(data) do begin
      //Freie Feldwahl überprüfen
      if data[i,j]<>triUnset then continue;
      put(i,j,tri0,smFixed);
      if not isSolvable() then begin
        put(i,j,tri0,smLogicCombined);
        continue;
      end;
      put(i,j,tri0,smFixed);
      if not isSolvable() then begin
        put(i,j,tri1,smLogicCombined);
        continue;
      end;
      //Bit
      if sAsBits[bit] then put(i,j,tri1,smFixed)
      else put(i,j,tri0,smFixed);
      bit+=1;
      if bit>high(sAsBits) then break;
      logicalSolve();
    end;
    if bit>high(sAsBits) then break;
  end;
  for i:=0 to high(data) do
    for j:=0 to high(data) do
      if solutionMethod[i,j] in LOGICAL_SOLUTION then
        put(i,j,triUnset,smUnknown);
end;

//Minimiert das Bidoku
procedure TBidoku.minimize;
var i,j:longint;               //Schleifenvariablen
    positions:array of tpoint; //Alle möglichen Feldpositionen
begin
  //Alle möglichen Positionen in ein Array eintragen
  SetLength(positions,n*n*n*n);
  for i:=0 to high(data) do
    for j:=0 to high(data[i]) do begin
      with positions[n*n*i+j] do begin
        x:=i;
        y:=j;
      end;
      //Feste Felder markieren (nur zur Sicherheit, eigentlich unnötig)
      if data[i,j]<>triUnset then
        solutionMethod[i,j]:=smFixed;
    end;
  //Alle Felder in zufälliger Reihenfolge besuchen und dann
  //auf ihre Notwendigkeit überprüfen
  j:=0;
  while j<=high(positions) do begin
    i:=random(length(positions)-j);
    with positions[i] do
      if data[x,y] <> triUnset then begin
        put(x,y,TRI_NOT[data[x,y]],smFixed);
        if isSolvable() then put(x,y,TRI_NOT[data[x,y]],smFixed) //zurücksetzen
        else put(x,y,triUnset,smUnknown);                        //löschen
      end;
    positions[i]:=positions[high(positions)-j];
    j+=1;
  end;
end;

//Findet den im Bidoku verborgenen Text
function TBidoku.decode(): string;
var bits: array of boolean;   //String als Bitfolge
    number: array of longint; //String als Zahl im 32er Sytem
    i,j,bit:longint;          //Schleifen, aktuelles Bit
    bidoku: TBidoku;          //Bidoku, das gefüllt wird
begin
  SetLength(bits,length(data)*length(data));
  fillchar(bits[0],sizeof(bits[0])*length(bits),0);
  //Generieren
  bidoku:=TBidoku.create;
  bit:=0;
  for i:=0 to high(data) do
    for j:=0 to high(data) do begin
      if bidoku.data[i,j]<>triUnset then continue;
      //Freie Feldwahl überprüfen
      bidoku.put(i,j,tri0,smFixed);
      if not bidoku.isSolvable() then begin
        bidoku.put(i,j,tri1,smFixed);
        continue;
      end;
      bidoku.put(i,j,tri0,smFixed);
      if not isSolvable() then begin
        bidoku.put(i,j,tri1,smFixed);
        continue;
      end;
      bidoku.put(i,j,data[i,j],smFixed);
      bidoku.logicalSolve();
      //Bit
      bits[bit]:=data[i,j]=tri1;
      bit+=1;
    end;

  //Binärzahl in 32er System umwandeln
  SetLength(number,bit div 5);
  for i:=0 to high(number) do begin
    number[i]:=0;
    for j:=4 downto 0 do begin
      number[i]*=2;
      if bits[j+5*i] then number[i]+=1;
    end;
  end;

  //Zahl in String umwandeln
  result:='';
  for i:=0 to high(number) do
    case number[i] of
      1..26:result+=chr(number[i]+ord('a')-1);
      27: result+='-';
      28: result+='.';
      29: result+=',';
      30: result+='?';
      31: result+='!';
      else result+=' '
    end;
end;


//Öffentliche Lösungsmethode
function TBidoku.solve(allSolutions,list: boolean):TSolveResult;
var i,j:longint;
    wtime: cardinal;
begin
  wtime:=GetTickCount;
  if list then result.solutions:=TFPList.create
  else result.solutions:=nil;
  //Markiere festgelegte Felder
  for i:=0 to high(data) do
     for j:=0 to high(data[i]) do
       if data[i,j]=triUnset then solutionMethod[i,j]:=smUnknown
       else solutionMethod[i,j]:=smFixed;
  //Eigentliches Lösungsverfahren aufrufen
  result.solutioncount:=_solve(allSolutions,0,result.solutions);
  //Ergebnisse setzen
  result.solved:=result.solutioncount>0;
  if (result.solutions<>nil)and(result.solutions.count>0) and
     (Tbidoku(result.solutions[0])=Self) then
    result.solutions[0]:=clone;
  OutputDebugString(pchar(IntToStr(GetTickCount-wtime)));
end;

//Überprüft, ob es eine Lösung gibt, indem das Rätsel geklont und gelöst wird
function TBidoku.issolvable(): boolean;
var temp: TBidoku;
begin
  temp:=clone();
  result:=temp._solve(false,0,nil)>0;
  temp.free;
end;

//In einen String umwandeln
function TBidoku.toString(): string;
var i,j: longint;
begin
  result:='';
  for i:=0 to high(data) do begin //Zeilen
    if i mod n = 0 then begin
      //Trennlinie einfügen
      for j:=0 to high(data[i]) do
        if j mod n = 0 then result+='|-'
        else result+='-';
      result+='|'#13#10;
    end;
    for j:=0 to high(data[i]) do begin //Spalten
      if j mod n = 0 then
        result+='|'; //Trennspalte
      case data[j,i] of
        triUnset: result+=' ';
        tri0: result+='0';
        tri1: result+='1';
      end;
    end;
    result:=result+'|'#13#10;
  end;
  //Schlusslinie
  for j:=0 to high(data[i]) do
    if j mod n = 0 then result+='|-'
    else result+='-';
  result+='|'#13#10;
end;

//Speichern
procedure TBidoku.saveToFile(fn: string);
var f: TFileStream;
    str: string;
begin
  f:=TFileStream.Create(fn,fmCreate);
  str:=toString();
  f.WriteBuffer(str[1],length(str));
  f.free;
end;

//Laden
procedure TBidoku.loadFromFile(fn: string);
var f: TFileStream;
    str:string;
    p,i,j:longint; //Stringposition, Spalte, Zeile
begin
  //Dateiinhalt in einen String kopieren
  f:=TFileStream.Create(fn,fmOpenRead);
  SetLength(str,f.Size-1);
  f.ReadBuffer(str[1],length(str));
  f.free;
  

  //Fehlertolerantes Lesen
  //Länge ermitteln (n^2+n+1=a => n=-0.5+-sqrt(0.25-(1-a))=-0.5+-sqrt(a-0.75))
  for p:=1 to length(str) do
    if str[p] in [#13,#10] then begin
      n:=trunc(sqrt(p-0.75));
      updateSize();
      break;
    end;
  i:=0;
  j:=0;
  for p:=n*n+n+1 to length(str) do
    if str[p] in ['0','1','O','X',' '] then begin
      if str[p] in ['0','O'] then put(j,i,tri0,smFixed)
      else if str[p] in ['1','X'] then put(j,i,tri1,smFixed)
      else put(j,i,triUnset,smFixed);
      j+=1;
      if j>high(data) then begin
        j:=0;
        i+=1;
      end;
    end;
end;

//Erzeugt eine horizontale Spiegelung um die Bidokumitte
function TBidoku.makeMirrorSymmetryH(invert: boolean): TPositionsArray;
var i,j:longint;
begin
  SetLength(result,length(data)*length(data)div 2,2);
  for i:=0 to high(data) div 2 do
    for j:=0 to high(data) do begin
      with result[i*length(data)+j,0] do begin
        u:=i;
        v:=j;
        negate:=false;
      end;
      with result[i*length(data)+j,1] do begin
        u:=high(data)-i;
        v:=j;
        negate:=invert;
      end;
    end;
end;

//Erzeugt eine vertikale Spiegelung um die Bidokumitte
function TBidoku.makeMirrorSymmetryV(invert: boolean): TPositionsArray;
var i,j:longint;
begin
  SetLength(result,length(data)*length(data)div 2,2);
  for i:=0 to high(data) div 2 do
    for j:=0 to high(data) do begin
      with result[i*length(data)+j,0] do begin
        u:=j;
        v:=i;
        negate:=false;
      end;
      with result[i*length(data)+j,1] do begin
        u:=j;
        v:=high(data)-i;
        negate:=invert;
      end;
    end;
end;

//Erzeugt eine horizontale Spiegelung um die Mitte der einen und
//der anderen Hälft des Bidokus
function TBidoku.makeMirrorSymmetrySubH(invert: boolean): TPositionsArray;
var i,j:longint;
begin
  SetLength(result,length(data)*length(data)div 2,2);
  for i:=0 to high(data) div 4 do
    for j:=0 to high(data) do begin
      with result[i*length(data)+j,0] do begin
        u:=i;
        v:=j;
        negate:=false;
      end;
      with result[i*length(data)+j,1] do begin
        u:=high(data) div 2-i;
        v:=j;
        negate:=invert;
      end;

      with result[(i+length(data) div 4)*length(data)+j,0] do begin
        u:=i+length(data) div 2;
        v:=j;
        negate:=false;
      end;
      with result[(i+length(data) div 4)*length(data)+j,1] do begin
        u:=high(data)-i;
        v:=j;
        negate:=invert;
      end;
    end;
end;

//Erzeugt eine vertikale Spiegelung um die Mitte der einen und
//der anderen Hälft des Bidokus
function TBidoku.makeMirrorSymmetrySubV(invert: boolean): TPositionsArray;
var i,j:longint;
begin
  SetLength(result,length(data)*length(data)div 2,2);
  for i:=0 to high(data) div 4 do
    for j:=0 to high(data) do begin
      with result[i*length(data)+j,0] do begin
        u:=j;
        v:=i;
        negate:=false;
      end;
      with result[i*length(data)+j,1] do begin
        u:=j;
        v:=high(data) div 2-i;
        negate:=invert;
      end;
      
      with result[(i+length(data) div 4)*length(data)+j,0] do begin
        u:=j;
        v:=i+length(data) div 2;
        negate:=false;
      end;
      with result[(i+length(data) div 4)*length(data)+j,1] do begin
        u:=j;
        v:=high(data)-i;
        negate:=invert;
      end;
    end;
end;


//Verbindet zwei Muster
function TBidoku.mergeSymmetry(a, b: TPositionsArray): TPositionsArray;
  //Berechnet alle Schnitte zwischen den Gruppen g und h
  //und gibt zurück, ob diese Schnittstelle die eine Gruppe invertiert
  function groupIntersection(const g,h:TPositionGroup;out negate: boolean):boolean;
  var i,j:longint;
  begin
    result:=false;
    for i:=0 to high(g) do
      for j:=0 to high(h) do
        if (h[j].u=g[i].u) and (g[i].v=h[j].v) then begin
          if result then
            assert((g[i].negate xor h[j].negate)=negate,'Symmetrien unpassend')
           else
            negate:=g[i].negate xor h[j].negate;
          result:=true;
        end;
  end;
  
  //Fügt die Gruppe h zur Gruppe g hinzu
  procedure addPositionGroup(var g,h:TPositionGroup;negate: boolean);
  var i,j:longint;
      found:boolean; //Feld existiert schon in Gruppe g
  begin
    for j:=0 to high(h) do begin
      found:=false;
      for i:=0 to high(g) do
        if (h[j].u=g[i].u) and (g[i].v=h[j].v) then begin
          found:=true;
          break;
        end;
        if not found then begin
          SetLength(g,length(g)+1);
          g[high(g)]:=h[j];
          if negate then with g[high(g)] do
            negate:=not negate;
        end;
    end;
  end;

var i,j,p:longint; //Schleifenvariablen und Anzahl zurückgegebener Gruppen
    negate,groupchanged:boolean; //Wurde die Gruppe negiert/geändert?
begin
  if a=nil then exit(b);
  if b=nil then exit(a);
  //a mit b verbinden
  setlength(result,length(a));
  for i:=0 to high(a) do begin
    setlength(result[i],length(a[i]));
    move(a[i,0],result[i,0],length(a[i])*sizeof(a[i,0]));
    for j:=0 to high(b) do
       if groupIntersection(a[i],b[j],negate) then
         addPositionGroup(result[i],b[j],negate);
  end;
  //Gruppen mit gemeinsamen Feldern suchen
  p:=high(result);
  repeat
    groupchanged:=false;
    for i:=p downto 0 do
      for j:=p downto i+1 do
        if groupIntersection(result[i],result[j],negate) then begin
          addPositionGroup(result[i],result[j],negate);
          result[j]:=result[p];
          p-=1;
          groupchanged:=true;
        end;
  until not groupchanged;
  setlength(result,p+1)
end;


procedure TBidoku.logicalSolve();
var waschanged: boolean; //Gab es eine Änderung?
    i,j,k,l:longint;     //Schleifenvariablen
    num,num2: trilean;   //Aktuelle Zahl und invertierte
    count:longint;       //Anzahl der gefüllten Felder
begin
  repeat
    waschanged:=false;
    //Vervollständigen von Reihen
    repeat
      num2:=tri1;
      for num:=tri0 to tri1 do begin
        changed:=false;
        for i:=0 to high(cols) do
          if (cols[i][num]=maxcount) and (cols[i][num2]<maxcount) then
            for j:=0 to high(rows) do
              tryPut(i,j,num2,smLogicTrivial);
        for i:=0 to high(rows) do
          if (rows[i][num]=maxcount) and (rows[i][num2]<maxcount) then
            for j:=0 to high(cols) do
              tryPut(j,i,num2,smLogicTrivial);
        for i:=0 to high(quadrates) do
          for j:=0 to high(quadrates[i]) do
            if (quadrates[i][j][num]=maxcount) and
               (quadrates[i][j][num2]<maxcount) then
              for k:=i*n to i*n+n-1 do
                for l:=j*n to j*n+n-1 do
                  tryPut(k,l,num2,smLogicTrivial);
        num2:=num;
      end;
      waschanged:=waschanged or changed;
    until not changed;
    
    changed:=waschanged;
    
    num2:=tri1;
    for num:=tri0 to tri1 do begin
      //Prüfe, wo nur wenige von einer Sorte eingefügt werden können und deshalb
      //von der anderen Sorte soviele eingefügt werden müssen das ein Bereich
      //voll ist
      //Spalte => bekanntes Quadrat
      for i:=0 to high(cols) do
        if (cols[i][num]>maxcount-n)
            and (cols[i][num]+cols[i][num2]<2*maxcount) then begin
          for j:=0 to high(quadrates[0]) do
            if (quadrates[i div n,j][num2]+n-(maxcount-cols[i][num])>=maxcount) and
               (quadrates[i div n,j][num]+quadrates[i div n,j][num2]
                 <2*maxcount) then begin
              count:=0;
              for k:=j*n to j*n+n-1 do
                if data[i,k]=triUnset then inc(count);
              if (quadrates[i div n,j][num2]+count-
                    (maxcount-cols[i][num])>=maxcount) and
                 (quadrates[i div n,j][num]+quadrates[i div n,j][num2]+count<
                  2*maxcount) then
                for l:=j*n to j*n+n-1 do begin
                  for k:=(i div n)*n to i-1 do
                    tryPut(k,l,num,smLogicCombined);
                  for k:=i+1 to (i div n)*n+n-1 do
                    tryPut(k,l,num,smLogicCombined);
                end;
            end;
        end;


      //Zeile => bekanntes Quadrat
      for i:=0 to high(rows) do
        if (rows[i][num]>maxcount-n)
            and (rows[i][num]+rows[i][num2]<2*maxcount) then begin
          for j:=0 to high(quadrates) do
            if (quadrates[j,i div n][num2]+n-
                    (maxcount-rows[i][num])>=maxcount) and
               (quadrates[j,i div n][num]+quadrates[j,i div n][num2]<
                  2*maxcount) then begin
              count:=0;
              for k:=j*n to j*n+n-1 do
                if data[k,i]=triUnset then inc(count);
              if (quadrates[j,i div n][num2]+count-
                    (maxcount-rows[i][num])>=maxcount)and
                 (quadrates[j,i div n][num]+quadrates[j,i div n][num2]+count<
                   2*maxcount) then
                for l:=j*n to j*n+n-1 do begin
                  for k:=(i div n)*n to i-1 do
                    tryPut(l,k,num,smLogicCombined);
                  for k:=i+1 to (i div n)*n+n-1 do
                    tryPut(l,k,num,smLogicCombined);
                end;
            end;
        end;


      //Fast volle Quadrate
      for i:=0 to high(quadrates) do
        for j:=0 to high(quadrates[0]) do  // i, j bestimmen Quadrat
          if (quadrates[i][j][num]>maxcount-n)
             and(quadrates[i][j][num]+quadrates[i][j][num2]<2*maxcount)then begin

            //Quadrat => bekannte Spalte?
            for k:=i*n to i*n+n-1 do //k bestimmt Spalte
              if (cols[k][num2]+n-(maxcount-quadrates[i][j][num])>=maxcount) and
                 (cols[k][num]+cols[k][num2]<2*maxcount) then begin
                //Anzahl unbekannter Felder in der Schnittmenge Quadrat/Spalte
                //bestimmen
                count:=0;
                for l:=j*n to j*n+n-1 do
                  if data[k,l]=triUnset then inc(count);
                //Spalte füllen, falls nun bekannt
                if (cols[k][num2]+count-(maxcount-quadrates[i][j][num])>=
                     maxcount)and
                   (cols[k][num]+cols[k][num2]+count<2*maxcount) then begin
                  for l:=0 to j*n-1 do
                    tryPut(k,l,num,smLogicCombined);
                  for l:=j*n+n to high(rows) do
                    tryPut(k,l,num,smLogicCombined);
                end;
              end;


            //Quadrat => bekannte Zeile
            for k:=j*n to j*n+n-1 do //k bestimmt Zeile
              if (rows[k][num2]+n-(maxcount-quadrates[i][j][num])>=maxcount) and
                 (rows[k][num]+rows[k][num2]<2*maxcount) then begin
                //Anzahl unbekannter Felder in der Schnittmenge Quadrat/Spalte
                //bestimmen
                count:=0;
                for l:=i*n to i*n+n-1 do
                  if data[l,k]=triUnset then inc(count);
                //Zeile füllen, falls nun bekannt
                if (rows[k][num2]+count-(maxcount-quadrates[i][j][num])>=maxcount)
                   and(rows[k][num]+rows[k][num2]+count<2*maxcount) then begin
                  for l:=0 to i*n-1 do
                    tryPut(l,k,num,smLogicCombined);
                  for l:=i*n+n to high(rows) do
                    tryPut(l,k,num,smLogicCombined);
                end;
              end;
          end;


      num2:=num;
    end;
  until not changed;
end;
end.

