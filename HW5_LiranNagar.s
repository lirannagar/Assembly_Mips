# Computer Architecture   HW5
# Question:  	
# Given Two NULL terminated strings which contain the ascii 
# for two numbers: 
# 0<A<1000, 0<B<1000,  A, B are Decimal
# Output:
# 1. Print an integer (word) containing the result of |A-B|
# 2. Print an integer (word) containing the result of A+B
# Print the relevant message before each answer.
# Print each answer in a separate line
# Subroutines:
# 1. PrintMsg1,Msg2,msgA,msgB (no input) 
# 2. PrintA,PrintB (input a0=pointer to string)
# 2. PrintNL   (Print new '\n')
# 3. Print '-'
# 4. PrintI(Print integer. input $a0=integer)
# 5. Str2I	(String to Integer)
#	Input: Pointer to string in $a0
#	Output: integer in $v0, $v1 is set when Error in input
# 6. AP2I (convert ASCII digit with position to integer)
#    Input: ASCII char in $a1, position in $a2
#	Output: integer (4 byte number in register $v0)
#	No usage of mult instruction
# Subroutine register conventions:
# Saved by Caller (if needed later): $t0-$t9,$a0-$a3,$v0-$v1
# Saved by Callee (if used): $s0-$s7, $ra
# First plan the main. Then plan the Str2I. Then AP2I
# Then the rest
# Remember the stack
# Example:
# Input A = 123
# Input B = 567
# A-B = -444
# A+B = 690
# The solution is turned in Moodle by 14.6.2017
# The important line of code needs to have a comment
# At the beginning of each routine add explainations
# about the implementation
################# Data segment #####################

.data
A:	 	.asciiz 	"167"
B:	 	.asciiz 	"723"
msg1:		.asciiz		"A-B = "
msg2: 		.asciiz		"A+B = "
msgA:		.asciiz		"Input A = "
msgB:		.asciiz		"Input B = "
minus:		.asciiz		"-"
errorMsg:	.asciiz 	"Whong input entered!"
################# Code segment #####################
.text
.globl main
main:	# main program entry
	
	jal	PrintMsgA			#Print message
	jal	PrintA				#Print A
	jal	PrintNL				#Print new line
	jal	PrintMsgB			#Print message
	jal	PrintB				#Print B
	jal	PrintNL				#Print new line

#invoke Str2I for A and for B (prepare inputs and save outputs)
#This routine reads the strings and turns them into an integer

#your code is here

	la $a0, A
	jal     Str2I
	beq $v1,1,whongErrorExit
	move $t8,$v0   # integer number A in $t8
	la $a0, B
	jal     Str2I
	beq $v1,1,whongErrorExit
	move $t9,$v0   # integer number B in $t2
	
#Use the outputs to answer the questions
#Remember that if the sub is negative you need to print a '-'

#your code is here
	jal     PrintMsg1		#Print message
	move $a0,$t8			#number A = $a0
	move $a1,$t9			#number B = $a1
	jal	DoSubstract		#Substract two numbers
	move $t2,$v0
	li $v0,1
	move $a0,$t2
	syscall
	
	jal	PrintNL				#Print new line
	jal	PrintMsg2			#Print message
	move $a1,$t9				#number B = $a1
	move $a0,$t8				#number A = $a0
	jal 	DoAdd				#Add two numbers
	move $a0,$v0
	li $v0,1
	syscall
	
	
	
	

# end of program
exit:	
	li $v0,10
	syscall
########################
# subroutines
# Saved by Caller (if needed later): $t0-$t9,$a0-$a3,$v0-$v1
# Saved by Callee (if used): $s0-$s7, $ra
# Remeber to save $since this routine calls an other one

DoAdd:
	add $v0 ,$a0,$a1
		jr	$ra


DoSubstract:
	sub $v0,$a0,$a1
	jr	$ra
	
	
Str2I:	# convert ASCII string input to integer
		#	Input: Pointer to string in a0
		#	Output: integer in $v0
		# $a1 counts the number of digits
		# $t0 contains the sum of the integer of the digits
#save $ra in stack

#your code is here
	addi $sp, $sp,-4  #Useing one word from the stack
	sw   $ra, 0($sp)  #Save the address to return
	li $a2,0	  #Position

getPosition:
	lb $a3,0($a0)
	beq $zero,$a3,endLoop
	addi $a2,$a2,1
	addi $a0,$a0,1
	j getPosition
endLoop:
	sub  $a0,$a0,$a2
	sub  $a2,$a2,1
	move $a1,$a2      #Number of digits at $a1
	li $t0,0 	  #The final Integer number in $t0
loop:
	li $v0,0 	  #Return value 
	lb $a1,0($a0)     #Load char to $a1
	beq $a1,$zero,end
	jal AP2I          #Turn ascii digit to integer digit
	move $t5,$v0
	add $t0,$t0,$t5   #The Inter Number from String  in $v0
	addi $a2,$a2,-1   
	addi $a0,$a0,1   #next ascii digit pointer
	j loop
end:
       		#restore $ra from stack
		#move $ra $t4
		lw   $ra, 0($sp) #use the address from the stack
		addi $sp, $sp,4 
		move $v0,$t0
		jr	$ra
####################################################
AP2I:		# convert one digit 
		# (ASCII char in decimal to integer) using
		# the position of the digit in the original number
		# 0-->digit, 1-->tenths, 2-->hundreds
		#	Input: ASCII char in $a1, position in $a2
		#	Output: integer (4 byte number in register $v0)
		# Note: A*10=A*8+A*2
#your code is here
	sgt $v1,$a1,57 
	bgt $a1,57,endProcedureAP2I  # check if the value whong by ascii
	slti $v1,$a1,48
	blt $a1,48,endProcedureAP2I   # check if the value whong by ascii
	
	addi $t3,$a1,-48 
	beq $a2,$zero,moveTo$v0
	beq $a2,1,$t2EqualToTen
	beq $a2,2,$t2EqualToHundred

$t2EqualToTen:
	sll $t2,$t3,1 #2^1 =2
	sll $t6,$t3,3 # 2^3=8
	add $v0,$t2,$t6 # $v0 = $t3 *(2+8)
	j endProcedureAP2I
	
$t2EqualToHundred:
	sll $t2,$t3,2 #2^2=4
	sll $t6,$t3,5 #2^5=32
	sll $t1,$t3,6 # 2^6=64
	add $v0,$t6,$t2 
	add $v0,$t1,$v0  # $v0 = $t3 *(4+32+64)
	j endProcedureAP2I
	
	
moveTo$v0:
	move $v0,$t3 # just remove the value of $t3 to $v0 and return to coller
	j endProcedureAP2I

	
	endProcedureAP2I:
		jr	$ra
######################

PrintI:	#input: integer in a0
	li	$v0,1
	syscall
	jr	$ra
PrintMsgA:
	la	$a0,msgA
	li	$v0,4
	syscall
	jr	$ra
PrintMsgB:
	la	$a0,msgB
	li	$v0,4
	syscall
	jr	$ra
PrintA:
	la	$a0,A
	li	$v0,4
	syscall
	jr	$ra
PrintB:
	la	$a0,B
	li	$v0,4
	syscall
	jr	$ra

PrintMsg1:
	la	$a0,msg1
	li	$v0,4
	syscall
	jr	$ra
PrintMsg2:
	la	$a0,msg2
	li	$v0,4
	syscall
	jr	$ra
PrintNL:
	li	$a0,'\n'
	li	$v0,11
	syscall
	jr	$ra
PrintM:
	li	$a0,'-'
	li	$v0,11
	syscall
	jr	$ra
	
whongErrorExit:
	li	$v0,4
	la	$a0,errorMsg
	syscall
	j exit




