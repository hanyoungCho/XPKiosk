unit Form.Popup;

interface

uses
  Frame.KeyBoard, Frame.Halbu, uConsts, DateUtils,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.Ani, FMX.Layouts, FMX.Gestures,
  FMX.Objects, Frame.Authentication, FMX.Controls.Presentation, FMX.Edit,
  Frame.XGolfMember, Frame.Member.ItemType,
  //chy newmember
  Frame.XGolfEvent;

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
    XGolfMember1: TXGolfMember;
    Halbu1: THalbu;
    frmMemberItemType1: TfrmMemberItemType;
    XGolfEvent1: TXGolfEvent;

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

  if FPopupLevel = plHalbu then
    Global.SaleModule.SelectHalbu := StrToIntDef(AStr, 0);

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
    edtNumber.Text := EmptyStr
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
      Authentication1.ChangeKey(edtNumber.Text)
    else if FPopupLevel = plPhone then
      XGolfMember1.ChangeKey(edtNumber.Text)
    else if FPopupLevel = plHalbu then
      Halbu1.ChangeKey(edtNumber.Text)
    else if FPopupLevel = plPromotionCode then
      XGolfMember1.SetPromotionCode(edtNumber.Text);
  end;
end;

procedure TPopup.FormDestroy(Sender: TObject);
begin
//  Authentication1.Image.Free;
//  Authentication1.Rectangle1.Free;
//  Authentication1.Rectangle2.Free;
//  Authentication1.Rectangle3.Free;
//  Authentication1.Image3.Free;
//  Authentication1.Image4.Free;
//  Authentication1.Image5.Free;
//  Authentication1.Image6.Free;
//  Authentication1.Text3.Free;
//  Authentication1.txtPw1.Free;
//  Authentication1.txtPw2.Free;
//  Authentication1.txtPw3.Free;
//  Authentication1.txtPw4.Free;
//  Authentication1.Text4.Free;
//  Authentication1.Text5.Free;
//  Authentication1.Rectangle4.Free;
//  Authentication1.Image1.Free;
//  Authentication1.Text17.Free;
//  Authentication1.Rectangle5.Free;
//  Authentication1.Image2.Free;
//  Authentication1.Text18.Free;
  Authentication1.CloseFrame;
  Authentication1.Free;
  XGolfMember1.CloseFrame;
  XGolfMember1.Free;
  Halbu1.CloseFrame;
  Halbu1.Free;
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

  //chy newmember, move
  if FPopupLevel in [plMemberItemType, plXGolf, plTeeboxChange, plXGolfEvent] then
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
  else if FPopupLevel in [plPhone, plPromotionCode] then
  begin
    FrameRectangle.Width := XGolfMember1.Width;
    FrameRectangle.Height := XGolfMember1.Height;
    XGolfMember1.KeyBoard1.DisPlayKeyBoard;
    XGolfMember1.Visible := True;
    if FPopupLevel = plPhone then
    begin
      FKeyLength := 9;
      XGolfMember1.PhoneRec.Visible := True;
      XGolfMember1.txtTitle.Text := '휴대폰 번호 입력';

      if global.SaleModule.AdvertPopupType = apEvent then
      begin
        XGolfMember1.recPolicy.Visible := True;
        XGolfMember1.Text18.Text := '응모하기';
      end
      else
      begin
        XGolfMember1.recPolicy.Visible := False;
      end;
    end
    else
    begin
      FKeyLength := 16;
      XGolfMember1.PromoRec.Visible := True;
      XGolfMember1.txtTitle.Text := '바코드 번호 입력';
    end;
  end
  else if FPopupLevel = plHalbu then
  begin
    FKeyLength := 2;
    FrameRectangle.Width := Halbu1.Width;
    FrameRectangle.Height := Halbu1.Height;
    Halbu1.KeyBoard1.DisPlayKeyBoard;
    Halbu1.Visible := True;
  end
  else if FPopupLevel in [plMemberItemType, plXGolf] then
  begin
    FKeyLength := 0;
    FrameRectangle.Width := frmMemberItemType1.Width;
    FrameRectangle.Height := frmMemberItemType1.Height;
    if FPopupLevel = plMemberItemType then
    begin
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
      frmMemberItemType1.ItemTypeRectangle.Visible := True;

      //chy 2020-11-04 층명칭
      //frmMemberItemType1.txtTasukInfo.Text := Format('%dF %s번', [Global.SaleModule.TeeBoxInfo.High, Global.SaleModule.TeeBoxInfo.Mno]);
      frmMemberItemType1.txtTasukInfo.Text := Global.SaleModule.TeeBoxInfo.FloorNm + ' ' + Global.SaleModule.TeeBoxInfo.Mno + '번';
      if Global.SaleModule.TeeBoxInfo.ZoneCode = 'O' then
        frmMemberItemType1.txtTasukInfo.Text := frmMemberItemType1.txtTasukInfo.Text + ' (좌타)';

      frmMemberItemType1.Text9.Text := '';
      frmMemberItemType1.CloseRectangle.Visible := True;
      frmMemberItemType1.ImgXGOLF.Visible := False;
    end
    else
    begin
      frmMemberItemType1.txtTitle.Text := Global.SaleModule.TeeBoxInfo.FloorNm + ' ' + Global.SaleModule.TeeBoxInfo.Mno + '번';

      frmMemberItemType1.txtTasukInfo.Text := EmptyStr;
      frmMemberItemType1.QnAXGolfRectangle.Visible := True;

      frmMemberItemType1.txtUseTime.Text := 'XGOLF 회원인증을 하시면' + #13#10 + '할인 요금이 적용됩니다.'; //2021-04-29 적용
      frmMemberItemType1.Text9.Text := 'XGOLF 회원인증을 하시겠습니까?';
      frmMemberItemType1.txtTime.Position.Y := frmMemberItemType1.txtTime.Position.Y - 40;

      frmMemberItemType1.ImgXGOLF.Visible := True;

      frmMemberItemType1.Text9.TextSettings.Font.Style := [];
      frmMemberItemType1.txtUseTime.TextSettings.Font.Style := [];
    end;
    frmMemberItemType1.Visible := True;
    frmMemberItemType1.iSec := 0;
    frmMemberItemType1.txtTime.Text := Format(TimeSecCaption, [LPadB(IntToStr(Time30Sec), 2, ' ')]);
    frmMemberItemType1.Timer.Enabled := True;
  end
  else if FPopupLevel = plXGolfEvent then
  begin
    FKeyLength := 0;
    FrameRectangle.Width := XGolfEvent1.Width;
    FrameRectangle.Height := XGolfEvent1.Height;
    XGolfEvent1.Visible := True;
  end;

  //Log.D('ShowPopup', 'showing - ' + FormatDateTime('yyymmdd hh:nn.ss', now));
end;

procedure TPopup.FrameRectangleClick(Sender: TObject);
begin
  TouchSound;
end;

end.
