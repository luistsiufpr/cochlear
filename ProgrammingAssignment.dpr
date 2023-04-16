program ProgrammingAssignment ;

uses
  Vcl.Forms,
  UIMain in 'Forms\UIMain.pas' {Main},
  uDM in 'DMs\uDM.pas' {DM: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TMain, Main);
  Application.Run;
end.
