extends Node

@export var sub_grid_scene: PackedScene
@export var circle_scene_s: PackedScene
@export var cross_scene_s: PackedScene
@export var circle_scene_b: PackedScene
@export var cross_scene_b: PackedScene 
@export var move_indicator_scene: PackedScene

var main_grid_data: Array

var sub_grids: Dictionary
var sub_grid_nodes: Dictionary
var circle_nodes: Dictionary 
var cross_nodes: Dictionary 

var player: int

var next_marker
var next_player_panel_pos: Vector2i

var move_indicator
var isDraw: bool
var grid_pos: Vector2i
var sub_grid_pos: Vector2i
var relative_pos: Vector2
var board_size: int
var cell_size: int
var sub_cell_size: int
var sub_cell_size_b: int
var sub_cell_pos: Vector2i
var last_move: Vector2i
var free_move: bool #a free move arises when a player's next move is 
					#supposed to be in a sub-cell in a sub_grid that has already been won
var row_sum_s: int 
var column_sum_s: int 
var diagonal_sum_s: int 
var diagonal2_sum_s: int 

var row_sum_m: int
var column_sum_m: int 
var diagonal_sum_m: int 
var diagonal2_sum_m: int 
 
var winner

# Called when the node enters the scene tree for the first time.
func _ready():
	board_size = $Board.texture.get_width()
	cell_size = board_size / 3
	sub_cell_size = cell_size / 3
	sub_cell_size_b = board_size / 9
	next_player_panel_pos = $NextPlayerPanel.get_position()
	
	new_game()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			#check if mouse is on the game board
			if event.position.x < board_size:
				#convert mouse position into grid location 
				grid_pos = Vector2i(event.position / cell_size)
				relative_pos = event.position - Vector2(grid_pos * cell_size)
				sub_grid_pos = Vector2i(relative_pos / sub_cell_size)
				sub_cell_pos = Vector2i(event.position / sub_cell_size_b)
					
				#logic 
				#when a button is pressed, whether a game is one going in the grid is first checked 
				if main_grid_data[grid_pos.y][grid_pos.x] == 0:
					#if the grid data is 0, it means that grid hasn't been clicked before 
					#2 means that a sub grid has been created and a game is on going in that grid.
					main_grid_data[grid_pos.y][grid_pos.x] = 2
					#place a new board for the sub_grid
					create_subgrids(grid_pos * cell_size + Vector2i(cell_size / 2, cell_size / 2))
					
				elif ((main_grid_data[grid_pos.y][grid_pos.x] != 1 or main_grid_data[grid_pos.y][grid_pos.x] != -1) and grid_pos == last_move) or ((main_grid_data[grid_pos.y][grid_pos.x] != 1 or main_grid_data[grid_pos.y][grid_pos.x] != -1) and free_move):
					var sub_grid = sub_grids[grid_pos]
					if sub_grid[sub_grid_pos.y][sub_grid_pos.x] == 0:
						sub_grid[sub_grid_pos.y][sub_grid_pos.x] = player
							
					create_marker_small(player, sub_cell_pos * sub_cell_size_b + Vector2i(sub_cell_size_b/2, sub_cell_size_b/2))
					
					if check_win_subgrid(sub_grids[grid_pos], grid_pos):
						replace_subgrid_with_marker(grid_pos, player)
						print("Checking 2")
						if check_win_maingrid(main_grid_data)!= 0:
							print("game over")
							get_tree().paused = true
							$GameOverMenu.show()
							if winner == 1:
								$GameOverMenu.get_node("ResultLabel").text = "Player 1 Wins!"
							elif winner == -1:
								$GameOverMenu.get_node("ResultLabel").text = "Player 2 Wins!"
							elif winner == 2:
								$GameOverMenu.get_node("ResultLabel").text = "Draw"
							$moveIndicator.hide()
						else:
							print("no game yet")
						
					player *= -1
					#delete the previous marker 
					next_marker.queue_free()
					#update the panel marker
					create_marker_big(player, next_player_panel_pos + Vector2i(cell_size / 2, cell_size / 2), true)
					last_move = sub_grid_pos
					
					if main_grid_data[last_move.y][last_move.x] == 1 or main_grid_data[last_move.y][last_move.x] == -1:
						free_move = true
						print("free move")
					else:
						free_move = false
					place_move_indicator(last_move)
				else:
					print("Invalid move")

func new_game():
	player = 1
	winner = 0
	free_move = false
	
	main_grid_data = [
		[0, 0, 0],
		[0, 0, 0],
		[0, 0, 0]
	]
	
	$GameOverMenu.hide()
	#create next player marker 
	
	row_sum_s = 0
	column_sum_s = 0
	diagonal_sum_s = 0
	diagonal2_sum_s = 0
	
	row_sum_m = 0
	column_sum_m = 0
	diagonal_sum_m = 0
	diagonal2_sum_m = 0
	
	#clear existing grids 
	get_tree().call_group("small_crosses", "queue_free")
	get_tree().call_group("small_circles", "queue_free")
	get_tree().call_group("crosses", "queue_free")
	get_tree().call_group("circles", "queue_free")
	get_tree().call_group("small_boards", "queue_free")
	
	
	get_tree().paused = false
	
	create_marker_big(player, next_player_panel_pos + Vector2i(cell_size / 2, cell_size / 2), true)
	
	sub_grids ={
		Vector2i(0, 0): [
		[0, 0, 0],
		[0, 0, 0],
		[0, 0, 0]
	],
	
	Vector2i(0, 1): [
		[0, 0, 0],
		[0, 0, 0],
		[0, 0, 0]
	],
	
	Vector2i(0, 2): [
		[0, 0, 0],
		[0, 0, 0],
		[0, 0, 0]
	],
	
	Vector2i(1, 0): [
		[0, 0, 0],
		[0, 0, 0],
		[0, 0, 0]
	],
	
	Vector2i(1, 1): [
		[0, 0, 0],
		[0, 0, 0],
		[0, 0, 0]
	],
	
	Vector2i(1, 2): [
		[0, 0, 0],
		[0, 0, 0],
		[0, 0, 0]
	],
	
	Vector2i(2, 0): [
		[0, 0, 0],
		[0, 0, 0],
		[0, 0, 0]
	],
	
	Vector2i(2, 1): [
		[0, 0, 0],
		[0, 0, 0],
		[0, 0, 0]
	],
	
	Vector2i(2, 2): [
		[0, 0, 0],
		[0, 0, 0],
		[0, 0, 0]
	]
	}
	
	sub_grid_nodes = {}
	circle_nodes = {}
	cross_nodes = {}

func create_subgrids(position):
	#whenever a new subgrid is created it should be stored in a dictionary so that 
	#it can be accessed when it needs to be removed
	var sub_grid = sub_grid_scene.instantiate()
	sub_grid.position = position
	sub_grid.name = "sub_grid_%s_%s" % [grid_pos.x, grid_pos.y]
	add_child(sub_grid)
	print("Created sub-grid at %s" % grid_pos)
	
	sub_grid_nodes[grid_pos] = sub_grid

func create_marker_small(player, position):
	#create a marker 
	if player == 1:
		var circle_s = circle_scene_s.instantiate()
		circle_s.position = position
		add_child(circle_s)
		
		if not circle_nodes.has(grid_pos):
			circle_nodes[grid_pos] = []
		circle_nodes[grid_pos].append(circle_s)
	else: 
		#the crosses need to be removed when the a game in a sub grid ends.
		#so they must be stored in functions
		var cross_s = cross_scene_s.instantiate()
		cross_s.position = position
		add_child(cross_s)
		
		if not cross_nodes.has(grid_pos):
			cross_nodes[grid_pos] = []
		cross_nodes[grid_pos].append(cross_s)
		
func create_marker_big(player, position, next = false):
	if player == 1:
		var circle_b = circle_scene_b.instantiate()
		circle_b.position = position
		add_child(circle_b)
		if next: next_marker = circle_b
	else:
		var cross_b = cross_scene_b.instantiate()
		cross_b.position = position
		add_child(cross_b)
		if next: next_marker = cross_b

func check_win_subgrid(sub_grid, grid_pos):
	for i in range(len(sub_grid)):
		row_sum_s = sub_grid[i][0] + sub_grid[i][1] + sub_grid[i][2]
		column_sum_s = sub_grid[0][i] + sub_grid[1][i] + sub_grid[2][i]
		
		diagonal_sum_s = sub_grid[0][0] + sub_grid[1][1] + sub_grid[2][2]
		diagonal2_sum_s = sub_grid[0][2] + sub_grid[1][1] + sub_grid[2][0]
		
		print("Checking subgrid position:", grid_pos)
		print("Row sums:", [sub_grid[i][0], sub_grid[i][1], sub_grid[i][2]])
		print("Column sums:", [sub_grid[0][i], sub_grid[1][i], sub_grid[2][i]])
		print("Diagonal sums:", [sub_grid[0][0], sub_grid[1][1], sub_grid[2][2]], "and", [sub_grid[0][2], sub_grid[1][1], sub_grid[2][0]])
		print()
		
		if row_sum_s == 3 or column_sum_s == 3 or diagonal_sum_s == 3 or diagonal2_sum_s == 3:
			winner = 1
			print("game won in", grid_pos)
			return true
		elif row_sum_s == -3 or column_sum_s == -3 or diagonal_sum_s == -3 or diagonal2_sum_s == -3:
			winner = -1
			print("Game won in", grid_pos)
			return true
	return false
	
func check_win_maingrid(main_grid_data):
	#there is probably a more efficient way to do this. 
	isDraw = true
	for i in len(main_grid_data):
		if main_grid_data[0][i] == 1 and main_grid_data[1][i] == 1 and main_grid_data[2][0] == 1:
			print("game Over 1")
			winner = 1
			return winner
		elif main_grid_data[i][0] == 1 and main_grid_data[i][1] == 1 and main_grid_data[i][2] == 1:
			print("game over 2")
			winner = 1
			return winner
		elif main_grid_data[0][0] == 1 and main_grid_data[1][1] == 1 and main_grid_data[2][2] == 1:
			print("game over 3")
			winner = 1
			return winner
		elif main_grid_data[0][2] == 1 and main_grid_data[1][1] == 1 and main_grid_data[2][0] == 1:
			print("game over 4")
			winner = 1
			return winner
		elif main_grid_data[0][i] == -1 and main_grid_data[1][i] == -1 and main_grid_data[2][i] == -1:
			print("game over 5")
			winner = -1
			return winner
		elif main_grid_data[i][0] == -1 and main_grid_data[i][1] == -1 and main_grid_data[i][2] == -1:
			print("game over 6")
			winner = -1
			return winner
		elif main_grid_data[0][0] == -1 and main_grid_data[1][1] == -1 and main_grid_data[2][2] == -1:
			print("Game over 7")
			winner = -1
			return winner
		elif main_grid_data[0][2] == -1 and main_grid_data[1][1] == -1 and main_grid_data[2][0] == -1:
			print("game over 8")
			winner = -1
			return winner
		for j in range(3):
			if main_grid_data[i][j] == 0:
				isDraw = false
		
	if isDraw:
		print("Main grid is a draw")
		winner = 2
		return winner
	return 0
	
func replace_subgrid_with_marker(grid_pos, player):
	#remove the sub-grid where the game is won
	if sub_grid_nodes.has(grid_pos):
		var sub_grid_node = sub_grid_nodes[grid_pos]
		sub_grid_node.queue_free()
		print("Sub-grid removed at %s", grid_pos)
	else:
		print("Sub-grid not found at %s", grid_pos)
		
	#remove small markers
	if circle_nodes.has(grid_pos):
		for node in circle_nodes[grid_pos]:
			node.queue_free()
	if cross_nodes.has(grid_pos):
		for node in cross_nodes[grid_pos]:
			node.queue_free()
	
	#update main grid to indicate the win.
	main_grid_data[grid_pos.y][grid_pos.x] = player
	
	#place the marker 
	var position = grid_pos * cell_size + Vector2i(cell_size / 2, cell_size / 2)
	create_marker_big(player, position)
	print("Marker placed at", grid_pos, "for player", player)
	
func place_move_indicator(last_move):
	#first just place the indicator at the middle of the board.
	#717
	#409
	
	
	if not move_indicator:
		move_indicator = move_indicator_scene.instantiate()
		var indicator_position = last_move * sub_cell_size_b + Vector2i(650, 343)
		print(indicator_position)
		move_indicator.position = indicator_position
		add_child(move_indicator)
		print("indicator placed")
	#
	if free_move:
		$moveIndicator.hide()
		print("indicator hidden")
	else:
		if not move_indicator.visible:
			move_indicator.show() 
		print(last_move)
		var indicator_position = last_move * sub_cell_size_b + Vector2i(650, 343)
		print("Indicator position",indicator_position)
		move_indicator.position = indicator_position
		print("indicator placed")
	#else: 
		#
	

func _on_game_over_menu_restart():
	new_game()
