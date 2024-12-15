.data
slist: .word 0
cclist: .word 0
wclist: .word 0
schedv: .space 32
menu: .ascii "\n===================================="
 .ascii "\nColecciones de objetos categorizados\n"
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
 .asciiz "Ingrese la opcion deseada:\n"
simbolo: .asciiz "\n> "
error: .asciiz "Error: "
return: .asciiz "\n"
catName: .asciiz "\nIngrese el nombre de una categoria: "
selCat: .asciiz "\nSe ha seleccionado la categoria: "
idObj: .asciiz "\nIngrese el ID del objeto a eliminar: "
objName: .asciiz "\nIngrese el nombre de un objeto: "
success: .asciiz "\n        *Operación exitosa*"
objetosCreados: .asciiz "\n Lista de objetos creados: \n"
puntoespacio: .asciiz ". "
noObj: .asciiz "\n Objeto no encontrado. \n"


.text 
.globl main
main:
	# initialization scheduler vector
	la $t0, schedv
	la $t1, newcategory
	sw $t1, 0($t0)
	la $t1, nextcategory
	sw $t1, 4($t0)
	la $t1, prevcategory
	sw $t1, 8($t0)
	la $t1, listcategories
	sw $t1, 12($t0)
	la $t1, delcategory
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
	# Continuar
	# print_label(menu)
	li $v0, 4
	la $a0, menu
	syscall
	# read_int
	li $v0, 5 
	syscall
	# test if invalid option go to L1
	bltz $v0, menu_display_L1
	bgt $v0, 8, menu_display_L1
	#bgt $v0, 8, #menu_display_L1
	#bltz $v0, #menu_display_L1
	# else return
	jr $ra
	# print error 101 and try again
menu_display_L1:
    	# Imprimir mensaje de error
    	li $v0, 4	
    	la $a0, error	
    	syscall
    	
    	li $v0, 1
    	la $a0, 101
    	syscall
    	
    	li $v0, 4	
    	la $a0, return	
    	syscall
    	j menu_display

smalloc:
 	lw $t0, slist	# Carga en t0 la etiqueta de la lista 	
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
 	lw $t0, slist		# Carga en $t0 el primer valor de slist
 	sw $t0, 12($a0)		# Guarda el valor en el siguiente nodo
 	sw $a0, slist		# Guarda Dirección de Nodo $a0 en una lista sin uso
 	jr $ra		
 	
newcategory:
	addiu $sp, $sp, -4
 	sw $ra, 4($sp)		
 	
 	la $a0, catName	   	# Texto: "Ingrese el nombre de una categoría"
 	jal getblock		# Bloque de texto para cargar nombre de categoría u objeto
 	move $a2, $v0 	  	# $a2 = Puntero al nombre de la categoría (Utilizará addnode)
 	
 	la $a0, cclist 		# $a0 = list
 	li $a1, 0 		# $a1 = NULL ($a1 es el segundo bloque del nodo)
 	jal addnode		
 	
 	lw $t0, wclist
 	
 	bnez $t0, newcategory_end #Si tiene algo saltar a newcategory_end
 	
 	sw $v0, wclist 		# Actualiza la dirección de wclist si esta era NULL/0

newcategory_end:

 
   	li $v0, 0	 	# return success
 	lw $ra, 4($sp)
 	addiu $sp, $sp, 4
 	li $v0, 4
	la $a0, success		#"*Operación exitosa*"
	syscall


	li $v0, 0 		# Return succes	 
 	jr $ra
 	
nextcategory:
	lw $t0, wclist 		# Carga en $t0 el valor de wclist
	beqz $t0, error201 	# verifica si la lista esta creada
	lw $t1, 12($t0)  	# carga el puntero al nodo siguiente
	beq $t0, $t1 error202  	# Si ambos registros son la misma categoría Salto a error202
	j fincategory

prevcategory:
	lw $t0, wclist		# Carga en $t0 el valor de wclist
	beqz $t0, error201 	# verifica si la lista esta creada
	lw $t1, 0($t0)  	# Carga en $t1 el puntero al nodo anterior
	beq $t0, $t1 error202   # Si ambos registros son la misma categoría Salto a error202
	j fincategory

fincategory:
	li $v0, 4		# Llamada a sistema para mostrar en pantalla
	la $a0, selCat		# "\nSe ha seleccionado la categoria:"
	syscall	
	sw $t1, wclist		# Actualiza la dirección actual de la lista
        
        lw $a0, 8($t1)		# Muestra en pantalla el nombre de la categoría actual
        li $v0, 4		# Llamada a sistema para mostrar en pantalla
        syscall
        
        la $a0, return		#"\n"
        li $v0, 4		# Llamada a sistema para mostrar en pantalla
        syscall
	
	li $v0, 4
	la $a0, success		#"*Operación exitosa*"
	syscall

	        		        		        	
	li $v0, 0	 	# return success
	jr $ra		

error201:			#Error 201, no hay categoria
	li $v0, 4		#Muestra en pantalla mensaje
	la $a0, error		#Carga la etiqueta de "Error: "
	syscall
	li $v0, 1		#Muestra en pantalla el número
	li $a0, 201		#Carga el número del error "201"
	syscall
	jr $ra
    
error202:			#Error202: solo una categoría 
	li $v0, 4
	la $a0, error		#Carga la etiqueta de "Error: "
	syscall
	li $v0, 1		#Muestra en pantalla el número
	li $a0, 202		#Carga el número del error "202"
	syscall
	jr $ra

###
listcategories:
	lw $t0, wclist		# Cargamos la lista de las categorías 
	beqz $t0, error301	# Si no está creada la lista saltar a error301
	move $t1, $t0		# Copia de dirección del nodo inicial
	
	li $v0, 4		# Imprimir en pantalla
	la $a0, simbolo		# "> "
	syscall
	
	li $v0, 4		# Imprimir en pantalla
	lw $a0, 8($t0)		# "Nombre de la categoría actual"
	syscall
	
	lw $t0, 12($t0)		# Actualiza el puntero al siguiente nodo
	
bucle: 	
	beq $t0, $t1 finlistado	#Si coinciden las direcciones salta al final
	
	li $v0, 4		# Imprimir en pantalla
	lw $a0, 8($t0)		# Muestra en pantalla el nombre la seleccionada categoría
	syscall
	
	lw $t0, 12($t0)		# Actualiza el puntero al siguiente nodo
	
	j bucle

error301:			# Error 301, no existen categorías
	li $v0, 4		# Muestra en pantalla mensaje
	la $a0, error		# Carga la etiqueta de "Error: "
	syscall
	li $v0, 1		# Muestra en pantalla el número
	li $a0, 301		# Carga el número del error "301"
	syscall
	jr $ra


finlistado:
	li $v0, 4
	la $a0, success		#"*Operación exitosa*"
	syscall

	li $v0, 0	 	# return success
	jr $ra


delcategory:
	# Continuar
	la $s0, wclist		#Se carga en $t0 el puntero de wclist
	lw $s1, wclist		#Carga en $t1 wclist
	beqz $s1, error401	#Si está vacía Error 401
	
	lw $s2, 4($s1)
	beqz $s2, borrarSoloCat	
##borrado de objetos en caso de existir
	addi $t2, $s1, 4	# Carga en $t2 la dirección de objetos

whileObjdel:
	lw $t3, ($t2)		# carga en $t3 el contenido id de objetos
	beqz $t3, borrarSoloCat	#verifica si existen objetos
	move    $a0, $t3        # mueve a $a0 dirección del nodo
        move    $a1, $t2        # mueve a $a0 la dirección de la lista staset list address
        jal     delnode                    
        j       whileObjdel
	
	
borrarSoloCat:
	lw $t0, cclist 		# Dirección del nodo cclist 
	lw $t0, 12($t0)		# Dirección al siguiente nodo de cclist
	sw $t0, cclist		# Actualiza la dirección de cclist al siguiente nodo
	
	lw $a0, wclist		# En $a0 se guardará el nodo
	la $a1, wclist		# en $a1 se guardará la dirección 
	
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
	jal delnode
	
	#move $t0, $s0		# brindamos a $t0 la dirección al puntero wclist
	lw $t1, ($s0)		# cargamos contenido de wclist
	beqz $t1, ceroCclist	
	
finDelcat:

	li $v0, 4
	la $a0, success		#"*Operación exitosa*"
	syscall

	li $v0, 0
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra
		
ceroCclist:	
	
	sw $0, cclist
	
	j finDelcat
	
	
error401:
	li $v0, 4		# Muestra en pantalla mensaje
	la $a0, error		# Carga la etiqueta de "Error: "
	syscall
	li $v0, 1		# Muestra en pantalla el número
	li $a0, 401		# Carga el número del error "401"
	syscall
	
	
	jr $ra
	


	

newobject:
#Mostrar objetos para que el usuario vea cuales hay antes de crearlos
 	lw $s0, wclist 		# $s0 = wclist
 	lw $s1,4($s0)		# Carga en $s1 el ID del objeto
 	
 	beqz $s1, saltarlistado	#Si no hay objetos no muestra listado	
	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal listobjects
	lw $ra, ($sp)
	addi $sp, $sp, 4
	
saltarlistado:

	addiu $sp, $sp, -4	#Solicita espacio en el Stack
 	sw $ra, 4($sp)		#Almacena $ra
 	

 	beqz $s0, error501	# Si la lista de objetos está vacía: Error501		
 	
 	la $a0, objName	   	# Texto: "\nIngrese el nombre de un objeto: "
 	jal getblock		# Bloque para cargar nombre de categoría u objeto
 	move $a2, $v0 	  	# $a2 = Puntero al bloque nuevo (Utilizará addnode)

# a0: Puntero de la etiqueta(en este caso del objeto)
# a1: Identificador o puntero a otra listaNULL if category, node address if object
# a2: Puntero al nombre // *char to category name
# v0: node address added

	la $a0, 4($s0)		#Carga en $a0 el puntero al segundo bloque(Puntero a ID, addnode)
	lw $t0, ($a0)		#Carga en $t0 el contenido de dicho segundo bloque	
	
	beqz $t0, primerObjeto	#Evalúa si ese contendio es null settear 1 al ID, sinó sumar sumar 1 a $a1

	lw $t0, ($t0)		#Puntero al anterior nodo
	lw $a1, 4($t0)		#Se carga en $a1 el identificador correspondiente
	addi $a1, $a1, 1	#Si No es null simplemente hace +1 al ID 

	jal addnode		#Creación de nodo
	j finObjeto		#Salto al final de objeto

error501:			# Error 501, no existen categorías		
	li $v0, 4		# Muestra en pantalla mensaje
	la $a0, error		# Carga la etiqueta de "Error: "
	syscall
	li $v0, 1		# Muestra en pantalla el número
	li $a0, 501		# Carga el número del error "501"
	syscall
	jr $ra
		
primerObjeto:
	li $a1, 1		#Establece el primer ID a 1
	jal addnode		#Creación de nodo

finObjeto:
	
	lw $ra, 4($sp)		#Devuelve el $ra original
	addiu $sp, $sp, 4	#Devuelve memoria
	
	li $v0, 4
	la $a0, success		#"*Operación exitosa*"
	syscall
	 
	li $v0, 0		# return success
	j listobjects
	jr $ra
	

listobjects:
	lw $t0, wclist		
	beqz $t0, error602
	
	lw $t1, 4($t0)		# Carga en $t1 el ID
	beqz $t1, error601	# Si no hay objetos saltar a error601
				
	move $t0, $t1	
	
	li $v0, 4
	la $a0, objetosCreados
	syscall	
	
bucle2:	
	li $v0, 1		# Mostrar entero
	lw $a0, 4($t0)		# carga ID 
	syscall
	
	li $v0, 4		# Mostrar String
	la $a0, puntoespacio	# Imprime separador
	syscall
	
	li $v0, 4		# Mostrar String
	lw $a0, 8($t0)		# Imprime el nombre del objeto
	syscall

	lw $t0, 12($t0)		# $t0 apunta al siguiente nodo
	
	beq $t0, $t1, finlistobjects	# Comprobación de fin de bucle, Si el registro es el mismo que el inicial termina el bucle
	j bucle2
	

	
	
error601: 			# Error 601, no existen categorías		
	li $v0, 4		# Muestra en pantalla mensaje
	la $a0, error		# Carga la etiqueta de "Error: "
	syscall
	li $v0, 1		# Muestra en pantalla el número
	li $a0, 601		# Carga el número del error "601"
	syscall
	jr $ra

error602:			# Error 602, no existen categorías
	li $v0, 4		# Muestra en pantalla mensaje
	la $a0, error		# Carga la etiqueta de "Error: "
	syscall
	li $v0, 1		# Muestra en pantalla el número
	li $a0, 602		# Carga el número del error "602"
	syscall
	jr $ra
	
finlistobjects:

#	li $v0, 4
#	la $a0, success		#"*Operación exitosa*"
#	syscall
	 
	li $v0, 0		# return success
	jr $ra
	
	

delobject:

        lw  $t0, wclist
        bne $t0, $0, verificarObjP1   #Si hay objetos saltar a verificarObjP1
        la $a0, error
        li $v0, 4
        syscall
        li $v0, 701
        jr $ra

verificarObjP1:
        addi $t5, $t0, 4                 # coloca en $t5 la dirección de id del objeto
        lw $t0, 4($t0)                 # Carga en $t0 el ID del objeto
        bne $t0, $0, consultarID            #Si es 0 entonces no hay objetos. Sinó saltar a ConsultarID
        la $a0, error
        li $v0, 4
        syscall
        li $a0, 702
        li $v0, 1
        syscall
        jr      $ra

consultarID:

	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal listobjects
	lw $ra, ($sp)
	addi $sp, $sp, 4

        la $a0, idObj		#"Ingrese el objeto a eliminar"
        li $v0, 4
        syscall
        li $v0, 5		#Espera al usuario para que ingrese el valor
        syscall
        move $t7, $v0		# Mueve a $t7 el numero que ingresa el usuario

        move $t1, $t0           # Copia del primer valor para verificación del bucle 

verificarObjP2: 
        lw $t6, 4($t0)          # Carga en $t6 el ID
        beq $t6, $t7, hayObj    # Compara si lo ingresado por el usuario existe
        lw $t0, 12($t0)         # En caso de no existir busca en el siguiente nodo
        beq $t1, $t0, noHayObj	
        j verificarObjP2

noHayObj:
        la $a0, noObj		#" Objeto no encontrado."
        li $v0, 4
        syscall
        j finDelobj

hayObj:
        move $a0, $t0           # Dirección del nodo a eliminar
        move $a1, $t5           # dirección de la lista del objeto a eliminar
        jal delnode

finDelobj:

	li $v0, 4
	la $a0, success		#"*Operación exitosa*"
	syscall

        lw $ra, ($sp)
        addi $sp, $sp, 4
        jr $ra
	


# "ANEXO"

# a0: Puntero de la etiqueta  // list adress
# a1: Identificador o puntero a otra listaNULL if category, node address if object
# a2: Puntero al nombre // *char to category name
# v0: node address added
# t0 y- t1 : puntero al anterior nodo 
addnode:#gestión de las listas enlazadas, agrega elementos a las listas de categorías u objetos
 	addi $sp, $sp, -8	#Solicita 2 words
 	sw $ra, 8($sp)		#Guarda la dirección de $ra en el stack
 	sw $a0, 4($sp)		#Guarda $a0 el puntero de la lista
 	
 	jal smalloc		
 	
 	sw $a1, 4($v0) 		#Guarda puntero de la otra categoría o ID del objeto
 	sw $a2, 8($v0)		#Guarda puntero del nombre.

  	lw $a0, 4($sp)		#Devuelve puntero a $a0
 	lw $t0, ($a0) 		#Carga en $t0 el primer bloque del nodo (Puntero al anterior nodo)

 	beqz $t0, addnode_empty_list #En caso de que la lista enlazada esté vacía saltar

addnode_to_end:
 	lw $t1, ($t0) # last node address
# update prev and next pointers of new node
 	sw $t1, 0($v0)		#Nodo anterior
 	sw $t0, 12($v0)		#Nodo siguiente
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

 # a0: node address to delete // lw 
 # a1: list address where node is deleted // la

delnode:
 	addi $sp, $sp, -8	# Solicitud de dos words
 	sw $ra, ($sp)		# Primer espacio para $ra
 	sw $a0, 4($sp)		# Guardamos $a0 en el siguiente espacio
 	
 	lw $a0, 8($a0) 		# get block address #Borra el nombre de categoría u objeto
 	jal sfree 		# free block
 	
 	lw $a0, 4($sp) 		# restore argument a0
 	lw $t0, 12($a0) 	# get address to next node of a0 node
 	beq $a0, $t0, delnode_point_self #Evalúa si es un nodo único dentro del listado
 	
 	lw $t1, 0($a0) 		# get address to prev node
 	sw $t1, 0($t0)	
 	sw $t0, 12($t1)
 	lw $t1, 0($a1) 		# get address to first node again
 	bne $a0, $t1, delnode_exit
 	sw $t0, ($a1) 		# list point to next node
 	j delnode_exit

delnode_point_self:
 	sw $zero, ($a1) # only one node

delnode_exit:
 	jal sfree
 	lw $ra, ($sp)
 	addi $sp, $sp, 8
 	jr $ra
	
 # a0: msg to ask
 # v0: block address allocated with string

getblock: 
#Asigna un bloque de memoria para almacenar la cadena de texto.
#Este bloque se utilizará para guardar el nombre de la categoría u objeto
	addi $sp, $sp, -4
 	sw $ra, 4($sp)		# Guarda $ra para más adelante

  	li $v0, 4		#Imprimir en pantalla el texto 	
 	syscall
 	
 	jal smalloc	 #Creación de espacio en memoria	
 	move $a0, $v0	 # $v0 contiene la dirección solicitada por smalloc, Al moverla en $a0 este espacio se utilizará para guardar aquí adentro toda la cadena de texto (Max 16 caracteres)	
# Guardará en el espacio creado la cadena de texto del usuario (Máx 16 Caracteres)	
#Lectura de String
 	li $a1, 16	# Establece 16 carateres como máximo máximo
 	li $v0, 8	# Llamada para leer cadena de texto ingresados por el usuario
 	syscall 	
 	move $v0, $a0	# Clona en $v0 el valor de $a0
#Recupera la dirección de $ra original y devuelve el espacio solicitado	
 	lw $ra, 4($sp)
 	addi $sp, $sp, 4	
 	jr $ra
 
 
done:
	li $v0, 10
	syscall
