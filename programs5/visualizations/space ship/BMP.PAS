//----------------------------------------------------------------------------
//
// Author              : Jan Horn
// Email               : jhorn@global.co.za
// Website             : http://home.global.co.za/~jhorn
// Date                : 8 April 2001
// TMT Pascal version  : Vadim Bodrov (http://www.tmt.com)
// Description         : A unit that used with OpenGL projects to load BMP files
// Usage               : LoadTexture(BMPFilename, TextureName);
//                       eg : LoadTexture('logo.bmp', LogoTex);
//
//----------------------------------------------------------------------------
unit BMP;

interface

uses
  Windows, Strings, OpenGL;

function LoadTexture(Filename: String; var Texture: GLuint): Boolean;

implementation

const
  glu32 = 'glu32.dll';
  opengl32 = 'opengl32.dll';

var
  Buff: Array[0..255] of Char;

function gluBuild2DMipmaps(Target: GLenum; Components, Width, Height: GLint; Format, atype: GLenum; Data: Pointer): GLint; stdcall; external glu32;
procedure glGenTextures(n: GLsizei; var textures: GLuint); stdcall; external opengl32;
procedure glBindTexture(target: GLenum; texture: GLuint); stdcall; external opengl32;


{------------------------------------------------------------------}
{  Load BMP file                                                   }
{------------------------------------------------------------------}
procedure LoadBitmap(Filename: String; out Width: Cardinal; out Height: Cardinal; out pData: Pointer);
var
  FileHeader: TBITMAPFILEHEADER;
  InfoHeader: TBITMAPINFOHEADER;
  Palette: Pointer;
  BitmapFile: THandle;
  BitmapLength: Cardinal;
  PaletteLength: Cardinal;
  ReadBytes: Cardinal;
  Front: ^Byte;
  Back: ^Byte;
  Temp: Byte;
  I : Cardinal;
begin
  BitmapFile := CreateFile(StrPCopy(Buff, Filename), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, 0, 0);
  if (BitmapFile = INVALID_HANDLE_VALUE) then begin
    MessageBox(0, StrPCopy(Buff, 'Error opening "' + Filename), 'BMP Unit', MB_OK);
    Exit;
  end;

  // Get header information
  ReadFile(BitmapFile, FileHeader, SizeOf(FileHeader), ReadBytes, nil);
  ReadFile(BitmapFile, InfoHeader, SizeOf(InfoHeader), ReadBytes, nil);

  // Get palette
  PaletteLength := InfoHeader.biClrUsed;
  GetMem(Palette, PaletteLength);
  ReadFile(BitmapFile, Palette, PaletteLength, ReadBytes, nil);
  if (ReadBytes <> PaletteLength) then begin
    MessageBox(0, 'Error reading palette', 'BMP Unit', MB_OK);
    Exit;
  end;

  Width := InfoHeader.biWidth;
  Height := InfoHeader.biHeight;
  BitmapLength := InfoHeader.biSizeImage;
  if BitmapLength = 0 then
    BitmapLength := Width * Height * InfoHeader.biBitCount Div 8;

  // Get the actual pixel data
  GetMem(pData, BitmapLength);
  ReadFile(BitmapFile, pData^, BitmapLength, ReadBytes, nil);
  if (ReadBytes <> BitmapLength) then begin
    MessageBox(0, 'Error reading bitmap data', 'BMP Unit', MB_OK);
    Exit;
  end;
  CloseHandle(BitmapFile);

  // Bitmaps are stored BGR and not RGB, so swap the R and B bytes.
  for I :=0 to Width * Height - 1 do
  begin
    Front := Pointer(Cardinal(pData) + I*3);
    Back := Pointer(Cardinal(pData) + I*3 + 2);
    Temp := Front^;
    Front^ := Back^;
    Back^ := Temp;
  end;
end;


{------------------------------------------------------------------}
{  Load BMP textures                                               }
{------------------------------------------------------------------}
function LoadTexture(Filename: String; var Texture: GLuint): Boolean;
var
  pData: Pointer;
  Width: Cardinal;
  Height: Cardinal;
begin
  pData :=nil;
  LoadBitmap(Filename, Width, Height, pData);

  if (Assigned(pData)) then
    Result := True
  else
  begin
    Result := False;
    MessageBox(0, StrPCopy(Buff, 'Unable to load ' + filename), 'Loading Textures', MB_OK);
    Halt(1);
  end;

  glGenTextures(1, Texture);
  glBindTexture(GL_TEXTURE_2D, Texture);
  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);  {Texture blends with object background}
//  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);  {Texture does NOT blend with object background}

  { Select a filtering type. BiLinear filtering produces very good results with little performance impact
    GL_NEAREST               - Basic texture (grainy looking texture)
    GL_LINEAR                - BiLinear filtering
    GL_LINEAR_MIPMAP_NEAREST - Basic mipmapped texture
    GL_LINEAR_MIPMAP_LINEAR  - BiLinear Mipmapped texture
  }

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR); { only first two can be used }
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR); { all of the above can be used }

  gluBuild2DMipmaps(GL_TEXTURE_2D, 3, Width, Height, GL_RGB, GL_UNSIGNED_BYTE, pData);
//  glTexImage2D(GL_TEXTURE_2D, 0, 3, Width, Height, 0, GL_RGB, GL_UNSIGNED_BYTE, pData);  // Use when not wanting mipmaps to be built by openGL
end;


end.
