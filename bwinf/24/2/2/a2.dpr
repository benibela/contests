program a2;

uses
  Forms,
  a2_u in 'a2_u.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
