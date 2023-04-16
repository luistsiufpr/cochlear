program ProgrammingAssignment ;

uses
  Vcl.Forms,
  UIMain in 'Forms\UIMain.pas' {Main};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMain, Main);
  Application.Run;
end.
