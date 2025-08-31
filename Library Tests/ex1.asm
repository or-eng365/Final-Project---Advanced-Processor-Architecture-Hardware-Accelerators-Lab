.data 
	num1: .word 1
	num2: .word 2
	res: .word 0

.text

	lw  $t2,num1 		# t2 = DTCM[&num1], address of lable num1 = &num1 = 0
	lw  $t3,num2 		# t3 = DTCM[&num2], address of lable num2 = &num2 = 4
	add $t4,$t3,$t2		# t4 = t3 + t2
	sw  $t4,res 		# t4 = DTCM[&res], address of lable res = &res = 8
	
END: beq $0,$0,END

