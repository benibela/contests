unit test_u;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,perm, Grids, ComCtrls;

type
  TPermutation=array of cardinal;
  BigNumber=array of integer;
  TPartFunction=function (const part:TPermutation;const data:pointer):boolean;
  TForm1 = class(TForm)
    Edit1: TEdit;
    Button1: TButton;
    Memo1: TMemo;
    Button4: TButton;
    ProgressBar1: TProgressBar;
    Label4: TLabel;
    fromFile: TRadioButton;
    direct: TRadioButton;
    Label1: TLabel;
    count: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure directClick(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure createParts(const func:TPartFunction;const perm:TPermutation;const data:pointer);
var i,j,k:cardinal;
    max:Cardinal;
    part:TPermutation;
    size:^cardinal;
begin
  //The procedure fakes the length of the part array:
  {$RANGECHECKS OFF}
  if length(perm)>31 then
    Raise Exception.Create('too long');

  SetLength(part,length(perm));
  max:=1 shl length(perm) - 1;
  size:=pointer(cardinal(part)-4);
  for i:=0 to max do begin
    k:=0;
    for j:=0 to high(perm) do begin
      if i and (1 shl j) <>0 then begin
        part[k]:=perm[j];
        inc(k);
      end;
    end;
    size^:=k;
    if not func(part,data) then break;
  end;
  size^:=length(perm);
end;

function nextPermutation(perm: TPermutation):boolean;
var i,j,k,s:integer;
    t: cardinal;
begin
  Result:=false;
  i:=length(perm)-1;
  while (i>0) and (perm[i-1]>perm[i]) do dec(i);
  if (i=0) then exit;
  Result:=true;
  s:=i;
  i:=i-1;
  for j:=i+2 to length(perm)-1 do
    if (perm[j]<perm[s])and(perm[j]>perm[i]) then s:=j;
  t:=perm[s];
  perm[s]:=perm[i];
  perm[i]:=t;
  //rest sortieren
  for j:=i+1 to length(perm)-1 do begin
    k:=j;
    while (perm[k-1]>perm[k])and(k>i+1) do begin
      t:=perm[k-1];
      perm[k-1]:=perm[k];
      perm[k]:=t;
      dec(k);
    end;
  end;

end;


function partFound(const part:TPermutation;const slp:pointer):boolean;
var s:string;
    i:integer;
    sl:Tstringlist;
begin
  sl:=slp;
  if Length(part)> 0 then begin
    s:=chr(part[0]);
    for i:=1 to high(part) do
      s:=s+chr(part[i]);
    sl.add(s);
  end else sl.add('');
  Result:=true;
end;

procedure TForm1.Button1Click(Sender: TObject);
var s:string;
    vperm:TPermutation;
    i,c:integer;
    sl:TStringList;
begin
  ProgressBar1.Visible:=true;
  memo1.Clear;
  s:=Edit1.text;
  sl:=TStringList.create();


  SetLength(vperm,length(s));
  for i:=1 to length(vperm) do
    vperm[i-1]:=ord(s[i]);
  createParts(partFound,vperm,sl);
  sl.sort;
  memo1.lines.Assign(sl);

  c:=1;
  for i:=1 to sl.Count-1 do
    if (sl[i]<>sl[i-1]) then
      inc(c);

  count.text:='Es gibt '+inttostr(c)+' Teilfolgen';
  sl.free;
  ProgressBar1.Visible:=false;
end;



(* Addiert zwei Zahlen mit gleicher Länge
   Übertrag wird beachtet, ABER:
     * die Zahl muss genügend Nullen enthalten, um ihn zu speichern
     * Ist n1=n2, wird jeder Übertrag verdoppelt!
*)
procedure add(s1:BigNumber;const s2:BigNumber{;const stop:integer=0});
var i:integer;
begin
  for i:=high(s1) downto 0 do begin
    s1[i]:=s1[i]+s2[i];
    if s1[i]>=1000000000 then begin
      s1[i]:=s1[i]-1000000000;
      inc(s1[i-1]);
    end;
  end;
end;

(* Subtrahiert zwei Zahlen mit gleicher Länge
   (Übertrag wird beachtet, eine mögliche Verlängerung jedoch nicht)
*)
procedure sub(s1:BigNumber;const s2:BigNumber{;const stop:integer});
var i:integer;
begin
  for i:=high(s1) downto {stop}0 do begin
    s1[i]:=s1[i]-s2[i];
    if s1[i]<0 then begin
      s1[i]:=s1[i]+1000000000;
      dec(s1[i-1]);
    end;
  end;
end;

function toStr(n: BigNumber):string;
var i,strPos:integer;
    t:string;
    noNull:boolean;
begin
  SetLength(result,length(n) * 9);
  noNull:=false;
  strPos:=1;
  for i:=0 to high(n) do begin
    if noNull or (n[i]<>0) then begin
       t:=IntToStr(n[i]);
       if noNull then begin
         move(t[1],result[i*9+strPos +9-length(t)],length(t));
         FillChar(result[i*9+strPos],9-length(t),ord('0'))
       end else begin
         move(t[1],result[i*9+strPos],length(t));
         strPos:=strPos-9+length(t);
         noNull:=true;
        end;
    end else
      strPos:=strPos-9;
  end;
  SetLength(result,length(n)*9+strpos-1);
  if length(result)=0 then result:='0';
end;

function countParts(const str: string):BigNumber;
var i:integer;
    lastParts: array of BigNumber;
    c: integer;

    numberLen,numberSize:integer;
    oldResult:BigNumber;
begin
  numberLen:=trunc(length(str)*ln(2)/ln(1000000000))+1;
  numberSize:=numberLen*sizeof(integer);

  SetLength(result,numberLen);
  SetLength(oldresult,numberLen);
  zeromemory(@result[0],numberSize);
  Result[high(result)]:=1;

  SetLength(lastParts,256);
  ZeroMemory(@lastParts[0],length(lastParts)*sizeof(lastParts[0]));

  if length(str)>50 then begin
    Form1.ProgressBar1.Max:=length(str);
  end;

  for i:=1 to length(str) do begin
    Move(result[0],oldResult[0],numberSize);

    c:=ord(str[i]);
    if lastParts[c]=nil then SetLength(lastParts[c],numberLen)
    else sub(result,lastParts[c]);
    Move(oldresult[0],lastParts[c][0],numberSize);

    add(result,oldResult);
    if i>50 then Form1.ProgressBar1.Position:=i;
  end;
end;


procedure TForm1.Button4Click(Sender: TObject);
var i:integer;
    s:string;
    f:file;
begin
  ProgressBar1.Visible:=true;
  if direct.Checked then
    s:=edit1.text
  else begin
    AssignFile(f,edit1.text);
    reset(f,1);
    SetLength(s,FileSize(f));
    BlockRead(f,s[1],filesize(f));
    CloseFile(f);

    for i:=length(s)downto 1 do
      if not (s[i] in ['A'..'Z','Ü','Ö','Ä','ß',#$A]) then begin
        ShowMessage('error: '+inttostr(i)+': '+s[i-1]+s[i]+s[i+1]);
        exit;
      end else if s[i]=#$A then delete(s,i,1);
    for i:=length(s)downto 1 do
      if not (s[i] in ['A'..'Z','Ü','Ö','Ä','ß']) then begin
        ShowMessage('error: '+inttostr(i)+': '+s[i-1]+s[i]+s[i+1]);
        exit;
      end;
  end;
  count.text:='Es gibt '+ToStr(countParts(s))+' Teilfolgen';;//+' Teilfolgen';
  ProgressBar1.Visible:=false;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
end;
//E:\programs\delphi\bwinf\24\2\2\verwandlung-big.txt
procedure TForm1.directClick(Sender: TObject);
begin
  if direct.Checked then Label4.Caption:='Folge der Übungen:'
  else Label4.Caption:='Dateiname:';
end;

end.

