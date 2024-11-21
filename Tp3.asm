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
success: .asciiz "La operación se realizo con exito\n\n"


.text 
.globl main
main:
	# initialization scheduler vector
	la $t0, schedv
	la $t1, newcaterogy
	sw $t1, 0($t0)
	la $t1, nextcategory
	sw $t1, 4($t0)
	la $t1, prevcaterogy
	sw $t1, 8($t0)
	la $t1, listcategories
	sw $t1, 12($t0)
	la $t1, delcaterogy
	sw $t1, 16($t0)
	la $t1, newobject
	sw $t1, 20($t0)
	la $t1, listobjects
	sw $t1, 24($t0)
	la $t1, delobject
	sw $t1, 28($t0)
	
main_loop:
	# Mostrar menu
	jal menu_display
	beqz $v0, main_end	# Si usuario ingresa 0 se termina.
	addi $v0, $v0, -1	# dec menu option
	sll $v0, $v0, 2         # Multiplica la opcion de menu por 4
	la $t0, schedv		# Carga dirección de la etiqueta en $t0
	add $t0, $t0, $v0	# Coloca en $t0 el valor de $v0
	lw $t1, ($t0)		# Carga en $t1 el primer valor de $t0
    	la $ra, main_ret 	# save return address
    	jr $t1			# call menu subrutine
    	
main_ret:
    j main_loop		

main_end:
	j done
	
menu_display:
	# write your code
	# print_label(menu)
	# read_int
	# test if invalid option go to L1
	#bgt $v0, 8, #menu_display_L1
	#bltz $v0, #menu_display_L1
	# else return
	jr $ra
	# print error 101 and try again
menu_display_L1:
	#print_error(101)
	j menu_display
	

smalloc:
 	lw $t0, slist	# Carga la etiqueta de la lista en t0	
 	beqz $t0, sbrk	# Evalúa si la lista está vacía, En caso de estar vacía salta a sbrk
 	move $v0, $t0	# Copia en $v0 el contenido de $t0
 	lw $t0, 12($t0) # Carga en $t0 la dirección al siguiente nodo
 	sw $t0, slist	# Actualiza slist con la nueva dirección(puntero al siguiente nodo)
 	jr $ra
sbrk:
 	li $a0, 16	 # Tamaño de nodo 4 Words, 16 bytes
 	li $v0, 9	 # Solicita sbrk
 	syscall		 # Devuelve la dirección del nodo en $v0
 	jr $ra

sfree:
 	lw $t0, slist	#Carga en $t0 ???
 	sw $t0, 12($a0)
 	sw $a0, slist	 # $a0 node address in unused list
 	jr $ra
# EJEMPLO Newcategory
newcaterogy:
	addiu $sp, $sp, -4
 	sw $ra, 4($sp)
 	la $a0, catName	   	# input category name
 	jal getblock
 	move $a2, $v0 	  	# $a2 = Puntero al nombre de la categoría
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
 	
nextcategory:
	# write your code
	jr $ra

prevcaterogy:
	# write your code
	jr $ra

listcategories:
	# write your code
	jr $ra

delcaterogy:
	# write your code
	jr $ra

newobject:
	# write your code
	jr $ra

listobjects:
	# write your code
	jr $ra

delobject:
	# write your code
	jr $ra

# "ANEXO"

# a0: list address
 # a1: NULL if category, node address if object
 # v0: node address added

addnode:
 	addi $sp, $sp, -8	#Solicita 2 words
 	sw $ra, 8($sp)		#Guarda la dirección de $ra en el stack
 	sw $a0, 4($sp)		#Guarda $a0 el puntero de la lista
 	jal smalloc		
 	sw $a1, 4($v0) 		#Guarda puntero de la otra categoría o ID del objeto
 	sw $a2, 8($v0)		#Guarda nombre.
 	lw $a0, 4($sp)		#Devuelve puntero a $a0
 	lw $t0, ($a0) 		#Carga en $t0 el primer bloque del nodo (Puntero al anterior nodo)
 	beqz $t0, addnode_empty_list

addnode_to_end:
 	lw $t1, ($t0) # last node address
# update prev and next pointers of new node
 	sw $t1, 0($v0)		#Nodo anterior(?
 	sw $t0, 12($v0)		#Nodo siguiente(?
# update prev and first node to new node
 	sw $v0, 12($t1)
 	sw $v0, 0($t0)
 	j addnode_exit

addnode_empty_list:
 	sw $v0, ($a0)	#Guarda $v0 en el primer bloque de $a0 (Puntero al anterior nodo)
 	sw $v0, 0($v0)	#Guarda $v0 en primer bloque de $v0 (Puntero al anterior nodo)
 	sw $v0, 12($v0)	#Guarda $v0 en el último bloque de $v0 (Puntero al siguiente nodo)

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

getblock: 
	addi $sp, $sp, -4
 	sw $ra, 4($sp)
#Imprimir en pantalla el texto 	
 	li $v0, 4
 	syscall
#Creación de espacio en memoria
 	jal smalloc	 	
 	move $a0, $v0	 #Carga en $a0,la dirección de memoria creada en smalloc para almacenar el texto		
#Lectura de String
 	li $a1, 16	#Establece 16 carateres como máximo máximo
 	li $v0, 8	# Llamada para leer cadena de texto ingresados por el usuario
 	syscall 	
 	move $v0, $a0	# $
#Recupera la dirección de $ra original y devuelve el espacio solicitado	
 	lw $ra, 4($sp)
 	addi $sp, $sp, 4	
 	jr $ra
 
 
done:
	li $v0, 10
	syscall
