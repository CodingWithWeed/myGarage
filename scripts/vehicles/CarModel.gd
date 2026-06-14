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
}

# Group prefixes hidden on load. Includes the outer body skin + glass + trim
# (so the engine bay and underbody are accessible) and the drivetrain parts
# that are installed through gameplay. Wheels/brakes stay visible so the car
# still sits on its wheels.
const HIDDEN_AT_START := [
	# Outer body skin (hood/roof/fenders/quarters all live under this group)
	"E36_coupe_bumper",
	"E36_coupe_fender",
	"E36_coupe_grille",
	"E36_coupe_headlight",
	"E36_taillight",
	"E36_coupe_hood_logo",
	"E36_coupe_trunk",
	"E36_coupe_panels",
	# Glass
	"E36_coupe_windshield",
	"E36_coupe_sideglass",
	"E36_coupe_doorglass",
	"E36_coupe_backlight",
	"E36_coupe_sunroof",
	# Wipers / mirrors / door cards
	"E36_coupe_wipers",
	"E36_coupe_washers",
	"E36_coupe_intmirror",
	"E36_coupe_doorpanel",
	# Drivetrain parts revealed through install
	"E36_coupe_engine_m51",
	"E36_coupe_transmission",
	"E36_subframe_F",
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
