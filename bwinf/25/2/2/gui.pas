unit gui; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, Grids,
  ExtCtrls, Buttons,logic, StdCtrls, ComCtrls, Menus;

type

  { TBidokuForm }

  TBidokuForm = class(TForm)
    bidokuList: TListBox;
    ComboBox1: TComboBox;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    allSolve: TMenuItem;
    logicSolve: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    saveAll: TMenuItem;
    showSteps: TMenuItem;
    minizeBidoku: TMenuItem;
    singleSolve: TMenuItem;
    saveBidoku: TMenuItem;
    loadbidoku: TMenuItem;
    createBidoku: TMenuItem;
    OpenDialog1: TOpenDialog;
    Panel2: TPanel;
    SaveDialog1: TSaveDialog;
    StatusBar1: TStatusBar;
    StringGrid1: TStringGrid;
    procedure allSolveClick(Sender: TObject);
    procedure ComboBox1Select(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure bidokuListSelectionChange(Sender: TObject; User: boolean);
    procedure createBidokuClick(Sender: TObject);
    procedure loadbidokuClick(Sender: TObject);
    procedure logicSolveClick(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure saveAllClick(Sender: TObject);
    procedure minizeBidokuClick(Sender: TObject);
    procedure saveBidokuClick(Sender: TObject);
    procedure showStepsClick(Sender: TObject);
    procedure singleSolveClick(Sender: TObject);
    procedure StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure StringGrid1EditingDone(Sender: TObject);
    procedure StringGrid1PrepareCanvas(sender: TObject; aCol, aRow: Integer;
      aState: TGridDrawState);
  private
    { private declarations }
  public
    { public declarations }
    shownID: longint; //Bidoku-ID
    shown: TBidoku;   //Aktuelles Bidoku
    //Zeigt ein Bidoku aus der Liste an
    procedure showBidoku(id:longint=-1);
    //Löscht alle Bidokus außer dem aktuell ausgewählten
    procedure needSingleBidoku;
  end;

var
  BidokuForm: TBidokuForm;

implementation

uses createparams,Clipbrd;
{ TBidokuForm }

//Initialisierung
procedure TBidokuForm.FormCreate(Sender: TObject);
begin
  shownID:=0;
  shown:=TBidoku.create;
  bidokuList.Items.AddObject('Bidoku',shown);
  ComboBox1.top:=StatusBar1.top+StatusBar1.Height;
end;

//Berechnet alle Lösungen
procedure TBidokuForm.allSolveClick(Sender: TObject);
var i:longint;
    solveResult: TSolveResult;
begin
  needSingleBidoku;
  solveResult:=shown.solve(true,true);
  if solveResult.solved then begin
    for i:=0 to bidokuList.Items.Count-1 do
      TBidoku(bidokuList.Items.Objects[i]).free;
    bidokuList.Clear;
    
    for i:=0 to solveResult.solutions.count-1 do
      bidokuList.Items.AddObject(IntToStr(i+1)+'. Lösung',
                                 tobject(solveResult.solutions[i]));
    solveResult.solutions.free;
    showBidoku(0);

    ShowMessage('Das Rätsel wurde komplett gelöst');
  end else
    ShowMessage('Das Rätsel ist unlösbar');
end;

//Änderung der Anzeigeart
procedure TBidokuForm.ComboBox1Select(Sender: TObject);
begin
  StringGrid1.Refresh;
end;

procedure TBidokuForm.FormDestroy(Sender: TObject);
var i:longint;
begin
  for i:=0 to bidokuList.Items.Count-1 do
    TBidoku(bidokuList.Items.Objects[i]).free;
end;

procedure TBidokuForm.bidokuListSelectionChange(Sender: TObject; User: boolean);
begin
  if User then showBidoku(bidokuList.ItemIndex);
end;

//Erzeugt ein neues Bidoku
procedure TBidokuForm.createBidokuClick(Sender: TObject);
var sym: TPositionsArray;
begin
  if CreateParamsDialog.ShowModal<>mrOK then exit;
  

  shown:=TBidoku.create(StrToInt(CreateParamsDialog.size.text));
  needSingleBidoku;
  
  //Muster setzen
  sym:=nil;
  with CreateParamsDialog,shown do begin
    if horizontal.ItemIndex>0 then
      sym:=mergeSymmetry(sym,makeMirrorSymmetryH(horizontal.ItemIndex=2));
    if subhorizontal.ItemIndex>0 then
      sym:=mergeSymmetry(sym,makeMirrorSymmetrySubH(subhorizontal.ItemIndex=2));
    if vertical.ItemIndex>0 then
      sym:=mergeSymmetry(sym,makeMirrorSymmetryV(vertical.ItemIndex=2));
    if subvertical.ItemIndex>0 then
      sym:=mergeSymmetry(sym,makeMirrorSymmetrySubV(subvertical.ItemIndex=2));
  end;

  //Erzeugen
  shown.generate(TDifficulty(CreateParamsDialog.difficulty.ItemIndex),sym);
  showBidoku;
end;

//Bidoku laden
procedure TBidokuForm.loadbidokuClick(Sender: TObject);
begin
  if OpenDialog1.Execute then begin
    needSingleBidoku;
    shown.loadFromFile(OpenDialog1.FileName);
    showBidoku;
  end;
end;

//logisches Lösen aufrufen
procedure TBidokuForm.logicSolveClick(Sender: TObject);
begin
  needSingleBidoku;
  shown.logicalSolve();
  showBidoku(0);
  case shown.solved() of
    ssPartly: ShowMessage('Das Rätsel wurde nur teilweise gelöst');
    ssSolved: ShowMessage('Das Rätsel wurde komplett gelöst');
    ssWrong: ShowMessage('Das Rätsel wurde fehlerhaft gelöst');
  end;
end;

//Kopieren
procedure TBidokuForm.MenuItem3Click(Sender: TObject);
begin
  Clipboard.AsText:=shown.toString();
end;

//Verschlüsseln
procedure TBidokuForm.MenuItem4Click(Sender: TObject);
var str: String;
begin
  if InputQuery('Bidokuverschlüsselung',
               'Bitte geben Sie den zu versteckenden Text ein:',str) then begin
    needSingleBidoku;
    shown.generateEncryption(str);
    showBidoku();
  end;
end;

//Entschlüsseln
procedure TBidokuForm.MenuItem5Click(Sender: TObject);
begin
  ShowMessage(shown.decode());
end;

//Alle vorhandenen Bidokus abspeichern
procedure TBidokuForm.saveAllClick(Sender: TObject);
var i:longint;
begin
  if SaveDialog1.Execute then begin
    for i:=0 to bidokuList.items.count-1 do
      TBidoku(bidokuList.Items.Objects[i]).saveToFile(
        SaveDialog1.FileName+bidokuList.Items[i]);
  end;
end;

//Bidoku minimieren
procedure TBidokuForm.minizeBidokuClick(Sender: TObject);
begin
  needSingleBidoku;
  shown.minimize;
  showBidoku();
end;

//Bidoku speichern
procedure TBidokuForm.saveBidokuClick(Sender: TObject);
begin
  if SaveDialog1.Execute then
    shown.saveToFile(SaveDialog1.FileName);
end;

//Zerlegt ein Bidoku in einzelne Schritte
procedure TBidokuForm.showStepsClick(Sender: TObject);
var current:TBidoku;     //Aktuelles Bidoku mit teilweise kopierten Feldern
    added:boolean;       //Wurde ein Feld kopiert
    i,j,t,bi,bj:longint; //Schleifenindizes, Zeit und frühestes Feld

begin
  needSingleBidoku;
  bidokuList.clear;
  current:=TBidoku.create(shown.size);
  t:=-1;
  if StatusBar1.panels[0].text='0' then begin
    //Bei gelösten Bidokus nur die Lösung zeigen
    for i:=0 to shown.size*shown.size-1 do
      for j:=0 to shown.size*shown.size-1 do
        if (shown.get(i,j)<>triUnset) and
           (shown.getSolutionMethod(i,j)=smFixed) then begin
          current.copyField(i,j,shown);
          if shown.getSolutionTime(i,j)>t then t:=shown.getSolutionTime(i,j);
        end;
    bidokuList.Items.AddObject('Ausgang',current);
    current:=current.clone;
  end;
  //Alle noch übrigen, nicht kopierten Felder in der Erstellungsreihenfolge
  //kopieren
  repeat
    added:=false;
    bi:=-1;
    //Letztes erstelltes suchen
    for i:=0 to shown.size*shown.size-1 do
      for j:=0 to shown.size*shown.size-1 do
        if (shown.get(i,j)<>triUnset) and (shown.getSolutionTime(i,j)>t)
           and ((bi=-1)or(shown.getSolutionTime(i,j)<
                          shown.getSolutionTime(bi,bj))) then begin
          bi:=i;
          bj:=j;
        end;
    //Feld kopieren
    if bi<>-1 then begin
      added:=true;
      t:=shown.getSolutionTime(bi,bj);
      bidokuList.Items.AddObject(IntToStr(t),current);
      current.copyField(bi,bj,shown);
      current:=current.clone();
    end;
  until not added;
  shown.free;
  current.free;
  showBidoku(0);
end;

//Eine Lösung finden
procedure TBidokuForm.singleSolveClick(Sender: TObject);
begin
  needSingleBidoku;
  shown.solve(false,false);
  showBidoku;
  case shown.solved() of
    ssPartly: ShowMessage('Das Rätsel wurde nur teilweise gelöst');
    ssSolved: ShowMessage('Das Rätsel wurde komplett gelöst');
    ssWrong: ShowMessage('Das Rätsel wurde fehlerhaft gelöst');
  end;
end;

//Quadratlinien hervorheben und Anzeigemodus beachten
procedure TBidokuForm.StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
begin
  if arow mod shown.size = 0 then begin
    StringGrid1.Canvas.pen.width:=3;
    StringGrid1.Canvas.pen.color:=clBlack;
    StringGrid1.Canvas.Line(aRect.Left,aRect.top, aRect.right,aRect.top);
  end;
  if arow mod shown.size = shown.size-1 then begin
    StringGrid1.Canvas.pen.width:=3;
    StringGrid1.Canvas.pen.color:=clBlack;
    StringGrid1.Canvas.Line(aRect.Left,aRect.bottom, aRect.right,aRect.bottom);
  end;
  if acol mod shown.size = 0 then begin
    StringGrid1.Canvas.pen.width:=3;
    StringGrid1.Canvas.pen.color:=clBlack;
    StringGrid1.Canvas.Line(aRect.Left,aRect.top, aRect.left,aRect.bottom);
  end;
  if acol mod shown.size = shown.size-1 then begin
    StringGrid1.Canvas.pen.width:=3;
    StringGrid1.Canvas.pen.color:=clBlack;
    StringGrid1.Canvas.Line(aRect.right,aRect.top, aRect.right,aRect.bottom);
  end;
  StringGrid1.Canvas.pen.width:=1;
  StringGrid1.Canvas.pen.color:=clSilver;
  if ComboBox1.ItemIndex=1 then begin
    case shown.get(aCol,aRow) of
      triUnset: StringGrid1.Canvas.brush.Color:=clSilver;
      tri0: StringGrid1.Canvas.brush.Color:=clWhite;
      tri1: StringGrid1.Canvas.brush.Color:=clBlack;
    end;
    StringGrid1.Canvas.FillRect(arect);
  end;
end;

//Feldänderung übernehmen
procedure TBidokuForm.StringGrid1EditingDone(Sender: TObject);
var i,j: longint;
begin
  for i:=0 to StringGrid1.ColCount-1 do
    for j:=0 to StringGrid1.rowCount-1 do begin
      if StrToIntDef(StringGrid1.Cells[i,j],-1)+1<>integer(shown.get(i,j)) then
        case StrToIntDef(StringGrid1.Cells[i,j],-1) of
          -1: shown.put(i,j,triUnset);
          0: shown.put(i,j,tri0);
          1: shown.put(i,j,tri1);
        end;
    end;
end;

//Änderung der Schriftfarbe gemäß Lösungsmethode für ein Feld
procedure TBidokuForm.StringGrid1PrepareCanvas(sender: TObject; aCol, aRow: Integer;
  aState: TGridDrawState);
begin
  if ComboBox1.ItemIndex=0 then begin
    case shown.getSolutionMethod(aCol,aRow) of
      smUser: StringGrid1.Canvas.Font.Color:=clBlue;
      smLogicTrivial,smLogicCombined: StringGrid1.canvas.font.color:=$00aa00;
      smBacktracking1: StringGrid1.canvas.font.color:=$00aaaa;
      smBacktracking2: StringGrid1.canvas.font.color:=clRed;
      else StringGrid1.canvas.font.color:=clBlack;
    end;
    if shown.getSolutionMethod(aCol,aRow) in [smUser,smUnknown,smFixed] then
      StringGrid1.canvas.font.Style:=[]
     else
      StringGrid1.canvas.font.Style:=[fsBold];
  end else case shown.get(aCol,aRow) of
    triUnset: StringGrid1.Canvas.font.Color:=clSilver;
    tri0: StringGrid1.Canvas.font.Color:=clWhite;
    tri1: StringGrid1.Canvas.font.Color:=clBlack;
  end;
end;

//Zeigt ein Bidoku aus der Liste an
procedure TBidokuForm.showBidoku(id: longint=-1);
var i,j,empty: longint;
begin
  //Bidoku auswählen
  if id<>-1 then begin
    shownID:=id;
    shown:=TBidoku(bidokuList.Items.Objects[id]);
  end;
  //Größe überprüfen
  if shown.size*shown.size<>StringGrid1.ColCount then begin
    StringGrid1.ColCount:=shown.size*shown.size;
    StringGrid1.RowCount:=shown.size*shown.size;
  end;

  //Felder kopieren
  empty:=0;
  for i:=0 to StringGrid1.ColCount-1 do
    for j:=0 to StringGrid1.rowCount-1 do
      case shown.get(i,j) of
        triUnset: begin
          StringGrid1.Cells[i,j]:='';
          empty+=1;
        end;
        tri0: StringGrid1.Cells[i,j]:='0';
        tri1: StringGrid1.Cells[i,j]:='1';
      end;
  //Weitete Informationen ausgeben
  StatusBar1.Panels[0].text:=IntToStr(empty);
  if empty=0 then
    StatusBar1.Panels[2].text:='Schierigkeit: '+IntToStr(shown.rateDifficulty)
   else
    StatusBar1.Panels[2].text:='';
  Panel2.Visible:=bidokuList.items.count>1;
end;

//Löscht alle Bidokus außer dem aktuell ausgewählten
procedure TBidokuForm.needSingleBidoku;
var i:longint;
begin
  for i:=0 to bidokuList.items.count-1 do
    if i<>shownID then
      tbidoku(bidokuList.Items.Objects[i]).free;
  bidokuList.Clear;
  bidokuList.items.AddObject('Bidoku',shown);
  shownID:=0;
  Panel2.Visible:=false;
end;


initialization
  {$I gui.lrs}

end.

