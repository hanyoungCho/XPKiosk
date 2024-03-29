unit Frame.FullPopupQR;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Layouts;

type
  TFullPopupQR = class(TFrame)
    Layout: TLayout;
    recTop: TRectangle;
    txtTasukInfo: TText;
    Text4: TText;
    Image1: TImage;
    Rectangle2: TRectangle;
    Text2: TText;
    Image2: TImage;
    Image3: TImage;
    Text1: TText;
    Text3: TText;
    Text5: TText;
    Text6: TText;
    recBody: TRectangle;
    procedure Rectangle2Click(Sender: TObject);
    procedure Image1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses
  uGlobal, uSaleModule, uConsts, uCommon, Form.Full.Popup;

{$R *.fmx}

procedure TFullPopupQR.Image1Click(Sender: TObject);
begin
  TouchSound;
end;

procedure TFullPopupQR.Rectangle2Click(Sender: TObject);
begin
  Global.SaleModule.PopUpLevel := plPhone;
  if ShowPopup('Rectangle2Click/plPhone') then
    FullPopup.CloseFormStrMrok('')
  else
    FullPopup.CloseFormStrMrCancel;
end;

end.
