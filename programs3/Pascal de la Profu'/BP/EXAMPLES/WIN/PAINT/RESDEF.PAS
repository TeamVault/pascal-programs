{************************************************}
{                                                }
{   ObjectWindows Paint demo                     }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit ResDef;

{ This unit supplies the constant definitions used in the paint program
  to refer to resources not in the standardly defined.

  These declarations are separated from other paint declarations because
  Resource Workshop can only parse a limited subset of Pascal.
}

interface

const

  { Used by Bitmap Size dialog }
  id_WidthField = 101;
  id_HeightField = 102;
  id_StretchBM = 104;
  id_PadBM = 105;
  id_CurrentBMGroup = 106;

  { Message numbers for menus }
  cm_OptionsSize = 444; 	{ An arbitrarily chosen message number }
  cm_HelpAbout = 333;		{ Equally arbitrary }

implementation

end.
