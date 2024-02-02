unit Frame.KeyBoard;

interface

uses
  Frame.KeyBoard.Item.Style,
  System.Classes,
  FMX.Forms, FMX.StdCtrls, FMX.Objects, FMX.Types, FMX.Controls;

type
  TKeyBoard = class(TFrame)
    Rectangle: TRectangle;
    KeyRectangle: TRectangle;
  private
    { Private declarations }
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
begin
  //KeyRectangle.DeleteChildren;
  //KeyRectangle.DisposeOf;
end;

procedure TKeyBoard.DisPlayKeyBoard;
var
  Index, ColIndex, RowIndex: Integer;
  AKeyBoardItemStyle: TKeyBoardItemStyle;
begin

  try
    ColIndex := 0;
    RowIndex := 0;

    for Index := 0 to Length(Key3BoardName) - 1 do
    begin

      if ColIndex = 3 then
      begin
        Inc(RowIndex);
        ColIndex := 0;
      end;

      AKeyBoardItemStyle := TKeyBoardItemStyle.Create(nil);
      AKeyBoardItemStyle.Position.X := ColIndex * (AKeyBoardItemStyle.Width + 20);
      AKeyBoardItemStyle.Position.Y := RowIndex * (AKeyBoardItemStyle.Height +15);

      AKeyBoardItemStyle.Text.Text := Key3BoardName[Index]; // 9, 11
      if Index in [9, 11] then
      begin
        AKeyBoardItemStyle.Text.Font.Size := 45;
        AKeyBoardItemStyle.Text.Font.Family := 'Noto Sans CJK KR';
      end
      else
        AKeyBoardItemStyle.Text.Font.Family := 'Roboto';

      AKeyBoardItemStyle.Key := Key3BoardArray[Index];
      AKeyBoardItemStyle.Parent := KeyRectangle;

      Inc(ColIndex);
    end;
  finally

  end;

end;

end.
