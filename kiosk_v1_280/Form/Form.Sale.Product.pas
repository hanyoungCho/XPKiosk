
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
    EasyRectangle: TRectangle;
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
    ImgLine1: TImage;
    ImgLine2: TImage;
    Rectangle4: TRectangle;
    Image4: TImage;
    Image5: TImage;
    txtCard: TText;
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
    AllianceRectangle: TRectangle;
    Image1: TImage;
    Text10: TText;
    PaycoRectangle: TRectangle;
    Image2: TImage;
    Text11: TText;
    WellbeingRectangle: TRectangle;
    Image3: TImage;
    txtWellbeing: TText;
    Timer1: TTimer;
    procedure FormShow(Sender: TObject);
    procedure Rectangle1Click(Sender: TObject);
    procedure BackImageClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PayCoRectangleClick(Sender: TObject);
    procedure CardRectangleClick(Sender: TObject);
    procedure PromotionRectangleClick(Sender: TObject);

    procedure TimerTimer(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);

    procedure FormDestroy(Sender: TObject);
    procedure ProcessRectangleClick(Sender: TObject);
    procedure CallImageClick(Sender: TObject);
    procedure HomeImageClick(Sender: TObject);
    procedure BottomRectangleClick(Sender: TObject);
    procedure ComPortRxChar(Sender: TObject; Count: Integer);
    procedure CancelRectangleClick(Sender: TObject);

    procedure AppCardRectangleClick(Sender: TObject);
    procedure AllianceRectangleClick(Sender: TObject);
    procedure WellbeingRectangleClick(Sender: TObject);

  private
    { Private declarations }
    FCnt: Integer;
    FSec: Integer;
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

    procedure ShowAdvertPopupView;

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
    EasyRectangle.Enabled := False;
    PaycoRectangle.Enabled := False;
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
    EasyRectangle.Enabled := True;
    PaycoRectangle.Enabled := True;
    CardRectangle.Enabled := True;
    CancelRectangle.Enabled := True;
    Global.SaleModule.CardApplyType := catNone;
  end;
end;

procedure TSaleProduct.BackImageClick(Sender: TObject);
begin
  TouchSound;
  Timer.Enabled := False;
  MemberSaleProductListStyle1.ItemList.Free;
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
    EasyRectangle.Enabled := False;
    PaycoRectangle.Enabled := False;
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

    if (Global.Config.Store.StoreCode = 'BC001') then //힐스테이트
    begin
      if Global.SaleModule.RealAmt = 0 then
      begin
        ModalResult := mrOk;
        Exit;
      end;
    end
    else
    begin
    if Global.SaleModule.RealAmt = 0 then
    begin
      Global.SBMessage.ShowMessageModalForm(MSG_NOT_PAY_AMT);
      Timer.Enabled := True;
      Exit;
    end;
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

    Log.D('CardRectangleClick', 'End');
  finally
    EasyRectangle.Enabled := True;
    PaycoRectangle.Enabled := True;
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

  //Comport.BaudRate := br115200; -> 트로스
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
  if (Global.SaleModule.PaymentAddType = patFacilityPeriod) or (Global.SaleModule.PaymentAddType = patFacilityDay) then
    Text1.Text := '시설 이용권 구매'
  else if (Global.SaleModule.PaymentAddType = patGeneral) then
    Text1.Text := '일반 상품권 구매'
  else
    Text1.Text := '타석 상품권 구매';

  if Global.SaleModule.PaymentAddType <> patNone then
  begin
    PromotionRectangle.Visible := False;
    AllianceRectangle.Visible := False;
  end
  else
  begin
    //프로모션 2022-03-22
    PromotionRectangle.Visible := Global.Config.Promotion;

    //제휴사 표시여부
    if Global.Config.Alliance = True then
    begin
      PromotionRectangle.Position.X := 0;
      AllianceRectangle.Visible := True;
      AllianceRectangle.Enabled := True;
    end
    else
    begin
      PromotionRectangle.Position.X := 60;
    end;
  end;

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
        //chy BC페이북QR - 스타 제외
        //장한평인경우 일일타석 무조건 1개만 표시
        if (MemberSaleProductListStyle1.Item420List.Count = 1) then
        begin
          Global.SaleModule.AddProduct(MemberSaleProductListStyle1.Item420List[0].Product);
          {
          if Global.Config.AD.USE = True then
          begin
            if StoreCloseTmCheck(MemberSaleProductListStyle1.Item420List[0].Product) then
            begin
              MinusProduct(MemberSaleProductListStyle1.Item420List[0].Product);
              Exit;
            end;
          end;
          }
        end;

        if Global.Config.PromotionPopup = True  then
          Global.SBMessage.ShowMessageModalForm('신한', True, 15);

      end;
    end;
  end;

  ShowAmt;
  Timer.Enabled := True;
  Top1.lblDay.Text := Global.SaleModule.NowHour;
  Top1.lblTime.Text := Global.SaleModule.NowTime;
  ErrorMsg := EmptyStr;

  if (Global.SaleModule.memberItemType = mitDay) and
     (Global.SaleModule.AdvertListPopupMember.Count > 0) then
  begin
    if (Global.SaleModule.AdvertListPopupMember[0].ProductAddYn = 'Y') then
      Timer1.Enabled := True;
  end;

  if (Global.Config.Store.StoreCode = 'C1001') and
     ((Global.SaleModule.memberItemType = mitperiod) or (Global.SaleModule.memberItemType = mitCoupon)) then //코리아하이파이브스포츠클럽
  begin
    txtTime.Text := '남은 시간 : 60초';
    Timer1.Enabled := True;
  end;

end;

procedure TSaleProduct.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;

  if (Global.SaleModule.memberItemType = mitDay) then
  begin
    ShowAdvertPopupView;
  end
  else
  begin
    if (Global.Config.Store.StoreCode = 'C1001') then
    begin
      if ShowPolicyView(4) = False then
        ModalResult := mrCancel;
    end;
  end;

end;

procedure TSaleProduct.ShowAdvertPopupView;
begin
  //광고 추가 구좌-추천회원권
  if (Global.SaleModule.AdvertPopupType <> apMember) then
  begin
    if ShowAdvertPopup = True then
    begin
      Global.SaleModule.PopUpLevel := plAdvertItemType;
      if not ShowPopup('ShowAdvertPopupView/plAdvertItemType') then
      begin
        Global.SaleModule.AdvertPopupType := apNone;
        Exit;
      end;

      if (Global.SaleModule.BuyProductList.Count > 0) then
        Global.SaleModule.MinusProduct(Global.SaleModule.BuyProductList[0].Products);

      ModalResult := mrCancel;
    end;
  end;

end;

procedure TSaleProduct.HomeImageClick(Sender: TObject);
begin
  TouchSound;
end;

procedure TSaleProduct.PayCoRectangleClick(Sender: TObject);
var
  APayco: TPaycoNewRecvInfo;
begin

  try
    try
      Log.D('PayCoRectangleClick', 'Begin');
      Cnt := 0;
      EasyRectangle.Enabled := False;
      PaycoRectangle.Enabled := False;
      CardRectangle.Enabled := False;
      CancelRectangle.Enabled := False;
      Timer.Enabled := False;

      if Global.Config.Scanner.Port <> 0 then
      begin
        Comport.Open;
      end;

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
      {$ENDIF}

      APayco := Global.SaleModule.CallPayco;
      if not APayco.Result then
      begin
        SetCursorPos(100, 100); //마우스 커서가 가야 할 버튼의 위치
        Mouse_Event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
        Mouse_Event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);

        Global.SBMessage.ShowMessageModalForm(APayco.Msg);
        Timer.Enabled := True;
      end
      else
      begin
        ModalResult := mrOk;
      end;
    except
      on E: Exception do
        Log.E('PayCoRectangleClick', E.Message);
    end;
  finally
    EasyRectangle.Enabled := True;
    PaycoRectangle.Enabled := True;
    CardRectangle.Enabled := True;
    CancelRectangle.Enabled := True;

    if Global.Config.Scanner.Port <> 0 then
      Comport.Close;

    Log.D('PayCoRectangleClick', 'End');
  end;
end;

procedure TSaleProduct.ProcessRectangleClick(Sender: TObject);
begin
  TouchSound;
end;

procedure TSaleProduct.AllianceRectangleClick(Sender: TObject);
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
    EasyRectangle.Enabled := False;
    PaycoRectangle.Enabled := False;
    CardRectangle.Enabled := False;
    CancelRectangle.Enabled := False;
    PromotionRectangle.Enabled := False;
    AllianceRectangle.Enabled := False;
    Timer.Enabled := False;

    TouchSound(False, True);
    Global.SaleModule.PromotionType := pttSelect;

    if (Global.SaleModule.BuyProductList.Count > 0) then
      MinusProduct(Global.SaleModule.BuyProductList[0].Products);

    //제휴사 표시
    if not (ShowFullPopup(False, 'AllianceRectangleClick') = mrOk) then
    begin
      Timer.Enabled := True;
      Global.SaleModule.PopUpFullLevel := pflNone;
      Global.SaleModule.PopUpLevel := plNone;
      Global.SaleModule.CardApplyType := catNone;
      Global.SaleModule.PromotionType := pttNone;

      ErrorMsg := EmptyStr;

      //제휴사 선택후 해당 제휴사 선택시 상품이 선택됨
      if (Global.SaleModule.BuyProductList.Count > 0) then
        MinusProduct(Global.SaleModule.BuyProductList[0].Products);
    end
    else
      ModalResult := mrOk;

    Log.D('AllianceRectangleClick', 'End');
  finally
    EasyRectangle.Enabled := True;
    PaycoRectangle.Enabled := True;
    CardRectangle.Enabled := True;
    CancelRectangle.Enabled := True;
    PromotionRectangle.Enabled := True;
    AllianceRectangle.Enabled := True;
    Global.SaleModule.PromotionType := pttNone;
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

    if txtTotalAmt.Text = '0원' then
    begin
      ModalResult := mrOk;
      Exit;
    end;

  end;

  Timer.Enabled := True;
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

  PromotionRectangle.Enabled := Global.SaleModule.BuyProductList.Count <> 0; //프로모션
  CardRectangle.Enabled := Global.SaleModule.BuyProductList.Count <> 0;
  EasyRectangle.Enabled := Global.SaleModule.BuyProductList.Count <> 0;
  PaycoRectangle.Enabled := Global.SaleModule.BuyProductList.Count <> 0;

  if Global.SaleModule.memberItemType = mitAlliance then
  begin
    PromotionRectangle.Enabled := False;
    CardRectangle.Enabled := False;
    CardRectangle.Visible := False;
    WellbeingRectangle.Visible := True;
    WellbeingRectangle.Enabled := Global.SaleModule.BuyProductList.Count <> 0;
    EasyRectangle.Enabled := False;
    PaycoRectangle.Enabled := False;
  end;

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
var
  nCnt: Integer;
begin
  try
    //2021-11-05 500 으로 변경
    if CardRectangle.Enabled = True then
    begin
      if txtCard.TextSettings.FontColor = $FFFFFFFF then
        txtCard.TextSettings.FontColor := $FF343434
      else
        txtCard.TextSettings.FontColor := $FFFFFFFF; //white
    end;

    if WellbeingRectangle.Enabled = True then
    begin
      if txtWellbeing.TextSettings.FontColor = $FFFFFFFF then
        txtWellbeing.TextSettings.FontColor := $FF343434
      else
        txtWellbeing.TextSettings.FontColor := $FFFFFFFF; //white
    end;

    Inc(FCnt);
    if FCnt > 1 then
    begin
      FCnt := 0;

      Inc(FSec);

      if (Global.Config.Store.StoreCode = 'C1001') then //코리아하이파이브스포츠클럽
      begin
        txtTime.Text := Format(TimeSecCaption, [LPadB(IntToStr(60 - FSec), 2, ' ')]);
        nCnt := 60 - FSec;
      end
      else
      begin
        txtTime.Text := Format(TimeSecCaption, [LPadB(IntToStr(Time30Sec - FSec), 2, ' ')]);
        nCnt := Time30Sec - FSec;
      end;

      //if (Time30Sec - FSec) = 0 then
      if nCnt = 0 then
      begin
        Timer.Enabled := False;
        MemberSaleProductListStyle1.ItemListClear;
        ModalResult := mrCancel;
      end;
    end;
  except
    on E: Exception do
      Log.E(ClassName, E.Message);
  end;
end;

procedure TSaleProduct.WellbeingRectangleClick(Sender: TObject);
begin

  try
    if Global.SaleModule.memberItemType <> mitAlliance then
    begin
      Global.SBMessage.ShowMessageModalForm('웰빙회원만 사용가능 합니다.', True, 15);
      Exit;
    end;

    if not CheckEndTime then
    begin
      Log.D('WellbeingRectangleClick CheckEndTime', 'Out');
      BackImageClick(nil);
      Exit;
    end;

    if Global.SaleModule.BuyProductList.Count = 0 then
    begin
      Global.SBMessage.ShowMessageModalForm(MSG_ADD_PRODUCT);
      Timer.Enabled := True;
      Exit;
    end;

    Global.SaleModule.PromotionType := pttWellbeing;

    if not (ShowFullPopup(False, 'WellbeingRectangleClick') = mrOk) then
    begin
      Timer.Enabled := True;
      Global.SaleModule.PopUpFullLevel := pflNone;
      Global.SaleModule.PopUpLevel := plNone;
      Global.SaleModule.CardApplyType := catNone;
      Global.SaleModule.PromotionType := pttNone;

      ErrorMsg := EmptyStr;
    end
    else
      ModalResult := mrOk;

    //Log.D('AllianceRectangleClick', 'End');
  finally
    Global.SaleModule.PromotionType := pttNone;
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
