extends Node2D
## 主场景: 竞技场、摄像机跟随、波次管理、敌人生成

var wave_timer: float = 3.0
var spawn_timer: float = 0.0
var enemies_to_spawn: int = 0
var wave_active: bool = false
var between_waves: bool = true

var melee_scene: PackedScene = preload("res://scenes/melee_enemy.tscn")
var ranged_scene: PackedScene = preload("res://scenes/ranged_enemy.tscn")
var dash_scene: PackedScene = preload("res://scenes/dash_enemy.tscn")

@onready var player_node = $Player
@onready var camera = $Camera2D
@onready var enemy_container = $Enemies


func _ready():
	GameManager.start_game()
	queue_redraw()


func _physics_process(delta: float):
	if GameManager.state != GameManager.State.PLAYING:
		return

	# 摄像机跟随玩家
	if player_node and is_instance_valid(player_node):
		camera.global_position = player_node.global_position

	# ---- 波次管理 ----
	if between_waves:
		wave_timer -= delta
		if wave_timer <= 0:
			_start_next_wave()
	elif wave_active:
		if enemies_to_spawn > 0:
			spawn_timer -= delta
			if spawn_timer <= 0:
				_spawn_enemy()
				enemies_to_spawn -= 1
				spawn_timer = max(0.3, 0.8 - GameManager.current_wave * 0.03)
		# 本波全部死亡
		if enemies_to_spawn <= 0 and enemy_container.get_child_count() == 0:
			_wave_complete()


func _start_next_wave():
	GameManager.next_wave()
	var wave := GameManager.current_wave
	enemies_to_spawn = 3 + wave * 2
	wave_active = true
	between_waves = false
	spawn_timer = 0.5


func _wave_complete():
	wave_active = false
	between_waves = true
	wave_timer = 2.0


func _spawn_enemy():
	var enemy_scene: PackedScene
	var wave := GameManager.current_wave

	var roll := randf()
	if wave < 3:
		enemy_scene = melee_scene
	elif wave < 5:
		if roll < 0.6:
			enemy_scene = melee_scene
		else:
			enemy_scene = ranged_scene
	else:
		if roll < 0.35:
			enemy_scene = melee_scene
		elif roll < 0.65:
			enemy_scene = ranged_scene
		else:
			enemy_scene = dash_scene

	var enemy = enemy_scene.instantiate()
	enemy.global_position = _get_spawn_position()

	# 难度递增
	if wave > 3:
		var hp_scale := 1.0 + (wave - 3) * 0.12
		var spd_scale := 1.0 + (wave - 3) * 0.05
		enemy.max_health *= hp_scale
		enemy.health = enemy.max_health
		enemy.move_speed *= spd_scale

	enemy_container.add_child(enemy)


func _get_spawn_position() -> Vector2:
	var r := GameManager.arena_rect
	var side := randi() % 4
	match side:
		0:  return Vector2(randf_range(r.position.x, r.end.x), r.position.y + 20)
		1:  return Vector2(randf_range(r.position.x, r.end.x), r.end.y - 20)
		2:  return Vector2(r.position.x + 20, randf_range(r.position.y, r.end.y))
		_:  return Vector2(r.end.x - 20, randf_range(r.position.y, r.end.y))


func _draw():
	var r := GameManager.arena_rect
	# 竞技场底色
	draw_rect(r, Color(0.10, 0.10, 0.14))
	# 网格线
	var grid_col := Color(0.13, 0.13, 0.18)
	var step := 100
	var x := int(r.position.x)
	while x <= int(r.end.x):
		draw_line(Vector2(x, r.position.y), Vector2(x, r.end.y), grid_col, 1.0)
		x += step
	var y := int(r.position.y)
	while y <= int(r.end.y):
		draw_line(Vector2(r.position.x, y), Vector2(r.end.x, y), grid_col, 1.0)
		y += step
	# 边框
	draw_rect(r, Color(0.3, 0.3, 0.45), false, 3.0)
