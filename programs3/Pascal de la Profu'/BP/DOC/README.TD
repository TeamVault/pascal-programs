	     TURBO DEBUGGER/PROFILER/ASSEMBLER RELEASE NOTES
	     -----------------------------------------------

This file contains important, last-minute information about Turbo Debugger,
Turbo Profiler, and Turbo Assembler.


TABLE OF CONTENTS
-----------------
1. Debugging Multiple Applications under Turbo Debugger for Windows
2. TDW.INI settings for Video DLLs and TDWIN.DLL
3. Using TDW in Dual-Monitor Mode from Borland Pascal for Windows
4. Using TDW in Dual-Monitor Monochrome Mode
5. The [WRemote] section of TDW.INI
6. Known Problems


1. Debugging Multiple Applications under Turbo Debugger for Windows
===================================================================
     You can debug multiple applications under TDW as follows:

       1. Load the first program to be debugged into TDW.
  
       2. Once the application is loaded, press the F3 key to display the
	  Load Module Source or DLL Symbols dialog box.
  
       3. In the DLL Name text entry box, enter the name of the .EXE or
	  DLL to add. If the .EXE or DLL resides in another directory, you
	  need to provide the full path.
  
       4. Press the Enter key. TDW adds the program name to the
	  DLLs & Programs list box and puts the !! symbol after it.
  
       5. Close the Load Module Source or DLL dialog box, return to the Module
	  window, and set any necessary breakpoints in the first program.
  
       6. Press F9 to run the first program.
  
       7. Switch to the Windows Program Manager while the first program
	  is running and run the second program in the usual way.
  
       8. You see the display switch back to TDW with the CPU window
	  showing the start-up information of the second application.
	  Close the CPU window.
  
       9. In the Module window, set any necessary breakpoints in the second
	  application, then press the F9 key to run it.

     This method is useful for debugging DDE conversations or any other
     inter-program communication in the Windows environment.


2. TDW.INI settings for Video DLLs, TDWIN.DLL, and WREMOTE
==========================================================
    TDW.INI, located in your local Windows directory, is the 
    Windows initialization file used by TDW, TPROFW, and WREMOTE. 
    It can contain up to three sections:

    o [TurboDebugger], a required section that specifies the names 
      and locations of the Debugger DLL and the video driver DLL  
  
    o [VideoOptions], where you put settings for the video DLL, if any

    o [WRemote], where WRSETUP puts settings for remote debugging 
      and profiling

    [TurboDebugger] section
    -----------------------
      The DebuggerDLL entry is one of two entries in this section.
      It must specify the full path to TDWIN.DLL (the DLL that
      replaces WINDEBUG.DLL).  TDWIN.DLL can be located anywhere you 
      wish (usually the main Windows directory).  The installation 
      program automatically inserts this entry for you in TDW.INI. 
      However, if you move the DLL, you need to change this entry.
      
      For example, if you move TDWIN.DLL to the WINDOWS3.1 directory, 
      you must change its TDW.INI entry to 
      
	  [TurboDebugger]
	  DebuggerDLL=c:\windows3.1\tdwin.dll

      The other entry in this section is the VideoDLL entry, which
      indicates a DLL that handles SVGA or 8514 video for TDW (or TPROFW). 
      By default, the installation program enters SVGA.DLL as the
      standard video DLL. If you install using the default directories,
      your [TurboDebugger] section looks like the following:
      
	  [TurboDebugger]
	  DebuggerDLL=C:\WINDOWS\TDWIN.DLL
	  VideoDLL=C:\BP\BIN\SVGA.DLL

      The following section describes the video DLLs and their 
      TDW.INI entries.

    SVGA support, the VideoDLL entry, and the [VideoOptions] section
    ----------------------------------------------------------------
      TDW and TPROFW handle most of the popular 2, 4, 16, and 256-color 
      high-resolution Super VGA modes. If your card isn't supported 
      correctly, you need to use a special Super VGA (SVGA) DLL.
  
      Currently, six DLLs are supplied with your language compiler to 
      support various SVGA and 8514 video cards and modes. These DLLs are
      described in the next section. For information on how to specify the
      Video DLL or its options, see the sections "The VideoDLL entry" and 
      "The [VideoOptions] section," which follow the "Video DLLs" section.

    
      Video DLLs
      ----------
	All the video DLLs described in this section are designed to work 
	with the most current Windows screen drivers for your video card.  If 
	you're not sure if you're using the latest drivers, contact your video 
	card manufacturer for more information.
  
	From time to time we have new DLLs for new video cards. These DLLs,
	when available, can be downloaded from Compuserve, BIX, GEnie, and our
	local BBS (408-439-9096). As new video cards and modes appear on the
	market, we will be creating new DLLs for them. If the card you use
	isn't supported by one of our DLLs, please contact Tech Support for
	the latest video DLL information.  Our main Tech Support phone number
	is 408-438-5300.




	SVGA.DLL
	--------

	This DLL is designed to support ALL video cards.  The performance of
	this DLL is slightly less than the card-specific DLLs, but it has a
	broader range.  If there is a specific DLL that supports your card,
	then you should use that one, since it will probably be faster than
	this one.

	This DLL will support any Video card/mode using some undocumented
	Windows functions that force the Windows display driver to do the 
	mode switching.  The Windows screen is saved into a full-screen 
	sized bitmap using the BitBlt API call.  It also uses 2 device 
	contexts (DCs) throughout the life of the debugger, so if you use 
	more than 2 to 3 DCs in your program and you see strange things 
	happening, then you'll want to disable the BitBlt option (described
	later).  
	
	On coprocessor cards (or those that are advertised as "Windows 
	Accelerators") the response time is fairly quick, even in 1024x768 
	modes.  On non-coprocessor cards, the higher the resolution, the 
	longer it takes for the screen switch to occur (the transition 
	between the Windows screen and the Debugger screen).  There are 
	some options that can be specified in the TDW.INI file under the
	[VideoOptions] section, that might help improve performance:

	BitBlt=Y|N       - Y saves the bitmap, N doesn't.
			 
			 This option is on by default. Specify it only if  
			 you want to disable it.  If disabled, it prevents 
			 the DLL from allocating the bitmap or the DCs, or 
			 from saving the entire screen each screen swap. 
			 Also, you won't see anything on the user screen 
			 (Alt+F5) until you run the program and control 
			 goes back to Windows.

	ForceRepaint=Y|N - Y Forces Windows to repaint the screen, N doesn't.

			 This option is off by default and only takes
			 effect if BitBlt is disabled.  It forces
			 Windows to repaint the whole screen when your
			 program is run and you are not saving the whole
			 screen in the bitmap.  If you disable this
			 option, you won't see anything on the Windows
			 screen until your program invalidates something
			 and repaints it.

	ROWS=xx          25, 43, or 50 rows on the screen.  Warning: TDW
			 will use this number, so don't specify anything 
			 that your screen won't handle.

	XGA=Y|N          - Set this to 'Y' only on an XGA card.

  On XGA, TIGA, and other high-powered coprocessor cards, the BitBlt
  option should be fast enough to be useful.



	ATI.DLL
	-------
	  Works with the ATI VGA Wonder and XL cards in certain video modes.
    
	  Use the following table to determine if you need an ATI.DLL
	  VideoDLL entry and an Int2FAssist=Yes [VideoOptions] entry:
      
	       Resolution   ATI.DLL  Int2FAssist
	     -----------------------------------
	     | 640X480    | Yes     |   Yes    |
	     -----------------------------------
	     | 800X600    | Yes     |   Yes    |
	     -----------------------------------
	     | 1024X768   | No      |    No    | 
	     -----------------------------------
   
	  EXPLANATION: ATI.DLL is required in all video modes except 
	  1024 X 768 (this mode is directly supported by TDW and TPROFW).
	  When the DLL is used (VideoDLL=ATI.DLL), Int2FAssist should be 
	  set to "yes" in the [VideoOptions] section.


	TSENG.DLL
	---------
	  Supports TSENG ET-3000 /ET-4000 based cards in certain 
	  video modes.
  
	  The latest TSENG drivers are available from the Microsoft
	  Windows Driver Library on Comp-U-Serve (GO MSOFT, then go
	  to Section 6). Use the following table to determine your
	  TDW.INI settings:
      
      
	      Resolution   TSENG.DLL   Int2FAssist
	     -------------------------------------
	     | 640X480    | Yes       |   Yes    |
	     -------------------------------------
	     | 800X600    | No        |    No    |
	     -------------------------------------
	     | 1024X768   | No        |    No    |
	     -------------------------------------
    
	  EXPLANATION: TSENG.DLL should only be used with 640 X 480 X 256 
	  resolution (set VideoDLL=TSENG.DLL and put a Int2FAssist="Yes" 
	  entry in the [VideoOptions] section). TDW and TPROFW directly 
	  support the other TSENG resolutions.
      


	TDVESA.DLL
	----------
	  Supports any video card that does VESA emulation, whether
	  through a TSR or through video card firmware. Use this DLL 
	  with all resolution settings.
    
	      NOTE: You can run VESATEST.EXE from either DOS or 
	      Windows to see if your system provides the proper 
	      VESA functions. If the emulation is not loaded, TDW 
	      (or TPROFW) will display an error message indicating
	      that the video DLL is not supported by the current 
	      configuration.
  
	  The TDVESA.DLL has been tested with the following video 
	  cards:      
	
	  o Video Seven VRAM II--uses V7VESA TSR supplied with card
  
	  o Weitek Power Windows--emulates VESA with firmware.
  
  
	DUAL8514.DLL 
	------------- 
	  Supports any dual-screen 8514 cards.  This DLL is only for 
	  systems that have two color monitors, one attached to the VGA
	  card and one attached to the 8514/A card.  It speeds up 
	  performance by preventing TDW (or TPROFW) from doing some 
	  things that aren't required in dual-monitor mode.
  
	      NOTE: Using this DLL is not the same as invoking TDW
	      with the -do parameter, which only specifies using a
	      monochrome screen.
  
      
	STB.DLL
	-------
	  Supports the MVP2 series of multi-screen video cards.
  
  
	ULTRA.DLL
	---------
	  Supports the ATI 8514 Ultra and Vantage graphics cards 
	  (8514/Ultra, 8514/Vantage, Graphics/Ultra, and Graphics/Vantage)
	  and 8514-based cards configured for a single monitor (including
	  the IBM 8514/A card). If you use this DLL with an IBM 8514/A card,
	  set "ATI=no" in the [VideoOptions] section of TDW.INI.


    The VideoDLL entry
    ------------------
      To use an SVGA DLL, simply edit the TDW.INI file that the installation
      program puts in your main Windows directory. You can modify TDW.INI
      with any ASCII text editor. Under the section heading [TurboDebugger]
      there is an option called "VideoDLL". This entry should equal the
      path and filename of the DLL you want to use for SVGA support (see the
      example later in this file).
  
      If there is an error loading the DLL or if the DLL doesn't support 
      the selected card or mode, TDW (or TPROFW) reports the error in a 
      Windows dialog box. When this happens, TDW (or TPROFW) unloads it
      and exits. If this situation occurs, either remove the DLL's name 
      from the VideoDLL line in the TDW.INI file or select a video mode 
      supported by that DLL.


    The [VideoOptions] section
    --------------------------
      There are options you can set for the current video DLL.  You list
      these options under the [VideoOptions] heading in any order you like.
  
      The following list shows all the video options:
    
	o SaveWholeScreen    --    default = no
	o Int2FAssist        --    default = no
	o DebugFile          --    default = <blank>
	o IgnoreMode         --    default = no
	o ATI                --    default = yes
	o Rows               --    default = 25
	o RestoreTextScreen  --    default = yes
	o XGA                --    default = no 
	o BitBlt             --    default = yes
	o ForceRepaint       --    default = no 

    
      DebugFile can be either blank or set to a specific filename. 
      Rows must be 25 or 50. The other five settings must be either 
      'yes' or 'no'.


      SaveWholeScreen   (ATI, TSENG, TDVESA)
      ---------------
	This option, normally set to "no", determines whether the entire 
	screen (512k - 64k from 8 planes) is saved (the entire graphics 
	screen is cleared when switching to it) or if only the top 32K of 
	planes 0 through 3 is saved (the entire screen is NOT cleared when 
	switching modes.)
      
	Saving the whole screen is not usually necessary, but is available
	in case you're using a nonstandard card that requires that the whole
	screen be saved.  It also provides support for the Alt+F5 key
	combination under the Int2FAssist mode.
  
      
      Int2FAssist  (ATI, TSENG)
      -----------
	This option, normally set to "no", tells the DLL to make a 
	special Int 2F call before switching video modes. This call 
	tells the current Windows screen driver what's happening. 
	The desired effect of this call is to make Windows tell all 
	of its child windows to repaint themselves. This option is 
	provided mainly to support some ATI Wonder and TSENG chip set 
	video modes.

    
      DebugFile   (ALL DLLs)
      ---------
	The video DLL normally doesn't log any debugging information. If
	you're having problems using a particular DLL, you can use the 
	DebugFile option to specify the path and filename of a log file. 
	You can use the information logged to this file if you need to 
	contact Borland's Technical Support.
      
	The information logged is:
      
	  o the date and time you ran TDW or TPROFW
	  o the version & location of the DLL
	  o the name of the current Windows screen driver
	  o the state of all TDW.INI options
	  o a listing of all calls and parameters to the DLL's functions
  
    
      IgnoreMode   (ATI, TSENG)
      ----------
	This option only applies when the video DLL is ATI.DLL or TSENG.DLL.
	It tells the DLL not to check the mode or card, but to force the
	Int2FAssist option on.  This option is useful for cards that aren't
	directly supported by an official DLL yet, such as Paradise, Video-7,
	Trident, or any other video card without a graphics coprocessor.
	(With this option enabled, the functionality is identical to the
	temporary ALL.DLL that we offered in the past.)

    
      ATI   (ULTRA)
      ---
	This option is only used by ULTRA.DLL and is on by default.  If you
	disable it (ATI=no), you can use ULTRA.DLL on regular IBM 8514/A 
	cards.
    
    
      ROWS  (ALL DLLs)
      ----
	This option is only used if you use a configuration file to set 
	the number of rows to 43/50 from 25. If you choose to have TDW 
	start in 50-line mode, set the Rows option to 50 in the TDW.INI file.
    
    
      RestoreTextScreen   (DUAL8514, STB)
      -----------------
	This option is only valid with the DUAL8514 and STB DLLs.  The valid
	options are:
  
	o Yes    - restores TDW's (or TPROFW's) screen after exiting.
	o No     - does not touch TDW's (or TPROFW's) screen at all.
	o Clear  - forces the screen to clear upon exiting TDW (or TPROFW).
    

    Video DLL example
    -----------------
      If you have an ATI VGA Wonder card and you want it to save
      the entire  screen and send log information to a file named
      C:\WINDOWS\TDVIDEO.LOG, the TDW.INI file will look something
      like this:
      
	  [TurboDebugger]
	  DebuggerDLL=c:\windows\tdwin.dll
	  VideoDLL=c:\bp\bin\ati.dll
	
	  [VideoOptions]
	  SaveWholeScreen=yes
	  DebugFile=c:\windows\tdvideo.log
    
  
    Technical information
    ---------------------
      TDW, upon loading, looks for the video DLL in the following 
      locations and in the following order:
  
	1. The same directory TDW (or TPROFW) is running from
  
	2. The Windows main directory
  
	3. The location specified in TDW.INI


    If it finds the file, TDW (or TPROFW) accesses the DLL as needed. 
    TDW (or TPROFW) makes calls to the DLL to handle the entire video 
    screen-switching context. The DLL accomplishes the screen switching 
    by allocating a buffer as it gets loaded. Graphics screen contents 
    are then saved to this buffer when TDW (or TPROFW) enters text mode. 
    The DLL restores the graphics screen from this buffer when TDW 
    (or TPROFW) exits text mode. Memory allocated for the buffer is freed 
    when the DLL is unloaded.
      
	
    Seeing the user screen of an application
    ----------------------------------------
      Some video modes might require some special handling. The Int2FAssist 
      option allows these modes to work correctly on most systems. The 
      behavior is as follows: 
  
      When you set "Int2FAssist=yes", the DLL informs Windows to tell 
      all sub-windows on the screen to repaint themselves while the user 
      application is running. This allows the user screen to be viewed 
      when stepping, tracing, or running your application. It will not, 
      however, switch to the user screen when you press the Alt+F5 key 
      combination because TDW is still in control. (TDW doesn't allow 
      Windows to process any messages at this point.)
  
      If you also set "SaveWholeScreen=yes", pressing the Alt+F5 key 
      combination shows the user screen. (The DLL will now copy the screen 
      back for you.) The drawback to enabling SaveWholeScreen is that it 
      will take longer to step or trace if TDW needs to switch back to 
      the user screen for that particular instruction. Also, extra messages 
      will be passed to your application that normally wouldn't be passed. 
      This may affect the debugging of certain pieces of code (like finding 
      a bug in an owner-draw control). In these cases, you won't want to use 
      this option on the current video mode.


3. Using TDW in Dual-Monitor Mode from Borland Pascal for Windows
=================================================================
    If you run TDW from Borland Pascal for Windows, you can use 
    dual-monitor mode only if you add the following section to your 
    BPW.INI file:

       [Debugger]
       ExePath=c:\bp\bin\
       Switches=-do


4. Using TDW in Dual-Monitor Monochrome Mode
============================================
     If TDW is activated using the -do switch, there is no need for 
     a value in the VideoDLL entry of TDW.INI. The VideoDLL entry
     should be empty, as follows:

       [Debugger]
       VideoDLL=


5. The [WRemote] section of TDW.INI
===================================
     If you run WRSETUP to configure WREMOTE, the settings are saved
     in the WRemote section of TDW.INI. In previous versions, these
     settings were saved in the WRemote section of WREMOTE.INI. If you
     have a previous version of TDW or TPROFW and want to preserve your
     WREMOTE settings, you can append the contents of WREMOTE.INI into
     TDW.INI. Be sure to include the [WRemote] section heading.

     The settings for the [WRemote] section are described in the "Turbo
     Debugger User's Guide" in Appendix E, "Remote Debugging".


6. Known Problems
=================

    o The MEMPAGE segment attribute in TASM is not currently supported by
      TLINK.  This option was added to TASM to support a feature of the Phar
      Lap linker.

    o TD386 and TF386 currently do not support machines with over 16M of
      memory.  You must disable any extra memory to use these programs.

    o TD286 and TD386 currently do not run from the IDE.

    o Some mouse drivers are incompatible with TD and will cause the mouse 
      cursor to get scrambled when debugging DOS graphics applications on 
      a second monitor (-do option).  If that happens, you can try a 
      different driver or turn off the mouse in TD by using the -p- option 
      on the TD command line.  The mouse will still be active in the
      target application.

    o If you have any lines in your SYSTEM.INI that rename DLLs, such as
      "sound.dll=mysound.drv", TDW might display the error "Can't find 
      sound.dll" when it loads a program that uses the DLL.  To solve this 
      problem, use the -wd command switch to disable TDW's DLL checking when 
      you load such a program.

    o The first time a program is run under TDW or TPROFW, mouse messages 
      are processed normally. However, on every subsequent execution of 
      that program, you must press a key on the keyboard before mouse 
      messages can be processed.

    o TSENG ET-4000 video chip set problems

      Under Windows 3.1, if you use the standard Windows VGA or SuperVga
      driver with a video card that uses the TSENG ET-4000 chip set, you
      might encounter a number of problems with running the debugger on a
      single monitor.
    
      - The hardware cursor (the white cursor displayed in all dialog boxes
	that require text input) is invisible, but you can still debug your
	program.
    
      - On certain TSENG 4000-based cards (such as the Diamond Speedstar VGA
	card), when you launch TDW the default character set is replaced by
	graphic characters.
    
	To overcome this problem, contact Microsoft Corp and ask for the
	updated TSENG drivers that were not shipped with Windows 3.1. They 
	are also available on CompuServe in the Microsoft Forum (GO MSOFT) 
	under the Microsoft Software Library heading. The drivers are
    
	  Filename       Date
	  --------       ----
	  TSEN1A.EXE     6/15/92
	  TSEN1B.EXE     6/15/92
	  TSEN1C.EXE     6/15/92
	  TSEN1D.EXE     6/15/92
	  TSEN2A.EXE     6/15/92
	  TSEN2B.EXE     6/15/92
	  TSEN2C.EXE     6/15/92
	  TSENG3.EXE     4/06/92
	  TSENG4.EXE     4/06/92
    
	In the meantime, you can use one of the following alternatives:
    
	o Run Windows Setup and replace your Windows 3.1 VGA or SVGA driver
	  with the Version 3.0 VGA driver supplied with Windows 3.1.
    
	o Start TDW from the DOS command line. For example,
    
	    WIN TDW myprog
    
	o Each time you launch Windows, run a full screen DOS session and 
	  type "exit" to close it. After you do this, when you run TDW, it 
	  will use the correct character set.

