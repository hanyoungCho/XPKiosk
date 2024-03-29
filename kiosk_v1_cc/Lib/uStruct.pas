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
    MemberCardUid: String; //회원 카드 고유번호, RFID
  end;

  // first_card_in_amt = Card 결제 금액
  TProductInfo = record
    Code: string;
    ZoneCode: string;
    ProductType: string;
    StartDate: string;
    EndDate: string;
    UseWeek: string;
    ActNo: string;
    TypeName: string;
    Name: string;
    Sex: string;
    ActSeq: Integer;
    Use_Qty: Integer;
    Buy_Qty: Integer;
    VatType: Boolean;
    UseMonth: string;
    Price: Integer;
    Use: Boolean;
    Yoday_Use: Boolean;
    ProductBuyCode: string;
    Reserve_No: string;
    Reserve_Time: string;
    Reserve_List: string;
    One_Use_Time: string;
    Start_Time: string;
    End_Time: string;
    Memo: string;
    Product_Div: string;  // R: 기간, C: 쿠폰, D: 일일타석, B:벙커
    Member_Product_Yn: string;  // Y:회원, N:비회원
    xgolf_dc_yn: Boolean;        // xgolf 할인 적용 유무
    xgolf_dc_amt: Integer;       // 할인금액
    xgolf_product_amt: Integer;  // 적용된 금액
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
    Use: Boolean;
    Stop: string;
    Sub_Cls: string;
    ERR: Integer;
    High: Integer;

    // 2020-11-04 층명칭
    FloorNm: String;

    TasukNo: Integer;
    SearchTime: TDateTime;
    End_Time: string;
    Ma_Time: string;
    End_DT: string;
    BtweenTime: Integer;
    IsAddList: Boolean;
    ZoneCode: string;
    Hold: Boolean;
    Vip: Boolean;
    Add_OK: Boolean;

    ReserveNo: String;
    UseStatus: String;

    ControlYn: String;
    DelYn: Boolean;
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
    FilePath: string;
    Position: string;
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

  //체크인정보
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
