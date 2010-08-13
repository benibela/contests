unit user;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, ExtDlgs,data, Grids, Spin,LMessages,w32initOpengl,oglDrawing,gl;

type

  { TForm1 }

  { tupdatethread }

  tupdatethread=class(tthread)
    private
      img:TBitmap;
      map:TMap;
    public
      hacksusped,useless,stop,done,running:boolean;
      procedure ResumeWin;
      procedure SuspendWin;
      procedure execute;override;
      constructor create(aimg:TBitmap;amap:TMap);
  end;

  TForm1 = class(TForm)
    brushsize: TScrollBar;
    Button1: TButton;
    Button2: TButton;
    autoUpdate: TCheckBox;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    CheckBox1: TCheckBox;
    drawing: TCheckBox;
    Label1: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    light: TCheckBox;
    FloatSpinEditX: TFloatSpinEdit;
    FloatSpinEditY: TFloatSpinEdit;
    Label3: TLabel;
    Panel3: TPanel;
    renderinfo: TLabel;
    SavePictureDialog1: TSavePictureDialog;
    ScrollBar1: TScrollBar;
    Shape1: TShape;
    SpinEdit2: TSpinEdit;
    SpinEdit3: TSpinEdit;
    SpinEdit4: TSpinEdit;
    SpinEdit5: TSpinEdit;
    transparenz: TCheckBox;
    Label2: TLabel;
    pos3d: TLabel;
    Notebook1: TNotebook;
    OpenPictureDialog1: TOpenPictureDialog;
    Page3D: TPage;
    PageImg: TPage;
    PageMap: TPage;
    PageWater: TPage;
    PaintBox1: TPaintBox;
    Panel1: TPanel;
    oglOutput: TPanel;
    Panel2: TPanel;
    SpinEdit1: TSpinEdit;
    StringGridMap: TStringGrid;
    StringGridWater: TStringGrid;
    Timer1: TTimer;
    procedure autoUpdateChange(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure CheckBox2Change(Sender: TObject);
    procedure FloatSpinEditXChange(Sender: TObject);
    procedure Form1Idle(Sender: TObject; var Done: Boolean);
    procedure lightChange(Sender: TObject);
    procedure SpinEdit3Change(Sender: TObject);
    procedure transparenzChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Notebook1PageChanged(Sender: TObject);
    procedure oglOutputMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure oglOutputMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure oglOutputMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure oglOutputResize(Sender: TObject);
    procedure PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1Paint(Sender: TObject);
    procedure ScrollBar1Change(Sender: TObject);
    procedure StringGridMapEditingDone(Sender: TObject);
    procedure StringGridMapSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: string);
    procedure Timer1Timer(Sender: TObject);
  private
    { private declarations }
    procedure render3D(list:longint);
  public
    { public declarations }
    img: TBitmap;
    map:TMap;
    updatethread: tupdatethread;
    
    w32ogl:   TOGLW32Base;
    ogl: TOGLRenderer;
    hscale,vscale: GLdouble;
    px,py,pz,rx,ry,cpx,cpy,cpz,crx,cry:GLdouble;
    cx,cy:longint;
  end; 


var
  Form1: TForm1; 

implementation
uses FPimage;
{ TForm1 }

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
  PaintBox1.canvas.Draw(0,0,img);
end;

procedure TForm1.ScrollBar1Change(Sender: TObject);
var temp:TFPColor;
begin
  temp:=shape1.brush.FPColor;
  temp.green:=ScrollBar1.Position;
  shape1.brush.FPColor:=temp;

end;

procedure TForm1.StringGridMapEditingDone(Sender: TObject);
begin

end;

procedure TForm1.StringGridMapSetEditText(Sender: TObject; ACol, ARow: Integer;
  const Value: string);
begin
  if (acol<length(map.map)) and (arow<length(map.map[0])) then
    map.map[acol,arow]:=strtointdef(value,map.map[acol,arow]);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if updatethread.done then begin//TODO: message, in Delphi wäre es so einfach :-(
    updatethread.done:=false;
    PaintBox1Paint(PaintBox1);
  end;
end;

procedure TForm1.render3D(list: longint);
  function getHeight(x,y:longint):longint;
  begin
    if (x<0) or (y<0) or (x>high(map.map)) or (y>high(map.map[x])) then result:=0
    else result:=map.map[x,y];
  end;
var x,y:longint;
begin
  if (length(map.map)=0) then exit;
  glNewList(list,GL_COMPILE);
  glDisable(GL_BLEND);
  glBegin(GL_QUADS);
  glColor4f(0,1,0,1);
  for x:=0 to high(map.map) do
    for y:=0 to high(map.map[x]) do begin
      glVertex3d(x*hscale,y*hscale,map.map[x,y]*vscale);
      glVertex3d((x+1)*hscale,y*hscale,map.map[x,y]*vscale);
      glVertex3d((x+1)*hscale,(y+1)*hscale,map.map[x,y]*vscale);
      glVertex3d(x*hscale,(y+1)*hscale,map.map[x,y]*vscale);
    end;

  glColor4f(0.5,0.25,0,1);
  for x:=0 to high(map.map) do
    for y:=0 to high(map.map[x]) do begin
      if getHeight(x,y)<>getHeight(x-1,y) then begin
        glVertex3d(x*hscale,y*hscale,map.map[x,y]*vscale);
        glVertex3d(x*hscale,(y+1)*hscale,map.map[x,y]*vscale);
        glVertex3d(x*hscale,(y+1)*hscale,getHeight(x-1,y)*vscale);
        glVertex3d(x*hscale,y*hscale,getHeight(x-1,y)*vscale);
      end;

      if getHeight(x,y)<>getHeight(x+1,y) then begin
        glVertex3d((x+1)*hscale,y*hscale,map.map[x,y]*vscale);
        glVertex3d((x+1)*hscale,(y+1)*hscale,map.map[x,y]*vscale);
        glVertex3d((x+1)*hscale,(y+1)*hscale,getHeight(x+1,y)*vscale);
        glVertex3d((x+1)*hscale,y*hscale,getHeight(x+1,y)*vscale);
      end;

      if getHeight(x,y)<>getHeight(x,y-1) then begin
        glVertex3d(x*hscale,y*hscale,map.map[x,y]*vscale);
        glVertex3d((x+1)*hscale,y*hscale,map.map[x,y]*vscale);
        glVertex3d((x+1)*hscale,y*hscale,getHeight(x,y-1)*vscale);
        glVertex3d(x*hscale,y*hscale,getHeight(x,y-1)*vscale);
      end;

      if getHeight(x,y)<>getHeight(x,y+1) then begin
        glVertex3d(x*hscale,(y+1)*hscale,map.map[x,y]*vscale);
        glVertex3d((x+1)*hscale,(y+1)*hscale,map.map[x,y]*vscale);
        glVertex3d((x+1)*hscale,(y+1)*hscale,getHeight(x,y+1)*vscale);
        glVertex3d(x*hscale,(y+1)*hscale,getHeight(x,y+1)*vscale);
      end;
    end;
  glEnd();

  if transparenz.Checked then begin
    glEnable(GL_BLEND);
    glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  end;
  glBegin(GL_QUADS);
  glColor4f(0,0,1,0.5);
  for x:=0 to high(map.map) do
    for y:=0 to high(map.map[x]) do begin
      if map.map[x,y]<>map.water[x,y] then begin
        glVertex3d(x*hscale,y*hscale,map.water[x,y]*vscale);
        glVertex3d((x+1)*hscale,y*hscale,map.water[x,y]*vscale);
        glVertex3d((x+1)*hscale,(y+1)*hscale,map.water[x,y]*vscale);
        glVertex3d(x*hscale,(y+1)*hscale,map.water[x,y]*vscale);
      end;
    end;

  glEnd();
  glEndList;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  img:=TBitmap.Create;
  img.width:=200;
  img.height:=200;
  map:=TMap.Create;
  updatethread:=tupdatethread.Create(img,map);
  updatethread.SuspendWin;
  hscale:=0.25;
  vscale:=1/5000;
  
  pz:=-52;
  rx:=-57;
  FloatSpinEditX.Value:=hscale;
  FloatSpinEditY.Value:=vscale;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if OpenPictureDialog1.Execute then begin
    img.LoadFromFile(OpenPictureDialog1.FileName);
    PaintBox1.Repaint;
    PaintBox1Paint(PaintBox1);
  end;
end;

procedure TForm1.autoUpdateChange(Sender: TObject);
begin
  if autoUpdate.Checked then updatethread.ResumeWin
  else begin
    updatethread.SuspendWin;
    updatethread.useless:=true;
  end;
  Button2.Enabled:=not autoUpdate.Checked;
  Button3.Enabled:=not autoUpdate.Checked;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  screen.Cursor:=crHourGlass;
  if Notebook1.ActivePageComponent=PageImg then
    map.loadFromImage256(img);
  map.completeFill;
  Notebook1.OnPageChanged(Notebook1);
  screen.Cursor:=crDefault;

end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  screen.Cursor:=crHourGlass;
  if Notebook1.ActivePageComponent=PageImg then
    map.loadFromImage256(img);
  map.rainFill(SpinEdit1.Value,SpinEdit4.Value);
  if CheckBox1.Checked then
    map.smooth(SpinEdit5.value);
  Notebook1.OnPageChanged(Notebook1);
  screen.Cursor:=crDefault;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  if SavePictureDialog1.Execute then
    img.SaveToFile(SavePictureDialog1.FileName);
end;

procedure TForm1.Button5Click(Sender: TObject);
var x,y:longint;
begin
  for x:=0 to img.width-1 do
    for y:=0 to img.height-1 do
      img.Canvas.Colors[x,y]:=TColorToFPColor(RGBToColor(0,random(256),0));
  PaintBox1Paint(PaintBox1);
end;

procedure TForm1.CheckBox2Change(Sender: TObject);
begin

end;

procedure TForm1.FloatSpinEditXChange(Sender: TObject);
begin
  hscale:=FloatSpinEditX.Value;
  vscale:=FloatSpinEditY.Value;
  Notebook1PageChanged(Notebook1);
  
end;

procedure TForm1.Form1Idle(Sender: TObject; var Done: Boolean);
begin
  if (w32ogl<>nil) and (length(map.map)>0)then begin
    glMatrixMode(GL_modelview);
    glShadeModel(GL_FLAT);
    glLoadIdentity;
    glClearColor(0,0,0,0);
    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
    glTranslatef(0,0,pz);
//    glTranslatef(0,0,pz);
    glRotatef(ry,0,1,0);
    glRotatef(rx,1,0,0);
    glTranslatef(px*hscale,py*hscale,0);

    glTranslatef(-hscale*length(map.map) /2,-hscale*length(map.map[0])/2,0);

    glColor4f(1,1,1,0.5);


    glCallList(1);

    w32ogl.endScene;
    done:=false;
  end else done:=true;

end;

procedure TForm1.lightChange(Sender: TObject);
const
  mat_specular   : Array[0..3] of GlFloat = (0.3, 0.3, 0.3, 0.3);
  mat_shininess  : Array[0..0] of GlFloat = (50.0);
  mat_ambient    : Array[0..3] of GlFloat = (1, 1, 1, 1.0);
  mat_diffuse    : Array[0..3] of GlFloat = (1, 1, 1, 1.0);

  light_position : Array[0..3] of GlFloat = (0.0, 0.0, -5.0, 1.0);
  light_ambient  : Array[0..3] of GlFloat = (0.1, 0.1, 0.1, 1.0);
  light_diffuse  : Array[0..3] of GlFloat = (0.8, 0.8, 0.8, 1.0);
begin
  if light.checked then begin
    glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT0);
    glEnable(GL_COLOR_MATERIAL);
    glLoadIdentity;

    glMaterialfv(GL_FRONT, GL_SPECULAR,  @mat_specular[0]);
    glMaterialfv(GL_FRONT, GL_SHININESS, @mat_shininess[0]);
    glMaterialfv(GL_FRONT, GL_AMBIENT,   @mat_ambient[0]);
    glMaterialfv(GL_FRONT, GL_DIFFUSE,   @mat_diffuse[0]);

    glLightfv(GL_LIGHT0, GL_AMBIENT,  @light_ambient[0]);
    glLightfv(GL_LIGHT0, GL_DIFFUSE,  @light_diffuse[0]);
    glLightfv(GL_LIGHT0, GL_POSITION, @light_position[0]);
  end else begin
    glDisable(GL_LIGHTING);
    glDisable(GL_COLOR_MATERIAL);
  end;
end;

procedure TForm1.SpinEdit3Change(Sender: TObject);
begin
  img.width:=SpinEdit2.Value;
  img.Height:=SpinEdit3.Value;
  map.setSize(img.width,img.height);
  PaintBox1.Repaint;
  Notebook1PageChanged(Notebook1);
end;

procedure TForm1.transparenzChange(Sender: TObject);
begin
  Notebook1PageChanged(Notebook1);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  updatethread.useless:=true;
  while updatethread.running do begin
    updatethread.stop:=true;
    updatethread.ResumeWin;
    sleep(50);
  end ;
  map.free;
  img.free;
  if w32ogl<>nil then begin
    ogl.free;
    FreeAndNil(w32ogl);
  end;
end;

procedure TForm1.Notebook1PageChanged(Sender: TObject);
var x,y:longint;
begin
  Application.OnIdle:=nil;
  if length(map.map)=0 then exit;
  if length(map.water)=0 then exit;
  if Notebook1.ActivePageComponent=PageImg then begin
    map.displayWater256(img);
    PaintBox1Paint(PaintBox1);
  end else if Notebook1.ActivePageComponent=Page3D then begin
    if w32ogl=nil then begin
      w32ogl:=TOGLW32Base.create(oglOutput.Handle);
      ogl:=TOGLRenderer.Create;
      ogl.init();
    end;
    oglOutputResize(oglOutput);
    render3D(1);
    Application.OnIdle:=@Form1Idle;
  end else if Notebook1.ActivePageComponent=PageMap then begin
    StringGridMap.RowCount:=length(map.map);
    StringGridMap.ColCount:=length(map.map[0]);
    for x:=0 to high(map.map) do
      for y:=0 to high(map.map[x]) do
        StringGridMap.Cells[x,y]:=IntToStr(map.map[x,y]);
  end else if Notebook1.ActivePageComponent=PageWater then begin
    StringGridWater.RowCount:=length(map.water);
    StringGridWater.ColCount:=length(map.water[0]);
    for x:=0 to high(map.water) do
      for y:=0 to high(map.water[x]) do
        StringGridWater.Cells[x,y]:=IntToStr(map.water[x,y]);
  end;
end;

procedure TForm1.oglOutputMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  cx:=x;
  cy:=y;
  cpx:=px;
  cpy:=py;
  cpz:=pz;
  crx:=rx;
  cry:=ry;
end;

procedure TForm1.oglOutputMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if ssRight in shift then begin
    pz:=cpz+(cy-y)/50;
    //viewChanged;
  end else if ssleft in shift then
    if not (ssShift in shift) then begin
      rx:=crx+y-cy;
      ry:=cry+x-cx;
    //  viewChanged;
    end else begin
      px:=cpx-x+cx;
      py:=cpy-y+cy;
    end;
  pos3d.Caption:=Format('x: %1.2f y: %1.2f z: %1.2f rx: %1.2f ry: %1.2f',[px,py,pz,rx,ry]);
end;

procedure TForm1.oglOutputMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin

end;

procedure TForm1.oglOutputResize(Sender: TObject);
begin
  if (w32ogl<>nil)and(length(map.map)>0) then begin
    ogl.zFar:=length(map.map)*length(map.map[0])*hscale*hscale;
    ogl.resize(oglOutput.ClientWidth,oglOutput.ClientHeight);
  end;
end;

procedure TForm1.PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if drawing.Checked then begin
    updatethread.SuspendWin;
    updatethread.useless:=true;
    img.canvas.pen.FPColor:=Shape1.Brush.FPColor;
    img.canvas.pen.Width:=brushsize.Position;
    img.Canvas.moveto(x,y);
    img.Canvas.lineto(x,y);
    PaintBox1Paint(PaintBox1);
  end;

end;

procedure TForm1.PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if ( ssLeft in shift) and drawing.Checked then begin
{    img.canvas.Brush.Assign(Shape1.Brush);
    img.canvas.Brush.Style:=bsSolid;
    img.Canvas.pen.Style:=psClear;
    img.Canvas.EllipseC(x,y,brushsize.Position,brushsize.Position);}
    img.Canvas.lineto(x,y);
    PaintBox1Paint(PaintBox1);
  end;
  if (x>0) and (y>0)and(length(map.map)>x)and(length(map.map[0])>y) then begin
    label1.Caption:='Berghöhe: '+inttostr(map.map[x,y])+' Wasserstand: '+IntToStr(map.water[x,y]);
  end;
end;

procedure TForm1.PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if autoUpdate.Checked then
    updatethread.ResumeWin;
end;

{ tupdatethread }

procedure tupdatethread.ResumeWin;
var rh:thandle;
begin
  hacksusped:=false;
end;

procedure tupdatethread.SuspendWin;
begin
  hacksusped:=true;
end;

procedure tupdatethread.execute;
begin
  running:=true;
  while not stop do begin
    while hacksusped do sleep(50); //warum geht das scheiß tthread.resume nicht?????
    useless:=false;
    map.loadFromImage256(img);
    map.completeFill;
    if not useless then begin
      map.displayWater256(img);
      done:=true; //todo: message
      SuspendWin;
      //PaintBox1.Repaint;
    end;
  end;
  running:=false;
end;


constructor tupdatethread.create(aimg: TBitmap; amap: TMap);
begin
  img:=aimg;;
  map:=amap;
  stop:=false;
  useless:=false;
  
  inherited Create(false               );
end;

initialization
  {$I user.lrs}

end.

