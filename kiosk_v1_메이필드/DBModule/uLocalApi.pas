unit uLocalApi;

interface

uses
  Generics.Collections, System.SysUtils, Uni, MySQLUniProvider, Data.DB,
  uStruct;

type
  TLocalApi = class
    private
      FConnection: TUniConnection;
      FMySQLUniProvider: TMySQLUniProvider;
      FStoreProc: TUniStoredProc;
    public
      constructor Create;
      destructor Destroy; override;

      function DBConnection: Boolean; //ȸ�����������

      function GetMemberListToDB: TList<TMemberInfo>; //ȸ������
      function SetMemberToDB(AMemberInfo: TMemberInfo): Boolean;
  end;

implementation

uses
  uGlobal, fx.Logging, uFunction;

{ TLocalApi }

constructor TLocalApi.Create;
begin
  FConnection := TUniConnection.Create(nil);
  FMySQLUniProvider := TMySQLUniProvider.Create(nil);
  FStoreProc := TUniStoredProc.Create(nil);
end;

destructor TLocalApi.Destroy;
begin
  FConnection.Close;
  FConnection.Free;

  FMySQLUniProvider.Free;

  FStoreProc.Close;
  FStoreProc.Free;

  inherited;
end;

function TLocalApi.DBConnection: Boolean;
begin
  Result := False;
  try
    try

      Log.D('DB����', 'localhost:' + IntToStr(Global.Config.LocalDBInfo.DB_PORT));
      FConnection.ProviderName := 'MySql';
      FConnection.Server := 'localhost';
      FConnection.Port := Global.Config.LocalDBInfo.DB_PORT;
      FConnection.Username := 'xgolf';
      FConnection.Password := 'xgolf0105';
      FConnection.Database := 'xgolf';
      FConnection.Connect;

      Result := FConnection.Connected;
      Log.D('DB����', IfThen(Result, '����', '����'));

    except
      on E: Exception do
        Log.E('DB ���� ����', E.Message);
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
      Connection := FConnection;

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
        //�� ����		customer_cd
        //��ü �ڵ�		group_cd
        rMemberInfo.MemberCardUid := FieldByName('member_card_uid').AsString; //ȸ�� ī�� ������ȣ
        //����ī�� ������ȣ		welfare_cd
        //��� ��ȣ		emp_no
        //ȸ�� ����Ʈ		member_point
        //ȸ�� ������		dc_rate
        rMemberInfo.CardNo := FieldByName('qr_cd').AsString;
        rMemberInfo.FingerStr := FieldByName('finger1').AsString;
        rMemberInfo.FingerStr_2 := FieldByName('finger2').AsString;
        //Ư��ȸ�� ����		special_yn
        rMemberInfo.Use := FieldByName('del_yn').AsString = 'Y';

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
begin

  Result := False;

  with TUniQuery.Create(nil) do
  begin

    try

      try
        Connection := FConnection;

        sSex := '1';
        if AMemberInfo.Sex = 'W' then
          sSex := '2';

        sUse := 'N';
        if AMemberInfo.Use = True then
          sUse := 'Y';

        sSql := ' INSERT INTO MEMBER ' +
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
      Close;
      Free;
    end;

  end;

end;

end.
