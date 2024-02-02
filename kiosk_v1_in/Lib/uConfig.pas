unit uConfig;

interface

uses
  System.SysUtils,
  System.IOUtils, CPort,
  fx.Logging, uConsts,
  uStruct, fx.Json, IniFiles, Variants;

type
  TPartners = class(TJson)
    OAuthURl: string;
    URL: string;
    FileUrl: string;
  end;

  TOAuth = class(TJson)
    Token: string;
    DeviceID: string;
    Key: string;
  end;

  TADInfo = class(TJson)
    USE: Boolean;
    IP: string;
    DB_PORT: Integer;
    SERVER_PORT: Integer;
  end;

  TStoreInfo = class(TJson)
    StoreName: string;
    StoreCode: string;
    UserID: string;
    DeviceNo: string;
    BossName: string;
    PosNo: string;
    Tel: string;
    Addr: string;
    BizNo: string;
    VanTID: string;
    VanCode: Integer;
    AdminPassword: string;
    StoreStartTime: string;
    StoreEndTime: string;
    StoreCloseStartTime: string;
    StoreCloseEndTime: string;
    //PromotionPopup: string;

    ACS: Boolean; //ACS사용여부-파트너센터 매장정보
  end;

  TPrintInfo = class(TJson)
    Port: Integer;
    BaudRate: Integer;

    //chy sewoo
    PrintType: String;
  end;

  TXGolfMember = class(TJson)
    Gubun: Integer;
    Value: Integer;
  end;

  TScannerInfo = class(TJson)
    Port: Integer;
    BaudRate: Integer;
  end;

  TRFIDInfo = class(TJson)
    Port: Integer;
    BaudRate: Integer;
  end;

  TReceiptAddInfo = class(TJson)
    Top1: string;
    Top2: string;
    Top3: string;
    Top4: string;
    Bottom1: string;
    Bottom2: string;
    Bottom3: string;
    Bottom4: string;
  end;

  TVersionInfo = class(TJson)
    MemberVersion: string;
    ConfigVersion: string;
    ProductVersion: string;
    TeeBoxMasterVersion: string;
    AdvertisVersion: string;
  end;

  TConfig = class(TJson)
  private
    function GetFileName: string;
    function GetFileNameV1: string;
  public
    MainPosIP: string;
    UseItem420Size: Boolean;
    NoPayModule: Boolean;
    NoDevice: Boolean;
    TeeBoxRefreshInterval: Integer;
    Sensitivity: Integer;
    KioskError: Boolean;
    PrePare_Min: string;
    PrepareUse: Boolean;
    CouponMember: Boolean;
    PromotionPopup: Boolean;

    XGolfStore: Boolean; //XGolf 가맹점 - 회원인증
    XGolfStoreMember: Boolean; // 기간,쿠폰 회원인증
    XGolfStoreNonMember: Boolean; //일일타석 회원인증

    AdvertMember: Boolean; //광고추가구좌-회원권판매광고
    AdvertEvent: Boolean; //광고추가구좌-이벤트용 광고(XGolf 응모 등)
    AdvertEventXGolf: Boolean; //광고추가구좌-이벤트용 광고시 XGolf 회원인증여부

    ProductTime: Boolean; //타석상품 선택시간, false:타석종료시간(배정시간), true:타석선택시간(현재/주문시간)

    //지문인식기
    Fingerprint: string;
    EnrollImageQuality: Integer; // 지문식인률
    VerifyImageQuality: Integer;
    SecurityLevel: Integer;

    ProgramVersion: TProgramVersion;

    Partners: TPartners;
    OAuth: TOAuth;
    Store: TStoreInfo;
    Print: TPrintInfo;
    Scanner: TScannerInfo;
    RFID: TRFIDInfo;
    Receipt: TReceiptAddInfo;
    Version: TVersionInfo;
    XGolf: TXGolfMember;

    AD: TADInfo;

    ConfigIni: TIniFile;

    constructor Create;
    destructor Destroy; override;

    procedure LoadConfig;
    procedure LoadConfigV1;

    procedure SetConfig(const ASection, AItem: string; const ANewValue: Variant);

    procedure LoadLocalConfig;   // Local Config.Json -> ini 변경에 따라 미사용
    procedure SaveLocalConfig;   // Local Config.Json -> 환경정보 저장용
  end;

implementation

{ TConfig }

constructor TConfig.Create;
begin
  Partners := TPartners.Create;
  OAuth := TOAuth.Create;
  Store := TStoreInfo.Create;
  Print := TPrintInfo.Create;
  Scanner := TScannerInfo.Create;
  RFID := TRFIDInfo.Create;

  Receipt := TReceiptAddInfo.Create;
  Version := TVersionInfo.Create;
  XGolf := TXGolfMember.Create;

  AD := TADInfo.Create;

  ConfigIni := TIniFile.Create(GetFileNameV1);
  LoadConfigV1;

  Version.MemberVersion := EmptyStr;
  Version.ConfigVersion := EmptyStr;
  Version.ProductVersion := EmptyStr;
  Version.TeeBoxMasterVersion := EmptyStr;
  Version.AdvertisVersion := EmptyStr;
end;

destructor TConfig.Destroy;
begin
  Partners.Free;
  OAuth.Free;
  Store.Free;
  Print.Free;
  Scanner.Free;
  RFID.Free;

  Receipt.Free;
  Version.Free;
  XGolf.Free;

  AD.Free;

  ConfigIni.Free;

  inherited;
end;

function TConfig.GetFileName: string;
begin
  Result := ExtractFilePath(ParamStr(0)) + 'Config.json';
end;

procedure TConfig.LoadConfig;
begin
  LoadLocalConfig;
  if TeeBoxRefreshInterval = 0 then
    TeeBoxRefreshInterval := 30;
end;

procedure TConfig.LoadLocalConfig;
var
  Json: string;
begin
  if TFile.Exists(GetFileName) then
  begin
    try
      Json := TFile.ReadAllText(GetFileName, TEncoding.UTF8);
      TJsonReadWriter.JsonToObject<TConfig>(Json, Self);
    finally

    end;
  end;
end;

procedure TConfig.SaveLocalConfig;
var
  Json: string;
begin
  Json := TJsonReadWriter.ObjectToJson<TConfig>(Self);
  TFile.WriteAllText(GetFileName, Json, TEncoding.UTF8);
end;

function TConfig.GetFileNameV1: string;
begin
  Result := ExtractFilePath(ParamStr(0)) + 'Config_in.json';
end;

procedure TConfig.LoadConfigV1;
begin

  Partners.OAuthURl := ConfigIni.ReadString('PARTNERS', 'OAuthURl', '');
  Partners.URL := ConfigIni.ReadString('PARTNERS', 'URL', '');
  Partners.FileUrl := ConfigIni.ReadString('PARTNERS', 'FileUrl', '');

  OAuth.DeviceID := ConfigIni.ReadString('OAUTH', 'DeviceID', '');
  OAuth.Key := ConfigIni.ReadString('OAUTH', 'Key', '');
  Store.StoreCode := ConfigIni.ReadString('OAUTH', 'StoreCode', '');
  Store.UserID := ConfigIni.ReadString('OAUTH', 'UserID', '');
  Store.DeviceNo := ConfigIni.ReadString('OAUTH', 'DeviceNo', '');

  AD.USE := ConfigIni.ReadString('AD', 'USE', 'N') = 'Y';
  //AD.USE := False;
  {$IFDEF RELEASE}
  AD.IP := ConfigIni.ReadString('AD', 'IP', '');
  AD.DB_PORT := ConfigIni.ReadInteger('AD', 'DB_PORT', 3306);
  {$ENDIF}
  {$IFDEF DEBUG}
  AD.IP := '192.168.0.81';
  AD.DB_PORT := 3307;
  {$ENDIF}
  AD.SERVER_PORT := ConfigIni.ReadInteger('AD', 'SERVER_PORT', 3308);

  {$IFDEF RELEASE}
  Print.Port := ConfigIni.ReadInteger('Print', 'Port', 0);
  Print.BaudRate := ConfigIni.ReadInteger('Print', 'BaudRate', 0);
  Print.PrintType := ConfigIni.ReadString('Print', 'PrintType', '');
  {$ENDIF}
  {$IFDEF DEBUG}
  Print.Port := 0;
  Print.BaudRate := 115200;
  Print.PrintType := 'SEWOO';
  {$ENDIF}

  {$IFDEF RELEASE}
  Scanner.Port := ConfigIni.ReadInteger('SCANNER', 'Port', 0);
  Scanner.BaudRate := ConfigIni.ReadInteger('SCANNER', 'BaudRate', 0);
  {$ENDIF}
  {$IFDEF DEBUG}
  Scanner.Port := 0;
  Scanner.BaudRate := 115200;
  {$ENDIF}

  {$IFDEF RELEASE}
  RFID.Port := ConfigIni.ReadInteger('RFID', 'Port', 0);
  RFID.BaudRate := ConfigIni.ReadInteger('RFID', 'BaudRate', 0);
  {$ENDIF}
  {$IFDEF DEBUG}
  RFID.Port := 0;
  RFID.BaudRate := 115200;
  {$ENDIF}

  PrePare_Min := ConfigIni.ReadString('STORE', 'PrePare_Min', '');
  PrepareUse := ConfigIni.ReadString('STORE', 'PrepareUse', 'N') = 'Y';
  MainPosIP := ConfigIni.ReadString('STORE', 'MainPosIP', '');
  UseItem420Size := ConfigIni.ReadString('STORE', 'UseItem420Size', 'Y') = 'Y';

  CouponMember := ConfigIni.ReadString('STORE', 'CouponMember', 'N') = 'Y';
  PromotionPopup := ConfigIni.ReadString('STORE', 'PromotionPopup', 'N') = 'Y';
  XGolfStore := ConfigIni.ReadString('STORE', 'XGolfStore', 'N') = 'Y';
  XGolfStoreMember := ConfigIni.ReadString('STORE', 'XGolfStoreMember', 'N') = 'Y';
  XGolfStoreNonMember := ConfigIni.ReadString('STORE', 'XGolfStoreNonMember', 'N') = 'Y';

  AdvertMember := ConfigIni.ReadString('STORE', 'AdvertMember', 'N') = 'Y';
  AdvertEvent := ConfigIni.ReadString('STORE', 'AdvertEvent', 'N') = 'Y';
  AdvertEventXGolf := ConfigIni.ReadString('STORE', 'AdvertEventXGolf', 'N') = 'Y';

  ProductTime := ConfigIni.ReadString('STORE', 'ProductTime', 'N') = 'Y'; //주문시간,배정시간

  TeeBoxRefreshInterval := ConfigIni.ReadInteger('STORE', 'TeeBoxRefreshInterval', 5);

  //지문인식기
  Fingerprint := ConfigIni.ReadString('STORE', 'Fingerprint', '');
  EnrollImageQuality := ConfigIni.ReadInteger('STORE', 'EnrollImageQuality', 70);
  VerifyImageQuality := ConfigIni.ReadInteger('STORE', 'VerifyImageQuality', 50);
  SecurityLevel := ConfigIni.ReadInteger('STORE', 'SecurityLevel', 7);

  Store.BizNo := ConfigIni.ReadString('STORE', 'BizNo', '');
  Store.VanTID := ConfigIni.ReadString('STORE', 'VanTID', '');
  Store.VanCode := ConfigIni.ReadInteger('STORE', 'VanCode', 0);
  Store.AdminPassword := ConfigIni.ReadString('STORE', 'AdminPassword', '');

  Receipt.Top1 := ConfigIni.ReadString('RECEIPT', 'TOP1', '');
  Receipt.Top2 := ConfigIni.ReadString('RECEIPT', 'TOP2', '');
  Receipt.Top3 := ConfigIni.ReadString('RECEIPT', 'TOP3', '');
  Receipt.Top4 := ConfigIni.ReadString('RECEIPT', 'TOP4', '');
  Receipt.Bottom1 := ConfigIni.ReadString('RECEIPT', 'BOTTOM1', '');
  Receipt.Bottom2 := ConfigIni.ReadString('RECEIPT', 'BOTTOM2', '');
  Receipt.Bottom3 := ConfigIni.ReadString('RECEIPT', 'BOTTOM3', '');
  Receipt.Bottom4 := ConfigIni.ReadString('RECEIPT', 'BOTTOM4', '');

end;

procedure TConfig.SetConfig(const ASection, AItem: string; const ANewValue: Variant);
begin
  case VarType(ANewValue) of
    varInteger:
      ConfigIni.WriteInteger(ASection, AItem, ANewValue);
    varBoolean:
      ConfigIni.WriteBool(ASection, AItem, ANewValue);
  else
    ConfigIni.WriteString(ASection, AItem, ANewValue);
  end;
end;



end.
