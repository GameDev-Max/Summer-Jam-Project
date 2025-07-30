extends Node

var GameTime: float = 0
var Seconds

var TimeElapsed: float = 0
var WaitTime: float = 5

var Hazards: Array[Resource] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var path := "res://Hazards/Resources"
	var dir := DirAccess.open(path)

	if dir == null:
		push_error("Couldn't open directory: " + path)
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()

	while file_name != "":
		if !dir.current_is_dir() and (file_name.ends_with(".tres") or file_name.ends_with(".res")):
			var full_path := path + "/" + file_name
			var resource = load(full_path)
			if resource != null:
				Hazards.append(resource)
		file_name = dir.get_next()

	dir.list_dir_end()

	print("Hazard resources loaded: ", Hazards.size())
	for r in Hazards:
		print(" - ", r.resource_path)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	TimeElapsed += delta
	
	if TimeElapsed >= WaitTime:
		SpawnHazard()
		TimeElapsed = 0
		
		if WaitTime >= 0.1:
			WaitTime -= 0.1
		else:
			WaitTime *= 0.95

func SpawnHazard():
	print("Spawning hazard")
	var hazard_res : Resource = Hazards.pick_random()
	var scene: PackedScene = hazard_res.Hazard
	var Hazard: Node2D = scene.instantiate()
	
	var area_name : String = hazard_res.SpawnerArea
	
	var shape_node := $SpawningAreas/In
	
	if area_name == "Out":
		if randi_range(0,1) == 0:
			shape_node = $SpawningAreas/OutLeft
		else:
			shape_node = $SpawningAreas/OutRight
	
	
	var shape = shape_node.shape
	var e = shape.extents
	
	Hazard.global_position = shape_node.global_position + Vector2(randf_range(-e.x, e.x),randf_range(-e.y, e.y))
	
	add_child(Hazard)
