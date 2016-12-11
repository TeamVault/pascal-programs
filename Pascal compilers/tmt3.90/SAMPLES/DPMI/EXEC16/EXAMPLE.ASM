        .286
        .MODEL small

        .CODE

        ; -----------------------------------------
        ; This is 16-bit Real Mode procedure
        ; to fill the text screen with white stars
        ; -----------------------------------------

FillScr PROC
        call    far ptr @FillProc
        mov     ax, 04C00h
        int     21h
@FillProc:
        ; -----------------    set VGA text mode 80x25 for sure...
        mov     ax, 03h
        int     10h
        ; -----------------    hide cursor
        mov     ax, 100h
        xor     bx, bx
        mov     cx, 2000h
        int     10h
        ; ------------------   fill the screen
        cld
        mov     ax, 0B800h   ; <- color text mode video segment
        mov     es, ax       ; <- load video segment
        xor     di, di       ; <- set offset to zero
        mov     cx, 80*2*25  ; <- size of color text video memory
        mov     ax, 220Fh    ; <- this is white star
        rep     stosb        ; <- do it!
        ; -------------------  wait a key
        xor     ax, ax
        int     16h
        ; -------------------  show cursor
        mov     ax, 100h
        xor     bx, bx
        mov     cx, 607h
        int     10h
        retf                 ; <- far frame return
FillScr ENDP
        END
