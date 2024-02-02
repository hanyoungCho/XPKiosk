unit uLocalDatabase;

interface

uses
  uStruct,
  SysUtils, Variants, Data.DB, Dialogs, Forms,
  uConsts, FireDAC.Stan.Intf, Generics.Collections,
  Uni, MySQLUniProvider;

type
  TLocalDatabase = class
  private
    FConnection: TUniConnection;
    FMySQLUniProvider: TMySQLUniProvider;
    FStoreProc: TUniStoredProc;

    procedure BeginTrans;                              // Begin
    procedure CommitTrans;                             // Commit
    procedure RollbackTrans;                           // RollBack
    procedure QueryRun(AQuery: TFDQuery);
    function QueryExec(ASQL: string; AParam: array of Variant): TFDQuery;
  public
    constructor Create;
    destructor Destroy; override;

    function DBConnection: Boolean;

    function GetMemberListToDB: TList<TMemberInfo>; //회원정보
    function SetMemberToDB(AMemberInfo: TMemberInfo): Boolean;

    // 영수증 번호 채번
    function GetRcpNo: Integer;

    // 저장
    function SaveDatabase: Boolean;
    // SL_SALE_H
    function SAVE_SL_SALE_H: Boolean;
    // SL_SALE_D
    function SAVE_SL_SALE_D: Boolean;
    // SL_PAY
    function SAVE_SL_PAY: Boolean;
    // SL_CARD
    function SAVE_SL_CARD(AIndex, ASeq: Integer): Boolean;
    // SL_PAYCO
    function SAVE_SL_PAYCO(AIndex, ASeq: Integer): Boolean;
    // SL_DISCOUNT
    function SAVE_SL_DISCOUNT: Boolean;

    // 광고
    function SAVE_ADVERTIS: Boolean;
    function Searh_MS_ADVERTIS_H_SELECT: Boolean;
    function Searh_MS_ADVERTIS_H_UPDATE(ATime: string): Boolean;
    function Searh_MS_ADVERTIS_D_INSERT(AList: TList<TAdvertisement>): Boolean;
    function Searh_MS_ADVERTIS_D_UPDATE(ASeq: string): Boolean;

    property StoreProc: TFDStoredProc read FStoredProc write FStoredProc;
    property Query: TFDQuery read FQuery write FQuery;

  end;

implementation

uses
  uGlobal, uSaleModule, fx.Logging, uLocalSQL, uFunction;

{ TLocalDatabase }

constructor TLocalDatabase.Create;
begin
  FConnection := TFDConnection.Create(nil);
  StoreProc := TFDStoredProc.Create(nil);
  Query := TFDQuery.Create(nil);

  FManager := TFDManager.Create(nil);
  FPhysFBDriverLink := TFDPhysFBDriverLink.Create(nil);
  FPhysFBDriverLink.VendorLib := ExtractFilePath(ParamStr(0)) + 'fbclient.dll';
  FGUIxWaitCursor := TFDGUIxWaitCursor.Create(nil);

  if FConnection.Connected then
    FConnection.Connected := False;

  FConnection.LoginPrompt := False;
  FConnection.DriverName := 'FB';

  FConnection.Params.Values['DriverID'] := 'FB';
  FConnection.Params.Values['Protocol'] := 'Local';
  FConnection.Params.Values['Port'] := '3050';
  FConnection.Params.Values['User_Name'] := 'sysdba';

  {$IFDEF RELEASE}
  FConnection.Params.Values['Server'] := '127.0.0.1';
  FConnection.Params.Values['Password'] := 'masterkey';
  FConnection.Params.Values['Database'] := ExtractFilePath(ParamStr(0)) + 'Data\XGOLF_KIOSK.FDB';
  {$ENDIF}
  {$IFDEF DEBUG}
  FConnection.Params.Values['Server'] := '127.0.0.1';
//  FConnection.Params.Values['Password'] := 'heejin';

//  FConnection.Params.Values['Database'] := 'D:\Project Source\XGolf\kiosk\Bin\Data\XGOLF_KIOSK.FDB';
  FConnection.Params.Values['Password'] := 'masterkey';
  FConnection.Params.Values['Database'] := ExtractFilePath(ParamStr(0)) + 'Data\XGOLF_KIOSK.FDB';
  {$ENDIF}
end;

destructor TLocalDatabase.Destroy;
begin
  FConnection.Free;
  FPhysFBDriverLink.Free;
  FGUIxWaitCursor.Free;
  Query.Free;
  StoreProc.Free;

  FManager.Free;
  inherited;
end;

procedure TLocalDatabase.BeginTrans;
begin
  try
    if FConnection.InTransaction then
      FConnection.Rollback;
    FConnection.StartTransaction;
  except on E: Exception do
    begin
      raise;
    end;
  end;
end;

procedure TLocalDatabase.CommitTrans;
begin
  try
    FConnection.Commit;
  except on E: Exception do
    begin
      raise;
    end;
  end;
end;

function TLocalDatabase.DBConnection: Boolean;
begin
  Result := False;
  try
    try

      Log.D('DB연결', 'localhost:' + IntToStr(Global.Config.LocalDBInfo.DB_PORT));
      FConnection.ProviderName := 'MySql';
      FConnection.Server := 'localhost';
      FConnection.Port := Global.Config.LocalDBInfo.DB_PORT;
      FConnection.Username := 'xgolf';
      FConnection.Password := 'xgolf0105';
      FConnection.Database := 'xgolf';
      FConnection.Connect;

      Result := FConnection.Connected;
      Log.D('DB연결', IfThen(Result, '성공', '실패'));

    except
      on E: Exception do
        Log.E('DB 연결 실패', E.Message);
    end;
  finally

  end;
end;

function TLocalApi.GetMemberListToDB: TList<TMemberInfo>;
var
  sSql: String;
  nIndex: Integer;
  rMemberInfo: TMemberInfo;
begin

  with TUniQuery.Create(nil) do
  begin

    try
      Connection := Connection;

      sSql := ' SELECT * FROM MEMBER ';;

      Close;
      SQL.Text := sSql;
      //Prepared := True;
      ExecSQL;

      Result := TList<TMemberInfo>.Create;
      for nIndex := 0 to RecordCount - 1 do
      begin
        rMemberInfo.Code := FieldByName('member_no').AsString;
        rMemberInfo.Name := FieldByName('member_nm').AsString;

        If FieldByName('sex_div').AsString = '1' then
          rMemberInfo.Sex := 'M'
        else
          rMemberInfo.Sex := 'W';

        rMemberInfo.Tel_Mobile := FieldByName('hp_no').AsString;
        //고객 구분		customer_cd
        //단체 코드		group_cd
        rMemberInfo.MemberCardUid := FieldByName('member_card_uid').AsString; //회원 카드 고유번호
        //복지카드 고유번호		welfare_cd
        //사원 번호		emp_no
        //회원 포인트		member_point
        //회원 할인율		dc_rate
        rMemberInfo.CardNo := FieldByName('qr_cd').AsString;
        rMemberInfo.FingerStr := FieldByName('fingerprint1').AsString;
        rMemberInfo.FingerStr_2 := FieldByName('fingerprint2').AsString;
        //특별회원 여부		special_yn
        rMemberInfo.Use := FieldByName('del_yn').AsString = 'N';

        if rMemberInfo.Use then
          Result.Add(rMemberInfo);

        Next;

      end;

    finally
      //LeaveCriticalSection(FCS);

      Close;
      Free;
    end;
  end;

end;

function TLocalApi.SetMemberToDB(AMemberInfo: TMemberInfo): Boolean;
var
  sSql, sSex, sUse: String;
  I: Integer;
begin

  Result := False;

  with TUniQuery.Create(nil) do
  begin

    try

      try

        Connection := Connection;

        sSex := '1';
        if AMemberInfo.Sex = 'W' then
          sSex := '2';

        sUse := 'N';
        if AMemberInfo.Use = True then
          sUse := 'Y';

        sSql := ' INSERT INTO SEAT ' +
                '( MEMBER_NO, MEMBER_NM, SEX_DIV, HP_NO, MEMBER_CARD_UID, QR_CD, FINGER1, FINGER2, DEL_YN ) ' +
                ' VALUES ' +
                '( ' + QuotedStr(AMemberInfo.Code) + ', '
                     + QuotedStr(AMemberInfo.Name) + ', '
                     + QuotedStr(sSex) +', '
                     + QuotedStr(AMemberInfo.Tel_Mobile) +', '
                     + QuotedStr(AMemberInfo.MemberCardUid) +', '
                     + QuotedStr(AMemberInfo.CardNo) +', '
                     + QuotedStr(AMemberInfo.FingerStr) +', '
                     + QuotedStr(AMemberInfo.FingerStr_2) +', '
                     + QuotedStr(sUse) + ')';

        Close;
        SQL.Text := sSql;
        Prepared := True;
        ExecSQL;

      except
        on E: Exception do
        begin
          //RollbackTrans;
        end;
      end;

      Result := True;
    finally
      //LeaveCriticalSection(FCS);

      Close;
      Free;
    end;

  end;

end;

function TLocalDatabase.GetRcpNo: Integer;
begin
  try
    Result := 0;

    FQuery := QueryExec(LOCAL_SALE_H_MAX_RCP_NO, [Global.Config.Store.StoreCode, Global.SaleModule.SaleDate, Global.Config.Store.PosNo]);

    if FQuery.RecordCount <> 0 then
      Result := FQuery.FieldByName('NO_RCP').AsInteger;
  except
    on E: Exception do
    begin

    end;
  end;
end;

function TLocalDatabase.QueryExec(ASQL: string; AParam: array of Variant): TFDQuery;
var
  i: Integer;
begin
  Result := TFDQuery.Create(nil);
  try
    try
      Result.Connection := FConnection;
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
//        Log.E('TFoodAsp.QueryExec', E.Message);
//        Log.E('TFoodAsp.QueryExec', ASQL);
        raise;
      end;
    end;
  finally
//    qryTemp.Free;
  end;
end;

procedure TLocalDatabase.QueryRun(AQuery: TFDQuery);
var
  i: Integer;
  SqlText, LogText1, LogText2: string;
begin
  with AQuery do
  begin
    SqlText := UpperCase(Copy(SQL.Text, 1, 20));
    // 쿼리 실행
    if Pos('SELECT', SqlText) > 0 then
      Open
    else
      ExecSql;
  end;
end;

procedure TLocalDatabase.RollbackTrans;
begin
  try
    FConnection.Rollback;
  except on E: Exception do
    begin
      raise;
    end;
  end;
end;

function TLocalDatabase.SaveDatabase: Boolean;
begin
  try
    try
      Result := False;
      BeginTrans;

      if not SAVE_SL_SALE_H then
        Exit;

      if not SAVE_SL_SALE_D then
        Exit;

      if not SAVE_SL_PAY then
        Exit;

      if not SAVE_SL_DISCOUNT then
        Exit;

      CommitTrans;
      Result := True;
    except
      on E: Exception do
      begin
      end;
    end;
  finally

  end;
end;

function TLocalDatabase.SAVE_SL_SALE_H: Boolean;
begin
  try
    try
      Result := False;
      Global.SaleModule.RcpNo := GetRcpNo + 1;
      Global.SaleModule.RcpAspNo := //Global.Config.Store.StoreCode +
//                                    Copy(Global.Config.OAuth.DeviceID, 6, 5) +
                                    Global.Config.OAuth.DeviceID +
                                    Copy(Global.SaleModule.SaleDate, 3, 6) +
                                    //FormatFloat('00', StrToInt(Global.Config.Store.PosNo)) +
//                                    FormatFloat('00', StrToInt(Copy(Global.Config.OAuth.DeviceID, 9, 2))) +
//                                    Global.Config.OAuth.DeviceID +
                                    FormatFloat('0000', Global.SaleModule.RcpNo);
      if Global.SaleModule.RcpNo = 0 then
      begin
        // 0이면 안된다.
        Exit;
      end;
      QueryExec(LOCAL_SALE_H_INSERT,
               [Global.Config.Store.StoreCode,
                Global.SaleModule.SaleDate,
                Global.Config.Store.PosNo,
                Global.SaleModule.RcpNo,
                Global.SaleModule.TotalAmt,
                Global.SaleModule.RealAmt,
                Global.SaleModule.VatAmt,
                Global.SaleModule.DCAmt]);
      Result := True;
    except
      on E: Exception do
      begin
        Log.E('SAVE_SL_SALE_H', E.Message + 'Global.SaleModule.RcpNo=' +IntToStr(Global.SaleModule.RcpNo));
        RollbackTrans;
      end;
    end;
  finally

  end;
end;

function TLocalDatabase.SAVE_ADVERTIS: Boolean;
begin
  try
    try
      BeginTrans;
      if Searh_MS_ADVERTIS_H_SELECT then
      begin
        if not Searh_MS_ADVERTIS_D_INSERT(Global.SaleModule.AdvertisementListUp) then
        begin
          Global.SaleModule.ProgramUse := False;
          RollbackTrans;
        end;
        if not Searh_MS_ADVERTIS_D_INSERT(Global.SaleModule.AdvertisementListDown) then
        begin
          Global.SaleModule.ProgramUse := False;
          RollbackTrans;
        end;
        CommitTrans;
      end
      else
        RollbackTrans;
    except
      on E: Exception do
      begin
        RollbackTrans;
      end;
    end;
  finally

  end;
end;

function TLocalDatabase.Searh_MS_ADVERTIS_H_SELECT: Boolean;
begin
  try
    try
      Result := False;
      Query := QueryExec(SQL_MS_ADVERTIS_H_SELECT, [Global.Config.Store.StoreCode, Global.SaleModule.SaleDate]);

      if Query.RecordCount = 0 then
        QueryExec(SQL_MS_ADVERTIS_H_INSERT, [Global.Config.Store.StoreCode, Global.SaleModule.SaleDate]);

      Result := True;
    except
      on E: Exception do
        Log.E('Searh_MS_ADVERTIS_H_SELECT', E.Message);
    end;
  finally

  end;
end;

function TLocalDatabase.Searh_MS_ADVERTIS_H_UPDATE(ATime: string): Boolean;
begin
  try
    try
      Result := False;
      Query := QueryExec(SQL_MS_ADVERTIS_H_UPDATE, [ATime, Global.Config.Store.StoreCode, Global.SaleModule.SaleDate]);
      Result := True;
    except
      on E: Exception do
        Log.E('Searh_MS_ADVERTIS_H_UPDATE', E.Message);
    end;
  finally

  end;
end;

function TLocalDatabase.Searh_MS_ADVERTIS_D_INSERT(AList: TList<TAdvertisement>): Boolean;
var
  Index: Integer;
begin
  try
    try
      Result := False;
      for Index := 0 to AList.Count - 1 do
      begin
        Query := QueryExec(SQL_MS_ADVERTIS_D_SELECT_SEQ, [Global.Config.Store.StoreCode, Global.SaleModule.SaleDate, IntToStr(AList[Index].Seq)]);
        if Query.RecordCount = 0 then
          QueryExec(SQL_MS_ADVERTIS_D_INSERT_SEQ, [Global.Config.Store.StoreCode, Global.SaleModule.SaleDate, IntToStr(AList[Index].Seq)]);
      end;
      Result := True;
    except
      on E: Exception do
        Log.E('Searh_MS_ADVERTIS_H_UPDATE', E.Message);
    end;
  finally

  end;
end;

function TLocalDatabase.Searh_MS_ADVERTIS_D_UPDATE(ASeq: string): Boolean;
begin
  try
    try
      Result := False;
      QueryExec(StringReplace(SQL_MS_ADVERTIS_D_UPDATE_SEQ, '@TIME@', 'TIME_' + FormatDateTime('hh', now), [rfReplaceAll]),
                [Global.Config.Store.StoreCode, Global.SaleModule.SaleDate, ASeq]);
      Result := True;
    except
      on E: Exception do
        Log.E('Searh_MS_ADVERTIS_H_UPDATE', E.Message);
    end;
  finally

  end;
end;

function TLocalDatabase.SAVE_SL_SALE_D: Boolean;
var
  Index: Integer;
  SaleAmt: Currency;
begin
  try
    try
      Result := False;
      SaleAmt := 0;
      for Index := 0 to Global.SaleModule.BuyProductList.Count - 1 do
      begin
        with Global.SaleModule.BuyProductList[Index] do
        begin
          SaleAmt := (ABS(SaleQty) * Products.Price) - ABS(DcAmt);
          QueryExec(LOCAL_SALE_D_INSERT,
                   [Global.Config.Store.StoreCode,
                    Global.SaleModule.SaleDate,
                    Global.Config.Store.PosNo,
                    Global.SaleModule.RcpNo,
                    (Index + 1),
                    SaleQty,
                    Products.Code,
                    Products.Price,
                    SaleAmt,
                    SaleAmt - Trunc(SaleAmt / 1.1),
                    DcAmt
                   ]);
        end;
      end;
      Result := True;
    except
      on E: Exception do
      begin
        Log.E('SAVE_SL_SALE_D', E.Message);
        RollbackTrans;
      end;
    end;
  finally

  end;
end;

function TLocalDatabase.SAVE_SL_PAY: Boolean;
var
  Index: Integer;
begin
  try
    try
      Result := False;
      for Index := 0 to Global.SaleModule.PayList.Count - 1 do
      begin
        QueryExec(LOCAL_PAY_INSERT,
                 [Global.Config.Store.StoreCode,
                  Global.SaleModule.SaleDate,
                  Global.Config.Store.PosNo,
                  Global.SaleModule.RcpNo,
                  (Index + 1),
                  Ord(TPayData(Global.SaleModule.PayList[Index]).PayType),
                  TPayData(Global.SaleModule.PayList[Index]).PayAmt,
                  TPayData(Global.SaleModule.PayList[Index]).PayAmt -
                    Trunc(TPayData(Global.SaleModule.PayList[Index]).PayAmt / 1.1)]);

         if TPayData(Global.SaleModule.PayList[Index]).PayType = ptCard then
         begin
           if not SAVE_SL_CARD(Index, Index + 1) then
             Exit;
         end
         else
         begin
           if not SAVE_SL_PAYCO(Index, Index + 1) then
             Exit;
         end;
      end;
      Result := True;
    except
      on E: Exception do
      begin
        Log.E('SAVE_SL_PAY', E.Message);
        RollbackTrans;
      end;
    end;
  finally

  end;
end;

function TLocalDatabase.SAVE_SL_CARD(AIndex, ASeq: Integer): Boolean;
var
  ACard: TPayCard;
begin
  try
    try
      Result := False;
      ACard := TPayCard(Global.SaleModule.PayList[AIndex]);

      QueryExec(LOCAL_CARD_INSERT,
               [Global.Config.Store.StoreCode,
                Global.SaleModule.SaleDate,
                Global.Config.Store.PosNo,
                Global.SaleModule.RcpNo,
                ASeq,
                IfThen(ACard.RecvInfo.Result, 1, 0),
                ACard.SendInfo.SaleAmt,
                ACard.RecvInfo.CardNo,
                ACard.SendInfo.HalbuMonth,
                ACard.RecvInfo.AgreeNo,
                ACard.RecvInfo.TransNo,
                ACard.RecvInfo.AgreeDateTime,
                ACard.RecvInfo.BalgupsaCode,
                ACard.RecvInfo.BalgupsaName,
                ACard.RecvInfo.CompCode,
                ACard.RecvInfo.CompName]);
      Result := True;
    except
      on E: Exception do
      begin
        Log.E('SAVE_SL_CARD', E.Message);
        RollbackTrans;
      end;
    end;
  finally

  end;
end;

function TLocalDatabase.SAVE_SL_PAYCO(AIndex, ASeq: Integer): Boolean;
var
  APayco: TPayPayco;
begin
  try
    try
      Result := False;
      APayco := TPayPayco(Global.SaleModule.PayList[AIndex]);

      QueryExec(LOCAL_PAYCO_INSERT,
               [Global.Config.Store.StoreCode,
                Global.SaleModule.SaleDate,
                Global.Config.Store.PosNo,
                Global.SaleModule.RcpNo,
                ASeq,
                IfThen(APayco.RecvInfo.Result, 1, 0),
                APayco.SendInfo.PayAmt,
                APayco.RecvInfo.RevCardNo,
                StrToIntDef(APayco.RecvInfo.HalbuMonth, 1),
                APayco.RecvInfo.AgreeNo,
                APayco.RecvInfo.TradeNo,
                APayco.RecvInfo.TransDateTime,
                APayco.RecvInfo.BuyTypeName,
                APayco.RecvInfo.BuyCompanyName,
                APayco.RecvInfo.ApprovalCompanyCode,
                APayco.RecvInfo.ApprovalCompanyName,
                APayco.RecvInfo.PointAmt,
                APayco.RecvInfo.PointName,
                APayco.RecvInfo.CouponAmt,
                APayco.RecvInfo.CouponName]);
      Result := True;
    except
      on E: Exception do
      begin
        Log.E('SAVE_SL_PAYCO', E.Message);
        RollbackTrans;
      end;
    end;
  finally

  end;
end;

function TLocalDatabase.SAVE_SL_DISCOUNT: Boolean;
var
  Index: Integer;
begin
  try
    try
      Result := False;
      for Index := 0 to Global.SaleModule.DisCountList.Count - 1 do
      begin
        with Global.SaleModule.DisCountList[Index] do
        begin
          QueryExec(LOCAL_DISCOUNT_INSERT,
                   [Global.Config.Store.StoreCode,
                    Global.SaleModule.SaleDate,
                    Global.Config.Store.PosNo,
                    Global.SaleModule.RcpNo,
                    (Index + 1),
                    QRCode,
                    ApplyAmt,
                    Name]);
        end;
      end;
      Result := True;
    except
      on E: Exception do
      begin
        Log.E('SAVE_SL_DISCOUNT', E.Message);
        RollbackTrans;
      end;
    end;
  finally

  end;
end;

end.
