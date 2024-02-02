unit uSaleModule;

interface

uses
  uConsts, uPrint, CPort, JSON, VCL.Forms, IdHTTP, System.Classes, Math, mmsystem,
  uStruct, System.SysUtils, IdGlobal, IdSSL, IdSSLOpenSSL, System.UITypes, System.DateUtils,
  Generics.Collections, Uni, IdComponent, IdTCPConnection, IdTCPClient,
  IdURI, //uVanDeamonModul, uPaycoNewModul,
  uUCBioBSPHelper;

type
  TPayTyepe = (ptNone, ptCash, ptCard, ptPayco, ptVoid);

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

  TSaleModule = class
  private
    // 백그라운드 마스터 수신
    //FMasterDownThread: TMasterDownThread;
    // 프로그램 사용 가능 여부
    FProgramUse: Boolean;
    // 판매일
    FSaleDate: string;
    // 영수증 번호
    FRcpNo: Integer;
    FRcpAspNo: string;
    // 전체 회원 정보
    FMemberList: TList<TMemberInfo>;
    FMemberUpdateList: TList<TMemberInfo>;
    // 판매 상품 정보
    FSaleList: TList<TProductInfo>;
    // 가동상황 조합 리스트
    FMainItemList: TList<TTeeBoxInfo>;
    FMainItemMapUse: Boolean;

    // 선택 회원
    FMember: TMemberInfo;
    // 회원의 사용가능한 상품 목록
    FProductList: TList<TProductInfo>;
    // 회원의 선택 상품
    FSelectProduct: TProductInfo;
    // 선택 시간
    FSelectTime: TDateTime;
    // VIP ZONE 여부
    FVipTeebox: Boolean;                     // 다중선택시 VIP타석은 어떻게 할 것 인가?
    // 전체 타석 보기(층구분 없이)
    FAllTeeBoxShow: Boolean;

    // 광고 리스트
    FAdvertisementListUp: TList<TAdvertisement>;
    FAdvertisementListDown: TList<TAdvertisement>;

    // 팝업
    // 타석 선택
    FPopUpLevel: TPopUpLevel;
    // 전체화면 팝업
    FPopUpFullLevel: TPopUpFullLevel;
    // 회원 종류 선택 기간/쿠폰/일일
    FmemberItemType: TMemberItemType;
    // 회원이 선택한 타석 정보
    FTeeBoxInfo: TTeeBoxInfo;

    // 타석 가동상확 타입
    FTeeBoxSortType: TTeeBoxSortType;
    // 카드결제 유형
    //FCardApplyType: TCardApplyType;

    FPrint: TReceiptPrint;

    FUCBioBSPHelper: TUCBioBSPHelper;

    FIsComplete: Boolean;
    FMiniMapCursor: Boolean;
    FPrepareMin: Integer;

    FTeeboxTimeError: Boolean;

    // 쿠폰 회원 조회
    FCouponMember: Boolean;
  public
    FingerStr: string;
    ConfigJsonText: string;
    // 회원 정보 수신 시간
    MemberInfoDownLoadDateTime: string;
    NowHour: string;
    NowTime: string;
    // 미니맵 width
    MiniMapWidth: Integer;

    FStoreCloseOver: Boolean;
    FStoreCloseOverMin: String;
    FSendPrintError: Boolean;

    //지문등록시 인증정보
    FCheckMemberCode: String;
    FCheckAuthCode: String;

    FProfileImg: String;
    FNoticeMsg: String;

    constructor Create;
    destructor Destroy; override;

    // 버전 체크
    function MasterReception(AType: Integer = 0): Boolean;

    function SetPrintData: string;

    procedure SaleDataClear;

    // 마스터
    function GetMemberList: Boolean;
    function GetConfig: Boolean;

    function GetTeeBoxInfo: Boolean;
    function GetPlayingTeeBoxList: Boolean;

    function DeviceInit: Boolean;

    // 직원호출
    function CallAdmin: Boolean;
    function CallIntroBlack: Boolean;

    // 타석시간 체크
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
    property MainItemList: TList<TTeeBoxInfo> read FMainItemList write FMainItemList;

    property AdvertisementListUp: TList<TAdvertisement> read FAdvertisementListUp write FAdvertisementListUp;
    property AdvertisementListDown: TList<TAdvertisement> read FAdvertisementListDown write FAdvertisementListDown;

    property PopUpLevel: TPopUpLevel read FPopUpLevel write FPopUpLevel;
    property PopUpFullLevel: TPopUpFullLevel read FPopUpFullLevel write FPopUpFullLevel;

    property Print: TReceiptPrint read FPrint write FPrint;

    property UCBioBSPHelper: TUCBioBSPHelper read FUCBioBSPHelper write FUCBioBSPHelper;

    property TeeBoxSortType: TTeeBoxSortType read FTeeBoxSortType write FTeeBoxSortType;
    property SelectTime: TDateTime read FSelectTime write FSelectTime;

    property IsComplete: Boolean read FIsComplete write FIsComplete;
    property PrepareMin: Integer read FPrepareMin write FPrepareMin;
    property VipTeeBox: Boolean read FVipTeeBox write FVipTeeBox;
    property AllTeeBoxShow: Boolean read FAllTeeBoxShow write FAllTeeBoxShow;
    property MainItemMapUse: Boolean read FMainItemMapUse write FMainItemMapUse;
    property MiniMapCursor: Boolean read FMiniMapCursor write FMiniMapCursor;
    //property MasterDownThread: TMasterDownThread read FMasterDownThread write FMasterDownThread;
    property TeeboxTimeError: Boolean read FTeeboxTimeError write FTeeboxTimeError;

    property CouponMember: Boolean read FCouponMember write FCouponMember;
  end;

var
  SaleModule: TSaleModule;

implementation

uses
  uGlobal, uCommon, uFunction, fx.Logging;

{ TSaleModule }

function TSaleModule.CallAdmin: Boolean;
begin
  Result := False;

  Global.SBMessage.ShowMessageModalForm2(MSG_PRINT_ADMIN_CALL, True, 30, True, True);

  Result := True;
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

constructor TSaleModule.Create;
begin
  ConfigJsonText := EmptyStr;
  ProgramUse := True;

  MemberList := TList<TMemberInfo>.Create;
  MemberUpdateList := TList<TMemberInfo>.Create;
  ProductList := TList<TProductInfo>.Create;
  SaleList := TList<TProductInfo>.Create;
  MainItemList := TList<TTeeBoxInfo>.Create;

  AdvertisementListUp := TList<TAdvertisement>.Create;
  AdvertisementListDown := TList<TAdvertisement>.Create;

  VipTeeBox := False;
  AllTeeBoxShow := False;
  MainItemMapUse := False;
  TeeBoxSortType := tstDefault;
  MiniMapCursor := False;
  //MasterDownThread := TMasterDownThread.Create;
  MemberInfoDownLoadDateTime := EmptyStr;
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

    if SaleList <> nil then
      SaleList.Free;

    //광고
    if AdvertisementListUp <> nil then
      AdvertisementListUp.Free;

    if AdvertisementListDown <> nil then
      AdvertisementListDown.Free;
    {
    if not Global.Config.NoPayModule then
    begin
      //VanModule.Free;
      //PaycoModule.Free;
    end;
    }
    if not Global.Config.NoDevice then
    begin
      UCBioBSPHelper.Free;
      Print.Free;
    end;

    {
    if FMasterDownThread <> nil then
    begin
      FMasterDownThread.Terminate;
      //FMasterDownThread.WaitFor; //타석현황 화면 이후 waitfor를 넘어가지 못함...
      //FMasterDownThread.Free;
    end;
    }
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

      if MemberList.Count = 0 then
      begin

        rMemberInfoList := Global.ELoomApi.GetAllMemberInfo;
        for nIndex := 0 to rMemberInfoList.Count - 1 do
        begin
          MemberList.Add(rMemberInfoList[nIndex]);
        end;
        FreeAndNil(rMemberInfoList);
        //ncnt := MemberList.Count;
      end
      else
        MemberUpdateList := Global.ELoomApi.GetAllMemberInfo;

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
    if Global.ELoomApi.GetConfig then
      Global.Config.LoadConfigV1;

    Result := True;
  finally

  end;
end;

function TSaleModule.GetTeeBoxInfo: Boolean;
var
  AList: TList<TTeeBoxInfo>;
  nIndex: Integer;
begin
  try
    Result := False;
    AList := Global.ELoomApi.GetTeeBoxMaster;
    if AList.Count <> 0 then
    begin

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
begin
  try
    Result := False;
    Global.LocalApi.GetTeeBoxPlayingInfo;

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

    if not Global.Config.NoDevice then
    begin
      UCBioBSPHelper := TUCBioBSPHelper.Create;
      UCBioBSPHelper.EnrollQuality := Global.Config.Finger.EnrollImageQuality; //품질
      UCBioBSPHelper.VerifyQuality := Global.Config.Finger.VerifyImageQuality; //비교
      UCBioBSPHelper.DefaultTimeout := 7000;   //디폴트로 이 값은 10000(10초)을 가진다.
      UCBioBSPHelper.SecurityLevel := Global.Config.Finger.SecurityLevel; //보안

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

function TSaleModule.MasterReception(AType: Integer): Boolean;
var
  AVersion: string;
begin
  try
    Result := False;

    AVersion := Global.ELoomApi.GetAllMmeberInfoVersion;
    if Global.Config.Version.MemberVersion <> AVersion then
    begin
      Global.Config.Version.MemberVersion := AVersion;
      Global.SaleModule.GetMemberList;
    end;
    Result := True;

  except
    on E: Exception do
    begin

    end;
  end;
end;

function TSaleModule.SetPrintData: string;
var
  Main, Store, Order, MemberObJect, Receipt, JsonItem: TJSONObject;
  ProductList, OrderList: TJSONArray;
begin
  Main := TJSONObject.Create;
  Store := TJSONObject.Create;
  MemberObJect := TJSONObject.Create;
  Receipt := TJSONObject.Create;

  OrderList := TJSONArray.Create;
  ProductList := TJSONArray.Create;
  //Discount := TJSONArray.Create;
  //PayList := TJSONArray.Create;
  try
    try
//      Log.D('프린터 JSON Begin', Result);

      Main.AddPair(TJSONPair.Create('StoreInfo', Store));
      Main.AddPair(TJSONPair.Create('OrderList', OrderList));
      Main.AddPair(TJSONPair.Create('ReceiptMemberInfo', MemberObJect));
      Main.AddPair(TJSONPair.Create('ProductInfo', ProductList));
      //Main.AddPair(TJSONPair.Create('PayInfo', PayList));
      //Main.AddPair(TJSONPair.Create('DiscountInfo', Discount));
      Main.AddPair(TJSONPair.Create('ReceiptEtc', Receipt));

      Store.AddPair(TJSONPair.Create('StoreName', Global.Config.Store.StoreName));

      // 키오스크는 1개 POS는 반복문 사용
      JsonItem := TJSONObject.Create;
      JsonItem.AddPair(TJSONPair.Create('TeeBox_Floor', TeeBoxInfo.FloorNm));

      JsonItem.AddPair(TJSONPair.Create('TeeBox_Nm', TeeBoxInfo.Name));
      JsonItem.AddPair(TJSONPair.Create('Parking_Barcode', SelectProduct.Reserve_Time));
      JsonItem.AddPair(TJSONPair.Create('ProductDiv', SelectProduct.Product_Div));
      JsonItem.AddPair(TJSONPair.Create('UseTime', SelectProduct.Start_Time));
      JsonItem.AddPair(TJSONPair.Create('One_Use_Time', SelectProduct.One_Use_Time));
      JsonItem.AddPair(TJSONPair.Create('Reserve_No', SelectProduct.Reserve_No));

      // 아래 5개는 쿠폰에 관련된 내용
      JsonItem.AddPair(TJSONPair.Create('UseProductName', SelectProduct.Name));
      JsonItem.AddPair(TJSONPair.Create('Coupon', TJSONBool.Create(IfThen(SelectProduct.Product_Div = PRODUCT_TYPE_C, True, False)).ToString)); // 쿠폰 사용 여부
      JsonItem.AddPair(TJSONPair.Create('CouponQty', TJSONNumber.Create(SelectProduct.Use_Qty)));  // 잔여 쿠폰 수
      JsonItem.AddPair(TJSONPair.Create('CouponUseDate', SelectProduct.Reserve_List));
      JsonItem.AddPair(TJSONPair.Create('ExpireDate', DateTimeSetString(SelectProduct.EndDate)));
      OrderList.Add(JsonItem);

      if (Member.Code <> EmptyStr) then
      begin
        MemberObJect.AddPair(TJSONPair.Create('Name', Member.Name));
        MemberObJect.AddPair(TJSONPair.Create('Code', Member.Code));
      end;

      Receipt.AddPair(TJSONPair.Create('RcpNo', TJSONNumber.Create(RcpNo)));
      Receipt.AddPair(TJSONPair.Create('SaleDate', FormatDateTime('yyyy-mm-dd', now)));
      Receipt.AddPair(TJSONPair.Create('ReturnDate', EmptyStr));
      Receipt.AddPair(TJSONPair.Create('RePrint', TJSONBool.Create(False).ToString));  // 재출력 여부
      Receipt.AddPair(TJSONPair.Create('Receipt_No', RcpAspNo));
      Receipt.AddPair(TJSONPair.Create('Top1', Global.Config.Receipt.Top1));
      Receipt.AddPair(TJSONPair.Create('Top2', Global.Config.Receipt.Top2));
      Receipt.AddPair(TJSONPair.Create('Top3', Global.Config.Receipt.Top3));
      Receipt.AddPair(TJSONPair.Create('Top4', Global.Config.Receipt.Top4));
      Receipt.AddPair(TJSONPair.Create('Bottom1', Global.Config.Receipt.Bottom1));
      Receipt.AddPair(TJSONPair.Create('Bottom2', Global.Config.Receipt.Bottom2));
      Receipt.AddPair(TJSONPair.Create('Bottom3', Global.Config.Receipt.Bottom3));
      Receipt.AddPair(TJSONPair.Create('Bottom4', Global.Config.Receipt.Bottom4));

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
          Log.D('CheckEndTime', '10분 이상');
          Log.D('CheckEndTime - Begin', Global.SaleModule.TeeBoxInfo.End_Time);
          Log.D('CheckEndTime - End', RealTime);

          Msg := Format(MSG_TEEBOX_TIME_ERROR, [Copy(ASelectTime, 1, 2) + ':' + Copy(ASelectTime, 3, 2),
                                                Copy(RealTime, 1, 2) + ':' + Copy(RealTime, 3, 2)]);

          if not Global.SBMessage.ShowMessageModalForm(Msg, False) then
          begin
            Log.D('TeeboxTimeCheck', '사용자 배정 취소');
            Exit;
          end;
        end
        else
        begin
          Log.D('CheckEndTime', '10분 이하');
          Log.D('CheckEndTime - Begin', Global.SaleModule.TeeBoxInfo.End_Time);
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

procedure TSaleModule.SaleDataClear;
var
  Index: Integer;
  ATeeBoxInfo: TTeeBoxInfo;
  AMemberInfo: TMemberInfo;
  AProduct: TProductInfo;
begin
  try
    RcpNo := 0;
    RcpAspNo := EmptyStr;
    IsComplete := False;
    VipTeeBox := False;

    ATeeBoxInfo.TasukNo := -1;
    TeeBoxInfo := ATeeBoxInfo;

    AMemberInfo.Code := EmptyStr;

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

    PopUpLevel := plNone;
    PopUpFullLevel := pflNone;

    MiniMapCursor := False;

    PrepareMin := StrToIntDef(Global.Config.PrePare_Min, 5);

    if Global.SaleModule.SaleDate <> FormatDateTime('yyyymmdd', now) then
      Global.SaleModule.SaleDate := FormatDateTime('yyyymmdd', now);

    TeeboxTimeError := False;

    CouponMember := False;

    FStoreCloseOver := False;
    FStoreCloseOverMin := EmptyStr;
    FSendPrintError := False;

    FCheckMemberCode := EmptyStr;
    FCheckAuthCode := EmptyStr;
    FingerStr := EmptyStr;

    FProfileImg := EmptyStr;
    FNoticeMsg := EmptyStr;

  except
    on E: Exception do
    begin
      Log.E('SaleDataClear', E.Message);
    end;
  end;
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
        AVersion := Global.XPartnersApi.GetAdvertisVersion;
        if Global.Config.Version.AdvertisVersion <> AVersion then
        begin
          Global.Config.Version.AdvertisVersion := AVersion;
    //      Global.Database.SearchAdvertisList;
          Synchronize(Global.XPartnersApi.SearchAdvertisList);
        end;
        FAdvertis := 0;
      end;
      Sleep(1200000); // 20분 딜레이 최대 40분 이후 적용
      Inc(FAdvertis);
    end;
  end;
end;
}

end.
