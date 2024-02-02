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

    MemberCardUid: String; //ȸ�� ī�� ������ȣ
  end;

  // first_card_in_amt = Card ���� �ݾ�
  TProductInfo = record // Ÿ����ǰ
    Code: string;
    Name: string;
    ZoneCode: string;
    AvailableZoneCd: String; //2021-12-17 ������
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
    Product_Div: string;  // R: �Ⱓ, C: ����, D: ����Ÿ��
    xgolf_dc_yn: Boolean;        // xgolf ���� ���� ����
    xgolf_dc_amt: Integer;       // ���αݾ�
    xgolf_product_amt: Integer;  // ����� �ݾ�
    Alliance_yn: Boolean;

    Alliance_code: String; //���޻� ���� �ڵ�, ���°� ���� Ÿ����ǰ 00001:����Ŭ�� 00002:���÷���Ŭ�� 00003:���÷������� 00004:�������� 00005:�̺긴��
    Alliance_name: String; //���޻� ���� ��
    Alliance_item_code: String; //���޻� ǰ�� �ڵ�: ���� �����ڵ�
    Alliance_item_name: String; //���޻� ǰ�� ��

    Limit_Product_Yn: Boolean; //�̿�ð����ѻ�ǰ ����
    Stamp_Yn: Boolean;

    Access_Barcode: String; //���Թ��ڵ� 2022-08-23
    Access_Control_Nm: String; //�������� ������ 2022-08-23

    //�Ϲݻ�ǰ
    //ClassCd: string;  // �з� �ڵ�
    //TaxType: string;    // 1:����, 2:�����
    //Barcode: string;
    //RefundYn: Boolean;   // ȯ��ó����ǰ ����

    //�ü���ǰ
    Ticket_Print_Yn: Boolean;   // ����ǥ ��� ����
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

    ProductAddYn: string; //��õȸ����
    ProductAddList: Array of String;

    MarketingAgreeYn: String;   //��3�� ������ ���� ����

    TeeboxStartNm: String; //������ ���� Ÿ������ ���� ��ȣ
    TeeboxEndNm: String; // ������ ���� Ÿ������ ���� ��ȣ
    RcpNth: String; // ������ N��° ��÷
    PopupNth: String; // �˾� N��° ��÷
    QrString: String; //������QR�ڵ幮�ڿ�

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

  TAdvertReceipt = record //����������(����ǥ) ���䰪
    ResultCd: String;
    ResultNth: String;
    ResultWinYn: String;
  end;

  //2021-08-05 üũ������
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
