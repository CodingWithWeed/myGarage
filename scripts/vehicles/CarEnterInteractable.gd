extends Interactable
class_name CarEnterInteractable

func _ready() -> void:
	interaction_hint = "Press E to enter"

func interact(player: Node) -> void:
	var car := get_parent()
	if car.has_method("enter_car"):
		car.enter_car(player)
