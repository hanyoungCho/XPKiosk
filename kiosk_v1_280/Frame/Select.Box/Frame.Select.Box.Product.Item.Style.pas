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
    ImgUsePastel: TImage;
    ImgLeftTeeboxPastel: TImage;
    ImgTeam: TImage;
    ImgSwingTeebox: TImage;
    ImgLeftTeeboxFirst: TImage;
    ImgTrackman: TImage;
    ImgInside: TImage;
    ImgCouple: TImage;
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
  uFunction, uGlobal, uCommon, uConsts, Form.Select.Box, Form.Select_In.Box, fx.Logging;

{$R *.fmx}

procedure TSelectBoxProductItemStyle.DisPlayTeeBoxInfo;
var
  AHour, AMinute, LimitTime: Integer;
begin
  try
    try
      Error := False;
      TeeBoxClean := False;
      TopText.Text := TeeBoxInfo.Mno;

      if Length(TeeBoxInfo.Mno) > 3 then
        TopText.Font.Size := 30; //35

      //if TeeBoxInfo.Vip then
      if (TeeBoxInfo.ZoneCode = 'V') or (TeeBoxInfo.ZoneCode = 'X') or (TeeBoxInfo.ZoneCode = 'C') then
      begin
        if (Global.Config.StoreType = '2') then
          ImgTeam.Visible := True
        else
        begin
          if (global.Config.Store.StoreCode = 'A8004') and (TeeBoxInfo.ZoneCode = 'C') then
            ImgCouple.Visible := True
          else
            VipImage.Visible := True;
        end;
      end;

      if TeeBoxInfo.ZoneCode = 'L' then
      begin
        if Global.Config.Store.StoreCode = 'B9001' then //파스텔골프클럽
          ImgLeftTeeboxPastel.Visible := True
        else if Global.Config.Store.StoreCode = 'C0001' then //강릉리더스
          ImgLeftTeeboxFirst.Visible := True
        else
          ImgLeftTeebox.Visible := True;
      end;

      if TeeBoxInfo.ZoneCode = 'O' then
        ImgOnlyLeftTeebox.Visible := True;

      //2020-12-18 빅토리아 반자동
      if TeeBoxInfo.ZoneCode = 'S' then
        ImgSemiAutoTeebox.Visible := True;

      if (TeeBoxInfo.ZoneCode = 'B') or (TeeBoxInfo.ZoneCode = 'D') then //스윙분석기
        ImgSwingTeebox.Visible := True;

      if Global.Config.Store.StoreCode = 'C3001' then
      begin
        if (TeeBoxInfo.ZoneCode = 'T') then
          ImgTrackman.Visible := True;
      end;

      if TeeBoxInfo.ZoneCode = 'I' then
        ImgInside.Visible := True;

      if (TeeBoxInfo.ERR <> 0) or (TeeBoxInfo.ERR in [7, 8, 9]) or (not TeeBoxInfo.Use) then
      begin
        Error := True;

        if (TeeBoxInfo.ZoneCode = 'T') then
        begin
          Text1.Text := '트랙맨';
        end
        else
        begin
          Text1.Text := '점검중';
        end;

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
            if Global.Config.Store.StoreCode = 'B9001' then //파스텔골프클럽
              ImgUsePastel.Visible := True
            else
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
              if Global.Config.Store.StoreCode = 'B9001' then //파스텔골프클럽
                ImgUsePastel.Visible := True
              else
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
    except
      on E: Exception do
        Log.E('TSelectBoxProductItemStyle.DisPlayTeeBoxInfo', E.Message);
    end;

  finally

  end;
end;

procedure TSelectBoxProductItemStyle.SelectRectangleClick(Sender: TObject);
begin
  TouchSound(False, True);
  try
    if Error then
    begin
      if Global.Config.StoreType = '0' then
        SelectBox.ShowErrorMsg(MSG_ERROR_TEEBOX)
      else
        SelectBox_In.ShowErrorMsg(MSG_ERROR_TEEBOX);
    end
    else
    begin
      Log.D('SelectTeeBox', 'Click');
//      SelectBox.Animate(Self.Tag);

      if Global.Config.StoreType = '0' then
        SelectBox.SelectTeeBox(TeeBoxInfo)
      else
        SelectBox_In.SelectTeeBox(TeeBoxInfo);

      //Log.D('SelectTeeBox', 'Close');

    end;
  except
    on E: Exception do
      Log.E('SelectRectangleClick', E.Message);
  end;
end;

end.
