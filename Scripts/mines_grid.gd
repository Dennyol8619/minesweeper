extends TileMap

class_name MinesGrid

signal flag_change(number_of_flags)
signal game_lost
signal game_won

const CELLS = {
	"1": Vector2i(0, 0),
	"2": Vector2i(1, 0),
	"3": Vector2i(2, 0),
	"4": Vector2i(3, 0),
	"5": Vector2i(4, 0),
	"6": Vector2i(0, 1),
	"7": Vector2i(1, 1),
	"8": Vector2i(2, 1),
	"CLEAR": Vector2i(3, 1),
	"MINE_RED": Vector2i(4, 1),
	"FLAG": Vector2i(0, 2),
	"MINE": Vector2i(1, 2),
	"DEFAULT": Vector2i(2, 2)
}

var columns = 8
var rows = 8
var number_of_mines = 20

@onready var data = get_node("/root/Data")

@export var corner1:Marker2D
@export var corner2:Marker2D
@export var ui_pos:Marker2D

const TILE_SET_ID = 0
const DEFAULT_LAYER = 0

var cells_with_mines = []
var cells_with_mines_fix = []
var cells_with_flags = []
var flags_placed = 0
var cells_checked_recursively = []
var is_game_finished = false

var click_time = 0
var long_click_threshold = 500

var is_flag:bool = false

func _ready():
	columns = data.GetSize()
	rows = data.GetSize()
	number_of_mines = data.GetMines()
	
	if columns % 2 == 1:
		global_position = global_position - Vector2(8, 8)
	
	
	corner1.global_position = Vector2(columns*-8,rows*-8-14)
	corner2.global_position = Vector2(columns*8,rows*8)
	ui_pos.global_position = Vector2(0,rows*-8-14)
	
	clear_layer(DEFAULT_LAYER)
	
	for i in rows:
		for j in columns:
			var cell_coord = Vector2(i - rows / 2, j - columns / 2)
			set_tile_cell(cell_coord, "DEFAULT")
	
	place_mines()

func _input(event: InputEvent):
	if is_game_finished:
		return
	
	var clicked_cell_coord = local_to_map(get_local_mouse_position())
	
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.button_index == 1 and mouse_event.pressed:
			if is_flag:
				place_flag(clicked_cell_coord)
			else:
				on_cell_clicked(clicked_cell_coord)
		elif mouse_event.button_index == 2 and mouse_event.pressed:
			place_flag(clicked_cell_coord)
	
	#Short-Long Press
	#if event is InputEventMouseButton:
		#var mouse_event = event as InputEventMouseButton
		#if mouse_event.button_index == 1 and mouse_event.pressed:
			#click_time = Time.get_ticks_msec()
		#elif mouse_event.button_index == 1 and !mouse_event.pressed:
			#var release_time = Time.get_ticks_msec()
			#var click_duration = release_time - click_time
			#if click_duration <= long_click_threshold:
				#on_cell_clicked(clicked_cell_coord)
			#else:
				#place_flag(clicked_cell_coord)
			#print(click_duration)

func place_mines():
	for i in number_of_mines:
		var cell_coordinates = Vector2(randi_range(- rows/2, rows/2 -1), randi_range(-columns/2, columns /2 -1))
		
		while cells_with_mines.has(cell_coordinates):
			cell_coordinates = Vector2(randi_range(- rows/2, rows/2 -1), randi_range(-columns/2, columns /2 -1))
		
		cells_with_mines.append(cell_coordinates)
		cells_with_mines_fix.append(cell_coordinates)

func set_tile_cell(cell_coord, cell_type):
	set_cell(DEFAULT_LAYER, cell_coord, TILE_SET_ID, CELLS[cell_type])

func on_cell_clicked(cell_coord: Vector2i):
	if cells_with_mines.any(func (cell): return cell.x == cell_coord.x && cell.y == cell_coord.y):
		lose(cell_coord)
		return
	
	cells_checked_recursively.append(cell_coord)
	handle_cells(cell_coord, true)
	
	if cells_with_flags.has(cell_coord):
		flags_placed -= 1
		flag_change.emit(flags_placed)
		cells_with_flags.erase(cell_coord)

func handle_cells(cell_coord: Vector2i, should_stop_after_mine: bool = false):
	var tile_data = get_cell_tile_data(DEFAULT_LAYER, cell_coord)
	
	if tile_data == null:
		return
		
	var cell_has_mine = tile_data.get_custom_data("has_mine")
	
	if cell_has_mine && should_stop_after_mine:
		return
	
	var mine_count = get_surrounding_cells_mine_count(cell_coord)
	
	if mine_count == 0:
		set_tile_cell(cell_coord, "CLEAR")
		var surrounding_cells = get_surrounding_cells(cell_coord)
		for cell in surrounding_cells:
			handle_surrounding_cell(cell)
	else:
		set_tile_cell(cell_coord, "%d" % mine_count)
		
	if cells_with_flags.has(cell_coord):
		flags_placed -= 1
		flag_change.emit(flags_placed)
		cells_with_flags.erase(cell_coord)

func handle_surrounding_cell(cell_coord: Vector2i):
	if cells_checked_recursively.has(cell_coord):
		return
	
	cells_checked_recursively.append(cell_coord)
	handle_cells(cell_coord)

func get_surrounding_cells_mine_count(cell_coord: Vector2i):
	var mine_count = 0
	var surrounding_cells = get_surrounding_cells_to_check(cell_coord)
	for cell in surrounding_cells:
		for mines in cells_with_mines_fix:
			if mines.x == cell.x && mines.y == cell.y:
				mine_count += 1
	return mine_count

func lose(cell_coord: Vector2i):
	game_lost.emit()
	is_game_finished = true
	
	for cell in cells_with_mines:
		set_tile_cell(cell, "MINE")
	
	set_tile_cell(cell_coord, "MINE_RED")

func place_flag(cell_coord: Vector2i):
	var tile_data = get_cell_tile_data(DEFAULT_LAYER, cell_coord)
	
	var atlast_coordinates = get_cell_atlas_coords(DEFAULT_LAYER, cell_coord)
	var is_empty_cell = atlast_coordinates == Vector2i(2,2)
	var is_flag_cell = atlast_coordinates == Vector2i(0, 2)
	
	if !is_empty_cell and !is_flag_cell:
		return
	
	if is_flag_cell:
		set_tile_cell(cell_coord, "DEFAULT")
		cells_with_flags.erase(cell_coord)
		flags_placed -= 1
	elif is_empty_cell:
		if flags_placed == number_of_mines:
			return
		
		flags_placed +=1 
		set_tile_cell(cell_coord, "FLAG")
		cells_with_flags.append(cell_coord)
	
	flag_change.emit(flags_placed)
	
	var count = 0
	for flag_cell in cells_with_flags:
		for mine_cell in cells_with_mines:
			if flag_cell.x == mine_cell.x and flag_cell.y == mine_cell.y:
				count += 1
	
	if count == cells_with_mines.size():
		win()

func win():
	is_game_finished = true
	game_won.emit()

func get_surrounding_cells_to_check(current_cell:Vector2i):
	var target_cell
	var surrounding_cells = []
	
	for y in 3:
		for x in 3:
			if x == 1 and y == 1:
				continue
			target_cell = current_cell + Vector2i(x - 1, y - 1)
			surrounding_cells.append(target_cell)
	return surrounding_cells
