unit Frame.FullPopupPayCard;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Controls.Presentation, FMX.Edit, FMX.EditBox, FMX.SpinBox;

type
  TFullPopupPayCard = class(TFrame)
    Rectangle1: TRectangle;
    txtTasukInfo: TText;
    Text4: TText;
    Rectangle2: TRectangle;
    txtProductAmtCaption: TText;
    txtProductVatAmtCaption: TText;
    txtProductTotalAmtCaption: TText;
    Rectangle3: TRectangle;
    HalbuImage: TImage;
    HalbuImageNot: TImage;
    Rectangle4: TRectangle;
    Rectangle5: TRectangle;
    Text1: TText;
    Rectangle6: TRectangle;
    Image3: TImage;
    Text3: TText;
    Rectangle7: TRectangle;
    Text5: TText;
    Rectangle8: TRectangle;
    Rectangle9: TRectangle;
    Rectangle10: TRectangle;
    txtProductAmt: TText;
    txtDiscountAmt: TText;
    txtProductTotalAmt: TText;
    txtHalbu: TText;
    Rectangle11: TRectangle;
    Image1: TImage;
    Text17: TText;
    Rectangle12: TRectangle;
    Image2: TImage;
    Text18: TText;
    Rectangle13: TRectangle;
    Text2: TText;
    txtProductVatAmt: TText;
    procedure HalbuImageNotClick(Sender: TObject);
    procedure Rectangle7Click(Sender: TObject);
    procedure HalbuImageClick(Sender: TObject);
    procedure Image3Click(Sender: TObject);
    procedure FrameClick(Sender: TObject);
    procedure Image1Click(Sender: TObject);
  private
    { Private declarations }
    FHalbu: Boolean;

    procedure ChangeImage;
  public
    { Public declarations }
    procedure DisPlay;
  end;

implementation

uses
  uGlobal, uCommon, Form.Full.Popup, uConsts;

{$R *.fmx}

{ TFullPopupPayCard }

procedure TFullPopupPayCard.ChangeImage;
begin
  FullPopup.ResetTimerCnt;

  if FHalbu then
  begin
    HalbuImage.Bitmap.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'Image\' + 'ic_unchecked' + '.png');
    HalbuImageNot.Bitmap.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'Image\' + 'ic_checked' + '.png');
  end
  else
  begin
    HalbuImage.Bitmap.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'Image\' + 'ic_checked' + '.png');
    HalbuImageNot.Bitmap.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'Image\' + 'ic_unchecked' + '.png');
  end;
end;

procedure TFullPopupPayCard.DisPlay;
begin
  FHalbu := False;
  txtProductAmt.Text := Format('%s원', [FormatFloat('#,##0.##', Global.SaleModule.TotalAmt)]);
  txtProductVatAmt.Text := Format('%s원', [FormatFloat('#,##0.##', Global.SaleModule.VatAmt)]);
  txtProductTotalAmt.Text := Format('%s원', [FormatFloat('#,##0.##', Global.SaleModule.RealAmt)]);
  txtDiscountAmt.Text := Format('%s원', [FormatFloat('#,##0.##', Global.SaleModule.DCAmt)]);
  if Global.SaleModule.SelectHalbu <> 1 then
  begin
    FHalbu := True;
    ChangeImage;
    txtHalbu.Text := Format(CardHalbu, [IntToStr(Global.SaleModule.SelectHalbu) + '개월']);
  end;
end;

procedure TFullPopupPayCard.FrameClick(Sender: TObject);
begin
  Image3Click(nil);
end;

procedure TFullPopupPayCard.HalbuImageClick(Sender: TObject);
begin
  Global.SaleModule.SelectHalbu := 1;
  txtHalbu.Text := Format(CardHalbu, ['미선택']);
  FHalbu := False;
  ChangeImage;
end;

procedure TFullPopupPayCard.HalbuImageNotClick(Sender: TObject);
begin
  try
    FullPopup.ResetTimerCnt;
    FullPopup.TimerFull.Enabled := False;
    TouchSound;
    if ShowPopup('HalbuImageNotClick') then
    begin
      if Global.SaleModule.SelectHalbu <> 1 then
      begin
        FHalbu := True;
        ChangeImage;
        txtHalbu.Text := Format(CardHalbu, [IntToStr(Global.SaleModule.SelectHalbu) + '개월']);
      end
      else
        txtHalbu.Text := Format(CardHalbu, ['미선택']);
    end;
  finally
    FullPopup.TimerFull.Enabled := True;
  end;
end;

procedure TFullPopupPayCard.Image1Click(Sender: TObject);
begin
  TouchSound;
  FullPopup.CloseFormStrMrCancel;
end;

procedure TFullPopupPayCard.Image3Click(Sender: TObject);
begin
  TouchSound;
end;

procedure TFullPopupPayCard.Rectangle7Click(Sender: TObject);
begin  //
  TouchSound;
  Global.SaleModule.CardApplyType := catMagnetic;
  FullPopup.ApplyCard('', False, False);
end;

end.
