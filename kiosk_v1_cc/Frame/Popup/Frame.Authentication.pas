unit Frame.Authentication;

interface

uses
  Frame.KeyBoard, Winapi.Windows,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, System.Generics.Collections;

type
  TAuthentication = class(TFrame)
    Image: TImage;
    Rectangle1: TRectangle;
    Rectangle2: TRectangle;
    KeyBoard1: TKeyBoard;
    Rectangle3: TRectangle;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    Text3: TText;
    txtPw1: TText;
    txtPw2: TText;
    txtPw3: TText;
    txtPw4: TText;
    Text4: TText;
    Text5: TText;
    Rectangle4: TRectangle;
    Image1: TImage;
    Text17: TText;
    Rectangle5: TRectangle;
    Image2: TImage;
    Text18: TText;
    procedure Rectangle4Click(Sender: TObject);
    procedure Rectangle5Click(Sender: TObject);
    procedure Rectangle1Click(Sender: TObject);
  private
    { Private declarations }
    FKeyStr: string;
  public
    { Public declarations }
    procedure ChangeKey(AKey: string);
    procedure CloseFrame;
  end;

implementation

uses
  Form.Popup, uGlobal, uConsts, uCommon;

{$R *.fmx}

procedure TAuthentication.ChangeKey(AKey: string);
var
  Index, Loop: Integer;
begin
  FKeyStr := Copy(AKey, 1, 4);
  FKeyStr := Trim(FKeyStr);
  Index := 0;
  if Length(FKeyStr) <> 0 then
  begin
    for Index := 0 to Length(FKeyStr) - 1 do
    begin
      if Index = 0 then
        txtPw1.Text := '*'
      else if Index = 1 then
        txtPw2.Text := '*'
      else if Index = 2 then
        txtPw3.Text := '*'
      else if Index = 3 then
        txtPw4.Text := '*';
    end;
  end;

  for Loop := Index to 4 - 1 do
  begin
    if Loop = 0 then
      txtPw1.Text := '-'
    else if Loop = 1 then
      txtPw2.Text := '-'
    else if Loop = 2 then
      txtPw3.Text := '-'
    else if Loop = 3 then
      txtPw4.Text := '-';
  end;

  if Length(FKeyStr) = 4 then
    Rectangle5Click(nil);
end;

procedure TAuthentication.CloseFrame;
begin
  RemoveObject(KeyBoard1);
//  KeyBoard1.CloseFrame;
//  KeyBoard1.Free;
end;

procedure TAuthentication.Rectangle1Click(Sender: TObject);
begin
  TouchSound;
end;

procedure TAuthentication.Rectangle4Click(Sender: TObject);
begin
  TouchSound;
  Popup.CloseFormStrMrCancel;
end;

procedure TAuthentication.Rectangle5Click(Sender: TObject);
begin
  TouchSound;
  if Global.Config.Store.AdminPassword = FKeyStr then
    Popup.CloseFormStrMrok('')
  else
  begin
    Global.SBMessage.ShowMessageModalForm(MSG_ADMIN_NOT_PASSWORD);
    Keybd_Event(vkCancel, vkCancel, 0, 0);
    Keybd_Event(vkCancel, vkCancel, KEYEVENTF_KEYUP, 0);
  end;
end;

end.
