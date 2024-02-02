unit uDevice.Tasuk;

interface

uses
  uStruct, System.Classes, System.SysUtils, System.DateUtils,
  Uni, System.Generics.Collections;

type
  TSampleThread = class(TThread)
  private
    Cnt: Integer;
    FClose: Boolean;
  protected
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  TTeeBox = class
  private
    FTeeBoxInfo: TList<TTeeBoxInfo>;
    FTeeBoxList: TList<TTeeBoxInfo>;
    FSampleThread: TSampleThread;
    FUpdateTeeBoxList: TList<TTeeBoxInfo>;

    FFloorList: TList<Integer>;

    //층명칭
    FFloorNmList: TList<String>;
    FFloorMaxTeeboxCnt: Integer;
  public
    constructor Create;
    destructor Destroy; override;

    procedure GetTeeBoxInfo;
    function GetGMTeeBoxList: Boolean;

    function GetTeeBoxFloorNm(ATeeboxNo: Integer): String;

    property TeeBoxInfo: TList<TTeeBoxInfo> read FTeeBoxInfo write FTeeBoxInfo;
    property TeeBoxList: TList<TTeeBoxInfo> read FTeeBoxList write FTeeBoxList;
    property UpdateTeeBoxList: TList<TTeeBoxInfo> read FUpdateTeeBoxList write FUpdateTeeBoxList;
    property SampleThread: TSampleThread read FSampleThread write FSampleThread;
    property FloorList: TList<Integer> read FFloorList write FFloorList;

    property FloorNmList: TList<String> read FFloorNmList write FFloorNmList;
    property FloorMaxTeeboxCnt: Integer read FFloorMaxTeeboxCnt write FFloorMaxTeeboxCnt;

  end;

implementation

uses
  uGlobal, uFunction, Form.Select.Box, fx.Logging;

{ Tasuk }

constructor TTeeBox.Create;
begin
  TeeBoxInfo := TList<TTeeBoxInfo>.Create;

  TeeBoxList := TList<TTeeBoxInfo>.Create;
  UpdateTeeBoxList := TList<TTeeBoxInfo>.Create;
  SampleThread := TSampleThread.Create;

  FFloorList := TList<Integer>.Create;
  FFloorNmList := TList<String>.Create; //층명칭

  SampleThread.FClose := False;
end;

destructor TTeeBox.Destroy;
var
  I: Integer;
begin
  try
    SampleThread.FClose := True;

    FFloorNmList.Free; //층명칭
    FFloorList.Free;

    SampleThread.Terminate;
    SampleThread.Free; //보류

    //TeeBoxList := UpdateTeeBoxList; -> 상태갱신시
    if (UpdateTeeBoxList <> nil) then
      UpdateTeeBoxList.Free;

    if (TeeBoxList <> nil) then
    begin
      //참조변수라 메모리 해제가 않됨. 참조 않되도록 수정이 필요...운영에는 상관없음.
      TeeBoxList := nil;
      TeeBoxList.Free;
    end;

    if (TeeBoxInfo <> nil) then
      TeeBoxInfo.Free;

  except
    on E: Exception do
      Log.E('TTeeBox.Destroy', E.Message);
  end;

  inherited;
end;

procedure TTeeBox.GetTeeBoxInfo;
begin
  if Global.SaleModule.TeeBoxInfo.TasukNo = -1 then
  begin
    GetGMTeeBoxList;
  end;
end;

function TTeeBox.GetGMTeeBoxList: Boolean;
var
  Index, AFloor, nFloorMax, nTemp: Integer;
  ATasukInfo: TTeeBoxInfo;
  ADateTime, EndDateTime: TDateTime;
  EndTime: string;
  AFloorNm: String;
begin

  try
    Global.LocalApi.GetTeeBoxPlayingInfo;

    AFloor := 0;
    nFloorMax := 0;
    nTemp := 0;
    if FloorList.Count = 0 then
    begin
      for Index := 0 to TeeBoxInfo.Count - 1 do
      begin

        if TeeBoxInfo[Index].Use = False then
          Continue;

        if AFloor = 0 then
        begin
          AFloor := TeeBoxInfo[Index].FloorCd;
          FloorList.Add(AFloor);
          AFloorNm := TeeBoxInfo[Index].FloorNm;
          FloorNmList.Add(AFloorNm);

          inc(nTemp);
        end
        else
        begin
          if AFloor <> TeeBoxInfo[Index].FloorCd then
          begin
            if nFloorMax < nTemp then
              nFloorMax := nTemp;
            nTemp := 0;

            AFloor := TeeBoxInfo[Index].FloorCd;
            FloorList.Add(AFloor);
            AFloorNm := TeeBoxInfo[Index].FloorNm;
            FloorNmList.Add(AFloorNm);

            inc(nTemp);
          end
          else
          begin
            inc(nTemp);
          end;
        end;
      end;

      if nFloorMax < nTemp then
        nFloorMax := nTemp;

      FFloorMaxTeeboxCnt := nFloorMax;
    end;

  except
    on E: Exception do
      Log.E('GetGMTeeBoxList', E.Message);
  end;
end;

function TTeeBox.GetTeeBoxFloorNm(ATeeboxNo: Integer): String;
var
  Index: Integer;
begin
  Result := '';
  for Index := 0 to TeeBoxInfo.Count - 1 do
  begin
    if TeeBoxInfo[Index].TasukNo = ATeeboxNo then
    begin
      Result := TeeBoxInfo[Index].FloorNm;
      break;
    end;
  end;
end;

{ TSampleThread }

constructor TSampleThread.Create;
begin
  Cnt := 0;
  FreeOnTerminate := False;
  inherited Create(True);
//  Cnt := 0;
end;

destructor TSampleThread.Destroy;
begin
//  Suspend;
  inherited;
end;

procedure TSampleThread.Execute;
begin
  inherited;

  while not Terminated do
  begin
    if FClose = True then
      Exit;

    Synchronize(Global.TeeBox.GetTeeBoxInfo);
    Sleep(Global.Config.TeeBoxRefreshInterval * 1000);
  end;

end;

end.
