unit Form.Popup;

interface

uses
  Frame.KeyBoard, Frame.Halbu, uConsts, DateUtils,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.Ani, FMX.Layouts, FMX.Gestures,
  FMX.Objects, Frame.Authentication, FMX.Controls.Presentation, FMX.Edit,
  Frame.XGolfMember, Frame.Member.ItemType,
  //chy newmember
  Frame.NewMember, Frame.NewMember.ItemType, Frame.XGolfEvent,
  Frame.Advert.ItemType;

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
    Halbu1: THalbu;
    frmNewMemberItemType1: TfrmNewMemberItemType;
    frmMemberItemType1: TfrmMemberItemType;
    NewMember1: TNewMember;
    XGolfEvent1: TXGolfEvent;
    Timer1: TTimer;
    frmAdvertItemType1: TfrmAdvertItemType;
    XGolfMember1: TXGolfMember;

    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure edtNumberKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure edtNumberChange(Sender: TObject);
    procedure edtNumberKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure FrameRectangleClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    FKeyIn: Boolean;
    FKeyLength: Integer;
    FPopupLevel: TPopUpLevel;
  public
    { Public declarations }
    CloseStr: string;
    iSec: Integer;

    procedure CloseFormStrMrok(AStr: string);
    procedure CloseFormStrMrCancel;

    //chy newmember
    procedure NewMemberPolicy;
    //procedure FacilityProductAuth;
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
    if FPopupLevel in [plAuthentication, plParkingDay] then
      Authentication1.ChangeKey(edtNumber.Text)
    else if FPopupLevel in [plPhone, plParkingPrint, plStamp] then
    begin
      XGolfMember1.ChangeKey(edtNumber.Text);

      if FPopupLevel = plParkingPrint then
        iSec := 0;
    end
    else if FPopupLevel = plHalbu then
      Halbu1.ChangeKey(edtNumber.Text)
    else if FPopupLevel = plPromotionCode then
      XGolfMember1.SetPromotionCode(edtNumber.Text);
  end;
end;

procedure TPopup.FormDestroy(Sender: TObject);
begin
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
  if FPopupLevel in [plMemberItemType, plXGolf, plNewMemberPolicy, plNewMemberProduct, plTeeboxChange, plXGolfEvent, plAdvertItemType, plFacilityProduct] then
  begin
    LeftImage.Visible := True;
    RightImage.Visible := True;
    Image.Width := 1200;
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
  else if FPopupLevel = plParkingDay then
  begin
    FKeyLength := 4;
    FrameRectangle.Width := Authentication1.Width;
    FrameRectangle.Height := Authentication1.Height;
    Authentication1.KeyBoard1.DisPlayKeyBoard;

    Authentication1.Text3.Text := '������ȣ ���';
    Authentication1.Text5.Text := '������ ����� ����';
    Authentication1.Text4.Text := '������ȣ�� ����� �ּ���';

    Authentication1.Visible := True;
  end
  else if FPopupLevel in [plPhone, plPromotionCode, plParkingPrint, plStamp] then
  begin
    FrameRectangle.Width := XGolfMember1.Width;
    FrameRectangle.Height := XGolfMember1.Height;
    XGolfMember1.KeyBoard1.DisPlayKeyBoard;
    XGolfMember1.Visible := True;
    XGolfMember1.txtTime.Text := Format(TimeSecCaption, [LPadB(IntToStr(Time30Sec), 2, ' ')]);
    XGolfMember1.recPolicy.Visible := False;

    if FPopupLevel = plPhone then
    begin
      iSec := 0;
      Timer1.Enabled := True;
      FKeyLength := 9;
      XGolfMember1.PhoneRec.Visible := True;
      XGolfMember1.txtTitle.Text := '�޴��� ��ȣ �Է�';

      if Global.SaleModule.AdvertPopupType = apEvent then
      begin
        //�̺�Ʈ ��3�ڸ������������� ����̸�
        if (Global.SaleModule.AdvertListEvent[0].MarketingAgreeYn = 'Y') then
        begin
          XGolfMember1.recPolicy.Visible := True;

          //���Ǽ� ������ ������ �ڼ������� ��ư �ʺ��̵���
          if (Global.SaleModule.AdvertListEvent[0].FilePath2 = EmptyStr) then
            XGolfMember1.recPolicyView.Visible := False;
        end;
      end;
    end
    else if FPopupLevel = plParkingPrint then
    begin
      iSec := 0;
      Timer1.Enabled := True;
      FKeyLength := 12;
      XGolfMember1.recParkingPrint.Visible := True;
      XGolfMember1.txtTitle.Text := '������ ���';
    end
    else if FPopupLevel = plStamp then
    begin
      iSec := 0;
      Timer1.Enabled := True;
      FKeyLength := 9;
      XGolfMember1.PhoneRec.Visible := True;
      XGolfMember1.txtTitle.Text := '������ ���� ��ȭ��ȣ';
    end
    else
    begin
      FKeyLength := 16;
      XGolfMember1.PromoRec.Visible := True;
      XGolfMember1.txtTitle.Text := '���ڵ� ��ȣ �Է�';
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
      if Global.SaleModule.TeeBoxInfo.TasukNo = 0 then //�ü��̿�� ����
      begin
        frmMemberItemType1.txtTitle.Text := '�̿�� ����';
        frmMemberItemType1.txtUseTime.Text := '';
      end
      else
      begin
        frmMemberItemType1.txtTitle.Text := 'ȸ���� ����';
        if Global.SaleModule.TeeBoxInfo.End_Time <> EmptyStr then
        begin
          ADateTime := DateStrToDateTime(FormatDateTime('yyyymmdd', now) + StringReplace(Global.SaleModule.TeeBoxInfo.End_Time, ':', '', [rfReplaceAll]) + '00');
          ADateTime := IncMinute(ADateTime, StrToIntDef(Global.Config.PrePare_Min, 5));
          frmMemberItemType1.txtUseTime.Text := Format('%s���� �̿��� �����մϴ�.', [FormatDateTime('hh:nn', ADateTime)]);
        end
        else
        begin
          if Global.Config.AD.USE then
          begin
            ADateTime := DateStrToDateTime(FormatDateTime('yyyymmddhhnn', now) + '00');
            ADateTime := IncMinute(ADateTime, StrToIntDef(Global.Config.PrePare_Min, 5));
            frmMemberItemType1.txtUseTime.Text := Format('%s���� �̿��� �����մϴ�.', [FormatDateTime('hh:nn', ADateTime)]);
          end;
        end;
      end;

      //chy test ���ǵ� �����
      {
      if (Global.Config.StoreType = '0') and (Global.Config.FingerprintUse = 'N') then //���ǵ� �����
      begin
        frmMemberItemType1.ItemTypeRectangle.Visible := False;
        frmMemberItemType1.ItemType2.Visible := True;
        frmMemberItemType1.txtUseTime.Margins.Top := 40;
      end
      else   }
      begin
        frmMemberItemType1.ItemTypeRectangle.Visible := True;

        if (Global.Config.StoreType = '1') then
        begin
          if (Global.Config.MobileOAuth = True) then
          begin
            //�����̻��� ��ȣ, QR, ����-����Ʈ
            if (Global.Config.Store.StoreCode = 'C1001') then //�ڸ����������̺꽺����Ŭ��
              frmMemberItemType1.txtPeriodTop.Text := '����'
            else
              frmMemberItemType1.txtPeriodTop.Text := '��ȣ';
          end
          else
            frmMemberItemType1.txtPeriodTop.Text := '����';

          frmMemberItemType1.txtCouponTop.Text := 'QR';
        end;

        if (Global.Config.Store.StoreCode = 'B9001') or (Global.Config.StoreType = '2') then //�Ľ��ڰ���Ŭ��
        begin
          frmMemberItemType1.txtPeriodTop.Text := '����';
          frmMemberItemType1.txtCouponTop.Text := 'QR';

          if (Global.Config.StoreType = '2') then
          begin
            frmMemberItemType1.txtPeriodBottom.Text := '����';
            frmMemberItemType1.txtCouponBottom.Text := '����';
          end;
        end;

        if (Global.Config.AllianceSmartix = True) or (Global.Config.AllianceWellbeing = True) then // ����ƽ��, ��������
        begin
          frmMemberItemType1.imgPeriod.Width := 160;
          frmMemberItemType1.imgCoupon.Width := 160;
          frmMemberItemType1.imgCoupon.Margins.Left := 10;
          frmMemberItemType1.imgDay.Width := 160;
          frmMemberItemType1.imgDay.Margins.Left := 10;

          if (Global.Config.AllianceSmartix = True) then
            frmMemberItemType1.txtAlliance.Text := '�¶���'
          else
            frmMemberItemType1.txtAlliance.Text := '����';
        end
        else
        begin
          frmMemberItemType1.imgAlliance.Visible := False;
        end;

        if (Global.Config.Store.StoreCode = 'BC001') then //��������Ʈ
        begin
          frmMemberItemType1.imgPeriod.Visible := false;
          frmMemberItemType1.imgCoupon.Visible := false;
          frmMemberItemType1.imgDay.Margins.Left := 110;
        end;
      end;

      if Global.SaleModule.TeeBoxInfo.TasukNo = 0 then //�ü��̿�� ����
      begin
        frmMemberItemType1.txtTasukInfo.Text := '';
      end
      else
      begin
        if global.Config.NewMember = True then
        begin
          if (Global.Config.StoreType = '0') and (Global.Config.FingerprintUse = 'N') then
            frmMemberItemType1.NewMemberRectangle.Visible := False
          else
            frmMemberItemType1.NewMemberRectangle.Visible := True;
        end;

        frmMemberItemType1.txtTasukInfo.Text := Global.SaleModule.TeeBoxInfo.FloorNm + ' ' + Global.SaleModule.TeeBoxInfo.Mno + '��';
        if Global.SaleModule.TeeBoxInfo.ZoneCode = 'O' then
          frmMemberItemType1.txtTasukInfo.Text := frmMemberItemType1.txtTasukInfo.Text + ' (��Ÿ)';
      end;

      frmMemberItemType1.Text9.Text := '';
      frmMemberItemType1.CloseRectangle.Visible := True;
      frmMemberItemType1.ImgXGOLF.Visible := False;
      frmMemberItemType1.imgCastlexXgolf.Visible := False; //2021-06-25 ĳ������
    end
    else
    begin
      frmMemberItemType1.txtTitle.Text := Global.SaleModule.TeeBoxInfo.FloorNm + ' ' + Global.SaleModule.TeeBoxInfo.Mno + '��';

      frmMemberItemType1.txtTasukInfo.Text := EmptyStr;
      frmMemberItemType1.QnAXGolfRectangle.Visible := True;

      frmMemberItemType1.txtUseTime.Text := 'XGOLF ȸ�������� �Ͻø�' + #13#10 + '���� ����� ����˴ϴ�.'; //2021-04-29 ����
      frmMemberItemType1.Text9.Text := 'XGOLF ȸ�������� �Ͻðڽ��ϱ�?';
      frmMemberItemType1.txtTime.Position.Y := frmMemberItemType1.txtTime.Position.Y - 40;

      //2021-06-25 ĳ������-xgolf ���� �̹��� ����
      if (Global.Config.Store.StoreCode = 'A6001') then //ĳ������
        frmMemberItemType1.imgCastlexXgolf.Visible := True
      else
        frmMemberItemType1.ImgXGOLF.Visible := True;

      frmMemberItemType1.Text9.TextSettings.Font.Style := [];
      frmMemberItemType1.txtUseTime.TextSettings.Font.Style := [];
    end;

    frmMemberItemType1.Visible := True;
    frmMemberItemType1.iSec := 0;
    frmMemberItemType1.txtTime.Text := Format(TimeSecCaption, [LPadB(IntToStr(Time30Sec), 2, ' ')]);
    frmMemberItemType1.Timer.Enabled := True;
  end
  //chy newmember
  else if FPopupLevel = plNewMemberPolicy then
  begin
    FKeyLength := 0;
    FrameRectangle.Width := NewMember1.Width;
    FrameRectangle.Height := NewMember1.Height;

    if Global.SaleModule.AgreementList1.Count > 0 then
      NewMember1.recPolicy1.Enabled := True;

    if Global.SaleModule.AgreementList2.Count > 0 then
      NewMember1.recPolicy2.Enabled := True;

    if Global.SaleModule.AgreementList3.Count > 0 then
      NewMember1.recPolicy3.Enabled := True;

    NewMember1.Visible := True;
  end
  else if FPopupLevel in [plNewMemberProduct, plTeeboxChange, plFacilityProduct] then
  begin
    FKeyLength := 0;
    FrameRectangle.Width := frmNewMemberItemType1.Width;
    FrameRectangle.Height := frmNewMemberItemType1.Height;
    frmNewMemberItemType1.ItemTypeRectangle.Visible := (FPopupLevel = plNewMemberProduct) or (FPopupLevel = plFacilityProduct);
    frmNewMemberItemType1.MenuTypeRectangle.Visible := (FPopupLevel = plTeeboxChange);

    if FPopupLevel = plNewMemberProduct then
    begin
      frmNewMemberItemType1.txtTitle.Text := 'ȸ������ �Ϸ�';
      frmNewMemberItemType1.txtTasukInfo.Visible := True;
    end;

    if FPopupLevel = plTeeboxChange then
    begin
      frmNewMemberItemType1.txtTitle.Text := 'Ÿ���̵�, ����ð� �߰�';
      frmNewMemberItemType1.txtTasukInfo.Visible := False;
    end;

    if FPopupLevel = plFacilityProduct then
    begin
      frmNewMemberItemType1.txtTitle.Text := '�ü� ����� ����';
      frmNewMemberItemType1.txtTasukInfo.Visible := False;
      frmNewMemberItemType1.txtItemTypePeriod.Text := 'ȸ��';
      frmNewMemberItemType1.txtItemTypeCoupon.Text := '��������';

      if global.Config.NewMember = True then
        frmNewMemberItemType1.NewMemberRectangle.Visible := True;
    end;

    frmNewMemberItemType1.Visible := True;
    frmNewMemberItemType1.iSec := 0;
    frmNewMemberItemType1.txtTime.Text := Format(TimeSecCaption, [LPadB(IntToStr(Time30Sec), 2, ' ')]);
    frmNewMemberItemType1.Timer.Enabled := True;
  end
  else if FPopupLevel = plAdvertItemType then
  begin
    FKeyLength := 0;
    FrameRectangle.Width := frmAdvertItemType1.Width;
    FrameRectangle.Height := frmAdvertItemType1.Height;
    frmAdvertItemType1.Visible := True;
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

procedure TPopup.NewMemberPolicy;
begin
  if Global.SaleModule.PaymentAddType = patFacilityNew then
  begin
    frmNewMemberItemType1.Visible := False;
    frmNewMemberItemType1.iSec := 0;
    frmNewMemberItemType1.Timer.Enabled := False;
  end
  else
  begin
    frmMemberItemType1.Visible := False;
    frmMemberItemType1.iSec := 0;
    frmMemberItemType1.Timer.Enabled := False;
  end;

  Global.SaleModule.PopUpLevel := plNewMemberPolicy;
  FormShow(Self);
end;
{
procedure TPopup.FacilityProductAuth;
begin
  frmNewMemberItemType1.Visible := False;
  frmNewMemberItemType1.iSec := 0;
  frmNewMemberItemType1.Timer.Enabled := False;

  Global.SaleModule.PopUpLevel := plPhone;
  FormShow(Self);
end;
}
procedure TPopup.Timer1Timer(Sender: TObject);
begin
  if FPopupLevel in [plPhone, plParkingPrint, plStamp] then
  begin
    Inc(iSec);
    XGolfMember1.txtTime.Text := Format(TimeSecCaption, [LPadB(IntToStr(Time30Sec - iSec), 2, ' ')]);
    if (Time30Sec - iSec) = 0 then
    begin
      Timer1.Enabled := False;
      XGolfMember1.recCloseClick(nil);
    end;
  end;
end;

end.
