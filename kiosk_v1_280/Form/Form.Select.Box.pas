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
    SortLayout_5: TLayout;
    rrSort1: TRoundRect;
    txtSort1: TText;
    rrSort2: TRoundRect;
    txtSort2: TText;
    rrSort3: TRoundRect;
    txtSort3: TText;
    rrSort4: TRoundRect;
    txtSort4: TText;
    FingerImage: TImage;
    ImgSlideRectangle: TRectangle;
    Bottom1: TBottom;
    Rectangle2: TRectangle;
    SelectBoxFloor1: TSelectBoxFloor;
    SelectBoxProduct1: TSelectBoxProduct;
    SelectBoxTopMap1: TSelectBoxTopMap;
    ImgTeeBoxColor2: TImage;
    rrMoveTmAdd: TRoundRect;
    txtTeeboxMove: TText;
    TimerPrint: TTimer;
    Text6: TText;
    TeeboxMore: TRectangle;
    Image1: TImage;
    Text7: TText;
    TeeboxBack: TRectangle;
    Image2: TImage;
    Text8: TText;
    rrSort5: TRoundRect;
    txtSort5: TText;
    SortLayout_4: TLayout;
    rrSort1_4: TRoundRect;
    txtSort1_4: TText;
    rrSort2_4: TRoundRect;
    txtSort2_4: TText;
    rrSort3_4: TRoundRect;
    txtSort3_4: TText;
    rrSort4_4: TRoundRect;
    txtSort4_4: TText;
    rrSort5_4: TRoundRect;
    txtSort5_4: TText;
    Text2: TText;
    rtTeeboxAdvice: TRectangle;
    TimerDelay: TTimer;
    ImgTeeBoxColor2_Pastel: TImage;
    LayoutBallBack: TLayout;
    Image4: TImage;
    Rectangle3: TRectangle;
    txtUpdate: TText;
    recCallTestBtn: TRectangle;
    recCallTest: TRectangle;
    Image3: TImage;
    Text3: TText;
    rrParkingPrint: TRoundRect;
    txtParkingPrint: TText;
    rrFacility: TRoundRect;
    txtFacility: TText;

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
    procedure txtSort1Click(Sender: TObject);
    procedure ComPortRxChar(Sender: TObject; Count: Integer);
    procedure rrMoveTmAddClick(Sender: TObject);
    procedure TimerPrintTimer(Sender: TObject);
    procedure TeeboxMoreClick(Sender: TObject);
    procedure TeeboxBackClick(Sender: TObject);
    procedure txtSort5Click(Sender: TObject);
    procedure TimerDelayTimer(Sender: TObject);
    procedure recCallTestBtnClick(Sender: TObject);
    procedure txtParkingPrintClick(Sender: TObject);
    procedure txtFacilityClick(Sender: TObject);

  private
    { Private declarations }
    FActiveFloor: Integer;
    FActivePage: Integer;

    FTimerInc: Integer;
    FIntro: Integer;

    FShowInfo: Boolean;
    FWork: Boolean;
    FBackCnt: Integer;
    FCallCnt: Integer; // 포스 알리미 테스트용

    FSortList: TList<TRoundRect>;
    FTextList: TList<TText>;
    FReadStr: string;
    FBarcodeIn: Boolean;

    FIntroDelay: Boolean; //씨아이테크 키오스크
    FIntroDelayCnt: Integer; //씨아이테크 키오스크

    procedure Clear;
    procedure SortTeeBox(AIndex: Integer);
    procedure SearchTeeBoxReservationInfo(ACode: string);
  public
    { Public declarations }

    procedure SelectTeeBox(ATeeBoxInfo: TTeeBoxInfo);
    procedure SelectBunkerPutting;

    procedure ChangeFloor(AFloor, APage: Integer; AChangeMap: Boolean = False; AIntroCntReset: Boolean = True);
    procedure ChangSortType;

    procedure ShowErrorMsg(AMsg: string);
    procedure Animate(Index: Integer);
    function SaleProduct: Boolean;
    function SaleProductTCM: Boolean;
    function SaleProductAdvertPopup: Boolean;
    procedure SetSelectBoxSliderText(AText: string);
    function ChangBottomImg: Integer;

    function AdvertMemberView: Boolean;

    function NewMember: Boolean;

    function CheckIn: Boolean;

    property ActiveFloor: Integer read FActiveFloor write FActiveFloor;
    property ActivePage: Integer read FActivePage write FActivePage;
    property Work: Boolean read FWork write FWork;
    property BackCnt: Integer read FBackCnt write FBackCnt;
    property CallCnt: Integer read FCallCnt write FCallCnt;
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
  
  ActiveFloor := Global.Config.ActiveFloor; //시작층

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

  rrMoveTmAdd.Visible := Global.Move_TEST;
  rtTeeboxAdvice.Visible := Global.Config.TeeboxAdvice;

  //chy 씨아이테크 키오스크
  FIntroDelay := False;
  FIntroDelayCnt := 0;
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

  if (Global.Config.Store.StoreCode = 'T0001') or (Global.Config.Store.StoreCode = 'T0002') then
    ImgTeeBoxColor1.Visible := True
  else
  begin
    if Global.Config.Store.StoreCode = 'B9001' then //파스텔골프클럽
      ImgTeeBoxColor2_Pastel.Visible := True
    else
      ImgTeeBoxColor2.Visible := True;
  end;

  //SelectBoxTopMap1 5개층으로 1개층 추가 -> top: 15 -52(층40 간격12) = -37 로 변경
  if Global.Config.Store.StoreCode = 'BF001' then //두성골프클럽
    text1.Visible := False; // 타석현황


  { 모바일 될때까지 임시 보류
  //체크인 버튼 추가로 인해 버튼 구성 2가지 타입
  if (Global.Config.Store.StoreCode = 'T0001') or (Global.Config.Store.StoreCode = 'A8001') then
  begin
    SortLayout_4.Visible := False;
    SortLayout_5.Visible := True;
  end
  else    }
  begin
    SortLayout_4.Visible := True;
    SortLayout_5.Visible := False;

    //chy 2020-11-02 JMS 동반타석 않보이게 조치
    if Global.Config.Store.StoreCode = 'A3001' then
    begin
      rrSort4_4.Visible := False;
    end;

    //체크인 버튼
    rrSort5_4.Visible := False;
    if Global.Config.CheckInUse = True then
    begin
      rrSort4_4.Visible := False;
      rrSort5_4.Visible := True;
      rrSort5_4.Position.Y := 35;
    end;

    //시설이용권
    rrFacility.Visible := False;
    if (Global.Config.PaymentAdd = True) then //시설이용권 판매 2023-06-27
    begin
      rrSort4_4.Visible := False;

      if Global.Config.CheckInUse = True then
      begin
        rrSort3_4.Visible := False; //지정시간순

        rrFacility.Visible := True;
        rrFacility.Position.X := 545;
        rrFacility.Position.Y := 35;
      end
      else
      begin
        rrSort5_4.Visible := False;

        rrFacility.Visible := True;
        rrFacility.Position.Y := 35;
      end;
    end;

  end;
  {
  rrParkingPrint.Visible := False;
  if (Global.Config.Store.StoreCode = 'A8001') then //쇼골프
    rrParkingPrint.Visible := True;
  }

  FReadStr := EmptyStr;
  FBarcodeIn := False;
  FShowInfo := False;
  FBackCnt := 0;
  FCallCnt := 0;

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

    if SortLayout_4.Visible = True then
    begin
      SortList.Add(rrSort1_4);
      SortList.Add(rrSort2_4);
      SortList.Add(rrSort4_4);
      SortList.Add(rrSort3_4);
    end
    else
    begin
      SortList.Add(rrSort1);
      SortList.Add(rrSort2);
      SortList.Add(rrSort4);
      SortList.Add(rrSort3);
    end;

    TextList := TList<TText>.Create;
    if SortLayout_4.Visible = True then
    begin
      TextList.Add(txtSort1_4);
      TextList.Add(txtSort2_4);
      TextList.Add(txtSort4_4);
      TextList.Add(txtSort3_4);
    end
    else
    begin
      TextList.Add(txtSort1);
      TextList.Add(txtSort2);
      TextList.Add(txtSort4);
      TextList.Add(txtSort3);
    end;
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
  CallCnt := 0;
  TouchSound;
  SortTeeBox(1);
  ChangeFloor(2, 1, True);
  Exit;
  SortTeeBox(2);

  Exit;
  Global.SaleModule.PopUpLevel := plAuthentication;

  if not ShowPopup('BackImageClick/plAuthentication') then
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

    if not ShowPopup('BackRectangleClick/plAuthentication') then
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
//  TouchSound;
  try
    FTimerInc := 0;
    Timer.Enabled := False;

    Global.SaleModule.CallAdminTest;
  finally
    Timer.Enabled := True;
  end;
end;

function TSelectBox.ChangBottomImg: Integer;
begin
  Result := Bottom1.ChangeImg;
end;

procedure TSelectBox.ChangeFloor(AFloor, APage: Integer; AChangeMap: Boolean; AIntroCntReset: Boolean);
begin
  BackCnt := 0;
  CallCnt := 0;

  if AIntroCntReset = True then
    IntroCnt := 0;

  ActiveFloor := AFloor;
  ActivePage := APage;
  try
    if (Global.Config.Store.StoreCode = 'T0001') or (Global.Config.Store.StoreCode = 'T0002') then
      HomeRectangle.Visible := (AFloor <> 2) or (Global.SaleModule.TeeBoxSortType in [tstLowTime, tst2TeeBox, tstTime]);

    if (Global.Config.Store.StoreCode = 'A8001') or (Global.Config.Store.StoreCode = 'AD001') then //쇼골프,한강
    begin
      if APage = 1 then
      begin
        TeeboxMore.Visible := True;
        TeeboxBack.Visible := False;
      end
      else
      begin
        TeeboxMore.Visible := False;
        TeeboxBack.Visible := True;
      end;
    end;

    SelectBoxFloor1.SelectFloor(AFloor);

    if (Global.Config.StoreType = '2') and (AFloor = 3) then
      SelectBoxProduct1.DisplayBunkerPutting
    else
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

procedure TSelectBox.TeeboxBackClick(Sender: TObject);
begin
  ChangeFloor(ActiveFloor, 1);
end;

procedure TSelectBox.TeeboxMoreClick(Sender: TObject);
begin
  ChangeFloor(ActiveFloor, 2);
end;

procedure TSelectBox.ChangSortType;
begin
  try
    IntroCnt := 0;
    if Global.SaleModule.TeeBoxSortType in [tstLowTime, tstTime] then
    begin
      Global.SaleModule.AllTeeBoxShow := True;
      {if False then
        SelectBoxFloor1.ChangeLayoutMarginsLeft(505)
      else }
        SelectBoxFloor1.ChangeLayoutMarginsLeft(330);
      ActiveFloor := -1;
    end
    else
    begin
      Global.SaleModule.AllTeeBoxShow := False;
      {if False then
        SelectBoxFloor1.ChangeLayoutMarginsLeft(260)
      else  }
        SelectBoxFloor1.ChangeLayoutMarginsLeft(330);

      if ActiveFloor = -1 then
      begin
        ActiveFloor := Global.Config.ActiveFloor;
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

    ActiveFloor := Global.Config.ActiveFloor;

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

procedure TSelectBox.ComPortRxChar(Sender: TObject; Count: Integer);
var
  TempBuff: string;
begin
  try
    if FBarcodeIn then
      Exit;
    {
    Comport.ReadStr(TempBuff, Count);

    FReadStr := FReadStr + TempBuff;

    if Copy(FReadStr, Length(FReadStr), 1) = #$D then
    begin
      FBarcodeIn := True;
      FReadStr := StringReplace(FReadStr, #$D, '', [rfReplaceAll]);
      SearchTeeBoxReservationInfo(FReadStr);
      FReadStr := EmptyStr;
      FBarcodeIn := False;
    end;    }
  except
    on E: Exception do
      Log.E('TSelectBox.ComPortRxChar', E.Message);
  end;
end;

procedure TSelectBox.HomeImageClick(Sender: TObject);
begin
  TouchSound;
end;

function TSelectBox.NewMember: Boolean;
label ReProduct;
begin
  try
    Result := False;

    //회원정보 입력
    //if not ShowNewMemberInfo then //후킹방식
    if not ShowNewMemberInfoTT then
      Exit;

    Global.SaleModule.PopUpFullLevel := pflNewMemberFinger;
    if ShowFullPopup(False, 'TSelectBox.NewMember 1') = mrCancel then
    begin
      Exit;
    end;

    // 회원신규등록시 성공하면 결과값으로 member_no(member.code) 회원번호 받아옴. SaleModule.member 에 담음
    if not Global.Database.AddNewMember then
    begin
      Log.E('AddMember', 'False');
      ShowErrorMsg(MSG_NEWMEMBER_FAIL);
      Exit;
    end;

    ReProduct :

    if (Global.SaleModule.AdvertPopupType = apMember) then
    begin
      //판매유도 팝업의 신규회원
    end
    else
    begin
      //타석선택후 신규회원
      Global.SaleModule.PopUpLevel := plNewMemberProduct; //기간권, 쿠폰 선택 화면
      if not ShowPopup('NewMember/plNewMemberProduct') then
      begin
        if not Global.Database.TeeBoxHold(False) then
        begin
          //Log.E('TeeBoxHold False', '실패');
        end;
        Global.SaleModule.PopUpLevel := plNone; //Clear;
        Exit;
      end;
    end;

    if not SaleProduct then
      goto ReProduct;

    if Global.SaleModule.NewMemberItemType = mitCoupon then
      Global.SBMessage.ShowMessageModalForm('쿠폰', True, 30)
    else
      Global.SBMessage.ShowMessageModalForm('기간', True, 30);

    Result := True;
  finally

  end;

end;

procedure TSelectBox.rrMoveTmAddClick(Sender: TObject);
var
  ATeeBoxInfo: TTeeBoxInfo;
  sErrMsg: string;
begin

  exit;

  try
    Global.SaleModule.SaleDataClear; // SelectTeeBox  Begin
    Global.SaleModule.MiniMapCursor := True;

    FBackCnt := 0;
    FCallCnt := 0;
    try
      Log.D('TeeBoxMove', 'Begin !');

      Work := True;
      IntroCnt := 0;

      // 타석상태 요청 중지위해
      ATeeBoxInfo.TasukNo := 0;
      Global.SaleModule.TeeBoxInfo := ATeeBoxInfo;

      //바코드 타석정보
      Global.SaleModule.PopUpFullLevel := pflTeeboxMove;
      if ShowFullPopup(False, 'TSelectBox.TeeBoxMove 1') <> mrOk then
        Exit;

      //현재 배정표로 읽은 타석 홀드
      if not Global.LocalApi.TeeboxMoveHold(True) then
      begin
        ShowErrorMsg(MSG_HOLD_TEEBOX_ERROR);
        Exit;
      end;

      Global.SaleModule.PopUpLevel := plTeeboxChange;
      if not ShowPopup('rrMoveTmAddClick/plTeeboxChange') then
      begin
        if not Global.LocalApi.TeeboxMoveHold(False) then
        begin
          //Log.E('TeeBoxHold False', '실패');
        end;
        Global.SaleModule.PopUpLevel := plNone; //Clear;
        Exit;
      end;

      if Global.SaleModule.TeeboxMenuType = tmNone then
        Exit;

      if Global.SaleModule.TeeboxMenuType = tmMove then
      begin
        if not ShowTeeBoxMove then
        begin
          if not Global.LocalApi.TeeboxMoveHold(False) then
          begin
          end;

          Global.SaleModule.PopUpLevel := plNone; //Clear;
          Exit;
        end
        else
        begin

          Global.SaleModule.SetPrepareMin;
          if not Global.Database.TeeBoxReserveMove then
          begin
            Log.E('TeeBoxReserveMove', '예약이동 실패');
          end
          else
          begin
            Global.SaleModule.PopUpFullLevel := pflTeeBoxPrint;
            ShowFullPopup(False, 'TSelectBox.TeeBoxMove 2');
          end;

          if not Global.Database.TeeBoxHold(False) then
            Log.E('TeeBoxHold False', '실패');
          if not Global.LocalApi.TeeboxMoveHold(False) then
            Log.E('TeeBoxMoveHold False', '실패');

        end;
      end
      else if Global.SaleModule.TeeboxMenuType = tmTimeAdd then
      begin

        //end_dt가 null
        //ATeeBoxInfo := Global.Teebox.GetTeeBoxRecordInfo(Global.SaleModule.TeeBoxMoveInfo.Mno);
        Global.SaleModule.TeeBoxInfo := Global.SaleModule.TeeBoxMoveInfo;

        Global.SaleModule.memberItemType := mitAdd;
        Global.SaleModule.PopUpFullLevel := pflPeriod;

        SaleProduct;

      end;

    finally
      Log.D('TeeBoxMove', 'End');
      Global.TeeBox.GetGMTeeBoxList;
      FTimerInc := IfThen(Global.Config.AD.USE, TIMER_3, TIMER_5);
      Global.SaleModule.SaleDataClear; // SelectTeeBox  End
      Work := False;
    end;
  except
    on E: Exception do
      Log.E(ClassName, E.Message);
  end;

end;

function TSelectBox.SaleProduct: Boolean;
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

    if (Global.SaleModule.MemberItemType in [mitperiod, mitCoupon, mitDay]) and (Global.SaleModule.PaymentAddType = patNone) then
    begin

      if Global.Config.XGolfStore = True then
      begin
        //2021-06-14 캐슬렉스 XGolf 회원 적용. 회원/비회원 구분
        bView := False;
        if (Global.SaleModule.memberItemType = mitDay) and (Global.Config.XGolfStoreNonMember = True) then
          bView := True;

        if (Global.SaleModule.memberItemType in [mitperiod, mitCoupon]) and (Global.Config.XGolfStoreMember = True) then
          bView := True;

        if bView = True then
        begin
          if (Global.SaleModule.Member.Code <> EmptyStr) or (not Global.SaleModule.Member.XGolfMember) then
          begin
            Global.SaleModule.PopUpLevel := plXGolf;

            if ShowPopup('SaleProduct/plXGolf') then
            begin
              Global.SaleModule.PopUpLevel := plNone;
              Global.SaleModule.PopUpFullLevel := pflQR; //Xgolf 회원인증

              if ShowFullPopup(False, 'TSelectBox.SaleProduct') = mrOk then
                Global.SaleModule.VipDisCount := True;
            end;
          end;
        end;

      end;

    end;

    // Application.Exception 의심되서 판매폼에서 여기로 옮김 2020.01.09 JHJ
    SelectBox.ChangBottomImg;

    if ShowSaleProduct then
    begin
      Global.SaleModule.SaleCompleteProc;

      if Global.SaleModule.NewMemberItemType = mitCoupon then
      begin
        Global.SaleModule.PopUpFullLevel := pflNewMemberQRSend;
        ShowFullPopup(False, 'TSelectBox.NewMemberQRSend');
      end;

      Clear;
    end
    else
    begin
      if Global.SaleModule.PaymentAddType <> patNone then
        Exit;

      if not Global.Database.TeeBoxHold(False) then
        Log.E('TeeBoxHold False', '실패');

      if Global.SaleModule.NewMemberItemType <> mitNone then
        Exit;
    end;

    Result := True;
  finally

  end;
end;
{
function TSelectBox.SaleProductTCM: Boolean;
var
  AMember: TMemberInfo;
  bChk: Boolean;

  Index: Integer;
  StartTime, EndTime, NowTime: string;
  AProduct, AProductTM: TProductInfo;
  sCode, sMsg: String;
begin
  Result := False;

  try

    //스마틱스 상품 여부 확인
    bChk := False;
    for Index := 0 to Global.SaleModule.SaleList.Count - 1 do
    begin
      AProduct := Global.SaleModule.SaleList[Index];

      if AProduct.Product_Div <> PRODUCT_TYPE_D then
        Continue;

      if AProduct.Alliance_code = GCD_SMARTIX_CODE then // 스마틱스 00007
      begin
        bChk := True;
        Break;
      end;
    end;

    if bChk = False then
    begin
      ShowErrorMsg('온라인 상품이 없습니다.');
      Exit;
    end;

    //선택된 타석의 구역구분 포함여부
    if not (Pos(Global.SaleModule.TeeBoxInfo.ZoneCode, AProduct.AvailableZoneCd) > 0) then
    begin
      ShowErrorMsg('해당 타석에서는 사용할수 없습니다.');
      Exit;
    end;

    if global.Config.ProductTime = True then // 타석선택시간 기준 타석상품 표출
      NowTime := FormatDateTime('yyyymmddhhnn', now)
    else
    begin
      if Global.SaleModule.TeeBoxInfo.BtweenTime <> 0 then //타석 전체 잔여시간
        NowTime := FormatDateTime('yyyymmdd', now) + StringReplace(Global.SaleModule.TeeBoxInfo.End_Time, ':', '', [rfReplaceAll]) + '00'
      else
        NowTime := FormatDateTime('yyyymmddhhnn', now);
    end;

    StartTime := StringReplace(AProduct.Start_Time, ':', '', [rfReplaceAll]);
    EndTime := StringReplace(AProduct.End_Time, ':', '', [rfReplaceAll]);

    bChk := False;
    if StartTime > EndTime then // 익일종료
    begin
      if not ((StartTime <= Copy(NowTime, 9, 4)) or (Copy(NowTime, 9, 4) <= EndTime)) then
        bChk := True;
    end
    else
    begin
      if not ((StartTime <= Copy(NowTime, 9, 4)) and (Copy(NowTime, 9, 4) <= EndTime)) then
        bChk := True;
    end;

    if bChk = True then
    begin
      ShowErrorMsg('해당 상품의 이용시간이 아닙니다.');
      Exit;
    end;

    //해당 상품 현재 사용가능여부
    AProductTM := Global.Database.GetTeeBoxProductTime(AProduct.Code, sCode, sMsg);
    if sCode <> '0000' then
    begin
      ShowErrorMsg(sMsg);
      Exit;
    end;

    AProduct.Limit_Product_Yn := AProductTM.Limit_Product_Yn;
    AProduct.One_Use_Time := AProductTM.One_Use_Time;

    if Global.SaleModule.AddProduct(AProduct) = False then
      Exit;

    Log.D('제휴상품', '-----------------------------------------------------');
    Log.D('제휴상품', AProduct.Code);
    Log.D('제휴상품', AProduct.Name);
    Log.D('제휴상품', AProduct.Start_Time);
    Log.D('제휴상품', AProduct.End_Time);
    Log.D('제휴상품', '-----------------------------------------------------');

    // 바코드 인식
    Global.SaleModule.PromotionType := pttSmartix;

    if not (ShowFullPopup(False, 'SaleProductTCM') = mrOk) then
      Exit;

    // 스마틱스 인증 성공 후
    Global.SaleModule.PromotionType := pttNone;
    Global.SaleModule.SaleCompleteProc;

    Result := True;
  finally

  end;
end;
}

function TSelectBox.SaleProductTCM: Boolean;
var
  AMember: TMemberInfo;
  bChk, bAuth: Boolean;

  Index: Integer;
  StartTime, EndTime, NowTime: string;
  AProduct, AProductTM: TProductInfo;
  sCode, sMsg, sErrorMsg, sRecvMsg: String;
begin
  Result := False;
  bAuth := False;

  try

    //스마틱스 상품 여부 확인
    bChk := False;
    for Index := 0 to Global.SaleModule.SaleList.Count - 1 do
    begin
      AProduct := Global.SaleModule.SaleList[Index];

      if AProduct.Product_Div <> PRODUCT_TYPE_D then
        Continue;

      if AProduct.Alliance_code = GCD_SMARTIX_CODE then // 스마틱스 00007
      begin
        bChk := True;
        Break;
      end;
    end;

    if bChk = False then
    begin
      ShowErrorMsg('온라인 상품이 없습니다.');
      Exit;
    end;

    // 바코드 인식
    Global.SaleModule.PromotionType := pttSmartix;
    if not (ShowFullPopup(False, 'SaleProductTCM') = mrOk) then
      Exit;

    bAuth := True;

    // 스마틱스 인증 성공 후 상품 매칭
    bChk := False;
    for Index := 0 to Global.SaleModule.SaleList.Count - 1 do
    begin
      AProduct := Global.SaleModule.SaleList[Index];

      if AProduct.Product_Div <> PRODUCT_TYPE_D then
        Continue;

      if AProduct.Alliance_code <> GCD_SMARTIX_CODE then
        Continue;

      if AProduct.Alliance_item_code = Global.SaleModule.SmartixRmsTkttypId then
      begin
        bChk := True;
        Break;
      end;
    end;

    if bChk = False then
    begin
      sErrorMsg := '해당하는 권종 상품이 없습니다.(권종코드:' + Global.SaleModule.SmartixRmsTkttypId + ')';
      Exit;
    end;

    //선택된 타석의 구역구분 포함여부
    if not (Pos(Global.SaleModule.TeeBoxInfo.ZoneCode, AProduct.AvailableZoneCd) > 0) then
    begin
      sErrorMsg := '해당 타석에서는 사용할수 없습니다.';
      Exit;
    end;

    if global.Config.ProductTime = True then // 타석선택시간 기준 타석상품 표출
      NowTime := FormatDateTime('yyyymmddhhnn', now)
    else
    begin
      if Global.SaleModule.TeeBoxInfo.BtweenTime <> 0 then //타석 전체 잔여시간
        NowTime := FormatDateTime('yyyymmdd', now) + StringReplace(Global.SaleModule.TeeBoxInfo.End_Time, ':', '', [rfReplaceAll]) + '00'
      else
        NowTime := FormatDateTime('yyyymmddhhnn', now);
    end;

    StartTime := StringReplace(AProduct.Start_Time, ':', '', [rfReplaceAll]);
    EndTime := StringReplace(AProduct.End_Time, ':', '', [rfReplaceAll]);

    bChk := False;
    if StartTime > EndTime then // 익일종료
    begin
      if not ((StartTime <= Copy(NowTime, 9, 4)) or (Copy(NowTime, 9, 4) <= EndTime)) then
        bChk := True;
    end
    else
    begin
      if not ((StartTime <= Copy(NowTime, 9, 4)) and (Copy(NowTime, 9, 4) <= EndTime)) then
        bChk := True;
    end;

    if bChk = True then
    begin
      sErrorMsg := '해당 상품의 이용시간이 아닙니다.';
      Exit;
    end;

    //해당 상품 현재 사용가능여부
    AProductTM := Global.Database.GetTeeBoxProductTime(AProduct.Code, sCode, sMsg);
    if sCode <> '0000' then
    begin
      sErrorMsg := sMsg;
      Exit;
    end;

    AProduct.Limit_Product_Yn := AProductTM.Limit_Product_Yn;
    AProduct.One_Use_Time := AProductTM.One_Use_Time;

    if Global.SaleModule.AddProduct(AProduct) = False then
    begin
      sErrorMsg := '해당상품 등록에 실패하였습니다';
      Exit;
    end;

    Log.D('제휴상품', '-----------------------------------------------------');
    Log.D('제휴상품', AProduct.Code);
    Log.D('제휴상품', AProduct.Name);
    Log.D('제휴상품', AProduct.Start_Time);
    Log.D('제휴상품', AProduct.End_Time);
    Log.D('제휴상품', '-----------------------------------------------------');


    // 스마틱스 인증 성공 및 상품 매칭 성공
    Global.SaleModule.PromotionType := pttNone;
    Global.SaleModule.SaleCompleteProc;

    Result := True;
  finally
    if Result = False then
    begin
      if bAuth = True then
      begin
         if Global.SaleModule.ApplySmartix(False, Global.SaleModule.allianceNumber, sRecvMsg) then
           ShowErrorMsg(sErrorMsg)
         else
           ShowErrorMsg(sErrorMsg + #13 + '사용처리 취소를 위해 카운터에 문의 해주세요');
      end
      else
      begin
        if sErrorMsg <> '' then
          ShowErrorMsg(sErrorMsg);
      end;
    end;
  end;
end;

function TSelectBox.SaleProductAdvertPopup: Boolean;
begin
  try
    Result := False;

    // Application.Exception 의심되서 판매폼에서 여기로 옮김 2020.01.09 JHJ
    SelectBox.ChangBottomImg;

    if ShowSaleProduct then
    begin
      Global.SaleModule.SaleCompleteProc;

      if Global.SaleModule.NewMemberItemType = mitCoupon then
      begin
        Global.SaleModule.PopUpFullLevel := pflNewMemberQRSend;
        ShowFullPopup(False, 'TSelectBox.NewMemberQRSend');
      end;

      Clear;
    end
    else
    begin
      if not Global.Database.TeeBoxHold(False) then
        Log.E('TeeBoxHold False', '실패');

      if Global.SaleModule.NewMemberItemType <> mitNone then
        Exit;
    end;

    Result := True;
  finally

  end;
end;

procedure TSelectBox.SearchTeeBoxReservationInfo(ACode: string);
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

procedure TSelectBox.SelectBoxProduct1Text3Click(Sender: TObject);
begin
  txtSort1Click(Sender);
end;

procedure TSelectBox.SelectTeeBox(ATeeBoxInfo: TTeeBoxInfo);
label ReReserve;
var
  AModalResult: TModalResult;
  AMsg, sMsgPostion: String;

begin

{
try
  Screen.Cursor := crHourGlass;
  ...
finally
  Screen.Cursor := crDefault;;
end;
}
  try

    //chy 씨아이테크 키오스크
    if Global.Config.Print.PrintType = 'SEWOO' then
    begin
      if FIntroDelay = True then
      begin
        inc(FIntroDelayCnt);
        if FIntroDelayCnt > 1 then
        begin
          FIntroDelay := False;
          FIntroDelayCnt := 0;
        end;
        Exit;
      end;
    end;

    Global.SaleModule.SaleDataClear; // SelectTeeBox  Begin
    Global.SaleModule.MiniMapCursor := True;

    FBackCnt := 0;
    FCallCnt := 0;
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

      //jhj 트로스프린터에러체크
      if (Global.Config.Store.StoreCode = 'A3001') then
      begin
        if Global.Config.Print.PrintType <> 'SEWOO' then
        begin
          AMsg := EmptyStr;
          if not Global.SaleModule.Print.PrintCheckStatus(AMsg) then
          begin
            Global.SBMessage.ShowMessageModalForm (AMsg + #13#10 + '프린터 오류입니다.' + #13#10 + '관리자를 호출하여 주시기 바랍니다.');
            Exit;
          end;
        end;
      end;

      // 타석 홀드
      Global.SaleModule.TeeBoxInfo := ATeeBoxInfo;
      Global.SaleModule.VipTeeBox := ATeeBoxInfo.Vip;

      if not Global.Database.TeeBoxHold then
      begin
        ShowErrorMsg(MSG_HOLD_TEEBOX_ERROR);
        Exit;
      end;

      //chy 2021-11-02 쇼골프 우선적용
      if (Global.Config.Store.StoreCode = 'A8001') then
      begin
        if (Global.Config.Store.Emergency = 'Y') or (Global.Config.Store.DNSFail = 'Y') then
        begin
          if not Global.Database.TeeBoxHold(False) then
          begin
            //Log.E('TeeBoxHold False', '실패');
          end;
          Global.SBMessage.ShowMessageModalForm ('통신장애가 발생하였습니다.' + #13#10 + '관리자에게 문의하여 주세요.');
          Exit;
        end;
      end;

      // 영업시간, 휴장체크- 상품별 배정시간이 달라 상품선택시로 이동
      if Global.Config.AD.USE = False then //A1001 스타
      begin
        if StoreCloseCheck then
        begin
          if not Global.Database.TeeBoxHold(False) then
          begin
            //Log.E('TeeBoxHold False', '실패');
          end;
          Exit;
        end;
      end
      else
      begin
        if StoreClosureCheck then //영업시간초과, 휴장체크
        begin
          if not Global.Database.TeeBoxHold(False) then
          begin
            //Log.E('TeeBoxHold False', '실패');
          end;
          Exit;
        end;
      end;

      Global.SaleModule.PopUpLevel := plMemberItemType;
      Log.D('SelectTeeBox', 'MemberItemType');

      if not ShowPopup('SelectTeeBox/plMemberItemType') then
      begin
        if not Global.Database.TeeBoxHold(False) then
        begin
          //Log.E('TeeBoxHold False', '실패');
        end;
        Global.SaleModule.PopUpLevel := plNone; //Clear;
        Exit;
      end;

      if Global.SaleModule.memberItemType = mitNone then
        Exit;

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
                  //Log.E('TeeBoxHold False', '실패');
                end;
              end
              else
              begin
                Global.SaleModule.PopUpFullLevel := pflTeeBoxPrint;
                ShowFullPopup(False, 'TSelectBox.SelectTeeBox 2');
              end;
            end;

          end;

          if not Global.Database.TeeBoxHold(False) then
          begin
            //Log.E('TeeBoxHold False', '실패');
          end;

        end
        else if AModalResult = mrTryAgain then
          SaleProduct;
      end
      else if Global.SaleModule.memberItemType = mitDay then
      begin
        //일일타석 결제전 추천회원권 표시. 추천회원권 선택시 빠져나옴
        SaleProduct;

        //추천회원권 선택후
        if Global.SaleModule.AdvertPopupType = apMember then
        begin
          if Global.SaleModule.memberItemType = mitCoupon then //지문,QR인증
            AdvertMemberView;

          if Global.SaleModule.memberItemType = mitNew then //회원가입
            NewMember;
        end;

      end
      else if Global.SaleModule.memberItemType = mitAlliance then
      begin
        if Global.Config.AllianceSmartix = True then
        begin
          if SaleProductTCM = False then
          begin
            if not Global.Database.TeeBoxHold(False) then
              Log.E('TeeBoxHold False', '실패');
          end;
        end
        else
          SaleProduct;
      end
      else if Global.SaleModule.memberItemType = mitNew then // newmember
      begin
        if not Global.Database.TeeBoxHold(False) then
        begin
          //Log.E('TeeBoxHold False', '실패');
        end;

        // 타석상태 요청 중지위해
        ATeeBoxInfo.TasukNo := 0;
        Global.SaleModule.TeeBoxInfo := ATeeBoxInfo;

        NewMember;
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

procedure TSelectBox.SelectBunkerPutting;
label ReReserve;
var
  AModalResult: TModalResult;
  AMsg: String;
  ATeeBoxInfo: TTeeBoxInfo;
begin
  try
    //Global.SaleModule.SaleDataClear; // SelectTeeBox  Begin
    Global.SaleModule.MiniMapCursor := True;

    FBackCnt := 0;
    FCallCnt := 0;
    try
      Log.D('SelectBunkerPutting', 'Begin - ');

      Work := True;
      IntroCnt := 0;

      ATeeBoxInfo.TasukNo := 0;
      Global.SaleModule.TeeBoxInfo := ATeeBoxInfo;

      //벙커/퍼팅 배정가능여부
      if Global.database.BunkerPossible = False then
      begin
        Global.SBMessage.ShowMessageModalForm('동시 배정인원수를 초과하였습니다.');
        Exit;
      end;

      if Global.SaleModule.memberItemType = mitBunkerMember then
      begin
        Global.SaleModule.PopUpFullLevel := pflBunkerMember;

        AModalResult := ShowFullPopup(False, 'TSelectBox.SelectBunkerPutting 1');
        if AModalResult = mrIgnore then
        begin
          BackImageClick(nil);
        end
        else if AModalResult = mrOk then
        begin
          SaleProduct;
        end;

      end
      else
        SaleProduct;

    finally
      Log.D('SelectBunkerPutting', 'End');
      Global.TeeBox.GetGMTeeBoxList;

      //FTimerInc := IfThen(Global.Config.AD.USE, TIMER_3, TIMER_5);
      FTimerInc := TIMER_3;
      Global.SaleModule.SaleDataClear; // SelectTeeBox  End
      Work := False;
      TimerPrint.Enabled := True;
    end;
  except
    on E: Exception do
      Log.E(ClassName, E.Message);
  end;
end;

procedure TSelectBox.SetSelectBoxSliderText(AText: string);
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

procedure TSelectBox.ShowErrorMsg(AMsg: string);
begin
  Global.SBMessage.ShowMessageModalForm(AMsg);
end;

procedure TSelectBox.txtFacilityClick(Sender: TObject);
var
  rTeeBoxInfo: TTeeBoxInfo;
  AModalResult: TModalResult;
begin

  try

    Work := True;
    // 타석상태 요청(타석현황 화면 갱신) 중지위해
    rTeeBoxInfo.TasukNo := 0;
    rTeeBoxInfo.ZoneCode := 'G';
    rTeeBoxInfo.BtweenTime := 0;
    Global.SaleModule.TeeBoxInfo := rTeeBoxInfo;

    Global.SaleModule.PopUpLevel := plMemberItemType;
    Log.D('SelectTeeBox', 'MemberItemType');

    if not ShowPopup('txtFacilityClick/plMemberItemType') then
    begin
      Global.SaleModule.PopUpLevel := plNone; //Clear;
      Exit;
    end;

    if Global.SaleModule.memberItemType = mitNone then
      Exit;

    if Global.SaleModule.memberItemType in [mitperiod, mitCoupon] then
    begin
      if Global.SaleModule.memberItemType = mitperiod then
      begin
        Global.SaleModule.PaymentAddType := patFacilityPeriod;
        Global.SaleModule.PopUpFullLevel := pflPeriod;
      end
      else
      begin
        Global.SaleModule.PaymentAddType := patFacilityPeriod;
        Global.SaleModule.PopUpFullLevel := pflCoupon;
      end;

      AModalResult := ShowFullPopup(False, 'TSelectBox.SelectTeeBox 1');
      if AModalResult in [mrOk,  mrCancel] then
      begin
        if AModalResult = mrOk then
        begin
          if Global.SaleModule.SelectProduct.Code = EmptyStr then
            Exit;

          if not Global.Database.UseFacilityProduct(Global.SaleModule.SelectProduct.ProductBuyCode) then
          begin
            Log.E('UseFacilityProduct', 'False');
            Exit;
          end;

          Global.SaleModule.PopUpFullLevel := pflPrint;
          ShowFullPopup(False, 'TSelectBox.SelectTeeBox 2');
        end;

      end;
    end
    else if Global.SaleModule.memberItemType = mitDay then
    begin
      Global.SaleModule.PaymentAddType := patFacilityDay;
      SaleProduct;
    end;

  finally
    Global.SaleModule.SaleDataClear;
    Work := False;
  end;

end;

procedure TSelectBox.txtParkingPrintClick(Sender: TObject);
var
  rTeeBoxInfo: TTeeBoxInfo;
begin
  try
    Work := True;

    // 타석상태 요청(타석현황 화면 갱신) 중지위해
    rTeeBoxInfo.TasukNo := 0;
    Global.SaleModule.TeeBoxInfo := rTeeBoxInfo;

    Global.SaleModule.PopUpLevel := plParkingPrint;
    if not ShowPopup('txtParkingPrintClick/plParkingPrint') then
      Exit;

    Global.SaleModule.PopUpFullLevel := pflParkingPrint;
    ShowFullPopup(False, 'TSelectBox.txtParkingPrintClick');

    Global.SaleModule.SaleDataClear; // SelectTeeBox  End
  finally
    Work := False;
  end;
end;

procedure TSelectBox.txtSort1Click(Sender: TObject);
begin
  TouchSound;
  SortTeeBox(TText(Sender).Tag);
end;

procedure TSelectBox.TimerDelayTimer(Sender: TObject);
begin
  if FIntroDelay = True then
  begin
    FIntroDelay := False;
    FIntroDelayCnt := 0;
  end;
  TimerDelay.Enabled := False;
end;

procedure TSelectBox.TimerPrintTimer(Sender: TObject);
begin
  try
    TimerPrint.Enabled := False;
    if Global.Config.Print.PrintType = 'SEWOO' then
    begin
      Global.SaleModule.Print.PrintStatus := '';
      Log.D('TimerPrintTimer', 'PrintStatusCheck check');
      Global.SaleModule.Print.PrintStatusCheck;
    end;
  except
    on E: Exception do
      Log.E('TimerPrintTimer', E.Message);
  end;
end;

procedure TSelectBox.TimerTimer(Sender: TObject);
var
  Index: Integer;
begin

  // 시스템 종료
  if Global.Config.SystemShutdown = True then
  begin
    if (FormatDateTime('hh:nn', now) = Global.Config.Store.StoreEndTime) then //"22:00"
    begin
      Log.D('SystemShutdown', '');
      MyExitWindows(EWX_SHUTDOWN);
      Exit;
    end;
  end;

  // 새벽 5시에 프로그램 리부팅 2020.01.14 JHJ
  if (FormatDateTime('hhnnss', now) > '050000') and (FormatDateTime('hhnnss', now) < '050010') then
  begin
    MyExitWindows(EWX_REBOOT);
    Exit;
  end;

  if Global.TeeBox.TeeboxBallBack = True then
    LayoutBallBack.Visible := True
  else
    LayoutBallBack.Visible := False;

  if Global.SBMessage.PrintError then
    Exit;

    //현재 선택된 솔트 글자 색상변환2021-09-06
  for Index := 0 to SortList.Count - 1 do
  begin
    if SortList[Index].Fill.Color = $FF00CE13 then
    begin
      if TextList[Index].TextSettings.FontColor = $FFFFFFFF then
        TextList[Index].TextSettings.FontColor := $FF00CE13
      else
        TextList[Index].TextSettings.FontColor := $FFFFFFFF;
    end;
  end;

  if not Work then
  begin
    //자정에 상품정보 재수신
    if (FormatDateTime('hhnnss', now) > '000000') and (FormatDateTime('hhnnss', now) < '000500') then
    begin
      if Global.SaleModule.FResetProductList = False then
      begin
        Work := True;
        Global.SaleModule.MasterReception(2);
        Global.SaleModule.FResetProductList := True;
        Work := False;
      end;
    end;

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
        if Global.Config.Print.PrintType = 'SEWOO' then
        begin
          FIntroDelay := True;
          TimerDelay.Enabled := True;
        end;

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
  CallCnt := 0;
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

function TSelectBox.AdvertMemberView: Boolean;
var
  AModalResult: TModalResult;
begin
  try
    Result := False;

    //지문/qr인증-기간,쿠폰인지 확인 불가, 쿠폰으로 처리
    Global.SaleModule.PopUpFullLevel := pflCoupon;

    AModalResult := ShowFullPopup(False, 'TSelectBox.SelectTeeBox 1');
    if AModalResult = mrIgnore then
    begin
      BackImageClick(nil);
    end
    else if AModalResult = mrTryAgain then
      SaleProductAdvertPopup;

    if not Global.Database.TeeBoxHold(False) then
    begin
      //Log.E('TeeBoxHold False', '실패');
    end;

    Result := True;
  finally

  end;
end;

//2021-08-04 chekcIn
procedure TSelectBox.txtSort5Click(Sender: TObject);
var
  rTeeBoxInfo: TTeeBoxInfo;
  AModalResult: TModalResult;
begin

  //chy test chekcIn
  //CheckIn;

  // 타석상태 요청(타석현황 화면 갱신) 중지위해
  rTeeBoxInfo.TasukNo := 0;
  Global.SaleModule.TeeBoxInfo := rTeeBoxInfo;

  Global.SaleModule.PopUpFullLevel := pflCheckInFinger;
  AModalResult := ShowFullPopup(False, 'TSelectBox.txtCheckInClick');
  if AModalResult = mrIgnore then
  begin
    BackImageClick(nil);
    Exit;
  end;

  if AModalResult = mrOk then
  begin
    Global.LocalApi.TeeBoxCheckIn;

    Global.SaleModule.PopUpFullLevel := pflCheckInPrint;
    ShowFullPopup(False, 'TSelectBox.txtCheckInClick 2');
  end;

  Global.SaleModule.SaleDataClear; // SelectTeeBox  End

end;

function TSelectBox.CheckIn: Boolean;
var
  rTeeBoxInfo: TTeeBoxInfo;
  AModalResult: TModalResult;
begin

  // 타석상태 요청(타석현황 화면 갱신) 중지위해
  rTeeBoxInfo.TasukNo := 0;
  Global.SaleModule.TeeBoxInfo := rTeeBoxInfo;

  Global.SaleModule.PopUpFullLevel := pflCheckInQR;
  AModalResult := ShowFullPopup(False, 'TSelectBox.txtCheckInClick');
  if AModalResult = mrIgnore then
  begin
    BackImageClick(nil);
    Exit;
  end;

  if AModalResult = mrOk then
  begin
    Global.LocalApi.TeeBoxCheckIn;

    Global.SaleModule.PopUpFullLevel := pflCheckInPrint;
    ShowFullPopup(False, 'TSelectBox.txtCheckInClick 2');
  end;

  Global.SaleModule.SaleDataClear; // SelectTeeBox  End
end;

procedure TSelectBox.recCallTestBtnClick(Sender: TObject);
begin
  IntroCnt := 0;
  CallCnt := CallCnt + 1;

  if CallCnt = 5 then
  begin

    CallCnt := 0;
    if recCallTest.Visible = True then
      recCallTest.Visible := False
    else
      recCallTest.Visible := True;
  end;
end;

end.
