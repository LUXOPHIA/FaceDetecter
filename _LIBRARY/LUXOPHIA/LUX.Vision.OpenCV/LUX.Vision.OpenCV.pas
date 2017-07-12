unit LUX.Vision.OpenCV;

interface //#################################################################### ■

uses FMX.Graphics,
     ocv.core_c, ocv.core.types_c;

type //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【型】

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

     TocvImage       = class;
       TocvImage1    = class;
         TocvBitmap1 = class;
       TocvImage3    = class;
         TocvBitmap3 = class;
       TocvImage4    = class;
         TocvBitmap4 = class;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TocvImage

     TocvImage = class
     private
     protected
       _Core :pIplImage;
       ///// アクセス
       procedure SetCore( const Core_:pIplImage ); virtual;
       function GetWidth :Integer; virtual;
       function GetHeight :Integer; virtual;
       function GetChannelN :Integer; virtual;
     public
       ///// プロパティ
       property Core     :pIplImage read _Core       write SetCore;
       property Width    :Integer   read GetWidth;
       property Height   :Integer   read GetHeight;
       property ChannelN :Integer   read GetChannelN;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TocvImage1

     TocvImage1 = class( TocvImage )
     private
     protected
     public
       ///// メソッド
       procedure CopyFrom( const Image_:TocvImage1 ); overload;
       procedure CopyTo( const Image_:TocvImage1 ); overload;
       procedure CopyFrom( const Image_:TocvImage3 ); overload;
       procedure CopyTo( const Image_:TocvImage3 ); overload;
       procedure CopyFrom( const Image_:TocvImage4 ); overload;
       procedure CopyTo( const Image_:TocvImage4 ); overload;
       procedure CopyFrom( const Image_:TBitmap ); overload;
       procedure CopyTo( const Image_:TBitmap ); overload;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TocvImage3

     TocvImage3 = class( TocvImage )
     private
     protected
     public
       ///// メソッド
       procedure CopyFrom( const Image_:TocvImage1 ); overload;
       procedure CopyTo( const Image_:TocvImage1 ); overload;
       procedure CopyFrom( const Image_:TocvImage3 ); overload;
       procedure CopyTo( const Image_:TocvImage3 ); overload;
       procedure CopyFrom( const Image_:TocvImage4 ); overload;
       procedure CopyTo( const Image_:TocvImage4 ); overload;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TocvImage4

     TocvImage4 = class( TocvImage )
     private
     protected
     public
       ///// メソッド
       procedure CopyFrom( const Image_:TocvImage1 ); overload;
       procedure CopyTo( const Image_:TocvImage1 ); overload;
       procedure CopyFrom( const Image_:TocvImage3 ); overload;
       procedure CopyTo( const Image_:TocvImage3 ); overload;
       procedure CopyFrom( const Image_:TocvImage4 ); overload;
       procedure CopyTo( const Image_:TocvImage4 ); overload;
       procedure CopyFrom( const Image_:TBitmap ); overload;
       procedure CopyTo( const Image_:TBitmap ); overload;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TocvBitmap1

     TocvBitmap1 = class( TocvImage1 )
     private
     protected
       ///// アクセス
       procedure SetCore( const Core_:pIplImage ); override;
     public
       constructor Create( const Width_,Height_:Integer );
       destructor Destroy; override;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TocvBitmap3

     TocvBitmap3 = class( TocvImage3 )
     private
     protected
       ///// アクセス
       procedure SetCore( const Core_:pIplImage ); override;
     public
       constructor Create( const Width_,Height_:Integer );
       destructor Destroy; override;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TocvBitmap4

     TocvBitmap4 = class( TocvImage4 )
     private
     protected
       ///// アクセス
       procedure SetCore( const Core_:pIplImage ); override;
     public
       constructor Create( const Width_,Height_:Integer );
       destructor Destroy; override;
     end;

//const //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【定数】

//var //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【変数】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

implementation //############################################################### ■

uses FMX.Types,
     ocv.imgproc_c, ocv.imgproc.types_c;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TocvImage

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

procedure TocvImage.SetCore( const Core_:pIplImage );
begin
     _Core := Core_;
end;

function TocvImage.GetWidth :Integer;
begin
     Result := _Core.width;
end;

function TocvImage.GetHeight :Integer;
begin
     Result := _Core.height;
end;

function TocvImage.GetChannelN :Integer;
begin
     Result := _Core.nChannels;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TocvImage1

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

/////////////////////////////////////////////////////////////////////// メソッド

procedure TocvImage1.CopyFrom( const Image_:TocvImage1 );
begin
     cvResize( Image_.Core, _Core );
end;

procedure TocvImage1.CopyTo( const Image_:TocvImage1 );
begin
     cvResize( _Core, Image_.Core );
end;

//------------------------------------------------------------------------------

procedure TocvImage1.CopyFrom( const Image_:TocvImage3 );
begin
     cvCvtColor( Image_.Core, _Core, CV_BGR2GRAY );
end;

procedure TocvImage1.CopyTo( const Image_:TocvImage3 );
begin
     cvCvtColor( _Core, Image_.Core, CV_GRAY2BGR );
end;

//------------------------------------------------------------------------------

procedure TocvImage1.CopyFrom( const Image_:TocvImage4 );
begin
     cvCvtColor( Image_.Core, _Core, CV_BGRA2GRAY );
end;

procedure TocvImage1.CopyTo( const Image_:TocvImage4 );
begin
     cvCvtColor( _Core, Image_.Core, CV_GRAY2BGRA );
end;

//------------------------------------------------------------------------------

procedure TocvImage1.CopyFrom( const Image_:TBitmap );
var
   D :TBitmapData;
begin
     with Image_ do
     begin
          Map( TMapAccess.Read, D );

          with _Core^ do AlphaColorToScanline( D.Data, ImageData, height * width, TPixelFormat.L );

          Unmap( D );
     end;
end;

procedure TocvImage1.CopyTo( const Image_:TBitmap );
var
   D :TBitmapData;
begin
     with Image_ do
     begin
          Map( TMapAccess.Write, D );

          with _Core^ do ScanlineToAlphaColor( ImageData, D.Data, height * width, TPixelFormat.L );

          Unmap( D );
     end;
end;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TocvImage3

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

/////////////////////////////////////////////////////////////////////// メソッド

procedure TocvImage3.CopyFrom( const Image_:TocvImage1 );
begin
     cvCvtColor( Image_.Core, _Core, CV_GRAY2BGR );
end;

procedure TocvImage3.CopyTo( const Image_:TocvImage1 );
begin
     cvCvtColor( _Core, Image_.Core, CV_BGR2GRAY );
end;

//------------------------------------------------------------------------------

procedure TocvImage3.CopyFrom( const Image_:TocvImage3 );
begin
     cvResize( Image_.Core, _Core );
end;

procedure TocvImage3.CopyTo( const Image_:TocvImage3 );
begin
     cvResize( _Core, Image_.Core );
end;

//------------------------------------------------------------------------------

procedure TocvImage3.CopyFrom( const Image_:TocvImage4 );
begin
     cvCvtColor( Image_.Core, _Core, CV_BGRA2BGR );
end;

procedure TocvImage3.CopyTo( const Image_:TocvImage4 );
begin
     cvCvtColor( _Core, Image_.Core, CV_BGR2BGRA );
end;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TocvImage4

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

/////////////////////////////////////////////////////////////////////// メソッド

procedure TocvImage4.CopyFrom( const Image_:TocvImage1 );
begin
     cvCvtColor( Image_.Core, _Core, CV_GRAY2BGRA );
end;

procedure TocvImage4.CopyTo( const Image_:TocvImage1 );
begin
     cvCvtColor( _Core, Image_.Core, CV_BGRA2GRAY );
end;

//------------------------------------------------------------------------------

procedure TocvImage4.CopyFrom( const Image_:TocvImage3 );
begin
     cvCvtColor( Image_.Core, _Core, CV_BGR2BGRA );
end;

procedure TocvImage4.CopyTo( const Image_:TocvImage3 );
begin
     cvCvtColor( _Core, Image_.Core, CV_BGRA2BGR );
end;

//------------------------------------------------------------------------------

procedure TocvImage4.CopyFrom( const Image_:TocvImage4 );
begin
     cvResize( Image_.Core, _Core );
end;

procedure TocvImage4.CopyTo( const Image_:TocvImage4 );
begin
     cvResize( _Core, Image_.Core );
end;

//------------------------------------------------------------------------------

procedure TocvImage4.CopyFrom( const Image_:TBitmap );
var
   D :TBitmapData;
begin
     with Image_ do
     begin
          Map( TMapAccess.Read, D );

          with _Core^ do Move( D.Data^, ImageData^, ImageSize );

          Unmap( D );
     end;
end;

procedure TocvImage4.CopyTo( const Image_:TBitmap );
var
   D :TBitmapData;
begin
     with Image_ do
     begin
          Map( TMapAccess.Write, D );

          with _Core^ do Move( imageData^, D.Data^, ImageSize );

          Unmap( D );
     end;
end;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TocvBitmap1

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

procedure TocvBitmap1.SetCore( const Core_:pIplImage );
begin
     cvReleaseImage( _Core );

     _Core := Core_;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TocvBitmap1.Create( const Width_,Height_:Integer );
begin
     inherited Create;

     _Core := cvCreateImage( cvSize( Width_, Height_ ), IPL_DEPTH_8U, 1 );
end;

destructor TocvBitmap1.Destroy;
begin
     cvReleaseImage( _Core );

     inherited;
end;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TocvBitmap3

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

procedure TocvBitmap3.SetCore( const Core_:pIplImage );
begin
     cvReleaseImage( _Core );

     _Core := Core_;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TocvBitmap3.Create( const Width_,Height_:Integer );
begin
     inherited Create;

     _Core := cvCreateImage( cvSize( Width_, Height_ ), IPL_DEPTH_8U, 3 );
end;

destructor TocvBitmap3.Destroy;
begin
     cvReleaseImage( _Core );

     inherited;
end;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TocvBitmap4

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

procedure TocvBitmap4.SetCore( const Core_:pIplImage );
begin
     cvReleaseImage( _Core );

     _Core := Core_;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TocvBitmap4.Create( const Width_,Height_:Integer );
begin
     inherited Create;

     _Core := cvCreateImage( cvSize( Width_, Height_ ), IPL_DEPTH_8U, 4 );
end;

destructor TocvBitmap4.Destroy;
begin
     cvReleaseImage( _Core );

     inherited;
end;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

//############################################################################## □

initialization //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 初期化

finalization //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 最終化

end. //######################################################################### ■
