# MIPS Test Program One
# Identical function to uP2 Test Program
# Uses "array($3)" pseudo addressing mode which wastes time
# Dr. Ned Lecky
# University of Vermont: EE 231 Digital Computer Design I

.text
.globl start
start:	xor  $2,$2,$2		# clear reg2 (SUM)
	lw   $3,count		# reg3=count
	add  $3,$3,$3		# count*2
	add  $3,$3,$3		# count*4
loop:	addi $3,$3,-4		# decr pointer
	lw   $4,array($3)	# get array element
	add  $2,$4,$2		# sum it in
	bne  $3,$0,loop		# wait until ptr 0
	sw   $2,sum		# save answer
end:	j end

# Assembler Output
#[0x00400000]	0x00421026  xor $2, $2, $2                  ;  9: xor  $2,$2,$2		# clear reg2 (SUM)
#[0x00400004]	0x3c011000  lui $1, 4096 [count]            ; 10: lw   $3,count		# reg3=count
#[0x00400008]	0x8c230020  lw $3, 32($1) [count]
#[0x0040000c]	0x00631820  add $3, $3, $3                  ; 11: add  $3,$3,$3		# count*2
#[0x00400010]	0x00631820  add $3, $3, $3                  ; 12: add  $3,$3,$3		# count*4
#[0x00400014]	0x2063fffc  addi $3, $3, -4                 ; 13: addi $3,$3,-4		# decr pointer
#[0x00400018]	0x3c011000  lui $1, 4096 [array]            ; 14: lw   $4,array($3)	# get array element
#[0x0040001c]	0x00230821  addu $1, $1, $3
#[0x00400020]	0x8c240030  lw $4, 48($1) [array]
#[0x00400024]	0x00821020  add $2, $4, $2                  ; 15: add  $2,$4,$2		# sum it in
#[0x00400028]	0x1460fffb  bne $3,$0,-20 [loop-0x00400028] ; 16: bne  $3,$0,loop	# wait until ptr hits start of array
#[0x0040002c]	0x3c011000  lui $1, 4096 [sum]              ; 17: sw   $2,sum		# save answer
#[0x00400030]	0xac220024  sw $2, 36($1) [sum]
#[0x00400034]	0x0810000d  j 0x00400034 [end]              ; 18: j end

# Variables
.data 0x10000020
count:	.word 0x10
sum:	.word 0x1234

# Array Data: Note: sum is A19Eh
.data 0x10000030
array:	.word 0x1
	.word 0x20
	.word 0x300
	.word 0x4000
	.word 0x123
	.word 0x100
	.word 0x270
	.word 0x15
	.word 0x1000
	.word 0x200
	.word 0x40
	.word 0x5
	.word 0x1200
	.word 0x2760
	.word 0x130
	.word 0xD00

