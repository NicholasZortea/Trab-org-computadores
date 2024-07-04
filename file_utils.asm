	.text
	.globl abre_arquivo
	.globl le_arquivo
	.globl fecha_arquivo
	.globl get_buffer_word
	.globl abre_arquivo_data
	.globl le_arquivo_byte_a_byte
	.globl get_buffer1
	
abre_arquivo:
	#Carrega arquivo
	li $v0, 13 #abre o arquivo
	la $a0, arquivo #passa como argumento o nome do arquivo
	li $a1, 0 #file flag = 0 (read)
	syscall #faz chamada para ler o arquivo
	li $a0, 0xffffffff
	beq $v0, $a0, erro_leitura #se $v0 for menor que 0 vai para erro de leitura
	jr $ra
	
abre_arquivo_data:
	#Carrega arquivo
	li $v0, 13 #abre o arquivo
	la $a0, arquivo_data #passa como argumento o nome do arquivo
	li $a1, 0 #file flag = 0 (read)
	syscall #faz chamada para ler o arquivo
	li $a0, 0xffffffff
	beq $v0, $a0, erro_leitura #se $v0 for menor que 0 vai para erro de leitura
	jr $ra

erro_leitura:
	la $a0, erro_leitura_string #$a0 <- string que representa erro de instrucao nao implementada
	li $v0, 4 #$v0 <- 4 (servico para printar string)
	syscall
	li $v0, 10 #$v0 <- 10 (servico para finalizar o programa)
	syscall

#recebe o file descriptor em $a0
le_arquivo:
	#le o arquivo
	li $v0, 14 #syscall para ler o arquivo
	la $a1, buffer #buffer que guarda todo o conteudo do arquivo
	li $a2, 4 #hardcoded tamanho do buffer
	syscall
	jr $ra
	
#recebe o file descriptor em $a0
le_arquivo_byte_a_byte:
	#le o arquivo
	li $v0, 14 #syscall para ler o arquivo
	la $a1, buffer1 #buffer que guarda todo o conteudo do arquivo
	li $a2, 1 #hardcoded tamanho do buffer
	syscall
	jr $ra
	
fecha_arquivo:
	li $v0, 16 #syscall para fechar arquivo
	move $a0, $s0 #move o file descriptor para o argumento
	syscall #chama o serviço
	jr $ra #volta para a main

#pilha
#0($sp) -> $t1
#4($sp) -> $t2
#8($sp) -> $t3
get_buffer_word:
	#prologo
	addiu $sp, $sp, -12 #abre 12 bytes na pilha
	sw $t1, 0($sp) #armazena registrador temporario
	sw $t2, 4($sp) #armazena registrador temporario
	sw $t3, 8($sp) #armazena registrador temporario
	
	la $t1, buffer
	lb $t2, 0($t1)
	move $t3, $zero
	sll $t2, $t2, 24
	srl $t2, $t2, 24
	or $t3, $t3, $t2
	
	lb $t2, 1($t1)
	sll $t2, $t2, 24
	srl $t2, $t2, 16
	or $t3, $t3, $t2
	
	lb $t2, 2($t1)
	sll $t2, $t2, 24
	srl $t2, $t2 8
	or $t3, $t3, $t2
	
	lb $t2, 3($t1)
	sll $t2, $t2, 24
	or $t3, $t3, $t2
	
	move $v0, $t3
	
	
	lw $t1, 0($sp) #restaura registrador temporario
	lw $t2, 4($sp) #restaura registrador temporario
	lw $t3, 8($sp) #restaura registrador temporario
	addiu $sp, $sp, 12 #retira 12 bytes na pilha
	jr $ra

get_buffer1:
	addiu $sp, $sp, -4 
	sw $t1, 0($sp)
	
	la $t1, buffer1
	lb $v0, 0($t1)
	
	lw $t1, 0($sp)
	addiu $sp, $sp, 4
	jr $ra
	

.data
arquivo: .asciiz "trabalho_01-2024_1.bin"
arquivo_data: .asciiz "trabalh0_01-2024_1.dat"
buffer: .space 4
buffer1: .space 1
erro_leitura_string: .asciiz "Erro ao ler arquivo, o programa sera encerrado"

