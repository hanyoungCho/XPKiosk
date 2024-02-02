unit Frame.Member.Sale.Product.Item420.Style;

interface

// 좌측정렬 114, 6

uses
  uStruct, FMX.Ani,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Layouts;

type
  TMemberSaleProductItem420Style = class(TFrame)
    Layout: TLayout;
    ImgDay: TImage;
    AniImage: TImage;
    txtVIP: TText;
    ImgPeriod: TImage;
    ImgCoupon: TImage;
    txtProductName: TText;
    txtProductTypeName: TText;
    txtProductPrice: TText;
    txtProductTemp: TText;
    txtXGOLFDiscount: TText;
    Line1: TLine;
    SelectRectangle: TRectangle;
    Image1: TImage;
    XGOLFLINERectangle: TRectangle;
    procedure RectangleClick(Sender: TObject);
  private
    { Private declarations }
    FProduct: TProductInfo;
  public
    { Public declarations }
    procedure Bind(AProduct: TProductInfo);

    property Product: TProductInfo read FProduct write FProduct;
  end;

implementation

uses
  uGlobal, Frame.Member.Sale.Product.List.Style, uFunction, uCommon, uConsts; //Form.Sale.Product,

{$R *.fmx}

{ TMemberSaleProductItem420Style }

procedure TMemberSaleProductItem420Style.Bind(AProduct: TProductInfo);
var
  a: Integer;
begin
  Product := AProduct;

  if Product.Product_Div = PRODUCT_TYPE_D then
  begin
    txtProductTypeName.Text := Format('%s', ['일일타석권']);
    txtProductPrice.TextSettings.FontColor := $FF234B9C;
    if Global.SaleModule.VipTeeBox then
      txtProductTemp.Text := Format('%s', ['VIP'])
    else
    begin
//      txtProductTemp.Text := Format('%s', [Copy(Product.Name, 1, 2)]);
      txtProductTemp.Text := Format('%s분', [Product.One_Use_Time]);
    end;
  end
  else if Product.Product_Div = PRODUCT_TYPE_C then
  begin
    txtProductTypeName.Text := Format('%s', ['쿠폰 회원권']);
    txtProductPrice.TextSettings.FontColor := $FFC53915;
    txtProductTemp.Text := Format('%d회', [Product.Use_Qty]);
  end
  else
  begin
    txtProductTypeName.Text := Format('%s', ['기간제 회원권']);
    txtProductPrice.TextSettings.FontColor := $FF2AA430;
    txtProductTemp.Text := Format('%s개월', [Product.UseMonth]);
  end;

  txtProductName.Text := Product.Name;

  txtProductPrice.Text := Format('%s', [FormatFloat('#,##0.##', Product.Price)]);
  txtProductPrice.Position.Y := 11;
  txtProductPrice.TextSettings.Font.Size := txtProductPrice.TextSettings.Font.Size + 8;

  if Product.Product_Div = PRODUCT_TYPE_C then
    ImgCoupon.Visible := True
  else if Product.Product_Div = PRODUCT_TYPE_D then
  begin
    ImgDay.Visible := True;
  end
  else
    ImgPeriod.Visible := True;
end;

procedure TMemberSaleProductItem420Style.RectangleClick(Sender: TObject);
var
  nMin: Integer;
begin
  TouchSound;

  if Global.Config.AD.USE = True then
  begin
    if StoreCloseTmCheck(FProduct) = True then
    begin
      Exit;
    end;
  end;

  SaleProduct.Animate(Self.Tag);
  SaleProduct.AddProduct(Product);
end;

end.
