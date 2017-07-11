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

unit uMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ocv.comp.Types, ocv.comp.ImageOperation,
  ocv.core.types_c, ocv.comp.Source, ocv.comp.View, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TMainForm = class(TForm)
    ocvView1: TocvView;
    ocvView3: TocvView;
    ocvmgprtn1: TocvImageOperation;
    ocvcmrsrc1: TocvCameraSource;
    procedure FormCreate(Sender: TObject);
    procedure cbb1Change(Sender: TObject);
    procedure chk1Click(Sender: TObject);
    procedure chk2Click(Sender: TObject);
    procedure chk3Click(Sender: TObject);
    procedure ocvmgprtn1AfterEachOperation(PrevOperation, Operation, NextOperation: TObject; const IplImage: IocvImage;
      var ContinueTransform: Boolean);
    procedure ocvmgprtn1OperationBeforeTransform(Sender: TObject; const IplImage: IocvImage; var ContinueTransform: Boolean);
  private
  public
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.cbb1Change(Sender: TObject);
begin
  ocvmgprtn1.OperationClass := TocvImageOperationClass(cbb1.Items.Objects[cbb1.ItemIndex]);
end;

procedure TMainForm.chk1Click(Sender: TObject);
begin
  ocvcmrsrc1.Enabled := chk1.Checked;
end;

procedure TMainForm.chk2Click(Sender: TObject);
begin
  ocvpcmsrc1.Enabled := chk2.Checked;
end;

procedure TMainForm.chk3Click(Sender: TObject);
begin
  ocvflsrc1.Enabled := chk3.Checked;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  cbb1.Items.Assign(GetRegisteredImageOperations);
  cbb1.ItemIndex := cbb1.Items.IndexOf(GetRegisteredImageOperations.GetNameByClass(ocvmgprtn1.OperationClass));
  chk3.Checked := ocvflsrc1.Enabled;
  chk2.Checked := ocvpcmsrc1.Enabled;
  chk1.Checked := ocvcmrsrc1.Enabled;
end;

procedure TMainForm.ocvmgprtn1AfterEachOperation(PrevOperation, Operation, NextOperation: TObject; const IplImage: IocvImage;
  var ContinueTransform: Boolean);
Var
  H: TocvRects;
begin
  if (Operation is TocvHaarCascade) and (NextOperation is TocvCropOperation) then
  begin
    H := (Operation as TocvHaarCascade).HaarRects;
    if Length(H) > 0 then
      (NextOperation as TocvCropOperation).CropRect.ocvRect := H[0];
  end;
end;

procedure TMainForm.ocvmgprtn1OperationBeforeTransform(Sender: TObject; const IplImage: IocvImage;
  var ContinueTransform: Boolean);
begin
  With Sender as TocvWarpPerspective do
  begin
    DestQuad.Points[0].x := IplImage.width * 0.05; // dst Top left
    DestQuad.Points[0].y := IplImage.height * 0.33;
    DestQuad.Points[1].x := IplImage.width * 0.9; // dst Top right
    DestQuad.Points[1].y := IplImage.height * 0.25;
    DestQuad.Points[2].x := IplImage.width * 0.2; // dst Bottom left
    DestQuad.Points[2].y := IplImage.height * 0.7;
    DestQuad.Points[3].x := IplImage.width * 0.8; // dst Bot right
    DestQuad.Points[3].y := IplImage.height * 0.9;
  end;
end;

end.
