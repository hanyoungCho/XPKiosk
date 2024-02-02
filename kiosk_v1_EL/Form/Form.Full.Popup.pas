unit Form.Full.Popup;

interface

uses
  uConsts, uStruct, uVanDeamonModul, Winapi.Windows,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.Ani, FMX.Layouts, FMX.Gestures,
  FMX.Objects, Frame.Top, Frame.FullPopup.Coupon,
  Frame.FullPopup.Period, Frame.FullPopupQR, Frame.FullPopup.Print,
  Frame.FullPopup.SelectTime, CPort, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Platform.Win,
  System.ImageList, FMX.ImgList, uPaycoNewModul,
  FMX.Edit, Frame.FullPopup.MemberInfo;

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
    Rectangle1: TRectangle;
    ImgBG: TImage;
    ImgCancel: TImage;
    Text1: TText;
    Image2: TImage;
    Text4: TText;
    ImgBG50Sub: TImage;
    ImgCenterCancel: TImage;
    Text5: TText;
    ImageClose: TImage;
    Text6: TText;
    MemberNameRectangle: TRectangle;
    Rectangle3: TRectangle;
    Text8: TText;
    txtMemberName: TText;
    ImgXGolfPhone: TImage;
    Text9: TText;
    ImageList: TImageList;
    AppCardImage: TImage;
    AppCardImageCancel: TImage;
    Text10: TText;
    Button1: TButton;
    Edit1: TEdit;
    FullPopupMemberInfo1: TFullPopupMemberInfo;

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
    procedure ImgCancelClick(Sender: TObject);
    procedure ImgCenterCancelClick(Sender: TObject);
    procedure ImgXGolfPhoneClick(Sender: TObject);
    procedure AppCardImageCancelClick(Sender: TObject);
    procedure Top1RectangleClick(Sender: TObject);
  private
    { Private declarations }
    FPopUpFullLevel: TPopUpFullLevel;
    FCnt: Currency;
    FResultStr: string;
    FReadStr: string;
    FComport: TComport;

    //RFID
    //FRFIDComport: TComport;
    //FRFIDUse: Boolean; //RFID로 회원조회

    BarcodeIn: Boolean;
    UseScanner: Boolean;
    Work: Boolean;
    IsPayco: Boolean;
//    BioMiniPlus2: TBioMiniPlus2;

    //chy 2020-11-04 재시도 횟수
    FFingerRetry: Integer;

    procedure ComPortRxChar(Sender: TObject; Count: Integer);

    //RFID
    //procedure RFIDComportRxChar(Sender: TObject; Count: Integer);

    procedure GetMemberInfo(ACode: string; AMember: TMemberInfo);

    //chy SCANNER usb
    procedure SetScannerUsb(ACode: string);
  public
    { Public declarations }
    procedure ShowFullPopup;
    procedure VisibleMsgBox;

    procedure ApplyPromotion;
    procedure InputPhoneNumber;
    procedure ResetTimerCnt;
    procedure StopTimer;

    procedure MemberProductView;

    procedure CloseFormStrMrok(AStr: string);
    procedure CloseFormStrMrCancel;
    procedure PrintCancel;

    procedure SetTimeText(ATime: Integer);

    procedure FormMessage(AShow: Boolean = True);

    property PopUpFullLevel: TPopUpFullLevel read FPopUpFullLevel write FPopUpFullLevel;
    property ResultStr: string read FResultStr write FResultStr;
    property Comport: TComport read FComport write FComport;

    //RFID
    //property RFIDComport: TComport read FRFIDComport write FRFIDComport;
  end;

var
  FullPopup: TFullPopup;

implementation

uses
  uGlobal, uFunction, fx.Logging, uCommon, uSaleModule, Form.Select.Box;

{$R *.fmx}

function StringToHex(const AValue: AnsiString): string;
begin
  SetLength(Result, Length(AValue) * 2);
  BinToHex(PAnsiChar(AValue), PChar(Result), Length(AValue));
end;

procedure TFullPopup.ApplyPromotion;
begin
  ShowFullPopup;
end;

procedure TFullPopup.MemberProductView;
begin
  FullPopupCoupon1.Visible := False;
  ImgBiomini.Visible := False;
  txtTime.Visible := False;
  PopUpFullLevel := pflMemberProduct;
  ShowFullPopup;
end;

procedure TFullPopup.BackImageClick(Sender: TObject);
begin
  TouchSound;
  ResetTimerCnt;
  if TimerFull.Enabled then
    StopTimer;

  ModalResult := mrCancel;
end;

procedure TFullPopup.BottomRectangleClick(Sender: TObject);
begin
  TouchSound;
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
  ModalResult := mrOk;
end;

procedure TFullPopup.ComPortRxChar(Sender: TObject; Count: Integer);
var
  TempBuff, sCode, sMsg: string;
  AMember: TMemberInfo;
  //ADiscount: TDiscount;
begin
  try
    //Log.D('Scan begin', 'begin');
    if BarcodeIn or (PopUpFullLevel = pflPeriod) or (not UseScanner) then
      Exit;

    Comport.ReadStr(TempBuff, Count);

    FReadStr := FReadStr + TempBuff;
    //Log.D('Scan begin', FReadStr);
    //Log.D('Scan begin', IntToHex(Ord(FReadStr[65]), 2));

    if (Global.Config.Store.StoreCode = 'E0007') then //수내
    begin

      if Copy(FReadStr, Length(FReadStr), 1) = #$A then
      //if Copy(FReadStr, Length(FReadStr), 1) = #$D then //debug chy test
      begin
        FCnt := 0;
        BarcodeIn := True;
        UseScanner := False;

        {$IFDEF RELEASE}
        FReadStr := StringReplace(FReadStr, #$D#$A, '', [rfReplaceAll]);
        {$ENDIF}
        {$IFDEF DEBUG}
        FReadStr := StringReplace(FReadStr, #$D, '', [rfReplaceAll]); //debug
        {$ENDIF}

        Log.D('Scan Barcode', FReadStr);

        AMember := Global.ELoomApi.GetQrcodeAuth(FReadStr, sCode, sMsg);

        if sCode <> '0000'  then
        begin
          Global.SBMessage.ShowMessageModalForm(sMsg);
          UseScanner := True;
        end
        else
        begin
          GetMemberInfo(EmptyStr, AMember); //쿠폰회원
        end;

        FReadStr := EmptyStr;
        BarcodeIn := False;
      end;
    end
    else
    begin
      if Copy(FReadStr, Length(FReadStr), 1) = #$D then
      begin
        FCnt := 0;
        BarcodeIn := True;
        UseScanner := False;

        FReadStr := StringReplace(FReadStr, #$D, '', [rfReplaceAll]); //debug

        Log.D('Scan Barcode', FReadStr);

        AMember := Global.ELoomApi.GetQrcodeAuth(FReadStr, sCode, sMsg);

        if sCode <> '0000'  then
        begin
          Global.SBMessage.ShowMessageModalForm(sMsg);
          UseScanner := True;
        end
        else
        begin
          GetMemberInfo(EmptyStr, AMember); //쿠폰회원
        end;

        FReadStr := EmptyStr;
        BarcodeIn := False;
      end;
    end;

  finally
    FCnt := 0;
  end;
end;
{
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
    if PopUpFullLevel <> pflPeriod then
      Exit;

    SetLength(sBuffer, Count);
    RFIDComport.Read(sBuffer[1], Count);

    nBuffer := Length(sBuffer);
    if (nBuffer = 0) then
      Exit;

    //Global.DeviceConfig.RFIDReader.ReadData := Global.DeviceConfig.RFIDReader.ReadData + sBuffer;

    //Log.D('Scan begin', FReadStr);
    if (sBuffer[nBuffer] = Chr($0d)) then //_CR
    begin
      sReadData := StringToHex(Copy(sBuffer, 1, Pred(nBuffer)));
      Log.D('Scan RFIDComPort: ', sReadData);

      if (Length(sReadData) = 8) then //ex) 2C35E3C1, 227C3B3F
      begin
        FCnt := 0;
        //BarcodeIn := True;
        //UseScanner := False;
        FRFIDUse := True;

        //1080 * 1920 540 1105
        //SetCursorPos(270, 620); //마우스 커서가 가야 할 버튼의 위치
        SetCursorPos(540, 1105); //마우스 커서가 가야 할 버튼의 위치
        Mouse_Event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
        Mouse_Event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);

        GetRFIDMemberInfo(sReadData, AMember);

        //FReadStr := EmptyStr;
        //BarcodeIn := False;
      end;
    end;

  finally
    FCnt := 0;
  end;
end;
}
procedure TFullPopup.ContentLayoutClick(Sender: TObject);
begin
  TouchSound;
end;

procedure TFullPopup.FormCreate(Sender: TObject);
begin
  try
    Comport := TComPort.Create(nil);

    //RFID
    //RFIDComport := TComPort.Create(nil);

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

  //      Comport.OnRxBuf := ComPortRxBuf;
        Comport.OnRxChar := ComPortRxChar;
      end;
      {
      //chy RFID
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
      }
    end;
    BarcodeIn := False;
    UseScanner := False;
    IsPayco := False;

    //chy 2020-11-04 지문인식기 retry 횟수 5회
    FFingerRetry := 0;

    //RFID
    //FRFIDUse := False;
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

    if Comport <> nil then
    begin
      if Comport.Connected then
        Comport.Close;
      Comport.Free;
    end;
    {
    //RFID
    if RFIDComport <> nil then
    begin
      if RFIDComport.Connected then
        RFIDComport.Close;
      RFIDComport.Free;
    end;
    }
   FullPopupCoupon1.CloseFrame;
   FullPopupCoupon1.Free;
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

    //if PopUpFullLevel = pflPayCard then
      //FullPopupPayCard1.DisPlay;
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
var
  sMsg: string;
  MemberTemp: TMemberInfo;
begin
  try
    try
      //chy test
      //AMember.Code := '7';
      //AMember.Name := '박훈';

      Global.SaleModule.Member := AMember;//Global.SaleModule.MemberList[AIndex]

      if Global.SaleModule.Member.Code = EmptyStr then
      begin
        Global.SBMessage.ShowMessageModalForm(MSG_NOT_MEMBER_SEARCH);

        ModalResult := mrCancel;
        Exit;
      end;

      Global.SaleModule.ProductList := Global.ELoomApi.GetMemberProductList(Global.SaleModule.Member.Code, '', sMsg);
      if Global.SaleModule.ProductList.Count = 0 then
      begin
        Global.SBMessage.ShowMessageModalForm(sMsg);
        ModalResult := mrCancel;
      end
      else
      begin
        txtTitle.Text := '회원 정보';
        txtBiomini.Visible := False;
        ImgBiomini.Visible := False;
        ImgCancel.Visible := False;
        FullPopupPeriod1.Visible := False;
        FullPopupCoupon1.Visible := False;
        FullPopupMemberInfo1.Visible := True;
        FullPopupMemberInfo1.txtTasukInfo.Text := Global.SaleModule.Member.Name + '님 환영합니다.';

        if Global.SaleModule.FProfileImg <> EmptyStr then
          FullPopupMemberInfo1.imgProfile.Bitmap.LoadFromFile(Global.SaleModule.FProfileImg);

        FullPopupMemberInfo1.txtNotice.Visible := False;
        if Global.SaleModule.FNoticeMsg <> EmptyStr then
        begin
          FullPopupMemberInfo1.txtNotice.Visible := True;
          FullPopupMemberInfo1.txtNotice.Text := Global.SaleModule.FNoticeMsg;
        end;

        FullPopupMemberInfo1.MemberInfoProductList1.Display;

        ImgBG.Visible := True;
        //ImgSmall.Visible := True;
        //ImgSmall1.Visible := True;
        //ImgBG50.Visible := True;
        //ImgBG50Sub.Visible := True;

        //ImgCenterCancel.Visible := True;

        //txtMemberName.Text := Global.SaleModule.Member.Name;
        UseScanner := False;
      end;
    except
      on E: Exception do
        Log.E('TFullPopup.GetMemberInfo', E.Message);
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

procedure TFullPopup.ImgBiominiClick(Sender: TObject);
begin
  FullPopupCoupon1.Visible := False;
  ImgBiomini.Visible := False;
  txtTime.Visible := False;
  PopUpFullLevel := pflPeriod;
  ShowFullPopup;
end;

procedure TFullPopup.ImgCancelClick(Sender: TObject);
begin
  CloseFormStrMrCancel;
end;

procedure TFullPopup.ImgCenterCancelClick(Sender: TObject);
begin
  CloseFormStrMrCancel;
end;

procedure TFullPopup.ImgXGolfPhoneClick(Sender: TObject);
begin
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
    {
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

procedure TFullPopup.SetScannerUsb(ACode: string);
begin

end;

procedure TFullPopup.SetTimeText(ATime: Integer);
begin
  FullPopupSelectTime1.SetText(ATime);
end;

procedure TFullPopup.ShowFullPopup;
var
  AMemberTm: TMemberInfo; //쿠폰회원 테스트용-주석처리 필수
begin
  try
    Log.D('TFullPopup.ShowFullPopup', 'Begin');
  //  if not (PopUpFullLevel in [pflCoupon, pflPeriod, pflPromo]) then
    if not (PopUpFullLevel in [pflPeriod]) then
      txtTime.Visible := True;

    Top1.lblDay.Text := FormatDateTime('yyyy-mm-dd', now);
    Top1.lblTime.Text := FormatDateTime('hh:nn', now);

    if PopUpFullLevel = pflProduct then
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
      //ImgAddProduct.Visible := True;
      ImgCancel.Position.Y := 1060;
    end
    else if PopUpFullLevel = pflCoupon then
    begin

      if not Global.Config.NoDevice then
      begin
        if Global.Config.Scanner.Port <> 0 then
          Comport.Open;
      end;

      txtTitle.Text := '회원 인증';

      ImgBiomini.Visible := True;
      ImgCancel.Visible := True;

      FullPopupCoupon1.txtTasukInfo.Text := Global.SaleModule.TeeBoxInfo.FloorNm + ' ' + Global.SaleModule.TeeBoxInfo.Name + '번';
      if Global.SaleModule.TeeBoxInfo.ZoneCode = 'O' then
        FullPopupCoupon1.txtTasukInfo.Text := FullPopupCoupon1.txtTasukInfo.Text + ' (좌타)';
      FullPopupCoupon1.Visible := True;
      UseScanner := True;

    end
    else if PopUpFullLevel = pflCheckIn then
    begin

      if not Global.Config.NoDevice then
      begin
        if Global.Config.Scanner.Port <> 0 then
          Comport.Open;
      end;

      txtTitle.Text := '체크인';

      ImgBiomini.Visible := True;
      ImgCancel.Visible := True;

      FullPopupCoupon1.txtTasukInfo.Text := '';
      FullPopupCoupon1.Text4.Visible := False;
      FullPopupCoupon1.Visible := True;
      UseScanner := True;
    end
    else if PopUpFullLevel in [pflPrint, pflTeeBoxPrint] then
    begin // FullPopupPrint1
      //FullPopupPrint1.txtTasukInfo.Text := Format('%dF %s번', [Global.SaleModule.TeeBoxInfo.High, Global.SaleModule.TeeBoxInfo.Mno]);
      FullPopupPrint1.txtTasukInfo.Text := Global.SaleModule.TeeBoxInfo.FloorNm + ' ' + Global.SaleModule.TeeBoxInfo.Name + '번';
      if Global.SaleModule.TeeBoxInfo.ZoneCode = 'O' then
        FullPopupPrint1.txtTasukInfo.Text := FullPopupPrint1.txtTasukInfo.Text + ' (좌타)';

      if PopUpFullLevel = pflTeeBoxPrint then
        FullPopupPrint1.Text.Text := '기기 하단의 프린터로 타석배정표가 출력되었습니다.'
  //    else if Global.SaleModule.SelectProduct.Product_Div = PRODUCT_TYPE_D then
      {
      else if Global.SaleModule.SelectProduct.Code <> EmptyStr then
      begin
        FullPopupPrint1.Text.Text := '기기 하단의 프린터로 카드 영수증과';
        FullPopupPrint1.Text1.Text := '타석배정표가 출력되었습니다.';
      end
      }
      else
        txtTitle.Text := '결제 완료';
      FullPopupPrint1.Visible := True;
      ImgBG.Visible := False;
      ImgSmall.Visible := True;
      ImgSmall1.Visible := True;
      Global.SaleModule.Print.PrintThread.PrintList.Add(Global.SaleModule.SetPrintData);
      Global.SaleModule.Print.PrintThread.Resume;
    end
    else if PopUpFullLevel = pflPeriod then
    begin  // FullPopupPeriod1

      //chy RFID
      if not Global.Config.NoDevice then
      begin
        {
        if Global.Config.RFID.Port <> 0 then
        begin
          //Log.D('TFullPopup.RFIDComport', 'Open');
          RFIDComport.Open;
        end;
        }
      end;

      txtTitle.Text := '회원 인증';

      if Global.SaleModule.TeeBoxInfo.TasukNo = 0 then
      begin
        FullPopupPeriod1.txtTasukInfo.Text := '';
        FullPopupPeriod1.Text4.Visible := False;
      end
      else
      begin
        FullPopupPeriod1.txtTasukInfo.Text := Global.SaleModule.TeeBoxInfo.FloorNm + ' ' + Global.SaleModule.TeeBoxInfo.Name + '번';
        if Global.SaleModule.TeeBoxInfo.ZoneCode = 'O' then
          FullPopupPeriod1.txtTasukInfo.Text := FullPopupPeriod1.txtTasukInfo.Text + ' (좌타)';
      end;

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
    else if PopUpFullLevel = pflMemberFingerInsert then
    begin
      txtTitle.Text := '지문 등록';
      FullPopupPeriod1.txtTasukInfo.Text := '';
      FullPopupPeriod1.Text4.Visible := False;
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
    else if PopUpFullLevel = pflMemberProduct then
    begin
      txtTitle.Text := '회원권 선택하기';

      BackRectangle.Visible := True;
      CallRectangle.Visible := True;
      HomeRectangle.Visible := True;
      txtBiomini.Visible := False;
      ImgBiomini.Visible := False;
      FullPopupMemberInfo1.Visible := False;
      FullPopupPeriod1.Visible := False;
      FullPopupCoupon1.Visible := True;
      FullPopupCoupon1.Layout.Visible := False;
      FullPopupCoupon1.ActivePage := 1;
      FullPopupCoupon1.Display;

      ImgCenterCancel.Position.Y := 1060;
      ImgCenterCancel.Visible := True;

      ImgBG.Visible := False;
      ImgBG50.Visible := True;
      ImgBG50Sub.Visible := True;

      ImgSmall.Visible := False;
      ImgSmall1.Visible := False;

      txtMemberName.Text := Global.SaleModule.Member.Name;
      UseScanner := False;
    end
    else // FullPopupSelectTime1
    begin
      txtTitle.Text := '시간 선택';
      FullPopupSelectTime1.Visible := True;
      FullPopupSelectTime1.Time := 8;
      FullPopupSelectTime1.Display;
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
label ReUnion, ReUnionAdd;
var
  iRv: Integer;
  AMsg: string;
  panel: TPanel;
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

    if FCnt = 0.5 then
    begin
      if PopUpFullLevel = pflPeriod then
      begin
        TimerFull.Enabled := False;

        ReUnion :

        //RFID
        //if FRFIDUse = True then
          //Exit;

        if Global.SaleModule.UCBioBSPHelper.SearchMemberFinger then
        begin
          GetMemberInfo(EmptyStr, Global.SaleModule.Member);
        end
        else
        begin

          //RFID
          //if FRFIDUse = True then
            //Exit;

          //chy 2020-11-04 재시도 간격1초, 3회까지 자동재시도->2회 01-27 이종섭과장 요청
          Inc(FFingerRetry);
          if FFingerRetry > 2 then
          begin
            Global.SBMessage.ShowMessageModalForm('일치하는 지문이 없습니다.');
            Log.D('FFingerRetry', '2 / 일치하는 지문이 없습니다');
            FFingerRetry := 0;

            //RFID
            //if FRFIDUse = False then
            begin
              CloseFormStrMrCancel;
              Log.D('pflPeriod', 'CloseFormStrMrCancel 1');
            end;
          end
          else
          begin
            if Global.SBMessage.ShowMessageModalForm('일치하는 지문이 없습니다.', False, 30, True, True) then
            begin
              goto ReUnion;
              Log.D('pflPeriod', 'ReUnion');
            end
            else
            begin
              //RFID
              //if FRFIDUse = False then
              begin
                CloseFormStrMrCancel;
                Log.D('pflPeriod', 'CloseFormStrMrCancel 2');
              end;
            end;
          end;

        end;

      end
      else if PopUpFullLevel = pflMemberFingerInsert then
      begin
        TimerFull.Enabled := False;

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
      else if PopUpFullLevel = pflSelectTime then
      begin
        if FullPopupSelectTime1.ItemList.Count = 0 then
        begin
          Global.SBMessage.ShowMessageModalForm('선택 가능한 시간이 없습니다.');
          CloseFormStrMrCancel;
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

end.
