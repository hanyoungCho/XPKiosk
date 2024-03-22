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
begin
  Global := TGlobal.Create;
end;

procedure TContainer.FormDestroy(Sender: TObject);
begin
  Global.Free;
  SystemParametersInfo(SPI_SETSCREENSAVEACTIVE, Ord(True), nil, 0); // ȭ�麸ȣ�� ��Ȱ��ȭ
  ShowWindow(FindWindow('Shell_TrayWnd', nil), SW_SHOW);            // �۾�ǥ���� ��Ȱ��ȭ
  ShowCursor(True);                                                 // Ŀ��
  {$IFDEF RELEASE}
  if IsRunningProcess('KioskCall.exe') then
    KillProcess('KioskCall.exe');
  {$ENDIF}
end;

procedure TContainer.FormShow(Sender: TObject);
begin
  Log.D('KIOSK START', '---------- ' + FormatDateTime('yyyymmdd hh:nn:ss', now) + ' ----------' + 'Ver. ' + GetFileVersion);

  if IsRunningProcess('KioskCall.exe') then
    KillProcess('KioskCall.exe');

  Application.OnException := onException;
  {$IFDEF RELEASE}
  SystemParametersInfo(SPI_SETSCREENSAVEACTIVE, Ord(False), nil, 0); // ȭ�麸ȣ�� ��Ȱ��ȭ
  ShowWindow(FindWindow('Shell_TrayWnd', nil), SW_HIDE);             // �۾�ǥ���� ��Ȱ��ȭ
  ShowCursor(False);
  {$ENDIF}
  {$IFDEF DEBUG}
  Self.Top := 0;
  Self.Left := 0;
  Self.Height := DEBUG_HEIGHT;
  Self.Width := DEBUG_WIDTH;
  Self.Layout.Scale.X := DEBUG_SCALE;
  Self.Layout.Scale.Y := DEBUG_SCALE;
  {$ENDIF}

  //chy test
  //{$IFDEF RELEASE}
  ShowMasterDownload(True, True, True, True, True);
  //{$ENDIF}

  ShowMain;

  Log.D('KIOSK END', '--------------------');
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


