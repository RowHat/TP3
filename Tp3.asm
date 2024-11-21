.data
slist: .word 0
cclist: .word 0
wclist: .word 0
schedv: .space 32
menu: .ascii "Colecciones de objetos categorizados\n"
 .ascii "====================================\n"
 .ascii "1-Nueva categoria\n"
 .ascii "2-Siguiente categoria\n"
 .ascii "3-Categoria anterior\n"
 .ascii "4-Listar categorias\n"
 .ascii "5-Borrar categoria actual\n"
 .ascii "6-Anexar objeto a la categoria actual\n"
 .ascii "7-Listar objetos de la categoria\n"
 .ascii "8-Borrar objeto de la categoria\n"
 .ascii "0-Salir\n"
 .asciiz "Ingrese la opcion deseada: "
error: .asciiz "Error: "
return: .asciiz "\n"
catName: .asciiz "\nIngrese el nombre de una categoria: "
selCat: .asciiz "\nSe ha seleccionado la categoria:"
idObj: .asciiz "\nIngrese el ID del objeto a eliminar: "
objName: .asciiz "\nIngrese el nombre de un objeto: "
success: .asciiz "La operaci�n se realizo con exito\n\n"


.text 

main: 
	la $t0, schedv		 # initialization scheduler vector
 	la $t1, newcaterogy
 	sw $t1, 0($t0)
 	la $t1, nextcategory
 	sw $t1, 4($t0)
#CONTINUAR

smalloc:
 	lw $t0, slist	#Carga la etiqueta de la lista en t0	
 	beqz $t0, sbrk	#Eval�a si la lista est� vac�a, En caso de estar vac�a salta a sbrk
 	move $v0, $t0	#Copia la direcci�n del nodo 
 	lw $t0, 12($t0) 
 	sw $t0, slist
 	jr $ra
sbrk:
 	li $a0, 16	 # Tama�o de nodo 4 Words, 16 bytes
 	li $v0, 9	 # Solicita sbrk
 	syscall		 # Devuelve la direcci�n del nodo en v0
 	jr $ra

sfree:
 	lw $t0, slist
 	sw $t0, 12($a0)
 	sw $a0, slist	 # $a0 node address in unused list
 	jr $ra



# EJEMPLO Newcategory
newcaterogy:
	addiu $sp, $sp, -4
 	sw $ra, 4($sp)
 	la $a0, catName	   	# input category name
 	jal getblock
 	move $a2, $v0 	  	# $a2 = *char to category name
 	la $a0, cclist 		# $a0 = list
 	li $a1, 0 		# $a1 = NULL
 	jal addnode
 	lw $t0, wclist
 	bnez $t0, newcategory_end
 	sw $v0, wclist 		# update working list if was NULL

newcategory_end:
 	li $v0, 0	 	# return success
 	lw $ra, 4($sp)
 	addiu $sp, $sp, 4
 	jr $ra
# "ANEXO"

# a0: list address
 # a1: NULL if category, node address if object
 # v0: node address added

addnode:
 	addi $sp, $sp, -8	#Solicita 2 words
 	sw $ra, 8($sp)		#Guarda la direcci�n de $ra en el stack
 	sw $a0, 4($sp)		#Guarda $a0 en el otro word(?
 	jal smalloc		
 	sw $a1, 4($v0) 		#set node content
 	sw $a2, 8($v0)
 	lw $a0, 4($sp)
 	lw $t0, ($a0) 	# first node address
 	beqz $t0, addnode_empty_list

addnode_to_end:
 	lw $t1, ($t0) # last node address
# update prev and next pointers of new node
 	sw $t1, 0($v0)
 	sw $t0, 12($v0)
# update prev and first node to new node
 	sw $v0, 12($t1)
 	sw $v0, 0($t0)
 	j addnode_exit

addnode_empty_list:
 	sw $v0, ($a0)
 	sw $v0, 0($v0)
 	sw $v0, 12($v0)

addnode_exit:
 	lw $ra, 8($sp)
 	addi $sp, $sp, 8
 	jr $ra
 # a0: node address to delete
 # a1: list address where node is deleted

delnode:
 	addi $sp, $sp, -8
 	sw $ra, 8($sp)
 	sw $a0, 4($sp)
 	lw $a0, 8($a0) 	# get block address
 	jal sfree 	# free block
 	lw $a0, 4($sp) 	# restore argument a0
 	lw $t0, 12($a0) # get address to next node of a0 node
 	beq $a0, $t0, delnode_point_self
 	lw $t1, 0($a0) 	# get address to prev node
 	sw $t1, 0($t0)
 	sw $t0, 12($t1)
 	lw $t1, 0($a1) 	# get address to first node again
 	bne $a0, $t1, delnode_exit
 	sw $t0, ($a1) 	# list point to next node
 	j delnode_exit

delnode_point_self:
 	sw $zero, ($a1) # only one node

delnode_exit:
 	jal sfree
 	lw $ra, 8($sp)
 	addi $sp, $sp, 8
 	jr $ra
	
 # a0: msg to ask
 # v0: block address allocated with string

getblock: #Crea un stack para guardar la direcci�n $ra (Esto porque se har� uso de otros saltos y evitar� perder el $ra original)
 	addi $sp, $sp, -4
 	sw $ra, 4($sp)
#Imprimir en pantalla el texto 	
 	li $v0, 4
 	syscall
#Creaci�n de espacio en memoria
 	jal smalloc	 	
 	move $a0, $v0	 		
#Lectura de String
 	li $a1, 16	#Establece 16 carateres como m�ximo m�ximo
 	li $v0, 8	# Llamada para leer cadena de texto ingresados por el usuario
 	syscall 	
 	move $v0, $a0
#Recupera la direcci�n de $ra original y devuelve el espacio solicitado	
 	lw $ra, 4($sp)
 	addi $sp, $sp, 4	
 	jr $ra
 	
 	#Prueba AAAaaa
 	addi $t7, $t7, 1
 	#ACH�
 	
