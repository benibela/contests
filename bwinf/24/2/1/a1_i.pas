unit a1_i;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,math, ComCtrls;

const inf=1.0/0.0;
      epsilon=1e-10;           //Kleinste berücksichtigte Differenz
type
  ppointf=^tpointf;
  tpointf=record               //Ein Punkt des Museums
    x,y: double;               //Seine Koordinten
  end;
  TSeenPos=record              //Eine sichtbarer Punkt auf einer Linie
      where: double	;          //Position auf der Linie (0: Start, 1: Ende)
      seeRight: boolean;       //liegt das Segment in Richtung Ende
      hiddenRaySide: integer;  //begrenzte Seite des Strahl zu diesem Punkt
      from,wherePos:tpointf;   //Strahlstartposition und getroffener Punkt
    end;
  TSeenArray=array of TSeenPos;//Mehrere getroffene Punkte (wird sortiert)

  PLine=^TLine;
  TLine=record
    start: tpointf;            //Startpunkt der Linie
    dir: tpointf;              //Richtung der Linie
    left,right:PLine;          //vorherige und nächste Linie

    sees:array of TSeenPos;    //auf der Linie getroffene Punkte
  end;
  TPolygon=array of TLine;     //Ein Polygon = eine Liniefolge

  TRayHitPoints=record         //Informationen über die Treffpunkte eines Strahls
    poly, line: integer;       //Getroffenes Polygon und dort getroffene Linie
    where, when: double;       //Position des Treffpunktes auf dem Strahl und der Linie
    between: array of record          //Passierte Ecken
               poly, point: integer;  //getroffenes Polygon und getroffener Punkt
               side: integer;         //Seite der Eckpunkte (beide sind auf derselben)
               when: double;          //Position auf dem Strahl
             end;
  end;
  TmuseumForm = class(TForm)
    Panel1: TPanel;
    outputPaintBox: TPaintBox;
    Label1: TLabel;
    museumFileName: TEdit;
    loadMuseum: TButton;
    Label2: TLabel;
    wayFileName: TEdit;
    loadWay: TButton;
    fillSeenAreas: TCheckBox;
    drawBorderedSeenAreas: TCheckBox;
    loadWayProbability: TButton;
    Label3: TLabel;
    wayProbabilityFileName: TEdit;
    polygonalMode: TRadioButton;
    probabilityMode: TRadioButton;
    Panel2: TPanel;
    showWayProbability: TRadioButton;
    showVisibility: TRadioButton;
    ProgressBar1: TProgressBar;
    progress: TLabel;
    procedure loadMuseumClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure outputPaintBoxPaint(Sender: TObject);
    procedure loadWayClick(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure outputPaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure outputPaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure fillSeenAreasClick(Sender: TObject);
    procedure loadWayProbabilityClick(Sender: TObject);
  private
    { Private-Deklarationen }
    clickPos, oldnullpoint:tpoint;
  public
    { Public-Deklarationen }
    zoom: double;                               //Zoomfaktor für die Ausgabe
    nullpoint:tpoint;                           //Verschiebungsfaktor  "
    museum: array of TPolygon;                  //Das geladene Museum
    museumSize: tpointf;                        //Größe des Museums 
    guardsWay: TPolygon;                        //Der Weg des Wächters
    seenAreas: array of array[0..3] of tpointf; //alle sichtbaren Bereiche

    invSeeProbability: array of array of double;
    invWayProbability: array of array of double;

    //Berechnet die von einem Punkt aus sichtbaren Segmente
    procedure lookFromPoint(const p: tpointf);
    //Berechnet die von einer Linie aus sichtbaren Segmente
    procedure lookFromWayLine(var line: TLine);
    //Wandelt die getroffenen Segmentpunkte in sichtbare Bereiche um
    procedure convertLookPoints;
    //Berechnet, alle von einem Weg aus sichtbaren Bereiche
    procedure lookAround();
  end;

var
  museumForm: TmuseumForm;

implementation

{$R *.DFM}

//================================File I/O======================================
//Lädt ein Polgon mit einer gegeben Anzahl von Punkten und sucht die minimalen
//und maximalen Koordinaten
function loadPolygon(var f: TextFile; len: integer; min,max: ppointf):TPolygon;
var i,j:integer;
    s:string;
begin
  SetLength(result,len);             //Speicher vorreservieren
  for i:=0 to len-1 do begin
    Readln(f,s);                     //Zeile lesen
    j:=pos(' ',s);                   //Trennzeichen zweischen zwei Koord. suchen
    with result[i].start do begin
      x:=StrToFloat(copy(s,1,j-1));  //erste Koordinate lesen
      delete(s,1,j);                 //sie zusammen mit dem Trennzeichen löschen
      y:=StrToFloat(s);              //zweite Koordinate lesen
      if max<>nil then begin         //äußerste Koordinaten suchen
        if (x>max.X) then max.X:=x;
        if (y>max.Y) then max.Y:=y;
      end;
      if min<>nil then begin
        if (x<min.X) then min.X:=x;
        if (y<min.Y) then min.Y:=y;
      end;
    end;
    if i<>0 then begin
      result[i].left:=@result[i-1];  //Zeiger auf vorherige Linie setzten
      result[i-1].right:=@result[i]; //Dort einen auf diese setzen
      result[i-1].dir.x:=result[i].start.x-result[i-1].start.x; //Richtung
      result[i-1].dir.y:=result[i].start.y-result[i-1].start.y; //  berechnen
    end;
  end;
  //Dasselbe wie am Ende der for-Schleife für die ersten Linie (Nachfolger der letzten)
  result[len-1].right:=@result[0];
  result[0].left:=@result[len-1];
  result[len-1].dir.x:=result[0].start.x-result[len-1].start.x;
  result[len-1].dir.y:=result[0].start.y-result[len-1].start.y;
end;

//Es wurde auf den Button zum Laden des Museums geklickt
procedure TmuseumForm.loadMuseumClick(Sender: TObject);
var museumFile: TextFile;
    s:string;
    maxP,minP: tpointf;
    i,j: integer;
begin
  SetLength(museum,0);
  //Koordinatengrenzen mit maximalen Grenzen besetzten
  maxP.x:=-inf;maxP.y:=-inf;
  minP.x:=inf;minP.y:=inf;
  //Datei laden
  AssignFile(museumFile,museumFileName.Text);
  reset(museumFile);
  repeat
    Readln(museumfile,s); //erste Zeile eines Polygones lesen
    if lowercase(copy(s,1,8))='polygon ' then begin
      delete(s,1,8);                      //"polygon " abschneiden
      SetLength(museum,length(museum)+1); //Neues Polygon anhängen
      //Polygon in nun reservierten Speicher laden
      museum[high(museum)]:=loadPolygon(museumFile,strtoint(s),@minP,@maxP)
    end else raise Exception.create('Can''t understand "'+s+'"'); //falsches Format
  until eof(museumFile);

  CloseFile(museumFile);

  museumSize.x:=maxP.X-minP.X;
  museumSize.y:=maxP.y-minP.y;
  if polygonalMode.checked then begin
    //Wenn der Algortihmus durch Polygonenanalyse arbeitet soll,
    //wird einfach ein passender Zoomfaktor gewählt
    zoom:=min(outputPaintBox.ClientHeight/(maxP.Y-minP.Y),
              outputPaintBox.ClientWidth/(maxP.X-minP.X));
  end else begin
    zoom:=max(museumSize.x,museumSize.y);
    //Sonst werden vorher die Koordinaten, in den 0 - 1 Bereich gemappt
    for i:=0 to high(museum) do
      for j:=0 to high(museum[i]) do begin
        museum[i,j].start.x:=(museum[i,j].start.x-minP.x)/zoom;
        museum[i,j].start.y:=(museum[i,j].start.y-minP.y)/zoom;
        museum[i,j].dir.x:=(museum[i,j].dir.x)/zoom;
        museum[i,j].dir.y:=(museum[i,j].dir.y)/zoom;
      end;
    zoom:=min(outputPaintBox.ClientHeight,outputPaintBox.ClientWidth);
  end;
  nullpoint.x:=0;
  nullpoint.y:=0;
  Refresh;
end;

//Einen Rundgang laden
procedure TmuseumForm.loadWayClick(Sender: TObject);
var  f: TextFile;
     len: integer;
begin
  AssignFile(f,wayFileName.Text);
  reset(f);
  Readln(f,len);                        //Anzahl der Punkte einlesen
  guardsWay:=loadPolygon(f,len,nil,nil);//Rundgang einlesen
  CloseFile(f);

  lookAround;                           //Sichtbarkeit berechnen

  Refresh;
end;

//==================================Ausgabe=====================================
procedure TmuseumForm.outputPaintBoxPaint(Sender: TObject);
  //Einen Punkt im Koordinatensystem des Museums ins Ausgabesystem umwandeln
  function transform(const p:tpointf): tpoint;
  begin
    result.x:=round(p.x*zoom)+nullpoint.x;
    result.y:=round(-p.y*zoom)+outputPaintBox.ClientHeight+nullpoint.y;
  end;
  //Ein Polygon zeichnen
  procedure drawPolygon(const p:TPolygon);
  var transformedPoly: array of tpoint;
      i:integer;
  begin
    SetLength(transformedPoly,length(p));
    for i:=0 to high(p) do
      transformedPoly[i]:=transform(p[i].start);
    outputPaintBox.Canvas.Polygon(transformedPoly)
  end;
var i,j:integer;
    temp: array[0..3] of tpoint;
    tempColor: integer;
begin
  if length(museum) = 0 then exit;     //Kein Museum geladen => schüss
  with outputPaintBox.Canvas do begin
    if polygonalMode.Checked then begin //Im Polygonanalysemodus
      pen.Width:=1;                     //werden die Museumspolygone gefüllt
      pen.color:=clBlack;
      pen.Style:=psSolid;
      brush.Color:=clSilver;
      drawPolygon(museum[0]);           //Hauptpolygon zeichnen
      brush.Color:=clGray;
      for i:=1 to high(museum) do       //Löcher zeichnen
        drawPolygon(museum[i]);

      //Sichtbare Bereiche ausgeben
      if fillSeenAreas.Checked then brush.Color:=$A6D9AD //füllen
      else brush.Style:=bsClear;                         
      for i:=0 to high(seenAreas) do begin
        if drawBorderedSeenAreas.Checked then begin      //umranden
          pen.Width:=1;
          pen.Color:=clGray;
        end else pen.Style:=psClear;

        //Polygon umrechnen und zeichnen
        for j:=0 to 3 do
          temp[j]:=transform(seenAreas[i,j]);
        Polygon(temp);

        //Treffpunkte auf der Linie
        pen.Style:=psSolid;
        pen.Width:=2;
        pen.Color:=clRed;
        moveto(temp[1].x,temp[1].y);
        LineTo(temp[2].x,temp[2].y);
      end;

      pen.Width:=1;
      pen.Color:=clBlack;
      brush.Style:=bsClear;
      drawPolygon(guardsWay);
    end else begin
      if showWayProbability.Checked then begin
        for i:=0 to high(invWayProbability) do
          for j:=0 to high(invWayProbability[i]) do begin
            tempColor:=min(255,max(0,round(invWayProbability[i,j]*255)));
            Pixels[i+nullpoint.x,j+nullpoint.y+outputPaintBox.ClientHeight-length(invSeeProbability)]:=rgb(tempColor,tempColor,tempColor);
          end;
      end else if showVisibility.Checked then begin
        for i:=0 to high(invSeeProbability) do
          for j:=0 to high(invSeeProbability[i]) do begin
            tempColor:=min(255,max(0,round(invSeeProbability[i,j]*255)));
            Pixels[i+nullpoint.x,j+nullpoint.y+outputPaintBox.ClientHeight-length(invSeeProbability)]:=rgb(tempColor,tempColor,tempColor);
          end;
      end else
      pen.Width:=1;
      pen.color:=clRed;
      pen.Style:=psSolid;
      brush.style:=bsClear;
      drawPolygon(museum[0]);
      for i:=1 to high(museum) do
        drawPolygon(museum[i]);
    end;
  end;
end;

//=================================LOGIK========================================
//Gibt zurück, auf welcher Seite vom Strahl pos,dir der Punkt p liegt.
//-1: links, 0: auf dem Strahl, 1: rechts
function whichSide(const pos,dir: tpointf; const p:tpointf): integer;
var temp:double;
begin
  //Feststellen auf welchwer Seite die Punkte liegen
  //pos1 zum Nullpunkt verschieben;
  //Koordintensystem so verzerren, dass dir auf die y-Achse fällt
  Result:=0;
  if abs(dir.y)<epsilon then begin //verzerren geht nicht, einfacher Vergleich
    if p.y<pos.y then result:=1
    else if p.y>pos.y then result:=-1;
    if dir.x<epsilon then Result:=-result;
  end else begin
    //x_new(x,y) = x - y * dir1.x / dir1.y
    //=> x_new(dir1.x,dir1.y) = 0
    temp:=((p.x - pos.x) - (p.y - pos.y) * dir.x / dir.y);
    if temp>epsilon then result:=1
    else if temp<-epsilon then result:=-1;
    if dir.y<0 then result:=-result;
  end;
end;

//Überprüft auf welcher Seite von der Linie a--b der Punkt p liegt
function whichLineSide(const a,b: tpointf; const p:tpointf): integer;
var dir: tpointf;
begin
  dir.x:=a.x-b.x; dir.y:=a.y-b.y; //Richtung für einen Strahl
  Result:=whichSide(a,dir,p);     //auf bekanntes Problem zurückleiten                             
end;

//Berechnet die Treffer eines Strahl mit einem Polygon 
procedure findRayHitPoints(const polys:array of TPolygon; const start,dir:tpointf;out result:TRayHitPoints);
var poly,line:integer;          //Momentan zu überprüfende Linie
    lineStart,lineDir: ppointf; //Start und Richtung dieser Linie
    u,v: double;                //Position des Treffpunkts auf dem Strahl und der Linie
    p1Side,p2Side:integer;      //Strahlseite auf der an einen Punkt grenzende Linien sind
    i:integer;                  //Loopindex                                                          
begin
  result.when:=inf;             //Maximaler Abstand 
  SetLength(result.between,0);
  for poly:=0 to high(polys) do
    for line:=0 to high(polys[poly]) do begin
      lineStart:=@polys[poly,line].start; //Zeiger für einfacheren Zugriff
      lineDir:=@polys[poly,line].dir;
      //Regel für Schnittpunkte:
      {    start+ u*dir = linestart + v*linedir, 0<=v<=1 }

      if abs(dir.x*lineDir.y - dir.y*lineDir.x) < epsilon then
        continue; //parallel von Linien und Strahlen ignorieren (siehe Doku) 

      //Position des Punktes auf der Linie berechnen
      v := (dir.x*(start.y - linestart.y) + dir.y*(linestart.x - start.x))/(dir.x*lineDir.y - dir.y*lineDir.x);
      //Abbrechen, falls außerhalb der Linie
      if abs(v)<epsilon then v:=0;
      if abs(v-1)<epsilon then v:=1;
      if (v<0) or (v>1) then continue;
      //Position auf dem Strahl berechnen
      u := (lineDir.x*(start.y - linestart.y) + lineDir.y*(linestart.x - start.x))/(dir.x*lineDir.y - dir.y*lineDir.x);
      //Abbrechen, falls hinter dem Strahl
      if abs(u-1)<epsilon then u:=1;
      if (u>result.when) or (u<epsilon) then continue;
      //Startpunkt getroffen
      if v=0 then begin
        //Berechnen auf welcher Seite des Strahls die angrenzenden Linie sind
        p1Side:=whichSide(start,dir,polys[poly,line].left^.start);
        p2Side:=whichSide(start,dir,polys[poly,line].right^.start);
        if (p1Side=p2Side) and (p1Side<>0) then begin //gleiche Seite => Zacke
          //=> der Strahl wird nicht geblockt, nur Strahlen, die neben ihm wären
          //Passende Position im sortierten between-Array suchen
          i:=high(result.between);
          while (i>=0) and (result.between[i].when>result.when) do
            dec(i);
          inc(i);
          //Punkt einfügen
          SetLength(result.between,length(result.between)+1);
          move(result.between[i],result.between[i+1],(high(result.between)-i)*sizeof(result.between[0]));
          result.between[i].poly:=poly;
          result.between[i].point:=line;
          result.between[i].side:=p1Side;
          result.between[i].when:=u;
          continue; //nächste Linie testen
        end;
      end else if v=1 then continue; //wird später behandelt

      //Kollision mit Polygonenseite
      result.poly:=poly;
      result.line:=line;
      result.when:=u;
      result.where:=v;

      //Alle Zacken löschen, die hinter der Seite liegen
      i:=high(result.between);
      while (i>=0) and (result.between[i].when>u) do
        dec(i);
      setlength(result.between,i+1);
    end;
end;

//Speichert einen getroffenen Punkt
//Im wesentlichen werden die übergebenen Parameter einfach kopiert, nur wird
//sichergestellt, dass das seen-Array sortiert ist
procedure addSeePoint(var line:TLine; const where: double; const seeRight: boolean;
                                      const hiddenRaySide: integer; const from:tpointf);
var i:integer;
begin
  with line do begin
    //Suchen der passenden Position
    i:=high(sees);
    while (i>=0) and (sees[i].where>where) do
      dec(i);
    SetLength(sees,length(sees)+1);
    if (i=-1) and (sees[0].where<=where) then i:=high(sees)
    else inc(i);
    //alle Einträge nach rechts verschieben
    move(sees[i],sees[i+1],(high(sees)-i)*sizeof(sees[i]));
    //Parameter kopieren
    sees[i].where:=where;
    sees[i].seeRight:=seeRight;
    sees[i].hiddenRaySide:=hiddenRaySide;
    sees[i].from:=from;
    sees[i].wherePos.x:=start.x+where*dir.x;
    sees[i].wherePos.y:=start.y+where*dir.y;
  end;
end;

//Diese Prozedur wird aufgerufen, wenn der Strahl den Startpunkt von line getroffen
//hat und festgestellt werden muss, welche Linie sichtbar ist.
//Entweder line, die den Punkt nun mal als Startpunkt hat, line.left^, die den Punkt
//als Endpunkt hat, oder beide.
//Eine Linie ist dann sichtbar, wenn der Startpunkt des Strahles auf der selben
//Linienseite liegt, wie der andere Punkt der anderen Linie
procedure searchVisibleLine(const raystart: tpointf; var line: TLine);
var rayfromline1,
    rayfromline2: integer; //Seite des Strahlenstart von einer der Linie
begin
  //Fesstellen auf welcher Seite, der an den Startpunkt von line angrenzenden
  //Linien, jeweils der Strahlstartpunkt liegt
  rayfromline2:=whichSide(line.start,line.dir,raystart);
  rayfromline1:=whichSide(line.left^.start,line.left^.dir,raystart);
  if rayfromline1=rayfromline2 then begin //Keine Linie wird von der nderen verdeckt
     addSeePoint(line,0,true,0,raystart);
     addSeePoint(line.left^,1,false,0,raystart);
  end else if whichSide(line.start,line.dir,line.left^.start)<>rayfromline2 then
     //line trennt line.left vom Strahl
     addSeePoint(line,0,true,0,raystart)
  else if whichSide(line.left^.start,line.left^.dir,line.right^.start)<>rayfromline1 then
     //line.left trennt line vom Strahl
     addSeePoint(line.left^,1,false,0,raystart)
  else //Keine Linie sichtbar 
     raise Exception.Create('Invisible point');
end;

//Überprüfen, ob der Punkt p in dem Dreieck a--b--c liegt
//Da ein Dreieck immer konvex ist, muss dafür nur überprüft werden,
//ob p in Bezug auf jede Dreieckseite auf derselben Seite liegt
function isPointInTri(const a,b,c,p:tpointf):boolean;
var s1,s2,s3: integer;
begin
  Result:=false;
  s1:=whichLineSide(a,b,p);
  s2:=whichLineSide(b,c,p);
  if s1<>s2 then exit;
  s3:=whichLineSide(c,a,p);
  result:=(s1=s3);
end;

//Überprüfen, ob der Punkt p im Viereck a--b--c--d liegt.
//Dabei werden die Fälle unterschieden, dass sich das Viereck selbst schneiden
//und dass es konkav ist. 
function isPointInQuad(const a,b,c,d,p:tpointf):boolean;
begin
  if whichLineSide(a,b,c)<>whichLineSide(a,b,d) then begin
    //a--b und c--d schneiden sich
    //Das Viereck lässt sich in zwei Bereiche aufteilen:
      //a--b--c geschnitten mit b--c--d
      //a--c--d geschnitten mit a--b--d
    Result:=(isPointInTri(a,b,c,p) and isPointInTri(b,c,d,p)) or
            (isPointInTri(a,c,d,p) and isPointInTri(a,b,d,p));
  end else if whichLineSide(a,d,b)<>whichLineSide(a,d,c) then begin
    //a--d und b--c schneiden sich
    //Das Viereck lässt sich in zwei Bereiche aufteilen:
      //a--b--c geschnitten mit a--b--d
      //a--c--d geschnitten mit b--c--d
    Result:=(isPointInTri(a,b,c,p) and isPointInTri(a,b,d,p)) or
            (isPointInTri(a,c,d,p) and isPointInTri(b,c,d,p));
  end else if whichLineSide(a,c,b)=whichLineSide(a,c,d) then begin
    //konkav, da die Digonale a--c außerhalb liegt
    //  => Aufteilung entlang der Diagonalen b--d
    Result:=(isPointInTri(a,b,d,p) and isPointInTri(b,c,d,p));
  end else begin
    //entweder konvex, oder konkav mit b--d außerhalb
    //  => Aufteilung entlang der Diagonalen a--c ist möglich
    Result:=(isPointInTri(a,b,c,p) and isPointInTri(a,b,d,p));
  end;
end;

//Berechnet alle Segmente die man vom Punkt p aus sehen kann.
procedure TmuseumForm.lookFromPoint(const p: tpointf);
var i,j,k:integer;              //loop-Counter
    dir: tpointf;               //Richtung des Strahls
    rayHit:TRayHitPoints;       //Informationen über die Strahlentreffer
    hideLeft,hideRight:boolean; //liegt auf einer der beiden Seiten eine Zacke
    hiddenside: integer;        //Seite auf der die einzigste Zacke liegt
    pointSide: integer;         //Seite auf der die Linie an einem getroffenen Punkt liegt
begin
  for i:=0 to high(museum) do
    for j:=0 to high(museum[i]) do begin
      //Für jeden Punkt wird die Richtung dorthin berechnet
      dir.x:=museum[i,j].start.x-p.x;
      dir.y:=museum[i,j].start.y-p.y;
      //Und der Strahl wird losgesendet
      findRayHitPoints(museum,p,dir,rayHit);

      if rayHit.when=inf then raise Exception.create('Hasn''t hit something');

      //Ist links oder rechts eine Zacke
      hideLeft:=false; hideRight:=false;
      for k:=0 to high(rayHit.between) do
        case rayHit.between[k].side of
          -1: hideLeft:=true; //Zacke links
          1: hideRight:=true; //Zacke rechts
          0: raise Exception.Create('Ray isn''t stopped, after point collision');
        end;

      if hideLeft then //Zacke links
        for k:=0 to high(rayhit.between) do
          if rayHit.between[k].side=-1 then begin
            with rayhit.between[k] do
              searchVisibleLine(p,museum[poly,point]);//Eckpunkt ist sichtbar
            break;
          end;

      if hideRight then //Zacke rechts
        for k:=0 to high(rayhit.between) do
          if rayHit.between[k].side=1 then begin
            with rayhit.between[k] do
              searchVisibleLine(p,museum[poly,point]);//Eckpunkt ist sichtbar
            break;
          end;

      if hideLeft and hideRight then continue; //Links und rechts eine Zacke
                                               // => abbruch, nur Zacken sieht man
      //Seite suchen, auf der eine Zacke ist
      if hideleft then hiddenside:=-1
      else if hideright then hiddenside:=1
      else hiddenside:=0;

      if rayHit.where=0 then begin //Ecke getroffen
        //Auf welcher Seite liegt die eine angrenzende Linie
        pointSide:=whichSide(p,dir,museum[rayhit.poly,rayhit.Line].right^.start);
        //Wird diese Seite nicht verdeckt
        if (pointSide<>hiddenSide) or (hiddenSide=0) then
          with museum[rayHit.poly,rayHit.line] do //Seite ist sichtbar
            addSeePoint(museum[rayHit.poly,rayHit.line],0,true,hiddenside,p);

        //Wird die andere Seite nicht verdeckt
        if (-pointSide<>hiddenSide) or (hiddenSide=0) then
          with museum[rayHit.poly,rayHit.line].Left^ do //ist sie auch sichtbar
            addSeePoint(museum[rayhit.poly,rayHit.line].Left^,1,false,hiddenside,p);
      end else begin //Kante getroffen
        if not (hideleft or hideRight) then continue; //Strahl ist nutzlos
        //feststellen auf welcher Seite der Startpunkt liegt
        //Das Segment liegt in Linienrichtung, wenn der Startpunkt verdeckt wird
        addSeePoint(museum[rayHit.poly,rayHit.line],
                    rayHit.where,
                    whichSide(p,dir,museum[rayhit.poly,rayhit.Line].start)=hiddenSide,
                    hiddenside,p);
      end;
    end;
end;


//Berechnet alle Segmente, die man von einer Weglinie aus sehen kann
procedure TmuseumForm.lookFromWayLine(var line: TLine);
var p1,l1,p2,l2: integer;            //Polygon und Linien loop-Variablen
    u,v: double;                     //Position des getroffenen Punktes (Strahl,Linie)
    raystart,waystart,waydir:ppointf;//Strahlstart, Weglinienstart, Wegrichtung
    raydir,wayhit: tpointf;          //Strahlrichtung und getroffener Punkt auf der Weglini
    divisor: double;                 //zwischengespeicherter Nenner
    hitInfo: TRayHitPoints;          //Informationen über die Treffer eines Strahls
    side1,side2,tempside: integer;
 begin
   //Sichtbarkeit von den Linienecken berechnen
   lookFromPoint(line.start);
   lookFromPoint(line.right^.start);

   //Schönere Namen geben
   waystart:=@line.start;
   waydir:=@line.dir;
   for p1:=0 to high(museum) do
    for p2:=0 to high(museum) do
     if p1<=p2 then
      for l1:=0 to high(museum[p1]) do
       for l2:=0 to high(museum[p2]) do begin
         if (p1=p2) and (l1+1>=l2) then continue;
          //Jetzt sind zwei Punkte museum[p1,l1].start und ...p2,l2... gewählt

         //Strahlvektoren vom ersten zum zweiten Punkt speichern
         raystart:=@museum[p1,l1].start;
         raydir.x:=museum[p2,l2].start.x-raystart.x;
         raydir.y:=museum[p2,l2].start.y-raystart.y;

         //Position der Linien an den Punkten überprüfen
         side1:=whichSide(raystart^,raydir,museum[p1,l1].left^.start);
         tempside:=whichSide(raystart^,raydir,museum[p1,l1].right^.start);
         if (side1<>tempside) then side1:=0; //Keine Zacke an Punkt 1

         side2:=whichSide(raystart^,raydir,museum[p2,l2].left^.start);
         tempside:=whichSide(raystart^,raydir,museum[p2,l2].right^.start);
         if (side2<>tempside) then side2:=0; //Keine Zacke an Punkt 2

         if (side1=side2) and (side1<>0) then
           continue; //Strahl ist nutzlos, da zwei Zacken auf derselben Seite
                                                           
         //Schnittpunkt mit dem Weg berechnen (siehe findRayHitPoints)
         divisor:=raydir.x*wayDir.y - raydir.y*wayDir.x;
         if abs(divisor)<epsilon then continue;
         v := (raydir.x*(raystart.y - waystart.y) + raydir.y*(waystart.x - raystart.x))/divisor;
         if (v<=0) or (v>=1) then continue;
         u := (wayDir.x*(raystart.y - waystart.y) + wayDir.y*(waystart.x - raystart.x))/divisor;

         if u<0 then begin //Strahl verläuft falschherum
           //Startpunkt wechseln
           raystart:=@museum[p2,l2].start;
           //Richtung invertieren
           raydir.x:=-raydir.x;
           raydir.y:=-raydir.y;
           //Neue Position in Anbetracht der beiden Änderungen berechnen
           u:=-u+1;
           //Zackeninformationen über die beiden Punkte tauschen
           tempside:=-side1;
           side1:=-side2;
           side2:=tempside;
         end;

         //Einen Strahl in Richtung des Weges aus senden
         findRayHitPoints(museum,raystart^,raydir,hitInfo);
         if (hitInfo.when<u) or (hitInfo.when<1) then
           continue; //Strahl zu früh unterbrochen

         //Vorhin auf der Weglinie getroffenen Punkt ausrechnen
         wayhit.x:=raystart^.x+u*raydir.x;
         wayhit.y:=raystart^.y+u*raydir.y;
         //Die beiden gewählten Punkte sind von diesem Punkt aus sichtbar
         searchVisibleLine(wayhit,museum[p1,l1]);
         searchVisibleLine(wayhit,museum[p2,l2]);

         if (side1=0)or(side2=0) then continue; //Alle Punkte sind berücksichtigt
         if u<1 then continue; //Weglinie kommt zu früh

         //Strahl in die andere Richtung senden
         raydir.x:=-raydir.x;
         raydir.y:=-raydir.y;
         //und Kollision mit dem Polygon berechnen
         findRayHitPoints(museum,raystart^,raydir,hitInfo);

         //Sichtbaren Punkt speichern
         //Das Segment liegt auf der anderen Seite, als der zweite Punkt, also
         //wenn der Startpunkt der Linie auf derselben Seite wie dieser Punkt liegt,
         //zeigt das Segment in Richtung des Endes der Linie
         addSeePoint(museum[hitinfo.poly,hitinfo.line], hitinfo.where,
                     whichSide(raystart^,raydir,museum[hitinfo.poly,hitinfo.Line].start) >0=(side2>0),
                     side1,wayhit);
       end;
end;

//Berechnet die sichtbaren Bereiche aus den sichtbaren Segmenten
procedure TmuseumForm.convertLookPoints;
var i,j,k,l,m,n,o:integer;  //loop-Variablen (Schachtelung ist sehr übersichtlich)

    border1Start,border1End,border2Start,border2End: integer;

    raydir:tpointf;
    nextLoop: boolean;
begin
  border2Start:=-1;  border1End:=-1; //wegen warnung über fehlende initialisierung
  //Es wird der größtmögliche sichtbare Bereich gewählt.
  //Das heißt bei mehreren aufeinanderfolgenden nach rechts blickenden Punkten
  //wird der erste genommen, bei nach links blickenden dagegen der letzte
  for i:=0 to high(museum) do
    for j:=0 to high(museum[i]) do
      //Linie auswählen
      with museum[i,j] do begin
        if length(sees)=0 then continue; //Keine sichtbaren Punkte => Weiter
        if length(sees)=1 then begin //Macht keinen Sinn => Abbruch
          setlength(seenAreas,0);
          exit;
        end;
        k:=0;
        while k<=high(sees) do begin
          border2End:=high(sees);
          border1Start:=k; //erster nach rechts blickender Punkt (Startpunkt)
          for l:=k+1 to high(sees) do
            if not sees[l].seeRight then begin
              border1End:=l-1; //letzter Startpunkt
              border2Start:=l; //erster nach links blickender (Endpunkt)
              break;
            end;
          if border1End<border1Start then begin //Macht keinen Sinn => Abbruch
            setlength(seenAreas,0);
            exit;
          end;
          for l:=border1End+1 to high(sees) do
            if sees[l].seeRight then begin
              border2End:=l-1; //letzer Endpunkt
              break;
            end;
          k:=border2End+1;

          for l:=border1Start to border1End do //Je einen Startpunkt
            for m:=border2Start to border2End do begin //und Endpunkt auswählen
              if (abs(sees[l].from.x-sees[m].from.x)>epsilon) or
                 (abs(sees[l].from.y-sees[m].from.y)>epsilon) then begin
                //Wenn kein Dreieck, dann, Sichtbarkeitstests durchführen
                //Strahl von dem Punkt, von dem aus der Startpunkt sichtbar ist
                //zum Startpunkt erstellen
                raydir.x:=sees[l].wherePos.x-sees[l].from.x;
                raydir.y:=sees[l].wherePos.y-sees[l].from.y;
                //Liegt, der andere Blickpunkt auf derselben Seite, wie die
                //blockierende Zacke, so ist der Bereich nicht komplett sichtbar
                if sees[l].hiddenRaySide=
                   whichSide(sees[l].from,raydir,sees[m].from) then continue;
                //Liegt, der andere Blickpunkt auf derselben Seite, wie der von
                //dort gesehene Endpunkt, so ist der Bereich nicht komplett sichtbar
                if whichSide(sees[l].from,raydir,sees[m].wherePos)=
                   whichSide(sees[l].from,raydir,sees[m].from) then continue;
                //Die gleichen Tests für den Endpunkt ausführen
                raydir.x:=sees[m].wherePos.x-sees[m].from.x;
                raydir.y:=sees[m].wherePos.y-sees[m].from.y;
                if sees[m].hiddenRaySide=
                   whichSide(sees[m].from,raydir,sees[l].from) then continue;
                if whichSide(sees[m].from,raydir,sees[l].wherePos)=
                   whichSide(sees[m].from,raydir,sees[l].from) then continue;

                //Haben die bisherigen Tests nichts erbracht, so muss für jede
                //Ecke des Polygon überprüft werden, ob sie innerhalb des neuen
                //Bereichs wäre
                nextLoop:=false;
                for n:=0 to high(museum) do
                  for o:=0 to high(museum[n]) do
                    if isPointInQuad(sees[l].from,sees[l].wherePos,sees[m].wherePos,sees[m].from,museum[n,o].start) then begin
                      nextLoop:=true; //Leider ist die Ecke drin => nächste Kombination
                      break;
                    end;
                if nextLoop then continue;
              end;

              //Bereich hat die Tests bestanden und ist somit sichtbar.
              SetLength(seenAreas,length(seenAreas)+1);
              seenAreas[high(seenAreas)][0]:=sees[l].from;
              seenAreas[high(seenAreas)][1]:=sees[l].wherePos;
              seenAreas[high(seenAreas)][2]:=sees[m].wherePos;
              seenAreas[high(seenAreas)][3]:=sees[m].from;
            end;
        end;
        //Bisherige Segmente löschen
        setlength(sees,0);
      end;
end;

//
procedure TmuseumForm.lookAround();
var i:integer;
begin
  setlength(seenAreas,0);
  for i:=0 to high(guardsway) do
  begin
    lookFromWayLine(guardsway[i]);
    convertLookPoints;
  end;
end;



//=============================Sonstiges (GUI)==================================
procedure TmuseumForm.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  if WheelDelta<0 then zoom:=zoom/(1.01*(WheelDelta/60))
  else zoom:=-zoom*1.01*WheelDelta/60;
  Refresh;
end;

procedure TmuseumForm.outputPaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  clickPos.x:=x;
  clickPos.y:=y;
  oldnullpoint:=nullpoint;
end;

procedure TmuseumForm.outputPaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if ssleft in shift then begin
    nullpoint.x:=oldnullpoint.x+x-clickPos.x;
    nullpoint.y:=oldnullpoint.y+y-clickPos.y;
    Refresh;
  end;
  if zoom<>0 then
  Caption:='BWINF 24.2.1 '+floatToStr((x-nullpoint.x)/zoom)+':'+
                           floattostr(-(y-outputPaintBox.ClientHeight-nullpoint.y)/zoom);
end;

procedure TmuseumForm.fillSeenAreasClick(Sender: TObject);
begin
  Refresh;
end;

procedure TmuseumForm.FormCreate(Sender: TObject);
begin
  SetLength(museum,0);
  DecimalSeparator:='.';
end;

procedure TmuseumForm.loadWayProbabilityClick(Sender: TObject);
var guardWay: tbitmap;
  procedure drawPolygon(const p:TPolygon);
  var transformedPoly: array of tpoint;
      i:integer;
  begin
    SetLength(transformedPoly,length(p));
    for i:=0 to high(p) do begin
      transformedPoly[i].x:=round(p[i].start.x*zoom);
      transformedPoly[i].y:=guardWay.height-round(p[i].start.y*zoom);
    end;
    guardWay.Canvas.Polygon(transformedPoly)
  end;
var
    x,y,x2,y2,i,j:integer;
    maxp,posp:integer;
    pos,pos2:tpointf;
    hitinfo: TRayHitPoints;
    visible: boolean;
    seeWidth: double;
begin
  guardWay:=TBitmap.create;
  guardWay.LoadFromFile(wayProbabilityFileName.text);
  zoom:=guardWay.width;
  if zoom<>guardWay.height then raise Exception.Create('nicht quadratisch');
  SetLength(invWayProbability,guardWay.width,guardWay.height);
  SetLength(invSeeProbability,guardWay.width,guardWay.height);
  for x:=0 to guardWay.width-1 do
    for y:=0 to guardWay.height-1 do
      invWayProbability[x,y]:=getrvalue(guardWay.Canvas.Pixels[x,y]) / 255;



  guardWay.Canvas.brush.color:=clRed;
  guardWay.Canvas.pen.style:=psClear;
  guardWay.Canvas.pen.width:=1;
  guardWay.Canvas.pen.Style:=psSolid;
  guardWay.Canvas.FillRect(rect(0,0,guardWay.width,guardWay.height));
  guardWay.Canvas.brush.color:=clWhite;
  drawPolygon(museum[0]);
  guardWay.Canvas.brush.color:=clRed;

  for i:=1 to high(museum) do
    drawPolygon(museum[i]);

  for x:=0 to high(invWayProbability) do
    for y:=0 to high(invWayProbability[x]) do
      if guardWay.Canvas.Pixels[x,y] = clred then
        invWayProbability[x,y]:=2;

  guardWay.free;

  for x:=0 to high(invSeeProbability) do
    for y:=0 to high(invSeeProbability[x]) do
      invSeeProbability[x,y]:=1;

  seeWidth:=sqr(4/Max(museumsize.x,museumsize.Y));

  maxp:=length(invSeeProbability)*length(invSeeProbability[0]);
  ProgressBar1.Max:=maxp;
  for x:=0 to high(invSeeProbability)  do
    for y:=0 to high(invSeeProbability[x])do begin
      posp:=x*length(invSeeProbability[0])+y;
      ProgressBar1.Position:=posp;
      progress.Caption:=inttostr(posp)+'/'+inttostr(maxp);
      Application.ProcessMessages;
      if invWayProbability[x,y] < 1 then begin
        pos.x:=x/high(invSeeProbability);
        pos.y:=1-y/high(invSeeProbability[x]);
        setlength(seenAreas,0);
        try
          lookFromPoint(pos);
          convertLookPoints;
        except
          continue;
        end;
        for x2:=0 to high(invSeeProbability) do
          for y2:=0 to high(invSeeProbability[x]) do begin
            if (x=x2)and(y=y2) then begin
              invSeeProbability[x2,y2]:=invSeeProbability[x,y]*invWayProbability[x,y];
              continue;
            end;
            if invWayProbability[x2,y2] = 2 then continue;
            pos2.x:=x2/high(invSeeProbability);
            pos2.y:=1-y2/high(invSeeProbability);
            if sQr(pos.x-pos2.x)+sQr(pos.y-pos2.y)>seeWidth then continue;

            visible:=false;
            for i:=0 to high(seenAreas) do
              if isPointInTri(seenAreas[i,0],seenAreas[i,1],
                               seenAreas[i,2],pos2) then begin
                visible:=true;
                break;
              end;

            if visible then
              invSeeProbability[x2,y2]:=invSeeProbability[x,y]*(
                                       max(0,min(1,invWayProbability[x,y]+(sQr(pos.x-pos2.x)+sQr(pos.y-pos2.y))/seeWidth))
                                      );
          end;
      end;
    end;
  Refresh;
end;

end.
