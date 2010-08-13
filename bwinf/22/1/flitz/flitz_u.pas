unit flitz_u;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls,math, Grids;
const frustumHeight=150;
      frustumWidth=40;
type TSozialVerhalten=(svNeutral,svLiebt,svHasst);
     TFisch=record
       //Fischdefinitionen (A1):
       rotation:single;
       x,y:single;
       //Sonstiges:
       //Farbe (A1):
       color:TColor;
       //"Drehpanik": (noch A1)
       zielrot,richtung: single;
       //Redunante Informationen (A2):
       intpos,frustum1,frustum2:TPoint;
       //Sozialverhalten (A3)
       sozialVerhalten:array of TSozialVerhalten;
     end;
type
  TfrmFlitz = class(TForm)
    Timer1: TTimer;
    Panel2: TPanel;
    Label5: TLabel;
    StringGrid1: TStringGrid;
    Label4: TLabel;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    Panel1: TPanel;
    Panel3: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    PaintBox1: TPaintBox;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Edit4: TEdit;
    Label6: TLabel;
    procedure Edit1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Edit2Change(Sender: TObject);
  private
    { Private-Deklarationen}
    fische:array of TFisch;
    EllipsenWidth,EllipsenHeight,radius:integer; //Teichgröße und Ellipsenradius
    RadiusDiff:single;   //(Teichbreite geteilt durch Höhe) zum Quadrat 
    LovedFish:integer;   //Index des geliebten Fisches
    procedure SetFischCount(const newlen:cardinal);

    function GetDistanceAt(x,y:integer;rotation:single):single;
  public
    { Public-Deklarationen}
  end;

var
  frmFlitz: TfrmFlitz;

implementation

{$R *.DFM}
procedure NormalizeAngle(var rot:single);
//Bringt den Winkel durch sukksessives addieren von 2pi in dem Bereich 0 bis 2pi
begin
  if (rot<-2*pi)or(rot>2*2*pi) then
    rot:=rot-2*pi*trunc(rot/2*pi) //Durch das Teilen ziemlich langsam
   else //Deshalb, wenn abs(rot/2*pi) 1 ist, nur einmal addieren/subtrahieren
    if rot> 2*pi then rot:=rot-2*pi
    else if rot<0 then rot:=rot+2*pi;
end;
function TfrmFlitz.GetDistanceAt(x,y:integer;rotation:single):single;
var a,b:single;
    pHalbe,wurzel:single;
    XSchnitt,YSchnitt:single;
begin
  //Randdistanz berechnen
  NormalizeAngle(rotation);

  //Nullpunkt ist zum Ellipsenmittelpunkt verschieben
  x:=x-EllipsenWidth div 2;
  y:=y-EllipsenHeight div 2;
  if (rotation=0)or(rotation=pi) then begin //Steigung wäre unendlich
    XSchnitt:=x; //Schnittpunkt an der selben x-Koordinaten
    //In Kreisgleichung einsetzten:
    YSchnitt:=sqrt(radius*radius-XSchnitt*XSchnitt/radiusDiff);
    if rotation<>0 then YSchnitt:=-YSchnitt;
  end else begin
    //Gleichung der Sichtlinie des Fisches berechnen
    a:=cos(rotation)/sin(rotation);
    b:=y-a*x;

    //Allgemeine Lösungsformel für quadratische Gleichungen anwenden
    wurzel:=sqr(a*b/(1/RadiusDiff+a*a))-(b*b-radius*radius)/(1/RadiusDiff+a*a);
    if wurzel<0 then begin
      Result:=maxInt; //Entfernung wäre imaginär
      exit;
    end;
    wurzel:=sqrt(wurzel);
    pHalbe:=-a*b/(1/RadiusDiff+a*a);
    if rotation<pi then XSchnitt:=pHalbe+wurzel //Das größere X Nehmen
    else XSchnitt:=pHalbe-wurzel;

    //Einsetzten von x in die Ellipsengleichung

    YSchnitt:=radius*radius-XSchnitt*XSchnitt/RadiusDiff;
    if YSchnitt < 0 then  begin
      Result:=maxInt; //Entfernung wäre imaginär
      exit;
    end;
    YSchnitt:=sqrt(YSchnitt);
    if abs(a*XSchnitt+b-YSchnitt)>2 then YSchnitt:=-YSchnitt; //Schnittpunkt unten
  end;

  //Pythagoras beschwören
  Result:=sqrt(sqr(XSchnitt-x)+sqr(YSchnitt-y));
end;

procedure TfrmFlitz.SetFischCount(const newlen:cardinal);
function GetFishColor:TColor;
begin
  result:=rgb(random(100)+128,random(120)+128,0);
end;
var oldlen,i,j:cardinal;
    zuneigung,abneigung:cardinal;
    distance:integer;
begin
  oldlen:=length(fische);
  if newlen<oldlen then SetLength(fische,newlen)
  else if newlen>oldlen then begin
    SetLength(fische,newlen);
    for i:=oldlen to newlen-1 do
      with fische[i] do begin
        color:=GetFishColor;

        rotation:=random(trunc(2*pi*2048))/2048; //Zufallsrotation
        //Entfernung des Fisches vom Nullpunkt, die Entfernung und rotation
        //bilden zusammen die Polarkoordinaten des Fisches
        distance:=random(trunc(GetDistanceAt(EllipsenWidth div 2, EllipsenHeight div 2,rotation)));

        //Zu kartesischen umrechnen
        x:=sin(rotation)*distance+EllipsenWidth/2;
        y:=cos(rotation)*distance+EllipsenHeight/2;

        //Position als integer Wert speichern
        intpos.x:=trunc(x);
        intpos.y:=trunc(y);

        //Neue Rotation
        rotation:=random(trunc(2*pi*2048))/2048;
        zielrot:=rotation;

        //Rotiert das Frustumdreieck
        frustum1.X:=trunc(sin(rotation)*frustumHeight-cos(rotation)*frustumWidth)+intpos.x;
        frustum1.Y:=trunc(cos(rotation)*frustumHeight+sin(rotation)*frustumWidth)+intpos.y;
        frustum2.X:=trunc(sin(rotation)*frustumHeight+cos(rotation)*frustumWidth)+intpos.x;
        frustum2.Y:=trunc(cos(rotation)*frustumHeight-sin(rotation)*frustumWidth)+intpos.y;

      end;
  end;
  StringGrid1.ColCount:=newlen+1;
  StringGrid1.RowCount:=newlen+1;
  if length(fische)>0 then begin
    StringGrid1.FixedCols:=1;
    StringGrid1.FixedRows:=1;
    for i:=0 to newLen-1 do
      StringGrid1.Cells[i+1,0]:=IntToStr(i);
    for i:=0 to newLen-1 do
      StringGrid1.Cells[0,i+1]:=IntToStr(i);
    if not radioButton1.checked then begin//Nicht die erste Alternative?
      fische[LovedFish].color:=GetFishColor;
      //Sozialverhalten neu berechnen:
      for i:=0 to high(fische) do begin
        if RadioButton2.Checked then zuneigung:=(newlen*30) div 100
        else zuneigung:=(newlen*70) div 100;
        abneigung:=newlen-zuneigung;
        SetLength(fische[i].sozialVerhalten,newLen);
        for j:=0 to newlen-1 do
          if i=j then StringGrid1.Cells[i+1,j+1]:='--'
          else if (abneigung=0)or ((random(101)<50)and(zuneigung>0)) then begin
            //Fisch j lieben Anzahl der Fische die geliebt werden dürfen verringern
            fische[i].sozialVerhalten[j]:=svLiebt;
            StringGrid1.Cells[i+1,j+1]:='liebt';
            dec(zuneigung);
          end else begin
            //Fisch j hassen und Anzahl der Fische die gehasst werden dürfen verringern
            fische[i].sozialVerhalten[j]:=svHasst;
            StringGrid1.Cells[i+1,j+1]:='hasst';
            dec(abneigung);
          end;
      end;
    end else begin
      fische[LovedFish].color:=clBlue;
      //Nur ins StringGrid schreiben
      StringGrid1.Cells[1,1]:='--';
      for i:=1 to newLen-1 do
        StringGrid1.Cells[i+1,1]:='hasst';
      for i:=1 to newLen-1 do
        StringGrid1.Cells[1,i+1]:='liebt';
      for i:=1 to newLen-1 do
        for j:=1 to newLen-1 do
          if i=j then StringGrid1.Cells[i+1,j+1]:='--'
          else StringGrid1.Cells[i+1,j+1]:='egal';
    end;
  end;
end;
procedure TfrmFlitz.Timer1Timer(Sender: TObject);
  function IsPointInKreis(x,y:integer):boolean;
  var wurzel:integer;
  begin//                    ________
    //Kreisgleichung: f(x)=-/r²-x²/d²
    x:=x-EllipsenWidth div 2;
    y:=y-EllipsenHeight div 2;
    wurzel:=radius*radius-trunc(x*x/RadiusDiff);
    wurzel:=round(sqrt(wurzel));
    result:=(y<=wurzel+2)and(y>=-wurzel-2);
  end;


  function CrossProduct3DWithSubtraction(const p1,p2,s:TPoint):integer;
  //z-Wert des Kreuzproduktes zwischen p1-s und p2-s berechnen
  begin
    result:= (p1.X-s.x) * (p2.Y-s.y)-(p1.Y-s.y) * (p2.X-s.x);
  end;

  function IsPointVisibleForFish(const fish:TFisch;const p1:TPoint):boolean;
  //Ist Punkt p für den Fisch fish sichtbar
  begin
    //Kreissichtbereich
    if sqr(fish.intpos.x-p1.x)+sqr(fish.intpos.y-p1.y)<225 then begin
      result:=true;
      exit;
    end;

    //Dreiecksichtbereich
    Result:=false;
    if CrossProduct3DWithSubtraction(fish.frustum2,p1,fish.intpos)*
       CrossProduct3DWithSubtraction(fish.frustum2,fish.frustum1,fish.intpos)<0 then exit;

    if CrossProduct3DWithSubtraction(fish.frustum2,p1,fish.frustum1)*
       CrossProduct3DWithSubtraction(fish.frustum2,fish.intpos,fish.frustum1)<0 then exit;

    if CrossProduct3DWithSubtraction(fish.intpos,p1,fish.frustum1)*
       CrossProduct3DWithSubtraction(fish.intpos,fish.frustum2,fish.frustum1)<0 then exit;

    result:=true;
  end;

  function IsPointLeftFromFish(const fish:TFisch;const p:TPoint):boolean;
  //Testet ob der Punkt p links vom Fisch fish ist
  var fishLook:TPoint;
  begin
    fishLook.x:=trunc(sin(fish.rotation)*1000);
    fishLook.y:=trunc(cos(fish.rotation)*1000);
    result:=CrossProduct3DWithSubtraction(fish.intpos,p,fishLook)*
            CrossProduct3DWithSubtraction(fish.intpos,fish.frustum1,fishLook)>=0;
  end;

  procedure TestGehasste(const i:integer;out GeLiebte_HassteLeft,GeLiebte_HassteRight:integer);
  var j:integer;
  begin
    GeLiebte_HassteLeft:=0;
    GeLiebte_HassteRight:=0;
    if RadioButton1.Checked then begin
      if i=LovedFish then begin
        for j:=0 to high(fische) do
          if (i<>j) and(IsPointVisibleForFish(fische[i],fische[j].intpos)) then
            //Fisch j ist i unsympathisch
            if IsPointLeftFromFish(fische[i],fische[j].intpos) then dec(GeLiebte_HassteLeft)
            else dec(GeLiebte_HassteRight);
      end else
        if IsPointVisibleForFish(fische[i],fische[LovedFish].intpos) then
            //geliebter Fisch gesehen
            if IsPointLeftFromFish(fische[i],fische[LovedFish].intpos) then inc(GeLiebte_HassteLeft)
            else inc(GeLiebte_HassteRight);
    end else begin
      for j:=0 to high(fische) do
        if (i<>j)and IsPointVisibleForFish(fische[i],fische[j].intpos) then
          case fische[i].sozialVerhalten[j] of
            svLiebt: //Wenn Fisch i den Fisch j liebt, erhöhen
              if IsPointLeftFromFish(fische[i],fische[j].intpos) then inc(GeLiebte_HassteLeft)
              else inc(GeLiebte_HassteRight);
            svHasst: //Wenn Fisch i den Fisch j nicht mag, verringern
              if IsPointLeftFromFish(fische[i],fische[j].intpos) then dec(GeLiebte_HassteLeft)
              else dec(GeLiebte_HassteRight);
          end;
    end;
  end;
var doubleBuffer:Tbitmap;
    i:integer;
    GeLiebte_HassteLeft,GeLiebte_HassteRight:integer;
    randDistanz:integer;
    geschwindigKeit,oldx,oldy:single;
    schwanz:array of TPoint;
    circelRGN:HRGN;
begin
  //Fischpositionen updaten
  for i:=0 to high(fische) do begin
    //Fisch nach vorne schwimmen lassen
    if fische[i].zielrot=fische[i].rotation then begin
      randDistanz:=trunc(GetDistanceAt(fische[i].intpos.x,fische[i].intpos.y,fische[i].rotation));
      if randDistanz<35 then begin //Ist der Fisch in der Nähe des Randes
        NormalizeAngle(fische[i].rotation); //Winkel normalisieren, damit es keinen Überlauf gibt
        if GetDistanceAt(fische[i].intpos.x,fische[i].intpos.y,fische[i].rotation+pi/2)+
           GetDistanceAt(fische[i].intpos.x,fische[i].intpos.y,fische[i].rotation+pi/3) >
           GetDistanceAt(fische[i].intpos.x,fische[i].intpos.y,fische[i].rotation-pi/2)+
           GetDistanceAt(fische[i].intpos.x,fische[i].intpos.y,fische[i].rotation-pi/3) then begin
            fische[i].richtung:=1; //Der Rand links vom Fisch ist weiter entfernt als rechts
            fische[i].zielrot:=fische[i].rotation+pi/(2)
           end else begin //Der Rand rechts vom Fisch ist weiter entfernt als links
            fische[i].richtung:=-1;
            fische[i].zielrot:=fische[i].rotation-pi/(2);
           end;
        geschwindigKeit:=2;
      end else begin
        //Der Fisch hat freie Bahn zum Schwimmen, Sympathien zu den sichtbaren Fischen berechnen
        TestGehasste(i,GeLiebte_HassteLeft,GeLiebte_HassteRight);
        if (GeLiebte_HassteLeft>0)or(GeLiebte_HassteRight>0) then begin
          //Geliebte Fische gesehen
          if GeLiebte_HassteLeft>GeLiebte_HassteRight then begin
            //Fisch will nach links, um Freunde zu treffen
            geschwindigkeit:=3+0.5*max(GeLiebte_HassteLeft,6); //Schneller schwimmen
            fische[i].rotation:=fische[i].rotation-pi/64;
          end else begin
            //Fisch will nach rechts, um Freunde zu treffen
            geschwindigkeit:=3+0.5*max(GeLiebte_HassteRight,6); //Schneller schwimmen
            fische[i].rotation:=fische[i].rotation+pi/64;
          end;
        end else if (GeLiebte_HassteLeft<0)or(GeLiebte_HassteRight<0) then begin
          //Nur gehasste Fische vorhanden
          if GeLiebte_HassteLeft<GeLiebte_HassteRight then begin
            //Fisch will nicht nach links, da dort mehr unsympathische sind
            geschwindigkeit:=4-max(3,2*abs(GeLiebte_HassteRight)); //Langsamer schwimmen
            fische[i].rotation:=fische[i].rotation+pi/64;
          end else begin
            //Fisch will nicht nach rechts, da dort mehr unsympathische sind
            geschwindigkeit:=4-max(3,2*abs(GeLiebte_HassteLeft)); //Langsamer schwimmen
            fische[i].rotation:=fische[i].rotation-pi/64;
          end;
        end else geschwindigKeit:=3;
        fische[i].zielrot:=fische[i].rotation;
      end;
    end else begin
      //Durch drehen in die gespeicherte Richtung, entfernt sich der Fisch von der richtigen Blickrichtung
      if fische[i].richtung*fische[i].rotation>fische[i].richtung*fische[i].zielrot then
           fische[i].rotation:=fische[i].zielrot
      else begin
        //Mit einer Geschwindigeit Antiproportional zur Randentfernung in die gespeicherte
        //Richtung drehen.
        fische[i].rotation:=fische[i].rotation+
           pi/max(10,min(80,GetDistanceAt(fische[i].intpos.x,fische[i].intpos.y,fische[i].rotation)))*
             fische[i].richtung;
      end;
      geschwindigKeit:=1.5;
    end;
    oldx:=fische[i].x;
    oldy:=fische[i].y;
    fische[i].x:=fische[i].x+sin(fische[i].rotation)*geschwindigKeit;
    fische[i].y:=fische[i].y+cos(fische[i].rotation)*geschwindigKeit;
    if not IsPointInKreis(trunc(fische[i].x),trunc(fische[i].y)) then begin
      //Der Kreis ist so eng, dass der Fisch nicht wenden konnte und raus kam,
      //also muss er am Rand stecken bleiben
      fische[i].x:=oldx;
      fische[i].y:=oldy;
    end;
    fische[i].intpos.x:=trunc(fische[i].x);
    fische[i].intpos.y:=trunc(fische[i].y);
    //Rotiert das Frustumdreieck
    fische[i].frustum1.X:=trunc(sin(fische[i].rotation)*frustumHeight-cos(fische[i].rotation)*frustumWidth)+fische[i].intpos.x;
    fische[i].frustum1.Y:=trunc(cos(fische[i].rotation)*frustumHeight+sin(fische[i].rotation)*frustumWidth)+fische[i].intpos.y;
    fische[i].frustum2.X:=trunc(sin(fische[i].rotation)*frustumHeight+cos(fische[i].rotation)*frustumWidth)+fische[i].intpos.x;
    fische[i].frustum2.Y:=trunc(cos(fische[i].rotation)*frustumHeight-sin(fische[i].rotation)*frustumWidth)+fische[i].intpos.y;
  end;

  //Fische Ausgeben
  doubleBuffer:=TBitmap.Create;
  try
    //Doublebuffer auf die richtige Größe setzten
    with doubleBuffer do begin
      Width:=EllipsenWidth;
      Height:=EllipsenHeight;
      with Canvas do begin
        pen.Style:=psClear;;
        brush.color:=clGreen;
        //Hintergrundwiese zeichnen
        FillRect(rect(0,0,EllipsenWidth,EllipsenHeight));
        brush.color:=clAqua;
        //Teich zeichnen
        Ellipse(0,0,EllipsenWidth,EllipsenHeight);
        pen.Color:=clBlack;
        font.Style:=[fsBold];
        Color:=clYellow;
      end;
    end;
    //Nur in den Teich zeichnen
    circelRGN:=CreateEllipticRgn(0,0,EllipsenWidth,EllipsenHeight);
    SelectObject(doubleBuffer.Canvas.Handle,circelRGN);

    SetLength(schwanz,3);

    for i:=0 to high(fische) do begin
      doubleBuffer.Canvas.pen.Style:=psClear;
      doubleBuffer.Canvas.brush.style:=bsSolid;
      doubleBuffer.Canvas.brush.color:=fische[i].color;
      //Fischkopf zeichnen
      doubleBuffer.Canvas.Ellipse(fische[i].intpos.x-5,fische[i].intpos.y-5,fische[i].intpos.x+5,fische[i].intpos.y+5);
      //Fischschwanz berechnen
      schwanz[0].x:=trunc(-sin(fische[i].rotation)*4)+fische[i].intpos.x;
      schwanz[0].y:=trunc(-cos(fische[i].rotation)*4)+fische[i].intpos.y;
      schwanz[1].x:=trunc(-sin(fische[i].rotation)*10+cos(fische[i].rotation)*8)+schwanz[0].x;
      schwanz[1].y:=trunc(-cos(fische[i].rotation)*10-sin(fische[i].rotation)*8)+schwanz[0].y;
      schwanz[2].x:=trunc(-sin(fische[i].rotation)*10-cos(fische[i].rotation)*8)+schwanz[0].x;
      schwanz[2].y:=trunc(-cos(fische[i].rotation)*10+sin(fische[i].rotation)*8)+schwanz[0].y;
      //Fischschwanz nun ausgeben
      doubleBuffer.Canvas.Polygon(schwanz);

      doubleBuffer.Canvas.pen.Style:=psSolid;
      doubleBuffer.Canvas.brush.style:=bsClear;
      if CheckBox1.Checked then begin
        if fische[i].zielrot=fische[i].rotation then
          doubleBuffer.Canvas.pen.Color:=clBlack
         else
          doubleBuffer.Canvas.pen.Color:=clRed;
        //Sichtbereich zeichnen
        doubleBuffer.Canvas.MoveTo(fische[i].frustum1.X,fische[i].frustum1.Y);
        doubleBuffer.Canvas.LineTo(fische[i].intpos.x,fische[i].intpos.y);
        doubleBuffer.Canvas.LineTo(fische[i].frustum2.X,fische[i].frustum2.Y);
        doubleBuffer.Canvas.LineTo(fische[i].frustum1.X,fische[i].frustum1.Y);

        //Kreis zeichnen in dem Strömungen gefühlt werden können
        doubleBuffer.Canvas.Ellipse(fische[i].intpos.x-15,fische[i].intpos.y-15,fische[i].intpos.x+15,fische[i].intpos.y+15);
      end;
      if checkbox2.checked then //Wenn die Nummer ausgegeben werden soll, diese schreiben
        doubleBuffer.Canvas.TextOut(fische[i].intpos.x,fische[i].intpos.y,IntToStr(i));
    end;

    PaintBox1.Canvas.Draw(0,0,doubleBuffer); //Doublebuffer ausgeben
    DeleteObject(circelRGN); //Teichbegrenzung löschen
  finally
    doubleBuffer.free; //Doublebuffer freigeben
  end;
end;

procedure TfrmFlitz.Edit2Change(Sender: TObject);
begin
  //Wenn die Teichgröße geändert wurde, die Wert aktualisieren
  EllipsenWidth:=StrToIntDef(edit2.text,0);
  EllipsenHeight:=StrToIntDef(edit3.text,0);
  radius:=EllipsenHeight div 2;
  RadiusDiff:=sqr(EllipsenWidth/EllipsenHeight);
end;
procedure TfrmFlitz.Edit1Change(Sender: TObject);
begin
  //Wenn die Fischanzahl, der Simulationstyp, oder der geliebte Fisch verändert wurde,
  //aktuallisieren
  Edit4.Enabled:=RadioButton1.Checked;
  LovedFish:=StrToIntDef(Edit4.text,0);
  SetFischCount(StrToIntDef(edit1.text,0));
end;
procedure TfrmFlitz.FormCreate(Sender: TObject);
begin
  //Initialisierung
  randomize; //Zufallsgenerator
  Edit2Change(edit2); //Teichgröße
  LovedFish:=0; //geliebter Fisch
  SetFischCount(5); //Fische
end;

end.
