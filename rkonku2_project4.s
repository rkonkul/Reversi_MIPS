#Ryan Konkul
#CS366
#Project 4
#Reversi/Othello Reloaded
#4/27/2011

#variable table
#t0: firstturn
#t7: validinput
#s5: anymovesleft
#s0: column
#s1: row
#s2: O
#s3: X
#s4: who's turn, 0 for human, 1 for comp
#s5: whether to execute a move or check
#s6: did player have no moves

#pseudocode
#cout << welcome
#t0 = random()
#if(t0 ==0)
#	computer is first
#else
#	player is first
#printboard
#cin >> player input
#while(possible moves available)
#if(checkinput)
#  if(move(col,row))
#  branch to computer turn
#  
#computer turn:
#for(each row,col)
#   if(move(col,row, computer))
#   break
#continue
#
#checkinput(col, row) {
#if(val(col,row) == '-'|| 'O' || 'X')
# return false
#}
# 
# move(col, row) {
# for(eachdirection) {
#     while(found opponent piece) {
#     look at next piece
#     }
#     if(see a '-' || out of bounds)
#    	 return false
#    else
#        while(not back to beginning)
#            flip pieces
#	return true
#}


.data
welcome0:	.asciiz "Welcome to the game of Othello, please give me a moment while "
welcome1:	.asciiz "I decide which player starts. \nPress any key to continue. "

newline:	.asciiz "\n\n"
board0:	   .asciiz "  a b c d e f g h\n"
board1:		.ascii "1 - - - - - - - -\n"
board2:		.ascii "2 - - - - - - - -\n"
board3:		.ascii "3 - - - - - - - -\n"
board4:		.ascii "4 - - - X O - - -\n"
board5:		.ascii "5 - - - O X - - -\n"
board6:		.ascii "6 - - - - - - - -\n"
board7:		.ascii "7 - - - - - - - -\n"
board8:	   .asciiz "8 - - - - - - - -"

firstturn0:	.asciiz "Computer moves first...\n"
firstturn1:	.asciiz "Player moves first...\n"
prompt:		.asciiz "\nSelect column and row for O: "
invalid:	.asciiz "\nInvalid input. Try again.\n"
illegal:	.asciiz "\nIllegal move. Try again.\n"
nomoves:	.asciiz "\nComputer had no moves. "
pnomoves:	.asciiz "\nPlayer had no moves."
totalnomoves: .asciiz "\nNo moves at all. "
playerwon:	.asciiz "\nPlayer has won!"
computerwon: .asciiz "\nComputer has won!"
draw:		.asciiz "It's a draw!"

.text
main:
li	$s2, 79		#s2 = 'O'
li	$s3, 88		#s3 = 'X'

la	$a0, welcome0	#print welcome messages
jal PrintString
la	$a0, welcome1
jal PrintString

addiu $sp, $sp -4	#call Wait
jal Wait
lw $s7, 0($sp)		#get "random" seed
addiu $sp, $sp, 4	

addiu $sp, $sp, -4
sw $s7, 0($sp)
jal Random
lw $s7, 0($sp)
addiu $sp, $sp, 4

li $v0, 1
move $a0, $s7

andi $s7, $s7, 1 #isolate first bit

la	$a0, newline
jal	PrintString

la	$a0, board0
jal	PrintString

la	$a0, board1
jal	PrintString

la	$a0, newline
jal PrintString

bnez	$s7, compfirst #if random == 0, comp is first
b	playerfirst	#else, player goes first

compfirst:
la	$a0, firstturn0
jal PrintString

la	$t4, board4	#hardcode first turn of comp
add	$t4, $t4, 12
li	$t3, 88
sb	$t3($t4)	#place X in f4
la	$t4, board4
add	$t4, $t4, 10
li	$t3, 88
sb	$t3($t4)	#place X in e4

la	$a0, board0
jal PrintString

la	$a0, board1
jal PrintString

b 	gameplay
playerfirst:
la	$a0, firstturn1	#player goes first
jal PrintString

gameplay:

gameplayanymoves:
li	$s0, 97	#1st col
li	$s1, 1	#1st row
li	$s4, 0	#human is playing
gameplayanymovesloop1:
bge	$s0, 105, gameplayanymovesloop2
bge	$s1, 9, gameplaynomoves

addiu $sp, $sp, -16	#begin code to call checkinput
sw	$s0, 0($sp)	#store column
sw	$s1, 4($sp)	#store row
sw	$ra, 12($sp)	#store return address
jal 	checkinput
lw	$ra, 12($sp)
lw	$t7, 8($sp)	#t7 is 0 if ok
addiu	$sp, $sp, 16	#deallocate
bnez	$t7, gameplayanymovesloop3#if value returned is invalid
li	$s5, 0	#just check dont move
addiu	$sp, $sp, -16
sw	$s4, 0($sp)
sw	$s5, 8($sp)
sw	$ra, 12($sp)
jal	move
lw	$v0, 4($sp)
lw	$ra, 12($sp)

gameplayanymovesloop3:
add	$s0, $s0, 1
bnez	$v0, gameplayanymovesloop1#if invalid move, test another
b	gameplayanymovesdone

gameplayanymovesloop2:
li	$s0, 97		#reset column
add	$s1, $s1, 1	#increment row
b	gameplayanymovesloop1

gameplaynomoves:
la	$a0, pnomoves
jal PrintString
li	$s6, 1	#flag player had no moves
b	computerturn

gameplayanymovesdone:
la	$a0, prompt
jal PrintString

jal	ReadChar
move	$s0, $v0	#store in s0
jal ReadChar
move	$s1, $v0	#store row in s1

sub	$s1, $s1, 48	#convert ascii char to integer
beqz	$s1, finish	#0 to quit

addiu $sp, $sp, -16	#begin code to call checkinput
sw	$s0, 0($sp)	#store column
sw	$s1, 4($sp)	#store row
sw	$ra, 12($sp)	#store return address
jal 	checkinput
lw	$ra, 12($sp)
lw	$t7, 8($sp)	#t7 is 0 if ok
addiu	$sp, $sp, 16	#deallocate
bnez	$t7, inval	#if value returned is invalid
b	gameplay1
inval:
la	$a0, invalid
jal PrintString
b	gameplay


gameplay1:
li	$s4, 0	#human is playing
li	$s5, 1	#dont just test, make the move
addiu	$sp, $sp, -16	#try the player's move
sw	$s4, 0($sp)
sw	$s5, 8($sp)
sw	$ra, 12($sp)
jal	move
lw	$v0, 4($sp)
lw	$ra, 12($sp)

bnez	$v0, illegalmove #if illegal move

b gameplay2

gameplay2:


la	$a0, newline
jal PrintString
la	$a0, board0
jal PrintString
la	$a0, board1
jal PrintString
b	computerturn

playerpass:
li	$s6, 1	#set flag for player passed
computerturn:
li	$s0, 97	#1st col
li	$s1, 1	#1st row
li	$s4, 1	#comp is playing
computerloop1:
bge	$s0, 105, computerloop2
bge	$s1, 9, computernomoves

addiu $sp, $sp, -16	#begin code to call checkinput
sw	$s0, 0($sp)	#store column
sw	$s1, 4($sp)	#store row
sw	$ra, 12($sp)	#store return address
jal 	checkinput
lw	$ra, 12($sp)
lw	$t7, 8($sp)	#t7 is 0 if ok
addiu	$sp, $sp, 16	#deallocate
bnez	$t7, computerloop3	#if value returned is invalid
li	$s5, 1	#make move
addiu	$sp, $sp, -16	
sw	$s4, 0($sp)
sw	$s5, 8($sp)
sw	$ra, 12($sp)
jal	move
lw	$v0, 4($sp)
lw	$ra, 12($sp)

computerloop3:
add	$s0, $s0, 1
bnez	$v0, computerloop1	#if invalid move, try another
b	computerdone

computerloop2:
li	$s0, 97		#reset column
add	$s1, $s1, 1	#increment row
b	computerloop1

computernomoves:


la	$a0, nomoves	#print no moves
jal PrintString

beq	$s6, 1, totlnomoves	#if player had no moves, end game
b	computerdone

totlnomoves:

la	$a0, totalnomoves	#print no moves for either player
jal PrintString

b	endgame			#count and declare winner

computerdone:
li	$s6, 0	#set player had made move

la	$a0, newline
jal PrintString
la	$a0, board0
jal PrintString
la	$a0, board1
jal PrintString

b gameplay

finish:
li	$v0, 10
syscall

endgame:
li	$s0, 97	#a
li	$s1, 1	#a
li	$t4, 0	#counter for O
li	$t5, 0	#counter for X

endgameloop1:
bge	$s1, 9, endgamedone

addiu   $sp, $sp, -28	#begin code to call getval
la	$t8, board1
sw	$t8, 0($sp)
sw	$s0, 4($sp)	#store column
sw	$s1, 8($sp)	#store row
sw	$t5, 16($sp)	#preserve t5
sw	$t4, 20($sp)	#preserve t4
sw	$ra, 24($sp)	#store return address
jal 	getval
lw	$ra, 24($sp)
lw	$t5, 16($sp)	
lw	$t4, 20($sp)	
lw	$t7, 12($sp)	#t7 is the value returned
addiu	$sp, $sp, 28	#deallocate

beq	$t7, 79, endO	#count an O
beq	$t7, 88, endX	#count an X
b	endgameloop2
endO:
add	$t4, $t4, 1
b	endgameloop2
endX:
add	$t5, $t5, 1
b	endgameloop2

endgameloop2:
add	$s0, $s0, 1	#increment column
bge	$s0, 105, endgamereset #if end of column
b	endgameloop1
endgamereset:
li	$s0, 97		#reset column counter
add	$s1, $s1, 1	#increment row
b	endgameloop1

endgamedone:
bgt	$t4, $t5, pwon	#player won
beq	$t4, $t5, drw	#draw
b	compwon

pwon:
la	$a0, playerwon
jal PrintString
b	finish
drw:
la	$a0, draw
jal PrintString
b	finish
compwon:
la	$a0, computerwon
jal PrintString
b	finish


illegalmove:
la	$a0, illegal
jal PrintString
b  	gameplay

#get the value at col,row 
#getval(address, col, row, value)
getval:
lw	$t5, 0($sp)	#get address
lw	$t6, 4($sp)	#get column
lw	$t7, 8($sp)	#get row
sub	$t6, $t6, 96	#convert [a-h] to [1-8] 
sub	$t7, $t7, 1	#subtract 1 to fix mult factor
li	$t4, 18		#18 is num chars in row
mult	$t4, $t7	#mult col offset
mflo	$t7
sll	$t6, $t6, 1	#mult by 2 to skip spaces
		
add	$t5, $t5, $t6	#add column offset
add	$t6, $t5, $t7	#add row offset
lb	$s7($t6)	#set value from address

sw	$s7, 12($sp)	#store return value on stack
jr	$ra
#end function getval

#set the value at col,row 
#setval(address, col, row, value)
setval:
lw	$t5, 0($sp)	#get address
lw	$t6, 4($sp)	#get column
lw	$t7, 8($sp)	#get row
lw	$s7, 12($sp)	#get value to set
sub	$t6, $t6, 96	#convert [a-h] to [1-8] 
sub	$t7, $t7, 1	#subtract 1 to fix mult factor
li	$t4, 18		#18 is num chars in row
mult	$t4, $t7	#mult col offset
mflo	$t7
sll	$t6, $t6, 1	#mult by 2 to skip spaces
		
add	$t5, $t5, $t6	#add column offset
add	$t6, $t5, $t7	#add row offset
sb	$s7($t6)	#set value from address

jr	$ra
#end function setval

#checkingput(col, row, valid)
#returns 0 if valid, 1 otherwise
checkinput:
lw	$t6, 0($sp)	#get column
lw	$t7, 4($sp)	#get row
sub	$t5, $t6, 97	#if ascii value > a, should be higher than 96
bltz	$t5, error
bgt	$t6, 104, error	#h is 104, if greater, error

blez	$t7, error	#if row is <0
bgt	$t7, 8, error	#if row > 8

addiu $sp, $sp, -20	#begin code to call getval
la	$t0, board1
sw	$t0, 0($sp)
sw	$s0, 4($sp)	#store column
sw	$s1, 8($sp)	#store row
sw	$ra, 16($sp)	#store return address
jal 	getval
lw	$ra, 16($sp)
lw	$t7, 12($sp)	#t7 is the value returned
addiu	$sp, $sp, 20	#deallocate

bne	$t7, 45, error	#if getval is not a '-'

li	$t5, 0		#at this point, ok input
b	chkret
error:
li	$t5, 1
chkret:			#checkinputreturn
sw	$t5, 8($sp) 	#place return value on stack
jr	$ra

#rand(r)
#generates a random number given a seed
Random:
lw	$v0, 0($sp)
mulu $v0, $v0, 373457
addiu $v0, $v0, 65854832
sw  $v0, 0($sp)
jr $ra


#function to print string
#takes a0 as address 
PrintString:
li   $t0, 0xffff0008        #t0=0xffff0008
move $t2, $a0
lb	 $t1, ($t2)
printloop:
lw   $v0, 0($t0)
andi $v0, $v0, 0x01			#check ready bit
beq  $v0, $zero, printloop	#loop if not ready
sw   $t1, 4($t0)			#print t2
addiu $t2, $t2, 1
lb	 $t1, ($t2)
bnez $t1, printloop
jr $ra

#function to read a char and echos
#return in v0
ReadChar:
lui  $t0, 0xFFFF         	#$t0 = 0xFFFF0000;
ReadLoop:   
lw 	 $t1, 0($t0)          	#$t1 = *($t0);
andi $t1, $t1, 0x0001   	#$t1 &= 0x00000001;
beq  $t1, $zero, ReadLoop 	#} while ($t1 == 0);
lw   $v0, 4($t0)        	#$v0 = *($t0 + 1);
move $t1, $v0

li   $t0, 0xffff0008        #t0=0xffff0008
ReadCharprntloop:
lw   $v0, 0($t0)
andi $v0, $v0, 0x01			#check ready bit
beq  $v0, $zero, ReadCharprntloop	#loop if not ready
sw   $t1, 4($t0)			#echo t1
move $v0, $t1
jr	 $ra

#waits for 1 char
#returns clock cycles passed / 3
Wait:
lui  $t0, 0xFFFF         	#$t0 = 0xFFFF0000;
li   $a0, 0
WReadLoop:   
lw 	 $t1, 0($t0)          	#$t1 = *($t0);
andi $t1, $t1, 0x0001   	#$t1 &= 0x00000001;
addi $a0, $a0, 1
beq  $t1, $zero, WReadLoop 	#} while ($t1 == 0);
lw   $v0, 4($t0)        	#$v0 = *($t0 + 1);
move $t1, $v0

li   $t0, 0xffff0008        #t0=0xffff0008
WReadCharprntloop:
lw   $v0, 0($t0)
andi $v0, $v0, 0x01			#check ready bit
beq  $v0, $zero, WReadCharprntloop	#loop if not ready
sw   $t1, 4($t0)			#echo t1
sw	 $a0, 0($sp)
jr	 $ra

#returns 0 if made a correct move, 1 if illegal
#calls each of eight directions
#if any values returned == 0, then valid move was made
move:
li	$t0, 1		#t0 is whether made correct move, assume didnt

right:
addiu	$sp, $sp, -16	#allocate 
sw	$s4, 4($sp)	#store whether comp of human is playing
sw	$s5, 8($sp)	#whether make move or not
sw	$ra, 12($sp)	#store return address
jal	rightdir
lw	$v0, 0($sp)	#get made valid move flag
lw	$ra, 12($sp)	#get return address
addiu	$sp, $sp, 16 	#deallocate stack

beqz	$v0, rightlegal	#if v0 == 0, made legal move
b	botright	#else continue to next function

rightlegal:
li	$t0, 0

botright:

addiu	$sp, $sp, -16	#allocate 
sw	$s4, 4($sp)	#store whether comp of human is playing
sw	$s5, 8($sp)	#whether make move or not
sw	$ra, 12($sp)	#store return address
jal	botrightdir	
lw	$v0, 0($sp)	#get made valid move flag
lw	$ra, 12($sp)	#get return address
addiu	$sp, $sp, 16 	#deallocate stack

beqz	$v0, botrightlegal
b	bottom
botrightlegal:

li	$t0, 0
bottom:

addiu	$sp, $sp, -16	#allocate 
sw	$s4, 4($sp)	#store whether comp of human is playing
sw	$s5, 8($sp)	#whether make move or not
sw	$ra, 12($sp)	#store return address
jal	bottomdir	
lw	$v0, 0($sp)	#get made valid move flag
lw	$ra, 12($sp)	#get return address
addiu	$sp, $sp, 16 	#deallocate stack

beqz	$v0, bottomlegal
b 	botleft

bottomlegal:
li	$t0, 0
botleft:
addiu	$sp, $sp, -16	#allocate 
sw	$s4, 4($sp)	#store whether comp of human is playing
sw	$s5, 8($sp)	#whether make move or not
sw	$ra, 12($sp)	#store return address
jal	botleftdir	
lw	$v0, 0($sp)	#get made valid move flag
lw	$ra, 12($sp)	#get return address
addiu	$sp, $sp, 16 	#deallocate stack

beqz	$v0, botleftlegal
b 	left

botleftlegal:
li	$t0, 0
left:
addiu	$sp, $sp, -16	#allocate 
sw	$s4, 4($sp)	#store whether comp of human is playing
sw	$s5, 8($sp)	#whether make move or not
sw	$ra, 12($sp)	#store return address
jal	leftdir	
lw	$v0, 0($sp)	#get made valid move flag
lw	$ra, 12($sp)	#get return address
addiu	$sp, $sp, 16 	#deallocate stack

beqz	$v0, leftlegal
b	topleft

leftlegal:
li	$t0, 0
topleft:
addiu	$sp, $sp, -16	#allocate 
sw	$s4, 4($sp)	#store whether comp of human is playing
sw	$s5, 8($sp)	#whether make move or not
sw	$ra, 12($sp)	#store return address
jal	topleftdir	
lw	$v0, 0($sp)	#get made valid move flag
lw	$ra, 12($sp)	#get return address
addiu	$sp, $sp, 16 	#deallocate stack

beqz	$v0, topleftlegal
b	top
topleftlegal:
li	$t0, 0
top:
addiu	$sp, $sp, -16	#allocate 
sw	$s4, 4($sp)	#store whether comp of human is playing
sw	$s5, 8($sp)	#whether make move or not
sw	$ra, 12($sp)	#store return address
jal	topdir	
lw	$v0, 0($sp)	#get made valid move flag
lw	$ra, 12($sp)	#get return address
addiu	$sp, $sp, 16 	#deallocate stack

beqz	$v0, toplegal
b	topright
toplegal:
li	$t0, 0
topright:
addiu	$sp, $sp, -16	#allocate 
sw	$s4, 4($sp)	#store whether comp of human is playing
sw	$s5, 8($sp)	#whether make move or not
sw	$ra, 12($sp)	#store return address
jal	toprightdir
lw	$v0, 0($sp)	#get made valid move flag
lw	$ra, 12($sp)	#get return address
addiu	$sp, $sp, 16 	#deallocate stack

beqz	$v0, toprightlegal
b	movedone
toprightlegal:
li	$t0, 0

movedone:
beqz	$t0, movedone1	#if t0==0, legal move
li	$v0, 1		#else made illegal move
b	movedone2
movedone1:
li	$v0, 0
movedone2:
sw	$v0, 4($sp)
jr	$ra






rightdir:
lw	$t4, 4($sp)	#whether human or comp is playing
lw	$s5, 8($sp) #whether make move or not
beqz	$t4, hright	#human move
b 	cright		#computer move
hright:
move	$t1, $s0	#column
move	$t2, $s1	#row
add	$t1, $t1, 1	#increment to peek

addiu $sp, $sp, -20	#begin code to call getval
la	$t2, board1
sw	$t2, 0($sp)
sw	$t1, 4($sp)	#store column
sw	$s1, 8($sp)	#store row
sw	$ra, 16($sp)	#store return address
jal 	getval
lw	$ra, 16($sp)
lw	$t7, 12($sp)	#t7 is the value returned
addiu	$sp, $sp, 20	#deallocate

beq	$t7, 79, rightloopexitillegal	#if see a 'O'

move	$t3, $t1	#t3: counter for loop $t1 is flag for beginning
rightloop1:
bge	$t3, 105, rightloopdone

addiu $sp, $sp, -20	#begin code to call getval
la	$t2, board1
sw	$t2, 0($sp)
sw	$t3, 4($sp)	#store column
sw	$s1, 8($sp)	#store row
sw	$ra, 16($sp)	#store return address
jal 	getval
lw	$ra, 16($sp)
lw	$t7, 12($sp)	#t7 is the value returned
addiu	$sp, $sp, 20	#deallocate

beq	$t7, 45, rightloopexitillegal	#if see a '-'
beq	$t7, 79, rightloop2	#if see an 'O'
add	$t3, $t3, 1	#increment column counter
b	rightloop1
rightloopexitillegal:
li	$v0, 1		#illegalmove
b	rightloopdone
rightloop2:		#flipping loop
add	$t1, $t1, -1	#decrement to look at player selected piece
rightloop3:
li	$v0, 0		#made valid move
beqz $s5, rightloopdone #exit if only checking
add	$t3, $t3, -1	#look at previous piece

addiu $sp, $sp, -24	#begin code to call setval
la	$t0, board1
sw	$t0, 0($sp)	#store address of board
sw	$t3, 4($sp)	#store column, change for 8 functions
sw	$s1, 8($sp)	#store row
sw	$s2, 12($sp)	#store value
sw	$t2, 16($sp)	#save t2
sw	$ra, 20($sp)	#store return address
jal 	setval
lw	$t3, 4($sp)	#restore t3
lw	$t2, 8($sp)	#restore t2
lw	$ra, 20($sp)
addiu	$sp, $sp, 24	#deallocate

bne	$t3, $t1,rightloop3 #if counter equals starting point, finish
			#t1 is stoppingpoint, #t3 is counter back 
b	rightloopdone
			
cright:
move	$t1, $s0	#column
move	$t2, $s1	#row
add	$t1, $t1, 1	#increment to peek

addiu $sp, $sp, -20	#begin code to call getval
la	$t2, board1
sw	$t2, 0($sp)
sw	$t1, 4($sp)	#store column
sw	$s1, 8($sp)	#store row
sw	$ra, 16($sp)	#store return address
jal 	getval
lw	$ra, 16($sp)
lw	$t7, 12($sp)	#t7 is the value returned
addiu	$sp, $sp, 20	#deallocate

beq	$t7, 88, crightloopexitillegal	#if see a 'X'

move	$t3, $t1	#t3: counter for loop $t1 is flag for beginning
crightloop1:
bge	$t3, 105, rightloopdone

addiu $sp, $sp, -20	#begin code to call getval
la	$t2, board1
sw	$t2, 0($sp)
sw	$t3, 4($sp)	#store column
sw	$s1, 8($sp)	#store row
sw	$ra, 16($sp)	#store return address
jal 	getval
lw	$ra, 16($sp)
lw	$t7, 12($sp)	#t7 is the value returned
addiu	$sp, $sp, 20	#deallocate

beq	$t7, 45, crightloopexitillegal	#if see a '-'
beq	$t7, 88, crightloop2	#if see an 'X'
add	$t3, $t3, 1	#increment column counter
b	crightloop1
crightloopexitillegal:
li	$v0, 1		#illegalmove
b	rightloopdone
crightloop2:		#flipping loop
add	$t1, $t1, -1	#decrement to look at player selected piece
crightloop3:
li	$v0, 0		#made valid move
beqz $s5, rightloopdone #exit if only checking
add	$t3, $t3, -1	#look at previous piece


addiu $sp, $sp, -24	#begin code to call setval
la	$t0, board1
sw	$t0, 0($sp)	#store address of board
sw	$t3, 4($sp)	#store column, change for 8 functions
sw	$s1, 8($sp)	#store row
sw	$s3, 12($sp)	#store value
sw	$t2, 16($sp)	#save t2
sw	$ra, 20($sp)	#store return address
jal 	setval
lw	$t3, 4($sp)	#restore t3
lw	$t2, 8($sp)	#restore t2
lw	$ra, 20($sp)
addiu	$sp, $sp, 24	#deallocate

bne	$t3, $t1,crightloop3 #if counter equals starting point, finish
			#t1 is stoppingpoint, #t3 is counter back 
			
rightloopdone:

sw	$v0, 0($sp)
jr	$ra
#end rightdir function


#############################################################



botrightdir:
lw	$s4, 4($sp)	#whether human or comp is playing
lw	$s5, 8($sp)
beqz	$s4, hbotright	#human move
b 	cbotright	#computer move
hbotright:
move	$t1, $s0	#column
move	$t2, $s1	#row
add	$t1, $t1, 1	#increment to peek
add	$t2, $t2, 1

addiu   $sp, $sp, -20	#begin code to call getval
la	$t8, board1
sw	$t8, 0($sp)
sw	$t1, 4($sp)	#store column
sw	$t2, 8($sp)	#store row
sw	$ra, 16($sp)	#store return address
jal 	getval
lw	$ra, 16($sp)
lw	$t7, 12($sp)	#t7 is the value returned
addiu	$sp, $sp, 20	#deallocate

beq	$t7, 79, botrightloopexitillegal	#if see a 'O'

move	$t3, $t1	#t3: counter for loop $t1 is flag for beginning
move	$t4, $t2	#t4 counter 
botrightloop1:
bge	$t3, 105, botrightloopdone
bge	$t4, 9, botrightloopdone

addiu $sp, $sp, -20	#begin code to call getval
la	$t8, board1
sw	$t8, 0($sp)
sw	$t3, 4($sp)	#store column
sw	$t4, 8($sp)	#store row
sw	$ra, 16($sp)	#store return address
jal 	getval
lw	$t3, 4($sp)
lw	$t4, 8($sp)
lw	$ra, 16($sp)
lw	$t7, 12($sp)	#t7 is the value returned
addiu	$sp, $sp, 20	#deallocate

beq	$t7, 45, botrightloopexitillegal	#if see a '-'
beq	$t7, 79, botrightloop2	#if see an 'O'
add	$t3, $t3, 1	#increment column counter
add	$t4, $t4, 1
b	botrightloop1
botrightloopexitillegal:
li	$v0, 1		#illegalmove
b	botrightloopdone
botrightloop2:		#flipping loop

add	$t1, $t1, -1	#decrement to look at player selected piece
add	$t2, $t2, -1
botrightloop3:
li	$v0, 0		#made valid move
beqz $s5, botrightloopdone #exit if only checking
add	$t3, $t3, -1	#look at previous piece
add	$t4, $t4, -1

addiu $sp, $sp, -24	#begin code to call setval
la	$t8, board1
sw	$t8, 0($sp)	#store address of board
sw	$t3, 4($sp)	#store column, change for 8 functions
sw	$t4, 8($sp)	#store row
sw	$s2, 12($sp)	#store value
sw	$t2, 16($sp)	#save t2
sw	$ra, 20($sp)	#store return address
jal 	setval
lw	$t3, 4($sp)	#restore t3
lw	$t4, 8($sp)	#restore t2
lw	$ra, 20($sp)
addiu	$sp, $sp, 24	#deallocate

bne	$t3, $t1, botrightloop3 #if counter equals starting point, finish
			#t1 is stoppingpoint, #t3 is counter back 
b	botrightloopdone
			
cbotright:
move	$t1, $s0	#column
move	$t2, $s1	#row
add	$t1, $t1, 1	#increment to peek
add	$t2, $t2, 1	#change

addiu $sp, $sp, -20	#begin code to call getval
la	$t8, board1
sw	$t8, 0($sp)
sw	$t1, 4($sp)	#store column
sw	$t2, 8($sp)	#store row
sw	$ra, 16($sp)	#store return address
jal 	getval
lw	$ra, 16($sp)
lw	$t7, 12($sp)	#t7 is the value returned
addiu	$sp, $sp, 20	#deallocate

beq	$t7, 88, cbotrightloopexitillegal	#if see a 'X'

move	$t3, $t1	#t3: counter for loop $t1 is flag for beginning
move	$t4, $t2	#t4 counter change 
cbotrightloop1:
bge	$t3, 105, botrightloopdone
bge	$t4, 9, botrightloopdone

addiu $sp, $sp, -20	#begin code to call getval
la	$t8, board1
sw	$t8, 0($sp)
sw	$t3, 4($sp)	#store column
sw	$t4, 8($sp)	#store row
sw	$ra, 16($sp)	#store return address
jal 	getval
lw	$t3, 4($sp)
lw	$t4, 8($sp)
lw	$ra, 16($sp)
lw	$t7, 12($sp)	#t7 is the value returned
addiu	$sp, $sp, 20	#deallocate

beq	$t7, 45, cbotrightloopexitillegal	#if see a '-'
beq	$t7, 88, cbotrightloop2	#if see an 'X'
add	$t3, $t3, 1	#increment column counter
add	$t4, $t4, 1	#increment row, change
b	cbotrightloop1
cbotrightloopexitillegal:
li	$v0, 1		#illegalmove
b	botrightloopdone
cbotrightloop2:		#flipping loop
add	$t1, $t1, -1	#decrement to look at player selected piece
add	$t2, $t2, -1	#change
cbotrightloop3:
li	$v0, 0		#made valid move
beqz $s5, botrightloopdone #exit if only checking
add	$t3, $t3, -1	#look at previous piece
add	$t4, $t4, -1	#change


addiu $sp, $sp, -24	#begin code to call setval
la	$t8, board1
sw	$t8, 0($sp)	#store address of board
sw	$t3, 4($sp)	#store column, change for 8 functions
sw	$t4, 8($sp)	#store row
sw	$s3, 12($sp)	#store value
sw	$t2, 16($sp)	#save t2
sw	$ra, 20($sp)	#store return address
jal 	setval
lw	$t3, 4($sp)	#restore t3
lw	$t4, 8($sp)	#store row
lw	$ra, 20($sp)
addiu	$sp, $sp, 24	#deallocate

bne	$t3, $t1,cbotrightloop3 #if counter equals starting point, finish
			#t1 is stoppingpoint, #t3 is counter back 
			
botrightloopdone:

sw	$v0, 0($sp)
jr	$ra
#end botrightdir function


###############################################################################


bottomdir:

lw	$s4, 4($sp)	#whether human or comp is playing
lw	$s5, 8($sp)
beqz	$s4, hbottom	#human move
b 	cbottom	#computer move
hbottom:
move	$t1, $s0	#column
move	$t2, $s1	#row
add	$t1, $t1, 0	#increment to peek
add	$t2, $t2, 1

addiu   $sp, $sp, -20	#begin code to call getval
la	$t8, board1
sw	$t8, 0($sp)
sw	$t1, 4($sp)	#store column
sw	$t2, 8($sp)	#store row
sw	$ra, 16($sp)	#store return address
jal 	getval
lw	$ra, 16($sp)
lw	$t7, 12($sp)	#t7 is the value returned
addiu	$sp, $sp, 20	#deallocate

beq	$t7, 79, bottomloopexitillegal	#if see a 'O'

move	$t3, $t1	#t3: counter for loop $t1 is flag for beginning
move	$t4, $t2	#t4 counter 
bottomloop1:
bge	$t3, 105, bottomloopdone
bge	$t4, 9, bottomloopdone

addiu $sp, $sp, -20	#begin code to call getval
la	$t8, board1
sw	$t8, 0($sp)
sw	$t3, 4($sp)	#store column
sw	$t4, 8($sp)	#store row
sw	$ra, 16($sp)	#store return address
jal 	getval
lw	$t3, 4($sp)
lw	$t4, 8($sp)
lw	$ra, 16($sp)
lw	$t7, 12($sp)	#t7 is the value returned
addiu	$sp, $sp, 20	#deallocate

beq	$t7, 45, bottomloopexitillegal	#if see a '-'
beq	$t7, 79, bottomloop2	#if see an 'O'
add	$t3, $t3, 0	#increment column counter
add	$t4, $t4, 1
b	bottomloop1
bottomloopexitillegal:
li	$v0, 1		#illegalmove
b	bottomloopdone
bottomloop2:		#flipping loop
add	$t1, $t1, 0	#decrement to look at player selected piece
add	$t2, $t2, -1
bottomloop3:
li	$v0, 0		#made valid move
beqz $s5, bottomloopdone #exit if only checking
add	$t3, $t3, 0	#look at previous piece
add	$t4, $t4, -1

addiu $sp, $sp, -24	#begin code to call setval
la	$t8, board1
sw	$t8, 0($sp)	#store address of board
sw	$t3, 4($sp)	#store column, change for 8 functions
sw	$t4, 8($sp)	#store row
sw	$s2, 12($sp)	#store value
sw	$t2, 16($sp)	#save t2
sw	$ra, 20($sp)	#store return address
jal 	setval
lw	$t3, 4($sp)	#restore t3
lw	$t4, 8($sp)	#restore t2
lw	$ra, 20($sp)
addiu	$sp, $sp, 24	#deallocate

bne	$t2, $t4, bottomloop3 #if counter equals starting point, finish, change
			#t1 is stoppingpoint, #t3 is counter back 
b	bottomloopdone
			
cbottom:
move	$t1, $s0	#column
move	$t2, $s1	#row
add	$t1, $t1, 0	#increment to peek
add	$t2, $t2, 1	#change

addiu $sp, $sp, -20	#begin code to call getval
la	$t8, board1
sw	$t8, 0($sp)
sw	$t1, 4($sp)	#store column
sw	$t2, 8($sp)	#store row
sw	$ra, 16($sp)	#store return address
jal 	getval
lw	$ra, 16($sp)
lw	$t7, 12($sp)	#t7 is the value returned
addiu	$sp, $sp, 20	#deallocate

beq	$t7, 88, cbottomloopexitillegal	#if see a 'X'

move	$t3, $t1	#t3: counter for loop $t1 is flag for beginning
move	$t4, $t2	#t4 counter change 
cbottomloop1:
bge	$t3, 105, bottomloopdone
bge	$t4, 9, bottomloopdone

addiu $sp, $sp, -20	#begin code to call getval
la	$t8, board1
sw	$t8, 0($sp)
sw	$t3, 4($sp)	#store column
sw	$t4, 8($sp)	#store row
sw	$ra, 16($sp)	#store return address
jal 	getval
lw	$t3, 4($sp)
lw	$t4, 8($sp)
lw	$ra, 16($sp)
lw	$t7, 12($sp)	#t7 is the value returned
addiu	$sp, $sp, 20	#deallocate

beq	$t7, 45, cbottomloopexitillegal	#if see a '-'
beq	$t7, 88, cbottomloop2	#if see an 'X'
add	$t3, $t3, 0	#increment column counter
add	$t4, $t4, 1	#increment row, change
b	cbottomloop1
cbottomloopexitillegal:
li	$v0, 1		#illegalmove
b	bottomloopdone
cbottomloop2:		#flipping loop
add	$t1, $t1, 0	#decrement to look at player selected piece
add	$t2, $t2, -1	#change
cbottomloop3:
li	$v0, 0		#made valid move
beqz $s5, bottomloopdone #exit if only checking
add	$t3, $t3, 0	#look at previous piece
add	$t4, $t4, -1	#change

addiu $sp, $sp, -24	#begin code to call setval
la	$t8, board1
sw	$t8, 0($sp)	#store address of board
sw	$t3, 4($sp)	#store column, change for 8 functions
sw	$t4, 8($sp)	#store row
sw	$s3, 12($sp)	#store value
sw	$t2, 16($sp)	#save t2
sw	$ra, 20($sp)	#store return address
jal 	setval
lw	$t3, 4($sp)	#restore t3
lw	$t4, 8($sp)	#store row
lw	$ra, 20($sp)
addiu	$sp, $sp, 24	#deallocate

bne	$t2, $t4,cbottomloop3 #if counter equals starting point, finish
			#t1 is stoppingpoint, #t3 is counter back 
			
bottomloopdone:

sw	$v0, 0($sp)
jr	$ra
#end bottomdir function


########################################################################


botleftdir:
lw	$s4, 4($sp)	#whether human or comp is playing
lw	$s5, 8($sp)
beqz	$s4, hbotleft	#human move
b 	cbotleft	#computer move
hbotleft:
move	$t1, $s0	#column
move	$t2, $s1	#row
add	$t1, $t1, -1	#increment to peek
add	$t2, $t2, 1

addiu   $sp, $sp, -20	#begin code to call getval
la	$t8, board1
sw	$t8, 0($sp)
sw	$t1, 4($sp)	#store column
sw	$t2, 8($sp)	#store row
sw	$ra, 16($sp)	#store return address
jal 	getval
lw	$ra, 16($sp)
lw	$t7, 12($sp)	#t7 is the value returned
addiu	$sp, $sp, 20	#deallocate

beq	$t7, 79, botleftloopexitillegal	#if see a 'O'

move	$t3, $t1	#t3: counter for loop $t1 is flag for beginning
move	$t4, $t2	#t4 counter 
botleftloop1:
ble	$t3, 96, botleftloopdone
bge	$t4, 9, botleftloopdone

addiu $sp, $sp, -20	#begin code to call getval
la	$t8, board1
sw	$t8, 0($sp)
sw	$t3, 4($sp)	#store column
sw	$t4, 8($sp)	#store row
sw	$ra, 16($sp)	#store return address
jal 	getval
lw	$t3, 4($sp)
lw	$t4, 8($sp)
lw	$ra, 16($sp)
lw	$t7, 12($sp)	#t7 is the value returned
addiu	$sp, $sp, 20	#deallocate

beq	$t7, 45, botleftloopexitillegal	#if see a '-'
beq	$t7, 79, botleftloop2	#if see an 'O'
add	$t3, $t3, -1	#increment column counter
add	$t4, $t4, 1
b	botleftloop1
botleftloopexitillegal:
li	$v0, 1		#illegalmove
b	botleftloopdone
botleftloop2:		#flipping loop
add	$t1, $t1, 1	#decrement to look at player selected piece
add	$t2, $t2, -1
botleftloop3:
li	$v0, 0		#made valid move
beqz $s5, botleftloopdone #exit if only checking
add	$t3, $t3, 1	#look at previous piece
add	$t4, $t4, -1

addiu $sp, $sp, -24	#begin code to call setval
la	$t8, board1
sw	$t8, 0($sp)	#store address of board
sw	$t3, 4($sp)	#store column, change for 8 functions
sw	$t4, 8($sp)	#store row
sw	$s2, 12($sp)	#store value
sw	$t2, 16($sp)	#save t2
sw	$ra, 20($sp)	#store return address
jal 	setval
lw	$t3, 4($sp)	#restore t3
lw	$t4, 8($sp)	#restore t2
lw	$ra, 20($sp)
addiu	$sp, $sp, 24	#deallocate

bne	$t2, $t4, botleftloop3 #if counter equals starting point, finish, change
			#t1 is stoppingpoint, #t3 is counter back 
b	botleftloopdone
			
cbotleft:
move	$t1, $s0	#column
move	$t2, $s1	#row
add	$t1, $t1, -1	#increment to peek
add	$t2, $t2, 1	#change

addiu $sp, $sp, -20	#begin code to call getval
la	$t8, board1
sw	$t8, 0($sp)
sw	$t1, 4($sp)	#store column
sw	$t2, 8($sp)	#store row
sw	$ra, 16($sp)	#store return address
jal 	getval
lw	$ra, 16($sp)
lw	$t7, 12($sp)	#t7 is the value returned
addiu	$sp, $sp, 20	#deallocate

beq	$t7, 88, cbotleftloopexitillegal	#if see a 'X'

move	$t3, $t1	#t3: counter for loop $t1 is flag for beginning
move	$t4, $t2	#t4 counter change 
cbotleftloop1:
ble	$t3, 96, bottomloopdone
bge	$t4, 9, bottomloopdone

addiu $sp, $sp, -20	#begin code to call getval
la	$t8, board1
sw	$t8, 0($sp)
sw	$t3, 4($sp)	#store column
sw	$t4, 8($sp)	#store row
sw	$ra, 16($sp)	#store return address
jal 	getval
lw	$t3, 4($sp)
lw	$t4, 8($sp)
lw	$ra, 16($sp)
lw	$t7, 12($sp)	#t7 is the value returned
addiu	$sp, $sp, 20	#deallocate

beq	$t7, 45, cbotleftloopexitillegal	#if see a '-'
beq	$t7, 88, cbotleftloop2	#if see an 'X'
add	$t3, $t3, -1	#increment column counter
add	$t4, $t4, 1	#increment row, change
b	cbotleftloop1
cbotleftloopexitillegal:
li	$v0, 1		#illegalmove
b	botleftloopdone
cbotleftloop2:		#flipping loop
add	$t1, $t1, 1	#decrement to look at player selected piece
add	$t2, $t2, -1	#change
cbotleftloop3:
li	$v0, 0		#made valid move
beqz $s5, botleftloopdone #exit if only checking
add	$t3, $t3, 1	#look at previous piece
add	$t4, $t4, -1	#change

addiu $sp, $sp, -24	#begin code to call setval
la	$t8, board1
sw	$t8, 0($sp)	#store address of board
sw	$t3, 4($sp)	#store column, change for 8 functions
sw	$t4, 8($sp)	#store row
sw	$s3, 12($sp)	#store value
sw	$t2, 16($sp)	#save t2
sw	$ra, 20($sp)	#store return address
jal 	setval
lw	$t3, 4($sp)	#restore t3
lw	$t4, 8($sp)	#store row
lw	$ra, 20($sp)
addiu	$sp, $sp, 24	#deallocate

bne	$t2, $t4,cbotleftloop3 #if counter equals starting point, finish
			#t1 is stoppingpoint, #t3 is counter back 
			
botleftloopdone:

sw	$v0, 0($sp)
jr	$ra
#end bottomdir function


########################################################################

leftdir:

lw	$s4, 4($sp)	#whether human or comp is playing
lw	$s5, 8($sp) #make move
beqz	$s4, hleft	#human move
b 	cleft	#computer move
hleft:
move	$t1, $s0	#column
move	$t2, $s1	#row
add	$t1, $t1, -1	#increment to peek
add	$t2, $t2, 0

addiu   $sp, $sp, -20	#begin code to call getval
la	$t8, board1
sw	$t8, 0($sp)
sw	$t1, 4($sp)	#store column
sw	$t2, 8($sp)	#store row
sw	$ra, 16($sp)	#store return address
jal 	getval
lw	$ra, 16($sp)
lw	$t7, 12($sp)	#t7 is the value returned
addiu	$sp, $sp, 20	#deallocate

beq	$t7, 79, leftloopexitillegal	#if see a 'O'

move	$t3, $t1	#t3: counter for loop $t1 is flag for beginning
move	$t4, $t2	#t4 counter 
leftloop1:
ble	$t3, 96, leftloopdone
ble	$t4, 0, leftloopdone

addiu $sp, $sp, -20	#begin code to call getval
la	$t8, board1
sw	$t8, 0($sp)
sw	$t3, 4($sp)	#store column
sw	$t4, 8($sp)	#store row
sw	$ra, 16($sp)	#store return address
jal 	getval
lw	$t3, 4($sp)
lw	$t4, 8($sp)
lw	$ra, 16($sp)
lw	$t7, 12($sp)	#t7 is the value returned
addiu	$sp, $sp, 20	#deallocate

beq	$t7, 45, leftloopexitillegal	#if see a '-'
beq	$t7, 79, leftloop2	#if see an 'O'
add	$t3, $t3, -1	#increment column counter
add	$t4, $t4, 0
b	leftloop1
leftloopexitillegal:
li	$v0, 1		#illegalmove
b	leftloopdone
leftloop2:		#flipping loop
add	$t1, $t1, 1	#decrement to look at player selected piece
add	$t2, $t2, 0
leftloop3:
li	$v0, 0		#made valid move
beqz $s5, leftloopdone #exit if only checking
add	$t3, $t3, 1	#look at previous piece
add	$t4, $t4, 0

addiu $sp, $sp, -24	#begin code to call setval
la	$t8, board1
sw	$t8, 0($sp)	#store address of board
sw	$t3, 4($sp)	#store column, change for 8 functions
sw	$t4, 8($sp)	#store row
sw	$s2, 12($sp)	#store value
sw	$t2, 16($sp)	#save t2
sw	$ra, 20($sp)	#store return address
jal 	setval
lw	$t3, 4($sp)	#restore t3
lw	$t4, 8($sp)	#restore t2
lw	$ra, 20($sp)
addiu	$sp, $sp, 24	#deallocate

bne	$t1, $t3, leftloop3 #if counter equals starting point, finish, change
			#t1 is stoppingpoint, #t3 is counter back 
b	leftloopdone
			
cleft:
move	$t1, $s0	#column
move	$t2, $s1	#row
add	$t1, $t1, -1	#increment to peek
add	$t2, $t2, 0	#change

addiu $sp, $sp, -20	#begin code to call getval
la	$t8, board1
sw	$t8, 0($sp)
sw	$t1, 4($sp)	#store column
sw	$t2, 8($sp)	#store row
sw	$ra, 16($sp)	#store return address
jal 	getval
lw	$ra, 16($sp)
lw	$t7, 12($sp)	#t7 is the value returned
addiu	$sp, $sp, 20	#deallocate

beq	$t7, 88, cleftloopexitillegal	#if see a 'X'

move	$t3, $t1	#t3: counter for loop $t1 is flag for beginning
move	$t4, $t2	#t4 counter change 
cleftloop1:
ble	$t3, 96, leftloopdone
ble	$t4, 0, leftloopdone

addiu $sp, $sp, -20	#begin code to call getval
la	$t8, board1
sw	$t8, 0($sp)
sw	$t3, 4($sp)	#store column
sw	$t4, 8($sp)	#store row
sw	$ra, 16($sp)	#store return address
jal 	getval
lw	$t3, 4($sp)
lw	$t4, 8($sp)
lw	$ra, 16($sp)
lw	$t7, 12($sp)	#t7 is the value returned
addiu	$sp, $sp, 20	#deallocate

beq	$t7, 45, cleftloopexitillegal	#if see a '-'
beq	$t7, 88, cleftloop2	#if see an 'X'
add	$t3, $t3, -1	#increment column counter
add	$t4, $t4, 0	#increment row, change
b	cleftloop1
cleftloopexitillegal:
li	$v0, 1		#illegalmove
b	leftloopdone
cleftloop2:		#flipping loop
add	$t1, $t1, 1	#decrement to look at player selected piece
add	$t2, $t2, 0	#change
cleftloop3:
li	$v0, 0		#made valid move
beqz $s5, leftloopdone #exit if only checking
add	$t3, $t3, 1	#look at previous piece
add	$t4, $t4, 0	#change

addiu $sp, $sp, -24	#begin code to call setval
la	$t8, board1
sw	$t8, 0($sp)	#store address of board
sw	$t3, 4($sp)	#store column, change for 8 functions
sw	$t4, 8($sp)	#store row
sw	$s3, 12($sp)	#store value
sw	$t2, 16($sp)	#save t2
sw	$ra, 20($sp)	#store return address
jal 	setval
lw	$t3, 4($sp)	#restore t3
lw	$t4, 8($sp)	#store row
lw	$ra, 20($sp)
addiu	$sp, $sp, 24	#deallocate

bne	$t1, $t3,cleftloop3 #if counter equals starting point, finish
			#t1 is stoppingpoint, #t3 is counter back 
			
leftloopdone:

sw	$v0, 0($sp)
jr	$ra
#end leftdir function


########################################################################


topleftdir:

lw	$s4, 4($sp)	#whether human or comp is playing
lw	$s5, 8($sp)
beqz	$s4, htopleft	#human move
b 	ctopleft	#computer move
htopleft:
move	$t1, $s0	#column
move	$t2, $s1	#row
add	$t1, $t1, -1	#increment to peek
add	$t2, $t2, -1

addiu   $sp, $sp, -20	#begin code to call getval
la	$t8, board1
sw	$t8, 0($sp)
sw	$t1, 4($sp)	#store column
sw	$t2, 8($sp)	#store row
sw	$ra, 16($sp)	#store return address
jal 	getval
lw	$ra, 16($sp)
lw	$t7, 12($sp)	#t7 is the value returned
addiu	$sp, $sp, 20	#deallocate

beq	$t7, 79, topleftloopexitillegal	#if see a 'O'

move	$t3, $t1	#t3: counter for loop $t1 is flag for beginning
move	$t4, $t2	#t4 counter 
topleftloop1:
ble	$t3, 96, topleftloopdone
ble	$t4, 0, topleftloopdone

addiu $sp, $sp, -20	#begin code to call getval
la	$t8, board1
sw	$t8, 0($sp)
sw	$t3, 4($sp)	#store column
sw	$t4, 8($sp)	#store row
sw	$ra, 16($sp)	#store return address
jal 	getval
lw	$t3, 4($sp)
lw	$t4, 8($sp)
lw	$ra, 16($sp)
lw	$t7, 12($sp)	#t7 is the value returned
addiu	$sp, $sp, 20	#deallocate

beq	$t7, 45, topleftloopexitillegal	#if see a '-'
beq	$t7, 79, topleftloop2	#if see an 'O'
add	$t3, $t3, -1	#increment column counter
add	$t4, $t4, -1
b	topleftloop1
topleftloopexitillegal:
li	$v0, 1		#illegalmove
b	topleftloopdone
topleftloop2:		#flipping loop
add	$t1, $t1, 1	#decrement to look at player selected piece
add	$t2, $t2, 1
topleftloop3:
li	$v0, 0		#made valid move
beqz $s5, topleftloopdone #exit if only checking
add	$t3, $t3, 1	#look at previous piece
add	$t4, $t4, 1

addiu $sp, $sp, -24	#begin code to call setval
la	$t8, board1
sw	$t8, 0($sp)	#store address of board
sw	$t3, 4($sp)	#store column, change for 8 functions
sw	$t4, 8($sp)	#store row
sw	$s2, 12($sp)	#store value
sw	$t2, 16($sp)	#save t2
sw	$ra, 20($sp)	#store return address
jal 	setval
lw	$t3, 4($sp)	#restore t3
lw	$t4, 8($sp)	#restore t2
lw	$ra, 20($sp)
addiu	$sp, $sp, 24	#deallocate

bne	$t2, $t4, topleftloop3 #if counter equals starting point, finish, change
			#t1 is stoppingpoint, #t3 is counter back 
b	topleftloopdone
			
ctopleft:
move	$t1, $s0	#column
move	$t2, $s1	#row
add	$t1, $t1, -1	#increment to peek
add	$t2, $t2, -1	#change

addiu $sp, $sp, -20	#begin code to call getval
la	$t8, board1
sw	$t8, 0($sp)
sw	$t1, 4($sp)	#store column
sw	$t2, 8($sp)	#store row
sw	$ra, 16($sp)	#store return address
jal 	getval
lw	$ra, 16($sp)
lw	$t7, 12($sp)	#t7 is the value returned
addiu	$sp, $sp, 20	#deallocate

beq	$t7, 88, ctopleftloopexitillegal	#if see a 'X'

move	$t3, $t1	#t3: counter for loop $t1 is flag for beginning
move	$t4, $t2	#t4 counter change 
ctopleftloop1:
ble	$t3, 96, topleftloopdone
ble	$t4, 0, topleftloopdone

addiu $sp, $sp, -20	#begin code to call getval
la	$t8, board1
sw	$t8, 0($sp)
sw	$t3, 4($sp)	#store column
sw	$t4, 8($sp)	#store row
sw	$ra, 16($sp)	#store return address
jal 	getval
lw	$t3, 4($sp)
lw	$t4, 8($sp)
lw	$ra, 16($sp)
lw	$t7, 12($sp)	#t7 is the value returned
addiu	$sp, $sp, 20	#deallocate

beq	$t7, 45, ctopleftloopexitillegal	#if see a '-'
beq	$t7, 88, ctopleftloop2	#if see an 'X'
add	$t3, $t3, -1	#increment column counter
add	$t4, $t4, -1	#increment row, change
b	ctopleftloop1
ctopleftloopexitillegal:
li	$v0, 1		#illegalmove
b	topleftloopdone
ctopleftloop2:		#flipping loop
add	$t1, $t1, 1	#decrement to look at player selected piece
add	$t2, $t2, 1	#change
ctopleftloop3:
li	$v0, 0		#made valid move
beqz $s5, topleftloopdone #exit if only checking
add	$t3, $t3, 1	#look at previous piece
add	$t4, $t4, 1	#change

addiu $sp, $sp, -24	#begin code to call setval
la	$t8, board1
sw	$t8, 0($sp)	#store address of board
sw	$t3, 4($sp)	#store column, change for 8 functions
sw	$t4, 8($sp)	#store row
sw	$s3, 12($sp)	#store value
sw	$t2, 16($sp)	#save t2
sw	$ra, 20($sp)	#store return address
jal 	setval
lw	$t3, 4($sp)	#restore t3
lw	$t4, 8($sp)	#store row
lw	$ra, 20($sp)
addiu	$sp, $sp, 24	#deallocate

bne	$t2, $t4,ctopleftloop3 #if counter equals starting point, finish
			#t1 is stoppingpoint, #t3 is counter back 
			
topleftloopdone:

sw	$v0, 0($sp)
jr	$ra
#end topleftdir function


########################################################################

topdir:

lw	$s4, 4($sp)	#whether human or comp is playing
lw	$s5, 8($sp)
beqz	$s4, htop	#human move
b 	ctop	#computer move
htop:
move	$t1, $s0	#column
move	$t2, $s1	#row
add	$t1, $t1, 0	#increment to peek
add	$t2, $t2, -1

addiu   $sp, $sp, -20	#begin code to call getval
la	$t8, board1
sw	$t8, 0($sp)
sw	$t1, 4($sp)	#store column
sw	$t2, 8($sp)	#store row
sw	$ra, 16($sp)	#store return address
jal 	getval
lw	$ra, 16($sp)
lw	$t7, 12($sp)	#t7 is the value returned
addiu	$sp, $sp, 20	#deallocate

beq	$t7, 79, toploopexitillegal	#if see a 'O'

move	$t3, $t1	#t3: counter for loop $t1 is flag for beginning
move	$t4, $t2	#t4 counter 
toploop1:
ble	$t3, 96, toploopdone
ble	$t4, 0, toploopdone

addiu $sp, $sp, -20	#begin code to call getval
la	$t8, board1
sw	$t8, 0($sp)
sw	$t3, 4($sp)	#store column
sw	$t4, 8($sp)	#store row
sw	$ra, 16($sp)	#store return address
jal 	getval
lw	$t3, 4($sp)
lw	$t4, 8($sp)
lw	$ra, 16($sp)
lw	$t7, 12($sp)	#t7 is the value returned
addiu	$sp, $sp, 20	#deallocate

beq	$t7, 45, toploopexitillegal	#if see a '-'
beq	$t7, 79, toploop2	#if see an 'O'
add	$t3, $t3, 0	#increment column counter
add	$t4, $t4, -1
b	toploop1
toploopexitillegal:
li	$v0, 1		#illegalmove
b	toploopdone
toploop2:		#flipping loop
add	$t1, $t1, 0	#decrement to look at player selected piece
add	$t2, $t2, 1
toploop3:
li	$v0, 0		#made valid move
beqz $s5, toploopdone #exit if only checking
add	$t3, $t3, 0	#look at previous piece
add	$t4, $t4, 1

addiu $sp, $sp, -24	#begin code to call setval
la	$t8, board1
sw	$t8, 0($sp)	#store address of board
sw	$t3, 4($sp)	#store column, change for 8 functions
sw	$t4, 8($sp)	#store row
sw	$s2, 12($sp)	#store value
sw	$t2, 16($sp)	#save t2
sw	$ra, 20($sp)	#store return address
jal 	setval
lw	$t3, 4($sp)	#restore t3
lw	$t4, 8($sp)	#restore t2
lw	$ra, 20($sp)
addiu	$sp, $sp, 24	#deallocate

bne	$t2, $t4, toploop3 #if counter equals starting point, finish, change
			#t1 is stoppingpoint, #t3 is counter back 
b	toploopdone
			
ctop:
move	$t1, $s0	#column
move	$t2, $s1	#row
add	$t1, $t1, 0	#increment to peek
add	$t2, $t2, -1	#change

addiu $sp, $sp, -20	#begin code to call getval
la	$t8, board1
sw	$t8, 0($sp)
sw	$t1, 4($sp)	#store column
sw	$t2, 8($sp)	#store row
sw	$ra, 16($sp)	#store return address
jal 	getval
lw	$ra, 16($sp)
lw	$t7, 12($sp)	#t7 is the value returned
addiu	$sp, $sp, 20	#deallocate

beq	$t7, 88, ctoploopexitillegal	#if see a 'X'

move	$t3, $t1	#t3: counter for loop $t1 is flag for beginning
move	$t4, $t2	#t4 counter change 
ctoploop1:
ble	$t3, 96, toploopdone
ble	$t4, 0, toploopdone

addiu $sp, $sp, -20	#begin code to call getval
la	$t8, board1
sw	$t8, 0($sp)
sw	$t3, 4($sp)	#store column
sw	$t4, 8($sp)	#store row
sw	$ra, 16($sp)	#store return address
jal 	getval
lw	$t3, 4($sp)
lw	$t4, 8($sp)
lw	$ra, 16($sp)
lw	$t7, 12($sp)	#t7 is the value returned
addiu	$sp, $sp, 20	#deallocate

beq	$t7, 45, ctoploopexitillegal	#if see a '-'
beq	$t7, 88, ctoploop2	#if see an 'X'
add	$t3, $t3, 0	#increment column counter
add	$t4, $t4, -1	#increment row, change
b	ctoploop1
ctoploopexitillegal:
li	$v0, 1		#illegalmove
b	toploopdone
ctoploop2:		#flipping loop
add	$t1, $t1, 0	#decrement to look at player selected piece
add	$t2, $t2, 1	#change
ctoploop3:
li	$v0, 0		#made valid move
beqz $s5, toploopdone #exit if only checking
add	$t3, $t3, 0	#look at previous piece
add	$t4, $t4, 1	#change

addiu $sp, $sp, -24	#begin code to call setval
la	$t8, board1
sw	$t8, 0($sp)	#store address of board
sw	$t3, 4($sp)	#store column, change for 8 functions
sw	$t4, 8($sp)	#store row
sw	$s3, 12($sp)	#store value
sw	$t2, 16($sp)	#save t2
sw	$ra, 20($sp)	#store return address
jal 	setval
lw	$t3, 4($sp)	#restore t3
lw	$t4, 8($sp)	#store row
lw	$ra, 20($sp)
addiu	$sp, $sp, 24	#deallocate

bne	$t2, $t4,ctoploop3 #if counter equals starting point, finish
			#t1 is stoppingpoint, #t3 is counter back 
			
toploopdone:

sw	$v0, 0($sp)
jr	$ra
#end topleftdir function


########################################################################

toprightdir:
lw	$s4, 4($sp)	#whether human or comp is playing
lw	$s5, 8($sp)
beqz	$s4, htopright	#human move
b 	ctopright	#computer move
htopright:
move	$t1, $s0	#column
move	$t2, $s1	#row
add	$t1, $t1, 1	#increment to peek
add	$t2, $t2, -1

addiu   $sp, $sp, -20	#begin code to call getval
la	$t8, board1
sw	$t8, 0($sp)
sw	$t1, 4($sp)	#store column
sw	$t2, 8($sp)	#store row
sw	$ra, 16($sp)	#store return address
jal 	getval
lw	$ra, 16($sp)
lw	$t7, 12($sp)	#t7 is the value returned
addiu	$sp, $sp, 20	#deallocate

beq	$t7, 79, toprightloopexitillegal	#if see a 'O'

move	$t3, $t1	#t3: counter for loop $t1 is flag for beginning
move	$t4, $t2	#t4 counter 
toprightloop1:
bge	$t3, 105, toprightloopdone
ble	$t4, 0, toprightloopdone

addiu $sp, $sp, -20	#begin code to call getval
la	$t8, board1
sw	$t8, 0($sp)
sw	$t3, 4($sp)	#store column
sw	$t4, 8($sp)	#store row
sw	$ra, 16($sp)	#store return address
jal 	getval
lw	$t3, 4($sp)
lw	$t4, 8($sp)
lw	$ra, 16($sp)
lw	$t7, 12($sp)	#t7 is the value returned
addiu	$sp, $sp, 20	#deallocate

beq	$t7, 45, toprightloopexitillegal	#if see a '-'
beq	$t7, 79, toprightloop2	#if see an 'O'
add	$t3, $t3, 1	#increment column counter
add	$t4, $t4, -1
b	toprightloop1
toprightloopexitillegal:
li	$v0, 1		#illegalmove
b	toprightloopdone
toprightloop2:		#flipping loop
add	$t1, $t1, -1	#decrement to look at player selected piece
add	$t2, $t2, 1
toprightloop3:
li	$v0, 0		#made valid move
beqz $s5, toprightloopdone #exit if only checking
add	$t3, $t3, -1	#look at previous piece
add	$t4, $t4, 1

addiu $sp, $sp, -24	#begin code to call setval
la	$t8, board1
sw	$t8, 0($sp)	#store address of board
sw	$t3, 4($sp)	#store column, change for 8 functions
sw	$t4, 8($sp)	#store row
sw	$s2, 12($sp)	#store value
sw	$t2, 16($sp)	#save t2
sw	$ra, 20($sp)	#store return address
jal 	setval
lw	$t3, 4($sp)	#restore t3
lw	$t4, 8($sp)	#restore t2
lw	$ra, 20($sp)
addiu	$sp, $sp, 24	#deallocate

bne	$t2, $t4, toprightloop3 #if counter equals starting point, finish, change
			#t1 is stoppingpoint, #t3 is counter back 
b	toprightloopdone
			
ctopright:
move	$t1, $s0	#column
move	$t2, $s1	#row
add	$t1, $t1, 1	#increment to peek
add	$t2, $t2, -1	#change

addiu $sp, $sp, -20	#begin code to call getval
la	$t8, board1
sw	$t8, 0($sp)
sw	$t1, 4($sp)	#store column
sw	$t2, 8($sp)	#store row
sw	$ra, 16($sp)	#store return address
jal 	getval
lw	$ra, 16($sp)
lw	$t7, 12($sp)	#t7 is the value returned
addiu	$sp, $sp, 20	#deallocate

beq	$t7, 88, ctoprightloopexitillegal	#if see a 'X'
beq	$t7, 45, ctoprightloopexitillegal	#if see a '-'

move	$t3, $t1	#t3: counter for loop $t1 is flag for beginning
move	$t4, $t2	#t4 counter change 
ctoprightloop1:
bge	$t3, 105, toprightloopdone
ble	$t4, 0, toprightloopdone

addiu $sp, $sp, -20	#begin code to call getval
la	$t8, board1
sw	$t8, 0($sp)
sw	$t3, 4($sp)	#store column
sw	$t4, 8($sp)	#store row
sw	$ra, 16($sp)	#store return address
jal 	getval
lw	$t3, 4($sp)
lw	$t4, 8($sp)
lw	$ra, 16($sp)
lw	$t7, 12($sp)	#t7 is the value returned
addiu	$sp, $sp, 20	#deallocate

beq	$t7, 45, ctoprightloopexitillegal	#if see a '-'
beq	$t7, 88, ctoprightloop2	#if see an 'X'
add	$t3, $t3, 1	#increment column counter
add	$t4, $t4, -1	#increment row, change
b	ctoprightloop1
ctoprightloopexitillegal:
li	$v0, 1		#illegalmove
b	toploopdone
ctoprightloop2:		#flipping loop
add	$t1, $t1, -1	#decrement to look at player selected piece
add	$t2, $t2, 1	#change
ctoprightloop3:
li	$v0, 0		#made valid move
beqz $s5, toprightloopdone #exit if only checking
add	$t3, $t3, -1	#look at previous piece
add	$t4, $t4, 1	#change

addiu $sp, $sp, -24	#begin code to call setval
la	$t8, board1
sw	$t8, 0($sp)	#store address of board
sw	$t3, 4($sp)	#store column, change for 8 functions
sw	$t4, 8($sp)	#store row
sw	$s3, 12($sp)	#store value
sw	$t2, 16($sp)	#save t2
sw	$ra, 20($sp)	#store return address
jal 	setval
lw	$t3, 4($sp)	#restore t3
lw	$t4, 8($sp)	#store row
lw	$ra, 20($sp)
addiu	$sp, $sp, 24	#deallocate

bne	$t2, $t4,ctoprightloop3 #if counter equals starting point, finish
			#t1 is stoppingpoint, #t3 is counter back 
			
toprightloopdone:

sw	$v0, 0($sp)
jr	$ra
#end toprightdir function


########################################################################

