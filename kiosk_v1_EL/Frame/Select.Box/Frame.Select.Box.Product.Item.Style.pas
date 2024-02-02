unit Frame.Select.Box.Product.Item.Style;

interface

uses
  uStruct,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Objects;

type
  TSelectBoxProductItemStyle = class(TFrame)
    Layout: TLayout;
    Image: TImage;
    BodyImage: TImage;
    TopText: TText;
    Text1: TText;
    Text2: TText;
    TasukNoRectangle: TRectangle;
    Rectangle2: TRectangle;
    VipImage: TImage;
    txtVIP: TText;
    SelectRectangle: TRectangle;
    Text3: TText;
    ImgHold: TImage;
    ImgBG: TImage;
    ImgRed: TImage;
    ImgDefault: TImage;
    ImgError: TImage;
    ImgUse: TImage;
    ImgLeftTeebox: TImage;
    ImgOnlyLeftTeebox: TImage;
    ImgSemiAutoTeebox: TImage;
    Text4: TText;
    procedure SelectRectangleClick(Sender: TObject);
  private
    { Private declarations }
    FTeeBoxInfo: TTeeBoxInfo;
    FError: Boolean;
    FTeeBoxClean: Boolean;
  public
    { Public declarations }

    procedure DisPlayTeeBoxInfo;

    property TeeBoxInfo: TTeeBoxInfo read FTeeBoxInfo write FTeeBoxInfo;
    property Error: Boolean read FError write FError;
    property TeeBoxClean: Boolean read FTeeBoxClean write FTeeBoxClean;
  end;

implementation
                // 노랑 #FFFFCB00
uses
  uFunction, uGlobal, uCommon, uConsts, Form.Select.Box, fx.Logging;

{$R *.fmx}

procedure TSelectBoxProductItemStyle.DisPlayTeeBoxInfo;
var
  AHour, AMinute, LimitTime: Integer;
begin
  Error := False;
  TeeBoxClean := False;
  TopText.Text := TeeBoxInfo.Name;

  if Length(TeeBoxInfo.Name) > 3 then
    TopText.Font.Size := 30; //35

  if (TeeBoxInfo.ZoneCode = 'V') then
  begin
    VipImage.Visible := True;
  end;

  if TeeBoxInfo.ZoneCode = 'L' then
    ImgLeftTeebox.Visible := True;

  if TeeBoxInfo.ZoneCode = 'O' then
    ImgOnlyLeftTeebox.Visible := True;

  if (TeeBoxInfo.ERR <> 0) or (TeeBoxInfo.ERR in [7, 8, 9]) or (not TeeBoxInfo.Use) then
  begin
    Error := True;

    Text1.Text := '점검중';

    Text2.Text := '-';
    Text3.Text := '';
    Text4.Text := '';
    ImgError.Visible := True;
  end
  else
  begin
    AHour := TeeBoxInfo.BtweenTime div 60;

    if TeeBoxInfo.Hold then
    begin
      ImgHold.Visible := True;
      Text1.Text := '예약중';
      Text2.Text := '';
      Text3.Text := '';
      Text4.Text := '';
    end
    else if (TeeBoxInfo.BtweenTime = 0) or ((Trim(TeeBoxInfo.Ma_Time) = '0') and (Trim(TeeBoxInfo.End_DT) = EmptyStr)) then
    begin
      TeeBoxClean := True;
      Text1.Text := '즉시예약';
      Text2.Text := '';
      Text3.Text := '';
      Text4.Text := '';
      ImgDefault.Visible := True;
    end
    else if TeeBoxInfo.BtweenTime <> 0 then
    begin
      AMinute := TeeBoxInfo.BtweenTime - (AHour * 60);
      Text1.Text := '사용중';
      Text3.Text := IntToStr(TeeBoxInfo.BtweenTime) + '분';
      Text4.Text := '( ' + TeeBoxInfo.End_DT + ' )';

      if ((Trim(TeeBoxInfo.Ma_Time) = '0') and (Trim(TeeBoxInfo.End_DT) = EmptyStr)) or (TeeBoxInfo.BtweenTime = 0) then
      begin
        ImgUse.Visible := True;
      end
      else
      begin
        if Global.Config.Store.StoreCode = 'T0001' then
          LimitTime := 5
        else
          LimitTime := 10;

        if TeeBoxInfo.BtweenTime < LimitTime then
        begin
          ImgRed.Visible := True;
          Text1.Text := IntToStr(Ifthen(TeeBoxInfo.BtweenTime = 0, 1, TeeBoxInfo.BtweenTime)) + '분 후 종료';
          Text1.TextSettings.Font.Size := 25;
          Text3.Text := '';
        end
        else
        begin  // 파랑 $FF2E74F0      주황 $FFFF8518
          ImgUse.Visible := True;
        end;
      end;
    end
    else
    begin
      ImgHold.Visible := True;
      Text1.Text := '예약중';
      Text2.Text := '-';
      Text4.Text := '';
    end;
  end;
end;

procedure TSelectBoxProductItemStyle.SelectRectangleClick(Sender: TObject);
begin
  TouchSound(False, True);
  try
    if Error then
      SelectBox.ShowErrorMsg(MSG_ERROR_TEEBOX)
    else
    begin
      Log.D('SelectTeeBox', 'Click');
//      SelectBox.Animate(Self.Tag);
      SelectBox.SelectTeeBox(TeeBoxInfo);
      //Log.D('SelectTeeBox', 'Close');

    end;
  except
    on E: Exception do
      Log.E('SelectRectangleClick', E.Message);
  end;
end;

end.
