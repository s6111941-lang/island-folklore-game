extends Node2D

@onready var essence_label: Label = $Interface/Essence


func _ready() -> void:
	queue_redraw()
	_update_essence_label()


func _process(delta: float) -> void:
	GameState.add_essence(delta)
	_update_essence_label()


func _update_essence_label() -> void:
	essence_label.text = "靈息：%d" % floori(GameState.spirit_essence)


func _draw() -> void:
	# A code-drawn prototype keeps the first playable build asset-free.
	draw_rect(Rect2(0, 0, 960, 540), Color("15251f"))
	draw_circle(Vector2(760, 115), 150.0, Color("203b31"))
	draw_circle(Vector2(170, 455), 230.0, Color("1d342a"))
	draw_circle(Vector2(480, 300), 105.0, Color("294b3b"))
	draw_arc(Vector2(480, 300), 112.0, 0.0, TAU, 64, Color("70a77d"), 3.0)
	for stone in [Vector2(180, 170), Vector2(780, 380), Vector2(660, 205), Vector2(300, 400)]:
		draw_circle(stone, 26.0, Color("43564d"))
		draw_circle(stone - Vector2(5, 6), 17.0, Color("536b5f"))
