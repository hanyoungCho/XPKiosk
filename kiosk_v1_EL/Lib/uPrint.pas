unit uPrint;

interface

uses
  System.SysUtils, Math, StrUtils, System.DateUtils,
  System.IOUtils, Winapi.Windows,
  fx.Json, Vcl.Forms, Vcl.StdCtrls, System.Classes,
  CPort, Generics.Collections;

const
  // ������ Ư�����
  rptReceiptCharNormal    = '{N}';   // �Ϲ� ����
  rptReceiptCharBold      = '{B}';   // ���� ����
  rptReceiptCharInverse   = '{I}';   // ���� ����
  rptReceiptCharUnderline = '{U}';   // ���� ����
  rptReceiptAlignLeft     = '{L}';   // ���� ����
  rptReceiptAlignCenter   = '{C}';   // ��� ����
  rptReceiptAlignRight    = '{R}';   // ������ ����
  rptReceiptSizeNormal    = '{S}';   // ���� ũ��
  rptReceiptSizeWidth     = '{X}';   // ����Ȯ�� ũ��
  rptReceiptSizeHeight    = '{Y}';   // ����Ȯ�� ũ��
  rptReceiptSizeBoth      = '{Z}';   // ���μ���Ȯ�� ũ��
  rptReceiptSize3Times    = '{3}';   // ���μ���3��Ȯ�� ũ��
  rptReceiptSize4Times    = '{4}';   // ���μ���4��Ȯ�� ũ��
  rptReceiptInit          = '{!}';   // ������ �ʱ�ȭ
  rptReceiptCut           = '{/}';   // ����Ŀ��
  rptReceiptImage1        = '{*}';   // �׸� �μ� 1
  rptReceiptImage2        = '{@}';   // �׸� �μ� 2
  rptReceiptCashDrawerOpen= '{O}';   // ������ ����
  rptReceiptSpacingNormal = '{=}';   // �ٰ��� ����
  rptReceiptSpacingNarrow = '{&}';   // �ٰ��� ����
  rptReceiptSpacingWide   = '{\}';   // �ٰ��� ����
  rptLF                   = '{-}';   // �ٹٲ�
  rptLF2                  = #13#10;  // �ٹٲ�
  rptBarCodeBegin128      = '{<}';   // ���ڵ� ��� ���� CODE128
  rptBarCodeBegin39       = '{[}';   // ���ڵ� ��� ���� CODE39
  rptBarCodeEnd           = '{>}';   // ���ڵ� ��� ��
  // ������ ��¸�� (������ ���� ��¿��� �����)
  rptReceiptCharSaleDate  = '{D}';   // �Ǹ�����
  rptReceiptCharPosNo     = '{P}';   // ������ȣ
  rptReceiptCharPosName   = '{Q}';   // ������
  rptReceiptCharBillNo    = '{A}';   // ����ȣ
  rptReceiptCharDateTime  = '{E}';   // ����Ͻ�

  RECEIPT_TITLE1          = '�޴���                      �ܰ� ����       �ݾ�';
  RECEIPT_TITLE2          = '�޴���                �ܰ� ����       �ݾ�';
  RECEIPT_LINE1           = '------------------------------------------------';
  RECEIPT_LINE2           = '------------------------------------------';
  RECEIPT_LINE3           = '================================================';
  RECEIPT_LINE4           = '==========================================';

type
  TDeviceType = (dtNone, dtKiosk42);

  TPrintThread = class(TThread)
  private
  protected
    procedure Execute; override;
  public
    PrintList: TList<string>;
    constructor Create;
    destructor Destroy; override;
  end;

  TStoreInfo = class(TJson)
    StoreName: string;               // �����
    BizNo: string;                   // ����ڹ�ȣ
    BossName: string;                // ���ָ�
    Tel: string;                     // ��ȭ��ȣ
    Addr: string;                    // �ּ�
  end;

  TOrderInfo = class(TJson)
    UseProductName: string;          // Ÿ������ǥ�� ǥ�õ� ��ǰ��
    TeeBox_Floor: string;            // Ÿ�� ���� ��
    TeeBox_Nm: string;               // Ÿ�� ���� ��ȣ
    UseTime: string;                 // �̿�ð�
    One_Use_Time: string;            // �̿�ð�(Ÿ����ǰ)
    Coupon: Boolean;                 // ��������
    CouponQty: Integer;              // �ܿ������� - �������� �⺻ 0
    CouponUseDate: string;           // ���� �����
    ExpireDate: string;              // ��������
    Reserve_No: string;              // ���� ��ȣ
    Parking_Barcode: string;         // Ÿ�� ����ǥ ���ڵ�(��������)
    ProductDiv: string;              // Ÿ���� ����
  end;

  TReceiptMemberInfo = class(TJson)
    Name: string;                    // ȸ����
    Code: string;                    // ȸ���ڵ�
    Tel: string;                     // ��ȭ��ȣ
  end;

  TProductInfo = class(TJson)
    Name: string;                    // ��ǰ��
    Code: string;                    // ��ǰ�ڵ�
    Price: Integer;                  // �Ǹűݾ�(1EA �ܰ�)
    Vat: Integer;                    // �ΰ����ݾ�(1EA �ΰ���)
    Qty: Integer;                    // �� ����
  end;

  TReceiptEtc = class(TJson)
    RcpNo: Integer;
    SaleDate: string;                // �Ǹ����� (����)
    ReturnDate: string;              // ��ǰ���� (��ǰ�� ���Ǹ�����)
    RePrint: Boolean;                // ����� ����
    TotalAmt: Integer;               // ��ǰ�ǸŽ� �� �Ǹűݾ�
    DCAmt: Integer;                  // ���αݾ�
    Receipt_No: string;              // ��������ȣ(���ڵ�)
    Top1: string;                    // ��ܹ���1
    Top2: string;                    // ��ܹ���2
    Top3: string;                    // ��ܹ���3
    Top4: string;                    // ��ܹ���4
    Bottom1: string;                 // �ϴܹ���1
    Bottom2: string;                 // �ϴܹ���2
    Bottom3: string;                 // �ϴܹ���3
    Bottom4: string;                 // �ϴܹ���4
    SaleUpload: string;
  end;

  TReceipt = class(TJson)
  private
  public
    StoreInfo: TStoreInfo;
    OrderList: TArray<TOrderInfo>;
    ReceiptMemberInfo: TReceiptMemberInfo;
    ProductInfo: TArray<TProductInfo>;
    ReceiptEtc: TReceiptEtc;
    constructor Create;
    destructor Destroy; override;

    procedure Load(AJsonText: string);
  end;

  TReceiptPrint = class
  private
    FPrintThread: TPrintThread;
    FComPort: TComPort;
    FDeviceType: TDeviceType;
    Receipt: TReceipt;
    FIsReturn: Integer;
    FInt_37: Integer;
    FInt_11: Integer;
    FInt_48: Integer;
    FInt_33: Integer;
    FInt_15: Integer;

    FPrintStatus: String;
    FComPortNo: Integer;

    function LPadB(const AStr: string; ALength: Integer; APadChar: Char): string;
    function RPadB(const AStr: string; ALength: Integer; APadChar: Char): string;
    function SCopy(S: AnsiString; F, L: Integer): string;
    function PadChar(ALength: Integer; APadChar: Char = ' '): string;
    function ByteLen(const AText: string): Integer;
    function GetCurrStr(AData: Currency): string;
    function DateTimeStrToString(const ADateTime: string): string;
    function CheckEnumComPorts(APort: Integer): Boolean;
  public
    constructor Create(ADeviceType: TDeviceType; APort: Integer; ABaudRate: TBaudRate);
    destructor Destroy; override;

    function ReceiptPrint(AJsonText: string): Boolean;

    function SetTeeBoxPrint: Boolean;

    function Print(APrintData: string): Boolean;

    function ConvertPrintData(AData: string): string;
    function ConvertBarCodeCMD(AData: string): string;

    //sewoo -> ��������½� ���䰪 ����
    procedure ComPortRxChar(Sender: TObject; Count: Integer);
    procedure SewooStatus;

    property ComPort: TComPort read FComPort write FComPort;
    property IsReturn: Integer read FIsReturn write FIsReturn;
    property Int_37: Integer read FInt_37 write FInt_37;
    property Int_11: Integer read FInt_11 write FInt_11;
    property Int_48: Integer read FInt_48 write FInt_48;
    property Int_33: Integer read FInt_33 write FInt_33;
    property Int_15: Integer read FInt_15 write FInt_15;

    property PrintStatus: String read FPrintStatus write FPrintStatus;

    property PrintThread: TPrintThread read FPrintThread write FPrintThread;
  end;

implementation

uses
  uGlobal, fx.Logging, uConsts;

function StringToHex(const S: string): string;
var
  Index: Integer;
begin
  Result := '';
  for Index := 1 to Length(S) do
    Result := Result + IntToHex( Byte( S[Index] ), 2 );
end;

function HexToBin(const Hexadecimal: string): string;
const
  BCD: array[0..15] of string =
  ('0000', '0001', '0010', '0011', '0100', '0101', '0110', '0111',
    '1000', '1001', '1010', '1011', '1100', '1101', '1110', '1111');
var
  I: integer;
begin
  for I := Length(Hexadecimal) downto 1 do
    Result := BCD[StrToInt('$' + Hexadecimal[I])] + Result;
end;

{ TReceiptPrint }

function TReceiptPrint.ConvertBarCodeCMD(AData: string): string;
const
  BAR_HEIGHT = #$50; // ���ڵ����
  BAR_CODE39 = #69;
  BAR_ITF = #70;
  BAR_CODABAR = #71;
  BAR_CODE93 = #72;
  BAR_CODE128 = #$49; //#73;
var
  BeginPos128, BeginPos39, BeginPos, EndPos: Integer;
  ChkBarCode39: Boolean;
  ALen: Char;
  BarCodeOrg, BarCodeToStr: string;
begin
  while Pos(rptBarCodeEnd, AData) > 0 do
  begin
    BeginPos128 := Pos(rptBarCodeBegin128, AData);
    BeginPos39 := Pos(rptBarCodeBegin39, AData);
    BeginPos := Min(BeginPos128, BeginPos39);
    if BeginPos128 = 0 then
      BeginPos := BeginPos39;
    if BeginPos39 = 0 then
      BeginPos := BeginPos128;
    ChkBarCode39 := BeginPos = BeginPos39;
    EndPos := Pos(rptBarCodeEnd, AData);

    if BeginPos <= 0 then
      Break;
    if EndPos <= 0 then
      Break;
    if BeginPos >= EndPos then
      Break;

    BarCodeOrg := Copy(AData, BeginPos + 3, EndPos - BeginPos - 3);

    // CODE39 �̸�
    if ChkBarCode39 then
    begin
      ALen := Char(Length(BarCodeOrg));
      BarCodeToStr := #$1D#$68 + BAR_HEIGHT + #$1D#$77#$02#$1B#$61#$01#$1D#$48#$02#$1D#$6B + BAR_CODE39 + ALen + BarCodeOrg;
    end
    else
    // CODE128 �̸�
    begin
      ALen := Char(Length(BarCodeOrg) + 2); // 2 �� ���ؾ� ��
      BarCodeToStr := #$1D#$68 + BAR_HEIGHT + #$1D#$77#$02#$1B#$61#$01#$1D#$48#$02#$1D#$6B + BAR_CODE128 + ALen + #$7B#$42 + BarCodeOrg;
                    //#$1D#$68 +  #$30      + #$1D#$77#$01#$1B#$61#$01 + #$1D#$48#$02 + #$1D#$6B + BAR_CODE128 + #$10 + #$7B#$42 + BarCodeOrg;
    end;
    if ChkBarCode39 then
      AData := ReplaceStr(AData, rptBarCodeBegin39 + BarCodeOrg + rptBarCodeEnd, BarCodeToStr)
    else
      AData := ReplaceStr(AData, rptBarCodeBegin128 + BarCodeOrg + rptBarCodeEnd, BarCodeToStr);
  end;
  Result := AData;
end;

function TReceiptPrint.ConvertPrintData(AData: string): string;
begin
  Result := AData;
  Result := ReplaceStr(Result, rptReceiptCharBold,      #27#71#1);
  Result := ReplaceStr(Result, rptReceiptCharInverse,   #29#66#1);
  Result := ReplaceStr(Result, rptReceiptCharUnderline, #27#45#1);
  Result := ReplaceStr(Result, rptReceiptAlignLeft,     #27#97#0);
  Result := ReplaceStr(Result, rptReceiptAlignCenter,   #27#97#1);
  Result := ReplaceStr(Result, rptReceiptAlignRight,    #27#97#2);
  Result := ReplaceStr(Result, rptReceiptCut,           #27#109);   // ���� 109
  Result := ReplaceStr(Result, rptReceiptInit,          #27#64);
  Result := ReplaceStr(Result, rptReceiptImage1,        #13#28#112#1#0);
  Result := ReplaceStr(Result, rptReceiptImage2,        #13#28#112#2#0);
  Result := ReplaceStr(Result, rptReceiptCashDrawerOpen,#27'p'#0#25#250#13#10);
  Result := ReplaceStr(Result, rptReceiptSpacingNormal, #27#51#60);
  Result := ReplaceStr(Result, rptReceiptSpacingNarrow, #27#51#50);
  Result := ReplaceStr(Result, rptReceiptSpacingWide,   #27#51#120);
  Result := ReplaceStr(Result, rptLF,                   #13#10);

  Result := ReplaceStr(Result, rptReceiptSize3Times,    #29#33#34);
  Result := ReplaceStr(Result, rptReceiptSize4Times,    #29#33#51);
  Result := ReplaceStr(Result, rptReceiptSizeNormal,    #27#33#0);
  Result := ReplaceStr(Result, rptReceiptSizeWidth,     #27#33#32);
  Result := ReplaceStr(Result, rptReceiptSizeHeight,    #27#33#16);
  Result := ReplaceStr(Result, rptReceiptSizeBoth,      #27#33#48);

  Result := ReplaceStr(Result, rptReceiptCharNormal,    EmptyStr);
  Result := ConvertBarCodeCMD(Result);
end;

constructor TReceiptPrint.Create(ADeviceType: TDeviceType; APort: Integer; ABaudRate: TBaudRate);
begin
  FDeviceType := ADeviceType;

  ComPort := TComPort.Create(nil);
  ComPort.Port := 'COM' + IntToStr(APort);
  ComPort.BaudRate := ABaudRate;

  ComPort.OnRxChar := ComPortRxChar;
  FComPortNo := APort;

  if CheckEnumComPorts(APort) then
    ComPort.Open
  else // Port�� ����
    Exit;

  //Ʈ�ν� 48��,  ��������ũ(sewoo ������) 42��
  Int_37 := 33;
  Int_11 := 9;
  Int_48 := 42;
  Int_33 := 29;
  Int_15 := 13;

  PrintThread := TPrintThread.Create;
end;

function TReceiptPrint.CheckEnumComPorts(APort: Integer): Boolean;
var
  KeyHandle: HKEY;
  ErrCode, Index: Integer;
  ValueName, Data: string;
  ValueLen, DataLen, ValueType: DWORD;
  TmpPorts: TStringList;
begin
  Result := False;
  ErrCode := RegOpenKeyEx(HKEY_LOCAL_MACHINE, 'HARDWARE\DEVICEMAP\SERIALCOMM', 0, KEY_READ, KeyHandle);

  if ErrCode <> ERROR_SUCCESS then
  begin
    //raise EComPort.Create(CError_RegError, ErrCode);
    Exit;
  end;

  TmpPorts := TStringList.Create;
  try
    Index := 0;
    repeat
      ValueLen := 256;
      DataLen := 256;
      SetLength(ValueName, ValueLen);
      SetLength(Data, DataLen);
      ErrCode := RegEnumValue(
        KeyHandle,
        Index,
        PChar(ValueName),
        {$IFDEF DELPHI_4_OR_HIGHER}
        Cardinal(ValueLen),
        {$ELSE}
        ValueLen,
          {$ENDIF}
        nil,
        @ValueType,
        PByte(PChar(Data)),
        @DataLen);

      if ErrCode = ERROR_SUCCESS then
      begin
        SetLength(Data, DataLen - 1);
        TmpPorts.Add(Data);
        Inc(Index);
      end
      else
        if ErrCode <> ERROR_NO_MORE_ITEMS then break;
          //raise EComPort.Create(CError_RegError, ErrCode);

    until (ErrCode <> ERROR_SUCCESS) ;

    TmpPorts.Sort;

    for Index := 0 to TmpPorts.Count - 1 do
    begin
      if StrToInt(StringReplace(UpperCase(TmpPorts[Index]), 'COM', '', [rfReplaceAll])) = APort then
        Result := True;
    end;

  finally
    RegCloseKey(KeyHandle);
    TmpPorts.Free;
  end;
end;

destructor TReceiptPrint.Destroy;
begin
  ComPort.Free;
  if PrintThread <> Nil then
    PrintThread.Terminate;
  inherited;
end;

function TReceiptPrint.ReceiptPrint(AJsonText: string): Boolean;
begin
  Log.D('TReceiptPrint.ReceiptPrint', 'Begin');
  try
    try
      Receipt := TReceipt.Create;
      Receipt.Load(AJsonText);

      if Receipt.OrderList[0].Reserve_No <> EmptyStr then
        SetTeeBoxPrint;

    except
      on E: Exception do
      begin
        Log.E('TReceiptPrint.ReceiptPrint', E.Message);
      end;
    end;
  finally
    Receipt.Free;
    Log.D('TReceiptPrint.ReceiptPrint', 'End');
  end;
end;

function TReceiptPrint.SetTeeBoxPrint: Boolean;
var
  Index: Integer;
  PrintData, sUseTime: string;
  sParkDate: String;
begin
  PrintData := EmptyStr;

  with Receipt do
  begin
    for Index := 0 to Length(OrderList) - 1 do
    begin
      PrintData := rptReceiptInit;
      PrintData := PrintData + rptReceiptAlignCenter;
      PrintData := PrintData + RECEIPT_LINE2 + rptLF;
      //rptReceiptSizeBoth;

      PrintData := PrintData + rptReceiptSizeWidth + 'Ÿ �� �� �� ǥ' + rptLF;

      PrintData := PrintData + rptReceiptAlignCenter{rptReceiptAlignLeft} + rptReceiptSizeNormal;
      PrintData := PrintData + RECEIPT_LINE2 + rptLF;
      PrintData := PrintData + rptReceiptSizeBoth;//rptReceiptSizeWidth + rptReceiptSizeHeight;//rptReceiptSizeBoth;

      sUseTime := OrderList[Index].UseTime + '-' + FormatDateTime( 'hh:nn', IncMinute(StrToDateTime(OrderList[Index].UseTime), StrToInt(OrderList[Index].One_Use_Time)) );

      PrintData := PrintData + rptReceiptAlignLeft + rptReceiptCharBold +  rptReceiptSizeHeight;
      PrintData := PrintData + 'Ÿ �� �� ȣ : ';
      PrintData := PrintData + rptReceiptSizeNormal + rptReceiptSizeBoth;
      PrintData := PrintData + Format('%s %s��', [OrderList[Index].TeeBox_Floor, OrderList[Index].TeeBox_Nm]) + rptLF + rptLF;

      PrintData := PrintData + rptReceiptCharBold +  rptReceiptSizeHeight;
      PrintData := PrintData + '�� �� �� �� : ';
      PrintData := PrintData + rptReceiptSizeNormal + rptReceiptSizeBoth;
      PrintData := PrintData + Format('%s', [sUseTime, OrderList[Index].One_Use_Time]) + rptLF;

      PrintData := PrintData + rptReceiptCharBold +  rptReceiptSizeHeight;
      PrintData := PrintData + '�� �� �� �� : ';
      PrintData := PrintData + rptReceiptSizeNormal + rptReceiptSizeBoth;
      PrintData := PrintData + Format('%s��', [OrderList[Index].One_Use_Time]) + rptLF + rptLF;

      PrintData := PrintData + rptReceiptSizeNormal;
      PrintData := PrintData + RPadB('�� �� �� �� : ' + Receipt.ReceiptEtc.SaleDate, Int_48, ' ') + rptLF;
      if ReceiptMemberInfo.Name <> EmptyStr then
        PrintData := PrintData + RPadB('ȸ �� �� �� : ' + Format('%s(%s)', [ReceiptMemberInfo.Name, ReceiptMemberInfo.Code]), Int_48, ' ') + rptLF;
      PrintData := PrintData + RPadB('�� �� �� �� : ' + OrderList[Index].UseProductName, Int_48, ' ') + rptLF;

      if OrderList[Index].ExpireDate <> EmptyStr then
        PrintData := PrintData + RPadB('�� �� �� �� : ' + OrderList[Index].ExpireDate, Int_48, ' ') + rptLF;

      if OrderList[Index].Reserve_No = EmptyStr then
        PrintData := PrintData + RPadB('�� �� �� ȣ : ' + '�����ڿ��� ���� �ٶ��ϴ�.', Int_48, ' ') + rptLF
      else
        PrintData := PrintData + RPadB('�� �� �� ȣ : ' + OrderList[Index].Reserve_No, Int_48, ' ') + rptLF;

      if OrderList[Index].Coupon then
      begin
        PrintData := PrintData + RPadB('�ܿ� ������ : ' + Format('%d��', [OrderList[Index].CouponQty]), Int_48, ' ') + rptLF;
        PrintData := PrintData + RPadB(OrderList[Index].CouponUseDate, Int_48, ' ') + rptLF
      end;

      PrintData := PrintData + RECEIPT_LINE2 + rptLF;
      PrintData := PrintData + RPadB('��½ð� : ' + FormatDateTime('yyyy-mm-dd hh:nn', now), Int_48, ' ') + rptLF2;
      PrintData := PrintData + RECEIPT_LINE2 + rptLF;

      PrintData := PrintData + rptReceiptAlignCenter;
      PrintData := PrintData + '��� ���Ǵ� ����Ʈ�� �湮�� �ּ���.' + rptLF;
      PrintData := PrintData + '�̿��� �ּż� �����մϴ�.' + rptLF;
      PrintData := PrintData + '���� �Ϸ� �Ǽ���.' + rptLF;

      if ReceiptEtc.Bottom1 <> EmptyStr then
        PrintData := PrintData + RPadB(ReceiptEtc.Bottom1, Int_48, ' ') + rptLF2;
      if ReceiptEtc.Bottom2 <> EmptyStr then
        PrintData := PrintData + RPadB(ReceiptEtc.Bottom2, Int_48, ' ') + rptLF2;
      if ReceiptEtc.Bottom3 <> EmptyStr then
        PrintData := PrintData + RPadB(ReceiptEtc.Bottom3, Int_48, ' ') + rptLF2;
      if ReceiptEtc.Bottom4 <> EmptyStr then
        PrintData := PrintData + RPadB(ReceiptEtc.Bottom4, Int_48, ' ') + rptLF2;

      {
       // �δ�ü� �̿�� ����
      CAT_PARKING_TICKET    = 'PZ';
      CAT_SAUNA_TICKET      = 'SB';
      CAT_FITNESS_TICKET    = 'FH';
      }

      PrintData := PrintData + RECEIPT_LINE2 + rptLF;
      PrintData := PrintData + FormatDateTime('yyyy��mm��dd�� hh��nn��', now) + rptLF + rptLF + rptLF;

      PrintData := PrintData + rptReceiptAlignCenter;//rptReceiptAlignLeft;
      PrintData := PrintData + rptLF + rptLF + rptLF + rptReceiptCut;

      Result := Print(PrintData);
    end;
  end;
end;

function TReceiptPrint.Print(APrintData: string): Boolean;
var
  SendData: AnsiString;
begin
  try
    Result := False;

    SendData := ConvertPrintData(APrintData);
    ComPort.Write(SendData[1], Length(SendData));

    Result := True;
  except
    on E: Exception do
    begin
      log.E('TReceiptPrint.Print', E.Message);
    end;
  end;
end;

function TReceiptPrint.LPadB(const AStr: string; ALength: Integer; APadChar: Char): string;
begin
  Result := SCopy(AStr, 1, ALength);
  Result := PadChar(ALength - ByteLen(Result), APadChar) + Result;
end;

function TReceiptPrint.RPadB(const AStr: string; ALength: Integer; APadChar: Char): string;
begin
  Result := SCopy(AStr, 1, ALength);
  Result := Result + PadChar(ALength - ByteLen(Result), APadChar);
end;

function TReceiptPrint.SCopy(S: AnsiString; F, L: Integer): string;
var
  ST, ED: Integer;
begin
  if F = 1 then ST := 1
  else
  begin
    case ByteType(S, F) of
      mbSingleByte : ST := F;
      mbLeadByte   : ST := F;
      mbTrailByte  : ST := F - 1;
    end;
  end;

  case ByteType(S, ST+L-1) of
    mbSingleByte : ED := L;
    mbLeadByte   : ED := L - 1;
    mbTrailByte  : ED := L;
  end;

  Result := Copy(S, ST, ED);
end;

function TReceiptPrint.PadChar(ALength: Integer; APadChar: Char = ' '): string;
var
  Index: Integer;
begin
  Result := '';
  for Index := 1 to ALength do
    Result := Result + APadChar;
end;

function TReceiptPrint.ByteLen(const AText: string): Integer;
var
  Index: Integer;
begin
  Result := 0;
  for Index := 1 to Length(AText) do
    Result := Result + IfThen(AText[Index] <= #$00FF, 1, 2);
end;

function TReceiptPrint.GetCurrStr(AData: Currency): string;
begin
  Result := FormatFloat('#,##0.###', AData);
end;

function TReceiptPrint.DateTimeStrToString(const ADateTime: string): string;
begin
  if Length(ADateTime) = 14 then
    Result := Copy(ADateTime, 1, 4) + FormatSettings.DateSeparator + Copy(ADateTime, 5, 2) + FormatSettings.DateSeparator + Copy(ADateTime, 7, 2) + ' ' +
              Copy(ADateTime, 9, 2) + FormatSettings.TimeSeparator + Copy(ADateTime, 11, 2) + FormatSettings.TimeSeparator + Copy(ADateTime, 13, 2);
end;

procedure TReceiptPrint.SewooStatus;
var
  SendData: AnsiString;
begin
  SendData := #16#4#2;
  {$IFDEF RELEASE}
  if not Global.Config.NoDevice then
  begin
    if Global.Config.Print.Port <> 0 then
      ComPort.Write(SendData[1], Length(SendData));
  end;
  {$ENDIF}
  {
  n=1 : Transmit printer status  ������ ���� ����
  n=2 : Transmit off-line status  �������� ���� ����
  n=3 : Transmit error status     ���� ���� ����
  n=4 : Transmit paper roll sensor status  ���� �� ���� ���� ����
  }
end;

procedure TReceiptPrint.ComPortRxChar(Sender: TObject; Count: Integer);
var
  sRecvData, sStr, sStrHex, sStrBin, sPrintStatus: AnsiString;
begin
  SetLength(sRecvData, Count);

  ComPort.Read(sRecvData[1], Count);
  sStr := sRecvData;

  //00100000
  sStrHex := StringToHex(sRecvData);
  sStrBin := HexToBin(sStrHex);

  PrintStatus := Copy(sStrBin, 3, 1);
  if PrintStatus = '1' then
  begin
    Global.SaleModule.FSendPrintError := True;

    Global.SaleModule.CallAdmin;
    Log.D('SewooStatus', 'CallAdmin');
  end
  else
  begin
    Global.SaleModule.FSendPrintError := False;
  end;
end;

{ TReceipt }

constructor TReceipt.Create;
begin
  StoreInfo := TStoreInfo.Create;
  OrderList := [];
  ReceiptMemberInfo := TReceiptMemberInfo.Create;
  ReceiptEtc := TReceiptEtc.Create;
  ProductInfo := [];
end;

destructor TReceipt.Destroy;
begin
  StoreInfo.Free;
  OrderList := [];
  ReceiptMemberInfo.Free;
  ReceiptEtc.Free;
  ProductInfo := [];
  inherited;
end;

procedure TReceipt.Load(AJsonText: string);
begin
  try
    TJsonReadWriter.JsonToObject<TReceipt>(AJsonText, Self);
  finally

  end;
end;

{ TPrintThread }

constructor TPrintThread.Create;
begin
  FreeOnTerminate := False;
  inherited Create(True);
  PrintList := TList<string>.Create;
end;

destructor TPrintThread.Destroy;
begin
  PrintList.Free;
  inherited;
end;

procedure TPrintThread.Execute;
begin
  inherited;
  while not Terminated do
  begin
    if PrintList.Count <> 0 then
    begin
      Log.D('TPrintThread.Execute', 'Print');
      Global.SaleModule.Print.ReceiptPrint(PrintList[0]);
      PrintList.Delete(0);
    end
    else
      Suspend;
    Sleep(10);
  end;
end;

end.
