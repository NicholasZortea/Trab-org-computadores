.eqv SERVICO_PRINTA_CHAR 11
.eqv SERVICO_PRINTA_INT 1

.text
.globl main
########################
#mapa dos registradores#
#$s0 -> file descriptor do arquivo binario sendo lido
#$s1 -> palavra carregada do buffer
#$s3 -> registrador que vai conter o valor 4 para comparações de quantidade de bytes lidos
main: 
	jal abre_arquivo #procedimento para abrir o arquivo
	move $s0, $v0 #move o file descriptor retornado para $s0
	addi $s3, $zero, 4 #adicina o valor 4 ao registrador $s3
	j enquanto_ler_4_bytes #pula para a condicao
faça:	
	#jal printa_buffer #procedimento para printar o que esta no buffer como string
	jal get_buffer_word #procedimento para retornar o que esta no buffer para o registrador $v0
	move $s1, $v0 #seta conteudo de $v0 em $s1
	move $a0, $s1
	jal printa_byte_a_byte
enquanto_ler_4_bytes:
	jal le_arquivo
	beq $s3, $v0, faça #compara o registrador $v0 com o $s3, se $v0 for igual a 4 vai para faça
fim_condição:
	jal fecha_arquivo
	#termina o programa
	li $v0, 10
	syscall

printa_byte_a_byte:
	addiu $sp, $sp -4 #aloca 4 bytes na pilha
	sw $a0, 0($sp) #move argumento para pilha no endereço 0
	
	#o codigo hexadecimal possui 32 bits 32 - 6 = 26
	lw $t1, 0($sp)
	srl $t1, $t1, 26 #shif para a direita de 24 casas, ficando com os 6 bits do opcode
	
	li $v0, SERVICO_PRINTA_INT
	move $a0, $t1
	syscall 
	
	li $v0, SERVICO_PRINTA_CHAR
	li $a0, ' '
	syscall
	
	addiu $sp, $sp, 4
	jr $ra
