extends Node2D

const CELL := 20
const COLS := 32
const ROWS := 32

const C_BG   := Color(0.08, 0.08, 0.10)
const C_GRID := Color(0.13, 0.13, 0.15)
const C_FOOD := Color(1.00, 0.30, 0.18)
const C_HEAD := Color(0.45, 1.00, 0.45)
const C_BODY := Color(0.20, 0.72, 0.20)
const C_TAIL := Color(0.10, 0.42, 0.10)

# Score threshold and step interval (seconds) per level
const LEVELS := [
	{"score": 0,   "tick": 0.150},  # 1
	{"score": 3,   "tick": 0.120},  # 2
	{"score": 8,   "tick": 0.100},  # 3
	{"score": 15,  "tick": 0.083},  # 4
	{"score": 24,  "tick": 0.068},  # 5
	{"score": 35,  "tick": 0.055},  # 6
	{"score": 48,  "tick": 0.044},  # 7
	{"score": 63,  "tick": 0.035},  # 8
	{"score": 80,  "tick": 0.027},  # 9
	{"score": 100, "tick": 0.021},  # 10
]

var snake         : Array[Vector2i] = []
var dir           : Vector2i = Vector2i(1, 0)
var next_dir      : Vector2i = Vector2i(1, 0)
var food          : Vector2i
var score         : int   = 0
var current_level : int   = 1
var dead          : bool  = false
var tick_timer    : float = 0.0
var tick_rate     : float = 0.150

var flash_timer   : float = 0.0
var flash_color   := Color.TRANSPARENT
var game_time     : float = 0.0

var score_label : Label
var time_label  : Label
var level_label : Label
var over_label  : Label
var fps_label   : Label


func _ready() -> void:
	score_label = Label.new()
	score_label.position = Vector2(8, 8)
	score_label.add_theme_font_size_override("font_size", 22)
	score_label.modulate = Color(0.9, 0.9, 0.9)
	add_child(score_label)

	time_label = Label.new()
	time_label.position = Vector2(0, 8)
	time_label.size = Vector2(COLS * CELL, 28)
	time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	time_label.add_theme_font_size_override("font_size", 22)
	time_label.modulate = Color(0.65, 0.65, 0.65)
	add_child(time_label)

	level_label = Label.new()
	level_label.position = Vector2(COLS * CELL - 120, 8)
	level_label.add_theme_font_size_override("font_size", 22)
	level_label.modulate = Color(0.9, 0.9, 0.9)
	add_child(level_label)

	over_label = Label.new()
	over_label.position = Vector2(COLS * CELL / 2 - 160, ROWS * CELL / 2 - 56)
	over_label.add_theme_font_size_override("font_size", 26)
	over_label.modulate = Color(1.0, 0.35, 0.35)
	over_label.visible = false
	add_child(over_label)

	fps_label = Label.new()
	fps_label.position = Vector2(8, ROWS * CELL - 22)
	fps_label.add_theme_font_size_override("font_size", 14)
	fps_label.modulate = Color(0.40, 0.40, 0.40)
	add_child(fps_label)

	_new_game()


func _new_game() -> void:
	snake         = [Vector2i(16, 16), Vector2i(15, 16), Vector2i(14, 16)]
	dir           = Vector2i(1, 0)
	next_dir      = Vector2i(1, 0)
	score         = 0
	current_level = 1
	dead          = false
	game_time     = 0.0
	tick_rate     = LEVELS[0].tick
	tick_timer    = 0.0
	flash_timer   = 0.0
	flash_color   = Color.TRANSPARENT
	over_label.visible = false
	_spawn_food()
	_refresh_hud()
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


func _fmt_time(secs: float) -> String:
	var s := int(secs)
	return "%d:%02d" % [s / 60, s % 60]


func _refresh_hud() -> void:
	score_label.text = "Score: %d" % score
	level_label.text = "Level: %d" % current_level


func _check_level_up() -> void:
	var new_level := 1
	for i in LEVELS.size():
		if score >= LEVELS[i].score:
			new_level = i + 1
	if new_level > current_level:
		current_level = new_level
		tick_rate = LEVELS[current_level - 1].tick
		_refresh_hud()
		flash_timer = 0.45
		flash_color = Color(0.30, 0.55, 1.0, 0.22)


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
		get_tree().change_scene_to_file("res://scenes/Menu.tscn")


func _process(delta: float) -> void:
	if dead:
		return

	game_time += delta
	time_label.text = _fmt_time(game_time)
	fps_label.text = "FPS: %d" % Engine.get_frames_per_second()

	if flash_timer > 0.0:
		flash_timer -= delta
		if flash_timer <= 0.0:
			flash_color = Color.TRANSPARENT
		queue_redraw()

	tick_timer += delta
	if tick_timer >= tick_rate:
		tick_timer -= tick_rate
		_step()


func _step() -> void:
	dir = next_dir
	var head := snake[0] + dir

	if head.x < 0 or head.x >= COLS or head.y < 0 or head.y >= ROWS or head in snake:
		_on_death()
		return

	snake.push_front(head)

	if head == food:
		score += 1
		_check_level_up()
		_refresh_hud()
		_spawn_food()
	else:
		snake.pop_back()

	queue_redraw()


func _on_death() -> void:
	dead = true

	var in_top5 := SaveData.add_result(SaveData.player_name, score, current_level, game_time)
	var banner  := "  ★ TOP 5!" if in_top5 else ""
	over_label.text = "GAME OVER  —  Level %d%s\nScore: %d   %s\n\nEnter = back to menu" % [
		current_level, banner, score, _fmt_time(game_time)
	]
	over_label.visible = true
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(0, 0, COLS * CELL, ROWS * CELL), C_BG)

	for x in range(COLS + 1):
		draw_line(Vector2(x * CELL, 0), Vector2(x * CELL, ROWS * CELL), C_GRID)
	for y in range(ROWS + 1):
		draw_line(Vector2(0, y * CELL), Vector2(COLS * CELL, y * CELL), C_GRID)

	# Level-up flash overlay
	if flash_timer > 0.0:
		draw_rect(Rect2(0, 0, COLS * CELL, ROWS * CELL), flash_color)

	# Food
	var fc := Vector2(food.x * CELL + CELL * 0.5, food.y * CELL + CELL * 0.5)
	draw_circle(fc, CELL * 0.5 - 2.0, C_FOOD)

	# Snake
	var n := snake.size()
	for i in n:
		var cell := snake[i]
		var color: Color = C_HEAD if i == 0 else C_BODY.lerp(C_TAIL, float(i) / float(n))
		var pad := 1 if i == 0 else 2
		draw_rect(
			Rect2(cell.x * CELL + pad, cell.y * CELL + pad, CELL - pad * 2, CELL - pad * 2),
			color
		)

	# Eyes
	if not dead and n > 0:
		var h    := snake[0]
		var cx   := h.x * CELL + CELL * 0.5
		var cy   := h.y * CELL + CELL * 0.5
		var perp := Vector2(float(dir.y), float(dir.x))
		var fwd  := Vector2(float(dir.x), float(dir.y)) * 4.0
		draw_circle(Vector2(cx, cy) + fwd + perp * 3.0, 2.0, Color.BLACK)
		draw_circle(Vector2(cx, cy) + fwd - perp * 3.0, 2.0, Color.BLACK)
