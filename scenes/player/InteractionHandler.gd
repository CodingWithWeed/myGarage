extends Node
class_name InteractionHandler

signal interaction_hint_changed(hint: String)

@export var raycast: RayCast3D
@export var inventory: NodePath

var current_interactable: Interactable = null
var held_node: CarPartNode3D = null
var _player: Node3D = null
var _last_hint: String = ""

const GENERIC_PART_SCENE := "res://scenes/parts/CarPart_Generic.tscn"

func _ready() -> void:
	_player = get_parent()
	# Fail-safe: if the exported reference didn't resolve, find it by path.
	if raycast == null and _player:
		raycast = _player.get_node_or_null("Head/InteractionRaycast")
	if raycast == null:
		push_error("InteractionHandler: no RayCast3D assigned — interaction disabled")

func _process(_delta: float) -> void:
	_update_interactable()
	_update_hint()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and current_interactable != null:
		current_interactable.interact(_player)
	if event.is_action_pressed("drop_item"):
		var inv := get_node_or_null(inventory) as PlayerInventory
		if inv and inv.held_item_id != "":
			_drop_held_item(inv)

func _update_interactable() -> void:
	if not raycast:
		return
	var hit := raycast.get_collider()
	var found: Interactable = null
	if hit:
		found = _find_interactable(hit)
	if found == current_interactable:
		return
	if current_interactable:
		current_interactable.on_unhighlight()
	current_interactable = found
	if current_interactable:
		current_interactable.on_highlight()

func _update_hint() -> void:
	if current_interactable == null:
		if _last_hint != "":
			_last_hint = ""
			interaction_hint_changed.emit("")
		return
	if current_interactable.has_method("set_hint_context"):
		current_interactable.set_hint_context(_player)
	var new_hint := current_interactable.get_interaction_hint()
	if new_hint != _last_hint:
		_last_hint = new_hint
		interaction_hint_changed.emit(new_hint)

func _find_interactable(node: Node) -> Interactable:
	# Check the hit node itself
	if node is Interactable:
		return node as Interactable
	# Check hit node's children for a "Pickup" interactable (CarPartNode3D pattern)
	var pickup := node.get_node_or_null("Pickup")
	if pickup is Interactable:
		return pickup as Interactable
	# Walk up parent chain
	var current := node.get_parent()
	while current:
		if current is Interactable:
			return current as Interactable
		var p := current.get_node_or_null("Pickup")
		if p is Interactable:
			return p as Interactable
		current = current.get_parent()
	return null

func attach_part_to_hand(node: CarPartNode3D) -> void:
	held_node = node
	var hand := _player.get_node_or_null("Head/HandAttachPoint")
	if hand:
		node.reparent(hand, false)
		node.transform = Transform3D.IDENTITY

func release_held_node() -> void:
	if held_node == null:
		return
	var world := get_tree().current_scene
	held_node.reparent(world, true)
	held_node = null

func release_held_for_slot() -> void:
	held_node = null

func consume_held_node() -> void:
	if held_node == null:
		return
	held_node.queue_free()
	held_node = null

func spawn_and_hold(part_id: String) -> void:
	var scene: PackedScene = load(GENERIC_PART_SCENE)
	if scene == null:
		push_error("CarPart_Generic.tscn not found")
		return
	var node: CarPartNode3D = scene.instantiate()
	node.part_id = part_id
	get_tree().current_scene.add_child(node)
	node.pick_up()
	attach_part_to_hand(node)

func _drop_held_item(inv: PlayerInventory) -> void:
	if held_node == null:
		return
	var part_id: String = inv.drop_held()
	if part_id == "":
		return
	var drop_pos: Vector3 = _player.global_position + _player.global_transform.basis.z * -1.5
	drop_pos.y += 0.5
	var world := get_tree().current_scene
	held_node.reparent(world, true)
	held_node.drop(drop_pos, _player.global_transform.basis.z * -2.0)
	held_node = null
