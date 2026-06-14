extends Interactable
class_name PartPickupInteractable

@onready var _part: CarPartNode3D = get_parent() as CarPartNode3D

func interact(player: Node) -> void:
	var inv: PlayerInventory = player.get_node("Inventory")
	var handler: InteractionHandler = player.get_node("InteractionHandler")
	if inv.held_item_id != "" or _part == null or _part.is_held or _part.is_installed:
		return
	_part.pick_up()
	inv.pick_up(_part.part_id)
	handler.attach_part_to_hand(_part)
	interacted.emit(player)

func get_interaction_hint() -> String:
	if _part == null or _part.is_held or _part.is_installed:
		return ""
	var part_name: String = PartCatalog.get_part(_part.part_id).get("name", _part.part_id)
	return "[E] Pick up: " + part_name

func on_highlight() -> void:
	super.on_highlight()
	if _part:
		_part.set_highlighted(true)

func on_unhighlight() -> void:
	super.on_unhighlight()
	if _part:
		_part.set_highlighted(false)
