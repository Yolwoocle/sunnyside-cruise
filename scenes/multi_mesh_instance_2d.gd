extends MultiMeshInstance2D

@export var grass_palette: Array[Color]

@export_category("Spawn params")
@export var spawn_curve: Path2D
@export var spawn_polygon: Polygon2D
@export var max_spawn_attempts: int = 10
@export var polygon_bottom_padding: float = 32

@export_category("Grass variants")
@export var variant_information: Array[GrassVariantData]

@export_category("Grass params")
@export var grass_count := 3000
@export var min_blade_sway := 10.0
@export var max_blade_sway := 16.0
@export var min_blade_sway_speed := 5.0
@export var max_blade_sway_speed := 8.0
@export var color_gradient_spread = 1.0
@export var color_gradient_range = 100.0

var _spawn_bounding_box: Rect2
var _rng = RandomNumberGenerator.new()
var _top_edge: Curve
var _weight_sum: float = 0.0

func _ready():
	assert(spawn_polygon != null)
	
	# Top edge
	_generate_polygon_from_curve()
	_get_bounding_box()
	
	_weight_sum = 0.0
	for info in variant_information:
		_weight_sum += info.probability_weight
	
	var shader_material = material as ShaderMaterial
	shader_material.set_shader_parameter("palette", PackedColorArray(grass_palette))
	shader_material.set_shader_parameter("variant_count", len(variant_information))
	
	generate()

func _generate_polygon_from_curve():
	var polygon = PackedVector2Array()
	for p in spawn_curve.curve.get_baked_points():
		polygon.append(p)
	
	var size = get_viewport_rect().size
	polygon.append(Vector2(size.x, size.y + polygon_bottom_padding))
	polygon.append(Vector2(0, size.y + polygon_bottom_padding))
	
	spawn_polygon.polygon = polygon

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

func _get_random_variant():
	if variant_information.is_empty():
		return 
	
	var r = randf_range(0.0, _weight_sum)
	
	for i in len(variant_information):
		if r < variant_information[i].probability_weight:
			return i
		r -= variant_information[i].probability_weight
	return 0

func generate():
	multimesh.instance_count = grass_count
	
	var blade_positions = _get_spawn_positions()
	var number_variants = len(variant_information)
	
	for i in len(blade_positions):
		var pos = floor(blade_positions[i])
		
		var variant = _get_random_variant()
		var variant_info = variant_information[variant]
		
		var texture_size = texture.get_size()
		texture_size.x /= number_variants
		
		var mesh: QuadMesh = multimesh.mesh
		mesh.size = texture_size
		mesh.center_offset = Vector3(0, texture_size.y / 2, 0)
		
		var blade_transform = Transform2D()
		var signx = 1
		if variant_info.flippable:
			signx = randi_range(0, 1) * 2 - 1
		var width = randf_range(variant_info.min_blade_width, variant_info.max_blade_width)
		var height = randf_range(variant_info.min_blade_height, variant_info.max_blade_height)
		var s = Vector2( 
			1/texture_size.x * width * signx, 
			1/texture_size.y * height
		) 
		blade_transform = blade_transform.scaled(s)
		blade_transform = blade_transform.rotated(PI + randf_range(-0.2, 0.2))
		blade_transform.origin = pos
		
		multimesh.set_instance_transform_2d(i, blade_transform)
		
		var palette_index
		if variant_info.colored:
			var closest_curve_point = spawn_curve.curve.get_closest_point(pos)
			var r = clamp(closest_curve_point.distance_to(pos) / color_gradient_range, 0.0, 1.0)
			var rand_col_i = round(_rng.randfn(r * len(grass_palette), color_gradient_spread))
			rand_col_i = int(clamp(rand_col_i, 0, len(grass_palette) - 1))
			
			palette_index = rand_col_i
		else:
			palette_index = -1
		
		multimesh.set_instance_custom_data(i, Color(
			randf_range(min_blade_sway, max_blade_sway), # sway
			randf_range(min_blade_sway_speed, max_blade_sway_speed), # sway_speed
			float(variant), 
			palette_index
		))
		
		#todo color_gradient_spread


func _input(event):
	if event.is_action_pressed("ui_accept"):
		generate()
