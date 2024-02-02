unit Frame.XGolfEvent;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects;

type
  TXGolfEvent = class(TFrame)
    Rectangle3: TRectangle;
    Rectangle11: TRectangle;
    Image3: TImage;
    Text17: TText;
    Rectangle12: TRectangle;
    Image4: TImage;
    Text18: TText;
    Image: TImage;
    procedure Rectangle11Click(Sender: TObject);
    procedure Rectangle12Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses
  Form.Popup;

{$R *.fmx}

procedure TXGolfEvent.Rectangle11Click(Sender: TObject);
begin
  Popup.CloseFormStrMrCancel;
end;

procedure TXGolfEvent.Rectangle12Click(Sender: TObject); //응모하기
begin
  Popup.CloseFormStrMrok('');
end;

end.
