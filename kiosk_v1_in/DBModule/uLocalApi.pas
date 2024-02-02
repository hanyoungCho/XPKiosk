unit uLocalApi;

interface

uses
  Generics.Collections, System.Variants, uConsts, JSON,
  IdTCPClient, IdGlobal, System.SysUtils, Uni, MySQLUniProvider, Data.DB, uStruct;

type
  TLocalApi = class
    private
      FConnection: TUniConnection;
      FMySQLUniProvider: TMySQLUniProvider;
      FStoreProc: TUniStoredProc;

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

      // 홀드 등록 및 취소
      function TeeboxHold(IsHold: Boolean = False): Boolean;

      // 예약 등록
      function TeeBoxListReservation(AJsonText: string): string;

      // 프린트 에러
      function SendPrintError(AError: String): Boolean;
      procedure SendKioskStatus;

      property Connection: TUniConnection read FConnection write FConnection;
      property MySQLUniProvider: TMySQLUniProvider read FMySQLUniProvider write FMySQLUniProvider;
  end;

implementation

uses
  uGlobal, fx.Logging, uFunction;

{ TLocalApi }

constructor TLocalApi.Create;
begin
  Connection := TUniConnection.Create(nil);
  MySQLUniProvider := TMySQLUniProvider.Create(nil);
  FStoreProc := TUniStoredProc.Create(nil);
end;

destructor TLocalApi.Destroy;
begin
  Connection.Close;
  Connection.Free;

  MySQLUniProvider.Free;

  FStoreProc.Close;
  FStoreProc.Free;

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

function TLocalApi.GetTeeBoxPlayingInfo: TList<TTeeBoxInfo>;
var
  Index: Integer;
  ATeeBoxInfo: TTeeBoxInfo;
//  AQuery: TUniQuery;
  AProc: TUniStoredProc;
begin
  try
    try

      for Index := Global.TeeBox.UpdateTeeBoxList.Count - 1 downto 0 do
        Global.TeeBox.UpdateTeeBoxList.Delete(Index);
      Global.TeeBox.UpdateTeeBoxList.Clear;

//      AQuery := QueryExec(SQL, [Global.Config.Store.StoreCode]);
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
          ATeeBoxInfo.ERR := AProc.FieldByName('use_status').AsInteger;

        ATeeBoxInfo.Add_OK := False;
        ATeeBoxInfo.IsAddList := False;
        ATeeBoxInfo.Vip := AProc.FieldByName('vip_yn').AsString = 'Y';
        ATeeBoxInfo.ZoneCode := AProc.FieldByName('zone_div').AsString;
        ATeeBoxInfo.Ma_Time := AProc.FieldByName('remain_min').AsString;


//        if AProc.FieldByName('end_datetime').AsString = EmptyStr then
//          ATeeBoxInfo.End_Time := ''
//        else
//          ATeeBoxInfo.End_Time := FormatDateTime('hhnn', AProc.FieldByName('end_datetime').AsDateTime);

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

        //chy test
        if AProc.FieldByName('use_status').AsInteger in [1, 4] then
        begin
          if ATeeBoxInfo.BtweenTime = 0 then
          begin
            Log.E('TLocalApi.GetTeeBoxPlayingInfo 0 Min Error', ATeeBoxInfo.Mno + ' / ' + ATeeBoxInfo.Ma_Time);
          end;
        end;

        Global.TeeBox.UpdateTeeBoxList.Add(ATeeBoxInfo);
        AProc.Next;
      end;
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

function TLocalApi.ProcExec(AStoredProc: TUniStoredProc; AProcedureName: string; AParam: array of Variant): TUniStoredProc;
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
  sResultCd, sResultMsg, sStoreCloseTime: String;
begin
  Result := False;
  try
    try
      MainJson := TJSONObject.Create;
      MainJson.AddPair(TJSONPair.Create('store_cd', Global.Config.Store.StoreCode));
      MainJson.AddPair(TJSONPair.Create('api', IfThen(IsHold, 'K405_TeeBoxHold', 'K406_TeeBoxHold')));
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

function TLocalApi.TeeBoxListReservation(AJsonText: string): string;
begin
  Result := SendApi(AJsonText);
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

end.
