unit Frame.Select.Box.Top.Map.List.Item.Style;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Objects, uStruct;

type
  TSelectBoxTopMapItemStyle = class(TFrame)
    ImgLayout: TLayout;
    Layout: TLayout;
    Text: TText;
    Circle: TCircle;
    Timer: TTimer;
    procedure CircleClick(Sender: TObject);
    procedure TextClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure FrameClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    FTeeBoxInfo: TTeeBoxInfo;
    FColor: TAlphaColor;
    procedure SetText(AText: string);
  end;

implementation

uses
  Form.Select.Box, uCommon, uGlobal, uConsts, fx.Logging;

{$R *.fmx}

{ TSelectBoxTopMapItemStyle }

procedure TSelectBoxTopMapItemStyle.CircleClick(Sender: TObject);
begin
  if Global.Config.Store.StoreCode = 'A8001' then
    Exit;

  if Circle.Fill.Color = TAlphaColorRec.Null then
    Exit;

  TouchSound(False, True);
  if (FTeeBoxInfo.ERR <> 0) or (FTeeBoxInfo.ERR in [7, 8, 9]) or (not FTeeBoxInfo.Use) then
    Global.SBMessage.ShowMessageModalForm(MSG_ERROR_TEEBOX)
  else
  begin
    SelectBox.SelectTeeBox(FTeeBoxInfo);
    Log.D('SelectTeeBox', 'CircleClick / Close');
  end;
end;

procedure TSelectBoxTopMapItemStyle.FrameClick(Sender: TObject);
begin
  if Global.Config.Store.StoreCode = 'A8001' then
    Exit;

  if Circle.Fill.Color = TAlphaColorRec.Null then
    Exit;

  TouchSound(False, True);
  if (FTeeBoxInfo.ERR <> 0) or (FTeeBoxInfo.ERR in [7, 8, 9]) or (not FTeeBoxInfo.Use) then
    Global.SBMessage.ShowMessageModalForm(MSG_ERROR_TEEBOX)
  else
  begin
    SelectBox.SelectTeeBox(FTeeBoxInfo);
    Log.D('SelectTeeBox', 'FrameClick / Close');
  end;
end;

procedure TSelectBoxTopMapItemStyle.SetText(AText: string);
begin
  Text.Text := AText;
  if AText <> 'X' then
    Text.TextSettings.Font.Family := 'Roboto';

  if Length(AText) >= 5 then
    Text.TextSettings.Font.Size := 13
  else if Length(AText) >= 3 then
    Text.TextSettings.Font.Size := 15; //20font

end;

procedure TSelectBoxTopMapItemStyle.TextClick(Sender: TObject);
begin
  //상단 미선택되도록 옵션 추가 - 2021-09-06 빅토리아
  if Global.Config.TeeboxTopMapNoSelect = True then
    Exit;

  if Global.Config.Store.StoreCode = 'A8001' then
    Exit;

  TouchSound(False, True);
  if (FTeeBoxInfo.ERR <> 0) or (FTeeBoxInfo.ERR in [7, 8, 9]) or (not FTeeBoxInfo.Use) then
    Global.SBMessage.ShowMessageModalForm(MSG_ERROR_TEEBOX)
  else
  begin
    SelectBox.SelectTeeBox(FTeeBoxInfo);
    Log.D('SelectTeeBox', 'TextClick / Close');
  end;
end;

procedure TSelectBoxTopMapItemStyle.TimerTimer(Sender: TObject);
begin
//  Application.ProcessMessages;
  if Circle.Fill.Color <> TAlphaColorRec.Null then
  begin
    if Global.SaleModule.MiniMapCursor then
    begin
      if Global.SaleModule.TeeBoxInfo.TasukNo = FTeeBoxInfo.TasukNo then
      begin
        if Text.TextSettings.FontColor = TAlphaColorRec.Black then
        begin
          Circle.Fill.Color := FColor;
          Text.TextSettings.FontColor := TAlphaColorRec.White;
        end
        else
        begin
          Circle.Fill.Color := TAlphaColorRec.White;
          Text.TextSettings.FontColor := TAlphaColorRec.Black;
        end;
  //        Circle.Stroke.Thickness := 5;
      end;
    end
    else
    begin
      Circle.Fill.Color := FColor;
      Text.TextSettings.FontColor := TAlphaColorRec.White;
    end;
  end;
end;

end.
