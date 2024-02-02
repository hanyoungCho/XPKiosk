unit Frame.Select.Box.Top.Map.List.Style;

interface

uses
  Frame.Select.Box.Top.Map.List.Item.Style, Math,
  System.Generics.Collections, System.DateUtils,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Layouts;

type
  TSelectBoxTopMapListStyle = class(TFrame)
    Rectangle: TRectangle;
    LeftRectangle: TRectangle;
    Text: TText;
    RightRectangle: TRectangle;
    Layout1: TLayout;
  private
    { Private declarations }
    FItemList: TList<TSelectBoxTopMapItemStyle>;
  public
    { Public declarations }
    function DisPlayFloor(AFloor: Integer; AFloorNm: String): Boolean;
    procedure CloseFrame;

    property ItemList: TList<TSelectBoxTopMapItemStyle> read FItemList write FItemList;
  end;

implementation

uses
  uFunction, uGlobal, uConsts, uStruct;

{$R *.fmx}

{ TSelectBoxTopMapListStyle }

procedure TSelectBoxTopMapListStyle.CloseFrame;
var
  Index: Integer;
begin
  if ItemList = nil then
    Exit;

  for Index := ItemList.Count - 1 to 0 do
    ItemList.Delete(Index);

  ItemList.Free;
end;

function TSelectBoxTopMapListStyle.DisPlayFloor(AFloor: Integer; AFloorNm: String): Boolean;
var
  EndDateTime: TDateTime;
  Index, Loop, ABetweenTime, MapIndex, AHour, AMinute, AMapCnt, TopMarginCnt, AFloorCnt, AFloorCnt_Mod, LimitTime: Integer;
  TopMargin, RoundValue: Currency;
  EndTime: string;
  ASelectBoxTopMapItemStyle: TSelectBoxTopMapItemStyle;
  Color: TAlphaColor;
  TeeBoxInfoTemp: TTeeBoxInfo;
begin
  try
    try
      BeginUpdate;
      Result := True;
      if FItemList = nil then
        FItemList := TList<TSelectBoxTopMapItemStyle>.Create;

      if FItemList.Count <> 0 then
      begin
       for Index := ItemList.Count - 1 to 0 do
       begin
         ASelectBoxTopMapItemStyle := ItemList[Index];
         FreeAndNil(ASelectBoxTopMapItemStyle);
         ItemList.Delete(Index);
       end;
        FItemList.Clear;
      end;

      MapIndex := 0;
      AFloorCnt := 0;
      AFloorCnt_Mod := 0;

      Text.Text := AFloorNm;

      RightRectangle.Width := 0;

      for Loop := RightRectangle.ChildrenCount - 1 downto 0 do
        RightRectangle.Children[Loop].Free;

      RightRectangle.DeleteChildren;

      TopMargin := 0;
      TopMarginCnt := 0;

      for Index := 0 to Global.TeeBox.TeeBoxList.Count - 1 do
      begin
        if Global.TeeBox.TeeBoxList[Index].High = AFloor then
          Inc(AFloorCnt);
      end;

      AFloorCnt_Mod := AFloorCnt mod 2;
      RoundValue := 2;

      if (Global.TeeBox.FloorMaxTeeboxCnt > FLOOR_MAX_CNT) then
      begin
        RightRectangle.Margins.Left := -25;
      end;

      for Index := 0 to Global.TeeBox.TeeBoxList.Count - 1 do
      begin
        if Global.TeeBox.TeeBoxList[Index].High <> AFloor then
          Continue;

        Inc(TopMarginCnt);

        if TopMarginCnt <= ((AFloorCnt div 2) + AFloorCnt_Mod) then
          TopMargin := TopMargin + RoundValue
        else
        begin
          if AFloorCnt_Mod = 0 then
          begin
            if TopMarginCnt <> (AFloorCnt div 2) + 1 then
              TopMargin := TopMargin - RoundValue;
          end
          else
            TopMargin := TopMargin - RoundValue;
        end;

        ASelectBoxTopMapItemStyle := TSelectBoxTopMapItemStyle.Create(nil);

        if Global.TeeBox.FloorMaxTeeboxCnt > FLOOR_MAX_CNT then
        begin
          Text.Visible := False;
          ASelectBoxTopMapItemStyle.Width := 1080 / Global.TeeBox.FloorMaxTeeboxCnt;
        end;

        if Global.TeeBox.FloorMaxTeeboxCnt > FLOOR_MAX_CNT then
        begin
          ASelectBoxTopMapItemStyle.Position.X := MapIndex * ASelectBoxTopMapItemStyle.Width;
        end
        else
          ASelectBoxTopMapItemStyle.Position.X := 3 + MapIndex * ASelectBoxTopMapItemStyle.Width;
        ASelectBoxTopMapItemStyle.Position.Y := TopMargin;

        RightRectangle.Width := RightRectangle.Width + ASelectBoxTopMapItemStyle.Width;
        RightRectangle.Height := ASelectBoxTopMapItemStyle.Height + 25;
        LeftRectangle.Height := ASelectBoxTopMapItemStyle.Height + 25 ;
        ASelectBoxTopMapItemStyle.Text.TextSettings.FontColor := TAlphaColorRec.White;

        TeeBoxInfoTemp := Global.TeeBox.TeeBoxList[Index];
        TeeBoxInfoTemp.FloorNm := AFloorNm;
        ASelectBoxTopMapItemStyle.FTeeBoxInfo := TeeBoxInfoTemp;

        if Global.TeeBox.TeeBoxList[Index].Hold then
        begin
          Color := $FFAC8282;
          ASelectBoxTopMapItemStyle.SetText(Global.TeeBox.TeeBoxList[Index].Name);
          ASelectBoxTopMapItemStyle.Circle.Fill.Color := Color;
        end
        else if (Global.TeeBox.TeeBoxList[Index].ERR <> 0) or (not Global.TeeBox.TeeBoxList[Index].Use) then
        begin
          ASelectBoxTopMapItemStyle.SetText('X');
          Color := $FF5C5C5C;// $FF777777;
          ASelectBoxTopMapItemStyle.Circle.Fill.Color := Color; //$FFB8B8B8;
        end
        else
        begin
          ASelectBoxTopMapItemStyle.Tag := Global.TeeBox.TeeBoxList[Index].TasukNo;

          ASelectBoxTopMapItemStyle.SetText(Global.TeeBox.TeeBoxList[Index].Name);
          if (Global.TeeBox.TeeBoxList[Index].BtweenTime = 0) or ((Trim(Global.TeeBox.TeeBoxList[Index].Ma_Time) = '0') and (Trim(Global.TeeBox.TeeBoxList[Index].End_DT) = EmptyStr)) then
          begin
            Color := $FF00CE13;//$FF45D10E;
            ASelectBoxTopMapItemStyle.Circle.Fill.Color := Color;//$FF5FB459//$FF555555 //TAlphaColorRec.Null
          end
          else if Global.TeeBox.TeeBoxList[Index].BtweenTime <> 0 then //  777777 Gray  85AC82 GREEN   $FF544ED6 RED
          begin
            LimitTime := 10;

            if Global.TeeBox.TeeBoxList[Index].BtweenTime < LimitTime then
            begin
              Color := $FFF30033;//$FFF60A14;//
              ASelectBoxTopMapItemStyle.Circle.Fill.Color := Color; //TAlphaColorRec.Red;
            end
            else
            begin
              Color := $FFFF8518;//$FF2E74F0;//$FFF0742E;//TAlphaColorRec.Coral;//$FF2366EC;//$FFFFCB00;
              ASelectBoxTopMapItemStyle.Circle.Fill.Color := Color;//$FF777777; //$FF80C97A; //TAlphaColorRec.Lightgreen;
            end;
          end
          else if Global.TeeBox.TeeBoxList[Index].Hold {and (Global.TeeBox.TeeBoxList[Index].TasukNo <> Global.SaleModule.LastHoldNo)} then
          begin
            Color := $FFAC8282;
            ASelectBoxTopMapItemStyle.Circle.Fill.Color := Color;
          end;

        end;
        ASelectBoxTopMapItemStyle.Parent := RightRectangle;
        ASelectBoxTopMapItemStyle.FColor := Color;

        ASelectBoxTopMapItemStyle.Align := TAlignLayout.Left;
        ASelectBoxTopMapItemStyle.Margins.Top := TopMargin;

        if Global.SaleModule.MainItemMapUse then
        begin
          AMapCnt := 0;
          if Global.SaleModule.TeeBoxSortType = tstLowTime then
          begin
            AMapCnt := IfThen(Global.SaleModule.MainItemList.Count > 24, 24, Global.SaleModule.MainItemList.Count);
          end
          else
            AMapCnt := Global.SaleModule.MainItemList.Count;

          for Loop := 0 to AMapCnt - 1 do
          begin
            if Global.SaleModule.TeeBoxSortType = tstTime then
            begin
              EndDateTime := DateStrToDateTime(FormatDateTime('YYYYMMDD', now) +
                                                     Copy(StringReplace(Global.TeeBox.TeeBoxList[Index].End_Time, ':', '', [rfReplaceAll]), 1, 2) + '0000');
              if Global.SaleModule.SelectTime <> EndDateTime then
              begin
                ASelectBoxTopMapItemStyle.Circle.Fill.Color := TAlphaColorRec.Null;
                ASelectBoxTopMapItemStyle.Circle.Stroke.Thickness := 1;
              end
              else
              begin
                ASelectBoxTopMapItemStyle.Circle.Fill.Color := Color;
                ASelectBoxTopMapItemStyle.Circle.Stroke.Thickness := 0;
                ASelectBoxTopMapItemStyle.Text.Visible := True;
                break;
              end;
            end
            else
            begin
              if Global.TeeBox.TeeBoxList[Index].TasukNo <> Global.SaleModule.MainItemList[Loop].TasukNo then
              begin
                ASelectBoxTopMapItemStyle.Circle.Fill.Color := TAlphaColorRec.Null;
                ASelectBoxTopMapItemStyle.Circle.Stroke.Thickness := 1;
              end
              else
              begin
                ASelectBoxTopMapItemStyle.Circle.Fill.Color := Color;
                ASelectBoxTopMapItemStyle.Circle.Stroke.Thickness := 0;
                ASelectBoxTopMapItemStyle.Text.Visible := True;
                break;
              end;
            end;
          end;
        end;

        ItemList.Add(ASelectBoxTopMapItemStyle);
        Inc(MapIndex);
      end;
      EndUpdate;

      if Global.SaleModule.MiniMapWidth = 0 then
      begin
        Global.SaleModule.MiniMapWidth := Trunc(RightRectangle.Width);
        LeftRectangle.Width := (1080 - Global.SaleModule.MiniMapWidth) div 2;
      end
      else
      begin
        //제일 많은 타석기준
        Global.SaleModule.MiniMapWidth := IfThen(Global.SaleModule.MiniMapWidth < RightRectangle.Width,
                                            Trunc(RightRectangle.Width),
                                            Global.SaleModule.MiniMapWidth);

        LeftRectangle.Width := (1080 - Global.SaleModule.MiniMapWidth) div 2;
      end;
    finally
      //APosition.Free;
      //FreeAndNil(APoint);
    end;
  except
    //on E: Exception do
      //Log.E('TSelectBoxTopMapListStyle.DisPlayFloor', E.Message);
  end;
end;

end.

