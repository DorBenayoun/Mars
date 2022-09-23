# Title: Solution for 2022A Question 3 MMN12 
# Author: Dor David Benayoun
# Date: 21-Nov-2021
# Version: 1.0
# This program will get a number in decimal (base 10) from the user in the range of -9999 - +9999 and return:
# A - the decimal number entered by the user
# B - a number in binary 16bit (complement 2) format 
# C - a reversed number in binary 16 bit (complement 2) format
# D - the number of section B in decimal

.data
input: .asciiz "\nEnter an integer in the range -9999 - +9999:\n"
wrong_input: .asciiz "\nWrong input, please enter an integer in the range\n"

.text
.globl main
# A
main:
	# Print input message and read an input from the user
	li $v0, 4
	la $a0, input
	syscall 
	li $v0, 5 
	syscall
	# Verification that the number is in the range
	bgt $v0, 9999, wrong
	blt $v0, -9999, wrong
	move $s0, $v0
	j continue
# If the input is wrong print wront_input message
wrong:
	li $v0, 4
	la $a0, wrong_input
	syscall	
	j main	
	# B
continue:	
	li $v0, 1
	li $t0, 0x8000 # Mask 16bit

# Print 16bit binary value loop
print_16_bit:
	and $a0, $s0, $t0
	beq $a0, $0, print_digit
	li $a0, 1

# Iteration call
print_digit:
	syscall
	srl $t0, $t0, 1
	bne $t0, $0, print_16_bit
	li $v0,11
	li $a0,'\n'
	syscall

	# C
	li $v0,1
	li $t0, 0x0001
	li $t1, 0x8000
	li $t2, 0

# Print 16bit reverse value loop
print_16_bit_reverse:
	and $a0, $s0, $t0
	beq $a0, $0 not_1
	li $a0, 1
	or $t2, $t2, $t1

	# Iteration call
not_1:
	syscall
	sll $t0, $t0, 1
	srl $t1, $t1, 1
	bne $t1, $0, print_16_bit_reverse
	li $v0, 11
	li $a0, '\n'
	syscall

	# D
	andi $a0, $t2, 0x8000 # Mask 16 bit
	beq $a0, $0, positive
	lui $a0, 0xffff # Bottom mask

positive:
	or $a0, $a0, $t2
	li $v0, 1
	syscall
	# Program termination
	li $v0, 10
	syscall
