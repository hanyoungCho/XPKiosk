unit Frame.Halbu;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, Frame.KeyBoard;

type
  THalbu = class(TFrame)
    Image: TImage;
    Rectangle1: TRectangle;
    Text3: TText;
    Image1: TImage;
    txtPw5: TText;
    Rectangle2: TRectangle;
    KeyBoard1: TKeyBoard;
    Rectangle3: TRectangle;
    Text4: TText;
    Text5: TText;
    Image2: TImage;
    txtPw6: TText;
    Rectangle11: TRectangle;
    Image3: TImage;
    Text17: TText;
    Rectangle12: TRectangle;
    Image4: TImage;
    Text18: TText;
    procedure Rectangle4Click(Sender: TObject);
    procedure Rectangle5Click(Sender: TObject);
    procedure Image1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ChangeKey(AKey: string);
    procedure CloseFrame;
  end;

implementation

uses
  Form.Popup, uGlobal, uCommon;

{$R *.fmx}

{ THalbu }

procedure THalbu.ChangeKey(AKey: string);
begin
  if Length(AKey) = 0 then
  begin
    txtPw5.Text := '';
    txtPw6.Text := '';
  end
  else if Length(AKey) = 1 then
  begin
    txtPw5.Text := AKey;
    txtPw6.Text := '';
  end
  else
  begin
    txtPw5.Text := Copy(AKey, 2, 1);
    txtPw6.Text := Copy(AKey, 1, 1);
  end;
end;

procedure THalbu.CloseFrame;
begin
  KeyBoard1.CloseFrame;
  KeyBoard1.Free;
end;

procedure THalbu.Image1Click(Sender: TObject);
begin
  TouchSound;
end;

procedure THalbu.Rectangle4Click(Sender: TObject);
begin
  Popup.CloseFormStrMrCancel;
end;

procedure THalbu.Rectangle5Click(Sender: TObject);
var
  AHalbu: Integer;
begin
  AHalbu := StrToIntDef(txtPw6.Text + txtPw5.Text, 0);

  Popup.CloseFormStrMrok(IntToStr(AHalbu));
end;

end.
