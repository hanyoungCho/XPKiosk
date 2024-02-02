unit Frame.PromotionList;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Layouts, Frame.PromotionList.Item;

type
  TFullPopupPrormotionList = class(TFrame)
    Layout: TLayout;
    Rectangle: TRectangle;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Display;
  end;

implementation

uses
  uGlobal;

{$R *.fmx}

{ TFullPopupPrormotionList }

procedure TFullPopupPrormotionList.Display;
var
  CardName: string;
  Index: Integer;
  Y, X: Single;
  APosition: TPosition;
  APoint: TPointF;
  AFullPopupPromotionListItem: TFullPopupPromotionListItem;
begin
  try
    X := 0;
    Y := 0;
    APoint := TPointF.Create(Y, X);
    APosition := TPosition.Create(APoint);

    //제휴사 목록
    // 우리카드 더라운지멤버스
    for Index := 0 to 2 do
    begin

      //장한평, 빅토리아 웰빙클럽 미사용
      if (Global.Config.Store.StoreCode = 'T0001') or //장한평
         (Global.Config.Store.StoreCode = 'A7001') then //빅토리아
      begin
        if Index = 0 then
          Continue;
      end;

      //캐슬렉스 리프레쉬클럽 사용
      if Global.Config.Store.StoreCode <> 'A6001' then
      begin
        if Index = 2 then
          Continue;
      end;

      if Index = 0 then
        CardName := '웰빙클럽';

      if Index = 1 then
        CardName := '무료골프';

      // 우리카드 더라운지멤버스
      if Index = 2 then
        //CardName := '더라운지멤버스';
        CardName := '리프레쉬클럽';

      AFullPopupPromotionListItem := TFullPopupPromotionListItem.Create(nil);

      AFullPopupPromotionListItem.Align := TAlignLayout.Top;
      AFullPopupPromotionListItem.Margins.Top := 30;

      AFullPopupPromotionListItem.Display(Index, CardName);
      AFullPopupPromotionListItem.Parent := Rectangle;

    end;
  finally
    APosition.Free;
  end;
end;

end.
