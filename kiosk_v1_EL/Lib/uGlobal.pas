unit uGlobal;

interface

uses
  uCommon, uELoomApi, uConsts, uLocalApi,
  uDevice.Tasuk, uSaleModule, uStruct, System.Classes, uConfig;

type
  TGlobal = class
  private
    FELoomApi: TELoomApi;
    FTeeBox: TTeeBox;
    FSaleModule: TSaleModule;
    FQueryError: Boolean;
    FConfig: TConfig;
    FSBMessage: TMessageForm;
    FLocalApi: TLocalApi;
  public
    sUrl: String; //debug±¸ºÐ¿ë

    constructor Create;
    destructor Destroy; override;

    property Config: TConfig read FConfig write FConfig;
    property QueryError: Boolean read FQueryError write FQueryError;
    property ELoomApi: TELoomApi read FELoomApi write FELoomApi;
    property TeeBox: TTeeBox read FTeeBox write FTeeBox;
    property SaleModule: TSaleModule read FSaleModule write FSaleModule;
    property SBMessage: TMessageForm read FSBMessage write FSBMessage;
    property LocalApi: TLocalApi read FLocalApi write FLocalApi;
  end;

var
  Global: TGlobal;

implementation

{ TGlobal }

constructor TGlobal.Create;
begin
  Config := TConfig.Create;

  ELoomApi := TELoomApi.Create;

  TeeBox := TTeeBox.Create;
  SaleModule := TSaleModule.Create;
  SBMessage := TMessageForm.Create;
  LocalApi := TLocalApi.Create;

end;

destructor TGlobal.Destroy;
begin
  TeeBox.Free;

  ELoomApi.Free;

  SaleModule.Free;
  SBMessage.Free;
  LocalApi.Free;

  Config.Free;
  inherited;
end;

end.
