extends Control

const W := 640
const H := 640

# Table column layout: [x, width, alignment]
const COL_RANK  := [45,  50,  HORIZONTAL_ALIGNMENT_CENTER]
const COL_NAME  := [105, 225, HORIZONTAL_ALIGNMENT_LEFT]
const COL_SCORE := [340, 120, HORIZONTAL_ALIGNMENT_CENTER]
const COL_LEVEL := [470, 110, HORIZONTAL_ALIGNMENT_CENTER]


func _ready() -> void:
	SaveData.load_data()

	# Background
	var bg := ColorRect.new()
	bg.size = Vector2(W, H)
	bg.color = Color(0.08, 0.08, 0.10)
	add_child(bg)

	# Title
	var title := Label.new()
	title.text = "S N A K E"
	title.add_theme_font_size_override("font_size", 64)
	title.modulate = Color(0.45, 1.0, 0.45)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size = Vector2(W, 80)
	title.position = Vector2(0, 70)
	add_child(title)

	# Name label
	var name_lbl := Label.new()
	name_lbl.text = "Your name:"
	name_lbl.add_theme_font_size_override("font_size", 22)
	name_lbl.modulate = Color(0.80, 0.80, 0.80)
	name_lbl.position = Vector2(W / 2.0 - 160, 178)
	add_child(name_lbl)

	# Name input
	var name_input := LineEdit.new()
	name_input.position = Vector2(W / 2.0 - 160, 212)
	name_input.size = Vector2(320, 46)
	name_input.max_length = 20
	name_input.placeholder_text = "Enter your name..."
	name_input.text = SaveData.player_name
	name_input.add_theme_font_size_override("font_size", 21)
	add_child(name_input)

	# Start button
	var start_btn := Button.new()
	start_btn.text = "▶  START"
	start_btn.position = Vector2(W / 2.0 - 110, 298)
	start_btn.size = Vector2(220, 56)
	start_btn.add_theme_font_size_override("font_size", 28)
	add_child(start_btn)

	# Divider
	var div := ColorRect.new()
	div.position = Vector2(40, 378)
	div.size = Vector2(W - 80, 2)
	div.color = Color(0.22, 0.22, 0.22)
	add_child(div)

	# Top 5 section
	var ranking_lbl := Label.new()
	ranking_lbl.text = "TOP 5 RANKING"
	ranking_lbl.add_theme_font_size_override("font_size", 16)
	ranking_lbl.modulate = Color(0.65, 0.65, 0.30)
	ranking_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ranking_lbl.size = Vector2(W, 22)
	ranking_lbl.position = Vector2(0, 392)
	add_child(ranking_lbl)

	# Table header
	_add_row(418, "#", "Name", "Score", "Level", Color(0.60, 0.60, 0.65), 15)

	# Table rows
	if SaveData.top5.is_empty():
		var empty_lbl := Label.new()
		empty_lbl.text = "No records yet — be the first!"
		empty_lbl.add_theme_font_size_override("font_size", 16)
		empty_lbl.modulate = Color(0.45, 0.45, 0.45)
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_lbl.size = Vector2(W, 22)
		empty_lbl.position = Vector2(0, 444)
		add_child(empty_lbl)
	else:
		for i in SaveData.top5.size():
			var e: Dictionary = SaveData.top5[i]
			var gold := i == 0
			var color := Color(1.0, 0.85, 0.30) if gold else Color(0.80, 0.80, 0.80)
			_add_row(
				444 + i * 26,
				"#%d" % (i + 1),
				e.name,
				str(e.score),
				"Lv %d" % e.level,
				color,
				17
			)

	# Hint
	var hint := Label.new()
	hint.text = "Arrow keys to steer   •   Enter to return to menu"
	hint.add_theme_font_size_override("font_size", 15)
	hint.modulate = Color(0.38, 0.38, 0.38)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.size = Vector2(W, 22)
	hint.position = Vector2(0, 600)
	add_child(hint)

	# Connections
	var go := func() -> void:
		SaveData.player_name = name_input.text.strip_edges()
		if SaveData.player_name == "":
			SaveData.player_name = "Player"
		SaveData.save_data()
		get_tree().change_scene_to_file("res://scenes/Game.tscn")

	start_btn.pressed.connect(go)
	name_input.text_submitted.connect(func(_t: String) -> void: go.call())


func _add_row(y: float, rank: String, name: String, score: String, level: String,
		color: Color, font_size: int) -> void:
	var cols := [
		[rank,  COL_RANK[0],  COL_RANK[1],  COL_RANK[2]],
		[name,  COL_NAME[0],  COL_NAME[1],  COL_NAME[2]],
		[score, COL_SCORE[0], COL_SCORE[1], COL_SCORE[2]],
		[level, COL_LEVEL[0], COL_LEVEL[1], COL_LEVEL[2]],
	]
	for c in cols:
		var lbl := Label.new()
		lbl.text            = c[0]
		lbl.position        = Vector2(c[1], y)
		lbl.size            = Vector2(c[2], 22)
		lbl.horizontal_alignment = c[3]
		lbl.add_theme_font_size_override("font_size", font_size)
		lbl.modulate        = color
		add_child(lbl)
