; #########################################################################

;     include files
;     ~~~~~~~~~~~~~
      include \MASM32\INCLUDE\windows.inc
      include \MASM32\INCLUDE\masm32.inc
      include \MASM32\INCLUDE\gdi32.inc
      include \MASM32\INCLUDE\user32.inc
      include \MASM32\INCLUDE\kernel32.inc
      include \MASM32\INCLUDE\Comctl32.inc
      include \MASM32\INCLUDE\comdlg32.inc
      include \MASM32\INCLUDE\shell32.inc
	  
;     libraries
;     ~~~~~~~~~
      includelib \MASM32\LIB\masm32.lib

      includelib \MASM32\LIB\gdi32.lib
      includelib \MASM32\LIB\user32.lib
      includelib \MASM32\LIB\kernel32.lib
      includelib \MASM32\LIB\Comctl32.lib
      includelib \MASM32\LIB\comdlg32.lib
      includelib \MASM32\LIB\shell32.lib

; #########################################################################

        ;=================
        ; Local prototypes
        ;=================
        WinMain PROTO :DWORD,:DWORD,:DWORD,:DWORD
        WndProc PROTO :DWORD,:DWORD,:DWORD,:DWORD
        TopXY PROTO   :DWORD,:DWORD
        FillBuffer   PROTO :DWORD,:DWORD,:BYTE
        Paint_Proc   PROTO :DWORD,:DWORD
		StaticImage PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
		popPairs PROTO
		PushButton PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
		genNewCandies PROTO
		update_maze PROTO :DWORD
		moveDown PROTO
		gamePlay PROTO



      ;=============
      ; Local macros
      ;=============

      szText MACRO Name, Text:VARARG
        LOCAL lbl
          jmp lbl
            Name db Text,0
          lbl:
        ENDM

      m2m MACRO M1, M2
        push M2
        pop  M1
      ENDM

      return MACRO arg
        mov eax, arg
        ret
      ENDM

	      ; ---------------------
    ; literal string MACRO
    ; ---------------------
      literal MACRO quoted_text:VARARG
        LOCAL local_text
        .data
          local_text db quoted_text,0
        .code
        EXITM <local_text>
      ENDM
    ; --------------------------------
    ; string address in INVOKE format
    ; --------------------------------
      SADD MACRO quoted_text:VARARG
        EXITM <ADDR literal(quoted_text)>
      ENDM

    .data
        szDisplayName db "Candy World",0
        CommandLine   dd 0
        hWnd          dd 0
        hInstance     dd 0
        hIcon         dd 0
        hBmp          dd 0
		statClass db "STATIC",0  
		BoardArr BYTE 100 dup(0)
		candy_type DWORD 0		; color/type of candy (1 = red, 2 = blue, 3 = yellow, 4 = purple, 5 = green, 6 = empty)
		Ctype dd 6
		red dd 0
		blue dd 0
		yellow dd 0
		purple dd 0
		green dd 0
		orange dd 0
		empty dd 0
		border dd 0
		paint dword 0
		score_count DWORD 0
		score dword 0
		data BYTE 0
		position POINT <>
		Inp1 BYTE 100
		Inp2 BYTE 100
		btnID BYTE 100
		getUserInp BYTE 0
		score_s BYTE 5 dup(?)
		score_button dd ?
		zero dd 0
		one dd 0
		two dd 0
		three dd 0
		four dd 0
		five dd 0
		six dd 0
		seven dd 0
		eight dd 0
		nine dd 0
		scr1d dd 0
		scr2d dd 0
		scr3d dd 0
		scr4d dd 0
		moves dd 30
		moves1d dd 0
		moves2d dd 0
		winScr dd 200
		move_img dd 0
		move_border dd 0
		result dd 0
		win dd 0
		lose dd 0

; ########################### Inserted modules ############################


; #########################################################################
