unit Frame.FullPopup.CouponItem;

interface  // 417 200         350  170

uses
  uStruct,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Layouts;

type
  TFullPopupCouponItem = class(TFrame)
    Layout: TLayout;
    ImgRectangle: TRectangle;
    ImgCoupon: TImage;
    ImgNotUse: TImage;
    ImgDay: TImage;
    ImgPeriod: TImage;
    TextRectangle: TRectangle;
    txtName: TText;
    txtUse: TText;
    txtYYYYMMDD: TText;
    SelectRectangle: TRectangle;
    Image1: TImage;
    txtProductTemp: TText;
    Rectangle1: TRectangle;
    imgSelectRectangle: TImage;
    Timer: TTimer;
    procedure SelectRectangleClick(Sender: TObject);
    procedure RectangleClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
  private
    { Private declarations }
    FProduct: TProductInfo;
  public
    { Public declarations }
    procedure DisPlayInfo(AProduct: TProductInfo);
    property Product: TProductInfo read FProduct write FProduct;
  end;

implementation

uses
  uGlobal, Form.Full.Popup, uFunction, uCommon, uConsts;

{$R *.fmx}

{ TFullPopupCouponItem }

procedure TFullPopupCouponItem.DisPlayInfo(AProduct: TProductInfo);
var
  ATitle: Boolean;
begin
  FProduct := AProduct;
  ATitle := Trim(AProduct.Code) = EmptyStr;

  //2021-05-13 ȸ���� �����ð�
  {f FProduct.Product_Div = PRODUCT_TYPE_C then
    txtUse.Text := format('(�ܿ� �� : %dȸ)', [FProduct.Use_Qty])
  else
    txtUse.Text := format('(��� %s����)', [IfThen(Product.Use, '', '��')]);
  }
  txtUse.Text := format('�����ð� : %s��', [Product.One_Use_Time]);

  txtYYYYMMDD.Text := format('%s.%s.%s����', [Copy(Product.EndDate, 1, 4),
                                              Copy(Product.EndDate, 5, 2),
                                              Copy(Product.EndDate, 7, 2)]);

  if FProduct.Product_Div = PRODUCT_TYPE_D then
  begin
    txtName.Text := Format('%s', ['����Ÿ����']);
    txtName.TextSettings.FontColor := $FF234B9C;
    txtProductTemp.Text := Format('%s��', [FProduct.One_Use_Time]);
  end
  else if FProduct.Product_Div = PRODUCT_TYPE_C then
  begin
    txtName.Text := Format('%s', ['���� ȸ����']);
    txtName.TextSettings.FontColor := $FFC53915;
    txtProductTemp.Text := Format('%dȸ', [FProduct.Use_Qty]);
  end
  else
  begin
    txtName.Text := Format('%s', ['�Ⱓ�� ȸ����']);
    txtName.TextSettings.FontColor := $FF2AA430;
    txtProductTemp.Text := Format('%s��', [FProduct.One_Use_Time]);
  end;

  if not Product.Use then
    ImgNotUse.Visible := True
  else if Product.Product_Div = PRODUCT_TYPE_D then
    ImgDay.Visible := True
  else if Product.Product_Div = PRODUCT_TYPE_C then
    ImgCoupon.Visible := True
  else
    ImgPeriod.Visible := True;

  //2021-10-12 ���ñ�����
  Timer.Enabled := True;
end;

procedure TFullPopupCouponItem.RectangleClick(Sender: TObject);
var
  AProductInfo: TProductInfo;
  sCode, sMsg: String;
begin
  if FProduct.Name = EmptyStr then
    Exit;

  if global.Config.ProductTime = False then //�����ð� ����
  begin
    AProductInfo := Global.Database.GetTeeBoxProductTime(FProduct.Code, sCode, sMsg);

    if sCode <> '0000' then
    begin
      Global.SBMessage.ShowMessageModalForm(sMsg);
      Exit;
    end;

    FProduct.One_Use_Time := AProductInfo.One_Use_Time;
  end;

  TouchSound(False, True);

  if FProduct.Use then
  begin
    //chy 2020-11-04 ������ǰ�� 1���ΰ�� �޼��� ��¾���
    if Global.SaleModule.ProductList.Count = 1 then
    begin
      if Global.Config.AD.USE = True then
      begin
        if StoreCloseTmCheck(FProduct) = True then //True: �ʰ���
        begin
          Exit;
        end;
      end;

      Global.SaleModule.SelectProduct := FProduct;
      FullPopup.CloseFormStrMrok('');
    end
    else
    begin
      if Global.SBMessage.ShowMessageModalForm(FProduct.Name + '���� ���� �����ðڽ��ϱ�?', False) then
      begin
        if Global.Config.AD.USE = True then
        begin
          if StoreCloseTmCheck(FProduct) = True then
          begin
            Exit;
          end;
        end;

        Global.SaleModule.SelectProduct := FProduct;
        FullPopup.CloseFormStrMrok('');
      end;
    end;
  end
  else
    Global.SBMessage.ShowMessageModalForm('�̹� ����ϰų� ��� �� �� ���� ��ǰ�Դϴ�.');
end;

procedure TFullPopupCouponItem.SelectRectangleClick(Sender: TObject);
begin
  TouchSound;
  if FProduct.Name = EmptyStr then
    Exit;

  if FProduct.Use then
  begin
    if Global.SBMessage.ShowMessageModalForm(FProduct.Name + '���� ���� �����ðڽ��ϱ�?', False) then
    begin
      Global.SaleModule.SelectProduct := FProduct;
      FullPopup.CloseFormStrMrok('');
    end;
  end
  else
    Global.SBMessage.ShowMessageModalForm('�̹� ����ϰų� ��� �� �� ���� ��ǰ�Դϴ�.');
end;

procedure TFullPopupCouponItem.TimerTimer(Sender: TObject);
begin
  if imgSelectRectangle.Visible = True then
    imgSelectRectangle.Visible := False
  else
    imgSelectRectangle.Visible := True;
end;

end.
