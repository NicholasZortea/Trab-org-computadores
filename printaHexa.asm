.text

.globl printa_hexa

######################################################################################################################################
#Mapa dos registradores:													     #
#$t1 -> contém o valor hexadecimal para ser printado										     #
#$t2 -> contém o valor de quantos bits deve ser feito o shift para a esquerda, aumenta de 4 em 4 para pegar cada valor hexadecimal   #
#$t3 -> contém o valor dos 4 bits atuais do loop a ser printado									     #
#$t5 -> vai conter os 4 bits dentro do procedimento 'printa_4_bits'								     #
######################################################################################################################################
#mapa da pilha:
#0($sp) -> vai conter o $ra
#4($sp) -> vai conter $t1
#8($sp) -> vai conter $t2
#12($sp) -> vai conter $t3
#16($sp) -> vai conter $t5
#20($sp) -> vai conter $a0

printa_hexa: 
	#prologo:
	addiu $sp, $sp -24 #ajusta a pilha
	sw $ra, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t5, 16($sp)
	sw $a0, 20($sp)
	
	#corpo do programa:	
	move $t1, $a0 #carrega o valor do argumento no registrador $t1
	move $t2, $zero #inicia o registrador $t2 com 0
	la $a0, inicio_hex #carrega '0x' no registrador de argumento $a0
	li $v0, 4 #carrega o serviço para printar string
	syscall #faz a chamada ao syscall para printar '0x' 
	j enquanto #vai para o enquanto
faca:
	#$t3 vai guardar os 4 bytes atuais
	sllv  $t3, $t1, $t2 #faz o shift para a esquerda de acordo com o valor armazenado em $t2
	srl $t3, $t3, 28 #faz o shift para a direita de 28 bits
	move $a0, $t3 #coloca o valor dos 4 bits no registrador de argumento $a0
	jal printa_4_bits
	addi $t2, $t2, 4 #adiciona 4 ao contador de quantos bits fazer shift para a esquerda

enquanto:
	ble $t2, 28, faca #enquanto o valor armazenado em $t2 for menor que 28 vai para o procedimento 'faca'
fim:
	li $v0, 11 #carrega serviço para printar caracter
	li $a0, '\t' #carrega tab no argumento
	syscall
	#epilogo restaura os valores da pilha e retorna
	lw $ra, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	lw $t5, 16($sp)
	lw $a0, 20($sp)
	
	addi $sp, $sp, 20 #reseta pilha
	jr $ra #volta para o procedimento chamador
printa_4_bits:
	move $t5, $a0
	ble $a0, 9, digito_decimal #se o valor for menor ou igual a 9 é um dígito decimal e pode ser printado como inteiro
	j digito_hexadecimal #vai para 'digito_hexadecimal'
digito_decimal:
	li $v0, 1 #syscall para printar inteiro
	syscall #faz a chamada
	jr $ra #retorna para faca
digito_hexadecimal:
	beq $t5, 10, hex_a #se for 10 vai para 'hex_a'
	beq $t5, 11, hex_b #se for 11 vai para 'hex_b'
	beq $t5, 12, hex_c #se for 12 vai para 'hex_c'
	beq $t5, 13, hex_d #se for 13 vai para 'hex_d'
	beq $t5, 14, hex_e #se for 14 vai para 'hex_e'
	beq $t5, 15, hex_f #se for 15 vai para 'hex_f'
	j fim_switch #vai para o 'fim_switch'
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
	jr $ra #retorna para o procedimento 'faca'
	
.data
inicio_hex: .asciiz "0x"
