unit uConsts;

interface

uses
  System.UITypes;

const
  PRODUCT_TYPE_R = 'R';
  PRODUCT_TYPE_C = 'C';
  PRODUCT_TYPE_D = 'D';

  TimeSecCaptionReTry = '재시도 진행중 : %s초';

  TimeSecCaption = '남은 시간 : %s초';
  TimeHH = '%s시간';
  TimeNN = '%s분';
  TimeHHNN = '%s시간 %s분';
  Time30Sec = 30;
  CardHalbu = '할부개월 : %s';

  //XGOLF_REPLACE_STR = 'XGOLFUser_key:';
  XGOLF_REPLACE_STR2 = 'XGOLF User_key : ';
  XGOLF_REPLACE_STR3 = 'X-';
  //                               1    2    3    4    5    6    7    8    9     Cancel    0    back
  Key3BoardName: Array[0..11] of string = ('1', '2', '3', '4', '5', '6', '7', '8', '9', '전체삭제', '0', '지우기');
  Key3BoardArray: Array[0..11] of Integer = (vk1, vk2, vk3, vk4, vk5, vk6, vk7, vk8, vk9, vkCancel, vk0, vkBack);
  SelectTime: Array[0..15] of Integer = (7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22);
  WeekDay: Array[0..7] of string = ('','일', '월', '화', '수', '목', '금', '토');

  DEBUG_SCALE = 0.5;
  DEBUG_WIDTH = 540;
  DEBUG_HEIGHT = 960;

  FLOOR_MAX_CNT = 27; //jms 30

  // 프린터 특수명령
  rptReceiptCharNormal    = '{N}';   // 일반 글자
  rptReceiptCharBold      = '{B}';   // 굵은 글자
  rptReceiptCharInverse   = '{I}';   // 역상 글자
  rptReceiptCharUnderline = '{U}';   // 밑줄 글자
  rptReceiptAlignLeft     = '{L}';   // 왼쪽 정렬
  rptReceiptAlignCenter   = '{C}';   // 가운데 정렬
  rptReceiptAlignRight    = '{R}';   // 오른쪽 정렬
  rptReceiptSizeNormal    = '{S}';   // 보통 크기
  rptReceiptSizeWidth     = '{X}';   // 가로확대 크기
  rptReceiptSizeHeight    = '{Y}';   // 세로확대 크기
  rptReceiptSizeBoth      = '{Z}';   // 가로세로확대 크기
  rptReceiptSize3Times    = '{3}';   // 가로세로3배확대 크기
  rptReceiptSize4Times    = '{4}';   // 가로세로4배확대 크기
  rptReceiptInit          = '{!}';   // 프린터 초기화
  rptReceiptCut           = '{/}';   // 용지커팅
  rptReceiptImage1        = '{*}';   // 그림 인쇄 1
  rptReceiptImage2        = '{@}';   // 그림 인쇄 2
  rptReceiptCashDrawerOpen= '{O}';   // 금전함 열기
  rptReceiptSpacingNormal = '{=}';   // 줄간격 보통
  rptReceiptSpacingNarrow = '{&}';   // 줄간격 좁음
  rptReceiptSpacingWide   = '{\}';   // 줄간격 넓음
  rptLF                   = '{-}';   // 줄바꿈
  rptLF2                  = #13#10;  // 줄바꿈
  rptBarCodeBegin128      = '{<}';   // 바코드 출력 시작 CODE128
  rptBarCodeBegin39       = '{[}';   // 바코드 출력 시작 CODE39
  rptBarCodeEnd           = '{>}';   // 바코드 출력 끝
  // 프린터 출력명령 (영수증 별도 출력에서 사용함)
  rptReceiptCharSaleDate  = '{D}';   // 판매일자
  rptReceiptCharPosNo     = '{P}';   // 포스번호
  rptReceiptCharPosName   = '{Q}';   // 포스명
  rptReceiptCharBillNo    = '{A}';   // 빌번호
  rptReceiptCharDateTime  = '{E}';   // 출력일시

/////////////////////         MSG//////////////////////////////////

  MSG_LOCAL_DATABASE_NOT_CONNECT = 'Local Database 연결에 실패 하였습니다.';
  MSG_ADMIN_NOT_PASSWORD = '비밀번호가 다릅니다.';
  MSG_MASTERDOWN_FAIL = '마스터 정보가 없습니다.' + #13#10 + '관리자를 호출하여 주시기 바랍니다.';
  MSG_MASTERDOWN_FAIL_PROGRAM_RESTART = '마스터 정보 수신 오류.' + #13#10 + '프로그램을 재실행하여 주시기 바랍니다.';
  MSG_ERROR_TEEBOX = '점검중인 타석입니다.';
  MSG_HOLD_TEEBOX_ERROR = '다른 사용자가 예약 대기중' + #13#10 + '또는 타석지정 오류입니다.';
  MSG_HOLD_TEEBOX = '다른 사용자가 예약중입니다.';
  MSG_ADD_PRODUCT = '상품을 선택하여 주시기 바랍니다.';
  MSG_NOT_PAY_AMT = '결제할 금액이 없습니다.';
  MSG_NOT_MEMBER_SEARCH = '회원 정보를 찾지 못하였습니다.';
  MSG_MEMBER_USE_NOT_PRODUCT = '사용 가능한 상품이 없습니다.';
  MSG_IS_PRODUCT_BUY = '상품을 구매 하시겠습니까?';
  MSG_DAY_PRODUCT_ONE = '일일타석 구매는 1개만 가능 합니다.';
  MSG_PROMOTION = '사용 할 수 없는 QR코드 입니다.';
  MSG_PROMOTION_OK = '프로모션 할인 적용 되었습니다.';
  MSG_PROMOTION_OPTION_1 = #13#10 + '(사용초과 또는 사용완료)';
  MSG_PROMOTION_OPTION_2 = #13#10 + '(정률 할인은 중복 사용 불가합니다.)';
  MSG_PROMOTION_OPTION_3 = #13#10 + '(할인금액 초과)';
  MSG_PROMOTION_OPTION_4 = #13#10 + '(QR코드 중복 사용 불가합니다.)';
  MSG_PROMOTION_OPTION_5 = #13#10 + '(적용 가능한 상품이 없습니다.)';
  MSG_PROMOTION_OPTION_6 = #13#10 + '(함께 사용이 불가한 할인쿠폰이 있습니다.)';
  MSG_PROMOTION_PRODUCT_ONLY_DAY = '일일타석만 사용 가능합니다.';
  MSG_SALE_PRODUCT_NOT_CNT = '구매 가능한 상품이 없습니다.';
  MSG_SALE_PRODUCT_RESERVE = '구매하신 상품으로 배정하시겠습니까?';
  MSG_SALE_PRODUCT_RESERVE_SEARCH = '회원님의 회원권 정보를 조회하시겠습니까?';
  MSG_VIP_ONLY_DAY_PRODUCT = 'VIP타석은 일일고객만 사용이 가능합니다';
  MSG_COMPLETE_CARD = '결제하신 카드는 챙기셨나요?' + #13#10 + '다시 한번 확인해 주세요.';

  MSG_TEEBOX_TIME_ERROR = '타석 예상 배정시각이 변경되었습니다!' + #13#10 +
                          '변경된 시각으로 배정 받으시겠습니까?' +
                          #13#10 + #13#10 + '[선택한 종료시각] %s' + #13#10 + '[변경된 종료시각] %s';

  MSG_TEEBOX_TIME_ERROR_STATUS = '점검중 또는 볼회수중인 타석입니다.';

  MSG_TEEBOX_RESERVATION_AD_FAIL = '타석 배정에 실패 하였습니다.' + #13#10 + '관리자를 호출하여 주시기 바랍니다.';

  MSG_UPDATE_MEMBER_INFO_FAIL = '회원정보 갱신에 실패 하였습니다.' + #13#10 + '다시시도하여 주시기 바랍니다.';

  MSG_PRINT_ADMIN_CALL = '영수증 용지가 부족합니다.' + #13#10 + '관리자를 호출하여 주시기 바랍니다.';

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
