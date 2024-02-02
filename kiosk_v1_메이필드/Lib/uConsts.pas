unit uConsts;

interface

uses
  System.UITypes;

const
  PRODUCT_TYPE_R = 'R';
  PRODUCT_TYPE_C = 'C';
  PRODUCT_TYPE_D = 'D';

  TimeSecCaptionReTry = '��õ� ������ : %s��';

  TimeSecCaption = '���� �ð� : %s��';
  TimeHH = '%s�ð�';
  TimeNN = '%s��';
  TimeHHNN = '%s�ð� %s��';
  Time30Sec = 30;
  CardHalbu = '�Һΰ��� : %s';

  //XGOLF_REPLACE_STR = 'XGOLFUser_key:';
  XGOLF_REPLACE_STR2 = 'XGOLF User_key : ';
  XGOLF_REPLACE_STR3 = 'X-';
  //                               1    2    3    4    5    6    7    8    9     Cancel    0    back
  Key3BoardName: Array[0..11] of string = ('1', '2', '3', '4', '5', '6', '7', '8', '9', '��ü����', '0', '�����');
  Key3BoardArray: Array[0..11] of Integer = (vk1, vk2, vk3, vk4, vk5, vk6, vk7, vk8, vk9, vkCancel, vk0, vkBack);
  SelectTime: Array[0..15] of Integer = (7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22);
  WeekDay: Array[0..7] of string = ('','��', '��', 'ȭ', '��', '��', '��', '��');

  DEBUG_SCALE = 0.5;
  DEBUG_WIDTH = 540;
  DEBUG_HEIGHT = 960;

  FLOOR_MAX_CNT = 27; //jms 30

  // ������ Ư�����
  rptReceiptCharNormal    = '{N}';   // �Ϲ� ����
  rptReceiptCharBold      = '{B}';   // ���� ����
  rptReceiptCharInverse   = '{I}';   // ���� ����
  rptReceiptCharUnderline = '{U}';   // ���� ����
  rptReceiptAlignLeft     = '{L}';   // ���� ����
  rptReceiptAlignCenter   = '{C}';   // ��� ����
  rptReceiptAlignRight    = '{R}';   // ������ ����
  rptReceiptSizeNormal    = '{S}';   // ���� ũ��
  rptReceiptSizeWidth     = '{X}';   // ����Ȯ�� ũ��
  rptReceiptSizeHeight    = '{Y}';   // ����Ȯ�� ũ��
  rptReceiptSizeBoth      = '{Z}';   // ���μ���Ȯ�� ũ��
  rptReceiptSize3Times    = '{3}';   // ���μ���3��Ȯ�� ũ��
  rptReceiptSize4Times    = '{4}';   // ���μ���4��Ȯ�� ũ��
  rptReceiptInit          = '{!}';   // ������ �ʱ�ȭ
  rptReceiptCut           = '{/}';   // ����Ŀ��
  rptReceiptImage1        = '{*}';   // �׸� �μ� 1
  rptReceiptImage2        = '{@}';   // �׸� �μ� 2
  rptReceiptCashDrawerOpen= '{O}';   // ������ ����
  rptReceiptSpacingNormal = '{=}';   // �ٰ��� ����
  rptReceiptSpacingNarrow = '{&}';   // �ٰ��� ����
  rptReceiptSpacingWide   = '{\}';   // �ٰ��� ����
  rptLF                   = '{-}';   // �ٹٲ�
  rptLF2                  = #13#10;  // �ٹٲ�
  rptBarCodeBegin128      = '{<}';   // ���ڵ� ��� ���� CODE128
  rptBarCodeBegin39       = '{[}';   // ���ڵ� ��� ���� CODE39
  rptBarCodeEnd           = '{>}';   // ���ڵ� ��� ��
  // ������ ��¸�� (������ ���� ��¿��� �����)
  rptReceiptCharSaleDate  = '{D}';   // �Ǹ�����
  rptReceiptCharPosNo     = '{P}';   // ������ȣ
  rptReceiptCharPosName   = '{Q}';   // ������
  rptReceiptCharBillNo    = '{A}';   // ����ȣ
  rptReceiptCharDateTime  = '{E}';   // ����Ͻ�

/////////////////////         MSG//////////////////////////////////

  MSG_LOCAL_DATABASE_NOT_CONNECT = 'Local Database ���ῡ ���� �Ͽ����ϴ�.';
  MSG_ADMIN_NOT_PASSWORD = '��й�ȣ�� �ٸ��ϴ�.';
  MSG_MASTERDOWN_FAIL = '������ ������ �����ϴ�.' + #13#10 + '�����ڸ� ȣ���Ͽ� �ֽñ� �ٶ��ϴ�.';
  MSG_MASTERDOWN_FAIL_PROGRAM_RESTART = '������ ���� ���� ����.' + #13#10 + '���α׷��� ������Ͽ� �ֽñ� �ٶ��ϴ�.';
  MSG_ERROR_TEEBOX = '�������� Ÿ���Դϴ�.';
  MSG_HOLD_TEEBOX_ERROR = '�ٸ� ����ڰ� ���� �����' + #13#10 + '�Ǵ� Ÿ������ �����Դϴ�.';
  MSG_HOLD_TEEBOX = '�ٸ� ����ڰ� �������Դϴ�.';
  MSG_ADD_PRODUCT = '��ǰ�� �����Ͽ� �ֽñ� �ٶ��ϴ�.';
  MSG_NOT_PAY_AMT = '������ �ݾ��� �����ϴ�.';
  MSG_NOT_MEMBER_SEARCH = 'ȸ�� ������ ã�� ���Ͽ����ϴ�.';
  MSG_MEMBER_USE_NOT_PRODUCT = '��� ������ ��ǰ�� �����ϴ�.';
  MSG_IS_PRODUCT_BUY = '��ǰ�� ���� �Ͻðڽ��ϱ�?';
  MSG_DAY_PRODUCT_ONE = '����Ÿ�� ���Ŵ� 1���� ���� �մϴ�.';
  MSG_PROMOTION = '��� �� �� ���� QR�ڵ� �Դϴ�.';
  MSG_PROMOTION_OK = '���θ�� ���� ���� �Ǿ����ϴ�.';
  MSG_PROMOTION_OPTION_1 = #13#10 + '(����ʰ� �Ǵ� ���Ϸ�)';
  MSG_PROMOTION_OPTION_2 = #13#10 + '(���� ������ �ߺ� ��� �Ұ��մϴ�.)';
  MSG_PROMOTION_OPTION_3 = #13#10 + '(���αݾ� �ʰ�)';
  MSG_PROMOTION_OPTION_4 = #13#10 + '(QR�ڵ� �ߺ� ��� �Ұ��մϴ�.)';
  MSG_PROMOTION_OPTION_5 = #13#10 + '(���� ������ ��ǰ�� �����ϴ�.)';
  MSG_PROMOTION_OPTION_6 = #13#10 + '(�Բ� ����� �Ұ��� ���������� �ֽ��ϴ�.)';
  MSG_PROMOTION_PRODUCT_ONLY_DAY = '����Ÿ���� ��� �����մϴ�.';
  MSG_SALE_PRODUCT_NOT_CNT = '���� ������ ��ǰ�� �����ϴ�.';
  MSG_SALE_PRODUCT_RESERVE = '�����Ͻ� ��ǰ���� �����Ͻðڽ��ϱ�?';
  MSG_SALE_PRODUCT_RESERVE_SEARCH = 'ȸ������ ȸ���� ������ ��ȸ�Ͻðڽ��ϱ�?';
  MSG_VIP_ONLY_DAY_PRODUCT = 'VIPŸ���� ���ϰ��� ����� �����մϴ�';
  MSG_COMPLETE_CARD = '�����Ͻ� ī��� ì��̳���?' + #13#10 + '�ٽ� �ѹ� Ȯ���� �ּ���.';

  MSG_TEEBOX_TIME_ERROR = 'Ÿ�� ���� �����ð��� ����Ǿ����ϴ�!' + #13#10 +
                          '����� �ð����� ���� �����ðڽ��ϱ�?' +
                          #13#10 + #13#10 + '[������ ����ð�] %s' + #13#10 + '[����� ����ð�] %s';

  MSG_TEEBOX_TIME_ERROR_STATUS = '������ �Ǵ� ��ȸ������ Ÿ���Դϴ�.';

  MSG_TEEBOX_RESERVATION_AD_FAIL = 'Ÿ�� ������ ���� �Ͽ����ϴ�.' + #13#10 + '�����ڸ� ȣ���Ͽ� �ֽñ� �ٶ��ϴ�.';

  MSG_UPDATE_MEMBER_INFO_FAIL = 'ȸ������ ���ſ� ���� �Ͽ����ϴ�.' + #13#10 + '�ٽýõ��Ͽ� �ֽñ� �ٶ��ϴ�.';

  MSG_PRINT_ADMIN_CALL = '������ ������ �����մϴ�.' + #13#10 + '�����ڸ� ȣ���Ͽ� �ֽñ� �ٶ��ϴ�.';

type
  //TPopUpLevel = (plNone, plAuthentication, plHalbu, plPhone, plMemberItemType, plPromotionCode, plParkingDay);
  TPopUpLevel = (plNone, plAuthentication, plHalbu, plMemberItemType, plParkingDay);
  TPopUpFullLevel = (pflNone, pflCoupon, pflPayCard, pflPrint, pflTeeBoxPrint, pflPeriod, pflSelectTime, pflProduct);
  TMemberItemType = (mitNone, mitperiod, mitCoupon, mitDay);
  TTeeBoxSortType = (tstNone, tstDefault, tstLowTime, tst2TeeBox, tstTime);
  TMethodType = (mtGet, mtPost, mtDelete);
  //TCardApplyType = (catNone, catAppCard, catMagnetic, catPayco);
  TCardApplyType = (catNone, catMagnetic, catPayco);
  //TPromotionType = (pttNone, pttSelect);

implementation

end.
