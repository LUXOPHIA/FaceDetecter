(*
  *****************************************************************
  Delphi-OpenCV Demo
  Copyright (C) 2013 Project Delphi-OpenCV
  ****************************************************************
  Contributor:
  Laentir Valetov
  email:laex@bk.ru
  ****************************************************************
  You may retrieve the latest version of this file at the GitHub,
  located at git://github.com/Laex/Delphi-OpenCV.git
  ****************************************************************
  The contents of this file are used with permission, subject to
  the Mozilla Public License Version 1.1 (the "License"); you may
  not use this file except in compliance with the License. You may
  obtain a copy of the License at
  http://www.mozilla.org/MPL/MPL-1_1Final.html

  Software distributed under the License is distributed on an
  "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
  implied. See the License for the specific language governing
  rights and limitations under the License.
  *******************************************************************
*)

program cv_MatchShapes;

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
  const_original = cResourceMedia + 'matchshapes2.jpg';
  const_template = cResourceMedia + 'matchshapes_template.jpg';

var
  original: pIplImage = nil;
  template: pIplImage = nil;
  original_filename, template_filename: AnsiString;

  src: pIplImage = nil;
  dst: pIplImage = nil;
  binI: pIplImage = nil;
  binT: pIplImage = nil;
  rgb: pIplImage = nil;
  rgbT: pIplImage = nil;
  storageI: pCvMemStorage = nil;
  storageT: pCvMemStorage = nil;
  contoursI: pCvSeq = nil;
  contoursT: pCvSeq = nil;
  seq0: pCvSeq = nil;
  seqT: pCvSeq = nil;
  seqM: pCvSeq = nil;
  contoursCont: integer;
  font: TCvFont;
  counter: integer;
  perim, match0: double;
  perimT: double = 0;
  matchM: double = 1000;

begin
  try
    // ������ �������� ��������� �c������ ��������, ������ - ������ ���c��
    if ParamCount = 2 then
    begin
      original_filename := AnsiString(ParamStr(1));
      template_filename := AnsiString(ParamStr(2));
    end
    else
    begin
      original_filename := const_original;
      template_filename := const_template;
    end;

    // �������� ��������
    original := cvLoadImage(pCVChar(original_filename), CV_LOAD_IMAGE_COLOR);
    WriteLn(Format('[i] original image: %s', [original_filename]));

    // �������� �������� �������
    template := cvLoadImage(pCVChar(template_filename), CV_LOAD_IMAGE_COLOR);
    WriteLn(Format('[i] template image: %s', [template_filename]));

    // ������� ���� �����������
    cvNamedWindow('Original', CV_WINDOW_AUTOSIZE);
    cvShowImage('Original', original);
    cvNamedWindow('Template', CV_WINDOW_AUTOSIZE);
    cvShowImage('Template', template);

    // C��������
    WriteLn('[i] Run test cvMatchShapes()');

    // ��������� ��������
    src := cvCloneImage(original);

    // c����� ������������� ��������
    binI := cvCreateImage(cvGetSize(src), IPL_DEPTH_8U, 1);
    binT := cvCreateImage(cvGetSize(template), IPL_DEPTH_8U, 1);

    // ������ ������� ��������
    rgb := cvCreateImage(cvGetSize(original), IPL_DEPTH_8U, 3);
    cvConvertImage(src, rgb, CV_GRAY2BGR);
    rgbT := cvCreateImage(cvGetSize(template), IPL_DEPTH_8U, 3);
    cvConvertImage(template, rgbT, CV_GRAY2BGR);

    // �������� ������� ����������� � �������
    cvCanny(src, binI, 50, 200);
    cvCanny(template, binT, 50, 200);

    // ����������
    // cvNamedWindow('CannyI', CV_WINDOW_AUTOSIZE);
    // cvShowImage('CannyI', binI);
    // cvNamedWindow('CannyT', CV_WINDOW_AUTOSIZE);
    // cvShowImage('CannyT', binT);

    // c������ ���������
    storageI := cvCreateMemStorage(0);

    // ������� �������
    contoursCont := cvFindContours(binI, storageI, @contoursI, sizeof(TCvContour), CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE, cvPoint(0, 0));

    // ��� ������� ��������
    cvInitFont(@font, CV_FONT_HERSHEY_PLAIN, 1.0, 1.0);

    // ����c��� ������� �����������
    if Assigned(contoursI) then
    begin
      // ��c��� ������
      seq0 := contoursI;
      while Assigned(seq0) do
      begin
        cvDrawContours(rgb, seq0, CV_RGB(255, 216, 0), CV_RGB(0, 0, 250), 0, 1, 8, cvPoint(0, 0));
        seq0 := seq0.h_next;
      end;
    end;

    // ����������
    // cvNamedWindow('Cont', CV_WINDOW_AUTOSIZE);
    // cvShowImage('Cont', rgb );

    cvConvertImage(src, rgb, CV_GRAY2BGR);

    // ������� ������� �������
    storageT := cvCreateMemStorage(0);
    cvFindContours(binT, storageT, @contoursT, sizeof(TCvContour), CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE, cvPoint(0, 0));

    if Assigned(contoursT) then
    begin
      // ������� c���� ������� ������
      seq0 := contoursT;
      while Assigned(seq0) do
      begin
        perim := cvContourPerimeter(seq0);
        if perim > perimT then
        begin
          perimT := perim;
          seqT := seq0;
        end;
        // ��c���
        cvDrawContours(rgbT, seq0, CV_RGB(255, 216, 0), CV_RGB(0, 0, 250), 0, 1, 8, cvPoint(0, 0));
        seq0 := seq0.h_next;
      end;
    end;
    // ������� ������ �������
    cvDrawContours(rgbT, seqT, CV_RGB(52, 201, 36), CV_RGB(36, 201, 197), 0, 2, 8, cvPoint(0, 0));
    // cvNamedWindow('ContT', CV_WINDOW_AUTOSIZE);
    // cvShowImage('ContT', rgbT);

    // ������� ������� �����������
    counter := 0;
    if Assigned(contoursI) then
    begin
      // ���c� ������� c��������� �������� �� �� ��������
      seq0 := contoursI;
      while Assigned(seq0) do
      begin
        WriteLn('Assigned seq0: ',Assigned(seq0),'(',IntToHex(Integer(seq0),8),')');
        WriteLn('Assigned seqT: ',Assigned(seqT),'(',IntToHex(Integer(seqT),8),')');
        match0 := cvMatchShapes(seq0, seqT, CV_CONTOURS_MATCH_I3);
        if match0 < matchM then
        begin
          matchM := match0;
          seqM := seq0;
        end;
        Inc(counter);
        WriteLn(Format('[i] %d match: %.2f', [counter, match0]));
        seq0 := seq0.h_next;
      end;
    end;
    // ��c��� ��������� ������
    cvDrawContours(rgb, seqM, CV_RGB(52, 201, 36), CV_RGB(36, 201, 197), 0, 2, 8, cvPoint(0, 0));
    cvNamedWindow('Find', CV_WINDOW_AUTOSIZE);
    cvShowImage('Find', rgb);

    // ��� ������� �������
    cvWaitKey(0);

    // �c��������� ��c��c�
    cvReleaseMemStorage(storageI);
    cvReleaseMemStorage(storageT);
    cvReleaseImage(src);
    cvReleaseImage(dst);
    cvReleaseImage(rgb);
    cvReleaseImage(rgbT);
    cvReleaseImage(binI);
    cvReleaseImage(binT);

    // ������� ����
    cvDestroyAllWindows();

    // �c��������� ��c��c�
    cvReleaseImage(original);
    cvReleaseImage(template);
    // ������� �c� ����
    cvDestroyAllWindows();
  except
    on E: Exception do
      WriteLn(E.ClassName, ': ', E.Message);
  end;

end.
