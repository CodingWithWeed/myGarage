extends RigidBody3D
class_name CarPartNode3D

signal picked_up(part_id: String)
signal dropped(part_id: String)

@export var part_id: String = ""

var is_held: bool = false
var is_installed: bool = false
var _original_collision_layer: int = 0
var _original_collision_mask: int = 0
var _material: StandardMaterial3D = null
var _visual_meshes: Array[MeshInstance3D] = []
var _highlight_overlay: StandardMaterial3D = null

# --- MSC-style physics grab ---
# A held part is NOT teleported into the hand or frozen; it stays a live physics
# body that chases a hold point in front of the camera (so it still collides
# with the world) and can be free-rotated with the mouse.
var _hold_point: Node3D = null
var _ignore_body: PhysicsBody3D = null
var _held_basis: Basis = Basis.IDENTITY

const HELD_LAYER := 8          # off the interaction raycast mask (1|2|3) while held
const HOLD_POS_GAIN := 12.0
const HOLD_MAX_SPEED := 9.0
const HOLD_ROT_GAIN := 14.0
const HOLD_MAX_ANGVEL := 14.0
const ROTATE_SENSITIVITY := 0.01

const CATEGORY_COLORS := {
	"engine": Color(0.8, 0.2, 0.1),
	"drivetrain": Color(0.8, 0.5, 0.0),
	"suspension": Color(0.1, 0.3, 0.8),
	"brakes": Color(0.7, 0.7, 0.0),
	"electrical": Color(0.0, 0.7, 0.7),
	"body": Color(0.4, 0.4, 0.4),
	"interior": Color(0.5, 0.2, 0.6),
	"exhaust": Color(0.5, 0.3, 0.1),
	"wheels": Color(0.15, 0.6, 0.15),
	"steering": Color(0.7, 0.3, 0.5),
	"consumable": Color(0.85, 0.85, 0.85),
}

const CATEGORY_BOX_SIZE := {
	"engine": Vector3(0.3, 0.2, 0.35),
	"drivetrain": Vector3(0.25, 0.2, 0.3),
	"suspension": Vector3(0.15, 0.35, 0.1),
	"brakes": Vector3(0.28, 0.06, 0.28),
	"electrical": Vector3(0.18, 0.1, 0.18),
	"body": Vector3(0.55, 0.05, 0.45),
	"interior": Vector3(0.4, 0.25, 0.45),
	"exhaust": Vector3(0.08, 0.08, 0.38),
	"wheels": Vector3(0.22, 0.55, 0.22),
	"steering": Vector3(0.1, 0.1, 0.35),
	"consumable": Vector3(0.1, 0.18, 0.1),
}

func _ready() -> void:
	_original_collision_layer = collision_layer
	_original_collision_mask = collision_mask
	if part_id != "":
		call_deferred("_apply_category_material")

func _physics_process(delta: float) -> void:
	if not is_held or _hold_point == null or not is_instance_valid(_hold_point):
		return
	# Chase the hold point with velocity (keeps collisions live, MSC-style).
	var to_target := _hold_point.global_position - global_position
	linear_velocity = (to_target * HOLD_POS_GAIN).limit_length(HOLD_MAX_SPEED)
	# Drive the orientation toward the target basis the player has rotated to.
	var cur_q := global_transform.basis.get_rotation_quaternion()
	var tgt_q := _held_basis.get_rotation_quaternion()
	var dq := (tgt_q * cur_q.inverse()).normalized()
	if dq.w < 0.0:
		dq = -dq  # shortest path
	var s := sqrt(maxf(1.0 - dq.w * dq.w, 0.0))
	if s > 0.0001:
		var angle := 2.0 * acos(clampf(dq.w, -1.0, 1.0))
		var axis := Vector3(dq.x, dq.y, dq.z) / s
		angular_velocity = (axis * angle * HOLD_ROT_GAIN).limit_length(HOLD_MAX_ANGVEL)
	else:
		angular_velocity = Vector3.ZERO

func _apply_category_material() -> void:
	var data := PartCatalog.get_part(part_id)
	if data.is_empty():
		return
	var category: String = data.get("category", "engine")
	var color: Color = CATEGORY_COLORS.get(category, Color(0.5, 0.5, 0.5))
	var size: Vector3 = CATEGORY_BOX_SIZE.get(category, Vector3(0.2, 0.2, 0.2))

	# Prefer the real model geometry; fall back to a coloured box.
	if PartVisuals.has_visual(part_id):
		var visual := PartVisuals.make_visual(part_id)
		if visual != null:
			var box_node := get_node_or_null("MeshInstance3D")
			if box_node is MeshInstance3D:
				(box_node as MeshInstance3D).visible = false
			add_child(visual)
			_collect_visual_meshes(visual)
			_fit_collider_to_visual()
			return

	var mesh_node := get_node_or_null("MeshInstance3D")
	if mesh_node is MeshInstance3D:
		var box := BoxMesh.new()
		box.size = size
		mesh_node.mesh = box
		var mat := StandardMaterial3D.new()
		mat.albedo_color = color
		mat.roughness = 0.9
		mesh_node.material_override = mat
		_material = mat

	var col_node := get_node_or_null("CollisionShape3D")
	if col_node is CollisionShape3D:
		var shape := BoxShape3D.new()
		shape.size = size
		col_node.shape = shape

func _collect_visual_meshes(node: Node) -> void:
	if node is MeshInstance3D:
		_visual_meshes.append(node as MeshInstance3D)
	for c in node.get_children():
		_collect_visual_meshes(c)

# Size the physics collider to the real geometry so big parts (engine, subframe)
# rest on a surface instead of sinking with a default tiny box.
func _fit_collider_to_visual() -> void:
	var col := get_node_or_null("CollisionShape3D")
	if not (col is CollisionShape3D):
		return
	var inv := global_transform.affine_inverse()
	var has := false
	var merged := AABB()
	for m in _visual_meshes:
		if m.mesh == null:
			continue
		var local := inv * m.global_transform
		var a: AABB = local * m.mesh.get_aabb()
		if not has:
			merged = a
			has = true
		else:
			merged = merged.merge(a)
	if not has or merged.size == Vector3.ZERO:
		return
	var box := BoxShape3D.new()
	box.size = merged.size
	(col as CollisionShape3D).shape = box
	(col as CollisionShape3D).position = merged.position + merged.size * 0.5

func set_highlighted(on: bool) -> void:
	# Box parts glow via their own material; real-mesh parts use a per-instance
	# overlay so the shared model materials aren't affected.
	if _material != null:
		_material.emission_enabled = on
		if on:
			_material.emission = _material.albedo_color.lightened(0.5)
			_material.emission_energy_multiplier = 0.6
	if not _visual_meshes.is_empty():
		if on and _highlight_overlay == null:
			_highlight_overlay = StandardMaterial3D.new()
			_highlight_overlay.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			_highlight_overlay.albedo_color = Color(1.0, 1.0, 0.7, 0.18)
			_highlight_overlay.emission_enabled = true
			_highlight_overlay.emission = Color(1.0, 0.95, 0.5)
			_highlight_overlay.emission_energy_multiplier = 0.4
		for m in _visual_meshes:
			m.material_overlay = _highlight_overlay if on else null

# Begin an MSC-style grab: the body stays in the world and chases hold_point.
# ignore_body (the player) is excepted so the held part can't shove the camera.
func pick_up(hold_point: Node3D = null, ignore_body: PhysicsBody3D = null) -> void:
	set_highlighted(false)
	is_held = true
	is_installed = false
	_hold_point = hold_point
	_ignore_body = ignore_body
	if ignore_body != null:
		add_collision_exception_with(ignore_body)
	freeze = false
	sleeping = false
	can_sleep = false
	gravity_scale = 0.0
	linear_damp = 4.0
	angular_damp = 8.0
	collision_layer = HELD_LAYER
	collision_mask = _original_collision_mask
	_held_basis = global_transform.basis.orthonormalized()
	picked_up.emit(part_id)

# Rotate the held part with the mouse (relative to the camera), MSC-style.
func rotate_by_mouse(rel: Vector2, camera: Node3D) -> void:
	if not is_held or camera == null:
		return
	var up := camera.global_transform.basis.y
	var right := camera.global_transform.basis.x
	_held_basis = (Basis(up, -rel.x * ROTATE_SENSITIVITY)
		* Basis(right, -rel.y * ROTATE_SENSITIVITY)
		* _held_basis).orthonormalized()

# Clear grab state and restore normal physics. Used by both drop() and when a
# slot takes ownership of the part for installation.
func end_grab() -> void:
	is_held = false
	_hold_point = null
	if _ignore_body != null and is_instance_valid(_ignore_body):
		remove_collision_exception_with(_ignore_body)
	_ignore_body = null
	gravity_scale = 1.0
	linear_damp = 0.0
	angular_damp = 0.0
	can_sleep = true
	collision_layer = _original_collision_layer
	collision_mask = _original_collision_mask

func drop() -> void:
	end_grab()
	dropped.emit(part_id)
