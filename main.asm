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
	jal decodifica #vai para procedimento que printa a instrucao
	move $a0, $s1
	jal executa 
	
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
	

#pilha
# 0($sp) -> $a0
# 4($sp) -> $ra
# 8($sp) -> $s0
#registradores
#recebe a instrucao no registrador de argumento $a0
executa:
	#prologo
	addi $sp, $sp, -12 #abre 12 bytes de espaco na pilha
	sw $a0, 0($sp) #armazena $a0
	sw $ra, 4($sp) #armazena $ra
	sw $s0, 8($sp) #armazena $s0
	
	#corpo do procedimento
	jal armazena_instrucao_no_IR #armazena instrucao contida em $a0 em IR
	jal get_instrucao_opcode  #pega o opcode da instrucao contida em $a0
	
	
	#epilogo
	addi $sp, $sp, 12 #
	sw $a0, 0($sp) #restaura $a0
	sw $ra, 4($sp) #restaura $ra
	sw $s0, 8($sp) #restaura $s0
	jr $ra
	
	
armazena_instrucao_no_IR:
	la $t1, IR #carrega endereco
	sw $a0, 0($t1) #armazena em IR
	jr $ra
	
retorna_instrucao_do_IR:
	la $t1, IR #carrega endereco
	lw $v0, 0($t1) #restorna instrucao
	jr $ra
.data
registradores: .space 128 #32 registradores * 4 bytes cada
pilha: .word 0x7FFFFFFC #a pilha "cresce" para baixo portanto começa no maior endereço possível
IR: .word 0 #instruction register

