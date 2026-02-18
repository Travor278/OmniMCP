extends Node
## 全局游戏管理器 (Autoload Singleton)
## 管理游戏状态、玩家属性、分数、存档

# ---- 信号 ----
signal score_changed(new_score: int)
signal health_changed(new_health: float, max_health: float)
signal wave_changed(new_wave: int)
signal xp_changed(xp: int, xp_to_next: int)
signal game_over_triggered
signal show_upgrade_menu

# ---- 游戏状态 ----
enum State { MENU, PLAYING, PAUSED, UPGRADING, GAME_OVER }
var state: State = State.MENU

# ---- 分数 ----
var score: int = 0
var high_score: int = 0

# ---- 波次 ----
var current_wave: int = 0

# ---- 玩家属性 (可通过升级系统修改) ----
var player_damage: float = 10.0
var player_fire_rate: float = 0.25   # 射击间隔(秒), 越低越快
var player_max_health: float = 100.0
var player_speed: float = 250.0
var player_bullet_speed: float = 600.0
var player_bullet_size: float = 1.0
var player_health: float = 100.0
var player_xp: int = 0
var player_level: int = 1
var player_xp_to_next: int = 30

# ---- 竞技场边界 ----
var arena_rect: Rect2 = Rect2(-960, -720, 1920, 1440)


func _ready():
	_setup_input_map()
	load_high_score()


# ========== 输入映射 ==========
func _setup_input_map():
	_replace_action("move_up", [KEY_W, KEY_UP])
	_replace_action("move_down", [KEY_S, KEY_DOWN])
	_replace_action("move_left", [KEY_A, KEY_LEFT])
	_replace_action("move_right", [KEY_D, KEY_RIGHT])
	_replace_action("pause", [KEY_ESCAPE])
	_replace_mouse_action("shoot", MOUSE_BUTTON_LEFT)


func _replace_action(action_name: String, keycodes: Array):
	if InputMap.has_action(action_name):
		InputMap.erase_action(action_name)
	InputMap.add_action(action_name)
	for k in keycodes:
		var ev = InputEventKey.new()
		ev.physical_keycode = k
		InputMap.action_add_event(action_name, ev)


func _replace_mouse_action(action_name: String, button: MouseButton):
	if InputMap.has_action(action_name):
		InputMap.erase_action(action_name)
	InputMap.add_action(action_name)
	var ev = InputEventMouseButton.new()
	ev.button_index = button
	InputMap.action_add_event(action_name, ev)


# ========== 游戏流程 ==========
func start_game():
	score = 0
	current_wave = 0
	player_damage = 10.0
	player_fire_rate = 0.25
	player_max_health = 100.0
	player_speed = 250.0
	player_bullet_speed = 600.0
	player_bullet_size = 1.0
	player_health = player_max_health
	player_xp = 0
	player_level = 1
	player_xp_to_next = 30
	state = State.PLAYING
	get_tree().paused = false


func add_score(amount: int):
	score += amount
	score_changed.emit(score)


func add_xp(amount: int):
	player_xp += amount
	xp_changed.emit(player_xp, player_xp_to_next)
	if player_xp >= player_xp_to_next:
		level_up()


func level_up():
	player_level += 1
	player_xp -= player_xp_to_next
	player_xp_to_next = int(player_xp_to_next * 1.4)
	state = State.UPGRADING
	get_tree().paused = true
	show_upgrade_menu.emit()


func take_damage(amount: float):
	player_health -= amount
	player_health = max(player_health, 0.0)
	health_changed.emit(player_health, player_max_health)
	if player_health <= 0:
		end_game()


func heal(amount: float):
	player_health = min(player_health + amount, player_max_health)
	health_changed.emit(player_health, player_max_health)


func end_game():
	state = State.GAME_OVER
	get_tree().paused = true
	if score > high_score:
		high_score = score
		save_high_score()
	game_over_triggered.emit()


func next_wave():
	current_wave += 1
	wave_changed.emit(current_wave)


# ========== 升级系统 ==========
func apply_upgrade(upgrade_type: String):
	match upgrade_type:
		"damage":
			player_damage *= 1.3
		"fire_rate":
			player_fire_rate *= 0.8
		"max_health":
			player_max_health += 25
			player_health += 25
			health_changed.emit(player_health, player_max_health)
		"speed":
			player_speed += 30
		"bullet_speed":
			player_bullet_speed += 100
		"bullet_size":
			player_bullet_size += 0.3
	state = State.PLAYING
	get_tree().paused = false


# ========== 存档 ==========
func save_high_score():
	var config = ConfigFile.new()
	config.set_value("game", "high_score", high_score)
	config.save("user://highscore.cfg")


func load_high_score():
	var config = ConfigFile.new()
	if config.load("user://highscore.cfg") == OK:
		high_score = config.get_value("game", "high_score", 0)
