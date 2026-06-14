extends Node3D
class_name InstallSlot

@export var slot_id: String = ""
@export var accepted_part_id: String = ""
@export var dependency_slot_ids: Array[String] = []
@export var ghost_mesh_path: NodePath
@export var installed_mesh_path: NodePath

var is_filled: bool = false
var installed_part_id: String = ""

func _ready() -> void:
	update_visuals()

func install_part(part_id: String) -> void:
	is_filled = true
	installed_part_id = part_id
	update_visuals()
	GameState.set_slot_filled(slot_id, part_id)
	EventBus.part_installed.emit(part_id, slot_id)

func remove_part() -> String:
	var removed_id := installed_part_id
	is_filled = false
	installed_part_id = ""
	update_visuals()
	GameState.set_slot_empty(slot_id)
	EventBus.part_removed.emit(removed_id, slot_id)
	return removed_id

func can_accept(part_id: String) -> bool:
	return accepted_part_id == part_id

func update_visuals() -> void:
	if ghost_mesh_path:
		var ghost := get_node_or_null(ghost_mesh_path)
		if ghost:
			ghost.visible = not is_filled
	if installed_mesh_path:
		var installed := get_node_or_null(installed_mesh_path)
		if installed:
			installed.visible = is_filled
