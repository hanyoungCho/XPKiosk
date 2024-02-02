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
    Text1: TText;
    Text2: TText;
    Text5: TText;
    Text6: TText;
    Text7: TText;
    Text8: TText;
    txtUseTime: TText;
    Image5: TImage;
    Image6: TImage;
    Text3: TText;
    Text4: TText;
    Text9: TText;
    Image4: TImage;
    Text10: TText;
    procedure CloseRectangleClick(Sender: TObject);
    procedure imgPeriodClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure Rectangle1Click(Sender: TObject);
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

procedure TfrmMemberItemType.imgPeriodClick(Sender: TObject);
begin
  TouchSound;
  Timer.Enabled := False;
  
  Global.SaleModule.memberItemType := TMemberItemType(Ord(TImage(Sender).Tag));
  Popup.CloseFormStrMrok('');
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
  Inc(iSec);
  txtTime.Text := Format(TimeSecCaption, [LPadB(IntToStr(Time30Sec - iSec), 2, ' ')]);
  if (Time30Sec - iSec) = 0 then
    CloseRectangleClick(nil);
end;

end.
