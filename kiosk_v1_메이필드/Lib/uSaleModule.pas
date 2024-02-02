unit uSaleModule;

interface

uses
  uConsts, uPrint, CPort, JSON, VCL.Forms, IdHTTP, System.Classes, Math, mmsystem,
  uStruct, System.SysUtils, IdGlobal, IdSSL, IdSSLOpenSSL, System.UITypes, System.DateUtils,
  Generics.Collections, Uni, uVanDeamonModul, uPaycoNewModul, IdComponent, IdTCPConnection, IdTCPClient,
  IdURI,
  //union
  uUCBioBSPHelper;

type
  TPayTyepe = (ptNone, ptCash, ptCard, ptPayco, ptVoid);

  TSoundThread = class(TThread)
  private
  protected
    procedure Execute; override;
  public
    SoundList: TList<string>;
    constructor Create;
    destructor Destroy; override;
  end;
  { //������ ���濩�� Ȯ�� - ntdll ������ ���� �Ͻû������ 2021-08-26
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
  // ��������
  TPayData = class
  private
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function PayType: TPayTyepe; virtual; abstract;
    function PayAmt: Currency; virtual; abstract;
//    // ���� �� ���� ����Ÿ�� DB�� �����Ѵ�.
  end;

  TPayCard = class(TPayData)
  private
  public
    // ��������
    SendInfo: TCardSendInfoDM;
    // ��������
    RecvInfo: TCardRecvInfoDM;
    // ����ī�� ����
    IsEyCard: Boolean;
    // ��������
    FPayType: TPayTyepe;
    // ī��� ���� �ݾ�
    CardDiscount: Currency;
    constructor Create; override;
    destructor Destroy; override;
    function PayAmt: Currency; override;
    function PayType: TPayTyepe; override;
  end;

  TPayPayco = class(TPayData)
  private
  public
    // ��������
    SendInfo: TPaycoNewSendInfo;
    // ��������
    RecvInfo: TPaycoNewRecvInfo;
    // ��������
    FPayType: TPayTyepe;
    constructor Create; override;
    destructor Destroy; override;
    function PayAmt: Currency; override;
    function PayType: TPayTyepe; override;
  end;

  TSaleModule = class
  private
    // ��׶��� ������ ����
    //FMasterDownThread: TMasterDownThread;
    // ����
    FSoundThread: TSoundThread;
    // ���α׷� ��� ���� ����
    FProgramUse: Boolean;
    // ���� DB or ���� ���� ����
    FSaveFailMessage: Boolean;
    // �Ǹ���
    FSaleDate: string;
    // ������ ��ȣ
    FRcpNo: Integer;
    FRcpAspNo: string;
    // ��ü ȸ�� ����
    FMemberList: TList<TMemberInfo>;
    FMemberUpdateList: TList<TMemberInfo>;
    // �Ǹ� ��ǰ ����
    FSaleList: TList<TProductInfo>;
    // ������Ȳ ���� ����Ʈ
    FMainItemList: TList<TTeeBoxInfo>;
    FMainItemMapUse: Boolean;

    // ���� ȸ��
    FMember: TMemberInfo;
    // ȸ���� ��밡���� ��ǰ ���
    FProductList: TList<TProductInfo>;
    // ȸ���� ���� ��ǰ
    FSelectProduct: TProductInfo;            // ������ ���ٸ� List�� ������.
    // ȸ�� ���� ���
    FBuyProductList: TList<TSaleData>;
    // ��������
    FDisCountList: TList<TDiscount>;
    // ��������
    FPayList: TList<TPayData>;
    // ���� �ð�
    FSelectTime: TDateTime;
    // �Һ� ����
    FSelectHalbu: Integer;
    // VIP ZONE ����
    //FVipTeebox: Boolean;                     // ���߼��ý� VIPŸ���� ��� �� �� �ΰ�?
    // ������ ���� ����
    FSaleUpload: Boolean;
    // ��ü Ÿ�� ����(������ ����)
    FAllTeeBoxShow: Boolean;
    // ���� ����Ʈ
    FAdvertisementListUp: TList<TAdvertisement>;
    FAdvertisementListDown: TList<TAdvertisement>;

    // �������� ���� ��ǰ ����Ʈ
    FParkingProductList: TList<TProductInfo>;

    // �˾�
    // Ÿ�� ����
    FPopUpLevel: TPopUpLevel;
    // ��üȭ�� �˾�
    FPopUpFullLevel: TPopUpFullLevel;
    // ȸ�� ���� ���� �Ⱓ/����/����
    FmemberItemType: TMemberItemType;
    // ȸ���� ������ Ÿ�� ����
    FTeeBoxInfo: TTeeBoxInfo;

    // Ÿ�� ������Ȯ Ÿ��
    FTeeBoxSortType: TTeeBoxSortType;
    // ī����� ����
    FCardApplyType: TCardApplyType;

    FPrint: TReceiptPrint;
    //Van
    FVanModule: TVanDeamonModul;
    // Payco
    FPaycoModule: TPaycoNewModul;

    // Union
    FUCBioBSPHelper: TUCBioBSPHelper;

    FTotalAmt: Currency;   // �Ǹűݾ�
    FRealAmt: Currency;    // ���Ǹűݾ�
    FVatAmt: Currency;     // �ΰ�����
    FDCAmt: Currency;      // ���αݾ�
    FRealSumAmt: Currency; // �Ǹ���
    FXGolfDCAmt: Currency; // XGolf���αݾ�

    FIsComplete: Boolean;
    FVipDisCount: Boolean;
    FMiniMapCursor: Boolean;
    FPrepareMin: Integer;

    FTeeboxTimeError: Boolean;

    // ���� ȸ�� ��ȸ
    FCouponMember: Boolean;

    //���� �������
    FNexpaParkList: String;

    function GetVanCode: string;
    function GetRcpNo: Integer;
  public
    // �ӽ� ȸ�� ��Ͻ� ����� ����
//    FingerStr: UTF8String;
    FingerStr: string;
    ConfigJsonText: string;
    // ȸ�� ���� ���� �ð�
    //MemberInfoDownLoadDateTime: string;
    NowHour: string;
    NowTime: string;
    // �̴ϸ� width
    MiniMapWidth: Integer;

    // ���޻� ��� �ڵ�
    FallianceCode: string;  //������ ��±���
    FallianceNumber: string;

    //2020-12-29 ��ī������
    FLockerEndDay: String;

    FStoreCloseOver: Boolean;
    FStoreCloseOverMin: String;
    FSendPrintError: Boolean;

    //���޻� �׽�Ʈ
    //FProductCdWellbeing: String;
    //FProductCdTheloungemembers: String;
    //FProductCdBCPaybookGolf: String;
    //FProductCdRefreshclub: String;
    //FProductCdIkozen: String;

    constructor Create;
    destructor Destroy; override;

    function OAuthCheck: Boolean;
    // ���� üũ
    function MasterReception(AType: Integer = 0): Boolean;
    function SaleCompleteProc: Boolean;
    function SetPrintData: string;
    function SearchMember(ACode: string): TMemberInfo;
    function SearchRFIDMember(ACode: string): TMemberInfo; //RFID
    function AddProduct(AProduct: TProductInfo): Boolean;
    function MinusProduct(AProduct: TProductInfo): Boolean;
    function DeleteProduct(AIndex: Integer): Boolean;

    procedure CallEmp;
    procedure SaleDataClear;
    procedure BuyListClear;
    procedure Calc;
    function AddCheckPromotionType(ACode: string): Boolean;
    function AddCheckDiscount(AProductDiv, AProductDivDetail: string; AGubun: Integer): Boolean;
    function AddChectDiscountAmt(AValue: Integer): Boolean;
    function AddCheckDiscountQR(AQRCode: string): Boolean;
    function AddCheckDiscountProductDiv(ACode: string): Boolean;    // �ʿ��Ѱ�?
    function SetDiscount: Boolean;
    // ����1���� ����1��
    function SetDiscount_Item: Boolean;
    // ����1���� ���� �ݾ׸�ŭ ����
    function SetDiscount_Item_ver2: Boolean;
    function DeleteDiscount(AQRCode: string): Boolean;
    // ī��� ������� ����
    function CardDiscountDelete: Boolean;
    // ī��� ������� SEQ
    function CardDiscountGetCode: string;

    // �غ�ð� �߰�
    function SetPrepareMin: Boolean;

    // ������
    function GetMemberList: Boolean;
    //function GetConfig: Boolean;
    function GetProductList: Boolean;
    function GetTeeBoxInfo: Boolean;
    function GetPlayingTeeBoxList: Boolean;

    function DeviceInit: Boolean;
    // ī�� ���� ��ȸ
    function CallCardInfo: string;
    // ī�� ����
    function CallCard(ACardBin, ACode, AMsg: string; ADiscountAmt: Currency; IsAppCard: Boolean = False): TCardRecvInfoDM;
    // PAYCO ����
    function CallPayco: TPaycoNewRecvInfo;

    // �������� �հ�
    function GetSumPayAmt(APayType: TPayTyepe): Currency;

    // ����ȣ��
    function CallAdmin: Boolean;
    //function CallIntroBlack: Boolean;

    // Ÿ���ð� üũ
    function TeeboxTimeCheck: Boolean;

    property ProgramUse: Boolean read FProgramUse write FProgramUse;
    property SaleDate: string read FSaleDate write FSaleDate;
    property RcpNo: Integer read FRcpNo write FRcpNo;
    property RcpAspNo: string read FRcpAspNo write FRcpAspNo;
    property Member: TMemberInfo read FMember write FMember;
    property MemberList: TList<TMemberInfo> read FMemberList write FMemberList;
    property MemberUpdateList: TList<TMemberInfo> read FMemberUpdateList write FMemberUpdateList;
    property memberItemType: TMemberItemType read FmemberItemType write FmemberItemType;

    property TeeBoxInfo: TTeeBoxInfo read FTeeBoxInfo write FTeeBoxInfo;
    property SelectProduct: TProductInfo read FSelectProduct write FSelectProduct;

    property ProductList: TList<TProductInfo> read FProductList write FProductList;
    property SaleList: TList<TProductInfo> read FSaleList write FSaleList;
    property BuyProductList: TList<TSaleData> read FBuyProductList write FBuyProductList;
    property DisCountList: TList<TDiscount> read FDisCountList write FDisCountList;
    property PayList: TList<TPayData> read FPayList write FPayList;
    property MainItemList: TList<TTeeBoxInfo> read FMainItemList write FMainItemList;
    property AdvertisementListUp: TList<TAdvertisement> read FAdvertisementListUp write FAdvertisementListUp;
    property AdvertisementListDown: TList<TAdvertisement> read FAdvertisementListDown write FAdvertisementListDown;
    property ParkingProductList: TList<TProductInfo> read FParkingProductList write FParkingProductList;

    property PopUpLevel: TPopUpLevel read FPopUpLevel write FPopUpLevel;
    property PopUpFullLevel: TPopUpFullLevel read FPopUpFullLevel write FPopUpFullLevel;

    property Print: TReceiptPrint read FPrint write FPrint;

    property VanModule: TVanDeamonModul read FVanModule write FVanModule;
    property PaycoModule: TPaycoNewModul read FPaycoModule write FPaycoModule;

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
    //property VipTeeBox: Boolean read FVipTeeBox write FVipTeeBox;
    property SaleUploadFail: Boolean read FSaleUpload write FSaleUpload;
    property AllTeeBoxShow: Boolean read FAllTeeBoxShow write FAllTeeBoxShow;
    property MainItemMapUse: Boolean read FMainItemMapUse write FMainItemMapUse;
    property MiniMapCursor: Boolean read FMiniMapCursor write FMiniMapCursor;
    //property MasterDownThread: TMasterDownThread read FMasterDownThread write FMasterDownThread;
    property SoundThread: TSoundThread read FSoundThread write FSoundThread;
    property TeeboxTimeError: Boolean read FTeeboxTimeError write FTeeboxTimeError;
    property CardApplyType: TCardApplyType read FCardApplyType write FCardApplyType;

    property allianceCode: string read FallianceCode write FallianceCode;  //������ ��±���
    property allianceNumber: string read FallianceNumber write FallianceNumber;
    property CouponMember: Boolean read FCouponMember write FCouponMember;

    property NexpaParkList: String read FNexpaParkList write FNexpaParkList;
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
    Log.D('AddProduct', AProduct.Code + '-' + AProduct.Name);
    Result := False;
    IsAdd := False;

    if (memberItemType = mitDay) and (BuyProductList.Count > 0) then
    begin
      Global.SBMessage.ShowMessageModalForm(MSG_DAY_PRODUCT_ONE);
      Exit;
      Result := True;
    end;

    for Index := 0 to BuyProductList.Count - 1 do
    begin
      if BuyProductList[Index].Products.Code = AProduct.Code then
      begin
        ASaleData := BuyProductList[Index];
        ASaleData.SaleQty := ASaleData.SaleQty + 1;
        ASaleData.DcAmt := 0;   // ���� ���

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
      ASaleData.DcAmt := 0;
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
          Log.D('CardDiscountDelete', 'ī��� ���� ����.');
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

//  SetDiscount_Item;
  SetDiscount_Item_ver2; //����
  AddTotalDCAmt := 0;

  for Index := 0 to BuyProductList.Count - 1 do
    AddTotalDCAmt := AddTotalDCAmt + Trunc(BuyProductList[Index].DcAmt);

  for Index := 0 to DisCountList.Count - 1 do
  begin
    if DisCountList[Index].Gubun = 998 then
    begin
      ADiscount := DisCountList[Index];
      ADiscount.ApplyAmt := ADiscount.Value;
      // ����� �ݾ�
      AddDCAmt := ADiscount.ApplyAmt;
      DisCountList[Index] := ADiscount;
//      AddTotalDCAmt := AddTotalDCAmt + DisCountList[Index].ApplyAmt;
    end;
  end;

//  if (PayList.Count = 1) and (AddDCAmt <> 0) then
//  begin
//    if PayList[0].PayType = ptCard then
//    begin
//      APayCard := TPayCard(PayList[0]);
//      APayCard.CardDiscount := AddDcAmt;
//      PayList[0] := APayCard;
//    end;
//  end;

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

function TSaleModule.AddCheckDiscountProductDiv(ACode: string): Boolean;
var
  Index: Integer;
begin
  try
    Result := False;
    for Index := 0 to BuyProductList.Count - 1 do
    begin
      if (BuyProductList[Index].DcAmt = 0) and (BuyProductList[Index].Products.Product_Div = ACode) then
        Result := True;
    end;
  finally

  end;
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

    // ���αݾ� 0���� �ʱ�ȭ
    for Index := 0 to BuyProductList.Count - 1 do
    begin
      ASaleData := BuyProductList[Index];
      ASaleData.DcAmt := 0;
      BuyProductList[Index] := ASaleData;    
    end;

    // ���� ����
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
    // ���� ������ ����
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
                  ASaleData.DcAmt := ASaleData.DcAmt + ((ASaleData.SalePrice / ASaleData.SaleQty) * ADiscount.Value) * 0.01;
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

                // ApplyAmt Ȯ�� �ʿ�
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
    // ���� ������ ����
    DisCountList := SortDiscountType;

    for AIndex := 0 to 2 - 1 do
    begin
      if AIndex = 0 then
      begin // fmx�ͽ�������
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
                  if (ADiscount.Product_Div_Detail = BuyProductList[Loop].Products.Product_Div) or
                    (ADiscount.Product_Div = 'A') or (ADiscount.Product_Div = 'S') then
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

                if ((ASaleData.SalePrice / ASaleData.SaleQty) - ASaleData.DcAmt) = 0 then
                  Continue;

                AddDcAmt := ((ASaleData.SalePrice / ASaleData.SaleQty) * ADiscount.Value) * 0.01;
                if (ASaleData.SalePrice / ASaleData.SaleQty) - (ASaleData.DcAmt + AddDcAmt) < 0 then
                  ADiscount.ApplyAmt := Trunc((ASaleData.SalePrice / ASaleData.SaleQty) - ASaleData.DcAmt)
                else
                  ADiscount.ApplyAmt := Trunc(AddDcAmt);

                ASaleData.DcAmt := ASaleData.DcAmt + AddDcAmt;
                ADiscount.Add := True;

                if (ADiscount.ApplyAmt <> 0) and (ADiscount.ApplyAmt > 0) then
                  ASaleData.DiscountList.Add(ADiscount);
                BuyProductList[MaxSalePriceIndex] := ASaleData;
                DisCountList[Index] := ADiscount;
              end;
            end;
          end;
        end;
      end
      else
      begin // 999: XGOLF, 998: ī���
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
              if (BuyProductList[Loop].Products.Product_Div = ADiscount.Product_Div_Detail) or
                (ADiscount.Product_Div = 'A') or (ADiscount.Product_Div = 'S') then
              begin
                ASaleData := BuyProductList[Loop];
                SaleDcAmt := BuyProductList[Loop].SalePrice - BuyProductList[Loop].DCAmt;

                if SaleDcAmt = 0 then
                  Continue;

                // ApplyAmt Ȯ�� �ʿ�
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

function TSaleModule.CallAdmin: Boolean;
var
  Indy: TIdTCPClient;
  Msg, sBuffer: string;
  JO: TJSONObject;
begin

  Result := False;
  Global.SBMessage.ShowMessageModalForm2(MSG_PRINT_ADMIN_CALL, True, 30, True, True);
  Result := True;
end;
{
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
        //Global.SBMessage.ShowMessageModalForm(MSG_ADMIN_CALL_FAIL);
    end;
  finally
    Indy.Free;
  end;
end;
}
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

      if Length(ACardBin) >= 30 then
        ADiscountInfo.Name := 'BCī�� ���� ����'
      else
        ADiscountInfo.Name := '����ī�� ���� ����';

      ADiscountInfo.Gubun := 998;

      if ADiscountAmt <> 0 then
      begin
        Log.D('ī������ - ��������', ARecvInfo.CardBinNo + FormatFloat('#,##0.##', ADiscountAmt));
        ADiscountInfo.QRCode := ACode;
        ADiscountInfo.Value := Trunc(ADiscountAmt);
        Global.SaleModule.DisCountList.Add(ADiscountInfo);
        Calc;
        ACard.CardDiscount := Trunc(ADiscountAmt);
      end
      else  // ���� ��� �ƴ�
      begin
        Log.D('ī������ ���� ��� �ƴ� - ���αݾ� 0', ACardBin);
        Log.D('ī������ ���� ��� �ƴ�', ACode);
        Log.D('ī������ ���� ��� �ƴ�', AMsg);
      end;
    end
    else
    begin
      Log.D('ī������ ���� ��� �ƴ�', ARecvInfo.CardBinNo);
      Log.D('ī������ ���� ��� �ƴ�', ACode);
      Log.D('ī������ ���� ��� �ƴ�', AMsg);
    end;

    Log.D('ī����� Bin, OTC', ACard.SendInfo.CardBinNo + ':' + ACard.SendInfo.OTCNo);

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

    Sleep(50);
    {$IFDEF RELEASE}
    //ACard.RecvInfo.Result := True;
    //ACard.RecvInfo.AgreeNo := '0001';

    //chy test
    ACard.RecvInfo := VanModule.CallCard(ACard.SendInfo);
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

    Log.D('TSaleModule.CallCard', 'End');
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
      GoodsNm := GoodsNm + '�� ' + IntToStr(BuyProductList.Count - 1);

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
  DisCountList := TList<TDiscount>.Create;
  PayList := TList<TPayData>.Create;
  MainItemList := TList<TTeeBoxInfo>.Create;
  AdvertisementListUp := TList<TAdvertisement>.Create;
  AdvertisementListDown := TList<TAdvertisement>.Create;
  ParkingProductList := TList<TProductInfo>.Create;

//  LastHoldNo := 0;
  //VipTeeBox := False;
  SaleUploadFail := False;
  AllTeeBoxShow := False;
  MainItemMapUse := False;
  TeeBoxSortType := tstDefault;
  MiniMapCursor := False;
  //MasterDownThread := TMasterDownThread.Create;
  SoundThread := TSoundThread.Create;
  //MemberInfoDownLoadDateTime := EmptyStr;
  NowHour := EmptyStr;
  NowTime := EmptyStr;
  MiniMapWidth := 0;
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

    if DisCountList <> nil then
      DisCountList.Free;

    if PayList <> nil then
      PayList.Free;

    //if (MainItemList <> nil) then // ��������
      //MainItemList.Free;

    if AdvertisementListUp <> nil then
      AdvertisementListUp.Free;

    if AdvertisementListDown <> nil then
      AdvertisementListDown.Free;

    if ParkingProductList <> nil then
      ParkingProductList.Free;

    if not Global.Config.NoPayModule then
    begin
      VanModule.Free;
      PaycoModule.Free;
    end;

    if not Global.Config.NoDevice then
    begin
      if Global.Config.Fingerprint = 'UNION' then
        UCBioBSPHelper.Free;

      Print.Free;
    end;

    {
    if FMasterDownThread <> nil then
    begin
      FMasterDownThread.Terminate;
      //FMasterDownThread.WaitFor; //Ÿ����Ȳ ȭ�� ���� waitfor�� �Ѿ�� ����...
      //FMasterDownThread.Free;
    end;
    }

    if FSoundThread <> nil then
    begin
      FSoundThread.Terminate;
      //FSoundThread.WaitFor;
      //FSoundThread.Free;
    end;

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
begin
  try
    try
      Result := False;

      if Copy(Global.Config.MemberInfoDownLoadDateTime, 1, 8) <> FormatDateTime('yyyymmdd', now) then
      begin
        if Global.LocalDB.delMemberListToDB = True then
        begin
          Log.D('delMemberListToDB', 'succes');
        end
        else
        begin
          Log.D('delMemberListToDB', 'fail');
        end;
      end;

      //db
      if MemberList.Count = 0 then
      begin
        rMemberInfoList := Global.LocalDB.GetMemberListToDB;
        for nIndex := 0 to rMemberInfoList.Count - 1 do
        begin
          MemberList.Add(rMemberInfoList[nIndex]);
        end;
      end;

      //erp
      if MemberList.Count = 0 then
      begin
        Global.Config.MemberInfoDownLoadDateTime := '';
        rMemberInfoList := Global.MFErpApi.GetAllMemberInfo;
        for nIndex := 0 to rMemberInfoList.Count - 1 do
        begin
          MemberList.Add(rMemberInfoList[nIndex]);
        end;

        for nIndex := 0 to MemberList.Count - 1 do
        begin
          Global.LocalDB.SetMemberToDB(MemberList[nIndex]);
        end;

        FreeAndNil(rMemberInfoList);

        //Log.D('SetMemberToDB', 'rMemberInfoList count: ' + IntToStr(MemberList.Count));
      end
      else
      begin
        //MemberUpdateList := Global.MFErpApi.GetAllMemberInfo;
        rMemberInfoList := Global.MFErpApi.GetAllMemberInfo;
         //DB ���庸��
        for nIndex := 0 to rMemberInfoList.Count - 1 do
        begin
          MemberList.Add(rMemberInfoList[nIndex]);
          Global.LocalDB.SetMemberToDB(rMemberInfoList[nIndex]);
        end;

        FreeAndNil(rMemberInfoList);

        //Log.D('SetMemberToDB', 'rMemberInfoList count: ' + IntToStr(MemberUpdateList.Count));
      end;

      Result := True;
    except
      on E: Exception do
      begin

      end;
    end;
  finally

  end;
end;

function TSaleModule.GetProductList: Boolean;
var
  AList: TList<TProductInfo>;
  nIndex: Integer;
begin
  try
    Result := False;
    AList := Global.MFErpApi.GetTeeBoxProductList;
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
    AList := Global.MFErpApi.GetTeeBoxMaster;
    if AList.Count <> 0 then
    begin
      //Global.TeeBox.TeeBoxInfo := AList;
      for nIndex := 0 to AList.Count - 1 do
      begin
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
    Global.MFErpApi.GetTeeBoxPlayingInfo;

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
      //union
      UCBioBSPHelper := TUCBioBSPHelper.Create;
      UCBioBSPHelper.EnrollQuality := Global.Config.EnrollImageQuality; //ǰ��
      UCBioBSPHelper.VerifyQuality := Global.Config.VerifyImageQuality; //��
      UCBioBSPHelper.DefaultTimeout := 7000;   //����Ʈ�� �� ���� 10000(10��)�� ������.
      UCBioBSPHelper.SecurityLevel := Global.Config.SecurityLevel; //����

      //sewoo
      Print := TReceiptPrint.Create(Global.Config.Print.Port, br115200);
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
      Member := False;
      Global.SaleModule.GetMemberList;

      Result := True;
    end
    else
    begin
      AVersion := Global.MFErpApi.GetTeeBoxProductListVersion;
      if Global.Config.Version.ProductVersion <> AVersion then
      begin
        Global.Config.Version.ProductVersion := AVersion;
        Product := False;
      end;
      if Member and Config and Product and TeeBox then
        Result := True
      else
        Result := ShowMasterDownload(False, not Member, not Config, not Product, not TeeBox);
    end;

  except
    on E: Exception do
    begin
      Log.E('TSaleModule.MasterReception', E.Message);
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

      if BuyProductList.Count = 0 then
        Exit;

      //Log.D('SaleCompleteProc', '1111');


      //���� ���
      SelectProduct := BuyProductList[0].Products;
       //chy test

      if not Global.MFErpApi.TeeBoxListReservation then
      begin
        Log.E('TeeBoxListReservation', '������� ����');
        Global.SBMessage.ShowMessageModalForm('���� ��Ͽ� �����Ͽ����ϴ�.');
        Exit;
      end;

      //���� ���
      Global.SaleModule.RcpAspNo := Global.Config.Store.StoreCode +             // 5
                                    Copy(Global.Config.OAuth.DeviceID, 8, 3) +  // 3
                                    FormatDateTime('YYMMDDHHNNSS', now);        // 12

      if not Global.MFErpApi.SaveSaleInfo then
      begin
        Log.E('SaleCompleteProc', 'False');
      end;

      if SaleUploadFail then
      begin
        Global.SaleModule.PopUpFullLevel := pflPrint;
        ShowFullPopup(False, 'SaleUploadFail');
        Exit;
      end;

      if SelectProduct.Code <> EmptyStr then
      begin
        if Global.Config.PARKING_DAY = True then
        begin
          //chy test
          Global.SaleModule.PopUpLevel := plParkingDay;
          ShowPopup;
        end;

        Global.SaleModule.PopUpFullLevel := pflPrint;
        ShowFullPopup(False, 'SaleCompleteProc 1');

        if not Global.MFErpApi.TeeBoxHold(False) then
          Log.E('TeeBoxHold False', '����');
      end
      else
      begin
        Global.SaleModule.PopUpFullLevel := pflProduct;
        Global.SaleModule.ProductList := Global.MFErpApi.GetMemberProductList(Global.SaleModule.Member.Code, '', '');

        if Global.SaleModule.ProductList.Count = 1 then
        begin
          Global.SaleModule.ProductList.Clear;
          Global.SaleModule.PopUpFullLevel := pflPrint;
          ShowFullPopup(False, 'SaleCompleteProc 2');
          if not Global.MFErpApi.TeeBoxHold(False) then
            Log.E('TeeBoxHold False', '����');
        end;

      end;

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
  sUseTime: String;
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
//      Log.D('������ JSON Begin', Result);

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

      // Ű����ũ�� 1�� POS�� �ݺ��� ���
      JsonItem := TJSONObject.Create;
      //JsonItem.AddPair(TJSONPair.Create('TeeBox_Floor', IntTostr(TeeBoxInfo.High)));
      JsonItem.AddPair(TJSONPair.Create('TeeBox_Floor', TeeBoxInfo.FloorNm));

      JsonItem.AddPair(TJSONPair.Create('TeeBox_No', TeeBoxInfo.Name));
  //    Order.AddPair(TJSONPair.Create('UseTime', SelectProduct.Start_Time + ' ~ ' + SelectProduct.End_Time));
      JsonItem.AddPair(TJSONPair.Create('Parking_Barcode', SelectProduct.Reserve_Time));
      JsonItem.AddPair(TJSONPair.Create('ProductDiv', SelectProduct.Product_Div));

      //JsonItem.AddPair(TJSONPair.Create('UseTime', SelectProduct.Start_Time));
      sUseTime := copy(SelectProduct.Start_Time, 1, 2) + ':' + Copy(SelectProduct.Start_Time, 3, 2);
      JsonItem.AddPair(TJSONPair.Create('UseTime', sUseTime));

      JsonItem.AddPair(TJSONPair.Create('One_Use_Time', SelectProduct.One_Use_Time));
      JsonItem.AddPair(TJSONPair.Create('Reserve_No', SelectProduct.Reserve_No));

      //��ī������
      JsonItem.AddPair(TJSONPair.Create('Locker_End_Day', Global.SaleModule.FLockerEndDay));

      // �Ʒ� 5���� ������ ���õ� ����
      JsonItem.AddPair(TJSONPair.Create('UseProductName', SelectProduct.Name));
      //JsonItem.AddPair(TJSONPair.Create('Coupon', TJSONBool.Create(IfThen(SelectProduct.Product_Div = PRODUCT_TYPE_C, True, False)).ToString)); // ���� ��� ����
      if SelectProduct.Product_Div = PRODUCT_TYPE_C then // ���� ��� ����
        JsonItem.AddPair(TJSONPair.Create('Coupon', TJSONBool.Create(True).ToString))
      else
        JsonItem.AddPair(TJSONPair.Create('Coupon', TJSONBool.Create(False).ToString));
      JsonItem.AddPair(TJSONPair.Create('CouponQty', TJSONNumber.Create(SelectProduct.Use_Qty)));  // �ܿ� ���� ��
      JsonItem.AddPair(TJSONPair.Create('CouponUseDate', SelectProduct.Reserve_List));
      JsonItem.AddPair(TJSONPair.Create('ExpireDate', DateTimeSetString(SelectProduct.EndDate)));
      OrderList.Add(JsonItem);

      if (Member.Code <> EmptyStr) or (Global.SaleModule.XGolfDCAmt <> 0) then
      begin
        MemberObJect.AddPair(TJSONPair.Create('Name', Member.Name));
        MemberObJect.AddPair(TJSONPair.Create('Code', Member.Code));
        MemberObJect.AddPair(TJSONPair.Create('Tel', Member.Tel_Mobile));
        //MemberObJect.AddPair(TJSONPair.Create('CarNo', Member.CarNo));
        MemberObJect.AddPair(TJSONPair.Create('CardNo', Member.CardNo));
        //MemberObJect.AddPair(TJSONPair.Create('MemberXGOLF', TJSONBool.Create(Global.SaleModule.Member.XGolfMember)));
        //MemberObJect.AddPair(TJSONPair.Create('XGolfDiscountAmt', TJSONNumber.Create(Global.SaleModule.XGolfDCAmt)));
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
        JsonItem.AddPair(TJSONPair.Create('Name', '����Ŭ�� ȸ��'));
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
      Receipt.AddPair(TJSONPair.Create('RePrint', TJSONBool.Create(False).ToString));  // ����� ����
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

      Log.D('������ JSON', Result);
    finally
      Main.Free;
    end;
  except
    on E: Exception do
    begin
      Log.E('������ JSON', E.Message);
    end;
  end;
end;

function TSaleModule.TeeboxTimeCheck: Boolean;
var
  Index: Integer;
  ASelectTime, RealTime, Msg: string;
begin
  try
    Result := False;

    Msg := EmptyStr;

    if (Global.TeeBox.UpdateTeeBoxList[Global.SaleModule.TeeBoxInfo.TasukNo - 1].ERR = 0) or True then
    begin
      ASelectTime := StringReplace(Global.SaleModule.TeeBoxInfo.End_Time, ':', '', [rfReplaceAll]);
      RealTime := StringReplace(Global.TeeBox.UpdateTeeBoxList[Global.SaleModule.TeeBoxInfo.TasukNo - 1].End_Time, ':', '', [rfReplaceAll]);

      if ASelectTime = EmptyStr then
        ASelectTime := FormatDateTime('hhnn', Now);

      if RealTime = EmptyStr then
        RealTime := FormatDateTime('hhnn', Now);

      if (ABS(Trunc(StrToIntDef(RealTime, 0) - StrToIntDef(ASelectTime, 0)))) > 0 then
      begin
        if ABS(Trunc(StrToIntDef(RealTime, 0) - StrToIntDef(ASelectTime, 0))) > 10 then
        begin
          TeeboxTimeError := True;
          Log.D('CheckEndTime', '10�� �̻�');
          Log.D('CheckEndTime - Begin', Global.SaleModule.TeeBoxInfo.End_Time);
          Log.D('CheckEndTime - End', RealTime);

          Msg := Format(MSG_TEEBOX_TIME_ERROR, [Copy(ASelectTime, 1, 2) + ':' + Copy(ASelectTime, 3, 2),
                                                Copy(RealTime, 1, 2) + ':' + Copy(RealTime, 3, 2)]);

          if not Global.SBMessage.ShowMessageModalForm(Msg, False) then
          begin
            Log.D('TeeboxTimeCheck', '����� ���� ���');
            Exit;
          end;
        end
        else
        begin
          Log.D('CheckEndTime', '10�� ����');
          Log.D('CheckEndTime - Begin', Global.SaleModule.TeeBoxInfo.End_Time);
          Log.D('CheckEndTime - End', RealTime);
        end;
      end
      else
      begin
        TeeboxTimeError := True;
        Log.D('CheckEndTime ����', '�ð� ���� ����');
      end;
    end
    else
    begin
      Msg := MSG_TEEBOX_TIME_ERROR_STATUS;
      Global.SBMessage.ShowMessageModalForm(Msg, False);
      Log.D('CheckEndTime ����', '������ �Ǵ� ��ȸ��');
      Exit;
    end;

    Result := True;
  finally

  end;
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
    //VipTeeBox := False;

    ATeeBoxInfo.TasukNo := -1;
    TeeBoxInfo := ATeeBoxInfo;

    AMemberInfo.Code := EmptyStr;
    AMemberInfo.CardNo := EmptyStr;
    //AMemberInfo.XGolfMember := False;

    Member := AMemberInfo;
    memberItemType := mitNone;
    SelectProduct := AProduct;

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

    allianceCode := EmptyStr;
    allianceNumber := EmptyStr;
    CouponMember := False;

    FLockerEndDay := EmptyStr;

    FStoreCloseOver := False;
    FStoreCloseOverMin := EmptyStr;
    FSendPrintError := False;

    FNexpaParkList := EmptyStr;
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
  // ASP Version�ΰ�� QR Code�� �˻�
  Result := AMember;
  AddMember := False;

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
      if (FAdvertis >= 2) and CheckIntro then
      begin
        AVersion := Global.XPErpApi.GetAdvertisVersion;
        if Global.Config.Version.AdvertisVersion <> AVersion then
        begin
          Global.Config.Version.AdvertisVersion := AVersion;
    //      Global.Database.SearchAdvertisList;
          Synchronize(Global.XPErpApi.SearchAdvertisList);
        end;
        FAdvertis := 0;
      end;
      Sleep(1200000); // 20�� ������ �ִ� 40�� ���� ����
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
