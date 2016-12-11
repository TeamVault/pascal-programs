            TURBO DEBUGGER AND TURBO PROFILER UTILITIES REFERENCE
            =====================================================

This file contains information about the following Turbo Debugger utilities:

1.  TDRF (also used with Turbo Profiler)
2.  TDSTRIP
3.  TDMAP
4.  TDUMP
5.  TDNMI
6.  TDMEM
7.  TDDEV
8.  TDWINST

For convenience, when searching for information about a particular utility,
you can search for the name of the utility followed by a colon (i.e. TDUMP:).
Doing so will take you directly to the header for the utility specified.

For a list of all the command-line options available for TDRF.EXE, 
TDSTRIP.EXE, TDMAP.EXE, and TDUMP.EXE, just type the program  name and
press Enter. For example, to see the command-line options for TDMAP.EXE, 
you enter

   TDMAP

For a list of all the command-line options available for TDNMI.COM, 
TDDEV.EXE, and TDMEM.EXE, enter the program name followed by -?.
TDNMI also accepts -h. For example,

   TDDEV -?


1. TDRF: Utility for remote file commands and file transfer
===========================================================================
The remote file transfer utility (TDRF) works in conjunction with TDREMOTE
or WREMOTE running on another system.  (For more information on TDREMOTE and
WREMOTE, see Appendix E, "Remote Debugging," in the "Turbo Debugger User's 
Guide"). 

You can also use TDRF in conjunction with TFREMOTE or WREMOTE running on
another system. (For more information on TFREMOTE and WREMOTE, see Appendix C,
"Remote Profiling," in the "Turbo Profiler User's Guide.")

With TDRF you can perform most DOS file maintenance operations on 
the remote system. You can

  o copy files to the remote system
  o copy files from the remote system
  o make directories
  o remove directories
  o display directories
  o change directories
  o rename files
  o delete files

Once you have started TDREMOTE, TFREMOTE, or WREMOTE on the remote system, 
you can use TDRF at any time. You can start it directly from the DOS prompt, 
or you can access DOS from inside Turbo Debugger by using the File|DOS
Shell command, then start TDRF (even while debugging a program on the
remote system). This second method is useful if you've forgotten to put
some files on the remote system that are required by the program you're
debugging.

When describing TDRF in the following sections, we refer to the system
you're typing at as the "local system" and any files there as "local
files," and the other system connected by a serial cable or network as 
the "remote system" and any files there as "remote files."


Starting TDRF from the DOS command line
---------------------------------------
The general form of the command line for TDRF is

   TDRF [<options>] <command> [<arguments>]

The <options> control whether the link is network or serial, and if it's
serial, the speed of the remote link and which port it runs on. The
options are described in more detail in the next section.

<command> indicates the operation you want to perform. You can type the 
command either as a DOS command--like COPY, DEL, MD, and so on--or as 
a single-letter abbreviation.

<arguments> are any arguments to the command.

For example, to get a directory display of all files starting with ABC
in the current directory on the remote system, you could type:

   TDRF DIR ABC*

All the commands are described fully after the next section.


TDRF command-line options
-------------------------
You must start an option with either a hyphen (-) or a slash (/).
The following list shows the command-line options for TDRF:

-rn<L>;<R>  Sets the link to network, the local name to <L>, and the remote
            name to <R>.

  If you link over the network, the name of the local machine defaults to
  "LOCAL" and the remote machine to "REMOTE". You can set your own name for
  the machines by entering a name up to 16 characters long for either the
  local machine, the remote machine, or both.
 
  You must be running TDREMOTE, TFREMOTE, or WREMOTE with the -rn option on 
  the remote machine with the local machine name set to the same name as 
  you've indicated in the TDRF command.

-rsN        Sets the type of remote link to serial and the speed of the link.

  The -rs option sets the speed at which the remote serial link operates. 
  You must make sure you use the same speed with TDRF that you specified
  when you started TDREMOTE, TFREMOTE, or WREMOTE on the remote system. 
  N can be 1, 2,  3, or 4, where 1 signifies a speed of 9600 baud, 2 signifies 
  19,200 baud, 3 signifies 38,400 baud, and 4 signifies 115,000 baud.

  In other words, the higher the number, the faster the data transfer
  rate across the serial link. Normally, TDRF defaults to -rs4 (the highest
  speed).

-rpN        Sets the remote serial link port.

  The -rp option specifies which port to use for the remote serial link.
  N can be either 1 or 2, where 1 stands for COM1 and 2 stands for COM2.

-w          Writes options to the TDRF executable program file.

  You can make the TDRF command-line options permanent by writing them
  back into the TDRF executable program image on disk. Do this by
  specifying the -w command-line option along with the other options you
  wish to make permanent. You will then be prompted for the name of the
  executable program.

  If you're running on DOS 3.0 or later, the prompt will indicate the
  path and file name that you executed TDRF from. You can accept this
  name by pressing Enter, or you can enter a new executable file name.
  The new name must already exist and must be a copy of the TDRF program 
  that you've already made.

  If you're running on DOS 2.x, you'll have to supply the full path
  and file name of the executable program.

  If you enter the name of an executable file that doesn't exist (a new
  filename), TDRF will create a new executable file.


TDRF commands
-------------
Following are the command names you can use with the TDRF utility. You
can use the wildcards * and ? with the COPY, COPYFROM, DEL, and DIR
commands.


COPY

  Copies files from the local system to the remote system. You can also
  type COPYTO instead of COPY. The single letter abbreviation for this
  command is T.

  If you supply a single file name after the COPY command, that file
  name will be copied to the current directory on the remote system. If
  you supply a second file name after the name of the file on the local
  system, the local file will be copied to that destination on the
  remote system. You can specify either a new file name, a directory
  name, or a drive name on the remote system. For example,

     TDRF COPY TEST1 \MYDIR
    
  copies file TEST1 from the local system to file MYDIR\TEST1 on the
  remote system.


COPYFROM

  Copies files from the remote system to the local system. The single
  letter abbreviation for this command is F.
  
  If you supply a single file name after the COPYFROM command, that file
  name will be copied from the current directory on the remote system to
  the current directory on the local system. If you supply a second file
  name after the name of the file on the remote system, the remote file
  will be copied to that destination on the local system. You can
  specify either a new file name, a directory name, or a drive name on
  the local system. For example,

     TDRF COPYFROM MYFILE ..

  copies file MYFILE from the remote system to the parent directory of
  the current directory on the local system.

     TDRF F TC*.* A:\TCDEMO
  
  copies all files beginning with TC on the current directory of the
  remote system to the TCDEMO directory on the local system's drive A.
  

DEL

  Erases a single file from the remote system. The single letter
  abbreviation for this command is E.

  If you just give a file name with no directory or drive, the file is
  deleted from the current directory on the remote system. For example,
  
     TDRF DEL XYZ
  
  removes file XYZ from the current directory of the remote system.
  

DIR

  Displays a listing of the files in a directory on the remote system.
  The single letter abbreviation for this command is D.
  
  This command behaves similarly to the equivalent DOS command. If
  you don't specify a wildcard mask, it shows all the files in the
  directory; if you do specify a mask, only those files will be listed.
  You can interrupt the directory display at any time by pressing
  Ctrl-Break.
  
  The directory listing is displayed in a format similar to that
  used by the DOS DIR command. For example,
  
     TDRF DIR \SYS\*.SYS
  
  results in a display like the following:
  
  Directory of C:\SYS

  ANSI         SYS     4833  8-23-91  6:00a
  VDISK        SYS     5190  8-23-91  6:00a
  
  
REN

  Renames a single file on the remote system. The single letter
  abbreviation for this command is R.
  
  You must supply two file names with this command: the original file
  name and the new file name. The new name can specify a different
  directory as part of the name, but not a different drive. For example,
  
     TDRF REN TEST1 \TEST2
  
  renames file TEST1 in the current directory in the remote to TEST2 in
  the root directory. This effectively "moves" the file from one
  directory to another. You can also use this command to simply rename a
  file within a directory, without moving it to another directory.
  
  
MD

  Makes a new directory on the remote system. The single letter
  abbreviation for this command is M.
  
  You must supply the name of the directory to be created. If you don't
  supply a directory path as part of the new directory name, the new
  directory will be created in the current directory on the remote
  system. For example,
  
     TDRF MD TEST
  
  creates a directory named TEST in the current directory on the remote
  system.
  

RD

  Removes an existing directory on the remote system. The single letter
  abbreviation for this command is K.
  
  You must supply the name of the directory to be removed. If you don't
  supply a directory path as part of the new directory name, the
  directory will be removed from the current directory on the remote
  system. For example,
  
     TDRF RD MYDIR
  
  removes a directory named MYDIR from the current directory on the
  remote system.
  

CD

  Changes to a new directory on the remote system. The single letter
  abbreviation for this command is C.
  
  You must supply the name of the directory to change to. You can also
  supply a new drive to switch to, or even supply a new drive and
  directory all at once. For example,
  
     TDRF CD A:ABC
  
  makes drive A the current drive on the remote system, and switches to
  directory ABC as well.
  
  
TDRF messages
-------------
Following is a list of the messages you might encounter when working with
TDRF:

"Can't create file on local system: ___"
  You were copying a file from the remote system using the COPYFROM 
  command, but the file could not be created on the local system. 
  Either the disk is full on the local system, or the file name on the
  remote system is the same as a directory name on the local system.

"Can't modify exe file"
  The file name you specified to modify is not a valid copy of the TDRF
  utility. You can only modify a copy of the TDRF utility with the -w
  option.

"Can't open exe file to modify"
  The file name you specified to be modified can't be opened. You've
  probably entered an invalid or nonexistent file name.

"Error opening file: ___"
  The file you wanted to transfer to the remote system could not be
  opened. You probably specified a nonexistent or invalid file name.

"Error writing file: ___"
  An error occurred while writing to a file on the local system, 
  probably because the local disk is full. Try deleting enough 
  files to make room for the file you want to copy from the 
  remote system.

"Error writing file ___ on remote system"
  An error occurred while writing a file to the disk on the remote
  system, probably because the remote disk is full. Try deleting
  enough files to make room for the file you want to transfer.

"File name is a directory on remote"
  You've tried to copy a file from the local to the remote system, but
  the local file name exists as a directory on the remote system. You'll
  have to rename the file by giving a second argument to the COPY
  command.

"Interrupted"
  You've pressed Ctrl-Break while waiting for communications to be
  established with the remote system.

"Invalid command: ___"
  You've entered a command that TDRF doesn't recognize. For each
  command, you can use the DOS-style command word or the single-letter
  abbreviation.

"Invalid command line option: ___"
  You've given an invalid command-line option when starting TDRF from
  the DOS command line.

"Invalid destination disk drive"
  You've specified a nonexistent disk drive letter in your command.
  Remember that the remote system might have a different number of disk
  drives than the local system.

"No matching files on remote"
  You've done a DIR command, but either there are no files in the
  directory on the remote system, or no files match the wildcard
  specification that you gave as an argument to the DIR command.

"No remote command specified"
  You haven't specified any command on the DOS command line; TDRF has
  nothing to do.

"Too few arguments"
  You haven't supplied enough arguments for the command you
  requested. Some commands require an argument, like DEL, MD, 
  CD, RD, and so on.

"Too many arguments"
  You've specified too many arguments for the command you requested.
  No command requires more than two arguments, and some require only one.

"Wrong version of remote driver"
  You're using incompatible versions of TDRF and either TDREMOTE or
  TFREMOTE. Make sure you're using the latest version of each utility.


2. TDSTRIP: The symbol table stripping utility
==============================================
TDSTRIP.EXE lets you remove the symbol table from an executable 
program generated with debugging information. This is a faster way 
of removing the symbol table than rebuilding without debugging 
information. TDSTRIP can also remove debugging information 
from an .OBJ file. Just enter

   TDSTRIP PROGRAM.OBJ

You can also use this utility to remove the symbol table and put it in
a separate file. This is useful when you want to convert the .EXE
format program to a .COM file and still retain the debugging symbol
table. This utility puts the symbol table in a file with the extension
.TDS. Turbo Debugger looks for this file when it loads a program to
debug that doesn't have a symbol table.


TDSTRIP command-line options
----------------------------
Following is the general form of the DOS command line used to start the
Symbol Table Stripping utility, TDSTRIP:

   TDSTRIP [-s] [-c] <exename> [<outputname>]

If you don't specify the -s option, the symbol table is removed from
the .EXE file <exename>. If you specify an <outputname>, the original
.EXE file is left unchanged and a version with no symbol table is created
as <outputname>.

If you do specify the -s option, the symbol table will be put in a
file with the same name as <exename> but with the extension .TDS. If you
specify an output file, the symbol table will be put in <outputname>.

If you specify the -c option, the input .EXE file is converted into a
.COM file. If you use -c in conjunction with -s, you can convert an
.EXE file with symbols into a .COM file with a separate .TDS symbol
file. This lets you debug .COM files with Turbo Debugger while
retaining full debugging information.

You can only convert certain .EXE files into .COM files. The following
restrictions apply to the -c option of TDSTRIP: Your program must 
start at location 100 hex, and it can't contain any segment fixups.

The default extension for <exename> is .EXE. If you add an extension,
it overrides the default.

There are two default extensions for <outputname>,

o .TDS when you use the -s command-line switch
o .EXE when you don't use the -s command-line switch

If you add an extension, it overrides the defaults.

Following are some sample TDSTRIP command lines:

   TDSTRIP MYPROG

removes the symbol table from MYPROG.EXE.

   TDSTRIP -s MYPROG.OLD

removes the symbol table from MYPROG.OLD and places it in MYPROG.TDS.

   TDSTRIP MYPROG MYPROG.NEW

leaves MYPROG.EXE unchanged but creates another copy of it named
MYPROG.NEW without a symbol table.

   TDSTRIP -s MYPROG MYSYMS

removes the symbol table from MYPROG.EXE and places it in MYSYMS.TDS


TDSTRIP error messages
----------------------
Following is a list of TDSTRIP error messages:

Can't create file: ___
  TDSTRIP couldn't create the output symbol or .EXE file. Either there
  is no more room on your disk, or you specified an invalid output file
  name.
  
Can't open file: ___
  TDSTRIP could not locate the .EXE file from which you want to remove the
  symbol table.

Error reading from input exe file
  An error occurred during reading from the input executable program
  file. Your disk may be unreadable. Try the operation again.

Error writing to output file: ___; disk may be full
  TDSTRIP couldn't write to the output symbol or executable file. This
  usually happens when there is no more room on your disk. You will have
  to delete some files to make room for the file created by TDSTRIP.

Input file is not an .exe file
  You've specified an input file name that isn't a valid executable
  program. You can strip symbols only from .EXE programs because these
  are the only ones that the linker can put a symbol table in. Programs 
  in .COM file format don't have symbol tables and can't be processed by
  TDSTRIP.

Invalid command-line option: ___
  You've given an invalid command-line option when starting TDSTRIP
  from the DOS command line.

Invalid exe file format
  The input file appears to be an .EXE format program file, but
  something is wrong with it. You should build the program again.

Not enough memory
  Your system doesn't have enough free memory for TDSTRIP to load and
  process the .EXE file. This only happens in extreme circumstances
  (TDSTRIP has very modest memory requirements). Try rebooting your 
  system and running TDSTRIP again. You might have previously run a
  program that allocated some memory that won't be freed until you reboot.

Program does not have a symbol table
  You've specified an input file that's a valid .EXE file, but it
  doesn't have a symbol table.

Program does not have a valid symbol table
  The symbol table at the end of the .EXE file isn't a valid symbol 
  table. This can happen if you try to use TDSTRIP on a program
  created by a linker other than TLINK. Rebuild the program with
  Borland Pascal so it gets linked with TLINK.

Too many arguments
  You can supply a maximum of two arguments to TDSTRIP, the first being
  the name of the executable program, and the second being the name of
  the output file for symbols or the executable program.

You must supply an exe file name
  You've started TDSTRIP without giving it the name of an .EXE program
  file whose symbol table you want to strip.


3. TDMAP: The .MAP file utility
===============================
The TDMAP utility takes a .MAP file--an ASCII file created by the
linker containing all public symbols of a program--and appends it to
the .EXE file in Turbo Debugger format.

The syntax for using TDMAP is

   TDMAP <filename> [/E<sourceextension>]

TDMAP reads <filename>.MAP and adds debugging information to
<filename>.EXE. For example, if you wanted to append debugging 
records to a program called HELLO.PAS, you could enter

   TDMAP hello /Ec

Note that the <sourceextension>, preceded with /E, is optional.


4. TDUMP: The file dumping utility
==================================
The TDUMP utility program produces a file dump that shows the 
structure of a file.

TDUMP breaks apart a file structurally and uses the file's extension to
determine the output display format. TDUMP recognizes many file formats, 
including .EXE, .OBJ, and .LIB files. If TDUMP doesn't recognize an 
extension, it produces a hexadecimal dump of the file.  You can control 
the output format by using command-line options when you start the 
program. (These options are described later).

TDUMP's ability to peek at a file's inner structure displays not only
a file's contents, but also how a file is constructed. Moreover,
because TDUMP verifies that a file's structure matches its extension,
you can also use TDUMP to test file integrity.


TDUMP syntax
------------
The syntax for TDUMP is

   TDUMP [<options>] <Inputfile> [<Listfile>] [<options>]

<Inputfile> is the file whose structure you want to display (or "dump").
<Listfile> is an optional output file name (you can also use the standard
DOS redirection command ">"). <options> stands for any of the TDUMP
options discussed in the next section.


TDUMP command-line options
--------------------------
You can use several optional switches with TDUMP, all of which start with
a hyphen or a forward slash. The following two examples are equivalent:

   TDUMP -el -v demo.exe

   TDUMP /el /v demo.exe


  The -a and -a7 options
  ----------------------
  TDUMP automatically adjusts its output display according to the file type.
  You can force a file to be displayed as ASCII by including the -a or -a7 
  option.

  -a  produces an ASCII file display, which shows the offset and the contents
      in displayable ASCII characters. A character that is not displayable 
      (like a control character) appears as a period.

  -a7 converts high-ASCII characters to their low-ASCII equivalents. This 
      is useful if the file you are dumping sets high-ASCII characters as
      flags (WordStar files do this).


  The -b# option
  --------------
  The -b# option allows you to display information beginning at a specified
  offset.  For example, if you wanted a dump of MYFILE starting from offset
  100, you would use:

     TDUMP -b100 MYFILE


  The -e, -el, -er, and -ex options
  ---------------------------------
  All four options force TDUMP to display the file as an executable
  (.EXE) file.

  An .EXE file display consists of information contained within a file
  that is used by the operating system when loading a file.  If symbolic
  debugging information is present, TDUMP displays it.

  TDUMP displays information for DOS executable files, NEW style executable
  files ( Microsoft Windows and OS/2 .EXEs and DLLs ), and Linear Executable
  files.

  -el suppresses line numbers in the display.

  -er prevents the relocation table from displaying.

  -ex prevents the display of New style executable information.
      This means TDUMP will only display information for the DOS
      "stub" program.


  The -h option
  -------------
  The -h option displays the dump file in hexadecimal (hex) format.  Hex
  format consists of a column of offset numbers, 16 columns of hex numbers,
  and their ASCII equivalents (a period appears where no displayable ASCII
  character occurs).

  If TDUMP doesn't recognize the input file's extension, it displays the
  file in hex format (unless an option is used to indicate another format).


  The -l option
  -------------
  The -l option displays the output file in library (.LIB) file format.
  A library file is a collection of object files (see the -o option for
  more on object files). The library file dump displays library-specific
  information, object files, and records in the object file.


  The -m option
  -------------
  The -m option leaves C++ names that occur in object files, executable
  files, and Turbo Debugger symbolic information files in "mangled" format.
  This option is helpful in determining how the C++ compiler "mangles"
  a given function name and its arguments.


  The -o, -oc, -ox, and -oi options
  ---------------------------------
  -o  displays the file as an object (.OBJ) file. An object file
      display contains descriptions of the command records that pass
      commands and data to the linker, telling it how to create an .EXE
      file.

      The display format shows each record and its associated data on a
      record-by-record basis.

  -oc causes TDUMP to perform a cyclic redundancy test (CRC) on each 
      encountered record. The display differs from the -o display only
      if an erroneous CRC check is encountered (the TDUMP CRC value differs
      from the record's CRC byte).

  -ox<id> excludes designated record types from the object module dump.
          <id> is the record name that is not to be displayed. For instance,

            TDUMP -oxPUBDEF MYMODULE.OBJ

          produces an object module display for MYMODULE.OBJ that excludes the
          PUBDEF records.

  -oi<id> includes only specified record types in the object module dump.
          <id> is the name of the record to be displayed. For instance,

            TDUMP -oiPUBDEF MYMODULE.OBJ

          produces an object module display for MYMODULE.OBJ that displays 
          only the PUBDEF records.

  The -ox and -oi options are helpful in finding errors that occur during
  linking.   By examining the spelling and case of the EXTDEF symbol and 
  the PUBDEF symbol, you can resolve many linking problems. For instance, 
  if you receive an "unresolved external" message from the linker, use 
  "TDUMP -oiEXTDEF" to display the external definitions occurring in the 
  module causing the error.  Then, use "TDUMP -oiPUBDEF" on the module 
  containing the public symbol the linker could not match.

  Another use for the -oi switch is to check the names and sizes
  of the segments generated in a particular module.  For instance,

    TDUMP -oiSEGDEF MYMODULE.OBJ

  displays the names, attributes, and sizes of all of the segments
  in MYMODULE.


  The -v option
  -------------
  The -v option is used for verbose display.  If used with an .OBJ or .LIB
  file, TDUMP produces a hexadecimal dump of the record's contents without
  any comments about the records.


If you use TDUMP on a Turbo Debugger symbol table, it displays the 
information tables in the order in which it encounters them.  TDUMP 
doesn't combine information from several tables to give a more meaningful
display on a per-module basis.


5. TDNMI: The utility to reset the breakout-switch
==================================================
Periscope users: Use TDNMI if you have a Periscope I board and want to
use its breakout switch with Turbo Debugger. TDNMI is a small TSR
program that periodically resets the breakout-switch latch on the
Periscope board. Use the /p command-line option to set the board's
base address if it is different from the default address of 300.

If you are using a PC clone that disables the NMI interrupt, you can 
install the TDNMI resident utility to clear the NMI every half second. 
You'll need to do this if you're using a breakout switch on such a system.


6. TDMEM: The memory display utility
====================================
TDMEM displays the current availability of your computer's memory,
including expanded or extended memory, if it exists, and conventional 
memory.  This information is useful when debugging TSRs and device drivers.  
You can use the File|Table Relocate option in Turbo Debugger to specify 
a base segment address for the current symbol table that is shown when 
running TDMEM.


7. TDDEV: The device driver display utility
===========================================
TDDEV produces a report showing the device drivers loaded into the system
as well as how much memory each uses and what interrupt vectors are taken
over.  This report is useful when debugging device driver applications.


8. TDWINST: the TDW configuration program
=========================================
This description consists of the following sections:

8.1 Introduction
8.2 Running TDWINST
8.3 Setting the screen colors
8.4 Setting TDW display parameters
8.5 TDW options
8.6 Setting the mode for display
8.7 Command-line options and installation equivalents
8.8 When you're through


8.1 Introduction
----------------
TDW is ready to run as soon as you install it. However, you can change
many of the default settings by running the customization program called
TDWINST. You also can change some of the options using command-line
options when you start TDW. If you find yourself frequently
specifying the same command-line options, you can make those options
permanent by running the customization program.

The customization program enables you to set the following items:

o window, dialog box, screen, and menu colors

o display options: display swapping, integer format, beginning
  display (source or assembler code), screen lines, tab size,
  maximum tiled Watches size, fast screen update, 43/50-line mode,
  user screen updating, log list length, floating precision, and range
  inspect.

o directories to search for source files and the TDW help and
  configuration files

o user input and prompting parameters: history list length, beep on
  error, full trace history, mouse enable, and control-key shortcuts

o Source debugging language options

o Display mode


8.2 Running TDWINST
-------------------
 _______________________
| Colors                |
| Display...            |
| Options               |
| Mode for display      |
| Save                  |
| Quit                  |
|_______________________|

To run the customization program, enter TDWINST at the DOS prompt
or run it using the Windows Program Manager File|Run command. As
soon as TDWINST comes up, it displays its main menu. You can either
press the highlighted first letter of a menu option or use the
arrow keys to move to the item you want and then press Enter. For
instance, press D to change the display settings. Use this same
technique for choosing from the other menus in the installation
utility. To return to a previous menu, press Esc. You may have to
press Esc several times to get back to the main menu.


8.3 Setting the screen colors
-----------------------------
Choose Colors from the main menu to bring up the Colors menu. It
offers you two choices: Customize and Default Color Set.


Customizing screen colors
=========================

If you choose Customize, a third menu appears, with options for
customizing windows, dialog boxes, menus, and screens.


Windows
_______

To customize windows, choose the Windows command. This opens a
fourth menu, from which you can choose the kind of window you want
to customize: Text, Data, Low Level (for example, the CPU window),
and Other (for example, the Breakpoints window). Choosing one of
these options brings up yet another menu listing the window
elements, together with a pair of sample windows (one active, one
inactive) in which you can test various color combinations.

When you select an item you want to change, a palette box pops up
over the menu. Use the arrow keys to move around in the palette
box. As you move the selection box through the various color
choices, the window element whose color you are changing is updated
to show the current selection. When you find the color you like,
press Enter to accept it.

TDW maintains three color tables: one for color, one for black and
white, and one for monochrome. You can only change one set of
colors at a time, based on your current video mode and display
hardware. So, if you are running on a color display and want to
adjust a black-and-white table, first set your video mode to
black and white by typing MODE BW80 at the DOS prompt, and then run
TDWINST.  To reset your terminal to a color display type MODE CO80.


Dialog boxes
____________

If you want to edit dialog box colors, choose Dialogs from the
Customize menu.  A menu appears listing dialog box and menu
elements, with a sample dialog box for you to experiment with.

As with the Windows menu, choosing an item from the current menu
opens a palette from which you can choose the color for that item.


Menus
______
 ________________________
| Menu background        |
| Standard item          |
| Active item background |
| Active item foreground |
| Hot letter             |
|________________________|
| Status foreground      |
| Status background      |
|________________________|

If you choose Menus from the Customize menu, a menu of menu options
opens, along with a sample menu. Choosing an item from the menu
causes the usual palette to appear.



Screen
______

 ________________________
| Pattern for background |
|________________________|
| Pattern background     |
| Pattern foreground     |
| Window move            |
|________________________|

Choosing Screen from the Customize menu opens a menu from which you
can access another menu with screen patterns and palettes for
screen elements, as well as a sample screen background on which to
test them.


The default colors
==================

If you choose Default Color Set from the Colors menu, an active
text window (Text Window) and an inactive window (Another Window)
appear onscreen, so you can see what the default colors for their
elements are.  The Accept color set window also appears.  From this
window you can choose to view the default colors for Text, Data,
Low level or Other displays.



8.4 Setting TDW display parameters
----------------------------------
Choose Display from the main menu to bring up the Display Options
dialog box.

The move between options use the TAB key.  To toggle the radio
buttons use the arrow keys and to select a check box use the
spacebar.

Some of the display options can be set from the command line when
you start TDW. See the Command-line options section later in this
chapter for a table of TDW command-line options and corresponding
TDWINST settings.


Display Swapping
================

You use the Display Swapping radio buttons to control how TDW
switches between its own display and the output of the program
you're debugging. Using the arrow keys, you can toggle between the
following settings:

Smart     Swap to the User screen only when display output might
          occur. TDW swaps the screens any time that you step over a
          routine, or if you execute any instruction or source line
          that appears to read or write video memory. This is the
          default option.

Always    Swap to the User screen every time the user program runs.
          Use this option if the Smart option is not catching all the
          occurrences of your program writing to screen. If you choose
          this option, the screen flickers every time you step through
          your program, since TDW's screen is replaced for a short
          time with the User screen.


Integer Format
==============

The Integer Format radio buttons let you set how integers are
displayed. You can toggle between the following options:

Hex        Chooses hexadecimal number display.

Decimal    Chooses decimal number display.

Both       Displays both hexadecimal and decimal.


Beginning Display
=================

The Beginning Display radio buttons determines the language in
which your program is displayed when TDW starts. They have the
following settings:

Source     Source startup: Your program's startup code runs, and you
           start in a Module window, where your source code begins.


Assembler
           Assembler startup: None of your program is executed, and a
           CPU window shows the first instruction of your program's
           startup code.



Screen Lines
============

Use these radio buttons to toggle whether TDW should start up with
a display screen of 25 lines or a display screen of 43 or 50 lines.

Only the EGA and VGA can display more than 25 lines.


Tab Size
========

In this input box, you can set the number of columns between tab
stops in a text or source file display. You are prompted for the
number of columns (a number from 1 to 32); the default is 8.


Maximum Tiled Watch
===================

This input box sets the number of lines that the Watches window can
expand to when it's in Tiled mode. You are prompted for the number
of lines (1 to 20).


Fast Screen Update
==================

The Fast Screen Update check box lets you toggle whether your
displays will be updated quickly. You can choose this option by
pressing the spacebar while Fast Screen Update is highlighted.
Toggle this option off if you get "snow" on your display with fast
updating enabled. You need to disable this option only if the "snow"
annoys you. (Some people prefer the snowy screen because it gets
updated more quickly.)


Permit 43/50 Lines
==================

Turning this check box on allows big (43/50-line) display modes. By
default this option is on.  However, if you turn it off by pressing
the spacebar, you save approximately 8K, since the large screen
modes need more window buffer space in TDW. This option might be
helpful if you are debugging a very large program that needs as
much memory as possible to execute in. When the option is disabled,
you won't be able to switch the display into 43/50-line mode even
if your system is capable of handling it.


International Sort
==================

If this check box is selected, all items in list boxes are sorted
according to the COUNTRY setting in your CONFIG.SYS.(in DOS) or the
language indicated in the Windows Control Panel's International
dialog box (in Windows).  For more information about setting the
current country or language, refer to your DOS or Windows Users Guide.

If International Sort is not selected, list box entries are sorted
according to the ASCII values (in DOS) or the ANSI values (in Windows)
of the items in the box.


User Screen Updating
====================

The User Screen Updating radio buttons set how the User screen is
updated when TDW switches between its screen and your program's
User screen. There are two settings:

Other Display    Runs TDW on the other display in your system. If
                 you have both a color and monochrome display
                 adapter, this option lets you view your program's
                 screen on one display and TDW's on the other.

Swap             Uses a single display adapter and display page,
                 and swaps the contents of the User and TDW screens
                 in software. This method, the default for updating
                 user screens, is the slowest method of display
                 swapping, but is the most protective and least
                 disruptive. If you are debugging a program that
                 uses multiple display pages, like a graphics
                 program, use this option.


Log List Length
===============

Use this input box to set how many entries are saved in the log
file. The maximum number is 200; the minimum is 4.


Floating Precision
==================

Use this input box to set the precision (the number of digits after
the decimal point) of any floating point data TDW inspects. This
number can range from 1 to 32.


Range Inspect
=============

Use this input box to set the number of elements TDW normally
displays for a pointer after you choose the local menu Range
command in an Inspector window. The default value is five, which
means that TDW displays only the first five elements pointed to
unless you indicate a different range by using the local menu Range
command. The maximum value you can enter for the range is 4096.


If any of the input boxes on the Display Options dialog box are empty
when you try to exit, you will be prompted to enter a value before you
may exit.


8.5 TDW options
---------------
 ______________________
|Directories...        |
|Input & prompting...  |
|Source debugging...   |
|______________________|

The Options command in the main menu opens a menu of options, which
in turn open dialog boxes for you.



Directories
===========

This dialog box contains input boxes in which you can enter:

Source directories     Sets the list of directories TDW searches for
                       source files.

Turbo directory        Sets the directory that TDW will look in for
                       its help and configuration files.


Input and Prompting
===================

This dialog box lets you set options that control how you input
information to TDW, and how TDW prompts you for information. It
also lets you decide if TDW is to keep a full history of your
debugging session.


History List Length
___________________

This input box lets you specify how many previous entries are to be
saved in a history list input box.  The default is 10.


Beep on Error
_____________

By default, TDW doesn't give a warning beep when you press an
invalid key or do something that generates an error message. The
Beep on Error check box lets you change this default.


Control Key Shortcuts
_____________________

This check box enables or disables the control-key shortcuts. When
control-key shortcuts are enabled, you can invoke any local menu
command directly by pressing the Ctrl key in combination with the
first letter of the menu item. However, in that case, you can't use
those control keys as WordStar-style cursor-movement commands.


Mouse Enabled
_____________

This check box controls whether TDW supports a mouse.


Full trace history
__________________

Pick this option if you want TDW to keep a full history list of your
debugging session. A history list lets you backtrace through your
source code, but also slows down execution of your code.


Source Debugging
================

The Source Debugging dialog box lets you specify what language TDW
will use for evaluating expressions, enables and disables symbol
case sensitivity, and controls special support for Windows message
debugging in ObjectWindows programs.


Language
________

The Language radio buttons toggle the language TDW uses for
evaluating expressions:

Source Module     Choose what language to use based on the languages
                  of the current source module.  This is the default.

C                 Always use C expressions, no matter what language the
                  current module was written in.

Pascal            Always use Pascal expressions, no matter what language
                  the current module was written in.

Assembler         Always use assembler expressions, no matter what
                  language the current module was written in.


Ignore Symbol Case
__________________

If this check box is on, TDW treats uppercase and lowercase the same.
If it is off, case sensitivity is in effect.


OWL window messages
___________________

If this option isn't checked (the default), there's no special support
for Windows message debugging in ObjectWindows programs, and TDW won't
recognize any of the window objects in your program as Windows procedures.
Instead, you're required to use window handles when setting Windows message
breakpoints (and to know enough about ObjectWindows to be able to locate
a handle).

If this check box is on, TDW provides special support for Windows message
breakpoints in ObjectWindows programs. This support allows you to use the
name of a window object from your program when setting Windows message
breakpoints. However, debugging with Windows message breakpoints set is
likely to be slower than when the option is off.


8.6 Setting the mode for display
--------------------------------
 ___________________
| Default           |
| Color             |
| Black and white   |
| Monochrome        |
| LCD               |
|___________________|

Choosing Mode for Display from the main menu enables you to select
the display mode for your system.


Default            TDW detects the kind of graphics adapter on your
                   system and selects the display mode appropriate for
                   it.


Color              If you have an EGA or VGA graphics adapter and choose
                   this option as your default, the display will be in
                   color.

Black and White    If you have an EGA or VGA graphics adapter and
                   choose this option, the display will be in black
                   and white.

Monochrome         Choose this option if you are using a color monitor
                   with a Hercules  adapter.

LCD                Choose this option if you have an LCD monitor.


8.7 Command-line options and installation equivalents
-----------------------------------------------------
Some of the options described in the previous section can be over-
ridden when you start TDW. The following table shows the
correspondence between TDW command-line options and the TDWINST
program command that permanently sets that option.

TDW command-line options
_____________________________________________________________________
Option          TDWINST menu path               Dialog box and option
_____________________________________________________________________


                Display                         Display Options
  -do                                             (X) Other
  -ds                                             (X) Swap

                Display                         Display Options
  -l                                              (X) Assembler
  -l-                                             (X) Source

                Options|Input and Prompting     User Input and Prompting
  -p                                              [X] Mouse Enabled
  -p-                                             [ ] Mouse Enabled

                Options|Directories             Directories
  -sd                                             Source Directories
  -t                                              Turbo Directory
______________________________________________________________________

For example, when starting TDW from the DOS prompt you can type:

   win tdw -p

This command loads Windows and enables use of the mouse in TDW.
Remember, you must type "win" when starting TDW from the DOS prompt
because TDW requires Microsoft Windows in order to run.  Note that
TDW.EXE must be in a directory in your DOS path in order for this
command to work.

For a list of all the command-line options available for TDW.EXE or
TDWINST.EXE, enter the program name followed by -h or -?:


8.8 When you're through
-----------------------
Saving changes
==============
 ____________________________
| Save configuration file... |
| Modify tdw.exe             |
|____________________________|

When you have set the TDW options to the way you want, choose
Save from the main menu to display saving options.


Save Configuration File
_______________________

If you choose Save Configuration File, a dialog box opens, initialized
to the default configuration file TDCONFIG.TDW. You can accept this
name by pressing Enter, or you can type a new configuration file name.
If you specify a different file name, you must load that configuration
using the -c command-line option when you start TDW.

For example, to start TDW using the configuration file MYCFG.TDW, you
have several options.  If Windows is already loaded, type the following
from the Windows Program Manager's File|Run command line:

   tdw -cmycfg.tdw myprog

If you are starting TDW directly from the DOS command line and want to
use the configuration MYCFG.TDW, Windows must be loaded concurrently by
typing:

   win tdw -cmycfg.tdw myprog

You can also use the TDW Options|Restore Options command to load a
configuration once you have started TDW.


Modify TDW.EXE
______________

If you choose Modify TDW.EXE, any changes that you have made to the
configuration are saved directly into the TDW executable program
file TDW.EXE. The next time you run TDW, those settings will be
your defaults.

If at any time, you want to return to the default configuration
that TDW is shipped with, copy TDW.EXE from your master disk onto
your working system disk, overwriting the TDW.EXE file that you
modified.


Exiting TDWINST
===============

To get out of TDWINST at any time, choose Quit from the main menu.

