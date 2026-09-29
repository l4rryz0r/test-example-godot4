extends Node2D
## Управление сценой: персонажи отправляют сигналы, а сцена связывает их с интерфейсом и эффектами.

const BURST := preload("res://effects/burst.gd")
@onready var player: Player = $Player
@onready var hud: CanvasLayer = $HUD
@onready var sounds: Node = $SoundBank
var elapsed: float = 0.0
var kills: int = 0
var total_enemies: int = 0
var finished: bool = false
var _restarting: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	player.health.changed.connect(hud.set_health)
	player.died.connect(_on_player_died)
	_wire_actor(player)
	for enemy: Sentinel in $Enemies.get_children():
		total_enemies += 1
		enemy.defeated.connect(func() -> void: kills += 1)
		_wire_actor(enemy)
	$Exit.reached.connect(_on_exit_reached)
	hud.restart_requested.connect(restart)
	hud.resume_requested.connect(_resume)
	hud.set_health(player.health.current, player.health.maximum)
	# Отдельный узел обрабатывает ввод даже на паузе, чтобы Esc мог возобновить игру.
	$SessionInput.pause_requested.connect(_toggle_pause)
	$SessionInput.restart_requested.connect(restart)
	$SessionInput.mute_requested.connect(_toggle_mute)

func _process(delta: float) -> void:
	if not finished:
		elapsed += delta
	hud.update_run(elapsed, (player.position.x - 112.0) / 2848.0, kills, total_enemies)

func _wire_actor(actor: Node) -> void:
	actor.effect_requested.connect(_spawn_effect)
	actor.sound_requested.connect(sounds.play)

func _spawn_effect(at: Vector2, color: Color, count: int) -> void:
	var burst := BURST.new()
	burst.position = at
	burst.color = color
	burst.count = count
	add_child(burst)

func _on_player_died() -> void:
	if finished:
		return
	finished = true
	_disable_actors()
	hud.show_result(false, elapsed, kills, total_enemies)
	await get_tree().create_timer(3.0).timeout
	restart()

func _on_exit_reached() -> void:
	if finished:
		return
	finished = true
	_disable_actors()
	sounds.play(&"win")
	hud.show_result(true, elapsed, kills, total_enemies)

func _disable_actors() -> void:
	player.controls_enabled = false
	player.set_physics_process(false)
	player.hitbox.end()
	for enemy: Sentinel in $Enemies.get_children():
		enemy.set_physics_process(false)
		enemy.hitbox.end()

func restart() -> void:
	if _restarting:
		return
	_restarting = true
	get_tree().paused = false
	get_tree().reload_current_scene.call_deferred()

func _toggle_pause() -> void:
	if finished:
		return
	get_tree().paused = not get_tree().paused
	hud.show_pause(get_tree().paused)

func _resume() -> void:
	get_tree().paused = false
	hud.show_pause(false)

func _toggle_mute() -> void:
	sounds.muted = not sounds.muted
	hud.set_muted(sounds.muted)
