unit Frame.Member.ItemType;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Objects;

type
  TfrmMemberItemType = class(TFrame)
    Layout: TLayout;
    Rectangle: TRectangle;
    txtTitle: TText;
    txtTasukInfo: TText;
    ItemTypeRectangle: TRectangle;
    imgPeriod: TImage;
    imgCoupon: TImage;
    imgDay: TImage;
    CloseRectangle: TRectangle;
    txtTime: TText;
    txtClose: TText;
    Timer: TTimer;
    QnAXGolfRectangle: TRectangle;
    Rectangle1: TRectangle;
    Rectangle2: TRectangle;
    txtPeriodTop: TText;
    txtPeriodBottom: TText;
    txtCouponTop: TText;
    txtCouponBottom: TText;
    Text7: TText;
    Text8: TText;
    txtUseTime: TText;
    Image5: TImage;
    Image6: TImage;
    Text3: TText;
    Text4: TText;
    Text9: TText;
    Image4: TImage;
    ImgXGOLF: TImage;
    NewMemberRectangle: TRectangle;
    imgNewMember: TImage;
    Text10: TText;
    imgCastlexXgolf: TImage;
    imgAlliance: TImage;
    txtAlliance: TText;
    Text12: TText;
    ItemType2: TRectangle;
    Image2: TImage;
    Text5: TText;
    Text6: TText;
    Image3: TImage;
    Text13: TText;
    Text14: TText;
    procedure CloseRectangleClick(Sender: TObject);
    procedure imgPeriodClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure Rectangle1Click(Sender: TObject);
    procedure RectangleClick(Sender: TObject);
    procedure imgNewMemberClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    nCnt: Integer;
    iSec: Integer;
  end;

implementation

uses
  Form.Popup, uConsts, uGlobal, uFunction, uCommon;

{$R *.fmx}

procedure TfrmMemberItemType.CloseRectangleClick(Sender: TObject);
begin
  TouchSound;
  Timer.Enabled := False;
  Popup.CloseFormStrMrCancel;
end;

procedure TfrmMemberItemType.imgPeriodClick(Sender: TObject);
begin
  TouchSound;
  Timer.Enabled := False;

  if (Global.Config.Store.StoreCode <> 'C7001') then //유나우 골프스튜디오
  begin
    if Global.SaleModule.VipTeeBox then
    begin
      if TImage(Sender).Tag <> 3 then
      begin
        if (Global.Config.StoreType = '2') then
          Global.SBMessage.ShowMessageModalForm(MSG_TEAM_ONLY_DAY_PRODUCT)
        else
          Global.SBMessage.ShowMessageModalForm(MSG_VIP_ONLY_DAY_PRODUCT);
        Timer.Enabled := True;
        Exit;
      end;
    end;
  end;

  Global.SaleModule.memberItemType := TMemberItemType(Ord(TImage(Sender).Tag));
  Popup.CloseFormStrMrok('');
end;

procedure TfrmMemberItemType.imgNewMemberClick(Sender: TObject);
begin
  TouchSound;
  Timer.Enabled := False;
  Global.SaleModule.memberItemType := mitNew;
  Popup.NewMemberPolicy;
end;

procedure TfrmMemberItemType.Rectangle1Click(Sender: TObject);
begin
  TouchSound;
  Timer.Enabled := False;
  Popup.CloseFormStrMrok('');
end;

procedure TfrmMemberItemType.RectangleClick(Sender: TObject);
begin
  TouchSound;
end;

procedure TfrmMemberItemType.TimerTimer(Sender: TObject);
begin
  // 2021-11-05 500 로 변경
  if txtPeriodTop.TextSettings.FontColor = $FF333333 then
  begin
    txtPeriodTop.TextSettings.FontColor := $FFBDBDBD;
    txtCouponTop.TextSettings.FontColor := $FFBDBDBD;
    text7.TextSettings.FontColor := $FFBDBDBD;
    txtAlliance.TextSettings.FontColor := $FFBDBDBD;
  end
  else
  begin
    txtPeriodTop.TextSettings.FontColor := $FF333333;
    txtCouponTop.TextSettings.FontColor := $FF333333;
    text7.TextSettings.FontColor := $FF333333;
    txtAlliance.TextSettings.FontColor := $FF333333;
  end;

  Inc(nCnt);
  if nCnt > 1 then
  begin
    nCnt := 0;

    Inc(iSec);
    txtTime.Text := Format(TimeSecCaption, [LPadB(IntToStr(Time30Sec - iSec), 2, ' ')]);
    if (Time30Sec - iSec) = 0 then
      CloseRectangleClick(nil);
  end;
end;

end.
