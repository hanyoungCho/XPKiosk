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

    MemberCardUid: String; //ȸ�� ī�� ������ȣ
    WelfareCd: String; // 1�� �Ⱓȸ�� 1�� ��밡�ɿ���, Y: 1����밡��, N:1�����Ұ���
  end;

  // first_card_in_amt = Card ���� �ݾ�
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
    Product_Div: string;  // R: �Ⱓ, C: ����, D: ����Ÿ��
    xgolf_dc_yn: Boolean;        // xgolf ���� ���� ����
    xgolf_dc_amt: Integer;       // ���αݾ�
    xgolf_product_amt: Integer;  // ����� �ݾ�
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
    SaleID: Integer;                        // ����
    Products: TProductInfo;                 // ǰ������
    SaleQty: Currency;                      // �Ǹż���
    SalePrice: Currency;                    // �ǸŴܰ�
    DcAmt: Currency;                        // ���δܰ�
    DiscountGubun: Integer;
    Remark: string;                         // �޸�
    Discount_Percent: Integer;              // �������� �� - SaleQty���� ����
    Discount_Not_Percent: Integer;          // �������� �� - SaleQty���� ����
    DiscountList: TList<TDiscount>;
  end;

  TTeeBoxInfo = record
    TasukNo: Integer;
    Tasuk: string; //TasukNo ����:01 ���ڸ�
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
