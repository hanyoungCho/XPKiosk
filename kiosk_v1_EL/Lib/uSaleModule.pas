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
    // ��׶��� ������ ����
    //FMasterDownThread: TMasterDownThread;
    // ���α׷� ��� ���� ����
    FProgramUse: Boolean;
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
    FSelectProduct: TProductInfo;
    // ���� �ð�
    FSelectTime: TDateTime;
    // VIP ZONE ����
    FVipTeebox: Boolean;                     // ���߼��ý� VIPŸ���� ��� �� �� �ΰ�?
    // ��ü Ÿ�� ����(������ ����)
    FAllTeeBoxShow: Boolean;

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
    //FCardApplyType: TCardApplyType;

    FPrint: TReceiptPrint;

    FUCBioBSPHelper: TUCBioBSPHelper;

    FIsComplete: Boolean;
    FMiniMapCursor: Boolean;
    FPrepareMin: Integer;

    FTeeboxTimeError: Boolean;

    // ���� ȸ�� ��ȸ
    FCouponMember: Boolean;
  public
    FingerStr: string;
    ConfigJsonText: string;
    // ȸ�� ���� ���� �ð�
    MemberInfoDownLoadDateTime: string;
    NowHour: string;
    NowTime: string;
    // �̴ϸ� width
    MiniMapWidth: Integer;

    FStoreCloseOver: Boolean;
    FStoreCloseOverMin: String;
    FSendPrintError: Boolean;

    //������Ͻ� ��������
    FCheckMemberCode: String;
    FCheckAuthCode: String;

    FProfileImg: String;
    FNoticeMsg: String;

    constructor Create;
    destructor Destroy; override;

    // ���� üũ
    function MasterReception(AType: Integer = 0): Boolean;

    function SetPrintData: string;

    procedure SaleDataClear;

    // ������
    function GetMemberList: Boolean;
    function GetConfig: Boolean;

    function GetTeeBoxInfo: Boolean;
    function GetPlayingTeeBoxList: Boolean;

    function DeviceInit: Boolean;

    // ����ȣ��
    function CallAdmin: Boolean;
    function CallIntroBlack: Boolean;

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

    //����
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
      //FMasterDownThread.WaitFor; //Ÿ����Ȳ ȭ�� ���� waitfor�� �Ѿ�� ����...
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

    //ȯ�漳�� ���� ����
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
      UCBioBSPHelper.EnrollQuality := Global.Config.Finger.EnrollImageQuality; //ǰ��
      UCBioBSPHelper.VerifyQuality := Global.Config.Finger.VerifyImageQuality; //��
      UCBioBSPHelper.DefaultTimeout := 7000;   //����Ʈ�� �� ���� 10000(10��)�� ������.
      UCBioBSPHelper.SecurityLevel := Global.Config.Finger.SecurityLevel; //����

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
//      Log.D('������ JSON Begin', Result);

      Main.AddPair(TJSONPair.Create('StoreInfo', Store));
      Main.AddPair(TJSONPair.Create('OrderList', OrderList));
      Main.AddPair(TJSONPair.Create('ReceiptMemberInfo', MemberObJect));
      Main.AddPair(TJSONPair.Create('ProductInfo', ProductList));
      //Main.AddPair(TJSONPair.Create('PayInfo', PayList));
      //Main.AddPair(TJSONPair.Create('DiscountInfo', Discount));
      Main.AddPair(TJSONPair.Create('ReceiptEtc', Receipt));

      Store.AddPair(TJSONPair.Create('StoreName', Global.Config.Store.StoreName));

      // Ű����ũ�� 1�� POS�� �ݺ��� ���
      JsonItem := TJSONObject.Create;
      JsonItem.AddPair(TJSONPair.Create('TeeBox_Floor', TeeBoxInfo.FloorNm));

      JsonItem.AddPair(TJSONPair.Create('TeeBox_Nm', TeeBoxInfo.Name));
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

      if (Member.Code <> EmptyStr) then
      begin
        MemberObJect.AddPair(TJSONPair.Create('Name', Member.Name));
        MemberObJect.AddPair(TJSONPair.Create('Code', Member.Code));
      end;

      Receipt.AddPair(TJSONPair.Create('RcpNo', TJSONNumber.Create(RcpNo)));
      Receipt.AddPair(TJSONPair.Create('SaleDate', FormatDateTime('yyyy-mm-dd', now)));
      Receipt.AddPair(TJSONPair.Create('ReturnDate', EmptyStr));
      Receipt.AddPair(TJSONPair.Create('RePrint', TJSONBool.Create(False).ToString));  // ����� ����
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
      Sleep(1200000); // 20�� ������ �ִ� 40�� ���� ����
      Inc(FAdvertis);
    end;
  end;
end;
}

end.
