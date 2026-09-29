class_name DamageData
extends RefCounted
## Данные одного попадания. Health проверяет урон, персонажи реагируют на принятые попадания.

var amount: int
var impulse: Vector2

func _init(hit_points: int = 1, knockback: Vector2 = Vector2.ZERO) -> void:
	amount = hit_points
	impulse = knockback
