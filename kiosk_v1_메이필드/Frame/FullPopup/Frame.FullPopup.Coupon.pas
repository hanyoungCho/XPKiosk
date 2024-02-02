unit Frame.FullPopup.Coupon;

interface

uses
  uStruct, Generics.Collections,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Layouts, Frame.FullPopup.CouponItem;

type
  TFullPopupCoupon = class(TFrame)
    Layout: TLayout;
    Rectangle1: TRectangle;
    txtTasukInfo: TText;
    Text4: TText;
    Rectangle2: TRectangle;
    Text1: TText;
    Text2: TText;
    BiominiRectangle: TRectangle;
    Image: TImage;
    ItemLayout: TLayout;
    Rectangle: TRectangle;
    ItemRectangle: TRectangle;
    ImgDown: TImage;
    ImgUp: TImage;
    ImageWellbeing: TImage;
    ImageTeeboxMove: TImage;
    ImageBCPaybook: TImage;
    procedure RectangleClick(Sender: TObject);
    procedure BiominiRectangleClick(Sender: TObject);
    procedure ImgDownClick(Sender: TObject);
    procedure ImgUpClick(Sender: TObject);
  private
    { Private declarations }
    FProductList: TList<TProductInfo>;
    FActivePage: Integer;
  public
    { Public declarations }
    procedure Display;
    procedure CloseFrame;

    property ProductList: TList<TProductInfo> read FProductList write FProductList;
    property ActivePage: Integer read FActivePage write FActivePage;
  end;

implementation

uses
  uGlobal, uFunction, uConsts, uCommon, Form.Full.Popup;

{$R *.fmx}

procedure TFullPopupCoupon.BiominiRectangleClick(Sender: TObject);
begin
  TouchSound;
end;

procedure TFullPopupCoupon.CloseFrame;
var
  Index: Integer;
begin
  if ProductList <> nil then
  begin
    for Index := ProductList.Count - 1 downto 0 do
      ProductList.Delete(Index);

    ProductList.Free;
  end;
end;

procedure TFullPopupCoupon.Display;
var
  Index, Loop, RowIndex, ColIndex, ItemCnt: Integer;
  AProductInfo: TProductInfo;
  AFullPopupCouponItem: TFullPopupCouponItem;
begin
  try

    RowIndex := 0;
    ColIndex := 0;
    ItemCnt := 0;

    ImgUp.Visible := False;//Global.SaleModule.ProductList.Count > 4;
    ImgDown.Visible := False;//Global.SaleModule.ProductList.Count > 4;

    if ((ActivePage - 1) * 4) > Global.SaleModule.ProductList.Count then
      Exit;

    if ActivePage <> 0 then
      Loop := (ActivePage - 1) * 4
    else
      Loop := 0;

    for Index := ItemRectangle.ChildrenCount - 1 downto 0 do
      ItemRectangle.Children[Index].Free;

    ItemRectangle.DeleteChildren;
    ItemRectangle.Height := 0;

    for Index := Loop to Global.SaleModule.ProductList.Count - 1 do
    begin
      if ItemCnt >= 4 then
        Continue;

      AProductInfo := Global.SaleModule.ProductList[Index];
      if not AProductInfo.Use then
        Continue;
      {
      //chy 2021-04-28 ÄíÆùÈ¸¿ø vip È®ÀÎ ¿ä¸Á
      if Global.SaleModule.VipTeeBox and (AProductInfo.ZoneCode <> 'V') then
        Continue;
      }
      {$IFDEF RELEASE}
      if Global.SaleModule.CouponMember and Global.Config.CouponMember then
      begin
        if AProductInfo.Product_Div <> PRODUCT_TYPE_C then
          Continue;
      end;
      {$ENDIF}

      if ColIndex = 2 then
      begin
        ColIndex := 0;
        Inc(RowIndex);
      end;

      AFullPopupCouponItem := TFullPopupCouponItem.Create(nil);

      if Global.SaleModule.ProductList.Count = 1 then
      begin
        AFullPopupCouponItem.Position.X := 210;
        AFullPopupCouponItem.Position.Y := 100;
      end
      else
      begin
        AFullPopupCouponItem.Position.X := (ColIndex * AFullPopupCouponItem.Width) + (ColIndex * 20);
        AFullPopupCouponItem.Position.Y := (RowIndex * AFullPopupCouponItem.Height) + (RowIndex * 20);
      end;

      ItemRectangle.Height := ItemRectangle.Height + AFullPopupCouponItem.Height;
      AFullPopupCouponItem.DisPlayInfo(AProductInfo);

      AFullPopupCouponItem.Parent := ItemRectangle;
      ItemRectangle.Height := ItemRectangle.Height + AFullPopupCouponItem.Height;
      Inc(ColIndex);
      Inc(ItemCnt);
    end;

  finally
  end;

  if ItemCnt = 0 then
  begin
    if ActivePage <> 1 then
    begin
      Dec(FActivePage);
    end
    else
    begin
      {
      if Global.SBMessage.ShowMessageModalForm(MSG_MEMBER_USE_NOT_PRODUCT + #13#10 + MSG_IS_PRODUCT_BUY , False) then
        FullPopup.CloseFormStrMrok('SALE')
      else
      }
        FullPopup.CloseFormStrMrCancel;
    end;
  end;
end;

procedure TFullPopupCoupon.ImgDownClick(Sender: TObject);
begin
  FullPopup.ResetTimerCnt;
  TouchSound;
  if (ActivePage * 4) <= Global.SaleModule.ProductList.Count then
  begin
    Inc(FActivePage);
    Display;
  end;
end;

procedure TFullPopupCoupon.ImgUpClick(Sender: TObject);
begin
  FullPopup.ResetTimerCnt;
  TouchSound;
  if not ((ActivePage - 1) < 1) then
  begin
    Dec(FActivePage);
    Display;
  end;
end;

procedure TFullPopupCoupon.RectangleClick(Sender: TObject);
begin
//  Rectangle.DeleteChildren;
  TouchSound;
end;

end.
