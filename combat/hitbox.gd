class_name Hitbox
extends Area2D
## Маски коллизий выбирают зоны урона противника. Один взмах наносит одно попадание каждой цели.

signal landed
@export var knockback_force: float = 200.0
var active: bool = false
var direction: float = 1.0
var _hit_ids: Array[int] = []

func _ready() -> void:
	monitoring = false
	area_entered.connect(_on_area_entered)

func begin(facing: float) -> void:
	direction = facing
	_hit_ids.clear()
	active = true
	set_deferred(&"monitoring", true)

func end() -> void:
	if not active:
		return
	active = false
	set_deferred(&"monitoring", false)

func _on_area_entered(area: Area2D) -> void:
	if not active or not area is Hurtbox or _hit_ids.has(area.get_instance_id()):
		return
	_hit_ids.append(area.get_instance_id())
	var target := area as Hurtbox
	# Стена между персонажами должна блокировать удар ближнего боя.
	var ray := PhysicsRayQueryParameters2D.create(global_position, target.global_position, 1)
	if not get_world_2d().direct_space_state.intersect_ray(ray).is_empty():
		return
	if target.receive(DamageData.new(1, Vector2(direction * knockback_force, -100.0))):
		landed.emit()
