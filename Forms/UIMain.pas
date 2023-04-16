unit UIMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtDlgs;

type
  TMain = class(TForm)
    pnlTop: TPanel;
    imgLogo: TImage;
    lblBold: TLabel;
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    pnlBottom: TPanel;
    Bevel1: TBevel;
    pcMain: TPageControl;
    tsInput: TTabSheet;
    tsResult: TTabSheet;
    pnlInput: TPanel;
    btnClose: TButton;
    btnAction: TButton;
    pnlButtons: TPanel;
    btnGenerate: TButton;
    mmInput: TMemo;
    btnImport: TButton;
    pnlTopInput: TPanel;
    pnlResult: TPanel;
    mmResult: TMemo;
    pnlTopResult: TPanel;
    dlgFile: TOpenTextFileDialog;
    procedure btnActionClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnImportClick(Sender: TObject);
    procedure btnGenerateClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    iMaxRandomStrSize: integer;

    sCaptionProcess,
    sCaptionReset,
    sCaptionClose,
    sBoldLabelCaption,
    sLabel1Caption,
    sLabel2Caption,
    sLabel3Caption,
    sPnlInputCaption,
    sPnlResultCaption,
    sFormCaption,
    sBtnImportCaption,
    sBtnGenerateCaption,
    sAlertMsgFileNotFound,
    sAlertErrorOpeningFile,
    sAlertNoTextToProcess: String;

    //UI related routines
    procedure PrepareCaptions;
    procedure UpdateUI(const bReset: Boolean = False);
    procedure Reset;
    procedure ImportTextFile;
    procedure GetINIParams;
    procedure Process; overload;

    //Business rules routines
    function Process(const sText: String): String; overload;
    function GetCurrentSequenceLength(var arSeq: TArray<String>): Integer;
    procedure CleanUpCurrentSequence(var arSeq: TArray<String>);
    procedure AddToCurrentSequence(var arSeq: TArray<String>; const cValue: Char);
    procedure NewSequence(var arSeq: TArray<String>);
    function GetIntegerValueOfChar(const cValue: Char): Integer;
    procedure GenerateTextRandomly;
    function SummarizeResults(var arSeq: TArray<String>; const sText: String): String;
  public
    { Public declarations }
  end;

const
  sBaseRandomStr = '1234567890abcdefghijklmnopqrstuvwxyz';

var
  Main: TMain;

implementation

uses
  System.IniFiles, System.UITypes, System.Character, StrUtils, System.Generics.Collections;

{$R *.dfm}

procedure TMain.btnActionClick(Sender: TObject);
begin
  if btnAction.Caption = sCaptionReset then
    Reset
  else
    Process;
end;

procedure TMain.btnCloseClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TMain.btnGenerateClick(Sender: TObject);
begin
  GenerateTextRandomly;
end;

procedure TMain.btnImportClick(Sender: TObject);
begin
  ImportTextFile;
end;

procedure TMain.FormCreate(Sender: TObject);
begin
  GetINIParams;
  PrepareCaptions;
end;

procedure TMain.FormShow(Sender: TObject);
begin
  UpdateUI(True);
end;

procedure TMain.GetINIParams;
var
  oIniFile: TIniFile;
  sLanguage: String;
begin
  oIniFile := TIniFile.Create(ChangeFileExt(Application.ExeName,'.INI' ));
  try
    iMaxRandomStrSize := oIniFile.ReadInteger('OPTIONS', 'MaxRandomStrSize', 50);
    sLanguage := oIniFile.ReadString('OPTIONS', 'Language', 'EN');

    sCaptionProcess := UTF8ToString(RawByteString(oIniFile.ReadString(sLanguage, 'Caption1', 'Text not found')));
    sCaptionReset := UTF8ToString(RawByteString(oIniFile.ReadString(sLanguage, 'Caption2', 'Text not found')));
    sCaptionClose := UTF8ToString(RawByteString(oIniFile.ReadString(sLanguage, 'Caption3', 'Text not found')));
    sBoldLabelCaption := UTF8ToString(RawByteString(oIniFile.ReadString(sLanguage, 'Caption4', 'Text not found')));
    sLabel1Caption := UTF8ToString(RawByteString(oIniFile.ReadString(sLanguage, 'Caption5', 'Text not found')));
    sLabel2Caption := UTF8ToString(RawByteString(oIniFile.ReadString(sLanguage, 'Caption6', 'Text not found')));
    sLabel3Caption := UTF8ToString(RawByteString(oIniFile.ReadString(sLanguage, 'Caption7', 'Text not found')));
    sPnlInputCaption := UTF8ToString(RawByteString(oIniFile.ReadString(sLanguage, 'Caption8', 'Text not found')));
    sPnlResultCaption := UTF8ToString(RawByteString(oIniFile.ReadString(sLanguage, 'Caption9', 'Text not found')));
    sFormCaption := UTF8ToString(RawByteString(oIniFile.ReadString(sLanguage, 'Caption10', 'Text not found')));
    sBtnImportCaption := UTF8ToString(RawByteString(oIniFile.ReadString(sLanguage, 'Caption11', 'Text not found')));
    sBtnGenerateCaption := UTF8ToString(RawByteString(oIniFile.ReadString(sLanguage, 'Caption12', 'Text not found')));
    sAlertMsgFileNotFound := UTF8ToString(RawByteString(oIniFile.ReadString(sLanguage, 'Message1', 'Text not found')));
    sAlertErrorOpeningFile := UTF8ToString(RawByteString(oIniFile.ReadString(sLanguage, 'Message2', 'Text not found')));
    sAlertNoTextToProcess := UTF8ToString(RawByteString(oIniFile.ReadString(sLanguage, 'Message3', 'Text not found')));
  finally
    oIniFile.Free;
  end;
end;

procedure TMain.ImportTextFile;
begin
  mmInput.Lines.Clear;
  if dlgFile.Execute then
  begin
    if FileExists(dlgFile.FileName) then
    begin
      try
        mmInput.Lines.LoadFromFile(dlgFile.FileName);
        //There is roomm for improvement... validate file type is really text instead of catching the exception
      Except
        on e: Exception do
          MessageDlg(sAlertErrorOpeningFile, TMsgDlgType.mtWarning, [mbOK], 0);
      end;
    end
    else
      MessageDlg(sAlertMsgFileNotFound, TMsgDlgType.mtWarning, [mbOK], 0);
  end;
end;

procedure TMain.UpdateUI(const bReset: Boolean);
begin
  if bReset then
  begin
    pcMain.ActivePage := tsInput;
    mmInput.Lines.Clear;
    mmResult.Lines.Clear;
    btnAction.Caption := sCaptionProcess;
  end
  else
  begin
    pcMain.ActivePage := tsResult;
    btnAction.Caption := sCaptionReset;
  end;
end;

procedure TMain.PrepareCaptions;
begin
  btnAction.Caption := sCaptionProcess;
  btnClose.Caption := sCaptionClose;
  lblBold.Caption := sBoldLabelCaption;
  lbl1.Caption := sLabel1Caption;
  lbl2.Caption := sLabel2Caption;
  lbl3.Caption := sLabel3Caption;
  pnlTopInput.Caption := sPnlInputCaption;
  pnlTopResult.Caption := sPnlResultCaption;
  Self.Caption := sFormCaption;
  btnImport.Caption := sBtnImportCaption;
  btnGenerate.Caption := sBtnGenerateCaption;
end;

procedure TMain.Process;
begin
  if mmInput.Lines.Text.IsEmpty then
    MessageDlg(sAlertNoTextToProcess, TMsgDlgType.mtWarning, [mbOK], 0)
  else
  begin
    mmResult.Lines.Add(Process(mmInput.Lines.Text));
    UpdateUI;
  end;
end;

function TMain.Process(const sText: String): String;
var
  iCount: Integer;
  arSequences: TArray<String>;
  cCurrentChar, cLastIntegerChar: Char;
begin
  cLastIntegerChar := Char(0);
  cCurrentChar := Char(0);

  NewSequence(arSequences);

  try
    for iCount := 1 to sText.Length do
    begin
      cCurrentChar := sText[iCount];

      if cCurrentChar.IsNumber then//if it is a number, we check whether is part of a sequence
      begin
        if cLastIntegerChar <> Char(0) then//if is there a previous number, we continue the verification of the sequence
        begin
          if (GetIntegerValueOfChar(cLastIntegerChar) + 1) = GetIntegerValueOfChar(cCurrentChar) then
          //The previous number and the current one are a sequence of two numbers, so we put them in a string inside the sequences array
          begin
            AddToCurrentSequence(arSequences, cCurrentChar);
          end
          else if (GetCurrentSequenceLength(arSequences) = 1) then
          //The previous and the current number are not a sequence, and the current sequence in the array has only one number
          // so we reset the current sequence in the array to empty
          begin
            CleanUpCurrentSequence(arSequences);
            AddToCurrentSequence(arSequences, cCurrentChar);
          end
          else//the previous and the current number are not a sequence, but there is a sequence with more than one number
          //so we start a new sequence in the array
          begin
            NewSequence(arSequences);
            AddToCurrentSequence(arSequences, cCurrentChar);
          end;
        end
        else//there is no previous number, so this is the begining of a potential sequence
        begin
          AddToCurrentSequence(arSequences, cCurrentChar);
        end;

        cLastIntegerChar := cCurrentChar;
      end
      else
      begin
        if (GetCurrentSequenceLength(arSequences) = 1) then
        //If the current sequence is only one char long, then we reset the it
        begin
          CleanUpCurrentSequence(arSequences);
        end
        else if (GetCurrentSequenceLength(arSequences) <> 0) then //otherwise, if the current sequence is longer than one char, we start a new one
        begin
          NewSequence(arSequences);
        end;

        cLastIntegerChar := Char(0);
      end;
    end;

    if arSequences[Length(arSequences) - 1].Length = 1 then
      SetLength(arSequences, Length(arSequences) - 1);

    Result := SummarizeResults(arSequences, sText);
  finally
    arSequences := nil;
  end;
end;

function TMain.GetCurrentSequenceLength(var arSeq: TArray<String>): Integer;
begin
  Result := arSeq[Length(arSeq) - 1].Length;
end;

procedure TMain.CleanUpCurrentSequence(var arSeq: TArray<String>);
begin
  arSeq[Length(arSeq) - 1] := EmptyStr;
end;

procedure TMain.AddToCurrentSequence(var arSeq: TArray<String>; const cValue: Char);
begin
  arSeq[Length(arSeq) - 1] := arSeq[Length(arSeq) - 1] + cValue;
end;

procedure TMain.NewSequence(var arSeq: TArray<String>);
begin
  SetLength(arSeq, Length(arSeq)+ 1);
  arSeq[Length(arSeq) - 1] := EmptyStr;
end;

function TMain.GetIntegerValueOfChar(const cValue: Char): Integer;
begin
  Result := Integer(cValue) - Integer('0');
end;

procedure TMain.GenerateTextRandomly;
var
  iCount:integer;
  sResult: String;
begin
  mmInput.Lines.Clear;
  for iCount := 1 to iMaxRandomStrSize do
    sResult := sResult + sBaseRandomStr[Random(Length(sBaseRandomStr))+1];

  mmInput.Lines.Add(sResult);
end;

procedure TMain.Reset;
begin
  UpdateUI(True);
end;

function TMain.SummarizeResults(var arSeq: TArray<String>; const sText: String): String;
var
  dSummary: TDictionary<String,Integer>;
  pItemSeq: TPair<String,Integer>;
  iCount: Integer;
begin
  Result := sText + sLineBreak + sLineBreak;

  dSummary := TDictionary<String,Integer>.Create;
  for iCount := 0 to (Length(arSeq) - 1) do
  begin
    if arSeq[iCount] <> EmptyStr then
    begin
      if dSummary.ContainsKey(arSeq[iCount]) then
        dSummary.Items[arSeq[iCount]] := (dSummary.Items[arSeq[iCount]] + 1)
      else
        dSummary.Add(arSeq[iCount], 1);
    end;
  end;

  Result := Result + sLineBreak + sLineBreak;

  for pItemSeq in dSummary do
    Result := Result + pItemSeq.Key + ' ' + pItemSeq.Value.ToString  + sLineBreak;
end;

end.
