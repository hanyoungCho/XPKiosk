unit Frame.MemberInfo.Product.List.Style;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, Frame.MemberInfo.Product.List.Item.Style, FMX.Objects;

type
  TMemberInfoProductList = class(TFrame)
    VertScrollBox: TVertScrollBox;
    Rectangle: TRectangle;
    ImgScrollDown: TImage;
    ImgScrollUp: TImage;
    ScrollRectangle: TRectangle;
    ScrollBar2: TScrollBar;
    ImgScrollBG: TImage;
    ImgScroll: TImage;
    MemberInfoProductItemStyle1: TMemberInfoProductItemStyle;
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

procedure TMemberInfoProductList.Display;
var
  Index, RowIndex, Loop: Integer;
  Y, X: Single;
  APosition: TPosition;
  APoint: TPointF;
  AItemStyle: TMemberInfoProductItemStyle;
begin
  try
    X := 0;
    Y := 0;

    RowIndex := 0;

    APoint := TPointF.Create(Y, X);
    APosition := TPosition.Create(APoint);

    for Index := VertScrollBox.Content.ChildrenCount - 1 downto 0 do
      VertScrollBox.Content.Children[Index].Free;

    VertScrollBox.Content.DeleteChildren;
    VertScrollBox.Repaint;

    for Index := 0 to Global.SaleModule.ProductList.Count - 1 do
    begin
      if Index > 3 then
      begin
        ImgScrollUp.Visible := True;
        ImgScrollDown.Visible := True;
      end;

      AItemStyle := TMemberInfoProductItemStyle.Create(nil);

      APosition.X := X;
      APosition.Y := RowIndex * AItemStyle.Height;

      AItemStyle.Position := APosition;
      AItemStyle.Display(Global.SaleModule.ProductList[Index]);
      AItemStyle.Parent := VertScrollBox;

      Inc(RowIndex);
    end;
  finally
//    RemoveObject(ASaleOrderItemStyle);
    APosition.Free;
    FreeAndNil(APoint);
  end;
end;

procedure TMemberInfoProductList.ImgScrollDownClick(Sender: TObject);
begin
  ScrollBar2.Value := ScrollBar2.Value + 10;
  ScrollBar1Change(ScrollBar2);
end;

procedure TMemberInfoProductList.ImgScrollUpClick(Sender: TObject);
begin
  ScrollBar2.Value := ScrollBar2.Value - 10;
  ScrollBar1Change(ScrollBar2);
end;

procedure TMemberInfoProductList.ScrollBar1Change(Sender: TObject);
var
  max: Single;
begin   //
  Max := VertScrollBox.ContentBounds.Height - VertScrollBox.Content.Height;
  VertScrollBox.ViewportPosition := TPointF.Create(0, ((ScrollBar2.Height / 2) - ScrollBar2.ViewportSize) * (ScrollBar2.Value / Max));
  ImgScroll.Position := TPosition.Create(TPointF.Create(0, ((ImgScrollBG.Height - ScrollBar2.ViewportSize) * (ScrollBar2.Value / Max))));
end;

end.
