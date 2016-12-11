all: helpex.exe owlhelp.exe helpex.hlp

helpex.hlp: helpex.rtf
    hc helpex

helpex.res: helpex.rc helpex.dlg
    rc -r -I\tpw\owl;\tpw\docdemos\helpex helpex.rc

owlhelp.res: owlhelp.rc helpex.dlg
    rc -r -I\tpw\owl;\tpw\docdemos\helpex owlhelp.rc

helpex.exe: helpex.res helpex.pas
    bpc /cw /m helpex

owlhelp.exe: owlhelp.res owlhelp.pas
    bpc /cw /m owlhelp
