extends Node3D

@export var rope: PackedScene
@export var impulse: Vector3 = Vector3(.0, .5, 3)

var angle: float = .0
var rotation_speed: float = 1.2
var rotation_min: float = -PI/2
var rotation_max: float = PI/2
var instanced_rope: Node3D
var arrow: Node3D

var rope_state: ROPE_STATE


func _ready():
	arrow = get_tree().root.get_node("/root/Catch/Player/Arrow")
	instanced_rope = null
	rope_state = ROPE_STATE.READY

func _process(delta):
	if(Input.is_action_just_pressed("throw")):
		if rope_state == ROPE_STATE.READY:
			throw_rope()
		elif rope_state == ROPE_STATE.THREW:
			recall_rope()
	
	if(angle < rotation_max and Input.is_action_pressed("left")):
		angle += rotation_speed * delta
	if(angle > rotation_min and Input.is_action_pressed("right")):
		angle -= rotation_speed * delta
		
	arrow.rotation = Vector3(0, angle, 0)

func throw_rope():
	print("Throwing rope")
	
	#Check if rope is instanced
	if(instanced_rope == null):
		instanced_rope = rope.instantiate() as Node3D
		instanced_rope.position = self.global_position
		instanced_rope.rotation = self.global_rotation
		get_tree().root.get_node("/root/Catch").add_child(instanced_rope)
		
	var rb: RigidBody3D = instanced_rope.get_child(0) as RigidBody3D
	rb.apply_central_impulse(impulse.rotated(Vector3.UP, angle))
	rope_state = ROPE_STATE.THREW

func recall_rope():
	print("Recalling rope")
	if(not instanced_rope == null):
		var rb: RigidBody3D = instanced_rope.get_child(0) as RigidBody3D
		var direction_to: Vector3 = rb.global_position.direction_to(global_position)
		
		'''
		print ("Global rope position: ", rb.global_position)
		print ("Global player position: ", rb.global_position)
		print("Angle between player and rope: ", direction_to)
		'''
		
		rb.apply_central_impulse(direction_to * 3 + Vector3.UP * 2)
		
	rope_state = ROPE_STATE.RECALLING


# Enums
enum ROPE_STATE{READY, THROWING, THREW, RECALLING}
	
