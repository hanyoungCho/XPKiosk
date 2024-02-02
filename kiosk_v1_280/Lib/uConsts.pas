unit uConsts;

interface

uses
  System.UITypes;

const
  PRODUCT_TYPE_R = 'R';
  PRODUCT_TYPE_C = 'C';
  PRODUCT_TYPE_D = 'D';

  //chy 2020-09-29
  TimeSecCaptionReTry = '��õ� ������ : %s��';

  TimeSecCaption = '���� �ð� : %s��';
  TimeHH = '%s�ð�';
  TimeNN = '%s��';
  TimeHHNN = '%s�ð� %s��';
  Time30Sec = 30;
  CardHalbu = '�Һΰ��� : %s';

  XGOLF_REPLACE_STR = 'XGOLFUser_key:';
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

  //chy jms,����
  FLOOR_MAX_CNT = 27; //jms 30

  //���޻�
  GCD_WBCLUB_CODE = '00001'; //����
  GCD_RFCLUB_CODE = '00002'; //��������Ŭ��
  GCD_RFGOLF_CODE = '00003'; //������������
  GCD_IKOZEN_CODE = '00004'; //��������
  GCD_THELOUNGEMEMBERS_CODE = '00005'; //�������
  GCD_BCPAYBOOK_CODE = '00006'; //'���̺�'
  GCD_SMARTIX_CODE = '00007'; // ����ƽ��


  //chy �츮ī�� ������������
  THE_LOUNGE_MEMBERS_REAL_URL = 'https://api.theloungemembers.com/';
  THE_LOUNGE_MEMBERS_REAL_ID = 'xgolf';
  THE_LOUNGE_MEMBERS_REAL_PW = 'mona9ng^^pang';
  THE_LOUNGE_MEMBERS_TEST_URL = 'https://dev-api.theloungemembers.com/';
  THE_LOUNGE_MEMBERS_TEST_ID = 'xgolf';
  THE_LOUNGE_MEMBERS_TEST_PW = 'mimigolf3x^^';

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
  MSG_ADMIN_CALL = '�����ڸ� ȣ�� �Ͽ����ϴ�.';
  MSG_ADMIN_CALL_FAIL = 'POS���� ������ ��Ȱ���� �ʽ��ϴ�.' + #13#10 + '����� POS�� �����Ͽ� �ֽñ�ٶ��ϴ�.';
  MSG_ADMIN_NOT_PASSWORD = '��й�ȣ�� �ٸ��ϴ�.';
  MSG_MASTERDOWN_FAIL = '������ ������ �����ϴ�.' + #13#10 + '�����ڸ� ȣ���Ͽ� �ֽñ� �ٶ��ϴ�.';
  MSG_MASTERDOWN_FAIL_PROGRAM_RESTART = '������ ���� ���� ����.' + #13#10 + '���α׷��� ������Ͽ� �ֽñ� �ٶ��ϴ�.';
  MSG_ERROR_TEEBOX = '�������� Ÿ���Դϴ�.';
  MSG_HOLD_TEEBOX_ERROR = '�ٸ� ����ڰ� ���� �����' + #13#10 + '�Ǵ� Ÿ������ �����Դϴ�.';
  MSG_HOLD_TEEBOX = '�ٸ� ����ڰ� �������Դϴ�.';
  MSG_ADD_PRODUCT = '��ǰ�� �����Ͽ� �ֽñ� �ٶ��ϴ�.';
  MSG_NOT_PAY_AMT = '������ �ݾ��� �����ϴ�.';
  MSG_NOT_XGOLF_MEMBER = 'XGOLF ȸ�� ������ �����Ͽ����ϴ�.';
  MSG_NOT_XGOLF_MEMBER_CANCEL = 'XGOLF ȸ�������� ����ϼ̽��ϴ�.';
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
  MSG_PROMOTION_OPTION_7 = #13#10 + '(�ش� ��ǰ�� �����Ҽ� ���� �����Դϴ�.)';
  MSG_PROMOTION_PRODUCT_ONLY_DAY = '����Ÿ���� ��� �����մϴ�.';
  MSG_SALE_PRODUCT_NOT_CNT = '���� ������ ��ǰ�� �����ϴ�.';
  MSG_SALE_PRODUCT_RESERVE = '�����Ͻ� ��ǰ���� �����Ͻðڽ��ϱ�?';
  MSG_SALE_PRODUCT_RESERVE_SEARCH = 'ȸ������ ȸ���� ������ ��ȸ�Ͻðڽ��ϱ�?';
  MSG_VIP_ONLY_DAY_PRODUCT = 'VIPŸ���� ���ϰ��� ����� �����մϴ�';
  MSG_TEAM_ONLY_DAY_PRODUCT = 'TEAMŸ���� ���ϰ��� ����� �����մϴ�';
  MSG_COMPLETE_CARD = '�����Ͻ� ī��� ì��̳���?' + #13#10 + '�ٽ� �ѹ� Ȯ���� �ּ���.';
  MSG_XGOLF_DISCOUNT = 'XGOLFȸ�� ������ Ȯ�����ּ���.' + #13#10 +
                       'XGOLF App �Ǵ� ����Ʈ���� ���� �����մϴ�.';
  MSG_XGOLF_ADD_MEMBER = '�����忡 XGOLFȸ�� ������ �Ͻðڽ��ϱ�?';
  MSG_XGOLF_QR_NOT = '�������� QR�ڵ尡 �ƴմϴ�.';

  MSG_TEEBOX_TIME_ERROR = 'Ÿ�� ���� �����ð��� ����Ǿ����ϴ�!' + #13#10 +
                          '����� �ð����� ���� �����ðڽ��ϱ�?' +
                          #13#10 + #13#10 + '[������ ����ð�] %s' + #13#10 + '[����� ����ð�] %s';

  MSG_TEEBOX_TIME_ERROR_STATUS = '������ �Ǵ� ��ȸ������ Ÿ���Դϴ�.';

  MSG_TEEBOX_RESERVATION_AD_FAIL = 'Ÿ�� ������ ���� �Ͽ����ϴ�.' + #13#10 + '�����ڸ� ȣ���Ͽ� �ֽñ� �ٶ��ϴ�.';

  MSG_UPDATE_MEMBER_INFO_FAIL = 'ȸ������ ���ſ� ���� �Ͽ����ϴ�.' + #13#10 + '�ٽýõ��Ͽ� �ֽñ� �ٶ��ϴ�.';

  //MSG_NEW_MEMBER = '�ʼ��׸� �������ּ���.';
  MSG_NEW_MEMBER = '���������� ����� �������ּ���.';
  MSG_TEEBOX_RESERVEMOVE_AD_FAIL = 'Ÿ�� �̵��� ���� �Ͽ����ϴ�.' + #13#10 + '�����ڸ� ȣ���Ͽ� �ֽñ� �ٶ��ϴ�.';
  MSG_TEEBOX_MOVE_FAIL = '���� ��Ÿ���� �̵��Ҽ� �ֽ��ϴ�.';
  MSG_TEEBOX_NULL = 'Ÿ���� �������� �ʽ��ϴ�.' + #13#10 + '�ٸ� Ÿ���� �������ּ���.';
  MSG_TEEBOX_MOVE_BARCODE_NOT = '��� �� �� ���� Ÿ������ǥ �Դϴ�.';
  MSG_TEEBOX_MOVE_BARCODE_NOT_2 = '����� �Ϸ�� Ÿ������ǥ �Դϴ�.';
  MSG_TEEBOX_MOVE_BARCODE_NOT_3 = '���������� Ÿ���� ���� ����ڰ� �ֽ��ϴ�. ' + #13#10 + 'Ÿ���̵��� �Ҽ� �����ϴ�.';

  MSG_NEWMEMBER_NULL = '�̸��� �޴�����ȣ�� �ʼ� �Է� �׸� �Դϴ�.';
  MSG_NEWMEMBER_PHONE_FAIL = '�޴�����ȣ�� ���ڷθ� �Է��� �ּ���.';
  MSG_NEWMEMBER_USE = '������ ȸ���� �����մϴ�.';
  MSG_NEWMEMBER_FAIL = 'ȸ�������� ������ �� �����ϴ�!';
  MSG_NEWMEMBER_SUCCESS = 'ȸ������ �� ��ǰ���Ű� �Ϸ�Ǿ����ϴ�. ' + #13#10 + 'Ÿ���� ������ �̿����ּ���.';

  MSG_PRINT_ADMIN_CALL = '������ ������ �����մϴ�.' + #13#10 + '�����ڸ� ȣ���Ͽ� �ֽñ� �ٶ��ϴ�.';

type
  TProgramVersion = (pvNone, pvASP, pvGMSoft);

  TPopUpLevel = (plNone, plAuthentication, plHalbu, plPhone, plMemberItemType, plXGolf, plPromotionCode, plNewMemberPolicy, plNewMemberProduct,
                 plTeeboxChange, plXGolfEvent, plParkingDay, plParkingPrint, plAdvertItemType, plFacilityProduct, plStamp);

  TPopUpFullLevel = (pflNone, pflCoupon, pflPayCard, pflPrint, pflTeeBoxPrint, pflQR, pflPeriod, pflSelectTime, pflPromo, pflProduct,
                     pflTeeboxMove, pflNewMemberFinger, pflNewMemberQRSend, pflCheckInQR, pflCheckInFinger, pflCheckInPrint, pflMobile,
                     pflBunkerMember, pflParkingPrint);

  TMemberItemType = (mitNone, mitperiod, mitCoupon, mitDay, mitAlliance, mitNew, mitAdd, mitBunkerMember, mitBunkerNonMember);

  TTeeboxMenuType = (tmNone, tmMove, tmTimeAdd);

  TTeeBoxSortType = (tstNone, tstDefault, tstLowTime, tst2TeeBox, tstTime);
  TMethodType = (mtGet, mtPost, mtDelete);
  TCardApplyType = (catNone, catAppCard, catMagnetic, catPayco);

  TPromotionType = (pttNone, pttSelect, pttWellbeing, pttTheloungemembers, pttBCPaybookGolf, pttRefreshclub, pttIkozen, pttSmartix);

  TAdvertPopupType = (apNone, apMember, apEvent);
  TPaymentAddType = (patNone, patGamePay, patFacilityPeriod, patFacilityDay, patFacilityNew, patGeneral);

implementation

end.
