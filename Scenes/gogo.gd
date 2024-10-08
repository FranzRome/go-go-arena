extends MeshInstance3D

@export var speed: float = 1.2
var max_x: float = 2.3
var min_x: float = -2.1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	transform.origin.x += speed * delta
	if(transform.origin.x < min_x):
		transform.origin.x = min_x
		speed *= -1
	elif (transform.origin.x > max_x):
		transform.origin.x = max_x
		speed *= -1
	print(transform.origin.x)
	pass
