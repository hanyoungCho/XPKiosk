unit Form.Message;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.Ani, FMX.Layouts, FMX.Gestures,
  FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls, Winapi.Windows, FMX.Platform.Win,
  FMX.Edit;

type
  TSBMessageForm = class(TForm)
    Layout: TLayout;
    Image: TImage;
    Rectangle: TRectangle;
    ButtonTwolRectangle: TRectangle;
    Rectangle4: TRectangle;
    Text1: TText;
    Rectangle5: TRectangle;
    Text2: TText;
    ButtonOneRectangle: TRectangle;
    Rectangle7: TRectangle;
    Text5: TText;
    TopRectangle: TRectangle;
    Text3: TText;
    MsgRectangle: TRectangle;
    Text: TText;
    Line1: TLine;
    Timer: TTimer;
    Image2: TImage;
    Image3: TImage;
    Rectangle11: TRectangle;
    Image4: TImage;
    Text17: TText;
    Rectangle12: TRectangle;
    Image5: TImage;
    Text18: TText;
    Image1: TImage;
    PrepareRec: TRectangle;
    Rectangle1: TRectangle;
    PlusRec: TRectangle;
    Rectangle3: TRectangle;
    MinusRec: TRectangle;
    Rectangle6: TRectangle;
    lblPrepare: TLabel;
    Label1: TLabel;
    Edit1: TEdit;
    ImageAppCard: TImage;
    Text4: TText;
    ImageAppCardBC: TImage;
    ImageAppCard202012: TImage;
    procedure Rectangle7Click(Sender: TObject);
    procedure Rectangle4Click(Sender: TObject);
    procedure RectangleClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MinusRecClick(Sender: TObject);
    procedure PlusRecClick(Sender: TObject);
  private
    { Private declarations }
    FPassWord: Boolean;
    procedure ActiveForm;
  public
    { Public declarations }
    FCnt: Integer;
    FCloseCnt: Integer;
    SoundPlay: Boolean;
    property PassWord: Boolean read FPassWord write FPassWord;
  end;

var
  SBMessageForm: TSBMessageForm;

implementation

uses
  uCommon, uGlobal, uSaleModule, uConsts, uFunction, fx.Logging;

{$R *.fmx}

procedure TSBMessageForm.ActiveForm;
begin
  //
end;

procedure TSBMessageForm.FormDestroy(Sender: TObject);
begin
  DeleteChildren;
  Exit;
end;

procedure TSBMessageForm.FormShow(Sender: TObject);
var
  sStr: String;
begin
  SetWindowPos(WindowHandleToPlatform(Self.Handle).Wnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);

//  WindowHandleToPlatform(Self.Handle).ZOrderManager;

  if SoundPlay then
    TouchSound(True);

  if Global.SBMessage.PrepareTimeSelect then
  begin
    lblPrepare.Text := Global.Config.PrePare_Min;
    PrepareRec.Visible := True;
  end;

  if Text.Text = '신한' then
  begin
    Text3.Text := '이달의 프로모션';
    Text.Text := EmptyStr;

    //chy BC페이북QR
    //ImageAppCard.Visible := True;
    //ImageAppCardBC.Visible := True
    ImageAppCard202012.Visible := True; //2020-12-31 신한잠시중단
  end;

  if (Text.Text = '기간') or (Text.Text = '쿠폰') then
  begin
    Text3.Text := '회원가입 완료';

    if (Text.Text = '기간') then
    begin
      //if (Global.Config.Store.StoreCode = 'C1001') then //코리아하이파이브스포츠클럽
      if Global.Config.FingerprintUse <> 'Y' then
        sStr := '신규회원 가입이'
      else
        sStr := '신규회원 가입 및 지문등록이';
    end
    else
      sStr := '신규회원 가입 및 QR코드 전송이';

    sStr := sStr +#13+'정상적으로 진행되었습니다.' +#13#13+'신규회원권 사용을 원하시면'+#13+'배정 받으실 타석을 선택해 주세요.';
    Text.Text := sStr;
  end;

  //chy retry
  Text4.Text := EmptyStr;

  Edit1.SetFocus;
end;

procedure TSBMessageForm.MinusRecClick(Sender: TObject);
var
  AValue: Integer;
begin
  AValue := StrToIntDef(lblPrepare.Text, StrToIntDef(Global.Config.PrePare_Min, StrToIntDef(Global.Config.PrePare_Min, 5)));
  if (AValue - 1) >= 1 then
    lblPrepare.Text := IntToStr(AValue - 1);
end;

procedure TSBMessageForm.PlusRecClick(Sender: TObject);
var
  AValue: Integer;
begin
  AValue := StrToIntDef(lblPrepare.Text, StrToIntDef(Global.Config.PrePare_Min, StrToIntDef(Global.Config.PrePare_Min, 5)));
  if (AValue + 1) <= 10 then
    lblPrepare.Text := IntToStr(AValue + 1);
end;

procedure TSBMessageForm.Rectangle4Click(Sender: TObject);
begin
  //닫기
  Log.D('TSBMessageForm', 'mrCancel');
  ModalResult := mrCancel;
end;

procedure TSBMessageForm.Rectangle7Click(Sender: TObject);
begin
  //확인
  Log.D('TSBMessageForm', 'mrOk');

  if Global.SBMessage.PrintError then
  begin
    Global.SaleModule.Print.PrintStatus := '';
    Global.SaleModule.Print.PrintStatusCheck;
  end;

  if Global.SBMessage.PrepareTimeSelect then
    Global.SaleModule.PrepareMin := StrToIntDef(lblPrepare.Text, StrToIntDef(Global.Config.PrePare_Min, 5));
  ModalResult := mrOk;
end;

procedure TSBMessageForm.RectangleClick(Sender: TObject);
begin
  TouchSound;
end;

procedure TSBMessageForm.TimerTimer(Sender: TObject);
begin
  Inc(FCnt);
  if FCnt = FCloseCnt then
  begin
    Timer.Enabled := False;
    if not ButtonTwolRectangle.Visible then
    begin
      Log.D('TSBMessageForm Timer', 'mrOk');
      ModalResult := mrOk;
    end
    else
    begin
      Log.D('TSBMessageForm Timer', 'mrCancel');
      ModalResult := mrCancel;
    end;
  end;

  //chy retry
  if (ButtonTwolRectangle.Visible = True) and (Text18.Text = '재시도') then
  begin
    if FCnt > 1 then
      Rectangle7.OnClick(Rectangle7)
    else
      Text4.Text := '재시도 ' + IntToStr(2 - FCnt) + '초';
  end;

  if Text3.Text = '회원가입 완료' then
  begin
    Text4.Text := Format(TimeSecCaption, [LPadB(IntToStr(Time30Sec - FCnt), 2, ' ')]);
  end;

end;

end.
