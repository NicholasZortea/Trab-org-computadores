
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
#################

decodifica:
	addi $sp, $sp, -16 #abre 12 bytes para armazenar os registradores na pilha
	sw $ra, 0($sp) #armazena o $ra na pilha para restaurar posteriormente
	sw $s1, 4($sp) #armazena o $s1 na pilha para restaurar posteriormente
	sw $s2, 8($sp) #armazena o $s2 na pilha para restaurar posteriormente
	sw $a0, 12($sp)
	
	move $s1, $a0 #move a instrução do argumento para $s1
	jal get_instrucao_opcode #vai para procedimento para pegar o opcode da instrução
	move $s2, $v0 #move o opcode da instrução para $s2

	move $a0, $s1 #move a instrução para o registrador de argumento $a0
	move $a1, $s2 #move o opcode da instrução para o registrador de argumento $a1
	jal identifica_instrucao
	
	lw $ra, 0($sp) #restaura o $ra
	lw $s1, 4($sp) #restaura o $s1
	lw $s2, 8($sp) #restaura o $s2
	lw $a0, 12($sp)
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
	addi $sp, $sp, -8
	sw $ra, 0($sp) #armazena o $ra na pilha para restaurar posteriormente
	sw $a0, 4($sp)
	
	move $t1, $a0 #seta $t1 para a instrução
	move $t2, $a1 #seta $t2 para o opcode da instrucao
	
	beq $t2, 9, addiu_label #se o opcode for 9 vai para a instrução addi
	
	j fim_switch
	
addiu_label:
	#la $a0, addiu_str
	#li $v0, 4
	#syscall
	j fim_switch
	
	
	
fim_switch:
	lw $ra, 0($sp) #restaura o $ra para voltar a funcao certa
	lw $a0, 4($sp)
	addi $sp, $sp 8 #restaura pilha
	jr $ra
	
.data
#addiu_str: .asciiz "addiu "
