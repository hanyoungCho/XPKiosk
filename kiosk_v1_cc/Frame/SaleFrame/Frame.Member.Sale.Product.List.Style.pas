unit Frame.Member.Sale.Product.List.Style;

interface

uses
  uStruct, FMX.Ani,
  Frame.Member.Sale.Product.Item.Style, DateUtils,
  Generics.Collections, Frame.Member.Sale.Product.Item420.Style,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Objects, Frame.SaleBox.Page.Item.Style;

type
  TMemberSaleProductListStyle = class(TFrame)
    Layout: TLayout;
    Rectangle: TRectangle;
    ItemRectangle: TRectangle;
    UpImage: TImage;
    DownImage: TImage;
    Image: TImage;
    VertScrollBox: TVertScrollBox;
    Animation: TFloatAnimation;
    Timer: TTimer;
    ImgDown: TImage;
    ImgUp: TImage;
    ScrollBar1: TScrollBar;
    ScrollRectangle: TRectangle;
    ImgScrollBG: TImage;
    ImgScroll: TImage;
    ImgScrollUp: TImage;
    ImgScrollDown: TImage;
    PageRectangle: TRectangle;
    ImageNext: TImage;
    ImagePrev: TImage;
    procedure UpImageClick(Sender: TObject);
    procedure DownImageClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure ScrollBar1Change(Sender: TObject);
    procedure ImgScrollUpClick(Sender: TObject);
    procedure ImgScrollDownClick(Sender: TObject);
  private
    { Private declarations }
    FActivePage: Integer;
    FMaxPage: Integer;
    FItemList: TList<TMemberSaleProductItemStyle>;
    FItem420List: TList<TMemberSaleProductItem420Style>;
    ShowList: TList<TProductInfo>;

    PageList: TList<TSaleBoxPageItemStyle>;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure SelectPage(APage: Integer);
    function ItemListClear: Boolean;

    procedure Display(APage: Integer = 1);
    procedure Animate(ItemStyle: TMemberSaleProductItemStyle);
    procedure Animate420(ItemStyle: TMemberSaleProductItem420Style);

    property ActivePage: Integer read FActivePage write FActivePage;
    property ItemList: TList<TMemberSaleProductItemStyle> read FItemList write FItemList;
    property Item420List: TList<TMemberSaleProductItem420Style> read FItem420List write FItem420List;
  end;

implementation

uses
  uGlobal, Form.Sale.Product, uConsts, uCommon, uFunction, fx.Logging;

{$R *.fmx}

{ TMemberSaleProductListStyle }

procedure TMemberSaleProductListStyle.Animate(
  ItemStyle: TMemberSaleProductItemStyle);
var
  Bitmap: TBitmap;
begin
  Bitmap := ItemStyle.MakeScreenshot;
  try
    try
      Image.Bitmap.Assign(Bitmap);
      Image.Visible := True;
      Image.Position.X := ItemStyle.Position.X - VertScrollBox.Position.X;
      Image.Position.Y := VertScrollBox.Margins.Top + ItemStyle.Position.Y - VertScrollBox.Position.Y;
      Image.Width := ItemStyle.Width;
      Image.Height := ItemStyle.Height;
      Image.Scale.X := 1;
      Image.Scale.Y := 1;
      Image.Opacity := 0.8;
    except
//      on E: Exception do
//        Log.E('TOrderItemListStyle.Animate', E.Message);
    end;
  finally
    Bitmap.Free;
  end;
  TAnimator.AnimateFloat(Image, 'Position.X', Image.Position.X - Image.Width * 0.3, 0.5);
  TAnimator.AnimateFloat(Image, 'Position.Y', Image.Position.Y - Image.Height * 0.3, 0.5);
  TAnimator.AnimateFloat(Image, 'Scale.X', 1.6, 0.5);
  TAnimator.AnimateFloat(Image, 'Scale.Y', 1.6, 0.5);
  TAnimator.AnimateFloat(Image, 'Opacity', 0, 0.5);
//  TAnimator.StopAnimation(Self, '');
end;

procedure TMemberSaleProductListStyle.Animate420(
  ItemStyle: TMemberSaleProductItem420Style);
var
  Bitmap: TBitmap;
  AValueY, AValueH: Integer;
begin
  Timer.Enabled := False;
  Bitmap := ItemStyle.MakeScreenshot;
  try
    try
      Image.Bitmap.Assign(Bitmap);
      Image.Visible := True;
      Image.Position.X := 105;
      Image.Position.Y := 210;

      Image.Width := ItemStyle.Width * 1.5;
      Image.Height := ItemStyle.Height * 1.5;
      Image.Scale.X := 1;
      Image.Scale.Y := 1;
      Image.Opacity := 0.8;
    except
//      on E: Exception do
//        Log.E('TOrderItemListStyle.Animate', E.Message);
    end;
  finally
    Bitmap.Free;
  end;
   Animation.PropertyName := 'Position.Y';
   Animation.StartValue := 0;
   Animation.StopValue := 600;
   Animation.Duration := 1;
   Animation.AnimationType := TAnimationType.&In;
   Animation.Interpolation := TInterpolationType.Back;
   Animation.Start;
   Timer.Enabled := True;
end;

constructor TMemberSaleProductListStyle.Create(AOwner: TComponent);
var
  Index: Integer;
  StartTime, EndTime, NowTime, AMemberType, UserSex: string;
  AProduct: TProductInfo;
  ASaleBoxPageItemStyle: TSaleBoxPageItemStyle;
begin
  inherited;
  PageList := TList<TSaleBoxPageItemStyle>.Create;
  FMaxPage := 0;
  ShowList := TList<TProductInfo>.Create;

  for Index := 0 to Global.SaleModule.SaleList.Count - 1 do
  begin
    AMemberType := EmptyStr;

    AProduct := Global.SaleModule.SaleList[Index];

    if AProduct.Price = 0 then
      Continue;

    begin

      if Global.SaleModule.memberItemType = mitperiod then
        AMemberType := PRODUCT_TYPE_R
      else if Global.SaleModule.memberItemType = mitCoupon then
        AMemberType := PRODUCT_TYPE_C
      else if (Global.SaleModule.memberItemType = mitBunkerMember) or (Global.SaleModule.memberItemType = mitBunkerNonMember) then
        AMemberType := PRODUCT_TYPE_B
      else
        AMemberType := PRODUCT_TYPE_D;

      // move
      if (Global.SaleModule.memberItemType = mitDay) then
      begin
        AMemberType := PRODUCT_TYPE_D;

        if Global.SaleModule.SaleList[Index].Product_Div <> AMemberType then
          Continue;

        //반자동
        if Global.SaleModule.SaleList[Index].Sex = '1' then
        begin

        end
        else if Global.SaleModule.SaleList[Index].Sex = '3' then
        begin

        end
        else
          Continue;

      end
      else if (Global.SaleModule.memberItemType = mitBunkerMember) then
      begin
        if Global.SaleModule.SaleList[Index].Product_Div <> PRODUCT_TYPE_B then
          Continue;

        if Global.SaleModule.SaleList[Index].Member_Product_Yn <> 'Y' then
          Continue;
      end
      else if (Global.SaleModule.memberItemType = mitBunkerNonMember) then
      begin
        if Global.SaleModule.SaleList[Index].Product_Div <> PRODUCT_TYPE_B then
          Continue;

        if Global.SaleModule.SaleList[Index].Member_Product_Yn <> 'N' then
          Continue;
      end
      else
      begin
        if Global.SaleModule.SaleList[Index].Product_Div = PRODUCT_TYPE_D then
          Continue;

        UserSex := IfThen(Global.SaleModule.Member.Sex = 'M', '1', '2');

        if Global.SaleModule.SaleList[Index].Sex <> '3' then
        begin
          if Global.SaleModule.SaleList[Index].Product_Div = 'R' then
          begin
            if UserSex <> Global.SaleModule.SaleList[Index].Sex then
              Continue;
          end;
        end;
      end;

      // Vip 타석 선택시에만 상품 표시?
      if Global.SaleModule.VipTeeBox then
      begin
        if Global.SaleModule.SaleList[Index].ZoneCode <> 'V' then
          Continue;
      end
      else
      begin
        if Global.SaleModule.SaleList[Index].ZoneCode = 'V' then
          Continue;
      end;

      if Global.SaleModule.TeeBoxInfo.BtweenTime <> 0 then
      begin
//      NowTime := DateStrToDateTime();
        NowTime := FormatDateTime('yyyymmdd', now) + StringReplace(Global.SaleModule.TeeBoxInfo.End_Time, ':', '', [rfReplaceAll]) + '00';
      end
      else
      begin
        NowTime := FormatDateTime('yyyymmddhhnn', IncMinute(now, StrToIntDef(Global.Config.PrePare_Min, 5)));
//      NowTime := FormatDateTime('hhnn', now);
      end;

      if (Global.SaleModule.SaleList[Index].Product_Div = PRODUCT_TYPE_B) then
        NowTime := FormatDateTime('yyyymmddhhnn', now);

      //if Global.Config.Store.StoreCode = 'A3001' then //JMS
        //NowTime := FormatDateTime('yyyymmddhhnn', now);

      StartTime := StringReplace(Global.SaleModule.SaleList[Index].Start_Time, ':', '', [rfReplaceAll]);
      EndTime := StringReplace(Global.SaleModule.SaleList[Index].End_Time, ':', '', [rfReplaceAll]);

      if (Global.SaleModule.SaleList[Index].Product_Div = PRODUCT_TYPE_B) then
      begin
        Log.D('상품시간', '-----------------------------------------------------');
        Log.D('상품시간', Global.SaleModule.SaleList[Index].Code);
        Log.D('상품시간', Global.SaleModule.SaleList[Index].Name);
        Log.D('상품시간', Global.SaleModule.SaleList[Index].Start_Time);
        Log.D('상품시간', Global.SaleModule.SaleList[Index].End_Time);
        Log.D('상품시간', '-----------------------------------------------------');
      end;

      if (Global.SaleModule.SaleList[Index].Product_Div = PRODUCT_TYPE_D) or
         (Global.SaleModule.SaleList[Index].Product_Div = PRODUCT_TYPE_B) then
      begin
        if not ((StartTime <= Copy(NowTime, 9, 4)) and (Copy(NowTime, 9, 4) <= EndTime)) then
          Continue;
      end;

    end;

    if FormatDateTime('hhnn', now) < '0600' then
    begin
      Log.D('상품시간', '-----------------------------------------------------');
      Log.D('상품시간', Global.SaleModule.SaleList[Index].Code);
      Log.D('상품시간', Global.SaleModule.SaleList[Index].Name);
      Log.D('상품시간', Global.SaleModule.SaleList[Index].Start_Time);
      Log.D('상품시간', Global.SaleModule.SaleList[Index].End_Time);
      Log.D('상품시간', '-----------------------------------------------------');
    end;

    ShowList.Add(Global.SaleModule.SaleList[Index]);
  end;

  FMaxPage := ShowList.Count div 4;
  if ShowList.Count mod 4 <> 0 then
    FMaxPage := FMaxPage + 1;

  PageRectangle.Width := PageRectangle.Width * FMaxPage;
  for Index := 0 to FMaxPage - 1 do
  begin
    ASaleBoxPageItemStyle := TSaleBoxPageItemStyle.Create(nil);
    ASaleBoxPageItemStyle.Text.Text := IntToStr(Index + 1);
//    ASaleBoxPageItemStyle.Align := TAlignLayout.Center;
    ASaleBoxPageItemStyle.Parent := PageRectangle;
    ASaleBoxPageItemStyle.Position := TPosition.Create(TPointF.Create((Index * ASaleBoxPageItemStyle.Width) + (Index * 2), 0));
    ASaleBoxPageItemStyle.IndexPage := Index + 1;

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

destructor TMemberSaleProductListStyle.Destroy;
begin
  PageList.Free;
  ShowList.Free;
  inherited;
end;

procedure TMemberSaleProductListStyle.Display(APage: Integer);
var
  Index, Loop, AddWidth, ColIndex, RowIndex, ProductCnt: Integer;
  Y, X: Single;
  APosition: TPosition;
  APoint: TPointF;
  AMemberSaleProductItemStyle: TMemberSaleProductItemStyle;
  AMemberSaleProductItem420Style: TMemberSaleProductItem420Style;
  StartTime, EndTime, NowTime, AMemberType: string;
begin
  try
    ActivePage := APage;
    X := 0;
    Y := 0;

    RowIndex := 0;
    ColIndex := 0;
    AddWidth := 0;
    Loop := 0;
    ProductCnt := 0;

    APoint := TPointF.Create(Y, X);
    APosition := TPosition.Create(APoint);

    if ActivePage <> 1 then
    begin
      if False then
        Loop := (ActivePage - 1) * 11
      else
        Loop := (ActivePage - 1) * 4;
    end
    else
      Loop := 0;

    if ShowList.Count = 0 then
    begin
      Global.SBMessage.ShowMessageModalForm(MSG_SALE_PRODUCT_NOT_CNT);
      Exit;
    end;

    for Index := VertScrollBox.Content.ChildrenCount - 1 downto 0 do
      VertScrollBox.Content.Children[Index].Free;

    VertScrollBox.Content.DeleteChildren;

    ItemList := TList<TMemberSaleProductItemStyle>.Create;
    Item420List := TList<TMemberSaleProductItem420Style>.Create;

    ImagePrev.Visible := ShowList.Count > 4;
    ImageNext.Visible := ShowList.Count > 4;
    PageRectangle.Visible := ShowList.Count > 4;
    ImagePrev.Visible := APage <> 1;
    ImageNext.Visible := APage <> FMaxPage;

    for Index := Loop to ShowList.Count - 1 do
    begin
      if {not Global.Config.UseItem420Size} False then
      begin
        if ColIndex = 4 then
        begin
          Inc(RowIndex);
          ColIndex := 0;
          AddWidth := 0;
        end;

        AMemberSaleProductItemStyle := TMemberSaleProductItemStyle.Create(nil);

        APosition.X := ColIndex * AMemberSaleProductItemStyle.Width + (AddWidth * 20);
        APosition.Y := -5 + RowIndex * AMemberSaleProductItemStyle.Height + (RowIndex * 20);
        AMemberSaleProductItemStyle.Position := APosition;
        AMemberSaleProductItemStyle.Tag := ProductCnt;
        AMemberSaleProductItemStyle.Parent := VertScrollBox;
        AMemberSaleProductItemStyle.Bind(ShowList[Index]);

        ItemList.Add(AMemberSaleProductItemStyle);
        Inc(ColIndex);
        Inc(AddWidth);
        Inc(ProductCnt);

        if ProductCnt = 11 then
          Break;
      end
      else
      begin
        if ColIndex = 2 then
        begin
          Inc(RowIndex);
          ColIndex := 0;
          AddWidth := 0;
        end;

        AMemberSaleProductItem420Style := TMemberSaleProductItem420Style.Create(nil);
        if ShowList.Count = 1 then
        begin
          APosition.X := 222;
          APosition.Y := 150;
        end
        else
        begin
          APosition.X := ColIndex * AMemberSaleProductItem420Style.Width + (AddWidth * 20);
          APosition.Y := RowIndex * AMemberSaleProductItem420Style.Height + (RowIndex * 20);
        end;
        AMemberSaleProductItem420Style.Position := APosition;
        AMemberSaleProductItem420Style.Tag := ProductCnt;
        AMemberSaleProductItem420Style.Parent := VertScrollBox;
        AMemberSaleProductItem420Style.Bind(ShowList[Index]);

        Item420List.Add(AMemberSaleProductItem420Style);
        Inc(ColIndex);
        Inc(AddWidth);
        Inc(ProductCnt);

        if ProductCnt = 4 then
          Break;
      end;
    end;

  finally
    APosition.Free;
    FreeAndNil(APoint);
  end;
end;

procedure TMemberSaleProductListStyle.DownImageClick(Sender: TObject);
begin
  TouchSound;
  SaleProduct.Cnt := 0;
  if (ActivePage * 4) < ShowList.Count then
  begin
    Inc(FActivePage);
    SelectPage(ActivePage);
  end;
end;

procedure TMemberSaleProductListStyle.ImgScrollDownClick(Sender: TObject);
begin
  ScrollBar1.Value := ScrollBar1.Value + 100;
  ScrollBar1Change(ScrollBar1);
end;

procedure TMemberSaleProductListStyle.ImgScrollUpClick(Sender: TObject);
begin
  ScrollBar1.Value := ScrollBar1.Value - 100;
  ScrollBar1Change(ScrollBar1);
end;

function TMemberSaleProductListStyle.ItemListClear: Boolean;
var
  Index: Integer;
begin
  try
    if ItemList <> nil then
    begin
      for Index := ItemList.Count - 1 downto 0 do
        ItemList.Delete(Index);
    end;

    if Item420List <> nil then
    begin
      for Index := Item420List.Count - 1 downto 0 do
        Item420List.Delete(Index);
    end;

    for Index := ShowList.Count - 1 downto 0 do
      ShowList.Delete(Index);

    for Index := PageList.Count - 1 downto 0 do
      PageList.Delete(Index);
  finally

  end;
end;

procedure TMemberSaleProductListStyle.ScrollBar1Change(Sender: TObject);
begin
  ScrollBar1.Max := VertScrollBox.ContentBounds.Height - VertScrollBox.Content.Height;
  VertScrollBox.ViewportPosition := TPointF.Create(0, ((ScrollBar1.Height / 2) - ScrollBar1.ViewportSize) * (ScrollBar1.Value / ScrollBar1.Max));
  ImgScroll.Position := TPosition.Create(TPointF.Create(0, ((ImgScrollBG.Height - ScrollBar1.ViewportSize) * (ScrollBar1.Value / ScrollBar1.Max))));
end;

procedure TMemberSaleProductListStyle.SelectPage(APage: Integer);
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
  Display(APage);

  ImagePrev.Visible := APage <> 1;
  ImageNext.Visible := APage <> FMaxPage;
end;

procedure TMemberSaleProductListStyle.TimerTimer(Sender: TObject);
begin
  Image.Visible := False;
  Timer.Enabled := False;
end;

procedure TMemberSaleProductListStyle.UpImageClick(Sender: TObject);
begin
  TouchSound;
  SaleProduct.Cnt := 0;
  if not ((ActivePage - 1) < 1) then
  begin
    Dec(FActivePage);
    SelectPage(ActivePage);
  end;
end;

end.
