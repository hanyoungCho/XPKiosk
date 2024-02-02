unit uLocalApi;

interface

uses
  Generics.Collections, System.Variants, uConsts, JSON,
  IdTCPClient, IdGlobal, System.SysUtils, Uni, MySQLUniProvider, Data.DB, uStruct, System.StrUtils;

type
  TLocalApi = class
    private
      FConnection: TUniConnection;
      FMySQLUniProvider: TMySQLUniProvider;
      FStoreProc: TUniStoredProc;

      FParkingConnection: TUniConnection;
      FParkingMySQLUniProvider: TMySQLUniProvider;
      FParkingStoreProc: TUniStoredProc;

      function SendApi(AJsonText: string): string;

      function QueryExec(AQuery: TUniQuery; ASQL: string; AParam: array of Variant): TUniQuery;
      procedure QueryRun(AQuery: TUniQuery);
      function ProcExec(AStoredProc: TUniStoredProc; AProcedureName: string; AParam: array of Variant): TUniStoredProc;
    public
      constructor Create;
      destructor Destroy; override;

      // 타석기 AD
      function DBConnection: Boolean;
      
      // 가동 상황
      function GetTeeBoxPlayingInfo: TList<TTeeBoxInfo>;

      //chy move
      function GetTeeBoxReserveInfo(AReserveNo: String): TTeeBoxInfo;
      function GetTeeBoxNextReserveInfo(ATeeBoxInfo: TTeeBoxInfo): Boolean;

      // 홀드 등록 및 취소
      function TeeboxHold(IsHold: Boolean = False): Boolean;
      function TeeboxMoveHold(IsHold: Boolean = False): Boolean;

      // 예약 등록
      function TeeBoxListReservation(AJsonText: string): string;

      // 체크인
      function TeeBoxCheckIn: Boolean;

      // 주차권 출력
      function ParkingPrintCheck(AReserveNo: String): string;

      // 상품 사용내역 조회
      function GetProductUseInfo(ABuyCode, AProductCode: string): Integer;

      // 프린트 에러
      function SendPrintError(AError: String): Boolean;
      procedure SendKioskStatus;

      // 주차관리 DB
      function DBConnectionParking: Boolean;
      function SaveParkingData: Boolean;

      property Connection: TUniConnection read FConnection write FConnection;
      property MySQLUniProvider: TMySQLUniProvider read FMySQLUniProvider write FMySQLUniProvider;

      property ParkingConnection: TUniConnection read FParkingConnection write FParkingConnection;
      property ParkingMySQLUniProvider: TMySQLUniProvider read FParkingMySQLUniProvider write FParkingMySQLUniProvider;
  end;

implementation

uses
  uGlobal, fx.Logging, uFunction, uLocalSQL;

{ TLocalApi }

constructor TLocalApi.Create;
begin
  Connection := TUniConnection.Create(nil);
  MySQLUniProvider := TMySQLUniProvider.Create(nil);
  FStoreProc := TUniStoredProc.Create(nil);

  ParkingConnection := TUniConnection.Create(nil);
  ParkingMySQLUniProvider := TMySQLUniProvider.Create(nil);
  FParkingStoreProc := TUniStoredProc.Create(nil);
end;

destructor TLocalApi.Destroy;
begin
  Connection.Close;
  Connection.Free;

  MySQLUniProvider.Free;

  FStoreProc.Close;
  FStoreProc.Free;

  ParkingConnection.Close;
  ParkingConnection.Free;

  ParkingMySQLUniProvider.Free;

  FParkingStoreProc.Close;
  FParkingStoreProc.Free;

  inherited;
end;

function TLocalApi.DBConnection: Boolean;
begin
  Result := False;
  try
    try
      if Global.Config.AD.USE then
      begin
        Log.D('DB연결', Global.Config.AD.IP + ':' + IntToStr(Global.Config.AD.DB_PORT));
        Connection.ProviderName := 'MySql';
        Connection.Server := Global.Config.AD.IP;
        Connection.Port := Global.Config.AD.DB_PORT;
        Connection.Username := 'xgolf';
        Connection.Password := 'xgolf0105';
        Connection.Database := 'xgolf';
        Connection.Connect;

        Result := Connection.Connected;
        Log.D('DB연결', IfThen(Result, '성공', '실패'));
      end;
    except
      on E: Exception do
        Log.E('DB 연결 실패', E.Message);
    end;
  finally

  end;
end;

function TLocalApi.DBConnectionParking: Boolean;
begin
  try
    if Global.Config.PARKINGBARCODE then
    begin
      ParkingConnection.ProviderName := 'MySql';
      ParkingConnection.Server := Global.Config.PARKING_DB_IP;
      ParkingConnection.Port := 3306;
      ParkingConnection.Username := 'stone';
      ParkingConnection.Password := '1111';
      ParkingConnection.Database := 'stone_host';

//        ParkingConnection.ProviderName := 'MySql';
//        ParkingConnection.Server := Global.Config.AD.IP;
//        ParkingConnection.Port := Global.Config.AD.DB_PORT;
//        ParkingConnection.Username := 'xgolf';
//        ParkingConnection.Password := 'xgolf0105';
//        ParkingConnection.Database := 'xgolf';
//        ParkingConnection.Connect;

//      ParkingConnection.SpecificOptions.Values['MySQL.Charset'] := 'euc-kr';

      ParkingConnection.Connect;

      Result := ParkingConnection.Connected;
      Log.D('Parking DB연결', IfThen(Result, '성공', '실패'));
    end
    else
      Log.D('Parking DB연결', '안함');
  except
    on E: Exception do
    begin
      Log.E('Parking DB 연결 실패', E.Message);
    end;
  end;
end;


function TLocalApi.GetTeeBoxPlayingInfo: TList<TTeeBoxInfo>;
var
  Index: Integer;
  ATeeBoxInfo: TTeeBoxInfo;
  AProc: TUniStoredProc;
  bBallBack: Boolean;
begin

  bBallBack := False;

  try
    try

      for Index := Global.TeeBox.UpdateTeeBoxList.Count - 1 downto 0 do
        Global.TeeBox.UpdateTeeBoxList.Delete(Index);
      Global.TeeBox.UpdateTeeBoxList.Clear;

      AProc := TUniStoredProc.Create(nil);
      AProc := ProcExec(AProc, 'SP_GET_TEEBOX_STATUS', [Global.Config.Store.StoreCode]);

      //Log.D('AD 타석 수', IntToStr(AProc.RecordCount));

      for Index := 0 to AProc.RecordCount - 1 do
      begin
        ATeeBoxInfo.Mno := AProc.FieldByName('Teebox_nm').AsString;
        ATeeBoxInfo.TasukNo := AProc.FieldByName('Teebox_no').AsInteger;
        ATeeBoxInfo.High := AProc.FieldByName('floor_cd').AsInteger;
        ATeeBoxInfo.Use := AProc.FieldByName('use_yn').AsString = 'Y';
        if AProc.FieldByName('use_status').AsInteger in [0, 1, 3, 4] then
        begin
          ATeeBoxInfo.ERR := 0;
          ATeeBoxInfo.Hold := AProc.FieldByName('use_status').AsInteger = 3;
        end
        else
        begin
          ATeeBoxInfo.ERR := AProc.FieldByName('use_status').AsInteger;

          if ATeeBoxInfo.ERR = 7 then
            bBallBack := True;
        end;

        ATeeBoxInfo.Add_OK := False;
        ATeeBoxInfo.IsAddList := False;
        ATeeBoxInfo.Vip := AProc.FieldByName('vip_yn').AsString = 'Y';
        ATeeBoxInfo.ZoneCode := AProc.FieldByName('zone_div').AsString;
        ATeeBoxInfo.Ma_Time := AProc.FieldByName('remain_min').AsString;

        ATeeBoxInfo.End_Time := AProc.FieldByName('end_date').AsString;
        if ATeeBoxInfo.End_Time <> EmptyStr then
        begin
          ATeeBoxInfo.End_Time := StringReplace(ATeeBoxInfo.End_Time, '-', '', [rfReplaceAll]);
          ATeeBoxInfo.End_Time := StringReplace(ATeeBoxInfo.End_Time, ':', '', [rfReplaceAll]);
          ATeeBoxInfo.End_Time := StringReplace(ATeeBoxInfo.End_Time, ' ', '', [rfReplaceAll]);
          ATeeBoxInfo.End_Time := Trim(ATeeBoxInfo.End_Time);
          ATeeBoxInfo.End_Time := Format('%s:%s', [Copy(ATeeBoxInfo.End_Time, 9, 2), Copy(ATeeBoxInfo.End_Time, 11, 2)]);
        end;

        ATeeBoxInfo.End_DT := ATeeBoxInfo.End_Time;
        ATeeBoxInfo.BtweenTime := StrToIntDef(ATeeBoxInfo.Ma_Time, 0); //타석 전체 잔여시간

        Global.TeeBox.UpdateTeeBoxList.Add(ATeeBoxInfo);
        AProc.Next;
      end;

      Global.TeeBox.SetTeeBoxBallBack(bBallBack); //볼회수 여부

      Result := Global.TeeBox.UpdateTeeBoxList;
    except
      on E: Exception do
      begin
        Log.E('TLocalApi.GetTeeBoxPlayingInfo', E.Message);
      end;
    end;
  finally
    AProc.Free;
  end;
end;

//chy move
function TLocalApi.GetTeeBoxReserveInfo(AReserveNo: String): TTeeBoxInfo;
var
  Index: Integer;
  ATeeBoxInfo: TTeeBoxInfo;
  AMemberInfo: TMemberInfo;
  //AProc: TUniStoredProc;
  AReserveDate, AReserveSeq: String;
begin

  if Trim(AReserveNo) = EmptyStr then
    Exit;

  AReserveDate := Copy(AReserveNo, 1, 8);
  AReserveSeq := Copy(AReserveNo, 9, 4);

  with TUniStoredProc.Create(nil) do
  try
    try
      //AProc := TUniStoredProc.Create(nil);
      //AProc := ProcExec(AProc, 'SP_GET_TEEBOX_RESERVE_SEQ', [Global.Config.Store.StoreCode, AReserveDate, StrToInt(AReserveSeq), StrToInt(AReserveSeq)]);

      Connection := FConnection;
      StoredProcName := 'SP_GET_TEEBOX_RESERVE_SEQ';
      Params.Clear;
      Params.CreateParam(ftString, 'p_store_cd', ptInput).AsString := Global.Config.Store.StoreCode;
      Params.CreateParam(ftString, 'p_date', ptInput).AsString := AReserveDate;
      Params.CreateParam(ftString, 'p_seqs', ptInput).AsInteger := StrToInt(AReserveSeq);

      Prepared := True;
      Open;

      //if AProc.IsEmpty then
      if IsEmpty then
      begin
        ATeeBoxInfo.ReserveNo := AReserveNo;
        ATeeBoxInfo.Mno := '';
        ATeeBoxInfo.TasukNo := 0;
      end
      else
      begin
        ATeeBoxInfo.ReserveNo := AReserveNo;
        ATeeBoxInfo.Mno := FieldByName('Teebox_nm').AsString;
        ATeeBoxInfo.TasukNo := FieldByName('Teebox_no').AsInteger;
        ATeeBoxInfo.High := FieldByName('floor_cd').AsInteger;
        ATeeBoxInfo.Use := FieldByName('use_yn').AsString = 'Y';
        ATeeBoxInfo.UseStatus := FieldByName('use_status').AsString;

        ATeeBoxInfo.Add_OK := False;
        ATeeBoxInfo.IsAddList := False;
        ATeeBoxInfo.Vip := FieldByName('vip_yn').AsString = 'Y';
        //ATeeBoxInfo.ZoneCode := AProc.FieldByName('zone_div').AsString;
        ATeeBoxInfo.Ma_Time := FieldByName('remain_min').AsString;

        ATeeBoxInfo.End_Time := FieldByName('end_date').AsString;
        if ATeeBoxInfo.End_Time <> EmptyStr then
        begin
          ATeeBoxInfo.End_Time := StringReplace(ATeeBoxInfo.End_Time, '-', '', [rfReplaceAll]);
          ATeeBoxInfo.End_Time := StringReplace(ATeeBoxInfo.End_Time, ':', '', [rfReplaceAll]);
          ATeeBoxInfo.End_Time := StringReplace(ATeeBoxInfo.End_Time, ' ', '', [rfReplaceAll]);
          ATeeBoxInfo.End_Time := Trim(ATeeBoxInfo.End_Time);
          ATeeBoxInfo.End_Time := Format('%s:%s', [Copy(ATeeBoxInfo.End_Time, 9, 2), Copy(ATeeBoxInfo.End_Time, 11, 2)]);
        end;

        ATeeBoxInfo.End_DT := ATeeBoxInfo.End_Time;
        ATeeBoxInfo.BtweenTime := StrToIntDef(ATeeBoxInfo.Ma_Time, 0);

        AMemberInfo.Code := FieldByName('member_no').AsString;
        AMemberInfo.Name := FieldByName('member_nm').AsString;
        Global.SaleModule.Member := AMemberInfo;

      end;

      Result := ATeeBoxInfo;
    except
      on E: Exception do
      begin
        Log.E('TLocalApi.GetTeeBoxReserveInfo', E.Message);
      end;
    end;
  finally
    //AProc.Free;
    Close;
    Free;
  end;
end;

//chy move
function TLocalApi.GetTeeBoxNextReserveInfo(ATeeBoxInfo: TTeeBoxInfo): Boolean;
var
  AReserveDate, AReserveSeq: String;
  ATeeboxNo: Integer;
begin
  Result := False;

  AReserveDate := Copy(ATeeBoxInfo.ReserveNo, 1, 8);
  AReserveSeq := Copy(ATeeBoxInfo.ReserveNo, 9, 4);
  ATeeboxNo := ATeeBoxInfo.TasukNo;

  with TUniStoredProc.Create(nil) do
  try
    try
      Connection := FConnection;
      StoredProcName := 'SP_GET_TEEBOX_NEXT_RESERVE_SEQ';
      Params.Clear;
      Params.CreateParam(ftString, 'p_store_cd', ptInput).AsString := Global.Config.Store.StoreCode;
      Params.CreateParam(ftString, 'p_date', ptInput).AsString := AReserveDate;
      Params.CreateParam(ftString, 'p_seqs', ptInput).AsInteger := StrToInt(AReserveSeq);
      Params.CreateParam(ftString, 'p_teebox_no', ptInput).AsInteger := ATeeboxNo;

      Prepared := True;
      Open;

      //if AProc.IsEmpty then
      if not IsEmpty then
        Result := True;

    except
      on E: Exception do
      begin
        Log.E('TLocalApi.GetTeeBoxNextReserveInfo', E.Message);
      end;
    end;
  finally
    //AProc.Free;
    Close;
    Free;
  end;
end;

function TLocalApi.ProcExec(AStoredProc: TUniStoredProc; AProcedureName: string;
  AParam: array of Variant): TUniStoredProc;
var
  Index: Integer;
begin
  try
//    Result := False;
    with AStoredProc do
    begin
      AStoredProc.Connection := FConnection;
      Close;

      StoredProcName := EmptyStr;
      StoredProcName := AProcedureName;

      Params.CreateParam(ftString, 'P_STORE_CD', ptInput);

      if StoredProcName = 'SP_SET_HOLD_CLEAR' then
      begin
        Params.CreateParam(ftString, 'p_device_id', ptInput);
      end;

      if Params.Count > 0 then
      begin
        for Index := Low(AParam) to High(AParam) do
        begin
          if VarType(AParam[Index]) and varTypeMask = varCurrency then
          begin
            Params[Index].DataType := ftCurrency;
            Params[Index].AsCurrency := AParam[Index];
          end
          else
            Params[Index].Value := AParam[Index];
        end;
      end;
      //Log.D('AD 타석 수', '4');
      ExecProc;
    end;
    Result := AStoredProc;
  except
    on E: Exception do
    begin
      //
    end;
  end;
end;

function TLocalApi.QueryExec(AQuery: TUniQuery; ASQL: string; AParam: array of Variant): TUniQuery;
var
  i: Integer;
begin
  Result := AQuery;
  try
    try
      Result.Connection := Connection;
      Result.SQL.Text := ASQL;
      if Result.Params.Count > 0 then
      begin
        for i := Low(AParam) to High(AParam) do
        begin
          if Result.Params[i].Name = 'SIGNATURE' then
          begin
            Result.Params[i].DataType := ftBlob;
            Result.Params[i].Value := AParam[i];
          end
          else if VarType(AParam[i]) and varTypeMask = varCurrency then
            Result.Params[i].AsCurrency := AParam[i]
          else
            Result.Params[i].Value := AParam[i];
        end;
      end;
      QueryRun(Result);
      Result := Result;
    except on E: Exception do
      begin
        Global.QueryError := True;
        Log.E('TLocalApi.QueryExec', E.Message);
        Log.E('TLocalApi.QueryExec', ASQL);
        raise;
      end;
    end;
  finally
  end;
end;

procedure TLocalApi.QueryRun(AQuery: TUniQuery);
var
  Index: Integer;
  SqlText, LogText1, LogText2: string;
begin
  with AQuery do
  begin
    SqlText := UpperCase(Copy(SQL.Text, 1, 20));
    if Pos('SELECT', SqlText) > 0 then
      Open
    else
      ExecSql;
  end;
end;

function TLocalApi.SaveParkingData: Boolean;
var
  Index, Loop: Integer;
  AQuery: TUniQuery;
  function GetWeekInfo(AData: string): string;
  begin
    Result := Emptystr;
    Result := Result + IfThen(Copy(AData, 7, 1) = '1', '일', '');
    Result := Result + IfThen(Copy(AData, 1, 1) = '1', '월', '');
    Result := Result + IfThen(Copy(AData, 2, 1) = '1', '화', '');
    Result := Result + IfThen(Copy(AData, 3, 1) = '1', '수', '');
    Result := Result + IfThen(Copy(AData, 4, 1) = '1', '목', '');
    Result := Result + IfThen(Copy(AData, 5, 1) = '1', '금', '');
    Result := Result + IfThen(Copy(AData, 6, 1) = '1', '토', '');
  end;
begin
  AQuery := TUniQuery.Create(nil);
  try
    try
      AQuery.Connection := ParkingConnection;

      Log.D('Parking Product List Count', IntToStr(Global.SaleModule.ParkingProductList.Count));
      for Index := 0 to Global.SaleModule.ParkingProductList.Count - 1 do
      begin
        if Global.SaleModule.ParkingProductList[Index].Product_Div <> PRODUCT_TYPE_R then
          Continue;

        AQuery.SQL.Clear;
        AQuery.Params.Clear;

        Log.D('ProductBuyCode', Global.SaleModule.ParkingProductList[Index].ProductBuyCode);
        Log.D('StartDate', Global.SaleModule.ParkingProductList[Index].StartDate);
        Log.D('EndDate', Global.SaleModule.ParkingProductList[Index].EndDate);
        Log.D('Car_No', Global.SaleModule.Member.CarNo);

        AQuery.SQL.Text := SQL_PARKING_INSERT;
        AQuery.Params.ParamByName('NO').AsString := Global.SaleModule.ParkingProductList[Index].ProductBuyCode;
        AQuery.Params.ParamByName('CAR_NUM').AsString := Global.SaleModule.Member.CarNo;
        AQuery.Params.ParamByName('NAME').AsString := Global.SaleModule.Member.Name;
        AQuery.Params.ParamByName('START_DAY').AsDateTime := DateStrToDateTime(Global.SaleModule.ParkingProductList[Index].StartDate + '000000');
        AQuery.Params.ParamByName('END_DAY').AsDateTime := DateStrToDateTime(Global.SaleModule.ParkingProductList[Index].EndDate + '000000');
        AQuery.Params.ParamByName('GATE_SEL').AsString := '123456789abc';
        AQuery.Params.ParamByName('WEEK').AsString := GetWeekInfo(Global.SaleModule.ParkingProductList[Index].UseWeek);
        AQuery.Params.ParamByName('NOUSE').AsString := 'F';

        AQuery.ExecSql;
      end;
    except
      on E: Exception do
      begin
        Log.E('SaveParkingData', E.Message);
      end;
    end;
  finally
    AQuery.Free;
  end;
end;

function TLocalApi.SendApi(AJsonText: string): string;
var
  Indy: TIdTCPClient;
  Msg: string;
begin
  try
    try
      Result := EmptyStr;
      Indy := TIdTCPClient.Create(nil);
      Indy.Host := Global.Config.AD.IP;
      Indy.Port := Global.Config.AD.SERVER_PORT;
      Indy.ConnectTimeout := 5000;
      Indy.ReadTimeout := 10000;
      Indy.Connect;

      if Indy.Connected then
      begin
        Indy.IOHandler.Writeln(AJsonText, IndyTextEncoding_UTF8);
        Result := Indy.IOHandler.ReadLn(IndyTextEncoding_UTF8);
      end;
    except
      on E: Exception do
      begin
        Log.E('SendApi', E.Message);
        Log.E('SendApi', AJsonText);
      end;
    end;
  finally
    Indy.Disconnect;
    Indy.Free;
  end;
end;

function TLocalApi.TeeboxHold(IsHold: Boolean): Boolean;
var
  JsonText, Msg: string;
  MainJson, jObj: TJSONObject;
  //JsonValue: TJSONValue;
  sResultCd, sResultMsg, sStoreCloseTime, sEmergency, sDNSFail: String;
begin
  Result := False;
  try
    try
      MainJson := TJSONObject.Create;
      MainJson.AddPair(TJSONPair.Create('store_cd', Global.Config.Store.StoreCode));
      MainJson.AddPair(TJSONPair.Create('api', System.StrUtils.IfThen(IsHold, 'K405_TeeBoxHold', 'K406_TeeBoxHold')));
      MainJson.AddPair(TJSONPair.Create('user_id', Global.Config.Store.UserID));
      MainJson.AddPair(TJSONPair.Create('teebox_no', IntToStr(Global.SaleModule.TeeBoxInfo.TasukNo)));

      JsonText := SendApi(MainJson.ToJSON);

      if JsonText <> EmptyStr then
      begin
        jObj := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;
        sResultCd := jObj.GetValue('result_cd').Value;
        sResultMsg := jObj.GetValue('result_msg').Value;

        if IsHold then //홀드요청
        begin
          sStoreCloseTime := jObj.GetValue('store_close_time').Value;
                             //jObj.GetValue('change_store_date').Value;
          if Global.Config.Store.StoreEndTime <> sStoreCloseTime then
          begin
            Msg := Global.Config.Store.StoreEndTime + ' / '+ sStoreCloseTime;
            Global.Config.Store.StoreEndTime := sStoreCloseTime;
            Msg := Msg + ' -> ' + Global.Config.Store.StoreEndTime;
            Log.D('StoreEndTime reset', Msg);
          end;

          //chy 2021-11-02 쇼골프 우선적용
          if (Global.Config.Store.StoreCode = 'A8001') then
          begin
            sEmergency := jObj.GetValue('emergency_yn').Value;
            Global.Config.Store.Emergency := sEmergency;

            sDNSFail := jObj.GetValue('DNSFail_yn').Value;
            Global.Config.Store.DNSFail := sDNSFail;
          end;
        end;

        if sResultCd = '0000' then
          Result := True;
      end;

    except
      on E: Exception do
      begin

      end;
    end;
  finally
    MainJson.Free;
    FreeAndNil(jObj);
  end;
end;

//chy move
function TLocalApi.TeeboxMoveHold(IsHold: Boolean): Boolean;
var
  JsonText, Msg: string;
  MainJson: TJSONObject;
  JsonValue: TJSONValue;
begin
  Result := False;
  try
    try
      MainJson := TJSONObject.Create;
      MainJson.AddPair(TJSONPair.Create('store_cd', Global.Config.Store.StoreCode));
      MainJson.AddPair(TJSONPair.Create('api', System.StrUtils.IfThen(IsHold, 'K405_TeeBoxHold', 'K406_TeeBoxHold')));
      MainJson.AddPair(TJSONPair.Create('user_id', Global.Config.Store.UserID));
      MainJson.AddPair(TJSONPair.Create('teebox_no', IntToStr(Global.SaleModule.TeeBoxMoveInfo.TasukNo)));

      JsonText := SendApi(MainJson.ToJSON);

      if JsonText <> EmptyStr then
      begin
        JsonValue := MainJson.ParseJSONValue(JsonText);

        if (JsonValue as TJSONObject).Get('result_cd').JsonValue.Value = '0000' then
          Result := True;
      end;

    except
      on E: Exception do
      begin

      end;
    end;
  finally
    FreeAndNilJSONObject(JsonValue);
    MainJson.Free;
  end;
end;

function TLocalApi.TeeBoxListReservation(AJsonText: string): string;
begin
  Result := SendApi(AJsonText);
end;

function TLocalApi.GetProductUseInfo(ABuyCode, AProductCode: string): Integer;
var
  Index, AProductState: Integer;
  AQuery: TUniQuery;
begin
  Result := 0;
  AQuery := TUniQuery.Create(nil);

  try
    AQuery := QueryExec(AQuery, SQL_LOCAL_AD_SELECT_PRODUCT_USE_INFO, [Global.Config.Store.StoreCode,
                                                                       Global.SaleModule.SaleDate,
                                                                       ABuyCode,
                                                                       AProductCode]);
    for Index := 0 to AQuery.RecordCount - 1 do
    begin
      AProductState := AQuery.FieldByName('USE_STATUS').AsInteger;

      if AProductState = 5 then
        Result := Result + 1
      else
        Result := Result - 1;
    end;
  finally
    AQuery.Free;
  end;
end;

function TLocalApi.SendPrintError(AError: String): Boolean;
var
  JsonText: string;
  MainJson: TJSONObject;
begin
  Result := False;
  try
    try
      MainJson := TJSONObject.Create;
      MainJson.AddPair(TJSONPair.Create('store_cd', Global.Config.Store.StoreCode));
      MainJson.AddPair(TJSONPair.Create('api', 'A418_KioskPrintError'));
      MainJson.AddPair(TJSONPair.Create('device_no', Global.Config.Store.DeviceNo));
      MainJson.AddPair(TJSONPair.Create('user_id', Global.Config.Store.UserID));
      MainJson.AddPair(TJSONPair.Create('error_cd', AError));

      JsonText := SendApi(MainJson.ToJSON);

      if JsonText <> EmptyStr then
      begin

      end;

    except
      on E: Exception do
      begin

      end;
    end;
  finally
    MainJson.Free;
  end;
end;

procedure TLocalApi.SendKioskStatus;
var
  JsonText: string;
  MainJson: TJSONObject;
begin

  try
    try
      MainJson := TJSONObject.Create;
      MainJson.AddPair(TJSONPair.Create('store_cd', Global.Config.Store.StoreCode));
      MainJson.AddPair(TJSONPair.Create('api', 'A419_KioskStatus'));
      MainJson.AddPair(TJSONPair.Create('device_no', Global.Config.Store.DeviceNo));
      MainJson.AddPair(TJSONPair.Create('user_id', Global.Config.Store.UserID));

      JsonText := SendApi(MainJson.ToJSON);

      if JsonText <> EmptyStr then
      begin

      end;

    except
      on E: Exception do
      begin

      end;
    end;
  finally
    MainJson.Free;
  end;
end;

function TLocalApi.TeeboxCheckIn: Boolean;
var
  JsonText: string;
  MainJson, jObj: TJSONObject;
  jObjArr: TJSONArray;
  sResultCd, sResultMsg: String;
  I: integer;
begin
  Result := False;

  try
    try

      MainJson := TJSONObject.Create;
      MainJson.AddPair(TJSONPair.Create('store_cd', Global.Config.Store.StoreCode));
      //MainJson.AddPair(TJSONPair.Create('store_cd', 'A2001'));
      MainJson.AddPair(TJSONPair.Create('api', 'A432_TeeboxCheckIn'));
      MainJson.AddPair(TJSONPair.Create('user_id', Global.Config.Store.UserID));

      jObjArr := TJSONArray.Create;
      MainJson.AddPair(TJSONPair.Create('data', jObjArr));
      for I := 0 to Global.SaleModule.CheckInList.Count - 1 do
      begin
        jObj := TJSONObject.Create;
        jObj.AddPair(TJSONPair.Create('reserve_no', Global.SaleModule.CheckInList[I].reserve_no));
        jObj.AddPair(TJSONPair.Create('teebox_no', Global.SaleModule.CheckInList[I].teebox_no));

        jObjArr.Add(jObj)
      end;

      JsonText := SendApi(MainJson.ToJSON);

      if JsonText <> EmptyStr then
      begin
        jObj := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;
        sResultCd := jObj.GetValue('result_cd').Value;
        sResultMsg := jObj.GetValue('result_msg').Value;

        if sResultCd = '0000' then
          Result := True;
      end;

    except
      on E: Exception do
      begin

      end;
    end;

  finally
    FreeAndNil(MainJson);
  end;

end;

function TLocalApi.ParkingPrintCheck(AReserveNo: String): String;
var
  JsonText: string;
  MainJson, jObj: TJSONObject;
  sResultCd, sResultMsg: String;
begin
  Result := '';

  try
    try

      MainJson := TJSONObject.Create;
      MainJson.AddPair(TJSONPair.Create('store_cd', Global.Config.Store.StoreCode));
      MainJson.AddPair(TJSONPair.Create('api', 'A433_ParkingPrintCheck'));
      MainJson.AddPair(TJSONPair.Create('user_id', Global.Config.Store.UserID));
      MainJson.AddPair(TJSONPair.Create('reserve_no', AReserveNo));

      JsonText := SendApi(MainJson.ToJSON);

      if JsonText <> EmptyStr then
      begin
        jObj := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;
        sResultCd := jObj.GetValue('result_cd').Value;
        sResultMsg := jObj.GetValue('result_msg').Value;

        Result := sResultMsg;
      end;

    except
      on E: Exception do
      begin

      end;
    end;

  finally
    FreeAndNil(MainJson);
    FreeAndNil(jObj);
  end;

end;

end.
