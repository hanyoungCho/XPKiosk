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

      FParkingConnection: TUniConnection;
      FParkingMySQLUniProvider: TMySQLUniProvider;
      FParkingStoreProc: TUniStoredProc;

      function SendApi(AJsonText: string): string;

      function ProcExec(AStoredProc: TUniStoredProc; AProcedureName: string; AParam: array of Variant): TUniStoredProc;
    public
      constructor Create;
      destructor Destroy; override;

      // 타석기 AD
      function DBConnection: Boolean;
      
      // 가동 상황
      function GetTeeBoxPlayingInfo: TList<TTeeBoxInfo>;

      // 홀드 등록 및 취소
      function TeeboxHold(IsHold: Boolean = True): Boolean;

      // 예약 등록
      function TeeBoxListReservation: Boolean;

      property Connection: TUniConnection read FConnection write FConnection;
      property MySQLUniProvider: TMySQLUniProvider read FMySQLUniProvider write FMySQLUniProvider;

      property ParkingConnection: TUniConnection read FParkingConnection write FParkingConnection;
      property ParkingMySQLUniProvider: TMySQLUniProvider read FParkingMySQLUniProvider write FParkingMySQLUniProvider;
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

      AProc := TUniStoredProc.Create(nil);
      AProc := ProcExec(AProc, 'SP_GET_TEEBOX_STATUS', [Global.Config.Store.StoreCode]);

      //Log.D('AD 타석 수', IntToStr(AProc.RecordCount));

      for Index := 0 to AProc.RecordCount - 1 do
      begin
        ATeeBoxInfo.Name := AProc.FieldByName('Teebox_nm').AsString;
        ATeeBoxInfo.TasukNo := AProc.FieldByName('Teebox_no').AsInteger;
        ATeeBoxInfo.FloorCd := AProc.FieldByName('floor_cd').AsInteger;
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

    with AStoredProc do
    begin
      AStoredProc.Connection := FConnection;
      Close;

      StoredProcName := EmptyStr;
      StoredProcName := AProcedureName;

      Params.CreateParam(ftString, 'P_STORE_CD', ptInput);

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

function TLocalApi.TeeBoxListReservation: Boolean;
label ReReserve;
var
  Index, Cnt: Integer;
  MainJson, ItemJson: TJSONObject;
  JsonList: TJSONArray;
  JsonValue, JsonListValue: TJSONValue;
  JsonText, ADate: string;
  AProductInfo: TProductInfo;
begin
  try
    try
      if not Global.SaleModule.TeeboxTimeError then
      begin
        Global.TeeBox.GetGMTeeBoxList;
        if not Global.SaleModule.TeeboxTimeCheck then
          Exit;
      end;

      Result := False;
      MainJson := TJSONObject.Create;      ItemJson := TJSONObject.Create;
      JsonList := TJSONArray.Create;

      MainJson.AddPair(TJSONPair.Create('data', JsonList));
      MainJson.AddPair(TJSONPair.Create('member_no', Global.SaleModule.Member.Code));
      MainJson.AddPair(TJSONPair.Create('store_cd', Global.Config.Store.StoreCode));
      MainJson.AddPair(TJSONPair.Create('user_id', Global.Config.Store.UserID));
      MainJson.AddPair(TJSONPair.Create('reserve_root_div', 'K'));
      MainJson.AddPair(TJSONPair.Create('receipt_no', Global.SaleModule.RcpAspNo));
      ItemJson.AddPair(TJSONPair.Create('assign_balls', '9999'));

      //매장종료시간초과시 배정시간 변경
      if Global.SaleModule.FStoreCloseOver = True then
        ItemJson.AddPair(TJSONPair.Create('assign_min', Global.SaleModule.FStoreCloseOverMin))
      else
        ItemJson.AddPair(TJSONPair.Create('assign_min', Global.SaleModule.SelectProduct.One_Use_Time));

      ItemJson.AddPair(TJSONPair.Create('prepare_min', IfThen(StrToIntDef(Global.Config.PrePare_Min, 5) <> Global.SaleModule.PrepareMin,
                                                                IntToStr(Global.SaleModule.PrepareMin), Global.Config.PrePare_Min)));
      ItemJson.AddPair(TJSONPair.Create('product_cd', Global.SaleModule.SelectProduct.Code));
      ItemJson.AddPair(TJSONPair.Create('purchase_cd', Global.SaleModule.SelectProduct.ProductBuyCode));
      ItemJson.AddPair(TJSONPair.Create('teebox_no', IntToStr(Global.SaleModule.TeeBoxInfo.TasukNo)));

      if Global.Config.AD.USE then
      begin
        ItemJson.AddPair(TJSONPair.Create('product_nm', Global.SaleModule.SelectProduct.Name));
        ItemJson.AddPair(TJSONPair.Create('reserve_div', Global.SaleModule.SelectProduct.Product_Div));
      end;

      JsonList.Add(ItemJson);

      MainJson.AddPair(TJSONPair.Create('api', 'K408_TeeBoxReserve2'));
      MainJson.AddPair(TJSONPair.Create('member_nm', Global.SaleModule.Member.Name));

      ReReserve :

      Log.D('Local TeeBoxReservation2', LogReplace(MainJson.ToString));
      WriteLog(False, 'ApiLog', Global.SaleModule.SaleDate, 'Local TeeBoxReservation2', LogReplace(MainJson.ToString));

      JsonText := SendApi(MainJson.ToString);

      WriteLog(False, 'ApiLog', Global.SaleModule.SaleDate, 'Local TeeBoxReservation2', LogReplace(JsonText));
      Log.D('Local TeeBoxReservation2', LogReplace(JsonText));

      if JsonText <> EmptyStr then
      begin
        JsonValue := MainJson.ParseJSONValue(JsonText);

        if (JsonValue as TJSONObject).Get('result_cd').JsonValue.Value = '0000' then
        begin
          Result := True;

          if not (JsonValue.FindValue('data') is TJSONNull) then
          begin
            AProductInfo := Global.SaleModule.SelectProduct;

            JsonValue := (JsonValue as TJSONObject).Get(VarToStr('data')).JsonValue;

            JsonValue := (JsonValue as TJSONArray).Items[0];

            AProductInfo.Reserve_Time := (JsonValue as TJSONObject).Get('start_datetime').JsonValue.Value;
            AProductInfo.Start_Time :=
              Copy(StringReplace((JsonValue as TJSONObject).Get('start_datetime').JsonValue.Value, '-', '', [rfReplaceAll]), 10, 5);
            AProductInfo.One_Use_Time := (JsonValue as TJSONObject).Get('remain_min').JsonValue.Value;

            AProductInfo.Use_Qty := StrToIntDef((JsonValue as TJSONObject).Get('coupon_cnt').JsonValue.Value, 0);

            AProductInfo.Reserve_No := (JsonValue as TJSONObject).Get('reserve_no').JsonValue.Value;
            AProductInfo.Reserve_List := EmptyStr;

            Result := True;
          end;
          Global.SaleModule.SelectProduct := AProductInfo;
        end        else        begin          if ((JsonValue as TJSONObject).Get('result_cd').JsonValue.Value = '0002') and Global.Config.AD.USE then          begin            goto ReReserve;
          end          else            Global.SBMessage.ShowMessageModalForm((JsonValue as TJSONObject).Get('result_msg').JsonValue.Value);        end;      end      else        Global.SBMessage.ShowMessageModalForm(MSG_TEEBOX_RESERVATION_AD_FAIL);    except
      on E: Exception do
      begin
        WriteLog(True, 'ApiLog', Global.SaleModule.SaleDate, 'TeeBoxReservation2', LogReplace(JsonText));
        Log.E('TeeBoxReservation', E.Message);
      end;
    end;  finally
    FreeAndNil(MainJson);
  end;
end;

end.
