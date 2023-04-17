program ProgrammingAssignment ;

uses
  Vcl.Forms,
  UIMain in 'Forms\UIMain.pas' {Main},
  uDM in 'DMs\uDM.pas' {DM: TDataModule},
  uSequenceFinder in 'Classes\uSequenceFinder.pas',
  uMySingleton in 'Classes\uMySingleton.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TMain, Main);
  Application.Run;
end.
