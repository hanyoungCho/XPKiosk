unit uStruct;

interface

uses
  FMX.Graphics, Classes, Generics.Collections;

type
  TMemberInfo = record
    Code: string;
    CardNo: string; // QR CODE
    Name: string;
    Sex: string;
    Tel_Home: string;
    Tel_Mobile: string;
    FingerStr: AnsiString;
    FingerStr_2: AnsiString;
    Finger: Array[0..384 - 1] of Byte;
    FingerCnt: Integer;
    Use: Boolean;

    MemberCardUid: String; //회원 카드 고유번호
    WelfareCd: String; // 1년 기간회원 1층 사용가능여부, Y: 1층사용가능, N:1층사용불가능
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
    Product_Div: string;  // R: 기간, C: 쿠폰, D: 일일타석
    xgolf_dc_yn: Boolean;        // xgolf 할인 적용 유무
    xgolf_dc_amt: Integer;       // 할인금액
    xgolf_product_amt: Integer;  // 적용된 금액
    //Alliance_yn: Boolean;
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
    TasukNo: Integer;
    Tasuk: string; //TasukNo 문자:01 두자리
    Name: string;
    Use: Boolean;
    Stop: string;
    Sub_Cls: string;
    ERR: Integer;
    High: Integer;

    FloorNm: String;

    SearchTime: TDateTime;
    End_Time: string;
    Ma_Time: string;
    End_DT: string;
    BtweenTime: Integer;
    IsAddList: Boolean;
    ZoneCode: string;
    Hold: Boolean;
    //Vip: Boolean;
    Add_OK: Boolean;
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

  TAgreement = record
    OrdrNo: Integer;
    AgreementDiv: string;
    FileUrl: string;
    FilePath: string;
    Image: TBitmap;
  end;

implementation

end.
