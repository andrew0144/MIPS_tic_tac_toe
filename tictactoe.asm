.data
	xAxis: .asciiz " 012"
	newLine: .asciiz "\n"
	xPrompt: .asciiz "X: "
	yPrompt: .asciiz "Y: "
	userPlayedPrompt: .asciiz "User played "
	validateMoveFalsePrompt: .asciiz "The move is illegal.\n"
	board: .byte  ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '
	moveNumberPrompt: .asciiz "The move number is "
	moveNumber: .byte 0
	gameWonPrompt: .asciiz " won!\n"
	gameTiedPrompt: .asciiz "Game is a tie!\n"
	inputRequirementPrompt: .asciiz "Invalid input. Input must be 0, 1, or 2.\n\n"
.text	
	### $s0 = X-input
	### $s1 = Y-input
	### $s2 = (X, Y) in array
	### $s7 = current piece
	main:

	li $s7, 'X'
	jal printBoard			# Prints the board
		
	while:
	jal getXInput 			# Store x-input into $s0
	jal validateInput
	move $s0, $v0
	jal getYInput 			# Store y-input into $s1
	jal validateInput
	move $s1, $v0
	jal printInput 			# Prints the last move played
	jal transformInput		# Transform (X,Y) input into array position
	jal validateMove # if move is legal, continue. Otherwise, return to while.
	beq $v0, 1, validateMoveTrue
	# validateMoveFalse
	la $a0, validateMoveFalsePrompt
	li $v0, 4
	syscall
	j while
	
	validateMoveTrue:
	jal playMove	
	jal incrementMoveNumber
	jal printBoard			# Prints the board
	
	jal validateIfGameOver
	jal changePiece

	j while
			
	end:
	# End of main
	li $v0, 10
	syscall
		 
	########### Helper procedures ##########
		
	# Iterates though board array to print Tic-Tac-Toe board.
	# Input: none
	# Output: none
	printBoard:
		li $v0, 4
		la $a0, moveNumberPrompt
		syscall
		li $v0, 1
		lb $a0, moveNumber
		syscall
		li $v0, 4
		la $a0, newLine
		syscall 
		syscall
	
		li $v0, 4
		la $a0, xAxis
		syscall
		
		la $a0, newLine
		syscall
		
		li $v0, 11
		li $a0, '0'
		syscall
		
		addi $t0, $zero, 0
		lb $a0, board($t0)
		syscall
		
		addi $t0, $t0, 1
		lb $a0, board($t0)
		syscall
		
		addi $t0, $t0, 1
		lb $a0, board($t0)
		syscall
		
		li $v0, 4
		
		la $a0, newLine
		syscall
		
		li $v0, 11
		li $a0, '1'
		syscall
		
		addi $t0, $t0, 1
		lb $a0, board($t0)
		syscall
		
		addi $t0, $t0, 1
		lb $a0, board($t0)
		syscall
		
		addi $t0, $t0, 1
		lb $a0, board($t0)
		syscall
		
		li $v0, 4
		
		la $a0, newLine
		syscall
		
		li $v0, 11
		la $a0, '2'
		syscall
		
		addi $t0, $t0, 1
		lb $a0, board($t0)
		syscall
		
		addi $t0, $t0, 1
		lb $a0, board($t0)
		syscall
		
		addi $t0, $t0, 1
		lb $a0, board($t0)
		syscall
		la $a0, newLine
		li $v0, 4		# print_string
		syscall
		syscall
		jr $ra
		
	# Prompts user for integer input. Places input into $s0.
	# Input: none
	# Output: integer
	getXInput:
		la $a0, xPrompt		# $a0 = "X: "
		li $v0, 4		# print_string
		syscall
		li $v0, 5		# input_int
		syscall
		jr $ra
		
	# Prompts user for integer input. Places input into $s1.
	# Input: none
	# Output: integer
	getYInput:
		la $a0, yPrompt		# $a0 equals "Y: "
		li $v0, 4		# print_string
		syscall
		li $v0, 5		# input_int
		syscall
		jr $ra
	
	transformInput:
		addi $s2, $zero, 3
		mul $s2, $s1, $s2
		add $s2, $s2, $s0
		jr $ra
		
	printInput:
		la $a0, userPlayedPrompt
		li $v0, 4		# print_string
		syscall
		li $a0, '('		
		li $v0, 11		# print_char	
		syscall			
		move $a0, $s0		
		li $v0, 1		# print_int
		syscall	
		li $a0, ','	
		li $v0, 11		# print_char
		syscall
		move $a0, $s1
		li $v0, 1		# print_int
		syscall
		li $a0, ')'
		li $v0, 11		# print_char
		syscall
		li $a0 '.'
		syscall
		la $a0, newLine
		li $v0, 4		# print_string
		syscall
		jr $ra
		
	### Checks if move inputted by user is legal. A move is legal if the location is unoccupied.
	validateMove:
		lb $t7, board($s2)
		bne $t7, ' ', moveIsIllegal
		li $v0, 1		# return 1
		jr $ra
		moveIsIllegal:
			li $v0, 0	# return 0	
			jr $ra
	playMove:
		move $a0, $s7
		sb $a0, board($s2)
		jr $ra
		
	incrementMoveNumber:
		lb $t7, moveNumber
		addi $t7, $t7, 1
		sb $t7, moveNumber
		jr $ra
		
	changePiece:
		beq $s7, 'O', changeToX
		li $s7, 'O'
		jr $ra
		changeToX:
		li $s7, 'X'
		jr $ra
		
	printMoveNumber:
		li $v0, 4
		la $a0, moveNumberPrompt
		syscall
		
		li $v0, 1
		lb $a0, moveNumber
		syscall
		
		li $v0, 11
		li $a0, '.'
		syscall
		
		li $v0, 4
		la $a0, newLine
		syscall 
		
		jr $ra
		
	validateIfGameOver:
		# Check if board $s7 == [0] == board[1] == board[2]
		addi $t4, $zero, 0
		lb $t5, board($t4)	# t5 = board[0]
		addi $t4, $zero, 1	
		
		lb $t6, board($t4)	# t6 = board[1]
	
		and $t7, $t5, $t6	# t7 = board[0] && board[1]
		addi $t4, $zero, 2
		lb $t5, board($t4)	# t5 = board[2]
		and $t7, $t5, $t7	# t7 = board[0] && board[1] && board[2]
		beq $t7, $s7, gameWon
		
		# Check if board[0] == board[3] == board[6]
		addi $t4, $zero, 0
		lb $t5, board($t4)	# t5 = board[0]
		addi $t4, $zero, 3
		lb $t6, board($t4)	# t6 = board[3]
		and $t7, $t5, $t6	# t7 = board[0] && board[3]
		addi $t4, $zero, 6	
		lb $t5, board($t4)	# t5 = board[6]
		and $t7, $t5, $t7	# t7 = board[0] && board[3] && board[6]
		beq $t7, $s7, gameWon
		
		# Check if board[0] == board[4] == board[8]
		addi $t4, $zero, 0
		lb $t5, board($t4)	# t5 = board[0]
		addi $t4, $zero, 4
		lb $t6, board($t4)	# t6 = board[4]
		and $t7, $t5, $t6	# t7 = board[0] && board[4]
		addi $t4, $zero, 8	
		lb $t5, board($t4)	# t5 = board[8]
		and $t7, $t5, $t7	# t7 = board[0] && board[4] && board[8]
		beq $t7, $s7, gameWon
		
		# Check if board[3] == board[4] == board[5]
		addi $t4, $zero, 3
		lb $t5, board($t4)	# t5 = board[3]
		addi $t4, $zero, 4
		lb $t6, board($t4)	# t6 = board[4]
		and $t7, $t5, $t6	# t7 = board[3] && board[4]
		addi $t4, $zero, 5	
		lb $t5, board($t4)	# t5 = board[5]
		and $t7, $t5, $t7	# t7 = board[3] && board[4] && board[5]
		beq $t7, $s7, gameWon
		
		# Check if board[1] == board[4] == board[7]
		addi $t4, $zero, 1
		lb $t5, board($t4)	# t5 = board[1]
		addi $t4, $zero, 4
		lb $t6, board($t4)	# t6 = board[4]
		and $t7, $t5, $t6	# t7 = board[0] && board[4]
		addi $t4, $zero, 7	
		lb $t5, board($t4)	# t5 = board[7]
		and $t7, $t5, $t7	# t7 = board[1] && board[4] && board[7]
		beq $t7, $s7, gameWon
		
		# Check if board[2] == board[4] == board[6]
		addi $t4, $zero, 2
		lb $t5, board($t4)	# t5 = board[2]
		addi $t4, $zero, 4
		lb $t6, board($t4)	# t6 = board[4]
		and $t7, $t5, $t6	# t7 = board[2] && board[4]
		addi $t4, $zero, 6	
		lb $t5, board($t4)	# t5 = board[6]
		and $t7, $t5, $t7	# t7 = board[2] && board[4] && board[6]
		beq $t7, $s7, gameWon
		
		# Check if board[6] == board[7] == board[8]
		addi $t4, $zero, 6
		lb $t5, board($t4)	# t5 = board[6]
		addi $t4, $zero, 7
		lb $t6, board($t4)	# t6 = board[7]
		and $t7, $t5, $t6	# t7 = board[6] && board[7]
		addi $t4, $zero, 8	
		lb $t5, board($t4)	# t5 = board[8]
		and $t7, $t5, $t7	# t7 = board[6] && board[7] && board[8]
		beq $t7, $s7, gameWon
		
		# Check if board[2] == board[5] == board[8]
		addi $t4, $zero, 2
		lb $t5, board($t4)	# t5 = board[2]
		addi $t4, $zero, 5
		lb $t6, board($t4)	# t6 = board[5]
		and $t7, $t5, $t6	# t7 = board[2] && board[5]
		addi $t4, $zero, 8	
		lb $t5, board($t4)	# t5 = board[8]
		and $t7, $t5, $t7	# t7 = board[2] && board[5] && board[8]
		beq $t7, $s7, gameWon
		
		lb $t4, moveNumber
		beq $t4, 9, gameTied
		
		jr $ra
	
	gameWon:
		li $v0, 11
		move $a0, $s7
		syscall
		li $v0, 4
		la $a0, gameWonPrompt
		syscall
		j end
	gameTied:
		la $a0, gameTiedPrompt
		li $v0, 4
		syscall
		j end
	validateInput:
		beq $v0, 0, validInput
		beq $v0, 1, validInput
		beq $v0, 2, validInput
		li $v0, 4
		la $a0, inputRequirementPrompt
		syscall
		j while
		validInput:
		jr $ra
	
	
	
