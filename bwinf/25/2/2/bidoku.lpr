program bidoku;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms
  { add your units here }, gui, logic, createparams;

begin
  Application.Initialize;
  Application.CreateForm(TBidokuForm, BidokuForm);
  Application.CreateForm(TCreateParamsDialog, CreateParamsDialog);
  Application.Run;
end.

