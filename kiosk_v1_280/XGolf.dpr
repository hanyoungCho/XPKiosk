program XGolf;

uses
  FastMM4 in '..\..\FastMM4-master\FastMM4.pas',
  FastMM4Messages in '..\..\FastMM4-master\FastMM4Messages.pas',
  Forms,
  windows,
  FMX.Forms,
  frmContainer in 'frmContainer.pas' {Container},
  fx.Json in 'Lib\fx.Json.pas',
  fx.Logging in 'Lib\fx.Logging.pas',
  uFunction in 'Lib\uFunction.pas',
  uGMSQL in 'DBModule\uGMSQL.pas',
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
  Form.Sale.Product in 'Form\Form.Sale.Product.pas' {SaleProduct},
  Frame.Member.Sale.Product.Item.Style in 'Frame\SaleFrame\Frame.Member.Sale.Product.Item.Style.pas' {MemberSaleProductItemStyle: TFrame},
  Frame.Member.Sale.Product.List.Style in 'Frame\SaleFrame\Frame.Member.Sale.Product.List.Style.pas' {MemberSaleProductListStyle: TFrame},
  Frame.Top in 'Frame\Frame.Top.pas' {Top: TFrame},
  Form.Popup in 'Form\Form.Popup.pas' {Popup},
  Frame.KeyBoard.Item.Style in 'Frame\KeyBoard\Frame.KeyBoard.Item.Style.pas' {KeyBoardItemStyle: TFrame},
  Frame.KeyBoard in 'Frame\KeyBoard\Frame.KeyBoard.pas' {KeyBoard: TFrame},
  Frame.Authentication in 'Frame\Popup\Frame.Authentication.pas' {Authentication: TFrame},
  Frame.Bottom in 'Frame\Frame.Bottom.pas' {Bottom: TFrame},
  Frame.XGolfMember in 'Frame\Popup\Frame.XGolfMember.pas' {XGolfMember: TFrame},
  Frame.Halbu in 'Frame\Popup\Frame.Halbu.pas' {Halbu: TFrame},
  Frame.Member.ItemType in 'Frame\Popup\Frame.Member.ItemType.pas' {frmMemberItemType: TFrame},
  Frame.FullPopup.Period in 'Frame\FullPopup\Frame.FullPopup.Period.pas' {FullPopupPeriod: TFrame},
  Frame.FullPopup.Coupon in 'Frame\FullPopup\Frame.FullPopup.Coupon.pas' {FullPopupCoupon: TFrame},
  Frame.FullPopup.CouponItem in 'Frame\FullPopup\Frame.FullPopup.CouponItem.pas' {FullPopupCouponItem: TFrame},
  Frame.FullPopup.Print in 'Frame\FullPopup\Frame.FullPopup.Print.pas' {FullPopupPrint: TFrame},
  Frame.FullPopupQR in 'Frame\FullPopup\Frame.FullPopupQR.pas' {FullPopupQR: TFrame},
  Frame.FullPopupPayCard in 'Frame\FullPopup\Frame.FullPopupPayCard.pas' {FullPopupPayCard: TFrame},
  uStore in 'Store\uStore.pas',
  Form.Message in 'Form\Form.Message.pas' {SBMessageForm},
  uConfig in 'Lib\uConfig.pas',
  fx.Base in 'Lib\fx.Base.pas',
  Form.Full.Popup in 'Form\Form.Full.Popup.pas' {FullPopup},
  Frame.Sale.Order.List.Style in 'Frame\OrderFrame\Frame.Sale.Order.List.Style.pas' {SaleOrderList: TFrame},
  Frame.Sale.Order.List.Item.Style in 'Frame\OrderFrame\Frame.Sale.Order.List.Item.Style.pas' {SaleOrderItemStyle: TFrame},
  uBiominiPlus2 in 'Lib\uBiominiPlus2.pas',
  uPrint in 'Lib\uPrint.pas',
  uLocalSQL in 'DBModule\uLocalSQL.pas',
  uASPDatabase in 'DBModule\uASPDatabase.pas',
  Frame.FullPopup.SelectTime in 'Frame\FullPopup\Frame.FullPopup.SelectTime.pas' {FullPopupSelectTime: TFrame},
  Form.Main in 'Form\Form.Main.pas' {Main},
  Form.Config in 'Form\Form.Config.pas' {Config},
  Frame.Config.Item.Style in 'Frame\Config\Frame.Config.Item.Style.pas' {ConfigItemStyle: TFrame},
  uPaycoNewModul in 'Lib\Pay\uPaycoNewModul.pas',
  uPaycoRevForm in 'Lib\Pay\uPaycoRevForm.pas' {PaycoRevForm},
  Form.Master.Download in 'Form\Form.Master.Download.pas' {MasterDownload},
  Frame.Member.Sale.Product.Item420.Style in 'Frame\SaleFrame\Frame.Member.Sale.Product.Item420.Style.pas' {MemberSaleProductItem420Style: TFrame},
  uLocalDatabase in 'DBModule\uLocalDatabase.pas',
  Frame.FullPopup.Time.ItemStyle in 'Frame\FullPopup\Frame.FullPopup.Time.ItemStyle.pas' {FullPopupTimeItemStyle: TFrame},
  Form.Intro in 'Form\Form.Intro.pas' {Intro},
  Frame.Media in 'Frame\Frame.Media.pas' {MediaFrame: TFrame},
  Frame.SaleBox.Page.Item.Style in 'Frame\SaleFrame\Frame.SaleBox.Page.Item.Style.pas' {SaleBoxPageItemStyle: TFrame},
  Form.Intro.Blank in 'Form\Form.Intro.Blank.pas' {IntroBlank},
  Form.Lock in 'Form\Form.Lock.pas' {KIOSKLock},
  BSPInter in 'Lib\Nitgen\BSPInter.pas',
  NBioAPI_Type in 'Lib\Nitgen\NBioAPI_Type.pas',
  uNitgen in 'Lib\uNitgen.pas',
  Frame.AppCardList in 'Frame\FullPopup\Frame.AppCardList.pas' {FullPopupAppCardList: TFrame},
  Frame.AppCardListI.Item in 'Frame\FullPopup\Frame.AppCardListI.Item.pas' {FullPopupAppCardListItem: TFrame},
  Frame.PromotionList in 'Frame\FullPopup\Frame.PromotionList.pas' {FullPopupPrormotionList: TFrame},
  Frame.PromotionList.Item in 'Frame\FullPopup\Frame.PromotionList.Item.pas' {FullPopupPromotionListItem: TFrame},
  Frame.Select.Box.Floor.Item.Style in 'Frame\Select.Box\Frame.Select.Box.Floor.Item.Style.pas' {SelectBoxFloorItemStyle: TFrame},
  Frame.Select.Box.Floor in 'Frame\Select.Box\Frame.Select.Box.Floor.pas' {SelectBoxFloor: TFrame},
  Form.Select.Box in 'Form\Form.Select.Box.pas' {SelectBox},
  Frame.Select.Box.Floor.Item.Ver2.Style in 'Frame\Select.Box\Frame.Select.Box.Floor.Item.Ver2.Style.pas' {SelectBoxFloorItemVer2Style: TFrame},
  uLocalApi in 'DBModule\uLocalApi.pas',
  uUCBioAPI_Type in 'Lib\Union\uUCBioAPI_Type.pas',
  uUCBioBSPHelper in 'Lib\Union\uUCBioBSPHelper.pas',
  Form.Popup.TeeboxMove in 'Form\Form.Popup.TeeboxMove.pas' {frmTeeboxMove},
  Virtualkeyboard.Qwerty.Classes in 'PSHook.API\Virtualkeyboard.Qwerty.Classes.pas',
  VirtualKeyboard.Qwerty.Key.FrameStyle in 'PSHook.API\VirtualKeyboard.Qwerty.Key.FrameStyle.pas' {VirtualKeyboardQwertyKeyStyle: TFrame},
  VirtualKeyboard.Qwerty.Key.IME.FrameStyle in 'PSHook.API\VirtualKeyboard.Qwerty.Key.IME.FrameStyle.pas' {VirtualKeyboardQwertyKeyIMEStyle: TFrame},
  VirtualKeyboard.Qwerty.Key.Shift.FrameStyle in 'PSHook.API\VirtualKeyboard.Qwerty.Key.Shift.FrameStyle.pas' {VirtualKeyboardQwertyKeyShiftStyle: TFrame},
  VirtualKeyboard.Qwerty.Key.Back.FrameStyle in 'PSHook.API\VirtualKeyboard.Qwerty.Key.Back.FrameStyle.pas' {VirtualKeyboardQwertyKeyBackStyle: TFrame},
  VirtualKeyboard.Qwerty.FrameStyle in 'PSHook.API\VirtualKeyboard.Qwerty.FrameStyle.pas' {VirtualKeyboardQwertyStyle: TFrame},
  App.DeviceManager in 'PSHook.API\App.DeviceManager.pas',
  PSHook.API in 'PSHook.API\PSHook.API.pas',
  PSHook.DllExports in 'PSHook.API\PSHook.DllExports.pas',
  Form.Popup.NewMemberInfo in 'Form\Form.Popup.NewMemberInfo.pas' {frmNewMemberInfo},
  Frame.NewMember.ItemType in 'Frame\Popup\Frame.NewMember.ItemType.pas' {frmNewMemberItemType: TFrame},
  Frame.NewMember in 'Frame\Popup\Frame.NewMember.pas' {NewMember: TFrame},
  Frame.FullPopup.QRSend in 'Frame\FullPopup\Frame.FullPopup.QRSend.pas' {FullPopupQRSend: TFrame},
  uNBioBSPHelper in 'Lib\Nitgen\uNBioBSPHelper.pas',
  Frame.Select.Box.Top.Map.List.Item.RoundStyle in 'Frame\Select.Box\Frame.Select.Box.Top.Map.List.Item.RoundStyle.pas' {SelectBoxTopMapItemRoundStyle: TFrame},
  Form.PolicyView in 'Form\Form.PolicyView.pas' {frmPolicyView},
  Frame.PolicyView.Page.Item.Style in 'Frame\Popup\Frame.PolicyView.Page.Item.Style.pas' {PolicyViewPageItemStyle: TFrame},
  Frame.XGolfEvent in 'Frame\Popup\Frame.XGolfEvent.pas' {XGolfEvent: TFrame},
  Form.Popup.NewMemberInfoTT in 'Form\Form.Popup.NewMemberInfoTT.pas' {frmNewMemberInfoTT},
  uTabTipHelper in 'Lib\uTabTipHelper.pas',
  Form.Select_In.Box in 'Form\Form.Select_In.Box.pas' {SelectBox_In},
  Frame.Advert.ItemType in 'Frame\Popup\Frame.Advert.ItemType.pas' {frmAdvertItemType: TFrame},
  Form.Advertise in 'Form\Form.Advertise.pas' {frmAdvertise};

const
  UniqueName = 'XGOLF KIOSK';

var
  Mutex : THandle;

{$R *.res}
{$R XGCursors.resource}

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
