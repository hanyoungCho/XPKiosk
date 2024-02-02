unit uConfig;

interface

uses
  System.SysUtils,
  System.IOUtils, CPort,
  fx.Logging, uConsts,
  uStruct, fx.Json;

type
  TOAuth = class(TJson)
    Token: string;
    DeviceID: string;
    Key: string;
  end;

  TWellbeing = class(TJson)
    Token: string;
    StoreCD: string;
  end;

  TRefreshClub = class(TJson)
    Token: string;
    StoreCD: string;
  end;

  TADInfo = class(TJson)
    //USE: Boolean;
    IP: string;
    DB_PORT: Integer;
    SERVER_PORT: Integer;
  end;

  TStoreInfo = class(TJson)
    StoreName: string;
    StoreCode: string;
    UserID: string;
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
    // Áö¹®½ÄÀÎ·ü

    // union
    Fingerprint: string;
    EnrollImageQuality: Integer;

    VerifyImageQuality: Integer;
    SecurityLevel: Integer;
    PARKINGBARCODE: Boolean;
    PARKING_DB_IP: string;
    CouponMember: Boolean;

    OAuthURl: String;
    URL: String;
    FileUrl: String;

    PromotionPopup: Boolean;

    ProgramVersion: TProgramVersion;
    OAuth: TOAuth;
    Store: TStoreInfo;
    Print: TPrintInfo;
    Scanner: TScannerInfo;
    RFID: TRFIDInfo;
    Receipt: TReceiptAddInfo;
    Version: TVersionInfo;
    XGolf: TXGolfMember;
    Wellbeing: TWellbeing;
    RefreshClub: TRefreshClub;
    AD: TADInfo;

    constructor Create;
    destructor Destroy; override;

    procedure LoadConfig;

    procedure LoadLocalConfig;   // Local Config_cc.Json
    procedure SaveLocalConfig;   // Local Config_cc.Json
  end;

implementation

{ TConfig }

constructor TConfig.Create;
begin
  OAuth := TOAuth.Create;
  Store := TStoreInfo.Create;
  Print := TPrintInfo.Create;
  Scanner := TScannerInfo.Create;
  RFID := TRFIDInfo.Create;
  Receipt := TReceiptAddInfo.Create;
  Version := TVersionInfo.Create;
  XGolf := TXGolfMember.Create;
  Wellbeing := TWellbeing.Create;
  RefreshClub := TRefreshClub.Create;
  AD := TADInfo.Create;
  LoadConfig;
  Version.MemberVersion := EmptyStr;
  Version.ConfigVersion := EmptyStr;
  Version.ProductVersion := EmptyStr;
  Version.TeeBoxMasterVersion := EmptyStr;
  Version.AdvertisVersion := EmptyStr;
end;

destructor TConfig.Destroy;
begin
  OAuth.Free;
  Store.Free;
  Print.Free;
  Scanner.Free;
  RFID.Free;
  Receipt.Free;
  Version.Free;
  XGolf.Free;
  Wellbeing.Free;
  AD.Free;
  inherited;
end;

function TConfig.GetFileName: string;
begin
  Result := ExtractFilePath(ParamStr(0)) + 'Config_cc.json';
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

end.
