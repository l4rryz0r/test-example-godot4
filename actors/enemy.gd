class_name Sentinel
extends CharacterBody2D

signal defeated
signal effect_requested(at: Vector2, color: Color, count: int)
signal sound_requested(cue: StringName)

enum State { PATROL, CHASE, WINDUP, RECOVER, HURT, DEAD }
@export var patrol_speed: float = 62.0
@export var chase_speed: float = 135.0
@export var initial_direction: float = -1.0
@onready var health: Health = $Health
@onready var visual: ActorVisual = $Visual
@onready var edge: RayCast2D = $EdgeProbe
@onready var hitbox: Hitbox = $Attack
@onready var detection: Area2D = $Detection
@onready var contact: Area2D = $Contact

var state: State = State.PATROL
var facing: float = -1.0
var target: Player
var _state_left: float = 0.0
var _attack_left: float = 0.0
var _turn_lock: float = 0.0

func _ready() -> void:
	facing = initial_direction
	health.damaged.connect(_on_damaged)
	health.died.connect(_on_died)
	detection.body_entered.connect(_on_detected)
	detection.body_exited.connect(_on_lost)

func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return
	_state_left -= delta
	_turn_lock = maxf(0.0, _turn_lock - delta)
	_attack_left = maxf(0.0, _attack_left - delta)
	if _attack_left <= 0.0:
		hitbox.end()
	if not is_on_floor():
		velocity.y = minf(velocity.y + 1400.0 * delta, 900.0)
	var sees_player := _can_see_target()
	match state:
		State.PATROL, State.CHASE:
			state = State.CHASE if sees_player else State.PATROL
			if sees_player:
				facing = 1.0 if target.global_position.x > global_position.x else -1.0
				if absf(target.global_position.x - global_position.x) < 68.0 and absf(target.global_position.y - global_position.y) < 42.0:
					state = State.WINDUP
					_state_left = 0.48
			velocity.x = facing * (chase_speed if state == State.CHASE else patrol_speed)
			edge.position.x = facing * 24.0
			edge.force_raycast_update()
			if is_on_floor() and (not edge.is_colliding() or is_on_wall()):
				velocity.x = 0.0
				if state == State.PATROL and _turn_lock <= 0.0:
					facing *= -1.0
					_turn_lock = 0.2
			if state == State.WINDUP:
				velocity.x = 0.0
		State.WINDUP:
			velocity.x = 0.0
			if _state_left <= 0.0:
				state = State.RECOVER
				_state_left = 0.7
				_attack_left = 0.16
				hitbox.position.x = facing * 35.0
				hitbox.begin(facing)
				sound_requested.emit(&"enemy_swing")
		State.RECOVER:
			velocity.x = 0.0
			if _state_left <= 0.0:
				state = State.PATROL
		State.HURT:
			velocity.x = move_toward(velocity.x, 0.0, 700.0 * delta)
			if _state_left <= 0.0:
				state = State.PATROL
	move_and_slide()
	# Контакт наносит урон; временная неуязвимость в Health защищает от урона каждый кадр.
	if state != State.HURT:
		for body in contact.get_overlapping_bodies():
			if body is Player:
				var away := 1.0 if body.global_position.x >= global_position.x else -1.0
				(body as Player).health.take_damage(DamageData.new(1, Vector2(away * 260.0, -140.0)))
	visual.facing = facing
	visual.speed = velocity.x
	visual.grounded = is_on_floor()
	visual.warning = 1.0 if state == State.WINDUP else 0.0
	visual.swing = _attack_left
	visual.health_ratio = float(health.current) / health.maximum
	if global_position.y > 850:
		health.eliminate()

func _can_see_target() -> bool:
	if not is_instance_valid(target) or target.health.current <= 0:
		return false
	if absf(target.global_position.y - global_position.y) > 90.0:
		return false
	var ray := PhysicsRayQueryParameters2D.create(global_position + Vector2(0, -25), target.global_position + Vector2(0, -25), 1)
	return get_world_2d().direct_space_state.intersect_ray(ray).is_empty()

func _on_detected(body: Node2D) -> void:
	if body is Player:
		target = body as Player

func _on_lost(body: Node2D) -> void:
	if body == target:
		target = null

func _on_damaged(hit: DamageData) -> void:
	state = State.HURT
	_state_left = 0.22
	velocity = hit.impulse
	_attack_left = 0.0
	hitbox.end()
	$AnimationPlayer.stop()
	$AnimationPlayer.play(&"hurt")
	effect_requested.emit(global_position + Vector2(0, -25), Color("ff637d"), 12)

func _on_died() -> void:
	state = State.DEAD
	hitbox.end()
	$CollisionShape2D.set_deferred(&"disabled", true)
	$Hurtbox/CollisionShape2D.set_deferred(&"disabled", true)
	$Contact/CollisionShape2D.set_deferred(&"disabled", true)
	$Detection/CollisionShape2D.set_deferred(&"disabled", true)
	effect_requested.emit(global_position + Vector2(0, -25), Color("ff637d"), 25)
	sound_requested.emit(&"destroy")
	defeated.emit()
	queue_free()
