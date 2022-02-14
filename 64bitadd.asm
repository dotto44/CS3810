# Add64 is an example procedure called by main (called on line 53)
# Main is responsible for saving and restoring $t registers (if there were any).
# Add64 saves and restores the $s registers

#Note: Code for reading and writing integers from stdin and stout modeled from MARS examples
.data


	  .align 2	# word-align the 16 byte array declared next
input:    .space 16	# make room for 4 ints (4 words)

prompt:    .asciiz "Enter 4 integers to be computed ((A*B) + (C*D)) one after the next: "

.text


# This is the 'main' body of this program. It gathers the input, and sets up the add operation.

main:		
		li $v0, 4			# display prompt message
		la $a0, prompt
		syscall
		
		addi $s0, $0, 0			# i = 0
		la $t1, input			# load base address of array C declared above under
						# label buffer3. This array is word-aligned, meaning
						# we can load and store whole words to it safely

inputloop:	
		beq  $s0, 4, endinput		# if i == 4, stop taking input
		
		li $v0, 5			# tell MARS to read an integer from the user
		syscall				# the integer is returned in register $v0
		
		sll $t0, $s0, 2			# store i*4 to t0, call this offset
		add $t2, $t0, $t1		# t2 = Base address of c + offset, this is address of c[i]
		sw $v0, 0($t2)			# store the integer read into memory at c[i]
		
		addi $s0, $s0, 1		# i++
		j inputloop

endinput: 
		lw $s4, 0($t1)			# $s4 stores A
		lw $s5, 4($t1)			# $s5 stores B
		lw $s6, 8($t1)			# $s6 stores C
		lw $s7, 12($t1)			# $s7 stores D
		multu $s4, $s5			# multiply A * B
		mfhi $a0			# stores the value of A * B in $a0 (most significant) and $a1 (least significant)
		mflo $a1
		multu $s6, $s7			# multiply C * D
		mfhi $a2			# stores the value of C * D in $a2 (most significant) and $a3 (least significant)
		mflo $a3
		jal add64			# This is the example procedure call
		add $t8, $v0, $zero		# store $v0 in $t8
		add $t9, $v1, $zero		# store $v1 in $t9
		j programend			# end the program
		
		


# This procedure performs an add operation on 64bit inputs. 
# $a0 ... $a1 stores the first number.
# $a2 ... $a3 stores the second number.

# Returns sum in $v0 ... $v1
add64: 
		sub $sp, $sp, 4			# make space on the stack for 1 word
		sw $s0, 0($sp)
		
		li $t9, 2147483648		# sets the minimum value of a number over 31 bits
		sgeu $s0, $a1, $t9		# $s0 stores the number of the 3 possible conditions that lead to a carry
						# add 1 to $s0 if the last bit of $a1 is 1
		sgeu $t5, $a3, $t9		# $add 1 to $s1 if the last bit of $a3 is 1
		add $s1, $s1, $t5
		addu $v1, $a1, $a3		# calculates the sum of the lower 32 bits
		beq $s1, 2, carry		# if 2 of the conditions for carry have already been met, skip to carry
		beq $s1, 0, nocarry		# if neither condition for the carry has been met yet, it can't happen
		bleu $v1, $t9, carry 		# if sum has a 0 in the last digit, then a carry must have occured
		j nocarry			# otherwise no carry
carry:
		addiu $a0, $a0, 1		# add 1 for the carry 
nocarry:
		addu $v0, $a0, $a2		# add the more significant halves
		
		lw $s0, 0($sp) 			# load $s0 back to previous value
		add $sp, $sp, 4			# reduce stack size
		jr $ra				# return to previous procedure. $v0 has the more significant half, $v1 has the less significant half
		
# Program End

programend:
	
	
	
