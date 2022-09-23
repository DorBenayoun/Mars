# Title: Solution for 2022A Question 4 MMN12 
# Author: Dor David Benayoun
# Date: 21-Nov-2021
# Version: 1.0
# This program will get an array with 10 elements in decimal (base 10) from the user in the range of -9999 - +9999 and return:
# A - signed numbers in the range divided by 8 without a remainder
# B - unsigned numbers in the range divided by 4 without a remainder
# C - sum of 10 elements in the array while referring them as signed numbers
# D - sum of 10 elements in the array while referring them as unsigned numbers
# E - sum of differences between each neighbor elements while referring them as signed numbers
# F - repeat A - E and print by base 4
# G - repeat A - E and print by base 8
# H - determine wether the array is an arithmetic sequence or not
# I - if the array is an arithmetic sequence choose a number in the range 50 - 100 and return the according sequence element 

.data
elements: .byte -16, -12, -8, -4, 0, 4, 8, 12, 16, 20
section_a_output: .asciiz "\nSection A - The signed numbers divisible by 8 without a remainder are: "
section_b_output: .asciiz "\nSection B - The unsigned numbers divisible by 4 without a remainder are: "
section_c_output: .asciiz "\nSection C - The signed sum is: "
section_d_output: .asciiz "\nSection D - The unsigned sum is: "
section_e_output: .asciiz "\nSection E - The sum of differences are: "
base_10_output: .asciiz "\nSections A - E in base 10:"
base_4_output: .asciiz "\n\nSection F (A - E in base 4):"
base_8_output: .asciiz "\n\nSection G (A - E in base 8):"
sequence_output: .asciiz "\n\nSection H - The array is an arithmetic sequence\n"
nsequence_output: .asciiz "\n\nSection H - The array is not an arithmetic sequence"
user_input: .asciiz "\n\nSection I - Please enter a number from 50 to 100:"
wrong_input: .asciiz "\nSection I result - Number is not in the range 50-100"
section_i_output_1: .asciiz "\nSection I result - Element number "
section_i_output_2: .asciiz " is "

.text
.globl main

main:
	# Caller: A - E in base 10
	li $v0, 4
	la $a0, base_10_output
	syscall
	la $a0, elements
	li $a1, 10
	li $a2, 10
	jal sections_a_to_e

	# Caller: A - E in base 4
	li $v0, 4
	la $a0, base_4_output
	syscall
	la $a0, elements
	li $a1, 10
	li $a2, 4
	jal sections_a_to_e

	# Caller: A - E in base 8
	li $v0, 4
	la $a0, base_8_output
	syscall
	la $a0, elements
	li $a1, 10
	li $a2, 8
	jal sections_a_to_e

	# Caller: H
	la $a0, elements
	li $a1, 10
	jal arithmetic_sequence

	# Caller: I
	beqz $v0, end
	la $a0, elements
	jal user_element
# Program termination
end:
	li $v0, 10
	syscall
# A - E print implementation
base:
	move $t0, $a0
	beqz $t0, base10
	beq $a2, 10, base10
	bgtz $t0, print_base
	li $v0, 11
	li $a0, '-'
	syscall
	abs $t0, $t0

print_base:
	beq $a2, 4, base4
	li $t3, 3
	li $t1, 7
	j base4or8

base4:
	li $t3, 2
	li $t1, 3

base4or8:
	clz $t2, $t0
	li $t4, 31
	sub $t2, $t4, $t2
	div $t2, $t2, $t3
	mulo $t2, $t2, $t3
	li $v0, 1
	
base_loop:
	bltz $t2, base_return
	srlv $a0, $t0, $t2
	and $a0, $a0, $t1
	syscall
	sub $t2, $t2, $t3
	j base_loop

base10:
	li $v0, 1
	move $a0, $t0
	syscall

base_return:
	jr $ra

base_byte:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	beqz $a1, base_byte_unsigned
	lb $a0, 0($a0)
	j base_byte_continue

base_byte_unsigned:
	lbu $a0, 0($a0)

base_byte_continue:
	jal base
	lw $ra, 0($sp)
	addi $sp,$sp,4
	jr $ra
# A & B printing
division:
	addi $sp, $sp, -20
	sw $ra, 16($sp)
	sw $a0, 12($sp)
	sw $a1, 8($sp)
	sw $a2, 4($sp)
	sw $s0, 0($sp)
	add $s0, $a0, $a3

division_loop:
	sub $s0, $s0, 1
	blt $s0, $a0, division_exit
	lbu $t0, 0($s0)
	lw $t1, 20($sp)
	rem $t1, $t0, $t1
	bnez $t1, division_loop
	move $a0, $s0
	jal base_byte
	li $v0, 11
	li $a0, ' '
	syscall
	lw $a0, 12($sp)
	lw $a1, 8($sp)
	lw $a2, 4($sp)
	j division_loop

division_exit:
	li $v0, 11
	li $a0, '\n'
	syscall
	lw $ra, 16($sp)
	lw $s0, 0($sp)
	addi $sp, $sp, 20
	jr $ra
# C & D printing
summation:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	add $t0, $a0, $a3
	li $t1, 0

summation_loop:
	sub $t0, $t0, 1
	blt $t0, $a0, summation_exit
	beqz $a1, summation_unsigned
	lb $t2, 0($t0)
	j summation_continue

summation_unsigned:
	lbu $t2, 0($t0)

summation_continue:
	add $t1, $t1, $t2
	j summation_loop

summation_exit:
	move $a0, $t1
	jal base
	li $v0, 11
	li $a0, '\n'
	syscall
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
# E printing
differences:
	addi $sp,$sp, -16
	sw $ra, 12($sp)
	sw $a2, 8($sp)
	sw $s0, 4($sp)
	sw $s1, 0($sp)
	move $s0, $a0
	add $s1, $a0, $a1
	subi $s1, $s1, 1

differences_loop:
	bge $s0, $s1, differences_exit
	lb $a0, 0($s0)
	lb $t0, 1($s0)
	sub $a0, $a0, $t0
	lw $a2, 8($sp)
	jal base
	li $v0, 11
	li $a0, ' '
	syscall
	addi $s0, $s0, 1
	j differences_loop

differences_exit:
	li $v0, 11
	li $a0, '\n'
	syscall
	lw $ra, 12($sp)
	lw $s0, 4($sp)
	lw $s1, 0($sp)
	addi $sp, $sp, 16
	jr $ra

sections_a_to_e:
	# Stack implementation
	addi $sp, $sp, -16
	sw $ra, 12($sp)
	sw $a0, 8($sp)
	sw $a1, 4($sp)
	sw $a2, 0($sp)

	# A implementation
	li $v0, 4
	la $a0, section_a_output
	syscall
	lw $a0, 8($sp)
	li $a1, 1
	lw $a2, 0($sp)
	lw $a3, 4($sp)
	addi $sp, $sp, -4
	li $t0, 8
	sw $t0, 0($sp)
	jal division
	addi $sp, $sp, 4

	# B implementation
	li $v0, 4
	la $a0, section_b_output
	syscall
	lw $a0, 8($sp)
	li $a1, 0
	lw $a2, 0($sp)
	lw $a3, 4($sp)
	addi $sp, $sp, -4
	li $t0, 4
	sw $t0, 0($sp)
	jal division
	addi $sp, $sp, 4

	# C implementation
	li $v0, 4
	la $a0, section_c_output
	syscall
	lw $a0, 8($sp)
	li $a1, 1
	lw $a2, 0($sp)
	lw $a3, 4($sp)
	jal summation

	# D implementation
	li $v0, 4
	la $a0, section_d_output
	syscall
	lw $a0, 8($sp)
	li $a1, 0
	lw $a2, 0($sp)
	lw $a3, 4($sp)
	jal summation

	# E implementation
	li $v0, 4
	la $a0, section_e_output
	syscall
	lw $a0, 8($sp)
	lw $a1, 4($sp)
	lw $a2, 0($sp)
	jal differences
	lw $ra, 12($sp)
	addi $sp, $sp, 16
	jr $ra
# H implementation
arithmetic_sequence:
	lb $t0, 0($a0)
	lb $t1, 1($a0)
	sub $t0, $t0, $t1
	addi $t1, $a0, 1
	add $t2, $a0, $a1
	subi $t2, $t2, 1

arithmetic_sequence_loop:
	bge $t1, $t2, sequence
	lb $t3, 0($t1)
	lb $t4, 1($t1)
	sub $t3, $t3, $t4
	bne $t3, $t0, not_sequence
	addi $t1, $t1, 1
	j arithmetic_sequence_loop

sequence:
	li $v0, 4
	la $a0, sequence_output
	syscall
	jr $ra

not_sequence:
	li $v0, 4
	la $a0, nsequence_output
	syscall
	li $v0, 0
	jr $ra
# I implementation
user_element:
	lb $t0, 0($a0)
	lb $t1, 1($a0)
	sub $t1, $t1, $t0
	li $v0, 4
	la $a0, user_input
	syscall
	li $v0, 5
	syscall
	move $t2, $v0
	blt $t2, 50, wrong_range
	bgt $t2, 100, wrong_range
	li $v0, 4
	la $a0, section_i_output_1
	syscall
	li $v0, 1
	move $a0, $t2
	syscall
	li $v0, 4
	la $a0, section_i_output_2
	syscall
	addi $a0, $t2, -1
	mulo $a0, $a0, $t1
	add $a0, $a0, $t0
	li $v0, 1
	syscall
	li $v0, 11
	li $a0, '\n'
	syscall
	jr $ra
# Print wrong input
wrong_range:
	li $v0, 4
	la $a0, wrong_input
	syscall
	j user_element




