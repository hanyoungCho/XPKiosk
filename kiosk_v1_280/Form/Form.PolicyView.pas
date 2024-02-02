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

    FAdvertMember: Boolean;
    FAdvertEvent: Boolean;

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
  FAdvertMember := False;
  FAdvertEvent := False;
end;

procedure TfrmPolicyView.FormDestroy(Sender: TObject);
begin
  PageList.Free;
end;

procedure TfrmPolicyView.FormShow(Sender: TObject);
var
  sLoadFile: String;
  nIdx: Integer;
begin
  if FPolicyType = 0 then
  begin
    //FMaxPage := 2;
    if (Global.SaleModule.AdvertListPopupMember.Count > 0) then
    begin
      FAdvertMember := True;
      Inc(FMaxPage);
    end;
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
  end
  else if FPolicyType = 4 then
  begin
    FMaxPage := 2;
  end
  else if FPolicyType = 5 then
  begin
    FMaxPage := 1;
  end;

  ImagePrev.Visible := FMaxPage > 1;
  ImageNext.Visible := FMaxPage > 1;
  PageRectangle.Visible := FMaxPage > 1;
  ImagePrev.Visible := FActivePage <> 1;
  ImageNext.Visible := FActivePage <> FMaxPage;

  if FPolicyType = 0 then
  begin
    txtTitle.Text := '';
    txtTitle.Visible := False;
    if FMaxPage = 1 then
    begin
      if FAdvertMember = True then //추천회원권
      begin
        nIdx := Global.SaleModule.AdvertListPopupMemberIdx;
        sLoadFile := TAdvertisement(Global.SaleModule.AdvertListPopupMember[nIdx]).FilePath;
        Image.Bitmap.LoadFromFile(sLoadFile);

       nIdx := nIdx + 1;
        if nIdx > Global.SaleModule.AdvertListPopupMember.Count - 1 then
          nIdx := 0;

        Global.SaleModule.AdvertListPopupMemberIdx := nIdx;
      end;
    end
    else
    begin
      if FActivePage = 1 then //추천회원권
      begin
        sLoadFile := TAdvertisement(Global.SaleModule.AdvertListPopupMember[0]).FilePath;
        Image.Bitmap.LoadFromFile(sLoadFile);
      end;
    end;
  end
  else if FPolicyType = 1 then  //1.서비스이용약관동의
  begin
    sLoadFile := TAgreement(Global.SaleModule.AgreementList1[0]).FilePath;
    Image.Bitmap.LoadFromFile(sLoadFile)
  end
  else if FPolicyType = 2 then  //2.개인정보수집이용동의
  begin
    sLoadFile := TAgreement(Global.SaleModule.AgreementList2[0]).FilePath;
    Image.Bitmap.LoadFromFile(sLoadFile)
  end
  else if FPolicyType = 3 then  //3.바이오정보수집이용제공동의
  begin
    sLoadFile := TAgreement(Global.SaleModule.AgreementList3[0]).FilePath;
    Image.Bitmap.LoadFromFile(sLoadFile)
  end
  else if FPolicyType = 4 then  // 'C1001' 코리아하이파이브스포츠클럽
  begin
    Image.Bitmap.LoadFromFile('C:\XPartners_kiosk\Image\Policy1.jpg');
    //Image.Bitmap.LoadFromFile('D:\Works\XGolf\bin_kiosk\Image\Policy1.jpg');
    text4.Text := '동의';
  end
  else if FPolicyType = 5 then
  begin
    sLoadFile := Global.SaleModule.AdvertListEvent[0].FilePath2;
    Image.Bitmap.LoadFromFile(sLoadFile)
  end;

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
  if FPolicyType = 0 then //'XGOLFF 회원 광고';
  begin
    //sLoadFile := TAdvertisement(Global.SaleModule.AdvertListPopupEvent[0]).FilePath2;
    //Image.Bitmap.LoadFromFile(sLoadFile);
  end
  else if FPolicyType = 1 then  //1.서비스이용약관동의
  begin
    sLoadFile := TAgreement(Global.SaleModule.AgreementList1[FActivePage]).FilePath;
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
  end
  else if FPolicyType = 4 then  // 'C1001' 코리아하이파이브스포츠클럽
  begin
    Image.Bitmap.LoadFromFile('C:\XPartners_kiosk\Image\Policy2.jpg');
    //Image.Bitmap.LoadFromFile('D:\Works\XGolf\bin_kiosk\Image\Policy2.jpg');
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

    if FPolicyType = 0 then  //추천회원권
    begin
      sLoadFile := TAdvertisement(Global.SaleModule.AdvertListPopupMember[0]).FilePath;
      Image.Bitmap.LoadFromFile(sLoadFile);
    end
    else if FPolicyType = 1 then  //1.서비스이용약관동의
    begin
      sLoadFile := TAgreement(Global.SaleModule.AgreementList1[nPage]).FilePath;
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
    end
    else if FPolicyType = 4 then  // 'C1001' 코리아하이파이브스포츠클럽
    begin
      Image.Bitmap.LoadFromFile('C:\XPartners_kiosk\Image\Policy1.jpg');
      //Image.Bitmap.LoadFromFile('D:\Works\XGolf\bin_kiosk\Image\Policy1.jpg');
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
  if FPolicyType = 0 then  //추천회원권
  begin
    if FMaxPage = 1 then
    begin
      if (Global.SaleModule.AdvertListPopupMember.Count > 0) then
        Global.SaleModule.AdvertPopupType := apMember;
    end
    else
    begin
      if FActivePage = 1 then
        Global.SaleModule.AdvertPopupType := apMember;
    end;
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
