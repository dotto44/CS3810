.data
#Note: Code to input and out strings modeled from MARS example code



# input buffer for compressed genome	
	.align 0				# byte-align the 40 byte space declared next
input:	.space 40				# allocate 40 bytes as a read buffer for string input


# output buffer for uncompressed genome

	.align 0				# byte-align the 2 byte array declared next
output:	.space 2				# allocate 2 bytes as a write buffer for string output

prompt:	.asciiz "Enter up to 39 characters of compressed genome: "

.text 

	li $v0, 4				# syscall reads this reg when called, 4 means print string
	la $a0, prompt				# load the address of the string declared at .data
	syscall					# print the string declared at label prompt in .data
	
	li $v0, 8				# syscall reads this reg when called, 8 means read string
	la $a0, input				# load the address of the buffer to write into from stdin
	li $a1, 40				# load the length of the buffer in bytes in $a1
	syscall
	
	li $s0, 0				# index of the current character in input
	add $s4, $a1, $zero			# store end of the input buffer
	la $s5, input				# $s5 stores the base of the input buffer
	la $s6, output				# $s6 stores the base of the input buffer 
	
	li $t1, 0				# load 0 into reg $t1 (ascii value of null terminator)
	sb $t1, 1($s6)				# store 'null' as the last byte of output
	
	
# loop to read characters from the input string
read:	beq $s0, $s4, procend			# if index == end of input, end procedure 
	add $t1, $s0, $s5			# calculate the address of the current character (index + base)
	lb  $s1, 0($t1)				# $s1 stores the value of the current character
	addi $s0, $s0, 1			# increment index as the current character is stored
	li $s2, 1				# $s2 stores the number of times to print the character
	beq $s1, 65, print			# if character == 'A', 'C', 'G', 'T', respectively, it is ready to print
	beq $s1, 67, print
	beq $s1, 71, print
	beq $s1, 84, print			# if character == '#', '$', '%', '&', respectively, it requires more logic before printing
	beq $s1, 35, hashtag
	beq $s1, 36, dollar
	beq $s1, 37, percent
	beq $s1, 38, ampersand
	j procend				# if character is not part of the sequence, end proc
	
#logic for multiadd operations (e.g. '#+')

hashtag:
	li $s1, 65				#set character as 'A'
	j multioperationlogic
	
dollar:
	li $s1, 67				#set character as 'C'
	j multioperationlogic
	
percent:
	li $s1, 71				#set character as 'G'
	j multioperationlogic
	
ampersand:
	li $s1, 84				#set character as 'T'
	j multioperationlogic
	
multioperationlogic:
	add $t1, $s0, $s5			# calculate the address of the following character (index + base + 1), remember index was already incremented
	lb  $t3, 0($t1)				# load the value of the following character
	subi $s2, $t3, 30			# calculate the number of times to print the current character from the following
	addi $s0, $s0, 1			# increment index
	j print					# we're now ready to print
	

# prints character $s1 to stoud $s2 times
print:  beq $s2, $zero, read			# if the character has been printed enough times, loop and check next character in input
	sb $s1, 0($s6)				# store the character to be printed to the output buffer
	li $v0, 4				# prints the output buffer to stdout
	la $a0, output
	syscall
        subi $s2, $s2, 1			# decrement counter
        j print					# loop
	
procend:

	
	
