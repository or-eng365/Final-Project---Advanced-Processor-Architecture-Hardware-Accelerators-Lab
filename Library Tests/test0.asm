.include "IO_map_addr.asm"
#--------------------------------------------------------------
#							 Data Segment
#--------------------------------------------------------------
.data 
N: .word 0xB71B00		# N=MCLKcycles argument of the delay routine 
#--------------------------------------------------------------
#							 Code Segment
#--------------------------------------------------------------
.text
	lw   $t3,N
	move $t0,$zero  	# $t0=0
	
Loop:	
	sw   $t0,PORT_LEDR 	# write to PORT_LEDR[7-0]
	sw   $t0,PORT_HEX0 	# write to PORT_HEX0[7-0]
	sw   $t0,PORT_HEX1 	# write to PORT_HEX1[7-0]
	sw   $t0,PORT_HEX2 	# write to PORT_HEX2[7-0]
	sw   $t0,PORT_HEX3 	# write to PORT_HEX3[7-0]
	sw   $t0,PORT_HEX4 	# write to PORT_HEX4[7-0]
	sw   $t0,PORT_HEX5 	# write to PORT_HEX5[7-0]
	
	addi $t0,$t0,1 		# $t0=$t0+1
	move $t1,$zero  	# $t1=0
	
delay:	
	addi $t1,$t1,1  	# $t1=$t1+1
	slt  $t2,$t1,$t3    #if $t1<N than $t2=1
	beq  $t2,$zero,Loop #if $t1>=N then go to Loop label
	j   delay


