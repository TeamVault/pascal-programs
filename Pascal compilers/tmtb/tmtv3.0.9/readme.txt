                         Pascal Compiler for MS DOS
                              [ Version 3.90 ]

                        TMT Development Corporation


Thank you for your trying this new Pascal compiler for MS DOS

This is a full 32-bit Pascal compiler for 80386/80486/Pentium Intel CPU's
and their compatibles. It produces native 32-bit protected-mode applications
which work with many popular MS-DOS extenders, such as PMODE, PMODE/W, WDOSX,
DOS/4GW etc.


Requirements
------------

       5Mb of hard disk
       MS DOS operating system v 5.0 or later
       8Mb of free XMS


Pascal Installation
-------------------

   The Pascal distribution is contained in the tmtp390d.zip archive.
   Please, read the license.doc file before the installation.

   Follow these instructions to run the installation process.

      - create the \TMTPL directory on one of the drives (we will call
        it the x: drive) using the command:
            x> md TMTPL

      - copy the tmtp390d.zip file into the TMTPL directory:

            x> copy  tmtp390d.zip x:\TMTPL
            x> x:
            x> cd \TMTPL

      - run the PKUNZIP program to decompress the tmtp390d.zip

            x:\TMTPL> pkunzip -d tmtp390d

        (the switch "-d" unpacks with subdirectories)

      - modify the PATH statement in the autoexec.bat, to include the
                x:\TMTPL\BIN
         subdirectory, if you so desire.

      - go to \TMTPL\SAMPLES\HELLO
        compile the simple test program, "HELLO.PAS", and run it:

           x:\TMTPL> tmtpc hello
           x:\TMTPL> hello

      - read the entire manual.dos file before using the compiler for
        any "real" application development.


                              TMT Development Corporation (http://www.tmt.com)