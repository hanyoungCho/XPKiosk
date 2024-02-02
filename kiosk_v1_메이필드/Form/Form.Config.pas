unit Form.Config;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.Ani, FMX.Layouts, FMX.Gestures,
  FMX.Objects, Frame.Config.Item.Style, Generics.Collections, JSON,
  InIFiles;

type
  TConfig = class(TForm)
    Layout: TLayout;
    BGImage: TImage;
    BottomLayout: TLayout;
    BottomRectangle: TRectangle;
    BackRectangle: TRectangle;
    BackImage: TImage;
    Text1: TText;
    WhiteImage: TImage;
    Text2: TText;
    Text3: TText;
    Text4: TText;
    Line: TLine;
    Rectangle: TRectangle;
    procedure BackImageClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Display;
    procedure ParkingSend(ATkno, ACarnum: String);
  end;

var
  Config: TConfig;

implementation

uses
  uGlobal, uFunction, fx.Logging;

{$R *.fmx}

procedure TConfig.FormShow(Sender: TObject);
begin
  Display;
end;

procedure TConfig.BackImageClick(Sender: TObject);
begin
  //ModalResult := mrOk;
  ModalResult := mrCancel;
end;

procedure TConfig.Display;
var
  AConfigItemStyle: TConfigItemStyle;
  jObj, jObjItem: TJSONObject;
  jObjArr: TJSONArray;
  sTkno, sCarnumber: String;
  I: Integer;
begin

  try
    jObj := TJSONObject.ParseJSONValue(Global.SaleModule.NexpaParkList) as TJSONObject;
    jObjArr := jObj.GetValue('recvdata') as TJsonArray;

    for I := 0 to jObjArr.Size - 1 do
    begin
      jObjItem := jObjArr.Get(I) as TJSONObject;
      sTkno := jObjItem.GetValue('tkno').Value; //고유번호
      sCarnumber := jObjItem.GetValue('carnumber').Value; //차량번호

      AConfigItemStyle := TConfigItemStyle.Create(nil);
      AConfigItemStyle.Position.X := 0;
      AConfigItemStyle.Position.Y := 2 + I * AConfigItemStyle.Height;
      AConfigItemStyle.Parent := Rectangle;
      AConfigItemStyle.Display(sTkno, sCarnumber);
    end;

  finally
    FreeAndNil(jObj);
  end;

  {
  AConfigItemStyle := TConfigItemStyle.Create(nil);
      AConfigItemStyle.Position.X := 0;
      AConfigItemStyle.Position.Y := 2;// + AConfigItemStyle.Height;
      AConfigItemStyle.Parent := Rectangle;
      AConfigItemStyle.Display('222', '0234');
   }
end;

procedure TConfig.ParkingSend(ATkno, ACarnum: String);
var
  jObj: TJSONObject;
  JsonText, sResult: String;
begin

  JsonText := '{"jobcode":"NP002",' +
               '"tkno":"' + ATkno + '",' +
               '"dcvalue":"180",' +
               '"carnum":"' + ACarnum + '"}';

  sResult := Global.XPErpApi.Send_Nexpa_API('/WebNexpaParkingSytstem/Discount', JsonText);
  //Log.D('Nexpa Result', sResult);

  try
    jObj := TJSONObject.ParseJSONValue(sResult) as TJSONObject;
    Global.SBMessage.ShowMessageModalForm(jObj.GetValue('resultmsg').Value);

    if jObj.GetValue('resultcode').Value <> '0' then
      Exit;

    ModalResult := mrOk;
  finally
    FreeAndNil(jObj);
  end;

end;

end.
