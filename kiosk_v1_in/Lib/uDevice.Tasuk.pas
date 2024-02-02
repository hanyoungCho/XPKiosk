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
//    SearchInfo: Boolean;
    constructor Create;
    destructor Destroy; override;
  end;

  TTeeBox = class
  private
    FTeeBoxInfo: TList<TTeeBoxInfo>;
    FTeeBoxList: TList<TTeeBoxInfo>;
    //FSubTeeBoxList: TList<TTeeBoxInfo>;
    FSampleThread: TSampleThread;
    FUpdateTeeBoxList: TList<TTeeBoxInfo>;

    FFloorList: TList<Integer>;

    //chy 2020-11-04 층명칭
    FFloorNmList: TList<String>;
    FFloorMaxTeeboxCnt: Integer;
  public
    constructor Create;
    destructor Destroy; override;

    procedure GetTeeBoxInfo;
    function GetGMTeeBoxList: Boolean;

    //chy move
    function GetTeeBoxNo(ATeeboxNm: String): Integer;
    function GetTeeBoxRecordInfo(ATeeboxNm: String): TTeeBoxInfo;
    function GetTeeBoxStatus(ATeeboxNm: String): String;

    //2020-12-28 층명칭 변경
    function GetTeeBoxFloorNm(ATeeboxNo: Integer): String;

    property TeeBoxInfo: TList<TTeeBoxInfo> read FTeeBoxInfo write FTeeBoxInfo;
    property TeeBoxList: TList<TTeeBoxInfo> read FTeeBoxList write FTeeBoxList;
    //property SubTeeBoxList: TList<TTeeBoxInfo> read FSubTeeBoxList write FSubTeeBoxList;
    property UpdateTeeBoxList: TList<TTeeBoxInfo> read FUpdateTeeBoxList write FUpdateTeeBoxList;
    property SampleThread: TSampleThread read FSampleThread write FSampleThread;
    property FloorList: TList<Integer> read FFloorList write FFloorList;

    //chy 2020-11-04 층명칭
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
  //SubTeeBoxList := TList<TTeeBoxInfo>.Create;
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

    //if (SubTeeBoxList <> nil) then
      //SubTeeBoxList.Free;

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
  {$IFDEF DEBUG}
//  Log.D('GetTasukInfo', FormatDateTime('yyyymmdd hhnnss', now));
  {$ENDIF}
//  Exit;
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
//    UpdateTeeBoxList := Global.Database.GetTeeBoxPlayingInfo;
    if Global.Config.AD.USE then
      Global.LocalApi.GetTeeBoxPlayingInfo
    else
      Global.Database.GetTeeBoxPlayingInfo;

//    if UpdateTeeBoxList.Count <> 0 then
//    begin
//      for Index := SubTeeBoxList.Count - 1 downto 0 do
//        SubTeeBoxList.Delete(Index);
//
//      SubTeeBoxList := UpdateTeeBoxList;
//    end;
//    Result := SubTeeBoxList.Count <> 0;
//    UpdateTeeBoxList.Clear;
//    UpdateTeeBoxList.Count := 0;

    //chy 2020-11-04 층명칭
    AFloor := 0;
    nFloorMax := 0;
    nTemp := 0;
    if FloorList.Count = 0 then
    begin
      for Index := 0 to TeeBoxInfo.Count - 1 do
      begin
        if AFloor = 0 then
        begin
          AFloor := TeeBoxInfo[Index].High;
          FloorList.Add(AFloor);
          AFloorNm := TeeBoxInfo[Index].FloorNm;
          FloorNmList.Add(AFloorNm);

          inc(nTemp);
        end
        else
        begin
          if AFloor <> TeeBoxInfo[Index].High then
          begin
            if nFloorMax < nTemp then
              nFloorMax := nTemp;
            nTemp := 0;

            AFloor := TeeBoxInfo[Index].High;
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


//chy move
function TTeeBox.GetTeeBoxNo(ATeeboxNm: String): Integer;
var
  Index: Integer;
begin
  Result := -1;
  for Index := 0 to TeeBoxInfo.Count - 1 do
  begin
    if TeeBoxInfo[Index].Mno = ATeeboxNm then
    begin
      Result := TeeBoxInfo[Index].TasukNo;
      break;
    end;
  end;
end;

//chy move
function TTeeBox.GetTeeBoxRecordInfo(ATeeboxNm: String): TTeeBoxInfo;
var
  Index: Integer;
begin

  for Index := 0 to TeeBoxInfo.Count - 1 do
  begin
    if TeeBoxInfo[Index].Mno = ATeeboxNm then
    begin
      Result := TeeBoxInfo[Index];
      break;
    end;
  end;
end;

//chy move
function TTeeBox.GetTeeBoxStatus(ATeeboxNm: String): String;
var
  Index: Integer;
begin
  Result := 'N';

  for Index := 0 to UpdateTeeBoxList.Count - 1 do
  begin
    if UpdateTeeBoxList[Index].Mno = ATeeboxNm then
    begin

      if (UpdateTeeBoxList[Index].ERR <> 0) or (UpdateTeeBoxList[Index].ERR in [7, 8, 9]) or (not UpdateTeeBoxList[Index].Use) then
      begin
        //Text1.Text := '점검중';
      end
      else
      begin
        if UpdateTeeBoxList[Index].Hold then
        begin
          //Text1.Text := '예약중';
        end
        else if (UpdateTeeBoxList[Index].BtweenTime = 0) or ((Trim(UpdateTeeBoxList[Index].Ma_Time) = '0') and (Trim(UpdateTeeBoxList[Index].End_DT) = EmptyStr)) then
        begin
          //Text1.Text := '즉시예약';
          Result := 'Y';
        end
        else if UpdateTeeBoxList[Index].BtweenTime <> 0 then
        begin
          //Text1.Text := '사용중';
        end
        else
        begin
          //Text1.Text := '예약중';
        end;
      end;

      break;
    end;
  end;

end;

//2020-12-28 층명칭
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
//    Suspend;

    Cnt := Cnt + Global.Config.TeeBoxRefreshInterval;
    if Cnt > 40 then //구동확인용-> AD 전송
    begin
      Cnt := 0;
      if Global.Config.Store.ACS = True then
        Synchronize(Global.LocalApi.SendKioskStatus);
    end;
  end;
end;

end.
