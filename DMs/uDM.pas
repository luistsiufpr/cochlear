unit uDM;

interface

uses
  System.SysUtils, System.Classes;

type
  TDM = class(TDataModule)
  private
    { Private declarations }
  public
    { Public declarations }

    function Process(const sText: String): String;
    function GenerateTextRandomly(const iMaxSize: Integer): String;
  end;

var
  DM: TDM;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

uses
  uSequenceFinder;

{$R *.dfm}

{ TDM }

function TDM.GenerateTextRandomly(const iMaxSize: Integer): String;
begin
  Result := TSequenceFinderSingleton.GetInstance.GenerateTextRandomly(iMaxSize);
end;

function TDM.Process(const sText: String): String;
begin
  TSequenceFinderSingleton.GetInstance.TextToProcess := sText;
  TSequenceFinderSingleton.GetInstance.Process;
  Result := TSequenceFinderSingleton.GetInstance.Result;
end;

initialization

finalization
  TSequenceFinderSingleton.ReleaseInstance;

end.
