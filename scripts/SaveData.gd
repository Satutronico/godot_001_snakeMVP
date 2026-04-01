extends Node

const SAVE_PATH := "user://save.cfg"

var player_name : String = ""
var top5        : Array  = []  # Array of {name, score, level, time}, sorted best-first


func load_data() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	player_name = cfg.get_value("player", "name", "")
	top5 = []
	for i in 5:
		if not cfg.has_section_key("top5", "name_%d" % i):
			break
		top5.append({
			"name":  cfg.get_value("top5", "name_%d"  % i, ""),
			"score": cfg.get_value("top5", "score_%d" % i, 0),
			"level": cfg.get_value("top5", "level_%d" % i, 1),
			"time":  cfg.get_value("top5", "time_%d"  % i, 0.0),
		})


func save_data() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("player", "name", player_name)
	for i in top5.size():
		cfg.set_value("top5", "name_%d"  % i, top5[i].name)
		cfg.set_value("top5", "score_%d" % i, top5[i].score)
		cfg.set_value("top5", "level_%d" % i, top5[i].level)
		cfg.set_value("top5", "time_%d"  % i, top5[i].time)
	cfg.save(SAVE_PATH)


# Inserts result into top5 if it qualifies. Returns true if it made the list.
# Ranking: higher score wins; equal score → lower time wins.
func add_result(name: String, score: int, level: int, time: float) -> bool:
	if score == 0:
		return false
	var qualifies: bool = (
		top5.size() < 5
		or score > top5.back().score
		or (score == top5.back().score and time < top5.back().time)
	)
	if not qualifies:
		return false
	top5.append({"name": name, "score": score, "level": level, "time": time})
	top5.sort_custom(func(a, b):
		if a.score != b.score:
			return a.score > b.score
		return a.time < b.time
	)
	if top5.size() > 5:
		top5.resize(5)
	save_data()
	return true
