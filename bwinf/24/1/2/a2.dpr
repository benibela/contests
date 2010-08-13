program a2;
uses classes,
  utils in '..\common\utils.pas';


const IGNORED_COUNT=3; //Anzahl der Zeilen, die ignoriert werden können
      SOLUTIONS_COUNT=3;//Anzahl der schönen Lösungen die gefunden werden sollen

type TValue=integer; //Typ für einen Wert in der Tabelle
     TValues=array of array[0..2] of integer; //Tabelle
     TFactor=TValue; //Typ für einen Faktor
     TOperators=char; //Typ für den Operator
     TPossibleSolution=record //Eine Lösung
                         f1,f2,f3:TFactor;  //Faktoren
                         op:TOperators; //Operator
                         //Summe der Absolutbeträge der Differenz aller m-Werte
                         //mit den jeweils berechneten,
                         //Summe der Absolutbeträge der Differenzen in den
                         //ignorierten Zeilen
                         absDifference,absIgnoredDifference:TValue;
                         //Differenzen (nicht absolut), nach Zeilenindex
                         differences:array of TValue;
                         //Zeilenindizes der ignorierten
                         ignoredDifferences:array[0..IGNORED_COUNT-1] of integer;
                         //ANzahl der Einträge in ignoredDifferences
                         ignoredLines:integer;
                       end;
  //Liest eine Tabelle
  function readValues(const fileName:string):tvalues;
  var loadedfile:TStringList;
      i,pos:integer;
  begin
    //Werte in Stringlist lesen
    loadedfile:=TStringList.create;
    try
      loadedfile.LoadFromFile(fileName);
      //Werte ins Array übertragen
      SetLength(result,loadedfile.Count-1);
      for i:=1 to loadedfile.Count-1 do
        if loadedfile[i]<>'' then begin
          pos:=0;
          //4 Nummern lesen
          readNumber(loadedfile[i],pos); //Zeilenindex
          Result[i-1][0]:=readNumber(loadedfile[i],pos);
          Result[i-1][1]:=readNumber(loadedfile[i],pos);
          Result[i-1][2]:=readNumber(loadedfile[i],pos);
        end else begin
          //Letzte Zeile
          SetLength(result,i-1);
          break;
        end;
    finally
      loadedfile.free;
    end;
  end;


var //Schönste gefundene Lösung
    bestSolutions:array[0..SOLUTIONS_COUNT-1] of TPossibleSolution;
    //Tabelleneinträge
    values:TValues;

//ggT nach euklid
function ggT(a,b:integer):integer;
var t:integer;
begin
  while b>0 do begin
    if b>=a then b:=b mod a
    else begin
      t:=b;
      b:=a;
      a:=t;
    end;
  end;
  result:=a;
end;

//Lösungsformelinformationen berechnen
//f1, f2, f3 sind die Faktoren
//sol die ausgegebene Formel
//result gibt an, ob die Formel zulässig ist
function createSolution(f1,f2,f3:TFactor;out sol:TPossibleSolution):boolean;
var divisor:TFactor; //hier durch wird diviedier
    i,j:integer; //Schleifenvariablen
begin
  Result:=false;
  //Korrektheit überprüfen
  if f1<=0 then exit;
  if f2<0 then sol.op:='-'
  else if f2>0 then sol.op:='+'
  else exit;
  f2:=abs(f2);
  if f3<=0 then exit;
  //Speichern und kürzen
  divisor:=ggt(f1,ggt(f2,f3));
  sol.f1:=f1 div divisor;
  sol.f2:=f2 div divisor;
  sol.f3:=f3 div divisor;

  //unterschiede berechnen
  SetLength(sol.differences,length(values));
  sol.absDifference:=0;
  sol.absIgnoredDifference:=0;
  sol.ignoredLines:=0;
  FillChar(sol.ignoredDifferences,sizeof(sol.ignoredDifferences),$FF); //$FF = -1
  for i:=0 to high(values) do begin
    //Differenz fürs Array berechnen
    if sol.op='+' then
      sol.differences[i]:=sol.f1*values[i][0]+sol.f2*values[i][1] - sol.f3*values[i][2]
     else
      sol.differences[i]:=sol.f1*values[i][0]-sol.f2*values[i][1] - sol.f3*values[i][2];
    //Absolutdifferenz erhöhen
    sol.absDifference:=sol.absDifference+abs(sol.differences[i]);
    if sol.differences[i]<>0 then begin //Unterschied
      //Rückwärts ignorierte Lösungen durchlaufen
      j:=IGNORED_COUNT-1;
      while (j>=0) do begin
        if (sol.ignoredDifferences[j]<>-1)and(abs(sol.differences[sol.ignoredDifferences[j]])>=abs(sol.differences[i])) then
          break //Abbrechen, da sol.ignoredDifferences[j] eine höhere Abweichung hat
        else if j<IGNORED_COUNT-1 then //geringere Abewichung
          sol.ignoredDifferences[j+1]:=sol.ignoredDifferences[j]; //Nach hinten verschieben 
        dec(j); //Nächster Eintrag
      end;
      if j<IGNORED_COUNT-1 then //Höhere Differenz als eines aus der Liste
        sol.ignoredDifferences[j+1]:=i; //Speichern
    end;
  end;
  //Summe der (abs.) ignorierten Differenz berechnen
  for j:=0 to IGNORED_COUNT-1 do
    if sol.ignoredDifferences[j]<>-1 then begin
      sol.absIgnoredDifference:=sol.absIgnoredDifference+abs(sol.differences[sol.ignoredDifferences[j]]);
      inc(sol.ignoredLines);
    end;

  Result:=true;
end;

//-1: s1 ist besser, 0 gleich, +1 s2 ist besser
function compareSolutions(const s1,s2:TPossibleSolution):integer;
begin
  //Lösungsexistens
  if s1.op=#0 then begin
    result:=1;
    exit;
  end else if s2.op=#0 then begin
    result:=-1;
    exit;
  end;
  //Abweichung von den Messergebnissen soll minimal sein
  if s1.absDifference-s1.absIgnoredDifference<s2.absDifference-s2.absIgnoredDifference then begin
    result:=-1;
    exit;
  end else if s1.absDifference-s1.absIgnoredDifference>s2.absDifference-s2.absIgnoredDifference then begin
    result:=1;
    exit;
  end;

  //Anzahl der ignorierten Zeilen soll minimal sein
  if s1.ignoredLines<s2.ignoredLines then begin
    result:=-1;
    exit;
  end else if s1.ignoredLines>s2.ignoredLines then begin
    result:=1;
    exit;
  end;

  //Faktorengröße soll minimal sein
  if abs(s1.f1)+abs(s1.f2)+abs(s1.f3)<abs(s2.f1)+abs(s2.f2)+abs(s2.f3) then
    Result:=-1
  else if abs(s1.f1)+abs(s1.f2)+abs(s1.f3)>abs(s2.f1)+abs(s2.f2)+abs(s2.f3) then
    Result:=1
  else
    Result:=0;
end;

//Lösung in das bestSolutions-Array einfügen, falls sie schöner als eine von
//diesen ist
procedure addSolution(const sol:TPossibleSolution);
var j:integer;
begin
  //Auf Gleichheit testen (jede Formel nur einmal)
  for j:=0 to SOLUTIONS_COUNT-1 do
    if (sol.f1=bestSolutions[j].f1)and(sol.f2=bestSolutions[j].f2)and
       (sol.f3=bestSolutions[j].f3)and(sol.op=bestSolutions[j].op) then exit;
  //Formeln rückwärts durchlaufen
  j:=SOLUTIONS_COUNT-1;
  while (j>=0) do begin
    case compareSolutions(sol,bestSolutions[j]) of //vergleichen
      1: break; //bestSolutions[j] ist schöner
      -1:  if j<SOLUTIONS_COUNT-1 then //ansonsten,
             bestSolutions[j+1]:=bestSolutions[j]; //Platz freimachen
    end;
    dec(j);
  end;
  if j<SOLUTIONS_COUNT-1 then //diese Formel ist schöner?
    bestSolutions[j+1]:=sol; //speichern
end;

//Formeleigenschaften aus den Faktoren berechnen, und mit bisherigen vergleichen
procedure createAndAddSolutions(const f1,f2,f3:TFactor);
var sol:TPossibleSolution;
begin
  if createSolution(f1,f2,f3,sol) then
    addSolution(sol);
end;

var i,j:integer; //Schleifenvar.
    f1,f2,f3:TFactor; //Faktoren
    min,max:TValue; //Minimu,Maximum
    noreason:boolean; //Die Lösung ist nicht besonders schön, aber alle anderen sind schlechter
begin
  FillChar(bestSolutions,sizeof(bestSolutions),0);
  values:=readValues(ParamStr(1));
  //Suche nach einer perfekten Lösung (Gleichungssystem)
  //h1 + f_2*a1 = f_3*m1
  //h2 + f_2*a2 = f_3*m2
  //f_2 = (h2·m1 - h1·m2)/(a1·m2 - a2·m1)
  //f_3 = (a1·h2 - a2·h1)/(a1·m2 - a2·m1)
  for i:=0 to high(values) do
    for j:=0 to high(values) do begin
      if i=j then continue;
      //Zwei Werte sind markiert
      f1 := values[i][1]*values[j][2] - values[j][1]*values[i][2];
      f2 := values[j][0]*values[i][2] - values[i][0]*values[j][2];
      f3 := values[i][1]*values[j][0] - values[j][1]*values[i][0];
      createAndAddSolutions(f1,f2,f3);
    end;
  //Minimum und Maximum suchen
  min:=MAXINT;
  max:=0;
  for i:=0 to high(values) do begin
    if values[i][2]>max then max:=values[i][2];
    if values[i][2]<min then min:=values[i][2];
  end;

  //Gefundene Lösungen durchlaufen
  for i:=0 to SOLUTIONS_COUNT-1 do begin
    if bestSolutions[i].op=#0 then exit; //Weniger als drei Lösungen
    //Formel ausgeben
    Writeln(bestSolutions[i].f1,' * H-Wert ',bestSolutions[i].op,' ',
            bestSolutions[i].f2,' * A-Wert = ',
            bestSolutions[i].f3,' * M-Wert');
    //Ignorierte Zeilen (sofern vorhanden) auflisten
    Writeln('  Es wurde gestrichen: ');
    for j:=0 to IGNORED_COUNT-1 do
      if bestSolutions[i].ignoredDifferences[j]<>-1 then
        writeln('    ',bestSolutions[i].ignoredDifferences[j]+1,' mit Abweichung: ',
                       bestSolutions[i].differences[bestSolutions[i].ignoredDifferences[j]]);
    //Begrüungen
    Writeln('  Dies ist eine schöne Formel, da:');
    noreason:=true;
    if bestSolutions[i].absDifference-bestSolutions[i].absIgnoredDifference<(max-min) then begin
      noreason:=false;
      Writeln('    - Die Summe der absoluten Abweichungen nur ',bestSolutions[i].absDifference-bestSolutions[i].absIgnoredDifference,' ist');
    end;
    if abs(bestSolutions[i].f1)+abs(bestSolutions[i].f2)+abs(bestSolutions[i].f3)<100 then begin
      noreason:=false;
      Writeln('    - Die Faktoren ','(',bestSolutions[i].f1,', ',bestSolutions[i].f2,', ',bestSolutions[i].f3,') alle klein sind');
    end;
    if noreason then //Bisher keine Begründung
      Writeln('    - mir nicht besseres einfällt');
  end;
  Readln; //warten 
end.
