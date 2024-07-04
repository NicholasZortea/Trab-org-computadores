#O objetivo deste arquivo é conter somente procedimentos FOLHA que printam alguma coisa na tela.

.text
.globl printa_linha_vazia
.globl printa_tab
.globl printa_string
.globl printa_inteiro
.globl printa_caracter
.globl printa_virgula_espaco
printa_linha_vazia:
	#prologo
	addiu $sp, $sp, -12
	sw $a0, 0($sp)
	sw $v0, 4($sp)
	sw $ra, 8($sp)
	
	li $a0, '\n' #carrega caracter especial de quebra de linha
	li $v0, 11 #carrega serviço para printar caracter
	syscall #faz chamada ao sistema
	
	#epilogo
	lw $a0, 0($sp)
	lw $v0, 4($sp)
	lw $ra, 8($sp)
	addiu $sp, $sp, 12
	jr $ra #retorna para metodo chamador

printa_tab:
	li $v0, 11 #carrega serviço para printar caracter
	li $a0, '\t' #carrega tab no argumento
	syscall #faz chamada ao sistema
	jr $ra #retorna para metodo chamador
	
#ja recebe o endereco da string no $a0
printa_string:
	li $v0, 4 #carrega serviço para printar string
	syscall #faz chamada ao sistema
	jr $ra #retorna para metodo chamador

#ja recebe o inteiro a ser printado no $a0
printa_inteiro:
	li $v0, 1 #carrega serviço para printar inteiro
	syscall #faz chamada ao sistema
	jr $ra #retorna para metodo chamador
	
printa_caracter:
	li $v0, 11 #servico para printar caracter
	syscall #faz chamada ao sistema
	jr $ra #retorna para metodo chamador
	
#procedimento folha que printa uma vírgula seguida de um espaço	
printa_virgula_espaco:
	li $a0, ','
	li $v0, 11
	syscall
	li $a0, ' '
	syscall
	jr $ra
