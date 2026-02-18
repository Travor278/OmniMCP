extends BaseEnemy
## 冲锋型敌人: 蓄力后向玩家冲刺

enum DashState { IDLE, CHARGING, DASHING, COOLDOWN }
var dash_state: DashState = DashState.IDLE
var dash_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO

const CHARGE_TIME: float = 0.8
const DASH_SPEED: float = 500.0
const DASH_DURATION: float = 0.3
const COOLDOWN_TIME: float = 1.5


func _ready():
	max_health = 40.0
	move_speed = 90.0
	contact_damage = 20.0
	score_value = 20
	xp_value = 10
	super._ready()


func ai_process(delta: float):
	if player == null or not is_instance_valid(player):
		return

	match dash_state:
		DashState.IDLE:
			var dir := (player.global_position - global_position).normalized()
			velocity = dir * move_speed
			var dist := global_position.distance_to(player.global_position)
			if dist < 350:
				dash_state = DashState.CHARGING
				dash_timer = CHARGE_TIME
				velocity = Vector2.ZERO

		DashState.CHARGING:
			velocity = Vector2.ZERO
			dash_timer -= delta
			dash_direction = (player.global_position - global_position).normalized()
			if dash_timer <= 0:
				dash_state = DashState.DASHING
				dash_timer = DASH_DURATION

		DashState.DASHING:
			velocity = dash_direction * DASH_SPEED
			dash_timer -= delta
			if dash_timer <= 0:
				dash_state = DashState.COOLDOWN
				dash_timer = COOLDOWN_TIME
				velocity = Vector2.ZERO

		DashState.COOLDOWN:
			velocity = Vector2.ZERO
			dash_timer -= delta
			if dash_timer <= 0:
				dash_state = DashState.IDLE


func _draw():
	# 紫色菱形
	var color := Color.PURPLE
	if dash_state == DashState.CHARGING:
		color = Color.WHITE if fmod(dash_timer * 8.0, 1.0) > 0.5 else Color.PURPLE
	elif dash_state == DashState.DASHING:
		color = Color.MAGENTA

	var pts := PackedVector2Array([
		Vector2(0, -18), Vector2(14, 0), Vector2(0, 18), Vector2(-14, 0)
	])
	draw_colored_polygon(pts, color)
	draw_circle(Vector2.ZERO, 5, Color(0.3, 0.0, 0.3))

	# 生命条
	var hp_ratio := health / max_health
	draw_rect(Rect2(-14, -26, 28, 4), Color(0.2, 0.0, 0.0))
	draw_rect(Rect2(-14, -26, 28 * hp_ratio, 4), Color.GREEN_YELLOW)
