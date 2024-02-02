unit uASPDatabase;

interface

uses
  IdGlobal, FMX.Graphics, IdCoderMIME, InIFiles, IdSSL, IdSSLOpenSSL, Vcl.Dialogs,
  uStore, uStruct, System.Variants, System.SysUtils, System.Classes, System.DateUtils, System.Math, System.StrUtils,
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
    FUTF8Str: UTF8String;

    function Send_API(MethodType: TMethodType; AUrl, AJsonText: string; NotSaveLog: Boolean = False): AnsiString;

    //타석기AD미사용시 배정예약, AD상관없이 매출저장
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
    // 회원등록
    //function AddMember: Boolean;
    // 회원데이터를 가져온다.
    function GetAllMmeberInfoVersion: string;
    function GetAllMemberInfo(var bMsg: Boolean): TList<TMemberInfo>;
    // 회원 정보를 가져온다. 회원코드로만
    //function GetMemberInfoApi(ACardNo: string; out AMsg: string): TMemberInfo;
    // 회원의 상품 리스트를 가져온다
    function GetMemberProductList(ACardNo, ACode, ADate: string): TList<TProductInfo>;
    function GetMemberFacilityProductList(ACardNo, ACode, ADate: string): TList<TProductInfo>; //회원 보유 시설상품
    //회원의 상품 이용시간,배정시간을 배정시간 기준으로 불러온다. producttime = false;
    function GetTeeBoxProductTime(AProductCd: string; out ACode, AMsg: string): TProductInfo;
    // OPT QR 로 회원번호 받아온다
    function GetMemberOptQR(AQRCode: string): TMemberInfo;

    //체크인 정보
    function GetMemberCheckInList(AMemberNo, AXGolf, AQRCode: string; out ACode, AMsg: string): TList<TCheckInInfo>;

    // 타석 마스터 정보를 읽어 온다.
    function GetTeeBoxMasterVersion: string;
    function GetTeeBoxMaster: TList<TTeeBoxInfo>;
    // 타석 정보를 읽어 온다.
    function GetTeeBoxPlayingInfo: TList<TTeeBoxInfo>;

    // 타석 상품을 가져온다.
    function GetTeeBoxProductListVersion: string;
    function GetTeeBoxProductList(var bMsg: Boolean): TList<TProductInfo>;
    function GetFacilityProductList(var bMsg: Boolean): TList<TProductInfo>;
    function GetGeneralProductList(var bMsg: Boolean): TList<TProductInfo>;
    // 일일 타석 상품을 가져온다.
    function GetTeeBoxDayProductList: TList<TProductInfo>;

    // OAuth 인증
    function OAuth_Certification: Boolean;

    // 환경설정
    function GetConfigVersion: string;
    function GetConfig: Boolean;
    function GetConfigNew: Boolean;

    // 가맹점 정보 조회
    function GetStoreInfo: Boolean;

    // 타석 홀드
    function TeeBoxHold(AIsHold: Boolean = True): Boolean;

    // 타석 예약 등록
    function TeeBoxListReservation: Boolean;

    function TeeBoxReserveMove: Boolean;

    function AddNewMember: Boolean;
    function AddNewMemberQR: Boolean;

    // 벙커/퍼팅 배정가능여부
    function BunkerPossible: Boolean;
    function BunkerReservation: Boolean;

    // 타석 예약 조회
    function TeeBoxReservationInfo(ACode: string): Boolean;

    // 매출 등록
    function SaveSaleInfo: Boolean;
    function UseFacilityProduct(APurchaseCd: String): Boolean;

    // 프로모션 확인
    function SearchPromotion(ACoupon: string): Boolean;
    function CouponError(ACode: string): string;

    // 광고 목록 조회
    function GetAdvertisVersion: string;
    procedure SearchAdvertisList;
    function SendAdvertisCnt(ASeq: string): Boolean;
    function SendAdvertisReceiptCnt(ASeq, AType: string): TAdvertReceipt;

    //DB개더링 응모
    function SendAdvertEvent(ASeq, APhone, AXgolfQR: string): Boolean;

    function SendStamp(AProductCode, APhone: string; out ACode, AMsg: string): Boolean;

    // XGOLF회원 QR 등록
    function AddMemberXGOLFQR(ACode: string): Boolean;
    // 카드사 할인 체크
    function SearchCardDiscount(ACardNo, ACardAmt, ASeatProductDiv: string; out ACode, AMsg: string): Currency;

    //일일타석 주차등록
    function SetParkingDay(ACarNo: string): Boolean;

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
//  FSendAPIThread := TSendAPIThread.Create;
  sslIOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  sslIOHandler.SSLOptions.Method := sslvSSLv23;
  sslIOHandler.SSLOptions.Mode := sslmClient;
end;

destructor TASPDatabase.Destroy;
begin
//  FSendAPIThread.Free;
//  FreeAndNil(SendData);
//  FreeAndNil(RecvData);

  sslIOHandler.Free;
//  SendData.Free;
//  RecvData.Free;
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

function TASPDatabase.GetAllMemberInfo(var bMsg: Boolean): TList<TMemberInfo>;
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
    try
      bMsg := False;
      Result := TList<TMemberInfo>.Create;

      SendDatetime := Global.SaleModule.MemberInfoDownLoadDateTime;

      if Global.SaleModule.MemberInfoDownLoadDateTime = EmptyStr then
        Global.SaleModule.MemberInfoDownLoadDateTime := FormatDateTime('yyyymmddhhnnss', now);

      if SendDatetime <> EmptyStr then
        JsonText := Send_API(mtGet, 'K214_MemberlistSimple?search_date=' + SendDatetime + '&store_cd=' + Global.Config.Store.StoreCode, EmptyStr)
      else
        JsonText := Send_API(mtGet, 'K214_MemberlistSimple?store_cd=' + Global.Config.Store.StoreCode, EmptyStr);

      if JsonText = EmptyStr then
      begin
        if StrPos(PChar(Global.SaleModule.FApiErrorMsg), PChar('Socket Error')) <> nil then
        begin
          showmessage('회원 정보 다운로드중 오류가 발생하였습니다.' + #13#10 + Global.SaleModule.FApiErrorMsg);
        end;

        Exit;
      end;

      //Log.D('회원정보', JsonText);
      MainJson := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;

      if '0000' = MainJson.GetValue('result_cd').Value then
      begin
        if MainJson.FindValue('result_data') is TJSONNull then
          Exit;

        jObjArr := MainJson.GetValue('result_data') as TJsonArray;
        nCnt := jObjArr.Size;

        Log.D('저장할 회원 수', Inttostr(nCnt));
        for Index := 0 to nCnt - 1 do
        begin
          AMemberInfo.FingerStr := EmptyStr;

          jObj := jObjArr.Get(Index) as TJSONObject;
          AMemberInfo.Code := jObj.GetValue('member_no').Value;
          AMemberInfo.CardNo := jObj.GetValue('qr_cd').Value;
          AMemberInfo.CarNo := jObj.GetValue('car_no').Value;
          AMemberInfo.Addr1 := jObj.GetValue('address').Value;
          AMemberInfo.Addr2 := jObj.GetValue('address_desc').Value;
          AMemberInfo.Tel_Mobile := jObj.GetValue('hp_no').Value;
          AMemberInfo.Email := jObj.GetValue('email').Value;
          AMemberInfo.Sex := IfThen(StrToIntDef(jObj.GetValue('sex_div').Value, 1) = 1, 'M', 'W');
          AMemberInfo.Name := jObj.GetValue('member_nm').Value;
          AMemberInfo.BirthDay := jObj.GetValue('birth_ymd').Value;
          AMemberInfo.XGolfMemberQR := jObj.GetValue('xg_user_key').Value;
          AMemberInfo.XGolfMember := Copy(AMemberInfo.XGolfMemberQR, 1, 2) = XGOLF_REPLACE_STR3;

          //chy 2021-01-26
          AMemberInfo.MemberCardUid := jObj.GetValue('member_card_uid').Value; //회원 카드 고유번호

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
          AMemberInfo.Use := jObj.GetValue('del_yn').Value = 'N';

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

          AMemberInfo.FingerStr := jObj.GetValue('fingerprint1').Value;
          AMemberInfo.FingerStr_2 := jObj.GetValue('fingerprint2').Value;

          if AMemberInfo.Use then
            Result.Add(AMemberInfo);
        end;
      end;

      bMsg := True;

    except
      on E: Exception do
      begin
        showmessage('회원 정보 다운로드중 오류가 발생하였습니다.' + #13#10 + e.Message);
      end;
    end;

    Log.D('저장된 회원 수', inttostr(Result.Count));

  finally
    FreeAndNil(MainJson);
    //Log.D('저장된 회원 수', inttostr(Result.Count));
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
    Global.sUrl := Global.Config.Partners.URL;

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

            //chy union
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
  end;
end;

function TASPDatabase.GetConfigNew: Boolean;
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
    Global.sUrl := Global.Config.Partners.URL;

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

{
function TASPDatabase.GetMemberInfoApi(ACardNo: string; out AMsg: string): TMemberInfo;
var
  Index: Integer;
  MainJson, jObj, jObjSub: TJSONObject;
  jObjArr, jObjArrSub: TJsonArray;
  AMember: TMemberInfo;
  JsonText: string;
  sLockerEndDay, sLockerEndDayTemp: String;
begin
  try
    Log.D('GetMemberInfo', LogReplace(ACardNo));
    AMember.Code := EmptyStr;

    Result := AMember;

    sLockerEndDay := '';

    JsonText := Send_API(mtGet, 'K301_Member?store_cd=' + Global.Config.Store.StoreCode + '&photo_yn=Y' + '&member_no=' + ACardNo, EmptyStr);

    if JsonText = EmptyStr then
      Exit;

    Log.D('GetMemberInfo JsonText', LogReplace(JsonText));

    MainJson := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;

    if MainJson.GetValue('result_cd').Value = '0000' then
    begin
      jObjArr := MainJson.GetValue('result_data') as TJsonArray;
      if jObjArr.Count = 0 then
        Exit;

      jObj := jObjArr.Get(0) as TJSONObject;
      Result.Code := jObj.GetValue('member_no').Value;
      Result.CardNo := jObj.GetValue('qr_cd').Value;
      Result.Addr1 := jObj.GetValue('address').Value;
      Result.Addr2 := jObj.GetValue('address_desc').Value;
      Result.Sex := IfThen(jObj.GetValue('sex_div').Value = '1', 'M', 'W');
      Result.BirthDay := jObj.GetValue('birth_ymd').Value;
      Result.Name := jObj.GetValue('member_nm').Value;
      Result.Tel_Mobile := jObj.GetValue('hp_no').Value;

      //2020-12-29 라카만료일
      if not (jObj.FindValue('locker') is TJSONNull) then
      begin
        jObjArrSub := jObj.GetValue('locker') as TJsonArray;
        for Index := 0 to jObjArrSub.Count - 1 do
        begin
          if Index <> 0 then
            sLockerEndDay := sLockerEndDay + ' ';

          jObjSub := jObjArrSub.Get(Index) as TJSONObject;
          sLockerEndDayTemp := jObjSub.GetValue('end_day').Value;
          sLockerEndDayTemp := Copy(sLockerEndDayTemp, 1, 4) + '-' + Copy(sLockerEndDayTemp, 5, 2) + '-' + Copy(sLockerEndDayTemp, 7, 2);
          sLockerEndDay := sLockerEndDay + sLockerEndDayTemp;
        end;
      end;

      Global.SaleModule.FLockerEndDay := sLockerEndDay;

    end;
  finally
    FreeAndNil(MainJson);
  end;
end;
 }

function TASPDatabase.GetMemberProductList(ACardNo, ACode, ADate: string): TList<TProductInfo>;
var
  Index, Loop, Cnt, ProductUseCnt, j: Integer;
  MainJson, jObj, jObjSub: TJSONObject;
  jObjArr, jObjArrSub: TJsonArray;
  JsonText, NowDay, NowTime: string;
  AProduct: TProductInfo;
  AProductList: TList<TProductInfo>;
  sUseStatus, sLockerEndDay, sLockerEndDayTemp: String;
begin
  try
    Result := TList<TProductInfo>.Create;
    AProductList := TList<TProductInfo>.Create;

    NowDay := EmptyStr;
    NowTime := EmptyStr;

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
        AProduct.UseCnt := StrToIntDef(jObj.GetValue('coupon_cnt').Value, 0);
        AProduct.Product_Div := jObj.GetValue('product_div').Value;

        AProduct.ZoneCode := jObj.GetValue('zone_cd').Value;
        AProduct.AvailableZoneCd := jObj.GetValue('available_zone_cd').Value; //2021-12-17 프라자

        AProduct.Start_Time := StringReplace(jObj.GetValue('day_start_time').Value, ':', '', [rfReplaceAll]); //이용 시작시간
        AProduct.End_Time := StringReplace(jObj.GetValue('day_end_time').Value, ':', '', [rfReplaceAll]); //이용 종료시간

        if AProduct.Product_Div = PRODUCT_TYPE_C then
          AProduct.Use := (jObj.GetValue('today_yn').Value = 'Y') and (AProduct.UseCnt <> 0)
        else
          AProduct.Use := (jObj.GetValue('today_yn').Value = 'Y');

        AProduct.One_Use_Time := jObj.GetValue('one_use_time').Value;

        NowDay := FormatDateTime('yyyymmdd', now);
        NowTime := FormatDateTime('hhnn', now);

        sUseStatus := jObj.GetValue('use_status').Value;
        if AProduct.Use then
          AProduct.Use := (sUseStatus = '1');

        //2022-05-30 라카만료일
        if Index = 0 then
        begin
          if not (jObj.FindValue('locker') is TJSONNull) then
          begin
            jObjArrSub := jObj.GetValue('locker') as TJsonArray;
            for j := 0 to jObjArrSub.Count - 1 do
            begin
              if j <> 0 then
                sLockerEndDay := sLockerEndDay + ' ';

              jObjSub := jObjArrSub.Get(j) as TJSONObject;
              sLockerEndDayTemp := jObjSub.GetValue('end_day').Value;
              sLockerEndDayTemp := Copy(sLockerEndDayTemp, 1, 4) + '-' + Copy(sLockerEndDayTemp, 5, 2) + '-' + Copy(sLockerEndDayTemp, 7, 2);
              sLockerEndDay := sLockerEndDay + sLockerEndDayTemp;
            end;
          end;

          Global.SaleModule.FLockerEndDay := sLockerEndDay;
        end;

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

function TASPDatabase.GetMemberFacilityProductList(ACardNo, ACode, ADate: string): TList<TProductInfo>;
var
  Index, ProductUseCnt: Integer;
  MainJson, jObj, jObjSub: TJSONObject;
  jObjArr: TJsonArray;
  JsonText: string;
  AProduct: TProductInfo;
  AProductList: TList<TProductInfo>;
  sUseStatus: String;
begin
  try
    Result := TList<TProductInfo>.Create;
    AProductList := TList<TProductInfo>.Create;

    JsonText := Send_API(mtGet, 'K315_GetMemberFacilityProduct?member_no=' + ACardNo +
                                                           '&store_cd=' + Global.Config.Store.StoreCode, EmptyStr);

    if JsonText = EmptyStr then
      Exit;

    Log.D('GetMemberFacilityProductList JsonText', LogReplace(JsonText));

    MainJson := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;

    if MainJson.GetValue('result_cd').Value = '0000' then
    begin
      if MainJson.FindValue('result_data') is TJSONNull then
        Exit;

      jObjArr := MainJson.GetValue('result_data') as TJsonArray;
      for Index := 0 to jObjArr.Count - 1 do
      begin
        jObj := jObjArr.Get(Index) as TJSONObject;

        AProduct.ProductBuyCode := jObj.GetValue('purchase_cd').Value;
        AProduct.Code := jObj.GetValue('product_cd').Value;
        AProduct.Name := jObj.GetValue('product_nm').Value;

        AProduct.Product_Div := jObj.GetValue('facility_product_div').Value;
        AProduct.Access_Control_Nm := jObj.GetValue('access_control_nm').Value;

        AProduct.StartDate := jObj.GetValue('start_day').Value; //이용 시작일
        AProduct.EndDate := jObj.GetValue('end_day').Value; //이용 종료일
        AProduct.UseCnt := StrToIntDef(jObj.GetValue('remain_cnt').Value, 0);
        AProduct.Ticket_Print_Yn := jObj.GetValue('ticket_print_yn').Value = 'Y';

        sUseStatus := jObj.GetValue('use_status').Value;
        AProduct.Use := (sUseStatus = '1');

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

function TASPDatabase.GetStoreInfo: Boolean;
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
    //Log.D('K203_StoreInfo', JsonText);

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
      Global.Config.Store.EndTimeIgnoreYn := jObj.GetValue('end_time_ignore_yn').Value;
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

        sslIOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
        sslIOHandler.SSLOptions.Mode := sslmClient;
        sslIOHandler.SSLOptions.SSLVersions := [sslvTLSv1_2];

        AIndy := TIdHTTP.Create(nil);
        AIndy.IOHandler := sslIOHandler;

        mStream := TMemoryStream.Create;
        FileUrl := Agreement.FileUrl;
        FilePath := Agreement.FilePath;

        AIndy.Get(FileUrl, mStream);

        if not FileExists(FilePath) then
          mStream.SaveToFile(FilePath);

        sslIOHandler.Free;
        AIndy.Free;
        mStream.Free;

        if Agreement.AgreementDiv = '01' then //01:서비스 이용약관 동의
          Global.SaleModule.AgreementList1.Add(Agreement);
        if Agreement.AgreementDiv = '02' then //02:개인정보 수집 이용 동의
          Global.SaleModule.AgreementList2.Add(Agreement);
        if Agreement.AgreementDiv = '03' then //03:바이오 정보 수집 이용 제공 동의
          Global.SaleModule.AgreementList3.Add(Agreement);

      end;

      Global.Config.Store.StampYn := Trim(jObj.GetValue('stamp_yn').Value) = 'Y';

    end;

    Result := True;
    Global.Config.SaveLocalConfig;
  finally
    FreeAndNil(MainJson);
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
  Index, nCnt: Integer;
  ATeeBoxInfo: TTeeBoxInfo;
  MainJson, jObj: TJSONObject;
  jObjArr: TJsonArray;
  JsonText, AVersion: string;
begin
  try
    Result := TList<TTeeBoxInfo>.Create;

    JsonText := Send_API(mtGet, 'K204_TeeBoxlist?store_cd=' + Global.Config.Store.StoreCode, EmptyStr);
    //Log.D('타석 마스터', JsonText);

    if JsonText = EmptyStr then
      Exit;

    MainJson := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;;

    if '0000' = MainJson.GetValue('result_cd').Value then
    begin
      if MainJson.FindValue('result_data') is TJSONNull then
        Exit;

      jObjArr := MainJson.GetValue('result_data') as TJsonArray;
      nCnt := jObjArr.size;

      for Index := 0 to nCnt - 1 do
      begin
        jObj := jObjArr.Get(Index) as TJSONObject;
        ATeeBoxInfo.Mno := jObj.GetValue('teebox_nm').Value;
        ATeeBoxInfo.TasukNo := StrToIntDef(jObj.GetValue('teebox_no').Value, 0);
        ATeeBoxInfo.High := StrToIntDef(jObj.GetValue('floor_cd').Value, 0);
        ATeeBoxInfo.FloorNm := jObj.GetValue('floor_nm').Value;
        ATeeBoxInfo.Vip := jObj.GetValue('vip_yn').Value = 'Y';
        ATeeBoxInfo.ZoneCode := jObj.GetValue('zone_div').Value;
        ATeeBoxInfo.ControlYn := jObj.GetValue('control_yn').Value;
        ATeeBoxInfo.Use := jObj.GetValue('use_yn').Value = 'Y';
        ATeeBoxInfo.DelYn := jObj.GetValue('del_yn').Value = 'Y';
        ATeeBoxInfo.ERR := 0;
        ATeeBoxInfo.Hold := False;
        ATeeBoxInfo.Add_OK := False;
        ATeeBoxInfo.IsAddList := False;

        Result.Add(ATeeBoxInfo);
      end;
    end;
  finally
    FreeAndNil(MainJson);
  end;
end;

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

      //Log.D('가동상황', JsonText);

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
    FreeAndNilJSONObject(JsonValue);
    FreeAndNil(MainJson);
  end;
end;

function TASPDatabase.GetTeeBoxProductListVersion: string;
begin
  Result := GetVersion('K205_TeeBoxProductVersion?store_cd=' + Global.Config.Store.StoreCode);
  if Result = EmptyStr then
    Result := Global.Config.Version.ProductVersion;
end;

function TASPDatabase.GetTeeBoxProductList(var bMsg: Boolean): TList<TProductInfo>;
var
  Index, WeekUse: Integer;
  MainJson, jObj: TJSONObject;
  jObjArr: TJsonArray;

  AProduct: TProductInfo;
  JsonText, AVersion: string;
  nCnt: Integer;
begin
  try
    try
      bMsg := False;
      Result := TList<TProductInfo>.Create;

      JsonText := Send_API(mtGet, 'K206_TeeBoxProductlist?store_cd=' + Global.Config.Store.StoreCode, EmptyStr);

      if JsonText = EmptyStr then
      begin
        if StrPos(PChar(Global.SaleModule.FApiErrorMsg), PChar('Socket Error')) <> nil then
        begin
          showmessage('상품 정보 다운로드중 오류가 발생하였습니다.' + #13#10 + Global.SaleModule.FApiErrorMsg);
        end;

        Exit;
      end;

      //Log.D('상품 마스터', JsonText);

      MainJson := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;

      if '0000' = MainJson.GetValue('result_cd').Value then
      begin
        if MainJson.FindValue('result_data') is TJSONNull then
          Exit;

        jObjArr := MainJson.GetValue('result_data') as TJsonArray;
        nCnt := jObjArr.Size;

        for Index := 0 to nCnt - 1 do
        begin
          jObj := jObjArr.Get(Index) as TJSONObject;

          if jObj.GetValue('del_yn').Value = 'Y' then
            Continue;

          AProduct.Code := jObj.GetValue('product_cd').Value;
          AProduct.Name := jObj.GetValue('product_nm').Value;
          //AProduct.TypeName := jObj.GetValue('product_nm').Value;
          AProduct.ZoneCode := jObj.GetValue('zone_cd').Value;
          AProduct.AvailableZoneCd := jObj.GetValue('available_zone_cd').Value; //2021-12-17 프라자
          AProduct.Price := StrToIntDef(jObj.GetValue('product_amt').Value, 0);
          AProduct.Use := jObj.GetValue('use_yn').Value = 'Y';
          AProduct.Today_Use := jObj.GetValue('today_yn').Value = 'Y';
          AProduct.One_Use_Time := jObj.GetValue('one_use_time').Value;
          AProduct.Sex := jObj.GetValue('sex').Value;
          AProduct.UseWeek := jObj.GetValue('use_div').Value;
          AProduct.Start_Time := jObj.GetValue('start_time').Value;
          AProduct.End_Time := jObj.GetValue('end_time').Value;
          AProduct.Product_Div := jObj.GetValue('product_div').Value;
          AProduct.xgolf_dc_yn := jObj.GetValue('xgolf_dc_yn').Value = 'Y';
          AProduct.xgolf_dc_amt := StrToIntDef(jObj.GetValue('xgolf_dc_amt').Value, 0);
          AProduct.xgolf_product_amt := StrToIntDef(jObj.GetValue('xgolf_product_amt').Value, 0);
          AProduct.UseMonth := jObj.GetValue('use_month').Value;
          AProduct.UseCnt := StrToIntDef(jObj.GetValue('use_cnt').Value, 0);
          AProduct.Memo := jObj.GetValue('memo').Value;
          AProduct.Alliance_yn := jObj.GetValue('alliance_yn').Value = 'Y';

          AProduct.Alliance_Code := jObj.GetValue('alliance_code').Value;
          AProduct.Alliance_Name := jObj.GetValue('alliance_name').Value;
          AProduct.Alliance_Item_Code := jObj.GetValue('alliance_item_code').Value;
          AProduct.Alliance_Item_Name := jObj.GetValue('alliance_item_name').Value;

          AProduct.Limit_Product_Yn := jObj.GetValue('limit_product_yn').Value = 'Y';
          AProduct.Stamp_Yn := jObj.GetValue('stamp_yn').Value = 'Y';

          WeekUse := DayOfWeek(Now);

          if (Pos('일일', AProduct.Name) > 0) then
          begin
            WeekUse := WeekUse;
          end;

          if WeekUse = 1 then
            WeekUse := 7
          else
            WeekUse := WeekUse - 1;

          if jObj.GetValue('kiosk_view_yn').Value <> 'Y' then
            AProduct.Use := False;

          if AProduct.Use and AProduct.Today_Use then
            Result.Add(AProduct);
        end;
      end;

      bMsg := True;
    except
      on E: Exception do
      begin
        showmessage('상품 정보 다운로드중 오류가 발생하였습니다.' + #13#10 + e.Message);
      end;
    end;

  finally
    FreeAndNil(MainJson);
  end;

end;

function TASPDatabase.GetFacilityProductList(var bMsg: Boolean): TList<TProductInfo>;
var
  Index: Integer;
  MainJson, jObj: TJSONObject;
  jObjArr: TJsonArray;

  AProduct: TProductInfo;
  JsonText: string;
  nCnt: Integer;
begin
  try
    try
      bMsg := False;
      Result := TList<TProductInfo>.Create;

      JsonText := Send_API(mtGet, 'K241_FacilityProductList?store_cd=' + Global.Config.Store.StoreCode + '&today_use_yn=Y', EmptyStr);

      if JsonText = EmptyStr then
      begin
        if StrPos(PChar(Global.SaleModule.FApiErrorMsg), PChar('Socket Error')) <> nil then
        begin
          showmessage('시설이용권 정보 다운로드중 오류가 발생하였습니다.' + #13#10 + Global.SaleModule.FApiErrorMsg);
        end;

        Exit;
      end;

      //Log.D('상품 마스터', JsonText);

      MainJson := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;

      if '0000' = MainJson.GetValue('result_cd').Value then
      begin
        if MainJson.FindValue('result_data') is TJSONNull then
          Exit;

        jObjArr := MainJson.GetValue('result_data') as TJsonArray;
        nCnt := jObjArr.Size;

        for Index := 0 to nCnt - 1 do
        begin
          jObj := jObjArr.Get(Index) as TJSONObject;

          if jObj.GetValue('del_yn').Value = 'Y' then
            Continue;

          if jObj.GetValue('kiosk_view_yn').Value <> 'Y' then //키오스크 노출 여부
            Continue;

          AProduct.Code := jObj.GetValue('product_cd').Value;
          AProduct.Name := jObj.GetValue('product_nm').Value;
          AProduct.Product_Div := jObj.GetValue('facility_product_div').Value;  //기간제(R), 쿠폰제(C), 일일이용(D)
          AProduct.Price := StrToIntDef(jObj.GetValue('product_amt').Value, 0);
          AProduct.UseCnt := StrToIntDef(jObj.GetValue('use_cnt').Value, 0);
          AProduct.UseMonth := jObj.GetValue('use_month').Value;
          AProduct.Ticket_Print_Yn := jObj.GetValue('ticket_print_yn').Value = 'Y'; //배정표 출력 여부

          AProduct.Use := jObj.GetValue('use_yn').Value = 'Y';

          if AProduct.Use = True then
            Result.Add(AProduct);
        end;
      end;

      bMsg := True;
    except
      on E: Exception do
      begin
        showmessage('시설이용권 정보 다운로드중 오류가 발생하였습니다.' + #13#10 + e.Message);
      end;
    end;

  finally
    FreeAndNil(MainJson);
  end;

end;

function TASPDatabase.GetGeneralProductList(var bMsg: Boolean): TList<TProductInfo>;
var
  Index, WeekUse: Integer;
  MainJson, jObj: TJSONObject;
  jObjArr: TJsonArray;

  AProduct: TProductInfo;
  JsonText, AVersion: string;
  nCnt: Integer;
begin
  try
    try
      bMsg := False;
      Result := TList<TProductInfo>.Create;

      JsonText := Send_API(mtGet, 'K208_Productlist?store_cd=' + Global.Config.Store.StoreCode, EmptyStr);

      if JsonText = EmptyStr then
      begin
        if StrPos(PChar(Global.SaleModule.FApiErrorMsg), PChar('Socket Error')) <> nil then
        begin
          showmessage('일반상품 정보 다운로드중 오류가 발생하였습니다.' + #13#10 + Global.SaleModule.FApiErrorMsg);
        end;

        Exit;
      end;

      //Log.D('상품 마스터', JsonText);

      MainJson := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;

      if '0000' = MainJson.GetValue('result_cd').Value then
      begin
        if MainJson.FindValue('result_data') is TJSONNull then
          Exit;

        jObjArr := MainJson.GetValue('result_data') as TJsonArray;
        nCnt := jObjArr.Size;

        for Index := 0 to nCnt - 1 do
        begin
          jObj := jObjArr.Get(Index) as TJSONObject;

          if jObj.GetValue('del_yn').Value = 'Y' then
            Continue;

          AProduct.Code := jObj.GetValue('product_cd').Value;
          AProduct.Name := jObj.GetValue('product_nm').Value;
          //AProduct.ClassCd := jObj.GetValue('class_cd').Value;
          //AProduct.TaxType := jObj.GetValue('tax_type').Value;

          //AProduct.Barcode := jObj.GetValue('barcode').Value;
          AProduct.Price := StrToIntDef(jObj.GetValue('product_amt').Value, 0);
          AProduct.Use := jObj.GetValue('use_yn').Value = 'Y';
          //AProduct.RefundYn := jObj.GetValue('refund_yn').Value = 'Y';
          //AProduct.DelYn := jObj.GetValue('del_yn').Value = 'Y';

          if AProduct.Use = True then
            Result.Add(AProduct);
        end;
      end;

      bMsg := True;
    except
      on E: Exception do
      begin
        showmessage('일반상품 정보 다운로드중 오류가 발생하였습니다.' + #13#10 + e.Message);
      end;
    end;

  finally
    FreeAndNil(MainJson);
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
        //AProduct.TypeName := (ItemValue as TJSONObject).Get('product_nm').JsonValue.Value;
        AProduct.Price := StrToIntDef((ItemValue as TJSONObject).Get('product_amt').JsonValue.Value, 0);
        AProduct.Use := (ItemValue as TJSONObject).Get('use_yn').JsonValue.Value = 'Y';
        AProduct.One_Use_Time := (ItemValue as TJSONObject).Get('one_use_time').JsonValue.Value;
        AProduct.Sex := (ItemValue as TJSONObject).Get('sex').JsonValue.Value;
        Result.Add(AProduct)
      end;
    end;
  finally
    FreeAndNilJSONObject(JsonValue);
    FreeAndNil(MainJson);
    //FreeAndNil(JsonValue);
  end;
end;

function TASPDatabase.OAuth_Certification: Boolean;
var
  Indy: TIdHTTP;
  SendData, RecvData: TStringStream;
  jObj: TJSONObject;
begin
  try
    try
      Result := False;

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

      Result := True;
    except
      on E: Exception do
      begin
        //showmessage('인증오류 입니다. 단말기 정보를 확인해 주세요' + Global.Config.Partners.OAuthURl + '/' + ByteStringToString(RecvData));
        showmessage('인증오류 입니다. 단말기 정보를 확인해 주세요' + #13#10 + e.Message);
      end;
    end;

  finally
    FreeAndNil(jObj); //Exception 발생후 강제에러발생. 그렇지 않으면 화면멈춤
    Indy.Free;
    SendData.Free;
    RecvData.Free;
  end;
end;

function TASPDatabase.TeeBoxHold(AIsHold: Boolean): Boolean;
var
  MainJson: TJSONObject;
  JsonValue: TJSONValue;
  AUrl, AStore_CD, TeeBox_No, User_Id: AnsiString;
  JsonText: string;
begin

  if Global.Config.AD.USE then
  begin
    Result := Global.LocalApi.TeeboxHold(AIsHold);
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
      FreeAndNilJSONObject(JsonValue);
      FreeAndNil(MainJson);
      //FreeAndNil(JsonValue);
    end;
  end;
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
      MainJson := TJSONObject.Create;
      ItemJson := TJSONObject.Create;
      JsonList := TJSONArray.Create;

      MainJson.AddPair(TJSONPair.Create('data', JsonList));
      MainJson.AddPair(TJSONPair.Create('member_no', Global.SaleModule.Member.Code));
      MainJson.AddPair(TJSONPair.Create('store_cd', Global.Config.Store.StoreCode));
      MainJson.AddPair(TJSONPair.Create('user_id', Global.Config.Store.UserID));

      //2021-12-17 프라자 3층 구분용
      MainJson.AddPair(TJSONPair.Create('teebox_no', IntToStr(Global.SaleModule.TeeBoxInfo.TasukNo)));

      MainJson.AddPair(TJSONPair.Create('reserve_root_div', 'K'));
      MainJson.AddPair(TJSONPair.Create('receipt_no', Global.SaleModule.RcpAspNo));
      MainJson.AddPair(TJSONPair.Create('affiliate_cd', Global.SaleModule.allianceCode));

      ItemJson.AddPair(TJSONPair.Create('assign_balls', '9999'));

      //매장종료시간초과시 배정시간 변경
      if Global.SaleModule.FStoreCloseOver = True then
        ItemJson.AddPair(TJSONPair.Create('assign_min', Global.SaleModule.FStoreCloseOverMin))
      else
        ItemJson.AddPair(TJSONPair.Create('assign_min', Global.SaleModule.SelectProduct.One_Use_Time));

      If (StrToIntDef(Global.Config.PrePare_Min, 5) <> Global.SaleModule.PrepareMin) then
        ItemJson.AddPair(TJSONPair.Create('prepare_min', IntToStr(Global.SaleModule.PrepareMin)))
      else
        ItemJson.AddPair(TJSONPair.Create('prepare_min', Global.Config.PrePare_Min));

      ItemJson.AddPair(TJSONPair.Create('product_cd', Global.SaleModule.SelectProduct.Code));
      ItemJson.AddPair(TJSONPair.Create('purchase_cd', Global.SaleModule.SelectProduct.ProductBuyCode));
      ItemJson.AddPair(TJSONPair.Create('available_zone_cd', Global.SaleModule.SelectProduct.AvailableZoneCd)); //2021-12-20 프라자
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
        MainJson.AddPair(TJSONPair.Create('hp_no', Global.SaleModule.Member.Tel_Mobile)); //2023-02-13 추가

        ReReserve :

        Log.D('Local TeeBoxReservation2', LogReplace(MainJson.ToString));
        JsonText := Global.LocalApi.TeeBoxListReservation(MainJson.ToString);
        Log.D('Local TeeBoxReservation2', LogReplace(JsonText));
      end
      else
      begin
        Log.D('TeeBoxReservation2', LogReplace(MainJson.ToString));
        JsonText := Send_API_Reservation(mtPost, 'K408_TeeBoxReserve2', MainJson.ToString);
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

            AProductInfo.UseCnt := StrToIntDef((JsonValue as TJSONObject).Get('coupon_cnt').JsonValue.Value, 0);

            AProductInfo.Access_Barcode := (JsonValue as TJSONObject).Get('access_barcode').JsonValue.Value;
            AProductInfo.Access_Control_Nm := (JsonValue as TJSONObject).Get('access_control_nm').JsonValue.Value;

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
        end
        else
        begin
          if ((JsonValue as TJSONObject).Get('result_cd').JsonValue.Value = '0002') and Global.Config.AD.USE then
          begin
            goto ReReserve;
          end
          else
            Global.SBMessage.ShowMessageModalForm((JsonValue as TJSONObject).Get('result_msg').JsonValue.Value);
        end;
      end
      else
        Global.SBMessage.ShowMessageModalForm(MSG_TEEBOX_RESERVATION_AD_FAIL);
    except
      on E: Exception do
      begin
        WriteLog(True, 'ApiLog', Global.SaleModule.SaleDate, 'TeeBoxReservation2', LogReplace(JsonText));
        Log.E('TeeBoxReservation', E.Message);
      end;
    end;
  finally
    FreeAndNil(MainJson);
  end;
end;

//chy move
function TASPDatabase.TeeBoxReserveMove: Boolean;
label ReReserve;
var
  Index, Cnt: Integer;
  MainJson: TJSONObject;

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
      MainJson := TJSONObject.Create;

      MainJson.AddPair(TJSONPair.Create('store_cd', Global.Config.Store.StoreCode));
      MainJson.AddPair(TJSONPair.Create('reserve_no', Global.SaleModule.TeeBoxMoveInfo.ReserveNo));
      MainJson.AddPair(TJSONPair.Create('user_id', Global.Config.Store.UserID));
      MainJson.AddPair(TJSONPair.Create('assign_balls', '9999'));
      MainJson.AddPair(TJSONPair.Create('assign_min', Global.SaleModule.TeeBoxMoveInfo.Ma_Time));
      {
      MainJson.AddPair(TJSONPair.Create('prepare_min', IfThen(StrToIntDef(Global.Config.PrePare_Min, 5) <> Global.SaleModule.PrepareMin,
                                                                IntToStr(Global.SaleModule.PrepareMin), Global.Config.PrePare_Min)));
      }
      If (StrToIntDef(Global.Config.PrePare_Min, 5) <> Global.SaleModule.PrepareMin) then
        MainJson.AddPair(TJSONPair.Create('prepare_min', IntToStr(Global.SaleModule.PrepareMin)))
      else
        MainJson.AddPair(TJSONPair.Create('prepare_min', Global.Config.PrePare_Min));

      MainJson.AddPair(TJSONPair.Create('teebox_no', IntToStr(Global.SaleModule.TeeBoxInfo.TasukNo)));
      MainJson.AddPair(TJSONPair.Create('api', 'K412_MoveTeeBoxReserved'));

      ReReserve :

      Log.D('Local K412_MoveTeeBoxReserved', LogReplace(MainJson.ToString));
      //WriteLog(False, 'ApiLog', Global.SaleModule.SaleDate, 'Local K412_MoveTeeBoxReserved', LogReplace(MainJson.ToString));
      JsonText := Global.LocalApi.TeeBoxListReservation(MainJson.ToString);
      //WriteLog(False, 'ApiLog', Global.SaleModule.SaleDate, 'Local K412_MoveTeeBoxReserved', LogReplace(JsonText));
      Log.D('Local K412_MoveTeeBoxReserved', LogReplace(JsonText));

      if JsonText <> EmptyStr then
      begin
        JsonValue := MainJson.ParseJSONValue(JsonText);

        if (JsonValue as TJSONObject).Get('result_cd').JsonValue.Value = '0000' then
        begin
          Result := True;

          if not (JsonValue.FindValue(Ifthen(Global.Config.AD.USE, 'data', 'result_data')) is TJSONNull) then
          begin
            AProductInfo := Global.SaleModule.SelectProduct;
            JsonValue := (JsonValue as TJSONObject).Get(VarToStr(Ifthen(Global.Config.AD.USE, 'data', 'result_data'))).JsonValue;

            JsonValue := (JsonValue as TJSONArray).Items[0];

            begin
              AProductInfo.Reserve_Time := (JsonValue as TJSONObject).Get('start_datetime').JsonValue.Value;
              AProductInfo.Start_Time :=
                Copy(StringReplace((JsonValue as TJSONObject).Get('start_datetime').JsonValue.Value, '-', '', [rfReplaceAll]), 10, 5);
              AProductInfo.One_Use_Time := (JsonValue as TJSONObject).Get('remain_min').JsonValue.Value;
            end;

              AProductInfo.UseCnt := StrToIntDef((JsonValue as TJSONObject).Get('coupon_cnt').JsonValue.Value, 0);

            AProductInfo.Reserve_No := (JsonValue as TJSONObject).Get('reserve_no').JsonValue.Value;
            AProductInfo.Name := (JsonValue as TJSONObject).Get('product_nm').JsonValue.Value;
            AProductInfo.Product_Div := (JsonValue as TJSONObject).Get('product_div').JsonValue.Value;
            AProductInfo.EndDate := (JsonValue as TJSONObject).Get('expire_day').JsonValue.Value;

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
        end
        else
        begin
          if ((JsonValue as TJSONObject).Get('result_cd').JsonValue.Value = '0002') and Global.Config.AD.USE then
          begin
            goto ReReserve;
          end
          else
            Global.SBMessage.ShowMessageModalForm((JsonValue as TJSONObject).Get('result_msg').JsonValue.Value);
        end;
      end
      else
        Global.SBMessage.ShowMessageModalForm(MSG_TEEBOX_RESERVEMOVE_AD_FAIL);
    except
      on E: Exception do
      begin
        WriteLog(True, 'ApiLog', Global.SaleModule.SaleDate, 'K412_MoveTeeBoxReserved', LogReplace(JsonText));
        Log.E('K412_MoveTeeBoxReserved', E.Message);
      end;
    end;
  finally
    FreeAndNil(MainJson);
  end;
end;

//chy newmember
function TASPDatabase.AddNewMember: Boolean;
var
  Json, MainJson: TJSONObject;
  JsonValue: TJSONValue;
  JsonText: string;
  AMemberInfo: TMemberInfo;
begin
  try
    try
      Result := False;
      JsonText := EmptyStr;
      Json := TJSONObject.Create;
      MainJson := TJSONObject.Create;

      MainJson.AddPair(TJSONPair.Create('store_cd', Global.Config.Store.StoreCode));
      MainJson.AddPair(TJSONPair.Create('user_id', Global.Config.Store.UserID));

      MainJson.AddPair(TJSONPair.Create('member_no', Global.SaleModule.NewMember.Code));
      MainJson.AddPair(TJSONPair.Create('member_nm', Global.SaleModule.NewMember.Name));
      //MainJson.AddPair(TJSONPair.Create('sex_div', Global.SaleModule.NewMember.Sex));
      MainJson.AddPair(TJSONPair.Create('sex_div', '1'));
      MainJson.AddPair(TJSONPair.Create('birth_ymd', Global.SaleModule.NewMember.BirthDay));
      MainJson.AddPair(TJSONPair.Create('hp_no', Global.SaleModule.NewMember.Tel_Mobile));
      MainJson.AddPair(TJSONPair.Create('email', Global.SaleModule.NewMember.Email));
      MainJson.AddPair(TJSONPair.Create('car_no', Global.SaleModule.NewMember.CarNo));
      MainJson.AddPair(TJSONPair.Create('zip_no', ''));
      MainJson.AddPair(TJSONPair.Create('address', Global.SaleModule.NewMember.Addr1));
      MainJson.AddPair(TJSONPair.Create('address_desc', Global.SaleModule.NewMember.Addr2));
      MainJson.AddPair(TJSONPair.Create('customer_cd', ''));
      MainJson.AddPair(TJSONPair.Create('group_cd', ''));
      MainJson.AddPair(TJSONPair.Create('qr_cd', Global.SaleModule.NewMember.CardNo));
      MainJson.AddPair(TJSONPair.Create('photo_encoding', ''));
      //MainJson.AddPair(TJSONPair.Create('fingerprint1', Global.SaleModule.NewMember.FingerStr));
      MainJson.AddPair(TJSONPair.Create('fingerprint1', Global.SaleModule.FingerStr));

      MainJson.AddPair(TJSONPair.Create('fingerprint2', Global.SaleModule.NewMember.FingerStr_2)); //예비
      MainJson.AddPair(TJSONPair.Create('xg_user_key', Global.SaleModule.NewMember.XGolfMemberQR));
      MainJson.AddPair(TJSONPair.Create('memo', ''));

      Log.D('NewMember Add JsonText Begin', '신규 등록');
      JsonText := Send_API(mtPost, 'K303_AddMember2', MainJson.ToString);
      Log.D('NewMember Add JsonText End', '신규 등록 완료');

      if JsonText = EmptyStr then
        Exit;

      JsonValue := MainJson.ParseJSONValue(JsonText);
      if (JsonValue as TJSONObject).Get('result_cd').JsonValue.Value = '0000' then
      begin

        if not (JsonValue.FindValue('result_data') is TJSONNull) then
        begin
          JsonValue := (JsonValue as TJSONObject).Get('result_data').JsonValue;

          AMemberInfo.XGolfMember := False;
          AMemberInfo.Code := (JsonValue as TJSONObject).Get('member_no').JsonValue.Value;
          AMemberInfo.CardNo := (JsonValue as TJSONObject).Get('qr_cd').JsonValue.Value;
          AMemberInfo.Name := Global.SaleModule.NewMember.Name;
          AMemberInfo.Tel_Mobile := Global.SaleModule.NewMember.Tel_Mobile;

          if Global.SaleModule.AdvertPopupType = apMember then //판매유도광고
          begin
            if Global.SaleModule.Member.XGolfMember = True then
              AMemberInfo.XGolfMember := True;
          end;

        end;
        Global.SaleModule.Member := AMemberInfo;

        Result := True;
      end
      else
      begin
        Global.SBMessage.ShowMessageModalForm((MainJson.ParseJSONValue(JsonText) as TJSONObject).Get('result_msg').JsonValue.Value);
      end;
    except
      on E: Exception do
      begin
        WriteLog(True, 'ApiLog', 'K303_AddMember2', 'NewMemberAdd', E.Message);
      end;
    end;
  finally
    FreeAndNil(MainJson);
  end;
end;

//chy newmember
function TASPDatabase.AddNewMemberQR: Boolean;
var
  //Json,
  MainJson: TJSONObject;
  JsonValue: TJSONValue;
  JsonText, AUrl: string;
  AMemberInfo: TMemberInfo;
begin
  try
    try
      Result := False;
      JsonText := EmptyStr;
      //Json := TJSONObject.Create;
      MainJson := TJSONObject.Create;

      AUrl := '?store_cd=' + Global.Config.Store.StoreCode +
              '&member_no=' + Global.SaleModule.Member.Code; //'12322';

      Log.D('NewMember QR Begin', '신규등록QR');
      Log.D('NewMember QR Begin', 'K309_MemberQr' + AUrl);
      //WriteLog(False, 'ApiLog', 'K309_MemberQr', 'NewMemberQR', 'K309_MemberQr' + AUrl);
      JsonText := Send_API(mtPost, 'K309_MemberQr' + AUrl, EmptyStr);
      //WriteLog(False, 'ApiLog', 'K309_MemberQr', 'NewMemberQR', LogReplace(JsonText));
      Log.D('NewMember QR End', LogReplace(JsonText));

      if JsonText = EmptyStr then
        Exit;

      JsonValue := MainJson.ParseJSONValue(JsonText);
      if (JsonValue as TJSONObject).Get('result_cd').JsonValue.Value = '0000' then
      begin
        Result := True;
      end
      else
      begin
        Global.SBMessage.ShowMessageModalForm((MainJson.ParseJSONValue(JsonText) as TJSONObject).Get('result_msg').JsonValue.Value);
      end;
    except
      on E: Exception do
      begin
        WriteLog(True, 'ApiLog', 'K309_MemberQr', 'NewMemberQR', E.Message);
        //Log.D('Sale Save JsonText Begin', LogReplace(MainJson.ToString));
        //Log.E('SaveSaleInfo', JsonText);
      end;
    end;
  finally
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
  MainJson, jObj, jObjP: TJSONObject;
  jObjArr, jObjArrP: TJsonArray;
  AUrl, FileExtract: string;

  JsonText: AnsiString;
  Loop, nCnt, nCntP, LoopP: Integer;
  AAdvertise: TAdvertisement;
  AIndy: TIdHTTP;
  mStream: TMemoryStream;
  mStream2: TMemoryStream;
  WeekUse: Integer;

  ListUp, ListTeeboxUp, ListDown: TList<TAdvertisement>;
  ListPopupMember, ListComplex: TList<TAdvertisement>; //2021-06-11 팝업, 복합
  ListEvent, ListReceipt: TList<TAdvertisement>; //이벤트, 영수증

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

        for Index := ListTeeboxUp.Count -1 downto 0 do
          ListTeeboxUp.Delete(Index);

        for Index := ListDown.Count -1 downto 0 do
          ListDown.Delete(Index);

        for Index := ListPopupMember.Count -1 downto 0 do
          ListPopupMember.Delete(Index);

        for Index := ListComplex.Count -1 downto 0 do
          ListComplex.Delete(Index);

        for Index := ListEvent.Count -1 downto 0 do
          ListEvent.Delete(Index);

        for Index := ListReceipt.Count -1 downto 0 do
          ListReceipt.Delete(Index);
      end
      else
      begin
        for Index := Global.SaleModule.AdvertListUp.Count -1 downto 0 do
        begin
          Global.SaleModule.AdvertListUp.Delete(Index);
        end;

        for Index := Global.SaleModule.AdvertListTeeboxUp.Count -1 downto 0 do //실내용
        begin
          Global.SaleModule.AdvertListTeeboxUp.Delete(Index);
        end;

        for Index := Global.SaleModule.AdvertListDown.Count -1 downto 0 do
        begin
          AAdvertise := Global.SaleModule.AdvertListDown[Index];
          AAdvertise.Image.Free;

          Global.SaleModule.AdvertListDown.Delete(Index);
        end;

        for Index := Global.SaleModule.AdvertListPopupMember.Count -1 downto 0 do
        begin
          AAdvertise := Global.SaleModule.AdvertListPopupMember[Index];
          AAdvertise.Image.Free;

          Global.SaleModule.AdvertListPopupMember.Delete(Index);
        end;

        for Index := Global.SaleModule.AdvertListComplex.Count -1 downto 0 do
        begin
          AAdvertise := Global.SaleModule.AdvertListComplex[Index];
          if AAdvertise.FileUrl2 <> EmptyStr then //AAdvertise.FileUrl2 - 이미지 파일
            AAdvertise.Image.Free;

          Global.SaleModule.AdvertListComplex.Delete(Index);
        end;

        for Index := Global.SaleModule.AdvertListEvent.Count -1 downto 0 do
        begin
          AAdvertise := Global.SaleModule.AdvertListEvent[Index];
          AAdvertise.Image.Free;

          Global.SaleModule.AdvertListEvent.Delete(Index);
        end;

        for Index := Global.SaleModule.AdvertListReceipt.Count -1 downto 0 do
        begin
          AAdvertise := Global.SaleModule.AdvertListReceipt[Index];
          AAdvertise.Image.Free;

          Global.SaleModule.AdvertListReceipt.Delete(Index);
        end;

        for Index := 0 to ListUp.Count - 1 do
          Global.SaleModule.AdvertListUp.Add(ListUp[Index]);

        for Index := 0 to ListTeeboxUp.Count - 1 do //실내용
          Global.SaleModule.AdvertListTeeboxUp.Add(ListTeeboxUp[Index]);

        for Index := 0 to ListDown.Count - 1 do
          Global.SaleModule.AdvertListDown.Add(ListDown[Index]);

        for Index := 0 to ListPopupMember.Count - 1 do
          Global.SaleModule.AdvertListPopupMember.Add(ListPopupMember[Index]);

        for Index := 0 to ListComplex.Count - 1 do
          Global.SaleModule.AdvertListComplex.Add(ListComplex[Index]);

        for Index := 0 to ListEvent.Count - 1 do
          Global.SaleModule.AdvertListEvent.Add(ListEvent[Index]);

        for Index := 0 to ListReceipt.Count - 1 do
          Global.SaleModule.AdvertListReceipt.Add(ListReceipt[Index]);

        if ListReceipt.Count > 0 then
        begin
          SetLength(Global.SaleModule.FAdvertReceiptPrintList, ListReceipt.Count);
          SetLength(Global.SaleModule.FAdvertReceiptPopupList, ListReceipt.Count);
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
      ListTeeboxUp := TList<TAdvertisement>.Create;
      ListDown := TList<TAdvertisement>.Create;
      ListPopupMember := TList<TAdvertisement>.Create;
      ListComplex := TList<TAdvertisement>.Create;
      ListEvent := TList<TAdvertisement>.Create;
      ListReceipt := TList<TAdvertisement>.Create;

      AUrl := '?store_cd=' + Global.Config.Store.StoreCode;

      JsonText := Send_API(mtGet, 'K231_AdvertiseList' + AUrl, EmptyStr);
      //Log.D('K231_AdvertiseList', JsonText);

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
            mStream2 := TMemoryStream.Create;

            AAdvertise.Seq := StrToIntDef(jObj.GetValue('ad_seq').Value, 0);
            AAdvertise.Name := jObj.GetValue('ad_nm').Value;
            AAdvertise.FileUrl := jObj.GetValue('file_url').Value;
            AAdvertise.FileUrl2 := jObj.GetValue('file_url2').Value; //C 복합: 이미지, E이벤트참여, R:영수증
            AAdvertise.Position := jObj.GetValue('position_div').Value; //U:상단,D:하단, P:팝업, C:복합, E:이벤트참여, R:영수증

            // 이벤트, 영수증 팝업 2023-03-10
            AAdvertise.MarketingAgreeYn := jObj.GetValue('marketing_agree_yn').Value;   //제3자 마케팅 동의 여부
            AAdvertise.TeeboxStartNm := jObj.GetValue('teebox_start_nm').Value; //영수증 광고 타석지정 시작 번호
            AAdvertise.TeeboxEndNm := jObj.GetValue('teebox_end_nm').Value; // 영수증 광고 타석지정 종료 번호
            AAdvertise.RcpNth := jObj.GetValue('rcp_n_th').Value; // 영수증 N번째 당첨
            AAdvertise.PopupNth := jObj.GetValue('popup_n_th').Value; // 팝업 N번째 당첨
            AAdvertise.QrString := jObj.GetValue('qr_string').Value; // 영수증QR코드분자열 - 2023-05-09

            // 추천회원권 2022-10-14
            AAdvertise.ProductAddYn := jObj.GetValue('product_add_yn').Value;
            jObjArrP := jObj.GetValue('product_add_list') as TJsonArray;
            nCntP := jObjArrP.Size;
            if nCntP > 0 then
            begin
              SetLength(AAdvertise.ProductAddList, nCntP);
              for LoopP := 0 to nCntP - 1 do
              begin
                jObjP := jObjArrP.Get(LoopP) as TJSONObject;
                AAdvertise.ProductAddList[LoopP] := jObjP.GetValue('product_cd').Value;
              end;
            end
            else
            begin
              if AAdvertise.ProductAddYn = 'Y' then
                AAdvertise.ProductAddYn := 'N';
            end;

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

                AIndy.Get(AAdvertise.FileUrl, mStream);

                if (FileExtract = '.avi') or (FileExtract = '.mp4') then
                  AAdvertise.FilePath := ExtractFilePath(ParamStr(0)) + '\Intro\Media\' + jObj.GetValue('upload_nm').Value
                else
                  AAdvertise.FilePath := ExtractFilePath(ParamStr(0)) + '\Intro\' + jObj.GetValue('upload_nm').Value;

                if (Global.SaleModule.AdvertListDown.Count = 0) and (Global.SaleModule.AdvertListUp.Count = 0) then
                begin
                  DeleteFile(AAdvertise.FilePath);
                end;

                if not FileExists(AAdvertise.FilePath) then
                  mStream.SaveToFile(AAdvertise.FilePath);

                if (AAdvertise.Position = 'C') or (AAdvertise.Position = 'P') or (AAdvertise.Position = 'E') or (AAdvertise.Position = 'R') then
                begin
                  if Trim(AAdvertise.FileUrl2) <> EmptyStr then
                  begin
                    FileExtract := ExtractFileExt(AAdvertise.FileUrl2);

                    AIndy.Get(AAdvertise.FileUrl2, mStream2);

                    AAdvertise.FilePath2 := ExtractFilePath(ParamStr(0)) + 'Intro\' + jObj.GetValue('upload_nm2').Value;

                    if not FileExists(AAdvertise.FilePath2) then
                      mStream2.SaveToFile(AAdvertise.FilePath2);
                  end;
                end;

                //2021-06-07 광고구좌 변경/추가
                if AAdvertise.Position = 'D' then //하단
                begin
                  AAdvertise.Image := TBitmap.CreateFromFile(AAdvertise.FilePath);
                  ListDown.Add(AAdvertise)
                end
                else if AAdvertise.Position = 'U' then //상단
                begin
                  if (FileExtract = '.avi') or (FileExtract = '.mp4') then
                  begin
                    ListUp.Add(AAdvertise);
                  end
                  else
                  begin
                    AAdvertise.Image := TBitmap.CreateFromFile(AAdvertise.FilePath);
                    ListTeeboxUp.Add(AAdvertise);
                  end;
                end
                else if AAdvertise.Position = 'P' then //팝업
                begin
                  if (AAdvertise.ProductAddYn = 'Y') and (AAdvertise.FilePath <> EmptyStr) then
                    ListPopupMember.Add(AAdvertise);
                  {
                  if AAdvertise.FilePath2 <> EmptyStr then
                    ListPopupEvent.Add(AAdvertise);
                  }
                end
                else if AAdvertise.Position = 'C' then //복합
                begin
                  ListComplex.Add(AAdvertise);
                end
                else if AAdvertise.Position = 'E' then //이벤트
                begin
                  AAdvertise.Image := TBitmap.CreateFromFile(AAdvertise.FilePath);
                  ListEvent.Add(AAdvertise);
                end
                else if AAdvertise.Position = 'R' then //영수증
                begin
                  AAdvertise.Image := TBitmap.CreateFromFile(AAdvertise.FilePath);
                  ListReceipt.Add(AAdvertise);
                end;
              end;
            end;

            sslIOHandler.Free;
            AIndy.Free;
            mStream.Free;
            mStream2.Free;
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
    FreeAndNil(ListTeeboxUp);
    FreeAndNil(ListDown);
    FreeAndNil(ListPopupMember);
    FreeAndNil(ListComplex);
    FreeAndNil(ListEvent);
    FreeAndNil(ListReceipt);

    FreeAndNil(MainJson);
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

          //2021-03-15 쇼골프 프로모션 할인후 취소시 use_yn Y로 내려옴. result_cd 0000 이면 사용가능이므로 체크 제외처리(강태진대표와 협의,긴급배포위해)->차후 파트너센터 수정필요
          //ADisCount.Use := IfThen(((JsonValue as TJSONObject).Get('result_data').JsonValue as TJSONObject).Get('use_yn').JsonValue.Value <> 'Y', True, False);
          ADisCount.Use := True;

          ADisCount.dc_cond_div := ((JsonValue as TJSONObject).Get('result_data').JsonValue as TJSONObject).Get('dc_cond_div').JsonValue.Value;
          ADisCount.Product_Div := ((JsonValue as TJSONObject).Get('result_data').JsonValue as TJSONObject).Get('product_div').JsonValue.Value;
          ADisCount.Product_Div_Detail := ((JsonValue as TJSONObject).Get('result_data').JsonValue as TJSONObject).Get('seat_product_div').JsonValue.Value;
          ADisCount.Product_Div_Cd := ((JsonValue as TJSONObject).Get('result_data').JsonValue as TJSONObject).Get('seat_product_cd').JsonValue.Value;

          ADisCount.Add := False;
          ADisCount.Sort := False;

          Log.D('ADisCount.Value', LogReplace(IntToStr(ADisCount.Value)));
          Log.D('ADisCount.Name', LogReplace(ADisCount.Name));
          Log.D('ADisCount.dc_cond_div', LogReplace(ADisCount.dc_cond_div));
          Log.D('ADisCount.product_div', LogReplace(ADisCount.Name));
          Log.D('ADisCount.seat_product_div', LogReplace(ADisCount.Product_Div_Detail));
          Log.D('ADisCount.seat_product_cd', LogReplace(ADisCount.Product_Div_Cd));
          Log.D('ADisCount.Gubun', LogReplace(((JsonValue as TJSONObject).Get('result_data').JsonValue as TJSONObject).Get('dc_div').JsonValue.Value));

          if Global.SaleModule.AddCheckDiscountProductDiv(ADisCount.Product_Div, ADisCount.Product_Div_Detail, ADisCount.Product_Div_Cd) = False then
          begin
            Global.SBMessage.ShowMessageModalForm(MSG_PROMOTION + MSG_PROMOTION_OPTION_7);
            Exit;
          end;

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
  //chy bc페이북골프
  else if ACode = 'P04F' then
    //Result := '발급이 취소된 쿠폰 입니다.'
    Result := '사용하실 수 없는 QR코드 입니다.'
  else
    Result := '알수 없는 오류코드(' + ACode + ')';
end;

function TASPDatabase.SendAdvertisCnt(ASeq: string): Boolean;
var
  MainJson, jObj, jObjSub: TJSONObject;
  JsonText: string;
begin
  try
    try
      Result := False;

      MainJson := TJSONObject.Create;

      MainJson.AddPair(TJSONPair.Create('store_cd', Global.Config.Store.StoreCode));
      MainJson.AddPair(TJSONPair.Create('ad_seq', ASeq));

      Log.D('SendAdvertisCnt', LogReplace(MainJson.ToString));
      JsonText := Send_API(mtPost, 'K232_AdvertiseView', MainJson.ToString);

      jObj := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;
      Log.D('SendAdvertisCnt', LogReplace(JsonText));

      if jObj.GetValue('result_cd').Value = '0000' then
      begin
        jObjSub := jObj.GetValue('result_data') as TJSONObject;
        Result := True;
      end;

    except
      on E: Exception do
        Log.E('SendAdvertisCnt', ASeq + ':' + E.Message);
    end;
  finally
    FreeAndNil(MainJson);
    FreeAndNil(jObj);
  end;
end;

function TASPDatabase.SendAdvertisReceiptCnt(ASeq, AType: string): TAdvertReceipt;
var
  MainJson, jObj, jObjSub: TJSONObject;
  JsonText: string;
  AdvertReceipt: TAdvertReceipt;
begin
  try
    try
      MainJson := TJSONObject.Create;

      MainJson.AddPair(TJSONPair.Create('store_cd', Global.Config.Store.StoreCode));
      MainJson.AddPair(TJSONPair.Create('ad_seq', ASeq));
      MainJson.AddPair(TJSONPair.Create('view_div', AType));

      Log.D('SendAdvertisReceiptCnt', LogReplace(MainJson.ToString));
      JsonText := Send_API(mtPost, 'K232_AdvertiseView', MainJson.ToString);

      jObj := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;
      Log.D('SendAdvertisReceiptCnt', LogReplace(JsonText));

      AdvertReceipt.ResultCd := jObj.GetValue('result_cd').Value;
      if jObj.GetValue('result_cd').Value <> '0000' then
      begin
        Result := AdvertReceipt;
        Exit;
      end;

      jObjSub := jObj.GetValue('result_data') as TJSONObject;

      AdvertReceipt.ResultWinYn := jObjSub.GetValue('win_yn').Value;
      AdvertReceipt.ResultNth := jObjSub.GetValue('n_th').Value;

      Result := AdvertReceipt;
    except
      on E: Exception do
        Log.E('SendAdvertisReceiptCnt', ASeq + ':' + E.Message);
    end;
  finally
    FreeAndNil(MainJson);
    FreeAndNil(jObj);
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
      Indy.ConnectTimeout := 10000;
      Indy.ReadTimeout := 10000;

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
        Global.SaleModule.FApiErrorMsg := E.Message;
      end;
    end;
  finally
    Indy.Disconnect;
    Indy.Free;
    SendData.Free;
    RecvData.Free;
  end;
end;

function TASPDatabase.Send_API_Reservation(MethodType: TMethodType; AUrl, AJsonText: string; NotSaveLog: Boolean): AnsiString;
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
        AProductInfo.UseCnt := 0;

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
      AProductInfo.UseCnt := StrToIntDef((JsonValue as TJSONObject).Get('coupon_cnt').JsonValue.Value, 0);
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
label ReSaleSave;
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

      MainJson.AddPair(TJSONPair.Create('xgolf_no', System.StrUtils.IfThen(Global.SaleModule.Member.XGolfMember, Global.SaleModule.Member.XGolfMemberQR, '')));  // ???

      MainJson.AddPair(TJSONPair.Create('receipt_no', Global.SaleModule.RcpAspNo));
      MainJson.AddPair(TJSONPair.Create('prev_receipt_no', ''));  // ???
      MainJson.AddPair(TJSONPair.Create('sale_date', FormatDateTime('yyyymmdd', now)));
      MainJson.AddPair(TJSONPair.Create('sale_time', FormatDateTime('hhnn', now)));

      MainJson.AddPair(TJSONPair.Create('total_amt', CurrToStr(Global.SaleModule.TotalAmt)));

      //chy 2020-12-09 웰빙등 제휴사 할인
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
          ItemObject.AddPair(TJSONPair.Create('pc_seq', System.StrUtils.IfThen(ACard.CardDiscount = 0, '', Global.SaleModule.CardDiscountGetCode)));
          ItemObject.AddPair(TJSONPair.Create('pc_div', System.StrUtils.IfThen(ACard.CardDiscount = 0, '', 'P')));
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
          //ItemObject.AddPair(TJSONPair.Create('buyer_cd', '99999'{APayco.RecvInfo.BuyTypeName}));
          ItemObject.AddPair(TJSONPair.Create('buyer_cd', APayco.RecvInfo.BuyCompanyCode)); //2021-10-13 매입사코드 추가
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

        // G:일반, S:타석, L:라커, O(레슨), V(예약), A(시설)
        if (Global.SaleModule.PaymentAddType = patFacilityPeriod) or (Global.SaleModule.PaymentAddType = patFacilityDay) then
          ItemObject.AddPair(TJSONPair.Create('product_div', 'A'))
        else if (Global.SaleModule.PaymentAddType = patGeneral) then
          ItemObject.AddPair(TJSONPair.Create('product_div', 'G'))
        else
          ItemObject.AddPair(TJSONPair.Create('product_div', 'S'));

        ItemObject.AddPair(TJSONPair.Create('product_cd', Global.SaleModule.BuyProductList[Index].Products.Code));
        ItemObject.AddPair(TJSONPair.Create('sale_qty', CurrToStr(Global.SaleModule.BuyProductList[Index].SaleQty)));
        ItemObject.AddPair(TJSONPair.Create('service_yn', 'N'));
        ItemObject.AddPair(TJSONPair.Create('total_amt', TJSONNumber.Create(Trunc(Global.SaleModule.BuyProductList[Index].SalePrice))));

        //chy 2020-12-09 웰빙등 제휴사 할인
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
        ItemObject.AddPair(TJSONPair.Create('coupon_cnt', IntToStr(Global.SaleModule.BuyProductList[Index].Products.UseCnt)));

        TeeBoxList := TJSONArray.Create;
        ItemObject.AddPair(TJSONPair.Create('teebox', TeeBoxList));

        if (Global.SaleModule.BuyProductList[Index].Products.Product_Div = PRODUCT_TYPE_D) and
           (Global.SaleModule.PaymentAddType = patNone) then
        begin
          TeeBoxItem := TJSONObject.Create;
          TeeBoxItem.AddPair(TJSONPair.Create('teebox_no', IntToStr(Global.SaleModule.TeeBoxInfo.TasukNo)));
          TeeBoxList.Add(TeeBoxItem);
        end;

        //chy 2020-12-09 웰빙등 제휴사 할인
        if Global.SaleModule.allianceCode <> EmptyStr then
          ItemObject.AddPair(TJSONPair.Create('direct_dc_amt', IntToStr(Global.SaleModule.BuyProductList[Index].Products.Price) ))
        else
          ItemObject.AddPair(TJSONPair.Create('direct_dc_amt', '0'));

        DataList.Add(ItemObject);
      end;

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

      ReSaleSave :

      Log.D('Sale Save JsonText Begin', '매출 저장');
      Log.D('Sale Save JsonText Begin', LogReplace(MainJson.ToString));
      WriteLog(False, 'ApiLog', Global.SaleModule.SaleDate, 'SaleSave', LogReplace(MainJson.ToString));
      JsonText := Send_API_Reservation(mtPost, 'K601_ProductSale', MainJson.ToString);
      WriteLog(False, 'ApiLog', Global.SaleModule.SaleDate, 'SaleSave', LogReplace(JsonText));
      Log.D('Sale Save JsonText End', LogReplace(JsonText));

      if JsonText = EmptyStr then
        Exit;

        //2021-03-22 socket 에러시 1회 재시도 추가->2022-03-14 3회 / sleep 100 -> 500로 변경 / 2022-05-18 3회->10회
      if JsonText = 'Socket Error' then
      begin
        inc(nSocketError);

        if nSocketError > 10 then
          Exit;

        sleep(500);
        goto ReSaleSave;
      end;

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

          for Loop := 0 to (ItemValue as TJSONArray).Count - 1 do
          begin
            ParkingProduct.Code := ((ItemValue as TJSONArray).Items[Loop] as TJSONObject).Get('product_cd').JsonValue.Value;
            ParkingProduct.ProductBuyCode := ((ItemValue as TJSONArray).Items[Loop] as TJSONObject).Get('purchase_cd').JsonValue.Value;
            ParkingProduct.Product_Div := ((ItemValue as TJSONArray).Items[Loop] as TJSONObject).Get('seat_product_div').JsonValue.Value;
            ParkingProduct.StartDate := ((ItemValue as TJSONArray).Items[Loop] as TJSONObject).Get('seat_start_day').JsonValue.Value;
            ParkingProduct.EndDate := ((ItemValue as TJSONArray).Items[Loop] as TJSONObject).Get('seat_end_day').JsonValue.Value;
            ParkingProduct.UseWeek := ((ItemValue as TJSONArray).Items[Loop] as TJSONObject).Get('use_div').JsonValue.Value;

            Global.SaleModule.ParkingProductList.Add(ParkingProduct);
          end;
        end;
        Result := True;
      end
      else
      begin
        Global.SBMessage.ShowMessageModalForm((MainJson.ParseJSONValue(JsonText) as TJSONObject).Get('result_msg').JsonValue.Value);
        Global.SaleModule.SaleUploadFail := True;
        // 웰빙클럽 취소 필요
        //Global.SaleModule.WellbeingClub(False, Global.SaleModule.allianceNumber);
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
        // 웰빙클럽 취소 필요
        //Global.SaleModule.WellbeingClub(False, Global.SaleModule.allianceNumber);
      end;
    end;
  finally
    FreeAndNil(MainJson);
  end;
end;

function TASPDatabase.UseFacilityProduct(APurchaseCd: String): Boolean;
label ReSaleSave;
var
  MainJson, jObj: TJSONObject;
  JsonText, AUrl: string;
  AProductInfo: TProductInfo;
begin

  try
    try

      Result := False;
      JsonText := EmptyStr;

      AUrl := 'K316_UseFacilityProduct?store_cd=' + Global.Config.Store.StoreCode +
              '&user_id=' + Global.Config.Store.UserID + '&purchase_cd=' + APurchaseCd;

      Log.D('Sale Save JsonText Begin', '시설상품 사용처리');
      JsonText := Send_API(mtPost, AUrl, EmptyStr);
      Log.D('Sale Save JsonText End', LogReplace(JsonText));

      if JsonText = EmptyStr then
        Exit;

      MainJson := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;

      if '0000' = MainJson.GetValue('result_cd').Value then
      begin
        //if Global.SaleModule.BuyProductList.Count = 1 then
        begin
          jObj := MainJson.GetValue('result_data') as TJSONObject;

          AProductInfo := Global.SaleModule.SelectProduct;
          AProductInfo.Access_Barcode := jObj.GetValue('access_barcode').Value;
          AProductInfo.Access_Control_Nm := jObj.GetValue('access_control_nm').Value;
          Global.SaleModule.SelectProduct := AProductInfo;
        end;

        Result := True;
      end
      else
      begin
        Global.SBMessage.ShowMessageModalForm((MainJson.ParseJSONValue(JsonText) as TJSONObject).Get('result_msg').JsonValue.Value);
      end;

    except
      on E: Exception do
      begin
        Log.E('UseFacilityProduct', JsonText);
        //Global.SBMessage.ShowMessageModalForm('업로드에 실패하였습니다.' + #13#10 + '하단의 영수증 지참 후 반드시' + #13#10 + '프론트에 문의하여 주시기 바랍니다.' + #13#10 + '감사합니다.');
      end;
    end;
  finally
    FreeAndNil(MainJson);
  end;
end;

function TASPDatabase.SearchCardDiscount(ACardNo, ACardAmt, ASeatProductDiv: string; out ACode, AMsg: string): Currency;
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
              '&bin_no=' + ACardNo + '&apply_amt=' + ACardAmt + '&seat_product_div=' + ASeatProductDiv;

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

function TASPDatabase.SendAdvertEvent(ASeq, APhone, AXgolfQR: string): Boolean;
var
  MainJson: TJSONObject;
  JsonText: string;
begin
  try
    try
      Result := False;

      MainJson := TJSONObject.Create;

      MainJson.AddPair(TJSONPair.Create('store_cd', Global.Config.Store.StoreCode));
      MainJson.AddPair(TJSONPair.Create('ad_seq', ASeq));
      MainJson.AddPair(TJSONPair.Create('hp_no', APhone));
      MainJson.AddPair(TJSONPair.Create('user_key', AXgolfQR));

      JsonText := Send_API(mtPost, 'K236_AdvertiseEvent', MainJson.ToString);
      Log.D('SendXGolfEvent', JsonText);

      Result := True;
    except
      on E: Exception do
        Log.E('SendXGolfEvent', E.Message);
    end;
  finally
    FreeAndNil(MainJson);
  end;
end;

function TASPDatabase.SendStamp(AProductCode, APhone: string; out ACode, AMsg: string): Boolean;
var
  MainJson, jObj: TJSONObject;
  JsonText: string;
begin
  try
    try
      Result := False;

      MainJson := TJSONObject.Create;

      MainJson.AddPair(TJSONPair.Create('store_cd', Global.Config.Store.StoreCode));
      MainJson.AddPair(TJSONPair.Create('product_cd', AProductCode));
      MainJson.AddPair(TJSONPair.Create('hp_no', APhone));
      MainJson.AddPair(TJSONPair.Create('save_cnt', '1'));

      Log.D('SendStamp', 'product_cd: ' + AProductCode + ' / hp_no: ' + APhone);
      JsonText := Send_API(mtPost, 'K614_StampSave', MainJson.ToString);
      Log.D('SendStamp', JsonText);

      jObj := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;
      ACode := jObj.GetValue('result_cd').Value;
      AMsg := jObj.GetValue('result_msg').Value;

      Result := True;
    except
      on E: Exception do
        Log.E('SendStamp', E.Message);
    end;
  finally
    FreeAndNil(MainJson);
    FreeAndNil(jObj);
  end;
end;

function TASPDatabase.GetMemberCheckInList(AMemberNo, AXGolf, AQRCode: string; out ACode, AMsg: string): TList<TCheckInInfo>;
var
  Index, j: Integer;
  MainJson, jObj, jObjSub: TJSONObject;
  jObjArr, jObjArrSub: TJsonArray;
  JsonText, AUrl: string;
  rCheckInInfo: TCheckInInfo;
  sLockerEndDay, sLockerEndDayTemp: String;
begin
  try
    Result := TList<TCheckInInfo>.Create;

    AUrl := 'K712_TeeboxCheckin?store_cd=' + Global.Config.Store.StoreCode + '&member_no=' + AMemberNo + '&xgolf_no=' + AXGolf + '&qr_code=' + AQRCode + '&user_id=' + Global.Config.Store.UserID;

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

      //2022-09-22 라카만료일
      if Index = 0 then
      begin
        if not (jObj.FindValue('locker') is TJSONNull) then
        begin
          jObjArrSub := jObj.GetValue('locker') as TJsonArray;
          for j := 0 to jObjArrSub.Count - 1 do
          begin
            if j <> 0 then
              sLockerEndDay := sLockerEndDay + ' ';

            jObjSub := jObjArrSub.Get(j) as TJSONObject;
            sLockerEndDayTemp := jObjSub.GetValue('end_day').Value;
            sLockerEndDayTemp := Copy(sLockerEndDayTemp, 1, 4) + '-' + Copy(sLockerEndDayTemp, 5, 2) + '-' + Copy(sLockerEndDayTemp, 7, 2);
            sLockerEndDay := sLockerEndDay + sLockerEndDayTemp;
          end;
        end;

        Global.SaleModule.FLockerEndDay := sLockerEndDay;
      end;

    end;

  finally
    FreeAndNil(MainJson);;
  end;

end;

function TASPDatabase.GetTeeBoxProductTime(AProductCd: string; out ACode, AMsg: string): TProductInfo;
var
  MainJson, jObj: TJSONObject;
  AProductInfo: TProductInfo;
  JsonText: string;

  sUrl: String;
  sEndTime, CheckTime: String;
begin
  try
    Log.D('GetTeeBoxProductTime', LogReplace(AProductCd));

    if global.Config.ProductTime = False then //배정시간 기준
    begin
      if Global.SaleModule.TeeBoxInfo.BtweenTime <> 0 then //타석 전체 잔여시간
      begin
        sEndTime := StringReplace(Global.SaleModule.TeeBoxInfo.End_Time, ':', '', [rfReplaceAll]);
        if FormatDateTime('hhnn', now) > sEndTime then //익일
          CheckTime := FormatDateTime('yyyymmdd', now + 1) + sEndTime + '00'
        else
          CheckTime := FormatDateTime('yyyymmdd', now) + sEndTime + '00'
      end
      else
      begin
        CheckTime := FormatDateTime('yyyymmddhhnn', now) + '00';
      end;
    end
    else
    begin
      CheckTime := FormatDateTime('yyyymmddhhnn', now) + '00';
    end;

    sUrl := 'K222_TeeBoxProductTime?store_cd=' + Global.Config.Store.StoreCode + '&product_cd=' + AProductCd + '&reserve_datetime=' + CheckTime + '&teebox_no=' + IntToStr(Global.SaleModule.TeeBoxInfo.TasukNo);
    JsonText := Send_API(mtGet, sUrl, EmptyStr);

    if JsonText = EmptyStr then
      Exit;

    Log.D('GetTeeBoxProductTime JsonText', LogReplace(JsonText));

    MainJson := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;
    ACode := MainJson.GetValue('result_cd').Value;
    AMsg := MainJson.GetValue('result_msg').Value;

    if ACode <> '0000' then
      Exit;

    jObj := MainJson.GetValue('result_data') as TJSONObject;

    AProductInfo.Limit_Product_Yn := jObj.GetValue('limit_product_yn').Value = 'Y';
    AProductInfo.UseWeek := jObj.GetValue('use_div').Value;
    AProductInfo.One_Use_Time := jObj.GetValue('one_use_time').Value;
    AProductInfo.Start_Time := jObj.GetValue('start_time').Value;
    AProductInfo.End_Time := jObj.GetValue('end_time').Value;

    Result := AProductInfo;

  finally
    FreeAndNil(MainJson);
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
      rMember.Tel_Mobile := (JsonValue as TJSONObject).Get('hp_no').JsonValue.Value;

      Result := rMember;
    end;

  finally
    FreeAndNil(MainJson);;
    FreeAndNil(JsonValue);
  end;
end;

function TASPDatabase.SetParkingDay(ACarNo: string): Boolean;
var
  MainJson: TJSONObject;
  JsonText, AUrl, ACode: string;
begin
  try
    try
      Result := False;

      AUrl := 'K751_Parking?store_cd=' + Global.Config.Store.StoreCode + '&car_no=' + ACarNo;

      JsonText := Send_API(mtPost, AUrl, EmptyStr);

      if JsonText = EmptyStr then
        Exit;

      Log.D('SetParkingDay JsonText', LogReplace(JsonText));

      MainJson := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;
      ACode := MainJson.GetValue('result_cd').Value;
      //AMsg := MainJson.GetValue('result_msg').Value;

      if ACode = '0000' then
        Result := True;
    except
      on E: Exception do
      begin
        Log.E('SetParkingDay', AUrl);
        Log.E('SetParkingDay', E.Message);
      end;
    end;
  finally
    MainJson.Free;
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
