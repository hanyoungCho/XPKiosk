unit Frame.NewMember;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects;

type
  TNewMember = class(TFrame)
    Rectangle3: TRectangle;
    Rectangle11: TRectangle;
    Image3: TImage;
    Text17: TText;
    Rectangle12: TRectangle;
    Image4: TImage;
    Text18: TText;
    Rectangle1: TRectangle;
    txtTitle: TText;
    PolicyAll: TRectangle;
    Text10: TText;
    imgPolicyAll: TImage;
    Text1: TText;
    Policy2: TRectangle;
    Text4: TText;
    Policy1: TRectangle;
    Text2: TText;
    Text3: TText;
    Policy3: TRectangle;
    Text7: TText;
    recPolicyAll: TRectangle;
    imgPolicyAllNon: TImage;
    recPolicy1: TRectangle;
    imgPolicy1Non: TImage;
    imgNewMember: TImage;
    Image1: TImage;
    recPolicy2: TRectangle;
    Image2: TImage;
    Text9: TText;
    Image5: TImage;
    recPolicy3: TRectangle;
    Image6: TImage;
    Text5: TText;
    Image7: TImage;
    procedure Rectangle11Click(Sender: TObject);
    procedure Rectangle12Click(Sender: TObject);
    procedure recPolicyAllClick(Sender: TObject);
    procedure recPolicy1Click(Sender: TObject);
    procedure recPolicy2Click(Sender: TObject);
    procedure recPolicy3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses
  Form.Popup, uGlobal, uCommon, uConsts;

{$R *.fmx}

procedure TNewMember.recPolicyAllClick(Sender: TObject);
begin
  if Text1.Text = '0' then
  begin
    Text1.Text := '1';
    imgPolicyAll.Visible := True;
    imgPolicyAllNon.Visible := False;
  end
  else
  begin
    Text1.Text := '0';
    imgPolicyAll.Visible := False;
    imgPolicyAllNon.Visible := True;
  end;
end;

procedure TNewMember.Rectangle11Click(Sender: TObject);
begin
  Popup.CloseFormStrMrCancel;
end;

procedure TNewMember.Rectangle12Click(Sender: TObject);
begin
  if (Text1.Text <> '1') then
  begin
    Global.SBMessage.ShowMessageModalForm(MSG_NEW_MEMBER);
  end
  else
    Popup.CloseFormStrMrok('');
end;

procedure TNewMember.recPolicy1Click(Sender: TObject);
begin
  //1.�����̿�������
  ShowPolicyView(1);
end;

procedure TNewMember.recPolicy2Click(Sender: TObject);
begin
  //2.�������������̿뵿��
  ShowPolicyView(2);
end;

procedure TNewMember.recPolicy3Click(Sender: TObject);
begin
  //3.���̿����������̿���������
  ShowPolicyView(3);
end;

end.
