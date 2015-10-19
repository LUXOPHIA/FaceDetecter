unit Main;

interface //#################################################################### ■

uses
  System.Types, System.UITypes, System.Classes, System.SysUtils,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Objects, FMX.Media, FMX.Graphics,
  FMX.StdCtrls, FMX.Controls.Presentation,
  LUX.Vision.OpenCV, LUX.Vision.OpenCV.Detect;

type
  TForm1 = class(TForm)
    Image1: TImage;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { private 宣言 }
  public
    { public 宣言 }
    _Detect :THaarCascade;
    _Image  :TocvBitmap4;
    ///// メソッド
    procedure ShowDetect;
  end;

var
  Form1: TForm1;

implementation //############################################################### ■

{$R *.fmx}

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

procedure TForm1.ShowDetect;
var
   I :Integer;
begin
     with Image1.Bitmap.Canvas do
     begin
          BeginScene;

          with Stroke do
          begin
               Color     := TAlphaColorRec.Red;
               Thickness := 2;
          end;

          with _Detect do
          begin
               for I := 0 to FaceN-1 do DrawEllipse( TRectF.Create( Box[ I ] ), 1 );
          end;

          EndScene;
     end;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

procedure TForm1.FormCreate(Sender: TObject);
begin
     _Detect := THaarCascade.Create( '..\..\_DATA\Cascade\Haar\haarcascade_frontalface_default.xml' );

     with Image1.Bitmap do
     begin
          LoadFromFile( '..\..\_DATA\Faces.jpg' );

          _Image := TocvBitmap4.Create( Width, Height );
     end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
     _Image.Free;

     _Detect.Free;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.Button1Click(Sender: TObject);
begin
     _Image.CopyFrom( Image1.Bitmap );

     _Detect.Search( _Image );

     ShowDetect;

     Button1.Enabled := False;
end;

end. //######################################################################### ■
