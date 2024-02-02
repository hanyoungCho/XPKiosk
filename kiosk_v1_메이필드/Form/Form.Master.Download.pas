unit Form.Master.Download;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.Ani, FMX.Layouts, FMX.Gestures,
  FMX.Objects;

type
  TMasterDownload = class(TForm)
    ImgLayout: TLayout;
    BGImage: TImage;
    DownLoadRectangle: TRectangle;
    DownLoadImage: TImage;
    txtMasterUpdate: TText;
    txtDownLoadTitle: TText;
    txtEndCnt: TText;
    Timer: TTimer;
    txtUpdate: TText;
    procedure TimerTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    ProgramStart: Boolean;
    Member: Boolean;
    Config: Boolean;
    Product: Boolean;
    TeeBox: Boolean;
  end;

var
  MasterDownload: TMasterDownload;

// 회원
// 환경설정
// 상품
// 타석 마스터
// 타석 가동상황


implementation

uses
  uGlobal, fx.Logging;

{$R *.fmx}

procedure TMasterDownload.FormDestroy(Sender: TObject);
begin
  DeleteChildren;
  Exit;
end;

procedure TMasterDownload.FormShow(Sender: TObject);
begin
  Log.D('TMasterDownload', 'OAuth_Certification');
  Global.XPErpApi.OAuth_Certification;
  Log.D('TMasterDownload', 'OAuth_Certification end');

  Timer.Enabled := True;

  if ProgramStart then
  begin
    txtUpdate.Visible := False;
    txtDownLoadTitle.Visible := True;
    txtEndCnt.Visible := True;
    txtMasterUpdate.Visible := True;
  end
  else
  begin
    txtUpdate.Visible := True;
    txtDownLoadTitle.Visible := False;
    txtEndCnt.Visible := False;
    txtMasterUpdate.Visible := False;
  end;

end;

procedure TMasterDownload.TimerTimer(Sender: TObject);
var
  DownLoadCnt: Integer;

  function SetCnt: Boolean;
  begin
    Result := False;
    Application.ProcessMessages;
    Inc(DownLoadCnt);
    DownLoadRectangle.Width := DownLoadCnt * 217; //217.5
    txtEndCnt.Text := Format('(%d of %d)', [DownLoadCnt, 4]);
    if DownLoadCnt = 1 then
      txtDownLoadTitle.Text := '회원 정보'
    {
    else if DownLoadCnt = 2 then
      txtDownLoadTitle.Text := '환경설정 정보'
    }
    else if DownLoadCnt = 2 then
      txtDownLoadTitle.Text := '상품 정보'
    else if DownLoadCnt = 3 then
      txtDownLoadTitle.Text := '타석 정보'
    else if DownLoadCnt = 4 then
      txtDownLoadTitle.Text := '타석가동 정보';
    Sleep(1000);
    Result := True;
  end;
begin
  Timer.Enabled := False;
  DownLoadCnt := 0;

  Log.D('TMasterDownload', 'Member');
  SetCnt;
  if Member then
  begin

    Global.LocalDB.DBConnection;

    //if ProgramStart then
      //Global.Config.Version.MemberVersion := Global.Database.GetAllMmeberInfoVersion;

    if not Global.SaleModule.GetMemberList then
    begin
      Log.E('Global.SaleModule.GetMemberList', '실패');
      ModalResult := mrCancel;
    end
    else
      Log.D('Global.SaleModule.GetMemberList', IntToStr(Global.SaleModule.MemberList.Count));

  end;

  Log.D('TMasterDownload', 'Product');
  SetCnt;
  if Product then
  begin
    //if ProgramStart then
      //Global.Config.Version.ProductVersion := Global.Database.GetTeeBoxProductListVersion;

    if not Global.SaleModule.GetProductList then
    begin
      Log.E('Global.SaleModule.GetProductList', '실패');
      ModalResult := mrCancel;
    end
    else
      Log.D('Global.SaleModule.GetProductList', IntToStr(Global.SaleModule.SaleList.Count));
  end;

  SetCnt;
  if TeeBox then
  begin
    //if ProgramStart then
      //Global.Config.Version.TeeBoxMasterVersion := Global.Database.GetTeeBoxMasterVersion;

    if not Global.SaleModule.GetTeeBoxInfo then
    begin
      Log.E('Global.SaleModule.GetTeeBoxInfo', '실패');
      ModalResult := mrCancel;
    end
    else
      Log.D('Global.SaleModule.GetTeeBoxInfo', IntToStr(Global.TeeBox.TeeBoxInfo.Count));
  end;

  SetCnt;
  if ProgramStart then
  begin
    if not Global.SaleModule.GetPlayingTeeBoxList then
    begin
      Log.E('Global.SaleModule.GetPlayingTeeBoxList', '실패');
      ModalResult := mrCancel;
    end
    else
      Log.D('Global.SaleModule.GetPlayingTeeBoxList', IntToStr(Global.TeeBox.TeeBoxList.Count));
  end;

  if ProgramStart then
  begin
    Global.MFErpApi.GetStoreInfo;

    Global.Config.Version.AdvertisVersion := Global.XPErpApi.GetAdvertisVersion;
    Global.XPErpApi.SearchAdvertisList;
    {$IFDEF DEBUG}
//    Global.LocalDatabase.SAVE_ADVERTIS;
    {$ENDIF}
    // 전일자 광고 정보 전달
    // 광고 테이블에 마스터 저장
    // 업데이트 필요
  end;

  Global.Config.SaveLocalConfig;
  ModalResult := mrOk;
end;

end.
