	.text
	.globl abre_arquivo
	.globl le_arquivo
	.globl fecha_arquivo
	.globl get_buffer_word

abre_arquivo:
	#Carrega arquivo
	li $v0, 13 #abre o arquivo
	la $a0, arquivo #passa como argumento o nome do arquivo
	li $a1, 0 #file flag = 0 (read)
	syscall #faz chamada para ler o arquivo
	jr $ra

le_arquivo:
	#le o arquivo
	li $v0, 14 #syscall para ler o arquivo
	move $a0, $s0 #passa o file descriptor como argumento 
	la $a1, buffer #buffer que guarda todo o conteudo do arquivo
	li $a2, 4 #hardcoded tamanho do buffer
	syscall
	jr $ra
	
fecha_arquivo:
	li $v0, 16 #syscall para fechar arquivo
	move $a0, $s0 #move o file descriptor para o argumento
	syscall #chama o serviço
	jr $ra #volta para a main

get_buffer_word:
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
	jr $ra

.data
arquivo: .asciiz "trabalho_01-2024_1.bin"
buffer: .space 4

