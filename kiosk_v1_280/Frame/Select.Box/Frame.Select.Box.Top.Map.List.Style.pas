unit Frame.Select.Box.Top.Map.List.Style;

interface

uses
  Frame.Select.Box.Top.Map.List.Item.Style, Math,
  System.Generics.Collections, System.DateUtils,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Layouts,
  Frame.Select.Box.Top.Map.List.Item.RoundStyle;

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
    FItemRoundList: TList<TSelectBoxTopMapItemRoundStyle>;
  public
    { Public declarations }
    function DisPlayFloor(AFloor: Integer; AFloorNm: String): Boolean;
    function DisPlayFloorRound(AFloor: Integer; AFloorNm: String): Boolean;
    procedure CloseFrame;

    property ItemList: TList<TSelectBoxTopMapItemStyle> read FItemList write FItemList;
    property ItemRoundList: TList<TSelectBoxTopMapItemRoundStyle> read FItemRoundList write FItemRoundList;
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

  if Global.Config.Store.StoreCode = 'A8001' then
  begin
    if ItemRoundList = nil then
      Exit;

    for Index := ItemRoundList.Count - 1 to 0 do
      ItemRoundList.Delete(Index);

    ItemRoundList.Free;
  end
  else
  begin
    if ItemList = nil then
      Exit;

    for Index := ItemList.Count - 1 to 0 do
      ItemList.Delete(Index);

    ItemList.Free;
  end;
end;

//2020-11-05 층명칭
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

    Text.Text := AFloorNm; //2020-11-05 층명칭

    RightRectangle.Width := 0;

    for Loop := RightRectangle.ChildrenCount - 1 downto 0 do
      RightRectangle.Children[Loop].Free;

    RightRectangle.DeleteChildren;

    TopMargin := 0;
    TopMarginCnt := 0;

    if (Global.Config.StoreType = '2') then
    begin
      AFloorCnt := Global.TeeBox.FloorMaxTeeboxCnt;
    end
    else
    begin
      for Index := 0 to Global.TeeBox.TeeBoxList.Count - 1 do
      begin
        if Global.TeeBox.TeeBoxList[Index].High = AFloor then
          Inc(AFloorCnt);
      end;
    end;

    AFloorCnt_Mod := AFloorCnt mod 2;
    RoundValue := 2;

    // 층명 표시 여부
    if (Global.Config.Store.StoreCode = 'A6001') then //	캐슬렉스서울
    begin
      LeftRectangle.Margins.Left := -10;
      RightRectangle.Margins.Left := 15;
    end
    else
    begin
      //if (Global.TeeBox.FloorMaxTeeboxCnt > FLOOR_MAX_CNT) or
      if (Global.TeeBox.FloorMaxTeeboxCnt > 25) or  //27 -> 25 강릉리더스 26타석 층 명칭 밀림 2022-09-28
         (Global.Config.Store.StoreCode = 'A1001') or  //스타
         (Global.Config.Store.StoreCode = 'A4001') or  //유명
         (Global.Config.Store.StoreCode = 'B7001') then //프라자
      begin
        RightRectangle.Margins.Left := -25;
        LeftRectangle.Visible := False;
      end;
    end;

    for Index := 0 to Global.TeeBox.TeeBoxList.Count - 1 do
    begin
      if (Global.Config.StoreType = '2') then
      begin
        if Afloor = 2 then
        begin
          if Index > 23 then
            Continue;
        end;

        if Afloor = 1 then
        begin
          if Index <= 23 then
            Continue;
        end;

        if Global.TeeBox.TeeBoxList[Index].Use = False then
          Continue;

        if Global.TeeBox.TeeBoxList[Index].DelYn = True then
          Continue;
      end
      else
      begin
        if Global.TeeBox.TeeBoxList[Index].High <> AFloor then
          Continue;
      end;

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

      if (Global.Config.Store.StoreCode = 'A6001') then //	캐슬렉스서울
      begin
        ASelectBoxTopMapItemStyle.Width := 1010 / Global.TeeBox.FloorMaxTeeboxCnt;
      end
      else
      begin
        // JMS 처리 해야 됨
        if Global.TeeBox.FloorMaxTeeboxCnt > FLOOR_MAX_CNT then
        begin
          Text.Visible := False;

          if Global.Config.Store.StoreCode = 'A4001' then //유명
            ASelectBoxTopMapItemStyle.Width := 1060 / Global.TeeBox.FloorMaxTeeboxCnt
          else
            ASelectBoxTopMapItemStyle.Width := 1080 / Global.TeeBox.FloorMaxTeeboxCnt;
        end;
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
        ASelectBoxTopMapItemStyle.SetText(Global.TeeBox.TeeBoxList[Index].Mno);
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
        ASelectBoxTopMapItemStyle.SetText(Global.TeeBox.TeeBoxList[Index].Mno);

        if (Global.TeeBox.TeeBoxList[Index].BtweenTime = 0) or ((Trim(Global.TeeBox.TeeBoxList[Index].Ma_Time) = '0') and (Trim(Global.TeeBox.TeeBoxList[Index].End_DT) = EmptyStr)) then
        begin
          Color := $FF00CE13;//$FF45D10E;
          ASelectBoxTopMapItemStyle.Circle.Fill.Color := Color;//$FF5FB459//$FF555555 //TAlphaColorRec.Null
        end
        else if Global.TeeBox.TeeBoxList[Index].BtweenTime <> 0 then //  777777 Gray  85AC82 GREEN   $FF544ED6 RED
        begin
          if Global.Config.Store.StoreCode = 'T0001' then
            LimitTime := 5
          else
            LimitTime := 10;

          if Global.TeeBox.TeeBoxList[Index].BtweenTime < LimitTime then
          begin
            Color := $FFF30033;//$FFF60A14;//
            ASelectBoxTopMapItemStyle.Circle.Fill.Color := Color; //TAlphaColorRec.Red;
          end
          else
          begin
            if Global.Config.Store.StoreCode = 'B9001' then //파스텔골프클럽
              Color := $FF001AFF
            else
              Color := $FFFF8518;//$FF2E74F0;//$FFF0742E;//TAlphaColorRec.Coral;//$FF2366EC;//$FFFFCB00;

            ASelectBoxTopMapItemStyle.Circle.Fill.Color := Color;//$FF777777; //$FF80C97A; //TAlphaColorRec.Lightgreen;
          end;
        end
        else if Global.TeeBox.TeeBoxList[Index].Hold {and (Global.TeeBox.TeeBoxList[Index].TasukNo <> Global.SaleModule.LastHoldNo)} then
        begin
          Color := $FFAC8282;
          ASelectBoxTopMapItemStyle.Circle.Fill.Color := Color;
        end

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
          AMapCnt := IfThen(Global.SaleModule.MainItemList.Count > 50, 50, Global.SaleModule.MainItemList.Count); //빠른타석 표시수변경
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

      if (Global.Config.Store.StoreCode = 'A6001') then //	캐슬렉스서울
        LeftRectangle.Width := (1080 - Global.SaleModule.MiniMapWidth)
      else
        LeftRectangle.Width := (1080 - Global.SaleModule.MiniMapWidth) div 2;
    end;
  finally
  end;
end;

function TSelectBoxTopMapListStyle.DisPlayFloorRound(AFloor: Integer; AFloorNm: String): Boolean;
var
  EndDateTime: TDateTime;
  Index, Loop, ABetweenTime, MapIndex, AHour, AMinute, AMapCnt, AFloorCnt, LimitTime: Integer;
  TopMargin: Currency;
  Y, X, XTemp: Single;
  EndTime: string;
  ASelectBoxTopMapItemRoundStyle: TSelectBoxTopMapItemRoundStyle;
  Color: TAlphaColor;
  ItemSize: Single;
begin
  try
    BeginUpdate;
    Result := True;
    if FItemRoundList = nil then
      FItemRoundList := TList<TSelectBoxTopMapItemRoundStyle>.Create;

    if FItemRoundList.Count <> 0 then
    begin
     for Index := FItemRoundList.Count - 1 to 0 do
     begin
       ASelectBoxTopMapItemRoundStyle := FItemRoundList[Index];
       FreeAndNil(ASelectBoxTopMapItemRoundStyle);
       FItemRoundList.Delete(Index);
     end;
      FItemRoundList.Clear;
    end;

    X := 0;
    Y := 0;
    MapIndex := 0;
    AFloorCnt := 0;

    Text.Text := AFloorNm;

    RightRectangle.Width := 0;

    for Loop := RightRectangle.ChildrenCount - 1 downto 0 do
      RightRectangle.Children[Loop].Free;

    RightRectangle.DeleteChildren;

    TopMargin := 0;

    AFloorCnt := Global.TeeBox.FloorMaxTeeboxCnt;

    ItemSize := 1080 / AFloorCnt;

    RightRectangle.Margins.Left := -35;
    RightRectangle.Height := ItemSize * 2 ;

    LeftRectangle.Align := TAlignLayout.None;
    LeftRectangle.Position.Y := -20;
    //LeftRectangle.Height := ItemSize * 2;
    LeftRectangle.Width := 70;

    for Index := 0 to Global.TeeBox.TeeBoxList.Count - 1 do
    begin
      if Global.TeeBox.TeeBoxList[Index].High <> AFloor then
        Continue;

      ASelectBoxTopMapItemRoundStyle := TSelectBoxTopMapItemRoundStyle.Create(nil);

      //Text.Visible := False; //층표시

      ASelectBoxTopMapItemRoundStyle.Width := ItemSize;
      ASelectBoxTopMapItemRoundStyle.Height := ItemSize * 2;
      ASelectBoxTopMapItemRoundStyle.RoundRect.Height := ItemSize;
      ASelectBoxTopMapItemRoundStyle.VipImage.Visible := false;

      //V	VIP타석- 2칸,X	VIP룸(싱글),C	VIP룸(커플)-3칸
      //if (Global.TeeBox.TeeBoxList[Index].TasukNo >= 142) and (Global.TeeBox.TeeBoxList[Index].TasukNo <= 148) then
      if (Global.TeeBox.TeeBoxList[Index].ZoneCode = 'V') then
      begin
        ASelectBoxTopMapItemRoundStyle.Width := ItemSize * 2;
        ASelectBoxTopMapItemRoundStyle.VipImage.Visible := True;
      end;

      //if (Global.TeeBox.TeeBoxList[Index].TasukNo >= 181) and (Global.TeeBox.TeeBoxList[Index].TasukNo <= 182) then
      if (Global.TeeBox.TeeBoxList[Index].ZoneCode = 'X') or (Global.TeeBox.TeeBoxList[Index].ZoneCode = 'C') then
      begin
        ASelectBoxTopMapItemRoundStyle.Width := ItemSize * 3;
        ASelectBoxTopMapItemRoundStyle.VipImage.Visible := True;
      end;

      if Index = 0 then
        XTemp := 0
      else
        XTemp := XTemp + ASelectBoxTopMapItemRoundStyle.Width;
      ASelectBoxTopMapItemRoundStyle.Position.X := XTemp;
      ASelectBoxTopMapItemRoundStyle.Position.Y := TopMargin;

      RightRectangle.Width := RightRectangle.Width + ASelectBoxTopMapItemRoundStyle.Width;
      //RightRectangle.Height := ASelectBoxTopMapItemRoundStyle.Height + 25 ;
      //LeftRectangle.Height := ASelectBoxTopMapItemRoundStyle.Height + 25 ;
      //ASelectBoxTopMapItemRoundStyle.Position := APosition;
      ASelectBoxTopMapItemRoundStyle.Text.TextSettings.FontColor := TAlphaColorRec.White;
      ASelectBoxTopMapItemRoundStyle.FTeeBoxInfo := Global.TeeBox.TeeBoxList[Index];

      if Global.TeeBox.TeeBoxList[Index].Hold then
      begin
        Color := $FFAC8282;
        ASelectBoxTopMapItemRoundStyle.SetText(Global.TeeBox.TeeBoxList[Index].Mno);
        ASelectBoxTopMapItemRoundStyle.RoundRect.Fill.Color := Color;
      end
      else if (Global.TeeBox.TeeBoxList[Index].ERR <> 0) or (not Global.TeeBox.TeeBoxList[Index].Use) then
      begin
        ASelectBoxTopMapItemRoundStyle.SetText('X');
        Color := $FF5C5C5C;// $FF777777;
        ASelectBoxTopMapItemRoundStyle.RoundRect.Fill.Color := Color; //$FFB8B8B8;
      end
      else
      begin
        ASelectBoxTopMapItemRoundStyle.Tag := Global.TeeBox.TeeBoxList[Index].TasukNo;
        ASelectBoxTopMapItemRoundStyle.SetText(Global.TeeBox.TeeBoxList[Index].Mno);

        if (Global.TeeBox.TeeBoxList[Index].BtweenTime = 0) or ((Trim(Global.TeeBox.TeeBoxList[Index].Ma_Time) = '0') and (Trim(Global.TeeBox.TeeBoxList[Index].End_DT) = EmptyStr)) then
        begin
          Color := $FF00CE13;//$FF45D10E;
          ASelectBoxTopMapItemRoundStyle.RoundRect.Fill.Color := Color;//$FF5FB459//$FF555555 //TAlphaColorRec.Null
        end
        else if Global.TeeBox.TeeBoxList[Index].BtweenTime <> 0 then                                              //  777777 Gray  85AC82 GREEN   $FF544ED6 RED
        begin
          if Global.Config.Store.StoreCode = 'T0001' then
            LimitTime := 5
          else
            LimitTime := 10;

          if Global.TeeBox.TeeBoxList[Index].BtweenTime < LimitTime then
          begin
            Color := $FFF30033;//$FFF60A14;//
            ASelectBoxTopMapItemRoundStyle.RoundRect.Fill.Color := Color; //TAlphaColorRec.Red;
          end
          else
          begin
            Color := $FFFF8518;//$FF2E74F0;//$FFF0742E;//TAlphaColorRec.Coral;//$FF2366EC;//$FFFFCB00;
            ASelectBoxTopMapItemRoundStyle.RoundRect.Fill.Color := Color;//$FF777777; //$FF80C97A; //TAlphaColorRec.Lightgreen;
          end;
        end
        else if Global.TeeBox.TeeBoxList[Index].Hold {and (Global.TeeBox.TeeBoxList[Index].TasukNo <> Global.SaleModule.LastHoldNo)} then
        begin
          Color := $FFAC8282;
          ASelectBoxTopMapItemRoundStyle.RoundRect.Fill.Color := Color;
        end

      end;
      ASelectBoxTopMapItemRoundStyle.Parent := RightRectangle;
      ASelectBoxTopMapItemRoundStyle.FColor := Color;

      ASelectBoxTopMapItemRoundStyle.Align := TAlignLayout.Left;
      ASelectBoxTopMapItemRoundStyle.Margins.Top := TopMargin;

      if Global.SaleModule.MainItemMapUse then
      begin
        AMapCnt := 0;
        AMapCnt := Global.SaleModule.MainItemList.Count;

        for Loop := 0 to AMapCnt - 1 do
        begin
          if Global.SaleModule.TeeBoxSortType = tstTime then
          begin
            EndDateTime := DateStrToDateTime(FormatDateTime('YYYYMMDD', now) +
                                                   Copy(StringReplace(Global.TeeBox.TeeBoxList[Index].End_Time, ':', '', [rfReplaceAll]), 1, 2) + '0000');
            if Global.SaleModule.SelectTime <> EndDateTime then
            begin
              ASelectBoxTopMapItemRoundStyle.RoundRect.Fill.Color := TAlphaColorRec.Null;
              ASelectBoxTopMapItemRoundStyle.RoundRect.Stroke.Thickness := 1;
            end
            else
            begin
              ASelectBoxTopMapItemRoundStyle.RoundRect.Fill.Color := Color;
              ASelectBoxTopMapItemRoundStyle.RoundRect.Stroke.Thickness := 0;
              ASelectBoxTopMapItemRoundStyle.Text.Visible := True;
              break;
            end;
          end
          else
          begin
            if Global.TeeBox.TeeBoxList[Index].TasukNo <> Global.SaleModule.MainItemList[Loop].TasukNo then
            begin
              ASelectBoxTopMapItemRoundStyle.RoundRect.Fill.Color := TAlphaColorRec.Null;
              ASelectBoxTopMapItemRoundStyle.RoundRect.Stroke.Thickness := 1;
            end
            else
            begin
              ASelectBoxTopMapItemRoundStyle.RoundRect.Fill.Color := Color;
              ASelectBoxTopMapItemRoundStyle.RoundRect.Stroke.Thickness := 0;
              ASelectBoxTopMapItemRoundStyle.Text.Visible := True;
              break;
            end;
          end;
        end;
      end;

      FItemRoundList.Add(ASelectBoxTopMapItemRoundStyle);
      Inc(MapIndex);
    end;
    EndUpdate;

  finally
  end;
end;

end.

