extends Node
class_name InteractionHandler

signal interaction_hint_changed(hint: String)

@export var raycast: RayCast3D
@export var inventory: NodePath

var current_interactable: Interactable = null
var _player: Node = null

func _ready() -> void:
	_player = get_parent()

func _process(_delta: float) -> void:
	_update_interactable()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and current_interactable != null:
		current_interactable.interact(_player)
	if event.is_action_pressed("drop_item"):
		var inv := get_node_or_null(inventory)
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
		interaction_hint_changed.emit(current_interactable.get_interaction_hint())
	else:
		interaction_hint_changed.emit("")

func _find_interactable(node: Node) -> Interactable:
	if node is Interactable:
		return node as Interactable
	var parent := node.get_parent()
	while parent:
		if parent is Interactable:
			return parent as Interactable
		parent = parent.get_parent()
	return null

func _drop_held_item(inv: Node) -> void:
	var part_id := inv.drop_held()
	if part_id == "":
		return
	# Spawn a physical part node in front of the player
	# (placeholder — actual part scene instantiation added in Phase 1)
	var drop_pos := _player.global_position + _player.global_transform.basis.z * -1.5
	drop_pos.y += 0.5
	# TODO: instance the part's scene and call .drop(drop_pos)
