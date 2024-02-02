unit PSHook.DllExports;

interface

uses
  {$IFDEF VER230}
  System.SysUtils,
  Winapi.Windows,
  {$ELSE}
  SysUtils,
  Windows,
  {$ENDIF}
  PSHook.API;

type
  TPSGetMouseHook = function (): IPSMouseHook; stdcall;
  TPSGetKeyboardHook = function (): IPSKeyboardHook; stdcall;

  TPSHook = class
  private
    const PSHook = 'PSHook.dll';
    class var Module: HMODULE;
    class constructor Create;
    class destructor Destroy;
  public
    class var GetMouseHook: TPSGetMouseHook;
    class var GetKeyboardHook: TPSGetKeyboardHook;
  end;

implementation

{ TPSHook }

class constructor TPSHook.Create;
begin
  Module := LoadLibrary(PWideChar(ExtractFilePath(ParamStr(0))+PSHook));
  if Module > 0 then
  begin
    @GetMouseHook := GetProcAddress(Module, 'GetPSMouse');
    @GetKeyboardHook := GetProcAddress(Module, 'GetPSKeyboard');
  end;
end;

class destructor TPSHook.Destroy;
begin
  if Module > 0 then
    FreeLibrary(Module);
end;

end.
