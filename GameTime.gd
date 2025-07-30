extends Node

var GameTime: float = 0
var TimerDisplay: String = "0:00"

var TimeElapsed: float = 0
var WaitTime: float = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	GameTime += delta
	var seconds = floor(GameTime)
	var minutes = floor(seconds / 60)
	
	if seconds-minutes*60 < 10:
		seconds = str("0",seconds-minutes*60)
	else:
		seconds = str(seconds-minutes*60)
	
	TimerDisplay = str(minutes,":",(seconds))
	print(TimerDisplay)
