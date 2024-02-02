unit Frame.KeyBoard;

interface

uses
  Frame.KeyBoard.Item.Style,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, System.Generics.Collections;

type
  TKeyBoard = class(TFrame)
    Rectangle: TRectangle;
    KeyRectangle: TRectangle;
  private
    { Private declarations }
//    FItemList: TList<TKeyBoardItemStyle>;
  public
    { Public declarations }
    procedure DisPlayKeyBoard;
    procedure CloseFrame;
  end;

implementation

uses
  uConsts;

{$R *.fmx}

{ TKeyBoard }

procedure TKeyBoard.CloseFrame;
var
  Index: Integer;
//  AKeyBoardItemStyle: TKeyBoardItemStyle;
begin
//  if FItemList = nil then
//    Exit;

//  for Index := FItemList.Count - 1 downto 0 do
//  begin
//    RemoveObject(TKeyBoardItemStyle(FItemList[Index]));
////
//    AKeyBoardItemStyle := FItemList[Index];
//    AKeyBoardItemStyle.ClearFrame;
//    FreeAndNil(AKeyBoardItemStyle);
//    FItemList.Delete(Index);
////
////
//    TKeyBoardItemStyle(FItemList[Index]).Free;
//    FItemList.Delete(Index);
//  end;

//  FItemList.Free;
//  FreeAndNil(FItemList);

//  RemoveObject(KeyRectangle);
  KeyRectangle.DeleteChildren;
  KeyRectangle.DisposeOf;

//  for Index := KeyRectangle.Children.Count - 1 downto 0 do
//    RemoveObject(TKeyBoardItemStyle(KeyRectangle.Children[Index]));
end;

procedure TKeyBoard.DisPlayKeyBoard;
var
  Index, ColIndex, RowIndex: Integer;
  AKeyBoardItemStyle: TKeyBoardItemStyle;
  Y, X: Single;
  APosition: TPosition;
  APoint: TPointF;
begin
  try
//    FItemList := TList<TKeyBoardItemStyle>.Create;

    X := 0;
    Y := 0;
    ColIndex := 0;
    RowIndex := 0;

    APoint := TPointF.Create(Y, X);
    APosition := TPosition.Create(APoint);

    for Index := 0 to Length(Key3BoardName) - 1 do
    begin
      AKeyBoardItemStyle := TKeyBoardItemStyle.Create(nil);

      if ColIndex = 3 then
      begin
        Inc(RowIndex);
        ColIndex := 0;
      end;

      APosition.X := ColIndex * (AKeyBoardItemStyle.Width + 20);
      APosition.Y := RowIndex * (AKeyBoardItemStyle.Height +15);

      AKeyBoardItemStyle := TKeyBoardItemStyle.Create(nil);
      AKeyBoardItemStyle.Position := APosition;
                              // 9, 11
      AKeyBoardItemStyle.Text.Text := Key3BoardName[Index];
      if Index in [9, 11] then
      begin
        AKeyBoardItemStyle.Text.Font.Size := 45;
        AKeyBoardItemStyle.Text.Font.Family := 'Noto Sans CJK KR';
      end
      else
        AKeyBoardItemStyle.Text.Font.Family := 'Roboto';

      AKeyBoardItemStyle.Key := Key3BoardArray[Index];

      AKeyBoardItemStyle.Parent := KeyRectangle;

//      FItemList.Add(AKeyBoardItemStyle);

      Inc(ColIndex);
    end;
  finally
//    RemoveObject(AKeyBoardItemStyle);
    APosition.DisposeOf;
    FreeAndNil(APoint);
  end;
end;

end.
