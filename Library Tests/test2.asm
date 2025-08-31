.include "IO_map_addr.asm"
#--------------------------------------------------------------
#							 Global constants
#--------------------------------------------------------------
.eqv SW0 0x01
.eqv SW1 0x02
#--------------------------------------------------------------
#							 Data Segment
#--------------------------------------------------------------
.data 
# N: .word 0x004 			# for simulation only
N: .word 0xB71B00 
#--------------------------------------------------------------
#							 Code Segment
#--------------------------------------------------------------
.text
	sw   $0,PORT_LEDR 		# write to PORT_LEDR[7-0]
	sw   $0,PORT_HEX0 		# write to PORT_HEX0[7-0]
	sw   $0,PORT_HEX1 		# write to PORT_HEX1[7-0]
	sw   $0,PORT_HEX2 		# write to PORT_HEX2[7-0]
	sw   $0,PORT_HEX3 		# write to PORT_HEX3[7-0]
	sw   $0,PORT_HEX4 		# write to PORT_HEX4[7-0]
	sw   $0,PORT_HEX5 		# write to PORT_HEX5[7-0]
	#--------------------------------------------------
	lw   $t3,N
	move $t0,$zero  		# $t0=0
	addi $t5,$zero,0x80  	# $t5=1000_0000
	addi $t0,$zero,1  		# $t0=1
Loop:	
	lw   $t4,PORT_SW 		# read the state of PORT_SW[7-0]
	andi $t2,$t4,SW0		# $t2 = PORT_SW & SW0
	bne  $t2,$zero,Loop1   	#if SW0 is set then go to Loop label
	andi $t2,$t4,SW1		# $t2 = PORT_SW & SW1
	bne  $t2,$zero,Loop2   	#if SW1 is set then go to Loop label
	j    Loop
	
Loop1:	
	sll  $t0,$t0,1 			# $t0=$t0*2
	sw   $t0,PORT_LEDR 		# write to PORT_LEDR[7-0]
	sw   $t0,PORT_HEX0 		# write to PORT_HEX0[7-0]
	sw   $t0,PORT_HEX1 		# write to PORT_HEX1[7-0]
	sw   $t0,PORT_HEX2 		# write to PORT_HEX2[7-0]
	sw   $t0,PORT_HEX3 		# write to PORT_HEX3[7-0]
	sw   $t0,PORT_HEX4 		# write to PORT_HEX4[7-0]
	sw   $t0,PORT_HEX5 		# write to PORT_HEX5[7-0]
	j    delay
	
Loop2:	
	srl  $t5,$t5,1 			# $t5=$t5/2
	sw   $t5,PORT_LEDR 		# write to PORT_LEDR[7-0]
	sw   $t5,PORT_HEX0 		# write to PORT_HEX0[7-0]
	sw   $t5,PORT_HEX1 		# write to PORT_HEX1[7-0]
	sw   $t5,PORT_HEX2 		# write to PORT_HEX2[7-0]
	sw   $t5,PORT_HEX3 		# write to PORT_HEX3[7-0]
	sw   $t5,PORT_HEX4 		# write to PORT_HEX4[7-0]
	sw   $t5,PORT_HEX5 		# write to PORT_HEX5[7-0]
	
delay:	
	move $t1,$zero  		# $t1=0
L:	addi $t1,$t1,1  		# $t1=$t1+1
	slt  $t2,$t1,$t3      	#if $t1<N than $t2=1
	beq  $t2,$zero,Loop   	#if $t1>=N then go to Loop label
	j    L


