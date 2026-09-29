class_name Player
extends CharacterBody2D

signal died
signal effect_requested(at: Vector2, color: Color, count: int)
signal sound_requested(cue: StringName)

@export var run_speed: float = 310.0
@export var jump_speed: float = 570.0
@export var gravity: float = 1400.0
@onready var health: Health = $Health
@onready var visual: ActorVisual = $Visual
@onready var hitbox: Hitbox = $Attack
@onready var animator: AnimationPlayer = $AnimationPlayer

var facing: float = 1.0
var controls_enabled: bool = true
var _coyote: float = 0.0
var _jump_buffer: float = 0.0
var _attack_left: float = 0.0
var _stun_left: float = 0.0

func _ready() -> void:
	health.damaged.connect(_on_damaged)
	health.died.connect(_on_died)
	hitbox.landed.connect(func() -> void: sound_requested.emit(&"hit"))

func _physics_process(delta: float) -> void:
	if health.current <= 0:
		return
	_coyote = maxf(0.0, _coyote - delta)
	_jump_buffer = maxf(0.0, _jump_buffer - delta)
	_stun_left = maxf(0.0, _stun_left - delta)
	if is_on_floor():
		_coyote = 0.12
	else:
		velocity.y = minf(velocity.y + gravity * delta, 900.0)
	var axis := Input.get_axis(&"move_left", &"move_right") if controls_enabled else 0.0
	if _stun_left <= 0.0:
		velocity.x = move_toward(velocity.x, axis * run_speed, 2300.0 * delta)
		if axis != 0.0 and _attack_left <= 0.0:
			facing = signf(axis)
	if controls_enabled:
		if Input.is_action_just_pressed(&"jump"):
			_jump_buffer = 0.12
		if _jump_buffer > 0.0 and _coyote > 0.0 and _stun_left <= 0.0:
			velocity.y = -jump_speed
			_coyote = 0.0
			_jump_buffer = 0.0
			sound_requested.emit(&"jump")
			effect_requested.emit(global_position, Color("6affdd"), 7)
		if Input.is_action_just_released(&"jump") and velocity.y < -220.0:
			velocity.y = -220.0
		if Input.is_action_just_pressed(&"attack") and _attack_left <= 0.0 and _stun_left <= 0.0:
			_attack_left = 0.38
			hitbox.position.x = facing * 39.0
			hitbox.begin(facing)
			sound_requested.emit(&"swing")
	_attack_left = maxf(0.0, _attack_left - delta)
	if _attack_left < 0.22:
		hitbox.end()
	var was_grounded := is_on_floor()
	move_and_slide()
	if is_on_ceiling():
		velocity.y = maxf(velocity.y, 0.0)
	if not was_grounded and is_on_floor():
		effect_requested.emit(global_position, Color("6affdd"), 5)
	visual.facing = facing
	visual.speed = velocity.x
	visual.grounded = is_on_floor()
	visual.swing = maxf(0.0, _attack_left - 0.13)
	visual.modulate.a = 0.5 if health.invulnerability_left > 0.0 and sin(health.invulnerability_left * 40.0) > 0.0 else 1.0
	if global_position.y > 850:
		health.eliminate()

func _on_damaged(hit: DamageData) -> void:
	velocity = hit.impulse
	_stun_left = 0.16
	_attack_left = 0.0
	hitbox.end()
	animator.stop()
	animator.play(&"hurt")
	effect_requested.emit(global_position + Vector2(0, -24), Color("6affdd"), 12)
	sound_requested.emit(&"hurt")

func _on_died() -> void:
	controls_enabled = false
	hitbox.end()
	$CollisionShape2D.set_deferred(&"disabled", true)
	$Hurtbox/CollisionShape2D.set_deferred(&"disabled", true)
	effect_requested.emit(global_position + Vector2(0, -24), Color("6affdd"), 28)
	visual.hide()
	died.emit()
