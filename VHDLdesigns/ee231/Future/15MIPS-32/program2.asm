# MIPS Test Program Two
# Identical function to uP2 Test Program
# Avoids pseudo-instructions in the loop
# Dr. Ned Lecky
# University of Vermont: EE 231 Digital Computer Design I

.text
.globl start
start:	xor  $2,$2,$2	# clear reg2 (SUM)
	lw   $3,count	# reg3=count
	add  $3,$3,$3	# count*2
	add  $3,$3,$3	# count*4
	la   $4,array	# base addr of data
	add  $5,$4,$3	# reg5 is data ptr
loop:	addi $5,$5,-4	# decr pointer
	lw   $6,($5)	# get array element
	add  $2,$6,$2	# sum it in
	bne  $5,$4,loop	# wait until ptr hits start
	sw   $2,sum	# save answer
end:	j end

# Assembler Output
#[0x00400000]	0x00421026  xor $2, $2, $2                    ; 9: xor  $2,$2,$2	# clear reg2 (SUM)
#[0x00400004]	0x3c011000  lui $1, 4096 [count]              ; 10: lw   $3,count	# reg3=count
#[0x00400008]	0x8c230020  lw $3, 32($1) [count]
#[0x0040000c]	0x00631820  add $3, $3, $3                    ; 11: add  $3,$3,$3	# count*2
#[0x00400010]	0x00631820  add $3, $3, $3                    ; 12: add  $3,$3,$3	# count*4
#[0x00400014]	0x3c011000  lui $1, 4096 [array]              ; 13: la   $4,array	# base addr of data
#[0x00400018]	0x34240030  ori $4, $1, 48 [array]
#[0x0040001c]	0x00832820  add $5, $4, $3                    ; 14: add  $5,$4,$3	# reg5 is data ptr
#[0x00400020]	0x20a5fffc  addi $5, $5, -4                   ; 15: addi $5,$5,-4	# decr pointer
#[0x00400024]	0x8ca60000  lw $6, 0($5)                      ; 16: lw   $6,($5)	# get array element
#[0x00400028]	0x00c21020  add $2, $6, $2                    ; 17: add  $2,$6,$2	# sum it in
#[0x0040002c]	0x14a4fffd  bne $5, $4 ,-12 [loop-0x0040002c] ; 18: bne  $5,$4,loop	# wait until ptr hits start
#[0x00400030]	0x3c011000  lui $1, 4096 [sum]                ; 19: sw   $2,sum		# save answer
#[0x00400034]	0xac220024  sw $2, 36($1) [sum]
#[0x00400038]	0x0810000e  j 0x00400038 [end]                ; 20: j end

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

