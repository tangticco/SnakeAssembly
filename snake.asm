.data # define the color
lightRd: .word 0x00FF4444 # 0x0RGB
lightGrey: .word 0x00a5a5a5
lightBlue : .word 0x00327aef
black : .word 0x00000000
startMessage : .asciiz "Game Start !!!! Good Luck!!!!\n"
progress1 : .asciiz "You eat a fruit!! Your current score is "
progress2 : .asciiz ". Keep Going!! \n"
deadMessage : .asciiz "You loose!!!! GAME OVER    \n"


.text

#Print the start message
li $v0, 4
la $a0 startMessage
syscall


lw $t1, lightRd($0) # put the color value into $t1
lw $t2, lightGrey($0) #put border color into $t2
lw $s7, lightBlue($0) #put snake head color into $s7


addi $t0, $gp, 0 # $gp -> $t0 cause I will change value

lw $t5 1000($gp)

li $t5 0	#assign $t5 as a counter for border drawing (can be freed later)
li $t6 32	#assign $t6 as a constraint of border drawing (can be freed later)
li $t4, 1	#assign $t4 as a function code for border drawing (can be freed later

jal paintBorder	#paint the border

#t4, t5, t6 are freed
#The initial length of the snake is 4 units and I only need to track the head and tail in fact
addi $t4 $gp 2108 #assigan a head location to the snake
sw $t4 4460($gp) #give a memory location to store the start of snake array
addi $t4 $gp 4460	#save the location of the snake array to 
li $t5 3	#use $t5 to store the length - 1 of the snake


#initialize snake 

#use $t6 as a temporary register to store the location value (can be freed later)
addi $t0, $gp, 0 #reset t0 to gp
sw $t7, 2108($t0)

sw $t1, 2104($t0)
addi $t6 $t0 2104
sw $t6, 4($t4)

sw $t1, 2100($t0)
addi $t6 $t0 2100
sw $t6, 8($t4)

sw $t1, 2096($t0)
addi $t6 $t0 2096
sw $t6, 12($t4)

#now entering the game plaing loop
li $s2 100
jal generateFruit

#set $s5 as the score
li $s5 0


gameLoop:
lw $t6 0($t4)	#get the location of the head
add $t6 $t6 $s0
beq $t6 $t3 extendSnake #check if the location of the head collide with fruit

#sleep 
li $a0 500
li $v0 32
syscall

jal getInput

move $t8, $v0 # move the key press data into $a0 for printing
#move the snake forward ( for now set it to move +4 (D)


beq $t8, 119 moveUp # pressed w
beq $t8, 115 moveDown # pressed s
beq $t8, 97 moveLeft #pressed a
beq $t8, 100 moveRight #pressed d

beq $s2, 119 moveUp # pressed w
beq $s2, 115 moveDown # pressed s
beq $s2, 97 moveLeft #pressed a
beq $s2, 100 moveRight #pressed d

j gameLoop



j exit

#paint the borders
paintBorder:
beq $t4, 1 paintHorizontalBorder   #if function code $t4 equal to 1, then go paint the upper horizontal border
li $t5, 0	#reset the counter to 0
li $t6 30	#add a constraint to $t6 with 30	
beq $t4, 2 paintVerticalBorder	#if function code $t4 equal to 2, then go paint the vertical borders
li $t5, 0	#reset the counter to 0
li $t6 32	#reload the constraint to 32
beq $t4, 3 paintBottomHorizontalBorder	#if function code $4 equal to 3, then go paint the horizontal border
jr $ra		#return to previous line


#paint the upper horizonal border
paintHorizontalBorder:
li $t4 2
beq $t5, $t6 paintBorder
addi $t5 $t5 1
sw $t2, 0($t0)
addi $t0, $t0, 4
j paintHorizontalBorder  

#paint the lower horizontal border
paintBottomHorizontalBorder:
li $t4 4
beq $t5, $t6 paintBorder
addi $t5 $t5 1
sw $t2, 0($t0)
addi $t0, $t0, 4
j paintBottomHorizontalBorder 

#paint the vertical border
paintVerticalBorder:
li $t4 3
beq $t5, $t6 paintBorder
addi $t5, $t5, 1
sw $t2, 0($t0)
addi $t0, $t0, 124
sw $t2, 0($t0)
addi $t0, $t0, 4
j paintVerticalBorder

#this function is to generate a fruit
generateFruit:
fruitloop:
li $a1 991
li $v0 42
syscall
mul $a0 $a0 4
add $a0 $a0 $gp
lw $a1, 0($a0)
beq $a1, $t1 ,  fruitloop
beq $a1, $t2, fruitloop
move $t3 $a0
sw $t1, 0($t3)
jr $ra

#this will extend the snake when it eat a fruit and it will generate a new fruit
extendSnake:

#print out game update message
li $v0, 4
la $a0 progress1
syscall
addi $s5 $s5 1	#update the score by 1
move $a0, $s5
li $v0, 1
syscall
li $v0, 4
la $a0 progress2
syscall


lw $a0 0($t4) #store the old location of the head
addi $t4 $t4 -4	#move the location of the head forward
sw $t3 0($t4) #save the location of the new head to the new head memory address
sw $s7 0($t3)
sw $t1 0($a0)
addi $t5 $t5 1
jal generateFruit
j gameLoop

#movement, use $t8 as adder to change the direction

moveRight:
li $s0 4
j updatePreviousDirection

moveLeft:
li $s0 -4
j updatePreviousDirection

moveUp:
li $s0 -128
j updatePreviousDirection

moveDown:
li $s0 128
j updatePreviousDirection


updatePreviousDirection:
beq $t8 32 updateSnake
beqz $t8 updateSnake
move $s2 $t8
j updateSnake


updateSnake:
lw $t6 0($t4)	#get the head location
add $a0 $t6 $s0 	#calculate the new head location
lw $a1 0($a0)	#read the color at location
beq $a0 $t3 gameLoop
beq $a1 $t1 exit
beq $a1 $t2 exit
sw $s7 0($a0)
sw $t1 0($t6)
mul $t6 $t5 4 #store a counter of rewritting the snake array to $t6
add $t7 $t6 $t4
lw $t7 0($t7)
sw $0 0($t7)
j reWriteSnakeArray



reWriteSnakeArray:
beqz $t6 finishReWriteSnake	#check if the counter is less than, if less than zero, then finished rewriting the snake
addi $t7 $t6 -4		#get the adder to get the second to tail
add $t7 $t7 $t4	#get the location of the second to tail in memory
lw $t7 0($t7) 	#get the location of the second to tail
add $s1 $t6 $t4 	#get the location of tail in memory
sw $t7  0($s1) 	#save the second to tail 
addi $t6 $t6 -4
j reWriteSnakeArray

finishReWriteSnake:
sw $a0 0($t4) #update the loaction of the head in snake array
j gameLoop


 
getInput:
	li $s4, 0xffff0000
	lw $t9, 0($s4)
	bnez $t9, read_val
	li $v0, 0 # If $s2 has zero, there is no value to read, ret 0	
	jr $ra
	read_val:
		# Read value cause there is something there!
		lw $v0, 4($s4)
	jr $ra


exit: 
#print game over message
li $v0, 4
la $a0 deadMessage
syscall


li $v0 10
syscall
