unit Form.Full.Popup;

interface

uses
  uConsts, uStruct, uVanDeamonModul, uBiominiPlus2, Winapi.Windows,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.Ani, FMX.Layouts, FMX.Gestures,
  FMX.Objects, Frame.Top, Frame.FullPopup.Coupon, Frame.FullPopupPayCard,
  Frame.FullPopup.Period, Frame.FullPopupQR, Frame.FullPopup.Print,
  Frame.FullPopup.SelectTime, CPort, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Platform.Win,
  Frame.AppCardList, System.ImageList, FMX.ImgList, uPaycoNewModul,
  Frame.PromotionList, FMX.Edit, Frame.FullPopup.QRSend;

type
  TFullPopup = class(TForm)
    TimerFull: TTimer;
    Layout: TLayout;
    Image: TImage;
    ContentLayout: TLayout;
    ImgSmall1: TImage;
    txtTime: TText;
    txtBiomini: TText;
    ImgBG50: TImage;
    ImgSmall: TImage;
    WhiteImage: TImage;
    txtTitle: TText;
    FullPopupCoupon1: TFullPopupCoupon;
    FullPopupPeriod1: TFullPopupPeriod;
    FullPopupPrint1: TFullPopupPrint;
    FullPopupQR1: TFullPopupQR;
    FullPopupSelectTime1: TFullPopupSelectTime;
    txtAddMember: TText;
    ImgBiomini: TImage;
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
    TopLayout: TLayout;
    Top1: TTop;
    MsgBGRectangle: TRectangle;
    MsgImage: TImage;
    TopRectangle: TRectangle;
    Text3: TText;
    MsgRectangle: TRectangle;
    Text: TText;
    Line1: TLine;
    ImgAddProduct: TImage;
    Rectangle1: TRectangle;
    ImgBG: TImage;
    ImgCancel: TImage;
    Text1: TText;
    Text2: TText;
    Image2: TImage;
    Text4: TText;
    ImgBG50Sub: TImage;
    ImgXGolfCancel: TImage;
    Text5: TText;
    ImageClose: TImage;
    Text6: TText;
    MemberNameRectangle: TRectangle;
    Rectangle3: TRectangle;
    Text8: TText;
    txtMemberName: TText;
    ImgPromoNumber: TImage;
    Text7: TText;
    ImgXGolfPhone: TImage;
    Text9: TText;
    FullPopupPayCard1: TFullPopupPayCard;
    FullPopupAppCardList1: TFullPopupAppCardList;
    ImageList: TImageList;
    AppCardImage: TImage;
    AppCardImageCancel: TImage;
    Text10: TText;
    FullPopupPrormotionList1: TFullPopupPrormotionList;
    Button1: TButton;
    Edit1: TEdit;
    FullPopupQRSend1: TFullPopupQRSend;
    txtCheckIn: TText;
    imgCreditCard: TImage;

    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);

    procedure TimerFullTimer(Sender: TObject);

    procedure BackImageClick(Sender: TObject);
    procedure ImageClick(Sender: TObject);
    procedure ContentLayoutClick(Sender: TObject);
    procedure CallImageClick(Sender: TObject);
    procedure HomeImageClick(Sender: TObject);
    procedure BottomRectangleClick(Sender: TObject);
    procedure ImgBiominiClick(Sender: TObject);
    procedure ImgAddProductClick(Sender: TObject);
    procedure ImgCancelClick(Sender: TObject);
    procedure ImgXGolfCancelClick(Sender: TObject);
    procedure ImgPromoNumberClick(Sender: TObject);
    procedure ImgXGolfPhoneClick(Sender: TObject);
    procedure AppCardImageCancelClick(Sender: TObject);
    procedure Top1RectangleClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    FPopUpFullLevel: TPopUpFullLevel;
    FCnt: Currency;
    FResultStr: string;
    FReadStr: string;
    FComport: TComport;

    FRFIDComport: TComport;
    FRFIDUse: Boolean; //RFID로 회원조회

    BarcodeIn: Boolean;
    UseScanner: Boolean;
    Work: Boolean;
    IsPayco: Boolean;

    FFingerRetry: Integer; // 재시도 횟수

    function BioMini_ErrorMsg(ACode: Integer; AStr: string = ''): string;
    procedure ComPortRxBuf(Sender: TObject; const Buffer; Count: Integer);
    procedure ComPortRxChar(Sender: TObject; Count: Integer);
    procedure RFIDComportRxChar(Sender: TObject; Count: Integer);

    procedure GetMemberInfo(ACode: string; AMember: TMemberInfo);
    procedure GetMemberCheckIn(ACode: string; AMember: TMemberInfo); //2021-08-04 checkin
    procedure GetRFIDMemberInfo(ACode: string);
    procedure GetRFIDMemberCheckIn(ACode: string);

    //2020-12-14 리프레쉬골프 상품표시
    procedure SetRefreshGolfProduct(ACode: string; AMember: TMemberInfo);

    function ApprovalAppCard(ABarcode: string): Boolean;
  public
    { Public declarations }
    procedure ShowFullPopup;
    procedure VisibleMsgBox;

    procedure ApplyCard(ABarcode: string = ''; AppCardDiscountUse: Boolean = False; ACallBinInfo: Boolean = False);
    procedure ApplyAppCard(AIndex: Integer; AText: string);
    procedure ApplyPromotion;
    procedure ApplyPayco;
    procedure InputPhoneNumber;
    procedure ResetTimerCnt;
    procedure StopTimer;

    procedure CloseFormStrMrok(AStr: string);
    procedure CloseFormStrMrCancel;
    procedure PrintCancel;

    procedure SetTimeText(ATime: Integer);

    procedure FormMessage(AShow: Boolean = True);

    property PopUpFullLevel: TPopUpFullLevel read FPopUpFullLevel write FPopUpFullLevel;
    property ResultStr: string read FResultStr write FResultStr;
    property Comport: TComport read FComport write FComport;

    //RFID
    property RFIDComport: TComport read FRFIDComport write FRFIDComport;
  end;

var
  FullPopup: TFullPopup;

implementation

uses
  uGlobal, uFunction, fx.Logging, uCommon, uSaleModule, Form.Select.Box, Form.Select_In.Box, Form.Sale.Product;

{$R *.fmx}

function StringToHex(const AValue: AnsiString): string;
begin
  SetLength(Result, Length(AValue) * 2);
  BinToHex(PAnsiChar(AValue), PChar(Result), Length(AValue));
end;

procedure TFullPopup.ApplyAppCard(AIndex: Integer; AText: string);
begin
  try
    StopTimer;
    ResetTimerCnt;
    ImgXGolfCancel.Visible := False;
    {$IFDEF RELEASE}
    TouchSound(False, True);
    BarcodeIn := False;

    if not Global.Config.NoDevice then
    begin
      if Global.Config.Scanner.Port <> 0 then
        ComPort.Open;
    end;
    {$ENDIF}

    if AText = 'PAYCO' then
    begin
      UseScanner := True;
//      IsPayco := True;
      AppCardImage.Visible := False;
      AppCardImageCancel.Visible := False;
      ApplyPayco;
    end
    else
    begin
      FullPopupAppCardList1.Visible := False;

      AppCardImage.MultiResBitmap.Bitmaps[1] := ImageList.Source[AIndex - 1].MultiResBitmap.Bitmaps[1];
      AppCardImage.Visible := True;
      if AText = '신한 터치결제' then
      begin
        Work := True;
        AppCardImageCancel.Visible := False;
        Global.SaleModule.CardApplyType := catMagnetic;
        ApplyCard('', False, True);
      end
      //else if AText = 'NH터치 결제' then 6:코나카드
      else if (AIndex = 5) or (AIndex = 6) then
      begin
        Work := True;
        AppCardImageCancel.Visible := False;
        Global.SaleModule.CardApplyType := catMagnetic;
        ApplyCard('', False, True);
      end
      else
      begin
        StopTimer;
        UseScanner := True;
        AppCardImageCancel.Visible := True;
      end;
    end;

  finally
  end;

end;

procedure TFullPopup.ApplyCard(ABarcode: string; AppCardDiscountUse: Boolean; ACallBinInfo: Boolean);
var
  ACardRecv: TCardRecvInfoDM;
  ACardBin, SendBinNo, ACode, AMsg: string;
  ADiscountAmt: Currency;
begin
  try
    ACardBin := EmptyStr;
    SendBinNo := EmptyStr;
    ACode := EmptyStr;
    AMsg := EmptyStr;
    ADiscountAmt := 0;

    StopTimer;
    ResetTimerCnt;

    //imgCreditCard.Visible := True;

    if (ABarcode = EmptyStr) and ACallBinInfo then
    begin
      ACardBin := Global.SaleModule.CallCardInfo;
      SendBinNo := ACardBin;
    end
    else if Length(ABarcode) >= 30 then
    begin
      ACardBin := ABarcode;
      SendBinNo := BCAppCardQrBinData(ACardBin);
    end
    else
    begin
      ACardBin := ABarcode;
      SendBinNo := ABarcode;
    end;

    //2021-06-16 파트너센터 카드사 할인여부 확인... 간편결제
    if Global.Config.AppCard = True then
    begin
      SetWindowPos(WindowHandleToPlatform(FullPopup.Handle).Wnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);

      if (SendBinNo <> EmptyStr) and (Length(SendBinNo) < 30) then
        ADiscountAmt := Global.Database.SearchCardDiscount(SendBinNo, CurrToStr(Global.SaleModule.RealAmt), Global.SaleModule.BuyProductList[0].Products.Product_Div, ACode, AMsg);
    end;

    SetWindowPos(WindowHandleToPlatform(FullPopup.Handle).Wnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);

    ACardRecv := Global.SaleModule.CallCard(ACardBin, ACode, AMsg, ADiscountAmt, AppCardDiscountUse);

    if not ACardRecv.Result then
    begin
      Global.SBMessage.ShowMessageModalForm(ACardRecv.Msg);
      CloseFormStrMrCancel;
    end
    else
      CloseFormStrMrok('');
  finally
    imgCreditCard.Visible := False;

    Work := False;
  end;
end;

procedure TFullPopup.ApplyPayco;
var
  APayco: TPaycoNewRecvInfo;
begin
  try
    try
      if IsPayco then
        Exit;

      IsPayco := True;
      Log.D('ApplyPayco', 'Begin');

      if Global.SaleModule.BuyProductList.Count = 0 then
      begin
        Global.SBMessage.ShowMessageModalForm(MSG_ADD_PRODUCT);
        Exit;
      end;

      if Global.SaleModule.RealAmt = 0 then
      begin
        Global.SBMessage.ShowMessageModalForm(MSG_NOT_PAY_AMT);
        Exit;
      end;

      if Global.Config.NoPayModule then
      begin
        Global.SBMessage.ShowMessageModalForm('결제 가능한 장비가 없습니다.');
        Exit;
      end;

      APayco := Global.SaleModule.CallPayco;
      if not APayco.Result then
      begin
        SaleProduct.ErrorMsg := APayco.Msg;
        ModalResult := mrCancel;
      end
      else
      begin
        ModalResult := mrOk;
      end;
    except
      on E: Exception do
        Log.E('ApplyPayco', E.Message);
    end;
  finally
    Log.D('ApplyPayco', 'End');
    IsPayco := False;
  end;
end;

procedure TFullPopup.ApplyPromotion;
begin
  ShowFullPopup;
end;

function TFullPopup.ApprovalAppCard(ABarcode: string): Boolean;
begin
  try
    Result := False;
    Log.D('ApprovalAppCard Barcode', ABarcode);
    ApplyCard(ABarcode, True, False);
  finally
  end;
end;

procedure TFullPopup.BackImageClick(Sender: TObject);
begin
  TouchSound;
  ResetTimerCnt;
  if TimerFull.Enabled then
    StopTimer;

  ModalResult := mrCancel;
end;

function TFullPopup.BioMini_ErrorMsg(ACode: Integer; AStr: string): string;
begin
  if ACode = 0 then
  begin
    if AStr = 'UFS_CaptureSingleImage' then
      Result := '지문을 인식하지 못하였습니다.'
    else if AStr = 'UFM_Verify' then
      Result := '일치하는 지문이 없습니다.'
    else
      Result := '오류!!';
  end
  else
  begin
    if ACode = -1 then
      Result := 'UFS_ClearCaptureImageBuffer'
    else if ACode = -2 then
      Result := 'UFS_CaptureSingleImage'
    else if ACode = -3 then
      Result := 'UFS_Extract'
    else if ACode = -4 then
      Result := 'UFM_Create'
    else
      Result := 'UFM_Verify';

    Result := '지문인식에 실패하였습니다.' + #13#10 + Result;
  end;
end;

procedure TFullPopup.BottomRectangleClick(Sender: TObject);
begin
  TouchSound;
end;

procedure TFullPopup.Button1Click(Sender: TObject);
begin
  if Global.SaleModule.WellbeingClub(False, Edit1.Text) then
    Global.SBMessage.ShowMessageModalForm('성공', True)
  else
    Global.SBMessage.ShowMessageModalForm('실패', True);
end;

procedure TFullPopup.CallImageClick(Sender: TObject);
begin
//  TouchSound;
  try
    ResetTimerCnt;
    TimerFull.Enabled := False;
    Global.SaleModule.CallAdmin;
  finally
    TimerFull.Enabled := True;
  end;
end;
procedure TFullPopup.CloseFormStrMrCancel;
begin
  ModalResult := mrCancel;
end;

procedure TFullPopup.CloseFormStrMrok(AStr: string);
begin
  ResultStr := AStr;
  if AStr = 'SALE' then
    ModalResult := mrTryAgain
  else
    ModalResult := mrOk;
end;

procedure TFullPopup.ComPortRxBuf(Sender: TObject; const Buffer;
  Count: Integer);
begin

end;

procedure TFullPopup.ComPortRxChar(Sender: TObject; Count: Integer);
var
  TempBuff, sMsg: string;
  AMember: TMemberInfo;
  ADiscount: TDiscount;
begin
  try

    if BarcodeIn or (PopUpFullLevel = pflPeriod) or (not UseScanner) then
      Exit;

    Comport.ReadStr(TempBuff, Count);

    FReadStr := FReadStr + TempBuff;
    Log.D('Scan begin', FReadStr);

    if Global.Config.Print.PrintType = 'EPSON' then //스캐너 구분위해
    begin
      if Copy(FReadStr, Length(FReadStr), 1) <> #$A then
        Exit;

      FReadStr := StringReplace(FReadStr, #$D#$A, '', [rfReplaceAll]);
    end
    else
    begin
      if Copy(FReadStr, Length(FReadStr), 1) <> #$D then
        Exit;

      FReadStr := StringReplace(FReadStr, #$D, '', [rfReplaceAll]);
    end;

    FCnt := 0;
    BarcodeIn := True;
    UseScanner := False;

    Log.D('Scan Barcode', FReadStr);
    if Global.SaleModule.PromotionType = pttWellbeing then
    begin

      if Global.SaleModule.WellbeingClub(True, FReadStr) then
      begin
        ModalResult := mrOk;
      end
      else
        ModalResult := mrCancel;

    end
    else if Global.SaleModule.PromotionType = pttBCPaybookGolf then //bc페이북골프
    begin
      Log.D('Scan begin', 'bc페이북골프');
      if Global.Database.SearchPromotion(FReadStr) then
      begin
        Global.SaleModule.Calc;
        ModalResult := mrOk;
      end
      else
        ModalResult := mrCancel;
      Exit;
    end
    else if Global.SaleModule.PromotionType = pttTheLoungeMembers then //더라운지멤버스
    begin
      Log.D('Scan begin', '우리카드 더라운지멤버스');
      if Global.SaleModule.TheLoungeMembers(FReadStr) then
        ModalResult := mrOk
      else
        ModalResult := mrCancel;
    end
    else if Global.SaleModule.PromotionType = pttRefreshclub then //리프레쉬클럽
    begin
      Log.D('Scan begin', '리프레쉬클럽');
      if Global.SaleModule.ApplyRefreshClub(FReadStr) then
        ModalResult := mrOk
      else
        ModalResult := mrCancel;
    end
    else if Global.SaleModule.PromotionType = pttIkozen then //아이코젠
    begin
      Log.D('Scan begin', '아이코젠');
      if Global.SaleModule.ApplyIKozen(FReadStr) then
        ModalResult := mrOk
      else
        ModalResult := mrCancel;
    end
    else if Global.SaleModule.PromotionType = pttSmartix then // 스마틱스
    begin
      Log.D('Scan begin', '스마틱스');
      if Global.SaleModule.ApplySmartix(True, FReadStr, sMsg) then  //   sRmsTkttypId    AProduct.Alliance_Item_Code
        ModalResult := mrOk
      else
      begin
        if sMsg <> '' then
          Global.SBMessage.ShowMessageModalForm(sMsg)
        else
          Global.SBMessage.ShowMessageModalForm('등록되지 않은 티켓번호 입니다.');
        ModalResult := mrCancel;
      end;
    end
    else if Global.SaleModule.CardApplyType <> catNone then
    begin
      if IsPayco then
        Global.SaleModule.PaycoModule.SetBarcode(FReadStr)
      else
        ApprovalAppCard(FReadStr);
    end
    else if PopUpFullLevel = pflPromo then
    begin
      if (Global.Config.Store.StoreCode = 'A8001') then
      begin
        if (FReadStr = 'C-5df2d5d8-8976-4ef5-957f-702a66147dda') or
           (FReadStr = 'C-5040bb31-4853-4fd9-aad8-7b9591e294fc') then
        begin
          Global.SBMessage.ShowMessageModalForm('해당 쿠폰은 사용횟수가 초과되어' +#13#10 +'이용이 불가합니다.' +#13#10 + '감사합니다');
          ModalResult := mrCancel;
          Exit;
        end;
      end;

      if Global.Database.SearchPromotion(FReadStr) then
        ModalResult := mrOk
      else
        ModalResult := mrCancel;

      Exit;
    end
    //else if PopUpFullLevel in [pflQR, pflCheckInQR] then
    else if PopUpFullLevel in [pflQR] then
    begin
      Log.D('Scan QR', FReadStr);

      FReadStr := StringReplace(Trim(FReadStr), XGOLF_REPLACE_STR, '', [rfReplaceAll]);
      FReadStr := StringReplace(Trim(FReadStr), XGOLF_REPLACE_STR2, '', [rfReplaceAll]);
      FReadStr := StringReplace(Trim(FReadStr), XGOLF_REPLACE_STR3, '', [rfReplaceAll]);

      VisibleMsgBox;
      Application.ProcessMessages;

      if (Copy(FReadStr, 1, 2) = 'M-') or (Copy(FReadStr, 1, 2) = 'C-') then
      begin
        Global.SBMessage.ShowMessageModalForm(MSG_XGOLF_QR_NOT, True, 10);
        Exit;
      end;

      //if Global.SaleModule.CheckXGolfMember(FReadStr) then // 2023-05-11 변경
      if Global.SaleModule.CheckXGolfMemberChk('QR', FReadStr) then
      begin

        if PopUpFullLevel = pflCheckInFinger then
        begin
          GetMemberCheckIn(FReadStr, Global.SaleModule.Member);
        end
        else
        begin
          // 윅스넷에 M030 API 추가 해야됨
          if Global.SaleModule.Member.Code <> EmptyStr then
          begin
            AMember := Global.SaleModule.Member;
            if Global.SBMessage.ShowMessageModalForm(MSG_XGOLF_ADD_MEMBER, False) then
              Global.Database.AddMemberXGOLFQR(FReadStr);
          end;

          AMember.XGolfMember := True;
          AMember.XGolfMemberQR := FReadStr;
          Global.SaleModule.Member := AMember;
          ModalResult := mrOk;
        end;

      end
      else
      begin
        Global.SBMessage.ShowMessageModalForm('XGOLF 회원조회에 실패 하였습니다.');
      end;
      VisibleMsgBox;

    end
    else if PopUpFullLevel = pflCheckInQR then
    begin
      GetMemberCheckIn(FReadStr, Global.SaleModule.Member);
    end
    else if PopUpFullLevel = pflTeeboxMove then // move
    begin

      if Copy(FReadStr, 1, 8) < FormatDateTime('YYYYMMDD', now) then
      begin
        Global.SBMessage.ShowMessageModalForm(MSG_TEEBOX_MOVE_BARCODE_NOT, True, 10);
        ModalResult := mrCancel;
        Exit;
      end;

      Global.SaleModule.TeeBoxMoveInfo := Global.LocalApi.GetTeeBoxReserveInfo(FReadStr);

      if (Global.SaleModule.TeeBoxMoveInfo.UseStatus <> '1') and
         (Global.SaleModule.TeeBoxMoveInfo.UseStatus <> '4') then
      begin
        Global.SBMessage.ShowMessageModalForm(MSG_TEEBOX_MOVE_BARCODE_NOT_2, True, 10);
        ModalResult := mrCancel;
        Exit;
      end;

      //다음타석 존재여부 확인
      if Global.LocalApi.GetTeeBoxNextReserveInfo(Global.SaleModule.TeeBoxMoveInfo) = True then
      begin
        Global.SBMessage.ShowMessageModalForm(MSG_TEEBOX_MOVE_BARCODE_NOT_3, True, 10);
        ModalResult := mrCancel;
        Exit;
      end;

      Global.SaleModule.VipTeeBoxMove := Global.SaleModule.TeeBoxMoveInfo.Vip;
      if Global.SaleModule.TeeBoxMoveInfo.TasukNo <> 0 then
        ModalResult := mrOk
      else
        ModalResult := mrCancel;
      Exit;
    end
    else
    begin
      if (Copy(FReadStr, 1, 2) = 'R-') then //OTP QR코드
      begin
        AMember := Global.Database.GetMemberOptQR(FReadStr);

        if AMember.Code = '0000' then //0000 회원정보 없음
        begin
          Global.SBMessage.ShowMessageModalForm('회원조회에 실패 하였습니다.');
        end
        else
        begin
          GetMemberInfo(EmptyStr, AMember);
        end;
      end
      else
        GetMemberInfo(FReadStr, AMember); //쿠폰회원
    end;

    FReadStr := EmptyStr;
    BarcodeIn := False;

  finally
    FCnt := 0;
  end;
end;

procedure TFullPopup.RFIDComPortRxChar(Sender: TObject; Count: Integer);
var
  TempBuff: String;
  AMember: TMemberInfo;
  ADiscount: TDiscount;

  //PM: TPluginMessage;
  sBuffer: AnsiString;
  sReadData: string;
  nBuffer: Integer;

begin
  try

    if (PopUpFullLevel <> pflPeriod) and
       (PopUpFullLevel <> pflCheckInFinger) and
       (PopUpFullLevel <> pflBunkerMember) then
      Exit;

    if BarcodeIn = True then
      Exit;

    SetLength(sBuffer, Count);
    RFIDComport.Read(sBuffer[1], Count);

    nBuffer := Length(sBuffer);
    if (nBuffer = 0) then
      Exit;

    //Log.D('Scan begin', FReadStr);
    if (sBuffer[nBuffer] = Chr($0d)) then //_CR
    begin
      sReadData := StringToHex(Copy(sBuffer, 1, Pred(nBuffer)));
      Log.D('Scan RFIDComPort: ', sReadData);

      if (Length(sReadData) = 8) then //ex) 2C35E3C1, 227C3B3F
      begin
        FCnt := 0;
        BarcodeIn := True;
        //UseScanner := False;
        FRFIDUse := True;

        //1080 * 1920 540 1105
        //SetCursorPos(270, 620); //마우스 커서가 가야 할 버튼의 위치
        SetCursorPos(540, 1105); //마우스 커서가 가야 할 버튼의 위치
        Mouse_Event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
        Mouse_Event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);

        if PopUpFullLevel = pflCheckInFinger then
          GetRFIDMemberCheckIn(sReadData)
        else
          GetRFIDMemberInfo(sReadData);

        //FReadStr := EmptyStr;
        BarcodeIn := False;
      end;
    end;

  finally
    FCnt := 0;
  end;
end;

procedure TFullPopup.ContentLayoutClick(Sender: TObject);
begin
  TouchSound;
end;

procedure TFullPopup.FormCreate(Sender: TObject);
begin
  try
    Comport := TComPort.Create(nil);
    RFIDComport := TComPort.Create(nil);

    if not Global.Config.NoDevice then
    begin
      if Global.Config.Scanner.Port <> 0 then
      begin
        Comport.Port := 'COM' + IntToStr(Global.Config.Scanner.Port);

        //chy bc페이북골프
        //Comport.BaudRate := br115200; -> 트로스
        //Comport.BaudRate := br9600; -> 씨아이테크
        if Global.Config.Scanner.BaudRate = 9600 then
          Comport.BaudRate := br9600
        else if Global.Config.Scanner.BaudRate = 115200 then
          Comport.BaudRate := br115200
        else
          Comport.BaudRate := br115200;

        Comport.OnRxChar := ComPortRxChar;
      end;

      if Global.Config.RFID.Port <> 0 then
      begin
        RFIDComport.Port := 'COM' + IntToStr(Global.Config.RFID.Port);
        //RFIDComport.BaudRate := br115200;
        if Global.Config.RFID.BaudRate = 9600 then
          RFIDComport.BaudRate := br9600
        else if Global.Config.RFID.BaudRate = 115200 then
          RFIDComport.BaudRate := br115200
        else
          RFIDComport.BaudRate := br115200;
        RFIDComport.OnRxChar := RFIDComportRxChar;
      end;

    end;
    BarcodeIn := False;
    UseScanner := False;
    IsPayco := False;

    //chy 2020-11-04 지문인식기 retry 횟수 5회
    FFingerRetry := 0;

    FRFIDUse := False;
  except
    on E: Exception do
    begin //페이북
      Log.E('TFullPopup.FormCreate', E.Message);
      Global.SBMessage.ShowMessageModalForm(E.Message);
    end;
  end;
end;

procedure TFullPopup.FormDestroy(Sender: TObject);
begin
  try
//    BioThread.Free;
    if Comport <> nil then
    begin
      if Comport.Connected then
        Comport.Close;
      Comport.Free;
    end;

    //RFID
    if RFIDComport <> nil then
    begin
      if RFIDComport.Connected then
        RFIDComport.Close;
      RFIDComport.Free;
    end;

//  if PopUpFullLevel = pflPeriod then
//  begin  // FullPopupPeriod1
//    BioMiniPlus2.Free;
//  end;
   FullPopupCoupon1.CloseFrame;
   FullPopupCoupon1.Free;
   FullPopupPayCard1.Free;
   FullPopupPeriod1.Free;
   FullPopupPrint1.Free;
   FullPopupQR1.Free;
   FullPopupSelectTime1.Free;
   DeleteChildren;
  except
    on E: Exception do
    begin
//      Global.SBMessage.ShowMessageModalForm('FormDestroy : ' + E.Message);
    end;
  end;
end;

procedure TFullPopup.FormKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  //FReadStr := FReadStr + KeyChar;
  //Global.SBMessage.ShowMessageModalForm(FReadStr);

  if Key = vkReturn then
  begin
    Global.SBMessage.ShowMessageModalForm(FReadStr);
    FReadStr := EmptyStr;
  end;
end;

procedure TFullPopup.FormMessage(AShow: Boolean);
begin
  Application.ProcessMessages;
  if AShow then
  begin
    MsgBGRectangle.Visible := True;
    Text.Text := '잠시만 기다려 주시기 바랍니다.';
  end
  else
  begin
    MsgBGRectangle.Visible := False;
    Text.Text := EmptyStr;
  end;
end;

procedure TFullPopup.FormShow(Sender: TObject);
begin
  try
    Log.D('TFullPopup.FormShow', 'Begin');
    FCnt := 0;
    PopUpFullLevel := Global.SaleModule.PopUpFullLevel;
    ShowFullPopup;
    Work := False;
    TimerFull.Enabled := True;

    if PopUpFullLevel = pflPayCard then
    begin
      //if (Global.Config.Store.StoreCode = 'C1001') and (Global.SaleModule.memberItemType = mitGamePay) then //코리아하이파이브스포츠클럽
      if Global.SaleModule.PaymentAddType = patGamePay then //코리아하이파이브스포츠클럽
      begin
        FullPopupPayCard1.txtTasukInfo.Text := '';
        FullPopupPayCard1.Text4.Visible := False;
      end;

      FullPopupPayCard1.DisPlay;
    end;
    Text.Text := '회원 정보를 확인중 입니다.' + #13#10 + '잠시만 기다려 주시기바랍니다.';

    Top1.lblDay.Text := Global.SaleModule.NowHour;
    Top1.lblTime.Text := Global.SaleModule.NowTime;

    Log.D('TFullPopup.FormShow', 'End');
  except
    on E: Exception do
    begin
      Log.E('TFullPopup.FormShow', E.Message);
    end;
  end;
end;

procedure TFullPopup.GetMemberInfo(ACode: string; AMember: TMemberInfo);
begin
  try
    try

      //chy test 회원
      //AMember.Code := 'T0001000000001';
      //AMember.Name := '조한용';

      if ACode = EmptyStr then
        Global.SaleModule.Member := AMember
      else
        Global.SaleModule.Member := Global.SaleModule.SearchMember(ACode);

      if Global.SaleModule.Member.Code = EmptyStr then
      begin
        Global.SBMessage.ShowMessageModalForm(MSG_NOT_MEMBER_SEARCH);

        ModalResult := mrCancel;
        Exit;
      end;

      if Global.SaleModule.PopUpFullLevel = pflBunkerMember then //벙커/퍼팅
      begin
        ModalResult := mrOk;
        Exit;
      end;

      //광고 추가 구좌-추천회원권
      if Global.SaleModule.AdvertPopupType = apMember then
      begin
        ModalResult := mrTryAgain;
        Exit;
      end;

      //시설이용권 회원인증
      if (Global.Config.StoreType = '1') and (Global.SaleModule.PaymentAddType = patFacilityPeriod) then
      begin
        ModalResult := mrOk;
        Exit;
      end;

      if (Global.Config.StoreType = '0') and (Global.SaleModule.PaymentAddType = patFacilityPeriod) then
      begin
        Global.SaleModule.ProductList := Global.Database.GetMemberFacilityProductList(Global.SaleModule.Member.Code, '', '');
        if Global.SaleModule.ProductList.Count = 0 then
        begin
          Global.SBMessage.ShowMessageModalForm(MSG_MEMBER_USE_NOT_PRODUCT);
          ModalResult := mrCancel;

          Exit;
        end;
      end
      else
      begin
        Global.SaleModule.ProductList := Global.Database.GetMemberProductList(Global.SaleModule.Member.Code, '', '');
        if Global.SaleModule.ProductList.Count = 0 then
        begin
          if Global.SBMessage.ShowMessageModalForm(MSG_MEMBER_USE_NOT_PRODUCT + #13#10 + MSG_IS_PRODUCT_BUY, False) then
            ModalResult := mrTryAgain
          else
            ModalResult := mrCancel;

          Exit;
        end;
      end;

      txtTitle.Text := '회원권 선택하기';
      txtAddMember.Visible := False;
      //ImageLeft.Visible := True;
      //ImageRight.Visible := True;
      BackRectangle.Visible := True;
      CallRectangle.Visible := True;
      HomeRectangle.Visible := True;
      txtBiomini.Visible := False;
      ImgBiomini.Visible := False;
      FullPopupPeriod1.Visible := False;
      FullPopupCoupon1.Visible := True;
      FullPopupCoupon1.Layout.Visible := False;
      FullPopupCoupon1.ActivePage := 1;
      FullPopupCoupon1.Display;

      if (Global.Config.StoreType = '0') and (Global.SaleModule.PaymentAddType = patFacilityPeriod) then
        ImgAddProduct.Visible := False
      else
        ImgAddProduct.Visible := True;

      ImgCancel.Position.Y := 1060;
      ImgBG.Visible := False;
      ImgBG50.Visible := True;
      ImgBG50Sub.Visible := True;
      ImgCancel.Visible := True;
      //ImageClose.Visible := False;
      txtMemberName.Text := Global.SaleModule.Member.Name;
      UseScanner := False;

    except
      on E: Exception do
        Log.E('TFullPopup.GetMemberInfo', E.Message);
    end;
  finally
  end;
end;

procedure TFullPopup.GetRFIDMemberInfo(ACode: string);
begin
  try
    try
      Global.SaleModule.Member := Global.SaleModule.SearchRFIDMember(ACode);

      if Global.SaleModule.PopUpFullLevel = pflBunkerMember then //벙커/퍼팅
      begin
        ModalResult := mrOk;
        Exit;
      end;

      if Global.SaleModule.Member.Code = EmptyStr then
      begin
        Global.SBMessage.ShowMessageModalForm(MSG_NOT_MEMBER_SEARCH);

        ModalResult := mrCancel;
        Exit;
      end;

      Global.SaleModule.ProductList := Global.Database.GetMemberProductList(Global.SaleModule.Member.Code, '', '');
      if Global.SaleModule.ProductList.Count = 0 then
      begin
        if Global.SBMessage.ShowMessageModalForm(MSG_MEMBER_USE_NOT_PRODUCT + #13#10 + MSG_IS_PRODUCT_BUY, False) then
          ModalResult := mrTryAgain
        else
          ModalResult := mrCancel;
      end
      else
      begin
        txtTitle.Text := '회원권 선택하기';
        txtAddMember.Visible := False;
        BackRectangle.Visible := True;
        CallRectangle.Visible := True;
        HomeRectangle.Visible := True;
        txtBiomini.Visible := False;
        ImgBiomini.Visible := False;
        FullPopupPeriod1.Visible := False;
        FullPopupCoupon1.Visible := True;
        FullPopupCoupon1.Layout.Visible := False;
        FullPopupCoupon1.ActivePage := 1;
        FullPopupCoupon1.Display;
        ImgAddProduct.Visible := True;
        ImgCancel.Position.Y := 1060;
        ImgBG.Visible := False;
        ImgBG50.Visible := True;
        ImgBG50Sub.Visible := True;
        ImgCancel.Visible := True;
        txtMemberName.Text := Global.SaleModule.Member.Name;
        UseScanner := False;
      end;
    except
      on E: Exception do
        Log.E('TFullPopup.GetRFIDMemberInfo', E.Message);
    end;
  finally
  end;
end;

procedure TFullPopup.HomeImageClick(Sender: TObject);
begin
  TouchSound;
  ResetTimerCnt;
  if TimerFull.Enabled then
    StopTimer;

  ModalResult := mrIgnore;
end;

procedure TFullPopup.AppCardImageCancelClick(Sender: TObject);
begin
  CloseFormStrMrCancel;
end;

procedure TFullPopup.ImageClick(Sender: TObject);
begin
  TouchSound;
end;

procedure TFullPopup.ImgAddProductClick(Sender: TObject);
begin
  TouchSound;
  ModalResult := mrTryAgain;
end;

procedure TFullPopup.ImgBiominiClick(Sender: TObject);
begin
  FullPopupQR1.Visible := False;
  FullPopupCoupon1.Visible := False;
  ImgBiomini.Visible := False;
  txtTime.Visible := False;

  if PopUpFullLevel = pflCheckInQR then
    PopUpFullLevel := pflCheckInFinger
  else
    PopUpFullLevel := pflPeriod;

  ShowFullPopup;
end;

procedure TFullPopup.ImgCancelClick(Sender: TObject);
begin
  CloseFormStrMrCancel;
end;

procedure TFullPopup.ImgPromoNumberClick(Sender: TObject);
begin
  Global.SaleModule.PopUpLevel := plPromotionCode;
  if ShowPopup('ImgPromoNumberClick/plPromotionCode') then
    ModalResult := mrOk
  else
    ModalResult := mrCancel;
end;

procedure TFullPopup.ImgXGolfCancelClick(Sender: TObject);
begin
  CloseFormStrMrCancel;
end;

procedure TFullPopup.ImgXGolfPhoneClick(Sender: TObject);
begin
  Global.SaleModule.PopUpLevel := plPhone;
  if ShowPopup('ImgXGolfPhoneClick/plPhone') then
    ModalResult := mrOk
  else
    ModalResult := mrCancel;
end;

procedure TFullPopup.InputPhoneNumber;
begin
//
end;

procedure TFullPopup.PrintCancel;
begin
  try
    TimerFull.Enabled := False;
    { 2023-03-22 이종섭차장-영수증,DB캐더링 광고 이후 시간 지체후 카드 알림음 제외처리
    if Global.SaleModule.GetSumPayAmt(ptCard) <> 0 then
    begin
      Global.SaleModule.SoundThread.SoundList.Add(ExtractFilePath(Application.GetNamePath) + 'CardOut.wav');
      Global.SaleModule.SoundThread.SoundList.Add(ExtractFilePath(Application.GetNamePath) + 'CardOut.wav');
      Global.SaleModule.SoundThread.Resume;
      Global.SBMessage.ShowMessageModalForm(MSG_COMPLETE_CARD, True, 10, False);
    end;
    }
    CloseFormStrMrCancel;
  except
    on E: Exception do
      Log.E('PrintCancel', E.Message);
  end;
end;

procedure TFullPopup.ResetTimerCnt;
begin
  FCnt := 0;
end;

procedure TFullPopup.SetTimeText(ATime: Integer);
begin
  FullPopupSelectTime1.SetText(ATime);
end;

procedure TFullPopup.ShowFullPopup;
var
  AMemberTm: TMemberInfo; //쿠폰회원 테스트용-주석처리 필수
  bEventChk: Boolean;
begin
  try
    Log.D('TFullPopup.ShowFullPopup', 'Begin');
    if not (PopUpFullLevel in [pflPeriod]) then
      txtTime.Visible := True;

    Top1.lblDay.Text := FormatDateTime('yyyy-mm-dd', now);
    Top1.lblTime.Text := FormatDateTime('hh:nn', now);

    if Global.SaleModule.PromotionType <> pttNone then
    begin
      if Global.SaleModule.PromotionType = pttSelect then
      begin
        ImgXGolfCancel.Visible := True;
        txtTitle.Text := '제휴사 선택';
        FullPopupPrormotionList1.Visible := True;
        FullPopupPrormotionList1.Display;
      end
      else
      begin
        if not Global.Config.NoDevice then
        begin
          if Global.Config.Scanner.Port <> 0 then
            Comport.Open;
        end;

        BarcodeIn := False;
        Work := False;
        UseScanner := True;
        FullPopupPrormotionList1.Visible := False;
        FullPopupCoupon1.Visible := True;

        if Global.SaleModule.PromotionType = pttWellbeing then
        begin

          if Global.SaleModule.memberItemType = mitAlliance then
          begin
            ImgXGolfCancel.Visible := True;
            txtTitle.Text := '제휴사 선택';
          end;

          FullPopupCoupon1.Image.Visible := False;
          FullPopupCoupon1.ImageWellbeing.Visible := True;
          FullPopupCoupon1.ImageBCPaybook.Visible := False;

          FullPopupCoupon1.Text1.Text := '웰빙클럽 바코드를 스캔해주세요.';
        end
        else if Global.SaleModule.PromotionType = pttBCPaybookGolf then
        begin
          FullPopupCoupon1.Image.Visible := False;
          FullPopupCoupon1.ImageWellbeing.Visible := False;
          FullPopupCoupon1.ImageBCPaybook.Visible := True;

          FullPopupCoupon1.Text1.Text := 'BC페이북 바코드를 스캔해주세요.';
        end
        else if (Global.SaleModule.PromotionType = pttTheLoungeMembers) or
                (Global.SaleModule.PromotionType = pttRefreshclub) or
                (Global.SaleModule.PromotionType = pttIkozen) or
                (Global.SaleModule.PromotionType = pttSmartix) then
        begin
          FullPopupCoupon1.Image.Visible := False;
          FullPopupCoupon1.ImageWellbeing.Visible := True;
          FullPopupCoupon1.ImageBCPaybook.Visible := False;

          if Global.SaleModule.PromotionType = pttTheLoungeMembers then
            FullPopupCoupon1.Text1.Text := '더라운지멤버스 바코드를 스캔해주세요.';

          if Global.SaleModule.PromotionType = pttRefreshclub then
            FullPopupCoupon1.Text1.Text := '리프레쉬클럽 바코드를 스캔해주세요.';

          if Global.SaleModule.PromotionType = pttIkozen then
            FullPopupCoupon1.Text1.Text := '아이코젠 바코드를 스캔해주세요.';

          if Global.SaleModule.PromotionType = pttSmartix then
          begin
            // 선택 화면이 없어서 버튼/타이틀 재설정
            ImgXGolfCancel.Visible := True;
            txtTitle.Text := '온라인 티켓 인증';
            FullPopupCoupon1.Text1.Text := 'QR코드를 아래 스캐너에 인식시켜 주세요.';
          end;
        end
        else
        begin
          ImgXGolfCancel.Visible := False;

          txtTitle.Text := '프로모션 인증';
          ImgCancel.Visible := True;
          ImgPromoNumber.Visible := True;

          FullPopupCoupon1.Image.Visible := True;
          FullPopupCoupon1.ImageWellbeing.Visible := False;
          FullPopupCoupon1.ImageBCPaybook.Visible := False;

          FullPopupCoupon1.Text1.Text := 'QR코드를 아래 스캐너에 인식시켜 주세요.';
        end;

        FullPopupCoupon1.txtTasukInfo.Text := Global.SaleModule.TeeBoxInfo.FloorNm + ' ' + Global.SaleModule.TeeBoxInfo.Mno + '번';
        if Global.SaleModule.TeeBoxInfo.ZoneCode = 'O' then
          FullPopupCoupon1.txtTasukInfo.Text := FullPopupCoupon1.txtTasukInfo.Text + ' (좌타)';

      end;
      AppCardImageCancel.Visible := True;
    end
    else if Global.SaleModule.CardApplyType = catAppCard then
    begin
      ImgXGolfCancel.Visible := True;
      txtTitle.Text := '간편결제 선택';
      FullPopupAppCardList1.Visible := True;
      FullPopupAppCardList1.Display;
      if not Global.Config.NoDevice then
      begin
        if Global.Config.Scanner.Port <> 0 then
          Comport.Open;
      end;
      AppCardImageCancel.Visible := True;
    end
    else if PopUpFullLevel = pflProduct then
    begin
  //    ImageLeft.Visible := True;
  //    ImageRight.Visible := True;
      ImgBG.Visible := False;
      ImgBG50.Visible := True;
      ImgBG50Sub.Visible := True;
      FullPopupCoupon1.Visible := True;
      FullPopupCoupon1.Layout.Visible := False;
      FullPopupCoupon1.Display;
      ImgCancel.Visible := True;
      ImgAddProduct.Visible := True;
      ImgCancel.Position.Y := 1060;
    end
    else if PopUpFullLevel in [pflCoupon, pflPromo] then
    begin

      if not Global.Config.NoDevice then
      begin
        if Global.Config.Scanner.Port <> 0 then
          Comport.Open;
      end;

      if PopUpFullLevel = pflPromo then
      begin
        txtTitle.Text := '프로모션 인증';
        //ImageClose.Visible := True;      // 원버튼 취소가 아닌 번호로 입력하게끔
        ImgCancel.Visible := True;
        ImgPromoNumber.Visible := True;
      end
      else
      begin
        txtTitle.Text := '회원 인증';

        if (Global.Config.FingerprintUse = 'Y') or (Global.Config.FingerprintQRUse = 'Y') then
          ImgBiomini.Visible := True;

        ImgCancel.Visible := True;
      end;

      if (Global.SaleModule.PaymentAddType <> patNone) then
      begin
        FullPopupCoupon1.txtTasukInfo.Text := '';
        FullPopupCoupon1.Text4.Visible := False;
      end
      else
      begin
        FullPopupCoupon1.txtTasukInfo.Text := Global.SaleModule.TeeBoxInfo.FloorNm + ' ' + Global.SaleModule.TeeBoxInfo.Mno + '번';
        if Global.SaleModule.TeeBoxInfo.ZoneCode = 'O' then
          FullPopupCoupon1.txtTasukInfo.Text := FullPopupCoupon1.txtTasukInfo.Text + ' (좌타)';
      end;
      FullPopupCoupon1.Visible := True;
      UseScanner := True;
    end
    else if PopUpFullLevel = pflPayCard then
    begin  // FullPopupPayCard1
      txtTitle.Text := '신용카드 결제';

      //if (Global.Config.Store.StoreCode = 'C1001') and (Global.SaleModule.PaymentAddType = patGamePay) then //코리아하이파이브스포츠클럽
      if (Global.SaleModule.PaymentAddType <> patNone) then
      begin
        FullPopupPayCard1.txtTasukInfo.Text := '';
        FullPopupPayCard1.Text4.Visible := False;
      end
      else
      begin
        FullPopupPayCard1.txtTasukInfo.Text := Global.SaleModule.TeeBoxInfo.FloorNm + ' ' + Global.SaleModule.TeeBoxInfo.Mno + '번';
        if Global.SaleModule.TeeBoxInfo.ZoneCode = 'O' then
          FullPopupPayCard1.txtTasukInfo.Text := FullPopupPayCard1.txtTasukInfo.Text + ' (좌타)';
      end;
      FullPopupPayCard1.Visible := True;
      ImgBG.Visible := False;
      ImgSmall.Visible := True;
      ImgSmall1.Visible := True;
    end
    else if PopUpFullLevel in [pflPrint, pflTeeBoxPrint] then
    begin

      //if (Global.Config.Store.StoreCode = 'C1001') and (Global.SaleModule.PaymentAddType = patGamePay) then //코리아하이파이브스포츠클럽
      if (Global.SaleModule.PaymentAddType <> patNone) then
      begin
        FullPopupPrint1.txtTasukInfo.Text := '시설 이용권';
        FullPopupPrint1.Text4.Visible := False;
      end
      else
      begin
        FullPopupPrint1.txtTasukInfo.Text := Global.SaleModule.TeeBoxInfo.FloorNm + ' ' + Global.SaleModule.TeeBoxInfo.Mno + '번';
        if Global.SaleModule.TeeBoxInfo.ZoneCode = 'O' then
          FullPopupPrint1.txtTasukInfo.Text := FullPopupPrint1.txtTasukInfo.Text + ' (좌타)';
      end;

      bEventChk := False;
      if PopUpFullLevel = pflTeeBoxPrint then
      begin
        FullPopupPrint1.Text.Text := '기기 하단의 프린터로 타석배정표가 출력되었습니다.';
        bEventChk := True;
      end
      else
      begin
        if (Global.SaleModule.PaymentAddType <> patNone) then
        begin
          if (Global.SaleModule.memberItemType in [mitNone, mitDay]) then
          begin
            txtTitle.Text := '결제 완료';

            if (Global.SaleModule.PaymentAddType = patFacilityPeriod) then
            begin
              FullPopupPrint1.Text1.Text := '입장QR은 카카오톡으로 자동 전송됩니다.';
            end;
          end
          else
          begin
            txtTitle.Text := '이용권 출력';
          end;
        end
        else
        begin
          if Global.SaleModule.SelectProduct.Code <> EmptyStr then
          begin
            FullPopupPrint1.Text.Text := '기기 하단의 프린터로 카드 영수증과';
            FullPopupPrint1.Text1.Text := '타석배정표가 출력되었습니다.';

            if (Global.SaleModule.memberItemType = mitDay) then
              bEventChk := True;
          end;
        end;
      end;

      if bEventChk = True then
      begin
        //영수증출력 광고(배정표) 당첨여부 확인 위해 출력전에 전송
        Global.SaleModule.AdvertReceiptView('PRINT');
      end;

      FullPopupPrint1.Visible := True;
      ImgBG.Visible := False;
      ImgSmall.Visible := True;
      ImgSmall1.Visible := True;

      if Global.SaleModule.Print.PrintThread <> nil then
      begin
        Global.SaleModule.Print.PrintThread.PrintList.Add(Global.SaleModule.SetPrintData);
        Global.SaleModule.Print.PrintThread.Resume;
      end;

      if bEventChk = True then
      begin
        TimerFull.Enabled := False;

        if Global.SaleModule.AdvertReceiptView('POPUP') = True then
        begin
          ShowAdvertReceipt;
        end;

        if Global.SaleModule.AdvertListEvent.Count > 0 then
        begin
          if ShowAdvertEvent = True then
          begin
            Global.SaleModule.AdvertPopupType := apEvent;
            Global.SaleModule.PopUpLevel := plPhone;
            ShowPopup('ShowFullPopup/plPhone');
          end;
        end;

        TimerFull.Enabled := True;
      end;

    end
    else if PopUpFullLevel = pflPeriod then
    begin

      if not Global.Config.NoDevice then
      begin
        if Global.Config.RFID.Port <> 0 then
          RFIDComport.Open;
      end;

      txtTitle.Text := '회원 인증';

      if Global.SaleModule.PaymentAddType = patFacilityPeriod then
      begin
        FullPopupPeriod1.txtTasukInfo.Text := '';
        FullPopupPeriod1.Text4.Text := '';
      end
      else
      begin
        FullPopupPeriod1.txtTasukInfo.Text := Global.SaleModule.TeeBoxInfo.FloorNm + ' ' + Global.SaleModule.TeeBoxInfo.Mno + '번';
        if Global.SaleModule.TeeBoxInfo.ZoneCode = 'O' then
          FullPopupPeriod1.txtTasukInfo.Text := FullPopupPeriod1.txtTasukInfo.Text + ' (좌타)';
      end;

      FullPopupPeriod1.Visible := True;

      //chy 2020-11-04 union 문구추가
      if Global.Config.Fingerprint = 'UNION' then
      begin
        FullPopupPeriod1.Rectangle5.Visible := True;
        FullPopupPeriod1.txtUnionMsg1.Visible := True;
        FullPopupPeriod1.txtUnionMsg2.Visible := True;
      end
      else
      begin
        FullPopupPeriod1.Rectangle5.Visible := False;
        FullPopupPeriod1.txtUnionMsg1.Visible := False;
        FullPopupPeriod1.txtUnionMsg2.Visible := False;
      end;

      BackRectangle.Visible := False;
      CallRectangle.Visible := False;
      HomeRectangle.Visible := False;
      txtBiomini.Visible := False;
      ImgBiomini.Visible := False;
      ImgCancel.Visible := False;
      ImageClose.Visible := False;
      if FCnt <> 0 then
        FCnt := 0;

    end
    else if PopUpFullLevel = pflQR then // FullPopupQR1
    begin
      if Global.Config.StoreType = '0' then
        SelectBox.ChangBottomImg
      else
        SelectBox_In.ChangBottomImg;

      if not Global.Config.NoDevice then
      begin
        if Global.Config.Scanner.Port <> 0 then
          Comport.Open;
      end;

      txtTitle.Text := 'XGOLF 회원 인증';

      FullPopupQR1.txtTasukInfo.Text := Global.SaleModule.TeeBoxInfo.FloorNm + ' ' + Global.SaleModule.TeeBoxInfo.Mno + '번';
      if Global.SaleModule.TeeBoxInfo.ZoneCode = 'O' then
        FullPopupQR1.txtTasukInfo.Text := FullPopupQR1.txtTasukInfo.Text + ' (좌타)';

      FullPopupQR1.Visible := True;
  //    ImgXGolfCancel.Visible := True;
      ImgCancel.Visible := True;
      ImgXGolfPhone.Visible := True;
      UseScanner := True;
    end
    else if PopUpFullLevel = pflBunkerMember then
    begin
      {
      if not Global.Config.NoDevice then
      begin
        if Global.Config.Scanner.Port <> 0 then
          Comport.Open;
      end;
      }
      if not Global.Config.NoDevice then
      begin
        if Global.Config.RFID.Port <> 0 then
          RFIDComport.Open;
      end;

      txtTitle.Text := '회원 인증';
      FullPopupPeriod1.txtTasukInfo.Text := '';

      FullPopupPeriod1.Visible := True;

      FullPopupPeriod1.Rectangle5.Visible := True;
      FullPopupPeriod1.txtUnionMsg2.Visible := True;

      BackRectangle.Visible := False;
      CallRectangle.Visible := False;
      HomeRectangle.Visible := False;
      txtBiomini.Visible := False;
      ImgBiomini.Visible := False;
      ImgCancel.Visible := False;
      ImageClose.Visible := False;
      if FCnt <> 0 then
        FCnt := 0;

    end
    //chy move
    else if PopUpFullLevel = pflTeeboxMove then
    begin

      if not Global.Config.NoDevice then
      begin
        if Global.Config.Scanner.Port <> 0 then
          Comport.Open;
      end;

      txtTitle.Text := '타석배정표 인증';
      ImageClose.Visible := True;

      FullPopupCoupon1.txtTasukInfo.Text := '';
      FullPopupCoupon1.Image.Visible := False;
      FullPopupCoupon1.ImageWellbeing.Visible := False;
      FullPopupCoupon1.ImageBCPaybook.Visible := False; //bc페이북
      FullPopupCoupon1.ImageTeeboxMove.Visible := True;
      FullPopupCoupon1.Text1.Text := '타석배정표를 아래 스캐너에 인식해주세요.';
      FullPopupCoupon1.Visible := True;
      UseScanner := True;
    end

    else if PopUpFullLevel = pflNewMemberFinger then
    begin

      txtTitle.Text := '회원 등록';
      FullPopupPeriod1.txtTasukInfo.Text := '';
      FullPopupPeriod1.Visible := True;

      //chy 2020-11-04 union 문구추가
      if Global.Config.Fingerprint = 'UNION' then
      begin
        FullPopupPeriod1.Rectangle5.Visible := True;
        FullPopupPeriod1.txtUnionMsg1.Visible := True;
        FullPopupPeriod1.txtUnionMsg2.Visible := True;
      end
      else
      begin
        FullPopupPeriod1.Rectangle5.Visible := False;
        FullPopupPeriod1.txtUnionMsg1.Visible := False;
        FullPopupPeriod1.txtUnionMsg2.Visible := False;
      end;

      BackRectangle.Visible := False;
      CallRectangle.Visible := False;
      HomeRectangle.Visible := False;
      txtBiomini.Visible := False;
      ImgBiomini.Visible := False;
      ImgCancel.Visible := False;
      ImageClose.Visible := False;
      if FCnt <> 0 then
        FCnt := 0;
    end
    else if PopUpFullLevel = pflNewMemberQRSend then
    begin
      txtTitle.Text := '';
      //FullPopupQRSend1.txtTasukInfo.Text := '';
      FullPopupQRSend1.Visible := True;
      BackRectangle.Visible := False;
      CallRectangle.Visible := False;
      HomeRectangle.Visible := False;
      txtBiomini.Visible := False;
      ImgBiomini.Visible := False;
      ImgCancel.Visible := False;
      ImageClose.Visible := False;
      if FCnt <> 0 then
        FCnt := 0;
    end

    else if PopUpFullLevel = pflCheckInQR then //
    begin
      if Global.Config.StoreType = '0' then
        SelectBox.ChangBottomImg
      else
        SelectBox_In.ChangBottomImg;

      if not Global.Config.NoDevice then
      begin
        if Global.Config.Scanner.Port <> 0 then
          Comport.Open;
      end;

      txtTitle.Text := '체크인';

      //FullPopupQR1.recTop.Visible := False;
      //FullPopupQR1.Visible := True;
      FullPopupCoupon1.txtTasukInfo.Text := '';
      FullPopupCoupon1.Text4.Visible := False;
      FullPopupCoupon1.Visible := True;

      ImgCancel.Visible := True;
      if (Global.Config.FingerprintUse = 'Y') or (Global.Config.FingerprintQRUse = 'Y') then
        ImgBiomini.Visible := True;
      txtCheckIn.Visible := True;

      UseScanner := True;
    end
    else if PopUpFullLevel = pflCheckInFinger then //2021-08-04
    begin
      if not Global.Config.NoDevice then
      begin
        if Global.Config.RFID.Port <> 0 then
          RFIDComport.Open;
      end;

      txtTitle.Text := '체크인';
      FullPopupPeriod1.txtTasukInfo.Text := '';
      FullPopupPeriod1.Text4.Text := '';
      FullPopupPeriod1.Visible := True;
      txtCheckIn.Visible := True;

      if Global.Config.Fingerprint = 'UNION' then
      begin
        FullPopupPeriod1.Rectangle5.Visible := True;
        FullPopupPeriod1.txtUnionMsg1.Visible := True;
        FullPopupPeriod1.txtUnionMsg2.Visible := True;

        txtCheckIn.Position.Y := 1060;
      end
      else
      begin
        FullPopupPeriod1.Rectangle5.Visible := False;
        FullPopupPeriod1.txtUnionMsg1.Visible := False;
        FullPopupPeriod1.txtUnionMsg2.Visible := False;
      end;

      BackRectangle.Visible := False;
      CallRectangle.Visible := False;
      HomeRectangle.Visible := False;
      txtBiomini.Visible := False;
      ImgBiomini.Visible := False;
      ImgCancel.Visible := False;
      ImageClose.Visible := False;
      if FCnt <> 0 then
        FCnt := 0;
    end
    else if PopUpFullLevel = pflCheckInPrint then
    begin
      FullPopupPrint1.txtTasukInfo.Text := '';

      FullPopupPrint1.Text.Text := '기기 하단의 프린터로 타석배정표가 출력되었습니다.';
      FullPopupPrint1.Visible := True;
      ImgBG.Visible := False;
      ImgSmall.Visible := True;
      ImgSmall1.Visible := True;

      if Global.SaleModule.Print.PrintThread <> nil then
      begin
        Global.SaleModule.Print.PrintThread.PrintList.Add(Global.SaleModule.SetCheckInPrintData);
        Global.SaleModule.Print.PrintThread.Resume;
      end;
    end
    else if PopUpFullLevel = pflMobile then
    begin
      txtTitle.Text := '회원권 선택하기';
      txtAddMember.Visible := False;
      BackRectangle.Visible := True;
      CallRectangle.Visible := True;
      HomeRectangle.Visible := True;
      txtBiomini.Visible := False;
      ImgBiomini.Visible := False;
      FullPopupPeriod1.Visible := False;
      FullPopupCoupon1.Visible := True;
      FullPopupCoupon1.Layout.Visible := False;
      FullPopupCoupon1.ActivePage := 1;
      //FullPopupCoupon1.Display;
      ImgAddProduct.Visible := True;
      ImgCancel.Position.Y := 1060;
      ImgBG.Visible := False;
      ImgBG50.Visible := True;
      ImgBG50Sub.Visible := True;
      ImgCancel.Visible := True;
      txtMemberName.Text := Global.SaleModule.Member.Name;
      UseScanner := False;
    end
    else if PopUpFullLevel = pflParkingPrint then
    begin
      txtTitle.Text := '주차권 발행';
      FullPopupPrint1.txtTasukInfo.Text := '주차권 출력';
      FullPopupPrint1.Text.Text := '기기 하단의 프린터로 주차권이 출력되었습니다.';
      FullPopupPrint1.Visible := True;
      ImgBG.Visible := False;
      ImgSmall.Visible := True;
      ImgSmall1.Visible := True;

      //쓰레드 미사용, 바로 출력
      Global.SaleModule.Print.SetParkingPrint;
    end
    else // FullPopupSelectTime1
    begin
      txtTitle.Text := '시간 선택';
      FullPopupSelectTime1.Visible := True;
      FullPopupSelectTime1.Time := 8;
      FullPopupSelectTime1.Display;
      //ImageBottom.Visible := True;
    end;

    Log.D('TFullPopup.ShowFullPopup', 'End');
  except
    on E: Exception do
    begin
      Log.E('TFullPopup.ShowFullPopup', E.Message);
    end;
  end;
end;

procedure TFullPopup.StopTimer;
begin
  TimerFull.Enabled := not TimerFull.Enabled;
end;

procedure TFullPopup.TimerFullTimer(Sender: TObject);
label ReNitgen, ReNitgenAdd, ReUnion, ReUnionAdd;
var
  iRv: Integer;
  AMsg: string;
  panel: TPanel;
  bXGolfMember: boolean;
  MemberTemp: TMemberInfo;
  sMsg: String;
begin
  try
    if Work then
    begin
      Log.D('TFullPopup.TimerFullTimer Work', 'Exit');
      Exit;
    end;

    FCnt := FCnt + 0.5;
    if PopUpFullLevel in [pflPrint, pflTeeBoxPrint] then
    begin
      txtTime.Text := Format(TimeSecCaption, [LPadB(IntToStr(11 - Trunc(FCnt)), 2, ' ')]);
      if (10 - FCnt) = 0 then
      //if (2 - FCnt) = 0 then //2021-05-13 이종섭과장 요청
      begin
        PrintCancel;
      end;
    end
    else
    begin
      txtTime.Text := Format(TimeSecCaption, [LPadB(IntToStr(Time30Sec - Trunc(FCnt)), 2, ' ')]);
      if (Time30Sec - FCnt) = 0 then
      begin
        TimerFull.Enabled := False;
        CloseFormStrMrCancel;
      end;
    end;

    if Global.SaleModule.CardApplyType = catNone then
    begin
      if FCnt = 0.5 then
      begin

        if PopUpFullLevel in [pflPeriod, pflBunkerMember, pflCheckInFinger]then
        begin
          TimerFull.Enabled := False;

          if Global.Config.Fingerprint = 'UNION' then
          begin
            ReUnion :

            if FRFIDUse = True then
              Exit;

            if Global.SaleModule.AdvertPopupType = apMember then
            begin
              bXGolfMember := False;
              if Global.SaleModule.Member.XGolfMember = True then
                bXGolfMember := True;
            end;

            if Global.SaleModule.UCBioBSPHelper.SearchMemberFinger(sMsg) then
            begin
 
              if Global.SaleModule.AdvertPopupType = apMember then
              begin
                if bXGolfMember then
                begin
                  MemberTemp := Global.SaleModule.Member;
                  MemberTemp.XGolfMember := True;
                  Global.SaleModule.Member := MemberTemp;
                end;
              end;

              if PopUpFullLevel = pflCheckInFinger then
              begin
                GetMemberCheckIn(EmptyStr, Global.SaleModule.Member);
              end
              else
              begin
                GetMemberInfo(EmptyStr, Global.SaleModule.Member);
              end;
            end
            else
            begin

              if FRFIDUse = True then
                Exit;

              //chy 2020-11-04 재시도 간격1초, 3회까지 자동재시도->2회 01-27 이종섭과장 요청
              Inc(FFingerRetry);
              if FFingerRetry > 2 then
              begin
                Global.SBMessage.ShowMessageModalForm('일치하는 지문이 없습니다.' + #13 + sMsg);
                //Log.D('FFingerRetry', '2 / 일치하는 지문이 없습니다');
                FFingerRetry := 0;

                if FRFIDUse = False then
                begin
                  CloseFormStrMrCancel;
                  Log.D('FRFIDUse', 'CloseFormStrMrCancel 1');
                end;
              end
              else
              begin
                if Global.SBMessage.ShowMessageModalForm('일치하는 지문이 없습니다.' + #13 + sMsg, False, 30, True, True) then
                  goto ReUnion
                else
                begin
                  if FRFIDUse = False then
                  begin
                    CloseFormStrMrCancel;
                    Log.D('FRFIDUse', 'CloseFormStrMrCancel 2');
                  end;
                end;
              end;

            end;
          end
          else
          begin

            ReNitgen :

            if Global.SaleModule.NBioBSPHelper.SearchMemberFinger then
            begin
              GetMemberInfo(EmptyStr, Global.SaleModule.Member);
            end
            else
            begin
              //chy 2020-11-24 재시도 간격1초, 3회까지 자동재시도
              Inc(FFingerRetry);
              if FFingerRetry > 3 then
              begin
                Global.SBMessage.ShowMessageModalForm('일치하는 지문이 없습니다.');
                Log.D('FFingerRetry', '3 / 일치하는 지문이 없습니다');
                FFingerRetry := 0;
                CloseFormStrMrCancel;
              end
              else
              begin
                if Global.SBMessage.ShowMessageModalForm('일치하는 지문이 없습니다.', False, 30, True, True) then
                  goto ReNitgen
                else
                  CloseFormStrMrCancel;
              end;
            end;

          end;

        end

        else if PopUpFullLevel = pflNewMemberFinger then
        begin
          TimerFull.Enabled := False;

          if Global.Config.Fingerprint = 'UNION' then
          begin
            ReUnionAdd :
            if Global.SaleModule.UCBioBSPHelper.Capture then
            begin
              Global.SaleModule.FingerStr := Global.SaleModule.UCBioBSPHelper.TextFIR;
              ModalResult := mrOk;
            end
            else
            begin
              if Global.SBMessage.ShowMessageModalForm('지문을 인식하지 못했습니다.', False, 30, True, True) then
                goto ReUnionAdd
              else
                CloseFormStrMrCancel;
            end;
          end
          else
          begin
            {
            ReNitgenAdd :
            //if Global.SaleModule.Nitgen.CaptureMemberFinger then
            if Global.SaleModule.NBioBSPHelper.CaptureMemberFinger then
            begin
              ModalResult := mrOk;
            end
            else
            begin
              if Global.SBMessage.ShowMessageModalForm('지문을 인식하지 못했습니다.', False, 30, True, True) then
                goto ReNitgenAdd
              else
                CloseFormStrMrCancel;
            end;
            }
          end;

        end
        else if PopUpFullLevel in [pflPrint, pflTeeBoxPrint] then
        begin
    //      if Global.SaleModule.Print <> nil then
//            Global.SaleModule.Print.ReceiptPrint(Global.SaleModule.SetPrintData);    2020.09.09 JHJ Thread로 변경
        end
        else if PopUpFullLevel = pflSelectTime then
        begin
          if FullPopupSelectTime1.ItemList.Count = 0 then
          begin
            Global.SBMessage.ShowMessageModalForm('선택 가능한 시간이 없습니다.');
            CloseFormStrMrCancel;
          end;
        end
        else if PopUpFullLevel = pflMobile then
        begin
          GetMemberInfo(EmptyStr, Global.SaleModule.Member);
        end;

      end;
    end;
  except
    on E: Exception do
    begin
      Log.E('TFullPopup.TimerFullTimer', 'Exception');
      Log.E('TFullPopup.TimerFullTimer FCnt', CurrToStr(FCnt));
      Log.E('TFullPopup.TimerFullTimer PopUpFullLevel', IntToStr(Ord(PopUpFullLevel)));
      Log.E('TFullPopup.TimerFullTimer txtTime.Text', txtTime.Text);
    end;
  end;

end;

procedure TFullPopup.Top1RectangleClick(Sender: TObject);
begin
  Top1.RectangleClick(Sender);
end;

procedure TFullPopup.VisibleMsgBox;
begin
  MsgImage.Visible := not MsgImage.Visible;
  MsgBGRectangle.Visible := not MsgBGRectangle.Visible;
end;

//2020-12-14 리프레쉬골프 상품표시
procedure TFullPopup.SetRefreshGolfProduct(ACode: string; AMember: TMemberInfo);
var
  Temp: string;
begin
  try
    try
      Temp := EmptyStr;

      if ACode = EmptyStr then
        Global.SaleModule.Member := AMember
      else
        Global.SaleModule.Member := Global.SaleModule.SearchMember(ACode);

      if Global.SaleModule.Member.Code = EmptyStr then
      begin
        Global.SBMessage.ShowMessageModalForm(MSG_NOT_MEMBER_SEARCH);

        ModalResult := mrCancel;
        Exit;
      end;

      Global.SaleModule.ProductList := Global.Database.GetMemberProductList(Global.SaleModule.Member.Code, '', '');
      if Global.SaleModule.ProductList.Count = 0 then
      begin
        if Global.SBMessage.ShowMessageModalForm(MSG_MEMBER_USE_NOT_PRODUCT + #13#10 + MSG_IS_PRODUCT_BUY, False) then
          ModalResult := mrTryAgain
        else
          ModalResult := mrCancel;
      end
      else
      begin
        txtTitle.Text := '회원권 선택하기';
        txtAddMember.Visible := False;
//        ImageLeft.Visible := True;
//        ImageRight.Visible := True;
        BackRectangle.Visible := True;
        CallRectangle.Visible := True;
        HomeRectangle.Visible := True;
        txtBiomini.Visible := False;
        ImgBiomini.Visible := False;
        FullPopupPeriod1.Visible := False;
        FullPopupCoupon1.Visible := True;
        FullPopupCoupon1.Layout.Visible := False;
        FullPopupCoupon1.ActivePage := 1;
        FullPopupCoupon1.Display;
        ImgAddProduct.Visible := True;
        ImgCancel.Position.Y := 1060;
        ImgBG.Visible := False;
        ImgBG50.Visible := True;
        ImgBG50Sub.Visible := True;
        ImgCancel.Visible := True;
//        ImageClose.Visible := False;
        txtMemberName.Text := Global.SaleModule.Member.Name;
        UseScanner := False;
      end;
    except
      on E: Exception do
        Log.E('TFullPopup.GetMemberInfo', E.Message);
    end;
  finally
  end;
end;

procedure TFullPopup.GetMemberCheckIn(ACode: string; AMember: TMemberInfo);
var
  sCode, sMsg: string;
begin

  try

    try

      if ACode = EmptyStr then //지문
      begin
        Global.SaleModule.Member := AMember;

        if Global.SaleModule.Member.Code = EmptyStr then
        begin
          Global.SBMessage.ShowMessageModalForm(MSG_NOT_MEMBER_SEARCH);

          ModalResult := mrCancel;
          Exit;
        end;

        //체크인 - 파트너센터에서 해당 회원의 모바일,정기권 예약목록을 줌
        Global.SaleModule.CheckInList := Global.Database.GetMemberCheckInList(Global.SaleModule.Member.Code, EmptyStr, EmptyStr, sCode, sMsg);

      end
      else
      begin
        //체크인 - 파트너센터에서 해당 회원의 모바일,정기권 예약목록을 줌 -> QR
        //Global.SaleModule.CheckInList := Global.Database.GetMemberCheckInList(EmptyStr, ACode, sCode, sMsg);
        Global.SaleModule.CheckInList := Global.Database.GetMemberCheckInList(EmptyStr, EmptyStr, ACode, sCode, sMsg);
      end;

      if sCode <> '0000' then
      begin
        Global.SBMessage.ShowMessageModalForm(sMsg);

        ModalResult := mrCancel;
        Exit;
      end;

      ModalResult := mrOk;
    except
      on E: Exception do
        Log.E('TFullPopup.GetMemberCheckIn', E.Message);
    end;

  finally
  end;

end;

procedure TFullPopup.GetRFIDMemberCheckIn(ACode: string);
var
  sCode, sMsg: string;
begin

  try

    try
      Global.SaleModule.Member := Global.SaleModule.SearchRFIDMember(ACode);

      if Global.SaleModule.Member.Code = EmptyStr then
      begin
        Global.SBMessage.ShowMessageModalForm(MSG_NOT_MEMBER_SEARCH);

        ModalResult := mrCancel;
        Exit;
      end;

      //체크인 - 파트너센터에서 해당 회원의 모바일,정기권 예약목록을 줌
      Global.SaleModule.CheckInList := Global.Database.GetMemberCheckInList(Global.SaleModule.Member.Code, EmptyStr, EmptyStr, sCode, sMsg);

      if sCode <> '0000' then
      begin
        Global.SBMessage.ShowMessageModalForm(sMsg);

        ModalResult := mrCancel;
        Exit;
      end;

      ModalResult := mrOk;
    except
      on E: Exception do
        Log.E('TFullPopup.GetRFIDMemberCheckIn', E.Message);
    end;

  finally
  end;

end;

end.
