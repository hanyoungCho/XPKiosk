unit uSaleModule;

interface

uses
  uConsts, uPrint, CPort, JSON, VCL.Forms, IdHTTP, System.Classes, Math, mmsystem,
  uStruct, System.SysUtils, uBiominiPlus2, IdGlobal, IdSSL, IdSSLOpenSSL, System.UITypes, System.DateUtils,
  Generics.Collections, Uni, uVanDeamonModul, uPaycoNewModul, IdComponent, IdTCPConnection, IdTCPClient,
  uNitgen, IdURI,
  //union
  uUCBioBSPHelper, uNBioBSPHelper;

type
  TPayTyepe = (ptNone, ptCash, ptCard, ptPayco, ptVoid);

  //현재 카드결제후 소리에 사용
  TSoundThread = class(TThread)
  private
  protected
    procedure Execute; override;
  public
    SoundList: TList<string>;
    constructor Create;
    destructor Destroy; override;
  end;
  {
  TMasterDownThread = class(TThread)
  private
    FAdvertis: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;
  end;
  }
  // 결제형태
  TPayData = class
  private
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function PayType: TPayTyepe; virtual; abstract;
    function PayAmt: Currency; virtual; abstract;
//    // 매출 및 결제 데이타를 DB에 저장한다.
  end;

  TPayCard = class(TPayData)
  private
  public
    // 전송정보
    SendInfo: TCardSendInfoDM;
    // 응답정보
    RecvInfo: TCardRecvInfoDM;
    // 은련카드 여부
    IsEyCard: Boolean;
    // 결제형태
    FPayType: TPayTyepe;
    // 카드사 할인 금액
    CardDiscount: Currency;
    constructor Create; override;
    destructor Destroy; override;
    function PayAmt: Currency; override;
    function PayType: TPayTyepe; override;
  end;

  TPayPayco = class(TPayData)
  private
  public
    // 전송정보
    SendInfo: TPaycoNewSendInfo;
    // 응답정보
    RecvInfo: TPaycoNewRecvInfo;
    // 결제형태
    FPayType: TPayTyepe;
    constructor Create; override;
    destructor Destroy; override;
    function PayAmt: Currency; override;
    function PayType: TPayTyepe; override;
  end;

  TSaleModule = class
  private
    // 백그라운드 마스터 수신 -임시주석 ntdll
    //FMasterDownThread: TMasterDownThread;
    // 사운드
    FSoundThread: TSoundThread;
    // 프로그램 사용 가능 여부
    FProgramUse: Boolean;
    // 로컬 DB or 서버 저장 실패
    FSaveFailMessage: Boolean;
    // 판매일
    FSaleDate: string;
    // 영수증 번호
    FRcpNo: Integer;
    FRcpAspNo: string;
    // 전체 회원 정보
    FMemberList: TList<TMemberInfo>;
    FMemberUpdateList: TList<TMemberInfo>;
    // 판매 상품 정보
    FSaleList: TList<TProductInfo>; //타석상품
    FFacilitySaleList: TList<TProductInfo>; //시설이용권 상품
    FGeneralSaleList: TList<TProductInfo>; //일반상품
    // 가동상황 조합 리스트
    FMainItemList: TList<TTeeBoxInfo>;
    FMainItemMapUse: Boolean;

    // 선택 회원
    FMember: TMemberInfo;
    // 회원의 사용가능한 상품 목록
    FProductList: TList<TProductInfo>;
    // 회원의 선택 상품
    FSelectProduct: TProductInfo;            // 복수로 간다면 List로 가야함.
    // 회원 구입 목록
    FBuyProductList: TList<TSaleData>;
    // 할인정보
    FDisCountList: TList<TDiscount>;
    // 결제정보
    FPayList: TList<TPayData>;
    // 선택 시간
    FSelectTime: TDateTime;
    // 할부 개월
    FSelectHalbu: Integer;
    // VIP ZONE 여부
    FVipTeebox: Boolean;                     // 다중선택시 VIP타석은 어떻게 할 것 인가?
    // 매출등록 실패 여부
    FSaleUpload: Boolean;
    // 전체 타석 보기(층구분 없이)
    FAllTeeBoxShow: Boolean;

    // 체크인 배정목록 2021-08-05
    FCheckInList: TList<TCheckInInfo>;

    // 광고 리스트
    FAdvertListUp: TList<TAdvertisement>;
    FAdvertListTeeboxUp: TList<TAdvertisement>;
    FAdvertListDown: TList<TAdvertisement>;
    FAdvertListPopupMember: TList<TAdvertisement>;
    FAdvertListPopupMemberIdx: Integer;
    FAdvertListComplex: TList<TAdvertisement>;
    FAdvertListEvent: TList<TAdvertisement>;
    FAdvertListReceipt: TList<TAdvertisement>;
    FAdvertListReceiptIdx: Integer;

    // 주차관리 저장 상품 리스트
    FParkingProductList: TList<TProductInfo>;

    //약관
    FAgreementList1: TList<TAgreement>;
    FAgreementList2: TList<TAgreement>;
    FAgreementList3: TList<TAgreement>;

    // 팝업
    // 타석 선택
    FPopUpLevel: TPopUpLevel;
    // 전체화면 팝업
    FPopUpFullLevel: TPopUpFullLevel;
    // 회원 종류 선택 기간/쿠폰/일일
    FmemberItemType: TMemberItemType;
    // 회원이 선택한 타석 정보
    FTeeBoxInfo: TTeeBoxInfo;

    FNewMemberItemType: TMemberItemType;
    FNewMember: TMemberInfo;

    FAdvertPopupType: TAdvertPopupType;

    FTeeBoxMoveInfo: TTeeBoxInfo;
    FVipTeeboxMove: Boolean;
    FTeeboxMenuType: TTeeboxMenuType;

    // 타석 가동상확 타입
    FTeeBoxSortType: TTeeBoxSortType;
    // 카드결제 유형
    FCardApplyType: TCardApplyType;
    // 프로모션 유형
    FPromotionType: TPromotionType;
    //추가 결제 유형
    FPaymentAddType: TPaymentAddType;

    FPrint: TReceiptPrint;
    //Van
    FVanModule: TVanDeamonModul;
    // Payco
    FPaycoModule: TPaycoNewModul;
    // BioMiniPlus2
    //FBioMiniPlus2: TBioMiniPlus2;
    // Nitgen
    //FNitgen: TNitgen;
    FNBioBSPHelper: TNBioBSPHelper;

    // Union
    FUCBioBSPHelper: TUCBioBSPHelper;

    FTotalAmt: Currency;   // 판매금액
    FRealAmt: Currency;    // 실판매금액
    FVatAmt: Currency;     // 부가세액
    FDCAmt: Currency;      // 할인금액
    FRealSumAmt: Currency; // 실매출
    FXGolfDCAmt: Currency; // XGolf할인금액

    FIsComplete: Boolean;
    FVipDisCount: Boolean;
    FMiniMapCursor: Boolean;
    FPrepareMin: Integer;

    FTeeboxTimeError: Boolean;

    // 쿠폰 회원 조회
    FCouponMember: Boolean;

    function GetVanCode: string;
    function GetRcpNo: Integer;
  public
    // 임시 회원 등록시 사용할 변수
//    FingerStr: UTF8String;
    FingerStr: string;
    ConfigJsonText: string;
    // 회원 정보 수신 시간
    MemberInfoDownLoadDateTime: string;
    NowHour: string;
    NowTime: string;
    // 미니맵 width
    MiniMapWidth: Integer;

    // 제휴사 멤버 코드
    FallianceCode: string;  //영수증 출력기준
    FallianceNumber: string;

    //2020-12-29 라카만료일
    FLockerEndDay: String;

    FStoreCloseOver: Boolean;
    FStoreCloseOverMin: String;
    FSendPrintError: Boolean;

    //제휴사 테스트
    FProductCdWellbeing: String;
    FWellbeingApprovalkey: String;
    FProductCdTheloungemembers: String;
    FProductCdBCPaybookGolf: String;
    FProductCdRefreshclub: String;
    FProductCdIkozen: String;

    FApiErrorMsg: String;

    FResetProductList: Boolean; // 00시 상품정보 리셋

    FAdvertReceiptPrintList: array of TAdvertReceipt;
    FAdvertReceiptPopupList: array of TAdvertReceipt;

    constructor Create;
    destructor Destroy; override;

    function OAuthCheck: Boolean;
    // 버전 체크
    function MasterReception(AType: Integer = 0): Boolean;
    function SaleCompleteProc: Boolean;
    function SetPrintData: string;
    function SearchMember(ACode: string): TMemberInfo;
    function SearchRFIDMember(ACode: string): TMemberInfo; //RFID
    function SearchPhoneMember(ACode: string): TMemberInfo; //RFID
    function AddProduct(AProduct: TProductInfo): Boolean;
    function MinusProduct(AProduct: TProductInfo): Boolean;
    function DeleteProduct(AIndex: Integer): Boolean;

    function SetCheckInPrintData: string;

    procedure CallEmp;
    procedure SaleDataClear;
    procedure BuyListClear;
    procedure Calc;
    function AddCheckPromotionType(ACode: string): Boolean;
    function AddCheckDiscount(AProductDiv, AProductDivDetail: string; AGubun: Integer): Boolean;
    function AddChectDiscountAmt(AValue: Integer): Boolean;
    function AddCheckDiscountQR(AQRCode: string): Boolean;
    function AddCheckDiscountProductDiv(AProductDiv, AProductDivDetail, AProductDivCd: string): Boolean;
    function SetDiscount: Boolean;
    // 수량1개당 정률1개
    function SetDiscount_Item: Boolean;
    // 수량1개당 정률 금액만큼 할인
    function SetDiscount_Item_ver2: Boolean;
    function DeleteDiscount(AQRCode: string): Boolean;
    // 카드사 즉시할인 삭제
    function CardDiscountDelete: Boolean;
    // 카드사 즉시할인 SEQ
    function CardDiscountGetCode: string;

    // 준비시간 추가
    function SetPrepareMin: Boolean;

    // X골프 회원인증
    function CheckXGolfMember(ACode: string): Boolean;
    function CheckXGolfMemberPhone(ACode: string): Boolean;
    function CheckXGolfMemberChk(AType, ACode: string): Boolean; //2023-05-11 인증변경

    // 마스터
    function GetMemberList: Boolean;
    function GetConfig: Boolean;
    function GetProductList: Boolean;
    function GetFacilityProductList: Boolean;
    function GetGeneralProductList: Boolean;

    function GetTeeBoxInfo: Boolean;
    function GetPlayingTeeBoxList: Boolean;

    function DeviceInit: Boolean;
    // 카드 정보 조회
    function CallCardInfo: string;
    // 카드 결제
    function CallCard(ACardBin, ACode, AMsg: string; ADiscountAmt: Currency; IsAppCard: Boolean = False): TCardRecvInfoDM;
    //function CallCard_Old: TCardRecvInfoDM;
    // PAYCO 결제
    function CallPayco: TPaycoNewRecvInfo;

    // 결제형태 합계
    function GetSumPayAmt(APayType: TPayTyepe): Currency;

    // 직원호출
    function CallAdmin: Boolean;
    function CallAdminTest: Boolean;
    function CallIntroBlack: Boolean;

    // 타석시간 체크
    function TeeboxTimeCheck: Boolean;

    // 웰빙클럽
    function WellbeingClub(AIsApproval: Boolean; AOTC: string): Boolean;

    // chy 우리카드 더라운지멤버스
    function TheLoungeMembers(AOTC: string): Boolean;
    function TheLoungeMembersUse(ACouponNum: String): Boolean;

    // chy 리프레쉬클럽
    function RefreshClub(AOTC: string): Boolean;
    function ApplyRefreshClub(const AUserId: string): Boolean;

    //2020-12-15 아이코젠
    function ApplyIKozen(const AReadData: string): Boolean;

    function ApplySmartix(const AReadData: string): Boolean;

    //2020-12-14 리프레쉬골프
    function ApplyRefreshGolf(const AUserId: string): Boolean;

    function AllianceProductCheck(AAllianceType: Integer): Boolean;

    function AdvertReceiptView(AType: String): Boolean;

    property ProgramUse: Boolean read FProgramUse write FProgramUse;
    property SaleDate: string read FSaleDate write FSaleDate;
    property RcpNo: Integer read FRcpNo write FRcpNo;
    property RcpAspNo: string read FRcpAspNo write FRcpAspNo;
    property Member: TMemberInfo read FMember write FMember;
    property MemberList: TList<TMemberInfo> read FMemberList write FMemberList;
    property MemberUpdateList: TList<TMemberInfo> read FMemberUpdateList write FMemberUpdateList;
    property memberItemType: TMemberItemType read FmemberItemType write FmemberItemType;

    property NewMemberItemType: TMemberItemType read FNewMemberItemType write FNewMemberItemType;
    property NewMember: TMemberInfo read FNewMember write FNewMember;

    property TeeBoxInfo: TTeeBoxInfo read FTeeBoxInfo write FTeeBoxInfo;
    property SelectProduct: TProductInfo read FSelectProduct write FSelectProduct;

    property TeeBoxMoveInfo: TTeeBoxInfo read FTeeBoxMoveInfo write FTeeBoxMoveInfo;
    property VipTeeboxMove: Boolean read FVipTeeboxMove write FVipTeeboxMove;
    property TeeboxMenuType: TTeeboxMenuType read FTeeboxMenuType write FTeeboxMenuType;

    property PaymentAddType: TPaymentAddType read FPaymentAddType write FPaymentAddType;

    property ProductList: TList<TProductInfo> read FProductList write FProductList;
    property SaleList: TList<TProductInfo> read FSaleList write FSaleList;
    property FacilitySaleList: TList<TProductInfo> read FFacilitySaleList write FFacilitySaleList;
    property GeneralSaleList: TList<TProductInfo> read FGeneralSaleList write FGeneralSaleList;
    property BuyProductList: TList<TSaleData> read FBuyProductList write FBuyProductList;
    property DisCountList: TList<TDiscount> read FDisCountList write FDisCountList;
    property PayList: TList<TPayData> read FPayList write FPayList;
    property MainItemList: TList<TTeeBoxInfo> read FMainItemList write FMainItemList;

    property CheckInList: TList<TCheckInInfo> read FCheckInList write FCheckInList;

    property AdvertListUp: TList<TAdvertisement> read FAdvertListUp write FAdvertListUp;
    property AdvertListTeeboxUp: TList<TAdvertisement> read FAdvertListTeeboxUp write FAdvertListTeeboxUp;
    property AdvertListDown: TList<TAdvertisement> read FAdvertListDown write FAdvertListDown;
    property AdvertListPopupMember: TList<TAdvertisement> read FAdvertListPopupMember write FAdvertListPopupMember;
    property AdvertListPopupMemberIdx: Integer read FAdvertListPopupMemberIdx write FAdvertListPopupMemberIdx;
    property AdvertListComplex: TList<TAdvertisement> read FAdvertListComplex write FAdvertListComplex;
    property AdvertListEvent: TList<TAdvertisement> read FAdvertListEvent write FAdvertListEvent;
    property AdvertListReceipt: TList<TAdvertisement> read FAdvertListReceipt write FAdvertListReceipt;
    property AdvertListReceiptIdx: Integer read FAdvertListReceiptIdx write FAdvertListReceiptIdx;

    property ParkingProductList: TList<TProductInfo> read FParkingProductList write FParkingProductList;

    property AgreementList1: TList<TAgreement> read FAgreementList1 write FAgreementList1; //약관
    property AgreementList2: TList<TAgreement> read FAgreementList2 write FAgreementList2; //약관
    property AgreementList3: TList<TAgreement> read FAgreementList3 write FAgreementList3; //약관

    property PopUpLevel: TPopUpLevel read FPopUpLevel write FPopUpLevel;
    property PopUpFullLevel: TPopUpFullLevel read FPopUpFullLevel write FPopUpFullLevel;

    property Print: TReceiptPrint read FPrint write FPrint;

    property VanModule: TVanDeamonModul read FVanModule write FVanModule;
    property PaycoModule: TPaycoNewModul read FPaycoModule write FPaycoModule;
    //property BioMiniPlus2: TBioMiniPlus2 read FBioMiniPlus2 write FBioMiniPlus2;

    //2020-12-09 이선우이사님 버전
    //property Nitgen: TNitgen read FNitgen write FNitgen;
    property NBioBSPHelper: TNBioBSPHelper read FNBioBSPHelper write FNBioBSPHelper;

    //chy union
    property UCBioBSPHelper: TUCBioBSPHelper read FUCBioBSPHelper write FUCBioBSPHelper;

    property TotalAmt: Currency read FTotalAmt write FTotalAmt;
    property VatAmt: Currency read FVatAmt write FVatAmt;
    property DCAmt: Currency read FDCAmt write FDCAmt;
    property RealAmt: Currency read FRealAmt write FRealAmt;
    property XGolfDCAmt: Currency read FXGolfDCAmt write FXGolfDCAmt;

    property TeeBoxSortType: TTeeBoxSortType read FTeeBoxSortType write FTeeBoxSortType;
    property SelectTime: TDateTime read FSelectTime write FSelectTime;
    property SelectHalbu: Integer read FSelectHalbu write FSelectHalbu;

    property IsComplete: Boolean read FIsComplete write FIsComplete;
    property VipDisCount: Boolean read FVipDisCount write FVipDisCount;
    property PrepareMin: Integer read FPrepareMin write FPrepareMin;
    property VipTeeBox: Boolean read FVipTeeBox write FVipTeeBox;
    property SaleUploadFail: Boolean read FSaleUpload write FSaleUpload;
    property AllTeeBoxShow: Boolean read FAllTeeBoxShow write FAllTeeBoxShow;
    property MainItemMapUse: Boolean read FMainItemMapUse write FMainItemMapUse;
    property MiniMapCursor: Boolean read FMiniMapCursor write FMiniMapCursor;

    //임시주석
    //property MasterDownThread: TMasterDownThread read FMasterDownThread write FMasterDownThread;

    property SoundThread: TSoundThread read FSoundThread write FSoundThread;
    property TeeboxTimeError: Boolean read FTeeboxTimeError write FTeeboxTimeError;
    property CardApplyType: TCardApplyType read FCardApplyType write FCardApplyType;
    property PromotionType: TPromotionType read FPromotionType write FPromotionType;
    property allianceCode: string read FallianceCode write FallianceCode;  //영수증 출력기준
    property allianceNumber: string read FallianceNumber write FallianceNumber;
    property CouponMember: Boolean read FCouponMember write FCouponMember;

    property AdvertPopupType: TAdvertPopupType read FAdvertPopupType write FAdvertPopupType;

  end;

var
  SaleModule: TSaleModule;

implementation

uses
  uGlobal, uCommon, uFunction, fx.Logging, System.StrUtils;

{ TSaleModule }

function TSaleModule.AddProduct(AProduct: TProductInfo): Boolean;
var
  Index: Integer;
  IsAdd: Boolean;
  ASaleData: TSaleData;
  ADiscount: TDiscount;
begin
  try
    Log.D('AddProduct', AProduct.Code + '-' + AProduct.Name + '-' + AProduct.One_Use_Time);
    Result := False;
    IsAdd := False;

    if (BuyProductList.Count > 0) then
    begin

      if (memberItemType = mitAlliance) then
      begin
        Global.SBMessage.ShowMessageModalForm('타석 구매는 1개만 가능 합니다.');
      end
      else if ((memberItemType = mitperiod) or (memberItemType = mitCoupon) or (memberItemType = mitNew)) then
      begin
        Global.SBMessage.ShowMessageModalForm('회원권 구매는 1개만 가능 합니다.');
      end
      else //if (memberItemType = mitDay) or (memberItemType = mitGamePay) then
      begin
        Global.SBMessage.ShowMessageModalForm(MSG_DAY_PRODUCT_ONE);
      end;

      Exit;
      Result := True;
    end;

    if Global.Config.AD.USE = True then
    begin
      if StoreCloseTmCheck(AProduct) = True then
      begin
        Exit;
      end;
    end;

    for Index := 0 to BuyProductList.Count - 1 do
    begin
      if BuyProductList[Index].Products.Code = AProduct.Code then
      begin
        ASaleData := BuyProductList[Index];
        ASaleData.SaleQty := ASaleData.SaleQty + 1;
        if Global.SaleModule.Member.XGolfMember and ASaleData.Products.xgolf_dc_yn then
          ASaleData.DcAmt := ASaleData.SaleQty * (ASaleData.Products.Price - ASaleData.Products.xgolf_product_amt)
        else
          ASaleData.DcAmt := 0;   // 할인 계산

        ASaleData.SalePrice := ASaleData.SaleQty * ASaleData.Products.Price;
        BuyProductList[Index] := ASaleData;
        IsAdd := True;
      end;
    end;

    if not IsAdd then
    begin
      ADiscount.ApplyAmt := 0;
      ASaleData.Products := AProduct;
      ASaleData.SaleQty := 1;
      ASaleData.SalePrice := ASaleData.Products.Price;
      if Global.SaleModule.Member.XGolfMember and ASaleData.Products.xgolf_dc_yn then
      begin
        ASaleData.DcAmt := ASaleData.Products.Price - ASaleData.Products.xgolf_product_amt;
        ADiscount.Name := 'XGOLF 할인';
        ADiscount.ApplyAmt := Trunc(ASaleData.DcAmt);
        ADiscount.Gubun := 999;
      end
      else
      begin
        ASaleData.DcAmt := 0;
      end;
      ASaleData.DiscountGubun := 0;
      ASaleData.Discount_Percent := 0;
      ASaleData.Discount_Not_Percent := 0;
      ASaleData.DiscountList := TList<TDiscount>.Create;
      if ADiscount.ApplyAmt <> 0 then
        ASaleData.DiscountList.Add(ADiscount);

      BuyProductList.Add(ASaleData);
    end;
    Result := True;
  finally
    Calc;
  end;
end;

function TSaleModule.MinusProduct(AProduct: TProductInfo): Boolean;
var
  Index: Integer;
  IsAdd: Boolean;
  ASaleData: TSaleData;
begin
  try
    Log.D('MinusProduct', AProduct.Code + '-' + AProduct.Name + '-' + AProduct.One_Use_Time);

    for Index := 0 to BuyProductList.Count - 1 do
    begin
      if BuyProductList[Index].Products.Code = AProduct.Code then
      begin
        ASaleData := BuyProductList[Index];
        ASaleData.SaleQty := ASaleData.SaleQty - 1;
        ASaleData.SalePrice := ASaleData.SaleQty * ASaleData.Products.Price;
        BuyProductList[Index] := ASaleData;
        if BuyProductList[Index].SaleQty = 0 then
        begin
          DeleteProduct(Index);
          Break;
        end;
      end;
    end;
  finally
    Calc;
  end;
end;

function TSaleModule.DeleteProduct(AIndex: Integer): Boolean;
begin
  BuyProductList.Delete(AIndex);
  Calc;
end;

function TSaleModule.DeleteDiscount(AQRCode: string): Boolean;
var
  Index: Integer;
begin
  try
    try
      Result := False;
      for Index := 0 to DisCountList.Count - 1 do
      begin
        if DisCountList[Index].QRCode = AQRCode then
        begin
          DisCountList.Delete(Index);
          Break;
        end;
      end;
      Result := True;
    except
      on E: Exception do
      begin
        Log.E('DeleteDiscount QR : ' + AQRCode, E.Message);
      end;
    end;
  finally
    Calc;
  end;
end;

function TSaleModule.CardDiscountDelete: Boolean;
var
  Index, DeleteIndex: Integer;
begin
  try
    try
      Result := False;
      if DisCountList.Count <> 0 then
      begin
//        for Index := DisCountList.Count - 1 downto 0 do
//        begin
//          if DisCountList[Index].Gubun = 998 then
//          begin
//            Log.E('CardDiscountDelete 998', DisCountList[Index].QRCode);
//            DeleteDiscount(DisCountList[Index].QRCode);
//            break;
//          end;
//        end;

        DeleteIndex := -1;
        for Index := 0 to DisCountList.Count - 1 do
        begin
          if DisCountList[Index].Gubun = 998 then
          begin
            DeleteIndex := Index;
            Log.D('CardDiscountDelete 998', DisCountList[Index].QRCode + ' - Index - ' + IntToStr(Index));
//            DeleteDiscount(DisCountList[Index].QRCode);
//            break;
          end;
        end;

        if DeleteIndex <> -1 then
          DisCountList.Delete(DeleteIndex)
        else
          Log.D('CardDiscountDelete', '카드사 할인 없음.');
      end;
      Result := True;
    except
      on E: Exception do
      begin
        Log.E('CardDiscountDelete', E.Message);
      end;
    end;
  finally
    Calc;
  end;
end;

function TSaleModule.CardDiscountGetCode: string;
var
  Index: Integer;
begin
  try
    try
      Result := EmptyStr;

      for Index := 0 to DisCountList.Count - 1 do
      begin
        if DisCountList[Index].Gubun = 998 then
          Result := DisCountList[Index].QRCode;
      end;
    except
      on E: Exception do
      begin
        Log.E('CardDiscountGetCode', E.Message);
      end;
    end;
  finally

  end;
end;

procedure TSaleModule.BuyListClear;
var
  Index: Integer;
begin
//  TListClear(Global.SaleModule.BuyProductList);
  try
//    Global.SaleModule.BuyProductList.Destroy;
//    Global.SaleModule.BuyProductList.DeleteRange(0, Global.SaleModule.BuyProductList.Count);
    for Index := BuyProductList.Count - 1 downto 0 do
      BuyProductList.Delete(Index);

    BuyProductList.Clear;
    Calc;
  except
    on E: Exception do
      Log.E('BuyListClear', E.Message);
  end;
end;

procedure TSaleModule.Calc;
var
  AIndex, Index, Loop, TotalDCAmt, AddDCAmt, AddTotalDCAmt, MaxSalePrice, MaxSalePriceIndex: Integer;
  ASaleData: TSaleData;
  ADiscount: TDiscount;
  ASetPercent: Currency;
  APayCard: TPayCard;
  APayPayco: TPayPayco;
begin
  TotalAmt := 0;
  VatAmt := 0;
  DCAmt := 0;
  RealAmt := 0;
  XGolfDCAmt := 0;

  TotalDCAmt := 0;
  AddDCAmt := 0;
  AddTotalDCAmt := 0;

  for Index := 0 to DisCountList.Count - 1 do
  begin
    ADiscount := DisCountList[Index];
    ADiscount.Add := False;
    ADiscount.Sort := False;
    ADiscount.ApplyAmt := 0;
    DisCountList[Index] := ADiscount;
  end;

  for Index := 0 to PayList.Count - 1 do
  begin
    if PayList[Index].PayType = ptCard then
    begin
      APayCard := TPayCard(PayList[Index]);
      APayCard.CardDiscount := 0;
      PayList[Index] := APayCard;
    end;
  end;

  if BuyProductList.Count = 0 then
    Exit;

  ADiscount.Name := '';
  ADiscount.ApplyAmt := 0;
  ADiscount.Gubun := 0;

  for Index := 0 to BuyProductList.Count - 1 do
  begin
    ASaleData := BuyProductList[Index];
    ASaleData.DiscountGubun := 0;
    if Global.SaleModule.Member.XGolfMember and ASaleData.Products.xgolf_dc_yn then
    begin
      ASaleData.DcAmt := ASaleData.SaleQty * (ASaleData.Products.Price - ASaleData.Products.xgolf_product_amt);
      XGolfDCAmt := XGolfDCAmt + ASaleData.DcAmt;
      ADiscount.Name := 'XGOLF 할인';
      ADiscount.ApplyAmt := Trunc(ASaleData.DcAmt);
      ADiscount.Gubun := 999;
    end
    else
      ASaleData.DcAmt := 0;

    ASaleData.Discount_Percent := 0;
    ASaleData.Discount_Not_Percent := 0;
    ASaleData.DiscountList.Free;
    ASaleData.DiscountList := TList<TDiscount>.Create;
    if ADiscount.Gubun = 999 then
      ASaleData.DiscountList.Add(ADiscount);

    BuyProductList[Index] := ASaleData;

    TotalAmt := TotalAmt + BuyProductList[Index].SalePrice;
  end;

  SetDiscount_Item_ver2; //할인
  AddTotalDCAmt := 0;

  for Index := 0 to BuyProductList.Count - 1 do
    AddTotalDCAmt := AddTotalDCAmt + Trunc(BuyProductList[Index].DcAmt);

  for Index := 0 to DisCountList.Count - 1 do
  begin
    if DisCountList[Index].Gubun = 998 then
    begin
      ADiscount := DisCountList[Index];
      ADiscount.ApplyAmt := ADiscount.Value;
      // 적용된 금액
      AddDCAmt := ADiscount.ApplyAmt;
      DisCountList[Index] := ADiscount;
    end;
  end;

  DCAmt := AddTotalDCAmt + AddDCAmt;
  RealAmt := TotalAmt - DCAmt;
  VatAmt := RealAmt - Trunc(RealAmt / 1.1);
end;

function TSaleModule.AddCheckPromotionType(ACode: string): Boolean;
var
  Index: Integer;
begin
  try
    Result := False;

    if ACode = '1' then
    begin
      if DisCountList.Count <> 0 then
      begin
        for Index := 0 to DisCountList.Count - 1 do
          if DisCountList[Index].dc_cond_div = '2' then
            Result := True;
      end;
    end
    else if ACode = '2' then
      Result := DisCountList.Count <> 0;

    if Result then
      Global.SBMessage.ShowMessageModalForm(MSG_PROMOTION + MSG_PROMOTION_OPTION_4);

  finally

  end;
end;

function TSaleModule.AddCheckDiscount(AProductDiv, AProductDivDetail: string; AGubun: Integer): Boolean;
var
  Index: Integer;
begin
  try
    try
      Result := False;
      for Index := 0 to BuyProductList.Count - 1 do
      begin
        if (AProductDiv = 'A') or (AProductDivDetail = 'A') then
        begin

        end
        else if AProductDivDetail <> BuyProductList[Index].Products.Product_Div then
          Continue;

        if AGubun = 1 then
        begin
          if (BuyProductList[Index].Discount_Percent + 1) <= BuyProductList[Index].SaleQty then
            Result := True;
        end
        else
        begin
          if (BuyProductList[Index].Discount_Not_Percent + 1) <= BuyProductList[Index].SaleQty then
            Result := True;
        end;
      end;
    except
      on E: Exception do
        Log.E('AddCheckDiscount', E.Message);
    end;
  finally
  end;
end;

function TSaleModule.AddChectDiscountAmt(AValue: Integer): Boolean;
var
  Index, ASumDCAmt: Integer;
begin
  try
    try
      Result := False;
      ASumDCAmt := 0;
      for Index := 0 to BuyProductList.Count - 1 do
        ASumDCAmt := ASumDCAmt + Trunc(BuyProductList[Index].DcAmt);

      if TotalAmt >= (ASumDCAmt + AValue) then
        Result := True;
    except
      on E: Exception do
        Log.E('AddChectDiscountAmt', E.Message);
    end;
  finally

  end;
end;

function TSaleModule.AddCheckDiscountQR(AQRCode: string): Boolean;
var
  Index: Integer;
begin
  try
    Result := False;
    for Index := 0 to DisCountList.Count - 1 do
    begin
      if DisCountList[Index].QRCode = AQRCode then
        Result := True;
    end;
  finally

  end;
end;

//function TSaleModule.AddCheckDiscountProductDiv(ACode: string): Boolean;
function TSaleModule.AddCheckDiscountProductDiv(AProductDiv, AProductDivDetail, AProductDivCd: string): Boolean;
begin
  {
  try
    Result := False;
    for Index := 0 to BuyProductList.Count - 1 do
    begin
      if (BuyProductList[Index].DcAmt = 0) and (BuyProductList[Index].Products.Product_Div = ACode) then
        Result := True;
    end;
  finally

  end;
  }
  Result := False;

  if (AProductDiv <> 'A') and (AProductDiv <> 'S') then
    Exit;

  if (AProductDivDetail = 'A') then
  begin
    Result := True;
    Exit;
  end;

  if BuyProductList[0].Products.Product_Div <> AProductDivDetail then
    Exit;

  if AProductDivCd <> '' then
  begin
    if BuyProductList[0].Products.Code <> AProductDivCd then
      Exit;
  end;

  Result := True;
end;

function TSaleModule.SetDiscount: Boolean;
var
  Index, ADCAmt: Integer;
  ADiscount: TDiscount;
  ASaleData: TSaleData;
begin
  try
    ADCAmt := 0;
    for Index := 0 to DisCountList.Count - 1 do
    begin
      ADiscount := DisCountList[Index];
      if ADiscount.Gubun = 1 then
        ADiscount.ApplyAmt := Trunc((TotalAmt * ADiscount.Value) * 0.01)
      else
        ADiscount.ApplyAmt := ADiscount.Value;
        
      DisCountList[Index] := ADiscount;

      ADCAmt := ADCAmt + DisCountList[Index].ApplyAmt;
    end;     

    // 할인금액 0으로 초기화
    for Index := 0 to BuyProductList.Count - 1 do
    begin
      ASaleData := BuyProductList[Index];
      ASaleData.DcAmt := 0;
      BuyProductList[Index] := ASaleData;    
    end;

    // 할인 적용
    for Index := 0 to BuyProductList.Count - 1 do
    begin
      if ADCAmt = 0 then
        Continue;
      
      ASaleData := BuyProductList[Index];

      if (ASaleData.SalePrice - ADCAmt) < 0 then
      begin
        ASaleData.DcAmt := Trunc(ASaleData.SalePrice);
        ADCAmt :=  ADCAmt - Trunc(ASaleData.SalePrice);
      end
      else
      begin      
        ASaleData.DcAmt := ADCAmt;
        ADCAmt := 0;      
      end;     

      BuyProductList[Index] := ASaleData;
    end;
  finally

  end;
end;

function TSaleModule.SetDiscount_Item: Boolean;
var
  Index, AIndex, Loop, MaxSalePrice, MaxSalePriceIndex: Integer;
  DiscountAmt, SaleDcAmt, AddDcAmt: Currency;
  ASaleData: TSaleData;
  ADiscount: TDiscount;
  function SortDiscountType: TList<TDiscount>;
  var
    SortIndex, ASortIndex, AValue: Integer;
    AValueList: TList<Integer>;
    ASortDiscount: TDiscount;
  begin
    try
      Result := TList<TDiscount>.Create;
      AValueList := TList<Integer>.Create;

      for SortIndex := 0 to DisCountList.Count - 1 do
      begin
        if DisCountList[SortIndex].Gubun = 1 then
          AValueList.Add(DisCountList[SortIndex].Value);
      end;

      AValueList.Sort;

      for SortIndex := AValueList.Count - 1 downto 0 do
      begin
        for ASortIndex := 0 to DisCountList.Count - 1 do
        begin
          if (DisCountList[ASortIndex].Gubun = 1) and (not DisCountList[ASortIndex].Sort) then
          begin
            AValue := AValueList[SortIndex];
            if DisCountList[ASortIndex].Value = AValueList[SortIndex] then
            begin
              ASortDiscount := DisCountList[ASortIndex];
              ASortDiscount.Sort := True;
              DisCountList[ASortIndex] := ASortDiscount;
              Result.Add(DisCountList[ASortIndex]);
            end;
          end;
        end;
      end;

      for SortIndex := 0 to DisCountList.Count - 1 do
      begin
        if not DisCountList[SortIndex].Sort then
          Result.Add(DisCountList[SortIndex]);
      end;
    finally
//      TListClear(AValueList);
      AValueList.Free;
    end;
  end;
begin
  try
    Result := False;
    // 할인 단위를 정렬
    DisCountList := SortDiscountType;

    for AIndex := 0 to 2 - 1 do
    begin
      if AIndex = 0 then
      begin
        for Index := 0 to DisCountList.Count - 1 do
        begin
          ADiscount := DisCountList[Index];
          if ADiscount.Gubun = 1 then
          begin
            if not ADiscount.Add then
            begin
              MaxSalePrice := -1;
              MaxSalePriceIndex := -1;
              for Loop := 0 to BuyProductList.Count - 1 do
              begin
                if BuyProductList[Loop].SaleQty >= (BuyProductList[Loop].Discount_Percent + 1) then
                begin
                  if (ADiscount.Product_Div_Detail = BuyProductList[Loop].Products.Product_Div) or
                    (ADiscount.Product_Div = 'A') or (ADiscount.Product_Div = 'S') then
                  begin
                    if MaxSalePrice < (BuyProductList[Loop].SalePrice / BuyProductList[Loop].SaleQty) then
                    begin
                      MaxSalePrice := Trunc(BuyProductList[Loop].SalePrice / BuyProductList[Loop].SaleQty);
                      MaxSalePriceIndex := Loop;
                    end;
                  end;
                end;
              end;

              if MaxSalePriceIndex <> -1 then
              begin
                ASaleData := BuyProductList[MaxSalePriceIndex];
                if ASaleData.SaleQty >= (ASaleData.Discount_Percent + 1) then
                begin
                  if Global.SaleModule.Member.XGolfMember and ASaleData.Products.xgolf_dc_yn then
                    ASaleData.DcAmt := ASaleData.DcAmt + (((ASaleData.SalePrice / ASaleData.SaleQty) - ASaleData.Products.xgolf_dc_amt) * ADiscount.Value) * 0.01
                  else
                    ASaleData.DcAmt := ASaleData.DcAmt + ((ASaleData.SalePrice / ASaleData.SaleQty) * ADiscount.Value) * 0.01;

  //                BuyProductList[MaxSalePriceIndex] := ASaleData;

                  if Global.SaleModule.Member.XGolfMember and ASaleData.Products.xgolf_dc_yn then
                    ADiscount.ApplyAmt := Trunc((((ASaleData.SalePrice / ASaleData.SaleQty) - ASaleData.Products.xgolf_dc_amt) * ADiscount.Value) * 0.01)
                  else
                    ADiscount.ApplyAmt := Trunc(((ASaleData.SalePrice / ASaleData.SaleQty) * ADiscount.Value) * 0.01);
                  ADiscount.Add := True;
                  ASaleData.Discount_Percent := ASaleData.Discount_Percent + 1;
                  if ADiscount.ApplyAmt <> 0 then
                    ASaleData.DiscountList.Add(ADiscount);
  //                AddTotalDCAmt := AddTotalDCAmt + Trunc(((ASaleData.SalePrice / ASaleData.SaleQty) * ADiscount.Value) * 0.01);
                  BuyProductList[MaxSalePriceIndex] := ASaleData;
                  DisCountList[Index] := ADiscount;
                end
                else
                begin
                  MaxSalePrice := -1;
                  MaxSalePriceIndex := -1;
                end;
              end;
            end;
          end;
        end;
      end
      else if ADiscount.Gubun <> 999 then
      begin
//        for Index := 0 to DisCountList.Count - 1 do
//        begin
//          ADiscount := DisCountList[Index];
//          if (ADiscount.Gubun <> 1) and (not ADiscount.Add) then
//          begin
//            if not ADiscount.Add then
//            begin
//              // 1. 금액 비교해서 넣어준다.
//              for Loop := 0 to BuyProductList.Count - 1 do
//              begin
//                if ADiscount.Add then
//                  Continue;
//
//                ASaleData := BuyProductList[Loop];
//                if ASaleData.SaleQty >= (ASaleData.Discount_Not_Percent + 1) then
//                begin
//                  if ASaleData.Products.Product_Div = ADiscount.Product_Div_Detail then
//                  begin
//                    if ASaleData.SalePrice >= ASaleData.DcAmt + ADiscount.Value then
//                    begin
//                      ASaleData.DcAmt := ASaleData.DcAmt + ADiscount.Value;
//                      ASaleData.Discount_Not_Percent := ASaleData.Discount_Not_Percent + 1;
//                      ADiscount.Add := True;
//  //                    AddTotalDCAmt := AddTotalDCAmt + ADiscount.Value;
//                      BuyProductList[Loop] := ASaleData;
//                      DisCountList[Index] := ADiscount;
//                    end;
//                  end;
//                end;
//              end;
//
//              // 2. 1번에서 추가가 안되었을때
//              if not ADiscount.Add then
//              begin
//                MaxSalePrice := -1;
//                MaxSalePriceIndex := -1;
//                for Loop := 0 to BuyProductList.Count - 1 do
//                begin
//                  ASaleData := BuyProductList[Loop];
//                  if ASaleData.SaleQty >= (ASaleData.Discount_Not_Percent + 1) then
//                  begin
//                    if ASaleData.Products.Product_Div = ADiscount.Product_Div_Detail then
//                    begin
//                      if MaxSalePrice < ADiscount.Value - (ASaleData.SalePrice - ASaleData.DcAmt) then
//                      begin
//                        MaxSalePrice := ADiscount.Value - Trunc(ASaleData.SalePrice - ASaleData.DcAmt);
//                        MaxSalePriceIndex := Loop;
//                      end;
//                    end;
//                  end;
//                end;
//
//                if MaxSalePriceIndex <> -1 then
//                begin
//                  ASaleData := BuyProductList[MaxSalePriceIndex];
//                  if ASaleData.SaleQty >= (ASaleData.Discount_Not_Percent + 1) then
//                  begin
//                    if ASaleData.Products.Product_Div = ADiscount.Product_Div_Detail then
//                    begin
//                      ASaleData.DcAmt := ASaleData.DcAmt + MaxSalePrice;
//  //                    AddTotalDCAmt := AddTotalDCAmt + MaxSalePrice;
//                      ASaleData.Discount_Not_Percent := ASaleData.Discount_Not_Percent + 1;
//                      ADiscount.Add := True;
//                      BuyProductList[MaxSalePriceIndex] := ASaleData;
//                      DisCountList[Index] := ADiscount;
//                    end;
//                  end;
//                end;
//              end;
//            end;
//          end;
//        end;

        for Index := 0 to DisCountList.Count - 1 do
        begin
          ADiscount := DisCountList[Index];
          if (ADiscount.Gubun <> 1) and (not ADiscount.Add) then
          begin
            DiscountAmt := ADiscount.Value;
            for Loop := 0 to BuyProductList.Count - 1 do
            begin
              if DiscountAmt = 0 then
                Continue;

              AddDcAmt := 0;
              if (BuyProductList[Loop].Products.Product_Div = ADiscount.Product_Div_Detail) or
                (ADiscount.Product_Div = 'A') or (ADiscount.Product_Div = 'S') then
              begin
                ASaleData := BuyProductList[Loop];
                SaleDcAmt := BuyProductList[Loop].SalePrice - BuyProductList[Loop].DCAmt;

                if SaleDcAmt = 0 then
                  Continue;

                // ApplyAmt 확인 필요
                if DiscountAmt <= SaleDcAmt then
                begin
                  ASaleData.DcAmt := ASaleData.DcAmt + DiscountAmt;
                  AddDcAmt := DiscountAmt;
                  ADiscount.ApplyAmt := Trunc(DiscountAmt);
                  DiscountAmt := 0;
//                  ADiscount.ApplyAmt := Trunc(DiscountAmt);
                end
                else
                begin
                  ASaleData.DcAmt := ASaleData.DcAmt + SaleDcAmt;
                  DiscountAmt := DiscountAmt - SaleDcAmt;
//                  ADiscount.ApplyAmt := Trunc(DiscountAmt - SaleDcAmt);
                  ADiscount.ApplyAmt := Trunc(SaleDcAmt);
//                  AddDcAmt := SaleDcAmt;
                end;
                if ADiscount.ApplyAmt <> 0 then
                  ASaleData.DiscountList.Add(ADiscount);
                BuyProductList[Loop] := ASaleData;
              end;
            end;
          end;
          if ADiscount.Value <> DiscountAmt then
          begin
            ADiscount.Add := True;
            DisCountList[Index] := ADiscount;
          end;
        end;

      end;
    end;
    Result := True;
  except
    on E: Exception do
    begin

    end;
  end;
end;

function TSaleModule.SetDiscount_Item_ver2: Boolean;
var
  Index, AIndex, Loop, DiscountIndex, MaxSalePrice, MaxSalePriceIndex: Integer;
  DiscountAmt, SaleDcAmt, AddDcAmt: Currency;
  ASaleData: TSaleData;
  ADiscount: TDiscount;
  function SortDiscountType: TList<TDiscount>;
  var
    SortIndex, ASortIndex, AValue: Integer;
    AValueList: TList<Integer>;
    ASortDiscount: TDiscount;
  begin
    try
      Result := TList<TDiscount>.Create;
      AValueList := TList<Integer>.Create;

      for SortIndex := 0 to DisCountList.Count - 1 do
      begin
        if DisCountList[SortIndex].Gubun = 1 then
          AValueList.Add(DisCountList[SortIndex].Value);
      end;

      AValueList.Sort;

      for SortIndex := AValueList.Count - 1 downto 0 do
      begin
        for ASortIndex := 0 to DisCountList.Count - 1 do
        begin
          if (DisCountList[ASortIndex].Gubun = 1) and (not DisCountList[ASortIndex].Sort) then
          begin
            AValue := AValueList[SortIndex];
            if DisCountList[ASortIndex].Value = AValueList[SortIndex] then
            begin
              ASortDiscount := DisCountList[ASortIndex];
              ASortDiscount.Sort := True;
              DisCountList[ASortIndex] := ASortDiscount;
              Result.Add(DisCountList[ASortIndex]);
            end;
          end;
        end;
      end;

      for SortIndex := 0 to DisCountList.Count - 1 do
      begin
        if not DisCountList[SortIndex].Sort then
          Result.Add(DisCountList[SortIndex]);
      end;
    finally
//      TListClear(AValueList);
      AValueList.Free;
    end;
  end;
begin
  try
    Result := False;
    DiscountIndex := -1;
    // 할인 단위를 정렬
    DisCountList := SortDiscountType;

    for AIndex := 0 to 2 - 1 do
    begin
      if AIndex = 0 then
      begin // fmx익스프레스
        for Index := 0 to DisCountList.Count - 1 do
        begin
          ADiscount := DisCountList[Index];
          if ADiscount.Gubun = 1 then
          begin
            AddDcAmt := 0;
            if not ADiscount.Add then
            begin
              MaxSalePrice := -1;
              MaxSalePriceIndex := -1;
              if DiscountIndex = -1 then
              begin
                for Loop := 0 to BuyProductList.Count - 1 do
                begin
                  if ((ADiscount.Product_Div = 'A') or (ADiscount.Product_Div = 'S')) and
                     ((ADiscount.Product_Div_Detail = 'A') or (ADiscount.Product_Div_Detail = BuyProductList[Loop].Products.Product_Div)) then
                  begin
                    if MaxSalePrice < (BuyProductList[Loop].SalePrice / BuyProductList[Loop].SaleQty) then
                    begin
                      MaxSalePrice := Trunc(BuyProductList[Loop].SalePrice / BuyProductList[Loop].SaleQty);
                      MaxSalePriceIndex := Loop;
                      DiscountIndex := Loop;
                    end;
                  end;
                end;
              end
              else
                MaxSalePriceIndex := DiscountIndex;

              if MaxSalePriceIndex <> -1 then
              begin
                ASaleData := BuyProductList[MaxSalePriceIndex];

                if Global.SaleModule.Member.XGolfMember and ASaleData.Products.xgolf_dc_yn then
                begin
                  if (((ASaleData.SalePrice / ASaleData.SaleQty) - ASaleData.Products.xgolf_dc_amt) -
                    (ASaleData.DcAmt - (ASaleData.Products.xgolf_dc_amt * ASaleData.SaleQty))) = 0 then
                    Continue;
                end
                else
                begin
                  if ((ASaleData.SalePrice / ASaleData.SaleQty) - ASaleData.DcAmt) = 0 then
                    Continue;
                end;

                if Global.SaleModule.Member.XGolfMember and ASaleData.Products.xgolf_dc_yn then
                begin
                  AddDcAmt := (((ASaleData.SalePrice / ASaleData.SaleQty) - ASaleData.Products.xgolf_dc_amt) * ADiscount.Value) * 0.01;
                  if ((ASaleData.SalePrice / ASaleData.SaleQty) - ASaleData.Products.xgolf_dc_amt) - ((ASaleData.DcAmt - (ASaleData.Products.xgolf_dc_amt * ASaleData.SaleQty)) + AddDcAmt) < 0 then
                    ADiscount.ApplyAmt := Trunc(((ASaleData.SalePrice / ASaleData.SaleQty) - ASaleData.Products.xgolf_dc_amt) - (ASaleData.DcAmt  - (ASaleData.Products.xgolf_dc_amt * ASaleData.SaleQty)))
                  else
                    ADiscount.ApplyAmt := Trunc(AddDcAmt);

                  ASaleData.DcAmt := ASaleData.DcAmt + AddDcAmt;
                end
                else
                begin     
                  AddDcAmt := ((ASaleData.SalePrice / ASaleData.SaleQty) * ADiscount.Value) * 0.01;
                  if (ASaleData.SalePrice / ASaleData.SaleQty) - (ASaleData.DcAmt + AddDcAmt) < 0 then
                    ADiscount.ApplyAmt := Trunc((ASaleData.SalePrice / ASaleData.SaleQty) - ASaleData.DcAmt)
                  else
                    ADiscount.ApplyAmt := Trunc(AddDcAmt);

                  ASaleData.DcAmt := ASaleData.DcAmt + AddDcAmt;
//                  ASaleData.DcAmt := ASaleData.DcAmt + ((ASaleData.SalePrice / ASaleData.SaleQty) * ADiscount.Value) * 0.01;
                end;

//                if Global.SaleModule.Member.XGolfMember and ASaleData.Products.xgolf_dc_yn then
//                  ADiscount.ApplyAmt := Trunc((((ASaleData.SalePrice / ASaleData.SaleQty) - ASaleData.Products.xgolf_dc_amt) * ADiscount.Value) * 0.01)
//                else
//                  ADiscount.ApplyAmt := Trunc(((ASaleData.SalePrice / ASaleData.SaleQty) * ADiscount.Value) * 0.01);
                ADiscount.Add := True;
//                ASaleData.Discount_Percent := ASaleData.Discount_Percent + 1;

                if (ADiscount.ApplyAmt <> 0) and (ADiscount.ApplyAmt > 0) then
                  ASaleData.DiscountList.Add(ADiscount);
//                AddTotalDCAmt := AddTotalDCAmt + Trunc(((ASaleData.SalePrice / ASaleData.SaleQty) * ADiscount.Value) * 0.01);
                BuyProductList[MaxSalePriceIndex] := ASaleData;
                DisCountList[Index] := ADiscount;
              end;
            end;
          end;
        end;
      end
      else
      begin // 999: XGOLF, 998: 카드사
        if (ADiscount.Gubun = 999) or (ADiscount.Gubun = 998) then
          Continue;

        for Index := 0 to DisCountList.Count - 1 do
        begin
          ADiscount := DisCountList[Index];
          if (ADiscount.Gubun <> 1) and (not ADiscount.Add) then
          begin
            DiscountAmt := ADiscount.Value;
            for Loop := 0 to BuyProductList.Count - 1 do
            begin
              if DiscountAmt = 0 then
                Continue;

              AddDcAmt := 0;

              if ((ADiscount.Product_Div = 'A') or (ADiscount.Product_Div = 'S')) and
                 ((ADiscount.Product_Div_Detail = 'A') or (ADiscount.Product_Div_Detail = BuyProductList[Loop].Products.Product_Div)) then
              begin
                ASaleData := BuyProductList[Loop];
                SaleDcAmt := BuyProductList[Loop].SalePrice - BuyProductList[Loop].DCAmt;

                if SaleDcAmt = 0 then
                  Continue;

                // ApplyAmt 확인 필요
                if DiscountAmt <= SaleDcAmt then
                begin
                  ASaleData.DcAmt := ASaleData.DcAmt + DiscountAmt;
                  AddDcAmt := DiscountAmt;
                  ADiscount.ApplyAmt := Trunc(DiscountAmt);
                  DiscountAmt := 0;
                end
                else
                begin
                  ASaleData.DcAmt := ASaleData.DcAmt + SaleDcAmt;
                  DiscountAmt := DiscountAmt - SaleDcAmt;
                  ADiscount.ApplyAmt := Trunc(SaleDcAmt);
                end;
                if ADiscount.ApplyAmt <> 0 then
                  ASaleData.DiscountList.Add(ADiscount);
                BuyProductList[Loop] := ASaleData;
              end;
            end;
          end;
          if ADiscount.Value <> DiscountAmt then
          begin
            ADiscount.Add := True;
            DisCountList[Index] := ADiscount;
          end;
        end;
      end;
    end;
    Result := True;
  except
    on E: Exception do
    begin

    end;
  end;
end;

function TSaleModule.CallAdmin: Boolean;
var
  Indy: TIdTCPClient;
  Msg, sBuffer: string;
  JO: TJSONObject;
begin
  (*
  try
    try
      Result := False;

      Indy := TIdTCPClient.Create(nil);
      Indy.Host := Global.Config.MainPosIP;
      Indy.Port := 60001;
      Indy.ConnectTimeout := 2000;
      Indy.Connect;
      Indy.IOHandler.Writeln('KIOSK', IndyTextEncoding_UTF8);
      Msg := Indy.IOHandler.ReadLn(IndyTextEncoding_UTF8);

      //chy sewoo
      //Global.SBMessage.ShowMessageModalForm(MSG_ADMIN_CALL);
      Global.SBMessage.ShowMessageModalForm2(MSG_PRINT_ADMIN_CALL, True, 30, True, True);

      Result := Indy.Connected;
    except
      on E: Exception do
      begin
        //chy 프린터상태 체크-pos연결상태 확인->보류
        Global.SBMessage.ShowMessageModalForm(MSG_ADMIN_CALL_FAIL);
        //Global.SBMessage.ShowMessageModalForm2(MSG_ADMIN_CALL_FAIL, True, 30, True, True);
        Log.E('CallAdmin', E.Message);
      end;
    end;
  finally
    Indy.Free;
  end;
  *)
  Result := False;
  JO := TJSONObject.Create;
  with TIdTCPClient.Create(nil) do
  try
    try
      JO.AddPair(TJSONPair.Create('error_cd', '6001'));
      JO.AddPair(TJSONPair.Create('sender_id', Global.Config.Store.UserID));
      JO.AddPair(TJSONPair.Create('error_msg', 'KIOSK 영수증 프린터의 용지가 부족합니다!'));
      sBuffer := JO.ToString;

      Host := Global.Config.MainPosIP;
      //Port := 6001;
      Port := Global.Config.MainPosPort;
      ConnectTimeout := 2000;
      ReadTimeout := 2000;
      Connect;
      IOHandler.Writeln(sBuffer, IndyTextEncoding_UTF8);

      Global.SBMessage.ShowMessageModalForm2(MSG_PRINT_ADMIN_CALL, True, 30, True, True);

      Result := Connected;
    except
      on e: Exception do
      begin
        Global.SBMessage.ShowMessageModalForm(MSG_ADMIN_CALL_FAIL);
        Log.E('CallAdmin', E.Message);
      end;
    end

  finally
    Disconnect;
    Free;
    FreeAndNilJSONObject(JO);
  end;

end;

function TSaleModule.CallAdminTest: Boolean;
var
  Indy: TIdTCPClient;
  Msg, sBuffer: string;
  JO: TJSONObject;
begin

  Result := False;
  JO := TJSONObject.Create;
  with TIdTCPClient.Create(nil) do
  try
    try
      JO.AddPair(TJSONPair.Create('error_cd', '6001'));
      JO.AddPair(TJSONPair.Create('sender_id', Global.Config.Store.UserID));
      JO.AddPair(TJSONPair.Create('error_msg', 'KIOSK 알리미 호출 테스트 입니다!'));
      sBuffer := JO.ToString;

      Host := Global.Config.MainPosIP;
      //Port := 6001;
      Port := Global.Config.MainPosPort;
      ConnectTimeout := 2000;
      ReadTimeout := 2000;
      Connect;
      IOHandler.Writeln(sBuffer, IndyTextEncoding_UTF8);

      Global.SBMessage.ShowMessageModalForm2('KIOSK 알리미 호출 테스트 입니다!', True, 30, True, True);

      Result := Connected;
    except
      on e: Exception do
      begin
        Global.SBMessage.ShowMessageModalForm(MSG_ADMIN_CALL_FAIL + '(' + Global.Config.MainPosIP + ')');
        //Log.E('CallAdmin', E.Message);
      end;
    end

  finally
    Disconnect;
    Free;
    FreeAndNilJSONObject(JO);
  end;

end;

function TSaleModule.CallIntroBlack: Boolean;
var
  Indy: TIdTCPClient;
  Msg: string;
begin
  try
    try
      Result := False;
      Indy := TIdTCPClient.Create(nil);
      Indy.Host := '127.0.0.1';
      Indy.Port := 60001;
      Indy.ConnectTimeout := 2000;
      Indy.Connect;
      Indy.IOHandler.Writeln('INTRO', IndyTextEncoding_UTF8);
      Msg := Indy.IOHandler.ReadLn(IndyTextEncoding_UTF8);
//      Global.SBMessage.ShowMessageModalForm(MSG_ADMIN_CALL);
//      Result := Indy.Connected;
    except
      on E: Exception do
        Global.SBMessage.ShowMessageModalForm(MSG_ADMIN_CALL_FAIL);
    end;
  finally
    Indy.Free;
  end;
end;

function TSaleModule.CallCardInfo: string;
var
  ARecvInfo: TCardRecvInfoDM;
  ASendInfo: TCardSendInfoDM;
begin
  Result := EmptyStr;

  ARecvInfo := VanModule.CallCardInfo(ASendInfo);

  if ARecvInfo.Result then
    Result := ARecvInfo.CardBinNo;
end;

function TSaleModule.CallCard(ACardBin, ACode, AMsg: string; ADiscountAmt: Currency; IsAppCard: Boolean): TCardRecvInfoDM;
var
  ACard: TPayCard;
  ARecvInfo: TCardRecvInfoDM;
  ADiscountInfo: TDiscount;
begin
  try
    ACard := TPayCard.Create;

    if CardApplyType = catMagnetic then
      ACard.SendInfo.OTCNo := EmptyStr
    else
      ACard.SendInfo.OTCNo := ACardBin;

    if ACardBin <> EmptyStr then
    begin
      ACard.SendInfo.CardBinNo := Copy(ACardBin, 1, 6);

      //chy bc페이북
      //ADiscountInfo.Name := '신용카드 제휴 할인';
      if Length(ACardBin) >= 30 then
        ADiscountInfo.Name := 'BC카드 제휴 할인'
      else
        //ADiscountInfo.Name := '신한카드 제휴 할인';
        ADiscountInfo.Name := 'NH카드 제휴 할인';

      ADiscountInfo.Gubun := 998;

      if ADiscountAmt <> 0 then
      begin
        Log.D('카드제휴 - 할인적용', ARecvInfo.CardBinNo + FormatFloat('#,##0.##', ADiscountAmt));
        ADiscountInfo.QRCode := ACode;
        ADiscountInfo.Value := Trunc(ADiscountAmt);
        Global.SaleModule.DisCountList.Add(ADiscountInfo);
        Calc;
        ACard.CardDiscount := Trunc(ADiscountAmt);
      end
      else  // 할인 대상 아님
      begin
        Log.D('카드제휴 할인 대상 아님 - 할인금액 0', ACardBin);
        Log.D('카드제휴 할인 대상 아님', ACode);
        Log.D('카드제휴 할인 대상 아님', AMsg);
      end;
    end
    else
    begin
      Log.D('카드제휴 할인 대상 아님', ARecvInfo.CardBinNo);
      Log.D('카드제휴 할인 대상 아님', ACode);
      Log.D('카드제휴 할인 대상 아님', AMsg);
    end;

    Log.D('카드결제 Bin, OTC', ACard.SendInfo.CardBinNo + ':' + ACard.SendInfo.OTCNo);

    ACard.SendInfo.Approval := True;
    ACard.SendInfo.SaleAmt := RealAmt;
    ACard.SendInfo.VatAmt := VatAmt;
    ACard.SendInfo.FreeAmt := 0;
    ACard.SendInfo.SvcAmt := 0;
    ACard.SendInfo.EyCard := False;
    ACard.SendInfo.HalbuMonth := System.Math.IfThen(Global.SaleModule.SelectHalbu = 1, 0, Global.SaleModule.SelectHalbu);
    ACard.SendInfo.BizNo := StringReplace(Global.Config.Store.BizNo, '-', '', [rfReplaceAll]);
    ACard.SendInfo.TerminalID := Global.Config.Store.VanTID;
    ACard.SendInfo.SignOption := 'T';

    //PG 사용일 경우
    if Global.Config.PaymentPG = True then
      ACard.SendInfo.Reserved1 := 'PG';

    Sleep(50);

    {$IFDEF RELEASE}
    if (Global.Config.Store.StoreCode = 'BC001') then //힐스테이트
    begin
      if RealAmt = 0 then
      begin
      ACard.RecvInfo.Result := True;
      ACard.RecvInfo.AgreeNo := '0001';
      end
      else
      ACard.RecvInfo := VanModule.CallCard(ACard.SendInfo);
    end
    else
    begin
      ACard.RecvInfo := VanModule.CallCard(ACard.SendInfo);
    end;
    {$ENDIF}
    {$IFDEF DEBUG}
    ACard.RecvInfo.Result := True;
    ACard.RecvInfo.AgreeNo := '0001';
    {$ENDIF}

    Result := ACard.RecvInfo;
    if Result.Result then
    begin
      PayList.Add(ACard);
    end
    else
    begin
      CardDiscountDelete;
    end;
  except
    on E: Exception do
    begin
      Log.E('TSaleModule.CallCard', E.Message);
    end;
  end;
end;

function TSaleModule.CallPayco: TPaycoNewRecvInfo;
const
  STX = #2;
  ETX = #3;
  FS  = #1;
var
  Index, ASaleQty: Integer;
  APayco: TPayPayco;
  GoodsNm, GoodsList: string;
begin
  try
    APayco := TPayPayco.Create;
    APayco.SendInfo.BizNo := StringReplace(Global.Config.Store.BizNo, '-', '', [rfReplaceAll]);
    APayco.SendInfo.TerminalID := Global.Config.Store.VanTID;
    APayco.SendInfo.SerialNo := Global.Config.Store.VanTID;
    APayco.SendInfo.VanName := GetVanCode;
    APayco.SendInfo.Approval := True;
    APayco.SendInfo.PayAmt := TotalAmt - DCAmt;
    APayco.SendInfo.TaxAmt := VatAmt;
    APayco.SendInfo.DutyAmt := (TotalAmt - DCAmt) - VatAmt;
    APayco.SendInfo.TaxAmt := VatAmt;
    APayco.SendInfo.FreeAmt := 0;
    APayco.SendInfo.TipAmt := 0;
    APayco.SendInfo.PointAmt := 0;
    APayco.SendInfo.CouponAmt := 0;
    APayco.SendInfo.ApprovalAmount := APayCo.SendInfo.PayAmt - APayCo.SendInfo.PointAmt - APayCo.SendInfo.CouponAmt;

    for Index := 0 to BuyProductList.Count - 1 do
    begin
      if Index = 0 then
        GoodsNm := BuyProductList[Index].Products.Name;

      ASaleQty := ASaleQty + Trunc(BuyProductList[Index].SaleQty);
      if Index <> 0 then
        GoodsList := GoodsList + FS;
      GoodsList := GoodsList + BuyProductList[Index].Products.Code + FS +
        BuyProductList[Index].Products.Name + FS + CurrToStr(BuyProductList[Index].Products.Price) + FS + CurrToStr(BuyProductList[Index].SaleQty);
      GoodsList := GoodsList + FS + 'Y';
    end;

    if BuyProductList.Count > 1 then
      GoodsNm := GoodsNm + '외 ' + IntToStr(BuyProductList.Count - 1);

    PaycoModule.GoodsName := GoodsNm;
    PaycoModule.GoodsList := GoodsList;

    APayco.RecvInfo := PaycoModule.ExecPayProc(APayco.SendInfo);

    Result := APayco.RecvInfo;

    if Result.Result then
      PayList.Add(APayCo);
  except
    on E: Exception do
    begin

    end;
  end;
end;

function TSaleModule.GetSumPayAmt(APayType: TPayTyepe): Currency;
var
  Index: Integer;
begin
  Result := 0;
  for Index := 0 to PayList.Count - 1 do
  begin
    if PayList[Index].PayType = ptCard then
      Result := Result + TPayCard(PayList[Index]).PayAmt;
  end;
end;

function TSaleModule.CheckXGolfMember(ACode: string): Boolean;
var
  MainJson: TJSONObject;
  Indy: TIdHTTP;
  sslIOHandler : TIdSSLIOHandlerSocketOpenSSL;
  RecvtData: TStringStream;
  ByteStr: RawByteString;
  JsonText: string;
begin       //jangheejin
  try
    try
      Result := False;

      MainJson := TJSONObject.Create;
      Indy := TIdHTTP.Create(nil);
      sslIOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
      RecvtData := TStringStream.Create;
      Indy.Request.CustomHeaders.Clear;
      Indy.Request.ContentType := 'application/x-www-form-urlencoded';
      sslIOHandler.SSLOptions.Method := sslvSSLv23;
      sslIOHandler.SSLOptions.Mode := sslmClient;

      Indy.IOHandler := sslIOHandler;
      Indy.HandleRedirects:=False;
      Indy.ConnectTimeout := 3000;
      Indy.ReadTimeout := 3000;
      Indy.Request.UserAgent := 'Mozilla/5.0';
      Indy.Request.Method := 'GET';
      Indy.Get('https://api2.xgolf.com/userCheck?text=' + ACode, RecvtData);

      ByteStr := PAnsiChar(RecvtData.Memory);
      setCodePage(ByteStr, 65001, false);

      JsonText := ByteStr;
      Log.D('CheckXGolfMember', JsonText);

      if (MainJson.ParseJSONValue(JsonText) as TJSONObject).Get('result_cd').JsonValue.Value = '00' then
      begin
        Log.D('CheckXGolfMember True', (MainJson.ParseJSONValue(JsonText) as TJSONObject).Get('result_cd').JsonValue.Value);
        Result := True;
      end
      else
        Global.SBMessage.ShowMessageModalForm(MSG_NOT_XGOLF_MEMBER);
    except
      on E: Exception do
      begin
        Log.E('CheckXGolfMember', ACode);
        Log.E('CheckXGolfMember', E.Message);
      end;
    end;
  finally
    MainJson.Free;
    RecvtData.Free;
    Indy.Free;
    sslIOHandler.Free;
  end;
end;

function TSaleModule.CheckXGolfMemberPhone(ACode: string): Boolean;
var
  MainJson: TJSONObject;
  Indy: TIdHTTP;
  sslIOHandler : TIdSSLIOHandlerSocketOpenSSL;
  RecvtData: TStringStream;
  ByteStr: RawByteString;
  JsonText: string;
begin       //jangheejin
  try
    try
      Result := False;
      Log.D('CheckXGolfMember Phone', ACode);

      MainJson := TJSONObject.Create;
      Indy := TIdHTTP.Create(nil);
      sslIOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
      RecvtData := TStringStream.Create;
      Indy.Request.CustomHeaders.Clear;
      Indy.Request.ContentType := 'application/x-www-form-urlencoded';
      sslIOHandler.SSLOptions.Method := sslvSSLv23;
      sslIOHandler.SSLOptions.Mode := sslmClient;

      Indy.IOHandler := sslIOHandler;
      Indy.HandleRedirects:=False;
      Indy.ConnectTimeout := 3000;
      Indy.ReadTimeout := 3000;
      Indy.Request.UserAgent := 'Mozilla/5.0';
      Indy.Request.Method := 'GET';
      Indy.Get('https://outsidebooking.xgolf.com/userCheckByHp?hp=' + ACode, RecvtData);

      ByteStr := PAnsiChar(RecvtData.Memory);
      setCodePage(ByteStr, 65001, false);
            //    CheckXGolfMember	{"result_msg":"success","result_cd":"00"}
      JsonText := ByteStr;
      Log.D('CheckXGolfMember Phone', JsonText);

      if (MainJson.ParseJSONValue(JsonText) as TJSONObject).Get('resultCode').JsonValue.Value = 'Y' then
      begin
        //xgolf phone 번호
        allianceNumber := ACode;
        Result := True;
      end
      else
        Global.SBMessage.ShowMessageModalForm(MSG_NOT_XGOLF_MEMBER);
    except
      on E: Exception do
      begin
        Log.E('CheckXGolfMember', ACode);
        Log.E('CheckXGolfMember', E.Message);
      end;
    end;
  finally
    MainJson.Free;
    RecvtData.Free;
    Indy.Free;
    sslIOHandler.Free;
  end;
end;

function TSaleModule.CheckXGolfMemberChk(AType, ACode: string): Boolean;
var
  RecvJson: TJSONObject;
  JsonText: string;

  Indy: TIdHTTP;
  SendData, RecvData: TStringStream;
  sslIOHandler : TIdSSLIOHandlerSocketOpenSSL;
  AUrl: string;
begin

  try
    try
      Result := False;
      Log.D('CheckXGolfMemberChk', AType + ' / ' + ACode);

      SendData := TStringStream.Create;
      RecvData := TStringStream.Create;

      Indy := TIdHTTP.Create(nil);
      sslIOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);

      Indy.Request.CustomHeaders.Clear;
      Indy.Request.ContentType := 'application/x-www-form-urlencoded';
      sslIOHandler.SSLOptions.Method := sslvSSLv23;
      sslIOHandler.SSLOptions.Mode := sslmClient;

      Indy.IOHandler := sslIOHandler;
      Indy.HandleRedirects:=False;
      Indy.ConnectTimeout := 3000;
      Indy.ReadTimeout := 3000;
      //Indy.Request.UserAgent := 'Mozilla/5.0';
      //Indy.Request.Method := 'POST';

      AUrl := 'https://xgolfapi.xgolf.com/api/Member/DrivingMembChk?drivingCode=' + Global.Config.Store.StoreCode + '&memberKey=' + AType + '&memberValue=' + ACode;
      Indy.Post(AUrl, SendData, RecvData);

      JsonText := ByteStringToString(RecvData);
      Log.D('CheckXGolfMemberChk', JsonText);

      RecvJson := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;

      if RecvJson.GetValue('result_cd').Value = '0000' then
      begin
        if AType = 'HP' then //xgolf phone 번호
          allianceNumber := ACode;

        Result := True;
      end
      else
        Global.SBMessage.ShowMessageModalForm(RecvJson.GetValue('result_msg').Value);

      FreeAndNil(RecvJson);
    except
      on E: Exception do
      begin
        Log.E('CheckXGolfMemberChk', E.Message);
      end;
    end;
  finally
    SendData.Free;
    RecvData.Free;
    Indy.Free;
    sslIOHandler.Free;
  end;
end;

procedure TSaleModule.CallEmp;
begin
//
end;

constructor TSaleModule.Create;
begin
  ConfigJsonText := EmptyStr;
  ProgramUse := True;

  MemberList := TList<TMemberInfo>.Create;
  MemberUpdateList := TList<TMemberInfo>.Create;
  ProductList := TList<TProductInfo>.Create;
  BuyProductList := TList<TSaleData>.Create;
  SaleList := TList<TProductInfo>.Create;
  FacilitySaleList := TList<TProductInfo>.Create;
  GeneralSaleList := TList<TProductInfo>.Create;
  DisCountList := TList<TDiscount>.Create;
  PayList := TList<TPayData>.Create;
  MainItemList := TList<TTeeBoxInfo>.Create;

  CheckInList := TList<TCheckInInfo>.Create;

  AdvertListUp := TList<TAdvertisement>.Create;
  AdvertListTeeboxUp := TList<TAdvertisement>.Create;
  AdvertListDown := TList<TAdvertisement>.Create;
  AdvertListPopupMember := TList<TAdvertisement>.Create;
  AdvertListComplex := TList<TAdvertisement>.Create;
  AdvertListEvent := TList<TAdvertisement>.Create;
  AdvertListReceipt := TList<TAdvertisement>.Create;

  ParkingProductList := TList<TProductInfo>.Create;

  //약관
  AgreementList1 := TList<TAgreement>.Create;
  AgreementList2 := TList<TAgreement>.Create;
  AgreementList3 := TList<TAgreement>.Create;

//  LastHoldNo := 0;
  VipTeeBox := False;
  SaleUploadFail := False;
  AllTeeBoxShow := False;
  MainItemMapUse := False;
  TeeBoxSortType := tstDefault;
  MiniMapCursor := False;

  //임시주석처리2021-08-24 ntdll 의심
  //MasterDownThread := TMasterDownThread.Create;

  SoundThread := TSoundThread.Create;
  MemberInfoDownLoadDateTime := EmptyStr;
  NowHour := EmptyStr;
  NowTime := EmptyStr;
  MiniMapWidth := 0;
  AdvertListPopupMemberIdx := 0;
  AdvertListReceiptIdx := 0;

  FResetProductList := False;
end;

destructor TSaleModule.Destroy;
begin

  try

    if MemberList <> nil then
      MemberList.Free;

    if MemberUpdateList <> nil then
      MemberUpdateList.Free;

    if ProductList <> nil then
      ProductList.Free;

    if BuyProductList <> nil then
      BuyProductList.Free;

    if SaleList <> nil then
      SaleList.Free;

    if FacilitySaleList <> nil then
      FacilitySaleList.Free;

    if GeneralSaleList <> nil then
      GeneralSaleList.Free;

    if DisCountList <> nil then
      DisCountList.Free;

    if PayList <> nil then
      PayList.Free;

    //if (MainItemList <> nil) then // 참조변수
      //MainItemList.Free;

    if CheckInList <> nil then
      CheckInList.Free;

    //광고
    if AdvertListUp <> nil then
      AdvertListUp.Free;

    if AdvertListTeeboxUp <> nil then
      AdvertListTeeboxUp.Free;

    if AdvertListDown <> nil then
      AdvertListDown.Free;

    if AdvertListPopupMember <> nil then
      AdvertListPopupMember.Free;

    if AdvertListComplex <> nil then
      AdvertListComplex.Free;

    if AdvertListEvent <> nil then
      AdvertListEvent.Free;

    if AdvertListReceipt <> nil then
      AdvertListReceipt.Free;

    if ParkingProductList <> nil then
      ParkingProductList.Free;

    //약관
    if AgreementList1 <> nil then
      AgreementList1.Free;
    if AgreementList2 <> nil then
      AgreementList2.Free;
    if AgreementList3 <> nil then
      AgreementList3.Free;

    if not Global.Config.NoPayModule then
    begin
      VanModule.Free;
      PaycoModule.Free;
    end;

    if not Global.Config.NoDevice then
    begin
      if Global.Config.Fingerprint = 'UNION' then
        UCBioBSPHelper.Free
      else
        //Nitgen.Free;
        NBioBSPHelper.Free;

      Print.Free;
    end;

    {//2021-08-24 임시주석
    if FMasterDownThread <> nil then
    begin
      FMasterDownThread.Terminate;
      //FMasterDownThread.WaitFor; //타석현황 화면 이후 waitfor를 넘어가지 못함...
      //FMasterDownThread.Free;
    end;
    }
    if FSoundThread <> nil then
    begin
      FSoundThread.Terminate;
      //FSoundThread.WaitFor;
      //FSoundThread.Free;
    end;

    SetLength(FAdvertReceiptPrintList, 0);
    SetLength(FAdvertReceiptPopupList, 0);

  except
    on E: Exception do
      Log.E('TSaleModule.Destroy', E.Message);
  end;

  inherited;
end;

function TSaleModule.GetMemberList: Boolean;
var
  rMemberInfoList: TList<TMemberInfo>;
  ncnt, nIndex: integer;
  bMsg: Boolean;
begin
  try
    try
      Result := False;

      if MemberList.Count = 0 then
      begin
        rMemberInfoList := Global.Database.GetAllMemberInfo(bMsg);

        if bMsg = False then
          Exit;

        for nIndex := 0 to rMemberInfoList.Count - 1 do
        begin
          MemberList.Add(rMemberInfoList[nIndex]);
        end;
        FreeAndNil(rMemberInfoList);
      end
      else
        MemberUpdateList := Global.Database.GetAllMemberInfo(bMsg);

      Result := True;
    except
      on E: Exception do
      begin

      end;
    end;
  finally

  end;
end;

function TSaleModule.GetConfig: Boolean;
begin
  try
    Result := False;
    Sleep(1000);

    //환경설정 정보 갱신
    if (Global.Config.StoreType = '2') then
    begin
      Global.Database.GetConfig;
    end
    else
    begin
      if Global.Database.GetConfigNew then
        Global.Config.LoadConfigV1;
    end;

    Result := True;
  finally

  end;
end;

function TSaleModule.GetProductList: Boolean;
var
  AList: TList<TProductInfo>;
  nIndex: Integer;
  bMsg: Boolean;
begin
  try
    Result := False;
    AList := Global.Database.GetTeeBoxProductList(bMsg);

    if bMsg = False then
      Exit;

    if AList.Count <> 0 then
    begin

      for nIndex := 0 to SaleList.Count - 1 do
      begin
        SaleList.Delete(0);
      end;

      for nIndex := 0 to AList.Count - 1 do
      begin
        SaleList.Add(AList[nIndex]);
      end;
    end;
    FreeAndNil(AList);

    Result := True;
  finally

  end;
end;

function TSaleModule.GetFacilityProductList: Boolean;
var
  AList: TList<TProductInfo>;
  nIndex: Integer;
  bMsg: Boolean;
begin
  try
    Result := False;
    AList := Global.Database.GetFacilityProductList(bMsg);

    if bMsg = False then
      Exit;

    if AList.Count <> 0 then
    begin

      for nIndex := 0 to FacilitySaleList.Count - 1 do
      begin
        FacilitySaleList.Delete(0);
      end;

      for nIndex := 0 to AList.Count - 1 do
      begin
        FacilitySaleList.Add(AList[nIndex]);
      end;
    end;
    FreeAndNil(AList);

    Result := True;
  finally

  end;
end;

function TSaleModule.GetGeneralProductList: Boolean;
var
  AList: TList<TProductInfo>;
  nIndex: Integer;
  bMsg: Boolean;
begin
  try
    Result := False;
    AList := Global.Database.GetGeneralProductList(bMsg);

    if bMsg = False then
      Exit;

    if AList.Count <> 0 then
    begin

      for nIndex := 0 to GeneralSaleList.Count - 1 do
      begin
        GeneralSaleList.Delete(0);
      end;

      for nIndex := 0 to AList.Count - 1 do
      begin
        GeneralSaleList.Add(AList[nIndex]);
      end;
    end;
    FreeAndNil(AList);

    Result := True;
  finally

  end;
end;

function TSaleModule.GetRcpNo: Integer;
begin
  try
    Result := 0;

  except
    on E: Exception do
      Log.E('GetRcpNo', E.Message);
  end;
end;

function TSaleModule.GetTeeBoxInfo: Boolean;
var
  AList: TList<TTeeBoxInfo>;
  nIndex: Integer;
begin
  try
    Result := False;
    AList := Global.Database.GetTeeBoxMaster;
    if AList.Count <> 0 then
    begin
      for nIndex := 0 to AList.Count - 1 do
      begin
        if AList[nIndex].DelYn = True then
          Continue;

        Global.TeeBox.TeeBoxInfo.Add(AList[nIndex]);
      end;
    end;
    FreeAndNil(AList);

    Result := True;
  finally

  end;
end;

function TSaleModule.GetPlayingTeeBoxList: Boolean;
var
  nIndex: Integer;
begin
  try
    Result := False;
    if Global.Config.AD.USE then
      Global.LocalApi.GetTeeBoxPlayingInfo
    else
      Global.Database.GetTeeBoxPlayingInfo;

    Global.TeeBox.TeeBoxList := Global.TeeBox.UpdateTeeBoxList;

    //Sleep(1000);
    Result := True;
  finally

  end;
end;

function TSaleModule.DeviceInit: Boolean;
begin
  try
    Result := False;

    if not Global.Config.NoPayModule then
    begin
      VanModule := TVanDeamonModul.Create;
      VanModule.VanCode := GetVanCode;
      VanModule.ApplyConfigAll;

      PaycoModule := TPaycoNewModul.Create;
      PaycoModule.SetOpen;
    end;

    if not Global.Config.NoDevice then
    begin

      if (Global.Config.FingerprintUse = 'Y') or (Global.Config.FingerprintQRUse = 'Y') then
      begin
        if Global.Config.Fingerprint = 'UNION' then
        begin
          UCBioBSPHelper := TUCBioBSPHelper.Create;
          UCBioBSPHelper.EnrollQuality := Global.Config.EnrollImageQuality; //품질
          UCBioBSPHelper.VerifyQuality := Global.Config.VerifyImageQuality; //비교
          UCBioBSPHelper.DefaultTimeout := 7000;   //디폴트로 이 값은 10000(10초)을 가진다.
          UCBioBSPHelper.SecurityLevel := Global.Config.SecurityLevel; //보안
        end
        else
        begin //2020-12-09 수정버전 적용(이선우 이사님 버전)
          NBioBSPHelper := TNBioBSPHelper.Create(Global.Config.EnrollImageQuality, Global.Config.EnrollImageQuality, 90,
                          Global.Config.VerifyImageQuality, Global.Config.SecurityLevel, 10000);
        end;
      end;

      if (Global.Config.Print.PrintType = 'SEWOO') or (Global.Config.Print.PrintType = 'EPSON') then
        Print := TReceiptPrint.Create(dtKiosk42, Global.Config.Print.Port, br115200)
      else
        Print := TReceiptPrint.Create(dtKiosk, Global.Config.Print.Port, br9600);
    end;
    Result := True;
  except
    on E: Exception do
    begin
      Log.D('ShowMain', 'DeviceInit Fail : ' + E.Message);
    end;
  end;
end;

function TSaleModule.GetVanCode: string;
begin
  if Global.Config.Store.VanCode = 1 then
    Result := VAN_CODE_KFTC
  else if Global.Config.Store.VanCode = 2 then
    Result := VAN_CODE_KICC
  else if Global.Config.Store.VanCode = 3 then
    Result := VAN_CODE_KIS
  else if Global.Config.Store.VanCode = 4 then
    Result := VAN_CODE_FDIK
  else if Global.Config.Store.VanCode = 5 then
    Result := VAN_CODE_KOCES
  else if Global.Config.Store.VanCode = 6 then
    Result := VAN_CODE_KSNET
  else if Global.Config.Store.VanCode = 7 then
    Result := VAN_CODE_JTNET
  else if Global.Config.Store.VanCode = 8 then
    Result := VAN_CODE_NICE
  else if Global.Config.Store.VanCode = 9 then
    Result := VAN_CODE_SMARTRO
  else if Global.Config.Store.VanCode = 10 then
    Result := VAN_CODE_KCP
  else if Global.Config.Store.VanCode = 11 then
    Result := VAN_CODE_DAOU
  else if Global.Config.Store.VanCode = 12 then
    Result := VAN_CODE_KOVAN
  else
    Result := VAN_CODE_SPC;
end;

function TSaleModule.OAuthCheck: Boolean;
begin
  try
    Result := False;

    Result := True;
  finally

  end;
end;

function TSaleModule.SetPrepareMin: Boolean;
begin
  try
    try
      Exit;

      if not Global.Config.PrepareUse then
        Exit;

      Global.SBMessage.PrepareTimeSelect := True;
      Global.SBMessage.ShowMessageModalForm('-', False);
    except
      on E: Exception do
      begin
        Log.E('SetPrepareMin', E.Message);
      end;
    end;
  finally
    Global.SBMessage.PrepareTimeSelect := False;
  end;
end;

function TSaleModule.MasterReception(AType: Integer): Boolean;
var
  AVersion: string;
  Member, Config, Product, TeeBox, Advertis: Boolean;
begin
  try
    Result := False;
    Member := True;
    Config := True;
    Product := True;
    TeeBox := True;
    Advertis := True;

    if AType = 0 then
    begin
      AVersion := Global.Database.GetAllMmeberInfoVersion;
      if Global.Config.Version.MemberVersion <> AVersion then
      begin
        Global.Config.Version.MemberVersion := AVersion;
        Member := False;
        Global.SaleModule.GetMemberList;
      end;
      Result := True;
    end
    else if AType = 1 then
    begin
      AVersion := Global.Database.GetTeeBoxProductListVersion;
      if Global.Config.Version.ProductVersion <> AVersion then
      begin
        Global.Config.Version.ProductVersion := AVersion;
        Product := False;
      end;
      if Member and Config and Product and TeeBox then
        Result := True
      else
        Result := ShowMasterDownload(False, not Member, not Config, not Product, not TeeBox);
    end
    else
    begin
      Product := False;
      Result := ShowMasterDownload(False, not Member, not Config, not Product, not TeeBox);
    end;

  except
    on E: Exception do
    begin

    end;
  end;
end;

function TSaleModule.SaleCompleteProc: Boolean;
var
  AProduct: TProductInfo;
begin
  try
    try
      Result := False;

      if BuyProductList.Count <> 0 then
      begin
        Global.SaleModule.RcpAspNo := Global.Config.Store.StoreCode +             // 5
                                      Copy(Global.Config.OAuth.DeviceID, 8, 3) +  // 3
                                      FormatDateTime('YYMMDDHHNNSS', now);        // 12

        if not Global.Database.SaveSaleInfo then
        begin
          Log.E('SaleCompleteProc', 'False');
        end;
      end;

      if SaleUploadFail then
      begin
        Global.SaleModule.PopUpFullLevel := pflPrint;
        ShowFullPopup(False, 'SaleUploadFail');
        Exit;
      end;

      //판매유도 팝업에서 신규회원인 경우
      if (Global.SaleModule.AdvertPopupType = apMember) and (Global.SaleModule.memberItemType = mitNew) then
      begin
        Global.SaleModule.PopUpFullLevel := pflPrint;
        ShowFullPopup(False, 'SaleCompleteProc 0');

        //구매한 상품이 쿠폰인 경우 QR전송화면 표시위해
        if (BuyProductList[0].Products.Product_Div = PRODUCT_TYPE_C) then
          Global.SaleModule.NewMemberItemType := mitCoupon;

        Result := True;
        Exit;
      end;

      //타석선택후 신규회원인 경우
      if Global.SaleModule.NewMemberItemType in [mitperiod, mitCoupon] then
      begin
        Global.SaleModule.PopUpFullLevel := pflPrint;
        ShowFullPopup(False, 'SaleCompleteProc 0');

        if Global.Config.Store.StoreCode = 'A3001' then //JMS
          Global.LocalApi.SaveParkingData;

        Result := True;
        Exit;
      end;

      //시설이용권 일일입장
      if Global.SaleModule.PaymentAddType = patFacilityDay then
      begin
        if Global.SaleModule.BuyProductList[0].Products.ProductBuyCode <> '' then
        begin
          if not Global.Database.UseFacilityProduct(Global.SaleModule.BuyProductList[0].Products.ProductBuyCode) then
          begin
            Log.E('UseFacilityProduct', 'False');
          end;
        end;
      end;

      if BuyProductList.Count = 1 then
      begin
        if (BuyProductList[0].Products.Product_Div <> PRODUCT_TYPE_D) and BuyProductList[0].Products.Use and BuyProductList[0].Products.Today_Use then
        begin
          { //2021-07-28 회원권 구매시 배정요청 제외. 이종섭 차장
          if Global.SBMessage.ShowMessageModalForm(MSG_SALE_PRODUCT_RESERVE, False) then
            SelectProduct := BuyProductList[0].Products;
          }
        end
        else
        begin
          //if (Global.Config.Store.StoreCode = 'C1001') and (Global.SaleModule.memberItemType = mitGamePay) then //코리아하이파이브스포츠클럽
          if Global.SaleModule.PaymentAddType <> patNone then // 타석상품결제가 아니면
          begin
            // 배정제외
          end
          else
            SelectProduct := BuyProductList[0].Products;
        end;
      end;

      if SelectProduct.Code <> EmptyStr then
      begin // 예약 배정 등록
        Global.SaleModule.SetPrepareMin;
        if not Global.Database.TeeBoxListReservation then
        begin
          Log.E('TeeBoxListReservation', '예약배정 실패');
          if not Global.Database.TeeBoxHold(False) then
            Log.E('TeeBoxHold False', '실패');
        end
        else
        begin

          if (Global.Config.Store.StampYn = True) and (SelectProduct.Stamp_Yn = True) then // D2001	동도센트리움 골프연습장
          begin
            PopUpLevel := plStamp;
            ShowPopup('uSaleModule/plStamp');
          end;

          if Global.Config.PARKING_DAY = True then
          begin
            Global.SaleModule.PopUpLevel := plParkingDay;
            ShowPopup('uSaleModule/plParkingDay');
          end;
        end;

        Global.SaleModule.PopUpFullLevel := pflPrint;
        ShowFullPopup(False, 'SaleCompleteProc 1');
      end
      else
      begin
        Global.SaleModule.PopUpFullLevel := pflProduct;

        if Global.SaleModule.Member.Code <> '' then
          Global.SaleModule.ProductList := Global.Database.GetMemberProductList(Global.SaleModule.Member.Code, '', '');

        if Global.SaleModule.ProductList.Count = 1 then
        begin
          Global.SaleModule.ProductList.Clear;
          Global.SaleModule.PopUpFullLevel := pflPrint;
          ShowFullPopup(False, 'SaleCompleteProc 2');
          if not Global.Database.TeeBoxHold(False) then
            Log.E('TeeBoxHold False', '실패');
        end
        else
        begin
          //2021-07-28 회원권 구매시 배정요청 제외. 이종섭 차장
          Global.SaleModule.PopUpFullLevel := pflPrint;
          ShowFullPopup(False, 'SaleCompleteProc 9');
          if not Global.Database.TeeBoxHold(False) then
            Log.E('TeeBoxHold False', '실패');
        end;
      end;

      if Global.Config.Store.StoreCode = 'A3001' then //JMS
        Global.LocalApi.SaveParkingData;

      Result := True;
    except
      on E: Exception do
        Log.E('SaleCompleteProc', E.Message);
    end;
  finally
  end;
end;

function TSaleModule.SetPrintData: string;
var
  Index, VatAmt: Integer;
  Main, Store, Order, MemberObJect, Receipt, JsonItem: TJSONObject;
  ProductList, Discount, PayList, OrderList: TJSONArray;
  ACard: TPayCard;
  APayco: TPayPayco;
begin
  Main := TJSONObject.Create;
  Store := TJSONObject.Create;
  MemberObJect := TJSONObject.Create;
  Receipt := TJSONObject.Create;

  OrderList := TJSONArray.Create;
  ProductList := TJSONArray.Create;
  Discount := TJSONArray.Create;
  PayList := TJSONArray.Create;
  try
    try
//      Log.D('프린터 JSON Begin', Result);

      Main.AddPair(TJSONPair.Create('StoreInfo', Store));
      Main.AddPair(TJSONPair.Create('OrderList', OrderList));
      Main.AddPair(TJSONPair.Create('ReceiptMemberInfo', MemberObJect));
      Main.AddPair(TJSONPair.Create('ProductInfo', ProductList));
      Main.AddPair(TJSONPair.Create('PayInfo', PayList));
      Main.AddPair(TJSONPair.Create('DiscountInfo', Discount));
      Main.AddPair(TJSONPair.Create('ReceiptEtc', Receipt));

      Store.AddPair(TJSONPair.Create('StoreName', Global.Config.Store.StoreName));
      Store.AddPair(TJSONPair.Create('BizNo', Global.Config.Store.BizNo));
      Store.AddPair(TJSONPair.Create('BossName', Global.Config.Store.BossName));
      Store.AddPair(TJSONPair.Create('Tel', Global.Config.Store.Tel));
      Store.AddPair(TJSONPair.Create('Addr', Global.Config.Store.Addr));

      // 키오스크는 1개 POS는 반복문 사용
      JsonItem := TJSONObject.Create;
      //JsonItem.AddPair(TJSONPair.Create('TeeBox_Floor', IntTostr(TeeBoxInfo.High)));
      JsonItem.AddPair(TJSONPair.Create('TeeBox_Floor', TeeBoxInfo.FloorNm));

      JsonItem.AddPair(TJSONPair.Create('TeeBox_Nm', TeeBoxInfo.Mno));
  //    Order.AddPair(TJSONPair.Create('UseTime', SelectProduct.Start_Time + ' ~ ' + SelectProduct.End_Time));
      JsonItem.AddPair(TJSONPair.Create('Parking_Barcode', SelectProduct.Reserve_Time));
      JsonItem.AddPair(TJSONPair.Create('ProductDiv', SelectProduct.Product_Div));
      JsonItem.AddPair(TJSONPair.Create('UseTime', SelectProduct.Start_Time));
      JsonItem.AddPair(TJSONPair.Create('One_Use_Time', SelectProduct.One_Use_Time));
      JsonItem.AddPair(TJSONPair.Create('Reserve_No', SelectProduct.Reserve_No));

      //라카만기일
      JsonItem.AddPair(TJSONPair.Create('Locker_End_Day', Global.SaleModule.FLockerEndDay));

      //출입통제 2022-08-23
      JsonItem.AddPair(TJSONPair.Create('Access_Barcode', SelectProduct.Access_Barcode));
      JsonItem.AddPair(TJSONPair.Create('Access_Control_Nm', SelectProduct.Access_Control_Nm));

      // 아래 5개는 쿠폰에 관련된 내용
      JsonItem.AddPair(TJSONPair.Create('UseProductName', SelectProduct.Name));

      //JsonItem.AddPair(TJSONPair.Create('Coupon', TJSONBool.Create(System.StrUtils.IfThen(SelectProduct.Product_Div = PRODUCT_TYPE_C, True, False)).ToString)); // 쿠폰 사용 여부
      if SelectProduct.Product_Div = PRODUCT_TYPE_C then // 쿠폰 사용 여부
        JsonItem.AddPair(TJSONPair.Create('Coupon', TJSONBool.Create(True).ToString))
      else
        JsonItem.AddPair(TJSONPair.Create('Coupon', TJSONBool.Create(False).ToString));

      JsonItem.AddPair(TJSONPair.Create('CouponQty', TJSONNumber.Create(SelectProduct.UseCnt)));  // 잔여 쿠폰 수
      JsonItem.AddPair(TJSONPair.Create('CouponUseDate', SelectProduct.Reserve_List));
      JsonItem.AddPair(TJSONPair.Create('ExpireDate', DateTimeSetString(SelectProduct.EndDate)));
      OrderList.Add(JsonItem);

      if (Member.Code <> EmptyStr) or (Global.SaleModule.XGolfDCAmt <> 0) then
      begin
        MemberObJect.AddPair(TJSONPair.Create('Name', Member.Name));
        MemberObJect.AddPair(TJSONPair.Create('Code', Member.Code));
        MemberObJect.AddPair(TJSONPair.Create('Tel', Member.Tel_Mobile));
        MemberObJect.AddPair(TJSONPair.Create('CarNo', Member.CarNo));
        MemberObJect.AddPair(TJSONPair.Create('CardNo', Member.CardNo));
        MemberObJect.AddPair(TJSONPair.Create('MemberXGOLF', TJSONBool.Create(Global.SaleModule.Member.XGolfMember)));
        MemberObJect.AddPair(TJSONPair.Create('XGolfDiscountAmt', TJSONNumber.Create(Global.SaleModule.XGolfDCAmt)));
      end;

      for Index := 0 to BuyProductList.Count - 1 do
      begin
        JsonItem := TJSONObject.Create;
        VatAmt := BuyProductList[Index].Products.Price - Trunc((BuyProductList[Index].Products.Price / 1.1));
        JsonItem.AddPair(TJSONPair.Create('Name', Global.SaleModule.BuyProductList[Index].Products.Name));
        JsonItem.AddPair(TJSONPair.Create('Code', Global.SaleModule.BuyProductList[Index].Products.Code));
        JsonItem.AddPair(TJSONPair.Create('Price', TJSONNumber.Create(Global.SaleModule.BuyProductList[Index].Products.Price)));
        JsonItem.AddPair(TJSONPair.Create('Vat', TJSONNumber.Create(VatAmt)));
        JsonItem.AddPair(TJSONPair.Create('Qty', TJSONNumber.Create(Global.SaleModule.BuyProductList[Index].SaleQty)));
        ProductList.Add(JsonItem);
      end;

      for Index := 0 to Global.SaleModule.DisCountList.Count - 1 do
      begin
        JsonItem := TJSONObject.Create;
        JsonItem.AddPair(TJSONPair.Create('Name', Global.SaleModule.DisCountList[Index].Name));
        JsonItem.AddPair(TJSONPair.Create('QRCode', Global.SaleModule.DisCountList[Index].QRCode));
        JsonItem.AddPair(TJSONPair.Create('Value', IntToStr(Global.SaleModule.DisCountList[Index].ApplyAmt)));
        Discount.Add(JsonItem);
      end;

      if (allianceCode <> EmptyStr) and (allianceNumber <> EmptyStr) then
      begin
        JsonItem := TJSONObject.Create;
        JsonItem.AddPair(TJSONPair.Create('Name', '웰빙클럽 회원'));
        JsonItem.AddPair(TJSONPair.Create('QRCode', allianceCode));
        JsonItem.AddPair(TJSONPair.Create('Value', allianceNumber));
        Discount.Add(JsonItem);
      end;

      for Index := 0 to Global.SaleModule.PayList.Count - 1 do
      begin
        JsonItem := TJSONObject.Create;

        if TPayData(Global.SaleModule.PayList[Index]).PayType = ptCard then
        begin
          ACard := TPayCard(Global.SaleModule.PayList[Index]);
          JsonItem.AddPair(TJSONPair.Create('PayCode', 'Card'));
          JsonItem.AddPair(TJSONPair.Create('Approval', TJSONBool.Create(ACard.SendInfo.Approval).ToString));
          JsonItem.AddPair(TJSONPair.Create('Internet', TJSONBool.Create(True)));
          JsonItem.AddPair(TJSONPair.Create('ApprovalAmt', TJSONNumber.Create(ACard.PayAmt)));
          JsonItem.AddPair(TJSONPair.Create('ApprovalNo', ACard.RecvInfo.AgreeNo));
          JsonItem.AddPair(TJSONPair.Create('OrgApprovalNo', ACard.SendInfo.OrgAgreeNo));
          JsonItem.AddPair(TJSONPair.Create('CardNo', ACard.RecvInfo.CardNo));
  //        JsonItem.AddPair(TJSONPair.Create('CashReceiptPerson', TJSONNumber.Create(0)));
          JsonItem.AddPair(TJSONPair.Create('HalbuMonth', IntToStr(ACard.SendInfo.HalbuMonth)));
          JsonItem.AddPair(TJSONPair.Create('CompanyName', ACard.RecvInfo.CompName));
          JsonItem.AddPair(TJSONPair.Create('MerchantKey', ''));
          JsonItem.AddPair(TJSONPair.Create('TransDateTime', ACard.RecvInfo.AgreeDateTime));
          JsonItem.AddPair(TJSONPair.Create('BuyCompanyName', ACard.RecvInfo.BalgupsaName));
          JsonItem.AddPair(TJSONPair.Create('BuyTypeName', ACard.RecvInfo.BalgupsaCode));
        end
        else
        begin
          APayco := TPayPayco(Global.SaleModule.PayList[Index]);
          JsonItem.AddPair(TJSONPair.Create('PayCode', 'Payco'));
          JsonItem.AddPair(TJSONPair.Create('Approval', TJSONBool.Create(APayco.SendInfo.Approval).ToString));
          JsonItem.AddPair(TJSONPair.Create('Internet', TJSONBool.Create(True).ToString));
          JsonItem.AddPair(TJSONPair.Create('ApprovalAmt', TJSONNumber.Create(APayco.PayAmt)));
          JsonItem.AddPair(TJSONPair.Create('ApprovalNo', APayco.RecvInfo.AgreeNo));
          JsonItem.AddPair(TJSONPair.Create('OrgApprovalNo', APayco.SendInfo.OrgAgreeNo));
          JsonItem.AddPair(TJSONPair.Create('CardNo', APayco.RecvInfo.RevCardNo));
  //        JsonItem.AddPair(TJSONPair.Create('CashReceiptPerson', TJSONNumber.Create(0)));
          JsonItem.AddPair(TJSONPair.Create('HalbuMonth', APayco.RecvInfo.HalbuMonth));
          JsonItem.AddPair(TJSONPair.Create('CompanyName', APayco.RecvInfo.ApprovalCompanyName));
          JsonItem.AddPair(TJSONPair.Create('MerchantKey', APayco.RecvInfo.MerchantName));
          JsonItem.AddPair(TJSONPair.Create('TransDateTime', APayco.RecvInfo.TransDateTime));
          JsonItem.AddPair(TJSONPair.Create('BuyCompanyName', APayco.RecvInfo.BuyCompanyName));
          JsonItem.AddPair(TJSONPair.Create('BuyTypeName', APayco.RecvInfo.BuyTypeName));
        end;
        PayList.Add(JsonItem);
      end;

      Receipt.AddPair(TJSONPair.Create('RcpNo', TJSONNumber.Create(RcpNo)));
      Receipt.AddPair(TJSONPair.Create('SaleDate', FormatDateTime('yyyy-mm-dd', now)));
      Receipt.AddPair(TJSONPair.Create('ReturnDate', EmptyStr));
      Receipt.AddPair(TJSONPair.Create('RePrint', TJSONBool.Create(False).ToString));  // 재출력 여부
      Receipt.AddPair(TJSONPair.Create('TotalAmt', TJSONNumber.Create(Trunc(TotalAmt))));
      Receipt.AddPair(TJSONPair.Create('DCAmt', TJSONNumber.Create(Trunc(DCAmt))));
      Receipt.AddPair(TJSONPair.Create('Receipt_No', RcpAspNo));
      Receipt.AddPair(TJSONPair.Create('Top1', Global.Config.Receipt.Top1));
      Receipt.AddPair(TJSONPair.Create('Top2', Global.Config.Receipt.Top2));
      Receipt.AddPair(TJSONPair.Create('Top3', Global.Config.Receipt.Top3));
      Receipt.AddPair(TJSONPair.Create('Top4', Global.Config.Receipt.Top4));
      Receipt.AddPair(TJSONPair.Create('Bottom1', Global.Config.Receipt.Bottom1));
      Receipt.AddPair(TJSONPair.Create('Bottom2', Global.Config.Receipt.Bottom2));
      Receipt.AddPair(TJSONPair.Create('Bottom3', Global.Config.Receipt.Bottom3));
      Receipt.AddPair(TJSONPair.Create('Bottom4', Global.Config.Receipt.Bottom4));
      Receipt.AddPair(TJSONPair.Create('SaleUpload', System.StrUtils.IfThen(Global.SaleModule.SaleUploadFail, 'Y', 'N')));

      Result := Main.ToString;

      Log.D('프린터 JSON', Result);
    finally
      Main.Free;
    end;
  except
    on E: Exception do
    begin
      Log.E('프린터 JSON', E.Message);
    end;
  end;
end;

function TSaleModule.TeeboxTimeCheck: Boolean;
var
  Index: Integer;
  ASelectTime, RealTime, Msg: string;
  rTeeBoxInfo: TTeeBoxInfo;
begin
  try
    Result := False;

    Msg := EmptyStr;

    rTeeBoxInfo := Global.TeeBox.GetUpdateTeeBoxListInfo(TeeBoxInfo.TasukNo);

    if (rTeeBoxInfo.ERR = 0) or True then
    begin
      ASelectTime := StringReplace(TeeBoxInfo.End_Time, ':', '', [rfReplaceAll]);
      RealTime := StringReplace(rTeeBoxInfo.End_Time, ':', '', [rfReplaceAll]);

      if ASelectTime = EmptyStr then
        ASelectTime := FormatDateTime('hhnn', Now);

      if RealTime = EmptyStr then
        RealTime := FormatDateTime('hhnn', Now);

      if (ABS(Trunc(StrToIntDef(RealTime, 0) - StrToIntDef(ASelectTime, 0)))) > 0 then
      begin
        if ABS(Trunc(StrToIntDef(RealTime, 0) - StrToIntDef(ASelectTime, 0))) > 10 then
        begin
          TeeboxTimeError := True;
          Log.D('CheckEndTime', '10분 이상');
          Log.D('CheckEndTime - Begin', TeeBoxInfo.End_Time);
          Log.D('CheckEndTime - End', RealTime);

          Msg := Format(MSG_TEEBOX_TIME_ERROR, [Copy(ASelectTime, 1, 2) + ':' + Copy(ASelectTime, 3, 2),
                                                Copy(RealTime, 1, 2) + ':' + Copy(RealTime, 3, 2)]);

          if not Global.SBMessage.ShowMessageModalForm(Msg, False) then
          begin
            Log.D('TeeboxTimeCheck', '사용자 배정 취소');

            // 웰빙클럽 취소
            if (allianceCode = GCD_WBCLUB_CODE) and (allianceNumber <> EmptyStr) then
              WellbeingClub(False, allianceNumber);

            Exit;
          end;

          if Global.Config.AD.USE = True then
          begin
            TeeBoxInfo := rTeeBoxInfo; //변경된 타석정보로 적용
            if StoreCloseTmCheck(BuyProductList[0].Products) = True then
            begin
              Exit;
            end;
          end;

        end
        else
        begin
          Log.D('CheckEndTime', '10분 이하');
          Log.D('CheckEndTime - Begin', TeeBoxInfo.End_Time);
          Log.D('CheckEndTime - End', RealTime);
        end;
      end
      else
      begin
        TeeboxTimeError := True;
        Log.D('CheckEndTime 정상', '시간 변동 없음');
      end;
    end
    else
    begin
      Msg := MSG_TEEBOX_TIME_ERROR_STATUS;
      Global.SBMessage.ShowMessageModalForm(Msg, False);
      Log.D('CheckEndTime 정상', '점검중 또는 볼회수');
      Exit;
    end;

    Result := True;
  finally

  end;
end;

function TSaleModule.WellbeingClub(AIsApproval: Boolean; AOTC: string): Boolean;
var
  AIndy: TIdHTTP;
  RecvData: TStringStream;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
  ApprovalCode, ResultStr: string;
  RBS: RawByteString;
  SL: TStringList;
  AApiToken, AStoreCode, AMemberNo, sApprovalkey: string;
  MainJson, jObjSub: TJSONObject;
begin
  Result := False;
  ResultStr := EmptyStr;

  Log.D('WellbeingClub', Ifthen(AIsApproval, '승인', '취소'));
  Log.D('WellbeingClub', AOTC);
  
  AIndy := TIdHTTP.Create(nil);
  RecvData := TStringStream.Create;
  SL := TStringList.Create;
  MainJson := TJSONObject.Create;
  SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  try
    try
      // approval : 승인, approvalwithjongmok : 종목승인
      // approvalcancel : 취소, approvalcancelwithkey : 승인코드 취소

      if Global.Config.Store.StoreCode = 'B8001' then //제이제이골프클럽
        ApprovalCode := Ifthen(AIsApproval, 'approvalwithjongmok', 'approvalcancelwithkey')
      else
        ApprovalCode := Ifthen(AIsApproval, 'approval', 'approvalcancelwithkey');

      AIndy.Request.Accept := 'application/json';
      AIndy.Request.ContentType := 'application/x-www-form-urlencoded';
      AIndy.Request.Method := 'POST';
      AIndy.Request.UserAgent := 'Mozilla/5.0';
      SSL.SSLOptions.Method := sslvSSLv23;
      SSL.SSLOptions.Mode := sslmClient;
      AIndy.IOHandler := SSL;

      AIndy.HandleRedirects := False;

      AApiToken := Global.Config.Wellbeing.Token;
      AStoreCode := Global.Config.Wellbeing.StoreCD;
      sApprovalkey := FWellbeingApprovalkey;
      AMemberNo := AOTC;

      SL.Add(TIdURI.ParamsEncode('api_token=' + AApiToken));
      SL.Add(TIdURI.ParamsEncode('sisul_code=' + AStoreCode));

      if (AIsApproval = True) then
      begin
        SL.Add(TIdURI.ParamsEncode('card_number=' + AMemberNo));

        if (Global.Config.Store.StoreCode = 'B8001') then //제이제이골프클럽
        begin
          SL.Add(TIdURI.ParamsEncode('ord_cd=' + BuyProductList[0].Products.Alliance_item_code));
          SL.Add(TIdURI.ParamsEncode('gubun_cd=SPT'));
        end;
      end
      else
      begin
        SL.Add(TIdURI.ParamsEncode('approvalkey=' + sApprovalkey));
      end;

      Log.D('WellbeingClub', 'https://partner-api.wbcm.co.kr/openapi/' + ApprovalCode);
      Log.D('WellbeingClub', 'api_token=' + AApiToken + ' / sisul_code=' + AStoreCode + ' / card_number=' + AMemberNo + ' / approvalkey=' + sApprovalkey);

      AIndy.Post('https://partner-api.wbcm.co.kr/openapi/' + ApprovalCode, SL, RecvData);
      RBS := PAnsiChar(RecvData.Memory);
      SetCodePage(RBS, 65001, False);
      ResultStr := RBS;

      if ResultStr <> EmptyStr then
      begin
        Log.D('WellbeingClub', ResultStr);
        MainJson := TJSONObject.ParseJSONValue(ResultStr) as TJSONObject;

        if (AIsApproval = True) then
        begin
          //if (MainJson.Get('code').JsonValue.Value = '0') or (MainJson.Get('code').JsonValue.Value = '1') then
          if (MainJson.Get('code').JsonValue.Value = '0') then
          begin

            jObjSub := MainJson.GetValue('data') as TJSONObject;
            FWellbeingApprovalkey := jObjSub.GetValue('approvalkey').Value;

            allianceCode := GCD_WBCLUB_CODE; //'00001';
            allianceNumber := AOTC;
            Result := True;
          end
          else
            Global.SBMessage.ShowMessageModalForm(MainJson.Get('msg').JsonValue.Value, True, 15);
        end
        else
        begin
          if (MainJson.Get('code').JsonValue.Value = '0') then
          begin
            Global.SBMessage.ShowMessageModalForm(MainJson.Get('msg').JsonValue.Value, True, 15);
            Result := True;
          end
          else
            Global.SBMessage.ShowMessageModalForm(MainJson.Get('msg').JsonValue.Value + #13#10 + '프론트에서 취소를 진행해 주세요', True, 15);
        end;

      end
      else
      begin
        Log.D('WellbeingClub', '응답 값 없음.');
      end;
    except
      on E: Exception do
      begin
        Log.E('WellbeingClub', E.Message);
      end;
    end;
  finally
    SSL.Free;
    AIndy.Free;
    RecvData.Free;
    MainJson.Free;
  end;
end;


//chy 우리카드 더라운지멤버스
function TSaleModule.TheLoungeMembers(AOTC: string): Boolean;
var
  AIndy: TIdHTTP;
  RecvData: TStringStream;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
  ResultStr, sStatus: string;
  RBS: RawByteString;
  sUrl, sUserId, sPassword, sCouponNum, sMsg: string;
  MainJson: TJSONObject;

  JsonValue: TJSONValue;
  ResponseJsonValue: TJSONValue;
  ContentJsonValue: TJSONValue;
begin
  Result := False;
  ResultStr := EmptyStr;

  Log.D('TheLoungeMembers', '정보조회');
  Log.D('TheLoungeMembers', AOTC);

  AIndy := TIdHTTP.Create(nil);
  RecvData := TStringStream.Create;
  MainJson := TJSONObject.Create;
  SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);

  try
    try

      AIndy.Request.Accept := 'application/json';
      AIndy.Request.ContentType := 'application/x-www-form-urlencoded';
      AIndy.Request.Method := 'POST';
      AIndy.Request.UserAgent := 'Mozilla/5.0';
      SSL.SSLOptions.Method := sslvSSLv23;
      SSL.SSLOptions.Mode := sslmClient;
      AIndy.IOHandler := SSL;

      AIndy.HandleRedirects := False;

      sCouponNum := AOTC;

      {$IFDEF RELEASE}
      sUrl := THE_LOUNGE_MEMBERS_REAL_URL;
      //sUserId := THE_LOUNGE_MEMBERS_REAL_ID;
      //sPassword := THE_LOUNGE_MEMBERS_REAL_PW;

      sUserId := Global.Config.TheLoungeMembers.UserId;
      sPassword := Global.Config.TheLoungeMembers.Password;
      {$ENDIF}
      {$IFDEF DEBUG}
      sUrl := THE_LOUNGE_MEMBERS_TEST_URL;  //'https://dev-api.theloungemembers.com/';
      sUserId := THE_LOUNGE_MEMBERS_TEST_ID;
      sPassword := THE_LOUNGE_MEMBERS_TEST_PW;
      //sCouponNum := '8574003842323278'; //8574337487960243 -만료
      {$ENDIF}

      //AIndy.Post('https://dev-api.theloungemembers.com/api/v2/coupon/info/?user_id=xgolf&password=mimigolf3x^^&coupon_num=8574003842323278', SL, RecvData);
      //AIndy.Get('https://dev-api.theloungemembers.com/api/v2/coupon/info/?user_id=xgolf&password=mimigolf3x^^&coupon_num=8574337487960243', RecvData);

      //정보조회
      AIndy.Get(sUrl + 'api/v2/coupon/info/?user_id=' + sUserId + '&password=' + sPassword + '&coupon_num=' + sCouponNum, RecvData);

      //사용
      //AIndy.Get('https://dev-api.theloungemembers.com/api/v2/coupon/use/?user_id='+sUserId+'&password='+sPassword+'&coupon_num=8574003842323278&lounge_code=A123&lounge_name=키오스크', RecvData);

      //취소
      //AIndy.Get('https://dev-api.theloungemembers.com/api/v2/coupon/cancel/?user_id=xgolf&password=mimigolf3x^^&coupon_num=8574003842323278&memo=test', RecvData);
      //AIndy.Get(sUrl + 'api/v2/coupon/cancel/?user_id=' + sUserId + '&password=' + sPassword + '&coupon_num=' + sCouponNum + '&memo=test', RecvData);

      RBS := PAnsiChar(RecvData.Memory);
      SetCodePage(RBS, 65001, False);
      ResultStr := RBS;

      if ResultStr <> EmptyStr then
      begin
        Log.D('TheLoungeMembers', ResultStr);
        //WriteLog(False, 'ApiLog', 'info', 'TheLoungeMembers', ResultStr);

        JsonValue := MainJson.ParseJSONValue(ResultStr);
        ResponseJsonValue := (JsonValue as TJSONObject).Get('response').JsonValue;
        if (ResponseJsonValue as TJSONObject).Get('action_result').JsonValue.Value = 'success' then
        begin
          ContentJsonValue := (JsonValue as TJSONObject).Get('content').JsonValue;
          ContentJsonValue := (ContentJsonValue as TJSONObject).Get('coupon_info').JsonValue;
          sStatus := (ContentJsonValue as TJSONObject).Get('status').JsonValue.Value;

          //used	이용권이 이미 사용되었다.
          //expired	이용권 사용 기간이 만료되었다.
          //usable	이용권을 사용할 수 있다.
          //nonexistent	이용권이 존재하지 않는다.

          if sStatus = 'usable' then
          begin
            if TheLoungeMembersUse(sCouponNum) = False then //사용요청
              Exit;

            allianceCode := GCD_THELOUNGEMEMBERS_CODE; //'00005';
            allianceNumber := '00000';

            Result := True;
          end
          else
          begin
            if sStatus = 'used' then
              sMsg := '이용권이 이미 사용되었습니다.';
            if sStatus = 'expired' then
              sMsg := '이용권 사용 기간이 만료되었습니다.';
            if sStatus = 'nonexistent' then
              sMsg := '이용권이 존재하지 않습니다.';

            Global.SBMessage.ShowMessageModalForm(sMsg, True, 15);
          end;
        end
        else
        begin
          //"action_failure_code":"E0204","action_failure_reason":"The password is incorrect."}}
          sMsg := (ResponseJsonValue as TJSONObject).Get('action_failure_code').JsonValue.Value + ' / ' + (ResponseJsonValue as TJSONObject).Get('action_failure_reason').JsonValue.Value;
          Global.SBMessage.ShowMessageModalForm(sMsg, True, 15);
        end;
      end
      else
      begin
        Log.D('TheLoungeMembers', '응답 값 없음.');
      end;
    except
      on E: Exception do
      begin
        Log.E('TheLoungeMembers', E.Message);
      end;
    end;
  finally
    SSL.Free;
    AIndy.Free;
    RecvData.Free;
    MainJson.Free;
  end;
end;

//chy 우리카드 더라운지멤버스
function TSaleModule.TheLoungeMembersUse(ACouponNum: String): Boolean;
var
  AIndy: TIdHTTP;
  RecvData: TStringStream;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
  ResultStr, sSendData: string;
  RBS: RawByteString;
  sUrl, sUserId, sPassword, sCouponNum, sMsg: string;
  MainJson: TJSONObject;

  JsonValue: TJSONValue;
begin
  Result := False;
  ResultStr := EmptyStr;

  Log.D('TheLoungeMembersUse', '사용요청');

  AIndy := TIdHTTP.Create(nil);
  RecvData := TStringStream.Create;
  MainJson := TJSONObject.Create;
  SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);

  try
    try

      AIndy.Request.Accept := 'application/json';
      AIndy.Request.ContentType := 'application/x-www-form-urlencoded';
      AIndy.Request.Method := 'POST';
      AIndy.Request.UserAgent := 'Mozilla/5.0';
      SSL.SSLOptions.Method := sslvSSLv23;
      SSL.SSLOptions.Mode := sslmClient;
      AIndy.IOHandler := SSL;

      AIndy.HandleRedirects := False;

      sCouponNum := ACouponNum;

      {$IFDEF RELEASE}
      sUrl := THE_LOUNGE_MEMBERS_REAL_URL;
      sUserId := THE_LOUNGE_MEMBERS_REAL_ID;
      sPassword := THE_LOUNGE_MEMBERS_REAL_PW;
      {$ENDIF}
      {$IFDEF DEBUG}
      sUrl := THE_LOUNGE_MEMBERS_TEST_URL;  //'https://dev-api.theloungemembers.com/';
      sUserId := THE_LOUNGE_MEMBERS_TEST_ID;
      sPassword := THE_LOUNGE_MEMBERS_TEST_PW;
      {$ENDIF}

      //사용
      //AIndy.Get('https://dev-api.theloungemembers.com/api/v2/coupon/use/?user_id='+sUserId+'&password='+sPassword+'&coupon_num=8574003842323278&lounge_code=A123&lounge_name=키오스크', RecvData);
      sSendData := sUrl + 'api/v2/coupon/use/?user_id=' + sUserId + '&password=' + sPassword + '&coupon_num=' + sCouponNum +
                          '&lounge_code=' + Global.Config.Store.StoreCode + '&lounge_name=' + Global.Config.Store.UserID;
      AIndy.Get(sSendData, RecvData);

      RBS := PAnsiChar(RecvData.Memory);
      SetCodePage(RBS, 65001, False);
      ResultStr := RBS;

      if ResultStr <> EmptyStr then
      begin
        Log.D('TheLoungeMembersUse', ResultStr);
        //WriteLog(False, 'ApiLog', 'info', 'TheLoungeMembers', ResultStr);

        JsonValue := MainJson.ParseJSONValue(ResultStr);
        JsonValue := (JsonValue as TJSONObject).Get('response').JsonValue;
        if (JsonValue as TJSONObject).Get('action_result').JsonValue.Value = 'success' then
        begin
          Result := True;
        end
        else
        begin
          //"action_failure_code":"E0204","action_failure_reason":"The password is incorrect."}}
          sMsg := (JsonValue as TJSONObject).Get('action_failure_code').JsonValue.Value + ' / ' + (JsonValue as TJSONObject).Get('action_failure_reason').JsonValue.Value;
          Global.SBMessage.ShowMessageModalForm(sMsg, True, 15);
        end;
      end
      else
      begin
        Log.D('TheLoungeMembersUse', '응답 값 없음.');
      end;
    except
      on E: Exception do
      begin
        Log.E('TheLoungeMembersUse', E.Message);
      end;
    end;
  finally
    SSL.Free;
    AIndy.Free;
    RecvData.Free;
    MainJson.Free;
  end;
end;

//chy 리프레쉬클럽
function TSaleModule.RefreshClub(AOTC: string): Boolean;
var
  AIndy: TIdHTTP;
  RecvData: TStringStream;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
  ResultStr: string;
  RBS: RawByteString;
  SL: TStringList;
  AApiToken, AStoreCode, AMemberNo: string;
  MainJson: TJSONObject;
begin
  Result := False;

  ResultStr := EmptyStr;

  Log.D('RefreshClub', '사용요청');
  Log.D('RefreshClub', AOTC);

  AIndy := TIdHTTP.Create(nil);
  RecvData := TStringStream.Create;
  SL := TStringList.Create;
  MainJson := TJSONObject.Create;
  SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  try
    try
      //AApiToken := Global.Config.RefreshClub.Token; //ra3589nRmlh821bX - test
      AApiToken := '1hLKxhHa62PWUky9';
      //AStoreCode := Global.Config.RefreshClub.StoreCD; //00002
      AStoreCode := '686';
      //AMemberNo := AOTC;
      AMemberNo := '32943';

      AIndy.Request.Accept := 'application/json';
      AIndy.Request.CustomHeaders.Values['Authorization'] := 'Bearer ' + AApiToken;
      //AIndy.Request.ContentType := 'application/x-www-form-urlencoded';
      AIndy.Request.Method := 'POST';
      //AIndy.Request.UserAgent := 'Mozilla/5.0';
      SSL.SSLOptions.Method := sslvSSLv23;
      SSL.SSLOptions.Mode := sslmClient;
      AIndy.IOHandler := SSL;

      AIndy.HandleRedirects := False;

  //    AIndy.HTTPOptions := (AIndy.HTTPOptions - [hoForceEncodeParams]); //자동 인코딩 방지
      SL.Add(TIdURI.ParamsEncode('user_id=' + AMemberNo));
      SL.Add(TIdURI.ParamsEncode('club_id=' + AStoreCode));
      SL.Add(TIdURI.ParamsEncode('created_at=' + FormatDateTime('yyyy-mm-dd hh:nn:ss', Now) ));

  //    AIndy.Post('http://v2dev.refreshclub.co.kr', SL, RecvData);
      AIndy.Post('https://api.refreshclub.co.kr/v2/checkin/kiosk', SL, RecvData);
      RBS := PAnsiChar(RecvData.Memory);
      SetCodePage(RBS, 65001, False);
      ResultStr := RBS;

      if ResultStr <> EmptyStr then
      begin
        Log.D('RefreshClub', ResultStr);
        MainJson := TJSONObject.ParseJSONValue(ResultStr) as TJSONObject;

        if (MainJson.Get('code').JsonValue.Value = '0000') then
        begin
          Result := True;
        end
        else
          Global.SBMessage.ShowMessageModalForm(MainJson.Get('message').JsonValue.Value, True, 15);
      end
      else
      begin
        Log.D('RefreshClub', '응답 값 없음.');
      end;
    except
      on E: Exception do
      begin
        Log.E('RefreshClub', E.Message);
      end;
    end;
  finally
    SSL.Free;
    AIndy.Free;
    RecvData.Free;
    MainJson.Free;
  end;

end;

{
 GCD_RFCLUB_CODE            = '00002';
  GCD_RFCLUB_HOST            = 'https://api.refreshclub.co.kr';
  GCD_RFCLUB_TEST_HOST       = 'http://v2dev.refreshclub.co.kr';
  GCD_RFCLUB_TEST_API_TOKEN  = 'ra3589nRmlh821bX';
  GCD_RFCLUB_TEST_STORE_CODE = '';
  GCD_RFCLUB_TEST_MEMBER_NO  = '';
}

function TSaleModule.ApplyRefreshClub(const AUserId: string): Boolean;
var
  HC: TIdHTTP;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
  JO: TJSONObject;
  SS, RS: TStringStream;
  RBS: RawByteString;
  sUrl, sToken, sResCode, sResMsg, AErrMsg: string;
  MainJson: TJSONObject;
  sUserId: String;
begin
  Result := False;
  AErrMsg := '';

  try
    JO := TJSONObject.Create;
    RS := TStringStream.Create;
    SS := nil;
    HC := TIdHTTP.Create(nil);
    try
      //if Global.RefreshClub.Enabled then
      if True then
      begin

        sUrl := 'https://api.refreshclub.co.kr/v2/checkin/kiosk';

        //sToken := '1hLKxhHa62PWUky9'; //캐슬렉스
        sToken := Global.Config.RefreshClub.Token;

        JO := TJSONObject.ParseJSONValue(AUserId) as TJSONObject;
        sUserId := JO.Get('user_id').JsonValue.Value;

        SS := TStringStream.Create(AUserId, TEncoding.UTF8);

        HC.Request.Accept := 'application/json';
        HC.Request.ContentType := 'application/json';
        HC.Request.CustomHeaders.Values['Authorization'] := 'AK ' + sToken;
        HC.HandleRedirects := False;
        HC.ConnectTimeout := IdTimeoutDefault;
        HC.ReadTimeout := IdTimeoutInfinite;
        HC.Request.Method := 'POST';

        SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
        SSL.SSLOptions.Method := sslvSSLv23;
        SSL.SSLOptions.Mode := sslmClient;
        HC.IOHandler := SSL;

        Log.D('Scan begin', 'Post');

        HC.Post(sUrl, SS, RS);
        //RS.SaveToFile(Global.LogDir + 'ApplyRefreshClub.Response.json');
        RBS := PAnsiChar(RS.Memory);
        SetCodePage(RBS, 65001, False);
        JO := TJSONObject.ParseJSONValue(String(RBS)) as TJSONObject;
        sResCode := JO.GetValue('code').Value;
        sResMsg  := JO.GetValue('message').Value;
        AErrMsg  := Format('ResultCode: %s, Message: %s', [sResCode, sResMsg]);

        Log.D('Scan begin', String(RBS));

        if (sResCode <> '0000') then
        begin
          //raise Exception.Create(AErrMsg);
          Global.SBMessage.ShowMessageModalForm(AErrMsg, True, 15);
          Exit;
        end;

        allianceCode := GCD_RFCLUB_CODE; //'00002'; //코드가 있어야 무료
        allianceNumber := sUserId;

        Result := True;
      end
      else
        raise Exception.Create('리프레쉬/클럽 연동 설정이 되어 있지 않습니다!');
    finally
      FreeAndNil(RS);
      if Assigned(SS) then
        FreeAndNil(SS);
      if Assigned(JO) then
        JO.Free;
      if Assigned(SSL) then
        SSL.Free;

      HC.Disconnect;
      HC.Free;
    end;
  except
    on E: Exception do
    begin
      AErrMsg := E.Message;
      //UpdateLog(Global.LogFile, Format('ApplyRefreshClub.Exception(%s) : %s', [E.Message]));
    end;
  end
end;

//2020-12-14 리프레쉬골프
function TSaleModule.ApplyRefreshGolf(const AUserId: string): Boolean;
var
  HC: TIdHTTP;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
  JO: TJSONObject;
  SS, RS: TStringStream;
  RBS: RawByteString;
  sUrl, sToken, sResCode, sResMsg, AErrMsg: string;
  MainJson: TJSONObject;
  sUserId: String;
begin
  Result := False;
  AErrMsg := '';

  try
    JO := TJSONObject.Create;
    RS := TStringStream.Create;
    SS := nil;
    HC := TIdHTTP.Create(nil);
    try
      //if Global.RefreshClub.Enabled then
      if True then
      begin

        sUrl := 'https://api.refreshclub.co.kr/v2/checkin/kiosk';

        //sToken := '1hLKxhHa62PWUky9'; //캐슬렉스
        sToken := Global.Config.RefreshClub.Token;

        JO := TJSONObject.ParseJSONValue(AUserId) as TJSONObject;
        sUserId := JO.Get('user_id').JsonValue.Value;

        SS := TStringStream.Create(AUserId, TEncoding.UTF8);

        HC.Request.Accept := 'application/json';
        HC.Request.ContentType := 'application/json';
        HC.Request.CustomHeaders.Values['Authorization'] := 'AK ' + sToken;
        HC.HandleRedirects := False;
        HC.ConnectTimeout := IdTimeoutDefault;
        HC.ReadTimeout := IdTimeoutInfinite;
        HC.Request.Method := 'POST';

        SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
        SSL.SSLOptions.Method := sslvSSLv23;
        SSL.SSLOptions.Mode := sslmClient;
        HC.IOHandler := SSL;

        Log.D('Scan begin', 'Post');

        HC.Post(sUrl, SS, RS);
        //RS.SaveToFile(Global.LogDir + 'ApplyRefreshClub.Response.json');
        RBS := PAnsiChar(RS.Memory);
        SetCodePage(RBS, 65001, False);
        JO := TJSONObject.ParseJSONValue(String(RBS)) as TJSONObject;
        sResCode := JO.GetValue('code').Value;
        sResMsg  := JO.GetValue('message').Value;
        AErrMsg  := Format('ResultCode: %s, Message: %s', [sResCode, sResMsg]);

        Log.D('Scan begin', String(RBS));

        if (sResCode <> '0000') then
        begin
          //raise Exception.Create(AErrMsg);
          Global.SBMessage.ShowMessageModalForm(AErrMsg, True, 15);
          Exit;
        end;

        allianceCode := GCD_RFCLUB_CODE; //'00002'; //코드가 있어야 무료
        allianceNumber := sUserId;

        Result := True;
      end
      else
        raise Exception.Create('리프레쉬/클럽 연동 설정이 되어 있지 않습니다!');
    finally
      FreeAndNil(RS);
      if Assigned(SS) then
        FreeAndNil(SS);
      if Assigned(JO) then
        JO.Free;
      if Assigned(SSL) then
        SSL.Free;

      HC.Disconnect;
      HC.Free;
    end;
  except
    on E: Exception do
    begin
      AErrMsg := E.Message;
      //UpdateLog(Global.LogFile, Format('ApplyRefreshClub.Exception(%s) : %s', [E.Message]));
    end;
  end
end;

{
  CPP_AFFILIATE_MEMBER_CD = 'CPP_AFFILIATE_MEMBER_CD'; //회원번호
  CPP_AFFILIATE_EXEC_ID = 'CPP_AFFILIATE_EXEC_ID'; //종목코드


  GCD_IKOZEN_CODE            = '00004';
  GCD_IKOZEN_HOST            = 'https://ikozen.com/api/qrcode_enter.php';
  GCD_IKOZEN_TEST_STORE_CODE = '1452';
  GCD_IKOZEN_TEST_MEMBER_NO  = '1056147'; //코인 소진 시까지 일 25회 사용 가능 (초기화 요청: 010-2591-9385)
}

//2020-12-15 아이코젠
function TSaleModule.ApplyIKozen(const AReadData: string): Boolean;
var
  sBuffer: string;
  nPos: Integer;
  AMemberCode, AStoreCode, AExecId, AErrMsg, AExecTime: String;
  sHost: String;

  HC: TIdHTTP;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
  JO: TJSONObject;
  SS, RS: TStringStream;
  RBS: RawByteString;
  sUrl, sResCode, sResMsg, sStoreName, sMemberName: string;
begin
  Result := False;

  sBuffer := AReadData; //IK_1041911_1452_1_1617860670
  //sBuffer := 'IK_1041911_1452_1_1617860670';

  if (Copy(sBuffer, 1, 3) <> 'IK_') and (Copy(sBuffer, 1, 3) <> 'AK_') then
  begin
    //raise Exception.Create('유효한 아이코젠 멤버십 바코드가 아닙니다.');
    Global.SBMessage.ShowMessageModalForm('유효한 아이코젠 멤버십 바코드가 아닙니다.', True, 15);
    Exit;
  end;

  sBuffer := Copy(sBuffer, 4, Length(sBuffer) - 3); //1041911_1452_1_1617860670
  nPos := Pos('_', sBuffer);
  if (nPos > 0) then
  begin
    AMemberCode := Copy(sBuffer, 1, Pred(nPos)); //1041911
    sBuffer := Copy(sBuffer, Succ(nPos), Length(sBuffer) - nPos); //1452_1_1617860670
    nPos := Pos('_', sBuffer);
    if (nPos > 0) then
    begin
      AStoreCode := Copy(sBuffer, 1, Pred(nPos)); //1452
      sBuffer := Copy(sBuffer, Succ(nPos), Length(sBuffer) - nPos); //1_1617860670
      //AExecId := sBuffer;
      nPos := Pos('_', sBuffer); //2
      if (nPos > 0) then
      begin
        AExecId := Copy(sBuffer, 1, 1);
        AExecTime := Copy(sBuffer, Succ(nPos), Length(sBuffer) - nPos); //1617860670;
      end;

    end;
  end;

  if (AMemberCode = '') or (AStoreCode = '') or (AExecId = '') or (AExecTime = '') then
  begin
    //raise Exception.Create('유효한 아이코젠 멤버십 바코드가 아닙니다.');
    Global.SBMessage.ShowMessageModalForm('유효한 아이코젠 멤버십 바코드가 아닙니다.', True, 15);
    Exit;
  end;

  if (Global.Config.IKozen.StoreCD <> AStoreCode) then
  begin
    //XGMsgBox(Self.Handle, mtInformation, '알림', '사용할 수 없는 시설코드 입니다!', ['확인'], 5);
    Global.SBMessage.ShowMessageModalForm('사용할 수 없는 시설코드 입니다!', True, 15);
    Exit;
  end;

  try
    RS := TStringStream.Create;
    SS := nil;
    JO := nil;
    HC := TIdHTTP.Create(nil);
    SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
    try
      //if not Global.IKozen.Enabled then
        //raise Exception.Create('아이코젠 연동 설정이 되어 있지 않습니다!');

      sHost := 'https://ikozen.com/api/qrcode_enter.php';

      //sUrl := Format('%s?MID=%s&SISUL_CODE=%s&EXECID=%s', [sHost, AMemberCode, AStoreCode, AExecId]);
      sUrl := Format('%s?MID=%s&SISUL_CODE=%s&EXECID=%s&EXPT=%s', [sHost, AMemberCode, AStoreCode, AExecId, AExecTime]);
      HC.Request.CustomHeaders.Clear;
      HC.Request.ContentType := 'application/x-www-form-urlencoded';
      SSL.SSLOptions.Method := sslvSSLv23;
      SSL.SSLOptions.Mode := sslmClient;
      HC.IOHandler := SSL;
      HC.HandleRedirects:=False;
      HC.ConnectTimeout := IdTimeoutDefault;
      HC.ReadTimeout := IdTimeoutInfinite;
      HC.Request.Method := 'GET';
      HC.Get(sUrl, RS);

      RBS := PAnsiChar(RS.Memory);
      SetCodePage(RBS, 65001, False);
      JO := TJSONObject.ParseJSONValue(String(RBS)) as TJSONObject;
      SS := TStringStream.Create(JO.ToString, TEncoding.UTF8);

      //SS.SaveToFile(Global.LogDir + 'ApplyIKozen.Response.json');
      Log.D('Scan begin', String(RBS));

      sResCode := JO.GetValue('enter_ok').Value;
      sResMsg := JO.GetValue('msg').Value;
      sStoreName := JO.GetValue('sisul_name').Value;
      sMemberName := JO.GetValue('member_name').Value;

      if (sResCode <> '1') then
      begin
        AErrMsg := Format('ResultCode=%s, MemberName=%s, StoreName=%s, Message=%s',
                  [sResCode, sMemberName, sStoreName, sResMsg]);
        Global.SBMessage.ShowMessageModalForm(AErrMsg, True, 15);
        Exit;
      end;

      allianceCode := GCD_IKOZEN_CODE; //'00004'; //코드가 있어야 무료
      allianceNumber := AMemberCode;

      Result := True;
    finally
      FreeAndNil(RS);
      if Assigned(SS) then
        FreeAndNil(SS);
      if Assigned(JO) then
        FreeAndNil(JO);
      if Assigned(SSL) then
        FreeAndNil(SSL);
      HC.Disconnect;
      FreeAndNil(HC);
    end;
  except
    on E: Exception do
    begin
      AErrMsg := E.Message;
      Log.E('ApplyIKozen.Exception : ', AErrMsg);
    end;
  end
end;

function TSaleModule.ApplySmartix(const AReadData: string): Boolean;
var
  sBuffer: string;
  sHost, sToken: String;

  HC: TIdHTTP;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
  JO: TJSONObject;
  JOArr: TJSONArray;
  SS, RS: TStringStream;
  RBS: RawByteString;
  sUrl, sResCode, sResMsg: string;

  sJson: AnsiString;
begin
  Result := False;

  sBuffer := AReadData; //701002392811

  try
    SS := TStringStream.Create;
    RS := TStringStream.Create;
    SS := nil;
    JO := nil;
    HC := TIdHTTP.Create(nil);
    SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
    try

      sHost := 'https://api.ticketchannelmanager.com/api/v1/tcm/reservations/use';
      //sHost := 'http://devapi.ticketchannelmanager.com/api/v1/tcm/reservations/use';

      //Prod : https://api.ticketchannelmanager.com/api/v1/tcm/reservations/use
      //Dev : https://devapi.ticketchannelmanager.com/api/v1/tcm/reservations/use

      sUrl := sHost + '?rsSeqInspect=' + sBuffer + '&clientCompSeq=' + Global.Config.Smartix.clientCompSeq;
      { 테스트용
      sToken := 'eyJhbGciOiJIUzUxMiJ9.eyJqdGkiOiJhZTNjMjQ5Yi0zMzU0LTRkMWUtOTk3Zi1lNjRhMzY0M2I1YmYiLCJjb21wX3NlcSI6IjE3OTkiLCJjaGFubmVsX3N'+
                'lcSI6IjAiLCJ1c2VyX3NlcSI6IjEzMTAiLCJ1c2VyX2F1dGgiOlsiU0lURV9VU0VSIl0sImlhdCI6MTcwMzEzNTY0Nywic3ViIjoiVENNIiwiaXNzIjoiU01B'+
                'UlRJWCJ9.PvRSR0OP4Er0NMtNEU1bc-i6eLKCijn5INmHsT66wI-zPwcfaL2_JR-CvT-zR7dfeR_oxWJJWxe9XoD6-6wVWQ';
      }

      sToken := 'eyJhbGciOiJIUzUxMiJ9.eyJqdGkiOiIzMzQ2OGUzNy04ODQ4LTQxYjgtYWU2Ny05MjQyZWVkYTBjYjkiLCJjb21wX3NlcSI6IjE4NDIiLCJjaGFubmVsX3Nl'+
                'cSI6IjAiLCJ1c2VyX3NlcSI6IjE0NDciLCJ1c2VyX2F1dGgiOlsiU0lURV9VU0VSIl0sImlhdCI6MTcwNDM1Mzk1Niwic3ViIjoiVENNIiwiaXNzIjoiU01BUl'+
                'RJWCJ9.8Fw9AsdHsOOiSzRfoVMK390rW8MejTvvX0Q7Fm3StJ__ZLVCkPnatgfIQGByJ0ohFDZ6W2PsJhruVpLqMtYQVA';


      HC.Request.CustomHeaders.Clear;
      HC.Request.CustomHeaders.Values['Authorization'] := 'Bearer ' + sToken;
      HC.Request.ContentType := 'application/json';
      HC.Request.Accept := '*/*';
      SSL.SSLOptions.Method := sslvSSLv23;
      SSL.SSLOptions.Mode := sslmClient;
      HC.IOHandler := SSL;
      //HC.HandleRedirects:=False;
      HC.ConnectTimeout := IdTimeoutDefault;
      HC.ReadTimeout := IdTimeoutInfinite;
      HC.Request.Method := 'PATCH';
      HC.Patch(sUrl, SS, RS);

      sJson := ByteStringToString(RS);
      Log.D('ApplySmartix Respones', sJson);

      JOArr := TJSONArray.ParseJSONValue(sJson) as TJSONArray;
      JO := JOArr.Get(0) as TJSONObject;

      sResCode := JO.GetValue('code').Value;
      sResMsg := JO.GetValue('message').Value;

      if (sResCode <> '100') then
      begin
        Global.SBMessage.ShowMessageModalForm(sResMsg, True, 15);
        Exit;
      end;

      allianceCode := GCD_SMARTIX_CODE;
      allianceNumber := sBuffer;
      Result := True;
    finally
      FreeAndNil(RS);
      if Assigned(SS) then
        FreeAndNil(SS);
      if Assigned(JOArr) then
        FreeAndNil(JOArr);
      if Assigned(SSL) then
        FreeAndNil(SSL);
      HC.Disconnect;
      FreeAndNil(HC);
    end;
  except
    on E: Exception do
    begin
      Log.E('ApplySmartix.Exception : ', E.Message);
    end;
  end
end;

procedure TSaleModule.SaleDataClear;
var
  Index: Integer;
  ATeeBoxInfo: TTeeBoxInfo;
  AMemberInfo: TMemberInfo;
  AProduct: TProductInfo;
  APayData: TPayData;
begin
  try
    RcpNo := 0;
    SaleUploadFail := False;
    RcpAspNo := EmptyStr;
    IsComplete := False;
    VipDisCount := False;
    VipTeeBox := False;

    ATeeBoxInfo.TasukNo := -1;
    TeeBoxInfo := ATeeBoxInfo;

    //chy move
    TeeBoxMoveInfo := ATeeBoxInfo;
    TeeboxMenuType := tmNone;

    AMemberInfo.Code := EmptyStr;
    AMemberInfo.CardNo := EmptyStr;
    AMemberInfo.XGolfMember := False;

    Member := AMemberInfo;
    memberItemType := mitNone;
    SelectProduct := AProduct;

    //chy newmember
    NewMember := AMemberInfo;
    NewMemberItemType := mitNone;
    AdvertPopupType := apNone;
    PaymentAddType := patNone;

    if ProductList.Count <> 0 then
    begin
      for Index := ProductList.Count - 1 downto 0 do
        ProductList.Delete(Index);

      ProductList.Clear;
      ProductList.Count := 0;
    end;

    if BuyProductList.Count <> 0 then
    begin
      for Index := ProductList.Count - 1 downto 0 do
        ProductList.Delete(Index);

      BuyProductList.Clear;
      BuyProductList.Count := 0;
    end;

    if DisCountList.Count <> 0 then
    begin
      for Index := ProductList.Count - 1 downto 0 do
        ProductList.Delete(Index);

      DisCountList.Clear;
      DisCountList.Count := 0;
    end;

    if PayList.Count <> 0 then
    begin
      for Index := PayList.Count - 1 downto 0 do
      begin
        APayData := PayList[Index];
        APayData.Free;

        PayList.Delete(Index);
      end;

      PayList.Clear;
      PayList.Count := 0;
    end;

    if ParkingProductList.Count <> 0 then
    begin
      for Index := ParkingProductList.Count - 1 downto 0 do
        ParkingProductList.Delete(Index);

      ParkingProductList.Clear;
      ParkingProductList.Count := 0;
    end;

    //체크인
    if CheckInList.Count <> 0 then
    begin
      for Index := CheckInList.Count - 1 downto 0 do
        CheckInList.Delete(Index);

      CheckInList.Clear;
      CheckInList.Count := 0;
    end;

    PopUpLevel := plNone;
    PopUpFullLevel := pflNone;

    TotalAmt := 0;
    VatAmt := 0;
    DCAmt := 0;
    RealAmt := 0;
    MiniMapCursor := False;

    PrepareMin := StrToIntDef(Global.Config.PrePare_Min, 5);

    SelectHalbu := 1;
    if Global.SaleModule.SaleDate <> FormatDateTime('yyyymmdd', now) then
      Global.SaleModule.SaleDate := FormatDateTime('yyyymmdd', now);

    TeeboxTimeError := False;

    CardApplyType := catNone;
    PromotionType := pttNone;

    allianceCode := EmptyStr;
    allianceNumber := EmptyStr;
    CouponMember := False;

    //2020-12-29 라카만료일
    FLockerEndDay := EmptyStr;

    FStoreCloseOver := False;
    FStoreCloseOverMin := EmptyStr;
    FSendPrintError := False;

    //제휴사 테스트
    FProductCdWellbeing := EmptyStr;
    FWellbeingApprovalkey := EmptyStr;
    FProductCdTheloungemembers := EmptyStr;
    FProductCdBCPaybookGolf := EmptyStr;
    FProductCdRefreshclub := EmptyStr;
    FProductCdIkozen := EmptyStr;
  except
    on E: Exception do
    begin
      Log.E('SaleDataClear', E.Message);
    end;
  end;
end;

function TSaleModule.SearchMember(ACode: string): TMemberInfo;
var
  Index: Integer;
  Msg, ADate: string;
  AMember: TMemberInfo;
  AddMember: Boolean;
begin
  // ASP Version인경우 QR Code로 검색
  Result := AMember;
  AddMember := False;

  // 양평 KIOSK 스캐너 리딩시 첫자리가 I로 읽혀짐
  if Global.Config.Store.StoreCode = 'A2001' then
  begin
    //Scan Barcode	¹000153927
    //Scan Barcode	I?00153927
    //Scan Barcode	¹000072526
    Log.D('SearchMember QRCode 변경 전', ACode);
    //ACode := 'M-' + Copy(ACode, 3, Length(ACode));
    ACode := '10' + Copy(ACode, 3, Length(ACode));
    Log.D('SearchMember QRCode 변경 후', ACode);
  end;

  for Index := 0 to MemberUpdateList.Count - 1 do
  begin
    if MemberUpdateList[Index].CardNo = ACode then
    begin
      Result := MemberUpdateList[Index];
      AddMember := True;
      Log.D('Member Search QR MemberUpdateList Count : ', IntToStr(MemberUpdateList.Count));
    end;
  end;

  if not AddMember then
  begin
    for Index := 0 to MemberList.Count - 1 do
    begin
      if MemberList[Index].CardNo = ACode then
      begin
        Result := MemberList[Index];
        Log.D('Member Search QR MemberList Count : ', IntToStr(MemberList.Count));
      end;
    end;
  end;

  if Result.Code <> EmptyStr then
  begin
    Global.SaleModule.CouponMember := True;
  end;

end;

function TSaleModule.SearchRFIDMember(ACode: string): TMemberInfo;
var
  Index: Integer;
  Msg, ADate: string;
  AMember: TMemberInfo;
  AddMember: Boolean;
begin
  Result := AMember;
  AddMember := False;

  for Index := 0 to MemberUpdateList.Count - 1 do
  begin
    if MemberUpdateList[Index].MemberCardUid = ACode then
    begin
      Result := MemberUpdateList[Index];
      AddMember := True;
      Log.D('Member Search RFID MemberUpdateList Count : ', IntToStr(MemberUpdateList.Count));
    end;
  end;

  if not AddMember then
  begin
    for Index := 0 to MemberList.Count - 1 do
    begin
      if MemberList[Index].MemberCardUid = ACode then
      begin
        Result := MemberList[Index];
        Log.D('Member Search RFID MemberList Count : ', IntToStr(MemberList.Count));
      end;
    end;
  end;
end;

function TSaleModule.SearchPhoneMember(ACode: string): TMemberInfo;
var
  Index: Integer;
  Msg, ADate: string;
  AMember: TMemberInfo;
  AddMember: Boolean;
begin
  Result := AMember;
  AddMember := False;

  for Index := 0 to MemberUpdateList.Count - 1 do
  begin
    if MemberUpdateList[Index].Tel_Mobile = ACode then
    begin
      Result := MemberUpdateList[Index];
      AddMember := True;
      Log.D('Member Search Phone MemberUpdateList Count : ', IntToStr(MemberUpdateList.Count));
    end;
  end;

  if not AddMember then
  begin
    for Index := 0 to MemberList.Count - 1 do
    begin
      if MemberList[Index].Tel_Mobile = ACode then
      begin
        Result := MemberList[Index];
        Log.D('Member Search Phone MemberList Count : ', IntToStr(MemberList.Count));
      end;
    end;
  end;
end;

function TSaleModule.AllianceProductCheck(AAllianceType: Integer): Boolean;
var
  Index: Integer;
  StartTime, EndTime, NowTime, AMemberType, UserSex: string;
  AProduct: TProductInfo;
  sAllianceProductCd: String;
begin
  Result := False;

  sAllianceProductCd := EmptyStr;
  if AAllianceType = 0 then //웰빙
    sAllianceProductCd := Global.SaleModule.FProductCdWellbeing
  else if AAllianceType = 1 then
    sAllianceProductCd := Global.SaleModule.FProductCdBCPaybookGolf
  else if AAllianceType = 2 then
    sAllianceProductCd := Global.SaleModule.FProductCdRefreshclub
  else if AAllianceType = 3 then
    sAllianceProductCd := Global.SaleModule.FProductCdTheloungemembers
  else if AAllianceType = 4 then
    sAllianceProductCd := Global.SaleModule.FProductCdIkozen;

  if sAllianceProductCd = EmptyStr then
    Exit;

  for Index := 0 to SaleList.Count - 1 do
  begin

    AProduct := SaleList[Index];

    if AProduct.Code = sAllianceProductCd then
    begin
      {
      //2021-06-23 제휴사 상품 마감종료시간 체크
      if Global.Config.AD.USE = True then
      begin
        if StoreCloseTmCheck(AProduct) = True then
        begin
          Exit;
        end;
      end;
      }
      if AddProduct(AProduct) = False then
        Exit;

      Log.D('제휴상품', '-----------------------------------------------------');
      Log.D('제휴상품', AProduct.Code);
      Log.D('제휴상품', AProduct.Name);
      Log.D('제휴상품', AProduct.Start_Time);
      Log.D('제휴상품', AProduct.End_Time);
      Log.D('제휴상품', '-----------------------------------------------------');

      Result := True;
      break;
    end;

  end;
end;

function TSaleModule.AdvertReceiptView(AType: String): Boolean;
var
  sTemp: String;
  i, nIdx, nStart, nEnd: Integer;
  AdvertReceipt: TAdvertReceipt;
begin
  Result := False;

  if AdvertListReceipt.Count = 0 then
  begin
    Log.D('AdvertReceiptView', '광고없음 count 0');
    Exit;
  end;

  if AType = 'PRINT' then
  begin
    for i := 0 to AdvertListReceipt.Count - 1 do
      FAdvertReceiptPrintList[i] := AdvertReceipt;

    for i := 0 to AdvertListReceipt.Count - 1 do
    begin
      nStart := StrToInt(AdvertListReceipt[i].TeeboxStartNm);
      nEnd := StrToInt(AdvertListReceipt[i].TeeboxEndNm);

      if (nStart > TeeBoxInfo.TasukNo) then
      begin
        Log.D('AdvertReceiptView', 'Start fail');
        Continue;
      end;

      if (nEnd < TeeBoxInfo.TasukNo) then
      begin
        Log.D('AdvertReceiptView', 'EndNm fail');
        Continue;
      end;

      if (AdvertListReceipt[i].FilePath2 = EmptyStr) then //출력문구
      begin
        Log.D('AdvertReceiptView', 'FilePath2 : No');
        Continue;
      end;

      // PRINT / POPUP
      AdvertReceipt := Global.Database.SendAdvertisReceiptCnt(IntToStr(AdvertListReceipt[i].Seq), AType);
      FAdvertReceiptPrintList[i] := AdvertReceipt;

      Result := True;
    end;
  end
  else
  begin
    for i := 0 to AdvertListReceipt.Count - 1 do
      FAdvertReceiptPopupList[i] := AdvertReceipt;

    nIdx := Global.SaleModule.AdvertListReceiptIdx;
    nStart := StrToInt(AdvertListReceipt[nIdx].TeeboxStartNm);
    nEnd := StrToInt(AdvertListReceipt[nIdx].TeeboxEndNm);

    if (nStart > TeeBoxInfo.TasukNo) then
    begin
      Log.D('AdvertReceiptView', 'Start fail');
      Exit;
    end;

    if (nEnd < TeeBoxInfo.TasukNo) then
    begin
      Log.D('AdvertReceiptView', 'EndNm fail');
      Exit;
    end;

    if (AdvertListReceipt[nIdx].FilePath = EmptyStr) then //이미지
    begin
      Log.D('AdvertReceiptView', 'FilePath : No');
      Exit;
    end;

    // PRINT / POPUP
    AdvertReceipt := Global.Database.SendAdvertisReceiptCnt(IntToStr(AdvertListReceipt[nIdx].Seq), AType);
    FAdvertReceiptPopupList[nIdx] := AdvertReceipt;

    Result := True;
  end;

end;

function TSaleModule.SetCheckInPrintData: string;
var
  Index, VatAmt: Integer;
  Main, Store, Order, MemberObJect, Receipt, JsonItem: TJSONObject;
  ProductList, Discount, PayList, OrderList: TJSONArray;
  ACard: TPayCard;
  APayco: TPayPayco;
  I: Integer;
begin
  Main := TJSONObject.Create;
  Store := TJSONObject.Create;
  MemberObJect := TJSONObject.Create;
  Receipt := TJSONObject.Create;

  OrderList := TJSONArray.Create;
  ProductList := TJSONArray.Create;
  Discount := TJSONArray.Create;
  PayList := TJSONArray.Create;

  try
    try
//      Log.D('프린터 JSON Begin', Result);

      Main.AddPair(TJSONPair.Create('StoreInfo', Store));
      Main.AddPair(TJSONPair.Create('OrderList', OrderList));
      Main.AddPair(TJSONPair.Create('ReceiptMemberInfo', MemberObJect));
      Main.AddPair(TJSONPair.Create('ProductInfo', ProductList));
      Main.AddPair(TJSONPair.Create('PayInfo', PayList));
      Main.AddPair(TJSONPair.Create('DiscountInfo', Discount));
      Main.AddPair(TJSONPair.Create('ReceiptEtc', Receipt));

      Store.AddPair(TJSONPair.Create('StoreName', Global.Config.Store.StoreName));
      Store.AddPair(TJSONPair.Create('BizNo', Global.Config.Store.BizNo));
      Store.AddPair(TJSONPair.Create('BossName', Global.Config.Store.BossName));
      Store.AddPair(TJSONPair.Create('Tel', Global.Config.Store.Tel));
      Store.AddPair(TJSONPair.Create('Addr', Global.Config.Store.Addr));


      for I := 0 to CheckInList.Count - 1 do
      begin
        // 키오스크는 1개 POS는 반복문 사용
        JsonItem := TJSONObject.Create;
        JsonItem.AddPair(TJSONPair.Create('TeeBox_Floor', CheckInList[I].floor_nm));

        JsonItem.AddPair(TJSONPair.Create('TeeBox_Nm', CheckInList[I].teebox_nm));
        JsonItem.AddPair(TJSONPair.Create('Parking_Barcode', CheckInList[I].reserve_datetime));
        JsonItem.AddPair(TJSONPair.Create('ProductDiv', CheckInList[I].product_div));
        JsonItem.AddPair(TJSONPair.Create('UseTime', CheckInList[I].start_datetime));
        JsonItem.AddPair(TJSONPair.Create('One_Use_Time', CheckInList[I].remain_min));
        JsonItem.AddPair(TJSONPair.Create('Reserve_No', CheckInList[I].reserve_no));

        //라카만기일
        //JsonItem.AddPair(TJSONPair.Create('Locker_End_Day', ''));
        JsonItem.AddPair(TJSONPair.Create('Locker_End_Day', Global.SaleModule.FLockerEndDay));

        // 아래 5개는 쿠폰에 관련된 내용
        JsonItem.AddPair(TJSONPair.Create('UseProductName', CheckInList[I].product_nm));
        JsonItem.AddPair(TJSONPair.Create('Coupon', TJSONBool.Create(False).ToString)); // 쿠폰 사용 여부
        JsonItem.AddPair(TJSONPair.Create('CouponQty', TJSONNumber.Create(CheckInList[I].coupon_cnt)));  // 잔여 쿠폰 수
        JsonItem.AddPair(TJSONPair.Create('CouponUseDate', ''));
        JsonItem.AddPair(TJSONPair.Create('ExpireDate', DateTimeSetString(CheckInList[I].expire_day)));
        OrderList.Add(JsonItem);

        MemberObJect.AddPair(TJSONPair.Create('Name', CheckInList[I].member_nm));
        MemberObJect.AddPair(TJSONPair.Create('Code', CheckInList[I].member_no));
        //MemberObJect.AddPair(TJSONPair.Create('Tel', Member.Tel_Mobile));
        //MemberObJect.AddPair(TJSONPair.Create('CarNo', Member.CarNo));
        //MemberObJect.AddPair(TJSONPair.Create('CardNo', Member.CardNo));
        //MemberObJect.AddPair(TJSONPair.Create('MemberXGOLF', TJSONBool.Create(Global.SaleModule.Member.XGolfMember)));
        //MemberObJect.AddPair(TJSONPair.Create('XGolfDiscountAmt', TJSONNumber.Create(Global.SaleModule.XGolfDCAmt)));

      end;

      Receipt.AddPair(TJSONPair.Create('SaleDate', FormatDateTime('yyyy-mm-dd', now)));
      
      Result := Main.ToString;

      Log.D('프린터 JSON', Result);
    finally
      Main.Free;
    end;
  except
    on E: Exception do
    begin
      Log.E('프린터 JSON', E.Message);
    end;
  end;
end;

{ TPayData }

constructor TPayData.Create;
begin

end;

destructor TPayData.Destroy;
begin

  inherited;
end;

{ TPayCard }

constructor TPayCard.Create;
begin
  inherited;
  FPayType := ptCard;
  CardDiscount := 0;
end;

destructor TPayCard.Destroy;
begin

  inherited;
end;

function TPayCard.PayAmt: Currency;
begin
  Result := SendInfo.SaleAmt;
end;

function TPayCard.PayType: TPayTyepe;
begin
  Result := FPayType;
end;

{ TPayPayco }

constructor TPayPayco.Create;
begin
  inherited;
  FPayType := ptPayco;
end;

destructor TPayPayco.Destroy;
begin

  inherited;
end;

function TPayPayco.PayAmt: Currency;
begin
  Result := SendInfo.PayAmt;
end;

function TPayPayco.PayType: TPayTyepe;
begin
  Result := FPayType;
end;

{ TMasterDownThread }
{
constructor TMasterDownThread.Create;
begin
  FreeOnTerminate := False;
  inherited Create(True);
  FAdvertis := 0;
end;

destructor TMasterDownThread.Destroy;
begin
//  Terminate;
//  Waitfor;
  inherited;
end;

procedure TMasterDownThread.Execute;
var
  AVersion: string;
begin
  inherited;

  while not Terminated do
  begin
    if Global.SaleModule.TeeBoxInfo.TasukNo = -1 then
    begin
      // CheckIntro : 인트로가 아닐경우 확인. ChangBottomImg 과 충돌. 인트로 인경우 목록 확인해야 하는게 아닌지... MasterDownThread 주석처리
      if (FAdvertis >= 2) and CheckIntro then
      begin
        AVersion := Global.Database.GetAdvertisVersion;
        if Global.Config.Version.AdvertisVersion <> AVersion then
        begin
          Global.Config.Version.AdvertisVersion := AVersion;
          Synchronize(Global.Database.SearchAdvertisList);
        end;
        FAdvertis := 0;
      end;
      Sleep(1200000); // 20분 딜레이 최대 40분 이후 적용
      Inc(FAdvertis);
    end;
  end;
end;
}
{ TSoundThread }

constructor TSoundThread.Create;
begin
  FreeOnTerminate := False;
  inherited Create(True);
  SoundList := TList<string>.Create;
end;

destructor TSoundThread.Destroy;
begin
  SoundList.Free;
  inherited;
end;

procedure TSoundThread.Execute;
begin
  inherited;
  while not Terminated do
  begin

    try

      if SoundList.Count <> 0 then
      begin
        PlaySound(StringToOLEStr(SoundList[0]), 0, SND_SYNC);
        SoundList.Delete(0);
      end
      else
        Suspend;
      Sleep(300);

    except
      on e: Exception do
      begin
        Log.E('TSoundThread.Execute', E.Message);
      end;
    end;

  end;
end;

end.
