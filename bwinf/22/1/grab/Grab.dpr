program Grab;

uses
  Forms,
  Grab_u in 'Grab_u.pas' {frmGrab};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfrmGrab, frmGrab);
  Application.Run;
end.
