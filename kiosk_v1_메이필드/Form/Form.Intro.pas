unit Form.Intro;

interface

uses
  FMX.Media,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.Ani, FMX.Layouts, FMX.Gestures,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.Objects, Frame.Bottom,
  Frame.Select.Box.Top.Map, Frame.Media, CPort;
type
  TIntro = class(TForm)
    BottomTimer: TTimer;
    Layout: TLayout;
    Rectangle2: TRectangle;
    Rectangle3: TRectangle;
    Rectangle4: TRectangle;
    SelectBoxTopMap1: TSelectBoxTopMap;
    Text1: TText;
    ImgTeeBoxColor1: TImage;
    Image2: TImage;
    Rectangle1: TRectangle;
    BottomImage: TImage;
    CloseRectangle: TRectangle;
    MediaFrame1: TMediaFrame;
    RecKioskError: TRectangle;
    lblKioskError: TLabel;
    Label1: TLabel;
    ImgTeeBoxColor2: TImage;
    procedure Rectangle4Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CloseRectangleClick(Sender: TObject);
    procedure BottomTimerTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormTouch(Sender: TObject; const Touches: TTouches;
      const Action: TTouchAction);
    procedure MediaFrame1Click(Sender: TObject);
  private
    { Private declarations }
    FInverval: Integer;
    FMediaIndex: Integer;
    FMiniMapInverval: Integer;
  public
    { Public declarations }
  end;

var
  Intro: TIntro;

implementation

uses
  uGlobal, uSaleModule, Form.Select.Box, uFunction, uCommon, uConsts, fx.Logging;

{$R *.fmx}

procedure TIntro.FormCreate(Sender: TObject);
begin
//  FMediaThread := TMediaThread.Create;
  Log.D('ShowIntro', 'FormCreate');
end;

procedure TIntro.FormDestroy(Sender: TObject);
begin
//  BottomImage.Free;
  BottomImage := nil;
  MediaFrame1.Free;
  SelectBoxTopMap1.CloseFrame;
  SelectBoxTopMap1.Free;
  DeleteChildren;
//  FMediaThread.Free;
end;

procedure TIntro.FormShow(Sender: TObject);
begin
  Log.D('ShowIntro', 'FormShow');

  Application.ProcessMessages;
  SelectBoxTopMap1.DisplayFloor;
  BottomTimer.Enabled := True;
  BottomTimer.Interval := Global.Config.TeeBoxRefreshInterval * 1000;
  MediaFrame1.PlayMedia;

  if Global.Config.KioskError then
    RecKioskError.Visible := True;

  //ImgTeeBoxColor1.Visible := True; //5분미만
  ImgTeeBoxColor2.Visible := True; //10분 미만
end;

procedure TIntro.FormTouch(Sender: TObject; const Touches: TTouches; const Action: TTouchAction);
begin
  ModalResult := mrok;
end;

procedure TIntro.MediaFrame1Click(Sender: TObject);
begin
  CloseRectangleClick(nil);
end;

procedure TIntro.BottomTimerTimer(Sender: TObject);
begin
  SelectBoxTopMap1.DisplayFloor;
end;

procedure TIntro.CloseRectangleClick(Sender: TObject);
begin
//  TouchSound;
  MediaFrame1.Timer.Enabled := False;
  MediaFrame1.MediaPlayer1.Stop;
  ModalResult := mrOk;
//  Close;
end;

procedure TIntro.Rectangle4Click(Sender: TObject);
begin
//
end;

end.
