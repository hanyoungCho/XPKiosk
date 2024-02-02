unit uDevice.Tasuk;

interface

uses
  uStruct, System.Classes, System.SysUtils, System.DateUtils,
  Uni, System.Generics.Collections;

type
  TSampleThread = class(TThread)
  private
//    Cnt: Integer;
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
    FSubTeeBoxList: TList<TTeeBoxInfo>;
    FSampleThread: TSampleThread;
    FUpdateTeeBoxList: TList<TTeeBoxInfo>;

    FFloorList: TList<Integer>;

    // 2020-11-04 Ãþ¸íÄª
    FFloorNmList: TList<String>;
    FFloorMaxTeeboxCnt: Integer;
  public
    constructor Create;
    destructor Destroy; override;

    procedure GetTeeBoxInfo;
    function GetGMTeeBoxList: Boolean;

    // move
    function GetTeeBoxNo(ATeeboxNm: String): Integer;
    function GetTeeBoxRecordInfo(ATeeboxNm: String): TTeeBoxInfo;
    function GetTeeBoxStatus(ATeeboxNm: String): String;

    //2020-12-28 Ãþ¸íÄª º¯°æ
    function GetTeeBoxFloorNm(ATeeboxNo: Integer): String;

    property TeeBoxInfo: TList<TTeeBoxInfo> read FTeeBoxInfo write FTeeBoxInfo;
    property TeeBoxList: TList<TTeeBoxInfo> read FTeeBoxList write FTeeBoxList;
    property SubTeeBoxList: TList<TTeeBoxInfo> read FSubTeeBoxList write FSubTeeBoxList;
    property UpdateTeeBoxList: TList<TTeeBoxInfo> read FUpdateTeeBoxList write FUpdateTeeBoxList;
    property SampleThread: TSampleThread read FSampleThread write FSampleThread;
    property FloorList: TList<Integer> read FFloorList write FFloorList;

    // 2020-11-04 Ãþ¸íÄª
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
  SubTeeBoxList := TList<TTeeBoxInfo>.Create;
  UpdateTeeBoxList := TList<TTeeBoxInfo>.Create;
  SampleThread := TSampleThread.Create;

  FFloorList := TList<Integer>.Create;
  FFloorNmList := TList<String>.Create;
end;

destructor TTeeBox.Destroy;
begin
  FFloorList.Free;
  FFloorNmList.Free;

//  if TeeBoxInfo <> nil then
//   TeeBoxInfo.Free;

//  if TeeBoxList <> nil then
//    TeeBoxList.Free;

//  if SubTeeBoxList <> nil then
//    SubTeeBoxList.Free;

//  if UpdateTeeBoxList <> nil then
//    UpdateTeeBoxList.Free;

//  FreeAndNil(FSampleThread);
    FSampleThread.Terminate;
//  TeeBoxInfo.Free;
//  if TeeBoxList <> nil then
//    TeeBoxList.Free;
//
//  if SubTeeBoxList <> nil then
//    SubTeeBoxList.Free;
//
//  if UpdateTeeBoxList <> nil then
//    UpdateTeeBoxList.Free;

  SampleThread.Free;

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
  AFloor, nFloorMax, nTemp: Integer;
begin
  try
    //if Global.Config.AD.USE then
      Global.LocalApi.GetTeeBoxPlayingInfo;
    //else
      //Global.Database.GetTeeBoxPlayingInfo;

    AFloor := 0;
    nFloorMax := 0;
    nTemp := 0;

    if FloorList.Count = 0 then
    begin
      FloorList.Add(1);
      FloorList.Add(2);
      FloorList.Add(3);
      FloorNmList.Add('1~23');
      FloorNmList.Add('25~44 / ¸ÖÆ¼Å¸¼®');
      FloorNmList.Add('ÆÛÆÃ/º¡Ä¿');
      FFloorMaxTeeboxCnt := 24;
    end;

  except
  end;
end;

// move
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

// move
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

// move
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
        //Text1.Text := 'Á¡°ËÁß';
      end
      else
      begin
        if UpdateTeeBoxList[Index].Hold then
        begin
          //Text1.Text := '¿¹¾àÁß';
        end
        else if (UpdateTeeBoxList[Index].BtweenTime = 0) or ((Trim(UpdateTeeBoxList[Index].Ma_Time) = '0') and (Trim(UpdateTeeBoxList[Index].End_DT) = EmptyStr)) then
        begin
          //Text1.Text := 'Áï½Ã¿¹¾à';
          Result := 'Y';
        end
        else if UpdateTeeBoxList[Index].BtweenTime <> 0 then
        begin
          //Text1.Text := '»ç¿ëÁß';
        end
        else
        begin
          //Text1.Text := '¿¹¾àÁß';
        end;
      end;

      break;
    end;
  end;

end;

//2020-12-28 Ãþ¸íÄª
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
    Synchronize(Global.TeeBox.GetTeeBoxInfo);
    Sleep(Global.Config.TeeBoxRefreshInterval * 1000);
//    Suspend;
  end;
end;

end.
