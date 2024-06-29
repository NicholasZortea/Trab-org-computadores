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
	move $a0, $s4 #move o PC para o registrador de argumento
	jal printa_hexa #chama procedimento para printar o PC em hexadecimal

	jal get_buffer_word #procedimento para retornar o que esta no buffer para o registrador $v0
	move $s1, $v0 #seta conteudo de $v0 em $s1
	move $a0, $s1 #passa para o argumento a word do conteudo do buffer
	jal printa_hexa #vai para o procedimento que printa a palavra carregada do buffer em hexadecimal
	
	jal decodifica
	
	jal printa_linha_vazia
	addi $s4, $s4, 4 #adiciona 4 no PC
enquanto_ler_4_bytes:
	jal le_arquivo
	beq $s3, $v0, faça #compara o registrador $v0 com o $s3, se $v0 for igual a 4 vai para faça
fim_condição:
	jal fecha_arquivo
	#termina o programa
	li $v0, 10
	syscall
	
printa_linha_vazia:
	li $a0, '\n'
	li $v0, 11
	syscall
	jr $ra
