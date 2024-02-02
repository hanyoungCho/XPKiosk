unit Frame.Top;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Objects;

type
  TTop = class(TFrame)
    Layout: TLayout;
    Rectangle: TRectangle;
    Rectangle1: TRectangle;
    LogoImg: TImage;
    lblDay: TText;
    lblTime: TText;
    Timer: TTimer;
    procedure TimerTimer(Sender: TObject);
    procedure RectangleClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses
  uGlobal, uCommon, uFunction;

{$R *.fmx}

procedure TTop.RectangleClick(Sender: TObject);
begin
  TouchSound;
end;

procedure TTop.TimerTimer(Sender: TObject);
begin //
  Global.SaleModule.NowHour := format('%s(%s)', [FormatDateTime('yyyy-mm-dd', now), GetWeekDay(now)]);
  Global.SaleModule.NowTime := FormatDateTime('hh:nn', now);
  lblDay.Text := Global.SaleModule.NowHour;
  lblTime.Text := Global.SaleModule.NowTime;
end;

end.
