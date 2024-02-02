unit Frame.Config.Item.Style;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.ListBox, FMX.Objects, FMX.Controls.Presentation;

type
  TConfigItemStyle = class(TFrame)
    Rectangle1: TRectangle;
    txtName: TText;
    SelectRectangle: TRectangle;
    procedure SelectRectangleClick(Sender: TObject);
  private
    { Private declarations }
    FTkno: String;
    FCarnum: String;
  public
    { Public declarations }
    procedure Display(ATkno, ACarnum: string);
  end;

implementation

uses
  uCommon, Form.Config;

{$R *.fmx}

{ TConfigItemStyle }

procedure TConfigItemStyle.Display(ATkno, ACarnum: string);
begin
  FTkno := ATkno;
  FCarnum := ACarnum;
  txtName.Text := FCarnum;
end;

procedure TConfigItemStyle.SelectRectangleClick(Sender: TObject);
begin
  Config.ParkingSend(FTkno, FCarnum);
end;

end.
