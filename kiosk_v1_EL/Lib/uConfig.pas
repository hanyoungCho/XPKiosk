unit uConfig;

interface

uses
  System.SysUtils,
  System.IOUtils, CPort,
  fx.Logging, uConsts,
  uStruct, fx.Json, IniFiles, Variants;

type
  TPartners = class(TJson)
    ERoomUrl: String;
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
    AdminPassword: string;
    StoreStartTime: string;
    StoreEndTime: string;
  end;

  //지문인식기
  TFingerInfo = class(TJson)
    Fingerprint: string;
    EnrollImageQuality: Integer; // 지문식인률
    VerifyImageQuality: Integer;
    SecurityLevel: Integer;
  end;

  TPrintInfo = class(TJson)
    Port: Integer;
    BaudRate: Integer;
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
    NoDevice: Boolean;
    TeeBoxRefreshInterval: Integer;
    KioskError: Boolean; //인트로 화면 점검중 표시
    PrePare_Min: string;
    CouponMember: Boolean;

    ProductTime: Boolean; //타석상품 선택시간, false:타석종료시간, true:타석선택시간(현재)
    NoTeeboxTicket: Boolean; //타석배정표 미출력

    Partners: TPartners;
    OAuth: TOAuth;
    Store: TStoreInfo;
    Finger: TFingerInfo;
    Print: TPrintInfo;
    Scanner: TScannerInfo;
    //RFID: TRFIDInfo;
    Receipt: TReceiptAddInfo;
    Version: TVersionInfo;

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
  Finger := TFingerInfo.Create;
  Print := TPrintInfo.Create;
  Scanner := TScannerInfo.Create;
  //RFID := TRFIDInfo.Create;
  Receipt := TReceiptAddInfo.Create;
  Version := TVersionInfo.Create;

  AD := TADInfo.Create;

  //chy config
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
  Finger.Free;
  Print.Free;
  Scanner.Free;
  //RFID.Free;
  Receipt.Free;
  Version.Free;

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
  Result := ExtractFilePath(ParamStr(0)) + 'Config_EL.json';
end;

procedure TConfig.LoadConfigV1;
begin

  Partners.ERoomUrl := ConfigIni.ReadString('PARTNERS', 'ERoomURL', '');

  AD.USE := ConfigIni.ReadString('AD', 'USE', 'N') = 'Y';
  {$IFDEF RELEASE}
  AD.IP := ConfigIni.ReadString('AD', 'IP', '');
  AD.DB_PORT := ConfigIni.ReadInteger('AD', 'DB_PORT', 3306);
  {$ENDIF}
  {$IFDEF DEBUG}
  AD.IP := '192.168.0.81';
  AD.DB_PORT := 3306;
  {$ENDIF}
  AD.SERVER_PORT := ConfigIni.ReadInteger('AD', 'SERVER_PORT', 3308);

  OAuth.DeviceID := ConfigIni.ReadString('OAUTH', 'DeviceID', '');
  OAuth.Key := ConfigIni.ReadString('OAUTH', 'Key', '');
  Store.StoreCode := ConfigIni.ReadString('OAUTH', 'StoreCode', '');
  Store.UserID := ConfigIni.ReadString('OAUTH', 'UserID', '');
  Store.DeviceNo := ConfigIni.ReadString('OAUTH', 'DeviceNo', '');

  Store.AdminPassword := ConfigIni.ReadString('STORE', 'AdminPassword', '');

  PrePare_Min := ConfigIni.ReadString('STORE', 'PrePare_Min', '');
  //PrepareUse := ConfigIni.ReadString('STORE', 'PrepareUse', 'N') = 'Y';
  //UseItem420Size := ConfigIni.ReadString('STORE', 'UseItem420Size', 'Y') = 'Y';

  CouponMember := ConfigIni.ReadString('STORE', 'CouponMember', 'N') = 'Y';
  ProductTime := ConfigIni.ReadString('STORE', 'ProductTime', 'N') = 'Y';
  NoTeeboxTicket := ConfigIni.ReadString('STORE', 'NoTeeboxTicket', 'N') = 'Y';

  TeeBoxRefreshInterval := ConfigIni.ReadInteger('STORE', 'TeeBoxRefreshInterval', 5);

  //지문인식기
  Finger.Fingerprint := ConfigIni.ReadString('Finger', 'Fingerprint', '');
  Finger.EnrollImageQuality := ConfigIni.ReadInteger('Finger', 'EnrollImageQuality', 70);
  Finger.VerifyImageQuality := ConfigIni.ReadInteger('Finger', 'VerifyImageQuality', 50);
  Finger.SecurityLevel := ConfigIni.ReadInteger('Finger', 'SecurityLevel', 7);

  {$IFDEF RELEASE}
  Print.Port := ConfigIni.ReadInteger('Print', 'Port', 0);
  Print.BaudRate := ConfigIni.ReadInteger('Print', 'BaudRate', 0);
  //Print.PrintType := ConfigIni.ReadString('Print', 'PrintType', '');
  {$ENDIF}
  {$IFDEF DEBUG}
  Print.Port := 0;
  Print.BaudRate := 115200;
  //Print.PrintType := 'SEWOO';
  {$ENDIF}

  {$IFDEF RELEASE}
  Scanner.Port := ConfigIni.ReadInteger('SCANNER', 'Port', 0);
  Scanner.BaudRate := ConfigIni.ReadInteger('SCANNER', 'BaudRate', 0);
  {$ENDIF}
  {$IFDEF DEBUG}
  Scanner.Port := 3;
  Scanner.BaudRate := 115200;
  //Scanner.BaudRate := 9600;
  {$ENDIF}

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
