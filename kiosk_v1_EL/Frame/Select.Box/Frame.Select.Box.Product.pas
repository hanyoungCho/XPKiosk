unit Frame.Select.Box.Product;

interface

uses
  Frame.Select.Box.Product.Item.Style, FMX.Ani,
  System.Generics.Collections, System.DateUtils, uStruct,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Objects, FMX.Controls.Presentation;

type
  TSelectBoxProduct = class(TFrame)
    Layout: TLayout;
    Image: TImage;
    VertScrollBox: TVertScrollBox;
    BGRectangle: TRectangle;
    Rectangle1: TRectangle;
    Timer: TTimer;
    txtSlider: TText;
    FingerImage: TImage;
    ImageFingerScroll: TImage;
//    procedure RoundRect1Click(Sender: TObject);
//    procedure Text1Click(Sender: TObject);
    procedure VertScrollBoxClick(Sender: TObject);
    procedure VertScrollBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure VertScrollBoxViewportPositionChange(Sender: TObject;
      const OldViewportPosition, NewViewportPosition: TPointF;
      const ContentSizeChanged: Boolean);
    procedure TimerTimer(Sender: TObject);
  private
    { Private declarations }
    FMainItemList: TList<TTeeBoxInfo>;
    FItemList: TList<TSelectBoxProductItemStyle>;
    FFloor: Integer;
    FMouseDownX: Extended;
    FMouseDownY: Extended;
    // 선택시간순
    function SetSortTime: TList<TTeeBoxInfo>;
    // 연속타선순
    function SetSort2TeeBox: TList<TTeeBoxInfo>;
    // 빠른타석순
    function SetSortLowTime: TList<TTeeBoxInfo>;
  public
    { Public declarations }
    procedure Display(AFloor, APage: Integer);
//    procedure SortTeeBox(AIndex: Integer);
    procedure Animate(ItemStyle: TSelectBoxProductItemStyle);
    procedure CloseFrame;

    property MainItemList: TList<TTeeBoxInfo> read FMainItemList write FMainItemList;
    property ItemList: TList<TSelectBoxProductItemStyle> read FItemList write FItemList;
    property Floor: Integer read FFloor write FFloor;
  end;

implementation

uses
  uGlobal, uFunction, fx.Logging, uConsts, uCommon, Form.Select.Box;

{$R *.fmx}

{ TSelectBoxProduct }

procedure TSelectBoxProduct.Animate(ItemStyle: TSelectBoxProductItemStyle);
var
  Bitmap: TBitmap;
begin
  Bitmap := ItemStyle.MakeScreenshot;
  try
    try
      Image.Bitmap.Assign(Bitmap);
      Image.Visible := True;
      Image.Position.X := ItemStyle.Position.X - (VertScrollBox.Position.X - 140);
      Image.Position.Y := VertScrollBox.Margins.Top + ItemStyle.Position.Y - VertScrollBox.Position.Y;
      Image.Width := ItemStyle.Width;
      Image.Height := ItemStyle.Height;
      Image.Scale.X := 1;
      Image.Scale.Y := 1;
      Image.Opacity := 0.8;
    except
      on E: Exception do
        Log.E('TSelectBoxProduct.Animate', E.Message);
    end;
  finally
    Bitmap.Free;
  end;
  TAnimator.AnimateFloat(Image, 'Position.X', Image.Position.X - Image.Width * 0.3, 0.5);
  TAnimator.AnimateFloat(Image, 'Position.Y', Image.Position.Y - Image.Height * 0.3, 0.5);
  TAnimator.AnimateFloat(Image, 'Scale.X', 1.6, 0.5);
  TAnimator.AnimateFloat(Image, 'Scale.Y', 1.6, 0.5);
  TAnimator.AnimateFloat(Image, 'Opacity', 0, 0.5);
//  TAnimator.StopAnimation(Self, '');
end;

procedure TSelectBoxProduct.CloseFrame;
var
  Index: Integer;
begin
  {
  if MainItemList <> nil then
  begin
    for Index := MainItemList.Count - 1 downto 0 do
      MainItemList.Delete(Index);

    MainItemList.Free;
  end;
  }
  if ItemList <> nil then
  begin
    for Index := ItemList.Count - 1 downto 0 do
      RemoveObject(ItemList[Index]);//ItemList.Delete(Index);

    ItemList.Free;
  end;
end;

procedure TSelectBoxProduct.Display(AFloor, APage: Integer);
var
  EndTime: string;
  Index, ColIndex, RowIndex, BoxCnt, ItemCnt: Integer;
  Y, X: Single;
  APosition: TPosition;
  APoint: TPointF;
  ASelectBoxProductItemStyle: TSelectBoxProductItemStyle;
  ATeeBoxInfo: TTeeBoxInfo;
  nColIndex, nPageBoxCnt: Integer;
begin
  try
    try
      FFloor := AFloor;

      if (Global.TeeBox.TeeBoxList.Count = 0) or (Global.TeeBox.UpdateTeeBoxList.Count <> 0) then
        Global.TeeBox.TeeBoxList := Global.TeeBox.UpdateTeeBoxList;

      if Global.SaleModule.TeeBoxSortType = tstDefault then
        MainItemList := Global.TeeBox.TeeBoxList
      else if Global.SaleModule.TeeBoxSortType = tstTime then
        MainItemList := SetSortTime
      else if Global.SaleModule.TeeBoxSortType = tst2TeeBox then
        MainItemList := SetSort2TeeBox
      else
        MainItemList := SetSortLowTime;

      Global.SaleModule.MainItemList := MainItemList;

      if FItemList = nil then
        FItemList := TList<TSelectBoxProductItemStyle>.Create;

      if FItemList.Count <> 0 then
      begin
        for Index := FItemList.Count - 1 downto 0 do
          FItemList.Delete(Index);

        FItemList.Clear;
      end;

      X := 0;
      Y := 0;

      RowIndex := 0;
      ColIndex := 0;
      BoxCnt := 0;
      nPageBoxCnt := 0;

      APoint := TPointF.Create(Y, X);
      APosition := TPosition.Create(APoint);

      for Index := VertScrollBox.Content.ChildrenCount - 1 downto 0 do
        VertScrollBox.Content.Children[Index].Free;

      VertScrollBox.Content.DeleteChildren;
      VertScrollBox.Content.Repaint;

      if Global.TeeBox.FloorMaxTeeboxCnt <= 16 then
        nColIndex := 4 //4*4
      else if Global.TeeBox.FloorMaxTeeboxCnt <= 25 then
        nColIndex := 5 //5*5
      else if Global.TeeBox.FloorMaxTeeboxCnt <= 36 then
        nColIndex := 6 //6*6
      else
        nColIndex := 5;

      if nColIndex = 6 then
      begin
        Layout.Position.X := 45; //기존 70
        Layout.Position.y := 0; //기존 140, 실제15
        ImageFingerScroll.Visible := False;
      end;

      for Index := 0 to MainItemList.Count - 1 do
      begin
        if MainItemList[Index].Use = false then
          Continue;

        EndTime := EmptyStr;

        if AFloor <> -1 then
        begin
          if ((MainItemList[Index].FloorCd <> AFloor) and not Global.SaleModule.AllTeeBoxShow) then
            Continue
          else if MainItemList[Index].FloorCd <> AFloor then
            Continue;
        end;

        //nColIndex := 4;
        //nColIndex := nDisplayType;

        if ColIndex = nColIndex then
        begin
          Inc(RowIndex);
          ColIndex := 0;
        end;

        ASelectBoxProductItemStyle := TSelectBoxProductItemStyle.Create(nil);

        if nColIndex = 6 then
        begin
          ASelectBoxProductItemStyle.Scale.x := 0.9;
          ASelectBoxProductItemStyle.Scale.y := 0.9;
          APosition.X := 35 + (14 * ColIndex) + ColIndex * (ASelectBoxProductItemStyle.Width * 0.9); //35 말풍선영역
          APosition.Y := 15 + (14 * RowIndex) + RowIndex * (ASelectBoxProductItemStyle.Height * 0.9); //15 말풍선영역
        end
        else if nColIndex = 4 then
        begin
          ASelectBoxProductItemStyle.Scale.x := 1.3;
          ASelectBoxProductItemStyle.Scale.y := 1.3;
          APosition.X := 35 + (14 * ColIndex) + ColIndex * (ASelectBoxProductItemStyle.Width * 1.3);
          APosition.Y := 15 + (14 * RowIndex) + RowIndex * (ASelectBoxProductItemStyle.Height * 1.3);
        end
        else //if nColIndex = 5 then
        begin
          APosition.X := 35 + (14 * ColIndex) + ColIndex * (ASelectBoxProductItemStyle.Width + 10);
          APosition.Y := 15 + (14 * RowIndex) + RowIndex * (ASelectBoxProductItemStyle.Height + 10);
        end;

        ASelectBoxProductItemStyle.Position := APosition;

        ASelectBoxProductItemStyle.Parent := VertScrollBox;//Layout;
        ASelectBoxProductItemStyle.Tag := BoxCnt;

        ATeeBoxInfo := MainItemList[Index];

        ATeeBoxInfo.FloorNm := Global.TeeBox.GetTeeBoxFloorNm(ATeeBoxInfo.TasukNo);

        ASelectBoxProductItemStyle.TeeBoxInfo := ATeeBoxInfo;

        ASelectBoxProductItemStyle.DisPlayTeeBoxInfo;

        ItemList.Add(ASelectBoxProductItemStyle);
        Inc(ColIndex);
        Inc(BoxCnt);

      end;

      for Index := 0 to Global.TeeBox.TeeBoxList.Count - 1 do
      begin
        ATeeBoxInfo := Global.TeeBox.TeeBoxList[Index];
        ATeeBoxInfo.Add_OK := False;
        Global.TeeBox.TeeBoxList[Index] := ATeeBoxInfo;
      end;
    except
      on E: Exception do
        Log.E('??', E.Message);
    end;
  finally
    APosition.Free;;
    FreeAndNil(APoint);
  end;
end;

procedure TSelectBoxProduct.VertScrollBoxClick(Sender: TObject);
var
  I: Integer;
  MouseService: IFMXMouseService;
  P: TPointF;
begin
  if SupportsPlatformService(IFMXMouseService, MouseService) then
  begin
    P := MouseService.GetMousePos;

    if Abs(P.X - FMouseDownX) > 10 then
      Exit;

    if Abs(P.Y - FMouseDownY) > 10 then
      Exit;
  end;
end;

procedure TSelectBoxProduct.VertScrollBoxMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  MouseService: IFMXMouseService;
  P: TPointF;
begin
  if SupportsPlatformService(IFMXMouseService, MouseService) then
  begin
    P := MouseService.GetMousePos;

    FMouseDownX := P.X;
    FMouseDownY := P.Y;
  end;
end;

procedure TSelectBoxProduct.VertScrollBoxViewportPositionChange(Sender: TObject;
  const OldViewportPosition, NewViewportPosition: TPointF;
  const ContentSizeChanged: Boolean);
begin
//
end;

function TSelectBoxProduct.SetSortTime: TList<TTeeBoxInfo>;
var
  Index, ABtweenTime: Integer;
  EndDateTime: TDateTime;
  ATeeBoxInfo: TTeeBoxInfo;
begin
  try
    Result := TList<TTeeBoxInfo>.Create;

    for Index := 0 to Global.TeeBox.TeeBoxList.Count - 1 do
    begin
      if Global.TeeBox.TeeBoxList[Index].ERR <> 0 then
          Continue;

      if (Trim(Global.TeeBox.TeeBoxList[Index].Ma_Time) = '0') and (Trim(Global.TeeBox.TeeBoxList[Index].End_DT) = EmptyStr) then
        Continue;

//      if (Floor = Global.TeeBox.TeeBoxList[Index].High) or Global.SaleModule.AllTeeBoxShow then
      if True then
      begin
        if not Global.TeeBox.TeeBoxList[Index].Add_OK then
        begin
          EndDateTime := DateStrToDateTime(FormatDateTime('YYYYMMDD', now) +
                                                   Copy(StringReplace(Global.TeeBox.TeeBoxList[Index].End_Time, ':', '', [rfReplaceAll]), 1, 2) + '0000');
          ABtweenTime := MinutesBetween(Global.SaleModule.SelectTime, EndDateTime);

          if Global.SaleModule.SelectTime = EndDateTime then
//          if ABtweenTime <= Global.TeeBox.TeeBoxList[Index].BtweenTime then
          begin
            ATeeBoxInfo := Global.TeeBox.TeeBoxList[Index];
            ATeeBoxInfo.Add_OK := True;
            Result.Add(ATeeBoxInfo);
            Global.TeeBox.TeeBoxList[Index] := ATeeBoxInfo;
          end;
        end;
      end;
    end;
  finally

  end;
end;

procedure TSelectBoxProduct.TimerTimer(Sender: TObject);
begin
//  if SlideRectangle.Position.Y <= 70 then
//    SlideRectangle.Position.Y := 300
//  else
//    SlideRectangle.Position.Y := SlideRectangle.Position.Y - 1;
end;

function TSelectBoxProduct.SetSort2TeeBox: TList<TTeeBoxInfo>;
var
  Index, Loop, AHour, AMinute, AddIndex: Integer;
  ATeeBoxInfo: TTeeBoxInfo;
  ATeeBox10MinuteList, ATeeBox10MinuteSetList: TList<TTeeBoxInfo>;
  function AddTeeBox10MinuteSetList_10MinuteList(AIndex: Integer): Boolean;
  begin
    try
      Result := False;
      if not ATeeBox10MinuteList[AIndex].Add_OK then
      begin
        ATeeBoxInfo := ATeeBox10MinuteList[AIndex];
        ATeeBoxInfo.Add_OK := True;
        ATeeBox10MinuteList[AIndex] := ATeeBoxInfo;
        ATeeBox10MinuteSetList.Add(ATeeBox10MinuteList[AIndex]);
      end;
      Result := True;
    except
      on E: Exception do
      begin

      end;
    end;
  end;
begin
  try
    Result := TList<TTeeBoxInfo>.Create;
    ATeeBox10MinuteList := TList<TTeeBoxInfo>.Create;
    ATeeBox10MinuteSetList := TList<TTeeBoxInfo>.Create;

    // List에서 10분 이하 타석을 저장
    for Index := 0 to Global.TeeBox.TeeBoxList.Count - 1 do
    begin
      if Global.TeeBox.TeeBoxList[Index].ERR <> 0 then
        Continue;

      if not Global.TeeBox.TeeBoxList[Index].Use then
        Continue;

//      if Floor = Global.TeeBox.TeeBoxList[Index].High then
//      begin
        ATeeBoxInfo := Global.TeeBox.TeeBoxList[Index];
        if not Global.TeeBox.TeeBoxList[Index].Add_OK then
        begin
          if (Global.TeeBox.TeeBoxList[Index].BtweenTime = 0) or ((Trim(Global.TeeBox.TeeBoxList[Index].Ma_Time) = '0')
            and (Trim(Global.TeeBox.TeeBoxList[Index].End_DT) = EmptyStr)) then
          begin
            ATeeBoxInfo := Global.TeeBox.TeeBoxList[Index];
            ATeeBox10MinuteList.Add(ATeeBoxInfo);
            Global.TeeBox.TeeBoxList[Index] := ATeeBoxInfo;
          end
          else
          begin
//             jangheejin Test로 120분
            if Global.TeeBox.TeeBoxList[Index].BtweenTime <= 10 then
            begin
              ATeeBoxInfo := Global.TeeBox.TeeBoxList[Index];
              ATeeBox10MinuteList.Add(ATeeBoxInfo);
              Global.TeeBox.TeeBoxList[Index] := ATeeBoxInfo;
            end;
          end;
        end;
//      end;
    end;

    AddIndex := 0;

    for Loop := 0 to Global.TeeBox.FloorList.Count - 1 do
    begin
      for Index := 0 to ATeeBox10MinuteList.Count - 1 do
      begin
        if (Loop + 1 + AddIndex) = ATeeBox10MinuteList[Index].FloorCd then
        begin
          if Index = 0 then
          begin // 뒤
            if (Index + 1) <> ATeeBox10MinuteList.Count then
            begin
              if ATeeBox10MinuteList[Index].TasukNo = (ATeeBox10MinuteList[Index + 1].TasukNo - 1) then
                if (Loop + 1 + AddIndex) = ATeeBox10MinuteList[Index + 1].FloorCd then
                  AddTeeBox10MinuteSetList_10MinuteList(Index);
            end;
          end
          else if (Index + 1) = ATeeBox10MinuteList.Count then
          begin // 앞
            if (ATeeBox10MinuteList[Index - 1].TasukNo + 1) = (ATeeBox10MinuteList[Index].TasukNo) then
              if (Loop + 1 + AddIndex) = ATeeBox10MinuteList[Index - 1].FloorCd then
                AddTeeBox10MinuteSetList_10MinuteList(Index);
          end
          else // 앞뒤
          begin
            if (ATeeBox10MinuteList[Index - 1].TasukNo + 1) = (ATeeBox10MinuteList[Index].TasukNo) then
              if (Loop + 1 + AddIndex) = ATeeBox10MinuteList[Index - 1].FloorCd then
                AddTeeBox10MinuteSetList_10MinuteList(Index);

            if ATeeBox10MinuteList[Index].TasukNo = (ATeeBox10MinuteList[Index + 1].TasukNo - 1) then
              if (Loop + 1 + AddIndex) = ATeeBox10MinuteList[Index + 1].FloorCd then
                AddTeeBox10MinuteSetList_10MinuteList(Index);
          end;
        end;
      end;
    end;
    Result := ATeeBox10MinuteSetList;
  finally

  end;
end;

function TSelectBoxProduct.SetSortLowTime: TList<TTeeBoxInfo>;
var
  Index, Loop, AValue, AHour, AMinute: Integer;
  ANumberSort: TList<Integer>;
  ATeeBoxInfo: TTeeBoxInfo;
  AddInfo: Boolean;
begin
  try
    Result := TList<TTeeBoxInfo>.Create;
    ANumberSort := TList<Integer>.Create;

    for Index := 0 to Global.TeeBox.TeeBoxList.Count - 1 do
    begin

      if Global.TeeBox.TeeBoxList[Index].ERR <> 0 then
        Continue;

      if not Global.TeeBox.TeeBoxList[Index].Use then
        Continue;

      if (Global.TeeBox.TeeBoxList[Index].BtweenTime = 0) or (Trim(Global.TeeBox.TeeBoxList[Index].Ma_Time) = '0')
        and (Trim(Global.TeeBox.TeeBoxList[Index].End_DT) = EmptyStr) then
        ANumberSort.Add(0)
      else
      begin
        if Global.TeeBox.TeeBoxList[Index].BtweenTime <> 0 then
        begin
          ATeeBoxInfo := Global.TeeBox.TeeBoxList[Index];
          AValue := Global.TeeBox.TeeBoxList[Index].BtweenTime;
          ANumberSort.Add(Global.TeeBox.TeeBoxList[Index].BtweenTime);
        end;
      end;
    end;

    ANumberSort.Sort;
    try
      if ANumberSort.Count <> 0 then
      begin
        for Index := 0 to ANumberSort.Count - 1 do
        begin
          AddInfo := False;
          for Loop := 0 to Global.TeeBox.TeeBoxList.Count - 1 do
          begin

            if Global.Config.Store.StoreCode <> 'A8001' then //쇼골프
            begin
              if Result.Count = 24 then
                Continue;
            end;

            if Global.TeeBox.TeeBoxList[Loop].ERR <> 0 then
              Continue;

            if not Global.TeeBox.TeeBoxList[Loop].Use then
              Continue;

            if not Global.TeeBox.TeeBoxList[Loop].Add_OK then
            begin
              if ANumberSort[Index] = 0 then
              begin
                if (Global.TeeBox.TeeBoxList[Loop].BtweenTime = 0) or ((Trim(Global.TeeBox.TeeBoxList[Loop].Ma_Time) = '0')
                  and (Trim(Global.TeeBox.TeeBoxList[Loop].End_DT) = EmptyStr)) then
                begin
                  ATeeBoxInfo := Global.TeeBox.TeeBoxList[Loop];
                  ATeeBoxInfo.Add_OK := True;
                  Global.TeeBox.TeeBoxList[Loop] := ATeeBoxInfo;
                  Result.Add(ATeeBoxInfo);
                  AddInfo := True;
                end;
              end
              else
              begin
                if ANumberSort[Index] = Global.TeeBox.TeeBoxList[Loop].BtweenTime then
                begin
                  ATeeBoxInfo := Global.TeeBox.TeeBoxList[Loop];
                  ATeeBoxInfo.Add_OK := True;
                  Global.TeeBox.TeeBoxList[Loop] := ATeeBoxInfo;
                  Result.Add(ATeeBoxInfo);
                  AddInfo := True;
                end;
              end;
            end;
          end;
        end;
      end;
    except
      on E: Exception do
      begin
        Index := Index;
      end;

    end;

//    for Index := 0 to Result.Count - 1 do
//    begin
//      Log.D('타석 체크', Result[Index].Mno + '-' + IntToStr(Result[Index].High));
//    end;
//    Log.D('타석 체크', 'ENd');
  finally
    ANumberSort.Free;
  end;
end;

end.
