extends BaseEnemy
## 远程型敌人: 保持距离, 向玩家射击

var shoot_timer: float = 0.0
var shoot_interval: float = 2.0
var preferred_distance: float = 250.0
var enemy_bullet_scene: PackedScene = preload("res://scenes/enemy_bullet.tscn")


func _ready():
	max_health = 25.0
	move_speed = 80.0
	contact_damage = 5.0
	score_value = 15
	xp_value = 8
	super._ready()


func ai_process(delta: float):
	if player == null or not is_instance_valid(player):
		return

	var to_player := player.global_position - global_position
	var dist := to_player.length()
	var dir := to_player.normalized()

	# 维持理想距离
	if dist > preferred_distance + 50:
		velocity = dir * move_speed
	elif dist < preferred_distance - 50:
		velocity = -dir * move_speed
	else:
		velocity = dir.rotated(PI / 2) * move_speed * 0.5

	# 射击
	shoot_timer -= delta
	if shoot_timer <= 0 and dist < 500:
		_shoot_at_player()
		shoot_timer = shoot_interval


func _shoot_at_player():
	if player == null or not is_instance_valid(player):
		return
	var bullet = enemy_bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.direction = (player.global_position - global_position).normalized()
	bullet.rotation = bullet.direction.angle()
	var bullets_node = get_tree().current_scene.get_node_or_null("Bullets")
	if bullets_node:
		bullets_node.add_child(bullet)


func _draw():
	# 橙色六边形
	var pts := PackedVector2Array()
	for i in range(6):
		var angle := i * TAU / 6.0 - PI / 6.0
		pts.append(Vector2(cos(angle), sin(angle)) * 14)
	draw_colored_polygon(pts, Color.ORANGE)
	draw_circle(Vector2.ZERO, 5, Color(0.5, 0.3, 0.0))
	# 生命条
	var hp_ratio := health / max_health
	draw_rect(Rect2(-14, -22, 28, 4), Color(0.2, 0.0, 0.0))
	draw_rect(Rect2(-14, -22, 28 * hp_ratio, 4), Color.GREEN_YELLOW)
