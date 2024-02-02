(*******************************************************************************

  Project     : ��Ʈ�� �ܽ��� �����νı� ���� ����
  Author      : �̼���
  Description :
  History     :
    Version   Date         Remark
    --------  ----------   -----------------------------------------------------
    1.3.0.0   2020-11-26   Added ValueClear.
    1.2.0.0   2020-09-21   Added MatchingValue.
    1.1.0.0   2020-03-15   Improved.
    1.0.0.0   2020-03-13   Initial Release.

  Copyright��SolbiPOS Co., Ltd. 2008-2020 All rights reserved.

*******************************************************************************)
unit uNBioBSPHelper;

interface

uses
  Classes, SysUtils, ExtCtrls, Windows, DB;

type
  TNBioBSPHelper = class
  private
    FNBioBSP: Variant;
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
    FFIR: string; //���� �ν� ���ڵ� ��
    FTextFIR: string; //���� �ν� ���ڵ� ��
    FMatchValue: string; //���� ��Ī �� ��ȯ�� ������ �ʵ� ��
    FSuccess: Boolean; //���� ó�� ���
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

    function SearchMemberFinger: Boolean;

    property Active: Boolean read FActive write FActive default False;
    property Success: Boolean read FSuccess write FSuccess default False;
    property FingerWindow: HWND read FFingerWindow write SetFingerWindow default 0;
    property ScanQuality: Integer read FScanQuality write FScanQuality default 0; // (30 < 100)
    property EnrollQuality: Integer read FEnrollQuality write FEnrollQuality default 90; // (30 < 100)
    property IdentifyQuality: Integer read FIdentifyQuality write FIdentifyQuality default 90; // (0 < 100)
    property VerifyQuality: Integer read FVerifyQuality write FVerifyQuality default 50; // (0 < 100)
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

var
  NBioBSPHelper: TNBioBSPHelper;

implementation

uses
  ComObj, Variants, Dialogs, uNBioAPI_Type,
  uGlobal, uSaleModule, fx.Logging;

{ TNBioBSPHelper }

constructor TNBioBSPHelper.Create;
begin
  FScanQuality := 0;
  FEnrollQuality := 90;
  FIdentifyQuality := 90;
  FVerifyQuality := 50;
  FSecurityLevel := 9;
  FDefaultTimeout := 10000;

  Create(FScanQuality, FEnrollQuality, FIdentifyQuality, FVerifyQuality, FSecurityLevel, FDefaultTimeout);
end;

constructor TNBioBSPHelper.Create(const AScanQuality, AEnrollQuality, AIdentifyQuality, AVerifyQuality,
  ASecurityLevel, ADefaultTimeout: Integer; const AAutoDetectFinger: Boolean);
begin
  FNBioBSP := CreateOleObject('NBioBSPCOM.NBioBSP');
  FDevice := FNBioBSP.Device;
  FExtraction := FNBioBSP.Extraction;
  FMatching := FNBioBSP.Matching;

  ScanQuality := AScanQuality;
  EnrollQuality := AEnrollQuality;
  IdentifyQuality := AIdentifyQuality;
  VerifyQuality := AVerifyQuality;
  SecurityLevel := ASecurityLevel;
  DefaultTimeout := ADefaultTimeout;
  AutoDetectFinger := AAutoDetectFinger;

  try
    FNBioBSP.SetSkinResource('NBSP2Kor.dll');
    Active := InitOption;
  except
    on E: Exception do
      ErrorMessage := E.Message;
  end;
end;

destructor TNBioBSPHelper.Destroy;
begin
  FreeAndNil(FExtraction);
  FreeAndNil(FMatching);
  FreeAndNil(FDevice);
  FreeAndNil(FNBioBSP);

  inherited;
end;

function TNBioBSPHelper.Capture: Boolean;
var
  sErrMsg: string;
begin
  Result := Capture(FingerWindow, sErrMsg);
end;
function TNBioBSPHelper.Capture(const AFingerWindow: HWND; var AErrMsg: string): Boolean;
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
    FDevice.Open(NBioAPI_DEVICE_ID_AUTO_DETECT);
    try
      LastError := FDevice.ErrorCode;
      if (LastError <> NBioAPIERROR_NONE) then
        raise Exception.Create('���� �ν���ġ�� ����� �� �����ϴ�.');

      FExtraction.Capture(NBioAPI_FIR_PURPOSE_VERIFY);
      LastError := FExtraction.ErrorCode;
      if (LastError <> NBioAPIERROR_NONE) then
        raise Exception.Create('������ �ν����� ���߽��ϴ�.');

      nSize := FExtraction.FIRLength;
      SetLength(ABuffer, nSize);
      ABuffer := FExtraction.FIR;
      SetString(FFIR, PAnsiChar(@ABuffer[0]), nSize);

      TextFIR := FExtraction.TextEncodeFIR;
      Success := True;
      Result := True;
    finally
      SetLength(ABuffer, 0);
      FDevice.Close(NBioAPI_DEVICE_ID_AUTO_DETECT);
    end;
  except
    on E: Exception do
    begin
      ErrorMessage := E.Message;
      AErrMsg := ErrorMessage;
    end;
  end;
end;

function TNBioBSPHelper.Matching: Boolean;
var
  sErrMsg: string;
begin
  Result := Matching(FingerWindow, DataSet, FingerFieldName, ValueFieldName, sErrMsg);
end;
function TNBioBSPHelper.Matching(const AFingerWindow: HWND; ADataSet: TDataSet; const AFingerField, AValueField: string; var AErrMsg: string): Boolean;
begin
  Result := False;
  ValueClear;
  if not Active then
    Exit;

  FingerWindow := AFingerWindow;
  try
    FDevice.Open(NBioAPI_DEVICE_ID_AUTO_DETECT);
    try
      LastError := FDevice.ErrorCode;
      if (LastError <> NBioAPIERROR_NONE) then
        raise Exception.Create('���� �ν���ġ�� ����� �� �����ϴ�.');

      if not ADataSet.Active then
        raise Exception.Create('���� �����͸� ����� �� �����ϴ�.');
      if (ADataSet.FieldDefs.IndexOf(AFingerField) < 0) then
        raise Exception.Create('���� �����Ϳ��� ����� �� ���� �ʵ���� �����Ǿ����ϴ�.');
      if (ADataSet.RecordCount = 0) then
        raise Exception.Create('�˻� ������ ���� �����Ͱ� �����ϴ�.');

      FExtraction.Capture(NBioAPI_FIR_PURPOSE_VERIFY);
      LastError := FExtraction.ErrorCode;
      if (LastError <> NBioAPIERROR_NONE) then
        raise Exception.Create('������ �ν����� ���߽��ϴ�.' + #13#10 + FExtraction.ErrorDescription);

      TextFIR := FExtraction.TextEncodeFIR;
      with ADataSet do
      try
        DisableControls;
        First;
        while not Eof do
        begin
          if (FieldByName(AFingerField).AsString <> '') then
          begin
            FMatching.VerifyMatch(TextFIR, FieldByName(AFingerField).AsString);
            if (VarToStr(FMatching.MatchingResult) = IntToStr(NBioAPI_TRUE)) then
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
    finally
      FDevice.Close(NBioAPI_DEVICE_ID_AUTO_DETECT);
    end;
  except
    on E: Exception do
    begin
      ErrorMessage := E.Message;
      AErrMsg := ErrorMessage;
    end;
  end;
end;

function TNBioBSPHelper.InitOption: Boolean;
begin
  Result := False;
  ValueClear;

  try
    FExtraction.EnrollImageQuality := EnrollQuality;
    FExtraction.IdentifyImageQuality := IdentifyQuality;
    FExtraction.VerifyImageQuality := VerifyQuality;
    FExtraction.SecurityLevel := SecurityLevel;
    FExtraction.DefaultTimeout := DefaultTimeout;

    LastError := FExtraction.ErrorCode;
    if (LastError <> NBioAPIERROR_NONE) then
      raise Exception.Create(FExtraction.ErrorDescription);
    Result := True;
  except
    on E: Exception do
    begin
      ErrorMessage := E.Message;
      ShowMessage(Format('Error #%d - %s', [LastError, ErrorMessage]));
    end;
  end;
end;

procedure TNBioBSPHelper.SetFingerWindow(const AValue: HWND);
begin
  FFingerWindow := AValue;
  if (FFingerWindow = 0) then
  begin
    FExtraction.WindowStyle := NBioAPI_WINDOW_STYLE_POPUP;
    FExtraction.WindowOption[NBioAPI_WINDOW_STYLE_NO_FPIMG] := False;
    FExtraction.WindowOption[NBioAPI_WINDOW_STYLE_NO_WELCOME] := True;
  end else
  begin
    FExtraction.WindowStyle := NBioAPI_WINDOW_STYLE_INVISIBLE;
    FExtraction.FingerWnd := FFingerWindow;
  end;
end;

procedure TNBioBSPHelper.ValueClear;
begin
  Success := False;
  TextFIR := '';
  MatchValue := '';
  ErrorMessage := '';
  LastError := NBioAPIERROR_NONE;
end;

function TNBioBSPHelper.SearchMemberFinger: Boolean;
var
  Index: Integer;
  sFingerData: string;
begin

  Result := False;
  ValueClear;
  if not Active then
    Exit;

  FingerWindow := FingerWindow;
  try
    FDevice.Open(NBioAPI_DEVICE_ID_AUTO_DETECT);
    try
      LastError := FDevice.ErrorCode;
      if (LastError <> NBioAPIERROR_NONE) then
        raise Exception.Create('���� �ν���ġ�� ����� �� �����ϴ�.');

      FExtraction.Capture(NBioAPI_FIR_PURPOSE_VERIFY);
      LastError := FExtraction.ErrorCode;
      if (LastError <> NBioAPIERROR_NONE) then
        raise Exception.Create('������ �ν����� ���߽��ϴ�.' + #13#10 + FExtraction.ErrorDescription);

      TextFIR := FExtraction.TextEncodeFIR;

      for Index := 0 to Global.SaleModule.MemberUpdateList.Count - 1 do
      begin
        if not Global.SaleModule.MemberUpdateList[Index].Use then
          Continue;

        if Global.SaleModule.MemberUpdateList[Index].FingerStr = EmptyStr then
          Continue;

        FMatching.VerifyMatch(TextFIR, Global.SaleModule.MemberUpdateList[Index].FingerStr);

        if (VarToStr(FMatching.MatchingResult) = IntToStr(NBioAPI_TRUE)) then
        begin
          Result := True;
          Log.D('MemberUpdateList ȸ����', Global.SaleModule.MemberUpdateList[Index].Name);
          //Log.D('MemberUpdateList ȸ������', Global.SaleModule.MemberUpdateList[Index].FingerStr);
          Global.SaleModule.Member := Global.SaleModule.MemberUpdateList[Index];
          Break;
        end;
      end;

      if not Result then
      begin
        for Index := 0 to Global.SaleModule.MemberList.Count - 1 do
        begin
          if not Global.SaleModule.MemberList[Index].Use then
            Continue;

          if Global.SaleModule.MemberList[Index].FingerStr = EmptyStr then
            Continue;

          FMatching.VerifyMatch(TextFIR, Global.SaleModule.MemberList[Index].FingerStr);

          if (VarToStr(FMatching.MatchingResult) = IntToStr(NBioAPI_TRUE)) then
          begin
            Log.D('MemberList ȸ����', Global.SaleModule.MemberList[Index].Name);
            //Log.D('MemberList ȸ������', Global.SaleModule.MemberList[Index].FingerStr);
            Result := True;
            Global.SaleModule.Member := Global.SaleModule.MemberList[Index];
            Break;
          end;
        end;
      end;

    finally
      FDevice.Close(NBioAPI_DEVICE_ID_AUTO_DETECT);
    end;
  except
    on E: Exception do
    begin
      ErrorMessage := E.Message;
      //AErrMsg := ErrorMessage;
    end;
  end;

end;

end.