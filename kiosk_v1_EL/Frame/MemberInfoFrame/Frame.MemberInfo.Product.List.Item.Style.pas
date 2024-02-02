unit Frame.MemberInfo.Product.List.Item.Style;

interface

uses
  uStruct,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects;

type
  TMemberInfoProductItemStyle = class(TFrame)
    Rectangle1: TRectangle;
    Rectangle2: TRectangle;
    Rectangle3: TRectangle;
    txtProductName: TText;
    Text2: TText;
    txtExpireDay: TText;
  private
    { Private declarations }
    FProductInfo: TProductInfo;
  public
    { Public declarations }
    procedure Display(AProductInfo: TProductInfo);

    property ProductInfo: TProductInfo read FProductInfo write FProductInfo;
  end;

implementation

uses
  uCommon, uConsts, uGlobal;

{$R *.fmx}

{ TSaleOrderItemStyle }

procedure TMemberInfoProductItemStyle.Display(AProductInfo: TProductInfo);
begin
  ProductInfo := AProductInfo;

  txtProductName.Text := ProductInfo.Name;
  txtProductName.TextSettings.Font.Style := [];
  txtProductName.TextSettings.Font.Size := 28;
  txtProductName.HorzTextAlign := TTextAlign.Leading;
  txtProductName.Margins.Left := 10;

  if ProductInfo.Use_Qty > 0 then
    text2.Text := IntToStr(ProductInfo.Use_Qty)
  else
    text2.Text := '-';

  txtExpireDay.Text := ProductInfo.Expire_Day;
  txtExpireDay.TextSettings.Font.Style := [];
  txtExpireDay.TextSettings.Font.Size := 28;
  txtExpireDay.TextSettings.Font.Family := 'Roboto';
  txtExpireDay.HorzTextAlign := TTextAlign.Leading;
  txtExpireDay.Margins.Right := 50;
  txtExpireDay.TextSettings.HorzAlign := TTextAlign.Trailing;
  txtExpireDay.Margins.Right := 65;

end;

end.
