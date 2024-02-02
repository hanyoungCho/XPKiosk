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

    //���޻� ���
    // �츮ī�� ������������
    for Index := 0 to 2 do
    begin

      //������, ���丮�� ����Ŭ�� �̻��
      if (Global.Config.Store.StoreCode = 'T0001') or //������
         (Global.Config.Store.StoreCode = 'A7001') then //���丮��
      begin
        if Index = 0 then
          Continue;
      end;

      //ĳ������ ��������Ŭ�� ���
      if Global.Config.Store.StoreCode <> 'A6001' then
      begin
        if Index = 2 then
          Continue;
      end;

      if Index = 0 then
        CardName := '����Ŭ��';

      if Index = 1 then
        CardName := '�������';

      // �츮ī�� ������������
      if Index = 2 then
        //CardName := '������������';
        CardName := '��������Ŭ��';

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
