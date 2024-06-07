.text

.globl main

main: 
	li $t1, 0x0040000c #carrega um valor de teste em $t1
	move $t2, $zero #inicia o registrador $t2 com 0
	la $a0, inicio_hex
	li $v0, 4
	syscall
	j enquanto
faca:
	#$t3 vai guardar os 4 bytes atuais
	sllv  $t3, $t1, $t2 #faz o shift para a esquerda de acordo com o valor armazenado em $t2
	srl $t3, $t3, 28 #faz o shift para a direita de 28 bits
	move $a0, $t3 #coloca o valor dos 4 bits no registrador de argumento $a0
	jal printa_4_bits
	addi $t2, $t2, 4 #adiciona 4 ao contador de quantos bits fazer shift para a esquerda

enquanto:
	ble $t2, 28, faca
fim:
	li $v0, 10
	syscall #finaliza o programa
printa_4_bits:
	move $t5, $a0
	ble $a0, 9, digito_decimal #se o valor for menor ou igual a 9 é um dígito decimal e pode ser printado como inteiro
	j digito_hexadecimal
digito_decimal:
	li $v0, 1 #syscall para printar inteiro
	syscall #faz a chamada
	jr $ra
digito_hexadecimal:
	beq $t5, 10, hex_a
	beq $t5, 11, hex_b
	beq $t5, 12, hex_c
	beq $t5, 13, hex_d
	beq $t5, 14, hex_e
	beq $t5, 15, hex_f
	j fim_switch
hex_a:
	li $a0, 'a'
	li $v0, 11
	syscall
	j fim_switch
hex_b:
	li $a0, 'b'
	li $v0, 11
	syscall
	j fim_switch
hex_c:
	li $a0, 'c'
	li $v0, 11
	syscall
	j fim_switch
hex_d:
	li $a0, 'd'
	li $v0, 11
	syscall
	j fim_switch
hex_e:
	li $a0, 'e'
	li $v0, 11
	syscall
	j fim_switch
hex_f:
	li $a0, 'f'
	li $v0, 11
	syscall
	j fim_switch
fim_switch:
	jr $ra
	
.data
inicio_hex: .asciiz "0x"