extends CharacterBody3D

const WALK_SPEED := 4.0
const CROUCH_SPEED := 2.0
const JUMP_VELOCITY := 4.5
const MOUSE_SENSITIVITY := 0.002
const CROUCH_HEIGHT := 1.1
const STAND_HEIGHT := 1.8

@onready var head: Node3D = $Head
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _is_crouching := false
var _shape_height_stand := 1.8
var _shape_height_crouch := 1.1

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
			and not Input.is_action_pressed("rotate_item")):
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		head.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		head.rotation.x = clamp(head.rotation.x, -PI / 2.0, PI / 2.0)
	if event.is_action_pressed("pause"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	_handle_crouch()
	if not is_on_floor():
		velocity.y -= _gravity * delta
	if Input.is_action_just_pressed("jump") and is_on_floor() and not _is_crouching:
		velocity.y = JUMP_VELOCITY
	var direction := _get_move_direction()
	var speed := CROUCH_SPEED if _is_crouching else WALK_SPEED
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	move_and_slide()

func _get_move_direction() -> Vector3:
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	return (transform.basis * Vector3(input.x, 0.0, input.y)).normalized()

func _handle_crouch() -> void:
	var want_crouch := Input.is_action_pressed("crouch")
	if want_crouch == _is_crouching:
		return
	_is_crouching = want_crouch
	if collision_shape.shape is CapsuleShape3D:
		var cap := collision_shape.shape as CapsuleShape3D
		cap.height = CROUCH_HEIGHT if _is_crouching else STAND_HEIGHT
	head.position.y = (CROUCH_HEIGHT - 0.1) if _is_crouching else (STAND_HEIGHT - 0.2)
