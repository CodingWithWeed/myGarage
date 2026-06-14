extends CanvasLayer

@onready var hint_label: Label = $InteractionHint
@onready var wallet_label: Label = $WalletLabel
@onready var time_label: Label = $TimeLabel

func _ready() -> void:
	hint_label.visible = false
	EventBus.wallet_changed.connect(_on_wallet_changed)
	EventBus.time_changed.connect(_on_time_changed)
	_on_wallet_changed(Economy.get_balance())
	_on_time_changed(TimeManager.current_hour)
	call_deferred("_connect_player")

func _connect_player() -> void:
	var player := get_tree().current_scene.get_node_or_null("Player")
	if player:
		var handler := player.get_node_or_null("InteractionHandler")
		if handler:
			handler.interaction_hint_changed.connect(_on_hint_changed)

func _on_hint_changed(hint: String) -> void:
	hint_label.text = hint
	hint_label.visible = hint != ""

func _on_wallet_changed(new_balance: float) -> void:
	if wallet_label:
		wallet_label.text = "$%.0f" % new_balance

func _on_time_changed(_hour: float) -> void:
	if time_label:
		time_label.text = TimeManager.get_time_string() + "  Day " + str(TimeManager.current_day)
