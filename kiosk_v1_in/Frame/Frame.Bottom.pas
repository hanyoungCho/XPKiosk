unit Frame.Bottom;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, Generics.Collections;

type
  TThreadImg = class(TThread)
  private
    FIndex: Integer;
//    AImgList: TList<string>;
    FImage: TImage;
    FActiveIndex: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;

    procedure SetImage(AImage: TImage);
  end;

  TBottom = class(TFrame)
    Image: TImage;
  private
    { Private declarations }
    FIndex: Integer;
  public
    FThreadImg: TThreadImg;
    { Public declarations }
    procedure Display(IsThread: Boolean = True);
    function ChangeImg: Integer;
  end;

implementation

uses
  uGlobal, fx.Logging;

{$R *.fmx}

{ TThreadImg }

constructor TThreadImg.Create;
begin
  FreeOnTerminate := False;
  inherited Create(True);

//  AImgList := TList<string>.Create;
//  AImgList.Add(ExtractFilePath(ParamStr(0)) + '\Intro\Image1.jpg');
//  AImgList.Add(ExtractFilePath(ParamStr(0)) + '\Intro\Image2.jpg');
//  AImgList.Add(ExtractFilePath(ParamStr(0)) + '\Intro\Image3.jpg');
//  AImgList.Add(ExtractFilePath(ParamStr(0)) + '\Intro\Image4.jpg');
  FIndex := 0;
  FActiveIndex := 0;
end;

destructor TThreadImg.Destroy;
begin
//  AImgList.Free;
  inherited;
end;


procedure TThreadImg.Execute;
begin
  inherited;
      //AGoodsInfo.BitMapFile.LoadFromFile((ExtractFilePath(ParamStr(0)) + 'SBImage\KidJob\' + 'default' + '.png'));
  while not Terminated do
  begin
    if FActiveIndex <= FIndex then
    begin
      FActiveIndex := FIndex;
      FImage.Bitmap.LoadFromFile(Global.SaleModule.AdvertisementListDown[FActiveIndex].FilePath);
  //    if FIndex = 3 then  // 파일리스트 COUNT
  //      FIndex := 0
  //    else
  //      Inc(FIndex);
      // API 전송
//      Global.Database.SendAdvertisCnt(IntToStr(Global.SaleModule.AdvertisementListDown[FActiveIndex].Seq));
      Sleep(StrToIntDef(Global.SaleModule.AdvertisementListDown[FActiveIndex].Show_Interval, 1) * 1000);
  //    Suspend;
      if FActiveIndex = (Global.SaleModule.AdvertisementListDown.Count - 1) then
      begin
        FActiveIndex := 0;
        FIndex := 0;
      end;
    end
    else
      Inc(FIndex);
  end;
end;

procedure TThreadImg.SetImage(AImage: TImage);
begin
  FImage := AImage;
end;

{ TBottom }

function TBottom.ChangeImg: Integer;
begin
  try
    Result := 1;
    if Global.SaleModule.AdvertisementListDown.Count <> 0 then
    begin
      if FIndex <= (Global.SaleModule.AdvertisementListDown.Count - 1) then
      begin
        //2021-08-24 ntdll 임시주석
        if (Global.Config.Store.StoreCode <> 'A6001') then //캐슬렉스
          Global.Database.SendAdvertisCnt(IntToStr(Global.SaleModule.AdvertisementListDown[FIndex].Seq));

        Image.Bitmap := Global.SaleModule.AdvertisementListDown[FIndex].Image;
        Inc(FIndex);
      end
      else
      begin
        FIndex := 0;
        ChangeImg;
      end;
    end;
  except
    on E: Exception do
    begin
      Log.E('ChangeImg', E.Message);
      Log.E('ChangeImg FIndex', IntToStr(FIndex));
      Log.E('ChangeImg AdvertisementListDown.Count', IntToStr(Global.SaleModule.AdvertisementListDown.Count));
      //Log.E('ChangeImg', E.Message);
    end;
  end;
end;

procedure TBottom.Display(IsThread: Boolean);
begin
  FIndex := 0;
  if IsThread then
  begin
    FThreadImg := TThreadImg.Create;
    FThreadImg.SetImage(Image);
    FThreadImg.Resume;
  end
  else
  begin
    if Global.SaleModule.AdvertisementListDown.Count <> 0 then
    begin
      //2021-08-24 ntdll 임시주석
      if (Global.Config.Store.StoreCode <> 'A6001') then //캐슬렉스
        Global.Database.SendAdvertisCnt(IntToStr(Global.SaleModule.AdvertisementListDown[0].Seq));

      Image.Bitmap.LoadFromFile(Global.SaleModule.AdvertisementListDown[0].FilePath);
      Inc(FIndex);
    end;
  end;
end;

end.
