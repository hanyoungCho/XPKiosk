unit Frame.Media;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Media, FMX.Layouts, FMX.Objects, FMX.Controls.Presentation;

type
  TMediaFrame = class(TFrame)
    MediaPlayer1: TMediaPlayer;
    MediaPlayerControl1: TMediaPlayerControl;
    Timer: TTimer;
    Layout: TLayout;
    Rectangle1: TRectangle;
    Image: TImage;
    Timer1: TTimer;
    procedure TimerTimer(Sender: TObject);
    procedure Rectangle1Click(Sender: TObject);
    procedure MediaPlayerControl1Tap(Sender: TObject; const Point: TPointF);
    procedure MediaPlayerControl1Gesture(Sender: TObject; const EventInfo: TGestureEventInfo; var Handled: Boolean);

    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    FMediaIndex: Integer;
    FIndex: Integer;
    procedure MediaMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
  public
    { Public declarations }
    procedure PlayMedia;
    procedure PlayImage;
    procedure CloseFrame;
  end;

implementation

uses
  uGlobal, Form.Intro, fx.Logging;

{$R *.fmx}

procedure TMediaFrame.CloseFrame;
var
  Index: Integer;
begin
  try
    if MediaPlayer1.ChildrenCount <> 0 then
    begin
      for Index := MediaPlayer1.ChildrenCount - 1 downto 0 do
        MediaPlayer1.Children[Index].Free;
    end;
  finally

  end;
end;

procedure TMediaFrame.MediaMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
begin
  Intro.CloseRectangleClick(nil);
end;

procedure TMediaFrame.MediaPlayerControl1Gesture(Sender: TObject; const EventInfo: TGestureEventInfo; var Handled: Boolean);
begin
  Intro.CloseRectangleClick(nil);
end;

procedure TMediaFrame.MediaPlayerControl1Tap(Sender: TObject; const Point: TPointF);
begin
  Intro.CloseRectangleClick(nil);
end;

procedure TMediaFrame.PlayMedia;
begin
//  Application.ProcessMessages;
  MediaPlayerControl1.MediaPlayer := MediaPlayer1;
  MediaPlayer1.Volume := 0;
  MediaPlayer1.Play;
  Timer.Enabled := True;
  MediaPlayerControl1.Parent := Rectangle1;
//  MediaPlayerControl1.Controls
//  MediaPlayerControl1.OnClick := Intro.CloseRectangleClick;

//  MediaPlayerControl1.OnMouseMove := MediaMouseMove;

//  MediaPlayerControl1.HitTest := True;
//  MediaPlayerControl1.Pressed := True;
end;

procedure TMediaFrame.Rectangle1Click(Sender: TObject);
begin
  Intro.CloseRectangleClick(nil);
end;

procedure TMediaFrame.TimerTimer(Sender: TObject);
var
  Index: Integer;
begin

  {
  try
    if (MediaPlayer1.State = TMediaState.Playing) and (MediaPlayer1.Duration = MediaPlayer1.CurrentTime) then
    begin
      MediaPlayer1.Stop;

      for Index := MediaPlayer1.ChildrenCount - 1 downto 0 do
        MediaPlayer1.Children[Index].Free;

      MediaPlayer1.DeleteChildren;

      Inc(FMediaIndex);
      if FMediaIndex < Global.SaleModule.AdvertisementListUp.Count then
      begin
        MediaPlayer1.FileName := Global.SaleModule.AdvertisementListUp[FMediaIndex].FilePath;
  //      MediaPlayer1.FileName := 'D:\Project Source\XGolf\kiosk\Bin\Intro\Media\1234.avi';
      end
      else
      begin
        FMediaIndex := 0;
        MediaPlayer1.FileName := Global.SaleModule.AdvertisementListUp[FMediaIndex].FilePath;
  //      MediaPlayer1.FileName := 'D:\Project Source\XGolf\kiosk\Bin\Intro\Media\1234.avi';
      end;

      MediaPlayer1.Volume := 0;
      MediaPlayerControl1.Visible := True;
      MediaPlayer1.Play;
    end
    else
    begin
      if MediaPlayer1.State = TMediaState.Stopped then
      begin
        if Global.SaleModule.AdvertisementListUp.Count <> 0 then
        begin
          for Index := MediaPlayer1.ChildrenCount - 1 downto 0 do
            MediaPlayer1.Children[Index].Free;

          MediaPlayer1.DeleteChildren;

          MediaPlayer1.FileName := Global.SaleModule.AdvertisementListUp[0].FilePath;
          MediaPlayer1.Volume := 0;
          MediaPlayer1.Play;
        end;
      end;
    end;
  //  MediaPlayerControl1.BringChildToFront(Rectangle2);
  //  Rectangle2.Parent := MediaPlayerControl1;
  except
    on E: Exception do
    begin
      Log.E('TMediaFrame.TimerTimer', E.Message);
//      Global.SBMessage.ShowMessageModalForm(E.Message);
    end;
  end; }
end;

procedure TMediaFrame.PlayImage;
begin
//  Application.ProcessMessages;
  FIndex := 0;
  Timer1.Enabled := True;
end;

procedure TMediaFrame.Timer1Timer(Sender: TObject);
begin
  try

    if Global.SaleModule.AdvertisementListUp.Count <> 0 then
    begin

      if Global.SaleModule.AdvertisementListUp.Count > 1 then
      begin

        if FIndex <= (Global.SaleModule.AdvertisementListUp.Count - 1) then
        begin
          Image.Bitmap := Global.SaleModule.AdvertisementListUp[FIndex].Image;
          Inc(FIndex);
        end
        else
        begin
          FIndex := 0;
          Image.Bitmap := Global.SaleModule.AdvertisementListUp[FIndex].Image;
        end;
      end;

    end;

  except
    on E: Exception do
    begin
      Log.E('ChangeImg', E.Message);
      Log.E('ChangeImg FIndex', IntToStr(FIndex));
      Log.E('ChangeImg AdvertisementListDown.Count', IntToStr(Global.SaleModule.AdvertisementListDown.Count));
      //Log.E('ChangeImg', E.Message);
    end;
  end;
end;

end.
