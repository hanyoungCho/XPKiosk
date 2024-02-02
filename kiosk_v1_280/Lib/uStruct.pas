unit uStruct;

interface

uses
  FMX.Graphics, Classes, Generics.Collections;

type
  // Class
  // Record
  TMemberInfo = record
    Code: string;
    CardNo: string; // QR CODE
//    QRCode: string; // QR CODE
    XGolfMember: Boolean;
    XGolfMemberQR: string;
    Name: string;
    Sex: string;
    Tel_Home: string;
    Tel_Mobile: string;
    Addr1: string;
    Addr2: string;
    CarNo: string;
    Email: string;
    BirthDay: string;
    FingerStr: AnsiString;
    FingerStr_2: AnsiString;
    Finger: Array[0..384 - 1] of Byte;
    FingerCnt: Integer;
    ImageStream: TMemoryStream;
    Bitmap: TBitMap;
    Use: Boolean;

    MemberCardUid: String; //회원 카드 고유번호
  end;

  // first_card_in_amt = Card 결제 금액
  TProductInfo = record // 타석상품
    Code: string;
    Name: string;
    ZoneCode: string;
    AvailableZoneCd: String; //2021-12-17 프라자
    ProductType: string;
    StartDate: string;
    EndDate: string;
    UseWeek: string;
    ActNo: string;
    //TypeName: string;
    Sex: string;
    ActSeq: Integer;
    UseCnt: Integer;
    Buy_Qty: Integer;
    VatType: Boolean;
    UseMonth: string;
    Price: Integer;
    Use: Boolean;
    Today_Use: Boolean;
    ProductBuyCode: string;
    Reserve_No: string;
    Reserve_Time: string;
    Reserve_List: string;
    One_Use_Time: string;
    Start_Time: string;
    End_Time: string;
    Memo: string;
    Product_Div: string;  // R: 기간, C: 쿠폰, D: 일일타석
    xgolf_dc_yn: Boolean;        // xgolf 할인 적용 유무
    xgolf_dc_amt: Integer;       // 할인금액
    xgolf_product_amt: Integer;  // 적용된 금액
    Alliance_yn: Boolean;

    Alliance_code: String; //제휴사 구분 코드, 없는것 기존 타석상품 00001:웰빙클럽 00002:리플레쉬클럽 00003:리플레쉬골프 00004:아이코젠 00005:이브릿지
    Alliance_name: String; //제휴사 구분 명
    Alliance_item_code: String; //제휴사 품목 코드: 웰빙 종목코드
    Alliance_item_name: String; //제휴사 품목 명

    Limit_Product_Yn: Boolean; //이용시간제한상품 여부
    Stamp_Yn: Boolean;

    Access_Barcode: String; //출입바코드 2022-08-23
    Access_Control_Nm: String; //출입통제 구역명 2022-08-23

    //일반상품
    //ClassCd: string;  // 분류 코드
    //TaxType: string;    // 1:과세, 2:비과세
    //Barcode: string;
    //RefundYn: Boolean;   // 환불처리상품 여부

    //시설상품
    Ticket_Print_Yn: Boolean;   // 배정표 출력 여부
  end;

  TDiscount = record
    QRCode: string;
    Name: string;
    Value: Integer;
    Gubun: Integer;
    ApplyAmt: Integer;
    ProductCode: string;
    Use: Boolean;
    Add: Boolean;
    Sort: Boolean;
    dc_cond_div: string;
    Product_Div: string;
    Product_Div_Detail: string;
    Product_Div_Cd: string;
  end;

   TSaleData = record
    SaleID: Integer;                        // 순서
    Products: TProductInfo;                 // 품목정보
    SaleQty: Currency;                      // 판매수량
    SalePrice: Currency;                    // 판매단가
    DcAmt: Currency;                        // 할인단가
    DiscountGubun: Integer;
    Remark: string;                         // 메모
    Discount_Percent: Integer;              // 정률할인 수 - SaleQty까지 가능
    Discount_Not_Percent: Integer;          // 정액할인 수 - SaleQty까지 가능
    DiscountList: TList<TDiscount>;
  end;

  TTeeBoxInfo = record
    Mno: string;
    Tasuk: string;
    TasukNo: Integer;
    FloorNm: String;
    ZoneCode: string;
    Use: Boolean;
    DelYn: Boolean; //2022-01-27
    Stop: string;
    Sub_Cls: string;
    ERR: Integer;
    High: Integer;
    SearchTime: TDateTime;
    End_Time: string;
    Ma_Time: string;
    End_DT: string;
    BtweenTime: Integer;
    IsAddList: Boolean;
    Hold: Boolean;
    Vip: Boolean;
    Add_OK: Boolean;

    ReserveNo: String;
    UseStatus: String;
    ControlYn: String;
  end;

  TPrintConfig = record
    Port: Integer;
    BaudRate: Integer;
    Version: string;
    Top1: string;
    Top2: string;
    Top3: string;
    Top4: string;
    Bottom1: string;
    Bottom2: string;
    Bottom3: string;
    Bottom4: string;
  end;

  TScannerConfig = record
    Port: Integer;
    Version: string;
  end;

  TXGolfConfig = record
    VipDc: Integer;
    Version: string;
  end;

  TProductConfig = record
    Version: string;
  end;

  TMemberConfig = record
    Version: string;
  end;

  TTeeBoxConfig = record
    Version: string;
  end;

  TConfigVersion = record
    Version: string;
  end;

  TAdvertisement = record
    Seq: Integer;
    Name: string;
    FileUrl: string;
    FileUrl2: string;
    FilePath: string;
    FilePath2: string;
    Position: string;

    ProductAddYn: string; //추천회원권
    ProductAddList: Array of String;

    MarketingAgreeYn: String;   //제3자 마케팅 동의 여부

    TeeboxStartNm: String; //영수증 광고 타석지정 시작 번호
    TeeboxEndNm: String; // 영수증 광고 타석지정 종료 번호
    RcpNth: String; // 영수증 N번째 당첨
    PopupNth: String; // 팝업 N번째 당첨
    QrString: String; //영수증QR코드문자열

    StartDate: string;
    EndDate: string;
    Show_Week: string;
    Show_Start_Time: string;
    Show_End_Time: string;
    Show_Interval: string;
    Show_YN: Boolean;
    ShowCnt: Integer;
    Image: TBitmap;
  end;

  TAgreement = record
    OrdrNo: Integer;
    AgreementDiv: string;
    FileUrl: string;
    FilePath: string;
    Image: TBitmap;
  end;

  TAdvertReceipt = record //영수증광고(배정표) 응답값
    ResultCd: String;
    ResultNth: String;
    ResultWinYn: String;
  end;

  //2021-08-05 체크인정보
  TCheckInInfo = record
    reserve_no: string;
    member_no: string;
    member_nm: string;
    floor_cd: string;
    floor_nm: string;
    teebox_no: string;
    teebox_nm: string;
    purchase_cd: string;
    product_cd: string;
    product_nm: string;
    product_div: string;
    reserve_datetime: string;
    start_datetime: string;
    remain_min: string;
    expire_day: string;
    coupon_cnt: string;
    reg_datetime: string;
    reserve_root_div: string;
  end;

implementation

end.
