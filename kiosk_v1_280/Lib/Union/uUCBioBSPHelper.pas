(*******************************************************************************

  Project     : ���Ͽ�Ŀ�´�Ƽ �����νı� ���� ����
  Author      : �̼���
  Description :
  History     :
    Version   Date         Remark
    --------  ----------   -----------------------------------------------------
    1.0.0.0   2020-07-06   Initial Release.

  Copyright��SolbiPOS Co., Ltd. 2008-2020 All rights reserved.

*******************************************************************************)
unit uUCBioBSPHelper;

interface

uses
  Classes, SysUtils, ExtCtrls, Windows, DB;

type
  TUCBioBSPOnCaptureEvent = procedure(ASender: TObject; AQuality: Integer) of Object;

  TUCBioBSPHelper = class
  private
    FUCBioBSP: Variant;
    FDevice: Variant;
    FExtraction: Variant;
    FMatching: Variant;
    FOnCaptureEvent: TUCBioBSPOnCaptureEvent;

    FActive: Boolean;
    FDataSet: TDataSet; //���� �˻��� �����ͼ�
    FFingerFieldName: string; //���� ���� �ʵ��
    FValueFieldName: string; //���� ��Ī �� ��ȯ�� �ʵ��
    FFingerWindow: HWND; //���� �̹��� ��¿� �ܺ� ��Ʈ�� �ڵ�(0�̸� ��� ����)
    FEnrollQuality: Integer; //���� ���� ǰ�� ����
    FVerifyQuality: Integer; //���� �� ǰ�� ����
    FSecurityLevel: Integer; //���� ���� ����
    FDefaultTimeout: Integer; //���� �ν� Ÿ�Ӿƿ�
    FFIR: string; //���� �ν� ���ڵ� ��
    FTextFIR: string; //���� �ν� ���ڵ� ��
    FMatchValue: string; //���� ��Ī �� ��ȯ�� ������ �ʵ� ��
    FSuccess: Boolean; //���� ó�� ���
    FLastError: Integer; //���� ���� �ڵ�
    FErrorMessage: string; //���� ���� �޽���

    function InitOption: Boolean; //���� �ν� ȯ�� �ʱ�ȭ
  public
    constructor Create;
    destructor Destroy; override;

    function Capture: Boolean; overload; //���� �ν�
    function Capture(const AFingerWindow: HWND; var AErrMsg: string): Boolean; overload; //���� �ν�
    function Matching: Boolean; overload; //���� ��Ī ��ȸ
    function Matching(const AFingerWindow: HWND; ADataSet: TDataSet; const AFingerField, AValueField: string; var AErrMsg: string): Boolean; overload; //���� ��Ī ��ȸ

    function SearchMemberFinger: Boolean;

    property Active: Boolean read FActive default False;
    property DataSet: TDataSet read FDataSet write FDataSet;
    property FingerFieldName: string read FFingerFieldName write FFingerFieldName;
    property ValueFieldName: string read FValueFieldName write FValueFieldName;
    property FingerWindow: HWND read FFingerWindow write FFingerWindow default 0;
    property EnrollQuality: Integer read FEnrollQuality write FEnrollQuality default 90; // (30 < 100)
    property VerifyQuality: Integer read FVerifyQuality write FVerifyQuality default 90; // (0 < 100)
    property SecurityLevel: Integer read FSecurityLevel write FSecurityLevel default 7; // (1 < 9)
    property DefaultTimeout: Integer read FDefaultTimeout write FDefaultTimeout default 10000; // 0 for Unlimited
    property FIR: string read FFIR write FFIR;
    property TextFIR: string read FTextFIR write FTextFIR;
    property MatchValue: string read FMatchValue write FMatchValue;
    property Success: Boolean read FSuccess write FSuccess default False;
    property LastError: Integer read FLastError write FLastError;
    property ErrorMessage: string read FErrorMessage write FErrorMessage;

    property OnCaptureEvent: TUCBioBSPOnCaptureEvent read FOnCaptureEvent write FOnCaptureEvent;
  end;

implementation

uses
  ComObj, Variants, Dialogs, uUCBioAPI_Type,
  uGlobal, uSaleModule, fx.Logging;

{ TSBUCBioBSPHelper }

constructor TUCBioBSPHelper.Create;
begin
  FUCBioBSP := CreateOleObject('UCBioBSPCOM.UCBioBSP');
  FDevice := FUCBioBSP.Device;
  FExtraction := FUCBioBSP.Extraction;
  FMatching := FUCBioBSP.Matching;
  FSuccess := False;

  try
    FUCBioBSP.SetSkinResource('UCBioBSPSkin_Kor.dll');
    FActive := InitOption;
  except
    on E: Exception do
      FErrorMessage := E.Message;
  end;
end;

destructor TUCBioBSPHelper.Destroy;
begin
  FDevice := 0;
  FExtraction := 0;
  FMatching := 0;
  FUCBioBSP := 0;

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
  FFingerWindow := AFingerWindow;
  if not InitOption then
    Exit;

  ABuffer := nil;
  try
    FDevice.Open(UCBioAPI_DEVICE_ID_AUTO_DETECT);
    try
      FLastError := FDevice.ErrorCode;
      if (FLastError <> UCBioAPIERROR_NONE) then
        raise Exception.Create('���� �ν���ġ�� ����� �� �����ϴ�.' + #13#10 + FDevice.ErrorDescription);

      FExtraction.Capture(UCBioAPI_FIR_PURPOSE_VERIFY);
      FLastError := FExtraction.ErrorCode;
      if (FLastError <> UCBioAPIERROR_NONE) then
        raise Exception.Create('������ �ν����� ���߽��ϴ�.' + #13#10 + FExtraction.ErrorDescription);

      nSize := FExtraction.FIRLength;
      SetLength(ABuffer, nSize);
      ABuffer := FExtraction.FIR;
      SetString(FFIR, PAnsiChar(@ABuffer[0]), nSize);
      FTextFIR := FExtraction.TextFIR;
      FSuccess := True;
      Result := True;
    finally
      SetLength(ABuffer, 0);
      FDevice.Close(UCBioAPI_DEVICE_ID_AUTO_DETECT);
    end;
  except
    on E: Exception do
    begin
      FErrorMessage := E.Message;
      AErrMsg := FErrorMessage;
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
  FFingerWindow := AFingerWindow;
  if not InitOption then
    Exit;

  try
    FDevice.Open(UCBioAPI_DEVICE_ID_AUTO_DETECT);
    try
      FLastError := FDevice.ErrorCode;
      if (FLastError <> UCBioAPIERROR_NONE) then
        raise Exception.Create('���� �ν���ġ�� ����� �� �����ϴ�.');

      if not ADataSet.Active then
        raise Exception.Create('���� �����͸� ����� �� �����ϴ�.');
      if (ADataSet.FieldDefs.IndexOf(AFingerField) < 0) then
        raise Exception.Create('���� �����Ϳ��� ����� �� ���� �ʵ���� �����Ǿ����ϴ�.');
      if (ADataSet.RecordCount = 0) then
        raise Exception.Create('�˻� ������ ���� �����Ͱ� �����ϴ�.');

      FExtraction.Capture(UCBioAPI_FIR_PURPOSE_VERIFY);
      FLastError := FExtraction.ErrorCode;
      if (FLastError <> UCBioAPIERROR_NONE) then
        raise Exception.Create('������ �ν����� ���߽��ϴ�.' + #13#10 + FExtraction.ErrorDescription);

      FTextFIR := FExtraction.TextFIR;
      with ADataSet do
      try
        DisableControls;
        First;
        while not Eof do
        begin
          if (FieldByName(AFingerField).AsString <> '') then
          begin
            FMatching.VerifyMatch(FTextFIR, FieldByName(AFingerField).AsString);
            if (VarToStr(FMatching.MatchingResult) = IntToStr(UCBioAPI_TRUE)) then
            begin
              if (ADataSet.FieldDefs.IndexOf(AValueField) >= 0) then
                FMatchValue := FieldByName(AValueField).AsString;
              FSuccess := True;
              Break;
            end;
          end;

          Next;
        end;

        Result := True;
        if not FSuccess then
          FErrorMessage := '��ġ�ϴ� ������ ã�� �� �����ϴ�.';
      finally
        EnableControls;
      end;
    finally
      FDevice.Close(UCBioAPI_DEVICE_ID_AUTO_DETECT);
    end;
  except
    on E: Exception do
    begin
      FErrorMessage := E.Message;
      AErrMsg := FErrorMessage;
    end;
  end;
end;

function TUCBioBSPHelper.InitOption: Boolean;
begin
  Result := False;
  FSuccess := False;
  FLastError := UCBioAPIERROR_NONE;
  FErrorMessage := '';
  FTextFIR := '';
  FMatchValue := '';

  {
  ScanQuality = FEnrollQuality ����, ����ȯ�漳������ ����ó��
  FEnrollQuality := 90; - �������
  FVerifyQuality := 55; - �������
  FIdentifyQuality := 90; - �������
  FSecurityLevel := 9; - �������
  FDefaultTimeout := 10000;

  nScanQuality : �Էµ� ������ ������ �̹����� ���� ǰ���� �ּ� ������
  nEnrollQuality : ����� Ư¡�� ǰ������ ���� ��Ͻ� �����ϴ� �ּ� ������
  nVerifyQuality : ����� Ư¡�� ǰ������ ���� 1:1��Ī�� �����ϴ� �ּ� ������
  nIdentifyQuality : ����� Ư¡�� ǰ������ ���� 1:N ��Ī�� �����ϴ� �ּ� ������
  *���� nScanQuality, nEnrollQuality �� ����� - > ���̵�v3.00 ����
  }

  try
    if (FingerWindow = 0) then
    begin
      FUCBioBSP.WindowStyle := UCBioAPI_WINDOW_STYLE_POPUP;
      //FUCBioBSP.WindowOption[UCBioAPI_WINDOW_STYLE_NO_FPIMG] := UCBioAPI_TRUE;
      FUCBioBSP.WindowOption[UCBioAPI_WINDOW_STYLE_NO_FPIMG] := UCBioAPI_FALSE;
      FUCBioBSP.WindowOption[UCBioAPI_WINDOW_STYLE_NO_WELCOME] := UCBioAPI_TRUE;
    end else
    begin
      FUCBioBSP.WindowStyle := UCBioAPI_WINDOW_STYLE_INVISIBLE;
      FUCBioBSP.FingerWnd := FingerWindow;
    end;

    //�⺻������Enroll/Verify �� 5 �� ���� ������ Identify �� 6 �� ���� ������
    FUCBioBSP.SecurityLevelForEnroll := SecurityLevel;
    FUCBioBSP.SecurityLevelForVerify := SecurityLevel;
    FUCBioBSP.SecurityLevelForIdentify := SecurityLevel;

    //FUCBioBSP.SetCaptureQuality(ScanQuality, EnrollQuality, VerifyQuality, IdentifyQuality);
    FUCBioBSP.SetCaptureQuality(EnrollQuality, EnrollQuality, VerifyQuality, EnrollQuality);
    FUCBioBSP.DefaultTimeout := DefaultTimeout;
    FDevice.SetAutoDetect(UCBioAPI_TRUE);

    FLastError := FUCBioBSP.ErrorCode;
    if (FLastError <> UCBioAPIERROR_NONE) then
      raise Exception.Create('���� �ν���ġ �ʱ�ȭ�� �����Ͽ����ϴ�.' +#13#10 + FUCBioBSP.ErrorDescription);
    Result := True;
  except
    on E: Exception do
    begin
      FErrorMessage := E.Message;
      ShowMessage(Format('Error #%d - %s', [FLastError, FErrorMessage]));
    end;
  end;

end;

//chy
function TUCBioBSPHelper.SearchMemberFinger: Boolean;
var
  Index: Integer;
  sFingerData: string;
begin

  Result := False;
  FFingerWindow := FingerWindow;
  if not InitOption then
    Exit;

  try
    FDevice.Open(UCBioAPI_DEVICE_ID_AUTO_DETECT);
    try
      FLastError := FDevice.ErrorCode;
      if (FLastError <> UCBioAPIERROR_NONE) then
        raise Exception.Create('���� �ν���ġ�� ����� �� �����ϴ�.');

      FExtraction.Capture(UCBioAPI_FIR_PURPOSE_VERIFY);
      FLastError := -1;
      FLastError := FExtraction.ErrorCode;
      if (FLastError <> UCBioAPIERROR_NONE) then
        raise Exception.Create('������ �ν����� ���߽��ϴ�.' + #13#10 + FExtraction.ErrorDescription);

      //Log.D('SearchMemberFinger', 'ErrorCode - ' + inttostr(FLastError));

      FTextFIR := FExtraction.TextFIR;
      //Log.D('SearchMemberFinger FTextFIR', FTextFIR);

      for Index := 0 to Global.SaleModule.MemberUpdateList.Count - 1 do
      begin
        if not Global.SaleModule.MemberUpdateList[Index].Use then
          Continue;

        if Global.SaleModule.MemberUpdateList[Index].FingerStr = EmptyStr then
          Continue;

        FMatching.VerifyMatch(FTextFIR, Global.SaleModule.MemberUpdateList[Index].FingerStr);

        if (VarToStr(FMatching.MatchingResult) = IntToStr(UCBioAPI_TRUE)) then
        begin
          Result := True;
          Log.D('MemberUpdateList ȸ����', Global.SaleModule.MemberUpdateList[Index].Name);
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

          FMatching.VerifyMatch(FTextFIR, Global.SaleModule.MemberList[Index].FingerStr);

          if (VarToStr(FMatching.MatchingResult) = IntToStr(UCBioAPI_TRUE)) then
          begin
            Log.D('MemberList ȸ����', Global.SaleModule.MemberList[Index].Name);
            Result := True;
            Global.SaleModule.Member := Global.SaleModule.MemberList[Index];
            Break;
          end;
        end;
      end;
    except
      on E: Exception do
      begin
        FErrorMessage := E.Message;
        Log.D('SearchMemberFinger Exception', FErrorMessage);
      end
    end;
  finally
    FDevice.Close(UCBioAPI_DEVICE_ID_AUTO_DETECT);
  end;


end;

end.
