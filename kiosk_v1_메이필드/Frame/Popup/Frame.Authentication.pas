unit Frame.Authentication;

interface

uses
  Frame.KeyBoard, Winapi.Windows,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, System.Generics.Collections,
  JSON;

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
    txtTime: TText;
    Timer1: TTimer;
    procedure Rectangle4Click(Sender: TObject);
    procedure Rectangle5Click(Sender: TObject);
    procedure Rectangle1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    FKeyStr: string;
  public
    { Public declarations }
    iSec: Integer;
    procedure ChangeKey(AKey: string);
    procedure CloseFrame;
  end;

implementation

uses
  Form.Popup, uGlobal, uConsts, uCommon, uFunction, fx.Logging;

{$R *.fmx}

procedure TAuthentication.ChangeKey(AKey: string);
var
  Index, Loop: Integer;
begin
  FKeyStr := Copy(AKey, 1, 4);
  FKeyStr := Trim(FKeyStr);
  Index := 0;
  iSec := 0;

  if Global.SaleModule.PopUpLevel = plAuthentication then
  begin

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
    end
  end
  else
  begin
    if Length(FKeyStr) <> 0 then
    begin
      for Index := 0 to Length(FKeyStr) - 1 do
      begin
        if Index = 0 then
          txtPw1.Text := Copy(FKeyStr, 1, 1)
        else if Index = 1 then
          txtPw2.Text := Copy(FKeyStr, 2, 1)
        else if Index = 2 then
          txtPw3.Text := Copy(FKeyStr, 3, 1)
        else if Index = 3 then
          txtPw4.Text := Copy(FKeyStr, 4, 1);
      end;
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

  if Global.SaleModule.PopUpLevel = plAuthentication then
  begin
    if Length(FKeyStr) = 4 then
      Rectangle5Click(nil);
  end;
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

  if Global.SaleModule.PopUpLevel = plParkingDay then
    Log.D('plParkingDay', '사용자 등록취소');

  Popup.CloseFormStrMrCancel;
end;

procedure TAuthentication.Rectangle5Click(Sender: TObject);
var
  MainJson: TJSONObject;
  JsonText, sResult: string;
begin
  TouchSound;

  if Global.SaleModule.PopUpLevel = plAuthentication then
  begin
    if Global.Config.Store.AdminPassword = FKeyStr then
    begin
      Log.D('관리자 인증', '사용자 종료');
      Popup.CloseFormStrMrok('');
    end
    else
    begin
      Global.SBMessage.ShowMessageModalForm(MSG_ADMIN_NOT_PASSWORD);
      Keybd_Event(vkCancel, vkCancel, 0, 0);
      Keybd_Event(vkCancel, vkCancel, KEYEVENTF_KEYUP, 0);
    end;
  end
  else
  begin
    if Length(FKeyStr) < 4 then
    begin
      Global.SBMessage.ShowMessageModalForm('차량번호 4자리를 입력해 주세요');
    end
    else
    begin
      JsonText := '{"jobcode":"NP001",' +
                   '"carnum":"' + FKeyStr + '"}';

      //Log.D('Nexpa Send', sResult);
      sResult := Global.XPErpApi.Send_Nexpa_API('/WebNexpaParkingSystem/FourCarSearch', JsonText);
      //Log.D('Nexpa Result', sResult);

      try
        MainJson := TJSONObject.ParseJSONValue(sResult) as TJSONObject;

        if MainJson.GetValue('resultcode').Value <> '0' then
        begin
          Global.SBMessage.ShowMessageModalForm(MainJson.GetValue('resultmsg').Value);
          Exit;
        end;

      finally
        FreeAndNil(MainJson);
      end;

      Timer1.Enabled := False;
      Global.SaleModule.NexpaParkList := sResult;
      if ShowConfig then
      begin
        Popup.CloseFormStrMrok('');
      end
      else
        Timer1.Enabled := True;

    end;
  end;

end;

procedure TAuthentication.Timer1Timer(Sender: TObject);
begin
  Inc(iSec);
  txtTime.Text := Format(TimeSecCaption, [LPadB(IntToStr(Time30Sec - iSec), 2, ' ')]);
  if (Time30Sec - iSec) = 0 then
  begin
    Timer1.Enabled := False;
    Log.D('plParkingDay', '시간초과 등록취소');
    Popup.CloseFormStrMrCancel;
  end;
end;

end.
