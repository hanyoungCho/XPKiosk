unit Form.Select_In.Box;

interface

uses
  Uni, uStruct, JSON, IdGlobal, Winapi.Windows,
  Frame.Select.Box.Top.Map, Frame.Select.Box.Floor,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.Ani, FMX.Layouts, FMX.Gestures,
  Frame.Select.Box.Product, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects,
  Frame.Top, Generics.Collections, Frame.Bottom, IdContext,
  IdBaseComponent, IdComponent, IdCustomTCPServer, IdTCPServer, CPort,
  frmmediaTest,
  FMX.Media;

const
  TIMER_3 = 3;
  TIMER_5 = 5;

type
  TSelectBox_In = class(TForm)
    ImgLayout: TLayout;
    Layout: TLayout;
    TopLayout: TLayout;
    BottomLayout: TLayout;
    BodyLayout: TLayout;
    Timer: TTimer;
    BGImage: TImage;
    BottomRectangle: TRectangle;
    BackImage: TImage;
    BackRectangle: TRectangle;
    HomeRectangle: TRectangle;
    CallRectangle: TRectangle;
    CallImage: TImage;
    CallText: TText;
    HomeImage: TImage;
    HomeText: TText;
    Rectangle1: TRectangle;
    ImgTeeBoxColor1: TImage;
    FingerImage: TImage;
    ImgSlideRectangle: TRectangle;
    Bottom1: TBottom;
    Rectangle2: TRectangle;
    ComPort: TComPort;
    SelectBoxProduct1: TSelectBoxProduct;
    ImgTeeBoxColor2: TImage;
    TimerPrint: TTimer;
    Text6: TText;
    Text2: TText;
    rtTeeboxAdvice: TRectangle;
    Top1: TTop;
    Image3: TImage;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    procedure TimerTimer(Sender: TObject);
    procedure BackImageClick(Sender: TObject);
    procedure CallImageClick(Sender: TObject);
    procedure HomeImageClick(Sender: TObject);
    procedure BottomRectangleClick(Sender: TObject);
    procedure BackRectangleClick(Sender: TObject);
    procedure ComPortRxChar(Sender: TObject; Count: Integer);
    procedure TimerPrintTimer(Sender: TObject);
  private
    { Private declarations }
    FActiveFloor: Integer;
    FActivePage: Integer;
    FTimerInc: Integer;
    FShowInfo: Boolean;
    FWork: Boolean;
    FBackCnt: Integer;
    FIntro: Integer;
    FReadStr: string;
    FBarcodeIn: Boolean;

    //chy 씨아이테크 키오스크
    FIntroDelay: Boolean;

    procedure Clear;
    procedure SortTeeBox(AIndex: Integer);
    procedure SearchTeeBoxReservationInfo(ACode: string);
  public
    { Public declarations }

    procedure SelectTeeBox(ATeeBoxInfo: TTeeBoxInfo);

    procedure ChangeFloor(AFloor, APage: Integer; AChangeMap: Boolean = False; AIntroCntReset: Boolean = True);


    procedure ShowErrorMsg(AMsg: string);
    procedure Animate(Index: Integer);
    function SaleProduct: Boolean;
    procedure SetSelectBoxSliderText(AText: string);
    function ChangBottomImg: Integer;

    function AdvertMemberView: Boolean;
    function AdvertEventView: Boolean;

    property ActiveFloor: Integer read FActiveFloor write FActiveFloor;
    property ActivePage: Integer read FActivePage write FActivePage;
    property Work: Boolean read FWork write FWork;
    property BackCnt: Integer read FBackCnt write FBackCnt;
    property IntroCnt: Integer read FIntro write FIntro;
    property TimerInc: Integer read FTimerInc write FTimerInc;
  end;

var
  SelectBox_In: TSelectBox_In;

implementation

uses
  uGlobal, uCommon, uConsts, fx.Logging, Form.Intro, uFunction;

{$R *.fmx}

procedure TSelectBox_In.FormCreate(Sender: TObject);
begin
  ActiveFloor := 1;
  FTimerInc := 0;
  IntroCnt := 0;
  Work := False;

  //chy debug구분용
  if Pos('test', Global.sUrl) > 0 then
  begin
    text6.Visible := True;
    text6.text := Global.sUrl;
  end
  else
  begin
    text6.Visible := False;
  end;

  //chy 씨아이테크 키오스크
  FIntroDelay := False;
end;

procedure TSelectBox_In.FormDestroy(Sender: TObject);
begin
  try
    SelectBoxProduct1.CloseFrame;

    //SortList.Free;
    //TextList.Free;
  except
    on E: Exception do
    begin
      Log.E('TSelectBox.FormDestroy', E.Message);
    end;
  end;
end;

procedure TSelectBox_In.FormShow(Sender: TObject);
var
  AError: Boolean;
begin

  //ImgTeeBoxColor1.Visible := True;
  ImgTeeBoxColor2.Visible := True;

  FReadStr := EmptyStr;
  FBarcodeIn := False;
  FShowInfo := False;
  FBackCnt := 0;

  Global.SaleModule.SaleDataClear;  // FormShow
  Global.TeeBox.GetGMTeeBoxList;
  Global.TeeBox.SampleThread.Resume;

  Timer.Enabled := True;

  ChangeFloor(ActiveFloor, 1, True);

  if Global.SaleModule.AdvertisementListTeeboxUp.Count <> 0 then
    Image3.Bitmap.LoadFromFile(Global.SaleModule.AdvertisementListTeeboxUp[0].FilePath);

  Bottom1.Display(False);

  AError := True;
end;


procedure TSelectBox_In.Animate(Index: Integer);
begin
  SelectBoxProduct1.Animate(SelectBoxProduct1.ItemList[Index]);
end;

procedure TSelectBox_In.BackImageClick(Sender: TObject);
begin
  BackCnt := 0;
  TouchSound;
  SortTeeBox(1);
  ChangeFloor(2, 1, True);
  Exit;
  SortTeeBox(2);

  Exit;
  Global.SaleModule.PopUpLevel := plAuthentication;

  if not ShowPopup then
    Exit;
  Close;
end;

procedure TSelectBox_In.BackRectangleClick(Sender: TObject);
begin
  IntroCnt := 0;
  BackCnt := BackCnt + 1;

  if BackCnt = 5 then
  begin

    BackCnt := 0;
    Global.SaleModule.PopUpLevel := plAuthentication;

    if not ShowPopup then
    begin
      Exit;
    end;

    Close;
  end;
end;

procedure TSelectBox_In.BottomRectangleClick(Sender: TObject);
begin
  TouchSound;
end;

procedure TSelectBox_In.CallImageClick(Sender: TObject);
begin
//  TouchSound;
  try
    FTimerInc := 0;
    Timer.Enabled := False;
    Global.SaleModule.CallAdmin;
  finally
    Timer.Enabled := True;
  end;
end;

function TSelectBox_In.ChangBottomImg: Integer;
begin
  Result := Bottom1.ChangeImg;
end;

//chy 2020-09-29
procedure TSelectBox_In.ChangeFloor(AFloor, APage: Integer; AChangeMap: Boolean; AIntroCntReset: Boolean);
begin
  BackCnt := 0;

  if AIntroCntReset = True then
    IntroCnt := 0;

  ActiveFloor := AFloor;
  ActivePage := APage;
  try
    HomeRectangle.Visible := False;

    SelectBoxProduct1.Display(AFloor, APage);

    Global.SaleModule.MainItemMapUse := False;

  except
    on E: Exception do
    begin
      Log.E(ClassName, E.Message);
    end;
  end;
end;

procedure TSelectBox_In.Clear;
begin
  try
    Global.SaleModule.SaleDataClear;  // TSelectBox.Clear
    ActiveFloor := 1;

    if Global.TeeBox.FloorList.Count <> 0 then
      ActiveFloor := Global.TeeBox.FloorList[0];

    SortTeeBox(1);

    SelectBoxProduct1.Display(ActiveFloor, 1);
  except
    on E: Exception do
    begin
      Log.E('TSelectBox.Clear', E.Message);
    end;
  end;
end;

procedure TSelectBox_In.ComPortRxChar(Sender: TObject; Count: Integer);
var
  TempBuff: string;
begin
  try
    if FBarcodeIn then
      Exit;

    Comport.ReadStr(TempBuff, Count);

    FReadStr := FReadStr + TempBuff;

    if Copy(FReadStr, Length(FReadStr), 1) = #$D then
    begin
      FBarcodeIn := True;
      FReadStr := StringReplace(FReadStr, #$D, '', [rfReplaceAll]);
      SearchTeeBoxReservationInfo(FReadStr);
      FReadStr := EmptyStr;
      FBarcodeIn := False;
    end;
  except
    on E: Exception do
      Log.E('TSelectBox.ComPortRxChar', E.Message);
  end;
end;

procedure TSelectBox_In.HomeImageClick(Sender: TObject);
begin
  TouchSound;
end;

function TSelectBox_In.SaleProduct: Boolean;
var
  AMember: TMemberInfo;
  bView: Boolean;
begin
  try
    Result := False;
    if not Global.SaleModule.MasterReception(1) then
    begin
      Log.D('MasterReception', '1');
      Global.SaleModule.ProgramUse := False;
      ShowErrorMsg(MSG_MASTERDOWN_FAIL);
      Exit;
    end;

    if Global.Config.XGolfStore = True then
    begin
      //XGolf 회원 적용. 회원/비회원 구분
      bView := False;
      if (Global.SaleModule.memberItemType = mitDay) and (Global.Config.XGolfStoreNonMember = True) then
        bView := True;

      if (Global.SaleModule.memberItemType in [mitCoupon]) and (Global.Config.XGolfStoreMember = True) then
        bView := True;

      if bView = True then
      begin
        if (Global.SaleModule.Member.Code <> EmptyStr) or (not Global.SaleModule.Member.XGolfMember) then
        begin
          Global.SaleModule.PopUpLevel := plXGolf;
    //    if Global.SaleModule.memberItemType <> mitDay then
          if ShowPopup then
          begin
            Global.SaleModule.PopUpLevel := plNone;
            Global.SaleModule.PopUpFullLevel := pflQR; //Xgolf 회원인증

            if ShowFullPopup(False, 'TSelectBox.SaleProduct') = mrOk then
              Global.SaleModule.VipDisCount := True
            else
            begin
            end;
          end;

        end;
      end;

    end;

    // Application.Exception 의심되서 판매폼에서 여기로 옮김 2020.01.09 JHJ
    SelectBox_In.ChangBottomImg;

    if ShowSaleProduct then
    begin
      Global.SaleModule.SaleCompleteProc;
      Clear;
    end
    else
    begin
      if not Global.Database.TeeBoxHold(False) then
        Log.E('TeeBoxHold False', '실패');
    end;

    Result := True;
  finally

  end;
end;

procedure TSelectBox_In.SearchTeeBoxReservationInfo(ACode: string);
begin
  try
    try
      Global.Database.TeeBoxReservationInfo(ACode);
      Global.SaleModule.PopUpFullLevel := pflTeeBoxPrint;
      ShowFullPopup(False, 'TSelectBox.SearchTeeBoxReservationInfo');
    except
      on E: Exception do
        Log.E('SearchTeeBoxReservationInfo', E.Message);
    end;
  finally
    Global.SaleModule.SaleDataClear;  // SearchTeeBoxReservationInfo
  end;
end;

procedure TSelectBox_In.SelectTeeBox(ATeeBoxInfo: TTeeBoxInfo);
label ReReserve;
var
  AModalResult: TModalResult;
  AMsg, sMsgPostion: String;

begin

  try

    if FIntroDelay = True then
    begin
      FIntroDelay := False;
      Exit;
    end;

    Global.SaleModule.SaleDataClear; // SelectTeeBox  Begin
    Global.SaleModule.MiniMapCursor := True;

    FBackCnt := 0;
    try
      Log.D('SelectTeeBox', 'no - ' + IntToStr(ATeeBoxInfo.TasukNo) + ' / ' + ATeeBoxInfo.Mno);

      if not Global.SaleModule.ProgramUse then
      begin
        Global.SBMessage.ShowMessageModalForm(MSG_MASTERDOWN_FAIL);
        Exit;
      end;

      Work := True;
      IntroCnt := 0;

      if ATeeBoxInfo.ERR <> 0 then
      begin
        ShowErrorMsg(MSG_ERROR_TEEBOX);
        Exit;
      end;

      if not Global.SaleModule.MasterReception then
      begin
        //Global.SaleModule.ProgramUse := False;   //스타골프랜드 네트워크 상태가 좋지 않아서 막지 않음.
        ShowErrorMsg(MSG_UPDATE_MEMBER_INFO_FAIL);
        Exit;
      end;

      // 타석 홀드
      Global.SaleModule.TeeBoxInfo := ATeeBoxInfo;
      Global.SaleModule.VipTeeBox := ATeeBoxInfo.Vip;
      if not Global.Database.TeeBoxHold then
      begin
        ShowErrorMsg(MSG_HOLD_TEEBOX_ERROR);
        Exit;
      end;

      if StoreClosureCheck then //영업시간초과, 휴장체크
      begin
        if not Global.Database.TeeBoxHold(False) then
        begin
//          Log.E('TeeBoxHold False', '실패');
        end;
        Exit;
      end;

      Global.SaleModule.PopUpLevel := plMemberItemType;
      Log.D('SelectTeeBox', 'MemberItemType');

      if not ShowPopup then
      begin
        if not Global.Database.TeeBoxHold(False) then
        begin
//          Log.E('TeeBoxHold False', '실패');
        end;
        Global.SaleModule.PopUpLevel := plNone; //Clear;
        Exit;
      end;

      if Global.SaleModule.memberItemType = mitNone then
      begin
        Exit;
      end
      else
      begin
        if Global.SaleModule.memberItemType in [mitCoupon] then
        begin
          Global.SaleModule.PopUpFullLevel := pflCoupon;

          ReReserve :

          AModalResult := ShowFullPopup(False, 'TSelectBox.SelectTeeBox 1');
          if AModalResult = mrIgnore then
          begin
            BackImageClick(nil);
          end
          else if AModalResult in [mrOk,  mrCancel] then
          begin
            if AModalResult = mrOk then
            begin
              // 정상으로 서버에 기간, 쿠폰으로 예약완료시 서버에서 타석홀드를 취소한다. 그래도 홀드 취소 날려준다.
              // 배정표 출력 후 Clear;
              if Global.SaleModule.SelectProduct.Code <> EmptyStr then
              begin
                // 예약 배정 등록
                Global.SaleModule.SetPrepareMin;
                if not Global.Database.TeeBoxListReservation then
                begin
                  //실패

                  if not Global.SaleModule.TeeboxTimeError then
                  begin
                    if Global.SBMessage.ShowMessageModalForm('다른 상품으로 배정하시겠습니까?', False) then
                    begin
                      Global.SaleModule.PopUpFullLevel := pflProduct;
                      goto ReReserve;
                    end;
                  end;

                  Log.E('TeeBoxListReservation', '예약배정 실패');
                  if not Global.Database.TeeBoxHold(False) then
                  begin
//                    Log.E('TeeBoxHold False', '실패');
                  end;
                end
                else
                begin
                  Global.SaleModule.PopUpFullLevel := pflTeeBoxPrint;
                  ShowFullPopup(False, 'TSelectBox.SelectTeeBox 2');
//                  Clear;
                end;
              end;
            end;

            if not Global.Database.TeeBoxHold(False) then
            begin
//              Log.E('TeeBoxHold False', '실패');
            end;

          end
          else if AModalResult = mrTryAgain then
            SaleProduct;
        end
        else if Global.SaleModule.memberItemType = mitDay then
        begin
          SaleProduct;
        end;
      end;
      {
      if not Global.Database.TeeBoxHold(False) then
      begin
//        Log.E('TeeBoxHold False', '실패');
      end;
      }
    finally
      Log.D('SelectTeeBox', 'End');

      sMsgPostion := 'SelectTeeBox 1';
      Global.TeeBox.GetGMTeeBoxList;
//      FTimerInc := 5;
      FTimerInc := IfThen(Global.Config.AD.USE, TIMER_3, TIMER_5);

      sMsgPostion := 'SelectTeeBox 2';
      Global.SaleModule.SaleDataClear; // SelectTeeBox  End
//      CloseForm;
      Work := False;
//      SetWindowPos(Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);

      // chy sewoo
      sMsgPostion := 'SelectTeeBox 3';
      TimerPrint.Enabled := True;

    end;
  except
    on E: Exception do
      Log.E(ClassName, sMsgPostion + ' / ' + E.Message);
  end;
end;

procedure TSelectBox_In.SetSelectBoxSliderText(AText: string);
begin
  if not Work then
  begin
//    FingerImage.Visible := not FingerImage.Visible;
//    SelectBoxProduct1.FingerImage.Visible := not SelectBoxProduct1.FingerImage.Visible;
    SelectBoxProduct1.txtSlider.Text := AText;
  end
  else
  begin
//    FingerImage.Visible := True;
//    SelectBoxProduct1.FingerImage.Visible := True;
  end;
end;

procedure TSelectBox_In.ShowErrorMsg(AMsg: string);
begin
  Global.SBMessage.ShowMessageModalForm(AMsg);
end;

procedure TSelectBox_In.TimerPrintTimer(Sender: TObject);
begin

  try
    TimerPrint.Enabled := False;

    Global.SaleModule.Print.PrintStatus := '';
    Global.SaleModule.Print.SewooStatus;

  except
    on E: Exception do
      Log.E('TimerPrintTimer', E.Message);
  end;

end;

procedure TSelectBox_In.TimerTimer(Sender: TObject);
var
  Index: Integer;
begin

  // 새벽 5시에 프로그램 리부팅 2020.01.14 JHJ
  if (FormatDateTime('hhnnss', now) > '050000') and (FormatDateTime('hhnnss', now) < '050010') then
  begin
    MyExitWindows(EWX_REBOOT);
    Exit;
  end;

  //chy sewoo
  if Global.SBMessage.PrintError then
    Exit;

  //chy 씨아이테크 키오스크
  if FIntroDelay = True then
    FIntroDelay := False;

  if not Work then
  begin
    if (FTimerInc = 0) and (not FShowInfo) then
    begin
      FShowInfo := True;
      ChangeFloor(ActiveFloor, 1, True);
    end;

//    if FTimerInc = 5 then
    if FTimerInc = IfThen(Global.Config.AD.USE, TIMER_3, TIMER_5) then
    begin
      FTimerInc := 0;
      ChangeFloor(ActiveFloor, ActivePage, True, False);
    end
    else
      Inc(FTimerInc);

    if (IntroCnt = 40) and True then
    begin
      IntroCnt := 0;
      Clear;

      ChangBottomImg;

      if ShowIntro(Bottom1.Image.Bitmap) then
      begin
        //chy 씨아이테크 키오스크
        FIntroDelay := True;

        IntroCnt := IntroCnt;
      end;
    end;

    if Intro = nil then
      Inc(FIntro);
  end;
end;

procedure TSelectBox_In.SortTeeBox(AIndex: Integer);
var
  Index: Integer;
begin
  BackCnt := 0;
  IntroCnt := 0;
end;

function TSelectBox_In.AdvertMemberView: Boolean;
var
  AModalResult: TModalResult;
begin
  try
    Result := False;

    { //상품 갱신 보류
    if not Global.SaleModule.MasterReception(1) then
    begin
      Log.D('MasterReception', '1');
      Global.SaleModule.ProgramUse := False;
      ShowErrorMsg(MSG_MASTERDOWN_FAIL);
      Exit;
    end;
    }

    //지문/qr인증-기간,쿠폰인지 확인 불가, 쿠폰으로 처리
    Global.SaleModule.PopUpFullLevel := pflCoupon;

    AModalResult := ShowFullPopup(False, 'TSelectBox.SelectTeeBox 1');
    if AModalResult = mrIgnore then
    begin
      BackImageClick(nil);
    end
    else if AModalResult = mrTryAgain then
      SaleProduct;

    if not Global.Database.TeeBoxHold(False) then
    begin
      //Log.E('TeeBoxHold False', '실패');
    end;

    Result := True;
  finally

  end;
end;

function TSelectBox_In.AdvertEventView: Boolean;
var
  AMember: TMemberInfo;
  nSeq: Integer;
begin
  try
    Result := False;

    if global.Config.AdvertEventXGolf = True then
    begin
      Global.SaleModule.PopUpLevel := plXGolf;

      if ShowPopup = False then
        Exit;

      Global.SaleModule.PopUpLevel := plNone;
      Global.SaleModule.PopUpFullLevel := pflQR; //Xgolf 회원인증

      if ShowFullPopup(False, 'TSelectBox.AdvertEventView') <> mrOk then
        Exit;
    end
    else
    begin
      Global.SaleModule.PopUpLevel := plPhone;
      if ShowPopup = False then
        Exit;
    end;

    {
    Global.SaleModule.PopUpLevel := plXGolfEvent;
    if ShowPopup = False then
      Exit;
    }
    if not Global.SBMessage.ShowMessageModalForm('이벤트에 응모 하시겠습니까?', False) then
      Exit;

    nSeq := TAdvertisement(Global.SaleModule.AdvertisementListPopup[0]).Seq;
    Global.Database.SendXGolfEvent(IntToStr(nSeq), Global.SaleModule.Member.XGolfMemberQR, Global.SaleModule.allianceNumber);

    // Application.Exception 의심되서 판매폼에서 여기로 옮김 2020.01.09 JHJ
    //SelectBox.ChangBottomImg; //일단 주석처리

    Global.SBMessage.ShowMessageModalForm('이벤트 응모가 완료되었습니다.');

    Result := True;
  finally

  end;
end;

end.
