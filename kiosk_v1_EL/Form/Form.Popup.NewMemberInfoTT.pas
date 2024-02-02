unit Form.Popup.NewMemberInfoTT;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, Winapi.Windows,
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
    laError: TLabel;
    recBtn: TRectangle;
    recClose: TRectangle;
    Image3: TImage;
    Text17: TText;
    recAdd: TRectangle;
    Image4: TImage;
    Text18: TText;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure recAddClick(Sender: TObject);
    procedure recCloseClick(Sender: TObject);
  private
    { Private declarations }

    TabTip: TTabTip;
  public
    { Public declarations }
  end;

var
  frmNewMemberInfoTT: TfrmNewMemberInfoTT;

implementation

uses
  uGlobal, uCommon, uConsts, uStruct;

{$R *.fmx}

procedure TfrmNewMemberInfoTT.FormCreate(Sender: TObject);
var
  AHWND: HWND;
begin
  AHWND := THandle(Self.Handle);

  TabTip.Launch(AHWND);

  laError.text := '';
  edtName.SetFocus;
end;

procedure TfrmNewMemberInfoTT.FormDestroy(Sender: TObject);
begin
  if TabTip.IsVisible then
  begin
    TabTip.Close;
    TabTip.Termiante;
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

  NewMember.Name := sName;
  NewMember.Tel_Mobile := sPhoneCheck;
  Global.SaleModule.NewMember := NewMember;

  ModalResult := mrOk;
end;

procedure TfrmNewMemberInfoTT.recCloseClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

end.
