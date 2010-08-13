unit Grab_u;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,math;

type
  {$Z4} //Aufzählungswerte als 32 Bit Zahlen speichern
  TFeld=(fOffen,fImBerg,fDiamant);
  TKarte=array of array of TFeld;
  TfrmGrab = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    Edit1: TEdit;
    Label2: TLabel;
    Edit2: TEdit;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    SaveDialog2: TSaveDialog;
    image1: TImage;
    procedure setClick(Sender: TObject);
    procedure image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure saveClick(Sender: TObject);
    procedure loadClick(Sender: TObject);
    procedure solveClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private-Deklarationen}
  public
    { Public-Deklarationen}
    karte:TKarte;
    wegKarte:array of array of boolean;
    procedure UpdateImage;
    function IsRandFeld(const x,y:integer):boolean; //Testet ob [x,y] am Rand sind
    procedure GoFromTo(const x1,y1,x2,y2:integer); //Zeichnet
  end;

var
  frmGrab: TfrmGrab;

implementation

{$R *.DFM}

procedure TfrmGrab.saveClick(Sender: TObject);
var datei:TFileStream;
    i:integer;
begin
if SaveDialog1.Execute then begin //Wurde eine Datei ausgewählt
   if pos('.',SaveDialog1.FileName)<=0 then
     SaveDialog1.FileName:=SaveDialog1.FileName+'.bwg';
   datei:=TFileStream.create(SaveDialog1.FileName,fmCreate); //Datei erzeugen
   try
     //Kartengröße speichern
     i:=length(karte);
     datei.Write(i,sizeof(i));
     i:=length(karte[0]);
     datei.Write(i,sizeof(i));
     //Zustand der Karte speichern (horizontal durchlaufen und Spalte sichern)
     for i:=0 to high(karte) do
       datei.Write(karte[i,0],sizeof(karte[i,0])*length(karte[i]));
   finally
     datei.free; //Datei freigeben
   end;
end;
end;

procedure TfrmGrab.loadClick(Sender: TObject);
var datei:TFileStream;
    i,i2:integer;
begin
if OpenDialog1.Execute then begin //Wurde eine Datei ausgewählt
   datei:=TFileStream.create(OpenDialog1.FileName,fmOpenRead); //Datei laden
   try
     //Kartengröße laden
     datei.Read(i,sizeof(i));
     datei.Read(i2,sizeof(i2));
     SetLength(karte,i,i2); //Größe setzen
     //Zustand der Karte laden (horizontal durchlaufen und Spalte ersetzen)
     for i:=0 to high(karte) do
       datei.Read(karte[i,0],sizeof(karte[i,0])*length(karte[i]));
   finally
     datei.free; //Datei freigeben
   end;
end;
UpdateImage;
end;

//Setzt die Größe des Feldes
procedure TfrmGrab.setClick(Sender: TObject);
begin
  SetLength(karte,StrToInt(edit2.text),StrToInt(edit1.text));
end;

//Zeichnet das Feld
procedure TfrmGrab.UpdateImage;
var x,y:integer;
begin
  if length(karte)=0 then exit;
  with image1.Canvas do begin
    //Hintergrund
    brush.Color:=clAqua;
    pen.Color:=clAqua;
    pen.width:=2;
    FillRect(rect(0,0,image1.width,image1.Height));

    //Felder
    for x:=0  to high(karte) do
      for y:=0 to high(karte[x]) do begin
        case karte[x,y] of
          fOffen: brush.Color:=clAqua;
          else brush.Color:=clRed; //Eisenoxidhaltiger Berg
        end;
        Rectangle(x*15,y*15,x*15+15,y*15+15);
        if karte[x,y]=fDiamant then begin
          //Diamant als Kreis drauf zeichnen
          brush.Color:=clYellow;
          pen.Style:=psClear;
          Ellipse(x*15+5,y*15+5,x*15+10,y*15+10);
          pen.Style:=psSolid;
        end;
      end;
  end;
end;


procedure TfrmGrab.image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  x:=x div 15; //Mauposition zu Kartenposition umrechnen
  y:=y div 15;
  if (x<0)or(y<0)or(x>high(karte))or(y>high(karte[0])) then
    exit; //Wenn nicht in der Karte abbrechen
  if button=mbLeft then begin
    if karte[x,y]=fOffen then karte[x,y]:=fImBerg
    else karte[x,y]:=fDiamant;
  end else
    if karte[x,y]=fDiamant then karte[x,y]:=fImBerg
    else karte[x,y]:=fOffen;
  UpdateImage;
end;


//Testet ob ein Feld ein Randfeld ist, von dem das Graben losgehen kann
function TfrmGrab.IsRandFeld(const x,y:integer):boolean;
begin
  //Ist das Feld am Kartenrand?
  if x<=0 then Result:=true
  else if y<=0 then Result:=true
  else if x>=high(karte) then result:=true
  else if y>=high(karte[0]) then result:=true
  else begin
    //Wenn nicht, überprüfen ob alle Nachbarn vorhanden sind.
    result:=karte[x-1,y]=fOffen;
    result:=result or (karte[x+1,y]=fOffen);
    result:=result or (karte[x,y-1]=fOffen);
    result:=result or (karte[x,y+1]=fOffen);
  end;
end;

//Zeichnet einen Weg zwischen zwei Feldern

procedure TfrmGrab.GoFromTo(const x1,y1,x2,y2:integer);
  function CanGoFromTo(const x1,y1,x2,y2:integer):boolean;
  var i:integer;
  begin
    result:=false;
    if x1<x2 then begin
      for i:=x1 to x2 do result:=result or wegkarte[i,y1];
    end else if x1>x2 then begin
      for i:=x2 to x1 do result:=result or wegkarte[i,y1];
    end else if y1<y2 then begin
      for i:=y1 to y2 do result:=result or wegkarte[x1,i];
    end else if y1>y2 then begin
      for i:=y2 to y1 do result:=result or wegkarte[x1,i];
    end;
    result:=not result;
  end;
  procedure GoFromToReal(const x1,y1,x2,y2:integer);
  //Geht nicht um die Ecke und markiert als gelaufen
  var i:integer;
  begin
    //Zeichnen
    image1.Canvas.MoveTo(x1*15+7,y1*15+7);
    image1.Canvas.LineTo(x2*15+7,y2*15+7);
    if x1<x2 then begin
      for i:=x1+1 to x2-1 do wegkarte[i,y1]:=true;
    end else if x1>x2 then begin
      for i:=x2+1 to x1-1 do wegkarte[i,y1]:=true;
    end else if y1<y2 then begin
      for i:=y1+1 to y2-1 do wegkarte[x1,i]:=true;
    end else if y1>y2 then begin
      for i:=y2+1 to y1-1 do wegkarte[x1,i]:=true;
    end;
  end;
begin
  with image1.Canvas do begin
    pen.Color:=clGray;
    pen.width:=3;
    pen.Style:=psSolid;
  end;
  if (x1=x2)or(y1=y2) then GoFromToReal(x1,y1,x2,y2)
  else begin
    //Jetzt gibt es zwei Möglichkeiten
    if CanGoFromTo(x1,y1,x2,y1) and CanGoFromTo(x2,y1,x2,y2) then begin
      GoFromToReal(x1,y1,x2,y1);
      GoFromToReal(x2,y1,x2,y2);
    end else begin
      GoFromToReal(x1,y1,x1,y2);
      GoFromToReal(x1,y2,x2,y2);
    end;
  end;
end;

procedure TfrmGrab.solveClick(Sender: TObject);
type TDiamant=record
       nearestPlaces: array of TPoint;//Das einzigste Randfeld ist immer das letzte Feld
       pos:TPoint;
     end;
     TDiamanten= array of TDiamant;
     TIntArray=array of integer;
     TVerbindung=record //Typ für eine Verbindung zwischen zwei Feldern
       x1,y1,x2,y2:integer; //Position der Felder auf der Karte
       startIndex,EndIndex:integer; //Wenn vorhanden, Feldindices im Array
     end;
     TWeg=array of TVerbindung; //Mehrere Verbindungen ergeben einen Weg
     TWege=array of TWeg; //Mehrere Wege


var Wege:TWege; //Variable, die mögliche Wege enthält

//Sucht rekursiv und rückwärts Wege (die aber meistens nur Wegstücke sind)
  procedure FindWegRek(const verbindungen:TWeg;const dia:TDiamanten;const last:integer);
    //Testet ob ein Feld bisher noch nicht als Startfeld verwendet wurde
    function IsFieldFree(const x,y:integer):boolean;
    var i:integer;
    begin
      result:=false;
      for i:=0 to high(verbindungen) do
        if (verbindungen[i].x1=x)and(verbindungen[i].y1=y) then exit;
      result:=true;
    end;
  var i,j:integer;
      newVerbindungen:TWeg;
  begin
    //Speicher für neue Verbindungen holen
    newVerbindungen:=verbindungen;
    SetLength(newverbindungen,length(verbindungen)+1);
    with newVerbindungen[high(newVerbindungen)] do begin
      //Startfeld: aktuelle Position
      x1:=dia[last].pos.x;
      y1:=dia[last].pos.y;
      startIndex:=last;

      //Endfeld: das nächste Randfeld
      x2:=dia[last].nearestPlaces[high(dia[last].nearestPlaces)].x;
      y2:=dia[last].nearestPlaces[high(dia[last].nearestPlaces)].y;
      EndIndex:=-1;

      //Die bisherigen Verbindugen (bisheriger Weg) speichern
      SetLength(wege,length(wege)+1);
      Wege[high(wege)]:=newVerbindungen;
      SetLength(Wege[high(wege)],length(Wege[high(wege)]));
    end;

    //Die Felder durchlaufen, von denen man zum aktuellen Feld gelangen kann
    for i:=0 to high(dia[last].nearestPlaces)-1 do begin
      //Ist das Feld noch nicht von einer Verbindung blockiert?
      if IsFieldFree(dia[last].nearestPlaces[i].x,dia[last].nearestPlaces[i].y) then begin
        //Diamanten durchlaufen, um den Index zu finden und um die Verarbeitung
        //rekursiv fortsetzen zu können
        for j:=0 to high(dia) do
          if (dia[j].pos.x=dia[last].nearestPlaces[i].x) and
             (dia[j].pos.y=dia[last].nearestPlaces[i].y) then begin
                //Index in die Verbindungen einfügen
                newVerbindungen[high(newVerbindungen)].x2:=dia[j].pos.x;
                newVerbindungen[high(newVerbindungen)].y2:=dia[j].pos.y;
                newVerbindungen[high(newVerbindungen)].EndIndex:=j;
                //Starten
                FindWegRek(newVerbindungen,dia,j);
                break;
          end;
      end;
    end;
  end;

var Diamanten:TDiamanten;

  //Speichert das Feld [x,y] in dem nearestPlaces Array vom letzten Diamanten
  procedure Insert(const x,y:integer);
  begin
    SetLength(diamanten[high(diamanten)].nearestPlaces,length(diamanten[high(diamanten)].nearestPlaces)+1);
    diamanten[high(diamanten)].nearestPlaces[high(diamanten[high(diamanten)].nearestPlaces)].x:=x;
    diamanten[high(diamanten)].nearestPlaces[high(diamanten[high(diamanten)].nearestPlaces)].y:=y;
  end;


var MinimalWeg:TWeg; //Bisher gefundener kürzester Weg
    MinimalLength:integer; //Länge des kürzesten Weges

  //Versucht die gefundenen Wegestücke so zu kombinieren, dass alle Diamanten
  //gefunden werden und die Länge möglichst kurz ist
  procedure findMinimalWeg(const aktWeg:TIntArray);
  var i,j,l,t:integer;
      found:array of boolean;
      foundAll,foundOk:boolean;
      newWeg:TIntArray;
  begin
    //Feststellen, welche Diamanten vom aktuellen Weg gefunden werden
    SetLength(found,length(diamanten));
    ZeroMemory(@found[0],length(found)*sizeof(boolean));
    for i:=0 to high(aktWeg) do  //Getrennte Wege durchlaufen
      for j:=0 to high(wege[aktWeg[i]]) do //Den Weg durchlaufen
        //Diamant mit dem End-Index (die Daten werden rückwärts gespeichert) auf gefunden setzen
        found[wege[aktWeg[i]][j].startIndex]:=true;
    //Testen ob alle gefunden wurden
    foundAll:=true;
    for i:=0 to high(found) do
      if not found[i] then begin
        foundAll:=false;
        break;
      end;
    //Wenn alle Diamanten auf dem Weg gesammelt werden können, Weg-Länge betrachten
    if foundAll then begin
      l:=0;
      for i:=0 to high(aktWeg) do //Getrennte Wege durchlaufen
        for j:=0 to high(wege[aktWeg[i]]) do //Weg durchlaufen
          //Länge berechnen:
          if wege[aktWeg[i]][j].EndIndex=-1 then
            inc(l,abs(wege[aktWeg[i]][j].x1-wege[aktWeg[i]][j].x2)+
                  abs(wege[aktWeg[i]][j].y1-wege[aktWeg[i]][j].y2))
           else //Diamant nicht mitzählen (da sie eh immer da sind) 
            inc(l,abs(wege[aktWeg[i]][j].x1-wege[aktWeg[i]][j].x2)+
                  abs(wege[aktWeg[i]][j].y1-wege[aktWeg[i]][j].y2)-1);
      if l<MinimalLength then begin //Weg kürzer als der bisherige?
        //Weg speichern
        SetLength(MinimalWeg,0);
        for i:= 0 to high(aktWeg) do begin
          t:=length(minimalWeg);
          SetLength(minimalWeg,t+length(wege[aktWeg[i]]));
          for j:=t to high(minimalWeg) do
            MinimalWeg[j]:=wege[aktWeg[i],j-t];
        end;
        //Länge speichern
        minimalLength:=L;
      end;
      exit;
    end;
    newWeg:=aktWeg;
    SetLength(newWeg,length(newWeg)+1);
    for i:=0 to high(wege) do begin
      foundOk:=true;
      for j:=0 to high(wege[i]) do
        if found[wege[i,j].startIndex] then begin
          foundOk:=false;
          break;
        end;
      if foundOk then begin
        newWeg[high(newWeg)]:=i;
        findMinimalWeg(newWeg);
      end;
    end;
  end;

var xd,yd:integer;
    r,p:integer;
    i,j,k,len:integer;
    Rand:TPoint;
    found:boolean;
    CountDiamant:array of boolean;
    tempverbindung:TVerbindung;
    label BreakSearchFieldsLoopLab, BreakSearchDiamantLab;
begin
  SetLength(wegKarte,length(Karte),length(karte[0]));
  for i:=0 to high(wegkarte) do
    ZeroMemory(@wegkarte[i,0],length(wegkarte[0])*sizeof(boolean));

  SetLength(diamanten,0);
  for xd:=0 to high(karte) do
    for yd:=0 to high(karte[xd]) do begin
      if karte[xd,yd]=fDiamant then begin //Diamant gefunden
        //Diamant merken
        SetLength(Diamanten,length(Diamanten)+1);
        with diamanten[high(diamanten)] do begin
          pos.x:=xd;
          pos.y:=yd;
        end;
        //Jetzt muss solange auf sich vergrößernden Manhattan-Kreisen um den
        //Diamanten gegangen werden, bis ein Randfeld gefunden wird.
        Rand.x:=-1;
        if IsRandFeld(xd,yd) then begin
          insert(xd,yd);
          break;
        end;
        //Manhattankreise durchsuchen
        for r:=1 to min(length(karte),length(karte[0])) do begin
          //Obere rechte Seite des Manhattan-Kreises
          for p:=0 to r do begin
            if (xd+p>high(karte)) then break;
            if (yd-r+p<0)then continue;
            if (karte[xd+p,yd-r+p]=fDiamant) then Insert(xd+p,yd-r+p)
            else if (IsRandFeld(xd+p,yd-r+p)) then begin
              rand.x:=xd+p;
              rand.y:=yd-r+p;
            end;
          end;
          
          //Obere linke Seite des Manhattan-Kreises
          for p:=1 to r do begin
            if (xd-p<0) then break;
            if (yd-r+p<0)then continue;
            if (karte[xd-p,yd-r+p]=fDiamant) then Insert(xd-p,yd+p-r)
            else if (IsRandFeld(xd-p,yd-r+p)) then begin
              rand.x:=xd-p;
              rand.y:=yd+p-r;
            end;;
          end;

          //Untere rechte Seite des Manhattan-Kreises
          for p:=0 to r do begin
            if (xd+p>high(karte)) then break;
            if (yd+r-p>high(karte[0]))then continue;
            if (karte[xd+p,yd+r-p]=fDiamant) then Insert(xd+p,yd-p+r)
            else  if (IsRandFeld(xd+p,yd+r-p)) then begin
              rand.x:=xd+p;
              rand.y:=yd-p+r;
            end;
          end;
          //Untere linke Seite des Manhattan-Kreises
          for p:=1 to r do begin
            if (xd-p<0) then break;
            if (yd+r-p>high(karte[0]))then continue;
            if (karte[xd-p,yd+r-p]=fDiamant) then Insert(xd-p,yd-p+r)
            else if (IsRandFeld(xd-p,yd+r-p)) then begin
              rand.x:=xd-p;
              rand.y:=yd-p+r;
            end;
          end;
          //Nach dem Finden eines Randfeldes abbrechen
          if Rand.x<>-1 then begin
            insert(rand.x,rand.y);
            goto BreakSearchFieldsLoopLab;
          end;
        end;
        BreakSearchFieldsLoopLab:
      end;
    end;
  //Alle Diamanten durchlaufen und versuchen einen zu finden, der nur von einem
  //Feld schnell zu erreichen ist und nicht in der Nähe eines anderen ist
  len:=0;
  for i:=high(diamanten) downto 0 do begin //Rückwärts für einfaches Löschen
    if length(Diamanten[i].nearestPlaces)=1 then begin
      //Wird er sonst nirgens erwähnt, kann er aus der Liste gelöscht werden
      found:=false;
      for j:=0 to high(diamanten) do
        if i<>j then
          for k:=0 to high(diamanten[j].nearestPlaces) do
            if (diamanten[j].nearestPlaces[k].x=Diamanten[i].pos.x)and
             (diamanten[j].nearestPlaces[k].y=Diamanten[i].pos.y) then begin
              found:=true;
              goto BreakSearchDiamantLab;
            end;

      BreakSearchDiamantLab:
      if not found then begin
        inc(len,abs(Diamanten[i].nearestPlaces[0].x-Diamanten[i].pos.x)+
                abs(Diamanten[i].nearestPlaces[0].y-Diamanten[i].pos.y)+1);
        GoFromTo(Diamanten[i].nearestPlaces[0].x,Diamanten[i].nearestPlaces[0].y,
          Diamanten[i].pos.x,Diamanten[i].pos.y);
        Diamanten[i]:=diamanten[high(diamanten)];
        setLength(diamanten,high(diamanten));
      end;
    end;
  end;
  //Die restlichen Kombinationen rekursiv durchprobieren

  for i:=0 to high(diamanten) do FindWegRek(nil,Diamanten,i);

  SetLength(CountDiamant,length(diamanten));

  MinimalLength:=maxint;
  if length(diamanten)<>0 then begin
    findMinimalWeg(nil);

    ZeroMemory(@countDiamant[0],length(countDiamant)*sizeof(boolean));
  end else begin
    minimalWeg:=0;
    minimalLength:=0;
  end;
  //Weg rückwärts mit Selectsort so sortieren, dass Haken am Schluss kommen (für Abzweigungsvermeidung)
  for i:=high(MinimalWeg) downto 0 do begin
    found:=false;
    for j:=0 to i-1 do  //Haken finden
      if (MinimalWeg[j].x1<>MinimalWeg[j].x2) and (MinimalWeg[j].y1<>MinimalWeg[j].y2) then begin
        tempverbindung:=minimalWeg[j];
        minimalWeg[j]:=minimalWeg[i];
        minimalWeg[i]:=tempverbindung;
        found:=true;
        break;
      end;
    if not found then //Keine Haken mehr vorhanden
      break;
  end;
  //Weg ausgeben
  for i:=0 to high(MinimalWeg) do
    GoFromTo(minimalweg[i].x1,minimalweg[i].y1,minimalweg[i].x2,minimalweg[i].y2);
  image1.canvas.brush.Style:=bsClear;
  image1.Canvas.TextOut(2,length(karte[0])*15+5,'Es muss in '+
    IntToStr(len+MinimalLength+length(diamanten))+' Planquadraten gegraben werden');

    if SaveDialog2.Execute then begin
      if pos('.',saveDialog2.FileName)<=0 then //Endung hinzufügen
        saveDialog2.FileName:=saveDialog2.FileName+'.bmp';
      image1.picture.bitmap.SaveToFile(saveDialog2.FileName);
    end;
end;


procedure TfrmGrab.FormResize(Sender: TObject);
begin
  image1.Picture.Bitmap.Width:=image1.width;
  image1.Picture.Bitmap.height:=image1.height;
end;

end.

//6:30
//Es muss in 1.463.173.695

