unit Frame.AppCardListI.Item;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Layouts, FMX.Effects, System.ImageList, FMX.ImgList;

type
  TFullPopupAppCardListItem = class(TFrame)
    Layout: TLayout;
    Rectangle: TRectangle;
    BlurEffect1: TBlurEffect;
    Image1: TImage;
    Text1: TText;
    ImageList: TImageList;
    procedure RectangleClick(Sender: TObject);
  private
    { Private declarations }
    FItemIndex: Integer;
    IsClick: Boolean;
  public
    { Public declarations }
    procedure Display(AItemIndex: Integer; AText: string);
  end;

implementation

uses
  Form.Full.Popup;

{$R *.fmx}

{ TFullPopupAppCardListItem }

procedure TFullPopupAppCardListItem.Display(AItemIndex: Integer; AText: string);
var
  s: TSizeF;
begin
  FItemIndex := AItemIndex;
  s.Create(180, 180);
//  Image1.Bitmap := ImageList.Bitmap(s, AItemIndex);
//  Image1.Bitmap. := TBitMap(ImageList.Source.Items[AItemIndex]);
  Image1.MultiResBitmap.Bitmaps[1] := ImageList.Source[FItemIndex].MultiResBitmap.Bitmaps[1];

//  Image1.Bitmap.Assign(ImageList.Source.Items[AItemIndex].MultiResBitmap.Owner);
  Text1.Text := AText;
  IsClick := False;
end;

procedure TFullPopupAppCardListItem.RectangleClick(Sender: TObject);
begin
  if not IsClick then
  begin
    IsClick := True;
    FullPopup.ApplyAppCard(FItemIndex, Text1.Text);
  end;
end;

end.
