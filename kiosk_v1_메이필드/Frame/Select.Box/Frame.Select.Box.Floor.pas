unit Frame.Select.Box.Floor;

interface

uses
  Frame.Select.Box.Floor.Item.Style, Frame.Select.Box.Floor.Item.Ver2.Style,
  System.Generics.Collections,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Objects;

type
  TSelectBoxFloor = class(TFrame)
    Layout: TLayout;
    BGRectangle: TRectangle;
    procedure FrameClick(Sender: TObject);
  private
    { Private declarations }
    FItemListVer2: TList<TSelectBoxFloorItemVer2Style>;
  public
    { Public declarations }
    procedure Display;
    procedure ChangeLayoutMarginsLeft(ALeft: Integer);
    procedure SelectFloor(AFloor: Integer);
    procedure CloseFrame;

    property ItemListVer2: TList<TSelectBoxFloorItemVer2Style> read FItemListVer2 write FItemListVer2;
  end;

implementation

uses
  uGlobal, uFunction, uStruct, uCommon;

{$R *.fmx}

{ TSelectBoxPloor }

procedure TSelectBoxFloor.ChangeLayoutMarginsLeft(ALeft: Integer);
begin
  Layout.Margins.Left := -50;
end;

procedure TSelectBoxFloor.CloseFrame;
var
  Index: Integer;
begin
  if ItemListVer2 <> nil then
  begin
    for Index := ItemListVer2.Count - 1 downto 0 do
      RemoveObject(ItemListVer2[Index]); //ItemListVer2.Delete(Index);

    ItemListVer2.Free;
  end;

//  RemoveObject(FItemList);
//  RemoveObject(FItemListVer2);
end;

procedure TSelectBoxFloor.Display;
var
  Index, AddWidth, ItemCnt: Integer;
  ASelectBoxFloorItemVer2Style: TSelectBoxFloorItemVer2Style;
begin
  try

    if ItemListVer2 = nil then
      ItemListVer2 := TList<TSelectBoxFloorItemVer2Style>.Create;

    if FItemListVer2.Count <> 0 then
      FItemListVer2.Clear;

    for Index := Layout.ChildrenCount - 1 downto 0 do
      Layout.Children[Index].Free;

    Layout.DeleteChildren;

    ItemCnt := 0;
    for Index := 0 to (Global.TeeBox.FloorList.Count + 1) - 1 do
    begin
      AddWidth := IfThen(Index = 0, 0, 15);

      ASelectBoxFloorItemVer2Style := TSelectBoxFloorItemVer2Style.Create(nil);
      if Global.SaleModule.AllTeeBoxShow then
      begin
        ASelectBoxFloorItemVer2Style.Width := 1080 / (Global.TeeBox.FloorList.Count + 1);
        ASelectBoxFloorItemVer2Style.Visible := True;
      end
      else
      begin
        ASelectBoxFloorItemVer2Style.Width := 1080 / Global.TeeBox.FloorList.Count;
        if Index = 0 then
          ASelectBoxFloorItemVer2Style.Visible := False;
      end;

      ASelectBoxFloorItemVer2Style.Position.X := (ItemCnt * ASelectBoxFloorItemVer2Style.Width);
      ASelectBoxFloorItemVer2Style.Position.Y := 0;

      Layout.Height := ASelectBoxFloorItemVer2Style.Height;
      ASelectBoxFloorItemVer2Style.Align := TAlignLayout.Left;

      if Index = 0 then
      begin
        ASelectBoxFloorItemVer2Style.Display(-1, '');
        ASelectBoxFloorItemVer2Style.Tag := -1;
      end
      else
      begin
        ASelectBoxFloorItemVer2Style.Display(Index, Global.TeeBox.FloorNmList[Index - 1]);
        ASelectBoxFloorItemVer2Style.Tag := Index;
      end;

      if Index = 3 then
        ASelectBoxFloorItemVer2Style.SideRectangle.Visible := False;

      ASelectBoxFloorItemVer2Style.Parent := Layout;
      ItemListVer2.Add(ASelectBoxFloorItemVer2Style);
      Inc(ItemCnt);
    end;

  finally
  end;
end;

procedure TSelectBoxFloor.FrameClick(Sender: TObject);
begin
  TouchSound;
end;

procedure TSelectBoxFloor.SelectFloor(AFloor: Integer);
var
  Index: Integer;
begin
  try
    for Index := 0 to ItemListVer2.Count - 1 do
    begin
      if ItemListVer2[Index].Tag = AFloor then
        ItemListVer2[Index].FloorRectangle.Fill.Color := TAlphaColorRec.Black
      else
        ItemListVer2[Index].FloorRectangle.Fill.Color := $FF848484;
    end;
  finally

  end;
end;

end.
