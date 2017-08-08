 ; #########################################################################
      .386
      .model flat, stdcall  ; 32 bit memory model
      option casemap :none  ; case sensitive

      include bitblt.inc    ; local includes for this file
; #########################################################################

.data

.code
start:
    invoke GetModuleHandle, NULL
    mov hInstance, eax

    invoke GetCommandLine
    mov CommandLine, eax
    
	invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT

    invoke ExitProcess,eax

; #########################################################################


WinMain proc hInst     :DWORD,
             hPrevInst :DWORD,
             CmdLine   :DWORD,
             CmdShow   :DWORD

      ;====================
      ; Put LOCALs on stack
      ;====================

      LOCAL win_class			:WNDCLASSEX
      LOCAL msg					:MSG
      LOCAL win_width			:DWORD
      LOCAL win_height			:DWORD
      LOCAL win_coordX			:DWORD
      LOCAL win_coordY			:DWORD

      ;==================================================
      ; Fill WNDCLASSEX structure with required variables
      ;==================================================

	  ;loading icon
      invoke LoadIcon,hInst,500    ;icon id 500 
      mov win_class.hIcon, eax
	  mov win_class.hIconSm, eax

	  ;loading cursor
	  invoke LoadCursor,hInst,101	;cursor id 101
      mov win_class.hCursor,        eax

      szText szClassName,"Project_Class"

	  ;setting properties of win_class
      mov win_class.cbSize,         sizeof WNDCLASSEX
      mov win_class.style,          CS_BYTEALIGNWINDOW
      mov win_class.lpfnWndProc,    offset WndProc
      mov win_class.cbClsExtra,     NULL
      mov win_class.cbWndExtra,     NULL
      m2m win_class.hInstance,      hInst
      mov win_class.hbrBackground,  COLOR_BTNFACE+2			;background color
      mov win_class.lpszMenuName,   NULL
      mov win_class.lpszClassName,  offset szClassName

      invoke RegisterClassEx, ADDR win_class

      ;================================
      ; Centre window at following size
      ;================================

      mov win_width, 750
      mov win_height, 500
	  mov win_coordX, 0
	  mov win_coordY, 0

      invoke GetSystemMetrics,SM_CXSCREEN		;width of the screen of the primary display monitor in pixels
      invoke TopXY,win_width,eax
      mov win_coordX, eax

      invoke GetSystemMetrics,SM_CYSCREEN		;height of the screen of the primary display monitor in pixels
      invoke TopXY,win_height,eax
      mov win_coordY, eax

      invoke CreateWindowEx,WS_EX_LEFT,
                            ADDR szClassName,
                            ADDR szDisplayName,
                            WS_OVERLAPPEDWINDOW,
                            win_coordX,win_coordY,win_width,win_height,
                            NULL,NULL,
                            hInst,NULL
      mov   hWnd,eax

      invoke LoadMenu,hInst,600  ; menu ID
      invoke SetMenu,hWnd,eax

      invoke ShowWindow,hWnd,SW_MAXIMIZE
      invoke UpdateWindow,hWnd


      ;===================================
      ; Loop until PostQuitMessage is sent
      ;===================================

    .WHILE TRUE 
        invoke GetMessage, addr msg, NULL, 0, 0 
        .if(getUserInp!=1)
			call gamePlay
		.endif
		.BREAK .IF (!eax) 
        invoke TranslateMessage, addr msg 
        invoke DispatchMessage, addr msg 
    .ENDW 

    return msg.wParam

WinMain endp

; #########################################################################
StaticImage proc lpText:DWORD,hParent:DWORD,
                 a:DWORD,b:DWORD,wd:DWORD,ht:DWORD,ID:DWORD

    invoke CreateWindowEx,WS_EX_NOACTIVATE,
            ADDR statClass,lpText,
            WS_CHILD or WS_VISIBLE or SS_BITMAP,
            a,b,wd,ht,hParent,ID,
            hInstance,NULL

    ret

StaticImage endp

; #########################################################################
moveDown PROC

mov ecx,0
mov esi,99
.WHILE esi>9

.IF (BoardArr[esi]==0 && BoardArr[esi-10]>0)		;non consecutive zeros movedown
mov eax,0
mov al,BoardArr[esi-10]					;swapping
mov BoardArr[esi-10],0
mov BoardArr[esi],al
mov ecx,1

.ELSEIF (BoardArr[esi]==0 && BoardArr[esi-10]==0)	;consecutive zeros movedown
mov eax,esi
again:
sub eax,10
cmp BoardArr[eax],0
jne outJump
cmp eax,10
js outJump
jmp again
outJump:
mov ebx,0
mov bl,BoardArr[eax]					;swapping
mov BoardArr[esi],bl
mov BoardArr[eax],0
mov ecx,1

.ENDIF
dec esi
.ENDW
mov eax,ecx
RET
moveDown ENDP

; ##################################################################################
popPairs PROC

mov esi,0
.WHILE esi < 100		;checking for horizontal pairs

movzx eax,BoardArr[esi]
.IF ((BoardArr[esi+1]==al)&&(BoardArr[esi+2]==al))
.WHILE(BoardArr[esi]==al)
mov ebx,eax
mov ecx,10
mov edx,0
mul ecx
mov BoardArr[esi],al
inc esi

mov eax,esi
div ecx
.IF edx==0
jmp breakloop
.ENDIF 

mov eax,ebx
.ENDW	
.ELSE
inc esi
mov eax,0
mov edx,0
mov ebx,0
mov eax,esi
mov ebx,10
div ebx
.IF(edx>7)
inc eax
mul ebx
mov esi,eax
.ENDIF
breakloop:
.ENDIF
.ENDW

mov esi,0
.WHILE esi < 100		;checking for vertical pairs

movzx eax,BoardArr[esi]		;checking already paired values
.IF eax<=Ctype
mov ecx,10
mul ecx
mov ecx,eax
.ELSE
mov ecx,10
div ecx
mov ecx,eax
.ENDIF
movzx eax,BoardArr[esi]

.IF ((BoardArr[esi+10]==al || BoardArr[esi+10]==cl)&&(BoardArr[esi+20]==al || BoardArr[esi+20]==cl))
mov ebx,esi
.WHILE(BoardArr[ebx]==al || BoardArr[ebx]==cl)
push eax
mov edx,10
mul edx
mov BoardArr[ebx],al
add ebx,10
pop eax
.ENDW	
.ENDIF
inc esi
.ENDW

;;;;popping values;;;;
mov esi,0
.WHILE esi < 100
mov ebx,Ctype
.IF(BoardArr[esi]>bl)
mov BoardArr[esi],0
inc score_count
mov eax,1
.ENDIF
inc esi
.ENDW

RET
popPairs ENDP


; #########################################################################
genNewCandies PROC

invoke GetTickCount
invoke nseed,eax

mov esi,0
.WHILE esi<100

.IF (BoardArr[esi]==0)
	invoke nrandom,6
	inc eax
	mov BoardArr[esi],al
.ENDIF

inc esi
.ENDW

RET
genNewCandies ENDP
; ########################################################################
swap PROC

mov eax,0
mov ebx,0
mov ecx,0
mov al,Inp1
mov bl,Inp2
mov dl, BoardArr[eax]
mov cl, BoardArr[ebx]
mov BoardArr[eax],cl
mov BoardArr[ebx],dl

RET
swap ENDP

; ########################################################################
checkPair PROC
mov eax,0
mov ebx,0
mov ecx,0
mov esi,0

call swap			;swapping values

.WHILE esi < 99		;checking for pairs

movzx eax,BoardArr[esi]
.IF ((BoardArr[esi+1]==al) &&(BoardArr[esi+2]==al))
mov eax,0
mov ecx,10
mov edx,0
mov eax,esi
div ecx
cmp edx,7
.IF edx<=7
mov eax,1
jmp found
.ENDIF
;jbe found
inc esi
.ELSEIF ((BoardArr[esi+10]==al) &&(BoardArr[esi+20]==al))
mov eax,1
jmp found
.ELSE
inc esi
.ENDIF
.ENDW
mov eax,0
call swap	;if no pairs found then revert swap
RET
found:		;if found kepp swap
mov eax,1
RET
checkPair ENDP

; ########################################################################
checkMove PROC
mov eax,0
mov al,Inp1
sub al,Inp2

.IF (eax==1 || eax==255)	;checking for horizontal swap
	mov eax,0				;inner check to prevent last col and first col swap
	mov ecx,0
	mov cl,10
	mov al, Inp1
	div cl
	mov bl,al
	mov eax,0
	mov cl,10
	mov al, Inp2
	div cl
	cmp al,bl
	jne endCheckMove		;wrong input end move
	jmp check2				;first check pass

.ELSEIF (eax==10 || eax==246)
	jmp check2			;first check pass

.ELSE
mov eax,0
jmp endCheckMove		;first check failed, wrong input

.ENDIF
 
check2:				;second check, pair check
call checkPair
RET
endCheckMove:
mov eax,0
RET
checkMove ENDP

; ########################################################################
;update_maze PROC hWin:DWORD

;	ret
;update_maze ENDP

;#############################################################################

getInput PROC
	.IF Inp1==100
		invoke Beep, 1000, 300  ;beep for testing
		movzx ecx,btnID
		mov Inp1,cl
		;mov btnID,100
	.ELSEIF Inp2==100
		invoke Beep, 600, 300  ;beep for testing
		movzx ecx,btnID
		mov Inp2,cl
		mov getUserInp,2
	.ENDIF
RET
getInput ENDP

;#############################################################################
gamePlay PROC
	LOCAL retAdd:DWORD
	LOCAL hWin:DWORD
	pop ecx
	mov retAdd,ecx

	.if(getUserInp==2)
		call checkMove
		mov Inp1,100
		mov Inp2,100
		.if(eax==0)
			mov getUserInp,1
		.elseif(eax==1)
			mov getUserInp,0
			dec moves
		.endif
	.endif
		.if(data==0)
			call genNewCandies
			mov data,1
			jmp printNow

		.elseif(data==1)
			call popPairs
			.IF eax!=1
				mov getUserInp,1
			.ENDIF
			mov data,2
			jmp printNow

		.elseif(data==2)
			call moveDown
			mov data,0
			jmp printNow
		.endif
	
		printNow: 
		mov paint,1
		invoke InvalidateRect, hWnd, NULL, FALSE
		invoke UpdateWindow,hWnd
		
		;.IF(eax==0)
		;call getInput
		;	call checkMove
		;.ENDIF

	mov ecx,retAdd
	push ecx
ret
gamePlay ENDP
;#############################################################################

WndProc proc hWin   :DWORD,
             uMsg   :DWORD,
             wParam :DWORD,
             lParam :DWORD

    LOCAL var    :DWORD
    LOCAL caW    :DWORD
    LOCAL caH    :DWORD
    LOCAL Rct    :RECT
    LOCAL hDC    :DWORD
    LOCAL Ps     :PAINTSTRUCT
    LOCAL buffer1[128]:BYTE  ; these are two spare buffers
    LOCAL buffer2[128]:BYTE  ; for text manipulation etc..
	LOCAL hStatImage :DWORD
	LOCAL posX :DWORD
	LOCAL posY :DWORD


    .if uMsg == WM_COMMAND
		mov eax, wParam
		.if eax == 510
			invoke dwtoa, score_count, addr score_s
			invoke MessageBox,hWin,ADDR score_s,ADDR szDisplayName,MB_OK
		.endif

    ;======== menu commands ========
    .elseif uMsg == WM_CREATE
		
		invoke BmpButton, hWin, 830, 2, 301, 301, 510

		invoke LoadBitmap, hInstance, 301
		mov score, eax
		invoke LoadBitmap, hInstance, 302
		mov border, eax

		invoke LoadBitmap, hInstance, 321
		mov move_img, eax
		invoke LoadBitmap, hInstance, 322
		mov move_border, eax

		invoke LoadBitmap, hInstance, 323
		mov win, eax
		invoke LoadBitmap, hInstance, 324
		mov lose, eax
		
		invoke LoadBitmap, hInstance, 310
		mov zero, eax
		invoke LoadBitmap, hInstance, 311
		mov one, eax
		invoke LoadBitmap, hInstance, 312
		mov two, eax
		invoke LoadBitmap, hInstance, 313
		mov three, eax
		invoke LoadBitmap, hInstance, 314
		mov four, eax
		invoke LoadBitmap, hInstance, 315
		mov five, eax
		invoke LoadBitmap, hInstance, 316
		mov six, eax
		invoke LoadBitmap, hInstance, 317
		mov seven, eax
		invoke LoadBitmap, hInstance, 318
		mov eight, eax
		invoke LoadBitmap, hInstance, 319
		mov nine, eax
		;invoke StaticImage,NULL,hWin,0,0,10,10,501
		;mov hStatImage, eax
		invoke LoadBitmap, hInstance, 201
		mov hBmp, eax
		invoke LoadBitmap, hInstance, 1
		mov red, eax
		invoke LoadBitmap, hInstance, 2
		mov blue, eax
		invoke LoadBitmap, hInstance, 3
		mov yellow, eax
		invoke LoadBitmap, hInstance, 4
		mov purple, eax
		invoke LoadBitmap, hInstance, 5
		mov green, eax
		invoke LoadBitmap, hInstance, 6
		mov orange, eax
		invoke LoadBitmap, hInstance, 7
		mov empty, eax
		;invoke SendMessage,hStatImage,STM_SETIMAGE,IMAGE_BITMAP,hBmp

		mov ebx,0
		push ebx
		
		call gamePlay

	.elseif uMsg == WM_LBUTTONDOWN && getUserInp==1 && moves>0
		invoke Beep, 800, 200  ;beep for testing
		
		invoke GetCursorPos, ADDR position
		invoke SetCursorPos, position.x, position.y
		.IF (position.x > 100 && position.x < 800 && position.y > 2 && position.y < 702)
			
			mov eax,position.x
			sub eax,100
			mov posX,eax

			mov eax,position.y
			sub eax,2
			mov posY,eax

			mov eax, posX
			mov ecx, 70
			div ecx
			mov btnID, al
			mov edx,0

			mov eax, posY
			mov ecx, 70
			div ecx
				
			mov ecx,10			
			mul ecx
			
			add btnID,al			
			movzx eax,btnID

			call getInput

	.ENDIF

	.elseif uMsg == WM_PAINT
        invoke BeginPaint,hWin,ADDR Ps
          mov hDC, eax
          invoke Paint_Proc,hWin,hDC
       invoke EndPaint,hWin,ADDR Ps   
		;invoke game, hWin
        return 0

    .elseif uMsg == WM_CLOSE

    .elseif uMsg == WM_DESTROY
        invoke PostQuitMessage,NULL
        return 0 
    .endif

    invoke DefWindowProc,hWin,uMsg,wParam,lParam

    ret

WndProc endp

; ########################################################################

TopXY proc wDim:DWORD, sDim:DWORD

    shr sDim, 1      ; divide screen dimension by 2
    shr wDim, 1      ; divide window dimension by 2
    mov eax, wDim    ; copy window dimension into eax
    sub sDim, eax    ; sub half win dimension from half screen dimension

    return sDim
	
TopXY endp

; ########################################################################

ScoreP proc 

   mov edx,0
   mov eax,score_count
   mov esi,10
   div esi

   mov scr3d,edx
   mov edx,0

   div esi
   mov scr2d,edx
   mov edx,0

   div esi
   mov scr1d,edx
   mov edx,0

ret	
ScoreP endp


; ########################################################################

MoveP proc 

   mov edx,0
   mov eax,moves
   mov esi,10
   div esi

   mov moves2d,edx
   mov edx,0

   div esi
   mov moves1d,edx
   mov edx,0

ret	
MoveP endp


; ########################################################################

Paint_Proc proc hWin:DWORD, hDC:DWORD
	LOCAL candy_x :DWORD		; x-axis position
	LOCAL candy_y :DWORD		; y-axis position
	LOCAL candy_id :DWORD		; unique for every candy to identify
	LOCAL score_x :DWORD
	LOCAL score_y :DWORD
	
    LOCAL hOld:DWORD
    LOCAL memDC :DWORD

    invoke CreateCompatibleDC,hDC
    mov memDC, eax

	mov score_x, 935
	mov score_y, 52
    
	invoke SelectObject,memDC,hBmp
    mov hOld, eax
	invoke BitBlt,hDC,0,0,1380,710,memDC,30,70,SRCCOPY	
	
	invoke SelectObject,memDC,score
    mov hOld, eax
	invoke BitBlt,hDC,830,2,1380,710,memDC,0,0,SRCCOPY	

	invoke SelectObject,memDC,border
    mov hOld, eax
	invoke BitBlt,hDC,830,52,1380,710,memDC,0,0,SRCCOPY	
	
	invoke SelectObject,memDC,move_img
    mov hOld, eax
	invoke BitBlt,hDC,830,112,1380,710,memDC,0,0,SRCCOPY	

	invoke SelectObject,memDC,move_border
    mov hOld, eax
	invoke BitBlt,hDC,830,162,1380,710,memDC,0,0,SRCCOPY	

	.IF moves > 0
	.IF paint == 1
	mov candy_x, 100
	mov candy_y, 2
	
	mov esi,0
	mov ebx,0
	.WHILE esi<100
		.WHILE ebx<10
			movzx eax,BoardArr[esi]
			mov candy_type, eax
			mov candy_id,esi
			.IF candy_type == 0
				mov candy_type,7
			.ENDIF
		
		.IF candy_type == 1
			invoke SelectObject,memDC,red
			mov hOld, eax
			invoke BitBlt,hDC,candy_x,candy_y,1380,710,memDC,0,0,SRCCOPY	
		.ELSEIF candy_type == 2
			invoke SelectObject,memDC,blue
			mov hOld, eax
			invoke BitBlt,hDC,candy_x,candy_y,1380,710,memDC,0,0,SRCCOPY	
		.ELSEIF candy_type == 3
			invoke SelectObject,memDC,yellow
			mov hOld, eax
			invoke BitBlt,hDC,candy_x,candy_y,1380,710,memDC,0,0,SRCCOPY	
		.ELSEIF candy_type == 4
			invoke SelectObject,memDC,purple
		    mov hOld, eax
			invoke BitBlt,hDC,candy_x,candy_y,1380,710,memDC,0,0,SRCCOPY	
		.ELSEIF candy_type == 5
			invoke SelectObject,memDC,green
			mov hOld, eax
			invoke BitBlt,hDC,candy_x,candy_y,1380,710,memDC,0,0,SRCCOPY	
		.ELSEIF candy_type == 6
			invoke SelectObject,memDC,orange
			mov hOld, eax
			invoke BitBlt,hDC,candy_x,candy_y,1380,710,memDC,0,0,SRCCOPY
		.ELSEIF candy_type == 7
			invoke SelectObject,memDC,empty
			mov hOld, eax
			invoke BitBlt,hDC,candy_x,candy_y,1380,710,memDC,0,0,SRCCOPY				
		.ENDIF	
	
			add candy_x,70
			inc ebx
			inc esi
		.ENDW
		mov candy_x,100
		add candy_y,70
		mov ebx,0
	.ENDW
	mov paint, 0
	invoke Sleep, 200
	.ENDIF
	.ENDIF

	call ScoreP
	call MoveP
	mov esi,0
	mov eax,scr3d
	.WHILE esi<5
		.IF eax==0
			invoke SelectObject,memDC,zero
			mov hOld, eax
			invoke BitBlt,hDC,score_x,score_y,1380,710,memDC,0,0,SRCCOPY
				
		.ELSEIF eax==1
			invoke SelectObject,memDC,one
			mov hOld, eax
			invoke BitBlt,hDC,score_x,score_y,1380,710,memDC,0,0,SRCCOPY	

		.ELSEIF eax==2
			invoke SelectObject,memDC,two
			mov hOld, eax
			invoke BitBlt,hDC,score_x,score_y,1380,710,memDC,0,0,SRCCOPY	

		.ELSEIF eax==3
			invoke SelectObject,memDC,three
			mov hOld, eax
			invoke BitBlt,hDC,score_x,score_y,1380,710,memDC,0,0,SRCCOPY	

		.ELSEIF eax==4
			invoke SelectObject,memDC,four
			mov hOld, eax
			invoke BitBlt,hDC,score_x,score_y,1380,710,memDC,0,0,SRCCOPY	

		.ELSEIF eax==5
			invoke SelectObject,memDC,five
			mov hOld, eax
			invoke BitBlt,hDC,score_x,score_y,1380,710,memDC,0,0,SRCCOPY	

		.ELSEIF eax==6
			invoke SelectObject,memDC,six
			mov hOld, eax
			invoke BitBlt,hDC,score_x,score_y,1380,710,memDC,0,0,SRCCOPY	

		.ELSEIF eax==7
			invoke SelectObject,memDC,seven
			mov hOld, eax
			invoke BitBlt,hDC,score_x,score_y,1380,710,memDC,0,0,SRCCOPY	

		.ELSEIF eax==8
			invoke SelectObject,memDC,eight
			mov hOld, eax
			invoke BitBlt,hDC,score_x,score_y,1380,710,memDC,0,0,SRCCOPY	

		.ELSEIF eax==9
			invoke SelectObject,memDC,nine
			mov hOld, eax
			invoke BitBlt,hDC,score_x,score_y,1380,710,memDC,0,0,SRCCOPY	
		.ENDIF

		inc esi
		.if esi==1
			mov eax,scr2d
			sub score_x, 35
		.elseif esi==2
			mov eax,scr1d
			sub score_x, 35
		.elseif esi==3
			mov eax,moves2d
			add score_x, 60
			mov score_y,162
		.elseif esi==4
			mov eax,moves1d
			sub score_x, 35
		.endif
		
	.ENDW

	.IF moves == 0
		.IF score_count >= 200
			invoke SelectObject,memDC,win
			mov hOld, eax
			invoke BitBlt,hDC,100,2,1380,710,memDC,0,0,SRCCOPY
		.ELSEIF 
			invoke SelectObject,memDC,lose
			mov hOld, eax
			invoke BitBlt,hDC,100,2,1380,710,memDC,0,0,SRCCOPY
		.ENDIF
	.ENDIF

    invoke SelectObject,hDC,hOld
    invoke DeleteDC,memDC
	
    return 0

Paint_Proc endp

; ########################################################################

end start
