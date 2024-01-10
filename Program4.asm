# Program4.asm
# Author: Krista Smith
# Date: 11/21/23
# Description: The program will repeat in a loop the following operations until
#	the user quits: 
#	take user input, print the sign, print the exponent, print the significand
#	and print the value stored in memory.


.macro print_str (%string)
la $a0, %string
li $v0, 4
syscall
.end_macro

.macro print_char(%char)
la $a0, %char
li $v0, 11
syscall
.end_macro

.globl read_float, print_sign, print_exp, print_significand, main
# Do not remove this line

# Data for the program goes here
.data
ieee: .word 0 # store your input here
again: .asciiz "Do you want to do it again?"
prompt: .asciiz "Enter an IEEE 754 floating point number in decimal form: "
res_sign: .asciiz "\n\nThe sign is: "
new_line: .asciiz "\n"
expoBias: .asciiz "\nExpo with bias: "
expoNoBias: .asciiz "\nExpo without bias: "
manti: .asciiz "\nMantissa: "
sieee: .asciiz "\nIEEE-754 Single Prec: "

.text # Code goes here

main:

# Task 2: Call read_float()
	jal read_float
# Task 3: Call print_sign(ieee)
	jal print_sign
# Task 4: Call print_exp(ieee)
	jal print_exp
# Task 5: Call print_significand(ieee)
	jal print_significand
# Task 6: Print IEEE number in hex
# print exponent with bias (hex)
	print_str(sieee)
	lw $t1, ieee
	li $v0, 34
	la $a0, ($t1)
	syscall
	
# Task 1: Try again pop-up
	# ask user if they want to repeat the tasks
	# if yes, $a0 will equal 0 and the main will be repeated	
	li $v0, 50
	la $a0, again
	syscall

	beqz $a0, main

exit_main:
li $v0, 10 # 10 is the exit program syscall
syscall # execute call
## end of ca.asm

###########################################################################
# Procedure void read_float()
# Functional description: Reads input from user using a pop up GUI.
#	It stores the capture value in ieee memory space.
# Argument parameters: none
# Return value: none
###########################################################################
# Register usage: 
# $f0 - input is automatically stored here
# $t0 - temporary storage for input
# $v0 - hold syscall address
# $a0 - hold string address
read_float:
	# ask user for input using GUI, store input in register
	li $v0, 52 # GUI prompt
	la $a0, prompt
	syscall
	
	mfc1 $t0, $f0 # move input from f0 to t0
	sw $t0, ieee # move input into memory
read_float_ret:
	jr $ra # go back to line after procedure


###########################################################################
# Procedure void print_sign(ieee)
# Functional description: Extracts the sign bit from the input param
#	and prints it to the screen with a corresponding message
# Argument parameters: 
#	$a0 : ieee single precision value
# Return value: none
#
# Note: sign character : 0x2B = '+', 0x2D = '-'
###########################################################################
# Register usage: 
# $a0 - single precision value
# $t0 - used to AND and shift
print_sign:

# The sign bit is the most significant bit. To isolate this bit, you can
#	use an AND to clear the other bits, then shift right 31 bits.
	
	lw $a0, ieee # load ieee into $a0
	andi $t0, $a0, 0x80000000 # clear all but the first bit
	srl $t0, $t0, 31 # shift right by 31 bits

# print_str(res_sign)
	print_str(res_sign)

# print_char( - or + )
	beqz $t0, positive # if sign is positive (equals zero), branch away
	print_char(0x2D) # print -
	j end_print_sign
positive:
	print_char(0x2B) 
end_print_sign:
	jr $ra # jump back to main
	
	
###############################################################################
# Procedure void print_exp(ieee)
# Functional description: Extracts the exponent bits from the input param
#	and prints it to the screen with a corresponding message
# Argument parameters: 
#	$a0 - ieee single precision value
# Return value: none
################################################################################
# Register usage: 
# $a0 - ieee value
# $t0 - value to hold isolated bits
# $t1 - value to hold input without bias
print_exp:
# clear all but bits 31-23
	lw $a0, ieee
	andi $t0, $a0, 0x7F800000 # isolate bits 31-23
	srl $t0, $t0, 23 # shift right 23 bits

# subtract bias (hex)
	subi $t1, $t0, 0x7F # subtract 127(bias) in hex
# print_str(expoBias)
	print_str(expoBias)
# print exponent with bias (hex)
	li $v0, 34 # print float
	la $a0, ($t0) # load $t0 into argument
	syscall
# print_str(expoNoBias)
	print_str(expoNoBias)
# print exponent with no bias (hex)
	li $v0, 34
	la $a0, ($t1)
	syscall

end_print_exp:
	jr $ra
	
	
###############################################################################
# Procedure void print_significand(ieee)
# Functional description: Extracts the significand bits from the input param
#	and prints it to the screen with a corresponding message
# Argument parameters: 
#	$a0 - ieee single precision value
# Return value: none
################################################################################
# Register usage: 
# $a0 - ieee value
# $t0 - mantissa value
print_significand:
# clear all but bits 0-23
	lw $a0, ieee # load ieee value
	andi $t0, $a0, 0x0007FFFFF  # clear all but bits 0-23
	
# print_str(manti)
	print_str(manti)
# print exponent with bias (hex)
	li $v0, 34
	la $a0, ($t0)
	syscall

end_print_significand:
	jr $ra
