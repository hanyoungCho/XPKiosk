unit Frame.NewMember;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects;

type
  TNewMember = class(TFrame)
    Image: TImage;
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
    Panel1: TPanel;
    Text10: TText;
    imgPolicyAll: TImage;
    Text1: TText;
    Policy2: TRectangle;
    Text4: TText;
    Text6: TText;
    Policy1: TRectangle;
    Text2: TText;
    Text3: TText;
    Policy3: TRectangle;
    Text7: TText;
    Text8: TText;
    recPolicyAll: TRectangle;
    imgPolicyAllNon: TImage;
    recPolicy1: TRectangle;
    imgPolicy1Non: TImage;
    imgPolicy1: TImage;
    recPolicy2: TRectangle;
    imgPolicy2Non: TImage;
    imgPolicy2: TImage;
    recPolicy3: TRectangle;
    imgPolicy3Non: TImage;
    imgPolicy3: TImage;
    procedure Rectangle11Click(Sender: TObject);
    procedure Rectangle12Click(Sender: TObject);
    procedure recPolicyAllClick(Sender: TObject);
    procedure recPolicy3Click(Sender: TObject);
    procedure recPolicy2Click(Sender: TObject);
    procedure recPolicy1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses
  Form.Popup, uGlobal, uCommon, uConsts;

{$R *.fmx}

procedure TNewMember.recPolicy1Click(Sender: TObject);
begin
  if Text3.Text = '0' then
  begin
    Text3.Text := '1';
    imgPolicy1.Visible := True;
    imgPolicy1Non.Visible := False;
  end
  else
  begin
    Text3.Text := '0';
    imgPolicy1.Visible := False;
    imgPolicy1Non.Visible := True;

    Text1.Text := '0';
    imgPolicyAll.Visible := False;
    imgPolicyAllNon.Visible := True;
  end;
end;

procedure TNewMember.recPolicy2Click(Sender: TObject);
begin
  if Text6.Text = '0' then
  begin
    Text6.Text := '1';
    imgPolicy2.Visible := True;
    imgPolicy2Non.Visible := False;
  end
  else
  begin
    Text6.Text := '0';
    imgPolicy2.Visible := False;
    imgPolicy2Non.Visible := True;

    Text1.Text := '0';
    imgPolicyAll.Visible := False;
    imgPolicyAllNon.Visible := True;
  end;
end;

procedure TNewMember.recPolicy3Click(Sender: TObject);
begin
  if Text8.Text = '0' then
  begin
    Text8.Text := '1';
    imgPolicy3.Visible := True;
    imgPolicy3Non.Visible := False;
  end
  else
  begin
    Text8.Text := '0';
    imgPolicy3.Visible := False;
    imgPolicy3Non.Visible := True;

    Text1.Text := '0';
    imgPolicyAll.Visible := False;
    imgPolicyAllNon.Visible := True;
  end;
end;

procedure TNewMember.recPolicyAllClick(Sender: TObject);
begin
  if Text1.Text = '0' then
  begin
    Text3.Text := '1';
    imgPolicy1.Visible := True;
    imgPolicy1Non.Visible := False;

    Text6.Text := '1';
    imgPolicy2.Visible := True;
    imgPolicy2Non.Visible := False;

    Text8.Text := '1';
    imgPolicy3.Visible := True;
    imgPolicy3Non.Visible := False;

    Text1.Text := '1';
    imgPolicyAll.Visible := True;
    imgPolicyAllNon.Visible := False;
  end
  else
  begin
    Text3.Text := '0';
    imgPolicy1.Visible := False;
    imgPolicy1Non.Visible := True;

    Text6.Text := '0';
    imgPolicy2.Visible := False;
    imgPolicy2Non.Visible := True;

    Text8.Text := '0';
    imgPolicy3.Visible := False;
    imgPolicy3Non.Visible := True;

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
  if (Text6.Text <> '1') or (Text3.Text <> '1') then
  begin
    Global.SBMessage.ShowMessageModalForm(MSG_NEW_MEMBER);
  end
  else
    Popup.CloseFormStrMrok('');
end;

end.
