// *****************************************************************
// Delphi-OpenCV Demo
// Copyright (C) 2013 Project Delphi-OpenCV
// ****************************************************************
// Contributor:
  // Laentir Valetov
// email:laex@bk.ru
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
// *******************************************************************

program cv_CvtPixToPlane;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  ocv.highgui_c,
  ocv.core_c,
  ocv.core.types_c,
  ocv.imgproc_c,
  ocv.imgproc.types_c,
  uResourcePaths;

const
  filename = cResourceMedia + 'roulette-wheel2-small.jpg';

var
  image: pIplImage = nil;
  dst: pIplImage = nil;

  // ��� �������� ������� HSV
  hsv: pIplImage = nil;
  h_plane: pIplImage = nil;
  s_plane: pIplImage = nil;
  v_plane: pIplImage = nil;
  // ��� �������� ������� HSV ��c�� ��������������
  h_range: pIplImage = nil;
  s_range: pIplImage = nil;
  v_range: pIplImage = nil;
  // ��� �������� c�������� ��������
  hsv_and: pIplImage = nil;

  Hmin: Integer = 0;
  Hmax: Integer = 256;

  Smin: Integer = 0;
  Smax: Integer = 256;

  Vmin: Integer = 0;
  Vmax: Integer = 256;

  HSVmax: Integer = 256;

  //
  // �������-����������� ���������
  //
procedure myTrackbarHmin(pos: Integer); cdecl;
begin
  Hmin := pos;
  cvInRangeS(h_plane, cvScalar(Hmin), cvScalar(Hmax), h_range);
end;

procedure myTrackbarHmax(pos: Integer); cdecl;
begin
  Hmax := pos;
  cvInRangeS(h_plane, cvScalar(Hmin), cvScalar(Hmax), h_range);
end;

procedure myTrackbarSmin(pos: Integer); cdecl;
begin
  Smin := pos;
  cvInRangeS(s_plane, cvScalar(Smin), cvScalar(Smax), s_range);
end;

procedure myTrackbarSmax(pos: Integer); cdecl;
begin
  Smax := pos;
  cvInRangeS(s_plane, cvScalar(Smin), cvScalar(Smax), s_range);
end;

procedure myTrackbarVmin(pos: Integer); cdecl;
begin
  Vmin := pos;
  cvInRangeS(v_plane, cvScalar(Vmin), cvScalar(Vmax), v_range);
end;

procedure myTrackbarVmax(pos: Integer); cdecl;
begin
  Vmax := pos;
  cvInRangeS(v_plane, cvScalar(Vmin), cvScalar(Vmax), v_range);
end;

Var
  framemin, framemax: Double;
  c: Integer;

begin
  try
    // �������� ��������
    image := cvLoadImage(filename, 1);
    WriteLn(Format('[i] image: %s', [filename]));

    // c����� ��������
    hsv := cvCreateImage(cvGetSize(image), IPL_DEPTH_8U, 3);
    h_plane := cvCreateImage(cvGetSize(image), IPL_DEPTH_8U, 1);
    s_plane := cvCreateImage(cvGetSize(image), IPL_DEPTH_8U, 1);
    v_plane := cvCreateImage(cvGetSize(image), IPL_DEPTH_8U, 1);
    h_range := cvCreateImage(cvGetSize(image), IPL_DEPTH_8U, 1);
    s_range := cvCreateImage(cvGetSize(image), IPL_DEPTH_8U, 1);
    v_range := cvCreateImage(cvGetSize(image), IPL_DEPTH_8U, 1);
    hsv_and := cvCreateImage(cvGetSize(image), IPL_DEPTH_8U, 1);
    // ������������ � HSV
    cvCvtColor(image, hsv, CV_BGR2HSV);
    // ��������� �� �������� ������
    cvCvtPixToPlane(hsv, h_plane, s_plane, v_plane, 0);

    //
    // ���������� ����������� � ���c�������� ��������
    // � ������� HSV
    framemin := 0;
    framemax := 0;

    cvMinMaxLoc(h_plane, @framemin, @framemax);
    WriteLn(Format('[H] %f x %f', [framemin, framemax]));
    Hmin := Trunc(framemin);
    Hmax := Trunc(framemax);
    cvMinMaxLoc(s_plane, @framemin, @framemax);
    WriteLn(Format('[S] %f x %f', [framemin, framemax]));
    Smin := Trunc(framemin);
    Smax := Trunc(framemax);
    cvMinMaxLoc(v_plane, @framemin, @framemax);
    WriteLn(Format('[V] %f x %f', [framemin, framemax]));
    Vmin := Trunc(framemin);
    Vmax := Trunc(framemax);

    // ���� ��� ����������� ��������
    cvNamedWindow('original', CV_WINDOW_AUTOSIZE);
    cvNamedWindow('H', CV_WINDOW_AUTOSIZE);
    cvNamedWindow('S', CV_WINDOW_AUTOSIZE);
    cvNamedWindow('V', CV_WINDOW_AUTOSIZE);
    cvNamedWindow('H range', CV_WINDOW_AUTOSIZE);
    cvNamedWindow('S range', CV_WINDOW_AUTOSIZE);
    cvNamedWindow('V range', CV_WINDOW_AUTOSIZE);
    cvNamedWindow('hsv and', CV_WINDOW_AUTOSIZE);

    cvCreateTrackbar('Hmin', 'H range', @Hmin, HSVmax, myTrackbarHmin);
    cvCreateTrackbar('Hmax', 'H range', @Hmax, HSVmax, myTrackbarHmax);
    cvCreateTrackbar('Smin', 'S range', @Smin, HSVmax, myTrackbarSmin);
    cvCreateTrackbar('Smax', 'S range', @Smax, HSVmax, myTrackbarSmax);
    cvCreateTrackbar('Vmin', 'V range', @Vmin, HSVmax, myTrackbarVmin);
    cvCreateTrackbar('Vmax', 'V range', @Vmax, HSVmax, myTrackbarVmax);

    //
    // �����c��� ���� �� �������� c����
    //
    if (image^.width < 1920 / 4) and (image^.height < 1080 / 2) then
    begin
      cvMoveWindow('original', 0, 0);
      cvMoveWindow('H', image^.width + 10, 0);
      cvMoveWindow('S', (image^.width + 10) * 2, 0);
      cvMoveWindow('V', (image^.width + 10) * 3, 0);
      cvMoveWindow('hsv and', 0, image^.height + 30);
      cvMoveWindow('H range', image^.width + 10, image^.height + 30);
      cvMoveWindow('S range', (image^.width + 10) * 2, image^.height + 30);
      cvMoveWindow('V range', (image^.width + 10) * 3, image^.height + 30);
    end;

    while true do
    begin

      // ���������� ��������
      cvShowImage('original', image);

      cvShowImage('H', h_plane);
      cvShowImage('S', s_plane);
      cvShowImage('V', v_plane);

      cvShowImage('H range', h_range);
      cvShowImage('S range', s_range);
      cvShowImage('V range', v_range);

      // c���������
      cvAnd(h_range, s_range, hsv_and);
      cvAnd(hsv_and, v_range, hsv_and);

      cvShowImage('hsv and', hsv_and);

      c := cvWaitKey(33);
      if (c = 27) then // �c�� ������ ESC - �������
        break;
    end;

    WriteLn('[i] Results:');
    WriteLn(Format('[H] %d x %d', [Hmin, Hmax]));
    WriteLn(Format('[S] %d x %d', [Smin, Smax]));
    WriteLn(Format('[V] %d x %d', [Vmin, Vmax]));

    // �c��������� ��c��c�
    cvReleaseImage(image);
    cvReleaseImage(hsv);
    cvReleaseImage(h_plane);
    cvReleaseImage(s_plane);
    cvReleaseImage(v_plane);
    cvReleaseImage(h_range);
    cvReleaseImage(s_range);
    cvReleaseImage(v_range);
    cvReleaseImage(hsv_and);
    // ������� ����
    cvDestroyAllWindows();
  except
    on E: Exception do
      WriteLn(E.ClassName, ': ', E.Message);
  end;

end.
