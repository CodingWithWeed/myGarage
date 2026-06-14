extends VehicleBody3D
class_name CarModel

# Drives the "hide & reveal" build-up on the imported E36 model.
# Removable parts are hidden at load (bare shell); installing the matching
# gameplay part reveals that part's real geometry in place via EventBus.
# Also handles player entry/exit and driving physics.

const PART_TO_GROUPS := {
	"engine_block": ["E36_coupe_engine_m51"],
	"gearbox": ["E36_coupe_transmission"],
	"front_subframe": ["E36_subframe_F"],
	"rear_subframe": ["E36_coupe_subframe_R"],
	"front_anti_roll_bar": ["E36_swaybar_F"],
	"rear_anti_roll_bar": ["E36_coupe_swaybar_R"],
	"front_lower_control_arm_left": ["E36_lowerarm_F_a"],
	"front_lower_control_arm_right": ["E36_lowerarm_F_b"],
	"hood": ["E36_coupe_bumper_R_trim_BMWE36_paint.001"],
}

const HIDDEN_AT_START := [
	"E36_coupe_engine_m51",
	"E36_coupe_transmission",
	"E36_subframe_F",
	"E36_coupe_subframe_R",
	"E36_swaybar_F",
	"E36_coupe_swaybar_R",
	"E36_lowerarm_F_a",
	"E36_lowerarm_F_b",
]

const MAX_STEER := 0.45
const ENGINE_POWER := 2500.0
const BRAKE_POWER := 30.0

var _nodes: Array[Node3D] = []
var _is_driven := false
var _driver: Node = null
var _drive_camera: Camera3D = null

func _ready() -> void:
	_gather_nodes(self)
	for key in HIDDEN_AT_START:
		_set_group_visible(String(key), false)
	EventBus.part_installed.connect(_on_part_installed)
	EventBus.part_removed.connect(_on_part_removed)
	for part_id in PART_TO_GROUPS:
		var pid: String = part_id
		if GameState.is_slot_filled(pid + "_slot"):
			_reveal_part(pid, true)
	# Start parked
	freeze = true
	freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	_drive_camera = get_node_or_null("DriveCamera")

func _physics_process(delta: float) -> void:
	if not _is_driven:
		return
	var throttle := Input.get_axis("move_backward", "move_forward")
	var steer_input := Input.get_axis("move_right", "move_left") * MAX_STEER
	steering = move_toward(steering, steer_input, delta * 3.0)
	# Brake when pressing reverse while rolling forward
	var going_forward := linear_velocity.dot(-global_transform.basis.z) > 0.5
	if throttle < 0.0 and going_forward:
		brake = BRAKE_POWER
		engine_force = 0.0
	else:
		brake = 0.0
		engine_force = throttle * ENGINE_POWER
	if Input.is_action_just_pressed("interact"):
		exit_car()

func enter_car(player: Node) -> void:
	if _is_driven:
		return
	_driver = player
	_is_driven = true
	freeze = false
	player.process_mode = Node.PROCESS_MODE_DISABLED
	if _drive_camera:
		_drive_camera.current = true

func exit_car() -> void:
	if not _is_driven or _driver == null:
		return
	# Place player beside driver's door (local -X = left side)
	var exit_offset := global_transform.basis.x * -1.5 + Vector3(0, 0.5, 0)
	_driver.global_position = global_position + exit_offset
	_driver.process_mode = Node.PROCESS_MODE_INHERIT
	if _drive_camera:
		_drive_camera.current = false
	_is_driven = false
	_driver = null
	engine_force = 0.0
	brake = BRAKE_POWER
	steering = 0.0
	freeze = true
	freeze_mode = RigidBody3D.FREEZE_MODE_STATIC

func _gather_nodes(node: Node) -> void:
	if node is Node3D and node != self:
		_nodes.append(node)
	for child in node.get_children():
		_gather_nodes(child)

static func _norm(s: String) -> String:
	var out := ""
	var low := s.to_lower()
	for i in low.length():
		var ch := low.substr(i, 1)
		if (ch >= "a" and ch <= "z") or (ch >= "0" and ch <= "9"):
			out += ch
	return out

func _set_group_visible(group_key: String, vis: bool) -> void:
	var key := _norm(group_key)
	if key == "":
		return
	for n in _nodes:
		if _norm(String(n.name)).begins_with(key):
			n.visible = vis

func _reveal_part(part_id: String, vis: bool) -> void:
	var groups: Array = PART_TO_GROUPS.get(part_id, [])
	for grp in groups:
		_set_group_visible(String(grp), vis)

func _on_part_installed(part_id: String, _slot_id: String) -> void:
	_reveal_part(part_id, true)

func _on_part_removed(part_id: String, _slot_id: String) -> void:
	_reveal_part(part_id, false)
