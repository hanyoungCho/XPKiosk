(*******************************************************************************

  Project     : ���Ͽ�Ŀ�´�Ƽ �����νı� ���� ����
  Author      : �̼���
  Description :
  History     :
    Version   Date         Remark
    --------  ----------   -----------------------------------------------------
    1.3.0.0   2020-11-26   Added ValueClear.
    1.2.0.0   2020-09-21   Added MatchingValue.
    1.0.0.0   2020-07-06   Initial Release.

  Copyright��SolbiPOS Co., Ltd. 2008-2020 All rights reserved.

*******************************************************************************)
unit uUCBioBSPHelper;

interface

uses
  Classes, SysUtils, ExtCtrls, Windows, DB;

type
  TUCBioBSPHelper = class
  private
    FUCBioBSP: Variant;
    FDevice: Variant;
    FExtraction: Variant;
    FMatching: Variant;

    FActive: Boolean;
    FDataSet: TDataSet; //���� �˻��� �����ͼ�
    FFingerFieldName: string; //���� ���� �ʵ��
    FValueFieldName: string; //���� ��Ī �� ��ȯ�� �ʵ��
    FFingerWindow: HWND; //���� �̹��� ��¿� �ܺ� ��Ʈ�� �ڵ�(0�̸� ��� ����)
    FScanQuality: Integer; //���� ��ĵ ǰ�� ����
    FEnrollQuality: Integer; //���� ���� ǰ�� ����
    FIdentifyQuality: Integer; //���� �ν� ǰ�� ����
    FVerifyQuality: Integer; //���� �� ǰ�� ����
    FSecurityLevel: Integer; //���� ���� ���� ����
    FDefaultTimeout: Integer; //���� �ν� Ÿ�Ӿƿ� ����
    FAutoDetectFinger: Boolean; //�ڵ� ���� �ν�
    FTextFIR: string; //���� �ν� ���ڵ� ��
    FMatchValue: string; //���� ��Ī �� ��ȯ�� ������ �ʵ� ��
    FSuccess: Boolean; //���� ó�� ���
    FCaptureQuality: Integer; //���� ĸ�� ��� ǰ��
    FLastError: Integer; //���� ���� �ڵ�
    FErrorMessage: string; //���� ���� �޽���

    function InitOption: Boolean;
    procedure SetFingerWindow(const AValue: HWND);
    procedure ValueClear;
  public
    constructor Create; overload;
    constructor Create(const AScanQuality, AEnrollQuality, AIdentifyQuality, AVerifyQuality,
      ASecurityLevel, ADefaultTimeout: Integer; const AAutoDetectFinger: Boolean=False); overload;
    destructor Destroy; override;

    function Capture: Boolean; overload; //���� �ν�
    function Capture(const AFingerWindow: HWND; var AErrMsg: string): Boolean; overload; //���� �ν�
    function Matching: Boolean; overload; //���� ��Ī ��ȸ
    function Matching(const AFingerWindow: HWND; ADataSet: TDataSet; const AFingerField, AValueField: string;
      var AErrMsg: string): Boolean; overload; //���� ��Ī ��ȸ

    property Active: Boolean read FActive write FActive default False;
    property Success: Boolean read FSuccess write FSuccess default False;
    property FingerWindow: HWND read FFingerWindow write SetFingerWindow default 0;
    property CaptureQuality: Integer read FScanQuality write FScanQuality default 0;
    property ScanQuality: Integer read FScanQuality write FScanQuality default 0;
    property EnrollQuality: Integer read FEnrollQuality write FEnrollQuality default 90;
    property IdentifyQuality: Integer read FIdentifyQuality write FIdentifyQuality default 90;
    property VerifyQuality: Integer read FVerifyQuality write FVerifyQuality default 50;
    property SecurityLevel: Integer read FSecurityLevel write FSecurityLevel default 9; // (1 < 9)
    property DefaultTimeout: Integer read FDefaultTimeout write FDefaultTimeout default 10000; // 0 for Unlimited
    property AutoDetectFinger: Boolean read FAutoDetectFinger write FAutoDetectFinger default False;
    property TextFIR: string read FTextFIR write FTextFIR;
    property MatchValue: string read FMatchValue write FMatchValue;
    property LastError: Integer read FLastError write FLastError;
    property ErrorMessage: string read FErrorMessage write FErrorMessage;
    property DataSet: TDataSet read FDataSet write FDataSet;
    property FingerFieldName: string read FFingerFieldName write FFingerFieldName;
    property ValueFieldName: string read FValueFieldName write FValueFieldName;
  end;

implementation

uses
  ComObj, Variants, Dialogs, uUCBioAPI_Type;

{ TUCBioBSPHelper }

constructor TUCBioBSPHelper.Create;
begin
  FCaptureQuality := 0;
  FScanQuality := 0;
  FEnrollQuality := 90;
  FIdentifyQuality := 90;
  FVerifyQuality := 50;
  FSecurityLevel := 9;
  FDefaultTimeout := 10000;
  FAutoDetectFinger := False;

  Create(FScanQuality, FEnrollQuality, FIdentifyQuality, FVerifyQuality, FSecurityLevel, FDefaultTimeout);
end;

constructor TUCBioBSPHelper.Create(const AScanQuality, AEnrollQuality, AIdentifyQuality, AVerifyQuality,
  ASecurityLevel, ADefaultTimeout: Integer; const AAutoDetectFinger: Boolean);
begin
  inherited Create;

  FUCBioBSP := CreateOleObject('UCBioBSPCOM.UCBioBSP');
  FDevice := FUCBioBSP.Device;
  FExtraction := FUCBioBSP.Extraction;
  FMatching := FUCBioBSP.Matching;

  ScanQuality := AScanQuality;
  EnrollQuality := AEnrollQuality;
  IdentifyQuality := AIdentifyQuality;
  VerifyQuality := AVerifyQuality;
  SecurityLevel := ASecurityLevel;
  DefaultTimeout := ADefaultTimeout;
  AutoDetectFinger := AAutoDetectFinger;

  try
    FUCBioBSP.SetSkinResource('UCBioBSPSkin_Kor.dll');
    Active := InitOption;
  except
    on E: Exception do
      ErrorMessage := E.Message;
  end;
end;

destructor TUCBioBSPHelper.Destroy;
begin
  FreeAndNil(FExtraction);
  FreeAndNil(FMatching);
  FreeAndNil(FDevice);
  FreeAndNil(FUCBioBSP);

  inherited;
end;

function TUCBioBSPHelper.Capture: Boolean;
var
  sErrMsg: string;
begin
  Result := Capture(FingerWindow, sErrMsg);
end;
function TUCBioBSPHelper.Capture(const AFingerWindow: HWND; var AErrMsg: string): Boolean;
var
  ABuffer: array of Byte;
  nSize: Integer;
begin
  Result := False;
  ValueClear;
  if not Active then
    Exit;

  FingerWindow := AFingerWindow;
  ABuffer := nil;
  try
    FDevice.Open(UCBioAPI_DEVICE_ID_AUTO_DETECT);
    try
      LastError := FDevice.ErrorCode;
      if (LastError <> UCBioAPIERROR_NONE) then
        raise Exception.Create('���� �ν���ġ�� ����� �� �����ϴ�.' + #13#10 + FDevice.ErrorDescription);

      FExtraction.Capture(UCBioAPI_FIR_PURPOSE_VERIFY);
      LastError := FExtraction.ErrorCode;
      if (LastError <> UCBioAPIERROR_NONE) then
        raise Exception.Create('������ �ν����� ���߽��ϴ�.' + #13#10 + FExtraction.ErrorDescription);
    finally
      FDevice.Close(UCBioAPI_DEVICE_ID_AUTO_DETECT);
    end;

    nSize := FExtraction.FIRLength;
    SetLength(ABuffer, nSize);
    ABuffer := FExtraction.FIR;
    SetString(FTextFIR, PAnsiChar(@ABuffer[0]), nSize);
    TextFIR := FExtraction.TextFIR;
    SetLength(ABuffer, 0);
    Success := True;
    Result := True;
  except
    on E: Exception do
    begin
      ErrorMessage := E.Message;
      AErrMsg := ErrorMessage;
    end;
  end;
end;

function TUCBioBSPHelper.Matching: Boolean;
var
  sErrMsg: string;
begin
  Result := Matching(FingerWindow, DataSet, FingerFieldName, ValueFieldName, sErrMsg);
end;
function TUCBioBSPHelper.Matching(const AFingerWindow: HWND; ADataSet: TDataSet; const AFingerField, AValueField: string; var AErrMsg: string): Boolean;
begin
  Result := False;
  ValueClear;
  if not Active then
    Exit;

  FingerWindow := AFingerWindow;
  try
    if not ADataSet.Active then
      raise Exception.Create('���� �����͸� ����� �� �����ϴ�.');
    if (ADataSet.FieldDefs.IndexOf(AFingerField) < 0) then
      raise Exception.Create('���� �����Ϳ��� ����� �� ���� �ʵ���� �����Ǿ����ϴ�.');
    if (ADataSet.RecordCount = 0) then
      raise Exception.Create('�˻� ������ ���� �����Ͱ� �����ϴ�.');

    FDevice.Open(UCBioAPI_DEVICE_ID_AUTO_DETECT);
    try
      LastError := FDevice.ErrorCode;
      if (LastError <> UCBioAPIERROR_NONE) then
        raise Exception.Create('���� �ν���ġ�� ����� �� �����ϴ�.');

      FExtraction.Capture(UCBioAPI_FIR_PURPOSE_VERIFY);
      LastError := FExtraction.ErrorCode;
      if (LastError <> UCBioAPIERROR_NONE) then
        raise Exception.Create('������ �ν����� ���߽��ϴ�.' + #13#10 + FExtraction.ErrorDescription);
    finally
      FDevice.Close(UCBioAPI_DEVICE_ID_AUTO_DETECT);
    end;

    TextFIR := FExtraction.TextFIR;
    with ADataSet do
    try
      DisableControls;
      First;
      while not Eof do
      begin
        if (FieldByName(AFingerField).AsString <> '') then
        begin
          FMatching.VerifyMatch(TextFIR, FieldByName(AFingerField).AsString);
          if (VarToStr(FMatching.MatchingResult) = IntToStr(UCBioAPI_TRUE)) then
          begin
            if (ADataSet.FieldDefs.IndexOf(AValueField) >= 0) then
              MatchValue := FieldByName(AValueField).AsString;
            Success := True;
            Break;
          end;
        end;

        Next;
      end;

      Result := True;
      if not Success then
        ErrorMessage := '��ġ�ϴ� ������ ã�� �� �����ϴ�.';
    finally
      EnableControls;
    end;
  except
    on E: Exception do
    begin
      ErrorMessage := E.Message;
      AErrMsg := ErrorMessage;
    end;
  end;
end;

function TUCBioBSPHelper.InitOption: Boolean;
begin
  Result := False;
  ValueClear;

  try
    FUCBioBSP.SecurityLevelForEnroll := SecurityLevel;
    FUCBioBSP.SecurityLevelForVerify := SecurityLevel;
    FUCBioBSP.SecurityLevelForIdentify := SecurityLevel;
    FUCBioBSP.SetCaptureQuality(ScanQuality, EnrollQuality, VerifyQuality, IdentifyQuality);
    FUCBioBSP.DefaultTimeout := DefaultTimeout;
    if AutoDetectFinger then
      FDevice.SetAutoDetect(UCBioAPI_TRUE)
    else
      FDevice.SetAutoDetect(UCBioAPI_FALSE);

    LastError := FUCBioBSP.ErrorCode;
    if (LastError <> UCBioAPIERROR_NONE) then
      raise Exception.Create('���� �ν���ġ �ʱ�ȭ�� �����Ͽ����ϴ�.' + #13#10 + FUCBioBSP.ErrorDescription);
    Result := True;
  except
    on E: Exception do
    begin
      ErrorMessage := E.Message;
      ShowMessage(Format('Error #%d - %s', [LastError, ErrorMessage]));
    end;
  end;
end;

procedure TUCBioBSPHelper.SetFingerWindow(const AValue: HWND);
begin
  FFingerWindow := AValue;
  if (FFingerWindow = 0) then
  begin
    FUCBioBSP.WindowStyle := UCBioAPI_WINDOW_STYLE_POPUP;
    FUCBioBSP.WindowOption[UCBioAPI_WINDOW_STYLE_NO_FPIMG] := UCBioAPI_FALSE;
    FUCBioBSP.WindowOption[UCBioAPI_WINDOW_STYLE_NO_WELCOME] := UCBioAPI_TRUE;
  end else
  begin
    FUCBioBSP.WindowStyle := UCBioAPI_WINDOW_STYLE_INVISIBLE;
    FUCBioBSP.FingerWnd := FFingerWindow;
  end;
end;

procedure TUCBioBSPHelper.ValueClear;
begin
  Success := False;
  TextFIR := '';
  MatchValue := '';
  ErrorMessage := '';
  LastError := UCBioAPIERROR_NONE;
end;

end.
