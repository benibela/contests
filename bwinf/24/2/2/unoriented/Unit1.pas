unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,perm,
  StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Memo1: TMemo;
    Memo2: TMemo;
    procedure Button1Click(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
var p: TPermutation;
    i:integer;
    s,o:string;
    sl:TStringList;
begin
  o:=edit1.text;
  SetLength(p,length(edit1.text));
  for i:=1 to length(edit1.text) do
    p[i-1]:=i;

    sl:=TStringList.create;
    sl.add('');

  repeat
    s:='';
    for i:=0 to high(p) do begin
      s:=s+o[p[i]];
      sl.add(s);
    end;
  until not  nextPermutation(p);

  sl.sort;

  memo1.lines.BeginUpdate;
  memo1.lines.Clear;
  memo1.lines.add(sl[0]);
  for i:=1 to sl.count-1 do
    if sl[i]<>sl[i-1] then memo1.lines.add(sl[i]);
  memo1.lines.EndUpdate;
  sl.free;

  memo2.lines.add(o+': '+IntToStr(memo1.lines.count));
  Button1.Caption:=IntToStr(memo1.lines.count);
end;

end.


{
  a^n:      n+1
  a^nb^m
}
