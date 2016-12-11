
{*******************************************************}
{                                                       }
{       Turbo Pascal for Windows Run-time Library       }
{       ObjectWindows Include File                      }
{                                                       }
{       Copyright (c) 1992 Borland International        }
{                                                       }
{*******************************************************}

const

{ Application message constants }

  wm_First    = $0000;	        { $0000-$7FFF window messages }
  id_First    =	$8000;          { $8000-$8FFF child id messages }
  id_Internal = $8F00;	        { $8F00-$8FFF reserved for internal use }
  nf_First    =	$9000;          { $9000-$9FFF notification messages }
  nf_Internal = $9F00;	        { $9F00-$9FFF reserved for internal use }
  cm_First    =	$A000;          { $A000-$FFFF command messages }
  cm_Internal =	$FF00;	        { $FF00-$FFFF reserved for internal use }
  wm_Count    =	$8000;	        { Number of window messages }
  id_Count    =	$1000;	        { Number of child ID messages }
  nf_Count    =	$1000;	        { Number of notification messages }
  cm_Count    =	$6000;	        { Number of command messages }

{ Standard child ID messages }

  id_Reserved      = id_Internal - id_First;
  id_FirstMDIChild = id_Reserved + 1;
  id_MDIClient     = id_Reserved + 2;

{ Standard command messages }

  cm_Reserved        = cm_Internal - cm_First;
  cm_EditCut         = cm_Reserved + 0;
  cm_EditCopy        = cm_Reserved + 1;
  cm_EditPaste       = cm_Reserved + 2;
  cm_EditDelete      = cm_Reserved + 3;
  cm_EditClear       = cm_Reserved + 4;
  cm_EditUndo        = cm_Reserved + 5;
  cm_EditFind        = cm_Reserved + 6;
  cm_EditReplace     = cm_Reserved + 7;
  cm_EditFindNext    = cm_Reserved + 8;

  cm_FileNew         = cm_Reserved + 9;
  cm_FileOpen        = cm_Reserved + 10;
  cm_MDIFileNew      = cm_Reserved + 11;
  cm_MDIFileOpen     = cm_Reserved + 12;
  cm_FileSave        = cm_Reserved + 13;
  cm_FileSaveAs      = cm_Reserved + 14;
  cm_ArrangeIcons    = cm_Reserved + 15;
  cm_TileChildren    = cm_Reserved + 16;
  cm_CascadeChildren = cm_Reserved + 17;
  cm_CloseChildren   = cm_Reserved + 18;
  cm_CreateChild     = cm_Reserved + 19;
  cm_Exit            = cm_Reserved + 20;

