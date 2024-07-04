.text
.globl main
main: 	
	jal armazena_data #le byte por byte do arquivo .dat e armazena no segmento simulado de data
	jal armazena_instrucoes #le instrucao por instrucao e armazena em um segmento de texto simulado
	jal carrega_endereco_sp_nos_registradores #registradores[29] = valor de SP 
faca:	
	jal printa_PC #printa o endereco de PC em hexadecimal
	jal busca_instrucao #IR <- instrucao atual
	
	jal printa_instrucao #printa a instrucao em hexa e sua versao traduzida para assembly
	
	jal executa 
	
	jal incrementa_PC #PC += 4
	j faca

printa_instrucao:
	addiu $sp, $sp, -4 #aloca 4 bytes
	sw $ra, 0($sp) #armazena $ra
	
	jal get_instrucao_do_IR #$v0 <- instrucao atual
	move $a0, $v0 #$a0 <- instrucao atual
	jal printa_hexa #vai para o procedimento que printa a instrucao de $a0 em hexadecimal
	jal decodifica #vai para procedimento que printa a instrucao
	jal printa_linha_vazia #printa o caracter '\n'
	
	lw $ra, 0($sp) #restaura $ra
	addiu $sp, $sp, 4 #desaloca 4 bytes
	jr $ra

printa_PC:
	#prologo
	addiu $sp, $sp -4 #aloca 4 bytes
	sw $ra, 0($sp) #armazena $ra
	
	#corpo do procedimento
	la $t1, PC #$t1 <- endereco de PC
	lw $t1, 0($t1) #$t1 <- valor de PC
	move $a0, $t1 #$a0 <- valor de PC
	jal printa_hexa #printa o PC em hexadecimal
	
	#epilogo
	lw $ra, 0($sp) #armazena $ra
	addiu $sp, $sp 4 #desaloca 4 bytes
	jr $ra

incrementa_PC:
	la $t1, PC #$t1 <- endereco de PC
	lw $t2, 0($t1) #$t2 <- valor de PC
	add $t2, $t2, 4 #$t2 <- PC + 4
	sw $t2, 0($t1) #PC <- PC + 4
	jr $ra
	
#esse procedimento procura no segmento de texto a instrucao que corresponde ao PC e carrega em IR
busca_instrucao:
	#prologo
	addiu $sp, $sp, -20 #aloca 20 bytes
	sw $t1, 0($sp) #armazena $t1
	sw $t2, 4($sp) #armazena $t2
	sw $t3, 8($sp) #armazena $t3
	sw $t4, 12($sp) #armazena $t4
	sw $ra, 16($sp) #armazena $ra

	move $t1, $zero #t1 <- 0
	lui $t1, 0x0040 #carrega a parte superior do numero hexadecimal 0x0040 0000 em $t1
	la $t2, PC #$t2 <- endereco de PC
	la $t3, instrucoes #$t3 <- endereco do segmento de instrucoes
	lw $t4, 0($t2) #$t4 <- valor efetivo de PC
	sub $t4, $t4, $t1 #$t4 <- valor efetivo de PC - 0x0040 0000 = instrucao atual
	add $t4, $t4, $t3 #t$4 <- endereco da instrucao atual
	lw $t4, 0($t4) #$t4 <- instrucao atual
	move $a0, $t4 #$a0 <- instrucao atual
	jal armazena_instrucao_no_IR #IR <- $a0
	
	#epilogo
	lw $t1, 0($sp) #retorna $t1
	lw $t2, 4($sp) #retorna $t2
	lw $t3, 8($sp) #retorna $t3
	lw $t4, 12($sp) #retorna $t4
	lw $ra, 16($sp) #retorna $ra
	addiu $sp, $sp, 20 #desaloca 20 bytes
	jr $ra
	
carrega_endereco_sp_nos_registradores:
	#prologo
	addiu $sp, $sp, -20 #aloca 20 bytes
	sw $t1, 0($sp) #armazena $t1
	sw $t2, 4($sp) #armazena $t2
	sw $t3, 8($sp) #armazena $t3
	sw $t4, 12($sp) #armazena $t4
	sw $ra, 16($sp) #armazena $ra

	#carrega valor da pilha em $t1
	la $t1, SP #$t1 <- endereco SP
	
	#carrega endereco inicial da pilha em $t4
	la $t4, espaco_pilha #$t4 <- endereco base de espaco_pilha
	addiu $t4, $t4, 1024 #$t4 <- endereco base de espaco_pilha + 1024 = topo da pilha
	
	sw $t4, 0($t1) #salva o topo da pilha em SP
	lw $t1, 0($t1) #$t1 <- endereco do topo da pilha
	
	la $t2, registradores #$t2 <- endereco dos registradores
	addiu $t3, $zero, 29 #$t3 <- numero do registrador sp (29)
	sll $t3, $t3, 2 #$t3 <- 29 * 4 = 116 endereco efetivo de sp
	add $t3, $t2, $t3 #$t3 <- endereco base dos registradores + endereco efetivo de sp = endereco do registrador sp
	sw $t1, 0($t3) #registrador sp <- endereco apontado por SP
	
	#epilogo
	lw $t1, 0($sp) #retorna $t1
	lw $t2, 4($sp) #retorna $t2
	lw $t3, 8($sp) #retorna $t3
	lw $t4, 12($sp) #retorna $t4
	lw $ra, 16($sp) #retorna $ra
	addiu $sp, $sp, 20 #desaloca 20 bytes
	jr $ra	

#le instrucao por instrucao e armazena no segmento simulado de texto
#registradores
#$t0 -> endereco do segmento de instrucoes
#pilha
#0($sp) -> $a0
#4($sp) -> $ra
#8($sp) -> $t0
armazena_instrucoes:
	#prologo
	addi $sp, $sp, -12 #abre 12 bytes de espaco na pilha
	sw $a0, 0($sp) #armazena $a0
	sw $ra, 4($sp) #armazena $ra
	sw $t0, 8($sp) #armazena $t0
	
	#corpo do procedimento
	jal abre_arquivo #abre o arquivo de instrucoe
	move $s0, $v0 #move o file descriptor retornado para $s0
	move $t1, $zero #seta o $t1 para zero
armazena_loop:
	move $a0, $s0 #move o file descriptor para o argumento
	jal le_arquivo
	bne $v0, 4, armazena_fim #se $v0 for diferente de 4 vai para o armazena fim
	jal get_buffer_word #pega a instrucao que esta no buffer
	la $t0, instrucoes #pega endereco base das instrucoes
	add $t0, $t0, $t1 #incrementa de acordo com o contador
	sw $v0, 0($t0) #armazena a instrucao na posicao certa
	addi $t1, $t1, 4 #incrementa em 4 o contador
	
	j armazena_loop #vai para o armazena_loop
	
armazena_fim:
	#epilogo
	jal fecha_arquivo
	lw $a0, 0($sp) #restaura $a0
	lw $ra, 4($sp) #restaura $ra
	lw $t0, 8($sp) #restaura $t0
	addi $sp, $sp, 12 #
	jr $ra
	
#$t1 <- contador para pegar o endereco correto inicia em 0
#$s0 <- armazena o file descriptor
armazena_data:
	addiu $sp, $sp, -16 #aloca 16 bytes
	sw $s0, 0($sp) #armazena $s0
	sw $t0, 4($sp) #armazena $t0
	sw $t1, 8($sp) #armazena $t1
	sw $ra, 12($sp) #armazena $ra
	
	jal abre_arquivo_data #$v0 <- file descriptor do arquivo data
	move $a0, $v0 #$a0 <- file descriptor
	move $s0, $a0 #$s0 <- file descriptor
	move $t1, $zero
armazena_loop_data:
	move $a0, $s0 #move o file descriptor para o argumento
	jal le_arquivo_byte_a_byte
	bne $v0, 1, armazena_fim_data #se $v0 for diferente de 1 vai para o armazena fim
	jal get_buffer1 #$v0 <- pega 1 byte lido
	la $t0, espaco_data #pega endereco base das instrucoes
	add $t0, $t0, $t1 #incrementa de acordo com o contador
	sb $v0, 0($t0) #armazena o byte na posicao certa
	addi $t1, $t1, 1 #incrementa em 1 o contador
	j armazena_loop_data #vai para o armazena_loop
	
armazena_fim_data:
	#epilogo
	jal fecha_arquivo
	lw $s0, 0($sp) #restaura $s0
	lw $t0, 4($sp) #restaura $t0
	lw $t1, 8($sp) #restaura $t1
	lw $ra, 12($sp) #restaura $ra
	addi $sp, $sp, 16 #desasloca
	jr $ra
		
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
	jal get_instrucao_do_IR #$V0 <- IR
	move $a0, $v0 #$a0 <- IR instrucao atual
	jal get_instrucao_opcode  #pega o opcode da instrucao contida em $a0
	move $a0, $v0 #seta o opcode em $v0
	jal identifica_instrucao #vai para o procedimento que identifica a instrucao
	
	#epilogo
	lw $a0, 0($sp) #restaura $a0
	lw $ra, 4($sp) #restaura $ra
	lw $s0, 8($sp) #restaura $s0
	addi $sp, $sp, 12 #
	jr $ra
	
identifica_instrucao:
	addi $sp, $sp, -12 #abre espaço na pilha para 12 bytes
	sw $ra, 0($sp) #armazena o $ra na pilha para restaurar posteriormente
	sw $a0, 4($sp) #armazena o registrador de argumento na pilha (instrução)
	sw $a1, 8($sp) #armazena o registrador de argumento na pilha (opcode)
	
	jal get_instrucao_do_IR #$v0 <- instrucao atual
	move $t1, $v0 #seta $t1 para a instrução
	move $t2, $a1 #seta $t2 para o opcode da instrucao
	
	addi $t3, $zero, 0x000c
	
	beq $t1, $t3, syscall_exec #se for syscall vai para syscall
	beq $t2, 9, addiu_exec #se o opcode for 9 vai para a instrução addiu
	beq $t2, 43, sw_exec #se o opcode for 43 vai para instrução sw
	beq $t2, 0, tipo_r_exec #se o opcode for 0 é uma instrução do tipo r e precisa verificar o campo funct
	beq $t2, 3, jal_exec #se o opcode for 2 é uma instrução do tipo jal
	beq $t2, 35, lw_exec #se o opcode for 43 vai para a instrução lw
	beq $t2, 5, bne_exec #se o opcode for 5 vai para a instrução bne
	beq $t2, 8, addi_exec #se o opcode for 5 vai para a instrução addi
	beq $t2, 28, tipo_r_exec #se o opcode for 28 vai para instruções do tipo r
	beq $t2, 2, j_exec #se o opcode for 2 vai para instrução j
	beq $t2, 15, lui_exec #se o opcode for 15 vai para instrução lui
	beq $t2, 13, ori_exec #se o opcode for 13 vai para instrução ori
	j fim_switch

#$t1 <-	rs
#$t2 <-	rt
#$t3 <-	imm
#$t4 <- instrucao	
ori_exec:#ori rt, rs, imm
	#prologo
	addiu $sp, $sp, -16
	sw $t1, 0($sp) 
	sw $t2, 4($sp) 
	sw $t3, 8($sp) 
	sw $t4, 12($sp)  
	
	#carrega instrucao
	jal get_instrucao_do_IR #$v0 <- instrucao atual
	move $t4, $v0 #$t4 <- instrucao atual
	move $a0, $v0 #$a0 <- instrucao atual
	
	#rs
	jal get_rs_tipo_i #$v0 <- rs
	move $t1, $v0 #$t1 <- $v0
	move $a0, $t1 #$a0 <- rs
	jal get_valor_registrador #$v0 <- valor contido do $rs do segmento simulado de registradores
	move $t1, $v0 #$t1 <- valor do registrador rs
	
	#rt
	move $a0, $t4 #$a0 <- instrucao atual
	jal get_rt_tipo_i #$v0 <- rt
	move $t2, $v0 #$t2 <- $v0
	move $a0, $t2 #$a0 <- rt
	jal get_valor_registrador #$v0 <- valor contido do $rt do segmento simulado de registradores
	move $t2, $v0 #$t2 <- valor do registrador rs
	
	#imm
	move $a0, $t4 #$a0 <- instrucao atual
	jal get_imm_tipo_i #$v0 <- imm
	move $t3, $v0 #$t3 <- $v0 / imm
	
	#or rd , rs , rt
	or $t2, $t1, $t3 #$t2 <- or entre $t1 e $t3
	move $a0, $t4 #$a0 <- instrucao
	jal get_rt_tipo_i #$v0 <- rt
	move $a0, $v0 #$a0 <- rt
	move $a1, $t2 #$a1 <- resultado da operacao
	jal set_valor_registrador#armazena o valor no endereco do registrador
	
	#epilogo
	lw $t1, 0($sp) 
	lw $t2, 4($sp) 
	lw $t3, 8($sp) 
	lw $t4, 12($sp)
	addiu $sp, $sp, 16 
	j fim_switch

#$t1 <-	rt
#$t2 <-	imm
#$t3 <-	instrucao
lui_exec: #lui rt imm tipo i
	#prologo
	addiu $sp, $sp, -12
	sw $t1, 0($sp) 
	sw $t2, 4($sp) 
	sw $t3, 8($sp) 
	
	#carrega instrucao
	jal get_instrucao_do_IR #$v0 <- instrucao atual
	move $t3, $v0 #$t3 <- instrucao atual
	move $a0, $v0 #$a0 <- instrucao atual
	
	#rt
	move $a0, $t3 #$a0 <- instrucao
	jal get_rt_tipo_i #$v0 <- rt
	move $t1, $v0 #$t1 <- rt
	
	#imm
	move $a0, $t3 #$a0 <- instrucao
	jal get_imm_tipo_i #$v0 <- imm
	move $a0, $v0 #$a0 <- imm
	add $t4, $t4, $zero #$t4 <- 0
	add $t4, $a0, $t4 #$t4 <- imm 
	sll $t4, $t4, 16 #$t4 <- carrega parte superior do registrador
	
	#salvar valor no rt
	move $a0, $t1 #$a0 <- registrador
	move $a1, $t4 #$a1 <- valor a ser salvo no registrador presente em $a0
	jal set_valor_registrador
	
	#epilogo
	lw $t1, 0($sp) 
	lw $t2, 4($sp) 
	lw $t3, 8($sp) 
	addiu $sp, $sp, 12
	j fim_switch
	
#$t1 <-	rs
#$t2 <-	rt
#$t3 <-	imm
#$t4 <- instrucao
#$t5 <- offset = endereco de rs + imm	
sw_exec:#sw rt, imm(rs)
	#prologo
	addiu $sp, $sp, -20
	sw $t1, 0($sp) 
	sw $t2, 4($sp) 
	sw $t3, 8($sp) 
	sw $t4, 12($sp)
	sw $t5, 16($sp) 
	
	#carrega instrucao
	jal get_instrucao_do_IR #$v0 <- instrucao atual
	move $t4, $v0 #$t4 <- instrucao atual
	move $a0, $v0 #$a0 <- instrucao atual
	
	#rs
	jal get_rs_tipo_i #$v0 <- rs
	move $a0, $v0 #$a0 <- rs
	jal get_valor_registrador #$v0 <- valor dentro do registrador simulado rs
	move $t5, $v0 #$t5 <- conteudo de rs
	
	#imm
	move $a0, $t4 #$a0 <- instrucao
	jal get_imm_tipo_i #$v0 <- imm
	move $a0, $v0 #$a0 <- imm
	jal extende_imm #$v0 <- imm extendido
	addu $t5, $t5, $v0 #$t5 <- imm + conteudo de rs = offset
	
	#rt
	move $a0, $t4 #$a0 <- instrucao
	jal get_rt_tipo_i #$v0 <- rt
	move $a0, $v0 #$a0 <- rt
	jal get_valor_registrador #$v0 <- valor dentro do registrador simulado rt
	move $t2, $v0 #$t2 <- conteudo de rt
	
	sw $t2, 0($t5) #salva o conteudo de rt em imm(rs)
	
	#epilogo
	lw $t1, 0($sp) 
	lw $t2, 4($sp) 
	lw $t3, 8($sp) 
	lw $t4, 12($sp)
	lw $t5, 16($sp)
	addiu $sp, $sp, 20 
	j fim_switch
	 
#$t1 <-	rs
#$t2 <-	rt
#$t3 <-	imm
#$t4 <- instrucao
addiu_exec:
	#addiu rt, rs, imm
	#prologo
	addiu $sp, $sp, -16
	sw $t1, 0($sp) 
	sw $t2, 4($sp) 
	sw $t3, 8($sp) 
	sw $t4, 12($sp) 
	
	#carrega instrucao
	jal get_instrucao_do_IR #$v0 <- instrucao atual
	move $t4, $v0 #$t4 <- instrucao atual
	move $a0, $v0 #$a0 <- instrucao atual
	
	#rs
	jal get_rs_tipo_i #$v0 <- rs
	move $t1, $v0 #$t1 <- $v0
	move $a0, $t1 #$a0 <- rs
	jal get_valor_registrador #$v0 <- valor contido do $rs do segmento simulado de registradores
	move $t1, $v0 #$t1 <- valor do registrador rs
	
	#rt
	move $a0, $t4 #$a0 <- instrucao atual
	jal get_rt_tipo_i #$v0 <- rt
	move $t2, $v0 #$t2 <- $v0
	move $a0, $t2 #$a0 <- rt
	jal get_valor_registrador #$v0 <- valor contido do $rt do segmento simulado de registradores
	move $t2, $v0 #$t2 <- valor do registrador rs
	
	#imm
	move $a0, $t4 #$a0 <- instrucao atual
	jal get_imm_tipo_i #$v0 <- imm
	move $a0, $v0 #$a0 <- imm 
	jal extende_imm #procedimento para extender o numero
	move $t3, $v0 #$t3 <- $v0
	
	#soma rt , rs , imm
	addu $t2, $t1, $t3 #soma o valor de $t1 com imm e armazena em $t2
	move $a0, $t4 #$a0 <- instrucao
	jal get_rt_tipo_i #$v0 <- rt
	move $a0, $v0 #$a0 <- rt
	move $a1, $t2 #$a1 <- resultado da operacao
	
	jal set_valor_registrador#armazena o valor no endereco do registrador
	
	#epilogo
	lw $t1, 0($sp) 
	lw $t2, 4($sp) 
	lw $t3, 8($sp) 
	lw $t4, 12($sp)
	addiu $sp, $sp, 16 
	j fim_switch
	
tipo_r_exec:
	jal get_instrucao_do_IR #$v0 <- instrucao atual
	move $a0, $v0 #$a0 <- instrucao atual
	jal get_funct_tipo_r #pega qual o campo funct e coloca em $v0
	lw $a0, 4($sp) #restaura instrucao no $a0
	beq $v0, 32, add_exec #se o campo funct for igual a 32 vai para add_exec
	beq $v0, 33, addu_exec #se o campo funct for igual a 33 vai para addu_exec
	beq $v0, 2, mul_exec #se o campo funct for igual a 2 vai para mul_exec
	beq $v0, 8, jr_exec #se o campo funct for igual a 8 vai para jr_exec
	j fim_switch
	
#$t1 <-	rs
#$t2 <-	rt
#$t3 <-	rd
#$t4 <- instrucao	
addu_exec: #addu rd, rs, rt
	#prologo
	addiu $sp, $sp, -16
	sw $t1, 0($sp) 
	sw $t2, 4($sp) 
	sw $t3, 8($sp) 
	sw $t4, 12($sp) 
	
	#carrega instrucao
	jal get_instrucao_do_IR #$v0 <- instrucao atual
	move $t4, $v0 #$t4 <- instrucao atual
	move $a0, $v0 #$a0 <- instrucao atual
	
	#rs
	jal get_rs_tipo_r #$v0 <- rs
	move $t1, $v0 #$t1 <- $v0
	move $a0, $t1 #$a0 <- rs
	jal get_valor_registrador #$v0 <- valor contido do $rs do segmento simulado de registradores
	move $t1, $v0 #$t1 <- valor do registrador rs
	
	#rt
	move $a0, $t4 #$a0 <- instrucao atual
	jal get_rt_tipo_r #$v0 <- rt
	move $t2, $v0 #$t2 <- $v0
	move $a0, $t2 #$a0 <- rs
	jal get_valor_registrador #$v0 <- valor contido do $rt do segmento simulado de registradores
	move $t2, $v0 #$t2 <- valor do registrador rt
	
	#rd
	move $a0, $t4 #$a0 <- instrucao atual
	jal get_rd_tipo_r #$v0 <- rd
	move $t3, $v0 #$t3 <- registrador 
	
	#faz a soma e armazena em $t4
	addu $t4, $t1, $t2 #$t4 <- $t2 + $t1 (rs + rt)
	move $a1, $t4 #$a1 <- resultado da soma
	move $a0, $t3 #$a0 <- numero do registrador de destino da soma
	jal set_valor_registrador
	
	#epilogo
	lw $t1, 0($sp) 
	lw $t2, 4($sp) 
	lw $t3, 8($sp) 
	lw $t4, 12($sp)
	addiu $sp, $sp, 16 
	j fim_switch
	
#$t1 <-	rs
#$t2 <-	rt
#$t3 <-	rd
#$t4 <- instrucao
add_exec:#add rd, rs, rt 
	#prologo
	addiu $sp, $sp, -16
	sw $t1, 0($sp) 
	sw $t2, 4($sp) 
	sw $t3, 8($sp) 
	sw $t4, 12($sp) 
	
	#carrega instrucao
	jal get_instrucao_do_IR #$v0 <- instrucao atual
	move $t4, $v0 #$t4 <- instrucao atual
	move $a0, $v0 #$a0 <- instrucao atual
	
	#rs
	jal get_rs_tipo_r #$v0 <- rs
	move $t1, $v0 #$t1 <- $v0
	move $a0, $t1 #$a0 <- rs
	jal get_valor_registrador #$v0 <- valor contido do $rs do segmento simulado de registradores
	move $t1, $v0 #$t1 <- valor do registrador rs
	
	#rt
	move $a0, $t4 #$a0 <- instrucao atual
	jal get_rt_tipo_r #$v0 <- rt
	move $t2, $v0 #$t2 <- $v0
	move $a0, $t2 #$a0 <- rs
	jal get_valor_registrador #$v0 <- valor contido do $rt do segmento simulado de registradores
	move $t2, $v0 #$t2 <- valor do registrador rt
	
	#rd
	move $a0, $t4 #$a0 <- instrucao atual
	jal get_rd_tipo_r #$v0 <- rd
	move $t3, $v0 #$t3 <- registrador 
	
	#faz a soma e armazena em $t4
	add $t4, $t1, $t2 #$t4 <- $t2 + $t1 (rs + rt)
	move $a1, $t4 #$a1 <- resultado da soma
	move $a0, $t3 #$a0 <- numero do registrador de destino da soma
	jal set_valor_registrador
	
	#epilogo
	lw $t1, 0($sp) 
	lw $t2, 4($sp) 
	lw $t3, 8($sp) 
	lw $t4, 12($sp)
	addiu $sp, $sp, 16 
	j fim_switch

#$t1 <- endereco de PC
#$t2 <- registrador $ra
#$t4 <- instrucao atual
jr_exec: #jr rs tipo r
	#prologo
	addiu $sp, $sp, -16
	sw $t1, 0($sp) 
	sw $t2, 4($sp) 
	sw $t3, 8($sp) 
	sw $t4, 12($sp)
	
	#carrega endereco no registrador 
	la $t1, PC #$t1 <- endereco de PC
	
	#rs
	jal get_instrucao_do_IR #$v0 <- instrucao atual
	move $t4, $v0 #$t4 <- instrucao atual
	move $a0, $v0 #$a0 <- instrucao atual
	jal get_rs_tipo_r #$v0 <- registrador rs
	move $a0, $v0 #$a0 <- registrador rs
	jal get_valor_registrador #$v0 <- valor contido no registrador rs
	
	#salva endereco do rs em PC
	sub $v0, $v0, 4 #subtrai 4 pois PC sera incrementado no loop faca do procedimento main
	sw $v0, 0($t1) #PC <- endereco contido em rs
	
	#epilogo
	lw $t1, 0($sp) 
	lw $t2, 4($sp) 
	lw $t3, 8($sp) 
	lw $t4, 12($sp)
	addiu $sp, $sp, 16 
	j fim_switch
	
#$t1 <-	rs
#$t2 <-	rt
#$t3 <-	rd
#$t4 <- instrucao
mul_exec: #mul rd, rs, rt tipo r
	#prologo
	addiu $sp, $sp, -16
	sw $t1, 0($sp) 
	sw $t2, 4($sp) 
	sw $t3, 8($sp) 
	sw $t4, 12($sp)
	
	#carrega instrucao
	jal get_instrucao_do_IR #$v0 <- instrucao atual
	move $t4, $v0 #$t4 <- instrucao atual
	move $a0, $v0 #$a0 <- instrucao atual
	
	#rs
	jal get_rs_tipo_r #$v0 <- rs
	move $t1, $v0 #$t1 <- $v0
	move $a0, $t1 #$a0 <- rs
	jal get_valor_registrador #$v0 <- valor contido do $rs do segmento simulado de registradores
	move $t1, $v0 #$t1 <- valor do registrador rs
	
	#rt
	move $a0, $t4 #$a0 <- instrucao atual
	jal get_rt_tipo_r #$v0 <- rt
	move $t2, $v0 #$t2 <- $v0
	move $a0, $t2 #$a0 <- rs
	jal get_valor_registrador #$v0 <- valor contido do $rt do segmento simulado de registradores
	move $t2, $v0 #$t2 <- valor do registrador rt
	
	#rd
	move $a0, $t4 #$a0 <- instrucao atual
	jal get_rd_tipo_r #$v0 <- rd
	move $t3, $v0 #$t3 <- registrador 
	
	#faz a multiplicacao e armazena em $t4
	mul $t4, $t1, $t2 #$t4 <- $t2 * $t1 (rs * rt)
	move $a1, $t4 #$a1 <- resultado da multiplicacao
	move $a0, $t3 #$a0 <- numero do registrador de destino da multiplicacao
	jal set_valor_registrador
	
	#epilogo
	lw $t1, 0($sp) 
	lw $t2, 4($sp) 
	lw $t3, 8($sp) 
	lw $t4, 12($sp)
	addiu $sp, $sp, 16 
	j fim_switch
	
	
#$t1 <- endereco PC
#$t2 <- registrador ficticio ra
#$t3 <- valor de PC
#$t4 <- target 
jal_exec: #jal target
	#prologo
	addiu $sp, $sp, -16
	sw $t1, 0($sp) 
	sw $t2, 4($sp) 
	sw $t3, 8($sp) 
	sw $t4, 12($sp) 
	
	la $t1, PC #$t1 <- endereco base de PC
	lw $t3, 0($t1) #$t3 <- valor da variavel global PC
	addiu $t2, $zero, 31 #$t2 <- 31 que corresponde ao registrador $ra
	addi $t3, $t3, 4 #incrementa o valor de PC em 4
	
	move $a1, $t3 #$a1 <- PC + 4
	move $a0, $t2 #$a0 <- 31
	jal set_valor_registrador #registrador ficticio 31 ($ra) = PC + 4
	
	jal get_instrucao_do_IR #$v0 <- instrucao atual
	move $a0, $v0 #$a0 <- instrucao atual
	jal get_target_tipo_j #$v0 <- target da instrucao jal 
	move $t4, $v0 #$t4 <- target
	
	#salva target no PC
	sub $t4, $t4, 4 #$t4 <- target - 4. Decrementa pois apos sair do switch o PC sera incrementado em 4 fazendo com que o endereco fique correto para a proxima interacao
	sw $t4, 0($t1) #PC <- target - 4
	
	#epilogo
	lw $t1, 0($sp) 
	lw $t2, 4($sp) 
	lw $t3, 8($sp) 
	lw $t4, 12($sp)
	addiu $sp, $sp, 16 
	j fim_switch

#$t1 <- rs
#$t2 <- rt
#$t3 <- label
#$t4 <- instrucao atual
bne_exec:#bne rs, rt, label #desvia para o numero de instrucoes se rs nao for igual a rt
	#1 pega rs
	#2 pega rt
	#3 compara rt e rs
	#4 se nao for igual desvia para label que incrementa o PC de acordo com a label
	#prologo
	addiu $sp, $sp, -16
	sw $t1, 0($sp) 
	sw $t2, 4($sp) 
	sw $t3, 8($sp) 
	sw $t4, 12($sp) 
	
	#carrega instrucao do IR
	jal get_instrucao_do_IR #$v0 <- instrucao atual
	move $a0, $v0 #$a0 <- instrucao atual
	move $t4, $v0 #$t4 <- instrucao atual
	
	#rs
	jal get_rs_tipo_i #$v0 <- rs
	move $t1, $v0 #$t1 <- valor que representa rs
	move $a0, $t1 #$a0 <- rs
	jal get_valor_registrador #$v0 <- valor contido do $rs do segmento simulado de registradores
	move $t1, $v0 #$t1 <- valor do registrador rs
	
	#rt
	move $a0, $t4 #$a0 <- instrucao atual
	jal get_rt_tipo_i #$v0 <- rt
	move $t2, $v0 #$t2 <- $v0
	move $a0, $t2 #$a0 <- rt
	jal get_valor_registrador #$v0 <- valor contido do $rt do segmento simulado de registradores
	move $t2, $v0 #$t2 <- valor do registrador rs
	
	#label
	move $a0, $t4 #$a0 <- instrucao atual
	jal get_imm_tipo_i #$v0 <- label
	move $t3, $v0 #$t3 <- label
	
	#faz comparacao para alterar PC
	bne $t1, $t2, altera_PC #se $t1 for diferente de $t2 vai para altera_PC
	j fim_bne #vai para fim e nao altera o PC 
altera_PC:	
	la $t1, PC #$t1 <- endereco de PC
	lw $t2, 0($t1) #$t2 <- valor de PC
	sll $t3, $t3, 2 #multiplica o target por 4 e armazena em $t3
	add $t3, $t3, $t2, #$t3 <- valor de PC + label * 4
	sw $t3, 0($t1) #PC += label * 4
fim_bne:
	#epilogo
	lw $t1, 0($sp) 
	lw $t2, 4($sp) 
	lw $t3, 8($sp) 
	lw $t4, 12($sp)
	addiu $sp, $sp, 16 
	j fim_switch
	
addi_exec: #addi rt, rs, imm
	#prologo
	addiu $sp, $sp, -16
	sw $t1, 0($sp) 
	sw $t2, 4($sp) 
	sw $t3, 8($sp) 
	sw $t4, 12($sp) 
	
	#carrega instrucao
	jal get_instrucao_do_IR #$v0 <- instrucao atual
	move $t4, $v0 #$t4 <- instrucao atual
	move $a0, $v0 #$a0 <- instrucao atual
	
	#rs
	jal get_rs_tipo_i #$v0 <- rs
	move $t1, $v0 #$t1 <- $v0
	move $a0, $t1 #$a0 <- rs
	jal get_valor_registrador #$v0 <- valor contido do $rs do segmento simulado de registradores
	move $t1, $v0 #$t1 <- valor do registrador rs
	
	#rt
	move $a0, $t4 #$a0 <- instrucao atual
	jal get_rt_tipo_i #$v0 <- rt
	move $t2, $v0 #$t2 <- $v0
	move $a0, $t2 #$a0 <- rt
	jal get_valor_registrador #$v0 <- valor contido do $rt do segmento simulado de registradores
	move $t2, $v0 #$t2 <- valor do registrador rs
	
	#imm
	move $a0, $t4 #$a0 <- instrucao atual
	jal get_imm_tipo_i #$v0 <- imm
	move $a0, $v0 #$a0 <- imm 
	jal extende_imm #procedimento para extender o numero
	move $t3, $v0 #$t3 <- $v0
	
	#soma rt , rs , imm
	add $t2, $t1, $t3 #soma o valor de $t1 com imm e armazena em $t2
	move $a0, $t4 #$a0 <- instrucao
	jal get_rt_tipo_i #$v0 <- rt
	move $a0, $v0 #$a0 <- rt
	move $a1, $t2 #$a1 <- resultado da operacao
	
	jal set_valor_registrador#armazena o valor no endereco do registrador
	
	#epilogo
	lw $t1, 0($sp) 
	lw $t2, 4($sp) 
	lw $t3, 8($sp) 
	lw $t4, 12($sp)
	addiu $sp, $sp, 16 
	j fim_switch
	
#registradores
#$t1 <- rs
#$t2 <- rt
#$t3 <- endereco
#$t4 <- instrucao atual	
lw_exec: #lw rt, endereco, endereco = offset + valor do rs
	#prologo
	addiu $sp, $sp, -16
	sw $t1, 0($sp) 
	sw $t2, 4($sp) 
	sw $t3, 8($sp) 
	sw $t4, 12($sp)
	
	#carrega instrucao
	jal get_instrucao_do_IR #$v0 <- instrucao atual
	move $t4, $v0 #$t4 <- instrucao atual
	move $a0, $v0 #$a0 <- instrucao atual
	
	#rs
	jal get_rs_tipo_i #$v0 <- rs
	move $a0, $v0 #$a0 <- rs
	jal get_valor_registrador #$v0 <- valor dentro do registrador simulado rs
	move $t1, $v0 #$t1 <- conteudo de rs
	
	#imm
	move $a0, $t4 #$a0 <- instrucao
	jal get_imm_tipo_i #$v0 <- imm
	move $a0, $v0 #$a0 <- imm
	jal extende_imm #$v0 <- imm extendido
	move $t3, $v0 #$t3 <- imm extendido
	add $t3, $t3, $t1 #$t3 <- endereco dentro de rs + offset = endereco
	
	#rt
	move $a0, $t4 #$a0 <- instrucao
	jal get_rt_tipo_i #$v0 <- rt
	move $a0, $v0 #$a0 <- rt
	
	#carrega valor em $t5
	lw $t5, 0($t3) #$t5 <- valor do lw do endereco simulado
	move $a1, $t5 #$a1 <- valor a ser colocado no registrador rt
	jal set_valor_registrador 
	
	#epilogo
	lw $t1, 0($sp) 
	lw $t2, 4($sp) 
	lw $t3, 8($sp) 
	lw $t4, 12($sp)
	addiu $sp, $sp, 16 
	j fim_switch	
	
#$t1 <- endereco PC
#$t4 <- endereco para pular
j_exec:
	#prologo
	addiu $sp, $sp, -8
	sw $t1, 0($sp) 
	sw $t4, 4($sp) 
	
	la $t1, PC #$t1 <- endereco base de PC
	
	#label
	jal get_instrucao_do_IR #$v0 <- instrucao atual
	move $a0, $v0 #$a0 <- instrucao atual
	jal get_target_tipo_j #$v0 <- target da instrucao jal 
	move $t4, $v0 #$t4 <- target
	
	#salva target no PC
	sub $t4, $t4, 4 #$t4 <- target - 4. Decrementa pois apos sair do switch o PC sera incrementado em 4 fazendo com que o endereco fique correto para a proxima interacao
	sw $t4, 0($t1) #PC <- target - 4
	
	#epilogo
	lw $t1, 0($sp) 
	lw $t4, 4($sp) 
	addiu $sp, $sp, 8 
	j fim_switch

syscall_exec:
	addi $a0, $zero, 2 #$a0 <- 2 representa registrador $v0
	jal get_valor_registrador #$v0 <- valor presente no registrador simulado $v0
	beq $v0, 1, sys_print_int #se $v0 == 1 deve fazer a chamada para printar um inteiro
	beq $v0, 17, sys_exit2 #se $v0 == 17 deve fazer a chamada para finalizar o programa
	beq $v0, 4, sys_print_string #se $v0 == 4 deve fazer a chamada para printar uma string
	#beq $v0, 11, sys_print_char #se $v0 == 11 deve fazer a chamada para printar um caracter
	j fim_switch
	
sys_print_string:
	jal printa_linha_vazia
	addi $a0, $zero, 4 #$a0 <- 4 que representa o registrador simulado $a0
	jal get_valor_registrador #$v0 <- valor contido no registrador simulado $a0 == vai ser um endereco
	move $a0, $v0 #$a0 <- endereco contido no registrador simulado $a0
	jal get_endereco_data #$v0 <- endereco do segmento de data simulado que contem a string
	move $a0, $v0 #$a0 <- endereco do segmento de data simulado que contem a string
	li $v0, 4 #chamada para printar string
	syscall
	jal printa_linha_vazia
	j fim_switch
	
sys_exit2:
	addi $a0, $zero, 4 #$a0 <- 4 que representa o registrador simulado $a0
	jal get_valor_registrador #$v0 <- valor contido no registrador simulado $a0
	move $a0, $v0 #$a0 <- valor dentro do registrador simulado $a0
	li $v0, 17 #$v0 <- int que representa chamada para finalizar o programa
	syscall #finaliza o programa
	j fim_switch
	
sys_print_int:
	jal printa_linha_vazia
	addi $a0, $zero, 4 #$a0 <- 4 que representa o registrador simulado $a0
	jal get_valor_registrador #$v0 <- valor contido no registrador simulado $a0
	move $a0, $v0 #$a0 <- valor dentro do registrador simulado $a0
	li $v0, 1 #chamada para printar inteiro
	syscall
	jal printa_linha_vazia
	j fim_switch

fim_switch:
	lw $ra, 0($sp) #restaura o $ra para voltar a funcao certa
	lw $a0, 4($sp) #restaura o registrador de argumento
	lw $a1, 8($sp) #restaura o registrador de argumento
	
	addi $sp, $sp 12 #restaura pilha
	jr $ra
	
armazena_instrucao_no_IR:
	#prologo
	addi $sp, $sp, -8 #aloca 8 bytes
	sw $t1, 0($sp) #salva $t1
	sw $ra, 4($sp) #salva $ra
	
	la $t1, IR #carrega endereco
	sw $a0, 0($t1) #armazena em IR
	
	#epilogo
	lw $t1, 0($sp) #retorna $t1
	lw $ra, 4($sp) #retorna $ra
	addi $sp, $sp, 8 #desaloca 8 bytes
	jr $ra
	
#recebe o valor que representa o registrador em $a0	
get_endereco_registrador:
	#prologo
	addi $sp, $sp, -8 #aloca 8 bytes
	sw $t0, 0($sp) #armazena $t0
	sw $ra, 4($sp) #armazena $ra
	
	la $t0, registradores #$t0 <- endereco base dos registradores
	sll $a0, $a0, 2 #valor que representa o registrador * 4 = posicao no vetor de registradores
	add $v0, $a0, $t0 #$v0 <- endereco base dos registradores + posicao = registradores[posicao]
	
	#epilogo
	lw $t0, 0($sp) #restaura $t0
	lw $ra, 4($sp) #restaura $ra
	addi $sp, $sp, 8 #desaloca 8 bytes
	jr $ra
	
#$a0 <- recebe qual o registrador a ser procurado o valor
get_valor_registrador:
	addiu $sp, $sp -4 #aloca 4 bytes
	sw $ra, 0($sp) #armazena $ra
	
	jal get_endereco_registrador #$v0 <- endereco do registrador procurado
	lw $v0, 0($v0) #$v0 <- valor contido no registrador
	
	lw $ra, 0($sp) #restaura $ra
	addiu $sp, $sp, 4 #desaloca 4 bytes
	jr $ra

#a0 <- valor que representa o registrador 
#a1 <- valor a ser salvo
set_valor_registrador:
	addiu $sp, $sp -4 #aloca 4 bytes
	sw $ra, 0($sp) #armazena $ra
	
	jal get_endereco_registrador #$v0 <- endereco do registrador procurado
	sw $a1, 0($v0) #salva o valor no registrador
	
	lw $ra, 0($sp) #restaura $ra
	addiu $sp, $sp, 4 #desaloca 4 bytes
	jr $ra

#$t0 <- endereco solicitado
#$t2 <- 0x1001 0000
#$t1 <- endereco inical do espaco_data
get_endereco_data:
	#prologo
	addiu $sp, $sp, -12 #aloca 12 bytes
	sw $t0, 0($sp) #armazena $t0
	sw $t2, 4($sp) #armazena $t2
	sw $t1, 8($sp) #armazena $t1
	
	#corpo
        move $t0, $a0 #0x10018cd por exemplo
        lui $t2, 0x1001 #$t2 <- endereco inicial do segmento de data 0x1010 0000
        sub $t2, $t0, $t2 #$t2 <- endereco buscado - endereco de data inicial = posicao no vetor simulado do espaco_data
        la $t1, espaco_data #$t1 <- espaco_data
        add $v0, $t1, $t2 #$v0 <- espaco_data[endereco solicitado]
        
        #epilogo
        lw $t0, 0($sp) #restaura $t0
	lw $t2, 4($sp) #restaura $t2
	lw $t1, 8($sp) #restaura $t1
	addiu $sp, $sp, 12 #desaloca 12 bytes
	jr $ra

get_instrucao_do_IR:
	#prologo
	addi $sp, $sp, -8 #aloca 8 bytes
	sw $t1, 0($sp) #salva $t1
	sw $ra, 4($sp) #salva $ra
	
	la $t1, IR #carrega endereco
	lw $v0, 0($t1) #retorna instrucao
	
	#epilogo
	lw $t1, 0($sp) #retorna $t1
	lw $ra, 4($sp) #retorna $ra
	addi $sp, $sp, 8 #desaloca 8 bytes
	jr $ra

#$a0 <- recebe imm para ser extendido	
extende_imm:
	#prologo
	addi $sp, $sp, -12 #aloca 12 bytes
	sw $t1, 0($sp) #salva $t1
	sw $ra, 4($sp) #salva $ra
	sw $t0, 8($sp) #salva $t0
	
	srl $t0, $a0, 15 #shift right para pegar o msb
	beq $t0, 1, negativo #se $t0 for igual a 1 significa que eh um numero negativo que precisa ser extendido com 1
	j fim
negativo:
	lui $t1, 0xffff #preenche o numero com 1111
	or $a0, $a0, $t1 #faz or para extender o sinal
fim:	
	move $v0, $a0 #$v0 <- numero extendido
	
	lw $t1, 0($sp) #retorna $t1
	lw $ra, 4($sp) #retorna $ra
	lw $t0, 8($sp) #salva $t0
	addi $sp, $sp, 12 #desaloca 12 bytes
	jr $ra	
	
.data
registradores: .space 128 #32 registradores * 4 bytes cada
SP: .word 0x7FFFFFFC #a pilha "cresce" para baixo portanto começa no maior endereço possível
IR: .word 0 #instruction register
instrucoes: .space 2048 #limite de 512 instrucoes
PC: .word 0x00400000 #Program counter começa apontando para esse endereço
espaco_pilha: .space 1024 #limite na pilha de 1024 bytes
espaco_data: .space 1024 #limite de dados no segmento de data simulado de 1024 bytes

