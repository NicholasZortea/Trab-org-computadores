
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
	addi $sp, $sp, -8 #abre 8 bytes
	sw $a0, 4($sp) #armzanea $a0 
	sw $ra, 0($sp) #armazena o $ra na pilha para restaurar posteriormente
	srl $v0, $a0, 26 #shift para direita de 26 casas para pegar o opcode
	lw $ra, 0($sp) #restaura o $ra para voltar a funcao certa
	lw $a0, 4($sp) #restaura $a0
	addi $sp, $sp 8 #restaura pilha
	jr $ra
	
#registrador
#$t1 <- instrução
#$t2 <- opcode	
#pilha
#0($sp) -> $ra
#4($sp) -> $a0
#8($sp) -> $a1
identifica_instrucao:
	addi $sp, $sp, -12 #abre espaço na pilha para 8 bytes
	sw $ra, 0($sp) #armazena o $ra na pilha para restaurar posteriormente
	sw $a0, 4($sp) #armazena o registrador de argumento na pilha (instrução)
	sw $a1, 8($sp) #armazena o registrador de argumento na pilha (opcode)
	
	move $t1, $a0 #seta $t1 para a instrução
	move $t2, $a1 #seta $t2 para o opcode da instrucao
	
	addi $t3, $zero, 0x000c
	
	beq $t1, $t3, syscall_label #se for syscall vai para syscall_label
	beq $t2, 9, addiu_label #se o opcode for 9 vai para a instrução addiu
	beq $t2, 43, sw_label #se o opcode for 43 vai para instrução sw
	beq $t2, 0, tipo_r_label #se o opcode for 0 é uma instrução do tipo r e precisa verificar o campo funct
	beq $t2, 3, jal_label #se o opcode for 2 é uma instrução do tipo jal
	beq $t2, 35, lw_label #se o opcode for 43 vai para a instrução lw
	beq $t2, 5, bne_label #se o opcode for 5 vai para a instrução bne
	beq $t2, 8, addi_label #se o opcode for 5 vai para a instrução addi
	beq $t2, 28, tipo_r_label #se o opcode for 28 vai para instruções do tipo r
	beq $t2, 2, j_label #se o opcode for 2 vai para instrução j
	beq $t2, 15, lui_label #se o opcode for 15 vai para instrução lui
	beq $t2, 13, ori_label #se o opcode for 13 vai para instrução ori
	j fim_switch
	
ori_label:
	la $a0, ori_str #carrega string em $a0
	jal printa_string #printa a string em $a0
	
	#rt
	lw $a0, 4($sp) #recarrega instrucao
	jal get_rt_tipo_i #move rs para $v0
	move $a0, $v0 #seta $a0 para o rs
	jal decodifica_registrador #printa o registrador rs
	jal printa_virgula_espaco #printa virgula e espaco
	
	#rs
	lw $a0, 4($sp) #recarrega instrucao
	jal get_rs_tipo_i #move rs para $v0
	move $a0, $v0 #seta $a0 para o rs
	jal decodifica_registrador #printa o registrador rs
	jal printa_virgula_espaco #printa virgula e espaco
	
	#label
	lw $a0, 4($sp) #recarrega instrucao
	jal get_imm_tipo_i #move rs para $v0
	move $a0, $v0 #seta $a0 para o rs
	jal printa_hexa #printa hexadecimal
	
	j fim_switch

lui_label:
	la $a0, lui_str #carrega string em $a0
	jal printa_string #printa a string em $a0
	
	#rt
	lw $a0, 4($sp) #recarrega instrução
	jal get_rt_tipo_i #move rt para $v0
	move $a0, $v0 #move rt para $a0
	jal decodifica_registrador #printa o registrador
	jal printa_virgula_espaco #printa uma virgula e um espaco
	
	#imm
	lw $a0, 4($sp) #recarrega instrucao
	jal get_imm_tipo_i #move imm para $v0
	move $a0, $v0 #seta $a0 para o imm
	jal printa_hexa #printa sabado
	
	j fim_switch
	
j_label:
	la $a0, j_str #carrega string
	jal printa_string #printa a string j
	
	lw $a0, 4($sp) #restaura instrucao
	jal get_target_tipo_j #move target da instrução para $v0
	move $a0, $v0 #move target para $a0
	jal printa_hexa #printa o target
	
	j fim_switch #vai para o fim do switch
	
addi_label:
	la $a0, addi_str #carrega string em $a0
	jal printa_string #printa string de $a0
	
	
	#rt
	lw $a0, 4($sp) #recarrega instrucao
	jal get_rt_tipo_i #pega rt em $v0
	move $a0, $v0 #seta $a0 para o registrador rt
	jal decodifica_registrador #printa o registrador rt
	jal printa_virgula_espaco #printa virgula e espaco
	
	#rs
	lw $a0, 4($sp) #recarrega instrucao
	jal get_rs_tipo_i #pega rs em $v0
	move $a0, $v0 #seta $a0 para o registrador rs
	jal decodifica_registrador #printa o registrador rs
	jal printa_virgula_espaco #printa virgula e espaco
	
	#imm
	lw $a0, 4($sp) #recarrega instrucao
	jal get_imm_tipo_i #pega imm em $v0
	move $a0, $v0 #seta $a0 para o registrador imm
	jal printa_imm #printa o imm
	j fim_switch

bne_label:
	la $a0, bne_str #carrega a string bne em $a0
	jal printa_string #vai para procedimento que printa a string de $a0
	
	lw $a0, 4($sp) #recarrega instrucao
	jal printa_tipo_i_2 #printa instrucao do tipo rs, rt, label
	
	j fim_switch
	
syscall_label:
	la $a0, syscall_str #carrega string do syscall
	jal printa_string #printa string 
	j fim_switch	#vai para o final do switch
	
lw_label:
	la $a0, lw_str #carrega string lw em $a0
	jal printa_string #printa string contida em $a0
	lw $a0, 4($sp) #recarrega instrucao 
	jal printa_tipo_i_1 #printa o tipo de lw
	j fim_switch
	
jal_label:
	la $a0, jal_str #carrega a string de jal em $a0
	jal printa_string #printa a string de $a0
	
	#target
	lw $a0, 4($sp) #recarrega instrucao
	jal get_target_tipo_j #retorna o target em $v0
	move $a0, $v0 #seta o target em $a0
	jal printa_hexa
	j fim_switch
	
tipo_r_label:
	jal get_funct_tipo_r #pega qual o campo funct e coloca em $v0
	lw $a0, 4($sp) #restaura instrucao no $a0
	beq $v0, 32, add_label #se o campo funct for igual a 32 vai para add_label
	beq $v0, 33, addu_label #se o campo funct for igual a 33 vai para addu_label
	beq $v0, 2, mul_label #se o campo funct for igual a 2 vai para mul_label
	beq $v0, 8, jr_label #se o campo funct for igual a 8 vai para jr_label
	j fim_switch
	
jr_label:
	la $a0, jr_str #carrega string
	jal printa_string #printa a string
	
	lw $a0, 4($sp) #restaura instrucao
	jal get_rs_tipo_r #move rs para $v0
	move $a0, $v0 #move rs para $a0
	jal decodifica_registrador #printa o registrador rs
	j fim_switch

mul_label:
	la $a0, mul_str #carrega string
	jal printa_string #printa string
	
	lw $a0, 4($sp) #carrega instrucao
	jal printa_tipo_r_1 #printa instrucao do tipo rd, rs, rt
	j fim_switch

addu_label:
	la $a0, addu_str #carrega a string addu em $a0
	jal printa_string #printa a string de $a0
	lw $a0, 4($sp) #recarrega instrucao
	jal printa_tipo_r_1 #printa instrucao do tipo rd, rs, rt
	j fim_switch

add_label:
	la $a0, add_str #carrega a string da instrucao
	jal printa_string #printa a string de $a0
	lw $a0, 4($sp) #recarrega instrucao
	jal printa_tipo_r_1 #printa instrucao do tipo rd, rs, rt
	j fim_switch #vai para o fim_switch

sw_label:
	la $a0, sw_str #carrega 'sw ' em $a0
	jal printa_string #printa a string acima
	lw $a0, 4($sp) #recarrega instrucao
	jal printa_tipo_i_1 #printa o tipo i de sw	
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
	lw $a1, 8($sp) #restaura o registrador de argumento
	
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
	sll $t1, $a0, 11 #shift left de 11 bits para pegar rt
	srl $t1, $t1, 27 #shift right para isolar os 27 bits do rt
	move $v0, $t1 #seta retorno como registrador dos 5 bits
	
	#epilogo
	jr $ra

get_imm_tipo_i:
	#corpo do procedimento
	sll $t1, $a0, 16 #shift left de 16 bits para pegar imm
	srl $t1, $t1, 16 #shift right para isolar os 16 bits do imm
	move $v0, $t1 #seta retorno como valor imediato de 16 bits
	
	#epilogo
	jr $ra
	
get_rs_tipo_r:
	#corpo do procedimento
	sll $t1, $a0, 6 #shift left de 6 bits para pegar o rs
	srl $v0, $t1, 27 #shift right para isolar os 5 bits do rs 
	
	#epilogo
	jr $ra
	
get_rt_tipo_r:
	#corpo do procedimento
	sll $t1, $a0, 11 #shift left de 11 bits para pegar o rt
	srl $v0, $t1, 27 #shift right para isolar os 5 bits do rt 
	
	#epilogo
	jr $ra
	
get_rd_tipo_r:
	#corpo do procedimento
	sll $t1, $a0, 16 #shift left de 16 bits para pegar o rd
	srl $v0, $t1, 27 #shift right para isolar os 5 bits do rd 
	
	#epilogo
	jr $ra
	
get_shamt_tipo_r:
	#corpo do procedimento
	sll $t1, $a0, 21 #shift left de 21 bits para pegar o campo shamt
	srl $v0, $t1, 27 #shift right para isolar o campo shamt
	
	#epilogo
	jr $ra

get_funct_tipo_r:
	#corpo do procedimento
	sll $t1, $a0, 26 #shift left de 26 bits para pegar o campo funct
	srl $v0, $t1, 26 #shift right para isolar o campo funct
	
	#epilogo
	jr $ra

get_target_tipo_j:
	#corpo do procedimento
	sll $v0, $a0, 6 #shift left de 6 bits para eliminar o opcode
	srl $v0, $v0 4 #shift right de 4 bits para colocar 4 bits no msb e 2 no lsb
	
	#epilogo 
	jr $ra
	
#printa instruções no estilo rt, imm(rs)
#pilha 
#0($sp) -> $a0
#4($sp) -> $ra
printa_tipo_i_1:
	#prologo
	addiu $sp, $sp, -8 #aloca 4 bytes para o argumento
	sw $a0, 0($sp) #salva $a0
	sw $ra, 4($sp) #salva $ra
	
	#rt
	lw $a0, 0($sp) #carrega a instrução em $a0
	jal get_rt_tipo_i #retorna em $v0 o registrador rt
	move $a0, $v0 #move para o argumento o registrador rt
	jal decodifica_registrador #printa o registrador rt
	jal printa_virgula_espaco #printa virgula e um espaco
	
	#imm/offset
	lw $a0, 0($sp) #carrega a instrução em $a0
	jal get_imm_tipo_i #retorna em $v0 o offset
	move $a0, $v0 #carrega o offset em $a0
	jal printa_inteiro #printa como inteiro
	
	#rs
	li $a0, '(' #carrega o caracter '(' em $a0
	jal printa_caracter #printa o caracter contido em $a0
	
	lw $a0, 0($sp) #carrega a instrução em $a0
	jal get_rs_tipo_i #retorna em $v0 o offset
	move $a0, $v0 #move para o argumento o registrador rs
	jal decodifica_registrador #printa o registrador rs
	
	li $a0, ')' #carrega o caracter ')' em $a0
	jal printa_caracter #printa o caracter contido em $a0
	
	#epilogo
	lw $a0, 0($sp) #restaura $a0
	lw $ra, 4($sp) #restaura $ra
	addiu $sp, $sp, 8 #desaloca 8 bytes
	jr $ra

#printa instruções no estilo rd, rs, rt
#pilha 
#0($sp) -> $a0
#4($sp) -> $ra
printa_tipo_r_1:
	#prologo
	addiu $sp, $sp, -8 #aloca 4 bytes para o argumento
	sw $a0, 0($sp) #salva $a0
	sw $ra, 4($sp) #salva $ra

	#rd
	jal get_rd_tipo_r #retorna o registrador rd em $v0
	move $a0, $v0 #move o registrador rd para $a0
	jal decodifica_registrador #vai para procedimento que printa o registrador
	jal printa_virgula_espaco #vai para procedimento que printa uma virgula seguida de espaco
	
	#rs
	lw $a0, 0($sp) #recarrega instrucao
	jal get_rs_tipo_r #retorna o registrador rs em $v0
	move $a0, $v0 #move o registrador rs para $a0
	jal decodifica_registrador #vai para procedimento que printa o registrador
	jal printa_virgula_espaco #vai para procedimento que printa uma virgula seguida de espaco
	
	#rt
	lw $a0, 0($sp) #recarrega instrucao
	jal get_rt_tipo_r #retorna o registrador rt em $v0
	move $a0, $v0 #move o registrador rt para $a0
	jal decodifica_registrador #vai para procedimento que printa o registrador

	#epilogo
	lw $a0, 0($sp) #restaura $a0
	lw $ra, 4($sp) #restaura $ra
	addiu $sp, $sp, 8 #desaloca 8 bytes
	jr $ra

#printa instrucoes do tipo $rs, $rt, label/offset
printa_tipo_i_2:
	#prologo
	addiu $sp, $sp, -8 #aloca 4 bytes para o argumento
	sw $a0, 0($sp) #salva $a0
	sw $ra, 4($sp) #salva $ra
	
	#rs
	jal get_rs_tipo_i #move rs para $v0
	move $a0, $v0 #seta $a0 para o rs
	jal decodifica_registrador #printa o registrador rs
	jal printa_virgula_espaco #printa virgula e espaco
	
	#rt
	lw $a0, 0($sp) #recarrega instrucao
	jal get_rt_tipo_i #move rs para $v0
	move $a0, $v0 #seta $a0 para o rs
	jal decodifica_registrador #printa o registrador rs
	jal printa_virgula_espaco #printa virgula e espaco
	
	#label
	lw $a0, 0($sp) #recarrega instrucao
	jal get_imm_tipo_i #move rs para $v0
	move $a0, $v0 #seta $a0 para o rs
	jal printa_hexa #printa hexadecimal
	
	#epilogo
	lw $a0, 0($sp) #restaura $a0
	lw $ra, 4($sp) #restaura $ra
	addiu $sp, $sp, 8 #desaloca 8 bytes
	jr $ra

.data
addiu_str: .asciiz "addiu "
sw_str: .asciiz "sw "
add_str: .asciiz "add "
jal_str: .asciiz "jal "
lw_str: .asciiz "lw "
addu_str: .asciiz "addu "
syscall_str: .asciiz "syscall "
bne_str: .asciiz "bne "
addi_str: .asciiz "addi "
mul_str: .asciiz "mul "
jr_str: .asciiz "jr "
j_str: .asciiz "j "
lui_str: .asciiz "lui "
ori_str: .asciiz "ori "