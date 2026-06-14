extends Interactable
class_name InstallSlot

@export var slot_id: String = ""
@export var accepted_part_id: String = ""
@export var dependency_slot_ids: Array[String] = []
# When true, the installed part's appearance is the real model mesh (revealed
# by CarModel via EventBus) rather than the carried physics node snapping in.
@export var use_model_reveal: bool = false
# When true the slot begins already filled (e.g. the hood is on the car at the
# start). The model mesh is already visible, so no install event is emitted.
@export var starts_filled: bool = false

var is_filled: bool = false
var installed_part_id: String = ""

var _ghost_mesh: MeshInstance3D = null
var _ghost_material: StandardMaterial3D = null
var _installed_node: CarPartNode3D = null
var _pulse_time: float = 0.0
var _cached_hint: String = ""
var _is_correct_part_held: bool = false

const CATEGORY_COLORS := {
	"engine": Color(0.8, 0.2, 0.1),
	"drivetrain": Color(0.8, 0.5, 0.0),
	"suspension": Color(0.1, 0.3, 0.8),
	"brakes": Color(0.7, 0.7, 0.0),
	"electrical": Color(0.0, 0.7, 0.7),
	"body": Color(0.4, 0.4, 0.4),
	"interior": Color(0.5, 0.2, 0.6),
	"exhaust": Color(0.5, 0.3, 0.1),
	"wheels": Color(0.15, 0.6, 0.15),
	"steering": Color(0.7, 0.3, 0.5),
	"consumable": Color(0.85, 0.85, 0.85),
}

const CATEGORY_BOX_SIZE := {
	"engine": Vector3(0.3, 0.2, 0.35),
	"drivetrain": Vector3(0.25, 0.2, 0.3),
	"suspension": Vector3(0.15, 0.35, 0.1),
	"brakes": Vector3(0.28, 0.06, 0.28),
	"electrical": Vector3(0.18, 0.1, 0.18),
	"body": Vector3(0.55, 0.05, 0.45),
	"interior": Vector3(0.4, 0.25, 0.45),
	"exhaust": Vector3(0.08, 0.08, 0.38),
	"wheels": Vector3(0.22, 0.55, 0.22),
	"steering": Vector3(0.1, 0.1, 0.35),
	"consumable": Vector3(0.1, 0.18, 0.1),
}

func _ready() -> void:
	if slot_id == "":
		slot_id = name
	_setup_meshes()
	if starts_filled:
		is_filled = true
		installed_part_id = accepted_part_id
		GameState.set_slot_filled(slot_id, accepted_part_id)
	update_visuals()

func _setup_meshes() -> void:
	var part_data := PartCatalog.get_part(accepted_part_id)
	var category: String = part_data.get("category", "engine")
	var color: Color = CATEGORY_COLORS.get(category, Color(0.5, 0.5, 0.5))
	var size: Vector3 = CATEGORY_BOX_SIZE.get(category, Vector3(0.2, 0.2, 0.2))

	# Very faint ghost outline — shows where a part goes.
	# Brightens and pulses when the player carries the matching part.
	_ghost_mesh = MeshInstance3D.new()
	var ghost_box := BoxMesh.new()
	ghost_box.size = size
	_ghost_mesh.mesh = ghost_box
	_ghost_material = StandardMaterial3D.new()
	_ghost_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_ghost_material.albedo_color = Color(color.r, color.g, color.b, 0.08)
	_ghost_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_ghost_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	_ghost_mesh.material_override = _ghost_material
	add_child(_ghost_mesh)

	# Detection area so the raycast can find this slot
	var area := Area3D.new()
	area.collision_layer = 2
	area.collision_mask = 0
	var area_shape := CollisionShape3D.new()
	var area_box := BoxShape3D.new()
	area_box.size = size * 1.15
	area_shape.shape = area_box
	area.add_child(area_shape)
	add_child(area)

func _process(delta: float) -> void:
	if is_filled or not _ghost_material:
		return
	if _is_correct_part_held:
		_pulse_time += delta * 3.0
		_ghost_material.albedo_color.a = 0.20 + 0.15 * sin(_pulse_time)
	else:
		_ghost_material.albedo_color.a = 0.08

# node is the live CarPartNode3D being snapped in; null when restoring from save.
func install_part(part_id: String, node: CarPartNode3D = null) -> void:
	is_filled = true
	installed_part_id = part_id
	_installed_node = node
	if node:
		node.is_installed = true
		node.reparent(self, true)
		node.position = Vector3.ZERO
		node.rotation = Vector3.ZERO
		node.freeze = true
		node.collision_layer = 0
		node.collision_mask = 0
	update_visuals()
	GameState.set_slot_filled(slot_id, part_id)
	EventBus.part_installed.emit(part_id, slot_id)

func remove_part() -> String:
	var removed_id := installed_part_id
	var node := _installed_node
	is_filled = false
	installed_part_id = ""
	_installed_node = null
	if node:
		node.is_installed = false
		var world := get_tree().current_scene
		if world:
			node.reparent(world, true)
	update_visuals()
	GameState.set_slot_empty(slot_id)
	EventBus.part_removed.emit(removed_id, slot_id)
	return removed_id

func can_accept(part_id: String) -> bool:
	return accepted_part_id == part_id

func update_visuals() -> void:
	if _ghost_mesh:
		_ghost_mesh.visible = false

func interact(player: Node) -> void:
	var inv: PlayerInventory = player.get_node("Inventory")
	var handler: InteractionHandler = player.get_node("InteractionHandler")

	if is_filled:
		if inv.held_item_id == "":
			if use_model_reveal:
				var removed_id := remove_part()
				inv.pick_up(removed_id)
				handler.spawn_and_hold(removed_id)
			else:
				var node := _installed_node
				var removed_id := remove_part()
				if node:
					inv.pick_up(removed_id)
					handler.attach_part_to_hand(node)
			interacted.emit(player)
	else:
		var held_id := inv.held_item_id
		if held_id == accepted_part_id and _deps_met():
			if use_model_reveal:
				handler.consume_held_node()
				inv.drop_held()
				install_part(held_id, null)
			else:
				var node: CarPartNode3D = handler.held_node
				handler.release_held_for_slot()
				inv.drop_held()
				install_part(held_id, node)
			interacted.emit(player)

func set_hint_context(player: Node) -> void:
	var inv: PlayerInventory = player.get_node("Inventory")
	var held_id := inv.held_item_id

	if is_filled:
		var part_name: String = PartCatalog.get_part(installed_part_id).get("name", installed_part_id)
		if held_id == "":
			_cached_hint = "[E] Remove: " + part_name
			_is_correct_part_held = false
		else:
			_cached_hint = part_name + " installed — drop item first"
			_is_correct_part_held = false
	else:
		var accepted_name: String = PartCatalog.get_part(accepted_part_id).get("name", accepted_part_id)
		if held_id == "":
			_cached_hint = "Needs: " + accepted_name
			_is_correct_part_held = false
		elif held_id == accepted_part_id:
			if _deps_met():
				_cached_hint = "[E] Install: " + accepted_name
				_is_correct_part_held = true
			else:
				var missing := _get_first_missing_dep_name()
				_cached_hint = "Install first: " + missing
				_is_correct_part_held = false
		else:
			_cached_hint = "Wrong part"
			_is_correct_part_held = false

	if _ghost_mesh:
		_ghost_mesh.visible = _is_correct_part_held and not is_filled
	if _ghost_material:
		if _is_correct_part_held and not is_filled:
			_ghost_material.emission_enabled = true
			var c := _ghost_material.albedo_color
			_ghost_material.emission = Color(c.r, c.g, c.b)
			_ghost_material.emission_energy_multiplier = 0.6
		else:
			_ghost_material.emission_enabled = false

func get_interaction_hint() -> String:
	return _cached_hint

func _deps_met() -> bool:
	for dep in dependency_slot_ids:
		if not GameState.is_slot_filled(dep):
			return false
	return true

func _get_first_missing_dep_name() -> String:
	for dep_slot_id in dependency_slot_ids:
		if GameState.is_slot_filled(dep_slot_id):
			continue
		for pid in PartCatalog.parts:
			var p: Dictionary = PartCatalog.parts[pid]
			if p.get("install_slot", "") == dep_slot_id:
				return p.get("name", dep_slot_id)
	return "dependency"
