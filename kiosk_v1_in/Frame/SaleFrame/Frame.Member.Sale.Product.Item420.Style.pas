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
    imgSelectRectangle: TImage;
    Timer: TTimer;
    procedure RectangleClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
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
  uGlobal, Form.Sale.Product, Frame.Member.Sale.Product.List.Style, uFunction, uCommon, uConsts;

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
  txtProductName.Text := StringReplace(txtProductName.Text, '쿠폰회원/', '', [rfReplaceAll]);
  txtProductName.Text := StringReplace(txtProductName.Text, '일일입장/', '', [rfReplaceAll]);
  txtProductName.Text := StringReplace(txtProductName.Text, '정회원(엑스골프)/', '', [rfReplaceAll]);
  txtProductName.Text := StringReplace(txtProductName.Text, '정회원(엑스골프)', '', [rfReplaceAll]);

  if Global.SaleModule.Member.XGolfMember and Product.xgolf_dc_yn then
  begin
    txtXGOLFDiscount.Visible := True;
    txtXGOLFDiscount.Text := FormatFloat('#,##0.##', Product.Price);
    txtXGOLFDiscount.Width := (Length(txtXGOLFDiscount.Text) * 11);
    XGOLFLINERectangle.Width := txtXGOLFDiscount.Width;

    txtProductPrice.Text := FormatFloat('#,##0.##', Product.xgolf_product_amt);
  end
  else
  begin
//    txtProductPrice.Position.Create(TPointF.Create(txtProductPrice.Position.X, txtProductPrice.Position.Y + 2));
//    txtProductPrice.TextSettings.Font.Size := txtProductPrice.TextSettings.Font.Size + 2;
//    txtXGolf.Visible := False;
//    txtProductXGOLFPrice.Visible := False;
    txtProductPrice.Text := Format('%s', [FormatFloat('#,##0.##', Product.Price)]);
    txtProductPrice.Position.Y := 11;
    txtProductPrice.TextSettings.Font.Size := txtProductPrice.TextSettings.Font.Size + 8;
  end;
//  txtProductPrice.Text := Format('(%s)', [FormatFloat('#,##0.##', Product.Price)]);

  if Product.Product_Div = PRODUCT_TYPE_C then
    ImgCoupon.Visible := True
  else if Product.Product_Div = PRODUCT_TYPE_D then
    ImgDay.Visible := True
  else
    ImgPeriod.Visible := True;

  //2021-10-12 선택깜빡임
  Timer.Enabled := True;
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

procedure TMemberSaleProductItem420Style.TimerTimer(Sender: TObject);
begin
  if imgSelectRectangle.Visible = True then
    imgSelectRectangle.Visible := False
  else
    imgSelectRectangle.Visible := True;
end;

end.
