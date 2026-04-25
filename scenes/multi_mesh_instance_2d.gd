extends MultiMeshInstance2D

@export var grass_palette: Array[Color]
@export var spawn_rect: Rect2
@export var grass_count := 3000
@export var min_blade_width := 18.0
@export var max_blade_width := 35.0
@export var min_blade_height := 18.0
@export var max_blade_height := 35.0

func _ready():
	generate()

func generate():
	multimesh.instance_count = grass_count
	
	for i in grass_count:
		var x = spawn_rect.position.x + randf_range(0.0, spawn_rect.size.x)
		var step = spawn_rect.size.y / grass_count
		var y = spawn_rect.position.y + randf_range(i * step, (i + 1) * step)
		var pos = Vector2(x, y)
		pos = floor(pos)
		
		var texture_size = texture.get_size()
		var mesh: QuadMesh = multimesh.mesh
		mesh.size = texture_size
		mesh.center_offset = Vector3(0, texture_size.y / 2, 0)
		
		var transform = Transform2D()
		var signx = 1 #randi_range(0, 1) * 2 - 1
		var s = Vector2( 
			signx * 1/texture_size.y * randf_range(min_blade_width, max_blade_width), 
			1/texture_size.y * randf_range(min_blade_height, max_blade_height)
		) 
		transform = transform.scaled(s)
		transform = transform.rotated(PI + randf_range(-0.2, 0.2))
		transform.origin = pos
		
		multimesh.set_instance_transform_2d(i, transform)
		
		var rand_col_i = randi_range(0, len(grass_palette)-1)
		multimesh.set_instance_color(i, grass_palette[rand_col_i])


func _input(event):
	if event.is_action_pressed("ui_accept"):
		generate()
