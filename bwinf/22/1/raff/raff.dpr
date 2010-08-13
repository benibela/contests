program Raff;

uses
  Forms,
  raff_u in 'raff_u.pas' {frmRaff};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfrmRaff, frmRaff);
  Application.Run;
end.
