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
    SelectBoxProduct1: TSelectBoxProduct;
    ImgTeeBoxColor2: TImage;
    TimerPrint: TTimer;
    Text6: TText;
    Text2: TText;
    rtTeeboxAdvice: TRectangle;
    Top1: TTop;
    Image3: TImage;
    rrGamePay: TRoundRect;
    txtGamePay: TText;
    rrCheckIn: TRoundRect;
    Text1: TText;
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
    procedure rrGamePayClick(Sender: TObject);
    procedure rrCheckInClick(Sender: TObject);
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

    //chy ��������ũ Ű����ũ
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

    function NewMember: Boolean;

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
  //ActiveFloor := 1;
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

  //chy ��������ũ Ű����ũ
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

  if Global.SaleModule.AdvertListTeeboxUp.Count <> 0 then
    Image3.Bitmap.LoadFromFile(Global.SaleModule.AdvertListTeeboxUp[0].FilePath);

  Bottom1.Display(False);

  rrGamePay.Visible := False;
  //if (Global.Config.Store.StoreCode = 'C1001') then //�ڸ����������̺꽺����Ŭ��
  if (Global.Config.PaymentAdd = True) and (Global.Config.PaymentAddType <> '') then
  begin
    if Global.Config.PaymentAddType = '0' then
      txtGamePay.Text := '���Ӻ� ����'
    else if Global.Config.PaymentAddType = '1' then
      txtGamePay.Text := '�ü� �����'
    else
      txtGamePay.Text := '��ǰ ����';

    rrGamePay.Visible := True;
  end;

  rrCheckIn.Visible := False;
  if Global.Config.CheckInUse = True then
  begin
    rrCheckIn.Visible := True;

    if rrGamePay.Visible = False then
    begin
      rrCheckIn.Position.X := 50;
      rrCheckIn.Position.Y := 25;
    end;
  end;

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

  if not ShowPopup('BackImageClick/plAuthentication') then
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

    if not ShowPopup('BackRectangleClick/plAuthentication') then
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

procedure TSelectBox_In.HomeImageClick(Sender: TObject);
begin
  TouchSound;
end;

procedure TSelectBox_In.rrCheckInClick(Sender: TObject);
var
  rTeeBoxInfo: TTeeBoxInfo;
  AModalResult: TModalResult;
begin

  // Ÿ������ ��û(Ÿ����Ȳ ȭ�� ����) ��������
  rTeeBoxInfo.TasukNo := 0;
  Global.SaleModule.TeeBoxInfo := rTeeBoxInfo;

  //Global.SaleModule.PopUpFullLevel := pflCheckInFinger;
  Global.SaleModule.PopUpFullLevel := pflCheckInQR;
  AModalResult := ShowFullPopup(False, 'TSelectBox_In.txtCheckInClick');
  if AModalResult = mrIgnore then
  begin
    BackImageClick(nil);
    Exit;
  end;

  if AModalResult = mrOk then
  begin
    Global.LocalApi.TeeBoxCheckIn;

    Global.SaleModule.PopUpFullLevel := pflCheckInPrint;
    ShowFullPopup(False, 'TSelectBox_In.txtCheckInClick 2');
  end;

  Global.SaleModule.SaleDataClear; // SelectTeeBox  End
end;

procedure TSelectBox_In.rrGamePayClick(Sender: TObject);
var
  rTeeBoxInfo: TTeeBoxInfo;
  AModalResult: TModalResult;
begin

  Work := True;
  // Ÿ������ ��û(Ÿ����Ȳ ȭ�� ����) ��������
  rTeeBoxInfo.TasukNo := 0;
  rTeeBoxInfo.ZoneCode := 'G';
  rTeeBoxInfo.BtweenTime := 0;
  Global.SaleModule.TeeBoxInfo := rTeeBoxInfo;

  if Global.Config.PaymentAddType = '0' then
    Global.SaleModule.PaymentAddType := patGamePay
  else if Global.Config.PaymentAddType = '1' then
  begin
    Global.SaleModule.PopUpLevel := plFacilityProduct; //ȸ��, �������� ���� ȭ��
    if not ShowPopup('rrGamePayClick/plFacilityProduct') then
    begin
      Global.SaleModule.SaleDataClear;
      Work := False;
      Exit;
    end;

    if Global.SaleModule.PaymentAddType = patFacilityPeriod then
    begin
      Global.SaleModule.PopUpFullLevel := pflPeriod;
      AModalResult := ShowFullPopup(False, 'TSelectBox_In.rrGamePayClick');
      if AModalResult <> mrOk then
      begin
        Global.SaleModule.SaleDataClear;
        Work := False;
        Exit;
      end;
    end
    else if Global.SaleModule.PaymentAddType = patFacilityNew then
    begin
      if NewMember = False then
      begin
        Global.SaleModule.SaleDataClear;
        Work := False;
        Exit;
      end;

      Global.SaleModule.PaymentAddType := patFacilityPeriod;
    end;

    //Global.SaleModule.PaymentAddType := patFacility;
  end
  else if Global.Config.PaymentAddType = '2' then
    Global.SaleModule.PaymentAddType := patGeneral;

  SaleProduct;

  Global.SaleModule.SaleDataClear;
  Work := False;
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
      //XGolf ȸ�� ����. ȸ��/��ȸ�� ����
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

          if ShowPopup('SaleProduct/plXGolf') then
          begin
            Global.SaleModule.PopUpLevel := plNone;
            Global.SaleModule.PopUpFullLevel := pflQR; //Xgolf ȸ������

            if ShowFullPopup(False, 'TSelectBox.SaleProduct') = mrOk then
              Global.SaleModule.VipDisCount := True
            else
            begin
            end;
          end;

        end;
      end;

    end;

    // Application.Exception �ǽɵǼ� �Ǹ������� ����� �ű� 2020.01.09 JHJ
    SelectBox_In.ChangBottomImg;

    if ShowSaleProduct then
    begin
      Global.SaleModule.SaleCompleteProc;
      Clear;
    end
    else
    begin
      if not Global.Database.TeeBoxHold(False) then
        Log.E('TeeBoxHold False', '����');
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

    Global.SaleModule.SaleDataClear;
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
        //Global.SaleModule.ProgramUse := False;   //��Ÿ�������� ��Ʈ��ũ ���°� ���� �ʾƼ� ���� ����.
        ShowErrorMsg(MSG_UPDATE_MEMBER_INFO_FAIL);
        Exit;
      end;

      // Ÿ�� Ȧ��
      Global.SaleModule.TeeBoxInfo := ATeeBoxInfo;
      Global.SaleModule.VipTeeBox := ATeeBoxInfo.Vip;

      if not Global.Database.TeeBoxHold then
      begin
        ShowErrorMsg(MSG_HOLD_TEEBOX_ERROR);
        Exit;
      end;

      if StoreClosureCheck then //�����ð��ʰ�, ����üũ
      begin
        if not Global.Database.TeeBoxHold(False) then
        begin
          //Log.E('TeeBoxHold False', '����');
        end;
        Exit;
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
        begin
          if (Global.Config.MobileOAuth = True) then
            Global.SaleModule.PopUpLevel := plPhone
          else
            Global.SaleModule.PopUpFullLevel := pflPeriod;
        end
        else
          Global.SaleModule.PopUpFullLevel := pflCoupon;

        ReReserve :

        if (Global.SaleModule.memberItemType = mitperiod) and (Global.Config.MobileOAuth = True) then
        begin
          if ShowPopup('SelectTeeBox/plPhone') then
          begin
            Global.SaleModule.PopUpFullLevel := pflMobile;
            AModalResult := ShowFullPopup(False, 'TSelectBox.SelectTeeBox 1');
          end
          else
            AModalResult := mrCancel;
        end
        else
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
//                    Log.E('TeeBoxHold False', '����');
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
//              Log.E('TeeBoxHold False', '����');
          end;

        end
        else if AModalResult = mrTryAgain then
          SaleProduct;
      end
      else if Global.SaleModule.memberItemType = mitDay then
      begin
        SaleProduct;
      end
      else if Global.SaleModule.memberItemType = mitNew then
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

      FTimerInc := IfThen(Global.Config.AD.USE, TIMER_3, TIMER_5); //FTimerInc := 5;

      sMsgPostion := 'SelectTeeBox 2';
      Global.SaleModule.SaleDataClear;
      Work := False;

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
    Global.SaleModule.Print.PrintStatusCheck;
  except
    on E: Exception do
      Log.E('TimerPrintTimer', E.Message);
  end;

end;

procedure TSelectBox_In.TimerTimer(Sender: TObject);
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

  //chy sewoo
  if Global.SBMessage.PrintError then
    Exit;

  //chy ��������ũ Ű����ũ
  if FIntroDelay = True then
    FIntroDelay := False;

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
        //chy ��������ũ Ű����ũ
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

    { //��ǰ ���� ����
    if not Global.SaleModule.MasterReception(1) then
    begin
      Log.D('MasterReception', '1');
      Global.SaleModule.ProgramUse := False;
      ShowErrorMsg(MSG_MASTERDOWN_FAIL);
      Exit;
    end;
    }

    //����/qr����-�Ⱓ,�������� Ȯ�� �Ұ�, �������� ó��
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
      //Log.E('TeeBoxHold False', '����');
    end;

    Result := True;
  finally

  end;
end;

function TSelectBox_In.NewMember: Boolean;
label ReProduct;
begin
  try
    Result := False;

    //ȸ������ �Է�
    if not ShowNewMemberInfoTT then
      Exit;

    if Global.Config.FingerprintUse = 'Y' then
    begin
      Global.SaleModule.PopUpFullLevel := pflNewMemberFinger;
      if ShowFullPopup(False, 'TSelectBox.NewMember 1') = mrCancel then
      begin
        Exit;
      end;
    end;

    // ȸ���űԵ�Ͻ� �����ϸ� ��������� member_no(member.code) ȸ����ȣ �޾ƿ�. SaleModule.member �� ����
    if not Global.Database.AddNewMember then
    begin
      Log.E('AddMember', 'False');
      ShowErrorMsg(MSG_NEWMEMBER_FAIL);
      Exit;
    end;

    if Global.SaleModule.PaymentAddType = patFacilityNew then
    begin
      Result := True;
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

end.
