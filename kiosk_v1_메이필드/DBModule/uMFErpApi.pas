unit uMFErpApi;

interface

uses
  IdGlobal, FMX.Graphics, IdCoderMIME, InIFiles, IdSSL, IdSSLOpenSSL,
  uStruct, System.Variants, System.SysUtils, System.Classes,
  Generics.Collections, Uni, IdHTTP, JSON, EncdDecd, IdURI, uConsts;

type
  {
  TSendAPIThread = class(TThread)
  private
  protected
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;
  end;
  }

  TMFErpApi = class
  private
    FAuthorization: AnsiString;
    FUTF8Str: UTF8String;

    function Send_MF_API(MethodType: TMethodType; AUrl, AJsonText: string; NotSaveLog: Boolean = False): AnsiString;
    function GetVersion(AUrl: string): string;
  public
    sslIOHandler: TIdSSLIOHandlerSocketOpenSSL;
    constructor Create;
    destructor Destroy; override;

    // 회원데이터를 가져온다.
    function GetAllMmeberInfoVersion: string;
    function GetAllMemberInfo: TList<TMemberInfo>;

    // 회원의 상품 리스트를 가져온다
    function GetMemberProductList(ACardNo, ACode, ADate: string): TList<TProductInfo>;

    // 타석 마스터 정보를 읽어 온다.
    function GetTeeBoxMasterVersion: string;
    function GetTeeBoxMaster: TList<TTeeBoxInfo>;
    // 타석 정보를 읽어 온다.
    function GetTeeBoxPlayingInfo: TList<TTeeBoxInfo>;

    // 타석 상품을 가져온다.
    function GetTeeBoxProductListVersion: string;
    function GetTeeBoxProductList: TList<TProductInfo>;

    // 가맹점 정보 조회
    function GetStoreInfo: Boolean;

    // 타석 홀드
    function TeeBoxHold(AIsHold: Boolean = True): Boolean;

    // 타석 예약 등록
    function TeeBoxListReservation: Boolean;

    // 매출 등록
    function SaveSaleInfo: Boolean;

    // 프로모션 확인
    //function SearchPromotion(ACoupon: string): Boolean;
    //function CouponError(ACode: string): string;

    // 카드사 할인 체크
    //function SearchCardDiscount(ACardNo, ACardAmt: string; out ACode, AMsg: string): Currency;

    property Authorization: AnsiString read FAuthorization write FAuthorization;
    property UTF8Str: UTF8String read FUTF8Str write FUTF8Str;
  end;

implementation

uses
  uGlobal, uSaleModule, fx.Logging, uFunction, uCommon;

{ TASPDatabase }

constructor TMFErpApi.Create;
begin
//  FSendAPIThread := TSendAPIThread.Create;
  sslIOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  sslIOHandler.SSLOptions.Method := sslvSSLv23;
  sslIOHandler.SSLOptions.Mode := sslmClient;
end;

destructor TMFErpApi.Destroy;
begin
//  FSendAPIThread.Free;
//  FreeAndNil(SendData);
//  FreeAndNil(RecvData);

  sslIOHandler.Free;
//  SendData.Free;
//  RecvData.Free;
  inherited;
end;

function TMFErpApi.GetAllMmeberInfoVersion: string;
begin
  Result := GetVersion('K213_MemberVersion?store_cd=' + Global.Config.Store.StoreCode);
  if Result = EmptyStr then
    Result := Global.Config.Version.MemberVersion;
end;

function TMFErpApi.GetAllMemberInfo: TList<TMemberInfo>;
var
  Index, Loop, tmp: Integer;
  AMemberInfo: TMemberInfo;
  MainJson, jObj, jObjItem: TJSONObject;
  jObjArr: TJsonArray;
  JsonText, AVersion, SendDatetime: string;
  ABytes: TBytes;
  AFingerStr: AnsiString;

  nCnt: Integer;
begin
  try
    Result := TList<TMemberInfo>.Create;

    //SendDatetime := Global.SaleModule.MemberInfoDownLoadDateTime;
    SendDatetime := Global.Config.MemberInfoDownLoadDateTime;

    //메이필드 회원정보 로컬DB 저장 ini 파일에 마지막 조회 시간 저장
    //if Global.SaleModule.MemberInfoDownLoadDateTime = EmptyStr then
      //Global.SaleModule.MemberInfoDownLoadDateTime := FormatDateTime('yyyymmddhhnnss', now);

    //if SendDatetime <> EmptyStr then
      JsonText := Send_MF_API(mtGet, 'K214_MemberlistSimple?search_date=' + SendDatetime + '&store_cd=' + Global.Config.Store.StoreCode, EmptyStr);
    //else
      //JsonText := Send_MF_API(mtGet, 'K214_MemberlistSimple?store_cd=' + Global.Config.Store.StoreCode, EmptyStr);

    if JsonText = EmptyStr then
      Exit;

//    Log.D('회원정보', JsonText);
    MainJson := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;

    if MainJson.FindValue('resultData') is TJSONNull then
      Exit;

    jObj := MainJson.GetValue('resultData') as TJSONObject;

    if '0000' = jObj.GetValue('result_cd').Value then
    begin
      Global.Config.MemberInfoDownLoadDateTime := FormatDateTime('yyyymmddhhnnss', now);

      Global.Config.SetConfig('STORE', 'MemberInfoDownLoadDateTime', Global.Config.MemberInfoDownLoadDateTime);

      jObjArr := jObj.GetValue('list') as TJsonArray;
      nCnt := jObjArr.Size;

      Log.D('저장할 회원 수', Inttostr(nCnt));
      for Index := 0 to nCnt - 1 do
      begin
        AMemberInfo.FingerStr := EmptyStr;

        jObjItem := jObjArr.Get(Index) as TJSONObject;
        AMemberInfo.Code := jObjItem.GetValue('member_no').Value;
        AMemberInfo.Name := jObjItem.GetValue('member_nm').Value;
        AMemberInfo.Sex := IfThen(StrToIntDef(jObjItem.GetValue('sex_div').Value, 1) = 1, 'M', 'W');
        AMemberInfo.Tel_Mobile := jObjItem.GetValue('hp_no').Value;
        //고객 구분		customer_cd
        //단체 코드		group_cd
        AMemberInfo.MemberCardUid := jObjItem.GetValue('member_card_uid').Value; //회원 카드 고유번호
        AMemberInfo.WelfareCd := jObjItem.GetValue('welfare_cd').Value;
        //사원 번호		emp_no
        //회원 포인트		member_point
        //회원 할인율		dc_rate
        AMemberInfo.CardNo := jObjItem.GetValue('qr_cd').Value;
        AMemberInfo.FingerStr := jObjItem.GetValue('fingerprint1').Value;
        AMemberInfo.FingerStr_2 := jObjItem.GetValue('fingerprint2').Value;
        //특별회원 여부		special_yn
        AMemberInfo.Use := jObjItem.GetValue('del_yn').Value = 'N';

        if (Global.SaleModule.MemberList.Count <> 0) then
        begin
          for tmp := 0 to Global.SaleModule.MemberList.Count - 1 do
          begin
            if AMemberInfo.Code = Global.SaleModule.MemberList[tmp].Code then
            begin
              Global.SaleModule.MemberList.Delete(tmp);
              Break;
            end;
          end;
        end;

        if AMemberInfo.Use then
          Result.Add(AMemberInfo);
      end;
    end;

  finally
    FreeAndNil(MainJson);

    Log.D('저장된 회원 수', inttostr(Result.Count));
  end;

end;

function TMFErpApi.GetMemberProductList(ACardNo, ACode, ADate: string): TList<TProductInfo>;
var
  Index, Loop, Cnt, ProductUseCnt: Integer;
  MainJson, jObj, jObjItem: TJSONObject;
  jObjArr: TJsonArray;
  JsonText, NowDay, NowTime: string;
  AProduct: TProductInfo;
  AProductList: TList<TProductInfo>;
begin
  try
    Result := TList<TProductInfo>.Create;
    AProductList := TList<TProductInfo>.Create;

    NowDay := EmptyStr;
    NowTime := EmptyStr;

    JsonText := Send_MF_API(mtGet, 'K306_GetMemberTeeBoxProduct?member_no=' + ACardNo + '&store_cd=' + Global.Config.Store.StoreCode, EmptyStr);

    if JsonText = EmptyStr then
      Exit;

    Log.D('GetMemberProductList JsonText', LogReplace(JsonText));

    MainJson := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;

    if MainJson.FindValue('resultData') is TJSONNull then
      Exit;

    jObj := MainJson.GetValue('resultData') as TJSONObject;

    if '0000' = jObj.GetValue('result_cd').Value then
    begin

      jObjArr := jObj.GetValue('result_data') as TJsonArray;
      for Index := 0 to jObjArr.Count - 1 do
      begin
        jObjItem := jObjArr.Get(Index) as TJSONObject;

        AProduct.Code := jObjItem.GetValue('product_cd').Value;
        AProduct.Name := jObjItem.GetValue('product_nm').Value;
        AProduct.ProductBuyCode := jObjItem.GetValue('purchase_cd').Value;
        AProduct.StartDate := jObjItem.GetValue('start_day').Value;
        AProduct.EndDate := jObjItem.GetValue('end_day').Value;
        AProduct.Use_Qty := StrToIntDef(jObjItem.GetValue('coupon_cnt').Value, 0);
        AProduct.Product_Div := jObjItem.GetValue('product_div').Value;

        AProduct.Start_Time := StringReplace(jObjItem.GetValue('day_start_time').Value, ':', '', [rfReplaceAll]);
        AProduct.End_Time := StringReplace(jObjItem.GetValue('day_end_time').Value, ':', '', [rfReplaceAll]);

        if AProduct.Product_Div = PRODUCT_TYPE_C then
          AProduct.Use := (jObjItem.GetValue('today_yn').Value = 'Y') and (AProduct.Use_Qty <> 0)
        else
          AProduct.Use := (jObjItem.GetValue('today_yn').Value = 'Y');

        // today_yn 이 N 으로 들어옴
        //AProduct.Use := True;

        AProduct.One_Use_Time := jObjItem.GetValue('one_use_time').Value;

        NowDay := FormatDateTime('yyyymmdd', now);
        NowTime := FormatDateTime('hhnn', now);

        if AProduct.Use then
          AProduct.Use := (NowDay >= AProduct.StartDate) and (NowDay <= AProduct.EndDate);

        if AProduct.Use then
          AProduct.Use := (NowTime >= AProduct.Start_Time) and (NowTime <= AProduct.End_Time);

        if AProduct.Use then
        begin
          AProductList.Add(AProduct);
        end;
      end;

      if AProductList.Count <> 0 then
      begin
        for Index := 0 to AProductList.Count - 1 do
        begin
          if AProductList[Index].Product_Div = 'R' then
          begin
            Result.Add(AProductList[Index]);
          end;
        end;

        for Index := 0 to AProductList.Count - 1 do
        begin
          if AProductList[Index].Product_Div = 'C' then
          begin
            Result.Add(AProductList[Index]);
          end;
        end;

      end;

    end;

  finally
    FreeAndNil(MainJson);;
    FreeAndNil(AProductList);
  end;
end;

function TMFErpApi.GetStoreInfo: Boolean;
var
  Index, nCnt: Integer;
  MainJson, jObj, jObjItem, jObjSub: TJSONObject;
  jObjArr: TJsonArray;
  JsonText: string;
  Agreement: TAgreement;
  FileExtract, FileName: string;

  AIndy: TIdHTTP;
  mStream: TMemoryStream;
  sslIOHandler : TIdSSLIOHandlerSocketOpenSSL;
  FileUrl, FilePath: String;
begin
  try
    Result := False;

    JsonText := Send_MF_API(mtGet, 'K203_StoreInfo?store_cd=' + Global.Config.Store.StoreCode, EmptyStr, True);

    if JsonText = EmptyStr then
      Exit;

    MainJson := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;

    if MainJson.FindValue('resultData') is TJSONNull then
      Exit;

    jObj := MainJson.GetValue('resultData') as TJSONObject;

    if '0000' = jObj.GetValue('result_cd').Value then
    begin

      jObjArr := jObj.GetValue('result_data') as TJsonArray;
      nCnt := jObjArr.size;

      for Index := 0 to nCnt - 1 do
      begin
        jObjItem := jObjArr.Get(Index) as TJSONObject;

        Global.Config.Store.StoreName := jObjItem.GetValue('store_nm').Value;
        Global.Config.Store.BossName := jObjItem.GetValue('owner_nm').Value;
        Global.Config.Store.Tel := jObjItem.GetValue('tel_no').Value;
        Global.Config.Store.Addr := jObjItem.GetValue('address').Value +
                                      jObjItem.GetValue('address_desc').Value;
        Global.Config.Store.StoreStartTime := jObjItem.GetValue('start_time').Value;
        Global.Config.Store.StoreEndTime := jObjItem.GetValue('end_time').Value;

        //SetServerLocalTime(jObjItem.GetValue('server_time').Value);

        Global.Config.Store.StoreCloseStartTime := jObjItem.GetValue('close_start_date').Value;
        if Global.Config.Store.StoreCloseStartTime = 'null' then
          Global.Config.Store.StoreCloseStartTime := EmptyStr;

        Global.Config.Store.StoreCloseEndTime := jObjItem.GetValue('close_end_date').Value;
        if Global.Config.Store.StoreCloseEndTime = 'null' then
          Global.Config.Store.StoreCloseEndTime := EmptyStr;

      end;

    end;

    Result := True;
    Global.Config.SaveLocalConfig;
  finally
    FreeAndNil(MainJson);
    //FreeAndNil(JsonValue);
  end;
end;

function TMFErpApi.GetTeeBoxMasterVersion: string;
begin
  Result := GetVersion('K203_TeeBoxVersion?store_cd=' + Global.Config.Store.StoreCode);
  if Result = EmptyStr then
    Result := Global.Config.Version.TeeBoxMasterVersion;
end;

function TMFErpApi.GetTeeBoxMaster: TList<TTeeBoxInfo>;
var
  Index, nCnt: Integer;
  ATeeBoxInfo: TTeeBoxInfo;
  MainJson, jObj, jObjItem: TJSONObject;
  jObjArr: TJsonArray;
  //JsonValue, ItemValue: TJSONValue;
  JsonText, AVersion: string;
begin
  try
    Result := TList<TTeeBoxInfo>.Create;
    //MainJson := TJSONObject.Create;
    //JsonValue := TJSONValue.Create;

    JsonText := Send_MF_API(mtGet, 'K204_TeeBoxlist?store_cd=' + Global.Config.Store.StoreCode, EmptyStr);

//    Log.D('타석 마스터', JsonText);

    if JsonText = EmptyStr then
      Exit;

    MainJson := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;;

    if MainJson.FindValue('resultData') is TJSONNull then
      Exit;

    jObj := MainJson.GetValue('resultData') as TJSONObject;

    if '0000' = jObj.GetValue('result_cd').Value then
    begin

      jObjArr := jObj.GetValue('list') as TJsonArray;
      nCnt := jObjArr.size;

      for Index := 0 to nCnt - 1 do
      begin
        jObjItem := jObjArr.Get(Index) as TJSONObject;

        ATeeBoxInfo.TasukNo := StrToIntDef(jObjItem.GetValue('teebox_no').Value, 0);
        ATeeBoxInfo.Tasuk := jObjItem.GetValue('teebox_no').Value;
        ATeeBoxInfo.Name := jObjItem.GetValue('teebox_nm').Value;
        ATeeBoxInfo.High := StrToIntDef(jObjItem.GetValue('floor_cd').Value, 0);
        ATeeBoxInfo.FloorNm := jObjItem.GetValue('floor_nm').Value;
        //ATeeBoxInfo.Vip := jObjItem.GetValue('vip_yn').Value = 'Y';
        ATeeBoxInfo.ZoneCode := jObjItem.GetValue('zone_div').Value;
        ATeeBoxInfo.ControlYn := jObjItem.GetValue('control_yn').Value;
        ATeeBoxInfo.Use := jObjItem.GetValue('use_yn').Value = 'Y';

        ATeeBoxInfo.ERR := 0;
        ATeeBoxInfo.Hold := False;
        ATeeBoxInfo.Add_OK := False;
        ATeeBoxInfo.IsAddList := False;

        Result.Add(ATeeBoxInfo);
      end;
    end;
  finally
    FreeAndNil(MainJson);
    //FreeAndNil(JsonValue);
  end;
end;

function TMFErpApi.GetTeeBoxPlayingInfo: TList<TTeeBoxInfo>;
var
  Index, nCnt: Integer;
  ATeeBoxInfo: TTeeBoxInfo;
  MainJson, jObj, jObjItem: TJSONObject;
  jObjArr: TJsonArray;
  JsonText: string;
begin

  try
    try
      for Index := Global.TeeBox.UpdateTeeBoxList.Count - 1 downto 0 do
        Global.TeeBox.UpdateTeeBoxList.Delete(Index);
      Global.TeeBox.UpdateTeeBoxList.Clear;

      JsonText := Send_MF_API(mtGet, 'K402_TeeBoxStatus?store_cd=' + Global.Config.Store.StoreCode, EmptyStr, True);
      //Log.D('가동상황', JsonText);

      if JsonText = EmptyStr then
        Exit;

      MainJson := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;

      if MainJson.FindValue('resultData') is TJSONNull then
        Exit;

      jObj := MainJson.GetValue('resultData') as TJSONObject;

      if '0000' = jObj.GetValue('result_cd').Value then
      begin

        jObjArr := jObj.GetValue('result_data') as TJsonArray;
        nCnt := jObjArr.Size;

        for Index := 0 to nCnt - 1 do
        begin
          jObjItem := jObjArr.Get(Index) as TJSONObject;

          ATeeBoxInfo.TasukNo := StrToIntDef(jObjItem.GetValue('teebox_no').Value, 0);
          ATeeBoxInfo.Tasuk := jObjItem.GetValue('teebox_no').Value;
          ATeeBoxInfo.Name := jObjItem.GetValue('teebox_nm').Value;
          ATeeBoxInfo.High := StrToIntDef(jObjItem.GetValue('floor_cd').Value, 0);
          //ATeeBoxInfo.Vip := (ItemValue as TJSONObject).Get('vip_yn').JsonValue.Value = 'Y';
          ATeeBoxInfo.ZoneCode := jObjItem.GetValue('zone_div').Value;
          ATeeBoxInfo.Use := jObjItem.GetValue('use_yn').Value = 'Y';
          ATeeBoxInfo.ERR := StrToIntDef(jObjItem.GetValue('use_status').Value, 0);
          ATeeBoxInfo.Ma_Time := jObjItem.GetValue('remain_min').Value;

          if jObjItem.GetValue('end_datetime').Value = 'null' then
          begin
            ATeeBoxInfo.End_Time := '';
            ATeeBoxInfo.End_DT := '';
          end
          else
          begin
            ATeeBoxInfo.End_Time := jObjItem.GetValue('end_datetime').Value;
            ATeeBoxInfo.End_DT := jObjItem.GetValue('end_datetime').Value;
          end;

          ATeeBoxInfo.Hold := False;

          if ATeeBoxInfo.ERR in [0, 1, 3, 4] then
            ATeeBoxInfo.ERR := 0;

          if StrToIntDef(jObjItem.GetValue('use_status').Value, 0) = 3 then
            ATeeBoxInfo.Hold := True;

          ATeeBoxInfo.Add_OK := False;
          ATeeBoxInfo.IsAddList := False;
          ATeeBoxInfo.BtweenTime := StrToIntDef(jObjItem.GetValue('remain_min').Value, 0);

          if ATeeBoxInfo.BtweenTime < 0 then
            ATeeBoxInfo.BtweenTime := 0;

          Global.TeeBox.UpdateTeeBoxList.Add(ATeeBoxInfo);
        end;
      end;

      Result := Global.TeeBox.UpdateTeeBoxList;
    except
      on E: Exception do
      begin
        Log.E('GetTeeBoxPlayingInfo', E.Message);
      end;
    end;

  finally
    FreeAndNil(MainJson);
  end;

end;

function TMFErpApi.GetTeeBoxProductListVersion: string;
begin
  Result := GetVersion('K205_TeeBoxProductVersion?store_cd=' + Global.Config.Store.StoreCode);
  if Result = EmptyStr then
    Result := Global.Config.Version.ProductVersion;
end;

function TMFErpApi.GetTeeBoxProductList: TList<TProductInfo>;
var
  Index, WeekUse: Integer;
  MainJson, jObj, jObjItem: TJSONObject;
  jObjArr: TJsonArray;

  AProduct: TProductInfo;
  JsonText, AVersion: string;
  nCnt: Integer;
begin
  try
    Result := TList<TProductInfo>.Create;

    JsonText := Send_MF_API(mtGet, 'K206_TeeBoxProductlist?store_cd=' + Global.Config.Store.StoreCode, EmptyStr);

    if JsonText = EmptyStr then
      Exit;

    Log.D('상품 마스터', JsonText);

    MainJson := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;

    if MainJson.FindValue('resultData') is TJSONNull then
      Exit;

    jObj := MainJson.GetValue('resultData') as TJSONObject;

    if '0000' = jObj.GetValue('result_cd').Value then
    begin

      jObjArr := jObj.GetValue('list') as TJsonArray;
      nCnt := jObjArr.Size;

      for Index := 0 to nCnt - 1 do
      begin
        jObjItem := jObjArr.Get(Index) as TJSONObject;

        if jObjItem.GetValue('del_yn').Value = 'Y' then
          Continue;

        AProduct.Code := jObjItem.GetValue('product_cd').Value;
        AProduct.ZoneCode := jObjItem.GetValue('zone_cd').Value;
        AProduct.Name := jObjItem.GetValue('product_nm').Value;
        AProduct.TypeName := jObjItem.GetValue('product_nm').Value;
        AProduct.Price := StrToIntDef(jObjItem.GetValue('product_amt').Value, 0);
        AProduct.Use := jObjItem.GetValue('use_yn').Value = 'Y';
        AProduct.Yoday_Use := jObjItem.GetValue('today_yn').Value = 'Y';
        AProduct.One_Use_Time := jObjItem.GetValue('one_use_time').Value;
        AProduct.Sex := jObjItem.GetValue('sex').Value;
        AProduct.UseWeek := jObjItem.GetValue('use_div').Value;
        AProduct.Start_Time := jObjItem.GetValue('start_time').Value;
        AProduct.End_Time := jObjItem.GetValue('end_time').Value;
        AProduct.Product_Div := jObjItem.GetValue('product_div').Value;
        AProduct.xgolf_dc_yn := jObjItem.GetValue('xgolf_dc_yn').Value = 'Y';
        AProduct.xgolf_dc_amt := StrToIntDef(jObjItem.GetValue('xgolf_dc_amt').Value, 0);
        AProduct.xgolf_product_amt := StrToIntDef(jObjItem.GetValue('xgolf_product_amt').Value, 0);
        AProduct.UseMonth := jObjItem.GetValue('use_month').Value;
        AProduct.Use_Qty := StrToIntDef(jObjItem.GetValue('use_cnt').Value, 0);
        AProduct.Memo := jObjItem.GetValue('memo').Value;
        //AProduct.Alliance_yn := jObjItem.GetValue('alliance_yn').Value = 'Y';

        WeekUse := DayOfWeek(Now);

        if (Pos('일일', AProduct.Name) > 0) then
        begin
          WeekUse := WeekUse;
        end;

        if WeekUse = 1 then
          WeekUse := 7
        else
          WeekUse := WeekUse - 1;

        if jObjItem.GetValue('kiosk_view_yn').Value <> 'Y' then
          AProduct.Use := False;

        //today_yn 아직 N
        //if AProduct.Use and AProduct.Yoday_Use then
        if AProduct.Use then
          Result.Add(AProduct);
      end;
    end;
  finally
    FreeAndNil(MainJson);
    //FreeAndNil(JsonValue);
  end;
end;

function TMFErpApi.TeeBoxHold(AIsHold: Boolean): Boolean;
var
  MainJson, jObj: TJSONObject;
  AUrl, AStore_CD, TeeBox_No, User_Id: AnsiString;
  JsonText: string;
begin

  begin
    try
      try
        Result := False;

        AStore_CD := Global.Config.Store.StoreCode;
        //TeeBox_No := IntToStr(Global.SaleModule.TeeBoxInfo.TasukNo);
        TeeBox_No := Global.SaleModule.TeeBoxInfo.Tasuk;
        User_Id := Global.Config.Store.UserID;

        AUrl := '?store_cd=' + AStore_CD + '&teebox_no=' + TeeBox_No + '&token=1';

        MainJson := TJSONObject.Create;

        MainJson.AddPair(TJSONPair.Create('store_cd', Global.Config.Store.StoreCode));
        MainJson.AddPair(TJSONPair.Create('token', '1'));
        MainJson.AddPair(TJSONPair.Create('teebox_no', TeeBox_No));

        if AIsHold then
        begin
          JsonText := Send_MF_API(mtPost, 'K405_TeeBoxHold', MainJson.ToString);
          Log.D('K405_TeeBoxHold', LogReplace(JsonText));
        end
        else
        begin
          JsonText := Send_MF_API(mtDelete, 'K406_TeeBoxHold' + AUrl, EmptyStr);
          Log.D('K406_TeeBoxHold', LogReplace(JsonText));
        end;

        MainJson := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;

        if MainJson.FindValue('resultData') is TJSONNull then
          Exit;

        jObj := MainJson.GetValue('resultData') as TJSONObject;

        if '0000' = jObj.GetValue('result_cd').Value then
          Result := True
        else
          Global.SBMessage.ShowMessageModalForm(jObj.GetValue('result_msg').Value);

      except
        on E: Exception do
        begin
          Log.E('TeeBoxHold', '-pass-');
        end;
      end;
    finally
      FreeAndNil(MainJson);
    end;
  end;
end;

function TMFErpApi.TeeBoxListReservation: Boolean;
label ReReserve;
var
  Index, Cnt, nCnt: Integer;
  MainJson, ItemJson: TJSONObject;
  JsonList: TJSONArray;
  ReceJson, ReceItemJson, ReceSubItemJson: TJSONObject;
  RecejObjArr: TJSONArray;
  //JsonValue, JsonListValue: TJSONValue;
  JsonText, ADate: string;
  AProductInfo: TProductInfo;
begin

  try

    try

      if not Global.SaleModule.TeeboxTimeError then
      begin
        Global.TeeBox.GetGMTeeBoxList;
        if not Global.SaleModule.TeeboxTimeCheck then
          Exit;
      end;

      Result := False;
      MainJson := TJSONObject.Create;
      ItemJson := TJSONObject.Create;
      JsonList := TJSONArray.Create;

      MainJson.AddPair(TJSONPair.Create('store_cd', Global.Config.Store.StoreCode));
      //MainJson.AddPair(TJSONPair.Create('token', '1'));
      MainJson.AddPair(TJSONPair.Create('user_id', Global.Config.Store.UserID));
      MainJson.AddPair(TJSONPair.Create('member_no', Global.SaleModule.Member.Code));
      MainJson.AddPair(TJSONPair.Create('reserve_root_div', 'K'));

      //MainJson.AddPair(TJSONPair.Create('receipt_no', Global.SaleModule.RcpAspNo));
      //MainJson.AddPair(TJSONPair.Create('affiliate_cd', Global.SaleModule.allianceCode));
      //ItemJson := TJSONObject.Create;

      MainJson.AddPair(TJSONPair.Create('data', JsonList));
      ItemJson.AddPair(TJSONPair.Create('product_cd', Global.SaleModule.SelectProduct.Code));
      //ItemJson.AddPair(TJSONPair.Create('purchase_cd', Global.SaleModule.SelectProduct.ProductBuyCode));
      ItemJson.AddPair(TJSONPair.Create('purchase_cd', '')); //배정후 매출등록이라 없음.
      ItemJson.AddPair(TJSONPair.Create('teebox_no', Global.SaleModule.TeeBoxInfo.Tasuk));

      //매장종료시간초과시 배정시간 변경
      if Global.SaleModule.FStoreCloseOver = True then
        ItemJson.AddPair(TJSONPair.Create('assign_min', Global.SaleModule.FStoreCloseOverMin))
      else
        ItemJson.AddPair(TJSONPair.Create('assign_min', Global.SaleModule.SelectProduct.One_Use_Time));
//      ItemJson.AddPair(TJSONPair.Create('prepare_min', Global.Config.PrePare_Min));

      ItemJson.AddPair(TJSONPair.Create('assign_balls', '9999'));

      //ItemJson.AddPair(TJSONPair.Create('prepare_min', IfThen(StrToIntDef(Global.Config.PrePare_Min, 5) <> Global.SaleModule.PrepareMin, IntToStr(Global.SaleModule.PrepareMin), Global.Config.PrePare_Min)));
      if StrToIntDef(Global.Config.PrePare_Min, 5) <> Global.SaleModule.PrepareMin then
        ItemJson.AddPair(TJSONPair.Create('prepare_min', IntToStr(Global.SaleModule.PrepareMin)))
      else
        ItemJson.AddPair(TJSONPair.Create('prepare_min', Global.Config.PrePare_Min));

      JsonList.Add(ItemJson);

      Log.D('TeeBoxReservation2', LogReplace(MainJson.ToString));
      //WriteLog(False, 'ApiLog', Global.SaleModule.SaleDate, 'TeeBoxReservation2', LogReplace(MainJson.ToString));
      JsonText := Send_MF_API(mtPost, 'K408_TeeBoxReserve2', MainJson.ToString);

      //WriteLog(False, 'ApiLog', Global.SaleModule.SaleDate, 'TeeBoxReservation2', LogReplace(JsonText));
      Log.D('TeeBoxReservation2', LogReplace(JsonText));

      if JsonText <> EmptyStr then
      begin

        ReceJson := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;

        if ReceJson.FindValue('resultData') is TJSONNull then
          Exit;

        ReceItemJson := ReceJson.GetValue('resultData') as TJSONObject;

        if '0000' = ReceItemJson.GetValue('result_cd').Value then
        begin
          RecejObjArr := ReceItemJson.GetValue('result_data') as TJsonArray;

          AProductInfo := Global.SaleModule.SelectProduct;

          ReceSubItemJson := RecejObjArr.Get(0) as TJSONObject;

          AProductInfo.Reserve_No := ReceSubItemJson.GetValue('reserve_no').Value;
          AProductInfo.Reserve_Time := ReceSubItemJson.GetValue('start_time').Value;
          AProductInfo.Start_Time := ReceSubItemJson.GetValue('start_time').Value;
          AProductInfo.One_Use_Time := ReceSubItemJson.GetValue('remain_min').Value;
          AProductInfo.Use_Qty := StrToIntDef(ReceSubItemJson.GetValue('coupon_cnt').Value, 0); //2021-11-26 주석해제, 잔여쿠폰수
          AProductInfo.Reserve_List := EmptyStr;

          Result := True;

          Global.SaleModule.SelectProduct := AProductInfo;
        end
        else
        begin
          Global.SBMessage.ShowMessageModalForm(ReceItemJson.GetValue('result_msg').Value);
        end;

      end
      else
        Global.SBMessage.ShowMessageModalForm(MSG_TEEBOX_RESERVATION_AD_FAIL);

    except
      on E: Exception do
      begin
        //WriteLog(True, 'ApiLog', Global.SaleModule.SaleDate, 'TeeBoxReservation2', LogReplace(JsonText));
        Log.E('TeeBoxReservation', E.Message);
      end;
    end;

  finally
    FreeAndNil(MainJson);
    FreeAndNil(ReceJson);
  end;

end;

{
function TMFErpApi.SearchPromotion(ACoupon: string): Boolean;
var
  MainJson: TJSONObject;
  JsonValue: TJSONValue;
  AUrl: AnsiString;
  JsonText: AnsiString;
  ADisCount: TDiscount;
begin
  try
    try
      Result := False;

      MainJson := TJSONObject.Create;
      JsonValue := TJSONValue.Create;

      if Copy(ACoupon, 1, 2) = 'C-' then
        AUrl := '?coupon_cd=' + ACoupon +
                IfThen(Global.SaleModule.Member.Code = EmptyStr, '', '&member_no=' + Global.SaleModule.Member.Code) +
                '&store_cd=' + Global.Config.Store.StoreCode
      else
        AUrl := '?coupon_no=' + ACoupon +
                IfThen(Global.SaleModule.Member.Code = EmptyStr, '', '&member_no=' + Global.SaleModule.Member.Code) +
                '&store_cd=' + Global.Config.Store.StoreCode;

      WriteLog(False, 'ApiLog', Global.SaleModule.SaleDate, 'Promotion', LogReplace('K604_CheckCoupon' + AUrl));
      JsonText := Send_MF_API(mtGet, 'K604_CheckCoupon' + AUrl, EmptyStr);
      WriteLog(False, 'ApiLog', Global.SaleModule.SaleDate, 'Promotion', LogReplace(JsonText));

      Log.D('Promotion JsonText', LogReplace(JsonText));
      JsonValue := MainJson.ParseJSONValue(JsonText);

      if (JsonValue as TJSONObject).Get('result_cd').JsonValue.Value = '0000' then
      begin
        if not (JsonValue.FindValue('result_data') is TJSONNull) then
        begin
          ADisCount.QRCode := ACoupon;
          ADisCount.Value := StrToIntDef(((JsonValue as TJSONObject).Get('result_data').JsonValue as TJSONObject).Get('dc_cnt').JsonValue.Value, 0);
          ADisCount.Name := ((JsonValue as TJSONObject).Get('result_data').JsonValue as TJSONObject).Get('coupon_nm').JsonValue.Value;
          ADisCount.Gubun := IfThen(((JsonValue as TJSONObject).Get('result_data').JsonValue as TJSONObject).Get('dc_div').JsonValue.Value = 'R', 1, 0);

          //2021-03-15 쇼골프 프로모션 할인후 취소시 use_yn Y로 내려옴. result_cd 0000 이면 사용가능이므로 체크 제외처리(강태진대표와 협의,긴급배포위해)->차후 파트너센터 수정필요
          //ADisCount.Use := IfThen(((JsonValue as TJSONObject).Get('result_data').JsonValue as TJSONObject).Get('use_yn').JsonValue.Value <> 'Y', True, False);
          ADisCount.Use := True;

          ADisCount.dc_cond_div := ((JsonValue as TJSONObject).Get('result_data').JsonValue as TJSONObject).Get('dc_cond_div').JsonValue.Value;
          ADisCount.Product_Div := ((JsonValue as TJSONObject).Get('result_data').JsonValue as TJSONObject).Get('product_div').JsonValue.Value;
          ADisCount.Product_Div_Detail := ((JsonValue as TJSONObject).Get('result_data').JsonValue as TJSONObject).Get('seat_product_div').JsonValue.Value;

          ADisCount.Add := False;
          ADisCount.Sort := False;

          Log.D('ADisCount.Value', LogReplace(IntToStr(ADisCount.Value)));
          Log.D('ADisCount.Name', LogReplace(ADisCount.Name));
          Log.D('ADisCount.dc_cond_div', LogReplace(ADisCount.dc_cond_div));
          Log.D('ADisCount.product_div', LogReplace(ADisCount.Name));
          Log.D('ADisCount.seat_product_div', LogReplace(ADisCount.Name));
          Log.D('ADisCount.Gubun', LogReplace(((JsonValue as TJSONObject).Get('result_data').JsonValue as TJSONObject).Get('dc_div').JsonValue.Value));

          if Global.SaleModule.AddCheckPromotionType(ADisCount.dc_cond_div) then
            Exit;

          if Global.SaleModule.AddCheckDiscountQR(ADisCount.QRCode) then
          begin
            Global.SBMessage.ShowMessageModalForm(MSG_PROMOTION + MSG_PROMOTION_OPTION_4);
            Exit;
          end;
          if ADisCount.Use then
          begin
            Global.SaleModule.DisCountList.Add(ADisCount);
            Result := True;
          end;
        end;
      end
      else
        Global.SBMessage.ShowMessageModalForm( CouponError((JsonValue as TJSONObject).Get('result_cd').JsonValue.Value) );
    except
      on E: Exception do
      begin
        WriteLog(True, 'ApiLog', Global.SaleModule.SaleDate, 'Promotion', LogReplace(JsonText));
        Log.E('SearchPromotion', E.Message);
      end;
    end;
  finally
    FreeAndNilJSONObject(JsonValue);
    FreeAndNil(MainJson);
    //FreeAndNil(JsonValue);
  end;
end;
}
{
function TMFErpApi.CouponError(ACode: string): string;
begin
  if ACode = 'P04A' then
    Result := '죄송합니다. 쿠폰을 찾을 수 없습니다.'
  else if ACode = 'P04B' then
    Result := '사용일이 도래하지 않았습니다. 감사합니다.'
  else if ACode = 'P04C' then
    Result := '사용일이 이미 지났습니다. 감사합니다.'
  else if ACode = 'P04D' then
    Result := '쿠폰 사용횟수를 모두 사용하셨습니다. 감사합니다.'
  else if ACode = 'P04E' then
    Result := '오늘은 해당 쿠폰을 이미 사용하셨습니다. 감사합니다.'
  else if ACode = 'P04F' then
    Result := '사용하실 수 없는 QR코드 입니다.'
  else
    Result := '알수 없는 오류코드(' + ACode + ')';
end;
}

function TMFErpApi.Send_MF_API(MethodType: TMethodType; AUrl, AJsonText: string; NotSaveLog: Boolean): AnsiString;
var
  Indy: TIdHTTP;
  SendData, RecvData: TStringStream;
begin

  try
    try
      SendData := TStringStream.Create;
      RecvData := TStringStream.Create;

      if not NotSaveLog then
        Log.D('Send_MF_API', 'Begin - ' + AUrl);

      Indy := TIdHTTP.Create(nil);
      Result := EmptyStr;
      SendData.Clear;
      RecvData.Clear;
      Indy.Request.CustomHeaders.Clear;
      Indy.IOHandler := sslIOHandler;
      Indy.URL.URI := Global.Config.Partners.MayfieldURL;
      Indy.Request.CustomHeaders.Values['systemId'] := 'MAYFIELD';

      if AJsonText <> EmptyStr then
      begin
        Indy.Request.ContentType := 'application/json';
        Indy.Request.Accept := '*/*';
        SendData := TStringStream.Create(AJsonText, TEncoding.UTF8);
      end
      else
        Indy.Request.ContentType := 'application/x-www-form-urlencoded';

      Indy.ConnectTimeout := 3000;
      Indy.ReadTimeout := 3000;

      if MethodType = mtGet then
        Indy.Get(Global.Config.Partners.MayfieldURL + AUrl, RecvData)
      else if MethodType = mtPost then
      begin
        Indy.Post(Global.Config.Partners.MayfieldURL + AUrl, SendData, RecvData);
      end
      else if MethodType = mtDelete then
        Indy.Delete(Global.Config.Partners.MayfieldURL + AUrl, RecvData);

      //Log.D('Send_MF_API', 'Send');
      Result := ByteStringToString(RecvData);

      if not NotSaveLog then
        Log.D('Send_MF_API', 'End');
    except
      on E: Exception do
      begin
        Log.E('Send_MF_API', AUrl);
        Log.E('Send_MF_API', E.Message);
      end;
    end;

  finally
//    Indy.Disconnect;
    Indy.Free;
    SendData.Free;
    RecvData.Free;
  end;
end;

function TMFErpApi.GetVersion(AUrl: string): string;
var
  MainJson: TJSONObject;
  JsonValue: TJSONValue;
  JsonText: string;
begin
  try
    try
      Result := EmptyStr;
      MainJson := TJSONObject.Create;
      JsonValue := TJSONValue.Create;
      JsonText := Send_MF_API(mtGet, AUrl, EmptyStr);

      if JsonText = EmptyStr then
        Exit;

      JsonValue := MainJson.ParseJSONValue(JsonText);
      if (JsonValue as TJSONObject).Get('result_cd').JsonValue.Value = '0000' then
      begin
        if not ((JsonValue as TJSONObject).Get('result_data').JsonValue is TJSONNull) then
        begin
          Result := ((JsonValue as TJSONObject).Get('result_data').JsonValue as TJSONObject).Get('version_no').JsonValue.Value;
        end;
      end;

    except
      on E: Exception do
      begin
        Log.E('GetVersion', AUrl);
        Log.E('GetVersion', E.Message);
      end;
    end;
  finally
    FreeAndNilJSONObject(JsonValue);
    FreeAndNilJSONObject(MainJson);
    //MainJson.Free;;
    //JsonValue.Free;
  end;
end;

function TMFErpApi.SaveSaleInfo: Boolean;
label ReSaleSave;
var
  Index, Loop, CardDiscountAmt: Integer;
  Json, MainJson, ItemObject, TeeBoxItem: TJSONObject;
  jReceObj, jReceItemObj, jReceArrItemObj: TJSONObject;
  jReceObjArr: TJsonArray;
  PayMentList, DataList, DiscountList, TeeBoxList: TJSONArray;
  //ItemValue: TJSONValue;
  JsonText: string;
  ACard: TPayCard;
  APayco: TPayPayco;
  AUTF8Str: UTF8String;
  ASaleData: TSaleData;
  allianceAmt: Integer;
  ParkingProduct: TProductInfo;

  nSocketError: Integer;
begin
  try
    try
      Result := False;
      JsonText := EmptyStr;
      Json := TJSONObject.Create;
      MainJson := TJSONObject.Create;
      PayMentList := TJSONArray.Create;
      DataList := TJSONArray.Create;
      DiscountList := TJSONArray.Create;
      CardDiscountAmt := 0;
      allianceAmt := 0;

      nSocketError := 0;

      MainJson.AddPair(TJSONPair.Create('store_cd', Global.Config.Store.StoreCode));
      MainJson.AddPair(TJSONPair.Create('user_id', Global.Config.Store.UserID));
      MainJson.AddPair(TJSONPair.Create('pos_no', Global.Config.OAuth.DeviceID));
      MainJson.AddPair(TJSONPair.Create('client_id', Global.Config.OAuth.DeviceID));
      MainJson.AddPair(TJSONPair.Create('member_no', Global.SaleModule.Member.Code));

      // 매출등록 매칭을 위해 배정번호를 넣는다. 차후 변경될수 있음
      MainJson.AddPair(TJSONPair.Create('xgolf_no', Global.SaleModule.SelectProduct.Reserve_No));

      MainJson.AddPair(TJSONPair.Create('receipt_no', Global.SaleModule.RcpAspNo));
      //MainJson.AddPair(TJSONPair.Create('prev_receipt_no', ''));  // ???
      MainJson.AddPair(TJSONPair.Create('sale_date', FormatDateTime('yyyymmdd', now)));
      MainJson.AddPair(TJSONPair.Create('sale_time', FormatDateTime('hhnn', now)));

      MainJson.AddPair(TJSONPair.Create('total_amt', CurrToStr(Global.SaleModule.TotalAmt)));

      //웰빙등 제휴사 할인
      if Global.SaleModule.allianceCode <> EmptyStr then
        MainJson.AddPair(TJSONPair.Create('sale_amt', CurrToStr(0)))
      else
        MainJson.AddPair(TJSONPair.Create('sale_amt', CurrToStr(Global.SaleModule.RealAmt)));

      MainJson.AddPair(TJSONPair.Create('xgolf_dc_amt', CurrToStr(Global.SaleModule.XGolfDCAmt)));

      MainJson.AddPair(TJSONPair.Create('payment', PayMentList));
      ItemObject := TJSONObject.Create;
      //ItemObject.AddPair(TJSONPair.Create('van_cd', IntToStr(Global.Config.Store.VanCode)));
      ItemObject.AddPair(TJSONPair.Create('van_cd', '31'));
      ItemObject.AddPair(TJSONPair.Create('tid', Global.Config.Store.VanTID));
      ItemObject.AddPair(TJSONPair.Create('internet_yn', 'Y'));
      ItemObject.AddPair(TJSONPair.Create('approve_amt', CurrToStr(Global.SaleModule.RealAmt)));
      ItemObject.AddPair(TJSONPair.Create('vat', CurrToStr(Global.SaleModule.VatAmt)));
      ItemObject.AddPair(TJSONPair.Create('service_amt', '0'));

      if Global.SaleModule.PayList.Count <> 0 then
      begin
        if TPayData(Global.SaleModule.PayList[0]).PayType = ptCard then
        begin
          ACard := TPayCard(Global.SaleModule.PayList[0]);
          ItemObject.AddPair(TJSONPair.Create('pay_method', 'CARD'));
          ItemObject.AddPair(TJSONPair.Create('credit_card_no', ACard.RecvInfo.CardNo));
          ItemObject.AddPair(TJSONPair.Create('inst_mon', IntToStr(ACard.SendInfo.HalbuMonth)));
          ItemObject.AddPair(TJSONPair.Create('approve_no', ACard.RecvInfo.AgreeNo));
          ItemObject.AddPair(TJSONPair.Create('org_approval_no', ''));
          ItemObject.AddPair(TJSONPair.Create('trade_no', ACard.RecvInfo.TransNo));
          ItemObject.AddPair(TJSONPair.Create('trade_date', Copy(ACard.RecvInfo.AgreeDateTime, 1, 8)));
          ItemObject.AddPair(TJSONPair.Create('issuer_cd', ACard.RecvInfo.BalgupsaCode));
          ItemObject.AddPair(TJSONPair.Create('issuer_nm', ACard.RecvInfo.BalgupsaName));
          ItemObject.AddPair(TJSONPair.Create('buyer_div', ''));
          ItemObject.AddPair(TJSONPair.Create('buyer_cd', ACard.RecvInfo.CompCode));
          ItemObject.AddPair(TJSONPair.Create('buyer_nm', ACard.RecvInfo.CompName));
          //ItemObject.AddPair(TJSONPair.Create('pc_seq', IfThen(ACard.CardDiscount = 0, '', Global.SaleModule.CardDiscountGetCode)));
          if ACard.CardDiscount = 0 then
            ItemObject.AddPair(TJSONPair.Create('pc_seq', ''))
          else
            ItemObject.AddPair(TJSONPair.Create('pc_seq', Global.SaleModule.CardDiscountGetCode));
          //ItemObject.AddPair(TJSONPair.Create('pc_div', IfThen(ACard.CardDiscount = 0, '', 'P')));
          If (ACard.CardDiscount = 0) then
            ItemObject.AddPair(TJSONPair.Create('pc_div', ''))
          else
            ItemObject.AddPair(TJSONPair.Create('pc_div', 'P'));
          ItemObject.AddPair(TJSONPair.Create('apply_dc_amt', IntToStr(Trunc(ACard.CardDiscount))));
          CardDiscountAmt := CardDiscountAmt + Trunc(ACard.CardDiscount);
        end
        else
        begin
          APayco := TPayPayco(Global.SaleModule.PayList[0]);
          ItemObject.AddPair(TJSONPair.Create('pay_method', 'PAYCOCARD'));
          ItemObject.AddPair(TJSONPair.Create('credit_card_no', APayco.RecvInfo.RevCardNo));
          ItemObject.AddPair(TJSONPair.Create('inst_mon', APayco.RecvInfo.HalbuMonth));
          ItemObject.AddPair(TJSONPair.Create('approve_no', APayco.RecvInfo.AgreeNo));
          ItemObject.AddPair(TJSONPair.Create('org_approval_no', ''));
          ItemObject.AddPair(TJSONPair.Create('trade_no', APayco.RecvInfo.TradeNo));
          ItemObject.AddPair(TJSONPair.Create('trade_date', Copy(APayco.RecvInfo.TransDateTime, 1, 8)));
          ItemObject.AddPair(TJSONPair.Create('issuer_cd', APayco.RecvInfo.ApprovalCompanyCode));
          ItemObject.AddPair(TJSONPair.Create('issuer_nm',APayco.RecvInfo.ApprovalCompanyName));
          ItemObject.AddPair(TJSONPair.Create('buyer_div', ''));
          ItemObject.AddPair(TJSONPair.Create('buyer_cd', '99999'{APayco.RecvInfo.BuyTypeName}));
          ItemObject.AddPair(TJSONPair.Create('buyer_nm', APayco.RecvInfo.BuyCompanyName));
          ItemObject.AddPair(TJSONPair.Create('pc_seq', ''));
          ItemObject.AddPair(TJSONPair.Create('pc_div', ''));
          ItemObject.AddPair(TJSONPair.Create('apply_dc_amt', '0'));
        end;
        PayMentList.Add(ItemObject);
      end;

      // 웰빙클럽 추가
      MainJson.AddPair(TJSONPair.Create('alliance_code', Global.SaleModule.allianceCode));
      MainJson.AddPair(TJSONPair.Create('alliance_member_no', Global.SaleModule.allianceNumber));
      if Global.SaleModule.allianceCode <> EmptyStr then
        allianceAmt := Trunc(Global.SaleModule.RealAmt);

      // 카드사 즉시 할인으로 해당 위치로 이동
      MainJson.AddPair(TJSONPair.Create('direct_dc_amt', IntToStr(CardDiscountAmt + allianceAmt)));
      MainJson.AddPair(TJSONPair.Create('dc_amt', CurrToStr(Global.SaleModule.DCAmt - Global.SaleModule.XGolfDCAmt - CardDiscountAmt)));

      MainJson.AddPair(TJSONPair.Create('data', DataList));
      for Index := 0 to Global.SaleModule.BuyProductList.Count - 1 do
      begin
        ItemObject := TJSONObject.Create;
        ItemObject.AddPair(TJSONPair.Create('purchase_cd', ''));  // 구매할때는 알수없다.
        ItemObject.AddPair(TJSONPair.Create('product_div', 'S'));  // G:일반, S:타석, L:라커
        ItemObject.AddPair(TJSONPair.Create('product_cd', Global.SaleModule.BuyProductList[Index].Products.Code));
        ItemObject.AddPair(TJSONPair.Create('sale_qty', CurrToStr(Global.SaleModule.BuyProductList[Index].SaleQty)));
        ItemObject.AddPair(TJSONPair.Create('service_yn', 'N'));
        ItemObject.AddPair(TJSONPair.Create('total_amt', TJSONNumber.Create(Trunc(Global.SaleModule.BuyProductList[Index].SalePrice))));

        // 웰빙등 제휴사 할인
        if Global.SaleModule.allianceCode <> EmptyStr then
          ItemObject.AddPair(TJSONPair.Create('sale_amt', TJSONNumber.Create(0) ))
        else
          ItemObject.AddPair(TJSONPair.Create('sale_amt', TJSONNumber.Create(Trunc(Global.SaleModule.BuyProductList[Index].SalePrice - Global.SaleModule.BuyProductList[Index].DcAmt))));

        ItemObject.AddPair(TJSONPair.Create('dc_amt', TJSONNumber.Create(Trunc(Global.SaleModule.BuyProductList[Index].DcAmt))));
        ItemObject.AddPair(TJSONPair.Create('coupon_cd', ''));  // 할인QR을 추가해야한다.
        ItemObject.AddPair(TJSONPair.Create('locker_no', TJSONNumber.Create(0)));
        ItemObject.AddPair(TJSONPair.Create('purchase_month', TJSONNumber.Create(StrToIntDef(FormatDateTime('mm', now), 0))));
        ItemObject.AddPair(TJSONPair.Create('keep_amt', TJSONNumber.Create(0)));
        ItemObject.AddPair(TJSONPair.Create('product_nm', Global.SaleModule.BuyProductList[Index].Products.Name));
        ItemObject.AddPair(TJSONPair.Create('unit_price', IntToStr(Global.SaleModule.BuyProductList[Index].Products.Price)));
        ItemObject.AddPair(TJSONPair.Create('coupon_cnt', IntToStr(Global.SaleModule.BuyProductList[Index].Products.Use_Qty)));

        TeeBoxList := TJSONArray.Create;
        ItemObject.AddPair(TJSONPair.Create('teebox', TeeBoxList));

        if Global.SaleModule.BuyProductList[Index].Products.Product_Div = PRODUCT_TYPE_D then
        begin
          TeeBoxItem := TJSONObject.Create;
          TeeBoxItem.AddPair(TJSONPair.Create('teebox_no', Global.SaleModule.TeeBoxInfo.Tasuk));
          TeeBoxList.Add(TeeBoxItem);
        end;

        //웰빙등 제휴사 할인
        if Global.SaleModule.allianceCode <> EmptyStr then
          ItemObject.AddPair(TJSONPair.Create('direct_dc_amt', IntToStr(Global.SaleModule.BuyProductList[Index].Products.Price) ))
        else
          ItemObject.AddPair(TJSONPair.Create('direct_dc_amt', '0'));

        DataList.Add(ItemObject);
      end;

      ReSaleSave :

      Log.D('Sale Save JsonText Begin', '매출 저장');
      Log.D('Sale Save JsonText Begin', LogReplace(MainJson.ToString));
      WriteLog(False, 'ApiLog', Global.SaleModule.SaleDate, 'SaleSave', LogReplace(MainJson.ToString));
      JsonText := Send_MF_API(mtPost, 'K601_ProductSale', MainJson.ToString);
      WriteLog(False, 'ApiLog', Global.SaleModule.SaleDate, 'SaleSave', LogReplace(JsonText));
      Log.D('Sale Save JsonText End', LogReplace(JsonText));

      if JsonText = EmptyStr then
        Exit;

        //2021-03-22 socket 에러시 1회 재시도 추가
      if JsonText = 'Socket Error' then
      begin
        inc(nSocketError);

        if nSocketError > 1 then
          Exit;

        sleep(50);
        goto ReSaleSave;
      end;

      jReceObj := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;

      if jReceObj.FindValue('resultData') is TJSONNull then
        Exit;

      jReceItemObj := jReceObj.GetValue('resultData') as TJSONObject;

      if '0000' = jReceItemObj.GetValue('result_cd').Value then
      begin
        if Global.SaleModule.BuyProductList.Count = 1 then
        begin
          if not (jReceItemObj.FindValue('result_data') is TJSONNull) then
          begin
            jReceObjArr := jReceItemObj.GetValue('result_data')as TJsonArray;
            jReceArrItemObj := jReceObjArr.Get(0) as TJSONObject;

            ASaleData := Global.SaleModule.BuyProductList[0];
            ASaleData.Products.ProductBuyCode := jReceArrItemObj.GetValue('purchase_cd').Value;
            Global.SaleModule.BuyProductList[0] := ASaleData;
          end;
        end;
        
        Result := True;
      end
      else
      begin
        Global.SBMessage.ShowMessageModalForm(jReceItemObj.GetValue('result_msg').Value);
        Global.SaleModule.SaleUploadFail := True;
      end;
    except
      on E: Exception do
      begin
        //Socket Error # 10060 Connection timed out.

        Global.SaleModule.SaleUploadFail := True;
        WriteLog(True, 'ApiLog', Global.SaleModule.SaleDate, 'SaleSave', E.Message);
        Log.D('Sale Save JsonText Begin', LogReplace(MainJson.ToString));
        Log.E('SaveSaleInfo', JsonText);
        Global.SBMessage.ShowMessageModalForm('업로드에 실패하였습니다.' + #13#10 + '하단의 영수증 지참 후 반드시' + #13#10 + '프론트에 문의하여 주시기 바랍니다.' + #13#10 + '감사합니다.');
      end;
    end;
  finally
    FreeAndNil(MainJson);
  end;
end;

{
function TMFErpApi.SearchCardDiscount(ACardNo, ACardAmt: string; out ACode, AMsg: string): Currency;
var
  MainJson: TJSONObject;
  ItemValue: TJSONValue;
  JsonText, AUrl: string;
begin
  try
    try
      Log.D('SearchCardDiscount CardNo', ACardNo);
      Result := 0;
      ACode := EmptyStr;
      AMsg := EmptyStr;
      MainJson := TJSONObject.Create;

      ACardNo := Copy(ACardNo, 1, 6);

      AUrl := 'K608_PromotionCardBin?store_cd=' + Global.Config.Store.StoreCode +
              '&bin_no=' + ACardNo + '&apply_amt=' + ACardAmt;

      JsonText := Send_MF_API(mtGet, AUrl, EmptyStr);

      if JsonText = EmptyStr then
        Exit;

      Log.D('SearchCardDiscount JsonText', JsonText);

      if (MainJson.ParseJSONValue(JsonText) as TJSONObject).Get('result_cd').JsonValue.Value = '0000' then
      begin
        if MainJson.ParseJSONValue(JsonText).FindValue('result_data') is TJSONNull then
          Exit;

        ItemValue := (MainJson.ParseJSONValue(JsonText) as TJSONObject).Get('result_data').JsonValue;

        if (ItemValue as TJSONObject).Get('kiosk_use_yn').JsonValue.Value = 'Y' then
        begin
          ACode := (ItemValue as TJSONObject).Get('pc_seq').JsonValue.Value;
          Result := StrToIntDef((ItemValue as TJSONObject).Get('dc_amt').JsonValue.Value, 0);
        end;
      end;
    except
      on E: Exception do
      begin
        Log.E('SearchCardDiscount', AUrl);
        Log.E('SearchCardDiscount', E.Message);
      end;
    end;
  finally
    FreeAndNil(MainJson);
  end;
end;
}

{ TSendAPIThread }
{
constructor TSendAPIThread.Create;
begin
  FreeOnTerminate := False;
  inherited Create(True);
end;

destructor TSendAPIThread.Destroy;
begin

  inherited;
end;

procedure TSendAPIThread.Execute;
begin
  inherited;

  while not Terminated do
  begin
    if FormatDateTime('nn', now) = '00' then
    begin
//      Global.Database.SendAdvertisList;
      Log.D('Media Count Send', 'Send');
      Sleep(3540000);
    end;
  end;
end;
}
end.
