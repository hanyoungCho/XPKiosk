
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
    AllianceRectangle: TRectangle;
    Image1: TImage;
    Text10: TText;
    PaycoRectangle: TRectangle;
    Image2: TImage;
    Text11: TText;
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
    procedure AllianceRectangleClick(Sender: TObject);
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
//  TListClear(MemberSaleProductListStyle1.ItemList);
  //MemberSaleProductListStyle1.ItemList.Free;
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

    if not (ShowFullPopup(False, 'CardRectangleClick') = mrOk) then
    begin
      Timer.Enabled := True;
      Global.SaleModule.PopUpFullLevel := pflNone;
      Global.SaleModule.PopUpLevel := plNone;
      Global.SaleModule.CardApplyType := catNone;

    end
    else
      ModalResult := mrOk;

//    ProcessRectangle.Visible := True;
    Log.D('CardRectangleClick', 'End');
  finally
//    ProcessRectangle.Visible := False;
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

//    Global.TeeBox.SampleThread.Suspend;
//    for Index := 0 to Global.TeeBox.UpdateTeeBoxList.Count - 1 do
//    begin
//      if Global.SaleModule.TeeBoxInfo.TasukNo = Global.TeeBox.UpdateTeeBoxList[Index].TasukNo then
//      begin
//        if Global.SaleModule.TeeBoxInfo.End_Time <> Global.TeeBox.UpdateTeeBoxList[Index].End_Time then
//        begin
//          Global.SBMessage.ShowMessageModalForm('이미 예약된 타석 입니다.', False);
//          Exit;
//        end;
//      end;
//    end;
//    Global.TeeBox.SampleThread.Resume;

//    ABeginTime := StringReplace(Global.SaleModule.TeeBoxInfo.End_Time, ':', '', [rfReplaceAll]);
//    AEndTime := StringReplace(Global.TeeBox.UpdateTeeBoxList[Global.SaleModule.TeeBoxInfo.TasukNo - 1].End_Time, ':', '', [rfReplaceAll]);
//
//    //if (Global.SaleModule.TeeBoxInfo.End_Time <> Global.TeeBox.UpdateTeeBoxList[Global.SaleModule.TeeBoxInfo.TasukNo - 1].End_Time) then
//    if Trunc(StrToIntDef(AEndTime, 0) - StrToIntDef(ABeginTime, 0)) > 0 then
//    begin
//      if Trunc(StrToIntDef(AEndTime, 0) - StrToIntDef(ABeginTime, 0)) > 10 then
//      begin
//        Log.D('CheckEndTime', '10분 이상');
//        Log.D('CheckEndTime - Begin', Global.SaleModule.TeeBoxInfo.End_Time);
//        Log.D('CheckEndTime - End', AEndTime);
//        Global.SBMessage.ShowMessageModalForm('이미 예약된 타석 입니다.', False);
//        Exit;
//      end
//      else
//      begin
//        Log.D('CheckEndTime', '5분 이하');
//        Log.D('CheckEndTime - Begin', Global.SaleModule.TeeBoxInfo.End_Time);
//        Log.D('CheckEndTime - End', AEndTime);
//      end;
//    end;
//
//    Result := True;
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
  //Global.SaleModule.DeleteDiscount(AQRCode);
  SaleOrderList1.Display;
  ShowAmt;
end;

procedure TSaleProduct.FormCreate(Sender: TObject);
begin
  Cnt := 0;
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
end;

procedure TSaleProduct.FormShow(Sender: TObject);
begin
  PromotionRectangle.Position.X := 60;

//  SelectBox.ChangBottomImg;  // Application.Exception 의심되서 해당 폼을 호출하기전으로 옮김 2020.01.09 JHJ
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

          if Global.Config.AD.USE = True then
          begin
            if StoreCloseTmCheck(MemberSaleProductListStyle1.Item420List[0].Product) then
            begin
              MinusProduct(MemberSaleProductListStyle1.Item420List[0].Product);
              Exit;
            end;
          end;

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
end;

procedure TSaleProduct.HomeImageClick(Sender: TObject);
begin
  TouchSound;
end;

procedure TSaleProduct.PayCoRectangleClick(Sender: TObject);
var
  APayco: TPaycoNewRecvInfo;
begin
  //Exit;
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

      //APayco := Global.SaleModule.CallPayco;
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
  //      Global.SaleModule.SaleCompleteProc;
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

(*
procedure TSaleProduct.PayCoRectangleClick(Sender: TObject);
begin
  try
    Log.D('PayCoRectangleClick', 'Begin');
    Cnt := 0;
    EasyRectangle.Enabled := False;
    PaycoRectangle.Enabled := False;
    CardRectangle.Enabled := False;
    CancelRectangle.Enabled := False;
    Timer.Enabled := False;
    Global.SaleModule.CardApplyType := catPayco;

    if not CheckEndTime then
    begin
      Log.D('PayCoRectangleClick CheckEndTime', 'Out');
      BackImageClick(nil);
      Exit;
    end;

    if not (ShowFullPopup(False, 'PayCoRectangleClick') = mrOk) then
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

    Log.D('PayCoRectangleClick', 'End');
  finally
    EasyRectangle.Enabled := True;
    PaycoRectangle.Enabled := True;
    CardRectangle.Enabled := True;
    CancelRectangle.Enabled := True;
    Global.SaleModule.CardApplyType := catNone;
  end;
end;
*)
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


    if (Global.SaleModule.BuyProductList.Count > 0) then
      MinusProduct(Global.SaleModule.BuyProductList[0].Products);

    //제휴사 표시
    if not (ShowFullPopup(False, 'AllianceRectangleClick') = mrOk) then
    begin
      Timer.Enabled := True;
      Global.SaleModule.PopUpFullLevel := pflNone;
      Global.SaleModule.PopUpLevel := plNone;
      Global.SaleModule.CardApplyType := catNone;

//      Global.SBMessage.ShowMessageModalForm(ErrorMsg);
      ErrorMsg := EmptyStr;
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


    //chy 웰빙
    if Global.SaleModule.BuyProductList.Count > 0 then
    begin
      for Index := 0 to Global.SaleModule.BuyProductList.Count - 1 do
      begin
        //if Global.SaleModule.BuyProductList[Index].Products.Name = '웰빙클럽' then
        if (Pos('웰빙클럽', Global.SaleModule.BuyProductList[Index].Products.Name) > 0) or
           (Pos('리프레쉬', Global.SaleModule.BuyProductList[Index].Products.Name) > 0) or
           (Pos('더라운지', Global.SaleModule.BuyProductList[Index].Products.Name) > 0) or
           (Pos('페이북', Global.SaleModule.BuyProductList[Index].Products.Name) > 0) then
        begin
          CardRectangle.Enabled := False; //카드결제
          EasyRectangle.Enabled := False; //간편결제
          PaycoRectangle.Enabled := False; //간편결제
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

  TouchSound(False, True);
  //Global.SaleModule.PopUpFullLevel := pflPromo;
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

  //프로모션
  if (Global.Config.Store.StoreCode = 'A6001') then //캐슬렉스
  begin
    PromotionRectangle.Enabled := False;

    if Global.SaleModule.BuyProductList.Count > 0 then
    begin
      for Index := 0 to Global.SaleModule.BuyProductList.Count - 1 do
      begin
        if (Global.SaleModule.BuyProductList[Index].Products.Name = '일일타석 주중 80분') or
           (Global.SaleModule.BuyProductList[Index].Products.Name = '일일타석 주말 80분') then
        begin
          PromotionRectangle.Enabled := True;

          break;
        end;
      end;
    end;
  end
  else
    PromotionRectangle.Enabled := Global.SaleModule.BuyProductList.Count <> 0;

  CardRectangle.Enabled := Global.SaleModule.BuyProductList.Count <> 0;
  EasyRectangle.Enabled := Global.SaleModule.BuyProductList.Count <> 0;
  PaycoRectangle.Enabled := Global.SaleModule.BuyProductList.Count <> 0;

  {
  //chy 웰빙
  if Global.SaleModule.BuyProductList.Count > 0 then
  begin
    for Index := 0 to Global.SaleModule.BuyProductList.Count - 1 do
    begin
      //if Global.SaleModule.BuyProductList[Index].Products.Name = '웰빙클럽' then
      if (Pos('웰빙클럽', Global.SaleModule.BuyProductList[Index].Products.Name) > 0) or
         (Pos('리프레쉬', Global.SaleModule.BuyProductList[Index].Products.Name) > 0) or
         (Pos('더라운지', Global.SaleModule.BuyProductList[Index].Products.Name) > 0) or
         (Pos('페이북', Global.SaleModule.BuyProductList[Index].Products.Name) > 0) then
      begin
        CardRectangle.Enabled := False; //카드결제 버튼
        EasyRectangle.Enabled := False; //간편결제 버튼
        PaycoRectangle.Enabled := False; // payco

        if (Global.Config.Store.StoreCode = 'A1001') or //스타
           (Global.Config.Store.StoreCode = 'A2001') or //양평
           (Global.Config.Store.StoreCode = 'A3001') or //JMS
           (Global.Config.Store.StoreCode = 'A4001') or //유명
           (Global.Config.Store.StoreCode = 'A6001') or //캐슬렉스
           (Global.Config.Store.StoreCode = 'A7001') or //빅토리아
           (Global.Config.Store.StoreCode = 'A9001') or //루이힐스
           (Global.Config.Store.StoreCode = 'AB001') then //대성
        begin
          AllianceRectangle.Enabled := True;  //제휴사 버튼
        end;

        break;
      end;
    end;
  end;
  }

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
