
.text
.globl decodifica

#####################################
#registradores			    #
#em $s1 <- instrução lida do buffer #
#em $s2 <- opcode da instrução      #
#####################################
#################
#pilha		#
#0($sp) <- $ra  #
#4($sp) <- $s1  #
#8($sp) <- $s2  #
#12($sp) <- $a0 #
#################
decodifica:
	#prologo
	addi $sp, $sp, -16 #abre 16 bytes para armazenar os registradores na pilha
	sw $ra, 0($sp) #armazena o $ra na pilha para restaurar posteriormente
	sw $s1, 4($sp) #armazena o $s1 na pilha para restaurar posteriormente
	sw $s2, 8($sp) #armazena o $s2 na pilha para restaurar posteriormente
	sw $a0, 12($sp) #armazena o $a0 na pilha para restaurar posteriormente
	
	#corpo do procedimento
	move $s1, $a0 #move a instrução do argumento para $s1
	jal get_instrucao_opcode #vai para procedimento para pegar o opcode da instrução
	move $s2, $v0 #move o opcode da instrução para $s2

	move $a0, $s1 #move a instrução para o registrador de argumento $a0
	move $a1, $s2 #move o opcode da instrução para o registrador de argumento $a1
	jal identifica_instrucao #vai para o procedimento que identifica a instrucao
	
	#epilogo
	lw $ra, 0($sp) #restaura o $ra
	lw $s1, 4($sp) #restaura o $s1
	lw $s2, 8($sp) #restaura o $s2
	lw $a0, 12($sp) #restaura o $a0
	addi $sp, $sp 16 #restaura pilha
	jr $ra #volta para o local onde chamou esse procedimento
	
get_instrucao_opcode:
	addi $sp, $sp, -8
	sw $a0, 4($sp)
	sw $ra, 0($sp) #armazena o $ra na pilha para restaurar posteriormente
	srl $v0, $a0, 26 #shift para direita de 26 casas para pegar o opcode
	lw $ra, 0($sp) #restaura o $ra para voltar a funcao certa
	lw $a0, 4($sp)
	addi $sp, $sp 8 #restaura pilha
	jr $ra
	
#registrador
#$t1 <- instrução
#$t2 <- opcode	
identifica_instrucao:
	addi $sp, $sp, -12 #abre espaço na pilha para 8 bytes
	sw $ra, 0($sp) #armazena o $ra na pilha para restaurar posteriormente
	sw $a0, 4($sp) #armazena o registrador de argumento na pilha (instrução)
	sw $a1, 8($sp) #armazena o registrador de argumento na pilha
	
	move $t1, $a0 #seta $t1 para a instrução
	move $t2, $a1 #seta $t2 para o opcode da instrucao
	
	beq $t2, 9, addiu_label #se o opcode for 9 vai para a instrução addiu
	beq $t2, 43, sw_label #se o opcode for 43 vai para instrução sw
	j fim_switch
	
sw_label:
	la $a0, sw_str #carrega 'sw ' em $a0
	jal printa_string #printa a string acima
	
	#rt
	lw $a0, 4($sp) #carrega a instrução em $a0
	jal get_rt_tipo_i #retorna em $v0 o registrador rt
	move $a0, $v0 #move para o argumento o registrador rt
	jal decodifica_registrador #printa o registrador rt
	jal printa_virgula_espaco #printa virgula e um espaco
	
	#imm/offset
	lw $a0, 4($sp) #carrega a instrução em $a0
	jal get_imm_tipo_i #retorna em $v0 o offset
	move $a0, $v0 #carrega o offset em $a0
	jal printa_inteiro #printa como inteiro
	
	#rs
	li $a0, '(' #carrega o caracter '(' em $a0
	jal printa_caracter #printa o caracter contido em $a0
	
	lw $a0, 4($sp) #carrega a instrução em $a0
	jal get_rs_tipo_i #retorna em $v0 o offset
	move $a0, $v0 #move para o argumento o registrador rs
	jal decodifica_registrador #printa o registrador rs
	
	li $a0, ')' #carrega o caracter ')' em $a0
	jal printa_caracter #printa o caracter contido em $a0
	
	j fim_switch

	
addiu_label:
	la $a0, addiu_str #printa o conteudo de addiu_str
	jal printa_string
	move $a0, $t1 #move instrucao para argumento
	
	#printa rt
	jal get_rt_tipo_i
	move $a0, $v0 #move o registrador rt para $a0
	jal decodifica_registrador #vai para procedimento que printa o registrador
	jal printa_virgula_espaco #procedimento que printa virgula e um espaço
	
	#printa rs
	lw $a0, 4($sp) #carrega instrucao no $a0 novamente
	jal get_rs_tipo_i #vai para método que retorna qual o rs
	move $a0, $v0 #move o registrador rs para o de argumento
	jal decodifica_registrador #printa o registrador rs
	jal printa_virgula_espaco #procedimento que printa virgula e um espaço
	
	#printa imm
	lw $a0, 4($sp) #carrega instrucao no $a0 novamente
	jal get_imm_tipo_i #procedimento que retorna o imm 
	move $a0, $v0 #move imm para registrador de argumento
	jal printa_imm #vai para procedimento que printa o imm
	
	j fim_switch
	
fim_switch:
	lw $ra, 0($sp) #restaura o $ra para voltar a funcao certa
	lw $a0, 4($sp) #restaura o registrador de argumento
	lw $a0, 8($sp) #restaura o registrador de argumento
	
	addi $sp, $sp 12 #restaura pilha
	jr $ra
		
#pilha
#0($sp) -> $a0
#4($sp) -> $ra
#8($sp) -> $t1
#12($sp) -> $t2
#-------------
#registradores
#$t2 -> imm
#$t1 -> msb / complemento
printa_imm:
	#prologo
	addi $sp, $sp, -16 #aloca 16 bytes
	sw $a0, 0($sp) #armazena registrador de argumento
	sw $ra, 4($sp) #armazena registrador de retorno
	sw $t1, 8($sp) #armazena registrador temporario
	sw $t2, 12($sp) #armazena registrador temporario
	
	#corpo do procedimento
	move $t2, $a0
	srl $t1, $a0, 15 #shift de 15 bits para pegar o msb
	beq $t1, 0, printa_numero #se o MSB for igual a 0 significa que é um número positivo, bastando printar ele
	
	nor $t1, $t2, $zero #complementa bit a bit e armazena em $t1
	sll $t1, $t1, 16 #shift para esquerda de 16 bits
	srl $t1, $t1, 16 #shift para direita para ignorar o complemento de numeros alem dos 16 bits
	addi $t1, $t1, 1 #adiciona 1 para pegar o complemento de 2
	li $a0, '-' #carrega simbolo de menos
	jal printa_caracter #vai para o procedimento que printa o caracter
	move $a0, $t1
	jal printa_inteiro #vai para o procedimento que printa inteiro
	j fim
printa_numero:
	move $a0, $t2
	jal printa_inteiro
fim:
	#epilogo
	lw $a0, 0($sp) #retorna registrador de argumento
	lw $ra, 4($sp) #retorna registrador de retorno
	lw $t1, 8($sp) #retorna registrador temporario
	lw $t2, 12($sp) #armazena registrador temporario
	addi $sp, $sp, 16 #desaloca 8 bytes
	jr $ra
	
get_rs_tipo_i:
	#corpo do procedimento
	sll $t1, $a0, 6 #shift left de 6 bits para pegar rs
	srl $t1, $t1, 27 #shift right para isolar os 5 bits do rs
	move $v0, $t1 #seta retorno como registrador dos 5 bits
	#epilogo
	jr $ra

get_rt_tipo_i:
	#corpo do procedimento
	sll $t1, $a0, 11 #shift left de 5 bits para pegar rs
	srl $t1, $t1, 27 #shift right para isolar os 5 bits do rs
	move $v0, $t1 #seta retorno como registrador dos 5 bits
	
	#epilogo
	jr $ra

get_imm_tipo_i:
	#corpo do procedimento
	sll $t1, $a0, 16 #shift left de 5 bits para pegar rs
	srl $t1, $t1, 16 #shift right para isolar os 5 bits do rs
	move $v0, $t1 #seta retorno como valor imediato de 16 bits
	
	#epilogo
	jr $ra

.data
addiu_str: .asciiz "addiu "
sw_str: .asciiz "sw "
