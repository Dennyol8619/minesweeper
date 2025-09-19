extends Node

@onready var data = get_node("/root/Data")
@onready var size = $Node2D/Size
@onready var mines = $Node2D/Mines

func _on_size_text_submitted(new_text):
	data.SetSize(int(new_text))
	if data.GetSize() < 8:
		data.SetSize(8)
		size.text = str(data.GetSize())
	if data.GetSize() > 20:
		data.SetSize(20)
		size.text = str(data.GetSize())
	if data.GetSize()*data.GetSize() < data.GetMines():
		data.SetMines(data.GetSize()*data.GetSize())
		mines.text = str(data.GetMines())

func _on_mines_text_submitted(new_text):
	data.SetMines(int(new_text))
	if data.GetMines() < 1:
		data.SetMines(1)
		mines.text = str(data.GetMines())
	if data.GetSize()*data.GetSize() < data.GetMines():
		data.SetMines(data.GetSize()*data.GetSize())
		mines.text = str(data.GetMines())

func _on_start_pressed():
	data.SetSize(int(size.text))
	data.SetMines(int(mines.text))
	
	if data.GetSize() < 8:
		data.SetSize(8)
	if data.GetSize() > 20:
		data.SetSize(20)
	if data.GetMines() < 1:
		data.SetMines(1)
	if data.GetSize()*data.GetSize() < data.GetMines():
		data.SetMines(data.GetSize()*data.GetSize())
	
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")

func _on_exit_pressed():
	get_tree().quit()
