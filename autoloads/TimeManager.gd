extends Node

var current_hour: float = 8.0
var current_day: int = 1
var time_scale: float = 60.0  # 1 real second = 1 in-game minute
var paused: bool = false

var _last_emitted_hour: int = 8

func _process(delta: float) -> void:
	if paused:
		return
	current_hour += delta * time_scale / 3600.0
	if current_hour >= 24.0:
		current_hour -= 24.0
		current_day += 1
		EventBus.day_changed.emit(current_day)
		GameState.check_machine_shop_orders()
	var hour_int := int(current_hour)
	if hour_int != _last_emitted_hour:
		_last_emitted_hour = hour_int
		EventBus.time_changed.emit(current_hour)

func skip_to_hour(hour: float) -> void:
	if hour <= current_hour:
		current_day += 1
		EventBus.day_changed.emit(current_day)
		GameState.check_machine_shop_orders()
	current_hour = hour
	_last_emitted_hour = int(hour)
	EventBus.time_changed.emit(current_hour)

func advance_days(count: int) -> void:
	current_day += count
	EventBus.day_changed.emit(current_day)
	GameState.check_machine_shop_orders()

func get_time_string() -> String:
	var h := int(current_hour)
	var m := int(fmod(current_hour, 1.0) * 60.0)
	return "%02d:%02d" % [h, m]

func is_store_open() -> bool:
	return current_hour >= 8.0 and current_hour < 18.0
