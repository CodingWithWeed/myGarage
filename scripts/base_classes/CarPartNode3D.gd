extends RigidBody3D
class_name CarPartNode3D

signal picked_up(part_id: String)
signal dropped(part_id: String)

@export var part_id: String = ""

var is_held: bool = false
var _original_collision_layer: int = 0
var _original_collision_mask: int = 0

func _ready() -> void:
	_original_collision_layer = collision_layer
	_original_collision_mask = collision_mask

func pick_up() -> void:
	is_held = true
	freeze = true
	collision_layer = 0
	collision_mask = 0
	picked_up.emit(part_id)

func drop(drop_position: Vector3, impulse: Vector3 = Vector3.ZERO) -> void:
	is_held = false
	global_position = drop_position
	freeze = false
	collision_layer = _original_collision_layer
	collision_mask = _original_collision_mask
	if impulse != Vector3.ZERO:
		apply_central_impulse(impulse)
	dropped.emit(part_id)
