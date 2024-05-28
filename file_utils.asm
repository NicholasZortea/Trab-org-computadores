	.text
	.globl abre_arquivo
	.globl le_arquivo
	.globl fecha_arquivo
	.globl printa_buffer
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
	
printa_buffer:
			
	la $a0, buffer #carrega o endereco do buffer no registrador de argumento $a0
	li $v0, 4 #syscall para printar string
	syscall
	
	li $a0, '\n'
	li $v0, 11
	syscall
	jr $ra

get_buffer_word:
	lw $v0, buffer
	jr $ra

.data
arquivo: .asciiz "C:/Users/zorte/Documents/TrabOrgComputadores/trabalho_01-2024_1.bin"
buffer: .space 4
