unit TestuSequenceFinder;

interface

uses
  TestFramework, Classes, uMySingleton, System.Generics.Collections, uSequenceFinder;

type
  TestTSequenceFinder = class(TTestCase)
  strict private
    FSequenceFinder: TSequenceFinder;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestProcess;
    procedure TestGenerateTextRandomly;
  end;

implementation

procedure TestTSequenceFinder.SetUp;
begin
  FSequenceFinder := TSequenceFinder.Create;
end;

procedure TestTSequenceFinder.TearDown;
begin
  FSequenceFinder.Free;
  FSequenceFinder := nil;
end;

procedure TestTSequenceFinder.TestProcess;
var
  sInput, sResult: String;
begin
  //First input
  sInput := 'asd123qwe457rty89234' + sLineBreak + '567zx01245cvbnm';

  sResult := sInput + sLineBreak + sLineBreak;
  sResult := sResult + sLineBreak + '45 2';
  sResult := sResult + sLineBreak + '567 1';
  sResult := sResult + sLineBreak + '234 1';
  sResult := sResult + sLineBreak + '123 1';
  sResult := sResult + sLineBreak + '89 1';
  sResult := sResult + sLineBreak + '012 1';

  FSequenceFinder.TextToProcess := sInput;
  FSequenceFinder.Process;

  CheckEqualsString(sResult, FSequenceFinder.Result, 'The processing failed - First input!');


  //Second input
  sInput := 's7u6ygblk661voq5bl1x5rmq7lbc0qy2ax1fmbpn2zazi96ysw85lsk20z5r6mnbgggtj29y3n8ercv6laupzrw5q0uo6jt5wmvmn0mzhxfj7reskw39c2m2fb6cpozv7eb5qirxk003mns9mzd7ir';

  sResult := sInput + sLineBreak + sLineBreak;

  FSequenceFinder.TextToProcess := sInput;
  FSequenceFinder.Process;

  CheckEqualsString(sResult, FSequenceFinder.Result, 'The processing failed - Second input');


  //Third input
  sInput := '11Teste123--pojj45lkkiii878900teste22212312312323223';

  sResult := sInput + sLineBreak + sLineBreak;
  sResult := sResult + sLineBreak + '123 4';
  sResult := sResult + sLineBreak + '23 2';
  sResult := sResult + sLineBreak + '789 1';
  sResult := sResult + sLineBreak + '45 1';

  FSequenceFinder.TextToProcess := sInput;
  FSequenceFinder.Process;

  CheckEqualsString(sResult, FSequenceFinder.Result, 'The processing failed - Third input');
end;

procedure TestTSequenceFinder.TestGenerateTextRandomly;
var
  ReturnValue: string;
  PiMaxSize: Integer;
begin
  PiMaxSize := 10;

  ReturnValue := FSequenceFinder.GenerateTextRandomly(PiMaxSize);

  CheckEquals(PiMaxSize, Length(ReturnValue), 'Generation of random text failed!');
end;

initialization
  RegisterTest(TestTSequenceFinder.Suite);
end.

