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
    EndTimeIgnoreYn: String; //��������ð� ������-������
    StoreCloseStartTime: string;
    StoreCloseEndTime: string;
    //PromotionPopup: string;

    ACS: Boolean; //ACS��뿩��-��Ʈ�ʼ��� ��������
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

    XGolfStore: Boolean; //XGolf ������ - ȸ������
    XGolfStoreMember: Boolean; // �Ⱓ,���� ȸ������
    XGolfStoreNonMember: Boolean; //����Ÿ�� ȸ������

    Promotion: Boolean; //���θ�� 2022-03-22
    Alliance: Boolean; //���޻�
    AllianceWellbeing: Boolean; //�������ù�ư-Ÿ�����ý�
    AllianceSmartix: Boolean; //����ƽ��-�¶��α���
    NewMember: Boolean; //�ű�ȸ�����

    //AdvertMember: Boolean; //�����߰�����-ȸ�����Ǹű��� -> K231_AdvertiseList -> product_add_yn ��ü
    //AdvertEvent: Boolean; //�����߰�����-�̺�Ʈ�� ����(XGolf ���� ��)
    //AdvertEventXGolf: Boolean; //�����߰�����-�̺�Ʈ�� ����� XGolf ȸ����������

    ProductTime: Boolean; //Ÿ����ǰ ���ýð�, false:Ÿ������ð�(�����ð�), true:Ÿ�����ýð�(����/�ֹ��ð�)

    TeeboxAdvice: Boolean; //Ÿ������ �ȳ�����

    //�����νı�
    FingerprintUse: String;
    Fingerprint: string;
    EnrollImageQuality: Integer; // �������η�
    VerifyImageQuality: Integer;
    SecurityLevel: Integer;
    FingerprintQRUse: String; //QR ���� �����νĿ���

    //������
    PARKINGBARCODE: Boolean;
    PARKING_DB_IP: string;
    PARKING_DAY: Boolean; //����Ÿ�� �������

    //��쳪 �̿��
    SAUNABARCODE: Boolean;
    SAUNABARCODE_Member: Boolean;
    SAUNABARCODE_NonMember: Boolean;

    //�δ�ü� �̿��
    ACCESSBARCODE: Boolean;

    //��� Ÿ������ ���� - ���丮�� 2021-09-06
    TeeboxTopMapNoSelect: Boolean; //N:���ð���, Y:���úҰ���
    ActiveFloor: Integer; //������

    AppCard: Boolean; //�������-����üũ����
    AppCard_CONA: Boolean; //�������- �ڳ�ī��
    AppCard_BC: Boolean; //�������- BC ���̺�

    CheckInUse: Boolean; //üũ�� ��ư Ȱ��ȭ 2022-06-30
    SystemShutdown: Boolean; //������ ���� 2022-09-01

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

    PaymentPG: Boolean; //PG��뿩��
    PaymentAdd: Boolean; // �ͼ���ǰ�� ���� ��뿩��
    PaymentAddType: String; // ��������- 0:���Ӻ����, 1:�ü�, 2:�Ϲ�

    //���޻�
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

    procedure LoadLocalConfig;   // Local Config.Json -> ini ���濡 ���� �̻��
    procedure SaveLocalConfig;   // Local Config.Json -> ȯ������ �����
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

  //���޻�
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

  //���޻�
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

  StoreType := ConfigIni.ReadString('STORE', 'StoreType', '0'); //0:��ȸ, 1:�ǳ�, 2:�Ⱦ�CC
  ColumnCount := ConfigIni.ReadInteger('STORE', 'ColumnCount', 5);
  MobileOAuth := ConfigIni.ReadString('STORE', 'MobileOAuth', 'N') = 'Y'; // �ǳ��� ��츸 ���, ��ȭ��ȣ ����
  MobileOAuthPW := ConfigIni.ReadString('STORE', 'MobileOAuthPW', 'N') = 'Y'; // ��ȣ������ �� 4�ڸ� * ǥ��
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

  // Ÿ����Ȳ �޼���. ����Ÿ��, ȸ�� ��ǰ ���� ������
  TeeboxAdvice := ConfigIni.ReadString('STORE', 'TeeboxAdvice', 'N') = 'Y';

  TeeBoxRefreshInterval := ConfigIni.ReadInteger('STORE', 'TeeBoxRefreshInterval', 5);

  //�����νı�
  FingerprintUse := ConfigIni.ReadString('STORE', 'FingerprintUse', 'Y');
  if (StoreType = '1') and (MobileOAuth = True) then
    FingerprintUse := 'N';

  Fingerprint := ConfigIni.ReadString('STORE', 'Fingerprint', '');
  EnrollImageQuality := ConfigIni.ReadInteger('STORE', 'EnrollImageQuality', 70);
  VerifyImageQuality := ConfigIni.ReadInteger('STORE', 'VerifyImageQuality', 50);
  SecurityLevel := ConfigIni.ReadInteger('STORE', 'SecurityLevel', 7);
  FingerprintQRUse := ConfigIni.ReadString('STORE', 'FingerprintQRUse', 'N');

  //������
  PARKINGBARCODE := ConfigIni.ReadString('STORE', 'PARKINGBARCODE', 'N') = 'Y';
  PARKING_DB_IP := ConfigIni.ReadString('STORE', 'PARKING_DB_IP', '');
  PARKING_DAY := ConfigIni.ReadString('STORE', 'PARKING_DAY', 'N') = 'Y';

  //��쳪 �̿��
  SAUNABARCODE := ConfigIni.ReadString('STORE', 'SAUNABARCODE', 'N') = 'Y';
  SAUNABARCODE_Member := ConfigIni.ReadString('STORE', 'SAUNABARCODE_Member', 'N') = 'Y';
  SAUNABARCODE_NonMember := ConfigIni.ReadString('STORE', 'SAUNABARCODE_NonMember', 'N') = 'Y';

  //�δ�ü� �̿��
  ACCESSBARCODE := ConfigIni.ReadString('STORE', 'ACCESSBARCODE', 'N') = 'Y';

  //��� Ÿ����Ȳ �̼���-2021-09-06
  TeeboxTopMapNoSelect := ConfigIni.ReadString('STORE', 'TeeboxTopMapNoSelect', 'N') = 'Y';

  //������-2021-11-12
  ActiveFloor := ConfigIni.ReadInteger('STORE', 'ActiveFloor', 1);

  //�������-����üũ���� 2022-02-23
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
