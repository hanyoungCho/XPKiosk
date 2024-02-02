
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
    BackRectangle: TRectangle;
    BackImage: TImage;
    HomeRectangle: TRectangle;
    HomeImage: TImage;
    HomeText: TText;
    CallRectangle: TRectangle;
    CallImage: TImage;
    CallText: TText;
    CardRectangle: TRectangle;
    PayCoRectangle: TRectangle;
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
    PromotionRectangle: TRectangle;
    Timer: TTimer;
    txtTime: TText;
    ProcessRectangle: TRectangle;
    ComPort: TComPort;
    ImgLine1: TImage;
    ImgLine2: TImage;
    Rectangle4: TRectangle;
    Image4: TImage;
    Image5: TImage;
    Text2: TText;
    CancelRectangle: TRectangle;
    Image6: TImage;
    Text3: TText;
    Image7: TImage;
    Image8: TImage;
    Text7: TText;
    MemberSaleProductListStyle1: TMemberSaleProductListStyle;
    BGRectangle: TRectangle;
    SaleOrderList1: TSaleOrderList;
    Text9: TText;
    PromotionRectangle2: TRectangle;
    Image1: TImage;
    Text10: TText;
    procedure FormShow(Sender: TObject);
    procedure Rectangle1Click(Sender: TObject);
    procedure BackImageClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PayCoRectangleClick(Sender: TObject);
    procedure CardRectangleClick(Sender: TObject);
    procedure PromotionRectangleClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ProcessRectangleClick(Sender: TObject);
    procedure CallImageClick(Sender: TObject);
    procedure HomeImageClick(Sender: TObject);
    procedure BottomRectangleClick(Sender: TObject);
    procedure ComPortRxChar(Sender: TObject; Count: Integer);
    procedure CancelRectangleClick(Sender: TObject);

    procedure AppCardRectangleClick(Sender: TObject);
    procedure PromotionRectangle2Click(Sender: TObject);
  private
    { Private declarations }
    FCnt: Integer;
    FMouseDownX: Extended;
    FMouseDownY: Extended;
    FReadStr: string;
    BarcodeIn: Boolean;
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

procedure TSaleProduct.AppCardRectangleClick(Sender: TObject);
begin
  try
    Log.D('AppCardRectangleClick', 'Begin');
    Cnt := 0;
    PayCoRectangle.Enabled := False;
    CardRectangle.Enabled := False;
    CancelRectangle.Enabled := False;
    Timer.Enabled := False;
    Global.SaleModule.CardApplyType := catAppCard;

    if not CheckEndTime then
    begin
      Log.D('AppCardRectangleClick CheckEndTime', 'Out');
      BackImageClick(nil);
      Exit;
    end;

    if not (ShowFullPopup(False, 'AppCardRectangleClick') = mrOk) then
    begin
      Timer.Enabled := True;
      Global.SaleModule.PopUpFullLevel := pflNone;
      Global.SaleModule.PopUpLevel := plNone;
      Global.SaleModule.CardApplyType := catNone;
      Global.SaleModule.PromotionType := pttNone;
      Global.SBMessage.ShowMessageModalForm(ErrorMsg);
      ErrorMsg := EmptyStr;
    end
    else
      ModalResult := mrOk;

    Log.D('AppCardRectangleClick', 'End');
  finally
    PayCoRectangle.Enabled := True;
    CardRectangle.Enabled := True;
    CancelRectangle.Enabled := True;
    Global.SaleModule.CardApplyType := catNone;
  end;
end;

procedure TSaleProduct.BackImageClick(Sender: TObject);
begin
  TouchSound;
  Timer.Enabled := False;
//  TListClear(MemberSaleProductListStyle1.ItemList);
  MemberSaleProductListStyle1.ItemList.Free;
//  TListClear(MemberSaleProductListStyle1.Item420List);
  MemberSaleProductListStyle1.Item420List.Free;
  Global.SaleModule.BuyListClear;
  ModalResult := mrIgnore;
end;

procedure TSaleProduct.BottomRectangleClick(Sender: TObject);
begin
  TouchSound;
end;

procedure TSaleProduct.CallImageClick(Sender: TObject);
begin
//  TouchSound;
  try
    Cnt := 0;
    Timer.Enabled := False;
    Global.SaleModule.CallAdmin;
  finally
    Timer.Enabled := True;
  end;
end;

procedure TSaleProduct.CardRectangleClick(Sender: TObject);
begin
  try
    Log.D('CardRectangleClick', 'Begin');
    Cnt := 0;
    PayCoRectangle.Enabled := False;
    CardRectangle.Enabled := False;
    CancelRectangle.Enabled := False;
    Timer.Enabled := False;
    Global.SaleModule.CardApplyType := catMagnetic;

    if not CheckEndTime then
    begin
      Log.D('CardRectangleClick CheckEndTime', 'Out');
      BackImageClick(nil);
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
      Global.SaleModule.PromotionType := pttNone;
    end
    else
      ModalResult := mrOk;

//    ProcessRectangle.Visible := True;
    Log.D('CardRectangleClick', 'End');
  finally
//    ProcessRectangle.Visible := False;
    PayCoRectangle.Enabled := True;
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
//  Comport.Port := 'COM' + IntToStr(Global.Config.Scanner.Port);
//  Comport.BaudRate := br115200;
end;

procedure TSaleProduct.FormDestroy(Sender: TObject);
begin
  MemberSaleProductListStyle1.ItemListClear;
  MemberSaleProductListStyle1.Free;
  SaleOrderList1.Free;
  DeleteChildren;
end;

procedure TSaleProduct.FormShow(Sender: TObject);
begin

  //제휴사 표시않함
  PromotionRectangle.Position.X := 60;

  FReadStr := EmptyStr;
  BarcodeIn := False;
  ImgLayout.Scale.X := Layout.Scale.X;
  ImgLayout.Scale.Y := Layout.Scale.Y;
  MemberSaleProductListStyle1.Display;

  //프로모션 팝업
  if MemberSaleProductListStyle1.Item420List <> nil then
  begin
    if (MemberSaleProductListStyle1.Item420List.Count <> 0) then
    begin
      if (MemberSaleProductListStyle1.Item420List[0].Product.Product_Div = PRODUCT_TYPE_D) then
      begin
        if (MemberSaleProductListStyle1.Item420List.Count = 1) then
          Global.SaleModule.AddProduct(MemberSaleProductListStyle1.Item420List[0].Product);

        if Global.Config.PromotionPopup = True then
          Global.SBMessage.ShowMessageModalForm('신한', True, 15);
      end;
    end;
  end;

  ShowAmt;
  Timer.Enabled := True;
  Top1.lblDay.Text := Global.SaleModule.NowHour;
  Top1.lblTime.Text := Global.SaleModule.NowTime;
  ErrorMsg := EmptyStr;
end;

procedure TSaleProduct.HomeImageClick(Sender: TObject);
begin
  TouchSound;
end;

procedure TSaleProduct.PayCoRectangleClick(Sender: TObject);
var
  APayco: TPaycoNewRecvInfo;
begin
  Exit;
  try
    try
//      Global.SBMessage.ShowMessageModalForm('곧 서비스 예정입니다.');
//      Timer.Enabled := True;
//      Exit;
      Log.D('PayCoRectangleClick', 'Begin');
      Cnt := 0;
      PayCoRectangle.Enabled := False;
      CardRectangle.Enabled := False;
      CancelRectangle.Enabled := False;
      Timer.Enabled := False;

      if not CheckEndTime then
      begin
        Log.D('CardRectangleClick CheckEndTime', 'Out');
        BackImageClick(nil);
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

      {$IFDEF RELEASE}
      TouchSound(False, True);
//      BarcodeIn := False;
//      if Global.Config.Scanner.Port <> 0 then
//        ComPort.Open;
      {$ENDIF}

      APayco := Global.SaleModule.CallPayco;
      if not APayco.Result then
      begin
        Global.SBMessage.ShowMessageModalForm(APayco.Msg);
        Timer.Enabled := True;
      end
      else
      begin
  //      Global.SaleModule.SaleCompleteProc;
        ModalResult := mrOk;
      end;
    except
      on E: Exception do
        Log.E('PayCoRectangleClick', E.Message);
    end;
  finally
    PayCoRectangle.Enabled := True;
    CardRectangle.Enabled := True;
    CancelRectangle.Enabled := True;
//    if Global.Config.Scanner.Port <> 0 then
//      Comport.Close;
    Log.D('PayCoRectangleClick', 'End');
  end;
end;

procedure TSaleProduct.ProcessRectangleClick(Sender: TObject);
begin
  TouchSound;
end;

procedure TSaleProduct.PromotionRectangle2Click(Sender: TObject);
var
  Index: Integer;
begin
  try
    {$IFDEF RELEASE}
    if Global.SaleModule.memberItemType <> mitDay then
    begin
      Global.SBMessage.ShowMessageModalForm(MSG_PROMOTION_PRODUCT_ONLY_DAY, True, 15);
      Exit;
    end;
    {$ENDIF}

    Log.D('PromotionRectangle2Click', 'Begin');
    Cnt := 0;
    PayCoRectangle.Enabled := False;
    CardRectangle.Enabled := False;
    CancelRectangle.Enabled := False;
    PromotionRectangle.Enabled := False;
    PromotionRectangle2.Enabled := False;
    Timer.Enabled := False;

    TouchSound(False, True);
    Global.SaleModule.PromotionType := pttSelect;

    if not CheckEndTime then
    begin
      Log.D('PromotionRectangle2Click CheckEndTime', 'Out');
      BackImageClick(nil);
      Exit;
    end;

    //제휴사 표시
    if not (ShowFullPopup(False, 'PromotionRectangle2Click') = mrOk) then
    begin
      Timer.Enabled := True;
      Global.SaleModule.PopUpFullLevel := pflNone;
      Global.SaleModule.PopUpLevel := plNone;
      Global.SaleModule.CardApplyType := catNone;
      Global.SaleModule.PromotionType := pttNone;
//      Global.SBMessage.ShowMessageModalForm(ErrorMsg);
      ErrorMsg := EmptyStr;
    end
    else
      ModalResult := mrOk;

    Log.D('PromotionRectangle2Click', 'End');
  finally
    PayCoRectangle.Enabled := True;
    CardRectangle.Enabled := True;
    CancelRectangle.Enabled := True;
    PromotionRectangle.Enabled := True;
    PromotionRectangle2.Enabled := True;
    Global.SaleModule.PromotionType := pttNone;

    // 웰빙
    if Global.SaleModule.BuyProductList.Count > 0 then
    begin
      for Index := 0 to Global.SaleModule.BuyProductList.Count - 1 do
      begin
        //if Global.SaleModule.BuyProductList[Index].Products.Name = '웰빙클럽' then
        if (Pos('웰빙클럽', Global.SaleModule.BuyProductList[Index].Products.Name) > 0) or
           (Pos('리프레쉬', Global.SaleModule.BuyProductList[Index].Products.Name) > 0) then
        begin
          CardRectangle.Enabled := False;
          PayCoRectangle.Enabled := False;
          break;
        end;
      end;
    end;
  end;
end;

procedure TSaleProduct.PromotionRectangleClick(Sender: TObject);
begin
  Timer.Enabled := False;
  Cnt := 0;

  if Global.SaleModule.BuyProductList.Count = 0 then
  begin
    Global.SBMessage.ShowMessageModalForm(MSG_ADD_PRODUCT);
    Timer.Enabled := True;
    Exit;
  end;
//  Global.Database.SearchPromotion('C-282802d5-cf6a-4336-83c7-24b5c6221e7f');
//  Global.SaleModule.Calc;
//  ShowAmt;
//
//  Global.Database.SearchPromotion('C-650b663f-2939-4e42-905d-4d4f480a15af');
//  Global.SaleModule.Calc;
//  ShowAmt;
//
//  Exit;
//
  TouchSound(False, True);
  Global.SaleModule.PopUpFullLevel := pflPromo;
  if ShowFullPopup(False, 'PromotionRectangleClick') = mrCancel then
  begin
//    Global.SBMessage.ShowMessageModalForm(MSG_PROMOTION + MSG_PROMOTION_OPTION_1);
  end
  else
  begin
    Global.SaleModule.Calc;
    ShowAmt;
    Global.SBMessage.ShowMessageModalForm(MSG_PROMOTION_OK);
  end;

  Timer.Enabled := True;;
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
  Index: Integer;
begin
  Vat := Global.SaleModule.TotalAmt - Trunc(Global.SaleModule.TotalAmt / 1.1);
  PromotionRectangle.Enabled := Global.SaleModule.BuyProductList.Count <> 0;

  //일일타석 상품 복수개-유명,캐슬렉스
  if (Global.Config.Store.StoreCode = 'A4001') or //유명
     (Global.Config.Store.StoreCode = 'A6001') then //캐슬렉스
    PromotionRectangle2.Enabled := False
  else
    PromotionRectangle2.Enabled := Global.SaleModule.BuyProductList.Count <> 0; //제휴사 표시

  CardRectangle.Enabled := Global.SaleModule.BuyProductList.Count <> 0;
  PayCoRectangle.Enabled := Global.SaleModule.BuyProductList.Count <> 0;

  // 웰빙
  if Global.SaleModule.BuyProductList.Count > 0 then
  begin
    for Index := 0 to Global.SaleModule.BuyProductList.Count - 1 do
    begin
      //if Global.SaleModule.BuyProductList[Index].Products.Name = '웰빙클럽' then
      if (Pos('웰빙클럽', Global.SaleModule.BuyProductList[Index].Products.Name) > 0) or
         (Pos('리프레쉬', Global.SaleModule.BuyProductList[Index].Products.Name) > 0) then
      begin
        CardRectangle.Enabled := False; //카드결제
        PayCoRectangle.Enabled := False; //간편결제

        if (Global.Config.Store.StoreCode = 'A4001') or //유명
           (Global.Config.Store.StoreCode = 'A6001') then //캐슬렉스
        begin
          PromotionRectangle2.Enabled := True;
        end;

        break;
      end;
    end;
  end;

  txtSaleAmt.Text := Format('%s원', [FormatFloat('#,##0.##', Global.SaleModule.TotalAmt)]);
  txtVat.Text := Format('%s원', [FormatFloat('#,##0.##', Vat)]);
  txtDCAmt.Text := Format('%s원', [FormatFloat('#,##0.##', -1 * Global.SaleModule.DCAmt)]);
//  txtSaleAmt.Text := Format('%s원', [FormatFloat('#,##0.##', Global.SaleModule.TotalAmt)]);
//  txtVat.Text := Format('%s원', [FormatFloat('#,##0.##', Global.SaleModule.TotalAmt - Trunc(Global.SaleModule.TotalAmt / 1.1))]);
//  txtDCAmt.Text := Format('%s원', [FormatFloat('#,##0.##', Global.SaleModule.DCAmt)]);
  txtTotalAmt.Text := Format('%s원', [FormatFloat('#,##0.##', Global.SaleModule.RealAmt)]);
  SaleOrderList1.Display;
end;

function TSaleProduct.TeeboxPlayList: Boolean;
begin
  try
    try
      Log.D('TSaleProduct.TeeboxPlayList', 'Begin');
      Result := False;
      // 가동상황을 읽어 온다.
//      Global.TeeBox.GetTeeBoxInfo;

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
//      TListClear(MemberSaleProductListStyle1.ItemList);
//      MemberSaleProductListStyle1.ItemList.Free;
      MemberSaleProductListStyle1.ItemListClear;
//      Global.SaleModule.BuyListClear;
      ModalResult := mrCancel;
    end;
  except
    on E: Exception do
      Log.E(ClassName, E.Message);
  end;
end;

procedure TSaleProduct.AddProduct(AProduct: TProductInfo);
begin//
  Cnt := 0;
  if Global.SaleModule.AddProduct(AProduct) then
  begin  // jangheejin Test
    SaleOrderList1.Display;
    ShowAmt;
  end;
end;

procedure TSaleProduct.MinusProduct(AProduct: TProductInfo);
begin//
  Cnt := 0;
  Global.SaleModule.MinusProduct(AProduct);
  SaleOrderList1.Display;
  ShowAmt;
end;

end.
