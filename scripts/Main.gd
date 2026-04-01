extends Node2D

# Grid dimensions
const CELL   := 20
const COLS   := 32
const ROWS   := 32

# Colours
const C_BG   := Color(0.08, 0.08, 0.10)
const C_GRID := Color(0.13, 0.13, 0.15)
const C_FOOD := Color(1.00, 0.30, 0.18)
const C_HEAD := Color(0.45, 1.00, 0.45)
const C_BODY := Color(0.20, 0.72, 0.20)
const C_TAIL := Color(0.10, 0.42, 0.10)

var snake      : Array[Vector2i] = []
var dir        : Vector2i = Vector2i(1, 0)
var next_dir   : Vector2i = Vector2i(1, 0)
var food       : Vector2i
var score      : int   = 0
var dead       : bool  = false
var tick_timer : float = 0.0
var tick_rate  : float = 0.15

var score_label    : Label
var over_label     : Label


func _ready() -> void:
	score_label = Label.new()
	score_label.position = Vector2(8, 8)
	score_label.add_theme_font_size_override("font_size", 22)
	score_label.modulate = Color(0.9, 0.9, 0.9)
	add_child(score_label)

	over_label = Label.new()
	over_label.position = Vector2(COLS * CELL / 2 - 140, ROWS * CELL / 2 - 36)
	over_label.text = "GAME OVER\nPress ENTER to restart"
	over_label.add_theme_font_size_override("font_size", 30)
	over_label.modulate = Color(1.0, 0.35, 0.35)
	over_label.visible = false
	add_child(over_label)

	_new_game()


func _new_game() -> void:
	snake     = [Vector2i(16, 16), Vector2i(15, 16), Vector2i(14, 16)]
	dir       = Vector2i(1, 0)
	next_dir  = Vector2i(1, 0)
	score     = 0
	dead      = false
	tick_rate = 0.15
	tick_timer = 0.0
	over_label.visible = false
	_spawn_food()
	_refresh_score()
	queue_redraw()


func _spawn_food() -> void:
	var free: Array[Vector2i] = []
	for x in COLS:
		for y in ROWS:
			var p := Vector2i(x, y)
			if p not in snake:
				free.append(p)
	free.shuffle()
	food = free[0]


func _refresh_score() -> void:
	score_label.text = "Score: %d" % score


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_right") and dir.x == 0:
		next_dir = Vector2i(1, 0)
	elif event.is_action_pressed("ui_left") and dir.x == 0:
		next_dir = Vector2i(-1, 0)
	elif event.is_action_pressed("ui_down") and dir.y == 0:
		next_dir = Vector2i(0, 1)
	elif event.is_action_pressed("ui_up") and dir.y == 0:
		next_dir = Vector2i(0, -1)
	elif event.is_action_pressed("ui_accept") and dead:
		_new_game()


func _process(delta: float) -> void:
	if dead:
		return
	tick_timer += delta
	if tick_timer >= tick_rate:
		tick_timer -= tick_rate
		_step()


func _step() -> void:
	dir = next_dir
	var head := snake[0] + dir

	# Wall or self collision
	if head.x < 0 or head.x >= COLS or head.y < 0 or head.y >= ROWS or head in snake:
		dead = true
		over_label.visible = true
		queue_redraw()
		return

	snake.push_front(head)

	if head == food:
		score     += 10
		tick_rate  = maxf(0.05, tick_rate - 0.002)
		_refresh_score()
		_spawn_food()
	else:
		snake.pop_back()

	queue_redraw()


func _draw() -> void:
	# Background
	draw_rect(Rect2(0, 0, COLS * CELL, ROWS * CELL), C_BG)

	# Grid lines
	for x in range(COLS + 1):
		draw_line(Vector2(x * CELL, 0), Vector2(x * CELL, ROWS * CELL), C_GRID)
	for y in range(ROWS + 1):
		draw_line(Vector2(0, y * CELL), Vector2(COLS * CELL, y * CELL), C_GRID)

	# Food (circle)
	var fc := Vector2(food.x * CELL + CELL * 0.5, food.y * CELL + CELL * 0.5)
	draw_circle(fc, CELL * 0.5 - 2.0, C_FOOD)

	# Snake segments
	var n := snake.size()
	for i in n:
		var cell := snake[i]
		var color: Color
		if i == 0:
			color = C_HEAD
		else:
			color = C_BODY.lerp(C_TAIL, float(i) / float(n))
		var pad := 1 if i == 0 else 2
		draw_rect(
			Rect2(cell.x * CELL + pad, cell.y * CELL + pad, CELL - pad * 2, CELL - pad * 2),
			color
		)

	# Eyes on head (two black dots, offset perpendicular to direction)
	if not dead and n > 0:
		var h    := snake[0]
		var cx   := h.x * CELL + CELL * 0.5
		var cy   := h.y * CELL + CELL * 0.5
		var perp := Vector2(float(dir.y), float(dir.x))
		var fwd  := Vector2(float(dir.x), float(dir.y)) * 4.0
		draw_circle(Vector2(cx, cy) + fwd + perp * 3.0, 2.0, Color.BLACK)
		draw_circle(Vector2(cx, cy) + fwd - perp * 3.0, 2.0, Color.BLACK)
