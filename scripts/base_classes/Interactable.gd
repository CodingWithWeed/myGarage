extends Node3D
class_name Interactable

signal interacted(player: Node)

@export var interaction_hint: String = "Interact"
@export var interaction_distance: float = 2.0

var is_highlighted: bool = false

func interact(player: Node) -> void:
	interacted.emit(player)

func get_interaction_hint() -> String:
	return interaction_hint

func on_highlight() -> void:
	is_highlighted = true

func on_unhighlight() -> void:
	is_highlighted = false
