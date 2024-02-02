unit Frame.Member.Sale.Product.Item420.Style;

interface

// �������� 114, 6

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
  x, y: string;
begin
  Product := AProduct;

  if Product.Product_Div = PRODUCT_TYPE_D then
  begin
    if (Global.SaleModule.PaymentAddType = patFacilityDay) then
      txtProductTypeName.Text := Format('%s', ['�����̿��'])
    else
      txtProductTypeName.Text := Format('%s', ['����Ÿ����']);
    txtProductPrice.TextSettings.FontColor := $FF234B9C;
    if Global.SaleModule.VipTeeBox then
      txtProductTemp.Text := Format('%s', ['VIP'])
    else
    begin
      //if (Global.Config.Store.StoreCode = 'C1001') and (Product.Name = '���Ӻ�') then
      if (Global.SaleModule.PaymentAddType <> patNone) then
        txtProductTemp.Text := ''
      else
        txtProductTemp.Text := Format('%s��', [Product.One_Use_Time]);
    end;
  end
  else if Product.Product_Div = PRODUCT_TYPE_C then
  begin
    txtProductTypeName.Text := Format('%s', ['���� ȸ����']);
    txtProductPrice.TextSettings.FontColor := $FFC53915;
    txtProductTemp.Text := Format('%dȸ', [Product.UseCnt]);
  end
  else
  begin
    if Global.SaleModule.PaymentAddType = patGeneral then //�Ϲݻ�ǰ
    begin
      txtProductTypeName.Text := '�Ϲݻ�ǰ';
      txtProductPrice.TextSettings.FontColor := $FF2AA430;
      txtProductTemp.Text := '';
    end
    else
    begin
      txtProductTypeName.Text := Format('%s', ['�Ⱓ�� ȸ����']);
      txtProductPrice.TextSettings.FontColor := $FF2AA430;
      txtProductTemp.Text := Format('%s����', [Product.UseMonth]);
    end;
  end;

  txtProductName.Text := Product.Name;
  txtProductName.Text := StringReplace(txtProductName.Text, '����ȸ��/', '', [rfReplaceAll]);
  txtProductName.Text := StringReplace(txtProductName.Text, '��������/', '', [rfReplaceAll]);
  txtProductName.Text := StringReplace(txtProductName.Text, '��ȸ��(��������)/', '', [rfReplaceAll]);
  txtProductName.Text := StringReplace(txtProductName.Text, '��ȸ��(��������)', '', [rfReplaceAll]);


  if Global.SaleModule.Member.XGolfMember and Product.xgolf_dc_yn then
  begin
    //Global.SBMessage.ShowMessageModalForm('����');
    txtXGOLFDiscount.Visible := True;
    txtXGOLFDiscount.Text := FormatFloat('#,##0.##', Product.Price);
    txtXGOLFDiscount.Width := (Length(txtXGOLFDiscount.Text) * 11);
    XGOLFLINERectangle.Width := txtXGOLFDiscount.Width;

    txtProductPrice.Text := FormatFloat('#,##0.##', Product.xgolf_product_amt);
  end
  else
  begin
    {
    x:= 'aa';
    y:='bb';
    if Global.SaleModule.Member.XGolfMember then
      x := 'XGolfMember';

    if Product.xgolf_dc_yn then
     y := 'xgolf_dc_yn';
    }

    //Global.SBMessage.ShowMessageModalForm('����' + x + ' / ' + y);
    txtProductPrice.Text := Format('%s', [FormatFloat('#,##0.##', Product.Price)]);
    txtProductPrice.Position.Y := 11;
    txtProductPrice.TextSettings.Font.Size := txtProductPrice.TextSettings.Font.Size + 8;
  end;

  if Product.Product_Div = PRODUCT_TYPE_C then
    ImgCoupon.Visible := True
  else if Product.Product_Div = PRODUCT_TYPE_D then
    ImgDay.Visible := True
  else
    ImgPeriod.Visible := True;

  //2021-10-12 ���ñ�����
  Timer.Enabled := True;
end;

procedure TMemberSaleProductItem420Style.RectangleClick(Sender: TObject);
var
  nMin: Integer;
  AProductInfo: TProductInfo;
  sCode, sMsg: String;
begin

  if (Global.Config.StoreType = '0') or (Global.Config.StoreType = '1') then
  begin
    if Global.SaleModule.TeeBoxInfo.TasukNo <> 0 then //Ÿ����ȣ 0�ΰ��-'C1001' �ڸ����������̺꽺����Ŭ�� ���Ӻ�, �ű�ȸ�������� ȸ����(�Ⱓ��,����) ���Ž�
    begin
      AProductInfo := Global.Database.GetTeeBoxProductTime(FProduct.Code, sCode, sMsg);

      if sCode <> '0000' then
      begin
        Global.SBMessage.ShowMessageModalForm(sMsg);
        Exit;
      end;

      FProduct.Limit_Product_Yn := AProductInfo.Limit_Product_Yn;
      FProduct.One_Use_Time := AProductInfo.One_Use_Time;
    end;
  end;

  TouchSound;
  
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
