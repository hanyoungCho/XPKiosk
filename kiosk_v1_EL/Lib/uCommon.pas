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
    // 준비시간 변경 여부
    PrepareTimeSelect: Boolean;
    PrintError: Boolean;

    function ShowMessageModalForm(AMsg: string; OneButton: Boolean = True; ACloseCnt: Integer = 30; ASoundPlay: Boolean = True; Retry: Boolean = False): Boolean;
    function ShowMessageModalForm2(AMsg: string; OneButton: Boolean = True; ACloseCnt: Integer = 30; ASoundPlay: Boolean = True; Print: Boolean = False): Boolean;

    function ShowMessageForm(AMsg: string; IsPassword: Boolean = False): Boolean;
    procedure HideMessageForm;
  end;

function ShowMain: Boolean;
function ShowSelectBox: Boolean;

function ShowPopup: Boolean;
function ShowFullPopup(IsFomeShow: Boolean = False; PositionStr: string = ''): TModalResult;
procedure CloseFullPopup;
function ShowConfig: Boolean;
function ShowMasterDownload(ProgramStart, Member, Config, Product, TeeBox: Boolean): Boolean;
function ShowIntroBlank: Boolean;
function ShowIntro(ABitMap: TBitmap): Boolean;
function CheckIntro: Boolean;

procedure TouchSound(AError: Boolean = False; AChangImg: Boolean = False);
//function StoreCloseCheck: Boolean;
//function StoreClosureCheck: Boolean; //휴장체크
function StoreCloseTmCheck(AProduct: TProductInfo): Boolean; //매장종료시간 체크


procedure CloseForm;

function IsRunningProcess(const ProcName: string): Boolean;
function KillProcess(const ProcName: string): Boolean;


implementation

uses
  uGlobal, fx.Logging, uFunction, uConsts, Form.Popup, Form.Full.Popup,
  Form.Select.Box, Form.Main, Form.Config, Form.Master.Download,
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

function ShowPopup: Boolean;
begin
  try
    Log.D('ShowPopup', 'Begin');
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
    Log.D('ShowPopup', 'End');
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
        Log.D('ShowFullPopup', '빠져나감');
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
      Result := FullPopup.ShowModal;// = mrOk;
    finally
      Log.D('ShowFullPopup', 'End');
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
  try

    if not AError then
    begin
      PlaySound(StringToOLEStr(ExtractFilePath(Application.ExeName) + 'Touch.wav'), 0, SND_ASYNC or SND_ALIAS);
    end
    else
    begin
      PlaySound(StringToOLEStr(ExtractFilePath(Application.ExeName) + 'Error.wav'), 0, SND_ASYNC or SND_ALIAS);
    end;

    if AChangImg then
    begin
      if SelectBox <> nil then
        SelectBox.ChangBottomImg;
    end;

  except
    on E: Exception do
    begin
      Log.D('TouchSound', E.Message);
    end;
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

function TMessageForm.ShowMessageForm(AMsg: string; IsPassword: Boolean): Boolean;
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
        Log.D('ShowMessageModalForm', 'EmptyStr End');
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
        SBMessageForm.Text18.Text := '재시도';
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

//chy sewoo
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
      Intro := TIntro.Create(nil);
      {$IFDEF DEBUG}
      Intro.WindowState := wsNormal;
      Intro.Width := DEBUG_WIDTH;
      Intro.Height := DEBUG_HEIGHT;
      Intro.Layout.Scale.X := DEBUG_SCALE;
      Intro.Layout.Scale.Y := DEBUG_SCALE;
      {$ENDIF}
      Intro.MediaFrame1.MediaPlayer1.Stop;
      if Global.SaleModule.AdvertisementListUp.Count <> 0 then
      begin
        Intro.MediaFrame1.Image.Bitmap.LoadFromFile(Global.SaleModule.AdvertisementListUp[0].FilePath);
      end;

      Intro.BottomImage.Bitmap := ABitMap;
      Result := Intro.ShowModal = mrOk;
    finally
      FreeAndNil(Intro);
      Log.D('ShowIntro', 'End');
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
{
function StoreCloseCheck: Boolean;
var
  IsTimeOver: Boolean;
  AMsg: string;
  ADateTime, AEndTime: TDateTime;
begin
  try
    try
      Result := False;

      IsTimeOver := False;
      AMsg := EmptyStr;

//      ADateTime := DateStrToDateTime(FormatDateTime('yyyymmdd', now) + StringReplace(Global.Config.Store.StoreEndTime, ':', '', [rfReplaceAll]) + '00');

      if Global.SaleModule.TeeBoxInfo.End_Time <> EMptyStr then
        ADateTime := DateStrToDateTime(FormatDateTime('yyyymmdd', now) + StringReplace(Global.SaleModule.TeeBoxInfo.End_Time, ':', '', [rfReplaceAll]) + '00')
      else
        ADateTime := DateStrToDateTime(FormatDateTime('yyyymmddhhnn', now) + '00');

      AEndTime := DateStrToDateTime(FormatDateTime('yyyymmdd', now) + StringReplace(Global.Config.Store.StoreEndTime, ':', '', [rfReplaceAll]) + '00');

      ADateTime := IncMinute(ADateTime, StrToIntDef(Global.Config.PrePare_Min, 5));

      if (ADateTime < AEndTime) and (Copy(Global.SaleModule.TeeBoxInfo.End_Time, 1, 2) <> '00') then
      begin
        if MinutesBetween(AEndTime, ADateTime) <= 70 then
          AMsg := AMsg + '영업종료 시간은' + FormatDateTime('hh:nn', AEndTime) + '입니다.' + #13#10 +
                         '남은 시간 예약을 진행하시겠습니까?';

        IsTimeOver := True;
      end
      else
      begin
        AMsg := AMsg + '선택하신 타석은 예약이 마감되었습니다.' + #13#10 +
          '(영업시간 : ' + Global.Config.Store.StoreStartTime + '~'  + Global.Config.Store.StoreEndTime + ')';
        Result := True;
      end;

      if IsTimeOver then
      begin
        if AMsg <> EmptyStr then
        begin
          if not Global.SBMessage.ShowMessageModalForm(AMsg, False) then
            Result := True;
        end;
      end
      else if AMsg <> EmptyStr then
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
}
{
function StoreClosureCheck: Boolean; //휴장체크
var
  AMsg: string;
  ADateTime, AEndTime, AStartTime: TDateTime;
begin
  try
    try
      Result := False;

      AMsg := EmptyStr;

      if Global.SaleModule.TeeBoxInfo.End_Time <> EMptyStr then
        ADateTime := DateStrToDateTime(FormatDateTime('yyyymmdd', now) + StringReplace(Global.SaleModule.TeeBoxInfo.End_Time, ':', '', [rfReplaceAll]) + '00')
      else
        ADateTime := DateStrToDateTime(FormatDateTime('yyyymmddhhnn', now) + '00');

      AStartTime := DateStrToDateTime(FormatDateTime('yyyymmdd', now) + StringReplace(Global.Config.Store.StoreStartTime, ':', '', [rfReplaceAll]) + '00');
      AEndTime := DateStrToDateTime(FormatDateTime('yyyymmdd', now) + StringReplace(Global.Config.Store.StoreEndTime, ':', '', [rfReplaceAll]) + '00');

      ADateTime := IncMinute(ADateTime, StrToIntDef(Global.Config.PrePare_Min, 5));

      if (Global.Config.Store.StoreStartTime > Global.Config.Store.StoreEndTime) then //익일 종료
      begin
        if (AStartTime > now) and (ADateTime >= AEndTime) then
        begin
          AMsg := AMsg + '선택하신 타석은 예약이 마감되었습니다.' + #13#10 +
            '(영업시간 : ' + Global.Config.Store.StoreStartTime + '~'  + Global.Config.Store.StoreEndTime + ')';
          Result := True;
        end;
      end
      else
      begin
        if (AStartTime > now) or (ADateTime >= AEndTime) then
        begin
          AMsg := AMsg + '선택하신 타석은 예약이 마감되었습니다.' + #13#10 +
            '(영업시간 : ' + Global.Config.Store.StoreStartTime + '~'  + Global.Config.Store.StoreEndTime + ')';
          Result := True;
        end;
      end;

      if AMsg <> EmptyStr then
      begin
        Global.SBMessage.ShowMessageModalForm(AMsg);
      end;
    except
      on E: Exception do
        Log.E('StoreClosureCheck', E.Message);
    end;
  finally

  end;
end;
}
function StoreCloseTmCheck(AProduct: TProductInfo): Boolean; //매장종료시간 체크
var
  AMsg: string;
  nMin: Integer;
  ADateTime, AEndTime: TDateTime;
  sNowHHNN: String;
begin
  try
    try
      Result := False;
      AMsg := EmptyStr;

      if (Global.Config.Store.StoreStartTime < Global.Config.Store.StoreEndTime) then //금일영업
      begin
        if Global.SaleModule.TeeBoxInfo.End_Time <> EMptyStr then
          ADateTime := DateStrToDateTime(FormatDateTime('yyyymmdd', now) + StringReplace(Global.SaleModule.TeeBoxInfo.End_Time, ':', '', [rfReplaceAll]) + '00')
        else
          ADateTime := DateStrToDateTime(FormatDateTime('yyyymmddhhnn', now) + '00');

        ADateTime := IncMinute(ADateTime, StrToIntDef(Global.Config.PrePare_Min, 5));

        AEndTime := DateStrToDateTime(FormatDateTime('yyyymmdd', now) + StringReplace(Global.Config.Store.StoreEndTime, ':', '', [rfReplaceAll]) + '00');
      end
      else // 익일/정시 종료 - 2023.04.17
      begin
        //chy test
        sNowHHNN := FormatDateTime('hh:nn', now);
        if Global.SaleModule.TeeBoxInfo.End_Time <> EMptyStr then
        begin
          if Global.SaleModule.TeeBoxInfo.End_Time < sNowHHNN then //종료시간이 현재보다 작으면 익일
            ADateTime := DateStrToDateTime(FormatDateTime('yyyymmdd', now + 1) + StringReplace(Global.SaleModule.TeeBoxInfo.End_Time, ':', '', [rfReplaceAll]) + '00')
          else
            ADateTime := DateStrToDateTime(FormatDateTime('yyyymmdd', now) + StringReplace(Global.SaleModule.TeeBoxInfo.End_Time, ':', '', [rfReplaceAll]) + '00');
        end
        else
          ADateTime := DateStrToDateTime(FormatDateTime('yyyymmddhhnn', now) + '00');

        ADateTime := IncMinute(ADateTime, StrToIntDef(Global.Config.PrePare_Min, 5));

        if Global.Config.Store.StoreStartTime > sNowHHNN  then
          AEndTime := DateStrToDateTime(FormatDateTime('yyyymmdd', now) + StringReplace(Global.Config.Store.StoreEndTime, ':', '', [rfReplaceAll]) + '00')
        else
          AEndTime := DateStrToDateTime(FormatDateTime('yyyymmdd', now + 1) + StringReplace(Global.Config.Store.StoreEndTime, ':', '', [rfReplaceAll]) + '00');
      end;

      if (ADateTime < AEndTime) then
      begin
        nMin :=  MinutesBetween(AEndTime, ADateTime);
        if nMin <= StrToInt(AProduct.One_Use_Time) then
          AMsg := AMsg + '영업종료 시간은' + FormatDateTime('hh:nn', AEndTime) + '입니다.' + #13#10 +
                         '남은 시간 예약을 진행하시겠습니까?';
      end;

      if AMsg <> EmptyStr then
      begin
        if Global.SBMessage.ShowMessageModalForm(AMsg, False) then
        begin
          Global.SaleModule.FStoreCloseOver := True;
          Global.SaleModule.FStoreCloseOverMin := IntToStr(nMin);
        end
        else //남은시간으로 예약진행 않함
        begin
          Result := True;
        end;
      end;

    except
      on E: Exception do
        Log.E('StoreCloseTmCheck', E.Message);
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
      Log.D('CloseForm', 'POUP Close nil 아님');
      {$IFDEF DEBUG}
      Global.SBMessage.ShowMessageModalForm('POUP Close nil 아님');
      {$ENDIF}
      FreeAndNil(Popup);
    end;

    if FullPopup <> nil then
    begin
      Log.D('CloseForm', 'FullPopup Close nil 아님');
      {$IFDEF DEBUG}
      Global.SBMessage.ShowMessageModalForm('FullPopup Close nil 아님');
      {$ENDIF}
      FreeAndNil(FullPopup);
    end;

    if SBMessageForm <> nil then
    begin
      Log.D('CloseForm', 'SBMessageForm Close nil 아님');
      {$IFDEF DEBUG}
      Global.SBMessage.ShowMessageModalForm('SBMessageForm Close nil 아님');
      {$ENDIF}
      FreeAndNil(SBMessageForm);
    end;

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

  // 프로세스 리스트를 돌면서 매개변수로 받은 이름과 같은 프로세스가 있을 경우 True를 반환하고 루프종료
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

  // 종료하고자 하는 프로세스가 실행중인지 확인하는 의미와 함께...
  if Process32First(SHandle, Process32) then
  begin
    repeat
      Next := Process32Next(SHandle, Process32);
      if AnsiCompareText(Process32.szExeFile, Trim(ProcName)) = 0 then
        break;
    until not Next;
  end;
  CloseHandle(SHandle);

  // 프로세스가 실행중이라면 Open & Terminate
  if Process32.th32ProcessID <> 0 then
  begin
    hProcess := OpenProcess(PROCESS_TERMINATE, True, Process32.th32ProcessID);
    if hProcess <> 0 then
    begin
      if not TerminateProcess(hProcess, 0) then
        Result := False;
    end
    // 프로세스 열기 실패
    else
    Result := False;

    CloseHandle(hProcess);
  end // if Process32.th32ProcessID<>0
  else
    Result := False;
end;

end.
