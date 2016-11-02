program FaceDetect;

uses
  FMX.Forms,
  Main in 'Main.pas' {Form1},
  ocv.core_c in '_LIBRARY\LUXOPHIA\LUX.Vision.OpenCV\› Laex\Delphi-OpenCV\source\ocv.core_c.pas',
  ocv.imgproc.types_c in '_LIBRARY\LUXOPHIA\LUX.Vision.OpenCV\› Laex\Delphi-OpenCV\source\ocv.imgproc.types_c.pas',
  ocv.imgproc_c in '_LIBRARY\LUXOPHIA\LUX.Vision.OpenCV\› Laex\Delphi-OpenCV\source\ocv.imgproc_c.pas',
  ocv.lib in '_LIBRARY\LUXOPHIA\LUX.Vision.OpenCV\› Laex\Delphi-OpenCV\source\ocv.lib.pas',
  ocv.objdetect_c in '_LIBRARY\LUXOPHIA\LUX.Vision.OpenCV\› Laex\Delphi-OpenCV\source\ocv.objdetect_c.pas',
  ocv.core.types_c in '_LIBRARY\LUXOPHIA\LUX.Vision.OpenCV\› Laex\Delphi-OpenCV\source\ocv.core.types_c.pas',
  LUX.Vision.OpenCV in '_LIBRARY\LUXOPHIA\LUX.Vision.OpenCV\LUX.Vision.OpenCV.pas',
  LUX.Vision.OpenCV.Detect in '_LIBRARY\LUXOPHIA\LUX.Vision.OpenCV\LUX.Vision.OpenCV.Detect.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
