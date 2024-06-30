.data
registrador0: .asciiz "$zero"
registradorAt: .asciiz "$at"
registradorV0: .asciiz "$v0"
registradorV1: .asciiz "$v1"
registradorA0: .asciiz "$a0"
registradorA1: .asciiz "$a1"
registradorA2: .asciiz "$a2"
registradorA3: .asciiz "$a3"
registradorT0: .asciiz "$t0"
registradorT1: .asciiz "$t1"
registradorT2: .asciiz "$t2"
registradorT3: .asciiz "$t3"
registradorT4: .asciiz "$t4"
registradorT5: .asciiz "$t5"
registradorT6: .asciiz "$t6"
registradorT7: .asciiz "$t7"
registradorS0: .asciiz "$s0"
registradorS1: .asciiz "$s1"
registradorS2: .asciiz "$s2"
registradorS3: .asciiz "$s3"
registradorS4: .asciiz "$s4"
registradorS5: .asciiz "$s5"
registradorS6: .asciiz "$s6"
registradorS7: .asciiz "$s7"
registradorT8: .asciiz "$t8"
registradorT9: .asciiz "$t9"
registradorK0: .asciiz "$k0"
registradorK1: .asciiz "$k1"
registradorGP: .asciiz "$gp"
registradorSP: .asciiz "$sp"
registradorFP: .asciiz "$fp"
registradorRA: .asciiz "$ra"

.text
.globl decodifica_registrador

#pilha:
#0($sp) -> $a0
#4($sp) -> $ra
#registadores:
#$a0 -> 5 bits que representam o registrador
decodifica_registrador:
	#prologo
	addi $sp, $sp -8 #aloca 8 bytes
	sw $ra, 4($sp) #armazena registrador de retorno
	sw $a0, 0($sp) #armazena registrador de argumento
	
	#corpo do programa
	beq $a0, 0, print_$zero
	beq $a0, 1, print_$at
	beq $a0, 2, print_$v0
	beq $a0, 3, print_$v1
	beq $a0, 4, print_$a0
	beq $a0, 5, print_$a1
	beq $a0, 6, print_$a2
	beq $a0, 7, print_$a3
	beq $a0, 8, print_$t0
	beq $a0, 9, print_$t1
	beq $a0, 10, print_$t2
	beq $a0, 11, print_$t3
	beq $a0, 12, print_$t4
	beq $a0, 13, print_$t5
	beq $a0, 14, print_$t6
	beq $a0, 15, print_$t7
	beq $a0, 16, print_$s0
	beq $a0, 17, print_$s1
	beq $a0, 18, print_$s2
	beq $a0, 19, print_$s3
	beq $a0, 20, print_$s4
	beq $a0, 21, print_$s5
	beq $a0, 22, print_$s6
	beq $a0, 23, print_$s7
	beq $a0, 24, print_$t8
	beq $a0, 25, print_$t9
	beq $a0, 26, print_$k0
	beq $a0, 27, print_$k1
	beq $a0, 28, print_$gp
	beq $a0, 29, print_$sp
	beq $a0, 30, print_$fp
	beq $a0, 31, print_$ra
	
fim:	
	#epilogo
	lw $ra, 4($sp) #retorna registrador de retorno
	lw $a0, 0($sp) #retorna registrador de argumento
	addi $sp, $sp 8 #desaloca 8 bytes
	jr $ra

print_$zero:
	la $a0, registrador0
	jal printa_string
	j fim
	
print_$at:
	la $a0, registradorAt
	jal printa_string
	j fim
	
print_$v0:
	la $a0, registradorV0
	jal printa_string
	j fim
	
print_$v1:
	la $a0, registradorV1
	jal printa_string
	j fim
	
print_$a0:
	la $a0, registradorA0
	jal printa_string
	j fim
	
print_$a1:
	la $a0, registradorA1
	jal printa_string
	j fim

print_$a2:
	la $a0, registradorA2
	jal printa_string
	j fim
	
print_$a3:
	la $a0, registradorA3
	jal printa_string
	j fim
	
print_$t0:
	la $a0, registradorT0
	jal printa_string
	j fim
	
print_$t1:
	la $a0, registradorT1
	jal printa_string
	j fim

print_$t2:
	la $a0, registradorT2
	jal printa_string
	j fim
	
print_$t3:
	la $a0, registradorT3
	jal printa_string
	j fim
	
print_$t4:
	la $a0, registradorT4
	jal printa_string
	j fim
	
print_$t5:
	la $a0, registradorT5
	jal printa_string
	j fim
	
print_$t6:
	la $a0, registradorT6
	jal printa_string
	j fim
	
print_$t7:
	la $a0, registradorT7
	jal printa_string
	j fim
	
print_$s0:
	la $a0, registradorS0
	jal printa_string
	j fim

print_$s1:
	la $a0, registradorS1
	jal printa_string
	j fim
	
print_$s2:
	la $a0, registradorS2
	jal printa_string
	j fim
	
print_$s3:
	la $a0, registradorS3
	jal printa_string
	j fim
	
print_$s4:
	la $a0, registradorS4
	jal printa_string
	j fim
	
print_$s5:
	la $a0, registradorS5
	jal printa_string
	j fim
	
print_$s6:
	la $a0, registradorS6
	jal printa_string
	j fim
	
print_$s7:
	la $a0, registradorS7
	jal printa_string
	j fim
	
print_$t8:
	la $a0, registradorT8
	jal printa_string
	j fim
	
print_$t9:
	la $a0, registradorT9
	jal printa_string
	j fim
	
print_$k0:
	la $a0, registradorK0
	jal printa_string
	j fim

print_$k1:
	la $a0, registradorK1
	jal printa_string
	j fim
	
print_$gp:
	la $a0, registradorGP
	jal printa_string
	j fim

print_$sp:
	la $a0, registradorSP
	jal printa_string
	j fim
	
print_$fp:
	la $a0, registradorFP
	jal printa_string
	j fim
	
print_$ra:
	la $a0, registradorRA
	jal printa_string
	j fim