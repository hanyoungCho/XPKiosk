unit uGlobal;

interface

uses
  uCommon, uMFErpApi, uXPErpApi, uConsts, uLocalDB,
  uDevice.Tasuk, uSaleModule, uStruct, System.Classes, uConfig;

type
  TGlobal = class
  private
    FMFErpApi: TMFErpApi;
    FXPErpApi: TXPErpApi;
    FLocalDB: TLocalDB;

    FTeeBox: TTeeBox;
    FSaleModule: TSaleModule;
    FQueryError: Boolean;
    FConfig: TConfig;
    FSBMessage: TMessageForm;
  public
    sUrl: String; //debug±¸ºÐ¿ë

    constructor Create;
    destructor Destroy; override;

    property Config: TConfig read FConfig write FConfig;
    property QueryError: Boolean read FQueryError write FQueryError;

    property TeeBox: TTeeBox read FTeeBox write FTeeBox;
    property SaleModule: TSaleModule read FSaleModule write FSaleModule;
    property SBMessage: TMessageForm read FSBMessage write FSBMessage;

    property MFErpApi: TMFErpApi read FMFErpApi write FMFErpApi;
    property XPErpApi: TXPErpApi read FXPErpApi write FXPErpApi;
    property LocalDB: TLocalDB read FLocalDB write FLocalDB;
  end;

var
  Global: TGlobal;

implementation

{ TGlobal }

constructor TGlobal.Create;
begin

  Config := TConfig.Create;
  //Config.ProgramVersion := pvASP;

  MFErpApi := TMFErpApi.Create;
  XPErpApi := TXPErpApi.Create;
  LocalDB := TLocalDB.Create;

  TeeBox := TTeeBox.Create;
  SaleModule := TSaleModule.Create;
  SBMessage := TMessageForm.Create;

end;

destructor TGlobal.Destroy;
begin
  TeeBox.Free;

  MFErpApi.Free;
  XPErpApi.Free;
  LocalDB.Free;

  SaleModule.Free;
  SBMessage.Free;

  Config.Free;

  inherited;
end;

end.
