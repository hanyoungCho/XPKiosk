unit uASPDatabase;

interface

uses
  IdGlobal, FMX.Graphics, IdCoderMIME, InIFiles, IdSSL, IdSSLOpenSSL, Vcl.Dialogs,
  uStruct, System.Variants, System.SysUtils, System.Classes,
  Generics.Collections, Uni, IdHTTP, JSON, EncdDecd, IdURI, uConsts;

//리얼서버 : https://xtouch.xpartners.co.kr
//테스트서버 : https://test.xpartners.co.kr

type
  TASPDatabase = class
  private
    FAuthorization: AnsiString;
    //FByteStr: RawByteString;
    FUTF8Str: UTF8String;

    function Send_API(MethodType: TMethodType; AUrl, AJsonText: string; NotSaveLog: Boolean = False): AnsiString;

    //타석기AD미사용시 배정예약, AD상관없이 매출저장
    //function Send_API_Reservation(MethodType: TMethodType; AUrl, AJsonText: string; NotSaveLog: Boolean = False): AnsiString;

    function GetVersion(AUrl: string): string;
  public
    sslIOHandler: TIdSSLIOHandlerSocketOpenSSL;
    constructor Create;
    destructor Destroy; override;

    // OAuth 인증
    function OAuth_Certification: Boolean;

    // 광고 목록 조회
    function SendAdvertisCnt(ASeq: string): Boolean;
    procedure SearchAdvertiseFile;

    property Authorization: AnsiString read FAuthorization write FAuthorization;
    property UTF8Str: UTF8String read FUTF8Str write FUTF8Str;
  end;

implementation

uses
  uGlobal, uSaleModule, fx.Logging, uFunction, uCommon;

{ TASPDatabase }

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
        showmessage('인증오류 입니다. 단말기 정보를 확인해 주세요');
      end;
    end;

  finally
    FreeAndNil(jObj);
    Indy.Free;
    SendData.Free;
    RecvData.Free;
  end;
end;



procedure TASPDatabase.SearchAdvertiseFile;
var
  SR: TSearchRec;
  SFile : string;
  sPath: string;
  AAdvertise: TAdvertisement;
  bFile: Boolean;
begin
  sPath := '';

  try
    bFile := False;
    sPath := ExtractFilePath(ParamStr(0)) + 'Intro\Media\';
    if FindFirst(sPath + '*.*', faAnyFile, SR) = 0 then begin

      repeat
        if (SR.Attr <> faDirectory) and (SR.Name <> '.') and (SR.Name <> '..') then begin // 디렉토리는 제외하고
          SFile := '';
          SFile := sPath + SR.Name;

          if FileExists(SFile) then begin // 파일 존재 체크
            AAdvertise.FilePath := SFile;
            Global.SaleModule.AdvertisementListUp.Add(AAdvertise);
            bFile := True;
          end;

        end;
      until (FindNext(SR) <> 0) or (bFile = True);
      FindClose(SR);
    end;

    bFile := False;
    sPath := ExtractFilePath(ParamStr(0)) + 'Intro\';
    if FindFirst(sPath + '*.*', faAnyFile, SR) = 0 then begin

      repeat
        if (SR.Attr <> faDirectory) and (SR.Name <> '.') and (SR.Name <> '..') then begin // 디렉토리는 제외하고
          SFile := '';
          SFile := sPath + SR.Name;

          if FileExists(SFile) then begin // 파일 존재 체크
            AAdvertise.FilePath := SFile;
            AAdvertise.Image := TBitmap.CreateFromFile(AAdvertise.FilePath);
            Global.SaleModule.AdvertisementListDown.Add(AAdvertise);
            bFile := True;
          end;

        end;
      until (FindNext(SR) <> 0) or (bFile = True);
      FindClose(SR);
    end;

  except
    on E: Exception do begin
      //WriteLogDayFile(LogFileName, 'Deletefiles Error Message : ' + E.Message);
    end;
  end;

end;


function TASPDatabase.SendAdvertisCnt(ASeq: string): Boolean;
var
  MainJson: TJSONObject;
  JsonText: string;
begin

  Exit;

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
    Indy.Disconnect;
    Indy.Free;
    SendData.Free;
    RecvData.Free;
  end;
end;

{
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
}

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
    //MainJson.Free;;
    //JsonValue.Free;
  end;
end;

end.
