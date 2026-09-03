extends Node

signal background_battle_tick

const SAVE_PATH := "user://save_game.json"
const DEVELOPER_TEST_SAVE_PATH := "user://developer_test_save.json"
const CHARACTER_ROSTER_PATH := "user://character_slots.json"
const MAX_OFFLINE_SECONDS := 8.0 * 60.0 * 60.0
const AUTO_SAVE_INTERVAL := 5.0
const BACKGROUND_BATTLE_INTERVAL := 6.0

var spirit_essence: float = 0.0
var player_level: int = 1
var player_exp: int = 0
var coins: int = 0
var pages: int = 0
var kill_count: int = 0
var region_progress: int = 0
var region_reward_claimed: bool = false
var daily_task_refreshes: int = 0
var weekly_task_refreshes: int = 0
var daily_task_reset_key: String = ""
var weekly_task_reset_key: String = ""
var task_tracker_collapsed: bool = false
var daily_tasks: Array = []
var weekly_tasks: Array = []
var repeat_task_offers: Array = []
var active_repeat_tasks: Array = []
var repeat_task_refreshes: int = 0
var repeat_task_reset_key: String = ""
var support_skill_exp: int = 0
var event_debuff_hits: int = 0
var boss_policy: String = "fight"
var escape_talismans: int = 3
var event_auto_policy: String = "manual"
var active_skill_auto: bool = true
var skills: Array = []
var equipment: Array = []
var skill_materials: Dictionary = {"普通法脈殘墨": 0, "稀有法脈殘墨": 0, "高級法脈殘墨": 0, "Boss法印": 0}
var card_counts: Dictionary = {"地基主": 0}
var prologue_completed: bool = false
var developer_test_mode: bool = false
var _save_timer: float = 0.0
var battle_view_active: bool = false
var _background_battle_timer: float = 0.0
var selected_character_slot: int = -1
var selected_character_name: String = ""
var character_slots: Array[Dictionary] = []


func _ready() -> void:
	_load_character_roster()


func _active_save_path() -> String:
	if developer_test_mode:
		return DEVELOPER_TEST_SAVE_PATH
	return _character_save_path(selected_character_slot)


func _character_save_path(slot_index: int) -> String:
	if slot_index <= 0:
		return SAVE_PATH
	return "user://character_%d.json" % (slot_index + 1)


func _empty_character_slot() -> Dictionary:
	return {"occupied": false, "name": "", "created_at": 0, "last_played": 0}


func _load_character_roster() -> void:
	character_slots.clear()
	if FileAccess.file_exists(CHARACTER_ROSTER_PATH):
		var file := FileAccess.open(CHARACTER_ROSTER_PATH, FileAccess.READ)
		if file != null:
			var parsed: Variant = JSON.parse_string(file.get_as_text())
			if parsed is Array:
				for entry in parsed:
					if entry is Dictionary:
						character_slots.append(entry.duplicate(true))
	while character_slots.size() < 3:
		character_slots.append(_empty_character_slot())
	if character_slots.size() > 3:
		character_slots.resize(3)
	if not bool(character_slots[0].get("occupied", false)) and FileAccess.file_exists(SAVE_PATH):
		character_slots[0] = {"occupied": true, "name": "既有角色", "created_at": 0, "last_played": int(Time.get_unix_time_from_system())}
		_save_character_roster()


func _save_character_roster() -> void:
	var file := FileAccess.open(CHARACTER_ROSTER_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(character_slots))


func create_character(slot_index: int, character_name: String) -> bool:
	if slot_index < 0 or slot_index >= 3 or bool(character_slots[slot_index].get("occupied", false)):
		return false
	var clean_name := character_name.strip_edges()
	if clean_name == "" or clean_name.length() > 10:
		return false
	var now := int(Time.get_unix_time_from_system())
	character_slots[slot_index] = {"occupied": true, "name": clean_name, "created_at": now, "last_played": now}
	selected_character_slot = slot_index
	selected_character_name = clean_name
	developer_test_mode = false
	_reset_runtime_state()
	_save_game()
	_save_character_roster()
	return true


func select_character(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= character_slots.size() or not bool(character_slots[slot_index].get("occupied", false)):
		return false
	if selected_character_slot >= 0:
		_save_game()
	selected_character_slot = slot_index
	selected_character_name = str(character_slots[slot_index].get("name", "引渡人"))
	developer_test_mode = false
	_reset_runtime_state()
	_load_game()
	character_slots[slot_index]["last_played"] = int(Time.get_unix_time_from_system())
	_save_character_roster()
	return true


func delete_character(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= character_slots.size() or not bool(character_slots[slot_index].get("occupied", false)):
		return false
	var absolute_path := ProjectSettings.globalize_path(_character_save_path(slot_index))
	if FileAccess.file_exists(_character_save_path(slot_index)):
		DirAccess.remove_absolute(absolute_path)
	character_slots[slot_index] = _empty_character_slot()
	if selected_character_slot == slot_index:
		selected_character_slot = -1
		selected_character_name = ""
		_reset_runtime_state()
	_save_character_roster()
	return true


func enter_developer_test_profile() -> void:
	_save_game()
	developer_test_mode = true
	_reset_runtime_state()
	if FileAccess.file_exists(DEVELOPER_TEST_SAVE_PATH):
		_load_game()
	else:
		_initialize_developer_test_profile()
		_save_game()


func exit_developer_test_profile() -> void:
	_save_game()
	developer_test_mode = false
	_reset_runtime_state()
	_load_game()


func reset_developer_test_profile() -> void:
	developer_test_mode = true
	_reset_runtime_state()
	_initialize_developer_test_profile()
	_save_game()


func _reset_runtime_state() -> void:
	spirit_essence = 0.0
	player_level = 1
	player_exp = 0
	coins = 0
	pages = 0
	kill_count = 0
	region_progress = 0
	region_reward_claimed = false
	daily_task_refreshes = 0
	weekly_task_refreshes = 0
	daily_task_reset_key = ""
	weekly_task_reset_key = ""
	task_tracker_collapsed = false
	daily_tasks = []
	weekly_tasks = []
	repeat_task_offers = []
	active_repeat_tasks = []
	repeat_task_refreshes = 0
	repeat_task_reset_key = ""
	support_skill_exp = 0
	event_debuff_hits = 0
	boss_policy = "fight"
	escape_talismans = 3
	event_auto_policy = "manual"
	active_skill_auto = true
	skills = []
	equipment = []
	skill_materials = {"普通法脈殘墨": 0, "稀有法脈殘墨": 0, "高級法脈殘墨": 0, "Boss法印": 0}
	card_counts = {"地基主": 0}
	prologue_completed = false


func _initialize_developer_test_profile() -> void:
	player_level = 80
	player_exp = 0
	coins = 10000000
	pages = 9999
	kill_count = 5000
	region_progress = 1200
	region_reward_claimed = true
	escape_talismans = 99
	event_auto_policy = "reward"
	skills = [
		{"name": "淨符", "level": 15, "books": 300, "need": 6, "quality": "普通", "profession": "引渡人", "type": "攻擊", "description": "以基礎淨符攻擊目前目標，對異變鬼怪造成少量額外傷害。", "unlocked": true},
		{"name": "引魂燈", "level": 15, "books": 300, "need": 6, "quality": "普通", "profession": "引渡人", "type": "輔助", "description": "伴生靈追加攻擊時，有小機率恢復主角 1 點生命。", "unlocked": true},
		{"name": "安魂咒", "level": 15, "books": 300, "need": 6, "quality": "普通", "profession": "引渡人", "type": "恢復", "description": "生命偏低時恢復少量生命。", "unlocked": true},
		{"name": "敕符・淨煞", "level": 15, "books": 300, "need": 6, "quality": "普通", "profession": "引渡人", "type": "主動", "description": "敕令淨符掃過敵陣，對所有存活鬼怪造成淨煞傷害。冷卻 12 秒。", "unlocked": true}
	]
	skill_materials = {"普通法脈殘墨": 60, "稀有法脈殘墨": 60, "高級法脈殘墨": 60, "Boss法印": 10}
	card_counts = {"地基主": 12, "無面紙僕": 5, "吊頸鬼影": 3, "腐燈童子": 2, "迷路陰兵": 1, "紙轎倀": 1, "送煞紙將": 1}
	prologue_completed = true
	equipment = [
		{"name": "試煉桃木劍", "level": 10, "affix": "攻擊 +30", "slot": "武器", "power": 30, "equipped": true},
		{"name": "試煉法衣", "level": 10, "affix": "生命 +80", "slot": "防具", "power": 40, "equipped": true},
		{"name": "試煉鎮魂符", "level": 10, "affix": "靈體減傷 +10", "slot": "護符", "power": 10, "equipped": true}
	]


func _process(delta: float) -> void:
	_save_timer += delta
	if _save_timer >= AUTO_SAVE_INTERVAL:
		_save_timer = 0.0
		_save_game()
	if battle_view_active:
		_background_battle_timer = 0.0
	else:
		_background_battle_timer += delta
		if _background_battle_timer >= BACKGROUND_BATTLE_INTERVAL:
			_background_battle_timer -= BACKGROUND_BATTLE_INTERVAL
			background_battle_tick.emit()


func set_battle_view_active(active: bool) -> void:
	battle_view_active = active
	if active:
		_background_battle_timer = 0.0


func add_essence(amount: float) -> void:
	# Later, multiplayer servers can own and validate this mutation.
	spirit_essence += maxf(amount, 0.0)


func update_inventory(new_level: int, new_exp: int, new_coins: int, new_pages: int, new_kill_count: int, new_region_progress: int, new_region_reward_claimed: bool, new_daily_task_refreshes: int, new_weekly_task_refreshes: int, new_daily_task_reset_key: String, new_weekly_task_reset_key: String, new_task_tracker_collapsed: bool, new_daily_tasks: Array, new_weekly_tasks: Array, new_repeat_task_offers: Array, new_active_repeat_tasks: Array, new_repeat_task_refreshes: int, new_repeat_task_reset_key: String, new_support_skill_exp: int, new_event_debuff_hits: int, new_boss_policy: String, new_escape_talismans: int, new_event_auto_policy: String, new_active_skill_auto: bool, new_skills: Array, new_equipment: Array, new_skill_materials: Dictionary, new_card_counts: Dictionary, new_prologue_completed: bool) -> void:
	player_level = maxi(new_level, 1)
	player_exp = maxi(new_exp, 0)
	coins = maxi(new_coins, 0)
	pages = maxi(new_pages, 0)
	kill_count = maxi(new_kill_count, 0)
	region_progress = maxi(new_region_progress, 0)
	region_reward_claimed = new_region_reward_claimed
	daily_task_refreshes = maxi(new_daily_task_refreshes, 0)
	weekly_task_refreshes = maxi(new_weekly_task_refreshes, 0)
	daily_task_reset_key = new_daily_task_reset_key
	weekly_task_reset_key = new_weekly_task_reset_key
	task_tracker_collapsed = new_task_tracker_collapsed
	daily_tasks = new_daily_tasks.duplicate(true)
	weekly_tasks = new_weekly_tasks.duplicate(true)
	repeat_task_offers = new_repeat_task_offers.duplicate(true)
	active_repeat_tasks = new_active_repeat_tasks.duplicate(true)
	repeat_task_refreshes = maxi(new_repeat_task_refreshes, 0)
	repeat_task_reset_key = new_repeat_task_reset_key
	support_skill_exp = maxi(new_support_skill_exp, 0)
	event_debuff_hits = maxi(new_event_debuff_hits, 0)
	boss_policy = new_boss_policy
	escape_talismans = maxi(new_escape_talismans, 0)
	event_auto_policy = new_event_auto_policy
	active_skill_auto = new_active_skill_auto
	skills = new_skills.duplicate(true)
	equipment = new_equipment.duplicate(true)
	skill_materials = new_skill_materials.duplicate(true)
	card_counts = new_card_counts.duplicate(true)
	prologue_completed = new_prologue_completed


func save_now() -> void:
	_save_game()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_game()
		get_tree().quit()


func _load_game() -> void:
	var save_path := _active_save_path()
	if not FileAccess.file_exists(save_path):
		return
	var file := FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return
	var data := parsed as Dictionary
	spirit_essence = maxf(float(data.get("spirit_essence", 0.0)), 0.0)
	player_level = maxi(int(data.get("player_level", 1)), 1)
	player_exp = maxi(int(data.get("player_exp", 0)), 0)
	coins = maxi(int(data.get("coins", 0)), 0)
	pages = maxi(int(data.get("pages", 0)), 0)
	kill_count = maxi(int(data.get("kill_count", 0)), 0)
	region_progress = maxi(int(data.get("region_progress", 0)), 0)
	region_reward_claimed = bool(data.get("region_reward_claimed", false))
	daily_task_refreshes = maxi(int(data.get("daily_task_refreshes", 0)), 0)
	weekly_task_refreshes = maxi(int(data.get("weekly_task_refreshes", 0)), 0)
	daily_task_reset_key = str(data.get("daily_task_reset_key", ""))
	weekly_task_reset_key = str(data.get("weekly_task_reset_key", ""))
	task_tracker_collapsed = bool(data.get("task_tracker_collapsed", false))
	var saved_daily_tasks: Variant = data.get("daily_tasks", [])
	if saved_daily_tasks is Array:
		daily_tasks = saved_daily_tasks.duplicate(true)
	var saved_weekly_tasks: Variant = data.get("weekly_tasks", [])
	if saved_weekly_tasks is Array:
		weekly_tasks = saved_weekly_tasks.duplicate(true)
	var saved_repeat_offers: Variant = data.get("repeat_task_offers", [])
	if saved_repeat_offers is Array:
		repeat_task_offers = saved_repeat_offers.duplicate(true)
	var saved_active_repeat: Variant = data.get("active_repeat_tasks", [])
	if saved_active_repeat is Array:
		active_repeat_tasks = saved_active_repeat.duplicate(true)
	repeat_task_refreshes = maxi(int(data.get("repeat_task_refreshes", 0)), 0)
	repeat_task_reset_key = str(data.get("repeat_task_reset_key", ""))
	support_skill_exp = maxi(int(data.get("support_skill_exp", 0)), 0)
	event_debuff_hits = maxi(int(data.get("event_debuff_hits", 0)), 0)
	boss_policy = str(data.get("boss_policy", "fight"))
	escape_talismans = maxi(int(data.get("escape_talismans", 3)), 0)
	event_auto_policy = str(data.get("event_auto_policy", "manual"))
	active_skill_auto = bool(data.get("active_skill_auto", true))
	var saved_skills: Variant = data.get("skills", [])
	if saved_skills is Array:
		skills = saved_skills.duplicate(true)
	var saved_equipment: Variant = data.get("equipment", [])
	if saved_equipment is Array:
		equipment = saved_equipment.duplicate(true)
	var saved_skill_materials: Variant = data.get("skill_materials", {})
	if saved_skill_materials is Dictionary:
		for material_name in saved_skill_materials.keys():
			skill_materials[material_name] = maxi(int(saved_skill_materials[material_name]), 0)
	var saved_card_counts: Variant = data.get("card_counts", {"地基主": 0})
	if saved_card_counts is Dictionary:
		card_counts = saved_card_counts.duplicate(true)
	prologue_completed = bool(data.get("prologue_completed", false))
	if developer_test_mode and not data.has("skill_materials"):
		skill_materials = {"普通法脈殘墨": 60, "稀有法脈殘墨": 60, "高級法脈殘墨": 60, "Boss法印": 10}
	var saved_at := int(data.get("saved_at_unix", Time.get_unix_time_from_system()))
	var elapsed := clampf(float(Time.get_unix_time_from_system() - saved_at), 0.0, MAX_OFFLINE_SECONDS)
	spirit_essence += elapsed


func _save_game() -> void:
	if not developer_test_mode and selected_character_slot < 0:
		return
	var file := FileAccess.open(_active_save_path(), FileAccess.WRITE)
	if file == null:
		return
	var data := {
		"save_version": 2,
		"spirit_essence": spirit_essence,
		"player_level": player_level,
		"player_exp": player_exp,
		"coins": coins,
		"pages": pages,
		"kill_count": kill_count,
		"region_progress": region_progress,
		"region_reward_claimed": region_reward_claimed,
		"daily_task_refreshes": daily_task_refreshes,
		"weekly_task_refreshes": weekly_task_refreshes,
		"daily_task_reset_key": daily_task_reset_key,
		"weekly_task_reset_key": weekly_task_reset_key,
		"task_tracker_collapsed": task_tracker_collapsed,
		"daily_tasks": daily_tasks,
		"weekly_tasks": weekly_tasks,
		"repeat_task_offers": repeat_task_offers,
		"active_repeat_tasks": active_repeat_tasks,
		"repeat_task_refreshes": repeat_task_refreshes,
		"repeat_task_reset_key": repeat_task_reset_key,
		"support_skill_exp": support_skill_exp,
		"event_debuff_hits": event_debuff_hits,
		"boss_policy": boss_policy,
		"escape_talismans": escape_talismans,
		"event_auto_policy": event_auto_policy,
		"active_skill_auto": active_skill_auto,
		"skills": skills,
		"equipment": equipment,
		"skill_materials": skill_materials,
		"card_counts": card_counts,
		"prologue_completed": prologue_completed,
		"saved_at_unix": Time.get_unix_time_from_system(),
	}
	file.store_string(JSON.stringify(data))
