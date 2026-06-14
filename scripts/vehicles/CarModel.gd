extends Node3D
class_name CarModel

# Drives the "hide & reveal" build-up on the imported E36 model.
# Removable parts are hidden at load (bare shell); installing the matching
# gameplay part reveals that part's real mesh in place via EventBus signals.

# part_id (gameplay) -> model group name prefix(es) whose meshes to reveal.
# Matching is fuzzy (normalized, prefix-based) so it survives Godot's glTF
# node-name sanitizing and the per-material child suffixes.
const PART_TO_GROUPS := {
	"engine_block": ["E36_coupe_engine_m51"],
	"gearbox": ["E36_coupe_transmission"],
	"front_subframe": ["E36_subframe_F"],
}

# Group prefixes hidden on load so the car starts stripped of these parts.
# (Wheels/brakes intentionally left visible for now so the body still sits
# on its wheels instead of floating.)
const HIDDEN_AT_START := [
	"E36_coupe_engine_m51",
	"E36_coupe_transmission",
	"E36_subframe_F",
]

var _meshes: Array[MeshInstance3D] = []

func _ready() -> void:
	_gather_meshes(self)
	for key in HIDDEN_AT_START:
		_set_group_visible(String(key), false)
	EventBus.part_installed.connect(_on_part_installed)
	EventBus.part_removed.connect(_on_part_removed)
	# Re-show any parts already installed (e.g. loaded from a save).
	for part_id in PART_TO_GROUPS:
		var pid: String = part_id
		if GameState.is_slot_filled(pid + "_slot"):
			_reveal_part(pid, true)

func _gather_meshes(node: Node) -> void:
	if node is MeshInstance3D:
		_meshes.append(node)
	for child in node.get_children():
		_gather_meshes(child)

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
	for m in _meshes:
		if _norm(String(m.name)).begins_with(key):
			m.visible = vis

func _reveal_part(part_id: String, vis: bool) -> void:
	var groups: Array = PART_TO_GROUPS.get(part_id, [])
	for grp in groups:
		_set_group_visible(String(grp), vis)

func _on_part_installed(part_id: String, _slot_id: String) -> void:
	_reveal_part(part_id, true)

func _on_part_removed(part_id: String, _slot_id: String) -> void:
	_reveal_part(part_id, false)
