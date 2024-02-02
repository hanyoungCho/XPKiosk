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
                // ��� #FFFFCB00
uses
  uFunction, uGlobal, uCommon, uConsts, Form.Select.Box, fx.Logging;

{$R *.fmx}

procedure TSelectBoxProductItemStyle.DisPlayTeeBoxInfo;
var
  AHour, AMinute, LimitTime: Integer;
begin
  Error := False;
  TeeBoxClean := False;
//  TopText.Text := IntToStr(TeeBoxInfo.TasukNo);
  TopText.Text := TeeBoxInfo.Mno;

  if TeeBoxInfo.Vip then
  begin
//    txtVIP.Visible := True;
    VipImage.Visible := True;
  end;

  if TeeBoxInfo.ZoneCode = 'L' then
    ImgLeftTeebox.Visible := True;

  if TeeBoxInfo.ZoneCode = 'O' then
    ImgOnlyLeftTeebox.Visible := True;

  //2020-12-18 ���丮�� ���ڵ�
  if TeeBoxInfo.ZoneCode = 'S' then
    ImgSemiAutoTeebox.Visible := True;

//  if (TeeBoxInfo.Mno = '13') or (TeeBoxInfo.Mno = '18') or (TeeBoxInfo.Mno = '31') or (TeeBoxInfo.Mno = '32') or (TeeBoxInfo.Mno = '39') then
//  begin
//    Error := True;
////    TopText.Text := '������';
//    Text1.Text := '������';
//    Text2.Text := '-';
//    Text3.Text := '';
//    ImgError.Visible := True;
////    TasukNoRectangle.Fill.Color := $FF5C5C5C;// $FF777777;//$FF5FB459;//$FF5FB459;//$FFB8B8B8; //TAlphaColorRec.Darkgray;
//    Exit;
//  end;

  if (TeeBoxInfo.ERR <> 0) or (TeeBoxInfo.ERR in [7, 8, 9]) or (not TeeBoxInfo.Use) then
  begin
    Error := True;
//    TopText.Text := '������';
    Text1.Text := '������';
    Text2.Text := '-';
    Text3.Text := '';
    ImgError.Visible := True;
//    TasukNoRectangle.Fill.Color := $FF5C5C5C;// $FF777777;//$FF5FB459;//$FF5FB459;//$FFB8B8B8; //TAlphaColorRec.Darkgray;
  end
  else
  begin
    AHour := TeeBoxInfo.BtweenTime div 60;

    if TeeBoxInfo.Hold then
    begin
//      TasukNoRectangle.Fill.Color := $FFAC8282; //TAlphaColorRec.Darkgray;
      ImgHold.Visible := True;
      Text1.Text := '������';
      Text2.Text := '';
      Text3.Text := '';
    end
    else if (TeeBoxInfo.BtweenTime = 0) or ((Trim(TeeBoxInfo.Ma_Time) = '0') and (Trim(TeeBoxInfo.End_DT) = EmptyStr)) then
    begin
      TeeBoxClean := True;
      Text1.Text := '��ÿ���';
      Text2.Text := '';
      Text3.Text := '';
      ImgDefault.Visible := True;
//      TasukNoRectangle.Fill.Color := $FF00CE13;// $FF45D10E; //TAlphaColorRec.Darkgray;
    end
    else if TeeBoxInfo.BtweenTime <> 0 then
    begin
      AMinute := TeeBoxInfo.BtweenTime - (AHour * 60);
      Text1.Text := '�����';
      Text3.Text := IntToStr(TeeBoxInfo.BtweenTime) + '��';
//      if AHour = 0 then
//        Text2.Text := Format(TimeNN, [IntToStr(AMinute)])
//      else if AMinute = 0 then
//        Text2.Text := Format(TimeHH, [IntToStr(AHour)])
//      else
//        Text2.Text := Format(TimeHHNN, [IntToStr(AHour), IntToStr(AMinute)]);
//
//      if Trim(TeeBoxInfo.End_DT) <> EmptyStr then
//        Text3.Text := Format('~ %s', [TeeBoxInfo.End_DT])
//      else
//        Text3.Text := Format('~ %s', [TeeBoxInfo.End_Time]);

      if ((Trim(TeeBoxInfo.Ma_Time) = '0') and (Trim(TeeBoxInfo.End_DT) = EmptyStr)) or (TeeBoxInfo.BtweenTime = 0) then
      begin
        ImgUse.Visible := True;
//        TasukNoRectangle.Fill.Color := $FF00CE13;// $FFFFCB00;//$FF5FB459;// $FF777777; //TAlphaColorRec.Darkgray;
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
          //Text1.Text := '���Ό��';
          Text1.Text := IntToStr(Ifthen(TeeBoxInfo.BtweenTime = 0, 1, TeeBoxInfo.BtweenTime)) + '�� �� ����';
          Text1.TextSettings.Font.Size := 25;
//          Text1.TextSettings.FontColor := $FFF30033;//$FFF60A14;
//          TasukNoRectangle.Fill.Color := $FFF30033;//$FFF60A14; //TAlphaColorRec.Red;
          Text3.Text := '';
        end
        else
        begin  // �Ķ� $FF2E74F0      ��Ȳ $FFFF8518
//          TasukNoRectangle.Fill.Color := $FFFF8518; //$FFF0742E;//TAlphaColorRec.Coral;// $FFFFCB00;//$FF777777; //$FF80C97A; //TAlphaColorRec.Lightgreen;
          ImgUse.Visible := True;
        end;
      end;
    end
    else
    begin
      ImgHold.Visible := True;
//      TasukNoRectangle.Fill.Color := $FFAC8282; //TAlphaColorRec.Darkgray;
      Text1.Text := '������';
      Text2.Text := '-';
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
//      SelectBox.Animate(Self.Tag);
      SelectBox.SelectTeeBox(TeeBoxInfo);
    end;
  except
    on E: Exception do
      Log.E(ClassName, E.Message);
  end;
end;

end.
