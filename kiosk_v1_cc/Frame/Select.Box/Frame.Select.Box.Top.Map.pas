unit Frame.Select.Box.Top.Map;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, Frame.Select.Box.Top.Map.List.Style, FMX.Objects;

type
  TSelectBoxTopMap = class(TFrame)
    Layout1: TLayout;
    Layout2: TLayout;
    Layout3: TLayout;
    SelectBoxTopMapListStyle1: TSelectBoxTopMapListStyle;
    SelectBoxTopMapListStyle2: TSelectBoxTopMapListStyle;
    SelectBoxTopMapListStyle3: TSelectBoxTopMapListStyle;
  private
    { Private declarations }
  public
    { Public declarations }
    function DisplayFloor: Boolean;
    procedure CloseFrame;
  end;

implementation

uses
  uGlobal;

{$R *.fmx}

{ TSelectBoxTopMap }

procedure TSelectBoxTopMap.CloseFrame;
begin
  SelectBoxTopMapListStyle1.CloseFrame;
  SelectBoxTopMapListStyle2.CloseFrame;
  SelectBoxTopMapListStyle3.CloseFrame;
  FreeAndNil(SelectBoxTopMapListStyle1);
  FreeAndNil(SelectBoxTopMapListStyle2);
  FreeAndNil(SelectBoxTopMapListStyle3);
end;

function TSelectBoxTopMap.DisplayFloor: Boolean;
var
  Index: Integer;
begin
  Result := True;

  //for Index := 0 to Global.TeeBox.FloorList.Count - 1 do
  for Index := 0 to 1 do
  begin
    if Index = 2 then
      SelectBoxTopMapListStyle1.DisPlayFloor(Global.TeeBox.FloorList[Index], Global.TeeBox.FloorNmList[Index]);

    if Index = 1 then
      SelectBoxTopMapListStyle2.DisPlayFloor(2, Global.TeeBox.FloorNmList[0]);

    if Index = 0 then
      SelectBoxTopMapListStyle3.DisPlayFloor(1, Global.TeeBox.FloorNmList[0]);
  end;


//  if Global.Config.Store.StoreCode = 'T0001' then
//  begin
//    SelectBoxTopMapListStyle1.DisPlayFloor(4);
//    SelectBoxTopMapListStyle2.DisPlayFloor(3);
//    SelectBoxTopMapListStyle3.DisPlayFloor(2);
//  end
//  else
//  begin
//    SelectBoxTopMapListStyle1.DisPlayFloor(3);
//    SelectBoxTopMapListStyle2.DisPlayFloor(2);
//    SelectBoxTopMapListStyle3.DisPlayFloor(1);
//  end;
end;

end.
