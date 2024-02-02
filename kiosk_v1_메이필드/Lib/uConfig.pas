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
    MayfieldURL: string;
    NexpaURL: string;
  end;

  TOAuth = class(TJson)
    Token: string;
    DeviceID: string;
    Key: string;
  end;

  TLocalDBInfo = class(TJson)
    DB_PORT: Integer;
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

    MemberInfoDownLoadDateTime: String; //ȸ������ ������ ��û �ð�

    ProductTime: Boolean; //Ÿ����ǰ ���ýð�, false:Ÿ������ð�, true:Ÿ�����ýð�(����)

    //�����νı�
    Fingerprint: string;
    EnrollImageQuality: Integer; // �������η�
    VerifyImageQuality: Integer;
    SecurityLevel: Integer;

    //������
    PARKING_DAY: Boolean; //����Ÿ�� �������

    //ProgramVersion: TProgramVersion;

    Partners: TPartners;
    OAuth: TOAuth;
    Store: TStoreInfo;
    Print: TPrintInfo;
    Scanner: TScannerInfo;
    RFID: TRFIDInfo;
    Receipt: TReceiptAddInfo;
    Version: TVersionInfo;
    XGolf: TXGolfMember;

    LocalDBInfo: TLocalDBInfo;

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

  LocalDBInfo := TLocalDBInfo.Create;

  //ȯ�漳������ ���ÿ��� �ε�
  //LoadConfig;
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

  LocalDBInfo.Free;

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
  Result := ExtractFilePath(ParamStr(0)) + 'Config_mf.json';
end;

procedure TConfig.LoadConfigV1;
begin

  Partners.OAuthURl := ConfigIni.ReadString('PARTNERS', 'OAuthURl', '');
  Partners.URL := ConfigIni.ReadString('PARTNERS', 'URL', '');
  Partners.FileUrl := ConfigIni.ReadString('PARTNERS', 'FileUrl', '');
  Partners.MayfieldURL := ConfigIni.ReadString('PARTNERS', 'MayfieldURL', '');
  Partners.NexpaURL := ConfigIni.ReadString('PARTNERS', 'NexpaURL', '');

  OAuth.DeviceID := ConfigIni.ReadString('OAUTH', 'DeviceID', '');
  OAuth.Key := ConfigIni.ReadString('OAUTH', 'Key', '');
  Store.StoreCode := ConfigIni.ReadString('OAUTH', 'StoreCode', '');
  Store.UserID := ConfigIni.ReadString('OAUTH', 'UserID', '');
  Store.DeviceNo := ConfigIni.ReadString('OAUTH', 'DeviceNo', '');

  {$IFDEF RELEASE}
  LocalDBInfo.DB_PORT := ConfigIni.ReadInteger('AD', 'DB_PORT', 3306);
  {$ENDIF}
  {$IFDEF DEBUG}
  LocalDBInfo.DB_PORT := 3307;
  {$ENDIF}

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
  Scanner.Port := 3;
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

  MemberInfoDownLoadDateTime := ConfigIni.ReadString('STORE', 'MemberInfoDownLoadDateTime', '');

  TeeBoxRefreshInterval := ConfigIni.ReadInteger('STORE', 'TeeBoxRefreshInterval', 5);

  //�����νı�
  Fingerprint := ConfigIni.ReadString('STORE', 'Fingerprint', '');
  EnrollImageQuality := ConfigIni.ReadInteger('STORE', 'EnrollImageQuality', 70);
  VerifyImageQuality := ConfigIni.ReadInteger('STORE', 'VerifyImageQuality', 50);
  SecurityLevel := ConfigIni.ReadInteger('STORE', 'SecurityLevel', 7);

  //������
  PARKING_DAY := ConfigIni.ReadString('STORE', 'PARKING_DAY', 'N') = 'Y';

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
