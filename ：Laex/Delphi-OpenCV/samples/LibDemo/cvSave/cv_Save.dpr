
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

program cv_Save;

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
  kernet_filename = cResourceResultDefault + 'kernel.xml';

var
  kernel: array [0 .. 8] of Single;
  kernel_matrix: TCvMat;
  i: Integer;
  j: Integer;
  matrix: pCvMat;
  ptr: pSingle;
  fs: pCvFileStorage;
  frame_count: Integer;
  s: pCvSeq;
  frame_width: Integer;
  frame_height: Integer;
  color_cvt_matrix: pCvMat;

begin
  try
    // �ccc��, c��������� ������ �������
    kernel[0] := 1;
    kernel[1] := 0;
    kernel[2] := 0;
    kernel[3] := 0;
    kernel[4] := 2;
    kernel[5] := 0;
    kernel[6] := 0;
    kernel[7] := 0;
    kernel[8] := 3;
    // c����� �������
    kernel_matrix := cvMat(3, 3, CV_32FC1, @kernel);
    // c�������� ������� � XML-����
    cvSave(kernet_filename, @kernel_matrix);
    // � ������ �������� ������ �� XML-�����
    matrix := pCvMat(cvLoad(kernet_filename));
    // ������� c��������� �������
    // 1 �������: c �c������������ �����c� CV_MAT_ELEM
    for i := 0 to matrix^.rows - 1 do
    begin
      for j := 0 to matrix^.cols - 1 do
        Write(Format('%.0f ', [pSingle(CV_MAT_ELEM(matrix^, SizeOf(single), i, j))^]));
      Writeln;
    end;
    Writeln;

    // 2 �������: c �c������������ cvGet2D()
    // cvGetReal2D() ��� CV_64FC1
    for i := 0 to matrix^.rows - 1 do
    begin
      for j := 0 to matrix^.cols - 1 do
        Write(Format('%.0f ', [cvGet2D(matrix, i, j).val[0]]));
      Writeln;
    end;
    Writeln('-----');

    // 3 �������: ������ ��c��� � ���������
    for i := 0 to matrix^.rows - 1 do
    begin
      ptr := pSingle((Integer(matrix^.data) + i * matrix^.step));
      for j := 0 to matrix^.cols - 1 do
        Write(Format('%.0f ', [ptr[j]]));
      Writeln;
    end;
    Writeln('-----');

    // �c��������� ��c��c�
    cvReleaseMat(matrix);

    // ������ XML
    Writeln('Example 3_19 Reading in cfg.xml');

    // ��������� ���� ��� ������
    fs := cvOpenFileStorage(cResourceMedia + 'cfg.xml', 0, CV_STORAGE_READ);
    // c�������� ��������
    frame_count := cvReadIntByName(fs, 0, 'frame_count', 5 { �������� ��-��������� } );
    s := cvGetFileNodeByName(fs, 0, 'frame_size')^.seq;
    frame_width := cvReadInt(pCvFileNode(cvGetSeqElem(s, 0)));
    frame_height := cvReadInt(pCvFileNode(cvGetSeqElem(s, 1)));
    color_cvt_matrix := pCvMat(cvRead(fs, 0));

    // ����������
    WriteLn(Format('frame_count=%d, frame_width=%d, frame_height=%d',[frame_count,frame_width,frame_height]));

    cvReleaseFileStorage(fs);
    Writeln('Press <Enter>');
    Readln;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
