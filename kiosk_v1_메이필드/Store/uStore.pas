unit uStore;

interface

uses
  uStruct, Uni,
  Generics.Collections;

type
  TStore = class
  private
  public
    procedure SetConnection; virtual; abstract;
    // ȸ�����
    function AddMember: Boolean; virtual; abstract;
    // ȸ�������͸� �����´�.
    function GetAllMmeberInfoVersion: string; virtual; abstract;
    function GetAllMemberInfo: TList<TMemberInfo>; virtual; abstract;
    // ȸ�� ������ �����´�. CARD �Ǵ� QR ȸ��
    function GetMemberInfoApi(ACardNo: string; out AMsg: string): TMemberInfo; virtual; abstract;
    // ȸ���� ��ǰ ����Ʈ�� �����´�
    function GetMemberProductList(ACardNo, ACode, ADate: string): TList<TProductInfo>; virtual; abstract;
    // ȸ���� ���� ���� Ȯ��
    function GetIsStopMemberStatus: Boolean; virtual; abstract;
    // ȸ���� ��ȸ ���� Ȯ��
    function GetProductNotStartDateNot: Boolean; virtual; abstract;
    // �������üũ
    function GetProductUseDayCheck(AProductCode: string): Boolean; virtual; abstract;
    // ����ð�üũ
    function GetProductUseTimeCheck(AProductCode: string): Boolean; virtual; abstract;
    // Ÿ�� ������ ������ �о� �´�.
    function GetTeeBoxMasterVersion: string; virtual; abstract;
    function GetTeeBoxMaster: TList<TTeeBoxInfo>; virtual; abstract;
    // Ÿ�� ������ �о� �´�.
    function GetTeeBoxPlayingInfo: TList<TTeeBoxInfo>; virtual; abstract;
    //
    function Connect: Boolean; virtual; abstract;
    //
    function DisConnect: Boolean; virtual; abstract;
    // Ÿ�� ��ǰ�� �����´�.
    function GetTeeBoxProductListVersion: string; virtual; abstract;
    function GetTeeBoxProductList: TList<TProductInfo>; virtual; abstract;
    // ���� Ÿ�� ��ǰ�� �����´�.
    function GetTeeBoxDayProductList: TList<TProductInfo>; virtual; abstract;
    // OAuth ����
    function OAuth_Certification: Boolean; virtual; abstract;
    // ȯ�漳��
    function GetConfigVersion: string; virtual; abstract;
    function GetConfig: Boolean; virtual; abstract;
    // ������ ���� ��ȸ
    function GetStoreInfo: Boolean; virtual; abstract;
    // Ÿ�� Ȧ��
    function TeeBoxHold(AIsHold: Boolean = True): Boolean; virtual; abstract;
    function TeeBoxListReservation: Boolean; virtual; abstract;
    // Ÿ�� ���� ���
    function TeeBoxReservation: Boolean; virtual; abstract;

    //chy move
    function TeeBoxReserveMove: Boolean; virtual; abstract;

    //chy newmember
    function AddNewMember: Boolean; virtual; abstract;
    function AddNewMemberQR: Boolean; virtual; abstract;

    // Ÿ�� ���� ��ȸ
    function TeeBoxReservationInfo(ACode: string): Boolean; virtual; abstract;
    // ���� ���
    function SaveSaleInfo: Boolean; virtual; abstract;
    // ���θ�� Ȯ��
    function SearchPromotion(ACoupon: string): Boolean; virtual; abstract;
    // ���� ��� ��ȸ
    function GetAdvertisVersion: string; virtual; abstract;
    procedure SearchAdvertisList; virtual; abstract;
    function SendAdvertisCnt(ASeq: string): Boolean; virtual; abstract;
    function SendAdvertisList: Boolean; virtual; abstract;
    // XGOLFȸ�� QR ���
    function AddMemberXGOLFQR(ACode: string): Boolean; virtual; abstract;
    // ī��� ���� üũ
    function SearchCardDiscount(ACardNo, ACardAmt: string; out ACode, AMsg: string): Currency; virtual; abstract;

  end;

implementation

end.

