extends CharacterBody2D
## 玩家角色: WASD 移动 + 鼠标瞄准 + 左键射击

var shoot_timer: float = 0.0
var invincible: bool = false
var invincible_timer: float = 0.0
const INVINCIBLE_DURATION: float = 0.3

var bullet_scene: PackedScene = preload("res://scenes/bullet.tscn")


func _ready():
	add_to_group("player")
	GameManager.health_changed.emit(GameManager.player_health, GameManager.player_max_health)


func _physics_process(delta: float):
	if GameManager.state != GameManager.State.PLAYING:
		return

	# ---- 移动 ----
	var input_dir := Vector2.ZERO
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.y = Input.get_axis("move_up", "move_down")
	velocity = input_dir.normalized() * GameManager.player_speed
	move_and_slide()

	# 限制在竞技场内
	var r := GameManager.arena_rect
	position.x = clamp(position.x, r.position.x + 20, r.end.x - 20)
	position.y = clamp(position.y, r.position.y + 20, r.end.y - 20)

	# ---- 朝向鼠标 ----
	look_at(get_global_mouse_position())

	# ---- 射击 ----
	shoot_timer -= delta
	if Input.is_action_pressed("shoot") and shoot_timer <= 0:
		_shoot()
		shoot_timer = GameManager.player_fire_rate

	# ---- 无敌闪烁 ----
	if invincible:
		invincible_timer -= delta
		if invincible_timer <= 0:
			invincible = false
	queue_redraw()


func _shoot():
	var bullet = bullet_scene.instantiate()
	var gun_pos = $GunPoint.global_position
	bullet.global_position = gun_pos
	bullet.rotation = rotation
	bullet.damage = GameManager.player_damage
	bullet.speed = GameManager.player_bullet_speed
	bullet.set_scale(Vector2.ONE * GameManager.player_bullet_size)
	get_tree().current_scene.get_node("Bullets").add_child(bullet)


func take_damage(amount: float):
	if invincible:
		return
	GameManager.take_damage(amount)
	invincible = true
	invincible_timer = INVINCIBLE_DURATION


func _draw():
	# 身体 (圆形)
	var body_color := Color.CYAN
	if invincible and fmod(invincible_timer * 10.0, 1.0) > 0.5:
		body_color = Color(0.3, 0.8, 1.0, 0.4)
	draw_circle(Vector2.ZERO, 16, body_color)
	# 内核
	draw_circle(Vector2.ZERO, 7, Color(0.1, 0.3, 0.5))
	# 枪管
	draw_line(Vector2(10, -3), Vector2(28, -3), Color.LIGHT_GRAY, 2.5)
	draw_line(Vector2(10, 3), Vector2(28, 3), Color.LIGHT_GRAY, 2.5)
	draw_line(Vector2(28, -3), Vector2(28, 3), Color.WHITE, 2.0)
