.data 
	arr1: .word  0,1,2,3,4,5,6,7
	arr2: .word  7,6,5,4,3,2,1,0
	res:  .space 32 				# 8 words * 4 byte/word = 32 bytes
.text
	addi  $s0,$0,0
	addi  $s1,$0,32		
L:	lw    $t1,arr1($s0)
	lw    $t2,arr2($s0)
	slt   $t0,$t1,$t2			#if $t1<$t2 than $t0=1
	beq   $t0,$0,ELSE
IF:	 add   $t3,$t2,$0	# t3 = t1<t2? t2 : t1
	beq   $0,$0,END_IF
ELSE:	add   $t3,$t1,$0
END_IF: sw    $t3,res($s0)
	addi  $s0,$s0,4
	slt   $t0,$s0,$s1 			#if $s0<$s1 than $t0=1 else $t0=0
	beq   $t0,$zero,END 
	beq $0,$0,L
END:	beq $0,$0,END


