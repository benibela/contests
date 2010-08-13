unit raff_u;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, StdCtrls,math;

type
  TfrmRaff = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    Button2: TButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private-Deklarationen}
  public
    { Public-Deklarationen}
  end;

var
  frmRaff: TfrmRaff;

implementation

{$R *.DFM}

procedure TfrmRaff.Button1Click(Sender: TObject);
begin
  if OpenDialog1.Execute then begin//Wurde eine Datei ausgewählt
    SaveDialog1.Filename:=OpenDialog1.FileName;//Name als Standard für den SaveDialog
    Memo1.Lines.LoadFromFile(OpenDialog1.filename);//Datei laden
  end;
end;

procedure TfrmRaff.Button2Click(Sender: TObject);
begin
  if SaveDialog1.Execute then begin//Wurde eine Datei ausgewählt
    if pos('.',SaveDialog1.filename)<=0 then //Keine Endung?
      SaveDialog1.filename:=SaveDialog1.filename+'.txt'; //diese hinzufügen
    Memo1.Lines.saveToFile(SaveDialog1.filename);//Datei speichern
  end;
end;

procedure TfrmRaff.Button3Click(Sender: TObject);
  type TAdjazenzMatrix=array of array of currency;
  var namen:array of string;//Array zur Umwandlung von Währungsnamen in Nummern

  //Findet einen Namen mit Fehlertoleranz im Namen Array
  function findName( name:string):integer;
  var i,j:integer;
      found:boolean;
      namenLen:integer;
  begin
    result:=-1;
    if length(name)<4 then name:='    '+name; //Wegen Problemem mit Abkürzungen
    namenLen:=length(name);
    for i:=0 to high(namen) do begin
      found:=true;
      if (namen[i]<>name) then
        for j:=1 to min(length(namen[i]),namenLen)-2 do
          if namen[i,j]<>name[j] then begin //Namen nicht ganz vergleichen, um
            found:=false;                   //Singular und Plural zu finden
            break;
          end;
      if found then begin
        result:=i;
        exit;
      end;
    end;
  end;

  //Fügt einen Namen ins Namen-Array
  procedure AddName(name:string);
  begin
    if length(name)<4 then name:='    '+name; //Wegen Problemem mit Abkürzungen
    if findName(name)=-1 then begin
      SetLength(namen,length(namen)+1);
      namen[high(namen)]:=name;
    end;
  end;

var //Stack, in dem der aktuell berechnete Zyklus ist
    ZyklusStack:array[0..1023] of integer;  
    StackSize:integer;

  //Fügt eine Zahl in den Stack ein
  procedure pushToStack(const i:integer);
  begin
    ZyklusStack[stacksize]:=i;
    inc(stacksize);
  end;
  //Holt eine Zahl aus dem Stack
  function GetFromStack:integer;
  begin
    if StackSize=0 then result:=-1
    else result:=zyklusStack[stacksize-1];
  end;
  //Löscht eine Zahl aus dem Stack
  procedure PopFromStack;
  begin
    dec (Stacksize);
  end;

var Gewinn:currency; //Gewinn des besten gefundenen Tauschzykluses
    BestZyklus:array of integer; //Bester gefundener Zyklus
    adjaMatrix:TAdjazenzMatrix;  //Adjazenz-Matrix für den Graph

  //Berechnet den besten Zyklus
  procedure GenerateZyklus(const matrix:TAdjazenzMatrix);
  var newMatrix:TAdjazenzMatrix; //Matrix, in der der neue Graph gespeichert wird
      x,y:integer;               //Schleifenvariablen
      newGewinn:currency;        //Neuer Durchschnittsgewinn
  begin
    x:=GetFromStack; //Nummer des aktuellen Elements
    if (x =ZyklusStack[0])and(stacksize>1) then begin //Zyklus entdeckt
      newGewinn:=1; //Neuen Durchschnittgewinn berechnen
      for x:=1 to stacksize-1 do
        newGewinn:=newGewinn*adjaMatrix[zyklusStack[x-1],zyklusStack[x]];

      newGewinn:=Power(newGewinn,1/(stacksize-1)); //geometrisches Mittel
      if newGewinn>gewinn then begin //Ist der neue Gewinn besser?
        SetLength(BestZyklus,stacksize); //Aktuellen Zyklus speichern
        move(ZyklusStack[0],BestZyklus[0],StackSize*sizeof(integer));
        Gewinn:=newGewinn;
      end;
      exit;
    end;
    newMatrix:=matrix;                             //Erzeugt eine neue Matrix
    SetLength(newMatrix,length(newMatrix));        //mit gleichen Werten
    SetLength(newMatrix[x],length(newMatrix[x]));  //wie die übergebene
    for y:=0 to high(matrix[x]) do begin         //Aktuelle Position durchlaufen
      if matrix[x,y]<>0 then begin                 //Verbindung von x zu y?
        newMatrix[x,y]:=0;                         //Verbindung löschen
        pushToStack(y);                           //y in den Stack als Parameter
        GenerateZyklus(newMatrix);                 //Rekursiv neu starten
        PopFromStack;                              //y wieder entfernen
        newMatrix[x,y]:=matrix[x,y];               //Verbindung wiederherstellen
      end;
    end;
  end;

var i:Integer;
    _wert,_n2:string;
    n1,n2:integer;
    wert:currency;
    temps:string;
begin
  StackSize:=0;

  DecimalSeparator:=',';  //Deutsche Ländereinstellung, je nach Computer
  ThousandSeparator:='.'; //meistens schon der Standard

  //======Erstmal die Währungs-Namen in Zahlen konvertieren======
  SetLength(namen,0);
  for i:=0 to Memo1.lines.count-1 do
    AddName(GetShortHint(Memo1.lines[i])); //GetshortHint trennt an ersten |
                                           //und liefert den Text davor

  //=======Adjazenzmatrix berechnen========
  //Matrix initialisieren
  SetLength(adjaMatrix,length(namen),length(namen));
  for i:=0 to high(adjaMatrix) do
    ZeroMemory(adjaMatrix[0],sizeof(currency)*length(adjaMatrix[i]));

  //Umrechnungszahlen einfügen
  for i:=0 to Memo1.lines.count-1 do begin
    _wert:=GetLongHint(Memo1.lines[i]); //G.L.H wie G.S.H nur den Text dahinter
    _n2:=GetLongHint(_wert);
    n2:=findName(_n2);
    if n2 = -1 then begin
      showMessage('Unbekannte Währung: '+_n2);
      continue; //Wenn die Währung eine Sackgasse ist, ist sie unwichtig
    end;
    wert:=StrToFloat( GetShortHint(_wert));
    n1:=findName(GetShortHint(Memo1.lines[i]));
    if adjaMatrix[n1,n2]<wert then adjaMatrix[n1,n2]:=wert;
  end;

  Gewinn:=0;
  for i:=0 to high(adjaMatrix) do begin
    StackSize:=1;
    ZyklusStack[0]:=i;
    GenerateZyklus(adjaMatrix);
  end;

  if gewinn=0 then ShowMessage('Kein Zyklus vorhanden')
  else begin

    temps:='maximal Zyklus gefunden: '+namen[BestZyklus[0]];

    for i:=1 to high(BestZyklus) do temps:=temps+'->'+namen[BestZyklus[i]];
    temps:=temps+#13#10'Der Durchschnitt Gewinn pro Tausch beträgt ~ '+ FloatToStr(Gewinn-1)+'%';
    if gewinn=1 then temps:=temps+#13#10'Allerdings gibt es bei diesem Tauschzyklus keinen echten Gewinn';
    ShowMessage(temps);
  end;
end;

end.
