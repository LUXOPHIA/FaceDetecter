//*****************************************************************
  //                       Delphi-OpenCV Demo
  //               Copyright (C) 2013 Project Delphi-OpenCV
  // ****************************************************************
  // Contributor:
  // Mikhail Grigorev
  // email: sleuthhound@gmail.com
  // ****************************************************************
  // You may retrieve the latest version of this file at the GitHub,
  // located at git://github.com/Laex/Delphi-OpenCV.git
  // ****************************************************************
  // The contents of this file are used with permission, subject to
  // the Mozilla Public License Version 1.1 (the "License"); you may
  // not use this file except in compliance with the License. You may
  // obtain a copy of the License at
  // http://www.mozilla.org/MPL/MPL-1_1Final.html
  //
  // Software distributed under the License is distributed on an
  // "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
  // implied. See the License for the specific language governing
  // rights and limitations under the License.
  //*******************************************************************


program CarNumDetect;

{$APPTYPE CONSOLE}
{$POINTERMATH ON}
{$R *.res}

uses
  System.SysUtils,
  System.Math,
  System.IniFiles,
  ocv.highgui_c,
  ocv.core_c,
  ocv.core.types_c,
  ocv.imgproc_c,
  ocv.imgproc.types_c,
  uResourcePaths;

const
  filename_ini = 'carnumdetect.ini';
  WindowNameOriginal = 'Original Car in Gray Scale';
  WindowNameThreshold = 'Threshold Car Image';
  WindowNameCarsNumber = 'Cars Number Detect';
  WindowNamePlateNum = 'Plate Number';
  Radius = 1;

type
  pCtx = ^TCtx;
  ArrCvRect = Array of TCvRect;
  ArrCvBox2D = Array of TCvBox2D;
  ArrDouble = Array of Double;

  TCtx = record
    MyCapture: pCvCapture; // Capture handle
    MyWriter: pCvVideoWriter; // Writer handle
    MyInputImage: pIplImage; // Input image
    MyOrigColorImage: pIplImage; // Original Color Image
    MyThresholdImage: pIplImage; // Threshold Image
    MyPlateNumberImage: pIplImage; // PlateNumber Image
    MyStorage: pCvMemStorage; // Memory storage
    MyCvRect: ArrCvRect;
    MyCvBox2D: ArrCvBox2D;
    MyArea: ArrDouble;
  end;

var
  MyCtx: pCtx;
  Key, SourceCapture, VideoCamNum, RotateImageAngle: Integer;
  BinarizationMethod, WriteVideoCaptureToFile, AdaptiveThresholdBlockSize: Integer;
  Threshold, ThresholdMaxValue: Integer;
  ImageFileCapture, VideoFileCapture, WriteVideoCaptureFileDir: AnsiString;
  WriteVideoFileName: AnsiString;
  MinRatio, MaxRatio, MinFillArea, VideoCamWidth, VideoCamHeight: Double;
  MinArea, MaxArea, MinFullArea, MaxFullArea: Integer;
  EnableErode, EnableDilate: Integer;

procedure PlateNumber(const Ctx: pCtx; Rect: TCvRect);
var
  Sub_Image: pIplImage;
begin
  // ������� ��������� �����
  Sub_Image := cvCreateImage(cvGetSize(Ctx.MyOrigColorImage), Ctx.MyOrigColorImage.depth, Ctx.MyOrigColorImage.nChannels);
  // �������� ������������ ����������� �� ��������� �����
  cvCopy(Ctx.MyOrigColorImage, Sub_Image, nil);
  // �������� ����� �� ���������� ������
  cvSetImageROI(Sub_Image, Rect);
  // ������������ � �������� ������
  Ctx.MyPlateNumberImage := cvCreateImage(cvGetSize(Sub_Image), IPL_DEPTH_8U, 1);
  cvConvertImage(Sub_Image, Ctx.MyPlateNumberImage, CV_BGR2BGRA);
  cvReleaseImage(Sub_Image);
  cvThreshold(Ctx.MyPlateNumberImage, Ctx.MyPlateNumberImage, Threshold, ThresholdMaxValue, CV_THRESH_BINARY or CV_THRESH_OTSU);
  // ���������
  //cvDilate(Ctx.MyPlateNumberImage, Ctx.MyPlateNumberImage, nil, 1);
  // ������
  //cvErode(Ctx.MyPlateNumberImage, Ctx.MyPlateNumberImage, nil, 1);
  // ������� �������
  //cvCanny(Ctx.MyPlateNumberImage, Ctx.MyPlateNumberImage, 100, 50, 3);
end;

procedure FindBox(const Ctx: pCtx; min_ratio, max_ratio: Double; min_area, max_area, MinFullArea, MaxFullArea: Integer;
  MinFillArea: Double);
var
  c, contours: pCvContour;
  box: TCvBox2D;
  rect: TCvRect;
  ratio, contourarea: Double;
  area: single;
begin
  contours := nil;
  c := nil;
  contours := AllocMem(SizeOf(TCvContour));
  c := AllocMem(SizeOf(TCvContour));
  cvClearMemStorage(Ctx.MyStorage);
  cvFindContours(Ctx.MyThresholdImage, Ctx.MyStorage, @contours, SizeOf(TCvContour), CV_RETR_LIST, CV_CHAIN_APPROX_NONE,
    cvPoint(0, 0));
  if contours <> nil then
  begin
    c := contours;
    while (c <> nil) do
    begin
      { cvMinAreaRect2 � ���������� ���������� ��������� �������������,
        ������� ����� ������� ������
        points � ������������������ ��� ������ �����
        storage � ����������� � ��������� ��������� ������
        ������� ������� cvMinAreaRect2 �� cvBoundingRect � ���� ������������ ���������.
        cvMinAreaRect2 ���������� CvBox2D, ������� ��������� �������������, �������
        ����� ���� ������� ������������ ������� ��������� ����������� �� ���� angle.
      }
      box := cvMinAreaRect2(c);
      area := box.size.width * box.size.height;
      // ���� ������� ������ ����
      if area > 0 then
      begin
        // ������ ������ ���� ������ ��� ������
        if box.size.width > box.size.height then
        begin
          // ����� �� ������� ��������������
          if (area > min_area) and (area < max_area) then
          begin
            ratio := IfThen(box.size.width < box.size.height, box.size.width / box.size.height,
              box.size.height / box.size.width);
             {$IFDEF DEBUG}
             {if box.size.width > box.size.height then
             begin
              WriteLn(Format('[d1] Rect size: height=%s, width=%s', [FloatToStr(box.size.height), FloatToStr(box.size.width)]));
              WriteLn(Format('[d1] Ratio: %s', [FloatToStr(IfThen(box.size.width < box.size.height, box.size.width/box.size.height, box.size.height/box.size.width))]));
              WriteLn(Format('[d1] Full Contour Area: %s', [FloatToStr(abs(cvContourArea(c, CV_WHOLE_SEQ)))]));
              WriteLn(Format('[d1] Contour Area: %s', [FloatToStr(abs(cvContourArea(c, CV_WHOLE_SEQ))/(area))]));
              WriteLn('------------------------- ');
              }cvRectangle(Ctx.MyOrigColorImage, cvPoint(Round(box.center.x-box.size.width/2),Round(box.center.y-box.size.height/2)), cvPoint(Round(box.center.x+box.size.width/2),Round(box.center.y+box.size.height/2)), CV_RGB(0,255,255), 2);
             //end;
             {$ENDIF}
            // ����� �� ����������� ������
            if (ratio > min_ratio) and (ratio < max_ratio) then
            begin
              {$IFDEF DEBUG}
              //WriteLn(Format('[d2] Ratio: %s', [FloatToStr(IfThen(box.size.width < box.size.height, box.size.width/box.size.height, box.size.height/box.size.width))]));
              //WriteLn('------------------------- ');
              cvRectangle(Ctx.MyOrigColorImage, cvPoint(Round(box.center.x-box.size.width/2),Round(box.center.y-box.size.height/2)), cvPoint(Round(box.center.x+box.size.width/2),Round(box.center.y+box.size.height/2)), CV_RGB(0,255,255), 2);
              {$ENDIF}
              { cvContourArea � ���������� ������� �������
                contour � ������ (������������������ ��� ������ ������)
                slice � ��������� � �������� ����� ������� (��-��������� ���� ������)
              }
              // ����� �� ������� �������
              contourarea := cvContourArea(c, CV_WHOLE_SEQ);
              if (abs(contourarea) > MinFullArea) and (abs(contourarea) < MaxFullArea) then
              begin
                {$IFDEF DEBUG}
                //WriteLn(Format('[d3] Ratio: %s', [FloatToStr(IfThen(box.size.width < box.size.height, box.size.width/box.size.height, box.size.height/box.size.width))]));
                //WriteLn(Format('[d3] Full Contour Area: %s', [FloatToStr(abs(contourarea))]));
                //WriteLn('------------------------- ');
                cvRectangle(Ctx.MyOrigColorImage, cvPoint(Round(box.center.x-box.size.width/2),Round(box.center.y-box.size.height/2)), cvPoint(Round(box.center.x+box.size.width/2),Round(box.center.y+box.size.height/2)), CV_RGB(255,0,0), 2);
                {$ENDIF}
                // ����� �� ����������� ������� ������� � ������� ��������������
                if abs(contourarea) / (area) > MinFillArea then
                begin
                  WriteLn(Format('[i] Rect size: height=%s, width=%s', [FloatToStr(box.size.height),
                    FloatToStr(box.size.width)]));
                  WriteLn(Format('[i] Ratio: %s', [FloatToStr(ratio)]));
                  WriteLn(Format('[i] Full Contour Area: %s', [FloatToStr(abs(contourarea))]));
                  WriteLn(Format('[i] Contour Area: %s', [FloatToStr(abs(contourarea) / (area))]));
                  WriteLn('------------------------- ');
                  // SetLength(Ctx.MyCvBox2D, length(Ctx.MyCvBox2D)+1);
                  // Ctx.MyCvBox2D[length(Ctx.MyCvBox2D)+1] := box;
                  // SetLength(Ctx.MyArea, length(Ctx.MyArea)+1);
                  // Ctx.MyArea[length(Ctx.MyArea)+1] := cvContourArea(c, CV_WHOLE_SEQ);
                  // cvRectangle(Ctx.MyOrigColorImage, cvPoint(Round(box.center.x-box.size.width/2),Round(box.center.y-box.size.height/2)), cvPoint(Round(box.center.x+box.size.width/2),Round(box.center.y+box.size.height/2)), CV_RGB(255,255,0), 2);
                  { cvBoundingRect � ���������� �������������, ������� ����� ������� ������
                    points � ����� 2D-����� � ������������������ ��� ������ (CvMat) �����
                    update � ���� ����������:
                    0 (CvContour) � ������������� �� ��������������, � ������ �� ���� rect ��������� �������
                    1 (CvContour) � ������������� �������������� � ������������ � ���� rect ��������� �������
                    0 (CvSeq ��� CvMat) � ������������� �������������� � ������������
                    1 (CvSeq ��� CvMat) � ! ������ ����������!
                    ������� ���������� �������������, � �������� ������� ������ ����������� �
                    ������������� (����������� ��������(������� ���������) �����������).
                  }
                  rect := cvBoundingRect(c);
                  PlateNumber(Ctx, rect);
                  // SetLength(Ctx.MyCvRect, Length(Ctx.MyCvRect)+1);
                  // Ctx.MyCvRect[Length(Ctx.MyCvRect)+1] := rect;
                  cvRectangle(Ctx.MyOrigColorImage, cvPoint(rect.x, rect.y),
                    cvPoint(rect.x + rect.width, rect.y + rect.height), CV_RGB(255, 255, 0), 2);
                end;
              end;
            end;
          end;
        end;
      end;
      c := c.h_next;
    end;
    c := nil;
    FreeMem(c, SizeOf(TCvContour));
  end;
  contours := nil;
  FreeMem(contours, SizeOf(TCvContour));
  cvClearMemStorage(Ctx.MyStorage);
end;

// ������� �������� ����������� �� �������� ����
procedure RotateImage(var image: pIplImage; angle: Double = 90);
var
  rot_mat: pCvMat;
  scale: Double;
  temp: pIplImage;
  center: TcvPoint2D32f;
begin
  // ������� �������������
  rot_mat := cvCreateMat(2, 3, CV_32FC1);
  // �������� ������������ ������ �����������
  center.x := image.width div 2;
  center.y := image.height div 2;
  scale := 1;
  cv2DRotationMatrix(center, angle, scale, rot_mat);
  // ������� �����������
  temp := nil;
  temp := cvCreateImage(cvSize(image.width, image.height), image.depth, image.nChannels);
  // ��������� ��������
  cvWarpAffine(image, temp, rot_mat, CV_INTER_LINEAR or CV_WARP_FILL_OUTLIERS, cvScalarAll(0));
  // �������� �����������
  cvCopy(temp, image);
  // ����������� �������
  cvReleaseImage(temp);
  cvReleaseMat(rot_mat);
end;

procedure InitImageCapture(const Ctx: pCtx);
begin
  if FileExists(ImageFileCapture) then
  begin
    Ctx.MyInputImage := cvLoadImage(pAnsiChar(ImageFileCapture), CV_LOAD_IMAGE_GRAYSCALE);
    Ctx.MyOrigColorImage := cvLoadImage(pAnsiChar(ImageFileCapture));
    Ctx.MyThresholdImage := cvCreateImage(cvSize(Ctx.MyInputImage^.width, Ctx.MyInputImage^.height), IPL_DEPTH_8U, 1);
    WriteLn('[i] Start image capture ' + ImageFileCapture);
  end
  else
  begin
    WriteLn('[i] Error reading the image file ' + ImageFileCapture);
    Halt;
  end;
end;

procedure InitVideoCapture(const Ctx: pCtx);
var
  width: Double;
  height: Double;
  fps: Double;
begin
  if SourceCapture = 0 then // ������ ����� � ������
    Ctx.MyCapture := cvCreateCameraCapture(VideoCamNum)
  else if SourceCapture = 2 then // ������ ����� �� �����
  begin
    if FileExists(VideoFileCapture) then
    begin
      Ctx.MyCapture := cvCreateFileCapture(pAnsiChar(VideoFileCapture));
      WriteVideoCaptureToFile := 0;
    end
    else
    begin
      WriteLn('[i] Error reading the video file ' + VideoFileCapture);
      Halt;
    end;
  end;
  if not Assigned(Ctx.MyCapture) then
  begin
    WriteLn('[i] Error initializing video capture.');
    Halt;
  end;
  // ������������� ��������� ������� �����
  if (VideoCamWidth <> 0.0) or (VideoCamHeight <> 0.0) then
  begin
    cvSetCaptureProperty(Ctx.MyCapture, CV_CAP_PROP_FRAME_WIDTH, VideoCamWidth);
    cvSetCaptureProperty(Ctx.MyCapture, CV_CAP_PROP_FRAME_HEIGHT, VideoCamHeight);
    cvSetCaptureProperty(Ctx.MyCapture, CV_CAP_PROP_FPS, 25.0);
  end;
  // �������� ��c�� ������
  fps := cvGetCaptureProperty(Ctx.MyCapture, CV_CAP_PROP_FPS);
  // ������ ������ � ������ �����
  width := cvGetCaptureProperty(Ctx.MyCapture, CV_CAP_PROP_FRAME_WIDTH);
  height := cvGetCaptureProperty(Ctx.MyCapture, CV_CAP_PROP_FRAME_HEIGHT);
  // ������� ��������
  Ctx.MyOrigColorImage := cvCreateImage(cvSize(Round(width), Round(height)), IPL_DEPTH_8U, 1);
  Ctx.MyOrigColorImage := cvQueryFrame(Ctx.MyCapture);
  WriteLn('[i] Start video capture.');
  WriteLn(Format('[i] VideoCapture size: %.0f x %.0f', [width, height]));
  WriteLn(Format('[i] VideoCapture FPS: %.0f', [fps]));
  // ������� �����������
  Ctx.MyInputImage := cvCreateImage(cvSize(Ctx.MyOrigColorImage^.width, Ctx.MyOrigColorImage^.height), IPL_DEPTH_8U, 1);
  Ctx.MyThresholdImage := cvCreateImage(cvSize(Ctx.MyOrigColorImage^.width, Ctx.MyOrigColorImage^.height),
    IPL_DEPTH_8U, 1);
end;

procedure InitVideoWriter(const Ctx: pCtx);
var
  size: TCvSize;
  fps: Double;
begin
  // ������ ��������
  size := cvSize(Trunc(cvGetCaptureProperty(Ctx.MyCapture, CV_CAP_PROP_FRAME_WIDTH)),
    Trunc(cvGetCaptureProperty(Ctx.MyCapture, CV_CAP_PROP_FRAME_HEIGHT)));
  fps := 10; // cvGetCaptureProperty(Ctx.MyCapture, CV_CAP_PROP_FPS);
  WriteLn(Format('[i] VideoWriter size: %d x %d', [size.width, size.height]));
  WriteLn(Format('[i] VideoWriter FPS: %.0f', [fps]));
  WriteVideoFileName := IncludeTrailingPathDelimiter(WriteVideoCaptureFileDir) + FormatDateTime('ddmmyyyyhhmmss',
    Now) + '.avi';
  WriteLn(Format('[i] VideoWriter filename: %s', [WriteVideoFileName]));
  Ctx.MyWriter := cvCreateVideoWriter(pAnsiChar(WriteVideoFileName), CV_FOURCC('X', 'V', 'I', 'D'), fps, size, 1);
end;

procedure ImageFilterAndThreshold(const Ctx: pCtx);
var
  Kern: pIplConvKernel;
begin
  // ��������� ������������ ����������� (�����������) � �������������� ����������� �������.
  // max_value = 255 - ������������ �������� ������������ ������ � CV_THRESH_BINARY � CV_THRESH_BINARY_INV
  // adaptive_method = CV_ADAPTIVE_THRESH_MEAN_C - ����� CV_ADAPTIVE_THRESH_MEAN_C ��� CV_ADAPTIVE_THRESH_GAUSSIAN_C
  // threshold_type = CV_THRESH_BINARY ��� CV_THRESH_BINARY_INV
  // block_size = 15 - ������ ������������ �������, ������������ ��� ���������� ���������� ��������.
  // param1 = 0 - ��������, ��������� �� ������. ��� CV_ADAPTIVE_THRESH_MEAN_C � CV_ADAPTIVE_THRESH_GAUSSIAN_C ��� ���������, ���������� �� �������� ��������.
  if BinarizationMethod = 0 then
    cvAdaptiveThreshold(Ctx.MyInputImage, Ctx.MyThresholdImage, ThresholdMaxValue, CV_ADAPTIVE_THRESH_MEAN_C,
      CV_THRESH_BINARY, AdaptiveThresholdBlockSize, 0)
  else
    // ��������� ������������ ����������� (�����������) � �������������� ���������� ������.
    cvThreshold(Ctx.MyInputImage, Ctx.MyThresholdImage, Threshold, ThresholdMaxValue, CV_THRESH_BINARY_INV);
  Kern := cvCreateStructuringElementEx(Radius * 2 + 1, Radius * 2 + 1, Radius, Radius, CV_SHAPE_RECT);
  if EnableErode = 1 then
    cvErode(Ctx.MyThresholdImage, Ctx.MyThresholdImage, Kern, 1);  // ������
  if EnableDilate = 1 then
  cvDilate(Ctx.MyThresholdImage, Ctx.MyThresholdImage, Kern, 1); // ���������
end;

procedure VideoFilterAndThreshold(const Ctx: pCtx);
var
  Kern: pIplConvKernel;
begin
  cvCvtColor(Ctx.MyOrigColorImage, Ctx.MyInputImage, CV_BGR2GRAY);
  // ��������� ������������ ����������� (�����������) � �������������� ����������� �������.
  // max_value = 255 - ������������ �������� ������������ ������ � CV_THRESH_BINARY � CV_THRESH_BINARY_INV
  // adaptive_method = CV_ADAPTIVE_THRESH_MEAN_C - ����� CV_ADAPTIVE_THRESH_MEAN_C ��� CV_ADAPTIVE_THRESH_GAUSSIAN_C
  // threshold_type = CV_THRESH_BINARY ��� CV_THRESH_BINARY_INV
  // block_size = 15 - ������ ������������ �������, ������������ ��� ���������� ���������� ��������.
  // param1 = 0 - ��������, ��������� �� ������. ��� CV_ADAPTIVE_THRESH_MEAN_C � CV_ADAPTIVE_THRESH_GAUSSIAN_C ��� ���������, ���������� �� �������� ��������.
  if BinarizationMethod = 0 then
    cvAdaptiveThreshold(Ctx.MyInputImage, Ctx.MyThresholdImage, ThresholdMaxValue, CV_ADAPTIVE_THRESH_MEAN_C,
      CV_THRESH_BINARY, AdaptiveThresholdBlockSize, 0)
  else
    // ��������� ������������ ����������� (�����������) � �������������� ���������� ������.
    cvThreshold(Ctx.MyInputImage, Ctx.MyThresholdImage, Threshold, ThresholdMaxValue, CV_THRESH_BINARY_INV);
  Kern := cvCreateStructuringElementEx(Radius * 2 + 1, Radius * 2 + 1, Radius, Radius, CV_SHAPE_RECT);
  if EnableErode = 1 then
    cvErode(Ctx.MyThresholdImage, Ctx.MyThresholdImage, Kern, 1);  // ������
  if EnableDilate = 1 then
  cvDilate(Ctx.MyThresholdImage, Ctx.MyThresholdImage, Kern, 1); // ���������
end;

procedure InitCtx(const Ctx: pCtx);
begin
  // ������� ���������
  Ctx.MyStorage := cvCreateMemStorage(0);
end;

procedure ClearRes(const Ctx: pCtx);
begin
  // ����������� �������
  if SourceCapture = 0 then
  begin
    if Assigned(Ctx.MyCapture) then
      cvReleaseCapture(Ctx.MyCapture);
    if Assigned(Ctx.MyWriter) then
      cvReleaseVideoWriter(Ctx.MyWriter);
  end;
  cvReleaseImage(Ctx.MyInputImage);
  cvReleaseImage(Ctx.MyThresholdImage);
  if Assigned(Ctx.MyPlateNumberImage) then
    cvReleaseImage(Ctx.MyPlateNumberImage);
  cvReleaseMemStorage(Ctx.MyStorage);
  cvDestroyAllWindows();
end;

procedure InitWindows(const Ctx: pCtx);
begin
  if SourceCapture = 1 then
    cvNamedWindow(WindowNameOriginal, CV_WINDOW_AUTOSIZE);
  cvNamedWindow(WindowNameThreshold, CV_WINDOW_AUTOSIZE);
  cvNamedWindow(WindowNameCarsNumber, CV_WINDOW_AUTOSIZE);
  cvNamedWindow(WindowNamePlateNum, CV_WINDOW_AUTOSIZE);
  // �����c��� ���� �� �������� c����
  if (Ctx.MyInputImage.width < 1920 / 4) and (Ctx.MyInputImage.height < 1080 / 2) then
  begin
    if SourceCapture = 1 then
    begin
      cvMoveWindow(WindowNameOriginal, 0, 0);
      cvMoveWindow(WindowNameThreshold, Ctx.MyInputImage.width + 10, 0);
      cvMoveWindow(WindowNameCarsNumber, 0, Ctx.MyInputImage.height + 35);
    end
    else
    begin
      cvMoveWindow(WindowNameThreshold, 0, 0);
      cvMoveWindow(WindowNameCarsNumber, Ctx.MyInputImage.width + 10, 0);
    end;
  end;
end;

procedure ShowWindow(const Ctx: pCtx);
begin
  // ������������ �����������
  if RotateImageAngle > 0 then
  begin
    RotateImage(MyCtx.MyOrigColorImage, RotateImageAngle);
    RotateImage(MyCtx.MyThresholdImage, RotateImageAngle);
    if SourceCapture = 1 then
      RotateImage(MyCtx.MyInputImage, RotateImageAngle);
  end;
  // ���������� �������� �����������
  if SourceCapture = 1 then
    cvShowImage(WindowNameOriginal, MyCtx.MyInputImage);
  // ���������� ��������������� �����������
  cvShowImage(WindowNameThreshold, MyCtx.MyThresholdImage);
  // ���������� ��� ��������c�
  cvShowImage(WindowNameCarsNumber, MyCtx.MyOrigColorImage);
  // ���������� ��� �����
  cvShowImage(WindowNamePlateNum, Ctx.MyPlateNumberImage);
end;

// ��������� ���������
procedure InitSettings(inipath: WideString);
var
  fullininame: WideString;
  INI: TIniFile;
begin
  // ��������� ������� ��������
  if not DirectoryExists(inipath) then
  begin
    try
      CreateDir(inipath);
    except
      on e: Exception do
        WriteLn('Exception in procedure InitSettings: Unable to create directory ' + inipath);
    end;
  end;
  fullininame := inipath + filename_ini;
  if FileExists(fullininame) then
  begin
    INI := TIniFile.Create(fullininame);
    try
      // 0 - VideoCam, 1 - ImageFile, 2 - VideoFile
      SourceCapture := INI.ReadInteger('Main', 'SourceCapture', 0);
      VideoCamNum := INI.ReadInteger('Main', 'VideoCamNum', 0);
      VideoCamWidth := INI.ReadFloat('Main', 'VideoCamWidth', 0.0);
      VideoCamHeight := INI.ReadFloat('Main', 'VideoCamWidth', 0.0);
      ImageFileCapture := INI.ReadString('Main', 'ImageFileCapture', 'Resource\CarNom1.jpg');
      VideoFileCapture := INI.ReadString('Main', 'VideoFileCapture', 'Resource\CarNom.avi');
      RotateImageAngle := INI.ReadInteger('Main', 'RotateImageAngle', 0);
      WriteVideoCaptureToFile := INI.ReadInteger('Main', 'WriteVideoCaptureToFile', 0);
      WriteVideoCaptureFileDir := INI.ReadString('Main', 'WriteVideoCaptureFileDir', ExtractFilePath(ParamStr(0)));
      if WriteVideoCaptureFileDir = '' then
        WriteVideoCaptureFileDir := ExtractFilePath(ParamStr(0));
      // 0 - cvAdaptiveThreshold, 1 - cvThreshold
      BinarizationMethod := INI.ReadInteger('Main', 'BinarizationMethod', 0);
      AdaptiveThresholdBlockSize := INI.ReadInteger('Main', 'AdaptiveThresholdBlockSize', 15);
      Threshold := INI.ReadInteger('Main', 'Threshold', 128);
      ThresholdMaxValue := INI.ReadInteger('Main', 'ThresholdMaxValue', 255);
      MinRatio := INI.ReadFloat('Main', 'MinRatio', 0.15);
      MaxRatio := INI.ReadFloat('Main', 'MaxRatio', 0.5);
      MinArea := INI.ReadInteger('Main', 'MinArea', 500);
      MaxArea := INI.ReadInteger('Main', 'MaxArea', 25000);
      MinFullArea := INI.ReadInteger('Main', 'MinFullArea', 800);
      MaxFullArea := INI.ReadInteger('Main', 'MaxFullArea', 7000);
      MinFillArea := INI.ReadFloat('Main', 'MinFillArea', 0.7);
      EnableErode := INI.ReadInteger('Main', 'EnableErode', 1);
      EnableDilate := INI.ReadInteger('Main', 'EnableDilate', 1);
    finally
      INI.Free;
    end;
  end
  else
  begin
    INI := TIniFile.Create(fullininame);
    try
      SourceCapture := 0;
      VideoCamNum := 0;
      VideoCamWidth := 0.0;
      VideoCamHeight := 0.0;
      ImageFileCapture := 'Resource\CarNom1.jpg';
      VideoFileCapture := 'Resource\CarNom.avi';
      WriteVideoCaptureFileDir := ExtractFilePath(ParamStr(0));
      RotateImageAngle := 0;
      WriteVideoCaptureToFile := 0;
      BinarizationMethod := 0;
      AdaptiveThresholdBlockSize := 15;
      Threshold := 128;
      ThresholdMaxValue := 255;
      MinRatio := 0.15;
      MaxRatio := 0.5;
      MinArea := 500;
      MaxArea := 25000;
      MinFullArea := 800;
      MaxFullArea := 7000;
      MinFillArea := 0.7;
      EnableErode := 1;
      EnableDilate := 1;
      // ��������� ���������
      INI.WriteInteger('Main', 'SourceCapture', SourceCapture);
      INI.WriteInteger('Main', 'VideoCamNum', VideoCamNum);
      INI.WriteFloat('Main', 'VideoCamWidth', VideoCamWidth);
      INI.WriteFloat('Main', 'VideoCamWidth', VideoCamHeight);
      INI.WriteString('Main', 'ImageFileCapture', ImageFileCapture);
      INI.WriteString('Main', 'VideoFileCapture', VideoFileCapture);
      INI.WriteInteger('Main', 'RotateImageAngle', RotateImageAngle);
      INI.WriteInteger('Main', 'WriteVideoCaptureToFile', WriteVideoCaptureToFile);
      INI.WriteString('Main', 'WriteVideoCaptureFileDir', WriteVideoCaptureFileDir);
      INI.WriteInteger('Main', 'BinarizationMethod', BinarizationMethod);
      INI.WriteInteger('Main', 'AdaptiveThresholdBlockSize', AdaptiveThresholdBlockSize);
      INI.WriteInteger('Main', 'Threshold', Threshold);
      INI.WriteInteger('Main', 'ThresholdMaxValue', ThresholdMaxValue);
      INI.WriteFloat('Main', 'MinRatio', MinRatio);
      INI.WriteFloat('Main', 'MaxRatio', MaxRatio);
      INI.WriteInteger('Main', 'MinArea', MinArea);
      INI.WriteInteger('Main', 'MaxArea', MaxArea);
      INI.WriteInteger('Main', 'MinFullArea', MinFullArea);
      INI.WriteInteger('Main', 'MaxFullArea', MaxFullArea);
      INI.WriteFloat('Main', 'MinFillArea', MinFillArea);
      INI.WriteInteger('Main', 'EnableErode', EnableErode);
      INI.WriteInteger('Main', 'EnableDilate', EnableDilate);
    finally
      INI.Free;
    end;
  end;
end;

begin
  try
    MyCtx := AllocMem(SizeOf(TCtx));
    InitSettings(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))));
    InitCtx(MyCtx);
    // ������ �� ����� ��������
    if SourceCapture = 1 then
    begin
      InitImageCapture(MyCtx);
      InitWindows(MyCtx);
      // ���������
      ImageFilterAndThreshold(MyCtx);
      // ����� ������
      // 0.15 � 0.5 - ���. � ����. ����������� ������
      // 500 � 25000 - ���. � ����. �������
      // 800 � 7000 - ���. � ����.
      // 0.7 - ���. ����������� ������� ������� � ������� ��������������
      FindBox(MyCtx, MinRatio, MaxRatio, MinArea, MaxArea, MinFullArea, MaxFullArea, MinFillArea);
      // ���������� ���������
      ShowWindow(MyCtx);
      // ��� ������� �������
      cvWaitKey(0);
    end
    else // ������ ����� � ������ ��� �� �����
    begin
      InitVideoCapture(MyCtx);
      InitWindows(MyCtx);
      if WriteVideoCaptureToFile = 1 then
        InitVideoWriter(MyCtx);
      while true do
      begin
        MyCtx.MyOrigColorImage := cvQueryFrame(MyCtx.MyCapture);
        if MyCtx.MyOrigColorImage = nil then
          Break;
        // ���������
        VideoFilterAndThreshold(MyCtx);
        // ����� ������
        // 0.15 � 0.5 - ���. � ����. ����������� ������
        // 500 � 25000 - ���. � ����. �������
        // 800 � 7000 - ���. � ����. ������� �������
        // 0.7 - ���. ����������� ������� ������� � ������� ��������������
        FindBox(MyCtx, MinRatio, MaxRatio, MinArea, MaxArea, MinFullArea, MaxFullArea, MinFillArea);
        // ���������� ���������
        ShowWindow(MyCtx);
        // ��������� � ����
        if Assigned(MyCtx.MyWriter) then
          cvWriteFrame(MyCtx.MyWriter, MyCtx.MyOrigColorImage);
        Key := cvWaitKey(33);
        if (Key = 27) then
          Break;
      end;
    end;
    // ������� ��������
    ClearRes(MyCtx);
    FreeMem(MyCtx, SizeOf(TCtx));
  except
    on e: Exception do
      WriteLn(e.ClassName, ': ', e.Message);
  end;

end.
