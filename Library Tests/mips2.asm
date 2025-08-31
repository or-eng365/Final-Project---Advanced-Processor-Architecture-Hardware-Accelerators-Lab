.data
	num32:	.word 3

.text
	addi	$t1,$0,1	
	addi	$t2,$0,2
	move	$t3,$t2
	la	$t3,JUMP1
	lui	$t3,58
	mul	$t3,$t2,$t1
	sll	$t3,$t1,1
	srl	$t3,$t1,1
	j	JUMP1
	addi	$t3,$0,3
JUMP1:	addi	$t3,$0,60
	jr	$t3
	addi	$t3,$0,3
	jal	JUMP3
	addi	$t3,$0,3
JUMP3:	add	$t3,$t2,$t1	# t3<-3
	add	$t3,$t3,$t1	# t3<-4
	add	$t3,$t3,$t1	# t3<-5

END:	beq $0,$0,END
