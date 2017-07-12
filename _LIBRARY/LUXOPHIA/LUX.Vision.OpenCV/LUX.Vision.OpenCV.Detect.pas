unit LUX.Vision.OpenCV.Detect;

interface //#################################################################### ■

uses System.Types,
     ocv.core_c, ocv.core.types_c, ocv.objdetect_c,
     LUX.Vision.OpenCV;

type //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【型】

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% THaarCascade

     THaarCascade = class
     private
       _Storage :pCvMemStorage;
     protected
       _Cascade      :pCvHaarClassifierCascade;
       _ScaleFactor  :Double;
       _MinNeighbors :Integer;
       _MinSize     :TCvSize;
       _MaxSize     :TCvSize;
       _Faces        :pCvSeq;
       ///// アクセス
       function GetFaceN :Integer;
       function GetBox( const I_:Integer ) :TRect;
     public
       constructor Create( const FileName_:AnsiString );
       destructor Destroy; override;
       ///// プロパティ
       property ScaleFactor             :Double  read _ScaleFactor    write _ScaleFactor;
       property MinNeighbors            :Integer read _MinNeighbors   write _MinNeighbors;
       property MinSizeX                :Integer read _MinSize.width  write _MinSize.width;
       property MinSizeY                :Integer read _MinSize.Height write _MinSize.Height;
       property MaxSizeX                :Integer read _MaxSize.width  write _MaxSize.width;
       property MaxSizeY                :Integer read _MaxSize.Height write _MaxSize.Height;
       property Faces                   :pCvSeq  read _Faces;
       property FaceN                   :Integer read GetFaceN;
       property Box[ const I_:Integer ] :TRect   read GetBox;
       ///// メソッド
       procedure Search( const Image_:TocvImage );
     end;

//const //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【定数】

//var //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【変数】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

implementation //############################################################### ■

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% THaarCascade

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

function THaarCascade.GetFaceN :Integer;
begin
     Result := _Faces^.total;
end;

function THaarCascade.GetBox( const I_:Integer ) :TRect;
begin
     with pCvRect( cvGetSeqElem( _Faces, I_ ) )^ do
     begin
          Result.Left   := x;
          Result.Top    := y;
          Result.Right  := x + width;
          Result.Bottom := y + height;
     end;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor THaarCascade.Create( const FileName_:AnsiString );
begin
     inherited Create;

     _Cascade := cvLoad( PAnsiChar( FileName_ ) );

     _Storage := cvCreateMemStorage( 0 );

     ScaleFactor  := 1.2;
     MinNeighbors := 2;
     MinSizeX     := 64;
     MinSizeY     := 64;
     MaxSizeX     := 128;
     MaxSizeY     := 128;
end;

destructor THaarCascade.Destroy;
begin
     cvReleaseMemStorage( _Storage );

     cvReleaseHaarClassifierCascade( _Cascade );

     inherited;
end;

/////////////////////////////////////////////////////////////////////// メソッド

procedure THaarCascade.Search( const Image_:TocvImage );
begin
     cvClearMemStorage( _Storage );

     _Faces := cvHaarDetectObjects( Image_.Core,
                                    _Cascade,
                                    _Storage,
                                    _ScaleFactor,
                                    _MinNeighbors,
                                    CV_HAAR_DO_CANNY_PRUNING,
                                    _MinSize,
                                    _MaxSize );
end;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

//############################################################################## □

initialization //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 初期化

finalization //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 最終化

end. //######################################################################### ■
