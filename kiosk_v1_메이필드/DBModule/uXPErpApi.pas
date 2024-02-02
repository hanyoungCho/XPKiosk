unit uXPErpApi;

interface

uses
  IdGlobal, FMX.Graphics, IdCoderMIME, InIFiles, IdSSL, IdSSLOpenSSL,
  uStruct, System.Variants, System.SysUtils, System.Classes,
  Generics.Collections, Uni, IdHTTP, JSON, EncdDecd, IdURI, uConsts;

type
  {
  TSendErpAPIThread = class(TThread)
  private
  protected
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;
  end;
  }

  TXPErpApi = class
  private
    FAuthorization: AnsiString;
    FUTF8Str: UTF8String;

    function Send_API(MethodType: TMethodType; AUrl, AJsonText: string; NotSaveLog: Boolean = False): AnsiString;
    function Send_API_Reservation(MethodType: TMethodType; AUrl, AJsonText: string; NotSaveLog: Boolean = False): AnsiString;
    function GetVersion(AUrl: string): string;
  public
    sslIOHandler: TIdSSLIOHandlerSocketOpenSSL;
    constructor Create;
    destructor Destroy; override;

    // OAuth 인증
    function OAuth_Certification: Boolean;

    // 가맹점 정보 조회
    function GetStoreInfo: Boolean;

    // 프로모션 확인
    //function SearchPromotion(ACoupon: string): Boolean;
    //function CouponError(ACode: string): string;

    // 광고 목록 조회
    function GetAdvertisVersion: string;
    procedure SearchAdvertisList;
    function SendAdvertisCnt(ASeq: string): Boolean;
    function SendAdvertisList: Boolean;

    // 카드사 할인 체크
    //function SearchCardDiscount(ACardNo, ACardAmt: string; out ACode, AMsg: string): Currency;

    function Send_Nexpa_API(AUrl, AJsonText: string): AnsiString;

    property Authorization: AnsiString read FAuthorization write FAuthorization;
    property UTF8Str: UTF8String read FUTF8Str write FUTF8Str;
  end;

implementation

uses
  uGlobal, uSaleModule, fx.Logging, uFunction, uCommon;

{ TXPErpApi }

constructor TXPErpApi.Create;
begin
//  FSendAPIThread := TSendAPIThread.Create;
  sslIOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  sslIOHandler.SSLOptions.Method := sslvSSLv23;
  sslIOHandler.SSLOptions.Mode := sslmClient;
end;

destructor TXPErpApi.Destroy;
begin
//  FSendAPIThread.Free;
//  FreeAndNil(SendData);
//  FreeAndNil(RecvData);

  sslIOHandler.Free;
//  SendData.Free;
//  RecvData.Free;
  inherited;
end;

function TXPErpApi.OAuth_Certification: Boolean;
var
  Indy: TIdHTTP;
  SendData, RecvData: TStringStream;
  jObj: TJSONObject;
begin
  try
    Indy := TIdHTTP.Create(nil);
    SendData := TStringStream.Create;
    RecvData := TStringStream.Create;

    SendData.Clear;
    RecvData.Clear;

    Indy.IOHandler := sslIOHandler;

    UTF8Str := UTF8String(Global.Config.OAuth.DeviceID + ':' + Global.Config.OAuth.Key);
    Authorization := EncdDecd.EncodeBase64(PAnsiChar(UTF8Str), Length(UTF8Str));

    Indy.Request.CustomHeaders.Clear;
    Indy.Request.ContentType := 'application/x-www-form-urlencoded';
    Indy.Request.CustomHeaders.Values['Authorization'] := 'Basic ' + Authorization;

    SendData.WriteString(TIdURI.ParamsEncode('grant_type=client_credentials'));

    Indy.Post(Global.Config.Partners.OAuthURl, SendData, RecvData);

    jObj := TJSONObject.ParseJSONValue( ByteStringToString(RecvData) ) as TJSONObject;
    Global.Config.OAuth.Token := jObj.Get('access_token').JsonValue.Value;
  finally
    FreeAndNil(jObj);
    Indy.Free;
    SendData.Free;
    RecvData.Free;
  end;
end;

function TXPErpApi.GetStoreInfo: Boolean;
var
  Index, nCnt: Integer;
  MainJson, jObj, jObjItem, jObjSub: TJSONObject;
  jObjArr: TJsonArray;
  JsonText: string;
  Agreement: TAgreement;
  FileExtract, FileName: string;

  AIndy: TIdHTTP;
  mStream: TMemoryStream;
  //sslIOHandler : TIdSSLIOHandlerSocketOpenSSL;
  FileUrl, FilePath: String;
begin
  try
    Result := False;

    JsonText := Send_API(mtGet, 'K203_StoreInfo?store_cd=' + Global.Config.Store.StoreCode, EmptyStr, True);

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

function TXPErpApi.GetAdvertisVersion: string;
begin
  Result := GetVersion('K233_AdvertiseVersion?store_cd=' + Global.Config.Store.StoreCode);
  if Result = EmptyStr then
    Result := Global.Config.Version.AdvertisVersion;
end;

procedure TXPErpApi.SearchAdvertisList;
var
//  Indy: TIdHTTP;
  MainJson, jObj: TJSONObject;
  jObjArr: TJsonArray;
  //JsonValue, ItemValue: TJSONValue;
  AUrl, FileExtract, FileName: string;
  JsonText: AnsiString;
  Loop, nCnt: Integer;
  AAdvertise: TAdvertisement;
  AIndy: TIdHTTP;
  mStream: TMemoryStream;
  WeekUse: Integer;
  ListUp, ListDown: TList<TAdvertisement>;
  AAdvertisement: TAdvertisement;
  sslIOHandler : TIdSSLIOHandlerSocketOpenSSL;

//  Stream: TStream;
//  AArray: Array of byte;
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
      //MainJson := TJSONObject.Create;
      //JsonValue := TJSONValue.Create;
      ListUp := TList<TAdvertisement>.Create;
      ListDown := TList<TAdvertisement>.Create;

      AUrl := '?store_cd=' + Global.Config.Store.StoreCode;

      JsonText := Send_API(mtGet, 'K231_AdvertiseList' + AUrl, EmptyStr);

      MainJson := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;

      if MainJson.GetValue('result_cd').Value = '0000' then
      begin
        if not (MainJson.FindValue('result_data') is TJSONNull) then
        begin
          jObjArr := MainJson.GetValue('result_data') as TJsonArray;
          nCnt := jObjArr.Size;

          for Loop := 0 to nCnt - 1 do
          begin
            jObj := jObjArr.Get(Loop) as TJSONObject;

            if jObj.GetValue('del_yn').Value = 'Y' then
              Continue;

            sslIOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
            sslIOHandler.SSLOptions.Mode := sslmClient;
            sslIOHandler.SSLOptions.SSLVersions := [sslvTLSv1_2];

            AIndy := TIdHTTP.Create(nil);
            AIndy.IOHandler := sslIOHandler;
            mStream := TMemoryStream.Create;
            //ItemValue := (JsonValue as TJSONArray).Items[Loop];

             StrToIntDef(jObj.GetValue('ad_seq').Value, 0);

            AAdvertise.Seq := StrToIntDef(jObj.GetValue('ad_seq').Value, 0);
            AAdvertise.FileUrl := jObj.GetValue('file_url').Value;
            AAdvertise.Position := jObj.GetValue('position_div').Value;
            AAdvertise.StartDate := jObj.GetValue('open_start_day').Value;
            AAdvertise.EndDate := jObj.GetValue('open_end_day').Value;
            AAdvertise.Show_Week := jObj.GetValue('open_week_div').Value;
            AAdvertise.Show_Start_Time := jObj.GetValue('open_start_time').Value;
            AAdvertise.Show_End_Time := jObj.GetValue('open_end_time').Value;
            AAdvertise.Show_Interval := jObj.GetValue('open_second').Value;
            AAdvertise.Show_YN := jObj.GetValue('open_yn').Value = 'Y';

            WeekUse := DayOfWeek(Now);

            if WeekUse = 1 then
              WeekUse := 7
            else
              WeekUse := WeekUse - 1;

            if (AAdvertise.StartDate <= FormatDateTime('yyyymmdd', now)) and (FormatDateTime('yyyymmdd', now) <= AAdvertise.EndDate) then
            begin
              if AAdvertise.Show_YN and (Copy(AAdvertise.Show_Week, WeekUse, 1) = '1') then
              begin
                FileExtract := ExtractFileExt(AAdvertise.FileUrl);
                FileName := StringReplace(AAdvertise.FileUrl, Global.Config.Partners.FileUrl, '', [rfReplaceAll]);

                AIndy.Get(AAdvertise.FileUrl, mStream);

                if (FileExtract = '.avi') or (FileExtract = '.mp4') then
                  AAdvertise.FilePath := ExtractFilePath(ParamStr(0)) + '\Intro\Media\' + jObj.GetValue('upload_nm').Value
                else
                  AAdvertise.FilePath := ExtractFilePath(ParamStr(0)) + '\Intro\' + jObj.GetValue('upload_nm').Value;

                if (Global.SaleModule.AdvertisementListDown.Count = 0) and (Global.SaleModule.AdvertisementListUp.Count = 0) then
                begin
                  DeleteFile(AAdvertise.FilePath);
                end;

                if not FileExists(AAdvertise.FilePath) then
                  mStream.SaveToFile(AAdvertise.FilePath);

                if AAdvertise.Position = 'D' then
                begin
                  AAdvertise.Image := TBitmap.CreateFromFile(AAdvertise.FilePath);
                  ListDown.Add(AAdvertise)
                end
                else
                  ListUp.Add(AAdvertise);
              end;
//              AAdvertise.Image.SaveToStream(Stream);
//              Stream.WriteData(AArray, Stream.Size);
//              EncdDecd.EncodeBase64(@AArray[0], Length(AArray));
            end;

            sslIOHandler.Free;
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

{
function TXPErpApi.SearchPromotion(ACoupon: string): Boolean;
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
      JsonText := Send_API(mtGet, 'K604_CheckCoupon' + AUrl, EmptyStr);
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

//          if ADisCount.Gubun = 1 then
//          begin

          if Global.SaleModule.AddCheckPromotionType(ADisCount.dc_cond_div) then
            Exit;

            // 바뀌면서 사용 X 2019.11.14
//            if not Global.SaleModule.AddCheckDiscount(ADisCount.Product_Div, ADisCount.Product_Div_Detail, ADisCount.Gubun) then
//            begin
//              Global.SBMessage.ShowMessageModalForm(MSG_PROMOTION + MSG_PROMOTION_OPTION_5);
//              Exit;
//            end;


//          end
//          else
//          begin
//            if not Global.SaleModule.AddChectDiscountAmt(ADisCount.Value) then
//            begin
//              Global.SBMessage.ShowMessageModalForm(MSG_PROMOTION + MSG_PROMOTION_OPTION_3);
//              Exit;
//            end;
//          end;

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
        //chy bc페이북골프
        //Global.SBMessage.ShowMessageModalForm(CouponError(((JsonValue as TJSONObject).Get('result_data').JsonValue as TJSONObject).Get('result_cd').JsonValue.Value));
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
function TXPErpApi.CouponError(ACode: string): string;
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
  //chy bc페이북골프
  else if ACode = 'P04F' then
    //Result := '발급이 취소된 쿠폰 입니다.'
    Result := '사용하실 수 없는 QR코드 입니다.'
  else
    Result := '알수 없는 오류코드(' + ACode + ')';
end;
}

function TXPErpApi.SendAdvertisCnt(ASeq: string): Boolean;
var
  MainJson: TJSONObject;
  JsonText: string;
begin
  try
    try
      MainJson := TJSONObject.Create;

      MainJson.AddPair(TJSONPair.Create('store_cd', Global.Config.Store.StoreCode));
      MainJson.AddPair(TJSONPair.Create('ad_seq', ASeq));

      JsonText := Send_API(mtPost, 'K232_AdvertiseView', MainJson.ToString);
      {$IFDEF DEBUG}
//      Global.LocalDatabase.Searh_MS_ADVERTIS_D_UPDATE(ASeq);
//      Log.D('SendAdvertisCnt', JsonText);
      {$ENDIF}
    except
      on E: Exception do
        Log.E('SendAdvertisCnt', ASeq + ':' + E.Message);
    end;
  finally
    FreeAndNil(MainJson);
  end;
end;

function TXPErpApi.SendAdvertisList: Boolean;
var
  Index, Cnt: Integer;
  MainJson: TJSONObject;
  JsonList: TJSONArray;
  JsonText: string;
  AFile: TIniFile;
begin
  try
    try
      AFile := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Config.ini');

      Cnt := 0;
      MainJson := TJSONObject.Create;
      JsonList := TJSONArray.Create;
      MainJson.AddPair(TJSONPair.Create('store_cd', Global.Config.Store.StoreCode));
      for Index := 0 to Global.SaleModule.AdvertisementListUp.Count - 1 do
      begin
        Cnt := AFile.ReadInteger('MEDIA', Global.SaleModule.AdvertisementListUp[Index].Name, 0);
        if Cnt <> 0 then
        begin
          JsonList.Add(TJSONObject.Create(TJSONPair.Create(IntToStr(Global.SaleModule.AdvertisementListDown[Index].Seq),
            IntToStr(Cnt))));
          Cnt := 0;
        end;
      end;

      for Index := 0 to Global.SaleModule.AdvertisementListDown.Count - 1 do
      begin
        Cnt := AFile.ReadInteger('MEDIA', Global.SaleModule.AdvertisementListDown[Index].Name, 0);
        if Cnt <> 0 then
        begin
          JsonList.Add(TJSONObject.Create(TJSONPair.Create(IntToStr(Global.SaleModule.AdvertisementListDown[Index].Seq),
            IntToStr(Cnt))));
          Cnt := 0;
        end;
      end;
      MainJson.AddPair(TJSONPair.Create('Data', JsonList));

      JsonText := Send_API(mtPost, 'K232_AdvertiseView', MainJson.ToString);
      {$IFDEF DEBUG}
//      Log.D('SendAdvertisCnt', JsonText);
      {$ENDIF}
    except
      on E: Exception do
        Log.E('SendAdvertisList', E.Message);
    end;
  finally
    FreeAndNil(JsonList);
    FreeAndNil(MainJson);
  end;
end;

function TXPErpApi.Send_API(MethodType: TMethodType; AUrl, AJsonText: string; NotSaveLog: Boolean): AnsiString;
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
      Indy.Request.CustomHeaders.Clear;
      Indy.IOHandler := sslIOHandler;
      Indy.URL.URI := Global.Config.Partners.URL;
      Indy.Request.CustomHeaders.Values['Authorization'] := 'Bearer ' + Global.Config.OAuth.Token;

      if AJsonText <> EmptyStr then
      begin
        Indy.Request.ContentType := 'application/json';
        Indy.Request.Accept := '*/*';
        SendData := TStringStream.Create(AJsonText, TEncoding.UTF8);
      end
      else
        Indy.Request.ContentType := 'application/x-www-form-urlencoded';

      //chy socket test
      Indy.ConnectTimeout := 3000;
      Indy.ReadTimeout := 3000;

      if MethodType = mtGet then
        Indy.Get(Global.Config.Partners.URL + AUrl, RecvData)
      else if MethodType = mtPost then
      begin
        Indy.Post(Global.Config.Partners.URL + AUrl, SendData, RecvData);
      end
      else if MethodType = mtDelete then
        Indy.Delete(Global.Config.Partners.URL + AUrl, RecvData);

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
//    Indy.Disconnect;
    Indy.Free;
    SendData.Free;
    RecvData.Free;
  end;
end;

function TXPErpApi.Send_API_Reservation(MethodType: TMethodType; AUrl, AJsonText: string; NotSaveLog: Boolean): AnsiString;
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

//      Indy.ConnectTimeout := 5000;
//      Indy.ReadTimeout := 5000;

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
//    Indy.Disconnect;
    AIndy.Free;
    SendData.Free;
    RecvData.Free;
  end;
end;

function TXPErpApi.GetVersion(AUrl: string): string;
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
      JsonText := Send_API(mtGet, AUrl, EmptyStr);

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

{
function TXPErpApi.SearchCardDiscount(ACardNo, ACardAmt: string; out ACode, AMsg: string): Currency;
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

      JsonText := Send_API(mtGet, AUrl, EmptyStr);

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

function TXPErpApi.Send_Nexpa_API(AUrl, AJsonText: string): AnsiString;
var
  Indy: TIdHTTP;
  SendData, RecvData: TStringStream;
begin

  try
    try
      SendData := TStringStream.Create;
      RecvData := TStringStream.Create;

      Log.D('Send_Nexpa_API', 'Begin - ' + Global.Config.Partners.NexpaURL + AUrl);

      Indy := TIdHTTP.Create(nil);
      Result := EmptyStr;
      SendData.Clear;
      RecvData.Clear;
      //Indy.Request.CustomHeaders.Clear;
      Indy.IOHandler := sslIOHandler;
      //Indy.URL.URI := Global.Config.Partners.URL;

      Indy.Request.ContentType := 'application/json';
      //Indy.Request.Accept := '*/*';
      SendData := TStringStream.Create(AJsonText, TEncoding.UTF8);

      Indy.ConnectTimeout := 5000;
      Indy.ReadTimeout := 5000;

      Indy.Post(Global.Config.Partners.NexpaURL + AUrl, SendData, RecvData);

      Result := ByteStringToString(RecvData);
      Log.D('Send_Nexpa_API End', Result);
    except
      on E: Exception do
      begin
        Log.E('Send_Nexpa_API Exception', AUrl);
        Log.E('Send_Nexpa_API Exception', E.Message);
      end;
    end;

  finally
    Indy.Free;
    SendData.Free;
    RecvData.Free;
  end;
end;

{ TSendAPIThread }

{
constructor TSendErpAPIThread.Create;
begin
  FreeOnTerminate := False;
  inherited Create(True);
end;

destructor TSendErpAPIThread.Destroy;
begin

  inherited;
end;

procedure TSendErpAPIThread.Execute;
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
