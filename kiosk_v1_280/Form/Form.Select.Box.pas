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
    FCallCnt: Integer; // ���� �˸��� �׽�Ʈ��

    FSortList: TList<TRoundRect>;
    FTextList: TList<TText>;
    FReadStr: string;
    FBarcodeIn: Boolean;

    FIntroDelay: Boolean; //��������ũ Ű����ũ
    FIntroDelayCnt: Integer; //��������ũ Ű����ũ

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
  
  ActiveFloor := Global.Config.ActiveFloor; //������

  FTimerInc := 0;
  IntroCnt := 0;
  Work := False;

  //chy debug���п�
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

  //chy ��������ũ Ű����ũ
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
    if Global.Config.Store.StoreCode = 'B9001' then //�Ľ��ڰ���Ŭ��
      ImgTeeBoxColor2_Pastel.Visible := True
    else
      ImgTeeBoxColor2.Visible := True;
  end;

  //SelectBoxTopMap1 5�������� 1���� �߰� -> top: 15 -52(��40 ����12) = -37 �� ����
  if Global.Config.Store.StoreCode = 'BF001' then //�μ�����Ŭ��
    text1.Visible := False; // Ÿ����Ȳ


  { ����� �ɶ����� �ӽ� ����
  //üũ�� ��ư �߰��� ���� ��ư ���� 2���� Ÿ��
  if (Global.Config.Store.StoreCode = 'T0001') or (Global.Config.Store.StoreCode = 'A8001') then
  begin
    SortLayout_4.Visible := False;
    SortLayout_5.Visible := True;
  end
  else    }
  begin
    SortLayout_4.Visible := True;
    SortLayout_5.Visible := False;

    //chy 2020-11-02 JMS ����Ÿ�� �ʺ��̰� ��ġ
    if Global.Config.Store.StoreCode = 'A3001' then
    begin
      rrSort4_4.Visible := False;
    end;

    //üũ�� ��ư
    rrSort5_4.Visible := False;
    if Global.Config.CheckInUse = True then
    begin
      rrSort4_4.Visible := False;
      rrSort5_4.Visible := True;
      rrSort5_4.Position.Y := 35;
    end;

    //�ü��̿��
    rrFacility.Visible := False;
    if (Global.Config.PaymentAdd = True) then //�ü��̿�� �Ǹ� 2023-06-27
    begin
      rrSort4_4.Visible := False;

      if Global.Config.CheckInUse = True then
      begin
        rrSort3_4.Visible := False; //�����ð���

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
  if (Global.Config.Store.StoreCode = 'A8001') then //�����
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

    if (Global.Config.Store.StoreCode = 'A8001') or (Global.Config.Store.StoreCode = 'AD001') then //�����,�Ѱ�
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

    //ȸ������ �Է�
    //if not ShowNewMemberInfo then //��ŷ���
    if not ShowNewMemberInfoTT then
      Exit;

    Global.SaleModule.PopUpFullLevel := pflNewMemberFinger;
    if ShowFullPopup(False, 'TSelectBox.NewMember 1') = mrCancel then
    begin
      Exit;
    end;

    // ȸ���űԵ�Ͻ� �����ϸ� ��������� member_no(member.code) ȸ����ȣ �޾ƿ�. SaleModule.member �� ����
    if not Global.Database.AddNewMember then
    begin
      Log.E('AddMember', 'False');
      ShowErrorMsg(MSG_NEWMEMBER_FAIL);
      Exit;
    end;

    ReProduct :

    if (Global.SaleModule.AdvertPopupType = apMember) then
    begin
      //�Ǹ����� �˾��� �ű�ȸ��
    end
    else
    begin
      //Ÿ�������� �ű�ȸ��
      Global.SaleModule.PopUpLevel := plNewMemberProduct; //�Ⱓ��, ���� ���� ȭ��
      if not ShowPopup('NewMember/plNewMemberProduct') then
      begin
        if not Global.Database.TeeBoxHold(False) then
        begin
          //Log.E('TeeBoxHold False', '����');
        end;
        Global.SaleModule.PopUpLevel := plNone; //Clear;
        Exit;
      end;
    end;

    if not SaleProduct then
      goto ReProduct;

    if Global.SaleModule.NewMemberItemType = mitCoupon then
      Global.SBMessage.ShowMessageModalForm('����', True, 30)
    else
      Global.SBMessage.ShowMessageModalForm('�Ⱓ', True, 30);

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

      // Ÿ������ ��û ��������
      ATeeBoxInfo.TasukNo := 0;
      Global.SaleModule.TeeBoxInfo := ATeeBoxInfo;

      //���ڵ� Ÿ������
      Global.SaleModule.PopUpFullLevel := pflTeeboxMove;
      if ShowFullPopup(False, 'TSelectBox.TeeBoxMove 1') <> mrOk then
        Exit;

      //���� ����ǥ�� ���� Ÿ�� Ȧ��
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
          //Log.E('TeeBoxHold False', '����');
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
            Log.E('TeeBoxReserveMove', '�����̵� ����');
          end
          else
          begin
            Global.SaleModule.PopUpFullLevel := pflTeeBoxPrint;
            ShowFullPopup(False, 'TSelectBox.TeeBoxMove 2');
          end;

          if not Global.Database.TeeBoxHold(False) then
            Log.E('TeeBoxHold False', '����');
          if not Global.LocalApi.TeeboxMoveHold(False) then
            Log.E('TeeBoxMoveHold False', '����');

        end;
      end
      else if Global.SaleModule.TeeboxMenuType = tmTimeAdd then
      begin

        //end_dt�� null
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
        //2021-06-14 ĳ������ XGolf ȸ�� ����. ȸ��/��ȸ�� ����
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
              Global.SaleModule.PopUpFullLevel := pflQR; //Xgolf ȸ������

              if ShowFullPopup(False, 'TSelectBox.SaleProduct') = mrOk then
                Global.SaleModule.VipDisCount := True;
            end;
          end;
        end;

      end;

    end;

    // Application.Exception �ǽɵǼ� �Ǹ������� ����� �ű� 2020.01.09 JHJ
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
        Log.E('TeeBoxHold False', '����');

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

    //����ƽ�� ��ǰ ���� Ȯ��
    bChk := False;
    for Index := 0 to Global.SaleModule.SaleList.Count - 1 do
    begin
      AProduct := Global.SaleModule.SaleList[Index];

      if AProduct.Product_Div <> PRODUCT_TYPE_D then
        Continue;

      if AProduct.Alliance_code = GCD_SMARTIX_CODE then // ����ƽ�� 00007
      begin
        bChk := True;
        Break;
      end;
    end;

    if bChk = False then
    begin
      ShowErrorMsg('�¶��� ��ǰ�� �����ϴ�.');
      Exit;
    end;

    //���õ� Ÿ���� �������� ���Կ���
    if not (Pos(Global.SaleModule.TeeBoxInfo.ZoneCode, AProduct.AvailableZoneCd) > 0) then
    begin
      ShowErrorMsg('�ش� Ÿ�������� ����Ҽ� �����ϴ�.');
      Exit;
    end;

    if global.Config.ProductTime = True then // Ÿ�����ýð� ���� Ÿ����ǰ ǥ��
      NowTime := FormatDateTime('yyyymmddhhnn', now)
    else
    begin
      if Global.SaleModule.TeeBoxInfo.BtweenTime <> 0 then //Ÿ�� ��ü �ܿ��ð�
        NowTime := FormatDateTime('yyyymmdd', now) + StringReplace(Global.SaleModule.TeeBoxInfo.End_Time, ':', '', [rfReplaceAll]) + '00'
      else
        NowTime := FormatDateTime('yyyymmddhhnn', now);
    end;

    StartTime := StringReplace(AProduct.Start_Time, ':', '', [rfReplaceAll]);
    EndTime := StringReplace(AProduct.End_Time, ':', '', [rfReplaceAll]);

    bChk := False;
    if StartTime > EndTime then // ��������
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
      ShowErrorMsg('�ش� ��ǰ�� �̿�ð��� �ƴմϴ�.');
      Exit;
    end;

    //�ش� ��ǰ ���� ��밡�ɿ���
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

    Log.D('���޻�ǰ', '-----------------------------------------------------');
    Log.D('���޻�ǰ', AProduct.Code);
    Log.D('���޻�ǰ', AProduct.Name);
    Log.D('���޻�ǰ', AProduct.Start_Time);
    Log.D('���޻�ǰ', AProduct.End_Time);
    Log.D('���޻�ǰ', '-----------------------------------------------------');

    // ���ڵ� �ν�
    Global.SaleModule.PromotionType := pttSmartix;

    if not (ShowFullPopup(False, 'SaleProductTCM') = mrOk) then
      Exit;

    // ����ƽ�� ���� ���� ��
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

    //����ƽ�� ��ǰ ���� Ȯ��
    bChk := False;
    for Index := 0 to Global.SaleModule.SaleList.Count - 1 do
    begin
      AProduct := Global.SaleModule.SaleList[Index];

      if AProduct.Product_Div <> PRODUCT_TYPE_D then
        Continue;

      if AProduct.Alliance_code = GCD_SMARTIX_CODE then // ����ƽ�� 00007
      begin
        bChk := True;
        Break;
      end;
    end;

    if bChk = False then
    begin
      ShowErrorMsg('�¶��� ��ǰ�� �����ϴ�.');
      Exit;
    end;

    // ���ڵ� �ν�
    Global.SaleModule.PromotionType := pttSmartix;
    if not (ShowFullPopup(False, 'SaleProductTCM') = mrOk) then
      Exit;

    bAuth := True;

    // ����ƽ�� ���� ���� �� ��ǰ ��Ī
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
      sErrorMsg := '�ش��ϴ� ���� ��ǰ�� �����ϴ�.(�����ڵ�:' + Global.SaleModule.SmartixRmsTkttypId + ')';
      Exit;
    end;

    //���õ� Ÿ���� �������� ���Կ���
    if not (Pos(Global.SaleModule.TeeBoxInfo.ZoneCode, AProduct.AvailableZoneCd) > 0) then
    begin
      sErrorMsg := '�ش� Ÿ�������� ����Ҽ� �����ϴ�.';
      Exit;
    end;

    if global.Config.ProductTime = True then // Ÿ�����ýð� ���� Ÿ����ǰ ǥ��
      NowTime := FormatDateTime('yyyymmddhhnn', now)
    else
    begin
      if Global.SaleModule.TeeBoxInfo.BtweenTime <> 0 then //Ÿ�� ��ü �ܿ��ð�
        NowTime := FormatDateTime('yyyymmdd', now) + StringReplace(Global.SaleModule.TeeBoxInfo.End_Time, ':', '', [rfReplaceAll]) + '00'
      else
        NowTime := FormatDateTime('yyyymmddhhnn', now);
    end;

    StartTime := StringReplace(AProduct.Start_Time, ':', '', [rfReplaceAll]);
    EndTime := StringReplace(AProduct.End_Time, ':', '', [rfReplaceAll]);

    bChk := False;
    if StartTime > EndTime then // ��������
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
      sErrorMsg := '�ش� ��ǰ�� �̿�ð��� �ƴմϴ�.';
      Exit;
    end;

    //�ش� ��ǰ ���� ��밡�ɿ���
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
      sErrorMsg := '�ش��ǰ ��Ͽ� �����Ͽ����ϴ�';
      Exit;
    end;

    Log.D('���޻�ǰ', '-----------------------------------------------------');
    Log.D('���޻�ǰ', AProduct.Code);
    Log.D('���޻�ǰ', AProduct.Name);
    Log.D('���޻�ǰ', AProduct.Start_Time);
    Log.D('���޻�ǰ', AProduct.End_Time);
    Log.D('���޻�ǰ', '-----------------------------------------------------');


    // ����ƽ�� ���� ���� �� ��ǰ ��Ī ����
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
           ShowErrorMsg(sErrorMsg + #13 + '���ó�� ��Ҹ� ���� ī���Ϳ� ���� ���ּ���');
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

    // Application.Exception �ǽɵǼ� �Ǹ������� ����� �ű� 2020.01.09 JHJ
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
        Log.E('TeeBoxHold False', '����');

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

    //chy ��������ũ Ű����ũ
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
        //Global.SaleModule.ProgramUse := False;   //��Ÿ�������� ��Ʈ��ũ ���°� ���� �ʾƼ� ���� ����.
        ShowErrorMsg(MSG_UPDATE_MEMBER_INFO_FAIL);
        Exit;
      end;

      //jhj Ʈ�ν������Ϳ���üũ
      if (Global.Config.Store.StoreCode = 'A3001') then
      begin
        if Global.Config.Print.PrintType <> 'SEWOO' then
        begin
          AMsg := EmptyStr;
          if not Global.SaleModule.Print.PrintCheckStatus(AMsg) then
          begin
            Global.SBMessage.ShowMessageModalForm (AMsg + #13#10 + '������ �����Դϴ�.' + #13#10 + '�����ڸ� ȣ���Ͽ� �ֽñ� �ٶ��ϴ�.');
            Exit;
          end;
        end;
      end;

      // Ÿ�� Ȧ��
      Global.SaleModule.TeeBoxInfo := ATeeBoxInfo;
      Global.SaleModule.VipTeeBox := ATeeBoxInfo.Vip;

      if not Global.Database.TeeBoxHold then
      begin
        ShowErrorMsg(MSG_HOLD_TEEBOX_ERROR);
        Exit;
      end;

      //chy 2021-11-02 ����� �켱����
      if (Global.Config.Store.StoreCode = 'A8001') then
      begin
        if (Global.Config.Store.Emergency = 'Y') or (Global.Config.Store.DNSFail = 'Y') then
        begin
          if not Global.Database.TeeBoxHold(False) then
          begin
            //Log.E('TeeBoxHold False', '����');
          end;
          Global.SBMessage.ShowMessageModalForm ('�����ְ� �߻��Ͽ����ϴ�.' + #13#10 + '�����ڿ��� �����Ͽ� �ּ���.');
          Exit;
        end;
      end;

      // �����ð�, ����üũ- ��ǰ�� �����ð��� �޶� ��ǰ���ý÷� �̵�
      if Global.Config.AD.USE = False then //A1001 ��Ÿ
      begin
        if StoreCloseCheck then
        begin
          if not Global.Database.TeeBoxHold(False) then
          begin
            //Log.E('TeeBoxHold False', '����');
          end;
          Exit;
        end;
      end
      else
      begin
        if StoreClosureCheck then //�����ð��ʰ�, ����üũ
        begin
          if not Global.Database.TeeBoxHold(False) then
          begin
            //Log.E('TeeBoxHold False', '����');
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
          //Log.E('TeeBoxHold False', '����');
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
            // �������� ������ �Ⱓ, �������� ����Ϸ�� �������� Ÿ��Ȧ�带 ����Ѵ�. �׷��� Ȧ�� ��� �����ش�.
            // ����ǥ ��� �� Clear;
            if Global.SaleModule.SelectProduct.Code <> EmptyStr then
            begin
              // ���� ���� ���
              Global.SaleModule.SetPrepareMin;
              if not Global.Database.TeeBoxListReservation then
              begin
                //����

                if not Global.SaleModule.TeeboxTimeError then
                begin
                  if Global.SBMessage.ShowMessageModalForm('�ٸ� ��ǰ���� �����Ͻðڽ��ϱ�?', False) then
                  begin
                    Global.SaleModule.PopUpFullLevel := pflProduct;
                    goto ReReserve;
                  end;
                end;

                Log.E('TeeBoxListReservation', '������� ����');
                if not Global.Database.TeeBoxHold(False) then
                begin
                  //Log.E('TeeBoxHold False', '����');
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
            //Log.E('TeeBoxHold False', '����');
          end;

        end
        else if AModalResult = mrTryAgain then
          SaleProduct;
      end
      else if Global.SaleModule.memberItemType = mitDay then
      begin
        //����Ÿ�� ������ ��õȸ���� ǥ��. ��õȸ���� ���ý� ��������
        SaleProduct;

        //��õȸ���� ������
        if Global.SaleModule.AdvertPopupType = apMember then
        begin
          if Global.SaleModule.memberItemType = mitCoupon then //����,QR����
            AdvertMemberView;

          if Global.SaleModule.memberItemType = mitNew then //ȸ������
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
              Log.E('TeeBoxHold False', '����');
          end;
        end
        else
          SaleProduct;
      end
      else if Global.SaleModule.memberItemType = mitNew then // newmember
      begin
        if not Global.Database.TeeBoxHold(False) then
        begin
          //Log.E('TeeBoxHold False', '����');
        end;

        // Ÿ������ ��û ��������
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

      //��Ŀ/���� �������ɿ���
      if Global.database.BunkerPossible = False then
      begin
        Global.SBMessage.ShowMessageModalForm('���� �����ο����� �ʰ��Ͽ����ϴ�.');
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
    // Ÿ������ ��û(Ÿ����Ȳ ȭ�� ����) ��������
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

    // Ÿ������ ��û(Ÿ����Ȳ ȭ�� ����) ��������
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

  // �ý��� ����
  if Global.Config.SystemShutdown = True then
  begin
    if (FormatDateTime('hh:nn', now) = Global.Config.Store.StoreEndTime) then //"22:00"
    begin
      Log.D('SystemShutdown', '');
      MyExitWindows(EWX_SHUTDOWN);
      Exit;
    end;
  end;

  // ���� 5�ÿ� ���α׷� ������ 2020.01.14 JHJ
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

    //���� ���õ� ��Ʈ ���� ����ȯ2021-09-06
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
    //������ ��ǰ���� �����
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

    //����/qr����-�Ⱓ,�������� Ȯ�� �Ұ�, �������� ó��
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
      //Log.E('TeeBoxHold False', '����');
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

  // Ÿ������ ��û(Ÿ����Ȳ ȭ�� ����) ��������
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

  // Ÿ������ ��û(Ÿ����Ȳ ȭ�� ����) ��������
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
