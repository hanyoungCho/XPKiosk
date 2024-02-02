unit Form.PolicyView;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Layouts,
  Generics.Collections, Frame.PolicyView.Page.Item.Style;

type
  TfrmPolicyView = class(TForm)
    Image: TImage;
    Rectangle3: TRectangle;
    recOK: TRectangle;
    Image4: TImage;
    Text18: TText;
    txtTitle: TText;
    Layout: TLayout;
    Rectangle: TRectangle;
    Rectangle1: TRectangle;
    ImagePrev: TImage;
    ImageNext: TImage;
    PageRectangle: TRectangle;
    ImgShortCut: TImage;
    Text4: TText;
    ImgClose: TImage;
    Text1: TText;
    txtTemp: TText;
    procedure recOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ImageNextClick(Sender: TObject);
    procedure ImagePrevClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ImgShortCutClick(Sender: TObject);
    procedure ImgCloseClick(Sender: TObject);
  private
    { Private declarations }
    FMaxPage: Integer;
    FActivePage: Integer;
    PageList: TList<TPolicyViewPageItemStyle>;
  public
    { Public declarations }
    FPolicyType: Integer;
    procedure SelectPage(APage: Integer);
    procedure Display;
  end;

var
  frmPolicyView: TfrmPolicyView;

implementation

uses
  uGlobal, uConsts, uStruct;

{$R *.fmx}

procedure TfrmPolicyView.FormCreate(Sender: TObject);
begin
  PageList := TList<TPolicyViewPageItemStyle>.Create;
  FMaxPage := 0;
  FActivePage := 1;
end;

procedure TfrmPolicyView.FormDestroy(Sender: TObject);
begin
  PageList.Free;
end;

procedure TfrmPolicyView.FormShow(Sender: TObject);
var
  sLoadFile: String;
begin
  if FPolicyType = 0 then
  begin
    //FMaxPage := 2;
    if global.Config.AdvertMember = True then
      Inc(FMaxPage);

    //if global.Config.AdvertXGolf = True then
      //Inc(FMaxPage);
  end
  else if FPolicyType = 1 then
  begin
    FMaxPage := Global.SaleModule.AgreementList1.Count;
  end
  else if FPolicyType = 2 then
  begin
    FMaxPage := Global.SaleModule.AgreementList2.Count;
  end
  else if FPolicyType = 3 then
  begin
    FMaxPage := Global.SaleModule.AgreementList3.Count;
  end;

  ImagePrev.Visible := FMaxPage > 1;
  ImageNext.Visible := FMaxPage > 1;
  PageRectangle.Visible := FMaxPage > 1;
  ImagePrev.Visible := FActivePage <> 1;
  ImageNext.Visible := FActivePage <> FMaxPage;

  //{$IFDEF RELEASE}
  txtTemp.Text := '';
  if FPolicyType = 0 then
  begin
    txtTitle.Text := '';
    if FMaxPage = 1 then
    begin
      if global.Config.AdvertMember = True then
        txtTemp.Text := '회원권 판매 광고';

      //if global.Config.AdvertXGolf = True then
        //txtTemp.Text := 'XGOLFF 회원 광고';
    end
    else
    begin
      if FActivePage = 1 then
        txtTemp.Text := '회원권 판매 광고'
      else
        txtTemp.Text := 'XGOLFF 회원 광고';
    end;
  end
  else if FPolicyType = 1 then  //1.서비스이용약관동의
  begin
    sLoadFile := TAgreement(Global.SaleModule.AgreementList1[0]).FilePath;
    //Image.Bitmap.LoadFromFile('C:\XPartners\Image\서비스약관.jpg')
    Image.Bitmap.LoadFromFile(sLoadFile)
  end
  else if FPolicyType = 2 then  //2.개인정보수집이용동의
  begin
    sLoadFile := TAgreement(Global.SaleModule.AgreementList2[0]).FilePath;
    //Image.Bitmap.LoadFromFile('C:\XPartners\Image\개인정보동의서.jpg')
    Image.Bitmap.LoadFromFile(sLoadFile)
  end
  else if FPolicyType = 3 then  //3.바이오정보수집이용제공동의
  begin
    sLoadFile := TAgreement(Global.SaleModule.AgreementList3[0]).FilePath;
    //Image.Bitmap.LoadFromFile('C:\XPartners\Image\바이오동의서.jpg');
    Image.Bitmap.LoadFromFile(sLoadFile)
  end;
  //{$ENDIF}


  Display;
end;

procedure TfrmPolicyView.Display;
var
  ASaleBoxPageItemStyle: TPolicyViewPageItemStyle;
  Index: Integer;
begin

  PageRectangle.Width := PageRectangle.Width * FMaxPage;
  for Index := 0 to FMaxPage - 1 do
  begin
    ASaleBoxPageItemStyle := TPolicyViewPageItemStyle.Create(nil);
    ASaleBoxPageItemStyle.Text.Text := IntToStr(Index + 1);
//    ASaleBoxPageItemStyle.Align := TAlignLayout.Center;
    ASaleBoxPageItemStyle.Parent := PageRectangle;
    ASaleBoxPageItemStyle.Position := TPosition.Create(TPointF.Create((Index * ASaleBoxPageItemStyle.Width) + (Index * 2), 0));
    //ASaleBoxPageItemStyle.IndexPage := Index + 1;

    if Index = 0 then
    begin
      ASaleBoxPageItemStyle.Circle.Fill.Color := TAlphaColorRec.Black;
      ASaleBoxPageItemStyle.Text.TextSettings.FontColor := $FFD9D9D9;
    end
    else
    begin
      ASaleBoxPageItemStyle.Circle.Fill.Color := TAlphaColorRec.White;
      ASaleBoxPageItemStyle.Text.TextSettings.FontColor := $FF37383C;
    end;

    PageList.Add(ASaleBoxPageItemStyle);
  end;
end;

procedure TfrmPolicyView.ImageNextClick(Sender: TObject);
var
  sLoadFile: String;
begin
  if FPolicyType = 0 then
  begin
    txtTemp.Text := 'XGOLFF 회원 광고';
  end
  else if FPolicyType = 1 then  //1.서비스이용약관동의
  begin
    sLoadFile := TAgreement(Global.SaleModule.AgreementList1[FActivePage]).FilePath;
    //Image.Bitmap.LoadFromFile('C:\XPartners\Image\장한평_약관_2.jpg');
    Image.Bitmap.LoadFromFile(sLoadFile)
  end
  else if FPolicyType = 2 then  //2.개인정보수집이용동의
  begin
    sLoadFile := TAgreement(Global.SaleModule.AgreementList2[FActivePage]).FilePath;
    Image.Bitmap.LoadFromFile(sLoadFile)
  end
  else if FPolicyType = 3 then  //3.바이오정보수집이용제공동의
  begin
    sLoadFile := TAgreement(Global.SaleModule.AgreementList3[FActivePage]).FilePath;
    Image.Bitmap.LoadFromFile(sLoadFile)
  end;

  Inc(FActivePage);
  SelectPage(FActivePage);
end;

procedure TfrmPolicyView.ImagePrevClick(Sender: TObject);
var
  sLoadFile: String;
  nPage: Integer;
begin

  if not ((FActivePage - 1) < 1) then
  begin
    Dec(FActivePage);
    nPage := FActivePage - 1;
    if nPage < 0 then
      nPage := 0;

    if FPolicyType = 0 then
    begin
      txtTemp.Text := '회원권 판매 광고';
    end
    else if FPolicyType = 1 then  //1.서비스이용약관동의
    begin
      sLoadFile := TAgreement(Global.SaleModule.AgreementList1[nPage]).FilePath;
      //Image.Bitmap.LoadFromFile('C:\XPartners\Image\장한평_약관_1.jpg');
      Image.Bitmap.LoadFromFile(sLoadFile)
    end
    else if FPolicyType = 2 then  //2.개인정보수집이용동의
    begin
      sLoadFile := TAgreement(Global.SaleModule.AgreementList2[nPage]).FilePath;
      Image.Bitmap.LoadFromFile(sLoadFile)
    end
    else if FPolicyType = 3 then  //3.바이오정보수집이용제공동의
    begin
      sLoadFile := TAgreement(Global.SaleModule.AgreementList3[nPage]).FilePath;
      Image.Bitmap.LoadFromFile(sLoadFile)
    end;

    SelectPage(FActivePage);
  end;
end;

procedure TfrmPolicyView.ImgCloseClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmPolicyView.ImgShortCutClick(Sender: TObject);
begin
  if FMaxPage = 1 then
  begin
    if global.Config.AdvertMember = True then
      Global.SaleModule.AdvertPopupType := apMember;

    //if global.Config.AdvertXGolf = True then
      //Global.SaleModule.AdvertPopupType := apXgolf;
  end
  else
  begin
    if FActivePage = 1 then
      Global.SaleModule.AdvertPopupType := apMember
    else
      Global.SaleModule.AdvertPopupType := apXgolf;
  end;
  ModalResult := mrOk;
end;

procedure TfrmPolicyView.recOKClick(Sender: TObject);
begin
  //1654*2339
  ModalResult := mrOk;
end;

procedure TfrmPolicyView.SelectPage(APage: Integer);
var
  Index: Integer;
begin
  for Index := 0 to PageList.Count - 1 do
  begin
    if Index = (APage - 1) then
    begin
      PageList[Index].Circle.Fill.Color := TAlphaColorRec.Black;
      PageList[Index].Text.TextSettings.FontColor := $FFD9D9D9;
    end
    else
    begin
      PageList[Index].Circle.Fill.Color := TAlphaColorRec.White;
      PageList[Index].Text.TextSettings.FontColor := $FF37383C;
    end;
  end;

  ImagePrev.Visible := APage <> 1;
  ImageNext.Visible := APage <> FMaxPage;
end;

end.
