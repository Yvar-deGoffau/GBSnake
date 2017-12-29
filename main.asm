
INCLUDE "gbhw.inc"

;##############################################################################;
;###### GRAFIX ################################################################;
;##############################################################################;

;-------Background-------------------------------------------------------------;

gEMPTY	EQU	$20
gGRASS	EQU	$40


;-------Apple------------------------------------------------------------------;

gAPPLE	EQU	$0C


;-------Header-----------------------------------------------------------------;

gTIMER	EQU	$0D
gDEATH	EQU	$0E
gHIGH	EQU	$0F
gLVL1	EQU	$3B
gLVL2	EQU	$3C


;##############################################################################;
;###### VARIABLES #############################################################;
;##############################################################################;

;=======Sprites ===============================================================;

SECTION	"Sprites",WRAM0

o_start

;-------Head Sprites-----------------------------------------------------------;

o_head1y	ds 1	; head1 Y position
o_head1x	ds 1	; head1 X position
o_head1chr	ds 1	; head1 chr
o_head1attr	ds 1	; head1 attributes

o_head2y	ds 1	; head2 Y position
o_head2x	ds 1	; head2 X position
o_head2chr	ds 1	; head2 chr
o_head2attr	ds 1	; head2 attributes


;-------Tail Sprites-----------------------------------------------------------;

o_tail1y	ds 1	; tail1 Y position
o_tail1x	ds 1	; tail1 X position
o_tail1chr	ds 1	; tail1 chr
o_tail1attr	ds 1	; tail1 attributes

o_tail2y	ds 1	; tail2 Y position
o_tail2x	ds 1	; tail2 X position
o_tail2chr	ds 1	; tail2 chr
o_tail2attr	ds 1	; tail2 attributes


;-------bonus Sprites---------------------------------------------------------;

o_bonusy	ds 1	; bonus y position
o_bonusx	ds 1	; bonus x position... 0 is disable
o_bonuschr	ds 1	;=FC
o_bonusattr	ds 1	;=0

;-------End--------------------------------------------------------------------;

o_end


SECTION	"Highscore",WRAM0[$C100]

s_scores	ds	24	; the highscore

g_message	ds	8	; the current message (yes, that one in the window
					;  saying you just lost the game!)


;======="High" Variables=======================================================;

SECTION	"HighVariables",HRAM

;-------Vertical Blank Related-------------------------------------------------;

v_oam		ds	10	; 		routine to copy OAM's
v_flag		ds	1	;= 0 	flag to notify that a vblank occured
v_time		ds	1	;= 0	current time
v_corpse	ds	1	;= 9	tile generated as corpse
v_trail		ds	1	;= 1	tile under trail
v_eating	ds	1	;= gEMPTY	whatever shit we are eating
v_desty		ds	1	;= 0	the destination scroll (x00 for even levels, x80 for odd levels and title screen)
v_speed		ds	1	;=16	the game speed
v_newframe	ds	1	;	if this is a new frame after a step
v_head1chr	ds 	1	; head1 chr
v_head2chr	ds 	1	; head2 chr
v_tail1chr	ds 	1	; tail1 chr
v_tail2chr	ds 	1	; tail2 chr

;-------Button Related---------------------------------------------------------;

b_hold		ds	1	; 		buttons currently hold
b_prev		ds	1	;= 0	buttons previously hold
b_pressed	ds	1	; 		buttons pressed this frame
b_released	ds	1	; 		buttons released this frame

b_evH		ds	1	;= 0	next: going left/right
b_evV		ds	1	;= 0	next: going up/down

;-------Head Related-----------------------------------------------------------;

h_freeze	ds	1	; 		freeze snake head  1=freeze
h_head1x	ds	1	;=10	horizontal position head 1
h_head1y	ds	1	;= 7	vertical position head 1
h_head1adr	ds	2	; 		address head 2
h_head2x	ds	1	; 		horizontal position head 2
h_head2y	ds	1	; 		vertical position head 1
h_head2adr	ds	2	;=$9898	address head 2

h_head1dirH	ds	1	;= 1	horizontal direction head 1
h_head1dirV	ds	1	;= 0	vertical direction head 1
h_head2dirH	ds	1	;= 1	horizontal direction head 2
h_head2dirV	ds	1	;= 0	vertical direction head 2

h_eated		ds	1	; 		whatever shit we did eat


;-------Tail Related-----------------------------------------------------------;

t_freeze	ds	1	; 		freeze snake tail  1=freeze
t_tail1x	ds	1	;= 8	horizontal position tail 1
t_tail1y	ds	1	;= 7	vertical position tail 1
t_tail1adr	ds	2	;=$9898	address tail 2
t_tail2x	ds	1	;= 0	horizontal position tail 2
t_tail2y	ds	1	; 		vertical position tail 1
t_tail2adr	ds	2	;		 address tail 2


;-------Apple Related----------------------------------------------------------;

a_applex	ds	1	; 		x position apple
a_appley	ds	1	; 		y position apple
a_appleadr	ds	2	; 		tile address apple
a_ateapple	ds	1	;= 0	did I just eat an apple?
a_error		ds	1	;= 7	was there something blocking me from putting my apple?
a_dispencer	ds	1	;=0	dispence a load of apples

;-------Score------------------------------------------------------------------;

s_score		ds	3	;= LVL1 LVL2 "0"	the current score

;-------Main-------------------------------------------------------------------;

m_rstcnt	ds	1	;= 3	the counter used for resetting the game correctly
m_prevtime	ds	1	;= 0	the previous time
s_songpos	ds	1	;=$1E	the position in the song

g_justStart	ds	1	;= 0	did we just left off from the title screen
g_vidBase	ds	1	;=$98	where in memory is based the video
					; $98	for even levels,	$9A for odd levels
g_level		ds	1	;= 0	the current level
g_bonusniv	ds	1	;	the speed setting at which the bonus appears
g_bonusadr	ds	2	;=$98	the address for the bonus
g_bonuschr	ds	1	;=gEMPTY	the char under the bonus

;-------Other------------------------------------------------------------------;

v_head1dirnum	ds	1	; a temporary variable


;##############################################################################;
;###### HEADER ################################################################;
;##############################################################################;

;=======Interrupt Handler======================================================;

;-------Vertical Blank Interrupt-----------------------------------------------;

SECTION "Vblank",HOME[$0040]

	jp	vBlank		; vertical blank handled elsewhere


;-------Joypad Interrupt-------------------------------------------------------;

SECTION	"Joypad interrupt",Home[$60]

	reti			; joypad interrupt not (really) handled

	
;=======ROM Header=============================================================;

SECTION "start",HOME[$0100]	

;-------Boot Code--------------------------------------------------------------;
	nop				;first 3 bytes allowed for the init
	jp	start

;-------Nintendo Header--------------------------------------------------------;
	db	$CE,$ED,$66,$66,$CC,$0D,$00,$0B,$03,$73,$00,$83,$00,$0C,$00,$0D
	db	$00,$08,$11,$1F,$88,$89,$00,$0E,$DC,$CC,$6E,$E6,$DD,$DD,$D9,$99
	db	$BB,$BB,$67,$63,$6E,$0E,$EC,$CC,$DD,$DC,$99,$9F,$BB,$B9,$33,$3E

;-------Game Title (15 bytes)--------------------------------------------------;
	db	"Yvar's GB Snake"

;-------Color Compatibility----------------------------------------------------;
	db	$80	;	$00 = dmg	$80 = dmg+cgb	$B0 = cgb only

;-------Licencee Code----------------------------------------------------------;
	db	$00,$00	;$0000 = Homebrew

;-------SGB Support Code-------------------------------------------------------;
	db	$00	;No support

;-------Card Type--------------------------------------------------------------;
	db	$00	;No MBC
	db	$00	;32384 bytes ROM
	db	$00	;No RAM

;-------Destination Code-------------------------------------------------------;
	db	$01	;Outside Japan

;-------Old Licencee Code------------------------------------------------------;
	db	$00	;Unused

;-------Rom Version------------------------------------------------------------;
	db	$2D	;Version 0.2D

;-------Header Checksum--------------------------------------------------------;
	db	$00	;To be filled in later

;-------Game Checksum----------------------------------------------------------;
	db	$00	;To be filled in later
	db	$00	;To be filled in later


;##############################################################################;
;###### INIT ##################################################################;
;##############################################################################;

start:
	nop	
	di					; we don't want an interrupt during init


;-------Initialize Stack-------------------------------------------------------;

iIniStack
	ld	sp,	$fffe		; stack points to top of the high ram


;-------DMG Joke---------------------------------------------------------------;
	;little joke for the DMG!

iDisLCD
	ld	b,	$80			; the number of lines to scroll
	ld	c,	$00			; the current line value
.wait
	ldh	a,	[rLY]		; wait for
	cp	$90				;  vertical blank
	jr	nz,	.wait

	dec	C				; scroll down
	ld	A,	C
	ldh	[rSCY],	A

	dec	B				; decrease frame counter
	jr	nz,	.wait		;  and loop if not done


;-------Disable Screen---------------------------------------------------------;
	xor	a				; write 0
	ldh	[rLCDC],	a	;  to LCD Control Register


;-------Initialize Scroll------------------------------------------------------;

iIniScrl
	ld	a,	0 			; write 0 to scroll registers X and Y
	ldh	[rSCX],	a 		;  so visible screen is
	ldh	[rSCY],	a		;  at the top left of the background.


;-------Clear Highscores-------------------------------------------------------;

iClearScores
	ld	HL,	s_scores	; address of highscores
	ld	B,	8			; number of highscores
.loop
	ld	A,	gHIGH		; the highscore icon
	ld	[HL+],	A		;  at position x+0
	ld	A,	$30			; the "0"
	ld	[HL+],	A		;  at position x+1
	ld	[HL+],	A		;  at position x+2
	dec	B				; decrease counter
	jp	nz,	.loop		;  and loop if not done


;-------Draw message "READY? +GO"----------------------------------------------;

	ld	A,	$3				; Message "READY? +GO"
	call	gDrawMessage


;-------Clear Sprites----------------------------------------------------------;

iClearOAM
	ld	HL,	$C09F	; load end of sprite map buffer
	ld	DE,	$FE9F	; load end of real sprite map
	ld	C,	$A0		; the number of bytes to clear
	ld	A,	$00		; the value to write
.loop
	ld	[HL-],	A	; clear memory in sprite map buffer
	ld	[DE],	A	; clear memory in real sprite map
	dec	DE			; decrease pointer
	dec	C			; decrease counter
	jr	nz,	.loop	;  and loop if not done


;-------Clear Screen-----------------------------------------------------------;

iClearScreen
	ld	HL,	$98FF	; load end of screen buffer 1
	ld	DE,	$99FF	; load end of screen buffer 2
	ld	B,	$00		; 256 bytes to write
	ld	A,	gEMPTY	; load empty tile
.loop
	; grass hashing function
	;  ((address^(address>>4))*1.5)&16
	ld	A,	L
	swap	A
	xor	L
	ld	C,	A
	add	C
	add	C
	rra
	and	32
	add	32
	ld	[HL-],	A	; clear memory 
	ld	[DE],	A	; clear memory
	dec	DE			; decrease pointer
	dec	B			; decrease counter
	jr	nz,	.loop	;  and loop if not done


iMakeSplash
	ld	HL,	$9A00	; load end of screen
	ld	DE,	$9B00	; load end of screen
	ld	BC,	gSplash1+256
.loop
	ld	A,	[BC]	; load tile from splash
	ld	[HL],	A	; clear memory
	dec	BC			; decrease pointer

	; grass hashing function
	;  ((address^(address>>4))*1.5)&16
	ld	A,	L
	db	$CB,$37	
	xor	L
	ld	E,	A
	add	E
	add	E
	rra
	and	32
	add	32
	dec	L			; decrease pointer
	ld	E,	L		; copy pointer to pointer
	ld	[DE],	A	; clear memory
	jr	nz, .loop	; and loop


;-------Load Grafix------------------------------------------------------------;

iLoadGfx
	ld	bc,	(gShapesEnd-gShapes) ; number of tiles to copy
	ld	hl,	gShapes		; address of tiles to copy
	ld	de,	$8000		; address to copy to
.loop
	ld	a,	[hl+]		; load from ROM
	ld	[de],	a		; save to VRAM
	inc	de				; increase pointers
	dec	bc
	ld	a,	b			; if we have copied
	or	c				;  all tiles
	jr	nz,	.loop		;  then we don't loop


;-------Prepare Sprite DMA-----------------------------------------------------;

; copy the 10-byte sprite DMA routine to HRAM
iPrepOAMDMA
	ld	C,	$80		; destination: v_oam
	ld	B,	10		; number of bytes: 10
	ld	HL,	vDMA	; source: vDMA
.loop	
	ld	A,	[HLI]	; load from source
	ld	[C], A		; put in destination HRAM
	inc	C			; increase destination pointer
	dec	B			; decrease counter
	jr	NZ,	.loop	;  and loop
    
;-------Prepare Colors---------------------------------------------------------;

iColors
	ld	A,	$80		; load address
	ld	[$FF68], A	;  to background palette
	ld	[$FF6A], A	;  and OAM palette
	
	ld	B,	$40		; load number of colors
	ld	HL,	gColors	;  load source

.loop	
	ld	A, [HL+]	; copy the same color
	ld	[$FF69],A	;  to background palette
	ld	[$FF6B],A	;  and OAM palette
	dec	B			; decrease counter
	jr	nz,	.loop	;  and loop

;-------Prepare Variables------------------------------------------------------;
	;see doc variables for info

	;ld	A,	0
	xor	A			; load 0

	ldh	[v_flag],	A
	ldh	[v_time],	A
	ldh	[b_prev],	A
	ldh	[b_evH],	A
	ldh	[b_evV],	A
	ldh	[a_ateapple],	A
	ldh	[v_desty],	A
	ldh	[t_tail2x],	A
	ldh	[g_justStart],	A
	ldh	[g_level],	A
	ldh	[h_head1dirV],	A
	ldh	[h_head2dirV],	A
	ldh	[m_prevtime],	A
	ld	[o_bonusx],	A
	ld	[o_bonusy],	A
	ld	[a_dispencer],	A

	;ld	A,	1
	inc	A

	ldh	[h_head1dirH],	A
	ldh	[h_head2dirH],	A
	ldh	[v_trail],	A
	ldh	[v_newframe],	A

	ld	A,	3
	ldh	[m_rstcnt],	A
	ld	[o_bonusattr],	A

	ld	A,	7
	ldh	[h_head1y],	A
	ldh	[t_tail1y],	A
	ldh	[a_error],	A

	;ld	A,	8
	inc	A
	ldh	[t_tail1x],	A

	;ld	A,	9
	inc	A
	ldh	[v_corpse],	A

	;ld	A,	10
	inc	A
	ldh	[h_head1x],	A

	ld	A,	13
	ld	[v_speed],	A

	ld	A,	$7E
	ldh	[s_songpos],	A

	ld	A,	gEMPTY
	ldh	[v_eating],	A
	ldh	[g_bonuschr],	A

	ld	A,	gLVL1
	ldh	[s_score],	A

	ld	A,	gLVL2
	ldh	[s_score+1],	A

	ld	A,	$31
	ldh	[s_score+2],	A

	ld	A,	$98
	ldh	[g_vidBase],	A
	ldh	[h_head2adr],	A
	ldh	[h_head2adr+1],	A
	ldh	[t_tail1adr],	A
	ldh	[t_tail1adr+1],	A
	ldh	[g_bonusadr],	A
	ldh	[g_bonusadr+1],A

	ld	A,	$FC
	ld	[o_bonuschr],	A

;-------Draw Header------------------------------------------------------------;

;draw colors first; the DMG then re-overwrites the data later
iHeaderColor
	ld	A,	1
	ldh	[$FF4F],A	;Set vbank 1

	ld	A,	3		;Color palette 3 = GREYSCALE
	ld	B,	$40		;Number of bytes to write = 64
	ld	HL,	$9C00	;Source address
.loop
	ld	[HL+],	A	;Write to char attribute ram
	dec	B			;Decrease counter
	jr	nz,	.loop	; and loop

	xor	A
	ldh	[$FF4F],A	;Restore vbank 0


;top part

iSplashHeader1
	ld	B,	20				;number of bytes
	ld	DE,	gSplashHeader1	;source
	ld	HL,	$9C00			;destination
.loop
	ld	A,	[DE]			;load from ROM
	ld	[HL+],	A			;store in charmap
	inc	DE					;increase pointer
	dec	B					;decrease counter
	jr	nz,	.loop			; and loop
	

;bottom part

iSplashHeader2
	ld	B,	20				;number of bytes
	ld	DE,	gSplashHeader2	;source
	ld	HL,	$9C20			;destination
.loop
	ld	A,	[DE]			;load from ROM
	ld	[HL+],	A			;store in charmap
	inc	DE					;increase pointer
	dec	B					;decrease counter
	jr	nz,	.loop			; and loop


;-------Initialize Window------------------------------------------------------;

	ld	A,	128				;position the window at line 128
	ld	[rWY],	A
	ld	A,	7				; and at the start of the screen
	ld	[rWX],	A


;-------Initialize Sound-------------------------------------------------------;
iSound
	xor	A
	ldh	[$ff26],A	; Turn all sound on
	nop				;  wait for it to damn stabilize
	nop
	nop
	nop
	
	ld	A,$80
	ldh	[$ff26],A	; Turn all sound on

	ld	A,$ff
	ldh	[$ff25],A	; Route all sound everywhere

	ld	A,$77
	ldh	[$ff24],A	; Master volume = full
	
	xor	A
	ldh	[$10],A		; No sweep for ch1
	ldh	[$1c],A		; CH3 level off

	ld	A,$40		; 25% duty
	ldh	[$11],A		;  for CH1
	ld	A,$80		; 50% duty
	ldh	[$16],A		;  for CH2

	ld	A,$94		; Volume envelope
	ldh	[$12],A		;  for CH1
	ldh	[$17],A		;  for CH2
	


;-------Initialize Palettes----------------------------------------------------;

iIniPal

	ld	a,	%11100100	; palette colors from darker to
						;  lighter, 00 01 10 11
	ldh 	[rBGP],	a		; write this at the background palette register
	ldh	[rOBP0],a		;  and at the sprites palette register
	ldh	[rOBP1],a		;


;-------Show Splash------------------------------------------------------------;
		
iShowSplash
	ld	A,	124			; position the screen at the splash location
	ldh	[rSCY],	A

	ld	A,	4			;  and a bit off-center for the fun of it
	ldh	[rSCX],	a 		

	ld	a,	%11100001	; LCD on + BG on + BG $8000 + WIN on + WIN $9C00
	ldh	[rLCDC],a		; enable LCD

	call	gWaitKey	; wait for user to press key to quit the splashscreen

iEndSplash
.wait
	ldh	a,	[rLY]		; wait for
	cp	$90				;  vertical blank
	jr	nz,	.wait		; because we have a few more tiles to set


;-------Randomnize bonus level-----------------------------------------------;

	ld	A,	[$FF04]	;randomnize the level at which the bonus appears
	and	A,	$3	; between 3 and 7
	add	A,	$3
	ld	[g_bonusniv],	A


;-------Init Screen-----------------------------------------------------------;

	;give the tail a trail to follow
	ld	A,	$9	
	ld	[$98E9], A

	;give the window a nice roll-up animation
	ld	A,	144
	ldh	[rWY],	A

;-------Draw Header-----------------------------------------------------------;

	; colorize a few icons on the header
	ld	A,	1
	ldh	[$FF4F],A	;Set vbank 1
	ld	[$9C30],A

	ld	A,	2
	ld	[$9C2B],A

	xor	A
	ld	[$9C26],A
	ld	[$9C27],A
	ldh	[$FF4F],A	;Reset vbank 0


	;copy top part header
iHeader3
	ld	B,	20			;number of bytes
	ld	DE,	gHeader1	;source
	ld	HL,	$9C00		;destination
.loop
	ld	A,	[DE]		;load from ROM
	ld	[HL+],	A		;store in charmap
	inc	DE				;increase pointer
	dec	B				;decrease counter
	jr	nz,	.loop		; and loop
	
	;copy bottom part header
iHeader4
	ld	B,	20			;number of bytes
	ld	DE,	gHeader2	;source
	ld	HL,	$9C20		;destination
.loop
	ld	A,	[DE]		;load from ROM
	ld	[HL+],	A		;store in charmap
	inc	DE				;increase pointer
	dec	B				;decrease counter
	jr	nz,	.loop		; and loop


;-------Re-Enable Interrupts---------------------------------------------------;


iEI
iReset

	xor	a
	ldh	[rIF],	a		; clear interrupt flags; too dangerous elsewise

	ld	a,	IEF_VBLANK
	ldh	[rIE],	a		; enable VBlank interrupt flag


	ei					; ahhh... enable interrupts

	jp	mHotRestart		;  and immediately perform a step


;##############################################################################;
;###### MAIN ##################################################################;
;##############################################################################;

mMain
	call	gGetKeyHeading	;Keypad Input

	ldh	A,	[v_time]		;Check if new step
	ld	B,	A
	ldh	A,	[m_prevtime]
	xor	B
	and	$80
	jr	z,	noMainStep		; if not, sleep in again

	;test if not blocking pause
	ldh	A,	[m_rstcnt]		;If we are still buzy resetting
	cp	A,	$FF	
	jp	nz,	noPause			; don't allow any pause to occur

	ldh	A,	[v_corpse]		;If we just die
	cp	$FF
	jp	Z,	noPause			; don't allow it eighter

	ldh	A,	[b_prev]		;Finally, if we did press any "button-style" button
	and	$F0
	jp	NZ,	mPause			; then, and only then, pause the game

noPause
mEndPause
	call	sPlayMusic1		;Step the music
	jp	mMainStep			; and step the game

;-------Sleep in the machine---------------------------------------------------;
noMainStep
mMainStepEnd 
	ldh	A,	[v_time]
	ldh	[m_prevtime],	A

.wait
	ld	a,	IEF_VBLANK
	ldh	[rIE],	a		; enable VBlank interrupt flag... just to be sure

	halt		;Halt the system clock.
				;Return from HALT mode 
				; if an interrupt is generated.
	nop			;Used to avoid bugs in the rare case 
				; that the instruction after the HALT 
				; is not executed

;-------Test for VBlank Interrupt----------------------------------------------;

	ldh	A,	[v_flag]
	and	A			;Generate a V-blank interrupt?
	jr	Z,	.wait	;Jump if a non-V-blank interrupt
 
	xor	A		
	ldh	[v_flag], A	;Clear the V-Blank Flag
 
	jr	mMain		; and restart that damn main


;-------Power Saving Pause-----------------------------------------------------;
mPause
	di					;disable interrupts
.wait
	ldh	a,	[rLY]		; wait for
	cp	$90				;  vertical blank
	jr	nz,	.wait
	
drawPauseMessage
	ld	A,	$68			; the start address in shapemap for our pause message
	ld	HL,	$9C26		; the address in video to write it to
	ld	B,	$8			; the number of bytes to write
.loop
	ld	[HL+],	A		; write byte to VRAM
	inc	A				; increase char pointer
	dec	B				; decrease counter
	jp	NZ,	.loop		;  and loop

	
.pause
	; wait for all keys to be released
	call	gGetKeyHeading
	ldh	A,	[b_prev]
	and	$F0
	jp	Z,	.pause

	; nuke all information we did keep about those keys
	xor	A
	ldh	[b_evH], A
	ldh	[b_evV], A
	ldh	[b_pressed],	A

	call	gWaitKey	; wait for any new keys to be pressed

	ldh	A,	[b_prev]	; if we did press the arrow buttons
	and	A,	$F0
	jp	Z,	.noReset	;  then don't restart the game

.restart
	ld	A,	$FF
	ldh	[v_corpse],	A	;fire a restart

	;correct the sprites
	ld	A,	[v_head1chr]
	dec	A
	ld	[v_head1chr],	A

	ld	A,	[v_head2chr]
	dec	A
	ld	[v_head2chr],	A
	
.noReset
	xor	A
	ldh	[rIF],	A		;clear the interrupt flag
	ei
	jp		mEndPause	; and end the pause

 
;##############################################################################;
;###### GENERIC ROUTINES ######################################################;
;##############################################################################;




;-------Read the keypad--------------------------------------------------------;
;    04                b  a    ;
; 02  + 01    se st    20 10   ;
;    08       40 80            ;
;------------------------------;

gRdKeypad
        ld      a,$20               ; Load bit 5
        ldio    [$ff00],a           ; Send to probe buttons (P15)
        ldio    a,[$ff00]           ; Get return value...
        ldio    a,[$ff00]           ; Wait for post-oscillation to go away...
        ldio    a,[$ff00]
        ldio    a,[$ff00]           ; ... stabilized!
        cpl                         ; Invert a to make pressed keys 1
        and     $0f                 ; Pass lower nibble
        ld      b,a                 ; Store in b


        ld      a,$10                ; Load bit 5
        ldio    [$ff00],a           ; Send to probe +-pad (P15)
        ldio    a,[$ff00]           ; Get return value...
        ldio    a,[$ff00]           ; Wait for post-oscillation to go away...
        ldio    a,[$ff00]
        ldio    a,[$ff00]           ; ... stabilized!
        cpl                         ; Invert a to make pressed keys 1
        and     $0f                 ; Pass lower nibble
        swap    a                   ; swap nibbles, to give space in lowe nibble
        or      b                   ; Combine values
        ld      b,a                 ; Copy a to b
;       ld      [b_hold],a   		; Store new joypad info
        ld      a,[b_prev]       	; Load old joypad value...
        xor     b                   ; Toggle
        and     b                   ;
        ld      [b_pressed],a   	; Store new joypad info
		xor		b
        ld      [b_released],a   	; Store new joypad info
        ld      a,b                 ;
        ld      [b_prev],a      	; Store old joypad info
        ld      a,$30               ;
        ld      [$ff00],a           ; De-activate
        ret

;-------Calculate new direction------------------------------------------------;

gGetKeyHeading
	call	gRdKeypad		;read keypad info

;test if we are pressing rightwards
	ldh	A,	[b_pressed]		
	rrc	A				;(little secret: right is the first bit of the pack)
	jp	NC,	.noRight	;if not right pressed, then check next

; we are pressing rightwards
	ld	B,	A			;save button test state

	ldh	A,	[b_evH]
	or	A,	$01			;fire horizontal button event, put it on RIGHTwards
	ld	[b_evH],	A

	ld	A,	B			;restore button test state
.noRight

;test if we are pressing leftwards
	rrc	A				;(and left is the second bit of the pack... hihi)
	jp	NC,	.noLeft		;if not left pressed, then check next

	ld	B,	A			;save button test state

	ldh	A,	[b_evH]
	or	A,	$FF			;fire horizontal button event, put it on LEFTwards
	ld	[b_evH],	A

	ld	A,	B			;restore button test state
.noLeft

;test if we are pressing upwards
	rrc	A				;(then comes up... well, up)
	jp	NC,	.noUp		;if not up pressed, then check next

	ld	B,	A			;save button test state

	ldh	A,	[b_evV]
	or	A,	$FF			;fire vertical button event, put it on UPwards
	ld	[b_evV],	A

	ld	A,	B			;restore button test state
.noUp

;test if we are pressing downwards
	rrc	A				;(and finally, down might be down)
	jp	NC,	.noDown		;if not down pressed, then wrap it up

	ldh	A,	[b_evV]
	or	A,	$01			;fire vertical button event, put it on DOWNwards
	ld	[b_evV],	A
.noDown

;and return where we left
	ret


;-------Wait for Key-----------------------------------------------------------;

;use this routine instead for emulators... there is nothing like the real
gWaitKeyOld
	call	gGetKeyHeading	;while there
	ldh	A,	[b_pressed]		; is no
	cp	$0					; key down
	jp	Z,	gWaitKeyOld		;burn useless battery life!
	ret

;does not work on some emulators
gWaitKey
	ldh	A,	[rIE]		; save the interrupt enable register state
	ld	D,	A
        
	ld      a,$0       
	ldio    [$ff00],a 	; look for all buttons

;wait for all keys to be released
.waitAllUp
	ldio    a,[$ff00]
	and	A,	$0F
	cp	A,	$0F
	jp	NZ,	.waitAllUp

	xor	A				;remove all interrupts
	ldh	[rIF],	A
	ldh	[rAUDENA],	a	; write 0 to sound enable register

	ld	A,	IEF_HILO	;wait only for HILO (keypad) interrupt
	ldh	[rIE],	A

	ei					;enable interrupts

	halt				;sleep down so badly, only keys can wake us up
	nop				

	di					;re-disable interrupts

	ld      a,$30       
	ldio    [$ff00],a	;re-disable keys
        
.waitAllDown
	call	gGetKeyHeading	;update key events to treat our new info
	ldh	A,	[b_prev]	;look if any pressed
	cp	$0			; if not...
	jp	Z,	.waitAllDown	; ... then keep on waiting
	

;reset sound registers
	ld	A,$80
	ldh	[$ff26],A	; Turn all sound on

	ld	A,$ff
	ldh	[$ff25],A	; Route all sound everywhere

	ld	A,$77
	ldh	[$ff24],A	; Master volume = full
	
	xor	A
	ldh	[$10],A		; No sweep for ch1
	ldh	[$1c],A		; CH3 level

	ld	A,	$18		; CH4 parameters
	ldh	[$FF20],	A	;Lenght: 24

	ld	A,	$F3
	ldh	[$FF21],	A	;Enveloppe: start=F down len=3


	ld	A,$40		; 50% duty
	ldh	[$11],A
	ld	A,$80		; 50% duty
	ldh	[$16],A

	ld	A,$94		; Volume envelope
	ldh	[$12],A
	ldh	[$17],A


	xor	A
	ldh	[rIF],	A	;clear flags
	ld	A,	D
	ldh	[rIE],	A	;re-set old interrupt flag
	ret


;-------Go Left----------------------------------------------------------------;

gGoLeft
	dec	A			;move left
	cp	A,	$FF		;if wrap-around
	jp	NZ,	.nowrap

	ld	A,	19		;come back at right of screen

.nowrap
	ret


;-------Go Right---------------------------------------------------------------;

gGoRight
	inc	A			;move right
	cp	20			;if wrap-around
	jp	c,	.nowrap

	ld	A,	$0		;come back at left of screen

.nowrap
	ret


;-------Go Up------------------------------------------------------------------;

gGoUp
	dec	A	;move up
	and	$F	;don't do complicated
	ret


;-------Go Down----------------------------------------------------------------;

gGoDown
	inc	A	;move down
	and	$F	;don't do complicated
	ret


;-------Draw Message-----------------------------------------------------------;

gDrawMessage
	ld	HL,	g_message	;destination
	cp	A,	$0			;if 0,
	jp	Z,	drawEmpty	; then draw empty message
	dec	A
	sla	A
	sla	A
	sla	A
	add	$60				;message= (index-1)*8 + 60

drawMessage
	ld	B,	$8			;number of bytes to copy
.loop
	ld	[HL+],	A		;copy to destination
	inc	A				;increase char pointer
	dec	B				;decrease counter
	jp	NZ,	.loop		; and loop
	ret

drawEmpty
	ld	A,	gEMPTY		;load the heir of nothingness
	ld	B,	$8			; and its 8 brothers
.loop
	ld	[HL+],	A		;send them to outer space
	dec	B				;jump to another plane of existance
	jp	NZ,	.loop		; and fire again

	ret


;-------Inc Score--------------------------------------------------------------;

gIncScore
	ldh	A,	[s_score+2]		;load lowest digit of score
	inc	A					; increase it
	ldh	[s_score+2],	A	; and save it back again
	cp	$3A					;look if it has gone bigger that 10
	jp	c,	.nocarry		; if not, then we are done

	ld	A,	$30				; if it is, load back "0"
	ldh	[s_score+2],	A

	ldh	A,	[s_score+1]		; and increase the middle digit of score
	inc	A
	ldh	[s_score+1],	A
	cp	$3A					;look if this has gone bigger than 10
	jp	c,	.nocarry		; if not, then we are done

	ld	A,	$30				; if it is, load back "0"
	ldh	[s_score+1],	A

	ldh	A,	[s_score+0]		; and open the highest digit of score
	cp	A,	$30				; look if there is still the icon of "score" inside
	jp	nc,	.toolow			;  if not, we can play
	ld	A,	$30				;  else, we need to simulate a 0 instead

.toolow
	inc	A					;increase the highest digit of score
	ldh	[s_score+0],	A

.nocarry
	ret						; and fuck for the carry

;-------Update Highscore-------------------------------------------------------;
; update in VBlank, pls

gUpdHigh
	ldh	A,	[s_score+0]		;load highest digit of score
	cp	A,	gLVL1			;if we did just load a level
	jp	Z,	.endUpd			; then ignore the update

	ld	B,	A
	ld	A,	[$9C30]			;load highest digit of highscore
	cp	A,	gHIGH			;if it isn't a icon of "score"
	jp	NZ,	.noStrangeSign	; then we don't need to
	ld	A,	gAPPLE			; replace it with an apple
.noStrangeSign
	cp	A,	B				;if those are equal
	jp	Z,	.notup1			; then check the next digit
	jp	NC,	.endUpd			;if the latter is bigger, 
							; then we don't need to update anything
	ld	A,	B				;if the former is bigger
	ld	[$9C30],	A		; put the former into the latter
	jp	.upd2				; and update the second digit

.notup1
	ldh	A,	[s_score+1]		;load middle digit of score
	ld	B,	A				; and compare it with
	ld	A,	[$9C31]			; the middle digit of highscore
	cp	A,	B				;if those are equal
	jp	Z,	.notup2			; then check the next digit
	jp	NC,	.endUpd			;if the latter is bigger, 
							; then we don't need to update anything
.upd2
	ld	A,	B				;if the former is bigger
	ld	[$9C31],	A		; put the former into the latter
	jp	.upd3				; and update the first digit

.notup2
	ldh	A,	[s_score+2]		;load lowest digit of score
	ld	B,	A				; and compare it with
	ld	A,	[$9C32]			; the lowest digit of highscore
	cp	A,	B				;if those are equal
	jp	Z,	.notup3			; then damn it, you are good
	jp	NC,	.endUpd			;if the latter is bigger, 
							; you are just a loser
.upd3
	ldh	A,	[s_score+2]		;if the latter is bigger,
	ld	[$9C32],	A		; you won by a small margin

.notup3
.endUpd
	ret						;pfft... why are they so happy about it?
							;It are just numbers!

;-------Update Level-----------------------------------------------------------;
; update in VBlank, pls
; A should loop from 0 to 127

gCopyLevel
	and	$7F				;we only need 127 steps, luckely
	ld	L,	A			; load as low bit of address for loading
	xor	A				; and load 0
	ld	H,	A			; as high bit of address for loading

	sla	L				;multiply HL...
	rl	H
	sla	L
	rl	H				;...by 4

	ld	BC,	gLevel		;load address of level
	ldh	A,	[g_level]	; from address table, indexed with [g_level*2]
	sla	A
	add	A,	C			;add [g_level*2] to lowest bit of address
	ld	C,	A

	ld	A,	[BC]		;load effective address of current level
	ld	E,	A			; first lowest bit
	inc	BC
	ld	A,	[BC]
	ld	D,	A			; then highest bit

	ld	A,	E
	add	A,	L			;add loading offset to source
	ld	E,	a
	jp	NC,	.notcarry	; and if carry...
	inc	D				; ...carry on
.notcarry

	ld	A,	D
	add	A,	H			;add loading offset to destination
	ld	D,	A

	ldh	A,	[g_vidBase]	;add current video map offset
	or	A,	H
	ld	H,	A

	ld	A,	$4			;effectively load 4 bytes
	ld	B,	A

.copylevelbase
	ld	A,	1		;Set palette to 4 shades of brown
	ldh	[$FF4F],A	; into vbank 1
	ld	[HL],A
	xor	A
	ldh	[$FF4F],A	; return to vbank 0

	ld	A,	[DE]	;Load tile to load
	cp	A,	$0		; if it isn't an empty one
	jp	NZ,	.notEmpty	; then do load it another way

	ld	A,	1		;Else, reset palette to 4 tints of olive
	ldh	[$FF4F],A	; into vbank 1
	xor	A
	ld	[HL],A
	ldh	[$FF4F],A	; return to vbank 0

	;and perform Yvar's secret grass hashing routine
	ld	A,	L
	swap	A
	xor	L
	ld	C,	A
	add	C
	add	C
	rra
	and	32

.notEmpty
	add	A,	32		;Anyway, add 43 as for the map base
	ld	[HL+],	A	; and store it in memory
	inc	DE			;increase pointer
	dec	B			;decrease counter
	jp	nz,	.copylevelbase	; and, guess what, loop!
	ret


;##############################################################################;
;###### PERFORM STEP ##########################################################;
;##############################################################################;

mMainStep
	ld	A,	$1		;signal a new frame
	ld	[v_newframe],	A

;=== Keys =====================================================================;
; TODO:	if you release the key you are heading in, and you hold another key,
;  go in the direction of the key you hold. This way, the game reacts the right
;  way if you like to hold your keys

mUpdKeys
	ldh	A,	[h_head1dirH]	;look if we were going horizontal
	cp	$0					; if not...
	jp	Z,	.goingVertiNow	; ... then go vertical

	ldh	A,	[b_evV]			;check if any of all those vertical keys were pressed
	cp	A,	$00				; if nothing...
	jp	Z,	.noHoriEvent	; ...then damn it

	ldh	[h_head1dirV],	A	;load the new vertical direction as our new direction
	xor	A
	ldh	[h_head1dirH],	A	; and clear our old horizontal direction
	ldh	[b_evV],	A		; as well as the vertical key event

	jp	mUpdKeysEnd			; and then we are done

.noHoriEvent				;if no vertical keys were pressed
	xor	A	
	ldh	[b_evH],	A		; then clear the horizontal keys too
	jp	mUpdKeysEnd			; and then we are done


.goingVertiNow				;we are now going vertical
	ldh	A,	[b_evH]			;check if any of those crazy horizontal keys were pressed
	cp	A,	$00				; if nothing...
	jp	Z,	.noVertiEvent	; ...well, don't give a fuck, actually

	ldh	[h_head1dirH],	A	;load the new horizontal direction as our new direction
	xor	A
	ldh	[h_head1dirV],	A	; and clear our old vertical direction
	ldh	[b_evH],	A		; as well as the horizontal key event

	jp	mUpdKeysEnd			; and we are done
	
.noVertiEvent				;if no horizontal keys were pressed
	xor	A					
	ldh	[b_evV],	A		; then clear the vertical keys too

mUpdKeysEnd					; and we are done


;=== Addresses ================================================================;

;--- Update Head-2 ; decode address -------------------------------------------;
hUpd2Adr
	;convert position to address
	ldh	A,	[h_head2y]		; get row
	swap	A				; *16
	rlc	A					; *32
	ld	C,	A				; save result for later
	and	$03					; calc MSB VRAM row start
	ldh	[h_head2adr+1],	A	; set MSB of VRAL ptr
	ld	A,	$E0				; LSB VRAM row start mask
	and	C					; calc LSB VRAM row start
	ld	C,	A				; save LSB VRAM row start
	ldh	A,	[h_head2x]		; get column
	add	A,	C				; add LSB VRAM row start
	ldh	[h_head2adr],	A	; set MSB of VRAL ptr

mHotRestart
;=== Tiles ====================================================================;

	xor	A
	ldh	[t_freeze],	A		;clear tail freeze; for if we did eat an apple last turn

;--- Kill head if neaded ------------------------------------------------------;

	ldh	A,	[v_corpse]		;if head is already death
	cp	$FF					; then leave it alone
	jp	Z,	.nokill

	ldh	A,	[v_eating]		;if we are eating an apple
	cp	gAPPLE				; then don't poison ourself
	jp	Z,	.nokill
	cp	gEMPTY				;if we eat the terrain
	jp	Z,	.nokill			; then there is nothing wrong
	cp	gGRASS				;if we eat grass
	jp	Z,	.nokill			; we won't get sick

.dokill						;if we did kill ourself
	ld	A,	$FF				; then sign our death contract
	ld	[v_corpse],	A

	ld	A,	[v_head1chr]	;clean our sprites
	dec	A
	ld	[v_head1chr],	A

	ld	A,	[v_head2chr]	;mummify our corpses
	dec	A
	ld	[v_head2chr],	A

;-------Play Dying Sound-------------------------------------------------------;

	ld	A,	$44			;play the song of our death
	ldh	[$FF22],	A	;Freq=0x44
	ld	A,	$F2
	ldh	[$FF21],	A	;Enveloppe: start=F down len=3
	ld	A,	$18		
	ldh	[$FF20],	A	;Lenght: 24

	ld	A,	$C0
	ldh	[$FF23],	A	;Fire single

	ld	A,	$1			; and draw our RIP
	call	gDrawMessage

	ld	A,	[v_speed]	;Speed up the rolldown
	ld	B,	A
	add	B
	add	B
	srl	A			;*1.5
	cp	A,	$0		;speed should never go to 0
	jp	Z,	.noupdspeed
	ld	[v_speed],	A
.noupdspeed

;-------Digest what we did eat-------------------------------------------------;

.nokill
	ldh	A,	[a_error]	; check if the apple failed to position
	cp	A,	$0			; if it is the case,
	jp	NZ,	.moveapple	;  then move it

	ldh	A,	[h_eated]		;update the food buffer
	ldh	[a_ateapple],	A

	cp	A,	gAPPLE		;look if we did eat an apple
	jp	NZ,	.noapple


;-------Play an Apple Eating Sound---------------------------------------------;

	ld	A,	$55
	ldh	[$FF22],	A	;Freq=0x55
	ld	A,	$F2
	ldh	[$FF21],	A	;Enveloppe: start=F down len=3
	ld	A,	$18		;
	ldh	[$FF20],	A	;Lenght: 24
	ld	A,	$C0
	ldh	[$FF23],	A	;Start single


;-------Increase the score-----------------------------------------------------;

	call	gIncScore	;increase our score


;-------Check if this is the good apple----------------------------------------;

	ld	A,	[a_appleadr]
	ld	B,	A
	ld	A,	[h_head2adr]
	cp	A,	B
	jp	NZ,	.noapple

	ld	A,	[a_appleadr+1]
	ld	B,	A
	ld	A,	[h_head2adr+1]
	cp	A,	B
	jp	NZ,	.noapple


;-------Move Apple-------------------------------------------------------------;

.moveapple
	ldh	A,	[$FF04]		;get random number (sorta of) from timer
	ld	B,	A			; save it temp
.modulo
	cp	A,	19			;perform a lazy modulo 20
	jp	c,	.noproblem	; while it is larger than 20
	sub	A,	$14			;  substract 20
	jp .modulo

.noproblem
	ldh	[a_applex],	A	;and save it as the X position for the apple

	ld	A,	B			;load our old random number
	swap	A			; do the swap
	and	$0F				; perform an efficient modulo 16
	ldh	[a_appley],	A	; and save it as the Y position for the apple

	xor	A
	ldh	[a_error],	A	; and clear the apple error
	jp	.endapple

.noapple
	ld	A,	[a_dispencer]
	cp	A,	$0
	jp	Z,	.endapple
	dec	A
	ld	[a_dispencer],	A

	ld	A,	$56			;play the basket falling sound
	ldh	[$FF22],	A	;Freq=0x56
	ld	A,	$F8
	ldh	[$FF21],	A	;Enveloppe: start=F up
	ld	A,	32		
	ldh	[$FF20],	A	;Lenght: 32
	ld	A,	$C0
	ldh	[$FF23],	A	;Fire single

	jp	.moveapple

.endapple
	ldh	A,	[v_eating]	;finally, update our eating buffer
	ldh	[h_eated],	A


;--- Don't update head if killed ----------------------------------------------;

	ldh	A,	[v_corpse]	;check if we are killed
	cp	$FF				; if so
	jp	Z,	dontUpdHead	;  we do a big leap forward


;--- Set pos head 2 to pos head 1 ---------------------------------------------;

tUpdateHead
	ldh	A,	[h_head1x]	;pretty straightforward
	ldh	[h_head2x],	A	; now, do you want me to talk about møøze?

	ldh	A,	[h_head1y]	;come take a holiday
	ldh	[h_head2y],	A	; I know that you need it! 


;--- Calculate Sprite and Position Head-1 -------------------------------------;

hCalcSpr1
	ldh	A,	[h_head1dirH]	;look if we are going horizontal-wards
	ld	B,	A
	cp	$0
	jp	Z,	.goingverti		; if not, perform code for vertical movement instead

	dec	A					;look if we are going rightwards
	jp	Z,	.goingright		; if so, go rightwards

	ldh	A,	[h_head1x]		;else, update head position
	call gGoLeft			; using an external function
	ldh	[h_head1x],	A		; and store it back

	ld	A,	$00				;save $00 as our direction number
	ldh	[v_head1dirnum],	A

	ld	A,	$C0				;and $C0 as our sprite number
	jp	.endcalc


.goingright					;if we are going rightwards indeed,
	ldh	A,	[h_head1x]		; then update head position
	call gGoRight			; using an external function
	ldh	[h_head1x],	A		; and store it back

	ld	A,	$10				;save $10 as our direction number
	ldh	[v_head1dirnum],	A

	ld	A,	$D0				;and $D0 as our sprite number
	jp	.endcalc


.goingverti					;if we are going vertical-wards
	ldh	A,	[h_head1dirV]	; look if we are going down
	ld	C,	A
	dec	A					;if this is the case
	jp	Z,	.goingdown		; then just do that

	ldh	A,	[h_head1y]		;else we are going up
	call gGoUp				; thanks to an external function
	ldh	[h_head1y],	A		;

	ld	A,	$20				;save $20 as our direction number
	ldh	[v_head1dirnum],	A

	ld	A,	$E0				;and $E0 as our sprite number
	jp	.endcalc


.goingdown					;if we are going downwards
	ldh	A,	[h_head1y]		; then update the head position
	call gGoDown			; thanks to some external magic
	ldh	[h_head1y],	A		;

	ld	A,	$30				;save $30 as our direction number
	ldh	[v_head1dirnum],	A

	ld	A,	$F0				;and $F0 as our sprite number
	jp	.endcalc


.endcalc
	ld	[v_head1chr],	A	;save our sprite number


;--- Draw Corpse --------------------------------------------------------------;

hDrawCorpse
	ld	A,	[v_head2chr]	;the corpse is the head sprite
	swap	A				; /16
	and	$F					; %16
	ldh	[v_corpse],	A		;


	ldh	A,	[a_ateapple]	;if we didn't ate an apple
	cp	A,	gAPPLE
	jp	NZ,	.noapple		; then skip the next part

	ldh	A,	[v_corpse]		;load corpse tile
	or	A,	%00010000		; and set eggy bit
	ldh	[v_corpse],	A		; (i.e. the eaten tiles)

	xor	A
	ld	[a_ateapple],	A	;finally, confirm that we did eat that apple

.noapple


;--- Calculate Sprite Head-2 --------------------------------------------------;
;TODO: transform this in a simple table lookup

hCalcSpr2
	ldh	A,	[h_head2dirH]	;look if we were heading horizontally,
	cp	$0					; if not,
	jp	Z,	.goingverti		;  then this is the wrong place to be

	dec	A					;look if we were heading right
	jp	Z,	.goingright		; if so, execute the code for it

.goingleft					;else, we are heading leftwards
	ldh	A,	[v_head1dirnum]	;now compare with the new head direction
	cp	A,	$00				; if they aren't the same...
	jp	NZ,	.left2verti		; ... then there is special code for them

	ld	A,	$80				;else, it is just tile $80
	jp	.endcalc			; so end this thing


.goingright					;if we were heading right
	ldh	A,	[v_head1dirnum]	; compare with the new head direction
	cp	A,	$10				; if they aren't the same
	jp	NZ,	.right2verti	; then that is such a shame

	ld	A,	$90				;else, just load $90
	jp	.endcalc			; and it is OK


.goingverti					;if we were heading vertically
	ldh	A,	[h_head2dirV]	; look if we are heading down
	dec	A
	jp	Z,	.goingdown		; if it is the case, go to the code specific for it

.goingup					;else, we are heading upwards
	ldh	A,	[v_head1dirnum]	;now compare with the new head direction
	cp	A,	$20				; if they aren't the same...
	jp	NZ,	.up2hori		; ... then there is special code for them

	ld	A,	$A0				;else, just load $A0
	jp	.endcalc			; and lay it down


.goingdown					;if we are heading down
	ldh	A,	[v_head1dirnum]	; compare with the new head direction
	cp	A,	$30				; if that isn't ok,
	jp	NZ,	.down2hori		; call the magic fixing machine

	ld	A,	$B0				;else, just load $B0
	jp	.endcalc			; and we are done


.left2verti					;if we did go left, and now we go vertically
	or	A,	$20				; then do some secret bit-hackery on it
	jp	.endcalc			;  and guess what? the right tile!

.right2verti				;if we did go right, and now we go vertically
	or	A,	$60				; then the magic bitmask is $60
	jp	.endcalc			; and we are fine

.down2hori					;if we did go down, and now we flow to horizontal
	or	A,	$40				; then set the 6th bit of our byte
	jp	.endcalc			; and that's all

.up2hori					;if we did go up, and now we fall down to horizontal
	;or	A,	$00				; then the magic bitmask... oh, fuck!
	;jp	.endcalc			; whatever

.endcalc
	ld	[v_head2chr],	A	;finally, save the tile

dontUpdHead					;end of our eventual skip


;--- Update Apple ; decode address --------------------------------------------;
	;magic routine to convert X,Y into address

	ldh	A,	[a_appley]		; get row
	swap	A				; *16
	rlc	A					; *32
	ld	C,	A				; save result for later
	and	$03					; calc MSB VRAM row start
	ldh	[a_appleadr+1],	A	; set MSB of VRAL ptr
	ld	A,	$E0				; LSB VRAM row start mask
	and	C					; calc LSB VRAM row start
	ld	C,	A				; save LSB VRAM row start
	ldh	A,	[a_applex]		; get column
	add	A,	C				; add LSB VRAM row start
	ldh	[a_appleadr],	A	; set MSB of VRAL ptr


;--- Calculate Sprite Tail-2 --------------------------------------------------;
; TODO: fix bug with tail sprite heading in wrong direction when wrapping around

tUpdSpr2
	ldh	A,	[t_tail2x]	;look if the second bit of tail
	ld	B,	A			; is futher left or right 
	ldh	A,	[t_tail1x]	; then the first bit of tail
	sub	A,	B			;if it ain't the case
	jp	Z,	.goingverti	; we are probably going vertical

	cp	A,	$FF			;if we are going left
	jp	Z,	.goingleft	; then go to the routine for it
	cp	A,	19			;if we are going left and wrapping around
	jp	Z,	.goingleft	; then go to the routine for it

.goingright				;else we are going right
	ld	A,	$D8			; so load $D8 as sprite
	jp	.endcalclr		; and we are done

.goingleft				;if we are going left
	ld	A,	$C8			; load $C8 as sprite

.endcalclr				;and end the calculation
	jp	.endcalc


.goingverti				;if we are going vertically
	ldh	A,	[t_tail2y]	; look if the second bit of tail
	ld	B,	A			; is futher down
	ldh	A,	[t_tail1y]	; then the first but of tail
	sub	A,	B			;if it is the case
	cp	A,	$FF			; then we are probably
	jp	Z,	.goingup	; heading upwards
	cp	A,	15			; if we wrap around take that
	jp	Z,	.goingup	; in account too

	ld	A,	$F8			;else, $F8 is the tile
	jp	.endcalc		; so now end the calc

.goingup				;if we are going up
	ld	A,	$E8			; $E8 is the tile

.endcalc
	ld	[v_tail2chr],	A	;save it as the char for our sprite
	


	
;--- Look if the tail didn't die ----------------------------------------------;

tUpdSpr1
	ldh	A,	[v_trail]
	cp	A,	12			;if the tail touched corpse
	jp	c,	.noapple	; then it wasn't an apple
	cp	A,	$20			;if it did touch an eaten apple
	jp	c,	.nodeath	; then it didn't die

	jp tDie				;else reset the game

.nodeath				;if it ate apple
	ld	A,	$1			; then freeze it for a jiffy
	ldh	[t_freeze],	A	; as to make it grow
	jp	tUpdSpr1End

.noapple				;else, no problem mate!

;--- Calculate Sprite Tail-1 --------------------------------------------------;

	ldh	A,	[v_trail]	;similary to how the tile for the corpse was (spr/16)%16
	and	A,	$F		; take care of the eggs
	swap	A			; the sprite for the first tail is trail*16
	or	A,	$8			; and of course we need to add the tail base address too
	ld	[v_tail1chr],	A	;save it back
tUpdSpr1End


;=== Directions ===============================================================;

upddir					;update the directions
	ldh	A,	[h_head1dirH]	;do you want me to explain this too?
	ldh	[h_head2dirH],	A

	ldh	A,	[h_head1dirV]
	ldh	[h_head2dirV],	A




;=== Sprite Positions =========================================================;

	ldh	A,	[v_corpse]		;If the head is frozen,
	cp	$FF					; then don't update it
	jp	Z,	dontUpdHead2


;--- Update Head-2 ; just copy from Head-1 ------------------------------------;

vUpdPosH2
	ld	A,	[o_head1x]		;get the old position from the Head-1
	ld	[o_head2x],	A		; and make it now the new position for the Head-2

	ld	A,	[o_head1y]		;ditto with the vertical position
	ld	[o_head2y],	A


;--- Update Head-1 ; *8+8 from Address ----------------------------------------;

vUpdPosH1
	ldh	A,	[h_head1x]		;get the horizontal tile position for the head
	rla
	inc	A
	rla
	rla						; multiply it with 8, and add the sprite base offset
	ld	[o_head1x],	A		; and save it back

	ldh	A,	[h_head1y]		;ditto with the vertical tile position
	inc	A
	inc	A
	rla
	rla
	rla
	ld	[o_head1y],	A


dontUpdHead2				;if the head is OK
	ldh	A,	[t_freeze]		; does that means that the tail is OK too?
	cp	$0
	jp	NZ,	mDigestScore	; if no, then it shouldn't move


;--- Update Tail-2 ; just copy from Tail-1 ------------------------------------;

	ld	A,	[o_tail1x]		;remember the Head-2 positions?
	ld	[o_tail2x],	A		; this is basically the same routine

	ld	A,	[o_tail1y]		;you just take the old one for the first
	ld	[o_tail2y],	A		; and put it down as the new one for the second


;--- Update Tail-1 ; *8+8 from Address ----------------------------------------;

	ldh	A,	[t_tail1x]		;get the horizontal tile position for the tail
	inc	A
	rla
	rla
	rla						; multiply it with 8, and add the sprite base offset
	ld	[o_tail1x],	A		; and save it back

	ldh	A,	[t_tail1y]		;ditto with the vertical tile position
	inc	A
	inc	A
	rla
	rla
	rla
	ld	[o_tail1y],	A


;=== Move tails ===============================================================;

;--- Set pos tail 2 to pos tail 1 ---------------------------------------------;

tUpdateTail

	ldh	A,	[t_tail1x]	;now we moved the sprite positions
	ldh	[t_tail2x],	A	; move the tile positions in the same matter

	ldh	A,	[t_tail1y]	;the reason I do move both this way,
	ldh	[t_tail2y],	A	; is that it takes less code than to recalculate them

	
;--- Move Tail-1 --------------------------------------------------------------;

	ldh	A,	[v_trail]	;look up what is the corpse we picked up
	and	$3				; we are only interested in what direction it was going

;--- Tail Going left ----------------------------------------------------------;

	jr	NZ,	.notLeft	; if it was 0, it wasn't going left

	ldh	A,	[t_tail1x]	; if it is going left
	call gGoLeft		;  then move left
	ldh	[t_tail1x],	A	;  thanks to our magical routine
	jp	mEndMoveTail	;  and finish the stuff


;--- Tail Going Right ---------------------------------------------------------;

.notLeft
	dec	A				; look if it was 1
	jr	NZ,	.notRight	;  else, it wasn't going right either

	ldh	A,	[t_tail1x]	; if it was going right
	call gGoRight		;  call our sublime routine
	ldh	[t_tail1x],	A	;  to move us right too
	jp	mEndMoveTail	;  and then we are done


;--- Tail Going Up ------------------------------------------------------------;

.notRight
	dec	A				; look if it was 2
	jr	NZ,	.notUp		;  else, downwards is what it was going to go to

	ldh	A,	[t_tail1y]	; if it was going up
	call gGoUp			;  follow the leader
	ldh	[t_tail1y],	A	;  with our routine, as usual
	jp	mEndMoveTail	;  and wrap it up

;--- Tail Going Down ----------------------------------------------------------;

.notUp
	dec	A				; look if it was 3
	jr NZ, mEndMoveTail	;  else, fuck it

	ldh	A,	[t_tail1y]	; if it was going down
	call gGoDown		;  go down ourself
	ldh	[t_tail1y],	A	;  and we are done

	;jp	mEndMoveTail	; we are done


mEndMoveTail

;=== Addresses ================================================================;
;--- Set address Tail-2 to Tail-1 ---------------------------------------------;

mMoveTail2Address
	ldh	A,	[t_tail1adr]	;the old story again
	ldh	[t_tail2adr],	A

	ldh	A,	[t_tail1adr+1]	;take one round
	ldh	[t_tail2adr+1],	A	; and spin it around

	jp	mUpdHead1adr	;a little twist....
						;if we need to digest a score, we need to continue here
						; so now perform a jump, so that someone else can digest
						; our score

;--- Digest our Score ---------------------------------------------------------;

mDigestScore

	ld	A,	$57			;play a (disgusting) digesting sound
	ldh	[$FF22],	A	;Freq=0x57
	ld	A,	$F2
	ldh	[$FF21],	A	;Enveloppe: start=F down len=3

	ld	A,	$18		;
	ldh	[$FF20],	A	;Lenght: 24
	ld	A,	$C0
	ldh	[$FF23],	A	;Start single on noise

	xor	A				;Finally, hide our tail-2 sprite
	ld	[o_tail2x],	A	; it will only bug anyway



;--- Update Head-1 ; decode address -------------------------------------------;

mUpdHead1adr

	;convert Head-1 pos to display address for VBlank routine
	ldh	A,	[h_head1y]		; get row
	swap	A				; *16
	rlc	A					; *32
	ld	C,	A				; save result for later
	and	$03					; calc MSB VRAM row start
	ldh	[h_head1adr+1],	A	; set MSB of VRAL ptr
	ld	A,	$E0				; LSB VRAM row start mask
	and	C					; calc LSB VRAM row start
	ld	C,	A				; save LSB VRAM row start
	ldh	A,	[h_head1x]		; get column
	add	A,	C				; add LSB VRAM row start
	ldh	[h_head1adr],	A	; set MSB of VRAL ptr


;--- Update Tail-1 ; decode address -------------------------------------------;

	;convert Tail-1 pos to display address for VBlank routine
	ldh	A,	[t_tail1y]		; get row
	swap	A				; *16
	rlc	A					; *32
	ld	C,	A				; save result for later
	and	$03					; calc MSB VRAM row start
	ldh	[t_tail1adr+1],	A	; set MSB of VRAL ptr
	ld	E,	A
	ld	A,	$E0				; LSB VRAM row start mask
	and	C					; calc LSB VRAM row start
	ld	C,	A				; save LSB VRAM row start
	ldh	A,	[t_tail1x]		; get column
	add	A,	C				; add LSB VRAM row start
	ldh	[t_tail1adr],	A	; set MSB of VRAL ptr


;--- Update Sprites -----------------------------------------------------------;

	ldh	A,	[v_time]	;put in the right time
	swap	A
	and	7
	ld	B,	A	;to update the sprites with
	call gUpdSprites	; and make sure the sprite chars are now right


;--- Update bonus-------------------------------------------------------------;
	;look if there is a bonus
	ld	A,	[o_bonusx]
	cp	A,	$0
	jp	Z,	.nobonus

	;look if we need to clear the bonus
	ldh	A,	[h_head2adr]
	ld	B,	A
	ld	A,	[g_bonusadr]
	cp	A,	B
	jp	NZ,	.notClearbonus

	ldh	A,	[h_head2adr+1]
	ld	B,	A
	ld	A,	[g_bonusadr+1]
	cp	A,	B
	jp	NZ,	.notClearbonus

	xor	A	;clear bonus
	ld	[o_bonusx],	A	; by positioning it offscreen
	ld	A,	$98
	ld	[g_bonusadr],	A
	ld	[g_bonusadr+1],	A

	;check if it is a basket or a cherry
	ld	A,	[o_bonuschr]
	cp	A,	$FC	
	jp	Z,	.isbasket
.ischerry
	ld	A,	$FC		;make it a basket
	ld	[o_bonuschr],	A
	ld	A,	$3
	ld	[o_bonusattr],	A

	ld	A,	[$FF04]	;randomnize the level at which the bonus appears
	and	A,	$3	; between 3 and 7
	add	A,	$3
	ld	[g_bonusniv],	A
	call	gIncScore
	call	gIncScore
	call	gIncScore
	call	gIncScore
	call	gIncScore
	ld	A,	$0C			;play the cherry sound
	ldh	[$FF22],	A	;Freq=0x0D
	ld	A,	$F8
	ldh	[$FF21],	A	;Enveloppe: start=F up
	ld	A,	24		
	ldh	[$FF20],	A	;Lenght: 24
	ld	A,	$C0
	ldh	[$FF23],	A	;Fire single
	jp	.endbasket
				
.isbasket			;if it is a basket
	ld	A,	[$FF04]	;dispence a random load of apples
	and	A,	$3
	add	A,	$3
	ld	[a_dispencer],	A
	ld	A,	$4
	ld	[o_bonusattr],	A
	ld	A,	$FD		;make it a cherry
	ld	[o_bonuschr],	A

	ld	A,	[$FF04]	;randomnize the level at which the bonus appears
	and	A,	$1	; between 8 and 9
	add	A,	$8
	ld	[g_bonusniv],	A
.endbasket

.notClearbonus
	;look if we need to repos the bonus
	ldh	A,	[g_bonuschr]
	cp	A,	gEMPTY
	jp	Z,	.notUpdbonus
	cp	A,	gGRASS
	jp	Z,	.notUpdbonus
	cp	A,	$FC
	jp	Z,	.notUpdbonus

	call	mPosbonus
.notUpdbonus
.nobonus

;--- Update Timer -------------------------------------------------------------;

mUpdTimer					;increase our timer by one
	ld	HL,	g_message+7		;start with the last digit
.loop
	ld	A,	[HL]			;load the old digit
	cp	gTIMER				;if we overflew the low part
	jp	Z,	.increaseSpeed		; speed it up a bit
	cp	gEMPTY
	jp	NZ,	.notempty		;if empty, then replace with 0
	ld	A,	$30
.notempty
	cp	$3A					;if it is not in the range "0"-"9"
	jp	NC,	endUpdTimer	; then there is some other message in the display
	cp	$30					; so skip the update
	jp	C,	endUpdTimer	; else it will scramble the message
	dec	A					;increase the digit
	ld	[HL],	A			; store it back again
	cp	A,	$2F				;if it isn't larger than "9" now
	jp	NZ,	endUpdTimer	; then we are done
	ld	A,	$39				;else correct our ":" with a "0"
	ld	[HL-],	A			; store it back, decrease the pointer
	jp	.loop				; and update the next digit
.increaseSpeed
	ld	A,	[v_speed]	;load the game speed
	inc	A			; and increase it
	cp	A,	$0		;speed should never go to 0
	jp	Z,	tDie		; else we kill it
	ld	[v_speed],	A

	dec	HL
	dec	HL

	;--- check if we need to show an bonus ---
	ld	A,	[HL]
	inc	A
	ld	B,	A
	ld	A,	[g_bonusniv]
	or	A,	$30
	cp	A,	B
	jp	nz,	.dontUpdbonus

	ld	A,	$0B			;play the powerup sound
	ldh	[$FF22],	A	;Freq=0x0B
	ld	A,	$F8
	ldh	[$FF21],	A	;Enveloppe: start=F up
	ld	A,	32		
	ldh	[$FF20],	A	;Lenght: 32
	ld	A,	$C0
	ldh	[$FF23],	A	;Fire single

	call	mPosbonus
	jp	mUpdTimer2

.dontUpdbonus
	ld	A,	$0A			;play the speed-up sound
	ldh	[$FF22],	A	;Freq=0x0B
	ld	A,	$F8
	ldh	[$FF21],	A	;Enveloppe: start=F up
	ld	A,	12		
	ldh	[$FF20],	A	;Lenght: 12
	ld	A,	$C0
	ldh	[$FF23],	A	;Fire single

	xor	A
	ld	[o_bonusx],	A	;disable bonus


mUpdTimer2					;increase our second timer by one
.loop
	ld	A,	[HL]			;load the old digit
	cp	gTIMER				;if we overflew the low part
	jp	Z,	.increaseSpeed		; speed it up a bit
	cp	gEMPTY
	jp	NZ,	.notempty		;if empty, then replace with 0
	ld	A,	$30
.notempty
	cp	$3A					;if it is not in the range "0"-"9"
	jp	NC,	endUpdTimer	; then there is some other message in the display
	cp	$30					; so skip the update
	jp	C,	endUpdTimer	; else it will scramble the message
	inc	A					;increase the digit
	ld	[HL],	A			; store it back again
	cp	A,	$3A				;if it isn't larger than "9" now
	jp	NZ,	endUpdTimer	; then we are done
	ld	A,	$30				;else correct our ":" with a "0"
	ld	[HL-],	A			; store it back, decrease the pointer
	jp	.loop				; and update the next digit
.increaseSpeed


endUpdTimer


;##############################################################################;
;###### POST RESET ############################################################;
;##############################################################################;
; start of ugliness
; this stuff is executed the first step after a reset, to show the "START" message
; it also (weirdly) scrolls the screen if needed
; TODO: just make this nicer

	ldh	A,	[m_rstcnt]	;look if we have to reset yet
	cp	A,	$FF			; if not, then head on
	jp	Z,	noFreeze	;

	dec	A				;decrease counter
	ldh	[m_rstcnt],	A	; store it back
	jp	NZ,	noFreeze	; and if it isn't yet our time, head back again

	di					;disable the interrupts; I'm to scared of some VBlank Interrupt happening
.wait
	ldh	a,	[rLY]		; wait for
	cp	$90				;  vertical blank
	jr	nz,	.wait		; because we need to work on the display

	;put some fake tiles in to prevent short bursts of grafic corruption
	ld	A,	$E2			
	ld	[$98E9], A
	ld	A,	$09	
	ld	[$98EA], A
	ld	[$98EB], A
	ld	A,	$E1	
	ld	[$98EC], A

	;look if we did just start... else we can't put the tiles for the second bank in
	ld	A,	[g_justStart]
	cp	A,	$0
	jp	Z,	.notJustStart

	ld	A,	$E2	
	ld	[$9AE9], A
	ld	A,	$09	
	ld	[$9AEA], A
	ld	[$9AEB], A
	ld	A,	$E1	
	ld	[$9AEC], A

.notJustStart
	ld	A,	$1	;in each case, notify we did the just start
	ld	[g_justStart],	A

	;change the display method
	ld	a,	%11100001	; LCD on + BG on + BG $8000 + WIN on + WIN $9C00
	ld	[rLCDC],	A

	ldh	A,	[v_desty]	;if we didn't change the level
	ld	B,	A
	ldh	A,	[rSCY]
	cp	B
	jp	Z,	saveHighscore	;don't copy a new level in

copyLevel1		;copy first row of the leve
	xor	A
	call	gCopyLevel
	ld	A,	$1
	call	gCopyLevel
	ld	A,	$2
	call	gCopyLevel
copyLevel2

.wait
	ldh	a,	[rLY]		; perform a vertical blank
	cp	$90				;  in between
	jr	nz,	.wait		; it just takes too much time

	ld	A,	$3
	call	gCopyLevel
	ld	A,	$4
	call	gCopyLevel

saveHighscore
.wait
	ldh	a,	[rLY]		; wait for
	cp	$90				;  new vertical blank
	jr	nz,	.wait


	ld	A,	[$9C21]
	cp	A,	gLVL1
	jp	Z,	.noHigh		; look if we have a new highscore

	call	gUpdHigh	; if so, update it

.noHigh
	ld	A,	gLVL1		; put in the string "LVL"+our level number
	ld	[$9C21],	A

	ld	A,	gLVL2
	ld	[$9C22],	A

	ld	A,	[g_level]
	add	A,	$31
	ld	[$9C23],	A

	call	gSnkAnim1

scroll2pos
.wait
	ldh	a,	[rLY]		; wait for
	cp	$0				;  outside vertical blank
	jr	nz,	.wait
.wait2
	ldh	a,	[rLY]		; wait for
	cp	$90				;  inside vertical blank
	jr	nz,	.wait2

	ldh	A,	[v_desty]	; look if we need to scroll the screen
	ld	B,	A
	ldh	A,	[rSCY]
	cp	B
	jp	Z,	.endscroll	;  else, pass
	inc	A				; increase scroll
	ldh	[rSCY],	A		;  store it back

	add	A,	$4			; add some (for first row)

	call	gCopyLevel	; and copy our level

	ld	A,	$E9			;finally, redraw our snake
	ld	L,	A
	ldh	A,	[g_vidBase]
	ld	H,	A

	ld	A,	$E2	
	ld	[HL+], A
	ld	A,	$09
	ld	[HL+], A
	ld	[HL+], A
	ld	A,	$E1	
	ld	[HL+], A

	jp	scroll2pos		;and continue our animation


.endscroll
	ldh	A,	[rSCX]		;scroll horizontally after
	cp	$0				; if needed, of course
	jp	Z,	.nohscroll
	dec	A
	ldh	[rSCX],	A
	jp	scroll2pos

.nohscroll
	ld	A,	gEMPTY		;clear our snake
	ld	[$98E9], A		;because we are going to enable our sprites
	ld	[$98EB], A
	ld	[$98EC], A
	ld	[$9AE9], A
	ld	[$9AEB], A
	ld	[$9AEC], A

	;put the sprites on again
	ld	a,	%11100011	; LCD on + BG on + BG $8000 + WIN on + WIN $9C00 + OBJ on
	ldh	[rLCDC],	A
	xor	A
	ldh	[rSCX],	a 		;clear scroll in case of

	call	gWaitKey	;now, we are done, so wait for user to press key
	; warning: we are now heading out of VBlank... but okay, the remainder is 
	;  buffered data

	ld	A,	gAPPLE		;then, show score rightly
	ldh	[s_score],	A

	ld	A,	$30
	ldh	[s_score+1],	A
	ldh	[s_score+2],	A

	ldh	A,	[b_prev]	;look if he wants to switch level
	and	A,	$F0
	cp	$0
	jp	NZ,	gSwitchLevel	;if so, then switch the level
	;else, he is going to play

drawEmptyTimer	;draw the starting text for the time
	ld	HL,	gMessageTimer
	ld	DE,	g_message
	ld	B,	8
.loop
	ld	A,	[HL+]
	ld	[DE],	A
	inc	DE
	dec	B
	jp	NZ,	.loop

	xor	a	;clear the interrupts
	ldh	[rIF],	a
	ei	;enable them again

noFreeze
	jp	mMainStepEnd	;and restart

;--- End of Stepping ----------------------------------------------------------;



;##############################################################################;
;###### SOFT RESET ############################################################;
;##############################################################################;

gSwitchLevel
.wait
	ldh	a,	[rLY]		; wait for
	cp	$90				;  vertical blank
	jr	nz,	.wait

;--- Save Scores --------------------------------------------------------------;
	ldh	A,	[g_level]
	ld	L,	A
	add	A,	L
	add	A,	L
	ld	HL,	s_scores
	add	A,	L
	ld	L,	A

	ld	A,	[$9C30]
	cp	A,	gLVL1
	jp	Z,	.ignoreScore

	ld	[HL+],	A
	ld	A,	[$9C31]
	ld	[HL+],	A
	ld	A,	[$9C32]
	ld	[HL+],	A

.ignoreScore

;--- Increase Level ------------------------------------------------------------;

	ldh	A,	[g_level]
	inc	A
	and	$7
	ldh	[g_level],	A


;--- Reload Scores ------------------------------------------------------------;
	ldh	A,	[g_level]
	ld	L,	A
	add	A,	L
	add	A,	L
	ld	HL,	s_scores
	add	A,	L
	ld	L,	A

	ld	A,	[HL+]
	ld	[$9C30],	A
	ld	A,	[HL+]
	ld	[$9C31],	A
	ld	A,	[HL+]
	ld	[$9C32],	A

	ldh	A,	[v_desty]
	cp	$0
	jp	nz,	.otherone
	ld	A,	$9A
	ldh	[g_vidBase],	A

	ld	A,	$80
	jp	.endone

.otherone
	ld	A,	$98
	ldh	[g_vidBase],	A

	ld	A,	$00

.endone
	ldh	[v_desty],	A


errTrail
stopTail
tDie
	di

	ld	A,	$3
	call	gDrawMessage

.wait
	ldh	a,	[rLY]		; wait for
	cp	$90				;  vertical blank
	jr	nz,	.wait



;--- Clear Screen -------------------------------------------------------------;

	ldh	A,	[a_appleadr]
	ld	L,	A
	ldh	A,	[a_appleadr+1]
	or	A,	$98
	ld	H,	A

	ld	A,	[HL]
	cp	A,	gAPPLE
	jp	NZ,	.noappleupd

	ld	A,	gEMPTY
	ld	[HL],	A

.noappleupd
	ldh	A,	[h_head2adr]
	ld	L,	A
	ldh	A,	[h_head2adr+1]
	or	A,	$98
	ld	H,	A

	ld	A,	gEMPTY
	ld	[HL],	A

	ldh	A,	[a_appleadr]
	ld	L,	A
	ldh	A,	[a_appleadr+1]
	or	A,	$98
	ld	H,	A

	ld	A,	[HL]
	cp	A,	gAPPLE
	jp	NZ,	.noappleupd2
	ld	A,	gEMPTY
	ld	[HL],	A
.noappleupd2

	ld	A,	H
	or	A,	$9A
	ld	H,	A

	ld	A,	[HL]
	cp	A,	gAPPLE
	jp	NZ,	.noappleupd3

	ld	A,	gEMPTY
	ld	[HL],	A
.noappleupd3

	;give the tail a trail to follow
	ld	A,	$9		
	ld	[$98EA], A	;bank 0
	ld	[$9AEA], A	;bank 1
	ld	[$98E9], A	;bank 0
	ld	[$9AE9], A	;bank 1


;--- Reset Variables ----------------------------------------------------------;
	xor	A		;load 0

	ldh	[v_flag],	A
	ldh	[v_time],	A
	ldh	[b_pressed],	A
	ldh	[b_evH],	A
	ldh	[b_evV],	A
	ldh	[a_ateapple],	A
	ldh	[h_head1dirV],	A
	ldh	[h_head2dirV],	A
	ld	[o_bonusx],	A
	ld	[o_bonusy],	A

	;ld	A,	$01
	inc	A
	ldh	[h_head1dirH],	A
	ldh	[h_head2dirH],	A
	ldh	[v_trail],	A

	ld	A,	3
	ldh	[m_rstcnt],	A
	ldh	[a_error],	A
	ld	[o_bonusattr],	A

	ld	A,	7
	ldh	[h_head1y],	A
	ldh	[t_tail1y],	A

	;ld	A,	8
	inc	A
	ldh	[t_tail1x],	A

	;ld	A,	$9
	inc	A
	ldh	[v_corpse],	A

	;ld	A,	10
	inc	A
	ldh	[h_head1x],	A

	ld	A,	13
	ld	[v_speed],	A

	ld	A,	$7E
	ldh	[s_songpos],	A

	ld	A,	gEMPTY
	ldh	[g_bonuschr],	A
	ldh	[v_eating],	A

	ld	A,	$98
	ldh	[h_head2adr],	A
	ldh	[h_head2adr+1],	A
	ldh	[g_bonusadr],	A
	ldh	[g_bonusadr+1],A

	ld	A,	[$FF04]	;randomnize the level at which the bonus appears
	and	A,	$3	; between 3 and 7
	add	A,	$3
	ld	[g_bonusniv],	A

	ld	A,	$3	;set bonus color to grey
	ld	[o_bonusattr],	A

	ld	A,	$FC	;set bonus char to basket
	ld	[o_bonuschr],	A

;--- Restart ------------------------------------------------------------------;
mRestaerd

.wait
	ldh	a,	[rLY]		; wait for
	cp	$90				;  vertical blank
	jr	nz,	.wait

	ld	A,	$09	
	ld	[$98E9], A

	ld	HL,	o_start
	ld	B,	16
	ld	A,	0
.clearOAM
	ld	[HL+],	A
	dec	B
	jp	NZ,	.clearOAM

	ld	A,	$FF
	ldh	[t_tail2adr],	A

	xor	a
	ld	[rIF],	a

	ei
	jp	iReset


;---- position bonus ------------------------------------------------------;

mPosbonus

	ld	A,	[$FF04]	;position it at a random position
	ld	B,	A
	and	A,	$F
	add	A,	$2

	ld	D,	A

	inc	A
	rla
	rla
	rla		
	ld	[o_bonusx],	A

	ld	A,	B
	swap	A
	and	A,	$F
	ld	E,	A
	inc	A
	inc	A
	rla
	rla
	rla
	ld	[o_bonusy],	A
	

	;convert bonus pos to display address
	ld	A,	E			; get row
	swap	A				; *16
	rlc	A				; *32
	ld	C,	A			; save result for later
	and	$03				; calc MSB VRAM row start
	ldh	[g_bonusadr+1],	A	; set MSB of VRAL ptr
	ld	E,	A
	ld	A,	$E0			; LSB VRAM row start mask
	and	C				; calc LSB VRAM row start
	ld	C,	A			; save LSB VRAM row start
	ld	A,	D			; get column
	add	A,	C			; add LSB VRAM row start
	ldh	[g_bonusadr],	A	; set MSB of VRAL ptr

	ret

;##############################################################################;
;###### VERTICAL BLANK EXCLUSIVE ##############################################;
;##############################################################################;

;-------Animate Snake----------------------------------------------------------;

snkAnim
	cp	0			;if it is 0
	jr	nz,	.is1
	jp	gSnkAnim1
.is1
	dec	A			;if it is 1
	jr	nz,	.is2
	jp	gSnkAnim2
.is2
	dec	A
	jr	nz,	.is3
	jp	gSnkAnim3
.is3
	dec	A
	jr	nz,	.is4
	jp	gSnkAnim4
.is4
	dec	A
	jr	nz,	.is5
	jp	gSnkAnim5
.is5
	dec	A
	jr	nz,	.is6
	jp	gSnkAnim6
.is6
	dec	A
	jr	nz,	.is7
	jp	gSnkAnim7
.is7
	dec	A
	jr	nz,	.is8
	jp	gSnkAnim8
.is8
	ret


;-------Save Registers---------------------------------------------------------;
vBlank

	push	AF	;Save registers
	push	BC
	push	DE
	push	HL

 
;-------Update Animated Tiles--------------------------------------------------;

	ld	DE,	$9000	;Tile base address
	ldh	A,	[v_time]	;look to the time
	swap	A
	and	7
	ld	B,	A	;Save time
	call	snkAnim		;Animate snake

	ld	D,	$9C	;Load base address destination message
	ld	HL,	g_message

	ld	A,	B	;Load tile indicated by time
	add	A,	$26	;to address + $9C26
	ld	E,	A

	ld	A,	B
	add	A,	L	;Source= [message+time]
	ld	L,	A

	ld	A,	[HL]	;Load from source...
	ld	[DE],	A	;... to destination

;-------Update Time------------------------------------------------------------;


	ldh	A,	[v_time]
	ld	D,	A
	ldh	A,	[v_speed]
	add	A,	D
	ldh	[v_time],	A

	ld	A,	[v_newframe]
	cp	$0		;look if we wanna update them all
	jp	Z,	.dontupdcorp	;if not, than skip a big part

	ld	A,	$0
	ld	[v_newframe],	A

	ld	A,	[g_vidBase]	;load the base adress of our video
	ld	D,	A

;-------Update Apple ----------------------------------------------------------;

	ldh	A,	[a_appleadr]
	ld	L,	A
	ldh	A,	[a_appleadr+1]
	or	A,	D
	ld	H,	A		;load the base address for the apple

	ld	A,	[HL]		;look what is in the place now
	cp	gEMPTY			; if it is empty...
	jp	Z,	.noapperror	; ... then no problem
	cp	gGRASS			; if it is grass...
	jp	Z,	.noapperror	; ... then no problem
	cp	gAPPLE			; if it is apple
	jp	Z,	.noapperror	; ... whatever

	ld	A,	42		;else signal an error
	jp	.enderror

.noapperror
	ld	A,	1		;colorify
	ldh	[$FF4F],A	;Set vbank 1
	ld	A,	3
	ld	[HL],	A

	xor	A
	ldh	[$FF4F],A	;Set vbank 0

	ld	A,	gAPPLE	;load apple at address
	ld	[HL],	A

	xor	A		;signal no apple error
.enderror
	ldh	[a_error],	A

;-------Update bonus----------------------------------------------------------;

	ldh	A,	[g_bonusadr]
	ld	L,	A
	ldh	A,	[g_bonusadr+1]
	or	A,	D
	ld	H,	A		
	ld	A,	[HL]
	ld	[g_bonuschr],	A


;-------Update Corpse----------------------------------------------------------;

	ldh	A,	[h_head1adr]
	ld	L,	A
	ldh	A,	[h_head1adr+1]
	or	A,	D
	ld	H,	A	;load address Head-1

	ld	A,	[HL]	;lookup what we are eating
	ldh	[v_eating],	A

	ldh	A,	[h_head2adr]
	ld	L,	A
	ldh	A,	[h_head2adr+1]
	or	A,	D
	ld	H,	A	;load address Head-2


	ld	A,	1	;colorify
	ldh	[$FF4F],A	;Set vbank 1

	xor	A
	ld	[HL],	A
	ldh	[$FF4F],A	;Set vbank 0

	ldh	A,	[v_corpse]	;load our corpse
	ld	[HL],	A	;...at that address

.freezecorpse

;-------Update Trail----------------------------------------------------------;
	ldh	A,	[t_tail1adr+1]
	or	A,	D
	ld	H,	A
	ldh	A,	[t_tail1adr]
	ld	L,	A	;load tail address

	ld	A,	[HL]	;lookup what is underneath
	ldh	[v_trail],	A

	cp	A,	12		;look if we are digesting something
	jp	c,	.notailegg	; if not, no problem
	and	$F	; else replace it by a normal corpse
	ld	[HL],	A	;and store it in memory
.notailegg

	ldh	A,	[t_tail2adr+1]	;then load address of tail
	or	A,	D
	ld	H,	A

	ldh	A,	[t_tail2adr]	; to clear it
	ld	L,	A

;Yvar's secret grass hatcher
	swap	A
	xor	L
	ld	C,	A
	add	C
	add	C
	rra
	and	32
	add	32

	ld	[HL],	A
.dontupdcorp

;-------Score------------------------------------------------------------------;

	;finally, update score
	ldh	A,	[m_rstcnt]
	cp	A,	$FF
	jp	NZ,	.noupdscore	;if resetting, don't update score

	ldh	A,	[s_score]	;else, update score
	ld	[$9C21],	A
	ldh	A,	[s_score+1]
	ld	[$9C22],	A
	ldh	A,	[s_score+2]
	ld	[$9C23],	A

.noupdscore

;-------Copy OAM---------------------------------------------------------------;

	call	v_oam


;-------Animate Window---------------------------------------------------------;

	ldh	A,	[rWY]
	cp	129
	jp	c,	.dontscroll
	dec	A
	ldh	[rWY],	A
.dontscroll

	call gUpdSprites

 
;-------Notify of a VBlank Update----------------------------------------------;

	ld	A,	1		;notify a vblank just happened
	ldh	[v_flag],	A

	ld	A,	0		;clear interrupt flag
	ldh	[rIF],	A

 
;-------Restore Registers------------------------------------------------------;

	pop	HL	;restore registers
	pop	DE
	pop	BC
	pop	AF

	reti		;and return

 
;-------Increase sprites-------------------------------------------------------;

gUpdSprites
;-------Increase Sprites for Head----------------------------------------------;

vIHead

	ldh	A,	[v_corpse]
	cp	$FF
	jp	Z,	.freezehead	;if head is frozen, don't update it

	ldh	A,	[v_eating]	;look if we ain't eating something
	cp	A,	gEMPTY
	jp	Z,	.updhead1normally
	cp	A,	gGRASS
	jp	Z,	.updhead1normally ; because then we update it normally

	ldh	A,	[v_head1chr]	;look if we are heading upwards
	and	A,	$20
	jp	NZ,	.updhead1normally

	ldh	A,	[v_head1chr]	;load normal head
	and	A,	$10		; look what direction we are looking
	
	sra	A			; divide by 2
	ld	H,	A		;store it temporary

	ld	A,	B		;look at the time
	or	A,	H		;add the head dir
	ld	[o_head1chr],	A	;and store it as the head
	xor	A
	ld	[o_head1attr],	A	;but store 0 as the head attributes
	jp	.vIHead1End		; and end

.updhead1normally

	ld	H,	$40

	ld	A,	[v_head1chr]	;increase char for head-1...
	and	A,	$F8
	or	A,	B
	ld	L,	A
	ld	A,	[HL]
	ld	[o_head1chr],	A
	inc	H
	ld	A,	[HL]
	ld	[o_head1attr],	A

.vIHead1End
	ld	A,	[h_eated]	;look if we did just eat air
	cp	A,	gEMPTY
	jp	Z,	.updhead2normally
	cp	A,	gGRASS
	jp	Z,	.updhead2normally ; because then we update it normally
	
	ld	A,	B
	and	A,	$4	;look if we are too early
	jp	Z,	.updhead2normally

	ld	HL,	g_mapeaten

	ld	A,	[v_head2chr]	;load head 2 char
	and	A,	$F0
	swap	A
	ld	L,	A	;lookup table

	ld	A,	[HL]	;load from table
	ld	L,	A

	ld	A,	B	;add time
	dec	A
	sra	A		;/2
	and	A,	$1	;&1
	or	A,	L	;add head

	ld	[o_head2chr],	A	;and store it as the head
	xor	A
	ld	[o_head2attr],	A	;but store 0 as the head attributes
	jp	.vIHead2End		; and end

.updhead2normally

	ld	H,	$40

	ld	A,	[v_head2chr]	;... and for head-2
	and	A,	$F8
	or	A,	B
	ld	L,	A
	ld	A,	[HL]
	ld	[o_head2chr],	A
	inc	H
	ld	A,	[HL]
	ld	[o_head2attr],	A
.vIHead2End
.freezehead
.vIHeadEnd


;-------Increase Sprites for Tail----------------------------------------------;

vITail
	ldh	A, [t_freeze]
	cp	$0
	jr	nz, .vTailEnd	;if tail is frozen, don't update it

	ld	H,	$40

	ld	A,	[v_tail1chr]
	and	A,	$F8
	or	A,	B
	ld	L,	A
	ld	A,	[HL]
	ld	[o_tail1chr],	A
	inc	H
	ld	A,	[HL]
	ld	[o_tail1attr],	A

	ld	H,	$40

	ld	A,	[v_tail2chr]
	and	A,	$F8
	or	A,	B
	ld	L,	A
	ld	A,	[HL]
	ld	[o_tail2chr],	A
	inc	H
	ld	A,	[HL]
	ld	[o_tail2attr],	A

.vTailEnd
	ret
 
;-------Sprite (OAM) DMA-------------------------------------------------------;

vDMA
	db	$3E,$C0,$E0,$46,$3E,$28,$3D,$20,$FD,$C9


;##############################################################################;
;###### Music ##################################################################;
;##############################################################################;

sPlayMusic1
	ldh	A,	[s_songpos]	;load songpos
	inc	A
	and	A,	$7F		;song is 64 steps long
	ldh	[s_songpos],	A
	dec	A

	ld	HL,	sNotes1		;load note table
	ld	DE,	sSong1		;load song position
	add	A,	E		;add song time
	ld	E,	A		;...and save as song position
	jp	NC,	.nocarry	;perform carry if needed
	inc	D
.nocarry

	ld	A,	[DE]	;load current notes in song
	ld	D,	A	;save temporary
	and	$0F		;16 different notes on left channel
	cp	$0		;look if note is silent
	jp	Z,	.noNote	;if so, don't play it
	dec	A		;else, start at 1
	sla	A		;2 bytes per note in the notetable
	add	A,	L	;add base address of notetable 1
	ld	L,	A	

	ld	A,	[HL+]	;load low frequency from notetable 1...
	ldh	[$FF13],	A	;... in left channel
	ld	A,	[HL+]	;load high frequency from notetable 1...
	or	A,	$80	;... make it trigger ...
	ldh	[$FF14],	A	;... in left channel

.noNote
	ld	HL,	sNotes2	;load notetable 2
	ld	A,	D	;load current notes
	swap	A		;look at high nibble
	and	$0F		;16 different notes on right channel
	cp	$0		;look if note is silent
	jp	Z,	.noNote2	; if so, then don't play it
	dec	A		;else, start at 1
	sla	A		;2 bytes per note in the notetable
	add	A,	L	;add base address of notetable 2
	ld	L,	A

	ld	A,	[HL+]	;load low frequency from notetable 2
	ldh	[$FF18],	A	;... in right channel
	ld	A,	[HL+]	;load high frequency from notetable 2...
	or	A,	$80	;... make it trigger ...
	ldh	[$FF19],	A	;... in right channel

.noNote2
	ret	;end of song routine


;##############################################################################;
;###### DATA ##################################################################;
;##############################################################################;

SECTION "data",ROMX[$4000]
;------------------------------------------------------------------------------;
; translate movable head-tail parts into real addresses

g_mapmov
	db $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2A, $2B, $2C, $2D, $2E, $2F
	db $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3A, $3B, $3C, $3D, $3E, $3F 
	db $40, $41, $42, $43, $44, $45, $46, $47, $48, $49, $4A, $4B, $4C, $4D, $4E, $4F 
	db $50, $51, $52, $53, $54, $55, $56, $39, $38, $37, $57, $58, $59, $5A, $5B, $5C 
	db $5D, $5E, $5F, $60, $61, $62, $63, $64, $65, $66, $67, $68, $69, $6A, $6B, $6C 
	db $6D, $6E, $6F, $70, $71, $72, $73, $49, $48, $47, $74, $75, $76, $77, $78, $79 
	db $7A, $7B, $7C, $7D, $7E, $7F, $80, $66, $65, $64, $81, $82, $69, $83, $84, $85 
	db $86, $87, $88, $89, $8A, $8B, $8C, $8D, $28, $27, $8E, $8F, $90, $91, $92, $93 
	db $94, $95, $96, $97, $98, $99, $9A, $9B, $9C, $9D, $9E, $9F, $A0, $A1, $A2, $A3 
	db $A4, $A5, $A6, $A7, $A8, $A9, $AA, $9D, $9C, $AB, $AC, $AD, $AE, $AF, $B0, $B1 
	db $B2, $B3, $B4, $B5, $B6, $B7, $B8, $B9, $BA, $BB, $BC, $BD, $BE, $BF, $C0, $C1 
	db $C2, $C3, $C4, $C5, $C6, $C7, $C8, $C9, $BA, $B9, $CA, $CB, $CC, $CD, $CE, $CF 
	db $D0, $D1, $D2, $D3, $D4, $D5, $D6, $D7, $D8, $D9, $DA, $DB, $DC, $DD, $DE, $DF 
	db $D0, $D1, $D2, $D3, $D4, $D5, $E0, $E1, $E2, $E3, $E4, $DB, $DC, $DD, $DE, $DF 
	db $E5, $E6, $E7, $E8, $E9, $EA, $EB, $EC, $ED, $EE, $EF, $F0, $F1, $F2, $F3, $F4 
	db $E5, $E6, $E7, $E8, $E9, $EA, $EB, $EC, $F5, $F6, $F7, $F8, $F9, $FA, $FB, $F4 

g_mapatr
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $20, $20, $20, $20, $20, $20, $00, $00, $00, $00, $00, $20, $20, $20, $20, $20 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $60, $40, $40, $40, $40, $40, $40, $40, $00, $00, $00, $00, $00, $00, $00, $00 

g_mapeaten
	db $10, $12, $14, $12, $16, $14, $12, $10, $18, $18, $1A, $1A, $18, $18, $1A, $1A

;-------Animation-----------------------------------------------------------------;

INCLUDE "anim.asm"	;code for the snake animations

;-------Colors-----------------------------------------------------------------;

gColors
		;gggrrrrr,	 -bbbbbgg

;-------palette 0:greens
gPal0
	db	%11111111,	%01111111
	db	%01101100,	%00100011
	db	%10100100,	%00011001
	db	%00000000,	%00000000

;-------palette 1:browns
gPal1
	db %11111111,	%01111111
	db %11010111,	%00001010
	db %11001111,	%00000100
	db %00000000,	%00000000


;-------palette 2:blues
gPal2
	db %11111111,	%01111111
	db %11100011,	%01110110
	db %11100000,	%01011100
	db %00000000,	%00000000


;-------palette 3:greys
gPal3
	db %11111111,	%01111111
	db %11101111,	%00111101
	db %11100111,	%00011100
	db %00000000,	%00000000


;-------palette 3:reds
gPal4
	db %11111111,	%01111111
	db %11111111,	%00111101
	db %00011111,	%00000000
	db %00000000,	%00000000

;-------Shapes-----------------------------------------------------------------;

gShapes
	incbin	"shapes.bin"	;all our remaining shapes
gShapesEnd


gHeader1	;the top of our header
	db	$28,$2C,$2C,$2C,$29,$28,$2C,$2C,$2C,$2C
	db	$2C,$2C,$2C,$2C,$29,$28,$2C,$2C,$2C,$29

gHeader2	;the bottom of our header
	db	$2E,gAPPLE,"00",$2F,$2E,gTIMER,gEMPTY,"000000",$2F,$2E,gHIGH,"00",$2F

gMessageTimer
	db	$E2,$E1,gEMPTY,gEMPTY,gEMPTY,gTIMER,$39,$39

;-------Splash-----------------------------------------------------------------;
gSplash1	;the logo splash
	db	" "," "," "," "," ","G","A","M","E","B","O","Y"," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "

	db	" ",$03,$08,$E1," "," "," "," "," "," "," "," "," ",$EC," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "

	db	" ",$0A," "," "," ",$EC,$D7,$00," ",$E2,$08,$00," ",$0A," ",$EC," ",$01,$08,$00," "," "," "," "," "," "," "," "," "," "," "," "

	db	" ",$05,$09,$00," ",$0A," ",$0A," "," "," ",$0A," ",$0A,$01,$04," ",$0A,$D7,$04," "," "," "," "," "," "," "," "," "," "," "," "

	db	" "," "," ",$0A," ",$0A," ",$0A," ",$01,$E1,$0A," ",$0A,$02,$00," ",$0A," "," "," "," "," "," "," "," "," "," "," "," "," "," "

	db	" ",$E2,$08,$04," ",$ED," ",$ED," ",$05,$08,$04," ",$ED," ",$ED," ",$02,$08,$D8," "," "," "," "," "," "," "," "," "," "," "," "

	db	" "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "

	db	" ","H","O","M","E","B","R","E","W"," ",gAPPLE," ","2","0","1","7"," ","Y","D","G"," "," "," "," "," "," "," "," "," "," "," "," "

	db	" "

gSplashHeader1	;the top of the splash header
	db	$28,$2C,$2C,$2C,$2C,$2C,$29,$28,$2C,$2C
	db	$2C,$2C,$2C,$2C,$2C,$2C,$2C,$2C,$2C,$29

gSplashHeader2	;the bottom of the splash header
	db	$2E,"V0",$3A,"2D",$2F,$2E,"PRESS START",$2F

;-------Music-----------------------------------------------------------------;
sNotes1		;noteset 1, lead
	dw	1546		; 1 : C5
	dw	1602		; 2 : D5
	dw	1650		; 3 : E5
	dw	1673		; 4 : F5
	dw	1714		; 5 : G5
	dw	1750		; 6 : A5
	dw	1767		; 7 : A#5
	dw	1798		; 8 : C6
	dw	1825		; 9 : D6
	dw	1849		; A : E6

sNotes2		;noteset 2, basses
	dw	1046		; 1 : C4
	dw	1155		; 2 : D4
	dw	1253		; 3 : E4
	dw	1297		; 4 : F4
	dw	1379		; 5 : G4
	dw	1452		; 6 : A4
	dw	1486		; 7 : A#4
	dw	1546		; 8 : C5


sNotes3		;noteset 3, unused
	;dw	44		; 1 : C4
	;dw	262		; 2 : D4
	;dw	457		; 3 : E4
	;dw	547		; 4 : F4
	;dw	710		; 5 : G4
	;dw	854		; 6 : A4
	;dw	923		; 7 : A#4
	;dw	986		; 8 : C5

sSong1
	;high nibble - bass channel
	;low nibble - lead channel
	db	$38	; C5 E3
	db	$20	; -- D3
	db	$47	; B4 F3
	db	$06	; A4 --

	db	$15	; G4 C3
	db	$20	; -- D4
	db	$07	; B4 --
	db	$00	; -- --

	db	$16	; A4 C3
	db	$20	; -- D3
	db	$37	; B4 E3
	db	$06	; A4 --

	db	$25	; G4 D3
	db	$10	; -- C3
	db	$04	; F4 --
	db	$00	; -- --

	db	$56	; A4 G3
	db	$40	; -- F3
	db	$35	; G4 E3
	db	$06	; A4 --

	db	$45	; G4 F3
	db	$30	; -- E3
	db	$24	; F4 D3
	db	$00	; -- --

	db	$43	; E4 F3
	db	$24	; F4 D3
	db	$43	; E4 F3
	db	$00	; -- --

	db	$22	; D4 D3
	db	$43	; E4 F3
	db	$31	; C4 E3
	db	$00	; -- --

	;----------------------

	db	$38	; C5 E3
	db	$20	; -- D3
	db	$47	; B4 F3
	db	$06	; A4 --

	db	$17	; B4 C3
	db	$20	; -- D4
	db	$06	; A4 --
	db	$00	; -- --

	db	$17	; B4 C3
	db	$20	; -- D3
	db	$36	; A4 E3
	db	$05	; G4 --

	db	$35	; A4 D3
	db	$10	; -- C3
	db	$04	; F4 --
	db	$00	; -- --

	db	$56	; A4 G3
	db	$40	; -- F3
	db	$35	; G4 E3
	db	$06	; A4 --

	db	$45	; G4 F3
	db	$30	; -- E3
	db	$24	; F4 D3
	db	$00	; -- --

	db	$43	; E4 F3
	db	$24	; F4 D3
	db	$43	; E4 F3
	db	$00	; -- --

	db	$22	; D4 D3
	db	$43	; E4 F3
	db	$31	; C4 E3
	db	$00	; -- --

	;----------------------

	db	$38	; C5 E3
	db	$20	; -- D3
	db	$49	; D5 F3
	db	$0A	; E5 --

	db	$19	; D5 C3
	db	$20	; -- D4
	db	$08	; C5 --
	db	$00	; -- --

	db	$16	; A4 C3
	db	$20	; -- D3
	db	$37	; B4 E3
	db	$06	; A4 --

	db	$27	; B4 D3
	db	$10	; -- C3
	db	$06	; A4 --
	db	$00	; -- --

	db	$54	; F4 G3
	db	$40	; -- F3
	db	$35	; G4 E3
	db	$06	; A4 --

	db	$45	; G4 F3
	db	$30	; -- E3
	db	$24	; F4 D3
	db	$00	; -- --

	db	$43	; E4 F3
	db	$24	; F4 D3
	db	$43	; E4 F3
	db	$00	; -- --

	db	$43	; E4 F3
	db	$31	; C4 E3
	db	$22	; D4 D3
	db	$00	; -- --

	;----------------------

	db	$38	; C5 E3
	db	$20	; -- D3
	db	$47	; B4 F3
	db	$06	; A4 --

	db	$15	; G4 C3
	db	$20	; -- D4
	db	$07	; B4 --
	db	$00	; -- --

	db	$16	; A4 C3
	db	$20	; -- D3
	db	$37	; B4 E3
	db	$06	; A4 --

	db	$25	; G4 D3
	db	$10	; -- C3
	db	$04	; F4 --
	db	$00	; -- --

	db	$56	; A4 G3
	db	$40	; -- F3
	db	$35	; G4 E3
	db	$06	; A4 --

	db	$45	; G4 F3
	db	$30	; -- E3
	db	$24	; F4 D3
	db	$00	; -- --

	db	$43	; E4 F3
	db	$24	; F4 D3
	db	$43	; E4 F3
	db	$00	; -- --

	db	$22	; D4 D3
	db	$43	; E4 F3
	db	$31	; C4 E3
	db	$00	; -- --

;##############################################################################;
;###### LEVELS ################################################################;
;##############################################################################;

gLevel	;list of all our levels
	dw	gLevel1
	dw	gLevel2
	dw	gLevel3
	dw	gLevel4
	dw	gLevel5
	dw	gLevel6
	dw	gLevel7
	dw	gLevel8

gLevel1	;The Grasses
	db	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0
	db	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0
	db	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0
	db	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0
	db	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0
	db	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0
	db	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0
	db	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0
	db	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0
	db	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0
	db	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0
	db	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0
	db	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0
	db	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0
	db	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0
	db	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0

gLevel2	;The Basket
	db	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0
	db	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0
	db	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0
	db	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0
	db	0, 0, 0, 0, 2, 4, 4, 1, 0, 0, 0, 0, 1, 4, 4, 3, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0
	db	0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0
 	db	0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0
	db	0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0
	db	0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0
	db	0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0
	db	0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0
	db	0, 0, 0, 0, 6, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 7, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0
	db	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0
	db	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0
	db	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0
	db	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0

gLevel3	;The Crossways
	db	2, 4, 4, 4, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 4, 4, 4, 4, 3,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,  0,0,0,0,0,0,0,0,0,0,0,0
	db	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0
	db	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0
	db	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0
	db	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0
	db	1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	6, 4, 4, 4, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 4, 4, 4, 4, 7,  0,0,0,0,0,0,0,0,0,0,0,0


gLevel4	;The Classic
	db	2, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 3,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
 	db	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
 	db	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	6, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 7,  0,0,0,0,0,0,0,0,0,0,0,0


gLevel5	;The Net
	db	2, 4, 4, 4, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 4, 4, 4, 4, 3,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 0, 0, 0, 2, 4, 4, 1, 0, 0, 0, 0, 1, 4, 4, 3, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	1, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 1,  0,0,0,0,0,0,0,0,0,0,0,0
	db	0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0
	db	0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0
	db	0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0
	db	0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0
	db	1, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 1,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 0, 0, 0, 6, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 7, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	6, 4, 4, 4, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 4, 4, 4, 4, 7,  0,0,0,0,0,0,0,0,0,0,0,0


gLevel6	;The Arena
	db	2, 4, 4, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 2, 4, 4, 3,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 2, 3, 5, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 5, 2, 3, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 6, 7, 5, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 5, 6, 7, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	6, 4, 4, 7, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 6, 4, 4, 7,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 1, 1, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 1, 1, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 1, 1, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 1, 1, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 1, 1, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 1, 1, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 1, 1, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 1, 1, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 1, 1, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 1, 1, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 1, 1, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 1, 1, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 1, 1, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 1, 1, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 1, 1, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 1, 1, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	2, 4, 4, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 2, 4, 4, 3,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 2, 3, 5, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 5, 2, 3, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 6, 7, 5, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 5, 6, 7, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	6, 4, 4, 7, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 6, 4, 4, 7,  0,0,0,0,0,0,0,0,0,0,0,0


gLevel7	;The House
	db	2, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 3,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 0, 0, 0, 1, 4, 4, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 4, 4, 1, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 0, 0, 0, 1, 4, 4, 4, 4, 1, 0, 0, 0, 5, 0, 0, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	6, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 7,  0,0,0,0,0,0,0,0,0,0,0,0


gLevel8	;The Knot
	db	2, 4, 4, 4, 4, 4, 4, 4, 4, 3, 2, 4, 4, 4, 4, 4, 4, 4, 4, 3,  0,0,0,0,0,0,0,0,0,0,0,0
	db	1, 0, 0, 0, 0, 0, 0, 0, 0, 5, 5, 0, 0, 0, 0, 0, 0, 0, 0, 1,  0,0,0,0,0,0,0,0,0,0,0,0
	db	0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0
	db	0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0
	db	0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0
	db	1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	6, 4, 4, 4, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 4, 4, 4, 4, 7,  0,0,0,0,0,0,0,0,0,0,0,0
	db	2, 4, 4, 4, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 4, 4, 4, 4, 3,  0,0,0,0,0,0,0,0,0,0,0,0
	db	5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5,  0,0,0,0,0,0,0,0,0,0,0,0
	db	1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1,  0,0,0,0,0,0,0,0,0,0,0,0
	db	0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0
	db	0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0
	db	0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,0,0,0,0,0,0,0,0,0,0,0
	db	1, 0, 0, 0, 0, 0, 0, 0, 0, 5, 5, 0, 0, 0, 0, 0, 0, 0, 0, 1,  0,0,0,0,0,0,0,0,0,0,0,0
	db	6, 4, 4, 4, 4, 4, 4, 4, 4, 7, 6, 4, 4, 4, 4, 4, 4, 4, 4, 7,  0,0,0,0,0,0,0,0,0,0,0,0




	db	"END OF ROM"	;end of our ROM