.data
	board: .byte  ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '
	x_axis_text: .asciiz " 012"
	get_x_input_text: .asciiz "X: "
	get_y_input_text: .asciiz "Y: "
	turn_count: .byte 0
	turn_count_text: .asciiz "Current turn:"
	won_game_output: .asciiz " You win!\n"
	drawn_game_output: .asciiz "Game over. It's a draw!\n"
	invalid_input: .asciiz "Invalid input coordinate. Please input a 0, 1, or 2.\n\n"
	check_legal_move_false_prompt: .asciiz "Illegal move!\n"
	user_played_text: .asciiz "User played:"
	new_line: .asciiz "\n"
.text	
	# $s0 = x coordinate 
	# $s1 = y coordinate
	# $s2 = (X, Y) in array
	# $s7 = whose turn it is
	main:

	li $s7, 'X'
	jal show_board_array	# shows the array that represents the tic tac toe
		
	while:
	jal get_x_coordinate 	# stores the inputted x coordinate into $s0
	jal check_input
	move $s0, $v0
	jal get_y_coordinate 	# stores the inputted y coordinate into $s1
	jal check_input
	move $s1, $v0
	jal show_last_move 		# shows the last move played
	jal process_input		# processes the input coordinates and returns the corresponding array position 
	jal check_legal_move 	# if the move is not legal, return to the while loop
	beq $v0, 1, check_legal_move_true
	la $a0, check_legal_move_false_prompt
	li $v0, 4
	syscall
	j while
	
	check_legal_move_true:
	jal make_move	
	jal increase_move_count
	jal show_board_array	# shows the array that represents the tic tac toe board
	
	jal check_if_game_over
	jal flip_turn
	j while
			
	end:
	# end of main function
	li $v0, 10
	syscall
		 
	# below this point are helper functions
		
	# loops through the tic tac toe board array and outputs it to the console
	# input: none | output: none
	show_board_array:
		li $v0, 4
		la $a0, turn_count_text
		syscall
		li $v0, 1
		lb $a0, turn_count
		syscall
		li $v0, 4
		la $a0, new_line
		syscall 
		syscall
	
		li $v0, 4
		la $a0, x_axis_text
		syscall
		
		la $a0, new_line
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
		
		la $a0, new_line
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
		
		la $a0, new_line
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
		la $a0, new_line
		li $v0, 4		
		syscall
		syscall
		jr $ra
		
	# prompts the player for the x-coordinate of their move, which is stored in $s0.
	# input: none | output: integer
	get_x_coordinate:
		la $a0, get_x_input_text		
		li $v0, 4		
		syscall
		li $v0, 5		
		syscall
		jr $ra
		
	# prompts the player for the y-coordinate of their move, which is stored in $s0.
	# input: none | output: integer
	get_y_coordinate:
		la $a0, get_y_input_text		
		li $v0, 4		
		syscall
		li $v0, 5		
		syscall
		jr $ra
	
	process_input:
		addi $s2, $zero, 3
		mul $s2, $s1, $s2
		add $s2, $s2, $s0
		jr $ra
		
	show_last_move:
		la $a0, user_played_text
		li $v0, 4		
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
		la $a0, new_line
		li $v0, 4		
		syscall
		jr $ra
		
	# ensures the move passed is legal (i.e. the desired spot is not filled)
	check_legal_move:
		lb $t7, board($s2)
		bne $t7, ' ', illegal_move
		li $v0, 1		# return 1
		jr $ra
		illegal_move:
			li $v0, 0	# return 0	
			jr $ra
	make_move:
		move $a0, $s7
		sb $a0, board($s2)
		jr $ra
		
	increase_move_count:
		lb $t7, turn_count
		addi $t7, $t7, 1
		sb $t7, turn_count
		jr $ra
		
	flip_turn:
		beq $s7, 'O', changeToX
		li $s7, 'O'
		jr $ra
		changeToX:
		li $s7, 'X'
		jr $ra
		
	printturn_count:
		li $v0, 4
		la $a0, turn_count_text
		syscall
		
		li $v0, 1
		lb $a0, turn_count
		syscall
		
		li $v0, 11
		li $a0, '.'
		syscall
		
		li $v0, 4
		la $a0, new_line
		syscall 
		
		jr $ra
		
	check_if_game_over:
		# Check if board $s7 == [0] == board[1] == board[2]
		addi $t4, $zero, 0
		lb $t5, board($t4)	# t5 = board[0]
		addi $t4, $zero, 1	
		
		lb $t6, board($t4)	# t6 = board[1]
	
		and $t7, $t5, $t6	# t7 = board[0] && board[1]
		addi $t4, $zero, 2
		lb $t5, board($t4)	# t5 = board[2]
		and $t7, $t5, $t7	# t7 = board[0] && board[1] && board[2]
		beq $t7, $s7, won_game
		
		# Check if board[0] == board[3] == board[6]
		addi $t4, $zero, 0
		lb $t5, board($t4)	# t5 = board[0]
		addi $t4, $zero, 3
		lb $t6, board($t4)	# t6 = board[3]
		and $t7, $t5, $t6	# t7 = board[0] && board[3]
		addi $t4, $zero, 6	
		lb $t5, board($t4)	# t5 = board[6]
		and $t7, $t5, $t7	# t7 = board[0] && board[3] && board[6]
		beq $t7, $s7, won_game
		
		# Check if board[0] == board[4] == board[8]
		addi $t4, $zero, 0
		lb $t5, board($t4)	# t5 = board[0]
		addi $t4, $zero, 4
		lb $t6, board($t4)	# t6 = board[4]
		and $t7, $t5, $t6	# t7 = board[0] && board[4]
		addi $t4, $zero, 8	
		lb $t5, board($t4)	# t5 = board[8]
		and $t7, $t5, $t7	# t7 = board[0] && board[4] && board[8]
		beq $t7, $s7, won_game
		
		# Check if board[3] == board[4] == board[5]
		addi $t4, $zero, 3
		lb $t5, board($t4)	# t5 = board[3]
		addi $t4, $zero, 4
		lb $t6, board($t4)	# t6 = board[4]
		and $t7, $t5, $t6	# t7 = board[3] && board[4]
		addi $t4, $zero, 5	
		lb $t5, board($t4)	# t5 = board[5]
		and $t7, $t5, $t7	# t7 = board[3] && board[4] && board[5]
		beq $t7, $s7, won_game
		
		# Check if board[1] == board[4] == board[7]
		addi $t4, $zero, 1
		lb $t5, board($t4)	# t5 = board[1]
		addi $t4, $zero, 4
		lb $t6, board($t4)	# t6 = board[4]
		and $t7, $t5, $t6	# t7 = board[0] && board[4]
		addi $t4, $zero, 7	
		lb $t5, board($t4)	# t5 = board[7]
		and $t7, $t5, $t7	# t7 = board[1] && board[4] && board[7]
		beq $t7, $s7, won_game
		
		# Check if board[2] == board[4] == board[6]
		addi $t4, $zero, 2
		lb $t5, board($t4)	# t5 = board[2]
		addi $t4, $zero, 4
		lb $t6, board($t4)	# t6 = board[4]
		and $t7, $t5, $t6	# t7 = board[2] && board[4]
		addi $t4, $zero, 6	
		lb $t5, board($t4)	# t5 = board[6]
		and $t7, $t5, $t7	# t7 = board[2] && board[4] && board[6]
		beq $t7, $s7, won_game
		
		# Check if board[6] == board[7] == board[8]
		addi $t4, $zero, 6
		lb $t5, board($t4)	# t5 = board[6]
		addi $t4, $zero, 7
		lb $t6, board($t4)	# t6 = board[7]
		and $t7, $t5, $t6	# t7 = board[6] && board[7]
		addi $t4, $zero, 8	
		lb $t5, board($t4)	# t5 = board[8]
		and $t7, $t5, $t7	# t7 = board[6] && board[7] && board[8]
		beq $t7, $s7, won_game
		
		# Check if board[2] == board[5] == board[8]
		addi $t4, $zero, 2
		lb $t5, board($t4)	# t5 = board[2]
		addi $t4, $zero, 5
		lb $t6, board($t4)	# t6 = board[5]
		and $t7, $t5, $t6	# t7 = board[2] && board[5]
		addi $t4, $zero, 8	
		lb $t5, board($t4)	# t5 = board[8]
		and $t7, $t5, $t7	# t7 = board[2] && board[5] && board[8]
		beq $t7, $s7, won_game
		
		lb $t4, turn_count
		beq $t4, 9, drawn_game
		
		jr $ra
	
	won_game:
		li $v0, 11
		move $a0, $s7
		syscall
		li $v0, 4
		la $a0, won_game_output
		syscall
		j end
	drawn_game:
		la $a0, drawn_game_output
		li $v0, 4
		syscall
		j end
	check_input:
		beq $v0, 0, valid_input
		beq $v0, 1, valid_input
		beq $v0, 2, valid_input
		li $v0, 4
		la $a0, invalid_input
		syscall
		j while
		valid_input:
		jr $ra
	
	
	
