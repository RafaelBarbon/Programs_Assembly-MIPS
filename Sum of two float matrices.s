#Rafael Silva Barbon 19243633
.data
msg1: .asciiz "\nInsira a matriz (4x4):"
msgx: .asciiz "\nMatriz X:\n"
msgy: .asciiz "\nMatriz Y:\n"
msgz: .asciiz "\nMatriz Z:\n"
space: .asciiz " "
Nline: .asciiz "\n"
x: .float 0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0
y: .float 0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0
z: .float 0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0
.text
.globl main
main:
	##_MATRIZ_X## 
	li $v0, 4
	la $a0, msgx
	syscall

	#Zerando o valor de i(s0) j(s1) 
	move $s0, $zero
	move $s1, $zero
	la $s4, x #Passando a matriz x como parametro para função de leitura em s4

	jal LE

	li $v0, 4
	la $a0, msgx
	syscall

	#Função imprime matriz em s4 como parametro 
	la $s4, x
	move $s0, $zero
	move $s1, $zero

	jal IMPRIME

	##_MATRIZ_Y###
	li $v0, 4
	la $a0, msgy
	syscall
	
	la $s4, y #Passando a matriz y como parametro para função de leitura em s4
	#Zerando o valor de x(s0) e y(s1) 
	move $s0, $zero
	move $s1, $zero

	jal LE

	li $v0, 4
	la $a0, msgy
	syscall

	#Função imprime matriz em s4 como parametro 
	la $s4, y
	move $s0, $zero
	move $s1, $zero

	jal IMPRIME

	move $s0, $zero 
	move $s1, $zero 

	#Copiando os endereços das matrizes para realização da soma dos elementos de x e y
	la $a0, x
	la $a1, y
	la $a2, z

	jal SOMAELEM #Soma x[i][j] + y[i][j] e armazena em z[i][j]

	###Impressão das matrizes 
	li $v0, 4
	la $a0, msgx
	syscall

	#Função imprime matriz em s4 como parametro 
	la $s4, x
	move $s0, $zero
	move $s1, $zero

	jal IMPRIME

	li $v0, 4
	la $a0, msgy
	syscall

	#Função imprime matriz em s4 como parametro 
	la $s4, y
	move $s0, $zero
	move $s1, $zero

	jal IMPRIME

	li $v0, 4
	la $a0, msgz
	syscall

	#Função imprime matriz em s4 como parametro 
	la $s4, z
	move $s0, $zero
	move $s1, $zero

	jal IMPRIME

	Fim:
		li $v0,10
		syscall

#Funções de LEITURA da matriz em $s4 
LE:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	LOOP:
		li $v0, 4
		la $a0, msg1
		syscall

		li $v0, 6
		syscall #Leu o numero float
		
		#Jogar o numero lindo na matriz_($t3)  
		s.s $f0, 0($s4) 

		#Trabalhar com i e j 
		jal INCPOS #Incrementa na posição da matriz i(s0) e j(s1)

		jal CALCULA #Retorna o end de acesso da matriz_ de acordo com i($s0) j($s1)  em $s4
	  
		beq $s0, 4, Fiml
		j LOOP

	Fiml:
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra

#Função IMPRIME matriz em $s4
IMPRIME:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	add $t2, $zero, $zero #Contador k 

	inicia: 
		li $v0, 2
		l.s $f12, 0($s4)
		syscall

		li $v0, 4
		la $a0, space #Imprime um espaço 
		syscall

		#Calculando o i e o end de retorno 
		jal INCPOS

		#Se j = 0 pula linha 
		beq $s1, $zero, PULALINHA 

	RETPL: #Retorno do pula linha 
		jal CALCULA

		beq $t2, 15, FIMM #Já printou os 16 elementos 
		addi $t2, $t2, 1
		j inicia

	PULALINHA:
		li $v0, 4
		la $a0, Nline 
		syscall 
		j RETPL 

	FIMM:
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra

##
##Funções auxiliares ao acesso da matriz 
##

##Função que calcula quantos bytes somar no end 0 da matriz de acordo com i e j, Retorna o end de acesso do vetor(Matriz) em s4 
CALCULA: #Acessa i e o j em s0 e s1
#i é a e cada linha soma 16
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	move $t5, $s0 #i
	move $t6, $s1 #j
	add $t9, $s1, $s0 

	beq $t9, $zero, FIMS # Se for 0 e 0 não adiociona nada no endereço inicial 

	move $t0, $zero 

	SOMAJ:
		beq $t6, $zero, SOMAI #j=0 jump SOMAI

		addi $t0, $t0, 4 #Uma COLUNA
		addi $t6, $t6, -1 #Dec j 

		j SOMAJ
	SOMAI:
		beq $t5, $zero, FIMS

		addi $t0,$t0,16 #Uma linha
		addi $t5, $t5, -1 #Dec i 

		j SOMAI   
	FIMS:
		add $s4, $s4, $t0
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra

##Função que incrementa i(s0) e j(s1)
INCPOS: #(i=s0, j=s1)
	addi $sp, $sp, -4
	sw $ra, 0($sp) 
	
	addi $s1, $s1, 1 
	beq $s1, 4, INCL
	j FIMI
	INCL:
		move $s1, $zero #Zera a coluna 
		addi $s0, $s0, 1 #Adiciona um na linha 
	FIMI:
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra 

SOMAELEM:#Função que soma X[i][j](a0) e Y[i][j](a1) e guarda em z[i][j](a2)
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	#Cópia dos parâmetros pra reg temporários 
	add $t6, $zero, $a0
	add $t7, $zero, $a1
	add $t8, $zero, $a2
	add $s0, $zero, $zero
	add $s1, $zero, $zero 

loopi:
	move $s1,$zero

	beq $s0, 64, sai
	loopj:
		#Realizando a adição nos endereços das matrizes para realizar o acesso na posição desejada 
		add $t6, $t6, $s0 
		add $t6, $t6, $s1
		add $t7, $t7, $s0
		add $t7, $t7, $s1
		add $t8, $t8, $s0
		add $t8, $t8, $s1

		l.s $f1, 0($t6) #Le x[i][j]
		l.s $f2, 0($t7)#Le y[i][j]

		add.s $f3, $f2, $f1#Realiza a adição e em seguida carrega em z[i][j]

		s.s $f3, 0($t8)

	addi $s1,$s1, 4 #Coluna soma 4
	beq $s1, 16, sai2
	j loopj 

sai2:
	addi $s0, $s0, 16 #Linha soma 16 
	j loopi

sai:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra