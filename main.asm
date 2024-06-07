.eqv SERVICO_PRINTA_CHAR 11
.eqv SERVICO_PRINTA_INT 1

.text
.globl main
########################
#mapa dos registradores#
#$s0 -> file descriptor do arquivo binario sendo lido
#$s1 -> palavra carregada do buffer
#$s3 -> registrador que vai conter o valor 4 para comparações de quantidade de bytes lidos
#$s4 -> registrador que simula o PC, vai começar em 0x00400000
main: 
	jal abre_arquivo #procedimento para abrir o arquivo
	move $s0, $v0 #move o file descriptor retornado para $s0
	addi $s3, $zero, 4 #adicina o valor 4 ao registrador $s3
	li $s4, 0x00400000 #inicia o Program Counter
	j enquanto_ler_4_bytes #pula para a condicao
faça:	
	#jal printa_buffer #procedimento para printar o que esta no buffer como string
	jal get_buffer_word #procedimento para retornar o que esta no buffer para o registrador $v0
	move $s1, $v0 #seta conteudo de $v0 em $s1
	move $a0, $s4 #seta o argumento para o endereco do programCounter
	move $a0, $s1 #passa para o argumento a word do conteudo do buffer
	jal printa_hexa #vai para o procedimento que printa o valor em $a0, como hexadecimal
enquanto_ler_4_bytes:
	jal le_arquivo
	beq $s3, $v0, faça #compara o registrador $v0 com o $s3, se $v0 for igual a 4 vai para faça
fim_condição:
	jal fecha_arquivo
	#termina o programa
	li $v0, 10
	syscall
	

######################################################################################################
#Mapa da pilha:										             #		
#0($sp) -> argumento passado para esse procedimento que contem a palavra da instrução		     #
#4($sp) -> armazena o valor do registrador $ra, para ser restaurado antes de terminar o procedimento #
######################################################################################################
printa_byte_a_byte:
	addiu $sp, $sp -8 #aloca 8 bytes na pilha
	sw $a0, 0($sp) #move argumento para pilha no endereço 0
	sw $ra, 4($sp) #armazena o valor de retorno da funcao
	
	jal get_instrucao_opcode
	move $t1, $v0
	
	li $v0, SERVICO_PRINTA_INT
	move $a0, $t1
	syscall 
	
	li $v0, SERVICO_PRINTA_CHAR
	li $a0, ' '
	syscall
	
	lw $ra, 4($sp)
	addiu $sp, $sp, 8
	jr $ra

get_instrucao_opcode:
	srl $v0, $a0, 26 #shift para direita de 26 casas para pegar o opcode
	jr $ra
	
printa_instrucao:
	addiu $sp, $sp -4 #aloca 4 bytes para a instrução a ser printada
	sw $a0, 0($sp) #guarda na memoria a instrução
	
	
	addiu $sp, $sp, 4
	jr $ra
