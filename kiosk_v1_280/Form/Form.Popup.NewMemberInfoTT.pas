unit Form.Popup.NewMemberInfoTT;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, Winapi.Windows, Winapi.Messages,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.Edit, FMX.Layouts,
  uTabTipHelper;

type
  TfrmNewMemberInfoTT = class(TForm)
    Rectangle: TRectangle;
    Layout: TLayout;
    Rectangle7: TRectangle;
    recTop: TRectangle;
    Text3: TText;
    Rectangle4: TRectangle;
    Text1: TText;
    edtPhone: TEdit;
    Rectangle5: TRectangle;
    Text2: TText;
    edtName: TEdit;
    Label1: TLabel;
    recBtn: TRectangle;
    recClose: TRectangle;
    Image3: TImage;
    Text17: TText;
    recAdd: TRectangle;
    Image4: TImage;
    Text18: TText;
    Rectangle1: TRectangle;
    recTabTip: TRectangle;
    PolicyAll: TRectangle;
    recPolicyAll: TRectangle;
    imgPolicyAllNon: TImage;
    imgPolicyAll: TImage;
    txtPolicyAll: TText;
    Text10: TText;
    Rectangle2: TRectangle;
    laError: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure recAddClick(Sender: TObject);
    procedure recCloseClick(Sender: TObject);
    procedure recTabTipClick(Sender: TObject);
    procedure imgPolicyAllClick(Sender: TObject);
  private
    { Private declarations }

    TabTip: TTabTip;
  public
    { Public declarations }
    function FindTrayButtonWindow: THandle;
  end;

var
  frmNewMemberInfoTT: TfrmNewMemberInfoTT;

implementation

uses
  uGlobal, uCommon, uConsts, uStruct, fx.Logging;

{$R *.fmx}

procedure TfrmNewMemberInfoTT.FormCreate(Sender: TObject);
var
  AHWND: HWND;
  //TrayButtonWindow: THandle;
begin
  AHWND := THandle(Self.Handle);
  TabTip.Launch(AHWND);

  {
  TrayButtonWindow := FindTrayButtonWindow;
  if TrayButtonWindow > 0 then
  begin
    PostMessage(TrayButtonWindow, WM_LBUTTONDOWN, MK_LBUTTON, $00010001);
    PostMessage(TrayButtonWindow, WM_LBUTTONUP, 0, $00010001);
  end;
  }

  PolicyAll.Visible := False;
  if Global.SaleModule.AdvertPopupType = apMember then
    PolicyAll.Visible := True;

  laError.text := '';
  edtName.SetFocus;
end;

procedure TfrmNewMemberInfoTT.FormDestroy(Sender: TObject);
begin

  if TabTip.IsVisible then
  begin
    TabTip.Close;
    TabTip.Termiante;
    Log.D('TabTip', 'Close !');
  end;

  if (Global.Config.Store.StoreCode = 'C7001') then //유나우 골프스튜디오
    SetCursorPos(1040, 1440)
  else
    SetCursorPos(1040, 1540); //마우스 커서가 가야 할 버튼의 위치
  Mouse_Event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
  Mouse_Event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);

  sleep(100);

  if (Global.Config.Store.StoreCode = 'C7001') then //유나우 골프스튜디오
    SetCursorPos(1040, 1440)
  else
    SetCursorPos(1040, 1540); //마우스 커서가 가야 할 버튼의 위치
  Mouse_Event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
  Mouse_Event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
end;

procedure TfrmNewMemberInfoTT.imgPolicyAllClick(Sender: TObject);
begin
  if txtPolicyAll.Text = '0' then
  begin
    txtPolicyAll.Text := '1';
    imgPolicyAll.Visible := True;
    imgPolicyAllNon.Visible := False;
  end
  else
  begin
    txtPolicyAll.Text := '0';
    imgPolicyAll.Visible := False;
    imgPolicyAllNon.Visible := True;
  end;
end;

procedure TfrmNewMemberInfoTT.recAddClick(Sender: TObject);
var
  sName, sPhone, sPhoneCheck, sPhoneTemp: String;
  bNum, bMember: Boolean;
  Index: Integer;
  NewMember: TMemberInfo;
begin

  if (Trim(edtName.Text) = '') or (Trim(edtPhone.Text) = '') then
  begin
    //Global.SBMessage.ShowMessageModalForm(MSG_NEWMEMBER_NULL);
    laError.Text := MSG_NEWMEMBER_NULL;
    Exit;
  end;

  sName := Trim(edtName.Text);
  sPhone := Trim(edtPhone.Text);

  bNum := True;

  sPhoneCheck := StringReplace(sPhone, '-', '', [rfReplaceAll]);
  for Index := 1 to Length(sPhoneCheck) do
  begin
    if not CharInSet(sPhoneCheck[Index], ['0'..'9']) then begin
      bNum := False;
      Break;
    end;
  end;

  if bNum = False then
  begin
    //Global.SBMessage.ShowMessageModalForm(MSG_NEWMEMBER_PHONE_FAIL);
    laError.Text := MSG_NEWMEMBER_PHONE_FAIL;
    Exit;
  end;

  bMember := False;
  for Index := 0 to Global.SaleModule.MemberUpdateList.Count - 1 do
  begin
    if not Global.SaleModule.MemberUpdateList[Index].Use then
      Continue;

    if Global.SaleModule.MemberUpdateList[Index].Name <> sName then
      Continue;

    sPhoneTemp := StringReplace(Global.SaleModule.MemberUpdateList[Index].Tel_Mobile, '-', '', [rfReplaceAll]);
    if sPhoneTemp = sPhoneCheck then
    begin
      bMember := True;
      //Log.D('MemberUpdateList 회원명', Global.SaleModule.MemberUpdateList[Index].Name);
      //Log.D('MemberUpdateList 회원지문', Global.SaleModule.MemberUpdateList[Index].FingerStr);
      //Global.SaleModule.Member := Global.SaleModule.MemberUpdateList[Index];
      Break;
    end;
  end;

  if not bMember then
  begin
    for Index := 0 to Global.SaleModule.MemberList.Count - 1 do
    begin
      if not Global.SaleModule.MemberList[Index].Use then
        Continue;

      if Global.SaleModule.MemberList[Index].Name <> sName then
        Continue;

      sPhoneTemp := StringReplace(Global.SaleModule.MemberList[Index].Tel_Mobile, '-', '', [rfReplaceAll]);
      if sPhoneTemp = sPhoneCheck then
      begin
        bMember := True;
        //Log.D('MemberList 회원명', Global.SaleModule.MemberList[Index].Name);
        //Log.D('MemberList 회원지문', Global.SaleModule.MemberList[Index].FingerStr);
        //Global.SaleModule.Member := Global.SaleModule.MemberList[Index];
        Break;
      end;
    end;
  end;

  if bMember = True then
  begin
    //Global.SBMessage.ShowMessageModalForm(MSG_NEWMEMBER_USE);
    laError.Text := MSG_NEWMEMBER_USE;
    Exit;
  end;

  if (Global.SaleModule.AdvertPopupType = apMember) and (PolicyAll.Visible = True) then
  begin
    if (txtPolicyAll.Text <> '1') then
    begin
      //Global.SBMessage.ShowMessageModalForm(MSG_NEW_MEMBER);
      laError.Text := MSG_NEW_MEMBER;
      Exit;
    end
  end;

  NewMember.Name := sName;
  NewMember.Tel_Mobile := sPhoneCheck;
  Global.SaleModule.NewMember := NewMember;

  ModalResult := mrOk;
end;

procedure TfrmNewMemberInfoTT.recCloseClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmNewMemberInfoTT.recTabTipClick(Sender: TObject);
var
  AHWND: HWND;
  TrayButtonWindow: THandle;
begin

  if TabTip.IsVisible then
  begin
    TabTip.Close;
    TabTip.Termiante;
    Log.D('TabTip', 'Close !');
  end;

  AHWND := THandle(Self.Handle);
  TabTip.Launch(AHWND);
  {
  // Post mouse click messages to it
  TrayButtonWindow := FindTrayButtonWindow;
  if TrayButtonWindow > 0 then
  begin
    PostMessage(TrayButtonWindow, WM_LBUTTONDOWN, MK_LBUTTON, $00010001);
    PostMessage(TrayButtonWindow, WM_LBUTTONUP, 0, $00010001);
  end;
  }
end;

function TfrmNewMemberInfoTT.FindTrayButtonWindow: THandle;
var
  ShellTrayWnd: THandle;
  TrayNotifyWnd: THandle;
begin
  Result := 0;
  ShellTrayWnd := FindWindow('Shell_TrayWnd', nil);
  if ShellTrayWnd > 0 then
  begin
    TrayNotifyWnd := FindWindowEx(ShellTrayWnd, 0, 'TrayNotifyWnd', nil);
    if TrayNotifyWnd > 0 then
    begin
      Result := FindWindowEx(TrayNotifyWnd, 0, 'TIPBand', nil);
    end;
  end;
end;

end.
