extends CharacterBody2D
class_name BaseEnemy
## 敌人基类: 生命值、移动、接触伤害、掉落物

@export var max_health: float = 30.0
@export var move_speed: float = 100.0
@export var contact_damage: float = 10.0
@export var score_value: int = 10
@export var xp_value: int = 5

var health: float
var player: CharacterBody2D = null
var _contact_cd: float = 0.0

var health_pickup_scene: PackedScene = preload("res://scenes/health_pickup.tscn")
var xp_pickup_scene: PackedScene = preload("res://scenes/xp_pickup.tscn")


func _ready():
	health = max_health
	_find_player()


func _find_player():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]


func _physics_process(delta: float):
	if GameManager.state != GameManager.State.PLAYING:
		return
	if player == null or not is_instance_valid(player):
		_find_player()
		return

	ai_process(delta)
	move_and_slide()

	# 限制在竞技场内
	var r := GameManager.arena_rect
	position.x = clamp(position.x, r.position.x + 16, r.end.x - 16)
	position.y = clamp(position.y, r.position.y + 16, r.end.y - 16)

	# 接触伤害
	_contact_cd -= delta
	if _contact_cd <= 0 and player and is_instance_valid(player):
		if global_position.distance_to(player.global_position) < 30:
			if player.has_method("take_damage"):
				player.take_damage(contact_damage)
				_contact_cd = 0.8

	queue_redraw()


## 子类覆写此方法实现 AI 行为
func ai_process(_delta: float):
	pass


func take_damage(amount: float):
	health -= amount
	if health <= 0:
		_die()


func _die():
	GameManager.add_score(score_value)
	_spawn_drops()
	queue_free()


func _spawn_drops():
	var pickups_node = get_tree().current_scene.get_node_or_null("Pickups")
	if pickups_node == null:
		return

	# 30% 概率掉生命恢复
	if randf() < 0.3:
		var hp = health_pickup_scene.instantiate()
		hp.global_position = global_position
		pickups_node.add_child(hp)

	# 必掉 XP
	var xp = xp_pickup_scene.instantiate()
	xp.global_position = global_position + Vector2(randf_range(-10, 10), randf_range(-10, 10))
	xp.xp_amount = xp_value
	pickups_node.add_child(xp)
