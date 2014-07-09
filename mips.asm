#-------------------------------------------------------------------------------
#autor: Rafal Braun
#data : 2014.04.02
#opis : Program symulujacy rysowanie mapy wysokosci i przekroju
#-------------------------------------------------------------------------------

.data

buffermapa:	 		.space  		125526					# 125 526 B
bufferprzekroj:	 		.space  		342522					# 342 522 B
inputmapa:	 		.space  		202005					# (4+1) * 201 * 201 * 1B = 202 005 B
inputprzekroj:			.space			20					# (4+1) * 2 * 2 = 20 B
inputprzekrojfile:		.asciiz			"przekroj.txt"				# nazwa pliku wejsciowego
inputmapafile:			.asciiz 		"mapa.txt"				# nazwa pliku wejsciowego
outputmapafile:	 		.asciiz 		"mapa.bmp"				# nazwa pliku wyjsciowego
outputprzekrojfile:		.asciiz 		"przekroj.bmp"				# nazwa pliku wyjsciowego
bug:		 		.asciiz 		"It appears that something has gone wrong"

headlinemapa:		.byte					0x42,0x4D,0xB6,0xDA,0x01,0x00,0x00,0x00,0x00,0x00,0x7A,0x00,0x00,0x00,0x6C,0x00
								0x00,0x00,0xC9,0x00,0x00,0x00,0xC9,0x00,0x00,0x00,0x01,0x00,0x18,0x00,0x00,0x00,
								0x00,0x00,0x3C,0xDA,0x01,0x00,0x13,0x0B,0x00,0x00,0x13,0x0B,0x00,0x00,0x00,0x00,
								0x00,0x00,0x00,0x00,0x00,0x00,0x42,0x47,0x52,0x73,0x00,0x00,0x00,0x00,0x00,0x00,
								0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
								0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x02,0x00,0x00,0x00,
								0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00

headlineprzekroj:	.byte					0x42,0x4D,0xFA,0x39,0x05,0x00,0x00,0x00,0x00,0x00,0x7A,0x00,0x00,0x00,0x6C,0x00,
								0x00,0x00,0x1D,0x01,0x00,0x00,0x90,0x01,0x00,0x00,0x01,0x00,0x18,0x00,0x00,0x00,
								0x00,0x00,0x80,0x39,0x05,0x00,0x13,0x0B,0x00,0x00,0x13,0x0B,0x00,0x00,0x00,0x00,
								0x00,0x00,0x00,0x00,0x00,0x00,0x42,0x47,0x52,0x73,0x00,0x00,0x00,0x00,0x00,0x00,
								0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
								0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x02,0x00,0x00,0x00,
								0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00			

.text

############## used registers:
############## -s0 - 1st desc
############## -s2 - 	
############## -s3 - 
############## -s4 - 
############## -k0 - x
############## -k1 - y
################################################################################
### MAIN #######################################################################
################################################################################
main:

	jal fropen
	jal readfile
	jal fclose

	la $a0, inputmapa
	li $t7, 40401			#0x9DD0			# 201*201
loop:	
	jal readdigit
	add $t7, $t7, -1
	bgt $t6, 9999, error
	blt $t6, 0, error
	
	addi $sp, $sp, -4
	sw $t6, 0($sp)
	
	bnez $t7, loop

	jal turntograymap

###################################################

	la $a0, inputprzekroj

	jal readdigit
	bgt $t6, 201, error
	blt $t6, 0, error		
	move $s4, $t6
	
	jal readdigit
	bgt $t6, 201, error
	blt $t6, 0, error		
	move $s5, $t6
	
	jal readdigit
	bgt $t6, 201, error
	blt $t6, 0, error		
	move $s6, $t6
	
	jal readdigit
	bgt $t6, 201, error
	blt $t6, 0, error		
	move $s7, $t6
	
	move $t1, $s4
	move $t2, $s5
	move $t3, $s6
	move $t4, $s7
	
	jal drawaline
	
#	li $t1, 1
#	li $t2, 1
#	jal drawheight
	
	jal fwopen
	jal writefile
	jal fclose
			
	j exit
################################################################################
### fwopen (write) #############################################################
################################################################################

################################################################################
### fropen (read) ##############################################################
################################################################################
fropen:
	li $v0, 13
	la $a0, inputmapafile
	li $a1, 0        # Open (flags are 0: read, 1: write)
 	li $a2, 0        # mode is ignored
	syscall
	
	bltz $v0, error
	move $s0, $v0
	
	li $v0, 13
	la $a0, inputprzekrojfile
	li $a1, 0        # Open (flags are 0: read, 1: write)
	li $a2, 0        # mode is ignored
	syscall
	
	bltz $v0, error
	move $s1, $v0
				
	jr $ra
################################################################################
### fwopen (write) #############################################################
################################################################################
fwopen:
	li $v0, 13
	la $a0, outputmapafile
	li $a1, 1        	# Open for writing (flags are 0: read, 1: write)
 	li $a2, 0        	# mode is ignored
	syscall
		
	move $s0, $v0
	bltz $v0, error
	
	li $v0, 13
	la $a0, outputprzekrojfile
	li $a1, 1        	# Open for writing (flags are 0: read, 1: write)
 	li $a2, 0        	# mode is ignored
	syscall
	
	move $s1, $v0
	bltz $v0, error
	
	jr $ra
################################################################################
### writefile ########################################################################
################################################################################
writefile:
	la $a0, buffermapa			# adres bufora
	la $a1, headlinemapa			# adres bufora
	li $t0, 0x7A
loop1:
	lb $t1, ($a1)
	sb $t1, ($a0)
	add $t0, $t0, -1
	add $a0, $a0, 1
	add $a1, $a1, 1
	bnez $t0, loop1
	
	li $v0, 15
	move $a0, $s0
	la $a1, buffermapa		# adres bufora
	li $a2, 121526			# ilosc bajtow do wczytania	
	syscall

	la $a0, bufferprzekroj			# adres bufora
	la $a1, headlineprzekroj		# adres bufora
	li $t0, 0x7A
	
	loop4:
	lb $t1, ($a1)
	sb $t1, ($a0)
	add $t0, $t0, -1
	add $a0, $a0, 1
	add $a1, $a1, 1
	bnez $t0, loop4
	
	li $v0, 15
	move $a0, $s1
	la $a1, bufferprzekroj		# adres bufora
	li $a2, 342522				# ilosc bajtow do wczytania	
	syscall
					
################################################################################
### readfile ###################################################################
################################################################################
readfile:
	li $v0, 14
	move $a0, $s0
	la $a1, inputmapa			# adres bufora
	li $a2, 0x31515				
	syscall

	li $v0, 14
	move $a0, $s1
	la $a1, inputprzekroj		# adres bufora
	li $a2, 0x14
	syscall

	jr $ra
################################################################################
### fclose #####################################################################
################################################################################
fclose:
	li $v0, 16
	move $a0, $s0		# s0 jest deskryptorem pliku	
	syscall
	
	li $v0, 16
	move $a0, $s1		# s0 jest deskryptorem pliku	
	syscall
	
	jr $ra
################################################################################
### turntograymap ##############################################################
################################################################################
turntograymap:
	la $a0, buffermapa			# adres bufora
	add $a0, $a0, 0x7A			# 0x7A
#	li $t7, 40401				#201*201
	li $t6, 201
	li $t7, 201
	move $a3, $sp 
	
	j loop2
loop3:
	add $t6, $t6, -1
	add $t7, $zero, 201
	add $a0, $a0, 1		
loop2:
	lw $t0, 0($a3)
	mul $t0, $t0, 256
	div $t0, $t0, 400
	
	bgt $t0, 0xff, white
normal:	
	sb $t0, 0($a0)
	sb $t0, 1($a0)
	sb $t0, 2($a0)

	add $a3, $a3, 4
	add $a0, $a0, 3
	add $t7, $t7, -1
	
	bnez $t7, loop2 
	bnez $t6, loop3
	
	jr $ra
white:
	li $t0, 0xff
	sb $t0, 0($a0)
	sb $t0, 1($a0)
	sb $t0, 2($a0)
	
	add $a3, $a3, 4
	add $a0, $a0, 3
	add $t7, $t7, -1
	
	bnez $t7, loop2 
	bnez $t6, loop3
	
	jr $ra
################################################################################
### drawaline ######################################################################
################################################################################	
################### $t1, $t2 : [x1,y1] 
################### $t3, $t4 : [x2,y2]
drawaline:
	li $t8, 0
	#li $t7, 0
	lhu $t7, ($sp)
	move $t9, $ra
	li $k0, 1
	li $k1, 1
	
	blt $t1, $t3, dontchangex	# jesli x1 < x2
	li $k0, -1
dontchangex:
	blt $t2, $t4, dontchangey	# jesli y1 < y2
	li $k1, -1
dontchangey:
	sub $t5, $t1, $t3			# delta x
	sub $t6, $t2, $t4			# delta y
	abs $t5, $t5
	abs $t6, $t6
	
	jal drawpointmapa
	jal drawpointprzekroj
				
	blt $t5, $t6, ycounter
	
####################################################################

xcounter:
	move $s0, $t5			# zachowaj licznik petli
	div $s1, $t5, 2			# e
loop5:
	add $t1, $t1, $k0		# x1 = x1 +- 1
	sub $s1, $s1, $t6		# e = e - delta y
	bgez $s1, gox 			# jesli e >= 0 skocz
	add $t2, $t2, $k1		# y1 = y1 +- 1
	add $s1, $s1, $t5		# e = ex + dx
gox:		
	jal drawpointmapa
	jal drawpointprzekroj
	
	addi $s0, $s0, -1			# zmniejsz licznik petli
	bnez $s0, loop5			# jesli licznik wiekszy od 0 kontynuuj
	
	move $ra, $t9
	jr $ra

###################################################################

ycounter:
	move $s0, $t6			# zachowaj licznik petli
	div $s1, $t6, 2			# e
loop6:
	add $t2, $t2, $k1		# y1 = y1 +- 1
	sub $s1, $s1, $t5		# e = e - delta x
	bgez $s1, goy			# jesli e >= 0 skocz
	add $t1, $t1, $k1		# x1 = x1 +- 1
	add $s1, $s1, $t6		# e = ey + dy
goy:
	jal drawpointmapa
	jal drawpointprzekroj
	
	addi $s0, $s0, -1		# zmniejsz licznik petli
	bnez $s0, loop6		# jesli licznik wiekszy od 0 kontynuuj
	
	move $ra, $t9
	jr $ra
################################################################################
### drawpointmapa ###########################################################
################################################################################
drawpointmapa:
	la $a0, buffermapa		# zaladuj  adres mapy
	add $a0, $a0, 0x7A		# dodaj dlugosc naglowka
	mul $s5, $t1, 3			
	mul $s6, $t2, 604
	
	add $a0, $a0, $s5		# dodaj x	
	add $a0, $a0, $s6 		# dodaj y
	
	li $s7, 0xff				# zaladuj kolor
	sb $s7, 2($a0)
	sb $zero, 1($a0)
	sb $zero, 0($a0)
	
	jr $ra
################################################################################
### drawpointprzekroj ###########################################################
################################################################################
drawpointprzekroj:
	#la $a0, bufferprzekroj		# zaladuj  adres mapy
	move $a3, $sp
	#add $a0, $a0, 0x7A			# dodaj dlugosc naglowka
	
	mul $s4, $t1, 1
	mul $s5, $t2, 201
	add $s5, $s5, $s4
	mul $s5, $s5, 4
	add $a3, $a3, $s5
	
	lhu $s6, ($a3)
	blt $s6, $t7, minusloop7
	bgt $s6, $t7, plusloop7
equal:	
	la $a0, bufferprzekroj		# zaladuj  adres mapy
	add $a0, $a0, 0x7A			# dodaj dlugosc naglowka
	
	mul $s5, $t8, 3			
	add $a0, $a0, $s5		# dodaj x	
	mul $s5, $t7, 856		
	add $a0, $a0, $s5		#$s6 		# dodaj y
	
	li $s7, 0xff					# zaladuj kolor
	sb $s7, 2($a0)
	sb $s7, 1($a0)
	sb $s7, 0($a0)
	
	j return
		
	### !!!
plusloop7:	
	la $a0, bufferprzekroj		# zaladuj  adres mapy
	add $a0, $a0, 0x7A			# dodaj dlugosc naglowka
	
	add $t7, $t7, 1
	
	mul $s5, $t8, 3			
	add $a0, $a0, $s5		# dodaj x	
	mul $s5, $t7, 856		
	add $a0, $a0, $s5		#$s6 		# dodaj y
	
	li $s7, 0xff					# zaladuj kolor
	sb $s7, 2($a0)
	sb $s7, 1($a0)
	sb $s7, 0($a0)
	
	blt $t7, $s6, plusloop7
	j return
	### !!!
minusloop7:	
	la $a0, bufferprzekroj		# zaladuj  adres mapy
	add $a0, $a0, 0x7A			# dodaj dlugosc naglowka
	
	add $t7, $t7, -1
	
	mul $s5, $t8, 3			
	add $a0, $a0, $s5		# dodaj x	
	mul $s5, $t7, 856		
	add $a0, $a0, $s5		#$s6 		# dodaj y
	
	li $s7, 0xff					# zaladuj kolor
	sb $s7, 2($a0)
	sb $s7, 1($a0)
	sb $s7, 0($a0)
	
	bgt $t7, $s6, minusloop7
	j return
	###!!!	

return:	
	add $t8, $t8, 1
	move $t7, $s6

	jr $ra
################################################################################
### exit the program ###########################################################
################################################################################	
exit:
	li $v0, 10 	# syscall code 10 is for exit.
	syscall 	# make the syscall.
################################################################################
### error ######################################################################
################################################################################	
error:
	li $v0, 4
	la $a0, bug
	syscall
	b exit
################################################################################
### readdigit #######################################################################
################################################################################
readdigit:
	
	lb $t1, ($a0)
	beq 	$t1, 0x20, go
	beq 	$t1, 0x0D, go
	
	add $a0, $a0, 1
	lb $t2, ($a0)
	beq 	$t2, 0x20, loaddigit1
	beq 	$t2, 0x0A, loaddigit1
	
	add $a0, $a0, 1
	lb $t3, ($a0)
	beq 	$t3, 0x20, loaddigit2
	beq 	$t3, 0x0A, loaddigit2
	
	add $a0, $a0, 1
	lb $t4, ($a0)
	beq 	$t4, 0x20, loaddigit3
	beq 	$t4, 0x0A, loaddigit3
	
	add $a0, $a0, 1
	lb $t5, ($a0)
	beq 	$t5, 0x20, loaddigit4
	beq 	$t5, 0x0A, loaddigit4
	
	j error
	
loaddigit1:
	sub $t1, $t1, 0x00000030
	mul $t1, $t1, 1
	add $t6, $zero, $t1
	
	add $a0, $a0, 1
	jr $ra				
loaddigit2:
	sub $t1, $t1, 0x00000030
	sub $t2, $t2, 0x00000030
	mul $t1, $t1, 10
	mul $t2, $t2, 1
	add $t6, $zero, $t1
	add $t6, $t6, $t2
	
	add $a0, $a0, 1
	jr $ra
loaddigit3:
	sub $t1, $t1, 0x00000030
	sub $t2, $t2, 0x00000030
	sub $t3, $t3, 0x00000030
	mul $t1, $t1, 100
	mul $t2, $t2, 10
	mul $t3, $t3, 1
	add $t6, $zero, $t1
	add $t6, $t6, $t2
	add $t6, $t6, $t3
	
	add $a0, $a0, 1
	jr $ra
loaddigit4:
	sub $t1, $t1, 0x00000030
	sub $t2, $t2, 0x00000030
	sub $t3, $t3, 0x00000030
	sub $t4, $t4, 0x00000030
	
	mul $t1, $t1, 1000
	mul $t2, $t2, 100
	mul $t3, $t3, 10
	mul $t4, $t4, 1
	
	add $t6, $zero, $t1
	add $t6, $t6, $t2
	add $t6, $t6, $t3
	add $t6, $t6, $t4
			
	add $a0, $a0, 1		
	jr $ra
	
go:
	add $a0, $a0, 1
	j readdigit

