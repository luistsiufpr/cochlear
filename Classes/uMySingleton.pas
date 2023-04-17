unit uMySingleton;

interface

uses
  System.SysUtils, System.Classes;

type
  TMySingleton<T: class, constructor> = class(TPersistent)
  strict private
    class var FInstance: T;
  public
    class function GetInstance: T; overload;
    class procedure ReleaseInstance;
  end;

implementation

class function TMySingleton<T>.GetInstance: T;
begin
  if not Assigned(FInstance) then
  begin
    FInstance := T.Create;
  end;

  Result := FInstance;
end;

class procedure TMySingleton<T>.ReleaseInstance;
begin
  if Assigned(FInstance) then
    FreeAndNil(FInstance);
end;

end.
