
unit Form.Sale.Product;

interface

uses
  Frame.Sale.Order.List.Style, uStruct,  Windows,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.Ani, FMX.Layouts, FMX.Gestures,
  FMX.Objects, Frame.Member.Sale.Product.List.Style, Frame.Top, uPaycoNewModul,
  CPort, FMX.StdCtrls;

type
  TSaleProduct = class(TForm)
    ImgLayout: TLayout;
    ImgBG: TImage;
    Layout: TLayout;
    TopLayout: TLayout;
    Top1: TTop;
    Text1: TText;
    ProductRectangle: TRectangle;
    Rectangle1: TRectangle;
    Rectangle2: TRectangle;
    BottomLayout: TLayout;
    BottomRectangle: TRectangle;
    CardRectangle: TRectangle;
    Rectangle5: TRectangle;
    Rectangle6: TRectangle;
    Rectangle7: TRectangle;
    Text4: TText;
    txtSaleAmt: TText;
    Text6: TText;
    txtDCAmt: TText;
    Rectangle3: TRectangle;
    Text5: TText;
    txtVat: TText;
    Rectangle8: TRectangle;
    Text8: TText;
    txtTotalAmt: TText;
    Timer: TTimer;
    txtTime: TText;
    ProcessRectangle: TRectangle;
    ImgLine1: TImage;
    ImgLine2: TImage;
    Rectangle4: TRectangle;
    Image5: TImage;
    Text2: TText;
    CancelRectangle: TRectangle;
    Image6: TImage;
    Text3: TText;
    Image7: TImage;
    MemberSaleProductListStyle1: TMemberSaleProductListStyle;
    BGRectangle: TRectangle;
    SaleOrderList1: TSaleOrderList;
    procedure FormShow(Sender: TObject);
    procedure Rectangle1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CardRectangleClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BottomRectangleClick(Sender: TObject);
    procedure ComPortRxChar(Sender: TObject; Count: Integer);
    procedure CancelRectangleClick(Sender: TObject);
  private
    { Private declarations }
    FCnt: Integer;
    FMouseDownX: Extended;
    FMouseDownY: Extended;
    FReadStr: string;
    BarcodeIn: Boolean;
    Comport: TComport;
    function TeeboxPlayList: Boolean;
  public
    { Public declarations }
    ErrorMsg: string;
    procedure AddProduct(AProduct: TProductInfo);
    procedure MinusProduct(AProduct: TProductInfo);
    procedure Animate(Index: Integer);

    procedure ShowAmt;
    procedure SelectPage(APage: Integer);
    function DeleteDiscount(AQRCode: string): Boolean;
    function CheckEndTime: Boolean;

    property Cnt: Integer read FCnt write FCnt;
  end;

var
  SaleProduct: TSaleProduct;

implementation

uses
  uGlobal, uConsts, uFunction, fx.Logging, uCommon, Form.Select.Box, Form.Full.Popup;

{$R *.fmx}

procedure TSaleProduct.Animate(Index: Integer);
begin
  if not Global.Config.UseItem420Size then
    MemberSaleProductListStyle1.Animate(MemberSaleProductListStyle1.ItemList[Index])
  else
    MemberSaleProductListStyle1.Animate420(MemberSaleProductListStyle1.Item420List[Index]);
end;

procedure TSaleProduct.BottomRectangleClick(Sender: TObject);
begin
  TouchSound;
end;

procedure TSaleProduct.CardRectangleClick(Sender: TObject);
begin
  try
    Log.D('CardRectangleClick', 'Begin');
    Cnt := 0;

    CardRectangle.Enabled := False;
    CancelRectangle.Enabled := False;
    Timer.Enabled := False;
    Global.SaleModule.CardApplyType := catMagnetic;

    if not CheckEndTime then
    begin
      Log.D('CardRectangleClick CheckEndTime', 'Out');

      TouchSound;
      Timer.Enabled := False;
      MemberSaleProductListStyle1.ItemList.Free;
      MemberSaleProductListStyle1.Item420List.Free;
      Global.SaleModule.BuyListClear;
      ModalResult := mrIgnore;

      Exit;
    end;

    if Global.SaleModule.BuyProductList.Count = 0 then
    begin
      Global.SBMessage.ShowMessageModalForm(MSG_ADD_PRODUCT);
      Timer.Enabled := True;
      Exit;
    end;

    if Global.SaleModule.RealAmt = 0 then
    begin
      Global.SBMessage.ShowMessageModalForm(MSG_NOT_PAY_AMT);
      Timer.Enabled := True;
      Exit;
    end;

    if Global.Config.NoPayModule then
    begin
      Global.SBMessage.ShowMessageModalForm('결제 가능한 장비가 없습니다.');
      Timer.Enabled := True;
      Exit;
    end;

    TouchSound(False, True);

    Global.SaleModule.PopUpFullLevel := pflPayCard;
    Global.SaleModule.PopUpLevel := plHalbu;

    if not (ShowFullPopup(False, 'CardRectangleClick') = mrOk) then
    begin
      Timer.Enabled := True;
      Global.SaleModule.PopUpFullLevel := pflNone;
      Global.SaleModule.PopUpLevel := plNone;
      Global.SaleModule.CardApplyType := catNone;
    end
    else
      ModalResult := mrOk;

    Log.D('CardRectangleClick', 'End');
  finally
    CardRectangle.Enabled := True;
    CancelRectangle.Enabled := True;
    Global.SaleModule.CardApplyType := catNone;
  end;
end;

function TSaleProduct.CheckEndTime: Boolean;
var
  Index: Integer;
begin
  try
    TeeboxPlayList;
    if Global.SaleModule.BuyProductList[0].Products.Product_Div <> PRODUCT_TYPE_D then
      Result := True
    else
      Result := Global.SaleModule.TeeboxTimeCheck;
  finally

  end;
end;

procedure TSaleProduct.ComPortRxChar(Sender: TObject; Count: Integer);
var
  TempBuff: string;
  AMember: TMemberInfo;
  ADiscount: TDiscount;
begin
  try
    if BarcodeIn then
      Exit;

    Comport.ReadStr(TempBuff, Count);

    FReadStr := FReadStr + TempBuff;
    if Copy(FReadStr, Length(FReadStr), 1) = #$D then
    begin
      BarcodeIn := True;
      Global.SaleModule.PaycoModule.SetBarcode(FReadStr);
      Log.D('Payco Barcode', FReadStr);
      FReadStr := EmptyStr;
    end;
  except
    on E: Exception do
    begin
      Log.E('Payco Barcode', E.Message);
    end;
  end;
end;

function TSaleProduct.DeleteDiscount(AQRCode: string): Boolean;
begin
  Global.SaleModule.DeleteDiscount(AQRCode);
  SaleOrderList1.Display;
  ShowAmt;
end;

procedure TSaleProduct.FormCreate(Sender: TObject);
begin
  Cnt := 0;
  Comport := TComPort.Create(nil);
  Comport.Port := 'COM' + IntToStr(Global.Config.Scanner.Port);

  //Comport.BaudRate := br9600; -> 씨아이테크
  if Global.Config.Scanner.BaudRate = 9600 then
    Comport.BaudRate := br9600
  else if Global.Config.Scanner.BaudRate = 115200 then
    Comport.BaudRate := br115200
  else
    Comport.BaudRate := br115200;

end;

procedure TSaleProduct.FormDestroy(Sender: TObject);
begin
  MemberSaleProductListStyle1.ItemListClear;
  MemberSaleProductListStyle1.Free;
  SaleOrderList1.Free;
  DeleteChildren;

  if Comport <> nil then
  begin
    if Comport.Connected then
      Comport.Close;
    Comport.Free;
  end;
end;

procedure TSaleProduct.FormShow(Sender: TObject);
begin
  FReadStr := EmptyStr;
  BarcodeIn := False;
  ImgLayout.Scale.X := Layout.Scale.X;
  ImgLayout.Scale.Y := Layout.Scale.Y;
  MemberSaleProductListStyle1.Display;

  ShowAmt;
  Timer.Enabled := True;
  Top1.lblDay.Text := Global.SaleModule.NowHour;
  Top1.lblTime.Text := Global.SaleModule.NowTime;
  ErrorMsg := EmptyStr;
end;

procedure TSaleProduct.Rectangle1Click(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TSaleProduct.CancelRectangleClick(Sender: TObject);
begin
  TouchSound(False, False);
  ModalResult := mrCancel;
end;

procedure TSaleProduct.SelectPage(APage: Integer);
begin
  MemberSaleProductListStyle1.SelectPage(APage);
end;

procedure TSaleProduct.ShowAmt;
var
  Vat: Currency;
  //Index: Integer;
begin
  Vat := Global.SaleModule.TotalAmt - Trunc(Global.SaleModule.TotalAmt / 1.1);

  CardRectangle.Enabled := Global.SaleModule.BuyProductList.Count <> 0;

  txtSaleAmt.Text := Format('%s원', [FormatFloat('#,##0.##', Global.SaleModule.TotalAmt)]);
  txtVat.Text := Format('%s원', [FormatFloat('#,##0.##', Vat)]);
  txtDCAmt.Text := Format('%s원', [FormatFloat('#,##0.##', -1 * Global.SaleModule.DCAmt)]);
  txtTotalAmt.Text := Format('%s원', [FormatFloat('#,##0.##', Global.SaleModule.RealAmt)]);
  SaleOrderList1.Display;
end;

function TSaleProduct.TeeboxPlayList: Boolean;
begin
  try
    try
      Log.D('TSaleProduct.TeeboxPlayList', 'Begin');
      Result := False;

      // 타석정보를 다시 읽어 온다.
      Global.TeeBox.GetGMTeeBoxList;

      Result := True;
    except
      on E: Exception do
      begin
        Log.E('TSaleProduct.TeeboxPlayList', E.Message);
      end;
    end;
  finally
    Log.D('TSaleProduct.TeeboxPlayList', 'End');
  end;
end;

procedure TSaleProduct.TimerTimer(Sender: TObject);
begin
  try
    Inc(FCnt);
    txtTime.Text := Format(TimeSecCaption, [LPadB(IntToStr(Time30Sec - FCnt), 2, ' ')]);
    if (Time30Sec - Cnt) = 0 then
    begin
      Timer.Enabled := False;
      MemberSaleProductListStyle1.ItemListClear;
      ModalResult := mrCancel;
    end;
  except
    on E: Exception do
      Log.E('TSaleProduct.TimerTimer', E.Message);
  end;
end;

procedure TSaleProduct.AddProduct(AProduct: TProductInfo);
begin
  Cnt := 0;
  if Global.SaleModule.AddProduct(AProduct) then
  begin  // jangheejin Test
    SaleOrderList1.Display;
    ShowAmt;
  end;
end;

procedure TSaleProduct.MinusProduct(AProduct: TProductInfo);
begin
  Cnt := 0;
  Global.SaleModule.MinusProduct(AProduct);
  SaleOrderList1.Display;
  ShowAmt;
end;

end.
