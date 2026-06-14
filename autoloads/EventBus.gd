extends Node

signal part_installed(part_id: String, slot_id: String)
signal part_removed(part_id: String, slot_id: String)

signal job_accepted(job_id: String)
signal job_step_completed(job_id: String, step_index: int)
signal job_completed(job_id: String, payout: float)

signal wallet_changed(new_balance: float)
signal part_purchased(part_id: String, cost: float)

signal customer_arrived(job_id: String)
signal customer_departed()

signal day_changed(day_number: int)
signal time_changed(hour: float)

signal engine_started()

signal part_dropped_off_machine_shop(part_id: String, ready_day: int)
signal part_ready_machine_shop(part_id: String)

signal restoration_step_completed(part_id: String, step: String)
