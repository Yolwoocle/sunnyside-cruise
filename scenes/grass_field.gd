extends Node2D

@onready var multimesh_instance: MultiMeshInstance2D = $MultiMeshInstance2D

@export var grass_palette: Array[Color]

@export_category("Terrain params")
@export var terrain_step = 16.0
@export var terrain_noise_scale = 0.01
@export var terrain_base_height = 200.0
@export var terrain_height_scale = 200.0
@export var terrain_offset = 0.0
@export var terrain_seed = -1

@export_category("Grass params")
@export var grass_count := 6000
@export var min_blade_sway := 10.0
@export var max_blade_sway := 16.0
@export var min_blade_sway_speed := 5.0
@export var max_blade_sway_speed := 8.0
@export var color_gradient_spread = 1.0
@export var color_gradient_range = 100.0

@export_category("Grass variants")
@export var variant_information: Array[GrassVariantData]

@export_category("Grass spawn params")
@export var max_spawn_attempts: int = 10
@export var polygon_bottom_padding: float = 32

@onready var multi_mesh_instance_2d: MultiMeshInstance2D = $MultiMeshInstance2D
@onready var spawn_curve: Path2D = $Path2D
@onready var spawn_polygon: Polygon2D = $Polygon2D
@onready var static_body: StaticBody2D = $StaticBody2D
@onready var collision_polygon: CollisionPolygon2D = $StaticBody2D/CollisionPolygon2D

@export_category("Decorations")
@onready var min_butterflies: int = 0
@onready var max_butterflies: int = 4
@onready var butterfly_spawn_range: float = 60.0

var _spawn_bounding_box: Rect2
var _rng = RandomNumberGenerator.new()
var _top_edge: Curve
var _weight_sum: float = 0.0


var _terrain_noise := FastNoiseLite.new() 

func _ready():
	assert(spawn_polygon != null)
	
	generate()


func _physics_process(delta: float) -> void:
	var camera = get_viewport().get_camera_2d()
	multi_mesh_instance_2d.position.x = fmod(camera.position.x + 1000.0, 1.0)


func generate() -> void:
	var multimesh = MultiMesh.new()
	multimesh.use_colors = multimesh_instance.multimesh.use_colors
	multimesh.use_custom_data = multimesh_instance.multimesh.use_custom_data
	multimesh.mesh = multimesh_instance.multimesh.mesh
	multimesh_instance.multimesh = multimesh
	
	if terrain_seed == -1:
		_terrain_noise.seed = randi()
	else:
		_terrain_noise.seed = terrain_seed
	_terrain_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	_terrain_noise.frequency = 0.05
	
	var polygon = _generate_polygon()
	spawn_polygon.polygon = polygon
	collision_polygon.polygon = polygon
	
	_get_bounding_box()
	
	_weight_sum = 0.0
	for info in variant_information:
		_weight_sum += info.probability_weight
	
	# Access the material through the child instance
	var shader_material = multimesh_instance.material as ShaderMaterial
	shader_material.set_shader_parameter("palette", PackedColorArray(grass_palette))
	shader_material.set_shader_parameter("variant_count", len(variant_information))
	
	generate_grass()
	generate_butterflies()


func _generate_polygon() -> PackedVector2Array:
	var polygon = PackedVector2Array()
	var size = get_viewport_rect().size
	spawn_curve.curve.clear_points()
	
	for ix in range(0, size.x + terrain_step, terrain_step):
		var x = ix
		var noise = _terrain_noise.get_noise_1d((terrain_offset + x) * terrain_noise_scale)
		var point = Vector2(x, terrain_base_height + noise * terrain_height_scale)
		polygon.append(point)
		spawn_curve.curve.add_point(point)
	
	
	polygon.append(Vector2(size.x, size.y + polygon_bottom_padding))
	polygon.append(Vector2(0, size.y + polygon_bottom_padding))
	
	return polygon

func _get_bounding_box():
	# Bounding box
	var points = spawn_polygon.polygon
	if points.size() == 0:
		_spawn_bounding_box = Rect2()
	else:
		var min_p = points[0]
		var max_p = points[0]
		
		for p in points:
			min_p.x = min(min_p.x, p.x)
			min_p.y = min(min_p.y, p.y)
			max_p.x = max(max_p.x, p.x)
			max_p.y = max(max_p.y, p.y)
		
		_spawn_bounding_box = Rect2(min_p, max_p - min_p)

func _get_spawn_positions():
	var positions = []
	for i in grass_count:
		var j = max_spawn_attempts
		while j > 0:
			var x = _spawn_bounding_box.position.x + randf_range(0.0, _spawn_bounding_box.size.x)
			var y = _spawn_bounding_box.position.y + randf_range(0.0, _spawn_bounding_box.size.y)
			var pos = Vector2(x, y)
			if Geometry2D.is_point_in_polygon(pos, spawn_polygon.polygon):
				positions.append(pos)
				break
			j -= 1
		if j <= 0:
			positions.append(_spawn_bounding_box.get_center())
		
	positions.sort_custom(func(a, b): return a.y < b.y)
	return positions

func _get_random_variant() -> int:
	if variant_information.is_empty():
		return 0
	
	var r = randf_range(0.0, _weight_sum)
	
	for i in len(variant_information):
		if r < variant_information[i].probability_weight:
			return i
		r -= variant_information[i].probability_weight
	return 0


func _generate_blade(instance_index: int, pos: Vector2):
	var variant = _get_random_variant()
	var variant_info = variant_information[variant]
	
	# Texture size 
	var texture_size = multimesh_instance.texture.get_size()
	texture_size.x /= len(variant_information)
	
	# Mesh size and offset 
	var mesh: QuadMesh = multimesh_instance.multimesh.mesh
	mesh.size = texture_size
	mesh.center_offset = Vector3(0, texture_size.y / 2, 0)
	
	# Update instance transform
	var signx = 1
	if variant_info.flippable:
		signx = randi_range(0, 1) * 2 - 1
	var width = randf_range(variant_info.min_blade_width, variant_info.max_blade_width)
	var height = randf_range(variant_info.min_blade_height, variant_info.max_blade_height)
	var s = Vector2( 
		1/texture_size.x * width * signx, 
		1/texture_size.y * height
	) 
	
	var blade_transform = Transform2D()
	blade_transform = blade_transform.scaled(s)
	blade_transform = blade_transform.rotated(PI + randf_range(-0.2, 0.2))
	blade_transform.origin = pos
	
	multimesh_instance.multimesh.set_instance_transform_2d(instance_index, blade_transform)
	
	# Update palette info
	var palette_index
	if variant_info.colored:
		var closest_curve_point = spawn_curve.curve.get_closest_point(pos)
		var r = clamp(closest_curve_point.distance_to(pos) / color_gradient_range, 0.0, 1.0)
		var rand_col_i = round(_rng.randfn(r * len(grass_palette), color_gradient_spread))
		rand_col_i = int(clamp(rand_col_i, 0, len(grass_palette) - 1))
		
		palette_index = rand_col_i
	else:
		palette_index = -1 # white
	
	# Assign data to the instance
	multimesh_instance.multimesh.set_instance_custom_data(
		instance_index, 
		Color(
			randf_range(min_blade_sway, max_blade_sway), # sway
			randf_range(min_blade_sway_speed, max_blade_sway_speed), # sway_speed
			float(variant), # variant index
			palette_index # palette color index
		)
	)


func generate_grass():
	multimesh_instance.multimesh.instance_count = grass_count
	
	var blade_positions = _get_spawn_positions()
	
	for i in len(blade_positions):
		var pos = floor(blade_positions[i])
		_generate_blade(i, pos)


func generate_butterflies():
	var n = randi_range(min_butterflies, max_butterflies)
	for i in n:
		var curve = spawn_curve.curve
		var point = curve.sample_baked(randf() * curve.get_baked_length())
		var offset = Vector2(0.0, -randf_range(0.0, butterfly_spawn_range))
		var butterfly = preload("res://scenes/butterfly.tscn").instantiate()
		butterfly.position = point + offset
		add_child(butterfly)
		print(butterfly.position)
