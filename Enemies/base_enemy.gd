extends CharacterBody2D

@export var acceleration: float = 300.0
@export var speed: float = 60.0
@export var friction: float = 200.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D 
@onready var stats: Node = $Stats 
@onready var HitEffect: PackedScene = preload("res://Effects/hit_effect.tscn")
@onready var DeathEffect: PackedScene = preload("res://Effects/enemy_death_effect.tscn")
@onready var soft_collision: Area2D = $SoftCollision

var player_direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	sprite.play("default")
	
func _physics_process(delta: float) -> void:
	if(Global.Player != null):
		player_direction = global_position.direction_to(Global.Player.global_position)
	else:
		player_direction = Vector2.ZERO

	if soft_collision.is_colliding():
		velocity += soft_collision.get_push_vector() * delta * 400

	velocity = velocity.move_toward(player_direction * speed, acceleration * delta)
	sprite.flip_h = velocity.x < 0
	move_and_slide()

func _on_hurtbox_area_entered(area: Area2D):
	if not area.is_in_group("safe"):
		var knockback_direction = -player_direction
		stats.health -= area.damage
		velocity = knockback_direction * 120
		var hitEffect = HitEffect.instantiate()
		get_tree().current_scene.add_child(hitEffect)
		hitEffect.global_position = global_position

func _on_stats_no_health():
	queue_free()
	var death_effect: AnimatedSprite2D = DeathEffect.instantiate()
	get_tree().current_scene.add_child(death_effect)
	death_effect.global_position = global_position
