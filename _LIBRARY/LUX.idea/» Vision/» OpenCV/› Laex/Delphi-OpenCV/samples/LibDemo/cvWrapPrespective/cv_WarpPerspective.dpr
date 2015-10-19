//*****************************************************************
  //                       Delphi-OpenCV Demo
  //               Copyright (C) 2013 Project Delphi-OpenCV
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
  //*******************************************************************

program cv_WarpPerspective;

{$APPTYPE CONSOLE}
{$POINTERMATH ON}
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
  filename = cResourceMedia + 'opencv_logo_with_text.png';

var
  src: pIplImage = nil;
  dst: pIplImage = nil;
  srcQuad, dstQuad: pCvPoint2D32f;
  warp_matrix: pCvMat;

begin
  try
    // �������� �������� (� ��������� c�����)
    src := cvLoadImage(filename, CV_LOAD_IMAGE_GRAYSCALE);
    WriteLn(Format('[i] image: %s', [filename]));

    cvNamedWindow('Original', CV_WINDOW_AUTOSIZE);
    cvShowImage('Original', src);

    // ������� ��������������
    warp_matrix := cvCreateMat(3, 3, CV_32FC1);

    // ��������� ��������
    dst := cvCloneImage(src);

    // ����� �����
    srcQuad := AllocMem(SizeOf(TCvPoint2D32f) * 4);
    dstQuad := AllocMem(SizeOf(TCvPoint2D32f) * 4);
    srcQuad[0].x := 0; // src Top left
    srcQuad[0].y := 0;
    srcQuad[1].x := src.width - 1; // src Top right
    srcQuad[1].y := 0;
    srcQuad[2].x := 0; // src Bottom left
    srcQuad[2].y := src.height - 1;
    srcQuad[3].x := src.width - 1; // src Bot right
    srcQuad[3].y := src.height - 1;
    // - - - - - - - - - - - - - -//
    dstQuad[0].x := src.width * 0.05; // dst Top left
    dstQuad[0].y := src.height * 0.33;
    dstQuad[1].x := src.width * 0.9; // dst Top right
    dstQuad[1].y := src.height * 0.25;
    dstQuad[2].x := src.width * 0.2; // dst Bottom left
    dstQuad[2].y := src.height * 0.7;
    dstQuad[3].x := src.width * 0.8; // dst Bot right
    dstQuad[3].y := src.height * 0.9;

    // �������� ������� ��������������
    cvGetPerspectiveTransform(srcQuad, dstQuad, warp_matrix);
    // �������������� ���c�������
    // CV_WARP_INVERSE_MAP � �c��������c� �������� ����c�������� �� dst � src
    // CV_WARP_FILL_OUTLIERS � ��������� �c� ���c��� �������� ����������� (�c�� ���c��� ��c��c����� �� �c������ ���������� �c��������c� fillval)
    // fillval � �������� ��� ���������� ���c���� ��� �c������� �����������
    cvWarpPerspective(src, dst, warp_matrix, CV_INTER_LINEAR or CV_WARP_FILL_OUTLIERS, cvScalarAll(0));

    // ����������
    cvNamedWindow('WarpPerspective', CV_LOAD_IMAGE_GRAYSCALE);
    cvShowImage('WarpPerspective', dst);

    // ��� ������� �������
    cvWaitKey(0);

    // �c��������� ��c��c�
    FreeMem(srcQuad);
    FreeMem(dstQuad);
    cvReleaseImage(src);
    cvReleaseImage(dst);
    cvReleaseMat(warp_matrix);
    cvDestroyAllWindows();
  except
    on E: Exception do
      WriteLn(E.ClassName, ': ', E.Message);
  end;

end.
