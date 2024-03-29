unit Frame.Sale.Order.List.Style;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, Frame.Sale.Order.List.Item.Style, FMX.Objects;

type
  TSaleOrderList = class(TFrame)
    VertScrollBox: TVertScrollBox;
    SaleOrderItemStyle1: TSaleOrderItemStyle;
    Rectangle: TRectangle;
    ImgScrollDown: TImage;
    ImgScrollUp: TImage;
    ScrollRectangle: TRectangle;
    ScrollBar2: TScrollBar;
    ImgScrollBG: TImage;
    ImgScroll: TImage;
    procedure ScrollBar1Change(Sender: TObject);
    procedure ImgScrollUpClick(Sender: TObject);
    procedure ImgScrollDownClick(Sender: TObject);
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

{ TSaleOrderList }

procedure TSaleOrderList.Display;
var
  Index, RowIndex, Loop: Integer;
  ASaleOrderItemStyle: TSaleOrderItemStyle;
begin
  try
    RowIndex := 0;

    for Index := VertScrollBox.Content.ChildrenCount - 1 downto 0 do
      VertScrollBox.Content.Children[Index].Free;

    VertScrollBox.Content.DeleteChildren;
    VertScrollBox.Repaint;

    for Index := 0 to Global.SaleModule.BuyProductList.Count - 1 do
    begin
      if Index > 3 then
      begin
        ImgScrollUp.Visible := True;
        ImgScrollDown.Visible := True;
      end;

      ASaleOrderItemStyle := TSaleOrderItemStyle.Create(nil);

      ASaleOrderItemStyle.Position.X := 0;
      ASaleOrderItemStyle.Position.Y := RowIndex * ASaleOrderItemStyle.Height;

      ASaleOrderItemStyle.Display(Global.SaleModule.BuyProductList[Index]);
      ASaleOrderItemStyle.Parent := VertScrollBox;

      Inc(RowIndex);
      if Global.SaleModule.BuyProductList[Index].DiscountList.Count <> 0 then
      begin
        for Loop := 0 to Global.SaleModule.BuyProductList[Index].DiscountList.Count - 1 do
        begin
          ASaleOrderItemStyle := TSaleOrderItemStyle.Create(nil);

          ASaleOrderItemStyle.Position.X := 0;
          ASaleOrderItemStyle.Position.Y := RowIndex * ASaleOrderItemStyle.Height;

          ASaleOrderItemStyle.Display(Global.SaleModule.BuyProductList[Index], Loop);
          ASaleOrderItemStyle.Parent := VertScrollBox;
          Inc(RowIndex);
        end;
      end;
    end;
  finally
  end;
end;

procedure TSaleOrderList.ImgScrollDownClick(Sender: TObject);
begin
  ScrollBar2.Value := ScrollBar2.Value + 10;
  ScrollBar1Change(ScrollBar2);
end;

procedure TSaleOrderList.ImgScrollUpClick(Sender: TObject);
begin
  ScrollBar2.Value := ScrollBar2.Value - 10;
  ScrollBar1Change(ScrollBar2);
end;

procedure TSaleOrderList.ScrollBar1Change(Sender: TObject);
var
  max: Single;
begin
  Max := VertScrollBox.ContentBounds.Height - VertScrollBox.Content.Height;
  VertScrollBox.ViewportPosition := TPointF.Create(0, ((ScrollBar2.Height / 2) - ScrollBar2.ViewportSize) * (ScrollBar2.Value / Max));
  ImgScroll.Position := TPosition.Create(TPointF.Create(0, ((ImgScrollBG.Height - ScrollBar2.ViewportSize) * (ScrollBar2.Value / Max))));
end;

end.
