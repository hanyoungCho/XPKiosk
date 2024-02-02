unit Form.Select.Box;

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
  TSelectBox = class(TForm)
    ImgLayout: TLayout;
    Layout: TLayout;
    TopLayout: TLayout;
    MapLayout: TLayout;
    FloorLayout: TLayout;
    BottomLayout: TLayout;
    BodyLayout: TLayout;
    Timer: TTimer;
    BGImage: TImage;
    Top1: TTop;
    BottomRectangle: TRectangle;
    BackImage: TImage;
    BackRectangle: TRectangle;
    HomeRectangle: TRectangle;
    CallRectangle: TRectangle;
    CallImage: TImage;
    CallText: TText;
    HomeImage: TImage;
    HomeText: TText;
    Text1: TText;
    Rectangle: TRectangle;
    Rectangle1: TRectangle;
    ImgTeeBoxColor1: TImage;
    txtLowTeeBox: TText;
    SortLayout: TLayout;
    RoundRect1: TRoundRect;
    Text2: TText;
    RoundRect2: TRoundRect;
    Text3: TText;
    RoundRect4: TRoundRect;
    Text4: TText;
    RoundRect5: TRoundRect;
    Text5: TText;
    FingerImage: TImage;
    ImgSlideRectangle: TRectangle;
    Bottom1: TBottom;
    Rectangle2: TRectangle;
    ComPort: TComPort;
    SelectBoxFloor1: TSelectBoxFloor;
    SelectBoxProduct1: TSelectBoxProduct;
    SelectBoxTopMap1: TSelectBoxTopMap;
    ImgTeeBoxColor2: TImage;
    TimerPrint: TTimer;
    txtURL: TText;
    rrCheckIn: TRoundRect;
    txtCheckIn: TText;
    rrFingerInsert: TRoundRect;
    txtFingerInsert: TText;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    procedure TimerTimer(Sender: TObject);
    procedure BackImageClick(Sender: TObject);
    procedure SelectBoxProduct1Text3Click(Sender: TObject);
    procedure CallImageClick(Sender: TObject);
    procedure HomeImageClick(Sender: TObject);
    procedure BottomRectangleClick(Sender: TObject);
    procedure BackRectangleClick(Sender: TObject);
    procedure Text2Click(Sender: TObject);
    procedure TimerPrintTimer(Sender: TObject);
    procedure txtCheckInClick(Sender: TObject);
    procedure txtFingerInsertClick(Sender: TObject);

  private
    { Private declarations }
    FActiveFloor: Integer;
    FActivePage: Integer;
    FTimerInc: Integer;
    FShowInfo: Boolean;
    FWork: Boolean;
    FBackCnt: Integer;
    FIntro: Integer;
    FSortList: TList<TRoundRect>;
    FTextList: TList<TText>;
    FReadStr: string;
    FBarcodeIn: Boolean;

    FIntroDelay: Boolean;

    procedure Clear;
    procedure SortTeeBox(AIndex: Integer);

  public
    { Public declarations }

    procedure SelectTeeBox(ATeeBoxInfo: TTeeBoxInfo);

    procedure ChangeFloor(AFloor, APage: Integer; AChangeMap: Boolean = False; AIntroCntReset: Boolean = True);
    procedure ChangSortType;

    procedure ShowErrorMsg(AMsg: string);
    procedure Animate(Index: Integer);

    procedure SetSelectBoxSliderText(AText: string);
    function ChangBottomImg: Integer;

    property ActiveFloor: Integer read FActiveFloor write FActiveFloor;
    property ActivePage: Integer read FActivePage write FActivePage;
    property Work: Boolean read FWork write FWork;
    property BackCnt: Integer read FBackCnt write FBackCnt;
    property IntroCnt: Integer read FIntro write FIntro;
    property TimerInc: Integer read FTimerInc write FTimerInc;
    property SortList: TList<TRoundRect> read FSortList write FSortList;
    property TextList: TList<TText> read FTextList write FTextList;
  end;

var
  SelectBox: TSelectBox;

implementation

uses
  uGlobal, uCommon, uConsts, fx.Logging, Form.Intro, uFunction;

{$R *.fmx}

procedure TSelectBox.FormCreate(Sender: TObject);
begin
  ActiveFloor := 1;
  FTimerInc := 0;
  IntroCnt := 0;
  Work := False;

  {$IFDEF DEBUG}
  txtURL.Visible := True;
  txtURL.text := Global.sUrl;
  {$ENDIF}

  FIntroDelay := False;
end;

procedure TSelectBox.FormDestroy(Sender: TObject);
begin
  try
    SelectBoxProduct1.CloseFrame;
    SelectBoxFloor1.CloseFrame;
    SelectBoxTopMap1.CloseFrame;

    SortList.Free;
    TextList.Free;
  except
    on E: Exception do
    begin
      Log.E('TSelectBox.FormDestroy', E.Message);
    end;
  end;
end;

procedure TSelectBox.FormShow(Sender: TObject);
var
  AError: Boolean;
begin

  ImgTeeBoxColor2.Visible := True;

  FReadStr := EmptyStr;
  FBarcodeIn := False;
  FShowInfo := False;
  FBackCnt := 0;

  Global.SaleModule.SaleDataClear;  // FormShow
  Global.TeeBox.GetGMTeeBoxList;
  Global.TeeBox.SampleThread.Resume;
  SelectBoxFloor1.Display;

  Timer.Enabled := True;
  Global.SaleModule.TeeBoxSortType := tstDefault;
  ChangeFloor(ActiveFloor, 1, True);

  if SortList = nil then
  begin
    SortList := TList<TRoundRect>.Create;
    SortList.Add(RoundRect1);
    SortList.Add(RoundRect2);
    SortList.Add(RoundRect5);
    SortList.Add(RoundRect4);

    TextList := TList<TText>.Create;
    TextList.Add(Text2);
    TextList.Add(Text3);
    TextList.Add(Text5);
    TextList.Add(Text4);
  end;

  Bottom1.Display(False);

  AError := True;
end;


procedure TSelectBox.Animate(Index: Integer);
begin
  SelectBoxProduct1.Animate(SelectBoxProduct1.ItemList[Index]);
end;

procedure TSelectBox.BackImageClick(Sender: TObject);
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

procedure TSelectBox.BackRectangleClick(Sender: TObject);
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

procedure TSelectBox.BottomRectangleClick(Sender: TObject);
begin
  TouchSound;
end;

procedure TSelectBox.CallImageClick(Sender: TObject);
begin
  //TouchSound;
  try
    FTimerInc := 0;
    Timer.Enabled := False;
    Global.SaleModule.CallAdmin;
  finally
    Timer.Enabled := True;
  end;
end;

function TSelectBox.ChangBottomImg: Integer;
begin
  Result := Bottom1.ChangeImg; //2021-06-14 복합일 경우 인트로에서 하단이미지 참조함. 없애면 않됨
end;

procedure TSelectBox.ChangeFloor(AFloor, APage: Integer; AChangeMap: Boolean; AIntroCntReset: Boolean);
begin
  BackCnt := 0;

  if AIntroCntReset = True then
    IntroCnt := 0;

  ActiveFloor := AFloor;
  ActivePage := APage;

  try

    SelectBoxFloor1.SelectFloor(AFloor);
    SelectBoxProduct1.Display(AFloor, APage);

    if Global.SaleModule.TeeBoxSortType in [tst2TeeBox, tstLowTime, tstTime] then
      Global.SaleModule.MainItemMapUse := True
    else
      Global.SaleModule.MainItemMapUse := False;

    if not ((AFloor > 0) and (Global.SaleModule.TeeBoxSortType = tstLowTime)) then
      SelectBoxTopMap1.DisplayFloor;

  except
    on E: Exception do
    begin
      Log.E(ClassName, E.Message);
    end;
  end;
end;

procedure TSelectBox.ChangSortType;
begin
  try
    IntroCnt := 0;
    if Global.SaleModule.TeeBoxSortType in [tstLowTime, tstTime] then

    begin
      Global.SaleModule.AllTeeBoxShow := True;
      if False then
        SelectBoxFloor1.ChangeLayoutMarginsLeft(505)
      else
        SelectBoxFloor1.ChangeLayoutMarginsLeft(330);
      ActiveFloor := -1;
    end
    else
    begin
      Global.SaleModule.AllTeeBoxShow := False;
      if False then
        SelectBoxFloor1.ChangeLayoutMarginsLeft(260)
      else
        SelectBoxFloor1.ChangeLayoutMarginsLeft(330);

      if ActiveFloor = -1 then
      begin
        ActiveFloor := 1;
      end;

    end;
   SelectBoxFloor1.Display;

   ChangeFloor(ActiveFloor, 1, True);
  except
    on E: Exception do
    begin
      Log.E(ClassName, E.Message);
    end;
  end;
end;

procedure TSelectBox.Clear;
begin
  try
    Global.SaleModule.SaleDataClear;  // TSelectBox.Clear
    ActiveFloor := 1;

    if Global.TeeBox.FloorList.Count <> 0 then
      ActiveFloor := Global.TeeBox.FloorList[0];

    SortTeeBox(1);
    SelectBoxFloor1.SelectFloor(ActiveFloor);
    SelectBoxProduct1.Display(ActiveFloor, 1);
  except
    on E: Exception do
    begin
      Log.E('TSelectBox.Clear', E.Message);
    end;
  end;
end;

procedure TSelectBox.HomeImageClick(Sender: TObject);
begin
  TouchSound;
end;

procedure TSelectBox.SelectBoxProduct1Text3Click(Sender: TObject);
begin
  Text2Click(Sender);
end;

procedure TSelectBox.SelectTeeBox(ATeeBoxInfo: TTeeBoxInfo);
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
      Log.D('SelectTeeBox', 'no - ' + IntToStr(ATeeBoxInfo.TasukNo) + ' / ' + ATeeBoxInfo.Name);

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
        ShowErrorMsg(MSG_UPDATE_MEMBER_INFO_FAIL);
        Exit;
      end;

      // 타석 홀드
      Global.SaleModule.TeeBoxInfo := ATeeBoxInfo;
      Global.SaleModule.VipTeeBox := ATeeBoxInfo.Vip;

      if not Global.LocalApi.TeeBoxHold then
      begin
        ShowErrorMsg(MSG_HOLD_TEEBOX_ERROR);
        Exit;
      end;
      {
      // 영업시간, 휴장체크- 상품별 배정시간이 달라 상품선택시로 이동
      if StoreClosureCheck then //영업시간초과, 휴장체크
      begin
        if not Global.LocalApi.TeeBoxHold(False) then
        begin
//          Log.E('TeeBoxHold False', '실패');
        end;
        Exit;
      end;
      }
      Global.SaleModule.PopUpLevel := plMemberItemType;
      Log.D('SelectTeeBox', 'MemberItemType');

      if not ShowPopup then
      begin
        if not Global.LocalApi.TeeBoxHold(False) then
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
        if Global.SaleModule.memberItemType in [mitperiod, mitCoupon] then
        begin
          if Global.SaleModule.memberItemType = mitperiod then
            Global.SaleModule.PopUpFullLevel := pflPeriod
          else
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
                if not Global.LocalApi.TeeBoxListReservation then
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
                  if not Global.LocalApi.TeeBoxHold(False) then
                  begin
//                    Log.E('TeeBoxHold False', '실패');
                  end;
                end
                else
                begin

                  if Global.Config.NoTeeboxTicket = False then
                  begin
                    Global.SaleModule.PopUpFullLevel := pflTeeBoxPrint;
                    ShowFullPopup(False, 'TSelectBox.SelectTeeBox 2');
                  end;

                end;
              end;
            end;

            if not Global.LocalApi.TeeBoxHold(False) then
            begin
//              Log.E('TeeBoxHold False', '실패');
            end;

          end
        end
      end;

    finally
      Log.D('SelectTeeBox', 'End');

      sMsgPostion := 'SelectTeeBox 1';
      Global.TeeBox.GetGMTeeBoxList;
      FTimerInc := IfThen(Global.Config.AD.USE, TIMER_3, TIMER_5);

      sMsgPostion := 'SelectTeeBox 2';
      Global.SaleModule.SaleDataClear; // SelectTeeBox  End
      Work := False;

      sMsgPostion := 'SelectTeeBox 3';
      TimerPrint.Enabled := True;
    end;

  except
    on E: Exception do
      Log.E(ClassName, sMsgPostion + ' / ' + E.Message);
  end;

end;

procedure TSelectBox.SetSelectBoxSliderText(AText: string);
begin
  if not Work then
    SelectBoxProduct1.txtSlider.Text := AText;
end;

procedure TSelectBox.ShowErrorMsg(AMsg: string);
begin
  Global.SBMessage.ShowMessageModalForm(AMsg);
end;

procedure TSelectBox.Text2Click(Sender: TObject);
begin
  TouchSound;
  SortTeeBox(TText(Sender).Tag);
end;

procedure TSelectBox.TimerPrintTimer(Sender: TObject);
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

procedure TSelectBox.TimerTimer(Sender: TObject);
begin

  // 새벽 5시에 프로그램 리부팅
  if (FormatDateTime('hhnnss', now) > '050000') and (FormatDateTime('hhnnss', now) < '050010') then
  begin
    MyExitWindows(EWX_REBOOT);
    Exit;
  end;

  if Global.SBMessage.PrintError then
    Exit;

  if FIntroDelay = True then
    FIntroDelay := False;

  if not Work then
  begin
    if (FTimerInc = 0) and (not FShowInfo) then
    begin
      FShowInfo := True;
      ChangeFloor(ActiveFloor, 1, True);
    end;

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
        FIntroDelay := True;

        IntroCnt := IntroCnt;
      end;
    end;

    if Intro = nil then
      Inc(FIntro);
  end;
end;

procedure TSelectBox.SortTeeBox(AIndex: Integer);
var
  Index: Integer;
begin
  BackCnt := 0;
  IntroCnt := 0;
  if TTeeBoxSortType(AIndex) = tstTime then
  begin
    Global.SaleModule.PopUpFullLevel := pflSelectTime;
    if not (ShowFullPopup(False, 'TSelectBox.SortTeeBox') = mrOk) then
      Exit;
  end;

  Global.SaleModule.TeeBoxSortType := TTeeBoxSortType(AIndex);

  for Index := 0 to SortList.Count - 1 do
  begin
    if (Index + 1) = AIndex then
    begin
      SortList[Index].Fill.Color := $FF00CE13;//$FFFFFFFF;
      TextList[Index].TextSettings.FontColor := $FFFFFFFF;//TAlphaColorRec.Black;// $$FF555555;
    end
    else
    begin
      SortList[Index].Fill.Color := $FFFFFFFF;//$FF555555;
      TextList[Index].TextSettings.FontColor := $FF5C5C5C;//$FFFFFFFF;
    end;
  end;
  ChangSortType;
end;

procedure TSelectBox.txtCheckInClick(Sender: TObject);
var
  rTeeBoxInfo: TTeeBoxInfo;
  AModalResult: TModalResult;
begin
  try
    // 타석상태 요청(타석현황 화면 갱신) 중지위해
    rTeeBoxInfo.TasukNo := 0;
    Global.SaleModule.TeeBoxInfo := rTeeBoxInfo;

    Work := True;
    IntroCnt := 0;

    Global.SaleModule.PopUpFullLevel := pflCheckIn;
    ShowFullPopup(False, 'TSelectBox.txtCheckInClick');

  finally
    Global.SaleModule.SaleDataClear; // SelectTeeBox  End
    Work := False;
  end;
end;

procedure TSelectBox.txtFingerInsertClick(Sender: TObject);
var
  rTeeBoxInfo: TTeeBoxInfo;
  AModalResult: TModalResult;
  sCode, sMsg: String;
begin
  try
    // 타석상태 요청(타석현황 화면 갱신) 중지위해
    rTeeBoxInfo.TasukNo := 0;
    Global.SaleModule.TeeBoxInfo := rTeeBoxInfo;

    Work := True;
    IntroCnt := 0;

    Global.SaleModule.PopUpLevel := plMemberCheck;
    if not ShowPopup then
    begin
      Exit;
    end;

    Global.SaleModule.PopUpFullLevel := pflMemberFingerInsert;
    if ShowFullPopup(False, 'TSelectBox.NewMember 1') = mrCancel then
    begin
      Exit;
    end;

    // 회원 지문 등록 Global.SaleModule.FingerStr
    if not Global.ELoomApi.SetMemberFinger(sCode, sMsg) then
    begin
      ShowErrorMsg(sMsg);
      Exit;
    end
    else
    begin
      Global.SBMessage.ShowMessageModalForm('지문등록이 완료되었습니다.');
    end;

  finally
    Global.SaleModule.SaleDataClear; // SelectTeeBox  End
    Work := False;
  end;

end;

end.
