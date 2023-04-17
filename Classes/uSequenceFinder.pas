unit uSequenceFinder;

interface

uses
  Classes, System.Generics.Collections, uMySingleton;

type
  TSequenceFinder = class(TPersistent)
  private
    FsTextToProcess: string;
    FsResult: String;

    procedure SetTextToProcess(const Value: string);
    function GetBaseRandomStr: String;
    function GetResult: String;

    function GetCurrentSequenceLength(var arSeq: TArray<String>): Integer;
    procedure CleanUpCurrentSequence(var arSeq: TArray<String>);
    procedure AddToCurrentSequence(var arSeq: TArray<String>; const cValue: Char);
    procedure NewSequence(var arSeq: TArray<String>);
    function GetIntegerValueOfChar(const cValue: Char): Integer;
    function SummarizeResults(var arSeq: TArray<String>; const sText: String): String;
  public
    procedure Process;
    function GenerateTextRandomly(const PiMaxSize: Integer): String;

    property TextToProcess: string write SetTextToProcess;
    property BaseRandomStr: String read GetBaseRandomStr;
    property Result: String read GetResult;
end;

  TSequenceFinderSingleton = class(TMySingleton<TSequenceFinder>);

implementation

uses
  Character, StrUtils, SysUtils;


{ TSequenceFinder }

procedure TSequenceFinder.AddToCurrentSequence(var arSeq: TArray<String>;
  const cValue: Char);
begin
  arSeq[Length(arSeq) - 1] := arSeq[Length(arSeq) - 1] + cValue;
end;

procedure TSequenceFinder.CleanUpCurrentSequence(var arSeq: TArray<String>);
begin
  arSeq[Length(arSeq) - 1] := EmptyStr;
end;

function TSequenceFinder.GenerateTextRandomly(const PiMaxSize: Integer): String;
var
  iCount:integer;
begin
  Result := EmptyStr;
  for iCount := 1 to PiMaxSize do
    Result := Result + BaseRandomStr[Random(Length(BaseRandomStr))+1];
end;

function TSequenceFinder.GetBaseRandomStr: String;
begin
  Result := '1234567890abcdefghijklmnopqrstuvwxyz';
end;

function TSequenceFinder.GetCurrentSequenceLength(
  var arSeq: TArray<String>): Integer;
begin
  Result := arSeq[Length(arSeq) - 1].Length;
end;

function TSequenceFinder.GetIntegerValueOfChar(const cValue: Char): Integer;
begin
  Result := Integer(cValue) - Integer('0');
end;

function TSequenceFinder.GetResult: String;
begin
  Result := FsResult;
end;

procedure TSequenceFinder.NewSequence(var arSeq: TArray<String>);
begin
  SetLength(arSeq, Length(arSeq)+ 1);
  arSeq[Length(arSeq) - 1] := EmptyStr;
end;

procedure TSequenceFinder.Process;
var
  iCount: Integer;
  arSequences: TArray<String>;
  cCurrentChar, cLastIntegerChar: Char;
begin
  cLastIntegerChar := Char(0);
  cCurrentChar := Char(0);

  NewSequence(arSequences);

  try
    for iCount := 1 to Length(FsTextToProcess) do
    begin
      cCurrentChar := FsTextToProcess[iCount];

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

    FsResult := SummarizeResults(arSequences, FsTextToProcess);
  finally
    arSequences := nil;
  end;
end;

procedure TSequenceFinder.SetTextToProcess(const Value: string);
begin
  FsTextToProcess := Value;
end;

function TSequenceFinder.SummarizeResults(var arSeq: TArray<String>;
  const sText: String): String;
var
  dSummary: TDictionary<String,Integer>;
  pItemSeq: TPair<String,Integer>;
  i,j: Integer;
  arToRemove: TArray<String>;
  sRemove: String;
  arResult: TArray<TArray<String>>;
  iHighest: Integer;

  procedure InsertSorted(var arAux: TArray<String>; const sValue: String);
  var
    k,l: Integer;
  begin
    SetLength(arAux, Length(arAux) + 1);
    k := 0;

    while (arAux[k] <> EmptyStr) and (StrToInt(sValue) > StrToInt(arAux[k])) do
      Inc(k);

    if k < (Length(arAux) - 1) then
      for l := (Length(arAux) -1) downto (k + 1) do
        arAux[l] := arAux[l-1];

    arAux[k] := sValue;
  end;
begin
  //This method is too long and likely not the best solution, but I didnt realized the
  //final list needed to be sorted until my last read of the assignment...
  //The is what I could do with the time I had.
  Result := sText + sLineBreak + sLineBreak;
  iHighest := 0;

  dSummary := TDictionary<String,Integer>.Create;
  for i := 0 to (Length(arSeq) - 1) do
  begin
    if arSeq[i] <> EmptyStr then
    begin
      if dSummary.ContainsKey(arSeq[i]) then
        dSummary.Items[arSeq[i]] := (dSummary.Items[arSeq[i]] + 1)
      else
        dSummary.Add(arSeq[i], 1);

      if iHighest < dSummary.Items[arSeq[i]] then
        iHighest := dSummary.Items[arSeq[i]];
    end;
  end;

  i := 1;
  SetLength(arResult, iHighest);
  SetLength(arToRemove, 0);
  try
    while dSummary.Count > 0 do
    begin
      for pItemSeq in dSummary do
      begin
        if i = pItemSeq.Value then
        begin
          InsertSorted(arResult[i-1], pItemSeq.Key);

          SetLength(arToRemove, Length(arToRemove) + 1);
          arToRemove[Length(arToRemove) - 1] := pItemSeq.Key;
        end;
      end;

      for sRemove in arToRemove do
        dSummary.Remove(sRemove);
      SetLength(arToRemove, 0);

      Inc(i);
    end;


    for i := (Length(arResult) - 1) downto 0 do
    begin
      if arResult[i] <> nil then
      begin
        for j := Length(arResult[i]) - 1 downto 0 do
          Result := Result + sLineBreak + arResult[i][j] + ' ' + IntToStr(i + 1);
      end;
    end;

  finally
    arToRemove := nil;
    arResult := nil;
  end;
end;

end.
