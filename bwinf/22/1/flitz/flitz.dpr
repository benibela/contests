program flitz;

uses
  Forms,
  flitz_u in 'flitz_u.pas' {frmFlitz};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfrmFlitz, frmFlitz);
  Application.Run;
end.
