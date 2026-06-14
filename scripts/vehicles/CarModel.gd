extends Node3D
class_name CarModel

# Drives the "hide & reveal" build-up on the imported E36 model.
# Removable parts are hidden at load (bare shell); installing the matching
# gameplay part reveals that part's real geometry in place via EventBus.

# part_id (gameplay) -> model group name prefix(es) whose nodes to reveal.
# Matching is fuzzy (normalized, prefix-based) so it survives Godot's glTF
# node-name sanitizing. Toggling a group node hides/shows its whole subtree.
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
	"front_bumper": ["E36_body_bumper_F"],
	"front_fender_left": ["E36_body_fender_L"],
	"front_fender_right": ["E36_body_fender_R"],
	"front_door_left": ["E36_body_door_FL"],
	"front_door_right": ["E36_body_door_FR"],
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
	"E36_body_bumper_F",
	"E36_body_fender_L",
	"E36_body_fender_R",
	"E36_body_door_FL",
	"E36_body_door_FR",
]

var _nodes: Array[Node3D] = []

func _ready() -> void:
	_gather_nodes(self)
	for key in HIDDEN_AT_START:
		_set_group_visible(String(key), false)
	EventBus.part_installed.connect(_on_part_installed)
	EventBus.part_removed.connect(_on_part_removed)
	# Re-show any parts already installed (e.g. loaded from a save).
	for part_id in PART_TO_GROUPS:
		var pid: String = part_id
		if GameState.is_slot_filled(pid + "_slot"):
			_reveal_part(pid, true)

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
