unit uERoomApi;

interface

uses
  IdGlobal, FMX.Graphics, IdCoderMIME, InIFiles, IdSSL, IdSSLOpenSSL, Vcl.Dialogs,
  uStruct, System.Variants, System.SysUtils, System.Classes,
  Generics.Collections, Uni, IdHTTP, JSON, EncdDecd, IdURI, uConsts;

// ERoomURL=https://api.eloomgolf.com/kiosk/

type
  TERoomApi = class
  private
    FAuthorization: AnsiString;
    //FByteStr: RawByteString;
    FUTF8Str: UTF8String;

    function Send_API(MethodType: TMethodType; AUrl, AJsonText: string; NotSaveLog: Boolean = False): AnsiString;

    //타석기AD미사용시 배정예약, AD상관없이 매출저장
    function Send_API_Reservation(MethodType: TMethodType; AUrl, AJsonText: string; NotSaveLog: Boolean = False): AnsiString;

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
    function GetTeeBoxMaster: TList<TTeeBoxInfo>;

    // 환경설정
    function GetConfigNew: Boolean;

    // 가맹점 정보 조회
    function GetStoreInfo: Boolean;

    // 타석 예약 등록
    //function TeeBoxReservation: Boolean;
    function TeeBoxListReservation: Boolean;

    property Authorization: AnsiString read FAuthorization write FAuthorization;
    property UTF8Str: UTF8String read FUTF8Str write FUTF8Str;
  end;

implementation

uses
  uGlobal, uSaleModule, fx.Logging, uFunction, uCommon;

{ TASPDatabase }

constructor TERoomApi.Create;
begin
  sslIOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  sslIOHandler.SSLOptions.Method := sslvSSLv23;
  sslIOHandler.SSLOptions.Mode := sslmClient;
end;

destructor TERoomApi.Destroy;
begin
  sslIOHandler.Free;
  inherited;
end;

function TERoomApi.GetAllMmeberInfoVersion: string;
begin
  Result := GetVersion('K213_MemberVersion?store_cd=' + Global.Config.Store.StoreCode);
  if Result = EmptyStr then
    Result := Global.Config.Version.MemberVersion;
end;

function TERoomApi.GetAllMemberInfo: TList<TMemberInfo>;
var
  Index, Loop, tmp: Integer;
  AMemberInfo: TMemberInfo;
  MainJson, jObj: TJSONObject;
  jObjArr: TJsonArray;
  JsonText, AVersion, SendDatetime: string;
  ABytes: TBytes;
  AFingerStr: AnsiString;

  nCnt: Integer;
begin
  try
    Result := TList<TMemberInfo>.Create;

    SendDatetime := Global.SaleModule.MemberInfoDownLoadDateTime;

    if Global.SaleModule.MemberInfoDownLoadDateTime = EmptyStr then
      Global.SaleModule.MemberInfoDownLoadDateTime := FormatDateTime('yyyymmddhhnnss', now);

    if SendDatetime <> EmptyStr then
      JsonText := Send_API(mtGet, 'K214_MemberlistSimple?search_date=' + SendDatetime + '&store_cd=' + Global.Config.Store.StoreCode, EmptyStr)
    else
      JsonText := Send_API(mtGet, 'K214_MemberlistSimple?store_cd=' + Global.Config.Store.StoreCode, EmptyStr);

    if JsonText = EmptyStr then
      Exit;

//    Log.D('회원정보', JsonText);
    MainJson := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;

    if '0000' = MainJson.GetValue('result_cd').Value then
    begin
      //if JsonValue.FindValue('result_data') is TJSONNull then
      //  Exit;

      jObjArr := MainJson.GetValue('list') as TJsonArray;
      nCnt := jObjArr.Size;

      Log.D('저장할 회원 수', Inttostr(nCnt));
      for Index := 0 to nCnt - 1 do
      begin
        AMemberInfo.FingerStr := EmptyStr;

        jObj := jObjArr.Get(Index) as TJSONObject;
        AMemberInfo.Code := jObj.GetValue('member_no').Value;
        AMemberInfo.Name := jObj.GetValue('member_nm').Value;
        AMemberInfo.Sex := IfThen(StrToIntDef(jObj.GetValue('sex_div').Value, 1) = 1, 'M', 'W');

        try
          AMemberInfo.FingerStr := jObj.GetValue('fingerprint1').Value;
          AMemberInfo.FingerStr_2 := jObj.GetValue('fingerprint2').Value;
        except
          on E: Exception do
          begin
            Log.E('GetAllMemberInfo', E.Message);
            Log.E('GetAllMemberInfo', LogReplace(AMemberInfo.Name));
            Log.E('GetAllMemberInfo', IntToStr(Length(AMemberInfo.FingerStr)));
            Log.E('GetAllMemberInfo', LogReplace(AMemberInfo.FingerStr));
          end;
        end;

        Result.Add(AMemberInfo);
      end;
    end;

  finally
    FreeAndNil(MainJson);

    Log.D('저장된 회원 수', inttostr(Result.Count));
  end;
end;

function TERoomApi.GetConfigNew: Boolean;
var
  MainJson: TJSONObject;
  AClient_ID, Store_CD: AnsiString;
  JsonText: string;

  MI: TMemIniFile;
  SL, IL: TStringList;
  SS: TStringStream;
  I, J: Integer;
begin
  try
    Result := False;

    //chy debug구분용
    Global.sUrl := Global.Config.Partners.ERoomURL;

    AClient_ID := Global.Config.OAuth.DeviceID;
    Store_CD := Global.Config.Store.StoreCode;

    JsonText := Send_API(mtGet, 'K202_ConfiglistNew?store_cd=' + Store_CD + '&client_id=' + AClient_ID, EmptyStr);

    if JsonText = EmptyStr then
      Exit;

    //Log.D('환경설정', JsonText);

    MainJson := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;

    if MainJson.GetValue('result_cd').Value <> '0000' then
      Exit;

    if MainJson.FindValue('settings') is TJSONNull then
      Exit;

    Global.SaleModule.ConfigJsonText := JsonText;

    SS := TStringStream.Create;
    SS.Clear;
    SS.WriteString(MainJson.GetValue('settings').Value);
    MI := TMemIniFile.Create(SS, TEncoding.UTF8);
    SL := TStringList.Create;
    IL := TStringList.Create;

    MI.ReadSections(SL);
    for I := 0 to Pred(SL.Count) do
    begin
      IL.Clear;
      //MI.ReadSectionValues(SL[I], IL);
      MI.ReadSection(SL[I], IL);
      for J := 0 to Pred(IL.Count) do
        Global.Config.SetConfig(SL[I], IL[J], MI.ReadString(SL[I], IL[J], ''));
    end;

    Result := True;

  finally
    FreeAndNil(MainJson);
    FreeAndNil(IL);
    FreeAndNil(SL);
    FreeAndNil(MI);
    SS.Free;
  end;
end;

function TERoomApi.GetMemberProductList(ACardNo, ACode, ADate: string): TList<TProductInfo>;
var
  Index, Loop, Cnt, ProductUseCnt: Integer;
  MainJson, jObj: TJSONObject;
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

//    JsonText := Send_API(mtGet, 'K306_GetMemberTeeBoxProduct?Store_cd=' + Global.Config.Store.StoreCode + '&member_no=' + ACardNo, EmptyStr);
    JsonText := Send_API(mtGet, 'K306_GetMemberTeeBoxProduct?member_no=' + ACardNo +
                                                           '&store_cd=' + Global.Config.Store.StoreCode, EmptyStr);

    if JsonText = EmptyStr then
      Exit;

    Log.D('GetMemberProductList JsonText', LogReplace(JsonText));

    MainJson := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;

    if MainJson.GetValue('result_cd').Value = '0000' then
    begin
      if MainJson.FindValue('result_data') is TJSONNull then
        Exit;

      jObjArr := MainJson.GetValue('result_data') as TJsonArray;
      for Index := 0 to jObjArr.Count - 1 do
      begin
        jObj := jObjArr.Get(Index) as TJSONObject;

        AProduct.Code := jObj.GetValue('product_cd').Value;
        AProduct.Name := jObj.GetValue('product_nm').Value;
        AProduct.ProductBuyCode := jObj.GetValue('purchase_cd').Value;
        AProduct.StartDate := jObj.GetValue('start_day').Value; //이용 시작일
        AProduct.EndDate := jObj.GetValue('end_day').Value; //이용 종료일
        AProduct.Use_Qty := StrToIntDef(jObj.GetValue('coupon_cnt').Value, 0);
        AProduct.Product_Div := jObj.GetValue('product_div').Value;

        AProduct.Start_Time := StringReplace(jObj.GetValue('day_start_time').Value, ':', '', [rfReplaceAll]); //이용 시작시간
        AProduct.End_Time := StringReplace(jObj.GetValue('day_end_time').Value, ':', '', [rfReplaceAll]); //이용 종료시간

        if AProduct.Product_Div = PRODUCT_TYPE_C then
          AProduct.Use := (jObj.GetValue('today_yn').Value = 'Y') and (AProduct.Use_Qty <> 0)
        else
          AProduct.Use := (jObj.GetValue('today_yn').Value = 'Y');

        AProduct.One_Use_Time := jObj.GetValue('one_use_time').Value;

//        AProduct.Use := True; // 2020.02.11

        NowDay := FormatDateTime('yyyymmdd', now);
        // 20200822 기간권, 쿠폰도 타석 시간에 맞춰서 표시
//        NowTime := StringReplace(Global.TeeBox.TeeBoxList[Index].End_Time, ':', '', [rfReplaceAll]);//FormatDateTime('hhnn', now);

        NowTime := FormatDateTime('hhnn', now);

        if AProduct.Use then
          AProduct.Use := (NowDay >= AProduct.StartDate) and (NowDay <= AProduct.EndDate);

        //Log.D('AProduct.Use ', AProduct.Use);

        //2021-06-01 유명 익일영업종료
        if AProduct.Use then
        begin
          if AProduct.Start_Time > AProduct.End_Time then
          begin
            AProduct.Use := (NowTime >= AProduct.Start_Time) or (NowTime <= AProduct.End_Time);
          end
          else
          begin
            AProduct.Use := (NowTime >= AProduct.Start_Time) and (NowTime <= AProduct.End_Time);
          end;
        end;

        //Log.D('AProduct.Use ', AProduct.Use);

        if AProduct.Use then
        begin
          AProductList.Add(AProduct);
          //Log.D('AProduct.Use ', '1');
        end;
      end;

      if AProductList.Count <> 0 then
      begin
        //Log.D('AProduct.Use ', '2');
        for Index := 0 to AProductList.Count - 1 do
        begin
          if AProductList[Index].Product_Div = 'R' then
          begin
            Result.Add(AProductList[Index]);
            //Log.D('AProduct.Use ', '3');
          end;
        end;

        for Index := 0 to AProductList.Count - 1 do
        begin
          if AProductList[Index].Product_Div = 'C' then
          begin
            Result.Add(AProductList[Index]);
            //Log.D('AProduct.Use ', '4');
          end;
        end;
      end;
    end;
  finally
    FreeAndNil(MainJson);;
    FreeAndNil(AProductList);
  end;
end;

function TERoomApi.GetStoreInfo: Boolean;
var
  Index, nCnt: Integer;
  MainJson, jObj, jObjSub: TJSONObject;
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

    JsonText := Send_API(mtGet, 'K203_StoreInfo?store_cd=' + Global.Config.Store.StoreCode, EmptyStr, True);

    if JsonText = EmptyStr then
      Exit;

    MainJson := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;

    if '0000' = MainJson.GetValue('result_cd').Value then
    begin
      //if MainJson.FindValue('result_data') is TJSONNull then
        //Exit;

      jObj := MainJson.GetValue('result_data') as TJSONObject;

      Global.Config.Store.StoreName := jObj.GetValue('store_nm').Value;
      Global.Config.Store.BossName := jObj.GetValue('owner_nm').Value;
      Global.Config.Store.Tel := jObj.GetValue('tel_no').Value;
      Global.Config.Store.Addr := jObj.GetValue('address').Value +
                                    jObj.GetValue('address_desc').Value;
      Global.Config.Store.StoreStartTime := jObj.GetValue('start_time').Value;
      Global.Config.Store.StoreEndTime := jObj.GetValue('end_time').Value;
      Global.Config.Store.StoreCloseStartTime := jObj.GetValue('close_start_date').Value;

      SetServerLocalTime(jObj.GetValue('server_time').Value);

      if Global.Config.Store.StoreCloseStartTime = 'null' then
        Global.Config.Store.StoreCloseStartTime := EmptyStr;

      Global.Config.Store.StoreCloseEndTime := jObj.GetValue('close_end_date').Value;
      if Global.Config.Store.StoreCloseEndTime = 'null' then
        Global.Config.Store.StoreCloseEndTime := EmptyStr;

      Global.Config.Store.ACS := Trim(jObj.GetValue('acs_use_yn').Value) = 'Y';

      jObjArr := jObj.GetValue('agreement_list') as TJsonArray;
      nCnt := jObjArr.size;

      for Index := 0 to nCnt - 1 do
      begin
        jObjSub := jObjArr.Get(Index) as TJSONObject;
        Agreement.OrdrNo := StrToInt(jObjSub.GetValue('order_no').Value);
        Agreement.AgreementDiv := jObjSub.GetValue('agreement_div').Value;
        Agreement.FileUrl := jObjSub.GetValue('agreement_file_url').Value;

        //FileExtract := ExtractFileExt(TAgreement(Global.SaleModule.AgreementList[Loop]).FileUrl);
        FileName := StringReplace(Agreement.FileUrl, Global.Config.Partners.FileUrl, '', [rfReplaceAll]);
        Agreement.FilePath := ExtractFilePath(ParamStr(0)) + 'Image\' + FileName;

        AIndy := TIdHTTP.Create(nil);
        AIndy.IOHandler := sslIOHandler;
        mStream := TMemoryStream.Create;
        //ItemValue := (JsonValue as TJSONArray).Items[Loop];

        FileUrl := Agreement.FileUrl;
        FilePath := Agreement.FilePath;

        AIndy.Get(FileUrl, mStream);

        if not FileExists(FilePath) then
          mStream.SaveToFile(FilePath);

        AIndy.Free;
        mStream.Free;

        if Agreement.AgreementDiv = '01' then //01:서비스 이용약관 동의
          Global.SaleModule.AgreementList1.Add(Agreement);
        if Agreement.AgreementDiv = '02' then //02:개인정보 수집 이용 동의
          Global.SaleModule.AgreementList2.Add(Agreement);
        if Agreement.AgreementDiv = '03' then //03:바이오 정보 수집 이용 제공 동의
          Global.SaleModule.AgreementList3.Add(Agreement);

      end;

    end;

    Result := True;
    Global.Config.SaveLocalConfig;
  finally
    FreeAndNil(MainJson);
    //FreeAndNil(JsonValue);
  end;
end;

function TERoomApi.GetTeeBoxMaster: TList<TTeeBoxInfo>;
var
  Index, nCnt: Integer;
  ATeeBoxInfo: TTeeBoxInfo;
  MainJson, jObj: TJSONObject;
  jObjArr: TJsonArray;
  JsonText, sUrl: string;
begin
  try
    Result := TList<TTeeBoxInfo>.Create;

    sUrl := 'K204_TeeBoxlist?store_cd=' + Global.Config.Store.StoreCode + '&search_date=' + FormatDateTime('YYYYMMDDHHNNSS', Now);
    JsonText := Send_API(mtGet, sUrl, EmptyStr);
    //Log.D('타석 마스터', JsonText);

    if JsonText = EmptyStr then
      Exit;

    MainJson := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;;

    if '0000' = MainJson.GetValue('result_cd').Value then
    begin
      if MainJson.FindValue('list') is TJSONNull then
        Exit;

      jObjArr := MainJson.GetValue('list') as TJsonArray;
      nCnt := jObjArr.size;

      for Index := 0 to nCnt - 1 do
      begin
        jObj := jObjArr.Get(Index) as TJSONObject;

        ATeeBoxInfo.High := StrToIntDef(jObj.GetValue('floor_cd').Value, 0);
        ATeeBoxInfo.FloorNm := jObj.GetValue('floor_nm').Value;
        ATeeBoxInfo.TasukNo := StrToIntDef(jObj.GetValue('teebox_no').Value, 0);
        ATeeBoxInfo.Name := jObj.GetValue('teebox_nm').Value;

        //ATeeBoxInfo.ZoneLeft := jObj.GetValue('zone_left').Value;
        ATeeBoxInfo.ZoneCode := jObj.GetValue('zone_div').Value;

        ATeeBoxInfo.Use := jObj.GetValue('use_yn').Value = 'Y';
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

function TERoomApi.TeeBoxListReservation: Boolean;
label ReReserve;
var
  Index, Cnt: Integer;
  MainJson, ItemJson: TJSONObject;
  JsonList: TJSONArray;
  JsonValue, JsonListValue: TJSONValue;
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
      MainJson := TJSONObject.Create;      ItemJson := TJSONObject.Create;
      JsonList := TJSONArray.Create;

      MainJson.AddPair(TJSONPair.Create('data', JsonList));
      MainJson.AddPair(TJSONPair.Create('member_no', Global.SaleModule.Member.Code));
      MainJson.AddPair(TJSONPair.Create('store_cd', Global.Config.Store.StoreCode));
      MainJson.AddPair(TJSONPair.Create('user_id', Global.Config.Store.UserID));
      MainJson.AddPair(TJSONPair.Create('reserve_root_div', 'K'));
      // 2020.05.11
      MainJson.AddPair(TJSONPair.Create('receipt_no', Global.SaleModule.RcpAspNo));
      // 2020.08.19
      MainJson.AddPair(TJSONPair.Create('affiliate_cd', Global.SaleModule.allianceCode));
      //ItemJson := TJSONObject.Create;
      ItemJson.AddPair(TJSONPair.Create('assign_balls', '9999'));

      //매장종료시간초과시 배정시간 변경
      if Global.SaleModule.FStoreCloseOver = True then
        ItemJson.AddPair(TJSONPair.Create('assign_min', Global.SaleModule.FStoreCloseOverMin))
      else
        ItemJson.AddPair(TJSONPair.Create('assign_min', Global.SaleModule.SelectProduct.One_Use_Time));
//      ItemJson.AddPair(TJSONPair.Create('prepare_min', Global.Config.PrePare_Min));

      ItemJson.AddPair(TJSONPair.Create('prepare_min', IfThen(StrToIntDef(Global.Config.PrePare_Min, 5) <> Global.SaleModule.PrepareMin,
                                                                IntToStr(Global.SaleModule.PrepareMin), Global.Config.PrePare_Min)));
      ItemJson.AddPair(TJSONPair.Create('product_cd', Global.SaleModule.SelectProduct.Code));
      ItemJson.AddPair(TJSONPair.Create('purchase_cd', Global.SaleModule.SelectProduct.ProductBuyCode));
      ItemJson.AddPair(TJSONPair.Create('teebox_no', IntToStr(Global.SaleModule.TeeBoxInfo.TasukNo)));

      if Global.Config.AD.USE then
      begin
        ItemJson.AddPair(TJSONPair.Create('product_nm', Global.SaleModule.SelectProduct.Name));
        ItemJson.AddPair(TJSONPair.Create('reserve_div', Global.SaleModule.SelectProduct.Product_Div));
      end;

      JsonList.Add(ItemJson);

      if Global.Config.AD.USE then
      begin
        MainJson.AddPair(TJSONPair.Create('api', 'K408_TeeBoxReserve2'));
        MainJson.AddPair(TJSONPair.Create('member_nm', Global.SaleModule.Member.Name));

        ReReserve :

        Log.D('Local TeeBoxReservation2', LogReplace(MainJson.ToString));
        WriteLog(False, 'ApiLog', Global.SaleModule.SaleDate, 'Local TeeBoxReservation2', LogReplace(MainJson.ToString));
        JsonText := Global.LocalApi.TeeBoxListReservation(MainJson.ToString);
        WriteLog(False, 'ApiLog', Global.SaleModule.SaleDate, 'Local TeeBoxReservation2', LogReplace(JsonText));
        Log.D('Local TeeBoxReservation2', LogReplace(JsonText));
      end
      else
      begin
        Log.D('TeeBoxReservation2', LogReplace(MainJson.ToString));
        WriteLog(False, 'ApiLog', Global.SaleModule.SaleDate, 'TeeBoxReservation2', LogReplace(MainJson.ToString));
        JsonText := Send_API_Reservation(mtPost, 'K408_TeeBoxReserve2', MainJson.ToString);
        WriteLog(False, 'ApiLog', Global.SaleModule.SaleDate, 'TeeBoxReservation2', LogReplace(JsonText));
        Log.D('TeeBoxReservation2', LogReplace(JsonText));
      end;

      if JsonText <> EmptyStr then
      begin
        JsonValue := MainJson.ParseJSONValue(JsonText);

        if (JsonValue as TJSONObject).Get('result_cd').JsonValue.Value = '0000' then
        begin
          Result := True;
//          if not (JsonValue.FindValue('result_data') is TJSONNull) then
          if not (JsonValue.FindValue(Ifthen(Global.Config.AD.USE, 'data', 'result_data')) is TJSONNull) then
          begin
            AProductInfo := Global.SaleModule.SelectProduct;
            JsonValue := (JsonValue as TJSONObject).Get(VarToStr(Ifthen(Global.Config.AD.USE, 'data', 'result_data'))).JsonValue;

            if not Global.Config.AD.USE then
              JsonValue := (JsonValue as TJSONObject).Get('data').JsonValue;

            JsonValue := (JsonValue as TJSONArray).Items[0];

            if not Global.Config.AD.USE then
            begin
              AProductInfo.Reserve_Time := (JsonValue as TJSONObject).Get('start_time').JsonValue.Value;
              AProductInfo.Start_Time :=
                Copy(StringReplace((JsonValue as TJSONObject).Get('start_time').JsonValue.Value, '-', '', [rfReplaceAll]), 10, 5);
              AProductInfo.One_Use_Time := (JsonValue as TJSONObject).Get('assign_time').JsonValue.Value;
            end
            else
            begin
              AProductInfo.Reserve_Time := (JsonValue as TJSONObject).Get('start_datetime').JsonValue.Value;
              AProductInfo.Start_Time :=
                Copy(StringReplace((JsonValue as TJSONObject).Get('start_datetime').JsonValue.Value, '-', '', [rfReplaceAll]), 10, 5);
              AProductInfo.One_Use_Time := (JsonValue as TJSONObject).Get('remain_min').JsonValue.Value;
            end;

            AProductInfo.Use_Qty := StrToIntDef((JsonValue as TJSONObject).Get('coupon_cnt').JsonValue.Value, 0);

            AProductInfo.Reserve_No := (JsonValue as TJSONObject).Get('reserve_no').JsonValue.Value;
            AProductInfo.Reserve_List := EmptyStr;

            if not (JsonValue.FindValue(Ifthen(Global.Config.AD.USE, 'coupon', 'data')) is TJSONNull) then
            begin
              Cnt := 0;
              if not Global.Config.AD.USE then
                JsonListValue := (JsonValue as TJSONObject).Get('data').JsonValue
              else
                JsonListValue := (JsonValue as TJSONObject).Get('coupon').JsonValue;

              for Index := 0 to (JsonListValue as TJSONArray).Count - 1 do
              begin
                if Cnt <> 0 then
                  AProductInfo.Reserve_List := AProductInfo.Reserve_List + ' ';

                ADate := ((JsonListValue as TJSONArray).Items[Index] as TJSONObject).Get('start_datetime').JsonValue.Value;

                if ADate = EmptyStr then
                  Continue;

                ADate := StringReplace(ADate, ' ', '', [rfReplaceAll]);
                ADate := StringReplace(ADate, '-', '', [rfReplaceAll]);
                ADate := StringReplace(ADate, ':', '', [rfReplaceAll]);
                ADate := FormatDateTime('mm.dd', DateStrToDateTime(ADate));

                AProductInfo.Reserve_List := AProductInfo.Reserve_List + ADate;
                Inc(Cnt);
              end;
              AProductInfo.Reserve_List := StringReplace(AProductInfo.Reserve_List, '-', '', [rfReplaceAll]);
              AProductInfo.Reserve_List := StringReplace(AProductInfo.Reserve_List, FormatDateTime('yyyy', now), '', [rfReplaceAll]);
            end;

            Result := True;
          end;
          Global.SaleModule.SelectProduct := AProductInfo;
        end        else        begin          if ((JsonValue as TJSONObject).Get('result_cd').JsonValue.Value = '0002') and Global.Config.AD.USE then          begin            goto ReReserve;
          end          else            Global.SBMessage.ShowMessageModalForm((JsonValue as TJSONObject).Get('result_msg').JsonValue.Value);        end;      end      else        Global.SBMessage.ShowMessageModalForm(MSG_TEEBOX_RESERVATION_AD_FAIL);    except
      on E: Exception do
      begin
        WriteLog(True, 'ApiLog', Global.SaleModule.SaleDate, 'TeeBoxReservation2', LogReplace(JsonText));
        Log.E('TeeBoxReservation', E.Message);
      end;
    end;  finally
    FreeAndNil(MainJson);
  end;
end;

function TERoomApi.Send_API(MethodType: TMethodType; AUrl, AJsonText: string; NotSaveLog: Boolean): AnsiString;
var
  Indy: TIdHTTP;
  SendData, RecvData: TStringStream;
begin
  try
    try
      SendData := TStringStream.Create;
      RecvData := TStringStream.Create;

      if not NotSaveLog then
        Log.D('Send_API', 'Begin - ' + AUrl);
      Indy := TIdHTTP.Create(nil);
      Result := EmptyStr;
      SendData.Clear;
      RecvData.Clear;
      //Indy.Request.CustomHeaders.Clear;
      Indy.IOHandler := sslIOHandler;
      Indy.URL.URI := Global.Config.Partners.ERoomUrl;
      Indy.Request.CustomHeaders.Values['x-api-key'] := 'owgss0w4008wk0cgks8cog00kok0k0kw40sk4kck';

      Indy.Request.ContentType := 'application/json';
      //Indy.Request.Accept := '*/*';
      SendData := TStringStream.Create(AJsonText, TEncoding.UTF8);

      Indy.ConnectTimeout := 3000;
      Indy.ReadTimeout := 3000;

      if MethodType = mtGet then
        Indy.Get(Global.Config.Partners.ERoomUrl + AUrl, RecvData)
      else if MethodType = mtPost then
      begin
        Indy.Post(Global.Config.Partners.ERoomUrl + AUrl, SendData, RecvData);
      end
      else if MethodType = mtDelete then
        Indy.Delete(Global.Config.Partners.ERoomUrl + AUrl, RecvData);

      Result := ByteStringToString(RecvData);
      if not NotSaveLog then
        Log.D('Send_API', 'End');
    except
      on E: Exception do
      begin
        Log.E('Send_API', AUrl);
        Log.E('Send_API', E.Message);
      end;
    end;
  finally
    Indy.Disconnect;
    Indy.Free;
    SendData.Free;
    RecvData.Free;
  end;
end;

function TERoomApi.Send_API_Reservation(MethodType: TMethodType; AUrl, AJsonText: string; NotSaveLog: Boolean): AnsiString;
var
  AIndy: TIdHTTP;
  SendData: TStringStream;
  RecvData: TStringStream;
begin
  AIndy := TIdHTTP.Create(nil);
  SendData := TStringStream.Create;
  RecvData := TStringStream.Create;
  try
    try
      if not NotSaveLog then
        Log.D('Send_API_Reservation', 'Begin - ' + AUrl);
      Result := EmptyStr;
      SendData.Clear;
      RecvData.Clear;
      AIndy.Request.CustomHeaders.Clear;
      AIndy.IOHandler := sslIOHandler;
      AIndy.URL.URI := Global.Config.Partners.URL;
      AIndy.Request.CustomHeaders.Values['Authorization'] := 'Bearer ' + Global.Config.OAuth.Token;

      if AJsonText <> EmptyStr then
      begin
        AIndy.Request.ContentType := 'application/json';
        AIndy.Request.Accept := '*/*';
        SendData := TStringStream.Create(AJsonText, TEncoding.UTF8);
      end
      else
        AIndy.Request.ContentType := 'application/x-www-form-urlencoded';

      AIndy.ConnectTimeout := 3000;
      AIndy.ReadTimeout := 3000;

      if MethodType = mtGet then
        AIndy.Get(Global.Config.Partners.URL + AUrl, RecvData)
      else if MethodType = mtPost then
      begin
        AIndy.Post(Global.Config.Partners.URL + AUrl, SendData, RecvData);
      end
      else if MethodType = mtDelete then
        AIndy.Delete(Global.Config.Partners.URL + AUrl, RecvData);

      Result := ByteStringToString(RecvData);
      if not NotSaveLog then
        Log.D('Send_API_Reservation', 'End');
    except
      on E: Exception do
      begin
        //if StrPos(PChar(e.Message), PChar('Socket Error')) <> nil then
          Result := 'Socket Error';

        Log.E('Send_API_Reservation', AUrl);
        Log.E('Send_API_Reservation', E.Message);
      end;
    end;
  finally
    AIndy.Disconnect;
    AIndy.Free;
    SendData.Free;
    RecvData.Free;
  end;
end;

function TERoomApi.GetVersion(AUrl: string): string;
var
  MainJson: TJSONObject;
  JsonText: string;
begin

  try
    try
      Result := EmptyStr;

      JsonText := Send_API(mtGet, AUrl, EmptyStr);

      if JsonText = EmptyStr then
        Exit;

      MainJson := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;

      if MainJson.GetValue('result_cd').Value = '0000' then
      begin
        Result := MainJson.GetValue('version_no').Value;
      end;

    except
      on E: Exception do
      begin
        Log.E('GetVersion', AUrl);
        Log.E('GetVersion', E.Message);
      end;
    end;

  finally
    FreeAndNilJSONObject(MainJson);
  end;

end;

end.
