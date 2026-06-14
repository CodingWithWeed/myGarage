extends Node
class_name AssemblyValidator

@export var e36_root: NodePath

var _part_system := PartSystem.new()
var _all_slots: Array = []
var _can_start: bool = false

func _ready() -> void:
	EventBus.part_installed.connect(_on_part_changed)
	EventBus.part_removed.connect(_on_part_changed)
	call_deferred("_gather_slots")

func _gather_slots() -> void:
	var root := get_node_or_null(e36_root) if e36_root else get_parent()
	if root:
		_all_slots = _find_slots(root)
	_revalidate()

func _find_slots(node: Node) -> Array:
	var result := []
	if node is InstallSlot:
		result.append(node)
	for child in node.get_children():
		result.append_array(_find_slots(child))
	return result

func _on_part_changed(_part_id: String, _slot_id: String) -> void:
	_revalidate()

func _revalidate() -> void:
	_can_start = _part_system.is_e36_startable(_all_slots)

func attempt_start() -> bool:
	if not _can_start:
		return false
	EventBus.engine_started.emit()
	if not GameState.get_flag("e36_started_first_time"):
		GameState.set_flag("e36_started_first_time", true)
	return true

func is_startable() -> bool:
	return _can_start
