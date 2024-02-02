unit uASPDatabase;

interface

uses
  IdGlobal, FMX.Graphics, IdCoderMIME, InIFiles, IdSSL, IdSSLOpenSSL,
  uStruct, System.Variants, System.SysUtils, System.Classes, System.DateUtils,
  Generics.Collections, Uni, IdHTTP, JSON, EncdDecd, IdURI, uConsts;

type
  TSendAPIThread = class(TThread)
  private
  protected
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  TASPDatabase = class
  private
    FAuthorization: AnsiString;
    FByteStr: RawByteString;
    FUTF8Str: UTF8String;
    function Send_API(MethodType: TMethodType; AUrl, AJsonText: string; NotSaveLog: Boolean = False): AnsiString;
    function Send_API_Reservation(MethodType: TMethodType; AUrl, AJsonText: string; NotSaveLog: Boolean = False): AnsiString;
    function GetVersion(AUrl: string): string;
  public
    sslIOHandler: TIdSSLIOHandlerSocketOpenSSL;
    constructor Create;
    destructor Destroy; override;

    procedure SetConnection;
    //
    function Connect: Boolean;
    //
    function DisConnect: Boolean;

    // 회원데이터를 가져온다.
    function GetAllMmeberInfoVersion: string;
    function GetAllMemberInfo: TList<TMemberInfo>;
    // 회원 정보를 가져온다. 회원코드로만
    function GetMemberInfo(ACardNo: string; out AMsg: string): TMemberInfo;
    // 회원의 상품 리스트를 가져온다
    function GetMemberProductList(ACardNo, ACode, ADate: string): TList<TProductInfo>;
    // OPT QR로회원정보 호출
    function GetMemberOptQR(AQRCode: string): TMemberInfo;

    // 타석 마스터 정보를 읽어 온다.
    function GetTeeBoxMasterVersion: string;
    function GetTeeBoxMaster: TList<TTeeBoxInfo>;
    // 타석 정보를 읽어 온다.
    //function GetTeeBoxPlayingInfo: TList<TTeeBoxInfo>;

    // 타석 상품을 가져온다.
    function GetTeeBoxProductListVersion: string;
    function GetTeeBoxProductList: TList<TProductInfo>;
    // 일일 타석 상품을 가져온다.
    function GetTeeBoxDayProductList: TList<TProductInfo>;

    // OAuth 인증
    function OAuth_Certification: Boolean;

    // 환경설정
    function GetConfigVersion: string;
    function GetConfig: Boolean;

    // 가맹점 정보 조회
    function GetStoreInfo: Boolean;

    // 타석 홀드
    function TeeBoxHold(AIsHold: Boolean = True): Boolean;

    // 타석 예약 등록
    function TeeBoxReservation: Boolean;
    function TeeBoxListReservation: Boolean;

    // 벙커/퍼팅 배정가능여부
    function BunkerPossible: Boolean;
    function BunkerReservation: Boolean;

    //체크인 정보
    function GetMemberCheckInList(AMemberNo, AQRCode: string; out ACode, AMsg: string): TList<TCheckInInfo>;

    // 타석 예약 조회
    function TeeBoxReservationInfo(ACode: string): Boolean;

    // 매출 등록
    function SaveSaleInfo: Boolean;

    // 프로모션 확인
    function SearchPromotion(ACoupon: string): Boolean;
    function CouponError(ACode: string): string;

    // 광고 목록 조회
    function GetAdvertisVersion: string;
    procedure SearchAdvertisList;
    function SendAdvertisCnt(ASeq: string): Boolean;
    function SendAdvertisList: Boolean;

    // XGOLF회원 QR 등록
    function AddMemberXGOLFQR(ACode: string): Boolean;
    // 카드사 할인 체크
    function SearchCardDiscount(ACardNo, ACardAmt: string; out ACode, AMsg: string): Currency;

    property Authorization: AnsiString read FAuthorization write FAuthorization;
    property UTF8Str: UTF8String read FUTF8Str write FUTF8Str;
  end;

implementation

uses
  uGlobal, uSaleModule, fx.Logging, uFunction, uCommon;

{ TASPDatabase }

function TASPDatabase.AddMemberXGOLFQR(ACode: string): Boolean;
var
  JsonValue: TJSONValue;
  MainJson: TJSONObject;
  JsonText, AUrl: string;
begin
  try
    try
      Result := False;
      MainJson := TJSONObject.Create;

      AUrl := 'M030_MemberAuth?member_no=' + Global.SaleModule.Member.Code +
              '&store_cd=' + Global.Config.Store.StoreCode + '&xg_user_key=' + Global.SaleModule.Member.XGolfMemberQR;

      JsonText := Send_API(mtPost, AUrl, EmptyStr);

      if JsonText = EmptyStr then
        Exit;

      JsonValue := MainJson.ParseJSONValue(JsonText);
      if (JsonValue as TJSONObject).Get('result_cd').JsonValue.Value = '0000' then
        Result := True;
    except
      on E: Exception do
      begin
        Log.E('AddMemberXGOLFQR', AUrl);
        Log.E('AddMemberXGOLFQR', E.Message);
      end;
    end;
  finally
    MainJson.Free;
    JsonValue.Free;
  end;
end;

constructor TASPDatabase.Create;
begin
  sslIOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  sslIOHandler.SSLOptions.Method := sslvSSLv23;
  sslIOHandler.SSLOptions.Mode := sslmClient;
end;

destructor TASPDatabase.Destroy;
begin
  sslIOHandler.Free;

  inherited;
end;

procedure TASPDatabase.SetConnection;
begin
  inherited;

end;

function TASPDatabase.Connect: Boolean;
begin

end;

function TASPDatabase.DisConnect: Boolean;
begin

end;

function TASPDatabase.GetAllMmeberInfoVersion: string;
begin
  Result := GetVersion('K213_MemberVersion?store_cd=' + Global.Config.Store.StoreCode);
  if Result = EmptyStr then
    Result := Global.Config.Version.MemberVersion;
end;

function TASPDatabase.GetAllMemberInfo: TList<TMemberInfo>;
var
  Index, Loop, tmp: Integer;
  AMemberInfo: TMemberInfo;
  MainJson: TJSONObject;
  JsonValue, ItemValue: TJSONValue;
  JsonText, AVersion, SendDatetime: string;
  ABytes: TBytes;
  AFingerStr: AnsiString;
begin
  try
    Result := TList<TMemberInfo>.Create;

    MainJson := TJSONObject.Create;
    JsonValue := TJSONValue.Create;

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

    JsonValue := MainJson.ParseJSONValue(JsonText);

    if '0000' = (JsonValue as TJSONObject).Get('result_cd').JsonValue.Value then
    begin
      if JsonValue.FindValue('result_data') is TJSONNull then
        Exit;

      JsonValue := (JsonValue as TJSONObject).Get('result_data').JsonValue;

      Log.D('저장할 회원 수', Inttostr((JsonValue as TJSONArray).Count));
      for Index := 0 to (JsonValue as TJSONArray).Count - 1 do
      begin
        AMemberInfo.FingerStr := EmptyStr;

        ItemValue := (JsonValue as TJSONArray).Items[Index];
        AMemberInfo.Code := (ItemValue as TJSONObject).Get('member_no').JsonValue.Value;
        AMemberInfo.CardNo := (ItemValue as TJSONObject).Get('qr_cd').JsonValue.Value;
        AMemberInfo.CarNo := (ItemValue as TJSONObject).Get('car_no').JsonValue.Value;
        AMemberInfo.Addr1 := (ItemValue as TJSONObject).Get('address').JsonValue.Value;
        AMemberInfo.Addr2 := (ItemValue as TJSONObject).Get('address_desc').JsonValue.Value;
        AMemberInfo.Tel_Mobile := (ItemValue as TJSONObject).Get('hp_no').JsonValue.Value;
        AMemberInfo.Email := (ItemValue as TJSONObject).Get('email').JsonValue.Value;
        AMemberInfo.Sex := IfThen(StrToIntDef((ItemValue as TJSONObject).Get('sex_div').JsonValue.Value, 1) = 1, 'M', 'W');
        AMemberInfo.Name := (ItemValue as TJSONObject).Get('member_nm').JsonValue.Value;
        AMemberInfo.BirthDay := (ItemValue as TJSONObject).Get('birth_ymd').JsonValue.Value;
        AMemberInfo.XGolfMemberQR := (ItemValue as TJSONObject).Get('xg_user_key').JsonValue.Value;
        AMemberInfo.XGolfMember := Copy(AMemberInfo.XGolfMemberQR, 1, 2) = XGOLF_REPLACE_STR3;

        if Copy(AMemberInfo.Name, 1, 7) = 'VIPBLUE' then
          Continue;

        if Copy(AMemberInfo.Name, 1, 7) = 'package' then
          Continue;

         if Copy(AMemberInfo.Name, 1, 4) = 'vip-' then
          Continue;

         if Copy(AMemberInfo.Name, 1, 3) = 'xyg' then
          Continue;

         if Copy(AMemberInfo.Name, 1, 2) = '5v' then
          Continue;

         if Copy(AMemberInfo.Name, 1, 2) = 'gv' then
          Continue;

         if Copy(AMemberInfo.Name, 1, 2) = 'pv' then
          Continue;

         if Copy(AMemberInfo.Name, 1, 2) = 'vv' then
          Continue;

         if Copy(AMemberInfo.Name, 1, 3) = 'vvv' then
          Continue;

         if Copy(AMemberInfo.Name, 1, 8) = 'VIPWHITE' then
          Continue;

         if Copy(AMemberInfo.Name, 1, 7) = 'VIPPINK' then
          Continue;

         if Copy(AMemberInfo.Name, 1, 4) = '2019' then
          Continue;

        // 삭제 여부 API 추가 확인 후 갱신
        AMemberInfo.Use := (ItemValue as TJSONObject).Get('del_yn').JsonValue.Value = 'N';
        //if (not AMemberInfo.Use) and (Global.SaleModule.MemberList.Count <> 0) then
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

        try
          if False then
          begin
            AMemberInfo.FingerStr := (ItemValue as TJSONObject).Get('fingerprint_hash').JsonValue.Value;

            if Copy(AMemberInfo.FingerStr, 1, 20) = 'AAAAAAAAAAAAAAAAAAAA' then
            begin
              Log.D('지문데이터 오류', AMemberInfo.Name + ':' + AMemberInfo.Code);
              Log.D('GetAllMemberInfo', LogReplace(AMemberInfo.Name));
              Log.D('GetAllMemberInfo', IntToStr(AMemberInfo.FingerCnt));
              Log.D('GetAllMemberInfo', IntToStr(Length(AMemberInfo.FingerStr)));
              Log.D('GetAllMemberInfo', LogReplace(AMemberInfo.FingerStr));
              AMemberInfo.FingerStr := EmptyStr;
            end
            else if AMemberInfo.FingerStr <> EmptyStr then
            begin
              AMemberInfo.FingerStr := StringReplace(AMemberInfo.FingerStr, '#$D#$A', #13#10, [rfReplaceAll]);
              AMemberInfo.FingerStr := StringReplace(AMemberInfo.FingerStr, 'fingerprint_hash', '', [rfReplaceAll]);
              AMemberInfo.FingerStr := StringReplace(AMemberInfo.FingerStr, '?', '', [rfReplaceAll]);
              AMemberInfo.FingerStr := StringReplace(AMemberInfo.FingerStr, '지문값', '', [rfReplaceAll]);

              ABytes := EncdDecd.DecodeBase64(AMemberInfo.FingerStr);

              for tmp := 0 to Length(ABytes) - 1 do
                AMemberInfo.Finger[tmp] := ABytes[tmp];
            end;
          end
          else
          begin
            AMemberInfo.FingerStr := (ItemValue as TJSONObject).Get('fingerprint1').JsonValue.Value;
            AMemberInfo.FingerStr_2 := (ItemValue as TJSONObject).Get('fingerprint2').JsonValue.Value;
          end;

        except
          on E: Exception do
          begin
            Log.E('GetAllMemberInfo', E.Message);
            Log.E('GetAllMemberInfo', LogReplace(AMemberInfo.Name));
            Log.E('GetAllMemberInfo', IntToStr(AMemberInfo.FingerCnt));
            Log.E('GetAllMemberInfo', IntToStr(Length(AMemberInfo.FingerStr)));
            Log.E('GetAllMemberInfo', LogReplace(AMemberInfo.FingerStr));
          end;
        end;

        if AMemberInfo.Use then
          Result.Add(AMemberInfo);
      end;
    end;
  finally
    FreeAndNil(MainJson);
    FreeAndNil(JsonValue);
    Log.D('저장된 회원 수', inttostr(Result.Count));
  end;
end;

function TASPDatabase.GetConfigVersion: string;
begin
  Result := GetVersion('K201_ConfigVersion?store_cd=' + Global.Config.Store.StoreCode);
  if Result = EmptyStr then
    Result := Global.Config.Version.ConfigVersion;
end;

function TASPDatabase.GetConfig: Boolean;
var
  MainJson, jObj: TJSONObject;
  jObjArr: TJsonArray;
  AClient_ID, Store_CD: AnsiString;
  JsonText, AVersion: string;
  Index, nCnt: Integer;
begin
  try
    Result := False;

    //chy debug구분용
    Global.sUrl := Global.Config.URL;

    AClient_ID := Global.Config.OAuth.DeviceID;
    Store_CD := Global.Config.Store.StoreCode;

    JsonText := Send_API(mtGet, 'K202_Configlist?store_cd=' + Store_CD + '&client_id=' + AClient_ID, EmptyStr);

    if JsonText = EmptyStr then
      Exit;
    //Log.D('환경설정', JsonText);

    MainJson := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;

    if MainJson.GetValue('result_cd').Value = '0000' then
    begin
      if not (MainJson.FindValue('result_data') is TJSONNull) then
      begin
        Global.SaleModule.ConfigJsonText := JsonText;
        jObjArr := MainJson.GetValue('result_data') as TJsonArray;
        nCnt := jObjArr.Size;

        for Index := 0 to nCnt - 1 do
        begin
          jObj := jObjArr.Get(Index) as TJSONObject;

          if jObj.GetValue('del_yn').Value = 'Y' then
            Continue;

          if jObj.GetValue('section_cd').Value = 'PRINTER' then
          begin
            if jObj.GetValue('item_cd').Value = 'COMPORT' then
            begin
              {$IFDEF RELEASE}
              Global.Config.Print.Port := StrToIntDef(jObj.GetValue('item_value').Value, 0);
              {$ENDIF}
              {$IFDEF DEBUG}
              Global.Config.Print.Port := 4;
              {$ENDIF}
            end
            else if jObj.GetValue('item_cd').Value = 'BAUDRATE' then
              Global.Config.Print.BaudRate := StrToIntDef(jObj.GetValue('item_value').Value, 0)
            else if jObj.GetValue('item_cd').Value = 'TYPE' then
              Global.Config.Print.PrintType := jObj.GetValue('item_value').Value;
          end;

          if jObj.GetValue('section_cd').Value = 'SCANNER' then
          begin
            if jObj.GetValue('item_cd').Value = 'COMPORT' then
            begin
              {$IFDEF RELEASE}
              Global.Config.Scanner.Port := StrToIntDef(jObj.GetValue('item_value').Value, 0);
              {$ENDIF}
              {$IFDEF DEBUG}
              Global.Config.Scanner.Port := 0;
              {$ENDIF}
            end
            else if jObj.GetValue('item_cd').Value = 'BAUDRATE' then
            begin
              {$IFDEF RELEASE}
              Global.Config.Scanner.BaudRate := StrToIntDef(jObj.GetValue('item_value').Value, 0);
              {$ENDIF}
              {$IFDEF DEBUG}
              Global.Config.Scanner.BaudRate := 115200;
              {$ENDIF}
            end;
          end;

          if jObj.GetValue('section_cd').Value = 'RFID' then
          begin
            if jObj.GetValue('item_cd').Value = 'COMPORT' then
            begin
              {$IFDEF RELEASE}
              Global.Config.RFID.Port := StrToIntDef(jObj.GetValue('item_value').Value, 0);
              {$ENDIF}
              {$IFDEF DEBUG}
              Global.Config.RFID.Port := 0;
              {$ENDIF}
            end
            else if jObj.GetValue('item_cd').Value = 'BAUDRATE' then
            begin
              {$IFDEF RELEASE}
              Global.Config.RFID.BaudRate := StrToIntDef(jObj.GetValue('item_value').Value, 0);
              {$ENDIF}
              {$IFDEF DEBUG}
              Global.Config.RFID.BaudRate := 115200;
              {$ENDIF}
            end;
          end;

          if jObj.GetValue('section_cd').Value = 'STORE' then
          begin
            {
            if (ItemValue as TJSONObject).Get('item_cd').JsonValue.Value = 'CODE' then
              Global.Config.Store.StoreCode := (ItemValue as TJSONObject).Get('item_value').JsonValue.Value
            else if (ItemValue as TJSONObject).Get('item_cd').JsonValue.Value = 'BIZNO' then
            }
            if jObj.GetValue('item_cd').Value = 'BIZNO' then
              Global.Config.Store.BizNo := jObj.GetValue('item_value').Value
            else if jObj.GetValue('item_cd').Value = 'VANTID' then
              Global.Config.Store.VanTID := jObj.GetValue('item_value').Value
            else if jObj.GetValue('item_cd').Value = 'VANCODE' then
              Global.Config.Store.VanCode := StrToIntDef(jObj.GetValue('item_value').Value, 0)
            else if jObj.GetValue('item_cd').Value = 'ADMINPW' then
              Global.Config.Store.AdminPassword := jObj.GetValue('item_value').Value
            else if jObj.GetValue('item_cd').Value = 'PREPARE_MIN' then
              Global.Config.PrePare_Min := jObj.GetValue('item_value').Value
            else if jObj.GetValue('item_cd').Value = 'POS_IP' then
              Global.Config.MainPosIP := jObj.GetValue('item_value').Value

            // union
            else if jObj.GetValue('item_cd').Value = 'Fingerprint' then
              Global.Config.Fingerprint := jObj.GetValue('item_value').Value
            else if jObj.GetValue('item_cd').Value = 'EnrollImageQuality' then
              Global.Config.EnrollImageQuality := StrToIntDef(jObj.GetValue('item_value').Value, 70)

            else if jObj.GetValue('item_cd').Value = 'VerifyImageQuality' then
              Global.Config.VerifyImageQuality := StrToIntDef(jObj.GetValue('item_value').Value, 70)
            else if jObj.GetValue('item_cd').Value = 'SecurityLevel' then
              Global.Config.SecurityLevel := StrToIntDef(jObj.GetValue('item_value').Value, 7)
            else if jObj.GetValue('item_cd').Value = 'PARKINGBARCODE' then
              Global.Config.PARKINGBARCODE := jObj.GetValue('item_value').Value = 'Y'
            else if jObj.GetValue('item_cd').Value = 'PARKING_DB_IP' then
              Global.Config.PARKING_DB_IP := jObj.GetValue('item_value').Value
            else if jObj.GetValue('item_cd').Value = 'COUPON_QR' then
              Global.Config.CouponMember := jObj.GetValue('item_value').Value = 'Y'
            else if jObj.GetValue('item_cd').Value = 'PromotionPopup' then
              Global.Config.PromotionPopup := jObj.GetValue('item_value').Value = 'Y';
          end;

          if jObj.GetValue('section_cd').Value = 'RECEIPT' then
          begin
            if jObj.GetValue('item_cd').Value = 'TOP1' then
              Global.Config.Receipt.Top1 := Trim(jObj.GetValue('item_value').Value)
            else if jObj.GetValue('item_cd').Value = 'TOP2' then
              Global.Config.Receipt.Top2 := Trim(jObj.GetValue('item_value').Value)
            else if jObj.GetValue('item_cd').Value = 'TOP3' then
              Global.Config.Receipt.Top3 := Trim(jObj.GetValue('item_value').Value)
            else if jObj.GetValue('item_cd').Value = 'TOP4' then
              Global.Config.Receipt.Top4 := Trim(jObj.GetValue('item_value').Value)
            else if jObj.GetValue('item_cd').Value = 'BOTTOM1' then
              Global.Config.Receipt.Bottom1 := Trim(jObj.GetValue('item_value').Value)
            else if jObj.GetValue('item_cd').Value = 'BOTTOM2' then
              Global.Config.Receipt.Bottom2 := Trim(jObj.GetValue('item_value').Value)
            else if jObj.GetValue('item_cd').Value = 'BOTTOM3' then
              Global.Config.Receipt.Bottom3 := Trim(jObj.GetValue('item_value').Value)
            else if jObj.GetValue('item_cd').Value = 'BOTTOM4' then
              Global.Config.Receipt.Bottom4 := Trim(jObj.GetValue('item_value').Value);
          end;

          if jObj.GetValue('section_cd').Value = 'WELLBEING' then
          begin
            if jObj.GetValue('item_cd').Value = 'TOKEN' then
              Global.Config.Wellbeing.Token := Trim(jObj.GetValue('item_value').Value)
            else if jObj.GetValue('item_cd').Value = 'CODE' then
              Global.Config.Wellbeing.StoreCD := Trim(jObj.GetValue('item_value').Value)
          end;

          if jObj.GetValue('section_cd').Value = 'REFRESHCLUB' then
          begin
            if jObj.GetValue('item_cd').Value = 'TOKEN' then
              Global.Config.RefreshClub.Token := Trim(jObj.GetValue('item_value').Value)
            else if jObj.GetValue('item_cd').Value = 'CODE' then
              Global.Config.RefreshClub.StoreCD := Trim(jObj.GetValue('item_value').Value)
          end;

          if jObj.GetValue('section_cd').Value = 'AD' then
          begin
            {
            if jObj.GetValue('item_cd').Value = 'USE' then
              Global.Config.AD.USE := Trim(jObj.GetValue('item_value').Value) = 'Y'
            else
            }
            if jObj.GetValue('item_cd').Value = 'IP' then
            begin
              {$IFDEF RELEASE}
              Global.Config.AD.IP := Trim(jObj.GetValue('item_value').Value);
              {$ENDIF}
              {$IFDEF DEBUG}
              Global.Config.AD.IP := '192.168.0.81';
              {$ENDIF}
            end
            else if jObj.GetValue('item_cd').Value = 'DB_PORT' then
            begin
              {$IFDEF RELEASE}
              Global.Config.AD.DB_PORT := StrToIntDef(Trim(jObj.GetValue('item_value').Value), 3306)
              {$ENDIF}
              {$IFDEF DEBUG}
              Global.Config.AD.DB_PORT := 3307;
              {$ENDIF}
            end
            else if jObj.GetValue('item_cd').Value = 'SERVER_PORT' then
              Global.Config.AD.SERVER_PORT := StrToIntDef(Trim(jObj.GetValue('item_value').Value), 16001);
          end;
        end;
      end;

      Global.Config.SaveLocalConfig;
      Result := True;
    end;
  finally
    FreeAndNil(MainJson);
    //FreeAndNil(JsonValue);
  end;
end;

function TASPDatabase.GetMemberInfo(ACardNo: string; out AMsg: string): TMemberInfo;
var
  Index: Integer;
  MainJson: TJSONObject;
  JsonValue, JsonListValue: TJSONValue;
  AMember: TMemberInfo;
  JsonText: string;
  sLockerEndDay: String;
begin
  try
    Log.D('GetMemberInfo', LogReplace(ACardNo));
    AMember.Code := EmptyStr;

    Result := AMember;

    MainJson := TJSONObject.Create;
    JsonValue := TJSONValue.Create;
    JsonListValue := TJSONValue.Create;
    sLockerEndDay := '';

    JsonText := Send_API(mtGet, 'K301_Member?store_cd=' + Global.Config.Store.StoreCode + '&photo_yn=Y' + '&member_no=' + ACardNo, EmptyStr);

    if JsonText = EmptyStr then
      Exit;

    Log.D('GetMemberInfo JsonText', LogReplace(JsonText));

    JsonValue := MainJson.ParseJSONValue(JsonText);

    if (JsonValue as TJSONObject).Get('result_cd').JsonValue.Value = '0000' then
    begin
      if MainJson.ParseJSONValue(JsonText).FindValue('result_data') is TJSONNull then
        Exit;

      if ((JsonValue as TJSONObject).Get('result_data').JsonValue as TJSONArray).Count = 0 then
        Exit;

      JsonValue := ((MainJson.ParseJSONValue(JsonText) as TJSONObject).Get('result_data').JsonValue as TJSONArray).Items[0];
      Result.Code := (JsonValue as TJSONObject).Get('member_no').JsonValue.Value;
      Result.CardNo := (JsonValue as TJSONObject).Get('qr_cd').JsonValue.Value;
      Result.Addr1 := (JsonValue as TJSONObject).Get('address').JsonValue.Value;
      Result.Addr2 := (JsonValue as TJSONObject).Get('address_desc').JsonValue.Value;
      Result.Sex := IfThen((JsonValue as TJSONObject).Get('sex_div').JsonValue.Value = '1', 'M', 'W');
      Result.BirthDay := (JsonValue as TJSONObject).Get('birth_ymd').JsonValue.Value;
      Result.Name := (JsonValue as TJSONObject).Get('member_nm').JsonValue.Value;
      Result.Tel_Mobile := (JsonValue as TJSONObject).Get('hp_no').JsonValue.Value;

      //2020-12-29 라카만료일
      if not (JsonValue.FindValue('locker') is TJSONNull) then
      begin
        JsonListValue := (JsonValue as TJSONObject).Get('locker').JsonValue;
        for Index := 0 to (JsonListValue as TJSONArray).Count - 1 do
        begin
          if Index <> 0 then
            sLockerEndDay := sLockerEndDay + ' ';

          sLockerEndDay := sLockerEndDay + ((JsonListValue as TJSONArray).Items[Index] as TJSONObject).Get('end_day').JsonValue.Value;
        end;
      end;

      Global.SaleModule.FLockerEndDay := sLockerEndDay;

    end;
  finally
    FreeAndNil(MainJson);
    FreeAndNil(JsonValue);
    FreeAndNil(JsonListValue);
  end;
end;

function TASPDatabase.GetMemberProductList(ACardNo, ACode, ADate: string): TList<TProductInfo>;
var
  Index, Loop, Cnt, ProductUseCnt: Integer;
  MainJson: TJSONObject;
  JsonValue, ItemValue, JsonListValue: TJSONValue;
  JsonText, NowDay, NowTime: string;
  AProduct: TProductInfo;
  AProductList: TList<TProductInfo>;
  sUseStatus: string;
begin
  try
    Result := TList<TProductInfo>.Create;
    AProductList := TList<TProductInfo>.Create;

    NowDay := EmptyStr;
    NowTime := EmptyStr;

    MainJson := TJSONObject.Create;
    JsonValue := TJSONValue.Create;
    JsonListValue := TJSONValue.Create;

//    JsonText := Send_API(mtGet, 'K306_GetMemberTeeBoxProduct?Store_cd=' + Global.Config.Store.StoreCode + '&member_no=' + ACardNo, EmptyStr);
    JsonText := Send_API(mtGet, 'K306_GetMemberTeeBoxProduct?member_no=' + ACardNo +
                                                           '&store_cd=' + Global.Config.Store.StoreCode, EmptyStr);

    if JsonText = EmptyStr then
      Exit;

    Log.D('GetMemberProductList JsonText', LogReplace(JsonText));

    JsonValue := MainJson.ParseJSONValue(JsonText);

    if (JsonValue as TJSONObject).Get('result_cd').JsonValue.Value = '0000' then
    begin
      if MainJson.ParseJSONValue(JsonText).FindValue('result_data') is TJSONNull then
        Exit;

      JsonValue := (JsonValue as TJSONObject).Get('result_data').JsonValue;
      for Index := 0 to (JsonValue as TJSONArray).Count - 1 do
      begin
        ItemValue := (JsonValue as TJSONArray).Items[Index];

        AProduct.Code := (ItemValue as TJSONObject).Get('product_cd').JsonValue.Value;
        AProduct.Name := (ItemValue as TJSONObject).Get('product_nm').JsonValue.Value;
        AProduct.ProductBuyCode := (ItemValue as TJSONObject).Get('purchase_cd').JsonValue.Value;
        AProduct.StartDate := (ItemValue as TJSONObject).Get('start_day').JsonValue.Value;
        AProduct.EndDate := (ItemValue as TJSONObject).Get('end_day').JsonValue.Value;
        AProduct.Use_Qty := StrToIntDef((ItemValue as TJSONObject).Get('coupon_cnt').JsonValue.Value, 0);
        AProduct.Product_Div := (ItemValue as TJSONObject).Get('product_div').JsonValue.Value;

        AProduct.Start_Time := StringReplace((ItemValue as TJSONObject).Get('day_start_time').JsonValue.Value, ':', '', [rfReplaceAll]);
        AProduct.End_Time := StringReplace((ItemValue as TJSONObject).Get('day_end_time').JsonValue.Value, ':', '', [rfReplaceAll]);

        if AProduct.Product_Div = PRODUCT_TYPE_C then
          AProduct.Use := ((ItemValue as TJSONObject).Get('today_yn').JsonValue.Value = 'Y') and (AProduct.Use_Qty <> 0)
        else
          AProduct.Use := ((ItemValue as TJSONObject).Get('today_yn').JsonValue.Value = 'Y');

        AProduct.One_Use_Time := (ItemValue as TJSONObject).Get('one_use_time').JsonValue.Value;

        NowDay := FormatDateTime('yyyymmdd', now);
        NowTime := FormatDateTime('hhnn', now);

        sUseStatus := (ItemValue as TJSONObject).Get('use_status').JsonValue.Value;
        if AProduct.Use then
          AProduct.Use := (sUseStatus = '1');

        if AProduct.Use then
          AProduct.Use := (NowDay >= AProduct.StartDate) and (NowDay <= AProduct.EndDate);

        if AProduct.Use then
          AProduct.Use := (NowTime >= AProduct.Start_Time) and (NowTime <= AProduct.End_Time);

        if AProduct.Use then
          AProductList.Add(AProduct);
      end;

      if AProductList.Count <> 0 then
      begin
        for Index := 0 to AProductList.Count - 1 do
        begin
          if AProductList[Index].Product_Div = 'R' then
            Result.Add(AProductList[Index]);
        end;

        for Index := 0 to AProductList.Count - 1 do
        begin
          if AProductList[Index].Product_Div = 'C' then
            Result.Add(AProductList[Index]);
        end;
      end;
    end;
  finally
    FreeAndNil(MainJson);;
    FreeAndNil(JsonValue);
    FreeAndNil(AProductList);
  end;
end;

function TASPDatabase.GetStoreInfo: Boolean;
var
  Index: Integer;
  MainJson: TJSONObject;
  JsonValue: TJSONValue;
  JsonText: string;
begin
  try
    Result := False;
    MainJson := TJSONObject.Create;

    JsonText := Send_API(mtGet, 'K203_StoreInfo?store_cd=' + Global.Config.Store.StoreCode, EmptyStr, True);

    if JsonText = EmptyStr then
      Exit;

    JsonValue := MainJson.ParseJSONValue(JsonText);

    if '0000' = (JsonValue as TJSONObject).Get('result_cd').JsonValue.Value then
    begin
      if JsonValue.FindValue('result_data') is TJSONNull then
        Exit;

      JsonValue := (JsonValue as TJSONObject).Get('result_data').JsonValue;

      Global.Config.Store.StoreName := (JsonValue as TJSONObject).Get('store_nm').JsonValue.Value;
      Global.Config.Store.BossName := (JsonValue as TJSONObject).Get('owner_nm').JsonValue.Value;
      Global.Config.Store.Tel := (JsonValue as TJSONObject).Get('tel_no').JsonValue.Value;
      Global.Config.Store.Addr := (JsonValue as TJSONObject).Get('address').JsonValue.Value +
                                    (JsonValue as TJSONObject).Get('address_desc').JsonValue.Value;
      Global.Config.Store.StoreStartTime := (JsonValue as TJSONObject).Get('start_time').JsonValue.Value;
      Global.Config.Store.StoreEndTime := (JsonValue as TJSONObject).Get('end_time').JsonValue.Value;
      Global.Config.Store.StoreCloseStartTime := (JsonValue as TJSONObject).Get('close_start_date').JsonValue.Value;
      SetServerLocalTime((JsonValue as TJSONObject).Get('server_time').JsonValue.Value);

      if Global.Config.Store.StoreCloseStartTime = 'null' then
        Global.Config.Store.StoreCloseStartTime := EmptyStr;

      Global.Config.Store.StoreCloseEndTime := (JsonValue as TJSONObject).Get('close_end_date').JsonValue.Value;
      if Global.Config.Store.StoreCloseEndTime = 'null' then
        Global.Config.Store.StoreCloseEndTime := EmptyStr;
    end;

    Result := True;
    Global.Config.SaveLocalConfig;
  finally
    FreeAndNil(MainJson);
    FreeAndNil(JsonValue);
  end;
end;

function TASPDatabase.GetTeeBoxMasterVersion: string;
begin
  Result := GetVersion('K203_TeeBoxVersion?store_cd=' + Global.Config.Store.StoreCode);
  if Result = EmptyStr then
    Result := Global.Config.Version.TeeBoxMasterVersion;
end;

function TASPDatabase.GetTeeBoxMaster: TList<TTeeBoxInfo>;
var
  Index: Integer;
  ATeeBoxInfo: TTeeBoxInfo;
  MainJson: TJSONObject;
  JsonValue, ItemValue: TJSONValue;
  JsonText, AVersion: string;
begin
  try
    Result := TList<TTeeBoxInfo>.Create;
    MainJson := TJSONObject.Create;
    JsonValue := TJSONValue.Create;

    JsonText := Send_API(mtGet, 'K204_TeeBoxlist?store_cd=' + Global.Config.Store.StoreCode, EmptyStr);

//    Log.D('타석 마스터', JsonText);

    if JsonText = EmptyStr then
      Exit;

    JsonValue := MainJson.ParseJSONValue(JsonText);

    if '0000' = (JsonValue as TJSONObject).Get('result_cd').JsonValue.Value then
    begin
      if JsonValue.FindValue('result_data') is TJSONNull then
        Exit;

      JsonValue := (JsonValue as TJSONObject).Get('result_data').JsonValue;

      for Index := 0 to (JsonValue as TJSONArray).Count - 1 do
      begin
        ItemValue := (JsonValue as TJSONArray).Items[Index];
        ATeeBoxInfo.Mno := (ItemValue as TJSONObject).Get('teebox_nm').JsonValue.Value;
        ATeeBoxInfo.TasukNo := StrToIntDef((ItemValue as TJSONObject).Get('teebox_no').JsonValue.Value, 0);
        ATeeBoxInfo.High := StrToIntDef((ItemValue as TJSONObject).Get('floor_cd').JsonValue.Value, 0);

        // 2020-11-04 층명칭
        ATeeBoxInfo.FloorNm := (ItemValue as TJSONObject).Get('floor_nm').JsonValue.Value;

        ATeeBoxInfo.Vip := (ItemValue as TJSONObject).Get('vip_yn').JsonValue.Value = 'Y';
        ATeeBoxInfo.ZoneCode := (ItemValue as TJSONObject).Get('zone_div').JsonValue.Value;

        //2020-12-17 빅토리아
        //ATeeBoxInfo.ControlYn := (ItemValue as TJSONObject).Get('control_yn').JsonValue.Value;

        ATeeBoxInfo.Use := (ItemValue as TJSONObject).Get('use_yn').JsonValue.Value = 'Y';
        ATeeBoxInfo.DelYn := (ItemValue as TJSONObject).Get('del_yn').JsonValue.Value = 'Y';
        ATeeBoxInfo.ERR := 0;
        ATeeBoxInfo.Hold := False;
        ATeeBoxInfo.Add_OK := False;
        ATeeBoxInfo.IsAddList := False;

        Result.Add(ATeeBoxInfo);
      end;
    end;
  finally
    FreeAndNil(MainJson);
    FreeAndNil(JsonValue);
  end;
end;
{
function TASPDatabase.GetTeeBoxPlayingInfo: TList<TTeeBoxInfo>;
var
  Index: Integer;
  ATeeBoxInfo: TTeeBoxInfo;
  MainJson: TJSONObject;
  JsonValue, ItemValue: TJSONValue;
  JsonText: string;
begin
  try
    try
      for Index := Global.TeeBox.UpdateTeeBoxList.Count - 1 downto 0 do
        Global.TeeBox.UpdateTeeBoxList.Delete(Index);
      Global.TeeBox.UpdateTeeBoxList.Clear;
      MainJson := TJSONObject.Create;
      JsonValue := TJSONValue.Create;

      JsonText := Send_API(mtGet, 'K402_TeeBoxStatus?store_cd=' + Global.Config.Store.StoreCode, EmptyStr, True);

//      Log.D('가동상황', JsonText);

      if JsonText = EmptyStr then
        Exit;

      JsonValue := MainJson.ParseJSONValue(JsonText);

      if '0000' = (JsonValue as TJSONObject).Get('result_cd').JsonValue.Value then
      begin
        if JsonValue.FindValue('result_data') is TJSONNull then
          Exit;

        JsonValue := (JsonValue as TJSONObject).Get('result_data').JsonValue;

        for Index := 0 to (JsonValue as TJSONArray).Count - 1 do
        begin
          ItemValue := (JsonValue as TJSONArray).Items[Index];
          ATeeBoxInfo.Mno := (ItemValue as TJSONObject).Get('teebox_nm').JsonValue.Value;
          ATeeBoxInfo.TasukNo := StrToIntDef((ItemValue as TJSONObject).Get('teebox_no').JsonValue.Value, 0);
          ATeeBoxInfo.High := StrToIntDef((ItemValue as TJSONObject).Get('floor_cd').JsonValue.Value, 0);
          ATeeBoxInfo.Vip := (ItemValue as TJSONObject).Get('vip_yn').JsonValue.Value = 'Y';
          ATeeBoxInfo.ZoneCode := (ItemValue as TJSONObject).Get('zone_div').JsonValue.Value;
          ATeeBoxInfo.Use := (ItemValue as TJSONObject).Get('use_yn').JsonValue.Value = 'Y';
          ATeeBoxInfo.Ma_Time := (ItemValue as TJSONObject).Get('remain_min').JsonValue.Value;
          ATeeBoxInfo.End_Time := Copy(StringReplace(Trim((ItemValue as TJSONObject).Get('end_datetime').JsonValue.Value), '-', '', [rfReplaceAll]), 10, 5);
          ATeeBoxInfo.End_DT := Copy(StringReplace(Trim((ItemValue as TJSONObject).Get('end_datetime').JsonValue.Value), '-', '', [rfReplaceAll]), 10, 5);
          ATeeBoxInfo.ERR := StrToIntDef((ItemValue as TJSONObject).Get('use_status').JsonValue.Value, 0);
          ATeeBoxInfo.Hold := False;

          if ATeeBoxInfo.ERR in [0, 1, 3, 4] then
            ATeeBoxInfo.ERR := 0;

          if StrToIntDef((ItemValue as TJSONObject).Get('use_status').JsonValue.Value, 0) = 3 then
            ATeeBoxInfo.Hold := True;

          ATeeBoxInfo.Add_OK := False;
          ATeeBoxInfo.IsAddList := False;
          ATeeBoxInfo.BtweenTime := StrToIntDef((ItemValue as TJSONObject).Get('remain_min').JsonValue.Value, 0);

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
    FreeAndNil(JsonValue);
  end;
end;
}
function TASPDatabase.GetTeeBoxProductListVersion: string;
begin
  Result := GetVersion('K205_TeeBoxProductVersion?store_cd=' + Global.Config.Store.StoreCode);
  if Result = EmptyStr then
    Result := Global.Config.Version.ProductVersion;
end;

function TASPDatabase.GetTeeBoxProductList: TList<TProductInfo>;
var
  Index, WeekUse: Integer;
  MainJson: TJSONObject;
  AProduct: TProductInfo;
  JsonValue, ItemValue: TJSONValue;
  JsonText, AVersion: string;
  nCnt: Integer;
begin
  try
    Result := TList<TProductInfo>.Create;
    MainJson := TJSONObject.Create;
    JsonValue := TJSONValue.Create;

    JsonText := Send_API(mtGet, 'K206_TeeBoxProductlist?store_cd=' + Global.Config.Store.StoreCode, EmptyStr);

    if JsonText = EmptyStr then
      Exit;

    //Log.D('상품 마스터', JsonText);

    JsonValue := MainJson.ParseJSONValue(JsonText);


    if '0000' = (JsonValue as TJSONObject).Get('result_cd').JsonValue.Value then
    begin
      if JsonValue.FindValue('result_data') is TJSONNull then
        Exit;

      JsonValue := (JsonValue as TJSONObject).Get('result_data').JsonValue;

      nCnt := (JsonValue as TJSONArray).Count;
      for Index := 0 to (JsonValue as TJSONArray).Count - 1 do
      begin
        ItemValue := (JsonValue as TJSONArray).Items[Index];

        if (ItemValue as TJSONObject).Get('del_yn').JsonValue.Value = 'Y' then
          Continue;

        AProduct.Code := (ItemValue as TJSONObject).Get('product_cd').JsonValue.Value;
        AProduct.ZoneCode := (ItemValue as TJSONObject).Get('zone_cd').JsonValue.Value;
        AProduct.Name := (ItemValue as TJSONObject).Get('product_nm').JsonValue.Value;
        AProduct.TypeName := (ItemValue as TJSONObject).Get('product_nm').JsonValue.Value;
        AProduct.Price := StrToIntDef((ItemValue as TJSONObject).Get('product_amt').JsonValue.Value, 0);
        AProduct.Use :=(ItemValue as TJSONObject).Get('use_yn').JsonValue.Value = 'Y';
        AProduct.Yoday_Use := (ItemValue as TJSONObject).Get('today_yn').JsonValue.Value = 'Y';
        AProduct.One_Use_Time := (ItemValue as TJSONObject).Get('one_use_time').JsonValue.Value;
        AProduct.Sex := (ItemValue as TJSONObject).Get('sex').JsonValue.Value;
        AProduct.UseWeek := (ItemValue as TJSONObject).Get('use_div').JsonValue.Value;
        AProduct.Start_Time := (ItemValue as TJSONObject).Get('start_time').JsonValue.Value;
        AProduct.End_Time := (ItemValue as TJSONObject).Get('end_time').JsonValue.Value;
        AProduct.Product_Div := (ItemValue as TJSONObject).Get('product_div').JsonValue.Value;
        AProduct.Member_Product_Yn := (ItemValue as TJSONObject).Get('member_product_yn').JsonValue.Value;
        AProduct.xgolf_dc_yn := (ItemValue as TJSONObject).Get('xgolf_dc_yn').JsonValue.Value = 'Y';
        AProduct.xgolf_dc_amt := StrToIntDef((ItemValue as TJSONObject).Get('xgolf_dc_amt').JsonValue.Value, 0);
        AProduct.xgolf_product_amt := StrToIntDef((ItemValue as TJSONObject).Get('xgolf_product_amt').JsonValue.Value, 0);
        AProduct.UseMonth := (ItemValue as TJSONObject).Get('use_month').JsonValue.Value;
        AProduct.Use_Qty := StrToIntDef((ItemValue as TJSONObject).Get('use_cnt').JsonValue.Value, 0);
        AProduct.Memo := (ItemValue as TJSONObject).Get('memo').JsonValue.Value;

        WeekUse := DayOfWeek(Now);

        if (Pos('일일', AProduct.Name) > 0) and (AProduct.Memo = 'KIOSK') then
        begin
          WeekUse := WeekUse;
        end;

        if WeekUse = 1 then
          WeekUse := 7
        else
          WeekUse := WeekUse - 1;

        // kiosk 노출여부
        if (ItemValue as TJSONObject).Get('kiosk_view_yn').JsonValue.Value <> 'Y' then
          AProduct.Use := False;

        if AProduct.Use and AProduct.Yoday_Use then
          Result.Add(AProduct);
      end;
    end;
  finally
    FreeAndNil(MainJson);
    FreeAndNil(JsonValue);
  end;
end;

function TASPDatabase.GetTeeBoxDayProductList: TList<TProductInfo>;
var
  Index: Integer;
  MainJson: TJSONObject;
  AProduct: TProductInfo;
  JsonValue, ItemValue: TJSONValue;
  JsonText: string;
begin
  try
    Result := TList<TProductInfo>.Create;

    MainJson := TJSONObject.Create;
    JsonValue := TJSONValue.Create;

    JsonText := Send_API(mtGet, '추가필요?store_cd=' + Global.Config.Store.StoreCode, EmptyStr);

    if JsonText = EmptyStr then
      Exit;

    JsonValue := MainJson.ParseJSONValue(JsonText);

    if '0000' = (JsonValue as TJSONObject).Get('result_cd').JsonValue.Value then
    begin
      if JsonValue.FindValue('result_data') is TJSONNull then
        Exit;

      JsonValue := (JsonValue as TJSONObject).Get('result_data').JsonValue;

      for Index := 0 to (JsonValue as TJSONArray).Count - 1 do
      begin
        ItemValue := (JsonValue as TJSONArray).Items[Index];
        AProduct.Code := (ItemValue as TJSONObject).Get('product_cd').JsonValue.Value;
        AProduct.Name := (ItemValue as TJSONObject).Get('product_nm').JsonValue.Value;
        AProduct.TypeName := (ItemValue as TJSONObject).Get('product_nm').JsonValue.Value;
        AProduct.Price := StrToIntDef((ItemValue as TJSONObject).Get('product_amt').JsonValue.Value, 0);
        AProduct.Use := (ItemValue as TJSONObject).Get('use_yn').JsonValue.Value = 'Y';
        AProduct.One_Use_Time := (ItemValue as TJSONObject).Get('one_use_time').JsonValue.Value;
        AProduct.Sex := (ItemValue as TJSONObject).Get('sex').JsonValue.Value;
        Result.Add(AProduct)
      end;
    end;
  finally
    FreeAndNil(MainJson);
    FreeAndNil(JsonValue);
  end;
end;

function TASPDatabase.OAuth_Certification: Boolean;
var
  Indy: TIdHTTP;
  SendData, RecvData: TStringStream;
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
    Log.D('OAuth_Certification', UTF8Str);
    Indy.Post(Global.Config.OAuthURl, SendData, RecvData);

    Global.Config.OAuth.Token := (TJSONObject.ParseJSONValue(ByteStringToString(RecvData)) as TJSONObject).Get('access_token').JsonValue.Value;
    Log.D('OAuth_Certification', Global.Config.OAuth.Token);
  finally
    Indy.Free;
    SendData.Free;
    RecvData.Free;
  end;
end;

function TASPDatabase.TeeBoxHold(AIsHold: Boolean): Boolean;
{
var
  MainJson: TJSONObject;
  JsonValue: TJSONValue;
  AUrl, AStore_CD, TeeBox_No, User_Id: AnsiString;
  JsonText: string;
}
begin
  //if Global.Config.AD.USE then
  //begin
    Result := Global.LocalApi.TeeboxHold(AIsHold);
  {
  end
  else
  begin
    try
      try
        Result := False;

        MainJson := TJSONObject.Create;
        JsonValue := TJSONValue.Create;

        AStore_CD := Global.Config.Store.StoreCode;
        TeeBox_No := IntToStr(Global.SaleModule.TeeBoxInfo.TasukNo);
        User_Id := Global.Config.Store.UserID;

        AUrl := '?store_cd=' + AStore_CD + '&teebox_no=' + TeeBox_No + '&user_id=' + User_Id;

        if AIsHold then
          JsonText := Send_API(mtPost, 'K405_TeeBoxHold' + AUrl, EmptyStr)
        else
          JsonText := Send_API(mtDelete, 'K406_TeeBoxHold' + AUrl, EmptyStr);

        Log.D('K406_TeeBoxHold', LogReplace(JsonText));

        JsonValue := MainJson.ParseJSONValue(JsonText);

        if (JsonValue as TJSONObject).Get('result_cd').JsonValue.Value = '0000' then
          Result := True
        else if (JsonValue as TJSONObject).Get('result_cd').JsonValue.Value = 'Z09A' then
          Global.SBMessage.ShowMessageModalForm((JsonValue as TJSONObject).Get('result_msg').JsonValue.Value);
      except
        on E: Exception do
        begin
          Log.E('TeeBoxHold', '-pass-');
        end;
      end;
    finally
      FreeAndNil(MainJson);
      FreeAndNil(JsonValue);
    end;
  end;
  }
end;

function TASPDatabase.TeeBoxListReservation: Boolean;
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
      MainJson.AddPair(TJSONPair.Create('receipt_no', Global.SaleModule.RcpAspNo));
      MainJson.AddPair(TJSONPair.Create('affiliate_cd', Global.SaleModule.allianceCode));

      ItemJson := TJSONObject.Create;
      ItemJson.AddPair(TJSONPair.Create('assign_balls', '9999'));

      //매장종료시간초과시 배정시간 변경
      if Global.SaleModule.FStoreCloseOver = True then
        ItemJson.AddPair(TJSONPair.Create('assign_min', Global.SaleModule.FStoreCloseOverMin))
      else
        ItemJson.AddPair(TJSONPair.Create('assign_min', Global.SaleModule.SelectProduct.One_Use_Time));

      ItemJson.AddPair(TJSONPair.Create('prepare_min', IfThen(StrToIntDef(Global.Config.PrePare_Min, 5) <> Global.SaleModule.PrepareMin,
                                                                IntToStr(Global.SaleModule.PrepareMin), Global.Config.PrePare_Min)));
      ItemJson.AddPair(TJSONPair.Create('product_cd', Global.SaleModule.SelectProduct.Code));
      ItemJson.AddPair(TJSONPair.Create('purchase_cd', Global.SaleModule.SelectProduct.ProductBuyCode));
      ItemJson.AddPair(TJSONPair.Create('teebox_no', IntToStr(Global.SaleModule.TeeBoxInfo.TasukNo)));

      //if Global.Config.AD.USE then
      begin
        ItemJson.AddPair(TJSONPair.Create('product_nm', Global.SaleModule.SelectProduct.Name));
        ItemJson.AddPair(TJSONPair.Create('reserve_div', Global.SaleModule.SelectProduct.Product_Div));
      end;

      JsonList.Add(ItemJson);

      //if Global.Config.AD.USE then
      begin
        MainJson.AddPair(TJSONPair.Create('api', 'K408_TeeBoxReserve2'));
        MainJson.AddPair(TJSONPair.Create('member_nm', Global.SaleModule.Member.Name));

        ReReserve :

        Log.D('Local TeeBoxReservation2', LogReplace(MainJson.ToString));
        WriteLog(False, 'ApiLog', Global.SaleModule.SaleDate, 'Local TeeBoxReservation2', LogReplace(MainJson.ToString));
        JsonText := Global.LocalApi.TeeBoxListReservation(MainJson.ToString);
        WriteLog(False, 'ApiLog', Global.SaleModule.SaleDate, 'Local TeeBoxReservation2', LogReplace(JsonText));
        Log.D('Local TeeBoxReservation2', LogReplace(JsonText));
      end;
      {else
      begin
        Log.D('TeeBoxReservation2', LogReplace(MainJson.ToString));
        WriteLog(False, 'ApiLog', Global.SaleModule.SaleDate, 'TeeBoxReservation2', LogReplace(MainJson.ToString));
        JsonText := Send_API_Reservation(mtPost, 'K408_TeeBoxReserve2', MainJson.ToString);
        WriteLog(False, 'ApiLog', Global.SaleModule.SaleDate, 'TeeBoxReservation2', LogReplace(JsonText));
        Log.D('TeeBoxReservation2', LogReplace(JsonText));
      end;}

      if JsonText <> EmptyStr then
      begin
        JsonValue := MainJson.ParseJSONValue(JsonText);

        if (JsonValue as TJSONObject).Get('result_cd').JsonValue.Value = '0000' then
        begin
          Result := True;

          //if not (JsonValue.FindValue(Ifthen(Global.Config.AD.USE, 'data', 'result_data')) is TJSONNull) then
          if not (JsonValue.FindValue('data') is TJSONNull) then
          begin
            AProductInfo := Global.SaleModule.SelectProduct;
            //JsonValue := (JsonValue as TJSONObject).Get(VarToStr(Ifthen(Global.Config.AD.USE, 'data', 'result_data'))).JsonValue;
            JsonValue := (JsonValue as TJSONObject).Get(VarToStr('data')).JsonValue;
            {
            if not Global.Config.AD.USE then
              JsonValue := (JsonValue as TJSONObject).Get('data').JsonValue;
            }
            JsonValue := (JsonValue as TJSONArray).Items[0];
            {
            if not Global.Config.AD.USE then
            begin
              AProductInfo.Reserve_Time := (JsonValue as TJSONObject).Get('start_time').JsonValue.Value;
              AProductInfo.Start_Time :=
                Copy(StringReplace((JsonValue as TJSONObject).Get('start_time').JsonValue.Value, '-', '', [rfReplaceAll]), 10, 5);
              AProductInfo.One_Use_Time := (JsonValue as TJSONObject).Get('assign_time').JsonValue.Value;
            end
            else  }
            begin
              AProductInfo.Reserve_Time := (JsonValue as TJSONObject).Get('start_datetime').JsonValue.Value;
              AProductInfo.Start_Time :=
                Copy(StringReplace((JsonValue as TJSONObject).Get('start_datetime').JsonValue.Value, '-', '', [rfReplaceAll]), 10, 5);
              AProductInfo.One_Use_Time := (JsonValue as TJSONObject).Get('remain_min').JsonValue.Value;
            end;

            AProductInfo.Use_Qty := StrToIntDef((JsonValue as TJSONObject).Get('coupon_cnt').JsonValue.Value, 0);

            AProductInfo.Reserve_No := (JsonValue as TJSONObject).Get('reserve_no').JsonValue.Value;
            AProductInfo.Reserve_List := EmptyStr;

            //if not (JsonValue.FindValue(Ifthen(Global.Config.AD.USE, 'coupon', 'data')) is TJSONNull) then
            if not (JsonValue.FindValue('coupon') is TJSONNull) then
            begin
              Cnt := 0;
              {if not Global.Config.AD.USE then
                JsonListValue := (JsonValue as TJSONObject).Get('data').JsonValue
              else  }
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
        end        else        begin          //if ((JsonValue as TJSONObject).Get('result_cd').JsonValue.Value = '0002') and Global.Config.AD.USE then          if ((JsonValue as TJSONObject).Get('result_cd').JsonValue.Value = '0002') then          begin            goto ReReserve;
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

function TASPDatabase.GetAdvertisVersion: string;
begin
  Result := GetVersion('K233_AdvertiseVersion?store_cd=' + Global.Config.Store.StoreCode);
  if Result = EmptyStr then
    Result := Global.Config.Version.AdvertisVersion;
end;

procedure TASPDatabase.SearchAdvertisList;
var
//  Indy: TIdHTTP;
  MainJson: TJSONObject;
  JsonValue, ItemValue: TJSONValue;
  AUrl, FileExtract, FileName: string;
  JsonText: AnsiString;
  Loop: Integer;
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
      MainJson := TJSONObject.Create;
      JsonValue := TJSONValue.Create;
      ListUp := TList<TAdvertisement>.Create;
      ListDown := TList<TAdvertisement>.Create;

      AUrl := '?store_cd=' + Global.Config.Store.StoreCode;

      JsonText := Send_API(mtGet, 'K231_AdvertiseList' + AUrl, EmptyStr);

      JsonValue := MainJson.ParseJSONValue(JsonText);

      if (JsonValue as TJSONObject).Get('result_cd').JsonValue.Value = '0000' then
      begin
        if not (JsonValue.FindValue('result_data') is TJSONNull) then
        begin
          JsonValue := (JsonValue as TJSONObject).Get('result_data').JsonValue;

          for Loop := 0 to (JsonValue as TJSONArray).Count - 1 do
          begin
            ItemValue := (JsonValue as TJSONArray).Items[Loop];

            if (ItemValue as TJSONObject).Get('del_yn').JsonValue.Value = 'Y' then
              Continue;

            AIndy := TIdHTTP.Create(nil);
            AIndy.IOHandler := sslIOHandler;
            mStream := TMemoryStream.Create;
            //ItemValue := (JsonValue as TJSONArray).Items[Loop];

             StrToIntDef((ItemValue as TJSONObject).Get('ad_seq').JsonValue.Value, 0);

            AAdvertise.Seq := StrToIntDef((ItemValue as TJSONObject).Get('ad_seq').JsonValue.Value, 0);
            AAdvertise.FileUrl := (ItemValue as TJSONObject).Get('file_url').JsonValue.Value;
            AAdvertise.Position := (ItemValue as TJSONObject).Get('position_div').JsonValue.Value;
            AAdvertise.StartDate := (ItemValue as TJSONObject).Get('open_start_day').JsonValue.Value;
            AAdvertise.EndDate := (ItemValue as TJSONObject).Get('open_end_day').JsonValue.Value;
            AAdvertise.Show_Week := (ItemValue as TJSONObject).Get('open_week_div').JsonValue.Value;
            AAdvertise.Show_Start_Time := (ItemValue as TJSONObject).Get('open_start_time').JsonValue.Value;
            AAdvertise.Show_End_Time := (ItemValue as TJSONObject).Get('open_end_time').JsonValue.Value;
            AAdvertise.Show_Interval := (ItemValue as TJSONObject).Get('open_second').JsonValue.Value;
            AAdvertise.Show_YN := (ItemValue as TJSONObject).Get('open_yn').JsonValue.Value = 'Y';

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
                FileName := StringReplace(AAdvertise.FileUrl, Global.Config.FileUrl, '', [rfReplaceAll]);

                AIndy.Get(AAdvertise.FileUrl, mStream);

                if (FileExtract = '.avi') or (FileExtract = '.mp4') then
                  AAdvertise.FilePath := ExtractFilePath(ParamStr(0)) + '\Intro\Media\' + (ItemValue as TJSONObject).Get('upload_nm').JsonValue.Value
                else
                  AAdvertise.FilePath := ExtractFilePath(ParamStr(0)) + '\Intro\' + (ItemValue as TJSONObject).Get('upload_nm').JsonValue.Value;

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
    FreeAndNil(JsonValue);
  end;
end;

function TASPDatabase.SearchPromotion(ACoupon: string): Boolean;
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
          ADisCount.Use := IfThen(((JsonValue as TJSONObject).Get('result_data').JsonValue as TJSONObject).Get('use_yn').JsonValue.Value <> 'Y', True, False);
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
        // bc페이북골프
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
    FreeAndNil(MainJson);
    FreeAndNil(JsonValue);
  end;
end;

function TASPDatabase.CouponError(ACode: string): string;
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
  // bc페이북골프
  else if ACode = 'P04F' then
    //Result := '발급이 취소된 쿠폰 입니다.'
    Result := '사용하실 수 없는 QR코드 입니다.'
  else
    Result := '알수 없는 오류코드(' + ACode + ')';
end;

function TASPDatabase.SendAdvertisCnt(ASeq: string): Boolean;
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

function TASPDatabase.SendAdvertisList: Boolean;
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

function TASPDatabase.Send_API(MethodType: TMethodType; AUrl, AJsonText: string; NotSaveLog: Boolean): AnsiString;
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
      Indy.URL.URI := Global.Config.URL;
      Indy.Request.CustomHeaders.Values['Authorization'] := 'Bearer ' + Global.Config.OAuth.Token;

      if AJsonText <> EmptyStr then
      begin
        Indy.Request.ContentType := 'application/json';
        Indy.Request.Accept := '*/*';
        SendData := TStringStream.Create(AJsonText, TEncoding.UTF8);
      end
      else
        Indy.Request.ContentType := 'application/x-www-form-urlencoded';

//      Indy.ConnectTimeout := 5000;
//      Indy.ReadTimeout := 5000;

      if MethodType = mtGet then
        Indy.Get(Global.Config.URL + AUrl, RecvData)
      else if MethodType = mtPost then
      begin
        Indy.Post(Global.Config.URL + AUrl, SendData, RecvData);
      end
      else if MethodType = mtDelete then
        Indy.Delete(Global.Config.URL + AUrl, RecvData);

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

function TASPDatabase.Send_API_Reservation(MethodType: TMethodType; AUrl,
  AJsonText: string; NotSaveLog: Boolean): AnsiString;
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
      AIndy.URL.URI := Global.Config.URL;
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
        AIndy.Get(Global.Config.URL + AUrl, RecvData)
      else if MethodType = mtPost then
      begin
        AIndy.Post(Global.Config.URL + AUrl, SendData, RecvData);
      end
      else if MethodType = mtDelete then
        AIndy.Delete(Global.Config.URL + AUrl, RecvData);

      Result := ByteStringToString(RecvData);
      if not NotSaveLog then
        Log.D('Send_API_Reservation', 'End');
    except
      on E: Exception do
      begin
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

function TASPDatabase.GetVersion(AUrl: string): string;
var
  MainJson: TJSONObject;
  JsonValue: TJSONValue;
  JsonText: string;
begin
  try
    try
      Result := EmptyStr;
      MainJson := TJSONObject.Create;
      JsonText := Send_API(mtGet, AUrl, EmptyStr);

      if JsonText = EmptyStr then
        Exit;

      JsonValue := MainJson.ParseJSONValue(JsonText);
      if (JsonValue as TJSONObject).Get('result_cd').JsonValue.Value = '0000' then
      begin
        if not ((JsonValue as TJSONObject).Get('result_data').JsonValue is TJSONNull) then
          Result := ((JsonValue as TJSONObject).Get('result_data').JsonValue as TJSONObject).Get('version_no').JsonValue.Value;
      end;
    except
      on E: Exception do
      begin
        Log.E('GetVersion', AUrl);
        Log.E('GetVersion', E.Message);
      end;
    end;
  finally
    MainJson.Free;;
    JsonValue.Free;
  end;
end;

function TASPDatabase.TeeBoxReservation: Boolean;
var
  Index: Integer;
  MainJson: TJSONObject;
  JsonValue, JsonListValue: TJSONValue;
  AUrl, Balls, Assign_Min, Member_No, Prepare_min, Product_cd,
  Purchase_cd, Receipt_No, Store_cd, TeeBox_No, User_id: AnsiString;
  AProductInfo: TProductInfo;
  JsonText, RcpNo: string;
begin
  try
    try
      Result := False;

      MainJson := TJSONObject.Create;
      JsonValue := TJSONValue.Create;
      JsonListValue := TJSONValue.Create;

      RcpNo := Global.SaleModule.RcpAspNo;
      Balls := '9999';
      Assign_Min := Global.SaleModule.SelectProduct.One_Use_Time;
      Member_No := Global.SaleModule.Member.Code;
      Prepare_min := Global.Config.PrePare_Min;
      Product_cd := Global.SaleModule.SelectProduct.Code;
      Purchase_cd :=Global.SaleModule.SelectProduct.ProductBuyCode;
      Receipt_No := RcpNo;
      Store_cd := Global.Config.Store.StoreCode;
      TeeBox_No := IntToStr(Global.SaleModule.TeeBoxInfo.TasukNo);
      User_id := Global.Config.Store.UserID;

      AUrl := '?assign_balls=' + Balls +
              '&assign_min=' + Assign_Min +
              '&member_no=' + Member_No +
              '&prepare_min=' + Prepare_min +
              '&product_cd=' + Product_cd +
              '&purchase_cd=' + Purchase_cd +
              '&receipt_no=' + Receipt_No +
              '&store_cd=' + Store_cd +
              '&teebox_no=' + TeeBox_No +
              '&user_id=' + User_id;
      Log.D('TeeBoxReservation', 'K408_TeeBoxReserve' + AUrl);

      JsonText := Send_API(mtPost, 'K408_TeeBoxReserve' + AUrl, EmptyStr);

      JsonValue := MainJson.ParseJSONValue(JsonText);
      Log.D('TeeBoxReservation', LogReplace(JsonText));

      if (JsonValue as TJSONObject).Get('result_cd').JsonValue.Value = '0000' then
      begin
        Result := True;

        if not (JsonValue.FindValue('result_data') is TJSONNull) then
        begin
          AProductInfo := Global.SaleModule.SelectProduct;
          JsonValue := (JsonValue as TJSONObject).Get('result_data').JsonValue;

          AProductInfo.Start_Time :=
            Copy(StringReplace((JsonValue as TJSONObject).Get('start_datetime').JsonValue.Value, '-', '', [rfReplaceAll]), 10, 5);
          AProductInfo.End_Time :=
            Copy(StringReplace((JsonValue as TJSONObject).Get('end_datetime').JsonValue.Value, '-', '', [rfReplaceAll]), 10, 5);
          AProductInfo.One_Use_Time := (JsonValue as TJSONObject).Get('assign_min').JsonValue.Value;
          AProductInfo.Use_Qty := StrToIntDef((JsonValue as TJSONObject).Get('coupon_cnt').JsonValue.Value, 0);
          AProductInfo.Reserve_No := (JsonValue as TJSONObject).Get('reserve_no').JsonValue.Value;
          AProductInfo.Reserve_List := EmptyStr;

          if not (JsonValue.FindValue('teeboxUsedItemList') is TJSONNull) then
          begin
            JsonListValue := (JsonValue as TJSONObject).Get('teeboxUsedItemList').JsonValue;
            for Index := 0 to (JsonListValue as TJSONArray).Count - 1 do
            begin
              if Index <> 0 then
                AProductInfo.Reserve_List := AProductInfo.Reserve_List + ' ';

              AProductInfo.Reserve_List := AProductInfo.Reserve_List + Copy(((JsonListValue as TJSONArray).Items[Index] as TJSONObject).Get('start_datetime').JsonValue.Value, 1, 10);
            end;
            AProductInfo.Reserve_List := StringReplace(AProductInfo.Reserve_List, '-', '', [rfReplaceAll]);
          end;
        end;

        Global.SaleModule.SelectProduct := AProductInfo;
      end;
    except
      on E: Exception do
        Log.E('TeeBoxReservation', E.Message);
    end;
  finally
    FreeAndNil(MainJson);
    FreeAndNil(JsonValue);
    FreeAndNil(JsonListValue);
  end;
end;

function TASPDatabase.BunkerReservation: Boolean;
var
  Index: Integer;
  MainJson, jObj: TJSONObject;
  AUrl, Assign_Min, Member_No, Prepare_min, Product_cd: AnsiString;
  Purchase_cd, Receipt_No, Store_cd, User_id: AnsiString;
  sReserveNo, sReserveDatetime, sStartDatetime, sEndDatetime: AnsiString;
  AProductInfo: TProductInfo;
  JsonText, RcpNo: string;
begin
  try
    try
      Result := False;

      //RcpNo := Global.SaleModule.RcpAspNo;
      //Balls := '9999';
      Assign_Min := Global.SaleModule.SelectProduct.One_Use_Time;
      Member_No := Global.SaleModule.Member.Code;
      Prepare_min := Global.Config.PrePare_Min;
      Product_cd := Global.SaleModule.SelectProduct.Code;
      Purchase_cd :=Global.SaleModule.SelectProduct.ProductBuyCode;
      Receipt_No := RcpNo;
      Store_cd := Global.Config.Store.StoreCode;
      //TeeBox_No := IntToStr(Global.SaleModule.TeeBoxInfo.TasukNo);
      User_id := Global.Config.Store.UserID;

      sReserveDatetime := FormatDateTime( 'YYYYMMDDHHNNSS', now);
      sStartDatetime := FormatDateTime( 'YYYYMMDDHHNNSS', IncMinute(now, StrToInt(Prepare_min)) );
      sEndDatetime := FormatDateTime( 'YYYYMMDDHHNNSS', IncMinute(now, StrToInt(Prepare_min) + StrToInt(Assign_Min)) );

      AUrl := '?store_cd=' + Store_cd +
              '&member_no=' + Member_No +
              '&reserve_root_div=K' +
              '&purchase_cd=' + Purchase_cd +
              '&product_cd=' + Product_cd +
              '&reserve_datetime=' + sReserveDatetime +
              '&prepare_min=' + Prepare_min +
              //'&assign_min=' + Assign_Min +
              //'&start_datetime=' + sStartDatetime +
              //'&end_datetime=' + sEndDatetime +
              '&user_id=' + User_id +
              '&memo=';

      //Log.D('BunkerReservation', 'K731_BunkerReserve' + AUrl);

      JsonText := Send_API(mtPost, 'K731_BunkerReserve' + AUrl, EmptyStr);

      MainJson := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;
      Log.D('BunkerReservation', LogReplace(JsonText));

      if MainJson.GetValue('result_cd').Value = '0000' then
      begin
        Result := True;

        AProductInfo := Global.SaleModule.SelectProduct;
        jObj := MainJson.GetValue('result_data') as TJSONObject;

        AProductInfo.Reserve_No := jObj.GetValue('reserve_no').Value;
        sStartDatetime := jObj.GetValue('start_datetime').Value;
        AProductInfo.Start_Time := Copy(sStartDatetime, 9, 2) + ':' + Copy(sStartDatetime, 11, 2);
        sEndDatetime := jObj.GetValue('end_datetime').Value;
        AProductInfo.End_Time := Copy(sEndDatetime, 9, 2) + ':' + Copy(sEndDatetime, 11, 2);
        AProductInfo.One_Use_Time := Assign_Min;
        AProductInfo.Use_Qty := 0;

        AProductInfo.Reserve_List := EmptyStr;

        Global.SaleModule.SelectProduct := AProductInfo;
      end;
    except
      on E: Exception do
        Log.E('BunkerReservation', E.Message);
    end;
  finally
    FreeAndNil(MainJson);
  end;
end;

function TASPDatabase.TeeBoxReservationInfo(ACode: string): Boolean;
var
  Index, Cnt: Integer;
  MainJson: TJSONObject;
  JsonValue, JsonListValue: TJSONValue;
  JsonText, ADate: string;
  AProductInfo: TProductInfo;
  ATeeBox: TTeeBoxInfo;
  AMember: TMemberInfo;
begin
  try
    Result := False;
    MainJson := TJSONObject.Create;

    JsonText := Send_API(mtGet, 'K409_TeeBoxReserved?store_cd=' + Global.Config.Store.StoreCode + '&reserve_no=' + ACode, EmptyStr, True);

    if JsonText = EmptyStr then
      Exit;

    JsonValue := MainJson.ParseJSONValue(JsonText);

    if '0000' = (JsonValue as TJSONObject).Get('result_cd').JsonValue.Value then
    begin
      if JsonValue.FindValue('result_data') is TJSONNull then
        Exit;

      JsonValue := (JsonValue as TJSONObject).Get('result_data').JsonValue;

      ATeeBox.High := StrToIntDef((JsonValue as TJSONObject).Get('floor_cd').JsonValue.Value, 0);
      ATeeBox.Mno := (JsonValue as TJSONObject).Get('teebox_nm').JsonValue.Value;

      AMember.Name := (JsonValue as TJSONObject).Get('member_nm').JsonValue.Value;

      AProductInfo.Code := (JsonValue as TJSONObject).Get('product_cd').JsonValue.Value;
      AProductInfo.Name := (JsonValue as TJSONObject).Get('product_nm').JsonValue.Value;
      AProductInfo.One_Use_Time := (JsonValue as TJSONObject).Get('remain_min').JsonValue.Value;
      AProductInfo.Start_Time := (JsonValue as TJSONObject).Get('start_datetime').JsonValue.Value;
      AProductInfo.Start_Time := StringReplace(AProductInfo.Start_Time, '-', '', [rfReplaceAll]);
      AProductInfo.Start_Time := StringReplace(AProductInfo.Start_Time, ':', '', [rfReplaceAll]);
      AProductInfo.Start_Time := StringReplace(AProductInfo.Start_Time, ' ', '', [rfReplaceAll]);
      AProductInfo.Start_Time := FormatDateTime('hh:nn', DateStrToDateTime(Trim(AProductInfo.Start_Time)));

      AProductInfo.Product_Div := (JsonValue as TJSONObject).Get('product_div').JsonValue.Value;
      AProductInfo.Use_Qty := StrToIntDef((JsonValue as TJSONObject).Get('coupon_cnt').JsonValue.Value, 0);
      if AProductInfo.Product_Div <> PRODUCT_TYPE_D then
        AProductInfo.EndDate := (JsonValue as TJSONObject).Get('expire_day').JsonValue.Value;
      AProductInfo.Reserve_No := ACode;

      if not (JsonValue.FindValue('teeboxUsedItemList') is TJSONNull) then
      begin
        Cnt := 0;
        JsonListValue := (JsonValue as TJSONObject).Get('teeboxUsedItemList').JsonValue;
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

      Global.SaleModule.Member := AMember;
      Global.SaleModule.TeeBoxInfo := ATeeBox;
      Global.SaleModule.SelectProduct := AProductInfo;
    end;

    Result := True;
  finally
    FreeAndNil(MainJson);
    FreeAndNil(JsonValue);
  end;
end;

function TASPDatabase.SaveSaleInfo: Boolean;
var
  Index, Loop, CardDiscountAmt: Integer;
  Json, MainJson, ItemObject, TeeBoxItem: TJSONObject;
  PayMentList, DataList, DiscountList, TeeBoxList: TJSONArray;
  ItemValue: TJSONValue;
  JsonText: string;
  ACard: TPayCard;
  APayco: TPayPayco;
  AUTF8Str: UTF8String;
  ASaleData: TSaleData;
  allianceAmt: Integer;
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

      MainJson.AddPair(TJSONPair.Create('store_cd', Global.Config.Store.StoreCode));
      MainJson.AddPair(TJSONPair.Create('user_id', Global.Config.Store.UserID));
      MainJson.AddPair(TJSONPair.Create('pos_no', Global.Config.OAuth.DeviceID));
      MainJson.AddPair(TJSONPair.Create('client_id', Global.Config.OAuth.DeviceID));
      MainJson.AddPair(TJSONPair.Create('member_no', Global.SaleModule.Member.Code));


      MainJson.AddPair(TJSONPair.Create('xgolf_no', IfThen(Global.SaleModule.Member.XGolfMember, Global.SaleModule.Member.XGolfMemberQR, '')));  // ???

      MainJson.AddPair(TJSONPair.Create('receipt_no', Global.SaleModule.RcpAspNo));
      MainJson.AddPair(TJSONPair.Create('prev_receipt_no', ''));  // ???
      MainJson.AddPair(TJSONPair.Create('sale_date', FormatDateTime('yyyymmdd', now)));
      MainJson.AddPair(TJSONPair.Create('sale_time', FormatDateTime('hhnn', now)));

      MainJson.AddPair(TJSONPair.Create('total_amt', CurrToStr(Global.SaleModule.TotalAmt)));

      // 2020-12-09 웰빙등 제휴사 할인
      if Global.SaleModule.allianceCode <> EmptyStr then
        MainJson.AddPair(TJSONPair.Create('sale_amt', CurrToStr(0)))
      else
        MainJson.AddPair(TJSONPair.Create('sale_amt', CurrToStr(Global.SaleModule.RealAmt)));


      MainJson.AddPair(TJSONPair.Create('xgolf_dc_amt', CurrToStr(Global.SaleModule.XGolfDCAmt)));
      // 카드사 즉시 할인으로 아래로 이동
//      MainJson.AddPair(TJSONPair.Create('direct_dc_amt', '0'));

      MainJson.AddPair(TJSONPair.Create('payment', PayMentList));
      ItemObject := TJSONObject.Create;
      ItemObject.AddPair(TJSONPair.Create('van_cd', IntToStr(Global.Config.Store.VanCode)));
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
          ItemObject.AddPair(TJSONPair.Create('pc_seq', IfThen(ACard.CardDiscount = 0, '', Global.SaleModule.CardDiscountGetCode)));
          ItemObject.AddPair(TJSONPair.Create('pc_div', IfThen(ACard.CardDiscount = 0, '', 'P')));
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

        // 2020-12-09 웰빙등 제휴사 할인
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
          TeeBoxItem.AddPair(TJSONPair.Create('teebox_no', IntToStr(Global.SaleModule.TeeBoxInfo.TasukNo)));
          TeeBoxList.Add(TeeBoxItem);
        end;

        // 2020-12-09 웰빙등 제휴사 할인
        if Global.SaleModule.allianceCode <> EmptyStr then
          ItemObject.AddPair(TJSONPair.Create('direct_dc_amt', IntToStr(Global.SaleModule.BuyProductList[Index].Products.Price) ))
        else
          ItemObject.AddPair(TJSONPair.Create('direct_dc_amt', '0'));

        DataList.Add(ItemObject);
      end;

      ItemObject := TJSONObject.Create;
      MainJson.AddPair(TJSONPair.Create('coupon', DiscountList));
      for Index := 0 to Global.SaleModule.DisCountList.Count - 1 do
      begin
        if Global.SaleModule.Member.XGolfMember then
        begin
          if Global.SaleModule.Member.XGolfMemberQR = Global.SaleModule.DisCountList[Index].QRCode then
            Continue;
        end;

        if not Global.SaleModule.DisCountList[Index].Add then
          Continue;

        if Global.SaleModule.DisCountList[Index].Gubun = 998 then
          Continue;

        ItemObject := TJSONObject.Create;

        ItemObject.AddPair(TJSONPair.Create('coupon_cd', Global.SaleModule.DisCountList[Index].QRCode));
        ItemObject.AddPair(TJSONPair.Create('apply_dc_amt', IntToStr(Global.SaleModule.DisCountList[Index].ApplyAmt)));

        DiscountList.Add(ItemObject);
      end;

      Log.D('Sale Save JsonText Begin', '매출 저장');
      Log.D('Sale Save JsonText Begin', LogReplace(MainJson.ToString));
      WriteLog(False, 'ApiLog', Global.SaleModule.SaleDate, 'SaleSave', LogReplace(MainJson.ToString));
      JsonText := Send_API_Reservation(mtPost, 'K601_ProductSale', MainJson.ToString);
      WriteLog(False, 'ApiLog', Global.SaleModule.SaleDate, 'SaleSave', LogReplace(JsonText));
      Log.D('Sale Save JsonText End', LogReplace(JsonText));

      if JsonText = EmptyStr then
        Exit;

      if '0000' = (MainJson.ParseJSONValue(JsonText) as TJSONObject).Get('result_cd').JsonValue.Value then
      begin
        if Global.SaleModule.BuyProductList.Count = 1 then
        begin
          if not (MainJson.ParseJSONValue(JsonText).FindValue('result_data') is TJSONNull) then
          begin
            ItemValue := (MainJson.ParseJSONValue(JsonText) as TJSONObject).Get('result_data').JsonValue;

            ASaleData := Global.SaleModule.BuyProductList[0];
            ASaleData.Products.ProductBuyCode := ((ItemValue as TJSONArray).Items[0] as TJSONObject).Get('purchase_cd').JsonValue.Value;
            Global.SaleModule.BuyProductList[0] := ASaleData;
          end;
        end;

        if Global.Config.PARKINGBARCODE then
        begin
          ItemValue := (MainJson.ParseJSONValue(JsonText) as TJSONObject).Get('result_data').JsonValue;
       end;
        Result := True;
      end
      else
      begin
        Global.SBMessage.ShowMessageModalForm((MainJson.ParseJSONValue(JsonText) as TJSONObject).Get('result_msg').JsonValue.Value);
        Global.SaleModule.SaleUploadFail := True;
        // 웰빙클럽 취소 필요
        Global.SaleModule.WellbeingClub(False, Global.SaleModule.allianceNumber);
      end;
    except
      on E: Exception do
      begin
        Global.SaleModule.SaleUploadFail := True;
        WriteLog(True, 'ApiLog', Global.SaleModule.SaleDate, 'SaleSave', E.Message);
        Log.D('Sale Save JsonText Begin', LogReplace(MainJson.ToString));
        Log.E('SaveSaleInfo', JsonText);
        Global.SBMessage.ShowMessageModalForm('업로드에 실패하였습니다.' + #13#10 + '하단의 영수증 지참 후 반드시' + #13#10 + '프론트에 문의하여 주시기 바랍니다.' + #13#10 + '감사합니다.');
        // 웰빙클럽 취소 필요
        Global.SaleModule.WellbeingClub(False, Global.SaleModule.allianceNumber);
      end;
    end;
  finally
    FreeAndNil(MainJson);
  end;
end;

function TASPDatabase.SearchCardDiscount(ACardNo, ACardAmt: string; out ACode, AMsg: string): Currency;
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

function TASPDatabase.BunkerPossible: Boolean;
var
  MainJson: TJSONObject;
  JsonText, AUrl: string;
begin
  try
    try
      //Log.D('K734_BunkerPossible ', ACardNo);
      Result := False;

      AUrl := 'K734_BunkerPossible?store_cd=' + Global.Config.Store.StoreCode +
              '&reserve_datetime=' + FormatDateTime('yyyymmddhhmmss', Now) +
              '&reserve_cnt=1' +
              '&prepare_min=' + Global.Config.PrePare_Min;

      JsonText := Send_API(mtGet, AUrl, EmptyStr);

      if JsonText = EmptyStr then
        Exit;

      Log.D('K734_BunkerPossible JsonText', JsonText);

      MainJson := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;

      if MainJson.GetValue('result_cd').Value = '0000' then
        Result := True;

    except
      on E: Exception do
      begin
        Log.E('K734_BunkerPossible', AUrl);
        Log.E('K734_BunkerPossible', E.Message);
      end;
    end;
  finally
    FreeAndNil(MainJson);
  end;
end;

function TASPDatabase.GetMemberCheckInList(AMemberNo, AQRCode: string; out ACode, AMsg: string): TList<TCheckInInfo>;
var
  Index: Integer;
  MainJson, jObj: TJSONObject;
  jObjArr: TJsonArray;
  JsonText, AUrl: string;
  rCheckInInfo: TCheckInInfo;
begin
  try
    Result := TList<TCheckInInfo>.Create;

    AUrl := 'K712_TeeboxCheckin?store_cd=' + Global.Config.Store.StoreCode + '&member_no=' + AMemberNo + '&xgolf_no=' + AQRCode + '&user_id=' + Global.Config.Store.UserID;

    JsonText := Send_API(mtPost, AUrl, EmptyStr);

    if JsonText = EmptyStr then
      Exit;

    Log.D('K712_TeeboxCheckin JsonText', LogReplace(JsonText));

    MainJson := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;
    ACode := MainJson.GetValue('result_cd').Value;
    AMsg := MainJson.GetValue('result_msg').Value;

    if ACode <> '0000' then
      Exit;

    if MainJson.FindValue('result_data') is TJSONNull then
      Exit;

    jObjArr := MainJson.GetValue('result_data') as TJsonArray;
    for Index := 0 to jObjArr.Count - 1 do
    begin
      jObj := jObjArr.Get(Index) as TJSONObject;

      rCheckInInfo.reserve_no := jObj.GetValue('reserve_no').Value;
      rCheckInInfo.member_no := jObj.GetValue('member_no').Value;
      rCheckInInfo.member_nm := jObj.GetValue('member_nm').Value;
      rCheckInInfo.floor_cd := jObj.GetValue('floor_cd').Value;
      rCheckInInfo.floor_nm := jObj.GetValue('floor_nm').Value;
      rCheckInInfo.teebox_no := jObj.GetValue('teebox_no').Value;
      rCheckInInfo.teebox_nm := jObj.GetValue('teebox_nm').Value;
      rCheckInInfo.purchase_cd := jObj.GetValue('purchase_cd').Value;
      rCheckInInfo.product_cd := jObj.GetValue('product_cd').Value;
      rCheckInInfo.product_nm := jObj.GetValue('product_nm').Value;
      rCheckInInfo.product_div := jObj.GetValue('product_div').Value;
      rCheckInInfo.reserve_datetime := jObj.GetValue('reserve_datetime').Value;
      rCheckInInfo.start_datetime := Copy(StringReplace(jObj.GetValue('start_datetime').Value, '-', '', [rfReplaceAll]), 10, 5);
      rCheckInInfo.remain_min := jObj.GetValue('remain_min').Value;
      rCheckInInfo.expire_day := jObj.GetValue('expire_day').Value;
      rCheckInInfo.coupon_cnt := jObj.GetValue('coupon_cnt').Value;
      //rCheckInInfo.reg_datetime := jObj.GetValue('reg_datetime').Value;
      rCheckInInfo.reserve_root_div := jObj.GetValue('reserve_root_div').Value;

      Result.Add(rCheckInInfo);
    end;

  finally
    FreeAndNil(MainJson);;
  end;

end;

function TASPDatabase.GetMemberOptQR(AQRCode: string): TMemberInfo;
var
  Index: Integer;
  MainJson: TJSONObject;
  JsonValue, ItemValue: TJSONValue;
  JsonText: string;
  rMember: TMemberInfo;
begin
  try

    rMember.Code := '0000';

    MainJson := TJSONObject.Create;
    JsonValue := TJSONValue.Create;

    JsonText := Send_API(mtGet, 'K314_GetMemberQr?qr_code=' + AQRCode + '&store_cd=' + Global.Config.Store.StoreCode, EmptyStr);

    if JsonText = EmptyStr then
      Exit;

    Log.D('GetMemberOptQR JsonText', LogReplace(JsonText));

    JsonValue := MainJson.ParseJSONValue(JsonText);

    if (JsonValue as TJSONObject).Get('result_cd').JsonValue.Value = '0000' then
    begin
      if MainJson.ParseJSONValue(JsonText).FindValue('result_data') is TJSONNull then
        Exit;

      JsonValue := (JsonValue as TJSONObject).Get('result_data').JsonValue;

      rMember.Code := (JsonValue as TJSONObject).Get('member_no').JsonValue.Value;
      rMember.Name := (JsonValue as TJSONObject).Get('member_nm').JsonValue.Value;

      Result := rMember;
    end;

  finally
    FreeAndNil(MainJson);;
    FreeAndNil(JsonValue);
  end;
end;

{ TSendAPIThread }

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

end.
