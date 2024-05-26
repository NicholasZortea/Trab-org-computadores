.text
.globl main
########################
#mapa dos registradores#
#$0 -> file descriptor do arquivo binario sendo lido
#s1 -> quantidade de bytes lidos
main: 
	#abre arquivo binario
	jal abre_arquivo #procedimento para abrir o arquivo
	move $s0, $v0 #move o file descriptor retornado para $s0
	j enquanto_ler_4_bytes
faça:	
	jal printa_buffer
enquanto_ler_4_bytes:
	jal le_arquivo
	move $s1, $v0 
	addi $t0, $zero, 4
	beq $t0, $s1, faça
fim_condição:
	jal fecha_arquivo
	#termina o programa
	li $v0, 10
	syscall

