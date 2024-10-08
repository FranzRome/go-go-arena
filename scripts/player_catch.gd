extends MeshInstance3D

@export var rope: PackedScene
var instanced_rope: Node3D

@export var impulse: Vector3 = Vector3(.0, .5, 3)
var angle: float = .0
var rotation_speed = 1.2
var rotation_min = -PI/2
var rotation_max = PI/2
var arrow: Node3D

var is_rope_threw: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	arrow = get_tree().root.get_node("/root/Catch/Player/Arrow")
	is_rope_threw = false
	instanced_rope = null


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(Input.is_action_just_pressed("throw")):
		if(not is_rope_threw):
			throw_rope()
		else:
			recall_rope()
	
	if(angle < rotation_max and Input.is_action_pressed("left")):
		angle += rotation_speed * delta
	if(angle > rotation_min and Input.is_action_pressed("right")):
		angle -= rotation_speed * delta
		
	arrow.rotation = Vector3(0, angle, 0)

func throw_rope():
	#print("throwing rope")
	if(instanced_rope == null):
		instanced_rope = rope.instantiate() as Node3D
		instanced_rope.position = self.global_position
		instanced_rope.rotation = self.global_rotation
		get_tree().root.get_node("/root/Catch").add_child(instanced_rope)
		
	var rb: RigidBody3D = instanced_rope.get_child(0) as RigidBody3D
	rb.apply_central_impulse(impulse.rotated(Vector3.UP, angle))
	is_rope_threw = true
	
func recall_rope():
	print("Recalling rope")
	if(not instanced_rope == null):
		var rb: RigidBody3D = instanced_rope.get_child(0) as RigidBody3D
		var direction_to: Vector3 = instanced_rope.global_position.direction_to(global_position)
		print ("Global rope position: ", instanced_rope.global_position)
		print ("Global player position: ", global_position)
		print("Angle between player and rope: ", direction_to)
		rb.apply_central_impulse(direction_to)
		
	is_rope_threw = false
