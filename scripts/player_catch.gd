extends Node3D

@export var rope: PackedScene
@export var impulse: Vector3 = Vector3(.0, .5, 3)

var angle: float = .0
var rotation_speed: float = 1.2
var rotation_min: float = -PI/2
var rotation_max: float = PI/2
var instanced_rope: Node3D
var arrow: Node3D
var rope_rb: RigidBody3D
var throw_cooldown: float = 2
var throw_timer: float
var throw_charge: float = 0


var rope_state: ROPE_STATE 


func _ready():
	arrow = get_tree().root.get_node("/root/Catch/Player/Arrow")
	instanced_rope = null
	rope_state = ROPE_STATE.READY
	throw_timer = throw_cooldown
	

func _process(delta):
	
	# Change throw angle based on imput
	if(angle < rotation_max and Input.is_action_pressed("left")):
		angle += rotation_speed * delta
	if(angle > rotation_min and Input.is_action_pressed("right")):
		angle -= rotation_speed * delta
	# Adjust arrow orientation
	arrow.rotation = Vector3(0, angle, 0)
	print(rope_state)
	
	if rope_state == ROPE_STATE.READY:
		if(Input.is_action_just_pressed("throw")):
			#throw_rope()
			rope_state = ROPE_STATE.CHARGING
	elif rope_state == ROPE_STATE.CHARGING:
		if(throw_charge < 1):
			throw_charge += delta
			if(throw_charge > 1):
				throw_charge = 1
		if(Input.is_action_just_released("throw")):
			throw_rope()
			rope_state = ROPE_STATE.THROWING
			throw_charge = 0		
	elif rope_state == ROPE_STATE.THROWING:
		if(throw_timer > 0):
			throw_timer -= delta
			if(throw_timer <= 0):
				rope_state = ROPE_STATE.THREW
				throw_timer = throw_cooldown
	elif rope_state == ROPE_STATE.THREW:
		if(Input.is_action_just_pressed("throw")):
			#recall_rope()
			rope_state = ROPE_STATE.RECALLING
	
	
	

func _physics_process(delta: float) -> void:
	if(rope_state == ROPE_STATE.RECALLING):
		if(rope_rb.position.distance_to(global_position) > 2):
			attract_rope()
		else:
			rope_state = ROPE_STATE.READY

func throw_rope():
	print("Throwing rope")
	
	#Check if rope is instanced
	if(instanced_rope == null):
		instanced_rope = rope.instantiate() as Node3D
		instanced_rope.position = self.global_position
		instanced_rope.rotation = self.global_rotation
		get_tree().root.get_node("/root/Catch").add_child(instanced_rope)
		
	rope_rb = instanced_rope.get_child(0) as RigidBody3D
	rope_rb.apply_central_impulse(impulse.rotated(Vector3.UP, angle) * throw_charge)
	

func recall_rope():
	print("Recalling rope")
	if(instanced_rope != null):
		#var rb: RigidBody3D = instanced_rope.get_child(0) as RigidBody3D
		var direction_to: Vector3 = rope_rb.global_position.direction_to(global_position)
		
		'''
		print ("Global rope position: ", rb.global_position)
		print ("Global player position: ", rb.global_position)
		print("Angle between player and rope: ", direction_to)
		'''
		
		rope_rb.apply_central_impulse(direction_to * 3 + Vector3.UP * 2)
		rope_state = ROPE_STATE.RECALLING
		
	

func attract_rope():
	if(instanced_rope != null):
		var direction_to: Vector3 = rope_rb.global_position.direction_to(global_position)
		rope_rb.apply_central_force(direction_to * 10 + Vector3.UP * 2)
		rope_state = ROPE_STATE.RECALLING
		
	
	
	
	

# Enums
enum ROPE_STATE{READY, CHARGING, THROWING, THREW, RECALLING}
	
