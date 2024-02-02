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
    imgFinger: TImage;
    imgQR: TImage;
    CloseRectangle: TRectangle;
    txtTime: TText;
    txtClose: TText;
    Timer: TTimer;
    Text1: TText;
    Text2: TText;
    Text5: TText;
    Text6: TText;
    txtUseTime: TText;
    Text9: TText;
    Image4: TImage;
    procedure CloseRectangleClick(Sender: TObject);
    procedure imgFingerClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure RectangleClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
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

procedure TfrmMemberItemType.imgFingerClick(Sender: TObject);
begin
  TouchSound;
  Timer.Enabled := False;
  if Global.SaleModule.VipTeeBox then
  begin
    if TImage(Sender).Tag <> 3 then
    begin
      Global.SBMessage.ShowMessageModalForm(MSG_VIP_ONLY_DAY_PRODUCT);
      Timer.Enabled := True;
      Exit;
    end;
  end;
  Global.SaleModule.memberItemType := TMemberItemType(Ord(TImage(Sender).Tag));
  Popup.CloseFormStrMrok('');
end;

procedure TfrmMemberItemType.RectangleClick(Sender: TObject);
begin
  TouchSound;
end;

procedure TfrmMemberItemType.TimerTimer(Sender: TObject);
begin
  Inc(iSec);
  txtTime.Text := Format(TimeSecCaption, [LPadB(IntToStr(Time30Sec - iSec), 2, ' ')]);
  if (Time30Sec - iSec) = 0 then
    CloseRectangleClick(nil);
end;

end.
