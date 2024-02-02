program XGolf_EL;

uses
  FastMM4 in '..\..\..\FastMM4-master\FastMM4.pas',
  FastMM4Messages in '..\..\..\FastMM4-master\FastMM4Messages.pas',
  Forms,
  windows,
  FMX.Forms,
  frmContainer in 'frmContainer.pas' {Container},
  fx.Json in 'Lib\fx.Json.pas',
  fx.Logging in 'Lib\fx.Logging.pas',
  uFunction in 'Lib\uFunction.pas',
  uConsts in 'Lib\uConsts.pas',
  uStruct in 'Lib\uStruct.pas',
  uGlobal in 'Lib\uGlobal.pas',
  Frame.Select.Box.Top.Map.List.Item.Style in 'Frame\Select.Box\Frame.Select.Box.Top.Map.List.Item.Style.pas' {SelectBoxTopMapItemStyle: TFrame},
  uCommon in 'Lib\uCommon.pas',
  Frame.Select.Box.Top.Map.List.Style in 'Frame\Select.Box\Frame.Select.Box.Top.Map.List.Style.pas' {SelectBoxTopMapListStyle: TFrame},
  Frame.Select.Box.Top.Map in 'Frame\Select.Box\Frame.Select.Box.Top.Map.pas' {SelectBoxTopMap: TFrame},
  Frame.Select.Box.Product in 'Frame\Select.Box\Frame.Select.Box.Product.pas' {SelectBoxProduct: TFrame},
  Frame.Select.Box.Product.Item.Style in 'Frame\Select.Box\Frame.Select.Box.Product.Item.Style.pas' {SelectBoxProductItemStyle: TFrame},
  uSaleModule in 'Lib\uSaleModule.pas',
  uDevice.Tasuk in 'Lib\uDevice.Tasuk.pas',
  Frame.Top in 'Frame\Frame.Top.pas' {Top: TFrame},
  Form.Popup in 'Form\Form.Popup.pas' {Popup},
  Frame.KeyBoard.Item.Style in 'Frame\KeyBoard\Frame.KeyBoard.Item.Style.pas' {KeyBoardItemStyle: TFrame},
  Frame.KeyBoard in 'Frame\KeyBoard\Frame.KeyBoard.pas' {KeyBoard: TFrame},
  Frame.Authentication in 'Frame\Popup\Frame.Authentication.pas' {Authentication: TFrame},
  Frame.Bottom in 'Frame\Frame.Bottom.pas' {Bottom: TFrame},
  Frame.Member.ItemType in 'Frame\Popup\Frame.Member.ItemType.pas' {frmMemberItemType: TFrame},
  Frame.FullPopup.Period in 'Frame\FullPopup\Frame.FullPopup.Period.pas' {FullPopupPeriod: TFrame},
  Frame.FullPopup.Coupon in 'Frame\FullPopup\Frame.FullPopup.Coupon.pas' {FullPopupCoupon: TFrame},
  Frame.FullPopup.CouponItem in 'Frame\FullPopup\Frame.FullPopup.CouponItem.pas' {FullPopupCouponItem: TFrame},
  Frame.FullPopup.Print in 'Frame\FullPopup\Frame.FullPopup.Print.pas' {FullPopupPrint: TFrame},
  Frame.FullPopupQR in 'Frame\FullPopup\Frame.FullPopupQR.pas' {FullPopupQR: TFrame},
  Form.Message in 'Form\Form.Message.pas' {SBMessageForm},
  uConfig in 'Lib\uConfig.pas',
  fx.Base in 'Lib\fx.Base.pas',
  Form.Full.Popup in 'Form\Form.Full.Popup.pas' {FullPopup},
  uPrint in 'Lib\uPrint.pas',
  Frame.FullPopup.SelectTime in 'Frame\FullPopup\Frame.FullPopup.SelectTime.pas' {FullPopupSelectTime: TFrame},
  Form.Main in 'Form\Form.Main.pas' {Main},
  Form.Config in 'Form\Form.Config.pas' {Config},
  Frame.Config.Item.Style in 'Frame\Config\Frame.Config.Item.Style.pas' {ConfigItemStyle: TFrame},
  Form.Master.Download in 'Form\Form.Master.Download.pas' {MasterDownload},
  Frame.FullPopup.Time.ItemStyle in 'Frame\FullPopup\Frame.FullPopup.Time.ItemStyle.pas' {FullPopupTimeItemStyle: TFrame},
  Form.Intro in 'Form\Form.Intro.pas' {Intro},
  Frame.Media in 'Frame\Frame.Media.pas' {MediaFrame: TFrame},
  Form.Intro.Blank in 'Form\Form.Intro.Blank.pas' {IntroBlank},
  Form.Lock in 'Form\Form.Lock.pas' {KIOSKLock},
  Frame.Select.Box.Floor.Item.Style in 'Frame\Select.Box\Frame.Select.Box.Floor.Item.Style.pas' {SelectBoxFloorItemStyle: TFrame},
  Frame.Select.Box.Floor in 'Frame\Select.Box\Frame.Select.Box.Floor.pas' {SelectBoxFloor: TFrame},
  Form.Select.Box in 'Form\Form.Select.Box.pas' {SelectBox},
  Frame.Select.Box.Floor.Item.Ver2.Style in 'Frame\Select.Box\Frame.Select.Box.Floor.Item.Ver2.Style.pas' {SelectBoxFloorItemVer2Style: TFrame},
  uLocalApi in 'DBModule\uLocalApi.pas',
  uUCBioAPI_Type in 'Lib\Union\uUCBioAPI_Type.pas',
  uUCBioBSPHelper in 'Lib\Union\uUCBioBSPHelper.pas',
  uELoomApi in 'DBModule\uELoomApi.pas',
  Frame.MemberCheck in 'Frame\Popup\Frame.MemberCheck.pas' {MemberCheck: TFrame},
  Frame.FullPopup.MemberInfo in 'Frame\FullPopup\Frame.FullPopup.MemberInfo.pas' {FullPopupMemberInfo: TFrame},
  Frame.MemberInfo.Product.List.Item.Style in 'Frame\MemberInfoFrame\Frame.MemberInfo.Product.List.Item.Style.pas' {MemberInfoProductItemStyle: TFrame},
  Frame.MemberInfo.Product.List.Style in 'Frame\MemberInfoFrame\Frame.MemberInfo.Product.List.Style.pas' {MemberInfoProductList: TFrame};

const
  UniqueName = 'XGOLF KIOSK';

var
  Mutex : THandle;

{$R *.res}

begin

  Mutex := OpenMutex(MUTEX_ALL_ACCESS, False, UniqueName);

  if (Mutex <> 0 ) and (GetLastError = 0) then
  begin
    CloseHandle(Mutex);
    MessageBox(0, '프로그램이 실행중입니다.', '', MB_ICONWARNING or MB_OK);
    Exit;
  end;

  Mutex := CreateMutex(nil, False, UniqueName);

  try
    Application.Initialize;
    Application.CreateForm(TContainer, Container);
  Application.Run;
  finally
    ReleaseMutex(Mutex);
  end;
end.
