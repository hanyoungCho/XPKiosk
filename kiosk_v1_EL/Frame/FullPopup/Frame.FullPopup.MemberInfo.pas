unit Frame.FullPopup.MemberInfo;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Layouts, Frame.MemberInfo.Product.List.Style;

type
  TFullPopupMemberInfo = class(TFrame)
    Layout: TLayout;
    Rectangle1: TRectangle;
    txtTasukInfo: TText;
    Text4: TText;
    imgProfile: TImage;
    txtNotice: TText;
    Rectangle2: TRectangle;
    Image2: TImage;
    Text2: TText;
    recProductInfo: TRectangle;
    MemberInfoProductList1: TMemberInfoProductList;
    Text1: TText;
    ImgLine1: TImage;
    ImgLine2: TImage;
    procedure Rectangle2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses
  Form.Full.Popup, uCommon, uGlobal, uConsts;

{$R *.fmx}

procedure TFullPopupMemberInfo.Rectangle2Click(Sender: TObject);
var
  nCnt, Index: Integer;
begin
  TouchSound;

  if Global.SaleModule.PopUpFullLevel = pflCheckIn then
    FullPopup.CloseFormStrMrCancel
  else
  begin
    nCnt := 0;
    for Index := 0 to Global.SaleModule.ProductList.Count - 1 do
    begin
      if Global.SaleModule.ProductList[Index].Product_Div <> '1' then // 1:타석상품
        Continue;

      inc(nCnt);
    end;

    if nCnt > 0 then
    begin
      FullPopup.MemberProductView;
    end
    else
    begin
      Global.SBMessage.ShowMessageModalForm('사용 가능한 타석상품이 없습니다.');
      FullPopup.CloseFormStrMrCancel;
    end

  end;
end;

end.
