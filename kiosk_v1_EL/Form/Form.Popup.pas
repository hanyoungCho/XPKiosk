unit Form.Popup;

interface

uses
  Frame.KeyBoard, uConsts, DateUtils,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.Ani, FMX.Layouts, FMX.Gestures,
  FMX.Objects, Frame.Authentication, FMX.Controls.Presentation, FMX.Edit,
  Frame.Member.ItemType, Frame.MemberCheck;

type
  TPopup = class(TForm)
    Layout: TLayout;
    edtNumber: TEdit;
    Rectangle: TRectangle;
    LeftImage: TImage;
    RightImage: TImage;
    Image: TImage;
    FrameRectangle: TRectangle;
    Authentication1: TAuthentication;
    frmMemberItemType1: TfrmMemberItemType;
    MemberCheck1: TMemberCheck;
    edtAuth: TEdit;

    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure edtNumberKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure edtNumberChange(Sender: TObject);
    procedure edtNumberKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure FrameRectangleClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FKeyIn: Boolean;
    FKeyLength: Integer;
    FPopupLevel: TPopUpLevel;
  public
    { Public declarations }
    CloseStr: string;
    procedure CloseFormStrMrok(AStr: string);
    procedure CloseFormStrMrCancel;
  end;

var
  Popup: TPopup;

implementation

uses
  uGlobal, uFunction, uCommon, fx.Logging;

{$R *.fmx}

procedure TPopup.CloseFormStrMrCancel;
begin
  ModalResult := mrCancel;
end;

procedure TPopup.CloseFormStrMrok(AStr: string);
begin
  CloseStr := AStr;

  ModalResult := mrOk;
end;

procedure TPopup.edtNumberChange(Sender: TObject);
begin
//  Authentication1.ChangeKey(edtNumber.Text);
end;

procedure TPopup.edtNumberKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  FKeyIn := True;
  if Key in [vkF1, vkF2, vkF3, vkF4, vkF5, vkF6, vkF7, vkF8, vkF9, vkF10, vkF11, vkF12] then
  begin
    FKeyIn := False;
    Exit;
  end;

  if Key = vkCancel then
  begin
    edtAuth.Text := EmptyStr;
  end
  else if key = vkBack then
  begin
    if Length(edtNumber.Text) <= 1 then
      edtNumber.Text := EmptyStr
    else
      edtNumber.Text := Copy(edtNumber.Text, 1, Length(edtNumber.Text));
  end;
end;

procedure TPopup.edtNumberKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if Length(edtNumber.Text) >= FKeyLength then
    edtNumber.Text := Copy(edtNumber.Text, 1, FKeyLength);

  if FKeyIn then
  begin
    if FPopupLevel = plAuthentication then
      Authentication1.ChangeKey(edtNumber.Text);
  end;
end;

procedure TPopup.FormDestroy(Sender: TObject);
begin
  Authentication1.CloseFrame;
  Authentication1.Free;

  frmMemberItemType1.Free;
  DeleteChildren;
end;

procedure TPopup.FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
begin
//
end;

procedure TPopup.FormShow(Sender: TObject);
var
  ADateTime: TDateTime;
begin
  edtNumber.Text := EmptyStr;
  CloseStr := EmptyStr;
  edtNumber.SetFocus;

  FPopupLevel := Global.SaleModule.PopUpLevel;

  if FPopupLevel = plMemberItemType then
  begin
    LeftImage.Visible := True;
    RightImage.Visible := True;
    Image.Width := 900;
    Image.Height := 900;
  end
  else
    Image.Height := 1480;

  if FPopupLevel = plAuthentication then
  begin
    FKeyLength := 4;
    FrameRectangle.Width := Authentication1.Width;
    FrameRectangle.Height := Authentication1.Height;
    Authentication1.KeyBoard1.DisPlayKeyBoard;
    Authentication1.Visible := True;
  end
  else if FPopupLevel = plMemberCheck then
  begin
    FrameRectangle.Width := MemberCheck1.Width;
    FrameRectangle.Height := MemberCheck1.Height;
    MemberCheck1.KeyBoard1.DisPlayKeyBoard;
    MemberCheck1.Visible := True;
    MemberCheck1.edtMember.SetFocus;

    FKeyLength := 7;
    //XGolfMember1.PromoRec.Visible := True;
    //XGolfMember1.txtTitle.Text := '바코드 번호 입력';
  end
  else if FPopupLevel = plMemberItemType then
  begin
    FKeyLength := 0;
    FrameRectangle.Width := frmMemberItemType1.Width;
    FrameRectangle.Height := frmMemberItemType1.Height;

    frmMemberItemType1.txtTitle.Text := '회원권 선택';
    if Global.SaleModule.TeeBoxInfo.End_Time <> EmptyStr then
    begin
      ADateTime := DateStrToDateTime(FormatDateTime('yyyymmdd', now) + StringReplace(Global.SaleModule.TeeBoxInfo.End_Time, ':', '', [rfReplaceAll]) + '00');
      ADateTime := IncMinute(ADateTime, StrToIntDef(Global.Config.PrePare_Min, 5));
      frmMemberItemType1.txtUseTime.Text := Format('%s부터 이용이 가능합니다.', [FormatDateTime('hh:nn', ADateTime)]);
    end
    else
    begin
      if Global.Config.AD.USE then
      begin
        ADateTime := DateStrToDateTime(FormatDateTime('yyyymmddhhnn', now) + '00');
        ADateTime := IncMinute(ADateTime, StrToIntDef(Global.Config.PrePare_Min, 5));
        frmMemberItemType1.txtUseTime.Text := Format('%s부터 이용이 가능합니다.', [FormatDateTime('hh:nn', ADateTime)]);
      end;
    end;
    //frmMemberItemType1.ItemTypeRectangle.Visible := True;

    frmMemberItemType1.txtTasukInfo.Text := Global.SaleModule.TeeBoxInfo.FloorNm + ' ' + Global.SaleModule.TeeBoxInfo.Name + '번';
    if Global.SaleModule.TeeBoxInfo.ZoneCode = 'O' then
      frmMemberItemType1.txtTasukInfo.Text := frmMemberItemType1.txtTasukInfo.Text + ' (좌타)';

    frmMemberItemType1.Text9.Text := '';
    frmMemberItemType1.CloseRectangle.Visible := True;

    frmMemberItemType1.Visible := True;
    frmMemberItemType1.iSec := 0;
    frmMemberItemType1.txtTime.Text := Format(TimeSecCaption, [LPadB(IntToStr(Time30Sec), 2, ' ')]);
    frmMemberItemType1.Timer.Enabled := True;
  end;

  //Log.D('ShowPopup', 'showing - ' + FormatDateTime('yyymmdd hh:nn.ss', now));
end;

procedure TPopup.FrameRectangleClick(Sender: TObject);
begin
  TouchSound;
end;

end.
