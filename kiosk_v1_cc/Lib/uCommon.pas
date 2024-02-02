unit uCommon;

interface

uses
  uStruct, Vcl.Forms, Form.Message, mmsystem, TlHelp32, Windows,
  System.UITypes, System.SysUtils, DateUtils, FMX.Objects, FMX.Graphics;

type
  TMessageForm = class
  private
    SBMessage: TSBMessageForm;
  public
    // �غ�ð� ���� ����
    PrepareTimeSelect: Boolean;

    // sewoo
    PrintError: Boolean;

    function ShowMessageModalForm(AMsg: string; OneButton: Boolean = True; ACloseCnt: Integer = 30; ASoundPlay: Boolean = True; Retry: Boolean = False): Boolean;

    // move
    function ShowMessageModalForm1(AMsg: string; OneButton: Boolean = True; ACloseCnt: Integer = 30; ASoundPlay: Boolean = True; Cancel: Boolean = False): Boolean;

    // sewoo
    function ShowMessageModalForm2(AMsg: string; OneButton: Boolean = True; ACloseCnt: Integer = 30; ASoundPlay: Boolean = True; Print: Boolean = False): Boolean;

    function ShowMessageForm(AMsg: string; IsPassword: Boolean = False): Boolean;
    procedure HideMessageForm;
  end;

function ShowMain: Boolean;
function ShowSelectBox: Boolean;

function ShowSaleProduct: Boolean;
function ShowPopup: Boolean;
function ShowFullPopup(IsFomeShow: Boolean = False; PositionStr: string = ''): TModalResult;
procedure CloseFullPopup;
function ShowConfig: Boolean;
function ShowMasterDownload(ProgramStart, Member, Config, Product, TeeBox: Boolean): Boolean;
function ShowIntroBlank: Boolean;
function ShowIntro(ABitMap: TBitmap): Boolean;
function CheckIntro: Boolean;

procedure TouchSound(AError: Boolean = False; AChangImg: Boolean = False);

function StoreClosureCheck: Boolean; //����ð� �ʰ�, ����üũ
function StoreCloseTmCheck(AProduct: TProductInfo): Boolean; //��������ð� üũ�� �ܿ��ð� ����

procedure CloseForm;

function IsRunningProcess(const ProcName: string): Boolean;
function KillProcess(const ProcName: string): Boolean;

// �α����� ����
procedure SendLogFileToServer;

implementation

uses
  uGlobal, fx.Logging, uFunction, uConsts, Form.Popup, Form.Full.Popup,
  Form.Select.Box, Form.Sale.Product, Form.Main, Form.Config, Form.Master.Download,
  Form.Intro, Form.Intro.Blank;

function ShowMain: Boolean;
begin
  try
    Log.D('Main', 'Begin');
    if not Global.SaleModule.DeviceInit then
    begin
      Log.D('ShowMain', 'DeviceInit Fail');
      Exit;
    end;

    Result := False;
    Main := TMain.Create(nil);
    {$IFDEF DEBUG}
    Main.WindowState := wsNormal;
    Main.Width := DEBUG_WIDTH;
    Main.Height := DEBUG_HEIGHT;
    Main.Layout.Scale.X := DEBUG_SCALE;
    Main.Layout.Scale.Y := DEBUG_SCALE;
    {$ENDIF}
    Result := Main.ShowModal = mrOk;
  finally
    Log.D('Main', 'End');
    FreeAndNil(Main);
  end;
end;

function ShowSelectBox: Boolean;
begin
  try
    Log.D('ShowSelectBox', 'Begin');
    Result := False;
    SelectBox := TSelectBox.Create(nil);
    {$IFDEF DEBUG}
    SelectBox.WindowState := wsNormal;
    SelectBox.Width := DEBUG_WIDTH;
    SelectBox.Height := DEBUG_HEIGHT;
    SelectBox.ImgLayout.Scale.X := DEBUG_SCALE;
    SelectBox.ImgLayout.Scale.Y := DEBUG_SCALE;
    SelectBox.Layout.Scale.X := DEBUG_SCALE;
    SelectBox.Layout.Scale.Y := DEBUG_SCALE;
    {$ENDIF}
    Result := SelectBox.ShowModal = mrOk;
  finally
    Log.D('ShowSelectBox', 'End');
    FreeAndNil(SelectBox);
  end;
end;

function ShowSaleProduct: Boolean;
begin
  try
    try
      Log.D('ShowSaleProduct', 'Begin');
      SaleProduct := TSaleProduct.Create(nil);
      {$IFDEF DEBUG}
      SaleProduct.WindowState := wsNormal;
      SaleProduct.Width := DEBUG_WIDTH;
      SaleProduct.Height := DEBUG_HEIGHT;
      SaleProduct.Layout.Scale.X := DEBUG_SCALE;
      SaleProduct.Layout.Scale.Y := DEBUG_SCALE;
      {$ENDIF}
      Result := SaleProduct.ShowModal = mrOk;
    finally
      Log.D('ShowSaleProduct', 'End');
      FreeAndNil(SaleProduct);
    end;
  except
    on E: Exception do
      Log.E('ShowSaleProduct', E.Message);
  end;
end;

function ShowPopup: Boolean;
begin
  try
    Log.D('ShowPopup', 'Begin - ' + FormatDateTime('yyymmdd hh:nn.ss', now));
    Log.D('ShowPopup', 'Begin - ' + IntToStr(Ord(Global.SaleModule.PopUpLevel)));
    Popup := TPopup.Create(nil);
    {$IFDEF DEBUG}
    Popup.WindowState := wsNormal;
    Popup.Width := DEBUG_WIDTH;
    Popup.Height := DEBUG_HEIGHT;
    Popup.Layout.Scale.X := DEBUG_SCALE;
    Popup.Layout.Scale.Y := DEBUG_SCALE;
    {$ENDIF}
    Result := Popup.ShowModal = mrOk;
  finally
    Log.D('ShowPopup', 'End - ' + FormatDateTime('yyymmdd hh:nn.ss', now));
//    Popup.Release;
//    Popup.Children.Free;
    FreeAndNil(Popup);
  end;
end;

function ShowFullPopup(IsFomeShow: Boolean; PositionStr: string): TModalResult;
begin
  try
    try
      Log.D('ShowFullPopup', 'Begin' + ' ' + PositionStr);

      if PositionStr = EmptyStr then
      begin
        Log.D('ShowFullPopup', '��������');
        Exit;
      end;

      FullPopup := TFullPopup.Create(nil);
      {$IFDEF DEBUG}
      FullPopup.WindowState := wsNormal;
      FullPopup.Width := DEBUG_WIDTH;
      FullPopup.Height := DEBUG_HEIGHT;
      FullPopup.Layout.Scale.X := DEBUG_SCALE;
      FullPopup.Layout.Scale.Y := DEBUG_SCALE;
      {$ENDIF}
  //    if IsFomeShow then
  //      FullPopup.Show
  //    else
        Result := FullPopup.ShowModal;// = mrOk;
    finally
      Log.D('ShowFullPopup', 'End');
  //    if not IsFomeShow then
        FreeAndNil(FullPopup);
    end;
  except
    on E: Exception do
    begin
      Log.E('ShowFullPopup', E.Message);
    end;
  end;
end;

procedure CloseFullPopup;
begin
  if FullPopup <> nil then
    FullPopup.Free;
end;

function ShowConfig: Boolean;
begin
  try
    Log.D('Config', 'Begin');
    Config := TConfig.Create(nil);
    {$IFDEF DEBUG}
    Config.WindowState := wsNormal;
    Config.Width := DEBUG_WIDTH;
    Config.Height := DEBUG_HEIGHT;
    Config.Layout.Scale.X := DEBUG_SCALE;
    Config.Layout.Scale.Y := DEBUG_SCALE;
    {$ENDIF}
    Result := Config.ShowModal = mrOk;
  finally
    Log.D('Config', 'End');
    FreeAndNil(Config);
  end;
end;

function ShowMasterDownload(ProgramStart, Member, Config, Product, TeeBox: Boolean): Boolean;
begin
  try
    Log.D('ShowMasterDownload', 'Begin');
    MasterDownload := TMasterDownload.Create(nil);
    MasterDownload.ProgramStart := ProgramStart;
    MasterDownload.Member := Member;
    MasterDownload.Config := Config;
    MasterDownload.Product := Product;
    MasterDownload.TeeBox := TeeBox;
    {$IFDEF DEBUG}
    MasterDownload.WindowState := wsNormal;
    MasterDownload.Width := DEBUG_WIDTH;
    MasterDownload.Height := DEBUG_HEIGHT;
    MasterDownload.ImgLayout.Scale.X := DEBUG_SCALE;
    MasterDownload.ImgLayout.Scale.Y := DEBUG_SCALE;
    {$ENDIF}
    Result := MasterDownload.ShowModal = mrOk;
  finally
    Log.D('ShowMasterDownload', 'End');
    FreeAndNil(MasterDownload);
  end;
end;

procedure TouchSound(AError: Boolean; AChangImg: Boolean);
begin
  if not AError then
  begin
//    Global.SaleModule.SoundThread.SoundList.Add(ExtractFilePath(Application.ExeName) + 'Touch.wav');
    PlaySound(StringToOLEStr(ExtractFilePath(Application.ExeName) + 'Touch.wav'), 0, SND_ASYNC or SND_ALIAS);
  end
  else
  begin
//    Global.SaleModule.SoundThread.SoundList.Add(ExtractFilePath(Application.ExeName) + 'Error.wav');
     PlaySound(StringToOLEStr(ExtractFilePath(Application.ExeName) + 'Error.wav'), 0, SND_ASYNC or SND_ALIAS);
//    PlaySound(StringToOLEStr(ExtractFilePath(Application.ExeName) + 'Error.wav'), 0, SND_ASYNC or SND_ALIAS);
  end;

  if AChangImg then
  begin
    if SelectBox <> nil then
      SelectBox.ChangBottomImg;
  end;
end;

{ TMessageForm }

procedure TMessageForm.HideMessageForm;
begin
  try
    if SBMessage <> nil then
      FreeAndNil(SBMessage);
  finally
    Log.D('HideMessageForm', '');
  end;
end;

function TMessageForm.ShowMessageForm(AMsg: string;
  IsPassword: Boolean): Boolean;
begin
  try
    Log.D('ShowMessageForm', 'Begin');
    if SBMessageForm <> nil then
      FreeAndNil(SBMessageForm);

    SBMessageForm := TSBMessageForm.Create(nil);
    {$IFDEF DEBUG}
    SBMessageForm.WindowState := wsNormal;
    SBMessageForm.Width := DEBUG_WIDTH;
    SBMessageForm.Height := DEBUG_HEIGHT;
    SBMessageForm.Layout.Scale.X := DEBUG_SCALE;
    SBMessageForm.Layout.Scale.Y := DEBUG_SCALE;
    {$ENDIF}
    SBMessageForm.PassWord := IsPassword;
    SBMessageForm.Text.Text := AMsg;
    SBMessageForm.ButtonOneRectangle.Visible := False;
    SBMessageForm.ButtonTwolRectangle.Visible := False;
    SBMessageForm.Show;
//    Result := SBMessageForm.ShowModal = mrOk;
  finally
    Log.D('ShowMessageForm', 'End');
    FreeAndNil(SBMessageForm);
  end;
end;
function TMessageForm.ShowMessageModalForm(AMsg: string; OneButton: Boolean; ACloseCnt: Integer; ASoundPlay: Boolean; Retry: Boolean): Boolean;
begin
  try
    try
      Log.D('ShowMessageModalForm', 'Begin');
      Log.D('ShowMessageModalForm', AMsg);
  //    if SBMessageForm <> nil then
  //      SBMessageForm.Free;
      if Trim(AMsg) = EmptyStr then
      begin
        Log.D('ShowMessageModalForm', 'End');
        Exit;
      end;

      SBMessageForm := TSBMessageForm.Create(nil);
      {$IFDEF DEBUG}
      SBMessageForm.WindowState := wsNormal;
      SBMessageForm.Width := DEBUG_WIDTH;
      SBMessageForm.Height := DEBUG_HEIGHT;
      SBMessageForm.Layout.Scale.X := DEBUG_SCALE;
      SBMessageForm.Layout.Scale.Y := DEBUG_SCALE;
      {$ENDIF}
      SBMessageForm.PassWord := False;
      SBMessageForm.Text.Text := AMsg;
      SBMessageForm.FCnt := 0;
      SBMessageForm.SoundPlay := ASoundPlay;
      SBMessageForm.ButtonOneRectangle.Visible := OneButton;
      SBMessageForm.ButtonTwolRectangle.Visible := not OneButton;
      SBMessageForm.FCloseCnt := ACloseCnt;
      SBMessageForm.Timer.Enabled := True;
      if Retry then
        SBMessageForm.Text18.Text := '��õ�';
      Result := SBMessageForm.ShowModal = mrOk;
    finally
      PrepareTimeSelect := False;
      Log.D('ShowMessageModalForm', 'End');
      FreeAndNil(SBMessageForm);
    end;
  except
    on E: Exception do
    begin
      Log.D('ShowMessageModalForm', E.Message);
    end;
  end;
end;


// move
function TMessageForm.ShowMessageModalForm1(AMsg: string; OneButton: Boolean; ACloseCnt: Integer; ASoundPlay: Boolean; Cancel: Boolean): Boolean;
begin
  try
    try
      Log.D('ShowMessageModalForm', 'Begin');
      Log.D('ShowMessageModalForm', AMsg);

      if Trim(AMsg) = EmptyStr then
      begin
        Log.D('ShowMessageModalForm', 'End');
        Exit;
      end;

      SBMessageForm := TSBMessageForm.Create(nil);
      {$IFDEF DEBUG}
      SBMessageForm.WindowState := wsNormal;
      SBMessageForm.Width := DEBUG_WIDTH;
      SBMessageForm.Height := DEBUG_HEIGHT;
      SBMessageForm.Layout.Scale.X := DEBUG_SCALE;
      SBMessageForm.Layout.Scale.Y := DEBUG_SCALE;
      {$ENDIF}
      SBMessageForm.PassWord := False;
      SBMessageForm.Text.Text := AMsg;
      SBMessageForm.FCnt := 0;
      SBMessageForm.SoundPlay := ASoundPlay;
      SBMessageForm.ButtonOneRectangle.Visible := OneButton;
      SBMessageForm.ButtonTwolRectangle.Visible := not OneButton;
      SBMessageForm.FCloseCnt := ACloseCnt;
      SBMessageForm.Timer.Enabled := True;
      if Cancel then
        SBMessageForm.Text17.Text := '���';
      Result := SBMessageForm.ShowModal = mrOk;
    finally
      PrepareTimeSelect := False;
      Log.D('ShowMessageModalForm', 'End');
      FreeAndNil(SBMessageForm);
    end;
  except
    on E: Exception do
    begin
      Log.D('ShowMessageModalForm', E.Message);
    end;
  end;
end;

// sewoo
function TMessageForm.ShowMessageModalForm2(AMsg: string; OneButton: Boolean; ACloseCnt: Integer; ASoundPlay: Boolean; Print: Boolean): Boolean;
begin
  try
    try
      Log.D('ShowMessageModalForm2', 'Begin');
      Log.D('ShowMessageModalForm2', AMsg);

      if Trim(AMsg) = EmptyStr then
      begin
        Log.D('ShowMessageModalForm2', 'End');
        Exit;
      end;

      SBMessageForm := TSBMessageForm.Create(nil);
      {$IFDEF DEBUG}
      SBMessageForm.WindowState := wsNormal;
      SBMessageForm.Width := DEBUG_WIDTH;
      SBMessageForm.Height := DEBUG_HEIGHT;
      SBMessageForm.Layout.Scale.X := DEBUG_SCALE;
      SBMessageForm.Layout.Scale.Y := DEBUG_SCALE;
      {$ENDIF}
      SBMessageForm.PassWord := False;
      SBMessageForm.Text.Text := AMsg;
      SBMessageForm.FCnt := 0;
      SBMessageForm.SoundPlay := ASoundPlay;
      SBMessageForm.ButtonOneRectangle.Visible := OneButton;
      SBMessageForm.ButtonTwolRectangle.Visible := not OneButton;
      SBMessageForm.FCloseCnt := ACloseCnt;
      SBMessageForm.Timer.Enabled := False;
      PrintError := True;

      Result := SBMessageForm.ShowModal = mrOk;
    finally
      PrintError := False;
      PrepareTimeSelect := False;
      Log.D('ShowMessageModalForm2', 'End');
      FreeAndNil(SBMessageForm);
    end;
  except
    on E: Exception do
    begin
      Log.D('ShowMessageModalForm2', E.Message);
    end;
  end;
end;

function ShowIntroBlank: Boolean;
begin
  try
    IntroBlank := TIntroBlank.Create(nil);
    {$IFDEF DEBUG}
    IntroBlank.WindowState := wsNormal;
    IntroBlank.Width := DEBUG_WIDTH;
    IntroBlank.Height := DEBUG_HEIGHT;
    IntroBlank.Layout.Scale.X := DEBUG_SCALE;
    IntroBlank.Layout.Scale.Y := DEBUG_SCALE;
  //      Intro.MediaPlayerControl1.Width := DEBUG_WIDTH;
  //      Intro.MediaPlayerControl1.Height := DEBUG_HEIGHT;
    {$ENDIF}
    Result := IntroBlank.ModalResult = mrOk;
  finally
    FreeAndNil(IntroBlank);
  end;
end;

function ShowIntro(ABitMap: TBitmap): Boolean;
begin
  try
    try
      Log.D('ShowIntro', 'Begin');
//    if SBMessageForm <> nil then
//      SBMessageForm.Free;
      Intro := TIntro.Create(nil);
      {$IFDEF DEBUG}
      Intro.WindowState := wsNormal;
      Intro.Width := DEBUG_WIDTH;
      Intro.Height := DEBUG_HEIGHT;
      Intro.Layout.Scale.X := DEBUG_SCALE;
      Intro.Layout.Scale.Y := DEBUG_SCALE;
//      Intro.MediaPlayerControl1.Width := DEBUG_WIDTH;
//      Intro.MediaPlayerControl1.Height := DEBUG_HEIGHT;
      {$ENDIF}
      Intro.MediaFrame1.MediaPlayer1.Stop;
      if Global.SaleModule.AdvertisementListUp.Count <> 0 then
      begin
        Intro.MediaFrame1.MediaPlayer1.FileName := Global.SaleModule.AdvertisementListUp[0].FilePath;
      end;
        // 'D:\Project Source\XGolf\kiosk\Bin\Intro\Temp\Media1.mp4';//
//      D:\Project Source\XGolf\kiosk\Bin\Intro\Media
      Intro.BottomImage.Bitmap := ABitMap;
      Result := Intro.ShowModal = mrOk;
    finally
      Log.D('ShowIntro', 'End');
      FreeAndNil(Intro);
    end;
  except
    on E: Exception do
    begin
      Log.D('ShowIntro', E.Message);
    end;
  end;
end;

function CheckIntro: Boolean;
begin
  Result := (Intro = nil);
end;

function StoreClosureCheck: Boolean;
var
  AMsg: string;
  ADateTime, AEndTime, AStartTime: TDateTime;
begin
  try
    try
      Result := False;

      AMsg := EmptyStr;

      AStartTime := DateStrToDateTime(FormatDateTime('yyyymmdd', now) + StringReplace(Global.Config.Store.StoreStartTime, ':', '', [rfReplaceAll]) + '00');
      AEndTime := DateStrToDateTime(FormatDateTime('yyyymmdd', now) + StringReplace(Global.Config.Store.StoreEndTime, ':', '', [rfReplaceAll]) + '00');

      if Global.SaleModule.TeeBoxInfo.End_Time <> EMptyStr then
        ADateTime := DateStrToDateTime(FormatDateTime('yyyymmdd', now) + StringReplace(Global.SaleModule.TeeBoxInfo.End_Time, ':', '', [rfReplaceAll]) + '00')
      else
        ADateTime := DateStrToDateTime(FormatDateTime('yyyymmddhhnn', now) + '00');

      ADateTime := IncMinute(ADateTime, StrToIntDef(Global.Config.PrePare_Min, 5));

      if (AStartTime > now) or (ADateTime >= AEndTime) then //�������۽ð����� ���� �ð��� �۰ų�(������) Ÿ������ð��� ��������ð����� ũ��(����)
      begin
        AMsg := AMsg + '�����Ͻ� Ÿ���� ������ �����Ǿ����ϴ�.' + #13#10 +
          '(�����ð� : ' + Global.Config.Store.StoreStartTime + '~'  + Global.Config.Store.StoreEndTime + ')';
        Result := True;
      end;

      if (Global.Config.Store.StoreCloseStartTime <> EmptyStr) and (Global.Config.Store.StoreCloseEndTime <> EmptyStr) then
      begin

        if (Global.Config.Store.StoreCloseStartTime <= FormatDateTime('yyyy-mm-dd hh:nn', ADateTime)) and
        (Global.Config.Store.StoreCloseEndTime >= FormatDateTime('yyyy-mm-dd hh:nn', ADateTime)) then
        begin
          AMsg := '����ð��Դϴ�.' + #13#10 + Global.Config.Store.StoreCloseStartTime + ' - ' +
            Global.Config.Store.StoreCloseEndTime + #13#10 +  AMsg;
          Result := True;
        end;
      end;

      if AMsg <> EmptyStr then
      begin
        Global.SBMessage.ShowMessageModalForm(AMsg);
      end;
    except
      on E: Exception do
        Log.E('StoreCloseCheck', E.Message);
    end;
  finally

  end;
end;

function StoreCloseTmCheck(AProduct: TProductInfo): Boolean; //��������ð� üũ
var
  AMsg: string;
  nMin: Integer;
  ADateTime, AEndTime: TDateTime;
begin
  try
    try
      Result := False;

      AMsg := EmptyStr;

      AEndTime := DateStrToDateTime(FormatDateTime('yyyymmdd', now) + StringReplace(Global.Config.Store.StoreEndTime, ':', '', [rfReplaceAll]) + '00');

      if Global.SaleModule.TeeBoxInfo.End_Time <> EMptyStr then
      begin
        //����ð��� ���� �����ð� ���� 1�� ���� ����. AD���� 1�� ������ ���
        ADateTime := DateStrToDateTime(FormatDateTime('yyyymmdd', now) + StringReplace(Global.SaleModule.TeeBoxInfo.End_Time, ':', '', [rfReplaceAll]) + '00');
        ADateTime := IncMinute(ADateTime, 1);
      end
      else
        ADateTime := DateStrToDateTime(FormatDateTime('yyyymmddhhnn', now) + '00');

      ADateTime := IncMinute(ADateTime, StrToIntDef(Global.Config.PrePare_Min, 5));

      if (ADateTime < AEndTime) then
      begin
        nMin :=  MinutesBetween(AEndTime, ADateTime);
        if nMin <= StrToInt(AProduct.One_Use_Time) then
          AMsg := AMsg + '�������� �ð���' + FormatDateTime('hh:nn', AEndTime) + '�Դϴ�.' + #13#10 +
                         '���� �ð� ������ �����Ͻðڽ��ϱ�?';
      end;

      if AMsg <> EmptyStr then
      begin
        if Global.SBMessage.ShowMessageModalForm(AMsg, False) then
        begin
          Global.SaleModule.FStoreCloseOver := True;
          Global.SaleModule.FStoreCloseOverMin := IntToStr(nMin);
        end
        else //�����ð����� �������� ����
        begin
          Result := True;
        end;
      end;

    except
      on E: Exception do
        Log.E('StoreCloseCheck', E.Message);
    end;
  finally

  end;
end;

procedure CloseForm;
begin
  try
//    Exit;
    if Popup <> nil then
    begin
      Log.D('CloseForm', 'POUP Close nil �ƴ�');
      {$IFDEF DEBUG}
      Global.SBMessage.ShowMessageModalForm('POUP Close nil �ƴ�');
      {$ENDIF}
      FreeAndNil(Popup);
    end;

    if FullPopup <> nil then
    begin
      Log.D('CloseForm', 'FullPopup Close nil �ƴ�');
      {$IFDEF DEBUG}
      Global.SBMessage.ShowMessageModalForm('FullPopup Close nil �ƴ�');
      {$ENDIF}
      FreeAndNil(FullPopup);
    end;

    if SaleProduct <> nil then
    begin
      Log.D('CloseForm', 'SaleProduct Close nil �ƴ�');
      {$IFDEF DEBUG}
      Global.SBMessage.ShowMessageModalForm('SaleProduct Close nil �ƴ�');
      {$ENDIF}
      FreeAndNil(SaleProduct);
    end;

    if SBMessageForm <> nil then
    begin
      Log.D('CloseForm', 'SBMessageForm Close nil �ƴ�');
      {$IFDEF DEBUG}
      Global.SBMessage.ShowMessageModalForm('SBMessageForm Close nil �ƴ�');
      {$ENDIF}
      FreeAndNil(SBMessageForm);
    end;

//    if Intro <> nil then
//    begin
//      Log.D('CloseForm', 'Intro Close nil �ƴ�');
//      {$IFDEF DEBUG}
//      Global.SBMessage.ShowMessageModalForm('Intro Close nil �ƴ�');
//      {$ENDIF}
//      FreeAndNil(Intro);
//    end;
  finally

  end;
end;

function IsRunningProcess(const ProcName: string): Boolean;
var
  Process32: TProcessEntry32;
  SHandle: THandle;
  Next: Boolean;

begin
  Result := False;

  Process32.dwSize := SizeOf(TProcessEntry32);
  SHandle := CreateToolHelp32Snapshot(TH32CS_SNAPPROCESS, 0);

  // ���μ��� ����Ʈ�� ���鼭 �Ű������� ���� �̸��� ���� ���μ����� ���� ��� True�� ��ȯ�ϰ� ��������
  if Process32First(SHandle, Process32) then
  begin
    repeat
      Next := Process32Next(SHandle, Process32);
      if AnsiCompareText(Process32.szExeFile, Trim(ProcName)) = 0 then
      begin
        Result := True;
        break;
      end;
    until not Next;
  end;
  CloseHandle(SHandle);
end;

function KillProcess(const ProcName: string): Boolean;
var
  Process32: TProcessEntry32;
  SHandle: THandle;
  Next: Boolean;
  hProcess: THandle;
  i: Integer;
begin
  Result := True;

  Process32.dwSize        := SizeOf(TProcessEntry32);
  Process32.th32ProcessID := 0;
  SHandle                 := CreateToolHelp32Snapshot(TH32CS_SNAPPROCESS, 0);

  // �����ϰ��� �ϴ� ���μ����� ���������� Ȯ���ϴ� �ǹ̿� �Բ�...
  if Process32First(SHandle, Process32) then
  begin
    repeat
      Next := Process32Next(SHandle, Process32);
      if AnsiCompareText(Process32.szExeFile, Trim(ProcName)) = 0 then
        break;
    until not Next;
  end;
  CloseHandle(SHandle);

  // ���μ����� �������̶�� Open & Terminate
  if Process32.th32ProcessID <> 0 then
  begin
    hProcess := OpenProcess(PROCESS_TERMINATE, True, Process32.th32ProcessID);
    if hProcess <> 0 then
    begin
      if not TerminateProcess(hProcess, 0) then
        Result := False;
    end
    // ���μ��� ���� ����
    else
    Result := False;

    CloseHandle(hProcess);
  end // if Process32.th32ProcessID<>0
  else
    Result := False;
end;

procedure SendLogFileToServer;
var
  ServerIP, SaveFolder, Files: AnsiString;
begin
//  ServerIP := 'update.solbipos.kr';
//  SaveFolder := 'XTOUCH_KIOSK' + FormatDateTime('yyyymm', Now) + '\' + Copy(Global.Config.OAuth.DeviceID, 1, 5) + '\' + Copy(Global.Config.OAuth.DeviceID, 6, 5);
//  // ������ ������ �α������� �����Ѵ�.
//  Files := 'Logs\' + FormatDateTime('yyyy-mm-dd', Date - 1) + '.txt' + ' ' +
//           'Logs\' + FormatDateTime('yyyy-mm-dd', Date) + '.txt' + ' ' +
//           'VanLog\' + FormatDateTime('yyyymmdd', Date - 1) + '.log' + ' ' +
//           'VanLog\' + FormatDateTime('yyyymmdd', Date) + '.log';
//  WinExec(PAnsiChar('PosLogFileClient.exe ' + ServerIP + ' ' + SaveFolder + ' ' + Files), SW_NORMAL);
end;

end.
