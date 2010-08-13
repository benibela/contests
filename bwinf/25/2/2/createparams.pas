unit createparams;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons;

type

  { TCreateParamsDialog }

  TCreateParamsDialog = class(TForm)
    Button1: TButton;
    Button2: TButton;
    difficulty: TComboBox;
    size: TComboBox;
    horizontal: TComboBox;
    vertical: TComboBox;
    subhorizontal: TComboBox;
    subvertical: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  CreateParamsDialog: TCreateParamsDialog;

implementation

{ TCreateParamsDialog }

procedure TCreateParamsDialog.Button1Click(Sender: TObject);
begin
  ModalResult:=mrOK ;
  close;
end;

procedure TCreateParamsDialog.Button2Click(Sender: TObject);
begin
  ModalResult:=mrCancel ;
  close;
end;

initialization
  {$I createparams.lrs}

end.

