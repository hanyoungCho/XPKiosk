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
  uCommon, uGlobal, uSaleModule;

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

    // BC페이북QR
    //ImageAppCard.Visible := True;
    //ImageAppCardBC.Visible := True
    ImageAppCard202012.Visible := True; //2020-12-31 신한잠시중단
  end;

  // retry
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
  ModalResult := mrCancel;
end;

procedure TSBMessageForm.Rectangle7Click(Sender: TObject);
begin
  if Global.SBMessage.PrintError then
  begin
    Global.SaleModule.Print.PrintStatus := '';
    Global.SaleModule.Print.SewooStatus;
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
      ModalResult := mrOk
    else
      ModalResult := mrCancel;
  end;

  // retry
  if (ButtonTwolRectangle.Visible = True) and (Text18.Text = '재시도') then
  begin
    if FCnt > 1 then
      Rectangle7.OnClick(Rectangle7)
    else
      Text4.Text := '재시도 ' + IntToStr(2 - FCnt) + '초';
  end;

end;

end.
