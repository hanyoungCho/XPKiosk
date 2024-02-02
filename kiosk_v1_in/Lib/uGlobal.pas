unit uGlobal;

interface

uses
  uCommon, uASPDatabase, uConsts, uLocalApi,
  uDevice.Tasuk, uSaleModule, uStruct, System.Classes, uStore, uConfig;

type
  TGlobal = class
  private
    //FDatabase: TStore;
    FDatabase: TASPDatabase;
    FTeeBox: TTeeBox;
    FSaleModule: TSaleModule;
    FQueryError: Boolean;
    FConfig: TConfig;
    FSBMessage: TMessageForm;
    FLocalApi: TLocalApi;
  public
    Move_TEST: Boolean;

    sUrl: String; //debug구분용

    SelectboxHandle: THandle; //newmember 핸들
    MainHandle: THandle;

    constructor Create;
    destructor Destroy; override;

    property Config: TConfig read FConfig write FConfig;
    property QueryError: Boolean read FQueryError write FQueryError;
    //property Database: TStore read FDatabase write FDatabase;
    property Database: TASPDatabase read FDatabase write FDatabase;
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
  Move_TEST := False;
  {$IFDEF DEBUG}
    //Move_TEST := True;
  {$ENDIF}

  Config := TConfig.Create;
  Config.ProgramVersion := pvASP;

  Database := TASPDatabase.Create;

  TeeBox := TTeeBox.Create;
  SaleModule := TSaleModule.Create;
  SBMessage := TMessageForm.Create;
  LocalApi := TLocalApi.Create;

end;

destructor TGlobal.Destroy;
begin
  TeeBox.Free;

  Database.Free;

  SaleModule.Free;
  SBMessage.Free;
  LocalApi.Free;

  Config.Free;
  inherited;
end;

end.
