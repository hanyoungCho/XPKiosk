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

  TWellbeing = class(TJson)
    Use: Boolean;
    Token: string;
    StoreCD: string;
  end;

  TBCPaybookGolf = class(TJson)
    Use: Boolean;
  end;

  TRefreshClub = class(TJson)
    Use: Boolean;
    Token: string;
    StoreCD: string;
  end;

  TTheLoungeMembers = class(TJson)
    Use: Boolean;
    UserId: string;
    Password: string;
  end;

  TIkozen = class(TJson)
    Use: Boolean;
    StoreCD: string;
  end;

  TSmartix = class(TJson)
    Use: Boolean;
    clientCompSeq: string;
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
    EndTimeIgnoreYn: String; //영업종료시간 미적용-배정시
    StoreCloseStartTime: string;
    StoreCloseEndTime: string;
    //PromotionPopup: string;

    ACS: Boolean; //ACS사용여부-파트너센터 매장정보
    StampYn: Boolean;

    Emergency: String;
    DNSFail: String;
  end;

  TPrintInfo = class(TJson)
    Port: Integer;
    BaudRate: Integer;
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
    StoreType: String;
    ColumnCount: Integer;
    MobileOAuth: Boolean;
    MobileOAuthPW: Boolean;
    MainPosIP: string;
    MainPosPort: Integer;
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

    Promotion: Boolean; //프로모션 2022-03-22
    Alliance: Boolean; //제휴사
    AllianceWellbeing: Boolean; //웰빙선택버튼-타석선택시
    AllianceSmartix: Boolean; //스마틱스-온라인구매
    NewMember: Boolean; //신규회원등록

    //AdvertMember: Boolean; //광고추가구좌-회원권판매광고 -> K231_AdvertiseList -> product_add_yn 대체
    //AdvertEvent: Boolean; //광고추가구좌-이벤트용 광고(XGolf 응모 등)
    //AdvertEventXGolf: Boolean; //광고추가구좌-이벤트용 광고시 XGolf 회원인증여부

    ProductTime: Boolean; //타석상품 선택시간, false:타석종료시간(배정시간), true:타석선택시간(현재/주문시간)

    TeeboxAdvice: Boolean; //타석선택 안내문구

    //지문인식기
    FingerprintUse: String;
    Fingerprint: string;
    EnrollImageQuality: Integer; // 지문식인률
    VerifyImageQuality: Integer;
    SecurityLevel: Integer;
    FingerprintQRUse: String; //QR 사용시 지문인식여부

    //주차권
    PARKINGBARCODE: Boolean;
    PARKING_DB_IP: string;
    PARKING_DAY: Boolean; //일일타석 주차등록

    //사우나 이용권
    SAUNABARCODE: Boolean;
    SAUNABARCODE_Member: Boolean;
    SAUNABARCODE_NonMember: Boolean;

    //부대시설 이용권
    ACCESSBARCODE: Boolean;

    //상단 타석선택 여부 - 빅토리아 2021-09-06
    TeeboxTopMapNoSelect: Boolean; //N:선택가능, Y:선택불가능
    ActiveFloor: Integer; //시작층

    AppCard: Boolean; //간편결제-할인체크여부
    AppCard_CONA: Boolean; //간편결제- 코나카드
    AppCard_BC: Boolean; //간편결제- BC 페이북

    CheckInUse: Boolean; //체크인 버튼 활성화 2022-06-30
    SystemShutdown: Boolean; //윈도우 종료 2022-09-01

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

    PaymentPG: Boolean; //PG사용여부
    PaymentAdd: Boolean; // 터석상품외 결제 사용여부
    PaymentAddType: String; // 결제종류- 0:게임비결제, 1:시설, 2:일반

    //제휴사
    Wellbeing: TWellbeing;
    BCPaybookGolf: TBCPaybookGolf;
    RefreshClub: TRefreshClub;
    TheLoungeMembers: TTheLoungeMembers;
    Ikozen: TIkozen;
    Smartix: TSmartix;

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

uses
  uFunction;

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

  //제휴사
  Wellbeing := TWellbeing.Create;
  BCPaybookGolf := TBCPaybookGolf.Create;
  RefreshClub := TRefreshClub.Create;
  TheLoungeMembers := TTheLoungeMembers.Create;
  Ikozen := TIkozen.Create;
  Smartix := TSmartix.Create;

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

  //제휴사
  Wellbeing.Free;
  BCPaybookGolf.Free;
  RefreshClub.Free;
  TheLoungeMembers.Free;
  Ikozen.Free;
  Smartix.Free;

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
  Result := ExtractFilePath(ParamStr(0)) + 'Config_v1.json';
end;

procedure TConfig.LoadConfigV1;
var
  sStr: String;
begin

  Partners.OAuthURl := ConfigIni.ReadString('PARTNERS', 'OAuthURl', '');
  Partners.URL := ConfigIni.ReadString('PARTNERS', 'URL', '');
  Partners.FileUrl := ConfigIni.ReadString('PARTNERS', 'FileUrl', '');

  OAuth.DeviceID := ConfigIni.ReadString('OAUTH', 'DeviceID', '');
  //OAuth.Key := ConfigIni.ReadString('OAUTH', 'Key', '');
  sStr := ConfigIni.ReadString('OAUTH', 'Key', '');
  OAuth.Key := StrDecrypt(Trim(sStr));

  Store.StoreCode := ConfigIni.ReadString('OAUTH', 'StoreCode', '');
  Store.UserID := ConfigIni.ReadString('OAUTH', 'UserID', '');
  Store.DeviceNo := ConfigIni.ReadString('OAUTH', 'DeviceNo', '');

  AD.USE := ConfigIni.ReadString('AD', 'USE', 'N') = 'Y';
  AD.SERVER_PORT := ConfigIni.ReadInteger('AD', 'SERVER_PORT', 3308);

  AD.DB_PORT := ConfigIni.ReadInteger('AD', 'DB_PORT', 3306);

  {$IFDEF RELEASE}
  AD.IP := ConfigIni.ReadString('AD', 'IP', '');

  Print.Port := ConfigIni.ReadInteger('Print', 'Port', 0);
  Print.BaudRate := ConfigIni.ReadInteger('Print', 'BaudRate', 0);
  Print.PrintType := ConfigIni.ReadString('Print', 'PrintType', '');

  Scanner.Port := ConfigIni.ReadInteger('SCANNER', 'Port', 0);
  Scanner.BaudRate := ConfigIni.ReadInteger('SCANNER', 'BaudRate', 0);

  RFID.Port := ConfigIni.ReadInteger('RFID', 'Port', 0);
  RFID.BaudRate := ConfigIni.ReadInteger('RFID', 'BaudRate', 0);
  {$ENDIF}
  {$IFDEF DEBUG}
  AD.IP := '192.168.0.212';

  Print.Port := 3;
  Print.BaudRate := 115200;
  Print.PrintType := 'SEWOO';

  Scanner.Port := 5;
  //Scanner.BaudRate := 115200;
  Scanner.BaudRate := 9600;

  RFID.Port := 0;
  RFID.BaudRate := 115200;
  {$ENDIF}

  StoreType := ConfigIni.ReadString('STORE', 'StoreType', '0'); //0:실회, 1:실내, 2:안양CC
  ColumnCount := ConfigIni.ReadInteger('STORE', 'ColumnCount', 5);
  MobileOAuth := ConfigIni.ReadString('STORE', 'MobileOAuth', 'N') = 'Y'; // 실내일 경우만 사용, 전화번호 인증
  MobileOAuthPW := ConfigIni.ReadString('STORE', 'MobileOAuthPW', 'N') = 'Y'; // 번호인증시 뒤 4자리 * 표시
  PrePare_Min := ConfigIni.ReadString('STORE', 'PrePare_Min', '');
  PrepareUse := ConfigIni.ReadString('STORE', 'PrepareUse', 'N') = 'Y';
  MainPosIP := ConfigIni.ReadString('STORE', 'MainPosIP', '');
  MainPosPort := ConfigIni.ReadInteger('STORE', 'MainPosPort', 6001);
  UseItem420Size := ConfigIni.ReadString('STORE', 'UseItem420Size', 'Y') = 'Y';
  CouponMember := ConfigIni.ReadString('STORE', 'CouponMember', 'N') = 'Y';
  PromotionPopup := ConfigIni.ReadString('STORE', 'PromotionPopup', 'N') = 'Y';
  XGolfStore := ConfigIni.ReadString('STORE', 'XGolfStore', 'N') = 'Y';
  XGolfStoreMember := ConfigIni.ReadString('STORE', 'XGolfStoreMember', 'N') = 'Y';
  XGolfStoreNonMember := ConfigIni.ReadString('STORE', 'XGolfStoreNonMember', 'N') = 'Y';
  Promotion := ConfigIni.ReadString('STORE', 'Promotion', 'N') = 'Y';
  Alliance := ConfigIni.ReadString('STORE', 'Alliance', 'N') = 'Y';
  AllianceWellbeing := ConfigIni.ReadString('STORE', 'AllianceWellbeing', 'N') = 'Y';
  AllianceSmartix := ConfigIni.ReadString('STORE', 'AllianceSmartix', 'N') = 'Y';
  NewMember := ConfigIni.ReadString('STORE', 'NewMember', 'N') = 'Y';

  //AdvertMember := ConfigIni.ReadString('STORE', 'AdvertMember', 'N') = 'Y';
  //AdvertEvent := ConfigIni.ReadString('STORE', 'AdvertEvent', 'N') = 'Y';
  //AdvertEventXGolf := ConfigIni.ReadString('STORE', 'AdvertEventXGolf', 'N') = 'Y';

  ProductTime := ConfigIni.ReadString('STORE', 'ProductTime', 'N') = 'Y';

  // 타석현황 메세지. 일일타석, 회원 상품 선택 깜빡임
  TeeboxAdvice := ConfigIni.ReadString('STORE', 'TeeboxAdvice', 'N') = 'Y';

  TeeBoxRefreshInterval := ConfigIni.ReadInteger('STORE', 'TeeBoxRefreshInterval', 5);

  //지문인식기
  FingerprintUse := ConfigIni.ReadString('STORE', 'FingerprintUse', 'Y');
  if (StoreType = '1') and (MobileOAuth = True) then
    FingerprintUse := 'N';

  Fingerprint := ConfigIni.ReadString('STORE', 'Fingerprint', '');
  EnrollImageQuality := ConfigIni.ReadInteger('STORE', 'EnrollImageQuality', 70);
  VerifyImageQuality := ConfigIni.ReadInteger('STORE', 'VerifyImageQuality', 50);
  SecurityLevel := ConfigIni.ReadInteger('STORE', 'SecurityLevel', 7);
  FingerprintQRUse := ConfigIni.ReadString('STORE', 'FingerprintQRUse', 'N');

  //주차권
  PARKINGBARCODE := ConfigIni.ReadString('STORE', 'PARKINGBARCODE', 'N') = 'Y';
  PARKING_DB_IP := ConfigIni.ReadString('STORE', 'PARKING_DB_IP', '');
  PARKING_DAY := ConfigIni.ReadString('STORE', 'PARKING_DAY', 'N') = 'Y';

  //사우나 이용권
  SAUNABARCODE := ConfigIni.ReadString('STORE', 'SAUNABARCODE', 'N') = 'Y';
  SAUNABARCODE_Member := ConfigIni.ReadString('STORE', 'SAUNABARCODE_Member', 'N') = 'Y';
  SAUNABARCODE_NonMember := ConfigIni.ReadString('STORE', 'SAUNABARCODE_NonMember', 'N') = 'Y';

  //부대시설 이용권
  ACCESSBARCODE := ConfigIni.ReadString('STORE', 'ACCESSBARCODE', 'N') = 'Y';

  //상단 타석현황 미선택-2021-09-06
  TeeboxTopMapNoSelect := ConfigIni.ReadString('STORE', 'TeeboxTopMapNoSelect', 'N') = 'Y';

  //시작층-2021-11-12
  ActiveFloor := ConfigIni.ReadInteger('STORE', 'ActiveFloor', 1);

  //간편결제-할인체크여부 2022-02-23
  AppCard := ConfigIni.ReadString('STORE', 'AppCard', 'N') = 'Y';
  AppCard_CONA := ConfigIni.ReadString('STORE', 'AppCard_CONA', 'N') = 'Y';
  AppCard_BC := ConfigIni.ReadString('STORE', 'AppCard_BC', 'N') = 'Y';

  CheckInUse := ConfigIni.ReadString('STORE', 'CheckInUse', 'N') = 'Y';
  SystemShutdown := ConfigIni.ReadString('STORE', 'SystemShutdown', 'N') = 'Y';

  PaymentPG := ConfigIni.ReadString('STORE', 'PaymentPG', 'N') = 'Y';
  PaymentAdd := ConfigIni.ReadString('STORE', 'PaymentAdd', 'N') = 'Y';
  PaymentAddType := ConfigIni.ReadString('STORE', 'PaymentAddType', '');

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

  Wellbeing.Use := ConfigIni.ReadString('WELLBEING', 'USE', 'N') = 'Y';
  Wellbeing.Token := ConfigIni.ReadString('WELLBEING', 'TOKEN', '');
  Wellbeing.StoreCD := ConfigIni.ReadString('WELLBEING', 'StoreCD', '');

  BCPaybookGolf.Use := ConfigIni.ReadString('BCPAYBOOKGOLF', 'USE', 'N') = 'Y';

  RefreshClub.Use := ConfigIni.ReadString('REFRESHCLUB', 'USE', 'N') = 'Y';
  RefreshClub.Token := ConfigIni.ReadString('REFRESHCLUB', 'TOKEN', '');
  RefreshClub.StoreCD := ConfigIni.ReadString('REFRESHCLUB', 'StoreCD', '');

  TheLoungeMembers.Use := ConfigIni.ReadString('THELOUNGEMEMBERS', 'USE', 'N') = 'Y';
  TheLoungeMembers.UserId := ConfigIni.ReadString('THELOUNGEMEMBERS', 'UserId', '');
  TheLoungeMembers.Password := ConfigIni.ReadString('THELOUNGEMEMBERS', 'Password', '');

  Ikozen.Use := ConfigIni.ReadString('IKOZEN', 'USE', 'N') = 'Y';
  Ikozen.StoreCD := ConfigIni.ReadString('IKOZEN', 'StoreCD', '');

  Smartix.Use := ConfigIni.ReadString('Smartix', 'USE', 'N') = 'Y';
  Smartix.clientCompSeq := ConfigIni.ReadString('Smartix', 'clientCompSeq', '');
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
