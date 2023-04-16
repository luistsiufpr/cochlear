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

    procedure PrepareCaptions;
    procedure UpdateUI(const bReset: Boolean = False);
    procedure Reset;
    procedure ImportTextFile;
    procedure GetINIParams;
    procedure Process;
  public
    { Public declarations }
  end;

var
  Main: TMain;

implementation

uses
  System.IniFiles, System.UITypes, uDM;

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
  mmInput.Lines.Add(DM.GenerateTextRandomly);
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
    DM.iMaxRandomStrSize := oIniFile.ReadInteger('OPTIONS', 'MaxRandomStrSize', 50);
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
    mmResult.Lines.Add(DM.Process(mmInput.Lines.Text));
    UpdateUI;
  end;
end;

procedure TMain.Reset;
begin
  UpdateUI(True);
end;

end.
