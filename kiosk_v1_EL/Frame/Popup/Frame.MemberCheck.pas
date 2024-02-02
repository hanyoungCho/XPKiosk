unit Frame.MemberCheck;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, Frame.KeyBoard, FMX.Controls.Presentation, FMX.Edit;

type
  TMemberCheck = class(TFrame)
    Image: TImage;
    Rectangle1: TRectangle;
    Rectangle3: TRectangle;
    recAuth: TRectangle;
    ButtonTwolRectangle: TRectangle;
    Rectangle11: TRectangle;
    Image14: TImage;
    Text17: TText;
    Rectangle12: TRectangle;
    Image15: TImage;
    Text18: TText;
    txtMemberNo: TText;
    txtAuthNo: TText;
    Rectangle2: TRectangle;
    KeyBoard1: TKeyBoard;
    txtTitle: TText;
    edtMember: TEdit;
    edtAuth: TEdit;
    procedure Rectangle4Click(Sender: TObject);
    procedure Rectangle5Click(Sender: TObject);
    procedure Rectangle1Click(Sender: TObject);
  private
    { Private declarations }
    FKeyStr: string;
    FPromotionCode: string;
  public
    { Public declarations }
    procedure CloseFrame;
  end;

implementation

uses
  Form.Popup, uCommon, uGlobal, uStruct, uConsts;

{$R *.fmx}

{ TXGolfMember }

procedure TMemberCheck.CloseFrame;
begin
  KeyBoard1.CloseFrame;
  KeyBoard1.Free;
end;

procedure TMemberCheck.Rectangle1Click(Sender: TObject);
begin
  TouchSound;
end;

procedure TMemberCheck.Rectangle4Click(Sender: TObject);
begin
  Popup.CloseFormStrMrCancel;
end;

procedure TMemberCheck.Rectangle5Click(Sender: TObject);
var
  CloseFormOk: Boolean;
  //AMobile, Msg: string;
  AMember: TMemberInfo;
begin
  CloseFormOk := False;

  if Trim(edtMember.Text) = '' then
  begin
    Global.SBMessage.ShowMessageModalForm('회원번호를 입력해 주세요');
    edtMember.SetFocus;
    Exit;
  end;

  if Trim(edtAuth.Text) = '' then
  begin
    Global.SBMessage.ShowMessageModalForm('인증번호를 입력해 주세요');
    edtAuth.SetFocus;
    Exit;
  end;

  Global.SaleModule.FCheckMemberCode := edtMember.Text;
  Global.SaleModule.FCheckAuthCode := edtAuth.Text;

  CloseFormOk := True;

  if CloseFormOk then
    Popup.CloseFormStrMrok('')
  else
    Popup.CloseFormStrMrCancel;
end;

end.
