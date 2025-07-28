extends Node

var GameTime: float = 0
var Seconds

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	GameTime += delta
	Seconds = floor(GameTime)
	print(Seconds)
