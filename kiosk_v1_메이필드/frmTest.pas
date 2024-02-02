unit frmTest;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, AdvTouchKeyboard;

type
  TfrmVeiw = class(TForm)
    AdvPopupTouchKeyBoard1: TAdvPopupTouchKeyBoard;
    Panel1: TPanel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmVeiw: TfrmVeiw;

implementation

{$R *.fmx}

end.
