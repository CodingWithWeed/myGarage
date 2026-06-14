extends Node
class_name JobSystem

var active_jobs: Array[Dictionary] = []

func start_job(job_id: String, tier: int, payout: float, total_steps: int) -> void:
	var job := {
		"job_id": job_id,
		"tier": tier,
		"payout": payout,
		"steps_total": total_steps,
		"steps_completed": [],
	}
	active_jobs.append(job)
	GameState.active_jobs = _serialize_jobs()
	EventBus.job_accepted.emit(job_id)

func complete_step(job_id: String, step_index: int) -> void:
	var job := _get_job(job_id)
	if job.is_empty():
		return
	if step_index not in job["steps_completed"]:
		job["steps_completed"].append(step_index)
	GameState.active_jobs = _serialize_jobs()
	EventBus.job_step_completed.emit(job_id, step_index)
	if job["steps_completed"].size() >= job["steps_total"]:
		complete_job(job_id)

func complete_job(job_id: String) -> void:
	var job := _get_job(job_id)
	if job.is_empty():
		return
	var payout: float = job["payout"]
	active_jobs.erase(job)
	GameState.completed_jobs_count += 1
	GameState.active_jobs = _serialize_jobs()
	Economy.add_funds(payout)
	EventBus.job_completed.emit(job_id, payout)

func get_active_job() -> Dictionary:
	if active_jobs.is_empty():
		return {}
	return active_jobs[0]

func is_step_available(job_id: String, step_index: int) -> bool:
	var job := _get_job(job_id)
	if job.is_empty():
		return false
	if step_index in job["steps_completed"]:
		return false
	# Steps must be completed in order
	if step_index > 0 and (step_index - 1) not in job["steps_completed"]:
		return false
	return true

func _get_job(job_id: String) -> Dictionary:
	for job in active_jobs:
		if job["job_id"] == job_id:
			return job
	return {}

func _serialize_jobs() -> Array:
	return active_jobs.duplicate(true)
