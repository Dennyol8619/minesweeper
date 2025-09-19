extends Camera2D

@export var corner1:Marker2D
@export var corner2:Marker2D

func _process(delta):
	var ds:Vector2 = DisplayServer.window_get_size()
	global_position = (corner1.global_position + corner2.global_position) * 0.5
	var zoom_factor1 = abs(corner1.global_position.x-corner2.global_position.x)/(ds.x-10)
	var zoom_factor2 = abs(corner1.global_position.y-corner2.global_position.y)/(ds.y-10)
	var zoom_factor = max(max(zoom_factor1, zoom_factor2), 0.1)
	zoom = Vector2(1/zoom_factor, 1/zoom_factor)
