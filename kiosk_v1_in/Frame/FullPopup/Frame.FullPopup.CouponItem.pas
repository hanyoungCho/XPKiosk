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

  //2021-05-13 회원권 배정시간
  {f FProduct.Product_Div = PRODUCT_TYPE_C then
    txtUse.Text := format('(잔여 수 : %d회)', [FProduct.Use_Qty])
  else
    txtUse.Text := format('(사용 %s가능)', [IfThen(Product.Use, '', '불')]);
  }
  txtUse.Text := format('배정시간 : %s분', [Product.One_Use_Time]);

  txtYYYYMMDD.Text := format('%s.%s.%s까지', [Copy(Product.EndDate, 1, 4),
                                              Copy(Product.EndDate, 5, 2),
                                              Copy(Product.EndDate, 7, 2)]);

  if FProduct.Product_Div = PRODUCT_TYPE_D then
  begin
    txtName.Text := Format('%s', ['일일타석권']);
    txtName.TextSettings.FontColor := $FF234B9C;
    txtProductTemp.Text := Format('%s분', [FProduct.One_Use_Time]);
  end
  else if FProduct.Product_Div = PRODUCT_TYPE_C then
  begin
    txtName.Text := Format('%s', ['쿠폰 회원권']);
    txtName.TextSettings.FontColor := $FFC53915;
    txtProductTemp.Text := Format('%d회', [FProduct.Use_Qty]);
  end
  else
  begin
    txtName.Text := Format('%s', ['기간제 회원권']);
    txtName.TextSettings.FontColor := $FF2AA430;
    txtProductTemp.Text := Format('%s분', [FProduct.One_Use_Time]);
  end;

  if not Product.Use then
    ImgNotUse.Visible := True
  else if Product.Product_Div = PRODUCT_TYPE_D then
    ImgDay.Visible := True
  else if Product.Product_Div = PRODUCT_TYPE_C then
    ImgCoupon.Visible := True
  else
    ImgPeriod.Visible := True;

  //2021-10-12 선택깜빡임
  Timer.Enabled := True;
end;

procedure TFullPopupCouponItem.RectangleClick(Sender: TObject);
var
  AProductInfo: TProductInfo;
  sCode, sMsg: String;
begin
  if FProduct.Name = EmptyStr then
    Exit;

  if global.Config.ProductTime = False then //배정시간 기준
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
    //chy 2020-11-04 보유상품이 1개인경우 메세지 출력않함
    if Global.SaleModule.ProductList.Count = 1 then
    begin
      if Global.Config.AD.USE = True then
      begin
        if StoreCloseTmCheck(FProduct) = True then //True: 초과시
        begin
          Exit;
        end;
      end;

      Global.SaleModule.SelectProduct := FProduct;
      FullPopup.CloseFormStrMrok('');
    end
    else
    begin
      if Global.SBMessage.ShowMessageModalForm(FProduct.Name + '으로 배정 받으시겠습니까?', False) then
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
    Global.SBMessage.ShowMessageModalForm('이미 사용하거나 사용 할 수 없는 상품입니다.');
end;

procedure TFullPopupCouponItem.SelectRectangleClick(Sender: TObject);
begin
  TouchSound;
  if FProduct.Name = EmptyStr then
    Exit;

  if FProduct.Use then
  begin
    if Global.SBMessage.ShowMessageModalForm(FProduct.Name + '으로 배정 받으시겠습니까?', False) then
    begin
      Global.SaleModule.SelectProduct := FProduct;
      FullPopup.CloseFormStrMrok('');
    end;
  end
  else
    Global.SBMessage.ShowMessageModalForm('이미 사용하거나 사용 할 수 없는 상품입니다.');
end;

procedure TFullPopupCouponItem.TimerTimer(Sender: TObject);
begin
  if imgSelectRectangle.Visible = True then
    imgSelectRectangle.Visible := False
  else
    imgSelectRectangle.Visible := True;
end;

end.
