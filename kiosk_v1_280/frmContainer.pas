unit frmContainer;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.Ani, FMX.Layouts, FMX.Gestures,
  FMX.ScrollBox, FMX.Memo, FMX.StdCtrls, FMX.Controls.Presentation, FMX.Edit,
  FMX.ListBox, IdBaseComponent, winprocs, FMX.Media;

type
  TContainer = class(TForm)
    Layout: TLayout;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure onException(Sender: TObject; E: Exception);
  end;

var
  Container: TContainer;

implementation

uses
  uConsts, uGlobal, uFunction, uCommon, fx.Logging, uSaleModule;

{$R *.fmx}

procedure TContainer.FormCreate(Sender: TObject);
//var
  //RS: TResourceStream;
  //HC: HCURSOR;
begin
  {
  RS := TResourceStream.Create(MainInstance, 'XPartners_HourGlass', 'ANICURSOR');
  try
    HC := CreateIconFromResourceEx(RS.Memory, RS.Size, False, $30000, 100, 100, LR_DEFAULTCOLOR);
    Win32Check(HC <> 0);
    Screen.Cursors[crHourGlass] := HC;
  finally
    RS.Free;
  end;
  }
  //Log.D('KIOSK FormCreate', '---------- ' + FormatDateTime('yyyymmdd hh:nn:ss', now) + ' ----------' + 'Ver. ' + GetFileVersion);
  Global := TGlobal.Create;
end;

procedure TContainer.FormDestroy(Sender: TObject);
begin
  Global.Free;
  SystemParametersInfo(SPI_SETSCREENSAVEACTIVE, Ord(True), nil, 0); // 화면보호기 비활성화
  ShowWindow(FindWindow('Shell_TrayWnd', nil), SW_SHOW);            // 작업표시줄 비활성화
  ShowCursor(True);                                                 // 커서
  {$IFDEF RELEASE}
  if IsRunningProcess('KioskCall.exe') then
    KillProcess('KioskCall.exe');
  {$ENDIF}
end;

procedure TContainer.FormShow(Sender: TObject);
var
  bResult: Boolean;
begin
  Log.D('KIOSK START', '---------- ' + FormatDateTime('yyyymmdd hh:nn:ss', now) + ' ----------' + 'Ver. ' + GetFileVersion);

  if IsRunningProcess('KioskCall.exe') then
    KillProcess('KioskCall.exe');

  Application.OnException := onException;
  {$IFDEF RELEASE}
  SystemParametersInfo(SPI_SETSCREENSAVEACTIVE, Ord(False), nil, 0); // 화면보호기 비활성화
  //ShowWindow(FindWindow('Shell_TrayWnd', nil), SW_HIDE);             // 작업표시줄 비활성화
  ShowCursor(False);
  {$ENDIF}
  {$IFDEF DEBUG}
  Self.Top := 0;
  Self.Left := 0;
  {
  Self.Height := DEBUG_HEIGHT;
  Self.Width := DEBUG_WIDTH;
  Self.Layout.Scale.X := DEBUG_SCALE;
  Self.Layout.Scale.Y := DEBUG_SCALE;
  }
  {$ENDIF}

  if Global.Config.ProgramVersion = pvASP then
    bResult := ShowMasterDownload(True, True, True, True, True);

  if bResult = True then
    ShowMain;

  Close;
end;

procedure TContainer.onException(Sender: TObject; E: Exception);
begin
  try
    Log.E('Application onException', E.Message);
  except
    on E: Exception do
    begin

    end;
  end;
end;

end.


