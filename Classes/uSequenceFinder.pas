unit uSequenceFinder;

interface

uses
  Classes, System.Generics.Collections, Generics.Defaults, uMySingleton;

type
  TSequence = Record
    Text: String;
    Count: Integer;
  end;


  TSequenceFinder = class(TPersistent)
  private
    FsTextToProcess: string;
    FsResult: String;

    procedure SetTextToProcess(const Value: string);
    function GetBaseRandomStr: String;
    function GetResult: String;

    procedure AddSequenceToList(var rSeq: TSequence; var lsSeqs: TList<TSequence>);
    procedure CleanUpCurrentSequence(var rSeq: TSequence);
    procedure AddToCurrentSequence(var rSeq: TSequence; const cValue: Char);
    procedure NewSequence(var rSeq: TSequence);
    function GetIntegerValueOfChar(const cValue: Char): Integer;
  public
    procedure Process;
    function GenerateTextRandomly(const PiMaxSize: Integer): String;

    property TextToProcess: string write SetTextToProcess;
    property BaseRandomStr: String read GetBaseRandomStr;
    property Result: String read GetResult;
  end;

  TSequenceComparer = class(TComparer<TSequence>)
  public
    function Compare(const Left, Right: TSequence): Integer; override;
  end;

  TSequenceFinderSingleton = class(TMySingleton<TSequenceFinder>);

implementation

uses
  Character, StrUtils, SysUtils;


{ TSequenceFinder }

procedure TSequenceFinder.AddSequenceToList(var rSeq: TSequence; var lsSeqs: TList<TSequence>);
var
  bExists: Boolean;
  i: Integer;
begin
  bExists := False;

  for i := 0 to lsSeqs.Count - 1 do
    if lsSeqs.Items[i].Text = rSeq.Text then
    begin
      rSeq.Count := lsSeqs.Items[i].Count + 1;
      lsSeqs.Items[i] := rSeq;
      bExists := True;
      Break;
    end;

  if not bExists then
    lsSeqs.Add(rSeq);
end;

procedure TSequenceFinder.AddToCurrentSequence(var rSeq: TSequence; const cValue: Char);
begin
  rSeq.Text := rSeq.Text + cValue;
end;

procedure TSequenceFinder.CleanUpCurrentSequence(var rSeq: TSequence);
begin
  NewSequence(rSeq);
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

function TSequenceFinder.GetIntegerValueOfChar(const cValue: Char): Integer;
begin
  Result := Integer(cValue) - Integer('0');
end;

function TSequenceFinder.GetResult: String;
begin
  Result := FsResult;
end;

procedure TSequenceFinder.NewSequence(var rSeq: TSequence);
begin
  rSeq.Text := EmptyStr;
  rSeq.Count := 1;
end;

procedure TSequenceFinder.Process;
var
  iCount: Integer;
  cCurrentChar, cLastIntegerChar: Char;
  rSequence, rAux: TSequence;
  lsSequences: TList<TSequence>;
  iCmp: IComparer<TSequence>;
begin
  cLastIntegerChar := Char(0);
  cCurrentChar := Char(0);

  NewSequence(rSequence);

  iCmp := TSequenceComparer.Create;
  lsSequences := TList<TSequence>.Create(iCmp);
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
            AddToCurrentSequence(rSequence, cCurrentChar);

            if (Length(rSequence.Text) > 1) and (iCount = Length(FsTextToProcess))  then
              AddSequenceToList(rSequence, lsSequences);
          end
          else if (Length(rSequence.Text) = 1) then
          //The previous and the current number are not a sequence, and the current sequence in the array has only one number
          // so we reset the current sequence in the array to empty
          begin
            CleanUpCurrentSequence(rSequence);
            AddToCurrentSequence(rSequence, cCurrentChar);
          end
          else//the previous and the current number are not a sequence, but there is a sequence with more than one number
          //so we start a new sequence in the array
          begin
            AddSequenceToList(rSequence, lsSequences);
            NewSequence(rSequence);
            AddToCurrentSequence(rSequence, cCurrentChar);
          end;
        end
        else//there is no previous number, so this is the begining of a potential sequence
        begin
          AddToCurrentSequence(rSequence, cCurrentChar);
        end;

        cLastIntegerChar := cCurrentChar;
      end
      else
      begin
        if (Length(rSequence.Text) = 1) then
        //If the current sequence is only one char long, then we reset the it
        begin
          CleanUpCurrentSequence(rSequence);
        end
        else if (Length(rSequence.Text) <> 0) then //otherwise, if the current sequence is longer than one char, we start a new one
        begin
          AddSequenceToList(rSequence, lsSequences);
          NewSequence(rSequence);
        end;

        cLastIntegerChar := Char(0);
      end;
    end;

    lsSequences.Sort;
    lsSequences.Reverse;

    FsResult  := FsTextToProcess + sLineBreak + sLineBreak;
    for rAux in lsSequences do
      FsResult  := FsResult  + sLineBreak + rAux.Text + ' ' + IntToStr(rAux.Count);
  finally
    lsSequences.Free;
  end;
end;

procedure TSequenceFinder.SetTextToProcess(const Value: string);
begin
  FsTextToProcess := Value;
end;

{ TSequenceComparer }

function TSequenceComparer.Compare(const Left, Right: TSequence): Integer;
begin
  Result := Left.Count - Right.Count;
  if Result = 0 then
    Result := StrToInt(Left.Text) - StrToInt(Right.Text);
end;

end.
