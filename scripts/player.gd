extends CharacterBody2D

@export var move_speed: float = 230.0


func _ready() -> void:
	# Multiplayer-ready seam: only the authority should drive this body later.
	queue_redraw()


func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * move_speed
	move_and_slide()
	global_position.x = clampf(global_position.x, 24.0, 936.0)
	global_position.y = clampf(global_position.y, 100.0, 516.0)


func _draw() -> void:
	draw_circle(Vector2.ZERO, 18.0, Color("e9d38b"))
	draw_circle(Vector2.ZERO, 12.0, Color("365a4a"))
	draw_circle(Vector2(4, -4), 3.0, Color("f5efcf"))
	draw_arc(Vector2.ZERO, 22.0, 0.0, TAU, 32, Color("a5d3a4"), 2.0)
