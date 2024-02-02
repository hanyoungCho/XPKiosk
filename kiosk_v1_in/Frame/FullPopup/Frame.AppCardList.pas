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

{$R *.fmx}

{ TFullPopupAppCardList }

procedure TFullPopupAppCardList.Display;
var
  CardName: string;
  Index: Integer;
  Y, X: Single;
  APosition: TPosition;
  APoint: TPointF;
  AFullPopupAppCardListItem: TFullPopupAppCardListItem;
begin
  try
    X := 0;
    Y := 0;
    APoint := TPointF.Create(Y, X);
    APosition := TPosition.Create(APoint);

    //for Index := 0 to 4 - 1 do
    for Index := 0 to 0 do //2021-09-16 KCP 별도 요청 있을때까지 payco 만 오픈
    begin
      if Index = 0 then
      begin
        CardName := 'PAYCO'
        //Continue;
      end
      else if Index = 1 then
        CardName := '신한PayFAN QR결제'
      else if Index = 2 then
        CardName := '신한 터치결제'
      else
        CardName := '페이북 QR결제';

      AFullPopupAppCardListItem := TFullPopupAppCardListItem.Create(nil);

      AFullPopupAppCardListItem.Align := TAlignLayout.Top;
      AFullPopupAppCardListItem.Margins.Top := 30;

      AFullPopupAppCardListItem.Display(Index, CardName);

      AFullPopupAppCardListItem.Parent := Rectangle;

    end;
  finally
    APosition.Free;
  end;
end;

end.
