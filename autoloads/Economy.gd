extends Node

var balance: float = 450.0

func add_funds(amount: float) -> void:
	balance += amount
	EventBus.wallet_changed.emit(balance)

func spend_funds(amount: float) -> bool:
	if not can_afford(amount):
		return false
	balance -= amount
	EventBus.wallet_changed.emit(balance)
	return true

func can_afford(amount: float) -> bool:
	return balance >= amount

func get_balance() -> float:
	return balance
