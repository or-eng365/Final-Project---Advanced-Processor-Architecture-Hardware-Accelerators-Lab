.data
  
	num1: .word 1
	num2: .word 2
	num3: .word 3
	num4: .word 4
	res1: .space 4
	res2: .space 4
	
.text

	lw 	$t1,num1		
	lw 	$t2,num2		
	lw 	$t3,num3		
	lw 	$t4,num4

	add $t5,$t1,$t2
	sw 	$t5,res1
	
	add $t5,$t3,$t4
	sw 	$t5,res2			
	
END:	beq $0,$0,END	
