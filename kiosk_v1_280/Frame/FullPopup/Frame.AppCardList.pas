unit Frame.AppCardList;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Objects, Frame.AppCardListI.Item;

type
  TFullPopupAppCardList = class(TFrame)
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

{ TFullPopupAppCardList }

procedure TFullPopupAppCardList.Display;
var
  CardName: string;
  Index: Integer;
  AFullPopupAppCardListItem: TFullPopupAppCardListItem;
begin
  try

    for Index := 0 to 6 do //2021-09-16 KCP ���� ��û ���������� payco �� ����
    begin
      if Index = 0 then
      begin
        CardName := 'PAYCO'
        //Continue;
      end
      else if Index = 1 then
      begin
        CardName := '����PayFAN QR����';
        Continue;
      end
      else if Index = 2 then
      begin
        CardName := '���� ��ġ����';
        Continue;
      end
      else if Index = 3 then
      begin
        if Global.Config.AppCard_BC = False then
          Continue;

        CardName := '���̺� QR����';
      end
      else if Index = 4 then //NHpay
      begin
        CardName := '���ڵ�/QR����';
      end
      else if Index = 5 then //NHpay
      begin
        CardName := 'NHī�� �� NH��ġ ����';
      end
      else if Index = 6 then //CONA ī��
      begin
        if Global.Config.AppCard_CONA = False then
          Continue;

        CardName := '�ڳ�ī�� ����';
      end;

      AFullPopupAppCardListItem := TFullPopupAppCardListItem.Create(nil);

      AFullPopupAppCardListItem.Align := TAlignLayout.Top;
      AFullPopupAppCardListItem.Margins.Top := 30;

      AFullPopupAppCardListItem.Display(Index, CardName);

      AFullPopupAppCardListItem.Parent := Rectangle;

    end;
  finally

  end;
end;

end.
