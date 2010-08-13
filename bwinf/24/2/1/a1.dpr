program a1;

uses
  Forms,
  a1_i in 'a1_i.pas' {museumForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TmuseumForm, museumForm);
  Application.Run;
end.
