extends BaseEnemy
## 近战型敌人: 直线追逐玩家


func _ready():
	max_health = 30.0
	move_speed = 120.0
	contact_damage = 10.0
	score_value = 10
	xp_value = 5
	super._ready()


func ai_process(_delta: float):
	if player and is_instance_valid(player):
		var dir := (player.global_position - global_position).normalized()
		velocity = dir * move_speed


func _draw():
	# 红色圆形怪物
	draw_circle(Vector2.ZERO, 14, Color.RED)
	draw_circle(Vector2.ZERO, 6, Color(0.6, 0.1, 0.1))
	# 生命条
	var hp_ratio := health / max_health
	draw_rect(Rect2(-14, -22, 28, 4), Color(0.2, 0.0, 0.0))
	draw_rect(Rect2(-14, -22, 28 * hp_ratio, 4), Color.GREEN_YELLOW)
