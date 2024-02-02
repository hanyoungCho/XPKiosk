unit uPrint;

interface

uses
  System.SysUtils, Math, StrUtils, System.DateUtils,
  System.IOUtils, Winapi.Windows,
  fx.Json, Vcl.Forms, Vcl.StdCtrls, System.Classes,
  CPort, Generics.Collections;

const
  // 프린터 특수명령
  rptReceiptCharNormal    = '{N}';   // 일반 글자
  rptReceiptCharBold      = '{B}';   // 굵은 글자
  rptReceiptCharInverse   = '{I}';   // 역상 글자
  rptReceiptCharUnderline = '{U}';   // 밑줄 글자
  rptReceiptAlignLeft     = '{L}';   // 왼쪽 정렬
  rptReceiptAlignCenter   = '{C}';   // 가운데 정렬
  rptReceiptAlignRight    = '{R}';   // 오른쪽 정렬
  rptReceiptSizeNormal    = '{S}';   // 보통 크기
  rptReceiptSizeWidth     = '{X}';   // 가로확대 크기
  rptReceiptSizeHeight    = '{Y}';   // 세로확대 크기
  rptReceiptSizeBoth      = '{Z}';   // 가로세로확대 크기
  rptReceiptSize3Times    = '{3}';   // 가로세로3배확대 크기
  rptReceiptSize4Times    = '{4}';   // 가로세로4배확대 크기
  rptReceiptInit          = '{!}';   // 프린터 초기화
  rptReceiptCut           = '{/}';   // 용지커팅
  rptReceiptImage1        = '{*}';   // 그림 인쇄 1
  rptReceiptImage2        = '{@}';   // 그림 인쇄 2
  rptReceiptCashDrawerOpen= '{O}';   // 금전함 열기
  rptReceiptSpacingNormal = '{=}';   // 줄간격 보통
  rptReceiptSpacingNarrow = '{&}';   // 줄간격 좁음
  rptReceiptSpacingWide   = '{\}';   // 줄간격 넓음
  rptLF                   = '{-}';   // 줄바꿈
  rptLF2                  = #13#10;  // 줄바꿈
  rptBarCodeBegin128      = '{<}';   // 바코드 출력 시작 CODE128
  rptBarCodeBegin39       = '{[}';   // 바코드 출력 시작 CODE39
  rptBarCodeEnd           = '{>}';   // 바코드 출력 끝
  // 프린터 출력명령 (영수증 별도 출력에서 사용함)
  rptReceiptCharSaleDate  = '{D}';   // 판매일자
  rptReceiptCharPosNo     = '{P}';   // 포스번호
  rptReceiptCharPosName   = '{Q}';   // 포스명
  rptReceiptCharBillNo    = '{A}';   // 빌번호
  rptReceiptCharDateTime  = '{E}';   // 출력일시

  RECEIPT_TITLE1          = '메뉴명                      단가 수량       금액';
  RECEIPT_TITLE2          = '메뉴명                단가 수량       금액';
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
    StoreName: string;               // 매장명
    BizNo: string;                   // 사업자번호
    BossName: string;                // 업주명
    Tel: string;                     // 전화번호
    Addr: string;                    // 주소
  end;

  TOrderInfo = class(TJson)
    UseProductName: string;          // 타석배정표에 표시될 상품명
    TeeBox_Floor: string;            // 타석 배정 층
    TeeBox_Nm: string;               // 타석 배정 번호
    UseTime: string;                 // 이용시간
    One_Use_Time: string;            // 이용시간(타석상품)
    Coupon: Boolean;                 // 쿠폰유무
    CouponQty: Integer;              // 잔여쿠폰수 - 쿠폰사용시 기본 0
    CouponUseDate: string;           // 쿠폰 사용일
    ExpireDate: string;              // 만기일자
    Reserve_No: string;              // 예약 번호
    Parking_Barcode: string;         // 타석 배정표 바코드(주차관리)
    ProductDiv: string;              // 타석권 종류
  end;

  TReceiptMemberInfo = class(TJson)
    Name: string;                    // 회원명
    Code: string;                    // 회원코드
    Tel: string;                     // 전화번호
  end;

  TProductInfo = class(TJson)
    Name: string;                    // 상품명
    Code: string;                    // 상품코드
    Price: Integer;                  // 판매금액(1EA 단가)
    Vat: Integer;                    // 부가세금액(1EA 부가세)
    Qty: Integer;                    // 총 수량
  end;

  TReceiptEtc = class(TJson)
    RcpNo: Integer;
    SaleDate: string;                // 판매일자 (금일)
    ReturnDate: string;              // 반품일자 (반품시 원판매일자)
    RePrint: Boolean;                // 재발행 여부
    TotalAmt: Integer;               // 상품판매시 총 판매금액
    DCAmt: Integer;                  // 할인금액
    Receipt_No: string;              // 영수증번호(바코드)
    Top1: string;                    // 상단문구1
    Top2: string;                    // 상단문구2
    Top3: string;                    // 상단문구3
    Top4: string;                    // 상단문구4
    Bottom1: string;                 // 하단문구1
    Bottom2: string;                 // 하단문구2
    Bottom3: string;                 // 하단문구3
    Bottom4: string;                 // 하단문구4
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

    //sewoo -> 프린터출력시 응답값 없음
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
  BAR_HEIGHT = #$50; // 바코드높이
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

    // CODE39 이면
    if ChkBarCode39 then
    begin
      ALen := Char(Length(BarCodeOrg));
      BarCodeToStr := #$1D#$68 + BAR_HEIGHT + #$1D#$77#$02#$1B#$61#$01#$1D#$48#$02#$1D#$6B + BAR_CODE39 + ALen + BarCodeOrg;
    end
    else
    // CODE128 이면
    begin
      ALen := Char(Length(BarCodeOrg) + 2); // 2 를 더해야 함
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
  Result := ReplaceStr(Result, rptReceiptCut,           #27#109);   // 반컷 109
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
  else // Port가 없다
    Exit;

  //트로스 48자,  씨아이테크(sewoo 프린터) 42자
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

      PrintData := PrintData + rptReceiptSizeWidth + '타 석 배 정 표' + rptLF;

      PrintData := PrintData + rptReceiptAlignCenter{rptReceiptAlignLeft} + rptReceiptSizeNormal;
      PrintData := PrintData + RECEIPT_LINE2 + rptLF;
      PrintData := PrintData + rptReceiptSizeBoth;//rptReceiptSizeWidth + rptReceiptSizeHeight;//rptReceiptSizeBoth;

      sUseTime := OrderList[Index].UseTime + '-' + FormatDateTime( 'hh:nn', IncMinute(StrToDateTime(OrderList[Index].UseTime), StrToInt(OrderList[Index].One_Use_Time)) );

      PrintData := PrintData + rptReceiptAlignLeft + rptReceiptCharBold +  rptReceiptSizeHeight;
      PrintData := PrintData + '타 석 번 호 : ';
      PrintData := PrintData + rptReceiptSizeNormal + rptReceiptSizeBoth;
      PrintData := PrintData + Format('%s %s번', [OrderList[Index].TeeBox_Floor, OrderList[Index].TeeBox_Nm]) + rptLF + rptLF;

      PrintData := PrintData + rptReceiptCharBold +  rptReceiptSizeHeight;
      PrintData := PrintData + '이 용 시 간 : ';
      PrintData := PrintData + rptReceiptSizeNormal + rptReceiptSizeBoth;
      PrintData := PrintData + Format('%s', [sUseTime, OrderList[Index].One_Use_Time]) + rptLF;

      PrintData := PrintData + rptReceiptCharBold +  rptReceiptSizeHeight;
      PrintData := PrintData + '배 정 시 간 : ';
      PrintData := PrintData + rptReceiptSizeNormal + rptReceiptSizeBoth;
      PrintData := PrintData + Format('%s분', [OrderList[Index].One_Use_Time]) + rptLF + rptLF;

      PrintData := PrintData + rptReceiptSizeNormal;
      PrintData := PrintData + RPadB('이 용 일 자 : ' + Receipt.ReceiptEtc.SaleDate, Int_48, ' ') + rptLF;
      if ReceiptMemberInfo.Name <> EmptyStr then
        PrintData := PrintData + RPadB('회 원 성 명 : ' + Format('%s(%s)', [ReceiptMemberInfo.Name, ReceiptMemberInfo.Code]), Int_48, ' ') + rptLF;
      PrintData := PrintData + RPadB('서 비 스 명 : ' + OrderList[Index].UseProductName, Int_48, ' ') + rptLF;

      if OrderList[Index].ExpireDate <> EmptyStr then
        PrintData := PrintData + RPadB('만 기 일 자 : ' + OrderList[Index].ExpireDate, Int_48, ' ') + rptLF;

      if OrderList[Index].Reserve_No = EmptyStr then
        PrintData := PrintData + RPadB('예 약 번 호 : ' + '관리자에게 문의 바랍니다.', Int_48, ' ') + rptLF
      else
        PrintData := PrintData + RPadB('예 약 번 호 : ' + OrderList[Index].Reserve_No, Int_48, ' ') + rptLF;

      if OrderList[Index].Coupon then
      begin
        PrintData := PrintData + RPadB('잔여 쿠폰수 : ' + Format('%d매', [OrderList[Index].CouponQty]), Int_48, ' ') + rptLF;
        PrintData := PrintData + RPadB(OrderList[Index].CouponUseDate, Int_48, ' ') + rptLF
      end;

      PrintData := PrintData + RECEIPT_LINE2 + rptLF;
      PrintData := PrintData + RPadB('출력시각 : ' + FormatDateTime('yyyy-mm-dd hh:nn', now), Int_48, ' ') + rptLF2;
      PrintData := PrintData + RECEIPT_LINE2 + rptLF;

      PrintData := PrintData + rptReceiptAlignCenter;
      PrintData := PrintData + '취소 문의는 프론트로 방문해 주세요.' + rptLF;
      PrintData := PrintData + '이용해 주셔서 감사합니다.' + rptLF;
      PrintData := PrintData + '좋은 하루 되세요.' + rptLF;

      if ReceiptEtc.Bottom1 <> EmptyStr then
        PrintData := PrintData + RPadB(ReceiptEtc.Bottom1, Int_48, ' ') + rptLF2;
      if ReceiptEtc.Bottom2 <> EmptyStr then
        PrintData := PrintData + RPadB(ReceiptEtc.Bottom2, Int_48, ' ') + rptLF2;
      if ReceiptEtc.Bottom3 <> EmptyStr then
        PrintData := PrintData + RPadB(ReceiptEtc.Bottom3, Int_48, ' ') + rptLF2;
      if ReceiptEtc.Bottom4 <> EmptyStr then
        PrintData := PrintData + RPadB(ReceiptEtc.Bottom4, Int_48, ' ') + rptLF2;

      {
       // 부대시설 이용권 구분
      CAT_PARKING_TICKET    = 'PZ';
      CAT_SAUNA_TICKET      = 'SB';
      CAT_FITNESS_TICKET    = 'FH';
      }

      PrintData := PrintData + RECEIPT_LINE2 + rptLF;
      PrintData := PrintData + FormatDateTime('yyyy년mm월dd일 hh시nn분', now) + rptLF + rptLF + rptLF;

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
  n=1 : Transmit printer status  프린터 상태 전송
  n=2 : Transmit off-line status  오프라인 상태 전송
  n=3 : Transmit error status     오류 상태 전송
  n=4 : Transmit paper roll sensor status  용지 롤 센서 상태 전송
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
