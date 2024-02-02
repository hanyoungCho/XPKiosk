unit uELoomApi;

interface

uses
  IdGlobal, FMX.Graphics, IdCoderMIME, InIFiles, IdSSL, IdSSLOpenSSL, Vcl.Dialogs,
  uStruct, System.Variants, System.SysUtils, System.Classes,
  Generics.Collections, Uni, IdHTTP, JSON, EncdDecd, IdURI, uConsts;

// ERoomURL=https://api.eloomgolf.com/kiosk/

type
  TELoomApi = class
  private
    FAuthorization: AnsiString;
    FUTF8Str: UTF8String;

    function Send_API(MethodType: TMethodType; AUrl, AJsonText: string; NotSaveLog: Boolean = False): AnsiString;
    function Send_API_Encoding_Get(MethodType: TMethodType; AUrl, AJsonText: string; NotSaveLog: Boolean = False): AnsiString;

    function GetVersion(AUrl: string): string;
  public
    sslIOHandler: TIdSSLIOHandlerSocketOpenSSL;
    constructor Create;
    destructor Destroy; override;

    // 회원 관련 정보
    function GetAllMmeberInfoVersion: string;
    function GetAllMemberInfo: TList<TMemberInfo>;
    function GetMemberProductList(ACardNo, ACode: string; var AMsg: string): TList<TProductInfo>;
    function SetMemberFinger(var ACode, AMsg: string): Boolean;
    function GetQrcodeAuth(AQRcode: String; var ACode, AMsg: string): TMemberInfo;

    // 타석 마스터 정보를 읽어 온다.
    function GetTeeBoxMaster: TList<TTeeBoxInfo>;

    // 환경설정
    function GetConfig: Boolean;

    // 가맹점 정보 조회
    function GetStoreInfo: Boolean;

    // 광고 목록 조회
    function GetAdvertisVersion: string;
    procedure SearchAdvertisList;

    property Authorization: AnsiString read FAuthorization write FAuthorization;
    property UTF8Str: UTF8String read FUTF8Str write FUTF8Str;
  end;

implementation

uses
  uGlobal, uSaleModule, fx.Logging, uFunction, uCommon;

{ TASPDatabase }

constructor TELoomApi.Create;
begin
  sslIOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  sslIOHandler.SSLOptions.Method := sslvSSLv23;
  sslIOHandler.SSLOptions.Mode := sslmClient;
end;

destructor TELoomApi.Destroy;
begin
  sslIOHandler.Free;
  inherited;
end;

function TELoomApi.GetAllMmeberInfoVersion: string;
begin
  Result := GetVersion('K213_MemberVersion?store_cd=' + Global.Config.Store.StoreCode);
  if Result = EmptyStr then
    Result := Global.Config.Version.MemberVersion;
end;

function TELoomApi.GetAllMemberInfo: TList<TMemberInfo>;
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

    //Log.D('회원정보', JsonText);
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

function TELoomApi.GetConfig: Boolean;
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

    JsonText := Send_API(mtGet, 'K202_Configlist?store_cd=' + Store_CD + '&client_id=' + AClient_ID, EmptyStr);

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

function TELoomApi.GetMemberProductList(ACardNo, ACode: string; var AMsg: string): TList<TProductInfo>;
var
  Index, Loop, Cnt, ProductUseCnt: Integer;
  MainJson, jObj: TJSONObject;
  jObjArr: TJsonArray;
  JsonText, NowDay, NowTime: string;
  AProduct: TProductInfo;
  AProductList: TList<TProductInfo>;
  sApi: String;
begin
  try
    Result := TList<TProductInfo>.Create;
    AProductList := TList<TProductInfo>.Create;

    NowDay := EmptyStr;
    NowTime := EmptyStr;

    sApi := 'K306_GetMemberTeeBoxProduct?member_no=' + ACardNo + '&store_cd=' + Global.Config.Store.StoreCode;
    JsonText := Send_API(mtGet, sApi, EmptyStr);

    if JsonText = EmptyStr then
      Exit;

    Log.D('GetMemberProductList JsonText', LogReplace(JsonText));

    MainJson := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;
    AMsg := MainJson.GetValue('result_msg').Value;

    Global.SaleModule.FProfileImg := MainJson.GetValue('profile_img').Value;
    Global.SaleModule.FNoticeMsg := MainJson.GetValue('notice_msg').Value;

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
        //AProduct.ProductBuyCode := jObj.GetValue('purchase_cd').Value;
        AProduct.Product_Div := jObj.GetValue('product_div').Value; //1:타석상품, 2:레슨상품, 3:라커상품
        AProduct.Start_Time := StringReplace(jObj.GetValue('day_start_time').Value, ':', '', [rfReplaceAll]); //이용 시작시간
        AProduct.End_Time := StringReplace(jObj.GetValue('day_end_time').Value, ':', '', [rfReplaceAll]); //이용 종료시간
        AProduct.One_Use_Time := jObj.GetValue('one_use_time').Value;
        AProduct.StartDate := jObj.GetValue('start_day').Value; //이용 시작일
        AProduct.EndDate := jObj.GetValue('end_day').Value; //이용 종료일
        AProduct.Use_Qty := StrToIntDef(jObj.GetValue('coupon_cnt').Value, 0);

        if AProduct.Product_Div = PRODUCT_TYPE_C then
          AProduct.Use := (jObj.GetValue('today_yn').Value = 'Y') and (AProduct.Use_Qty <> 0)
        else
          AProduct.Use := (jObj.GetValue('today_yn').Value = 'Y');

        AProduct.Expire_Day := jObj.GetValue('expire_day').Value;

        NowDay := FormatDateTime('yyyymmdd', now);
        NowTime := FormatDateTime('hhnn', now);

        if AProduct.Use then
          AProduct.Use := (NowDay >= AProduct.StartDate) and (NowDay <= AProduct.EndDate);

        if AProduct.Use then
        begin
          if AProduct.Start_Time > AProduct.End_Time then
            AProduct.Use := (NowTime >= AProduct.Start_Time) or (NowTime <= AProduct.End_Time)
          else
            AProduct.Use := (NowTime >= AProduct.Start_Time) and (NowTime <= AProduct.End_Time);
        end;

        if AProduct.Use then
        begin
          AProductList.Add(AProduct);
        end;
      end;

      if AProductList.Count <> 0 then
      begin

        for Index := 0 to AProductList.Count - 1 do
        begin
          //2021-12-30 레슨상품도 보여지도록
          //if AProductList[Index].Product_Div = '1' then // 1:타석상품
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

function TELoomApi.GetStoreInfo: Boolean;
var
  Index, nCnt: Integer;
  MainJson, jObj, jObjSub: TJSONObject;
  JsonText: string;
  sApi: string;
begin

  try
    Result := False;

    sApi := 'K203_StoreInfo?store_cd=' + Global.Config.Store.StoreCode + '&search_date=' + FormatDateTime('YYYYMMDDHHNNSS', Now);
    JsonText := Send_API(mtGet, sApi, EmptyStr, True);

    if JsonText = EmptyStr then
      Exit;

    MainJson := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;

    if '0000' = MainJson.GetValue('result_cd').Value then
    begin
      jObj := MainJson.GetValue('result_data') as TJSONObject;

      Global.Config.Store.StoreName := jObj.GetValue('store_nm').Value;
      Global.Config.Store.StoreStartTime := jObj.GetValue('start_time').Value;
      Global.Config.Store.StoreEndTime := jObj.GetValue('end_time').Value;
      //SetServerLocalTime(jObj.GetValue('server_time').Value);

      if Global.Config.Store.StoreStartTime = 'null' then
        Global.Config.Store.StoreStartTime := '06:00';
      if Global.Config.Store.StoreEndTime = 'null' then
        Global.Config.Store.StoreEndTime := '23:00';
    end;

    Result := True;
    Global.Config.SaveLocalConfig;
  finally
    FreeAndNil(MainJson);
    //FreeAndNil(JsonValue);
  end;
end;

function TELoomApi.GetTeeBoxMaster: TList<TTeeBoxInfo>;
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

        ATeeBoxInfo.FloorCd := StrToIntDef(jObj.GetValue('floor_cd').Value, 0);
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

function TELoomApi.GetQrcodeAuth(AQRcode: String; var ACode, AMsg: string): TMemberInfo;
var
  MainJson: TJSONObject;
  JsonText: string;
  sApi: string;
begin

  try

    sApi := 'K307_QrcodeAuth?store_cd=' + Global.Config.Store.StoreCode + '&auth_type=QRCODE&auth_data=' + AQRcode;
    //JsonText := Send_API(mtGet, sApi, EmptyStr, True);
    JsonText := Send_API_Encoding_Get(mtGet, sApi, EmptyStr, True);

    if JsonText = EmptyStr then
      Exit;

    MainJson := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;
    ACode := MainJson.GetValue('result_cd').Value;
    AMsg := MainJson.GetValue('result_msg').Value;

    if '0000' = ACode then
    begin
      Result.Code := MainJson.GetValue('member_no').Value;
      Result.Name := MainJson.GetValue('member_name').Value;
    end
    else
    begin
      Result.Code := EmptyStr;
      Result.Name := EmptyStr;
    end;

  finally
    FreeAndNil(MainJson);
  end;
end;

function TELoomApi.SetMemberFinger(var ACode, AMsg: string): Boolean;
var
  MainJson, jObj: TJSONObject;
  JsonText: string;
begin

  try
    Result := False;

    jObj := TJSONObject.Create;
    jObj.AddPair(TJSONPair.Create('store_cd', Global.Config.Store.StoreCode ));
    jObj.AddPair(TJSONPair.Create('member_no', Global.SaleModule.FCheckMemberCode ) );
    jObj.AddPair(TJSONPair.Create('auth_no', Global.SaleModule.FCheckAuthCode ) );
    jObj.AddPair(TJSONPair.Create('fp_data1', Global.SaleModule.FingerStr ) );
    jObj.AddPair(TJSONPair.Create('fp_data2', EmptyStr ) );
    jObj.AddPair(TJSONPair.Create('fp_data3', EmptyStr ) );

    Log.D('SetMemberFinger JsonText', Global.Config.Store.StoreCode + ' / ' + Global.SaleModule.FCheckMemberCode);
    JsonText := Send_API(mtpost, 'K308_RegistFingerprint', jObj.ToString);

    if JsonText = EmptyStr then
      Exit;

    Log.D('K308_RegistFingerprint JsonText', LogReplace(JsonText));

    MainJson := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;
    ACode := MainJson.GetValue('result_cd').Value;
    AMsg := MainJson.GetValue('result_msg').Value;

    if ACode <> '0000' then
      Exit;

    Result := True;

  finally
    FreeAndNil(MainJson);;
    FreeAndNil(jObj);
  end;

end;

function TELoomApi.GetAdvertisVersion: string;
begin
  Result := GetVersion('K233_AdvertiseVersion?store_cd=' + Global.Config.Store.StoreCode);
  if Result = EmptyStr then
    Result := Global.Config.Version.AdvertisVersion;
end;

procedure TELoomApi.SearchAdvertisList;
var
  MainJson, jObj: TJSONObject;
  jObjArr: TJsonArray;

  AUrl, FileExtract: string;

  JsonText: AnsiString;
  Loop, nCnt: Integer;
  AAdvertise: TAdvertisement;
  AIndy: TIdHTTP;
  mStream: TMemoryStream;

  WeekUse: Integer;
  ListUp, ListDown: TList<TAdvertisement>;

  AAdvertisement: TAdvertisement;
  sslIOHandler : TIdSSLIOHandlerSocketOpenSSL;

  function ClearListAdvertisList(AType: Integer): Boolean;
  var
    Index: Integer;
  begin
    try
      Result := False;
      if AType = 0 then
      begin
        for Index := ListUp.Count -1 downto 0 do
          ListUp.Delete(Index);

        for Index := ListDown.Count -1 downto 0 do
          ListDown.Delete(Index);
      end
      else
      begin
         for Index := Global.SaleModule.AdvertisementListUp.Count -1 downto 0 do
         begin
           Global.SaleModule.AdvertisementListUp.Delete(Index);
         end;

        for Index := Global.SaleModule.AdvertisementListDown.Count -1 downto 0 do
        begin
          AAdvertise := Global.SaleModule.AdvertisementListDown[Index];
          AAdvertise.Image.Free;

          Global.SaleModule.AdvertisementListDown.Delete(Index);
        end;

        for Index := 0 to ListUp.Count - 1 do
        begin
          Global.SaleModule.AdvertisementListUp.Add(ListUp[Index]);
        end;

        for Index := 0 to ListDown.Count - 1 do
        begin
          Global.SaleModule.AdvertisementListDown.Add(ListDown[Index]);
        end;

      end;

      Result := True;
    finally
    end;

  end;

begin

  try
    try

      ListUp := TList<TAdvertisement>.Create;
      ListDown := TList<TAdvertisement>.Create;

      AUrl := '?store_cd=' + Global.Config.Store.StoreCode;

      JsonText := Send_API(mtGet, 'K231_AdvertiseList' + AUrl, EmptyStr);
      //Log.D('K231_AdvertiseList', JsonText);

      MainJson := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;

      if MainJson.GetValue('result_cd').Value = '0000' then
      begin
        if not (MainJson.FindValue('list') is TJSONNull) then
        begin
          jObjArr := MainJson.GetValue('list') as TJsonArray;
          nCnt := jObjArr.Size;

          for Loop := 0 to nCnt - 1 do
          begin
            jObj := jObjArr.Get(Loop) as TJSONObject;

            if jObj.GetValue('del_yn').Value = 'Y' then
              Continue;

            AIndy := TIdHTTP.Create(nil);
            AIndy.IOHandler := sslIOHandler;
            mStream := TMemoryStream.Create;

            AAdvertise.Seq := StrToIntDef(jObj.GetValue('ad_seq').Value, 0);
            AAdvertise.FileUrl := jObj.GetValue('file_url').Value;
            AAdvertise.Position := jObj.GetValue('position_div').Value;
            AAdvertise.StartDate := jObj.GetValue('open_start_day').Value;
            AAdvertise.EndDate := jObj.GetValue('open_end_day').Value;
            AAdvertise.Show_Week := jObj.GetValue('open_week_div').Value;
            AAdvertise.Show_Start_Time := jObj.GetValue('open_start_time').Value;
            AAdvertise.Show_End_Time := jObj.GetValue('open_end_time').Value;
            //AAdvertise.Show_Interval := jObj.GetValue('open_second').Value;
            AAdvertise.Show_YN := jObj.GetValue('open_yn').Value = 'Y';

            WeekUse := DayOfWeek(Now);

            if WeekUse = 1 then
              WeekUse := 7
            else
              WeekUse := WeekUse - 1;

            //if (AAdvertise.StartDate <= FormatDateTime('yyyymmdd', now)) and (FormatDateTime('yyyymmdd', now) <= AAdvertise.EndDate) then
            if (AAdvertise.StartDate <= FormatDateTime('yyyymmdd', now)) then
            begin
              if AAdvertise.Show_YN and (Copy(AAdvertise.Show_Week, WeekUse, 1) = '1') then
              begin
                FileExtract := ExtractFileExt(AAdvertise.FileUrl);
                //FileName := StringReplace(AAdvertise.FileUrl, Global.Config.Partners.FileUrl, '', [rfReplaceAll]);

                AIndy.Get(AAdvertise.FileUrl, mStream);

                if (FileExtract = '.avi') or (FileExtract = '.mp4') then
                  AAdvertise.FilePath := ExtractFilePath(ParamStr(0)) + '\Intro\Media\' + jObj.GetValue('upload_nm').Value
                else
                  AAdvertise.FilePath := ExtractFilePath(ParamStr(0)) + '\Intro\' + jObj.GetValue('upload_nm').Value;

                if (Global.SaleModule.AdvertisementListDown.Count = 0) and (Global.SaleModule.AdvertisementListUp.Count = 0) then
                begin
                  DeleteFile(AAdvertise.FilePath); //????
                end;

                if not FileExists(AAdvertise.FilePath) then
                  mStream.SaveToFile(AAdvertise.FilePath);

                if AAdvertise.Position = 'D' then //하단
                begin
                  AAdvertise.Image := TBitmap.CreateFromFile(AAdvertise.FilePath);
                  ListDown.Add(AAdvertise);
                end
                else if AAdvertise.Position = 'U' then //상단
                begin
                  AAdvertise.Image := TBitmap.CreateFromFile(AAdvertise.FilePath);
                  ListUp.Add(AAdvertise);
                end;
              end;

            end;

            AIndy.Free;
            mStream.Free;

          end;

        end;

      end;

      ClearListAdvertisList(1);

    except
      on E: Exception do
      begin
        Log.E('SearchAdvertisList', E.Message);
      end;
    end;

  finally
    ClearListAdvertisList(0);

    FreeAndNil(ListUp);
    FreeAndNil(ListDown);

    FreeAndNil(MainJson);
    //FreeAndNil(JsonValue);
  end;
end;

function TELoomApi.Send_API(MethodType: TMethodType; AUrl, AJsonText: string; NotSaveLog: Boolean): AnsiString;
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

      if Global.Config.Store.StoreCode = 'E0001' then //이룸골프 잠실점
        Indy.Request.CustomHeaders.Values['x-api-key'] := '4c4c8gsw0wss44w4kos8gk4wswoo40wko0oogw08'
      else if Global.Config.Store.StoreCode = 'E0008' then //이룸골프 동탄라크몽
        Indy.Request.CustomHeaders.Values['x-api-key'] := 'gwg8o8c48kccsw0w0ksoks0go8gcgogssgo04ccs'
      else if Global.Config.Store.StoreCode = 'E0009' then //강남
        Indy.Request.CustomHeaders.Values['x-api-key'] := 'ok480gwokokgw4co0gcocwgkooswkgg8gwgcwokg'
      else if Global.Config.Store.StoreCode = 'E0011' then //구리갈매센터
        Indy.Request.CustomHeaders.Values['x-api-key'] := 'k0cgkgcsw4848ocscoso4okc0404owog0wo484w8'
      else
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


function TELoomApi.Send_API_Encoding_Get(MethodType: TMethodType; AUrl, AJsonText: string; NotSaveLog: Boolean): AnsiString;
var
  Indy: TIdHTTP;
  RecvData: TStringStream;
  sUrl: AnsiString;
begin

  try
    try
      RecvData := TStringStream.Create;

      if not NotSaveLog then
        Log.D('Send_API_Encoding_Get', 'Begin - ' + AUrl);
      Indy := TIdHTTP.Create(nil);
      Result := EmptyStr;
      //SendData.Clear;
      RecvData.Clear;
      //Indy.Request.CustomHeaders.Clear;
      Indy.IOHandler := sslIOHandler;
      Indy.URL.URI := Global.Config.Partners.ERoomUrl;

      if Global.Config.Store.StoreCode = 'E0001' then //이룸골프 잠실점
        Indy.Request.CustomHeaders.Values['x-api-key'] := '4c4c8gsw0wss44w4kos8gk4wswoo40wko0oogw08'
      else if Global.Config.Store.StoreCode = 'E0008' then //이룸골프 동탄라크몽
        Indy.Request.CustomHeaders.Values['x-api-key'] := 'gwg8o8c48kccsw0w0ksoks0go8gcgogssgo04ccs'
      else if Global.Config.Store.StoreCode = 'E0009' then //강남
        Indy.Request.CustomHeaders.Values['x-api-key'] := 'ok480gwokokgw4co0gcocwgkooswkgg8gwgcwokg'
      else if Global.Config.Store.StoreCode = 'E0011' then //구리갈매센터
        Indy.Request.CustomHeaders.Values['x-api-key'] := 'k0cgkgcsw4848ocscoso4okc0404owog0wo484w8'
      else
        Indy.Request.CustomHeaders.Values['x-api-key'] := 'owgss0w4008wk0cgks8cog00kok0k0kw40sk4kck';

      Indy.Request.ContentType := 'application/json';
      //Indy.Request.Accept := '*/*';
      //SendData := TStringStream.Create(AJsonText, TEncoding.UTF8);

      Indy.ConnectTimeout := 3000;
      Indy.ReadTimeout := 3000;

      sUrl := URLEncode2(Global.Config.Partners.ERoomUrl + AUrl);
      Indy.Get(sUrl, RecvData);

      Result := ByteStringToString(RecvData);
      if not NotSaveLog then
        Log.D('Send_API_Encoding_Get', 'End');
    except
      on E: Exception do
      begin
        Log.E('Send_API_Encoding_Get', AUrl);
        Log.E('Send_API_Encoding_Get', E.Message);
      end;
    end;
  finally
    Indy.Disconnect;
    Indy.Free;
    //SendData.Free;
    RecvData.Free;
  end;
end;

function TELoomApi.GetVersion(AUrl: string): string;
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
