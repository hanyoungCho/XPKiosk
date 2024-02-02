program XGolf_MF;

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
  Frame.Halbu in 'Frame\Popup\Frame.Halbu.pas' {Halbu: TFrame},
  Frame.Member.ItemType in 'Frame\Popup\Frame.Member.ItemType.pas' {frmMemberItemType: TFrame},
  Frame.FullPopup.Period in 'Frame\FullPopup\Frame.FullPopup.Period.pas' {FullPopupPeriod: TFrame},
  Frame.FullPopup.Coupon in 'Frame\FullPopup\Frame.FullPopup.Coupon.pas' {FullPopupCoupon: TFrame},
  Frame.FullPopup.CouponItem in 'Frame\FullPopup\Frame.FullPopup.CouponItem.pas' {FullPopupCouponItem: TFrame},
  Frame.FullPopup.Print in 'Frame\FullPopup\Frame.FullPopup.Print.pas' {FullPopupPrint: TFrame},
  Frame.FullPopupPayCard in 'Frame\FullPopup\Frame.FullPopupPayCard.pas' {FullPopupPayCard: TFrame},
  Form.Message in 'Form\Form.Message.pas' {SBMessageForm},
  uConfig in 'Lib\uConfig.pas',
  fx.Base in 'Lib\fx.Base.pas',
  Form.Full.Popup in 'Form\Form.Full.Popup.pas' {FullPopup},
  Frame.Sale.Order.List.Style in 'Frame\OrderFrame\Frame.Sale.Order.List.Style.pas' {SaleOrderList: TFrame},
  Frame.Sale.Order.List.Item.Style in 'Frame\OrderFrame\Frame.Sale.Order.List.Item.Style.pas' {SaleOrderItemStyle: TFrame},
  uPrint in 'Lib\uPrint.pas',
  uMFErpApi in 'DBModule\uMFErpApi.pas',
  Frame.FullPopup.SelectTime in 'Frame\FullPopup\Frame.FullPopup.SelectTime.pas' {FullPopupSelectTime: TFrame},
  Form.Main in 'Form\Form.Main.pas' {Main},
  Form.Config in 'Form\Form.Config.pas' {Config},
  Frame.Config.Item.Style in 'Frame\Config\Frame.Config.Item.Style.pas' {ConfigItemStyle: TFrame},
  uPaycoNewModul in 'Lib\Pay\uPaycoNewModul.pas',
  uPaycoRevForm in 'Lib\Pay\uPaycoRevForm.pas' {PaycoRevForm},
  Form.Master.Download in 'Form\Form.Master.Download.pas' {MasterDownload},
  Frame.Member.Sale.Product.Item420.Style in 'Frame\SaleFrame\Frame.Member.Sale.Product.Item420.Style.pas' {MemberSaleProductItem420Style: TFrame},
  Frame.FullPopup.Time.ItemStyle in 'Frame\FullPopup\Frame.FullPopup.Time.ItemStyle.pas' {FullPopupTimeItemStyle: TFrame},
  Form.Intro in 'Form\Form.Intro.pas' {Intro},
  Frame.Media in 'Frame\Frame.Media.pas' {MediaFrame: TFrame},
  Frame.SaleBox.Page.Item.Style in 'Frame\SaleFrame\Frame.SaleBox.Page.Item.Style.pas' {SaleBoxPageItemStyle: TFrame},
  Form.Intro.Blank in 'Form\Form.Intro.Blank.pas' {IntroBlank},
  Form.Lock in 'Form\Form.Lock.pas' {KIOSKLock},
  Frame.Select.Box.Floor.Item.Style in 'Frame\Select.Box\Frame.Select.Box.Floor.Item.Style.pas' {SelectBoxFloorItemStyle: TFrame},
  Frame.Select.Box.Floor in 'Frame\Select.Box\Frame.Select.Box.Floor.pas' {SelectBoxFloor: TFrame},
  Form.Select.Box in 'Form\Form.Select.Box.pas' {SelectBox},
  Frame.Select.Box.Floor.Item.Ver2.Style in 'Frame\Select.Box\Frame.Select.Box.Floor.Item.Ver2.Style.pas' {SelectBoxFloorItemVer2Style: TFrame},
  uLocalDB in 'DBModule\uLocalDB.pas',
  uUCBioAPI_Type in 'Lib\Union\uUCBioAPI_Type.pas',
  uUCBioBSPHelper in 'Lib\Union\uUCBioBSPHelper.pas',
  uXPErpApi in 'DBModule\uXPErpApi.pas';

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
