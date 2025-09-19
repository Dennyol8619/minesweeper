extends Node

class_name UI

@onready var mines_count_label = %MinesCountLabel
@onready var game_status_button = %GameStatusButton
@onready var timer_count_label = %TimerCountLabel
@onready var flag_button = %FlagButton
@onready var win_text = $"../../WinNode2D"

var game_lost_button_texture = preload("res://Assets/button_dead.png")
var game_won_button_texture = preload("res://Assets/button_cleared.png")

var flag_button_texture = preload("res://Assets/button_flag.png")
var flag_pressed_button_texture = preload("res://Assets/button_flag_pressed.png")

func set_mine_count(mines_count: int):
	var mines_count_string = str(mines_count)
	if mines_count_string.length() < 3:
		mines_count_string = mines_count_string.lpad(3, "0")
	mines_count_label.text = mines_count_string

func set_timer_count(timer_count: int):
	var timer_string = str(timer_count)
	if timer_string.length() < 3:
		timer_string = timer_string.lpad(3, "0")
	timer_count_label.text = timer_string

func _on_game_status_button_pressed():
	get_tree().reload_current_scene()

func game_lost():
	game_status_button.texture_normal = game_lost_button_texture

func game_won():
	game_status_button.texture_normal = game_won_button_texture
	win_text.visible = true

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

func change_flag_button_texture(pressed:bool):
	if pressed:
		flag_button.texture_normal = flag_pressed_button_texture
	else:
		flag_button.texture_normal = flag_button_texture
