;
;	>> Boom!k 1k party coded compo ruler <<
;
;	120 stars at 50 FPS to save a Revision compo - like every year :-) 
;	The name is of course a (too) obvious reference to Bang! by SvOlli.
;
;	(c) 1991-12-25 by JAC! original idea
;	(r) 2014-04-19 by JAC! party coding final
;

x1	= $82
x2	= $83
x3	= $84

xcnt	= $90
ycnt	= $91
xspd	= $92
yspd	= $93
xorg	= $94
yorg	= $95
acnt	= $98

smup	= $a0

p1	= $e0
p2	= $e2
p3	= $e4

cnt	= $fe

anz	= 120
range	= 31
kwait	= 14

llo	= $4000
lhi1	= $4100
altlo1	= $4200
althi1	= $4300
lhi2	= $4400
altlo2	= $4500
althi2	= $4600
sinus	= $4700
dl	= $4c00
dl_lms1 = dl+$03
dl_lms2 = dl+$85
dl_vbl  = dl+$c7

xt	= $5000
xt1	= $5100
yt	= $5200
yt1	= $5300
gx1	= $5500
gy1	= $5700
rx	= $5800
ry	= $5900
ctab	= $5a00

pic	= $6000
sm1	= $8000
sm2	= $a000

sm_pages = $20

	org $2000

start	jsr scrninit
	jsr genadr
	lda #$a2
	sta xcnt
	sta ycnt
	sta $d203
	lda #$3d
	sta $d400
main	jsr swap
	jsr clrplot
	jsr anim
	jsr print
	jsr movestar
	lda $d20a
	and #31
	sta $d202
	inc cnt
	sne
	inc cnt+1
	lda cnt+1
	cmp #5
	bne main

	lda #0
	sta $d400
boom	lda cnt
	sta $d200
	sta $d202
	eor #$ff
	lsr
	lsr
	lsr
	lsr
	sta $d01a
	lda #$8a
	sta $d201
	sta $d203
sync_boom
	jsr sync_vcount
	inc cnt
	bne boom
	lda #0
	sta $d201
	sta $d203
	mwa #boom_dl $d402
	mva #$22 $d400
ending	lsr $d017
	jmp ending

	.local boom_dl
:10	.byte $70
	.byte $42,a(sm)
	.byte $41,a(boom_dl)

	.local sm
;	.byte  0123456789012345678901234567890123456789
	.byte "Boom!k - saving 4k old school since 2014"
	.endl
	
	.print .len sm

	.endl

bittab	.byte $80,$40,$20,$10,$08,$04,$02,$01

;----------------------------------------------------------------

	.proc sync_vcount
	lda #kwait
loop	cmp $d40b
	bne loop
	rts
	.endp

;----------------------------------------------------------------

	.proc scrninit
	sei
	lda #0
	sta p1
	sta p2
	sta p3
	sta $d40e
	sta $d018
	sta $d208
	lda #$ff
	sta $d301
	sta $d017


	ldx #63
	ldy #0
generate_sinus
	lda sinus_template,y
	sta sinus,y
	sta sinus+64,x
	eor #$ff
	clc
	adc #$9b
	sta sinus+128,y
	sta sinus+192,x

	lda #$0f
	sta dl_lms1+2,x
	sta dl_lms1+2+64,x
	sta dl_lms2+2,x

	iny
	dex
	bpl generate_sinus

	lda #$70
	sta dl
	sta dl+1
	sta dl+2
	lda #$4f
	sta dl_lms1
	sta dl_lms2
	lda #$41
	sta dl_vbl
	mwa #dl dl_vbl+1

	mwa #dl $d402

	mva #>sm1 p1+1
	mva #>sm2 p2+1
	mva #>pic p3+1
	ldy #0
	sty p1
	sty p2
	sty p3
scrinit1
	lda #$ff
	ldx #7
getstar	and $d20a
	dex
	bpl getstar
	
	sta (p1),y
	sta (p2),y
	sta (p3),y
	iny
	bne scrinit1
	inc p1+1
	inc p2+1
	inc p3+1
	bpl scrinit1

;----------------------------------------------------------------

	.proc print_revision
	mwa #pic+32*32+4 p1
	ldx #0
more_loop
	mva #5 x3
line_loop
	mva #3 x2
char_loop
	mva #8 x1
byte_loop
	asl picture,x
	bcc no_pixel
	lda #$ff
	.rept 8
	ldy # #*32
	sta (p1),y
	.endr
no_pixel
	inc p1
	dec x1
	bne byte_loop
	inx
	dec x2
	bne char_loop
	adw p1 #8+256
	dec x3
	bne line_loop
	adw p1 #96
	cpx #45
	bne more_loop
	rts

	.local picture
	ins "Boom!k-Text.pic"
	.endl

	.endp				;End of print_revision

	.endp

;----------------------------------------------------------------

	.proc genadr
	ldx #0
	stx p1
	mva #>sm1 p1+1
genadr1	clc
	lda p1
	sta llo,x
	adc #32
	sta p1
	lda p1+1
	lda p1+1
	sta lhi1,x
	ora #sm_pages
	sta lhi2,x
	scc
	inc p1+1
	inx
	bne genadr1

	ldx #anz
genadr3	lda #127
	sta xt,x
	lda #64
	sta yt,x
	lda $d20a
	and #range
	sta ctab,x
	dex
	bne genadr3
	rts
	.endp

;----------------------------------------------------------------
swap	jsr sync_vcount

	lda cnt
	lsr
	bcs swap2
	
swap1	lda #>sm2
	ldx #>lhi1
	bne swap3

swap2	lda #>sm1
	ldx #>lhi2

swap3	sta smup
	sta dl_lms1+2
	ora #$10
	sta dl_lms2+2

	stx printpt+2
	inx
	stx altptl1+2
	stx altptl2+2
	inx
	stx altpth1+2
	stx altpth2+2

	rts

;----------------------------------------------------------------

print	ldx #anz
print1	ldy yt,x
	lda xt,x
	lsr
	lsr
	lsr
	ora llo,y
	sta p1
altptl1	sta altlo1,x		;"Pointer"
printpt	lda lhi1,y		;"Pointer"
	sta p1+1
altpth1	sta althi1,x		;"Pointer"
	lda xt,x
	and #7
	tay
	lda bittab,y
	ldy #0
	ora (p1),y
	sta (p1),y

print2	dex
	bne print1
	rts

;----------------------------------------------------------------
clrplot	ldx #anz
	ldy #0
clrplot1
altptl2	lda altlo1,x
	sta p1
	sta p2
altpth2	lda althi1,x
	sta p1+1
	and #$1f
	ora #>pic
	sta p2+1

	lda (p2),y
	sta (p1),y
	dex
	bne clrplot1
	rts

;----------------------------------------------------------------
movestar
	ldx #anz

move	lda #0
	sta x1
	lda xt1,x
	ldy rx,x
	bmi move1
	sec
	adc gx1,x
	sta xt1,x
	lda xt,x
	adc #0
	sta xt,x
	bcs move2
	bcc move3
move1	clc
	sbc gx1,x
	sta xt1,x
	lda xt,x
	sbc #0
	sta xt,x
	bcs move3
move2	inc x1

move3	lda yt1,x
	ldy ry,x
	bmi move4
	sec
	adc gy1,x
	sta yt1,x
	lda yt,x
	adc #0
	sta yt,x
	bcs move5
	bcc move6
move4	clc
	sbc gy1,x
	sta yt1,x
	lda yt,x
	sbc #0
	sta yt,x
	bcs move6
move5	inc x1
move6

	dec ctab,x
	bmi movea

move8	lda x1
	beq move9

movea	jsr neumove
move9	dex
	bne move
	rts

neumove	lda xorg
	sta xt,x
	lda yorg	
	sta yt,x

	lda #$80
	and $d20a
	sta rx,x
	lda #$80
	and $d20a
	sta ry,x
	lda $d20a
	sta gx1,x
	lda $d20a
	sta gy1,x

	lda #range
	sta ctab,x
	rts

;----------------------------------------------------------------

anim	clc
	lda xcnt
	adc xspd
	sta xcnt
	clc
	lda ycnt
	adc yspd
	sta ycnt

	ldy xcnt
	lda sinus,y
	clc
	adc #$32
	sta xorg
	
	ldy ycnt
	lda sinus,y
	clc
	adc #$10
	sta yorg

	clc
	lda xspd
	asl
	adc yspd
	sta x1
	asl
	sta x2
	
	clc
	lda xorg
	adc yorg
	ror
	lsr
	lsr
	lsr
	lsr
	adc x2
	sta x2

	sec
	lda #$20
	sbc x2
	sta $d200
	
	lda x1
	lsr
	lsr
	clc
	adc #$81
	sta $d201

	dec acnt
	beq *+3
	rts

	lda $d20a
	and #3
	sta xspd
	lda $d20a
	and #3
	sta yspd
	lda $d20a
	and #63
	ora #128
	sta acnt
	rts

	.local sinus_template
	ins "Boom!k.sin",+0,64
	.endl

	run start
