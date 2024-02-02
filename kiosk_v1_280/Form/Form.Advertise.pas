unit Form.Advertise;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Layouts;

type
  TfrmAdvertise = class(TForm)
    Layout: TLayout;
    recBG: TRectangle;
    recBody: TRectangle;
    Image: TImage;
    recBottom: TRectangle;
    recOK: TRectangle;
    Image4: TImage;
    Text18: TText;
    ImgClose: TImage;
    Text1: TText;
    ImgSend: TImage;
    Text4: TText;
    Timer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure recOKClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure ImgCloseClick(Sender: TObject);
    procedure ImgSendClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    FType: String;
    FCnt: Integer;
  end;

var
  frmAdvertise: TfrmAdvertise;

implementation

uses
  uGlobal, fx.Logging;

{$R *.fmx}

procedure TfrmAdvertise.FormCreate(Sender: TObject);
begin
//
end;

procedure TfrmAdvertise.FormDestroy(Sender: TObject);
begin
//
end;

procedure TfrmAdvertise.FormShow(Sender: TObject);
var
  sLoadFile: String;
  sStr: String;
  nIdx: Integer;
begin
  if FType = 'Receipt' then
  begin
    nIdx := Global.SaleModule.AdvertListReceiptIdx;

    Log.D('Receipt', Global.SaleModule.AdvertListReceipt[nIdx].Name);

    sLoadFile := Global.SaleModule.AdvertListReceipt[nIdx].FilePath;
    Image.Bitmap.LoadFromFile(sLoadFile);

    if Global.SaleModule.FAdvertReceiptPopupList[nIdx].ResultWinYn = 'Y' then
    begin
      sStr := '축하합니다.' +#13 + Global.SaleModule.FAdvertReceiptPopupList[nIdx].ResultNth + '번째 회원님!' + #13 + Global.SaleModule.AdvertListReceipt[nIdx].Name + '이벤트에 당첨되셨습니다.';
      Global.SBMessage.ShowMessageModalForm(sStr, True, 15);
    end;

    nIdx := nIdx + 1;
    if nIdx > Global.SaleModule.AdvertListReceipt.Count - 1 then
      nIdx := 0;

    Global.SaleModule.AdvertListReceiptIdx := nIdx;
  end
  else if FType = 'Event' then
  begin
    Log.D('Event', Global.SaleModule.AdvertListEvent[0].Name);

    sLoadFile := Global.SaleModule.AdvertListEvent[0].FilePath;
    Image.Bitmap.LoadFromFile(sLoadFile);
  end;

  Timer.Enabled := True;
end;

procedure TfrmAdvertise.ImgCloseClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmAdvertise.ImgSendClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TfrmAdvertise.recOKClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TfrmAdvertise.TimerTimer(Sender: TObject);
begin
  Inc(FCnt);
  if FCnt = 15 then
  begin
    Timer.Enabled := False;
    ModalResult := mrCancel;
  end;
end;

end.
