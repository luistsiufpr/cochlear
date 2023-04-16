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
    iMaxRandomStrSize: integer;

    function Process(const sText: String): String;
    function GetCurrentSequenceLength(var arSeq: TArray<String>): Integer;
    procedure CleanUpCurrentSequence(var arSeq: TArray<String>);
    procedure AddToCurrentSequence(var arSeq: TArray<String>; const cValue: Char);
    procedure NewSequence(var arSeq: TArray<String>);
    function GetIntegerValueOfChar(const cValue: Char): Integer;
    function GenerateTextRandomly: String;
    function SummarizeResults(var arSeq: TArray<String>; const sText: String): String;
  end;

var
  DM: TDM;

const
  sBaseRandomStr = '1234567890abcdefghijklmnopqrstuvwxyz';

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

uses
  System.Character, StrUtils, System.Generics.Collections;

{$R *.dfm}

{ TDM }

procedure TDM.AddToCurrentSequence(var arSeq: TArray<String>;
  const cValue: Char);
begin
  arSeq[Length(arSeq) - 1] := arSeq[Length(arSeq) - 1] + cValue;
end;

procedure TDM.CleanUpCurrentSequence(var arSeq: TArray<String>);
begin
  arSeq[Length(arSeq) - 1] := EmptyStr;
end;

function TDM.GenerateTextRandomly: String;
var
  iCount:integer;
begin
  Result := EmptyStr;
  for iCount := 1 to iMaxRandomStrSize do
    Result := Result + sBaseRandomStr[Random(Length(sBaseRandomStr))+1];
end;

function TDM.GetCurrentSequenceLength(var arSeq: TArray<String>): Integer;
begin
  Result := arSeq[Length(arSeq) - 1].Length;
end;

function TDM.GetIntegerValueOfChar(const cValue: Char): Integer;
begin
  Result := Integer(cValue) - Integer('0');
end;

procedure TDM.NewSequence(var arSeq: TArray<String>);
begin
  SetLength(arSeq, Length(arSeq)+ 1);
  arSeq[Length(arSeq) - 1] := EmptyStr;
end;

function TDM.Process(const sText: String): String;
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

function TDM.SummarizeResults(var arSeq: TArray<String>;
  const sText: String): String;
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
