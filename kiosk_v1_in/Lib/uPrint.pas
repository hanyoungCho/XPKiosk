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
  //jhj jms
  TOpenPort = function(PortName: AnsiString; Gubun, Code: Integer): Integer; stdcall;
  TClose = function(): Integer; stdcall;
  TStatus = function(ATimeOut: Integer): Integer; stdcall;

  //chy sewoo
  TDeviceType = (dtNone, dtPos, dtKiosk, dtKiosk42);
  TPayType = (None, Cash, Card, Payco, Void);

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

    Locker_End_Day: string;         // 라카만기일
  end;

  TReceiptMemberInfo = class(TJson)
    Name: string;                    // 회원명
    Code: string;                    // 회원코드
    Tel: string;                     // 전화번호
    CarNo: string;                   // 차량번호
    CardNo: string;                  // 회원카드번호
    MemberXGOLF: Boolean;            // XGOLF 회원 유무
    XGolfDiscountAmt: Integer;       // XGOLF 할인 금액
  end;

  TProductInfo = class(TJson)
    Name: string;                    // 상품명
    Code: string;                    // 상품코드
    Price: Integer;                  // 판매금액(1EA 단가)
    Vat: Integer;                    // 부가세금액(1EA 부가세)
    Qty: Integer;                    // 총 수량
  end;

  TDiscountInfo = class(TJson)
    Name: string;                    // 할인명
    QRCode: string;                  // QR Code
    Value: string;                   // 할인금액
  end;

  TPayInfo = class(TJson)
    &PayCode: TPayType;              // 결제타입
    Approval: Boolean;               // 승인유무 T: 승인 F: 취소
    Internet: Boolean;               // 인터넷 승인 유무
    ApprovalAmt: Integer;            // 승인금액
    ApprovalNo: string;              // 승인번호
    OrgApprovalNo: string;           // 원 승인번호
    CardNo: string;                  // 카드번호
    CashReceiptPerson: Integer;      // 소득공제 1: 개인, 2: 사업자
    HalbuMonth: string;              // 할부개월

    CompanyName: string;             // PAYCO 승인기관
    MerchantKey: string;             // 가맹번호
    TransDateTime: string;           // 승인일시
    BuyCompanyName: string;          // 매입사
    BuyTypeName: string;             // 매입처
    CardDiscount: Integer;           // 카드사 할인
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
    PayInfo: TArray<TPayInfo>;
    DiscountInfo: TArray<TDiscountInfo>;
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

    //jhj jms
    FHandel: THandle;

    //jhj jms
    Exec_Open: TOpenPort;
    Exec_Close: TClose;
    Exec_Status: TStatus;

    //chy sewoo
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
    function SetReceiptPrint: Boolean;
    function SetTeeBoxPrint: Boolean;

    function Print(APrintData: string): Boolean;

    function ReceiptHeader: string;
    function ReceiptItemList: string;
    function ReceiptTotalAmt: string;
    function ReceiptPayList: string;
    function ReceiptPayListInfo: string;
    function ReceiptDiscountInfo: string;
    function ReceiptBottom: string;
    function MakeNewPayCoData(APayInfo: TPayInfo): string;  // NewPayCo정보

    function ConvertPrintData(AData: string): string;
    function ConvertBarCodeCMD(AData: string): string;

    //jhj jms
    function PrintCheckStatus(out AMsg: string): Boolean;
    procedure PrintCheckLoadDLL;

    //chy sewoo -> 프린터출력시 응답값 없음
    procedure ComPortRxChar(Sender: TObject; Count: Integer);
    procedure SewooStatus;

    property ComPort: TComPort read FComPort write FComPort;
    property IsReturn: Integer read FIsReturn write FIsReturn;
    property Int_37: Integer read FInt_37 write FInt_37;
    property Int_11: Integer read FInt_11 write FInt_11;
    property Int_48: Integer read FInt_48 write FInt_48;
    property Int_33: Integer read FInt_33 write FInt_33;
    property Int_15: Integer read FInt_15 write FInt_15;

    //chy sewoo
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
//  if Global.Config.OAuth.DeviceID = 'T000100001' then
    Result := ReplaceStr(Result, rptReceiptCut,           #27#109);   // 반컷 109
//  else
//    Result := ReplaceStr(Result, rptReceiptCut,           #27#105);
  Result := ReplaceStr(Result, rptReceiptInit,          #27#64);
//  Result := ReplaceStr(Result, rptReceiptCut,           #27#109);   // 반컷 109
//  Result := ReplaceStr(Result, rptReceiptCut,           #29#86#1); // #29#86#1 반컷팅 #29#86#0 풀컷팅
  Result := ReplaceStr(Result, rptReceiptImage1,        #13#28#112#1#0);
  Result := ReplaceStr(Result, rptReceiptImage2,        #13#28#112#2#0);
  Result := ReplaceStr(Result, rptReceiptCashDrawerOpen,#27'p'#0#25#250#13#10);
  Result := ReplaceStr(Result, rptReceiptSpacingNormal, #27#51#60);
  Result := ReplaceStr(Result, rptReceiptSpacingNarrow, #27#51#50);
  Result := ReplaceStr(Result, rptReceiptSpacingWide,   #27#51#120);
  Result := ReplaceStr(Result, rptLF,                   #13#10);
  if FDeviceType = dtKiosk then
  begin
    Result := ReplaceStr(Result, rptReceiptSize3Times,    #29#33#17);//#29#33#34);
    Result := ReplaceStr(Result, rptReceiptSize4Times,    #29#33#34);//#29#33#51);
    Result := ReplaceStr(Result, rptReceiptSizeNormal,    #29#33#0);//#27#33#0);
    Result := ReplaceStr(Result, rptReceiptSizeWidth,     #29#33#1);//#27#33#32);
    Result := ReplaceStr(Result, rptReceiptSizeHeight,    #29#33#16);//#27#33#16);
    Result := ReplaceStr(Result, rptReceiptSizeBoth,      #29#33#17);
  end
  else
  begin
    Result := ReplaceStr(Result, rptReceiptSize3Times,    #29#33#34);
    Result := ReplaceStr(Result, rptReceiptSize4Times,    #29#33#51);
    Result := ReplaceStr(Result, rptReceiptSizeNormal,    #27#33#0);
    Result := ReplaceStr(Result, rptReceiptSizeWidth,     #27#33#32);
    Result := ReplaceStr(Result, rptReceiptSizeHeight,    #27#33#16);
    Result := ReplaceStr(Result, rptReceiptSizeBoth,      #27#33#48);
  end;
  Result := ReplaceStr(Result, rptReceiptCharNormal,    EmptyStr);
  Result := ConvertBarCodeCMD(Result);
end;

constructor TReceiptPrint.Create(ADeviceType: TDeviceType; APort: Integer; ABaudRate: TBaudRate);
begin
  FDeviceType := ADeviceType;

  ComPort := TComPort.Create(nil);
  ComPort.Port := 'COM' + IntToStr(APort);
  ComPort.BaudRate := ABaudRate;

  //chy sewoo
  ComPort.OnRxChar := ComPortRxChar;
  FComPortNo := APort;

  if CheckEnumComPorts(APort) then
    ComPort.Open
  else
  begin
    // Port가 없다
    Exit;
  end;

  //chy sewoo
  //트로스 48자,  씨아이테크(sewoo 프린터) 42자
  if (FDeviceType = dtPos) or (FDeviceType = dtKiosk42) then
  begin
    Int_37 := 33;
    Int_11 := 9;
    Int_48 := 42;
    Int_33 := 29;
    Int_15 := 13;
  end
  else
  begin
    Int_37 := 37;
    Int_11 := 11;
    Int_48 := 48;
    Int_33 := 33;
    Int_15 := 15;
  end;

  PrintThread := TPrintThread.Create;

  //jhj jms
  PrintCheckLoadDLL;
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

function TReceiptPrint.MakeNewPayCoData(APayInfo: TPayInfo): string;
resourcestring
  STR_POINT = '페이코포인트';
  STR_COUPON = '페이코쿠폰';
  STR_CARD = '신용카드';
  STR1 = '***승인정보(고객용)***';
  STR2 = '승인기관     :';
  STR3 = '신용카드번호 :';
  STR4 = '할부개월     :';
  STR5 = '승인번호     :';
  STR6 = '승인일시     :';
  STR7 = '가맹번호     :';
  STR8 = '매입사       :';
  STR9 = '매입처       :';
  STR10 = '***OK 캐쉬백 포인트 내역***';
  STR11 = '적립포인트          :';
  STR12 = '사용가능 적립포인트 :';
  STR13 = '누적 적립포인트     :';
  STR14 = '일시불';
  STR15 = ' 개월';
  STR16 = '티머니카드번호 :';
  STR17 = '결제전잔액   :';
  STR18 = '결제금액     :';
  STR19 = '결제후잔액   :';
  STR20 = '- PAYCO 승인정보 -';
  STR21 = '- PAYCO 취소정보 -';
  STR22 = '***승인취소정보(고객용)***';
  STR23 = '쿠폰이름     :';
var
  Index, ASaleSign: Integer;
begin//
  Result := EmptyStr;

  if APayInfo.Approval then
    ASaleSign := 1
  else
    ASaleSign := -1;

//  Result := Result + IfThen(FDeviceType = dtKiosk, RECEIPT_LINE1, RECEIPT_LINE2) + rptLF2;
  Result := Result + rptReceiptAlignCenter + IfThen(APayInfo.Approval, STR20, STR21) + rptLF2;

  Result := Result + RPadB(STR_CARD, Int_33, ' ') + LPadB(GetCurrStr(ASaleSign * APayInfo.ApprovalAmt), Int_15, ' ') + rptLF2;
  Result := Result + rptReceiptCharNormal;

  Result := Result + rptReceiptAlignCenter;//rptReceiptAlignLeft;
  Result := Result + IfThen(FDeviceType = dtKiosk, RECEIPT_LINE1, RECEIPT_LINE2) + rptLF2;
  Result := Result + rptReceiptAlignCenter + IfThen(APayInfo.Approval, STR1, STR22) + rptLF2;
  Result := Result + rptReceiptAlignCenter;//rptReceiptAlignLeft;
  Result := Result + RPadB(STR2, Int_15, ' ') + LPadB(APayInfo.CompanyName, Int_33, ' ') + rptLF2;
  Result := Result + RPadB(STR3, Int_15, ' ') + LPadB(APayInfo.CardNo, Int_33, ' ') + rptLF2;
  if StrToIntDef(APayInfo.HalbuMonth, 0) = 0 then
    Result := Result + RPadB(STR4, Int_15, ' ') + LPadB(STR14, Int_33, ' ') + rptLF2
  else
    Result := Result + RPadB(STR4, Int_15, ' ') + LPadB(APayInfo.HalbuMonth + STR15, Int_33, ' ') + rptLF2;

  Result := Result + RPadB(STR5, Int_15, ' ') + LPadB(APayInfo.ApprovalNo, Int_33, ' ') + rptLF2;
  Result := Result + RPadB(STR6, Int_15, ' ') + LPadB(DateTimeStrToString(APayInfo.TransDateTime), Int_33, ' ') + rptLF2;

  Result := Result + RPadB(STR7, Int_15, ' ') + LPadB(APayInfo.MerchantKey, Int_33, ' ') + rptLF2;
  Result := Result + RPadB(STR8, Int_15, ' ') + LPadB(APayInfo.BuyCompanyName, Int_33, ' ') + rptLF2;
  Result := Result + RPadB(STR9, Int_15, ' ') + LPadB(APayInfo.BuyTypeName, Int_33, ' ') + rptLF2;
end;

function TReceiptPrint.ReceiptBottom: string;
begin
  Result := EmptyStr;
  Result := Result + rptReceiptSizeNormal;

  Result := Result + rptBarCodeBegin128;
  Result := Result + Receipt.ReceiptEtc.Receipt_No;
  Result := Result+ rptBarCodeEnd + rptLF;

  if Receipt.ReceiptEtc.Bottom1 <> EmptyStr then
    Result := Result + Receipt.ReceiptEtc.Bottom1 + rptLF2;
  if Receipt.ReceiptEtc.Bottom2 <> EmptyStr then
    Result := Result + Receipt.ReceiptEtc.Bottom2 + rptLF2;
  if Receipt.ReceiptEtc.Bottom3 <> EmptyStr then
    Result := Result + Receipt.ReceiptEtc.Bottom3 + rptLF2;
  if Receipt.ReceiptEtc.Bottom4 <> EmptyStr then
    Result := Result + Receipt.ReceiptEtc.Bottom4 + rptLF2;

  if Receipt.ReceiptEtc.SaleUpload = 'Y' then
  begin
    Result := Result + '매출업로드에 실패하였습니다.' + #13#10 + rptLF2;
    Result := Result + '관리자에게 문의 바랍니다..' + #13#10 + rptLF2;
  end;
  Result := Result + IfThen(FDeviceType = dtKiosk, RECEIPT_LINE3, RECEIPT_LINE4) + rptLf2;

  if Receipt.ReceiptEtc.RePrint then
  begin
    Result := Result + rptReceiptAlignCenter + '재발행된 영수증 입니다.' + rptLF2;
    Result := Result + rptReceiptAlignCenter;//rptReceiptAlignLeft;
    Result := Result + IfThen(FDeviceType = dtKiosk, RECEIPT_LINE3, RECEIPT_LINE4) + rptLf2;
  end;
  Result := Result + rptLF + rptLF + rptLF + rptReceiptCut;
end;

function TReceiptPrint.ReceiptHeader: string;
begin
  Result := EmptyStr;
  Result := Result + rptReceiptInit;
//  Result := Result + #29#76#0#1;
  Result := Result + rptReceiptAlignCenter;
  Result := Result + rptReceiptSizeWidth;
  Result := Result + '영 수 증' + rptLF2 + rptLF2;
  Result := Result + rptReceiptSizeNormal;
  Result := Result + rptReceiptAlignCenter;//rptReceiptAlignLeft;
  Result := Result + RPadB('매 장 명 : ' + Receipt.StoreInfo.StoreName, Int_48, ' ') + rptLF2;
  Result := Result + RPadB('대표자명 : ' + Receipt.StoreInfo.BossName, Int_48, ' ') + rptLF2;
  Result := Result + RPadB('전화번호 : ' + Receipt.StoreInfo.Tel, Int_48, ' ') + rptLF2;
//  Result := Result + RPadB('매장주소 : ' + Receipt.StoreInfo.Addr, Int_48, ' ') + rptLF2;
  Result := Result + RPadB('매장주소 : ' + SCopy(Receipt.StoreInfo.Addr, 1, 36), Int_48, ' ') + rptLF2;
  Result := Result + RPadB('           ' + SCopy(Receipt.StoreInfo.Addr, 37, Length(Receipt.StoreInfo.Addr)), Int_48, ' ') + rptLF2;
  Result := Result + RPadB('사업자번호 : ' + Receipt.StoreInfo.BizNo, Int_48, ' ') + rptLF2;
  Result := Result + RPadB('출력시각 : ' + FormatDateTime('yyyy-mm-dd hh:nn', now), Int_48, ' ') + rptLF2;
  if Receipt.ReceiptEtc.Top1 <> EmptyStr then
    Result := Result + RPadB(Receipt.ReceiptEtc.Top1, Int_48, ' ') + rptLF2;
  if Receipt.ReceiptEtc.Top2 <> EmptyStr then
    Result := Result + RPadB(Receipt.ReceiptEtc.Top2, Int_48, ' ') + rptLF2;
  if Receipt.ReceiptEtc.Top3 <> EmptyStr then
    Result := Result + RPadB(Receipt.ReceiptEtc.Top3, Int_48, ' ') + rptLF2;
  if Receipt.ReceiptEtc.Top4 <> EmptyStr then
    Result := Result + RPadB(Receipt.ReceiptEtc.Top4, Int_48, ' ') + rptLF2;
  Result := Result + IfThen(FDeviceType = dtKiosk, RECEIPT_LINE3, RECEIPT_LINE4) + rptLF2;
  Result := Result + IfThen(FDeviceType = dtKiosk, RECEIPT_TITLE1, RECEIPT_TITLE2) + rptLF2;
  Result := Result + IfThen(FDeviceType = dtKiosk, RECEIPT_LINE3, RECEIPT_LINE4) + rptLF2;
end;

function TReceiptPrint.ReceiptItemList: string;
var
  Index: Integer;
  AProductInfo: TProductInfo;
begin
  Result := EmptyStr;
  for Index := 0 to Length(Receipt.ProductInfo) - 1 do
  begin
    AProductInfo := Receipt.ProductInfo[Index];
    Result := Result + Format('%s%10s%5s%11s', [
                       RPadB(AProductInfo.Name, IfThen(FDeviceType = dtKiosk, 22, 16), ' '),
                       FormatFloat('#,##0.##', AProductInfo.Price),
                       FormatFloat('#,##0.##', AProductInfo.Qty),
                       FormatFloat('#,##0.##', IsReturn * (AProductInfo.Price * AProductInfo.Qty))
                       ]) + rptLF2;
  end;
end;

function TReceiptPrint.ReceiptPayList: string;
var
  Index: Integer;
  CashStr: string;
  APayInfo: TPayInfo;
begin
  Result := EmptyStr;
  for Index := 0 to Length(Receipt.PayInfo) - 1 do
  begin
    APayInfo := Receipt.PayInfo[Index];
    if APayInfo.PayCode = Cash then
    begin
      if APayInfo.Internet and (APayInfo.ApprovalNo <> EmptyStr) then
      begin
        if Trim(APayInfo.OrgApprovalNo) = EmptyStr then
          Result := Result + LPadB('현금영수증(승인)', Int_33, ' ') + LPadB(FormatFloat('#,##0.##', APayInfo.ApprovalAmt), Int_15, ' ') + rptLF2
        else
          Result := Result + LPadB('현금영수증(취소)', Int_33, ' ') + LPadB(FormatFloat('#,##0.##', (-1 * APayInfo.ApprovalAmt)), Int_15, ' ') + rptLF2;
      end
      else
      begin
//        CashStr := IfThen(APayInfo.Approval, '승인', '취소');
        CashStr := '수기등록';
        Result := Result + LPadB('현금(' + CashStr + ')', Int_33, ' ') +
          LPadB(FormatFloat('#,##0.##', IfThen(APayInfo.Approval, 1, -1) * APayInfo.ApprovalAmt), Int_15, ' ') + rptLF2;
      end;
    end;

    if APayInfo.PayCode = Card then
    begin
      if APayInfo.Internet then
      begin
        if APayInfo.Approval then
          Result := Result + LPadB('신용카드(승인)', Int_33, ' ') + LPadB(FormatFloat('#,##0.##', APayInfo.ApprovalAmt), Int_15, ' ') + rptLF2
        else
          Result := Result + LPadB('신용카드(취소)', Int_33, ' ') + LPadB(FormatFloat('#,##0.##', -1 * APayInfo.ApprovalAmt), Int_15, ' ') + rptLF2;
      end
      else
      begin
        Result := Result + LPadB('카드(수기등록)', Int_33, ' ') +
          LPadB(FormatFloat('#,##0.##', IfThen(APayInfo.Approval, 1, -1) * APayInfo.ApprovalAmt), Int_15, ' ') + rptLF2;
      end;
    end;

    if APayInfo.PayCode = Payco then
    begin
      if APayInfo.Approval then
        Result := Result + LPadB('PAYCO(승인)', Int_33, ' ') + LPadB(FormatFloat('#,##0.##', (IsReturn * APayInfo.ApprovalAmt)), Int_15, ' ') + rptLF2
      else
        Result := Result + LPadB('PAYCO(취소)', Int_33, ' ') + LPadB(FormatFloat('#,##0.##', (IsReturn * APayInfo.ApprovalAmt)), Int_15, ' ') + rptLF2;
    end;
  end;
  Result := Result + rptReceiptSizeNormal;
  Result := Result + IfThen(FDeviceType = dtKiosk, RECEIPT_LINE1, RECEIPT_LINE2) + rptLF2;
end;

function TReceiptPrint.ReceiptPayListInfo: string;
var
  Index: Integer;
  CashMsg: string;
  APayInfo: TPayInfo;
begin
  Result := EmptyStr;

  with Receipt do
  begin
    for Index := 0 to Length(PayInfo) - 1 do
    begin
      APayInfo := PayInfo[Index];
      if APayInfo.PayCode = Cash then
      begin
        if Trim(APayInfo.ApprovalNo) <> EmptyStr then
        begin
          CashMsg := IfThen(APayInfo.CashReceiptPerson = 1, '(소득공제)', '(지출증빙)');
          Result := Result + rptReceiptAlignCenter + '';
          Result := Result + IfThen(APayInfo.Approval, '<현금영수증' + CashMsg + ' 승인내역>', '<현금영수증' + CashMsg + ' 취소내역>') + rptLF2;
          Result := Result + IfThen(FDeviceType = dtKiosk, RECEIPT_LINE3, RECEIPT_LINE4) + rptLF2;
          Result := Result + rptReceiptAlignCenter{rptReceiptAlignLeft} + rptReceiptCharNormal;
          Result := Result + RPadB('승인금액', Int_33, ' ') + LPadB(FormatFloat('#,##0.##', APayInfo.ApprovalAmt), Int_15, ' ') + rptLF2;
          Result := Result + RPadB('승인번호', Int_33, ' ') + LPadB(APayInfo.ApprovalNo, Int_15, ' ') + rptLF2;
          Result := Result + RPadB('카드번호', Int_33, ' ') + LPadB(APayInfo.CardNo, Int_15, ' ') + rptLF2;
        end;
      end;

      if APayInfo.PayCode = Card then
      begin
        Result := Result + rptReceiptAlignCenter;
        Result := Result + IfThen(APayInfo.Approval, '<카드 승인내역>', '<카드 취소내역>') + rptLF2;
        Result := Result + IfThen(FDeviceType = dtKiosk, RECEIPT_LINE3, RECEIPT_LINE4) + rptLF2;
        Result := Result + rptReceiptAlignCenter{rptReceiptAlignLeft} + rptReceiptCharNormal;
        Result := Result + RPadB('승인금액', Int_33, ' ') + LPadB(FormatFloat('#,##0.##', APayInfo.ApprovalAmt), Int_15, ' ') + rptLF2;

        if APayInfo.HalbuMonth = '0' then
          Result := Result + RPadB('할부개월', Int_33, ' ') + LPadB('일시불', Int_15, ' ') + rptLF2
        else
          Result := Result + RPadB('할부개월', Int_33, ' ') + LPadB(APayInfo.HalbuMonth  + '개월', Int_15, ' ') + rptLF2;
        Result := Result + RPadB('발 급 사', Int_33, ' ') + LPadB(APayInfo.BuyCompanyName, Int_15, ' ') + rptLF2;
        Result := Result + RPadB('승인번호', Int_33, ' ') + LPadB(APayInfo.ApprovalNo, Int_15, ' ') + rptLF2;
        Result := Result + RPadB('카드번호', Int_33, ' ') + LPadB(APayInfo.CardNo, Int_15, ' ') + rptLF2;
//        if APayInfo.CardDiscount <> 0 then
//        begin
//          Result := Result + RPadB('할인내역', Int_33, ' ') + LPadB(APayInfo.BuyCompanyName + ' 제휴할인', Int_15, ' ') + rptLF2;
//          Result := Result + RPadB('할인금액', Int_33, ' ') + LPadB(FormatFloat('#,##0.##', APayInfo.CardDiscount), Int_15, ' ') + rptLF2;
//        end;
      end;

      if APayInfo.PayCode = Payco then
        Result := Result + MakeNewPayCoData(APayInfo);
    end;
    Result := Result + IfThen(FDeviceType = dtKiosk, RECEIPT_LINE1, RECEIPT_LINE2) + rptLF2;
  end;
end;

function TReceiptPrint.ReceiptDiscountInfo: string;
var
  Index: Integer;
begin
  try
    Result := EmptyStr;

    if (Length(Receipt.DiscountInfo) <> 0) or (Receipt.ReceiptMemberInfo.XGolfDiscountAmt <> 0) then
    begin
      Result := Result + rptReceiptAlignCenter + '<할인내역>' + rptLF;
      Result := Result + rptReceiptAlignCenter;//rptReceiptAlignLeft;
      Result := Result + IfThen(FDeviceType = dtKiosk, RECEIPT_LINE3, RECEIPT_LINE4) + rptLf2;
      if Receipt.ReceiptMemberInfo.MemberXGOLF and (Receipt.ReceiptMemberInfo.XGolfDiscountAmt <> 0) then
      begin
        Result := Result + RPadB('할인종류', Int_33 - 10, ' ') + LPadB('XGOLF 회원 할인', Int_15 + 10, ' ') + rptLF2;
        Result := Result + RPadB('승인금액', Int_33, ' ') +
          LPadB(FormatFloat('#,##0.##', Receipt.ReceiptMemberInfo.XGolfDiscountAmt), Int_15, ' ') + rptLF2;
      end;

      // 웰빙클럽 회원

      for Index := 0 to Length(Receipt.DiscountInfo) - 1 do
      begin
        if Receipt.DiscountInfo[Index].Name = '웰빙클럽 회원' then
        begin
//          Result := Result + rptReceiptAlignCenter + Format('---- %s ----', [Receipt.DiscountInfo[Index].Name]) + rptLF;
          Result := Result + rptReceiptAlignLeft;
          Result := Result + RPadB('웰빙클럽 회원할인', Int_33 - 9, ' ') + LPadB(FormatFloat('#,##0.##', Receipt.ReceiptEtc.TotalAmt - Receipt.ReceiptEtc.DCAmt), Int_15 + 9, ' ') + rptLF2;
//          Result := Result + RPadB('회원코드', Int_33 - 9, ' ') + LPadB(Receipt.DiscountInfo[Index].QRCode, Int_15 + 9, ' ') + rptLF2;
//          Result := Result + RPadB('회원번호', Int_33 - 9, ' ') + LPadB(Receipt.DiscountInfo[Index].Value, Int_15 + 9, ' ') + rptLF2;
        end
        else
        begin
          if StrToIntDef(Receipt.DiscountInfo[Index].Value, 0) = 0 then
            Continue;

          Result := Result + RPadB('할인종류', Int_33 - 10, ' ') + LPadB(Receipt.DiscountInfo[Index].Name, Int_15 + 10, ' ') + rptLF2;
          Result := Result + RPadB('승인금액', Int_33, ' ') +
            LPadB(FormatFloat('#,##0.##', StrToInt(Receipt.DiscountInfo[Index].Value)), Int_15, ' ') + rptLF2;
        end;
      end;

      if Length(Receipt.PayInfo) <> 0 then
      begin
        if Receipt.PayInfo[0].PayCode = Card then
        begin
          if Receipt.PayInfo[0].CardDiscount <> 0 then
          begin
            Result := Result + RPadB('할인종류', Int_33 - 10, ' ') + LPadB(Receipt.PayInfo[0].BuyCompanyName, Int_15 + 10, ' ') + rptLF2;
            Result := Result + RPadB('승인금액', Int_33, ' ') +
              LPadB(FormatFloat('#,##0.##', Receipt.PayInfo[0].CardDiscount), Int_15, ' ') + rptLF2;
          end;
        end;
      end;

      Result := Result + IfThen(FDeviceType = dtKiosk, RECEIPT_LINE1, RECEIPT_LINE2) + rptLF2;
    end;
  finally

  end;
end;

function TReceiptPrint.ReceiptPrint(AJsonText: string): Boolean;
begin
  Log.D('TReceiptPrint.ReceiptPrint', 'Begin');
  try
    try
      Receipt := TReceipt.Create;
      Receipt.Load(AJsonText);

      IsReturn := IfThen(Trim(Receipt.ReceiptEtc.ReturnDate) = EmptyStr, 1, -1);

      if FDeviceType = dtPos then
      begin
        if Length(Receipt.OrderList) <> 0 then
          SetTeeBoxPrint;
      end
      else
      begin
        if Receipt.OrderList[0].Reserve_No <> EmptyStr then
          SetTeeBoxPrint;
      end;

      //if Global.SaleModule.allianceNumber = EmptyStr then //xgolf 회원 phone 인증시 전화번호 들어감
      if Global.SaleModule.allianceCode = EmptyStr then
      begin
        if Length(Receipt.ProductInfo) <> 0 then
        begin
          if SetReceiptPrint then
          begin

          end;
        end;
      end;
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

function TReceiptPrint.ReceiptTotalAmt: string;
var
  AVat: Integer;
begin
  AVat := (Receipt.ReceiptEtc.TotalAmt - Receipt.ReceiptEtc.DCAmt) - Trunc((Receipt.ReceiptEtc.TotalAmt - Receipt.ReceiptEtc.DCAmt) / 1.1);
  Result := EmptyStr;
  Result := Result + rptReceiptSizeNormal;
  Result := Result + IfThen(FDeviceType = dtKiosk, RECEIPT_LINE1, RECEIPT_LINE2) + rptLF2;
  Result := Result + rptReceiptSizeWidth;                        // 16
  Result := Result + Format(IfThen(FDeviceType = dtKiosk, '판매금액%40s', '판매금액%13s'),
                           [FormatFloat('#,##0.##', (IsReturn * Receipt.ReceiptEtc.TotalAmt))]) + rptLF2;
  Result := Result + rptReceiptSizeNormal;
  if Receipt.ReceiptEtc.DCAmt <> 0 then
    Result := Result + LPadB('할인금액', Int_37, ' ') + LPadB(FormatFloat('#,##0.##', (IsReturn * Receipt.ReceiptEtc.DCAmt)), Int_11, ' ') + rptLF2;
  Result := Result + LPadB('과세상품금액', Int_37, ' ') + LPadB(FormatFloat('#,##0.##', (IsReturn * ((Receipt.ReceiptEtc.TotalAmt - Receipt.ReceiptEtc.DCAmt) - AVat))), Int_11, ' ') + rptLF2;
  Result := Result + LPadB('부가세(VAT)금액', Int_37, ' ') + LPadB(FormatFloat('#,##0.##', (IsReturn * AVat)), Int_11, ' ') + rptLF2;
  Result := Result + LPadB('---------------------------', Int_48, ' ') + rptLF2;
  Result := Result + rptReceiptSizeWidth;
  Result := Result + Format(IfThen(FDeviceType = dtKiosk, '결제금액%40s', '결제금액%13s'),
                           [FormatFloat('#,##0.##', (IsReturn * (Receipt.ReceiptEtc.TotalAmt - Receipt.ReceiptEtc.DCAmt)))]) + rptLF2;
  Result := Result + rptReceiptSizeNormal;
end;

function TReceiptPrint.SetReceiptPrint: Boolean;
var
  PrintData: string;
begin
  PrintData := EmptyStr;
  PrintData := PrintData + rptReceiptInit;
  PrintData := PrintData + ReceiptHeader;
  PrintData := PrintData + ReceiptItemList;
  PrintData := PrintData + ReceiptTotalAmt;
  PrintData := PrintData + ReceiptPayList;
  PrintData := PrintData + ReceiptPayListInfo;
  PrintData := PrintData + ReceiptDiscountInfo;
  PrintData := PrintData + ReceiptBottom;

  Result := Print(PrintData);
end;

function TReceiptPrint.SetTeeBoxPrint: Boolean;
var
  Index: Integer;
  PrintData, ParkingBarcode, SaunaBarcode, sUseTime: string;
  bParkingBarcode, bSaunaBarcode: Boolean;
  sParkDate: String;
begin
  PrintData := EmptyStr;
  ParkingBarcode := Emptystr;

  with Receipt do
  begin
    for Index := 0 to Length(OrderList) - 1 do
    begin
      PrintData := rptReceiptInit;
      PrintData := PrintData + rptReceiptAlignCenter;
      PrintData := PrintData + IfThen(FDeviceType = dtKiosk, RECEIPT_LINE1, RECEIPT_LINE2) + rptLF;
      //rptReceiptSizeBoth;

      PrintData := PrintData + rptReceiptSizeWidth + '타 석 배 정 표' + rptLF;

      PrintData := PrintData + rptReceiptAlignCenter{rptReceiptAlignLeft} + rptReceiptSizeNormal;
      PrintData := PrintData + IfThen(FDeviceType = dtKiosk, RECEIPT_LINE1, RECEIPT_LINE2) + rptLF;
      PrintData := PrintData + rptReceiptSizeBoth;//rptReceiptSizeWidth + rptReceiptSizeHeight;//rptReceiptSizeBoth;

      sUseTime := OrderList[Index].UseTime + '-' + FormatDateTime( 'hh:nn', IncMinute(StrToDateTime(OrderList[Index].UseTime), StrToInt(OrderList[Index].One_Use_Time)) );

      PrintData := PrintData + rptReceiptAlignLeft + rptReceiptCharBold +  rptReceiptSizeHeight;
      if (FDeviceType = dtPos) or (FDeviceType = dtKiosk42) then //sewoo
        PrintData := PrintData + '타 석 번 호 : '
      else
        PrintData := PrintData + '타석번호 : ';
      PrintData := PrintData + rptReceiptSizeNormal + rptReceiptSizeBoth;
      //PrintData := PrintData + Format('%s층 %s번', [OrderList[Index].TeeBox_Floor, OrderList[Index].TeeBox_No]) + rptLF + rptLF;
      PrintData := PrintData + Format('%s %s번', [OrderList[Index].TeeBox_Floor, OrderList[Index].TeeBox_Nm]) + rptLF + rptLF;

      PrintData := PrintData + rptReceiptCharBold +  rptReceiptSizeHeight;
      if (FDeviceType = dtPos) or (FDeviceType = dtKiosk42) then //sewoo
        PrintData := PrintData + '이 용 시 간 : '
      else
        PrintData := PrintData + '이용시간 : ';
      PrintData := PrintData + rptReceiptSizeNormal + rptReceiptSizeBoth;
      PrintData := PrintData + Format('%s', [sUseTime, OrderList[Index].One_Use_Time]) + rptLF;

      PrintData := PrintData + rptReceiptCharBold +  rptReceiptSizeHeight;
      if (FDeviceType = dtPos) or (FDeviceType = dtKiosk42) then //sewoo
        PrintData := PrintData + '배 정 시 간 : '
      else
        PrintData := PrintData + '배정시간 : ';
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
        //사용일자 제외 2021-04-13
        //PrintData := PrintData + RPadB('사 용 일 자 : ', Int_48, ' ') + rptLF;
        PrintData := PrintData + RPadB(OrderList[Index].CouponUseDate, Int_48, ' ') + rptLF
      end;

      //라카만료일
      if OrderList[Index].Locker_End_Day <> '' then
      begin
        PrintData := PrintData + RPadB('라카 만기일 : ' + OrderList[Index].Locker_End_Day, Int_48, ' ') + rptLF;
      end;

      PrintData := PrintData + IfThen(FDeviceType = dtKiosk, RECEIPT_LINE1, RECEIPT_LINE2) + rptLF;
      PrintData := PrintData + RPadB('출력시각 : ' + FormatDateTime('yyyy-mm-dd hh:nn', now), Int_48, ' ') + rptLF2;
      PrintData := PrintData + IfThen(FDeviceType = dtKiosk, RECEIPT_LINE1, RECEIPT_LINE2) + rptLF;

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

      //chy move
      if Global.Move_TEST = True then
      begin
        if OrderList[Index].Reserve_No <> EmptyStr then
        begin
          PrintData := PrintData + rptLF;
          PrintData := PrintData + '[타석이동] 및 [시간추가] 시' + rptLF;
          PrintData := PrintData + '사용하는 바코드 입니다.' + rptLF;

          PrintData := PrintData + rptBarCodeBegin128;
          PrintData := PrintData + OrderList[Index].Reserve_No;
          PrintData := PrintData+ rptBarCodeEnd + rptLF;
        end;
      end;

      {
       // 부대시설 이용권 구분
      CAT_PARKING_TICKET    = 'PZ';
      CAT_SAUNA_TICKET      = 'SB';
      CAT_FITNESS_TICKET    = 'FH';
      }

      bParkingBarcode := False;

      if bParkingBarcode = True then
      begin
        PrintData := PrintData + rptLF + rptLF + rptLF + rptLF + rptLF + rptLF;
        PrintData := PrintData + rptReceiptCut;

        PrintData := PrintData + IfThen(FDeviceType = dtKiosk, RECEIPT_LINE1, RECEIPT_LINE2) + rptLF + rptLF;

        PrintData := PrintData + rptReceiptAlignCenter;
        //PrintData := PrintData + rptReceiptCharBold + '주 차 권' + rptLF;
        //PrintData := PrintData + rptReceiptAlignLeft + rptReceiptCharNormal;

        PrintData := PrintData + rptReceiptSizeWidth + '주 차 권 (4시간)' + rptLF;

        PrintData := PrintData + rptReceiptAlignLeft + rptReceiptSizeNormal;

        ParkingBarcode := OrderList[Index].Parking_Barcode;
        ParkingBarcode := StringReplace(ParkingBarcode, '-', '', [rfReplaceAll]);
        ParkingBarcode := StringReplace(ParkingBarcode, ' ', '', [rfReplaceAll]);
        ParkingBarcode := StringReplace(ParkingBarcode, ':', '', [rfReplaceAll]);
        ParkingBarcode := Trim(ParkingBarcode);

        PrintData := PrintData + rptBarCodeBegin128;

        PrintData := PrintData + 'PZ04' + Copy(ParkingBarcode, 3, Length(ParkingBarcode));

        PrintData := PrintData+ rptBarCodeEnd + rptLF + rptLF + rptLF;
        PrintData := PrintData + IfThen(FDeviceType = dtKiosk, RECEIPT_LINE1, RECEIPT_LINE2) + rptLF;
        PrintData := PrintData + FormatDateTime('yyyy년mm월dd일 hh시nn분', now) + rptLF;
        PrintData := PrintData + rptLF + rptLF + rptLF;
      end;

      if (bParkingBarcode = False) and (bSaunaBarcode = False) then
      begin
        PrintData := PrintData + IfThen(FDeviceType = dtKiosk, RECEIPT_LINE1, RECEIPT_LINE2) + rptLF;

        //chy sewoo
        if (FDeviceType = dtPos) or (FDeviceType = dtKiosk42) then
          PrintData := PrintData + FormatDateTime('yyyy년mm월dd일 hh시nn분', now) + rptLF + rptLF + rptLF
        else
          PrintData := PrintData + FormatDateTime('yyyy년mm월dd일 hh시nn분', now) + rptLF;
      end;

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

//chy sewoo
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

//chy sewoo
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
    if Global.Config.Store.ACS = True then
    begin
      if Global.SaleModule.FSendPrintError = False then
        Global.localapi.SendPrintError('Y'); //프린트에러발생
    end;
    Global.SaleModule.FSendPrintError := True;

    Global.SaleModule.CallAdmin;
    Log.D('SewooStatus', 'CallAdmin');
  end
  else
  begin
    if Global.Config.Store.ACS = True then
    begin
      if Global.SaleModule.FSendPrintError = True then
        Global.localapi.SendPrintError('N'); //프린트에러해제;
    end;
    Global.SaleModule.FSendPrintError := False;
  end;
end;

//jhj jms
procedure TReceiptPrint.PrintCheckLoadDLL;
begin
  FHandel := LoadLibrary(PWideChar(ExtractFilePath(ParamStr(0)) + 'REXOD_LIB.dll'));
  if FHandel <> 0 then
  begin
    @Exec_Open := GetProcAddress(FHandel, 'OpenPort');
    @Exec_Close := GetProcAddress(FHandel, 'ClosePort');
    @Exec_Status := GetProcAddress(FHandel, 'PrinterStatus');
  end;
end;

//jhj jms
function TReceiptPrint.PrintCheckStatus(out AMsg: string): Boolean;
var
  APort: string;
  AStatus: Integer;
  function GetError(ACode: Integer): string;
  begin
    Result := EmptyStr;
    if ACode = -1 then
      Result := '통신 연결 안됨'
    else if ACode = -2 then
      Result := '상태체크 전송 실패'
    else if ACode = -3 then
      Result := '상태체크 타임 아웃'
    else if ACode = -4 then
      Result := '상태체크 확인 실패'
    else if ACode = 1 then
      Result := '용지 없음'
    else if ACode = 2 then
      Result := '커버 열림'
    else if ACode = 4 then
      Result := 'Auto Cutter 에러'
    else if ACode = 8 then
      Result := '프리젠더 BLOCK 센서 감지'
    else if ACode = 16 then
      Result := '용지 잔량 센서 감지 됨'
    else if ACode = 64 then
      Result := '용지 배출 센서 감지 됨';
  end;
begin
  Result := False;
  try
    try
      if (not Assigned(@Exec_Open)) or (not Assigned(@Exec_Close)) or (not Assigned(@Exec_Status)) then
      begin
        Log.D('PrintCheckStatus', '함수 없음 체크 불가능으로 그냥 진행');
      end
      else
      begin
        if ComPort.Connected then
        begin
          APort := ComPort.Port;
          ComPort.Close;

          if Exec_Open(APort, 9600, 0) = 0 then
          begin
            AStatus := Exec_Status(500);
            if AStatus <> 0 then
            begin
              AMsg := GetError(AStatus);
            end;

            if Exec_Close <> 0 then
            begin
              Log.D('PrintCheckStatus', 'DLL Close 실패 프로그램 재실행 필요');
            end;
          end
          else
          begin
            Log.D('PrintCheckStatus', '포트 오픈 실패');
          end;

        end;
      end;
    except
      on E: Exception do
      begin
        Log.E('PrintCheckStatus', E.Message);
      end;
    end;
  finally
    ComPort.Open;
  end;

  if AStatus = 0 then
    Result := True;
end;

{ TReceipt }

constructor TReceipt.Create;
begin
  StoreInfo := TStoreInfo.Create;
  OrderList := [];
  ReceiptMemberInfo := TReceiptMemberInfo.Create;
  DiscountInfo := [];
  ReceiptEtc := TReceiptEtc.Create;
  ProductInfo := [];
  PayInfo := [];
end;

destructor TReceipt.Destroy;
begin
  StoreInfo.Free;
  OrderList := [];
  ReceiptMemberInfo.Free;
  DiscountInfo := [];
  ReceiptEtc.Free;
  ProductInfo := [];
  PayInfo := [];
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
