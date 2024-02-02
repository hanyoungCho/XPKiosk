unit uSaleModule;

interface

uses
  uConsts, uPrint, CPort, JSON, VCL.Forms, IdHTTP, System.Classes, Math, mmsystem,
  uStruct, System.SysUtils, IdGlobal, IdSSL, IdSSLOpenSSL, System.UITypes,
  Generics.Collections, Uni, uVanDeamonModul, uPaycoNewModul, IdComponent, IdTCPConnection, IdTCPClient,
  IdURI,
  // union
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

  TMasterDownThread = class(TThread)
  private
    FAdvertis: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;
  end;

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
    FMasterDownThread: TMasterDownThread;
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
    FVipTeebox: Boolean;                     // ���߼��ý� VIPŸ���� ��� �� �� �ΰ�?
    // ������ ���� ����
    FSaleUpload: Boolean;
    // ��ü Ÿ�� ����(������ ����)
    FAllTeeBoxShow: Boolean;

    // üũ�� �������
    FCheckInList: TList<TCheckInInfo>;

    // ���� ����Ʈ
    FAdvertisementListUp: TList<TAdvertisement>;
    FAdvertisementListDown: TList<TAdvertisement>;

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
    // ���θ�� ����
    FPromotionType: TPromotionType;

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

    function GetVanCode: string;
    function GetRcpNo: Integer;
  public
    // �ӽ� ȸ�� ��Ͻ� ����� ����
    FingerStr: string;
    ConfigJsonText: string;
    // ȸ�� ���� ���� �ð�
    MemberInfoDownLoadDateTime: string;
    NowHour: string;
    NowTime: string;
    // �̴ϸ� width
    MiniMapWidth: Integer;

    // ���޻� ��� �ڵ�
    FallianceCode: string;
    FallianceNumber: string;

    //2020-12-29 ��ī������
    FLockerEndDay: String;

    FStoreCloseOver: Boolean;
    FStoreCloseOverMin: String;

    constructor Create;
    destructor Destroy; override;

    function OAuthCheck: Boolean;
    // ���� üũ
    function MasterReception(AType: Integer = 0): Boolean;
    function SaleCompleteProc: Boolean;
    function SaleCompleteProcBunker: Boolean;
    function SetPrintData: string;
    function SearchMember(ACode: string): TMemberInfo;
    function SearchRFIDMember(ACode: string): TMemberInfo;  //RFID
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

    // X���� ȸ������
    function CheckXGolfMember(ACode: string): Boolean;
    function CheckXGolfMemberPhone(ACode: string): Boolean;

    // ������
    function GetMemberList: Boolean;
    function GetConfig: Boolean;
    function GetProductList: Boolean;
    function GetTeeBoxInfo: Boolean;
    function GetPlayingTeeBoxList: Boolean;

    function DeviceInit: Boolean;
    // ī�� ���� ��ȸ
    function CallCardInfo: string;
    // ī�� ����
    function CallCard(ACardBin, ACode, AMsg: string; ADiscountAmt: Currency; IsAppCard: Boolean = False): TCardRecvInfoDM;
    function CallCard_Old: TCardRecvInfoDM;
    // PAYCO ����
    function CallPayco: TPaycoNewRecvInfo;

    // �������� �հ�
    function GetSumPayAmt(APayType: TPayTyepe): Currency;

    // ����ȣ��
    function CallAdmin: Boolean;
    function CallIntroBlack: Boolean;

    // Ÿ���ð� üũ
    function TeeboxTimeCheck: Boolean;

    // ����Ŭ��
    function WellbeingClub(AIsApproval: Boolean; AOTC: string): Boolean;

    // �츮ī�� ������������
    function TheLoungeMembers(AOTC: string): Boolean;
    function TheLoungeMembersUse(ACouponNum: String): Boolean;

    // ��������Ŭ��
    function RefreshClub(AOTC: string): Boolean;
    function ApplyRefreshClub(const AUserId: string): Boolean;

    //2020-12-15 ��������
    function ApplyIKozen(const AReadData: string): Boolean;

    //2020-12-14 ������������
    function ApplyRefreshGolf(const AUserId: string): Boolean;

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

    property CheckInList: TList<TCheckInInfo> read FCheckInList write FCheckInList;

    property AdvertisementListUp: TList<TAdvertisement> read FAdvertisementListUp write FAdvertisementListUp;
    property AdvertisementListDown: TList<TAdvertisement> read FAdvertisementListDown write FAdvertisementListDown;

    property PopUpLevel: TPopUpLevel read FPopUpLevel write FPopUpLevel;
    property PopUpFullLevel: TPopUpFullLevel read FPopUpFullLevel write FPopUpFullLevel;

    property Print: TReceiptPrint read FPrint write FPrint;

    property VanModule: TVanDeamonModul read FVanModule write FVanModule;
    property PaycoModule: TPaycoNewModul read FPaycoModule write FPaycoModule;

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
    property MasterDownThread: TMasterDownThread read FMasterDownThread write FMasterDownThread;
    property SoundThread: TSoundThread read FSoundThread write FSoundThread;
    property TeeboxTimeError: Boolean read FTeeboxTimeError write FTeeboxTimeError;
    property CardApplyType: TCardApplyType read FCardApplyType write FCardApplyType;
    property PromotionType: TPromotionType read FPromotionType write FPromotionType;
    property allianceCode: string read FallianceCode write FallianceCode;
    property allianceNumber: string read FallianceNumber write FallianceNumber;
    property CouponMember: Boolean read FCouponMember write FCouponMember;

  end;

var
  SaleModule: TSaleModule;

implementation

uses
  uGlobal, uCommon, uFunction, fx.Logging;

{ TSaleModule }

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

  CheckInList := TList<TCheckInInfo>.Create;

  AdvertisementListUp := TList<TAdvertisement>.Create;
  AdvertisementListDown := TList<TAdvertisement>.Create;
  //ParkingProductList := TList<TProductInfo>.Create;
//  LastHoldNo := 0;
  VipTeeBox := False;
  SaleUploadFail := False;
  AllTeeBoxShow := False;
  MainItemMapUse := False;
  TeeBoxSortType := tstDefault;
  MiniMapCursor := False;
  MasterDownThread := TMasterDownThread.Create;
  SoundThread := TSoundThread.Create;
  MemberInfoDownLoadDateTime := EmptyStr;
  NowHour := EmptyStr;
  NowTime := EmptyStr;
  MiniMapWidth := 0;
end;

destructor TSaleModule.Destroy;
begin
//  if MemberList <> nil then
//    MemberList.Free;

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

  if MainItemList <> nil then
    MainItemList.Free;

  if AdvertisementListUp <> nil then
    AdvertisementListUp.Free;

  if AdvertisementListDown <> nil then
    AdvertisementListDown.Free;

  if not Global.Config.NoPayModule then
  begin
    VanModule.Free;
    PaycoModule.Free;
  end;

  if not Global.Config.NoDevice then
  begin
    //UCBioBSPHelper.Free;
    Print.Free;
  end;

  FMasterDownThread.Terminate;
  FSoundThread.Terminate;

  inherited;
end;

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

    if (memberItemType = mitBunkerNonMember) and (BuyProductList.Count > 0) then
    begin
      Global.SBMessage.ShowMessageModalForm('����/��Ŀ ���ӱ��Ŵ� 1���� �����մϴ�.');
      Exit;
      Result := True;
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
      if Global.SaleModule.Member.XGolfMember and ASaleData.Products.xgolf_dc_yn then
      begin
        ASaleData.DcAmt := ASaleData.Products.Price - ASaleData.Products.xgolf_product_amt;
        ADiscount.Name := 'XGOLF ����';
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

        DeleteIndex := -1;
        for Index := 0 to DisCountList.Count - 1 do
        begin
          if DisCountList[Index].Gubun = 998 then
          begin
            DeleteIndex := Index;
            Log.D('CardDiscountDelete 998', DisCountList[Index].QRCode + ' - Index - ' + IntToStr(Index));
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

  try
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
      ADiscount.Name := 'XGOLF ����';
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
                end;

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
  Msg: string;
begin
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

      // sewoo
      //Global.SBMessage.ShowMessageModalForm(MSG_ADMIN_CALL);
      Global.SBMessage.ShowMessageModalForm2(MSG_PRINT_ADMIN_CALL, True, 30, True, True);

      Result := Indy.Connected;
    except
      on E: Exception do
        // �����ͻ��� üũ-pos������� Ȯ��->����
        Global.SBMessage.ShowMessageModalForm(MSG_ADMIN_CALL_FAIL);
        //Global.SBMessage.ShowMessageModalForm2(MSG_ADMIN_CALL_FAIL, True, 30, True, True);
    end;
  finally
    Indy.Free;
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
//  ACode, AMsg: string;
//  ADiscountAmt: Currency;
begin
  try
    ACard := TPayCard.Create;

    // ī������ ����
//    ARecvInfo := VanModule.CallCardInfo(ACard.SendInfo);

//    if ARecvInfo.Result then
    if CardApplyType = catMagnetic then
      ACard.SendInfo.OTCNo := EmptyStr
    else
      ACard.SendInfo.OTCNo := ACardBin;

    if ACardBin <> EmptyStr then
    begin
      ACard.SendInfo.CardBinNo := Copy(ACardBin, 1, 6);

      // bc���̺�
      //ADiscountInfo.Name := '�ſ�ī�� ���� ����';
      if Length(ACardBin) >= 30 then
        ADiscountInfo.Name := 'BCī�� ���� ����'
      else
        ADiscountInfo.Name := '����ī�� ���� ����';

      ADiscountInfo.Gubun := 998;

//      ACode := EmptyStr;
//      AMsg := EmptyStr;
//        ADiscountAmt := Global.Database.SearchCardDiscount(ARecvInfo.CardBinNo, CurrToStr(Global.SaleModule.RealAmt), ACode, AMsg);

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
//        ACard.SendInfo.CardBinNo := IfThen(Length(ACardBin) > 30, '', Copy(ACardBin, 1, 6));
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
    ACard.SendInfo.HalbuMonth := IfThen(Global.SaleModule.SelectHalbu = 1, 0, Global.SaleModule.SelectHalbu);
    ACard.SendInfo.BizNo := StringReplace(Global.Config.Store.BizNo, '-', '', [rfReplaceAll]);
    ACard.SendInfo.TerminalID := Global.Config.Store.VanTID;
    ACard.SendInfo.SignOption := 'T';

    ACard.SendInfo.Reserved1 := 'PG';

    Sleep(50);
    {$IFDEF RELEASE}
    ACard.RecvInfo := VanModule.CallCard(ACard.SendInfo);

    //ACard.RecvInfo.Result := True;
    //ACard.RecvInfo.AgreeNo := '0001';
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

function TSaleModule.CallCard_Old: TCardRecvInfoDM;
var
  ACard: TPayCard;
  ARecvInfo: TCardRecvInfoDM;
  ADiscountInfo: TDiscount;
  ACode, AMsg: string;
  ADiscountAmt: Currency;
begin
  try
    ACard := TPayCard.Create;

    // ī������ ����
    ARecvInfo := VanModule.CallCardInfo(ACard.SendInfo);

    if ARecvInfo.Result then
    begin
      ACard.SendInfo.CardBinNo := ARecvInfo.CardBinNo;

      ADiscountInfo.Name := '�ſ�ī�� ���� ����';
      ADiscountInfo.Gubun := 998;

      ACode := EmptyStr;
      AMsg := EmptyStr;
      ADiscountAmt := Global.Database.SearchCardDiscount(ARecvInfo.CardBinNo, CurrToStr(Global.SaleModule.RealAmt), ACode, AMsg);

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
        Log.D('ī������ ���� ��� �ƴ� - ���αݾ� 0', ARecvInfo.CardBinNo);
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

    ACard.SendInfo.Approval := True;
    ACard.SendInfo.SaleAmt := RealAmt;
    ACard.SendInfo.VatAmt := VatAmt;
    ACard.SendInfo.FreeAmt := 0;
    ACard.SendInfo.SvcAmt := 0;
    ACard.SendInfo.EyCard := False;
    ACard.SendInfo.HalbuMonth := IfThen(Global.SaleModule.SelectHalbu = 1, 0, Global.SaleModule.SelectHalbu);
    ACard.SendInfo.BizNo := StringReplace(Global.Config.Store.BizNo, '-', '', [rfReplaceAll]);
    ACard.SendInfo.TerminalID := Global.Config.Store.VanTID;
    ACard.SendInfo.SignOption := 'T';

    Sleep(50);
    ACard.RecvInfo := VanModule.CallCard(ACard.SendInfo);

    Result := ACard.RecvInfo;
    if Result.Result then
    begin
      PayList.Add(ACard);
    end
    else
      CardDiscountDelete;
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
        Result := True
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

procedure TSaleModule.CallEmp;
begin
//
end;

function TSaleModule.GetMemberList: Boolean;
begin
  try
    try
      Result := False;

      if MemberList.Count = 0 then
        MemberList := Global.Database.GetAllMemberInfo //Global.Database.GetAllMemberInfo;
      else
        MemberUpdateList := Global.Database.GetAllMemberInfo;

      Result := True;
    except
      on E: Exception do
      begin

      end;
    end;
  finally
    //AList.Free;
  end;
end;

function TSaleModule.GetConfig: Boolean;
begin
  try
    Result := False;
    Sleep(1000);

    if Global.Database.GetConfig then
      Global.Config.SaveLocalConfig;
    Result := True;
  finally

  end;
end;

function TSaleModule.GetProductList: Boolean;
var
  AList: TList<TProductInfo>;
begin
  try
    Result := False;
    AList := Global.Database.GetTeeBoxProductList;
    if AList.Count <> 0 then
      SaleList := AList;//Global.Database.GetTeeBoxProductList;
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
begin
  try
    Result := False;
    AList := Global.Database.GetTeeBoxMaster;
    if AList.Count <> 0 then
      Global.TeeBox.TeeBoxInfo := AList;
    Result := True;
  finally

  end;
end;

function TSaleModule.GetPlayingTeeBoxList: Boolean;
begin
  try
    Result := False;
    //if Global.Config.AD.USE then
      Global.LocalApi.GetTeeBoxPlayingInfo;
    //else
      //Global.Database.GetTeeBoxPlayingInfo;

    Global.TeeBox.TeeBoxList := Global.TeeBox.UpdateTeeBoxList;

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
      { ���� �̻��
      UCBioBSPHelper := TUCBioBSPHelper.Create;
      UCBioBSPHelper.EnrollQuality := Global.Config.EnrollImageQuality; //ǰ��
      UCBioBSPHelper.VerifyQuality := Global.Config.VerifyImageQuality; //��
      UCBioBSPHelper.SecurityLevel := Global.Config.SecurityLevel; //����
      }
      Print := TReceiptPrint.Create(dtKiosk42, Global.Config.Print.Port, br115200);
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
    else
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
    end;

  except
    on E: Exception do
    begin

    end;
  end;
end;

function TSaleModule.SaleCompleteProc: Boolean;
label ReReserve1;
label ReReserve2;
label ReReserve3;
var
  AProduct: TProductInfo;
begin
  try
    try
      Result := False;

      // Local Database Save
      if BuyProductList.Count <> 0 then
      begin
        Global.SaleModule.RcpAspNo := Global.Config.Store.StoreCode +             // 5
                                      Copy(Global.Config.OAuth.DeviceID, 8, 3) +  // 3
                                      FormatDateTime('YYMMDDHHNNSS', now);        // 12

        if not Global.Database.SaveSaleInfo then
        begin
          Log.E('SaleCompleteProc', 'False');
    //      Exit;
        end;
      end;

      if SaleUploadFail then
      begin
        Global.SaleModule.PopUpFullLevel := pflPrint;
        ShowFullPopup(False, 'SaleUploadFail');
        Exit;
      end;

      if BuyProductList.Count = 1 then
      begin
        if (BuyProductList[0].Products.Product_Div <> PRODUCT_TYPE_D) and BuyProductList[0].Products.Use and BuyProductList[0].Products.Yoday_Use then
        begin
          if Global.SBMessage.ShowMessageModalForm(MSG_SALE_PRODUCT_RESERVE, False) then
            SelectProduct := BuyProductList[0].Products;
        end
        else
          SelectProduct := BuyProductList[0].Products;
      end;

      if SelectProduct.Code <> EmptyStr then
      begin // ���� ���� ���
        Global.SaleModule.SetPrepareMin;
        if not Global.Database.TeeBoxListReservation then
        begin
          Log.E('TeeBoxListReservation', '������� ����');
          if not Global.Database.TeeBoxHold(False) then
            Log.E('TeeBoxHold False', '����');
        end;
        Global.SaleModule.PopUpFullLevel := pflPrint;
        ShowFullPopup(False, 'SaleCompleteProc 1');
        if not Global.Database.TeeBoxHold(False) then
          Log.E('TeeBoxHold False', '����');
      end
      else
      begin
        Global.SaleModule.PopUpFullLevel := pflProduct;
        Global.SaleModule.ProductList := Global.Database.GetMemberProductList(Global.SaleModule.Member.Code, '', '');

        if Global.SaleModule.ProductList.Count = 1 then
        begin
          Global.SaleModule.ProductList.Clear;
          Global.SaleModule.PopUpFullLevel := pflPrint;
          ShowFullPopup(False, 'SaleCompleteProc 2');
          if not Global.Database.TeeBoxHold(False) then
            Log.E('TeeBoxHold False', '����');
        end
        else
        begin
          if Global.SBMessage.ShowMessageModalForm(MSG_SALE_PRODUCT_RESERVE_SEARCH, False) then // �ҷ�����?
          begin
            if Global.SaleModule.ProductList.Count = 1 then
            begin
              SelectProduct := Global.SaleModule.ProductList[0];
              Global.SaleModule.SetPrepareMin;
              if not Global.Database.TeeBoxListReservation then
              begin
                //����
                Log.E('Sale TeeBoxListReservation_1', '������� ����');
                Global.SaleModule.PopUpFullLevel := pflPrint;
                ShowFullPopup(False, 'SaleCompleteProc 3');
                if not Global.Database.TeeBoxHold(False) then
                  Log.E('TeeBoxHold False', '����');
              end
              else
              begin
                Global.SaleModule.PopUpFullLevel := pflTeeBoxPrint;
                ShowFullPopup(False, 'SaleCompleteProc 4');
              end;
            end
            else
            begin
              ReReserve3 :
              if ShowFullPopup(False, 'SaleCompleteProc 5') = mrOk then
              begin
                SetPrepareMin;
                if not Global.Database.TeeBoxListReservation then
                begin
                  //����
                  if not TeeboxTimeError then
                  begin
                    if Global.SBMessage.ShowMessageModalForm('�ٸ� ��ǰ���� �����Ͻðڽ��ϱ�?', False) then
                      goto ReReserve3;
                  end;

                  Log.E('Sale TeeBoxListReservation_2', '������� ����');
                  PopUpFullLevel := pflPrint;
                  ShowFullPopup(False, 'SaleCompleteProc 6');
                  if not Global.Database.TeeBoxHold(False) then
                    Log.E('TeeBoxHold False', '����');
                end
                else
                begin
                  PopUpFullLevel := pflTeeBoxPrint;
                  ShowFullPopup(False, 'SaleCompleteProc 7');
                end;
              end
              else
              begin
                Global.SaleModule.PopUpFullLevel := pflPrint;
                ShowFullPopup(False, 'SaleCompleteProc 8');
              end;
            end;
          end
          else
          begin
            Global.SaleModule.PopUpFullLevel := pflPrint;
            ShowFullPopup(False, 'SaleCompleteProc 9');
            if not Global.Database.TeeBoxHold(False) then
              Log.E('TeeBoxHold False', '����');
          end;
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

function TSaleModule.SaleCompleteProcBunker: Boolean;
var
  AProduct: TProductInfo;
begin
  try
    try
      Result := False;

      // Local Database Save
      if BuyProductList.Count <> 0 then
      begin
        Global.SaleModule.RcpAspNo := Global.Config.Store.StoreCode +             // 5
                                      Copy(Global.Config.OAuth.DeviceID, 8, 3) +  // 3
                                      FormatDateTime('YYMMDDHHNNSS', now);        // 12

        if not Global.Database.SaveSaleInfo then
          Log.E('SaleCompleteProcBunker', 'False');
      end;

      if SaleUploadFail then
      begin
        Global.SaleModule.PopUpFullLevel := pflPrint;
        ShowFullPopup(False, 'SaleUploadFail');
        Exit;
      end;

      if BuyProductList.Count = 1 then
      begin
        SelectProduct := BuyProductList[0].Products;
      end;

      if SelectProduct.Code <> EmptyStr then
      begin // ���� ���� ���

        Global.SaleModule.SetPrepareMin;
        if not Global.Database.BunkerReservation then
          Log.E('BunkerReservation', '������� ����');

        Global.SaleModule.PopUpFullLevel := pflPrint;
        ShowFullPopup(False, 'SaleCompleteProcBunker 1');
      end;

      Result := True;
    except
      on E: Exception do
        Log.E('SaleCompleteProcBunker', E.Message);
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
      JsonItem.AddPair(TJSONPair.Create('TeeBox_Floor', IntTostr(TeeBoxInfo.High)));
      JsonItem.AddPair(TJSONPair.Create('TeeBox_No', TeeBoxInfo.Mno));
  //    Order.AddPair(TJSONPair.Create('UseTime', SelectProduct.Start_Time + ' ~ ' + SelectProduct.End_Time));
      JsonItem.AddPair(TJSONPair.Create('Parking_Barcode', SelectProduct.Reserve_Time));
      JsonItem.AddPair(TJSONPair.Create('ProductDiv', SelectProduct.Product_Div));
      JsonItem.AddPair(TJSONPair.Create('UseTime', SelectProduct.Start_Time));
      JsonItem.AddPair(TJSONPair.Create('One_Use_Time', SelectProduct.One_Use_Time));
      JsonItem.AddPair(TJSONPair.Create('Reserve_No', SelectProduct.Reserve_No));
      // �Ʒ� 5���� ������ ���õ� ����
      JsonItem.AddPair(TJSONPair.Create('UseProductName', SelectProduct.Name));
      JsonItem.AddPair(TJSONPair.Create('Coupon', TJSONBool.Create(IfThen(SelectProduct.Product_Div = PRODUCT_TYPE_C, True, False)).ToString)); // ���� ��� ����
      JsonItem.AddPair(TJSONPair.Create('CouponQty', TJSONNumber.Create(SelectProduct.Use_Qty)));  // �ܿ� ���� ��
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
      Receipt.AddPair(TJSONPair.Create('SaleUpload', IfThen(Global.SaleModule.SaleUploadFail, 'Y', 'N')));

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

function TSaleModule.WellbeingClub(AIsApproval: Boolean; AOTC: string): Boolean;
var
  AIndy: TIdHTTP;
  RecvData: TStringStream;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
  ApprovalCode, ResultStr: string;
  RBS: RawByteString;
  SL: TStringList;
  AApiToken, AStoreCode, AMemberNo: string;
  MainJson: TJSONObject;
begin
  Result := False;
  ResultStr := EmptyStr;

  Log.D('WellbeingClub', Ifthen(AIsApproval, '����', '���'));
  Log.D('WellbeingClub', AOTC);
  
  AIndy := TIdHTTP.Create(nil);
  RecvData := TStringStream.Create;
  SL := TStringList.Create;
  MainJson := TJSONObject.Create;
  SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  try
    try
      ApprovalCode := Ifthen(AIsApproval, 'approval', 'approvalcancel');

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
      AMemberNo := AOTC;

  //    AIndy.HTTPOptions := (AIndy.HTTPOptions - [hoForceEncodeParams]); //�ڵ� ���ڵ� ����
      SL.Add(TIdURI.ParamsEncode('api_token=' + AApiToken));
      SL.Add(TIdURI.ParamsEncode('sisul_code=' + AStoreCode));
      SL.Add(TIdURI.ParamsEncode('card_number=' + AMemberNo));

  //    AIndy.Post('http://partnerapi.wbcm.co.kr/openapi/' + ApprovalCode, SL, RecvData);
      AIndy.Post('https://partner-api.wbcm.co.kr/openapi/' + ApprovalCode, SL, RecvData);
      RBS := PAnsiChar(RecvData.Memory);
      SetCodePage(RBS, 65001, False);
      ResultStr := RBS;

      if ResultStr <> EmptyStr then
      begin
        Log.D('WellbeingClub', ResultStr);
        MainJson := TJSONObject.ParseJSONValue(ResultStr) as TJSONObject;

        if (MainJson.Get('code').JsonValue.Value = '0') or (MainJson.Get('code').JsonValue.Value = '1') then
        begin
          allianceCode := '00001';
          allianceNumber := AOTC;
          Result := True;
        end
        else
          Global.SBMessage.ShowMessageModalForm(MainJson.Get('msg').JsonValue.Value, True, 15);
      end
      else
      begin
        Log.D('WellbeingClub', '���� �� ����.');
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


// �츮ī�� ������������
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

  Log.D('TheLoungeMembers', '������ȸ');
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
      sUserId := THE_LOUNGE_MEMBERS_REAL_ID;
      sPassword := THE_LOUNGE_MEMBERS_REAL_PW;
      {$ENDIF}
      {$IFDEF DEBUG}
      sUrl := THE_LOUNGE_MEMBERS_TEST_URL;  //'https://dev-api.theloungemembers.com/';
      sUserId := THE_LOUNGE_MEMBERS_TEST_ID;
      sPassword := THE_LOUNGE_MEMBERS_TEST_PW;
      //sCouponNum := '8574003842323278'; //8574337487960243 -����
      {$ENDIF}

      //AIndy.Post('https://dev-api.theloungemembers.com/api/v2/coupon/info/?user_id=xgolf&password=mimigolf3x^^&coupon_num=8574003842323278', SL, RecvData);
      //AIndy.Get('https://dev-api.theloungemembers.com/api/v2/coupon/info/?user_id=xgolf&password=mimigolf3x^^&coupon_num=8574337487960243', RecvData);

      //������ȸ
      AIndy.Get(sUrl + 'api/v2/coupon/info/?user_id=' + sUserId + '&password=' + sPassword + '&coupon_num=' + sCouponNum, RecvData);

      //���
      //AIndy.Get('https://dev-api.theloungemembers.com/api/v2/coupon/use/?user_id='+sUserId+'&password='+sPassword+'&coupon_num=8574003842323278&lounge_code=A123&lounge_name=Ű����ũ', RecvData);

      //���
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

          //used	�̿���� �̹� ���Ǿ���.
          //expired	�̿�� ��� �Ⱓ�� ����Ǿ���.
          //usable	�̿���� ����� �� �ִ�.
          //nonexistent	�̿���� �������� �ʴ´�.

          if sStatus = 'usable' then
          begin
            if TheLoungeMembersUse(sCouponNum) = False then
              Exit;

            Result := True;
          end
          else
          begin
            if sStatus = 'used' then
              sMsg := '�̿���� �̹� ���Ǿ����ϴ�.';
            if sStatus = 'expired' then
              sMsg := '�̿�� ��� �Ⱓ�� ����Ǿ����ϴ�.';
            if sStatus = 'nonexistent' then
              sMsg := '�̿���� �������� �ʽ��ϴ�.';

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
        Log.D('TheLoungeMembers', '���� �� ����.');
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

// �츮ī�� ������������
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

  Log.D('TheLoungeMembersUse', '����û');

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

      //���
      //AIndy.Get('https://dev-api.theloungemembers.com/api/v2/coupon/use/?user_id='+sUserId+'&password='+sPassword+'&coupon_num=8574003842323278&lounge_code=A123&lounge_name=Ű����ũ', RecvData);
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
        Log.D('TheLoungeMembersUse', '���� �� ����.');
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

// ��������Ŭ��
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

  Log.D('RefreshClub', '����û');
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

  //    AIndy.HTTPOptions := (AIndy.HTTPOptions - [hoForceEncodeParams]); //�ڵ� ���ڵ� ����
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
        Log.D('RefreshClub', '���� �� ����.');
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

        //sToken := '1hLKxhHa62PWUky9'; //ĳ������
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

        allianceCode := '00002'; //�ڵ尡 �־�� ����
        allianceNumber := sUserId;

        Result := True;
      end
      else
        raise Exception.Create('��������/Ŭ�� ���� ������ �Ǿ� ���� �ʽ��ϴ�!');
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

//2020-12-14 ������������
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

        //sToken := '1hLKxhHa62PWUky9'; //ĳ������
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

        allianceCode := '00002'; //�ڵ尡 �־�� ����
        allianceNumber := sUserId;

        Result := True;
      end
      else
        raise Exception.Create('��������/Ŭ�� ���� ������ �Ǿ� ���� �ʽ��ϴ�!');
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
  CPP_AFFILIATE_MEMBER_CD = 'CPP_AFFILIATE_MEMBER_CD'; //ȸ����ȣ
  CPP_AFFILIATE_EXEC_ID = 'CPP_AFFILIATE_EXEC_ID'; //�����ڵ�


  GCD_IKOZEN_CODE            = '00004';
  GCD_IKOZEN_HOST            = 'https://ikozen.com/api/qrcode_enter.php';
  GCD_IKOZEN_TEST_STORE_CODE = '1452';
  GCD_IKOZEN_TEST_MEMBER_NO  = '1056147'; //���� ���� �ñ��� �� 25ȸ ��� ���� (�ʱ�ȭ ��û: 010-2591-9385)
}

//2020-12-15 ��������
function TSaleModule.ApplyIKozen(const AReadData: string): Boolean;
var
  sBuffer: string;
  nPos: Integer;
  AMemberCode, AStoreCode, AExecId, AErrMsg: String;
  sHost: String;

  HC: TIdHTTP;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
  JO: TJSONObject;
  SS, RS: TStringStream;
  RBS: RawByteString;
  sUrl, sResCode, sResMsg, sStoreName, sMemberName: string;
begin
  Result := False;

  sBuffer := AReadData; //IK_1041911_1452_1

  if (Copy(sBuffer, 1, 3) <> 'IK_') then
  begin
    //raise Exception.Create('��ȿ�� �������� ����� ���ڵ尡 �ƴմϴ�.');
    Global.SBMessage.ShowMessageModalForm('��ȿ�� �������� ����� ���ڵ尡 �ƴմϴ�.', True, 15);
    Exit;
  end;

  sBuffer := Copy(sBuffer, 4, Length(sBuffer) - 3); //1041911_1452_1
  nPos := Pos('_', sBuffer);
  if (nPos > 0) then
  begin
    AMemberCode := Copy(sBuffer, 1, Pred(nPos));
    sBuffer := Copy(sBuffer, Succ(nPos), Length(sBuffer) - nPos); //1452_1
    nPos := Pos('_', sBuffer);
    if (nPos > 0) then
    begin
      AStoreCode := Copy(sBuffer, 1, Pred(nPos));
      sBuffer := Copy(sBuffer, Succ(nPos), Length(sBuffer) - nPos); //1
      AExecId := sBuffer;
    end;
  end;

  if (AMemberCode = '') or (AStoreCode = '') or (AExecId = '') then
  begin
    //raise Exception.Create('��ȿ�� �������� ����� ���ڵ尡 �ƴմϴ�.');
    Global.SBMessage.ShowMessageModalForm('��ȿ�� �������� ����� ���ڵ尡 �ƴմϴ�.', True, 15);
    Exit;
  end;
 {
  if (Global.Config.IKozen.StoreCD <> AStoreCode) then
  begin
    //XGMsgBox(Self.Handle, mtInformation, '�˸�', '����� �� ���� �ü��ڵ� �Դϴ�!', ['Ȯ��'], 5);
    Global.SBMessage.ShowMessageModalForm('����� �� ���� �ü��ڵ� �Դϴ�!', True, 15);
    Exit;
  end;
  }

  try
    RS := TStringStream.Create;
    SS := nil;
    JO := nil;
    HC := TIdHTTP.Create(nil);
    SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
    try
      //if not Global.IKozen.Enabled then
        //raise Exception.Create('�������� ���� ������ �Ǿ� ���� �ʽ��ϴ�!');

      sHost := 'https://ikozen.com/api/qrcode_enter.php';

      sUrl := Format('%s?MID=%s&SISUL_CODE=%s&EXECID=%s', [sHost, AMemberCode, AStoreCode, AExecId]);
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
        //raise Exception.Create(Format('ResultCode=%s, MemberName=%s, StoreName=%s, Message=%s',
        //  [sResCode, sMemberName, sStoreName, sResMsg]));

        AErrMsg := Format('ResultCode=%s, MemberName=%s, StoreName=%s, Message=%s',
                  [sResCode, sMemberName, sStoreName, sResMsg]);
        Global.SBMessage.ShowMessageModalForm(AErrMsg, True, 15);
        Exit;
      end;

      allianceCode := '00004'; //�ڵ尡 �־�� ����
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
      //UpdateLog(Global.LogFile, Format('ApplyIKozen.Exception : %s', [E.Message]));
      Log.E('ApplyIKozen.Exception : ', AErrMsg);
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
//    MainItemMapUse := False;
//    AllTeeBoxShow := False;
    RcpNo := 0;
    SaleUploadFail := False;
    RcpAspNo := EmptyStr;
    IsComplete := False;
    VipDisCount := False;
    VipTeeBox := False;

    ATeeBoxInfo.TasukNo := -1;
    TeeBoxInfo := ATeeBoxInfo;

    AMemberInfo.Code := EmptyStr;
    AMemberInfo.CardNo := EmptyStr;
    AMemberInfo.XGolfMember := False;

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

    // ��ī������
    FLockerEndDay := EmptyStr;

    FStoreCloseOver := False;
    FStoreCloseOverMin := EmptyStr;
  except
    on E: Exception do
    begin

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
  {
  if Result.Code <> EmptyStr then
  begin
    Global.SaleModule.CouponMember := True;
  end;
  }
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


      for I := 0 to CheckInList.Count - 1 do
      begin
        // Ű����ũ�� 1�� POS�� �ݺ��� ���
        JsonItem := TJSONObject.Create;
        JsonItem.AddPair(TJSONPair.Create('TeeBox_Floor', CheckInList[I].floor_nm));

        JsonItem.AddPair(TJSONPair.Create('TeeBox_Nm', CheckInList[I].teebox_nm));
        JsonItem.AddPair(TJSONPair.Create('Parking_Barcode', CheckInList[I].reserve_datetime));
        JsonItem.AddPair(TJSONPair.Create('ProductDiv', CheckInList[I].product_div));
        JsonItem.AddPair(TJSONPair.Create('UseTime', CheckInList[I].start_datetime));
        JsonItem.AddPair(TJSONPair.Create('One_Use_Time', CheckInList[I].remain_min));
        JsonItem.AddPair(TJSONPair.Create('Reserve_No', CheckInList[I].reserve_no));

        //��ī������
        JsonItem.AddPair(TJSONPair.Create('Locker_End_Day', ''));

        // �Ʒ� 5���� ������ ���õ� ����
        JsonItem.AddPair(TJSONPair.Create('UseProductName', CheckInList[I].product_nm));
        JsonItem.AddPair(TJSONPair.Create('Coupon', TJSONBool.Create(False).ToString)); // ���� ��� ����
        JsonItem.AddPair(TJSONPair.Create('CouponQty', TJSONNumber.Create(CheckInList[I].coupon_cnt)));  // �ܿ� ���� ��
        JsonItem.AddPair(TJSONPair.Create('CouponUseDate', ''));
        JsonItem.AddPair(TJSONPair.Create('ExpireDate', DateTimeSetString(CheckInList[I].expire_day)));
        OrderList.Add(JsonItem);
      end;

      Receipt.AddPair(TJSONPair.Create('SaleDate', FormatDateTime('yyyy-mm-dd', now)));

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
        AVersion := Global.Database.GetAdvertisVersion;
        if Global.Config.Version.AdvertisVersion <> AVersion then
        begin
          Global.Config.Version.AdvertisVersion := AVersion;
    //      Global.Database.SearchAdvertisList;
          Synchronize(Global.Database.SearchAdvertisList);
        end;
        FAdvertis := 0;
      end;
      Sleep(1200000); // 20�� ������ �ִ� 40�� ���� ����
      Inc(FAdvertis);
    end;
  end;
end;

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
    if SoundList.Count <> 0 then
    begin  
      PlaySound(StringToOLEStr(SoundList[0]), 0, SND_SYNC);
      SoundList.Delete(0);
    end
    else
      Suspend;
    Sleep(300);
  end;
end;

end.
