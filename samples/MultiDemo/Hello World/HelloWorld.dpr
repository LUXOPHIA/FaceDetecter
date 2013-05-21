(* /*****************************************************************
  //                       Delphi-OpenCV Demo
  //               Copyright (C) 2013 Project Delphi-OpenCV
  // ****************************************************************
  // Contributor:
  // laentir Valetov
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
  ******************************************************************* *)
// JCL_DEBUG_EXPERT_GENERATEJDBG OFF
// JCL_DEBUG_EXPERT_INSERTJDBG OFF
// JCL_DEBUG_EXPERT_DELETEMAPFILE OFF
program HelloWorld;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  uLibName in '..\..\..\include\uLibName.pas',
  highgui_c in '..\..\..\include\highgui\highgui_c.pas',
  core_c in '..\..\..\include\core\core_c.pas',
  Core.types_c in '..\..\..\include\core\Core.types_c.pas',
  imgproc.types_c in '..\..\..\include\imgproc\imgproc.types_c.pas',
  imgproc_c in '..\..\..\include\imgproc\imgproc_c.pas',
  legacy in '..\..\..\include\legacy\legacy.pas',
  calib3d in '..\..\..\include\calib3d\calib3d.pas',
  imgproc in '..\..\..\include\imgproc\imgproc.pas',
  haar in '..\..\..\include\objdetect\haar.pas',
  objdetect in '..\..\..\include\objdetect\objdetect.pas',
  tracking in '..\..\..\include\video\tracking.pas',
  Core in '..\..\..\include\core\core.pas',
  Mat in '..\..\..\include\core\Mat.pas',
  core.types in '..\..\..\include\core\core.types.pas',
  cvUtils in '..\..\..\include\cvUtils.pas';

var
  // ����� ��c��� � ������ ��������
  height: Integer = 620;
  width: Integer = 440;
  pt: TCvPoint;
  hw: pIplImage;
  font: TCvFont;

begin
  try
    // ����� ����� ��� ������ ���c��
    pt := CvPoint(height div 4, width div 2);
    // c����� 8-������, 3-��������� ��������
    hw := cvCreateImage(CvSize(height, width), 8, 3);
    // �������� �������� ������ ������
    CvSet(pCvArr(hw), cvScalar(0, 0, 0));
    // ������������� ������
    cvInitFont(@font, CV_FONT_HERSHEY_COMPLEX, 1.0, 1.0, 0, 1, CV_AA);
    // �c������� ����� ������� �� �������� ���c�
    cvPutText(hw, 'OpenCV Step By Step', pt, @font, CV_RGB(150, 0, 150));
    // c����� ������
    cvNamedWindow('Hello World', 0);
    // ���������� �������� � c�������� ����
    cvShowImage('Hello World', hw);
    // ��� ������� �������
    cvWaitKey(0);
    // �c��������� ��c��c�
    cvReleaseImage(hw);
    cvDestroyWindow('Hello World');
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
