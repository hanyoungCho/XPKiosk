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
    FRFIDUse: Boolean; //RFID�� ȸ����ȸ

    BarcodeIn: Boolean;
    UseScanner: Boolean;
    Work: Boolean;
    IsPayco: Boolean;

    FFingerRetry: Integer; // ��õ� Ƚ��

    function BioMini_ErrorMsg(ACode: Integer; AStr: string = ''): string;
    procedure ComPortRxBuf(Sender: TObject; const Buffer; Count: Integer);
    procedure ComPortRxChar(Sender: TObject; Count: Integer);
    procedure RFIDComportRxChar(Sender: TObject; Count: Integer);

    procedure GetMemberInfo(ACode: string; AMember: TMemberInfo);
    procedure GetMemberCheckIn(ACode: string; AMember: TMemberInfo); //2021-08-04 checkin
    procedure GetRFIDMemberInfo(ACode: string);
    procedure GetRFIDMemberCheckIn(ACode: string);

    //2020-12-14 ������������ ��ǰǥ��
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
      if AText = '���� ��ġ����' then
      begin
        Work := True;
        AppCardImageCancel.Visible := False;
        Global.SaleModule.CardApplyType := catMagnetic;
        ApplyCard('', False, True);
      end
      //else if AText = 'NH��ġ ����' then 6:�ڳ�ī��
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

    //2021-06-16 ��Ʈ�ʼ��� ī��� ���ο��� Ȯ��... �������
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
        Global.SBMessage.ShowMessageModalForm('���� ������ ��� �����ϴ�.');
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
      Result := '������ �ν����� ���Ͽ����ϴ�.'
    else if AStr = 'UFM_Verify' then
      Result := '��ġ�ϴ� ������ �����ϴ�.'
    else
      Result := '����!!';
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

    Result := '�����νĿ� �����Ͽ����ϴ�.' + #13#10 + Result;
  end;
end;

procedure TFullPopup.BottomRectangleClick(Sender: TObject);
begin
  TouchSound;
end;

procedure TFullPopup.Button1Click(Sender: TObject);
begin
  if Global.SaleModule.WellbeingClub(False, Edit1.Text) then
    Global.SBMessage.ShowMessageModalForm('����', True)
  else
    Global.SBMessage.ShowMessageModalForm('����', True);
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

    if Global.Config.Print.PrintType = 'EPSON' then //��ĳ�� ��������
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
    else if Global.SaleModule.PromotionType = pttBCPaybookGolf then //bc���̺ϰ���
    begin
      Log.D('Scan begin', 'bc���̺ϰ���');
      if Global.Database.SearchPromotion(FReadStr) then
      begin
        Global.SaleModule.Calc;
        ModalResult := mrOk;
      end
      else
        ModalResult := mrCancel;
      Exit;
    end
    else if Global.SaleModule.PromotionType = pttTheLoungeMembers then //������������
    begin
      Log.D('Scan begin', '�츮ī�� ������������');
      if Global.SaleModule.TheLoungeMembers(FReadStr) then
        ModalResult := mrOk
      else
        ModalResult := mrCancel;
    end
    else if Global.SaleModule.PromotionType = pttRefreshclub then //��������Ŭ��
    begin
      Log.D('Scan begin', '��������Ŭ��');
      if Global.SaleModule.ApplyRefreshClub(FReadStr) then
        ModalResult := mrOk
      else
        ModalResult := mrCancel;
    end
    else if Global.SaleModule.PromotionType = pttIkozen then //��������
    begin
      Log.D('Scan begin', '��������');
      if Global.SaleModule.ApplyIKozen(FReadStr) then
        ModalResult := mrOk
      else
        ModalResult := mrCancel;
    end
    else if Global.SaleModule.PromotionType = pttSmartix then // ����ƽ��
    begin
      Log.D('Scan begin', '����ƽ��');
      if Global.SaleModule.ApplySmartix(True, FReadStr, sMsg) then  //   sRmsTkttypId    AProduct.Alliance_Item_Code
        ModalResult := mrOk
      else
      begin
        if sMsg <> '' then
          Global.SBMessage.ShowMessageModalForm(sMsg)
        else
          Global.SBMessage.ShowMessageModalForm('��ϵ��� ���� Ƽ�Ϲ�ȣ �Դϴ�.');
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
          Global.SBMessage.ShowMessageModalForm('�ش� ������ ���Ƚ���� �ʰ��Ǿ�' +#13#10 +'�̿��� �Ұ��մϴ�.' +#13#10 + '�����մϴ�');
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

      //if Global.SaleModule.CheckXGolfMember(FReadStr) then // 2023-05-11 ����
      if Global.SaleModule.CheckXGolfMemberChk('QR', FReadStr) then
      begin

        if PopUpFullLevel = pflCheckInFinger then
        begin
          GetMemberCheckIn(FReadStr, Global.SaleModule.Member);
        end
        else
        begin
          // �����ݿ� M030 API �߰� �ؾߵ�
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
        Global.SBMessage.ShowMessageModalForm('XGOLF ȸ����ȸ�� ���� �Ͽ����ϴ�.');
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

      //����Ÿ�� ���翩�� Ȯ��
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
      if (Copy(FReadStr, 1, 2) = 'R-') then //OTP QR�ڵ�
      begin
        AMember := Global.Database.GetMemberOptQR(FReadStr);

        if AMember.Code = '0000' then //0000 ȸ������ ����
        begin
          Global.SBMessage.ShowMessageModalForm('ȸ����ȸ�� ���� �Ͽ����ϴ�.');
        end
        else
        begin
          GetMemberInfo(EmptyStr, AMember);
        end;
      end
      else
        GetMemberInfo(FReadStr, AMember); //����ȸ��
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
        //SetCursorPos(270, 620); //���콺 Ŀ���� ���� �� ��ư�� ��ġ
        SetCursorPos(540, 1105); //���콺 Ŀ���� ���� �� ��ư�� ��ġ
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

        //chy bc���̺ϰ���
        //Comport.BaudRate := br115200; -> Ʈ�ν�
        //Comport.BaudRate := br9600; -> ��������ũ
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

    //chy 2020-11-04 �����νı� retry Ƚ�� 5ȸ
    FFingerRetry := 0;

    FRFIDUse := False;
  except
    on E: Exception do
    begin //���̺�
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
    Text.Text := '��ø� ��ٷ� �ֽñ� �ٶ��ϴ�.';
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
      //if (Global.Config.Store.StoreCode = 'C1001') and (Global.SaleModule.memberItemType = mitGamePay) then //�ڸ����������̺꽺����Ŭ��
      if Global.SaleModule.PaymentAddType = patGamePay then //�ڸ����������̺꽺����Ŭ��
      begin
        FullPopupPayCard1.txtTasukInfo.Text := '';
        FullPopupPayCard1.Text4.Visible := False;
      end;

      FullPopupPayCard1.DisPlay;
    end;
    Text.Text := 'ȸ�� ������ Ȯ���� �Դϴ�.' + #13#10 + '��ø� ��ٷ� �ֽñ�ٶ��ϴ�.';

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

      //chy test ȸ��
      //AMember.Code := 'T0001000000001';
      //AMember.Name := '���ѿ�';

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

      if Global.SaleModule.PopUpFullLevel = pflBunkerMember then //��Ŀ/����
      begin
        ModalResult := mrOk;
        Exit;
      end;

      //���� �߰� ����-��õȸ����
      if Global.SaleModule.AdvertPopupType = apMember then
      begin
        ModalResult := mrTryAgain;
        Exit;
      end;

      //�ü��̿�� ȸ������
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

      txtTitle.Text := 'ȸ���� �����ϱ�';
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

      if Global.SaleModule.PopUpFullLevel = pflBunkerMember then //��Ŀ/����
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
        txtTitle.Text := 'ȸ���� �����ϱ�';
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
    { 2023-03-22 ����������-������,DBĳ���� ���� ���� �ð� ��ü�� ī�� �˸��� ����ó��
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
  AMemberTm: TMemberInfo; //����ȸ�� �׽�Ʈ��-�ּ�ó�� �ʼ�
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
        txtTitle.Text := '���޻� ����';
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
            txtTitle.Text := '���޻� ����';
          end;

          FullPopupCoupon1.Image.Visible := False;
          FullPopupCoupon1.ImageWellbeing.Visible := True;
          FullPopupCoupon1.ImageBCPaybook.Visible := False;

          FullPopupCoupon1.Text1.Text := '����Ŭ�� ���ڵ带 ��ĵ���ּ���.';
        end
        else if Global.SaleModule.PromotionType = pttBCPaybookGolf then
        begin
          FullPopupCoupon1.Image.Visible := False;
          FullPopupCoupon1.ImageWellbeing.Visible := False;
          FullPopupCoupon1.ImageBCPaybook.Visible := True;

          FullPopupCoupon1.Text1.Text := 'BC���̺� ���ڵ带 ��ĵ���ּ���.';
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
            FullPopupCoupon1.Text1.Text := '������������ ���ڵ带 ��ĵ���ּ���.';

          if Global.SaleModule.PromotionType = pttRefreshclub then
            FullPopupCoupon1.Text1.Text := '��������Ŭ�� ���ڵ带 ��ĵ���ּ���.';

          if Global.SaleModule.PromotionType = pttIkozen then
            FullPopupCoupon1.Text1.Text := '�������� ���ڵ带 ��ĵ���ּ���.';

          if Global.SaleModule.PromotionType = pttSmartix then
          begin
            // ���� ȭ���� ��� ��ư/Ÿ��Ʋ �缳��
            ImgXGolfCancel.Visible := True;
            txtTitle.Text := '�¶��� Ƽ�� ����';
            FullPopupCoupon1.Text1.Text := 'QR�ڵ带 �Ʒ� ��ĳ�ʿ� �νĽ��� �ּ���.';
          end;
        end
        else
        begin
          ImgXGolfCancel.Visible := False;

          txtTitle.Text := '���θ�� ����';
          ImgCancel.Visible := True;
          ImgPromoNumber.Visible := True;

          FullPopupCoupon1.Image.Visible := True;
          FullPopupCoupon1.ImageWellbeing.Visible := False;
          FullPopupCoupon1.ImageBCPaybook.Visible := False;

          FullPopupCoupon1.Text1.Text := 'QR�ڵ带 �Ʒ� ��ĳ�ʿ� �νĽ��� �ּ���.';
        end;

        FullPopupCoupon1.txtTasukInfo.Text := Global.SaleModule.TeeBoxInfo.FloorNm + ' ' + Global.SaleModule.TeeBoxInfo.Mno + '��';
        if Global.SaleModule.TeeBoxInfo.ZoneCode = 'O' then
          FullPopupCoupon1.txtTasukInfo.Text := FullPopupCoupon1.txtTasukInfo.Text + ' (��Ÿ)';

      end;
      AppCardImageCancel.Visible := True;
    end
    else if Global.SaleModule.CardApplyType = catAppCard then
    begin
      ImgXGolfCancel.Visible := True;
      txtTitle.Text := '������� ����';
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
        txtTitle.Text := '���θ�� ����';
        //ImageClose.Visible := True;      // ����ư ��Ұ� �ƴ� ��ȣ�� �Է��ϰԲ�
        ImgCancel.Visible := True;
        ImgPromoNumber.Visible := True;
      end
      else
      begin
        txtTitle.Text := 'ȸ�� ����';

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
        FullPopupCoupon1.txtTasukInfo.Text := Global.SaleModule.TeeBoxInfo.FloorNm + ' ' + Global.SaleModule.TeeBoxInfo.Mno + '��';
        if Global.SaleModule.TeeBoxInfo.ZoneCode = 'O' then
          FullPopupCoupon1.txtTasukInfo.Text := FullPopupCoupon1.txtTasukInfo.Text + ' (��Ÿ)';
      end;
      FullPopupCoupon1.Visible := True;
      UseScanner := True;
    end
    else if PopUpFullLevel = pflPayCard then
    begin  // FullPopupPayCard1
      txtTitle.Text := '�ſ�ī�� ����';

      //if (Global.Config.Store.StoreCode = 'C1001') and (Global.SaleModule.PaymentAddType = patGamePay) then //�ڸ����������̺꽺����Ŭ��
      if (Global.SaleModule.PaymentAddType <> patNone) then
      begin
        FullPopupPayCard1.txtTasukInfo.Text := '';
        FullPopupPayCard1.Text4.Visible := False;
      end
      else
      begin
        FullPopupPayCard1.txtTasukInfo.Text := Global.SaleModule.TeeBoxInfo.FloorNm + ' ' + Global.SaleModule.TeeBoxInfo.Mno + '��';
        if Global.SaleModule.TeeBoxInfo.ZoneCode = 'O' then
          FullPopupPayCard1.txtTasukInfo.Text := FullPopupPayCard1.txtTasukInfo.Text + ' (��Ÿ)';
      end;
      FullPopupPayCard1.Visible := True;
      ImgBG.Visible := False;
      ImgSmall.Visible := True;
      ImgSmall1.Visible := True;
    end
    else if PopUpFullLevel in [pflPrint, pflTeeBoxPrint] then
    begin

      //if (Global.Config.Store.StoreCode = 'C1001') and (Global.SaleModule.PaymentAddType = patGamePay) then //�ڸ����������̺꽺����Ŭ��
      if (Global.SaleModule.PaymentAddType <> patNone) then
      begin
        FullPopupPrint1.txtTasukInfo.Text := '�ü� �̿��';
        FullPopupPrint1.Text4.Visible := False;
      end
      else
      begin
        FullPopupPrint1.txtTasukInfo.Text := Global.SaleModule.TeeBoxInfo.FloorNm + ' ' + Global.SaleModule.TeeBoxInfo.Mno + '��';
        if Global.SaleModule.TeeBoxInfo.ZoneCode = 'O' then
          FullPopupPrint1.txtTasukInfo.Text := FullPopupPrint1.txtTasukInfo.Text + ' (��Ÿ)';
      end;

      bEventChk := False;
      if PopUpFullLevel = pflTeeBoxPrint then
      begin
        FullPopupPrint1.Text.Text := '��� �ϴ��� �����ͷ� Ÿ������ǥ�� ��µǾ����ϴ�.';
        bEventChk := True;
      end
      else
      begin
        if (Global.SaleModule.PaymentAddType <> patNone) then
        begin
          if (Global.SaleModule.memberItemType in [mitNone, mitDay]) then
          begin
            txtTitle.Text := '���� �Ϸ�';

            if (Global.SaleModule.PaymentAddType = patFacilityPeriod) then
            begin
              FullPopupPrint1.Text1.Text := '����QR�� īī�������� �ڵ� ���۵˴ϴ�.';
            end;
          end
          else
          begin
            txtTitle.Text := '�̿�� ���';
          end;
        end
        else
        begin
          if Global.SaleModule.SelectProduct.Code <> EmptyStr then
          begin
            FullPopupPrint1.Text.Text := '��� �ϴ��� �����ͷ� ī�� ��������';
            FullPopupPrint1.Text1.Text := 'Ÿ������ǥ�� ��µǾ����ϴ�.';

            if (Global.SaleModule.memberItemType = mitDay) then
              bEventChk := True;
          end;
        end;
      end;

      if bEventChk = True then
      begin
        //��������� ����(����ǥ) ��÷���� Ȯ�� ���� ������� ����
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

      txtTitle.Text := 'ȸ�� ����';

      if Global.SaleModule.PaymentAddType = patFacilityPeriod then
      begin
        FullPopupPeriod1.txtTasukInfo.Text := '';
        FullPopupPeriod1.Text4.Text := '';
      end
      else
      begin
        FullPopupPeriod1.txtTasukInfo.Text := Global.SaleModule.TeeBoxInfo.FloorNm + ' ' + Global.SaleModule.TeeBoxInfo.Mno + '��';
        if Global.SaleModule.TeeBoxInfo.ZoneCode = 'O' then
          FullPopupPeriod1.txtTasukInfo.Text := FullPopupPeriod1.txtTasukInfo.Text + ' (��Ÿ)';
      end;

      FullPopupPeriod1.Visible := True;

      //chy 2020-11-04 union �����߰�
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

      txtTitle.Text := 'XGOLF ȸ�� ����';

      FullPopupQR1.txtTasukInfo.Text := Global.SaleModule.TeeBoxInfo.FloorNm + ' ' + Global.SaleModule.TeeBoxInfo.Mno + '��';
      if Global.SaleModule.TeeBoxInfo.ZoneCode = 'O' then
        FullPopupQR1.txtTasukInfo.Text := FullPopupQR1.txtTasukInfo.Text + ' (��Ÿ)';

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

      txtTitle.Text := 'ȸ�� ����';
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

      txtTitle.Text := 'Ÿ������ǥ ����';
      ImageClose.Visible := True;

      FullPopupCoupon1.txtTasukInfo.Text := '';
      FullPopupCoupon1.Image.Visible := False;
      FullPopupCoupon1.ImageWellbeing.Visible := False;
      FullPopupCoupon1.ImageBCPaybook.Visible := False; //bc���̺�
      FullPopupCoupon1.ImageTeeboxMove.Visible := True;
      FullPopupCoupon1.Text1.Text := 'Ÿ������ǥ�� �Ʒ� ��ĳ�ʿ� �ν����ּ���.';
      FullPopupCoupon1.Visible := True;
      UseScanner := True;
    end

    else if PopUpFullLevel = pflNewMemberFinger then
    begin

      txtTitle.Text := 'ȸ�� ���';
      FullPopupPeriod1.txtTasukInfo.Text := '';
      FullPopupPeriod1.Visible := True;

      //chy 2020-11-04 union �����߰�
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

      txtTitle.Text := 'üũ��';

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

      txtTitle.Text := 'üũ��';
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

      FullPopupPrint1.Text.Text := '��� �ϴ��� �����ͷ� Ÿ������ǥ�� ��µǾ����ϴ�.';
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
      txtTitle.Text := 'ȸ���� �����ϱ�';
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
      txtTitle.Text := '������ ����';
      FullPopupPrint1.txtTasukInfo.Text := '������ ���';
      FullPopupPrint1.Text.Text := '��� �ϴ��� �����ͷ� �������� ��µǾ����ϴ�.';
      FullPopupPrint1.Visible := True;
      ImgBG.Visible := False;
      ImgSmall.Visible := True;
      ImgSmall1.Visible := True;

      //������ �̻��, �ٷ� ���
      Global.SaleModule.Print.SetParkingPrint;
    end
    else // FullPopupSelectTime1
    begin
      txtTitle.Text := '�ð� ����';
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
      //if (2 - FCnt) = 0 then //2021-05-13 ���������� ��û
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

              //chy 2020-11-04 ��õ� ����1��, 3ȸ���� �ڵ���õ�->2ȸ 01-27 ���������� ��û
              Inc(FFingerRetry);
              if FFingerRetry > 2 then
              begin
                Global.SBMessage.ShowMessageModalForm('��ġ�ϴ� ������ �����ϴ�.' + #13 + sMsg);
                //Log.D('FFingerRetry', '2 / ��ġ�ϴ� ������ �����ϴ�');
                FFingerRetry := 0;

                if FRFIDUse = False then
                begin
                  CloseFormStrMrCancel;
                  Log.D('FRFIDUse', 'CloseFormStrMrCancel 1');
                end;
              end
              else
              begin
                if Global.SBMessage.ShowMessageModalForm('��ġ�ϴ� ������ �����ϴ�.' + #13 + sMsg, False, 30, True, True) then
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
              //chy 2020-11-24 ��õ� ����1��, 3ȸ���� �ڵ���õ�
              Inc(FFingerRetry);
              if FFingerRetry > 3 then
              begin
                Global.SBMessage.ShowMessageModalForm('��ġ�ϴ� ������ �����ϴ�.');
                Log.D('FFingerRetry', '3 / ��ġ�ϴ� ������ �����ϴ�');
                FFingerRetry := 0;
                CloseFormStrMrCancel;
              end
              else
              begin
                if Global.SBMessage.ShowMessageModalForm('��ġ�ϴ� ������ �����ϴ�.', False, 30, True, True) then
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
              if Global.SBMessage.ShowMessageModalForm('������ �ν����� ���߽��ϴ�.', False, 30, True, True) then
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
              if Global.SBMessage.ShowMessageModalForm('������ �ν����� ���߽��ϴ�.', False, 30, True, True) then
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
//            Global.SaleModule.Print.ReceiptPrint(Global.SaleModule.SetPrintData);    2020.09.09 JHJ Thread�� ����
        end
        else if PopUpFullLevel = pflSelectTime then
        begin
          if FullPopupSelectTime1.ItemList.Count = 0 then
          begin
            Global.SBMessage.ShowMessageModalForm('���� ������ �ð��� �����ϴ�.');
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

//2020-12-14 ������������ ��ǰǥ��
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
        txtTitle.Text := 'ȸ���� �����ϱ�';
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

      if ACode = EmptyStr then //����
      begin
        Global.SaleModule.Member := AMember;

        if Global.SaleModule.Member.Code = EmptyStr then
        begin
          Global.SBMessage.ShowMessageModalForm(MSG_NOT_MEMBER_SEARCH);

          ModalResult := mrCancel;
          Exit;
        end;

        //üũ�� - ��Ʈ�ʼ��Ϳ��� �ش� ȸ���� �����,����� �������� ��
        Global.SaleModule.CheckInList := Global.Database.GetMemberCheckInList(Global.SaleModule.Member.Code, EmptyStr, EmptyStr, sCode, sMsg);

      end
      else
      begin
        //üũ�� - ��Ʈ�ʼ��Ϳ��� �ش� ȸ���� �����,����� �������� �� -> QR
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

      //üũ�� - ��Ʈ�ʼ��Ϳ��� �ش� ȸ���� �����,����� �������� ��
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
