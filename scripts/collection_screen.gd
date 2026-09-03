extends Control

const PAPER := Color("d6c398")
const INK := Color("211b17")
const RED := Color("6d241f")
const GREEN := Color("344b3e")
const COPPER := Color("657265")
const CURRENT_COMPANION_AWAKENING := 1
const REGION_BOSS_CHANCE := 0.05
const REGION_EVENT_CHANCE := 0.10
const REGION_MONSTERS := [
	{"name": "無面紙僕", "weight": 35, "level": 8, "hp": 90, "damage_min": 2, "damage_max": 4, "coin_mult": 1.0, "page_chance": 0.10, "trait": "普通近戰", "color": "727a70", "scale": 1.00},
	{"name": "吊頸鬼影", "weight": 22, "level": 7, "hp": 72, "damage_min": 3, "damage_max": 6, "coin_mult": 1.0, "page_chance": 0.12, "trait": "緩慢重擊", "color": "43594f", "scale": 1.00},
	{"name": "腐燈童子", "weight": 20, "level": 6, "hp": 58, "damage_min": 2, "damage_max": 5, "coin_mult": 0.9, "page_chance": 0.18, "trait": "腐燈侵蝕", "color": "8a6b3e", "scale": 1.00},
	{"name": "迷路陰兵", "weight": 13, "level": 9, "hp": 125, "damage_min": 2, "damage_max": 5, "coin_mult": 1.6, "page_chance": 0.08, "trait": "厚重陰甲", "color": "39454a", "scale": 1.00},
	{"name": "紙轎倀", "weight": 10, "level": 8, "hp": 66, "damage_min": 3, "damage_max": 5, "coin_mult": 1.1, "page_chance": 0.35, "trait": "尋得殘頁", "color": "78534d", "scale": 1.00}
]
const SKILL_BOOK_DROP_CHANCE := 0.02
const LEVEL_EXP_REQUIREMENTS := [0, 100, 350, 800, 1600, 2800, 4500, 7000, 10500, 15000]
const REGION_COMPLETION_KILLS := 100

var card_names := ["地基主", "魔神仔", "虎姑婆", "林投姐", "風獅爺", "蛇郎君"]
var card_types := ["神祇", "精怪", "凶煞", "異聞", "神祇", "異聞"]
var battle_enemy_hp := 90
var battle_kill_count := 0
var battle_targets: Array[Dictionary] = []
var battle_locked_target := -1
var battle_player_hp := 140
var battle_player_attack_timer: Timer
var battle_enemy_attack_timer: Timer
var battle_active_skill_timer: Timer
var battle_active_skill_button: Button
var battle_active_skill_auto := true
var skill_materials: Dictionary = {"普通法脈殘墨": 0, "稀有法脈殘墨": 0, "高級法脈殘墨": 0, "Boss法印": 0}
var skill_exchange_message := ""
var exchange_selected_skill_by_quality: Dictionary = {}
var background_kills_since_view := 0
var background_exp_since_view := 0
var background_coins_since_view := 0
var background_pages_since_view := 0
var background_items_since_view := 0
var battle_motion_tween: Tween
var battle_companion_tween: Tween
var battle_companion_hp := 60
var battle_companion_resting := false
var region_event_active := false
var support_skill_exp := 0
var event_debuff_hits := 0
var boss_policy := "fight"
var escape_talismans := 3
var event_auto_policy := "manual"
var battle_spawn_sequence := 0
var battle_hit_counter := 0
var battle_player_hp_bar_ref: ColorRect
var battle_player_level_label: Label
var battle_player_exp_label: Label
var inventory_coins := 0
var player_level := 1
var player_exp := 0
var inventory_pages := 0
var card_counts: Dictionary = {"地基主": 0}
var prologue_completed := false
var tutorial_dijizhu_hp := 60
var tutorial_dijizhu_hp_bar: ColorRect
var tutorial_player_hp := 36
var tutorial_player_hp_bar: ColorRect
var tutorial_battle_log: Label
var tutorial_attack_timer: Timer
var starter_equipment_tutorial_active := false
var region_progress := 0
var region_reward_claimed := false
var daily_task_refreshes := 0
var weekly_task_refreshes := 0
var daily_task_reset_key := ""
var weekly_task_reset_key := ""
var task_tracker_collapsed := false
var daily_tasks: Array[Dictionary] = []
var weekly_tasks: Array[Dictionary] = []
var repeat_task_offers: Array[Dictionary] = []
var active_repeat_tasks: Array[Dictionary] = []
var repeat_task_refreshes := 0
var repeat_task_reset_key := ""
var region_boss_pending := false
var region_boss_active := false
var region_boss_target_index := -1
var region_progress_label: Label
var region_boss_badge: Label
var inventory_equipment: Array[Dictionary] = [
	{"name": "舊短刀", "level": 0, "affix": "攻擊 +5", "slot": "武器", "power": 5, "equipped": false},
	{"name": "粗布衣", "level": 0, "affix": "生命 +12", "slot": "防具", "power": 12, "equipped": false},
	{"name": "香灰護符", "level": 0, "affix": "靈息恢復 +1%", "slot": "護符", "power": 1, "equipped": false}
]
var novice_skills: Array[Dictionary] = [
	{"name": "淨符", "level": 1, "books": 0, "need": 1, "quality": "普通", "profession": "引渡人", "type": "攻擊", "description": "以基礎淨符攻擊目前目標，對異變鬼怪造成少量額外傷害。", "unlocked": true},
	{"name": "引魂燈", "level": 1, "books": 0, "need": 1, "quality": "普通", "profession": "引渡人", "type": "輔助", "description": "伴生靈追加攻擊時，有小機率恢復主角 1 點生命。", "unlocked": true},
	{"name": "安魂咒", "level": 0, "books": 0, "need": 1, "quality": "普通", "profession": "引渡人", "type": "恢復", "description": "生命偏低時施放，恢復少量生命；需要取得安魂咒技能書。", "unlocked": false},
	{"name": "敕符・淨煞", "level": 1, "books": 0, "need": 1, "quality": "普通", "profession": "引渡人", "type": "主動", "description": "敕令淨符掃過敵陣，對所有存活鬼怪造成淨煞傷害。冷卻 12 秒。", "unlocked": true}
]


func _ready() -> void:
	if not GameState.background_battle_tick.is_connected(_resolve_background_battle_tick):
		GameState.background_battle_tick.connect(_resolve_background_battle_tick)
	GameState.set_battle_view_active(false)
	if GameState.selected_character_slot < 0:
		_show_character_select()
		return
	_load_persistent_progress()
	if prologue_completed:
		_build_screen()
	else:
		_show_prologue_intro()


func _load_persistent_progress() -> void:
	player_level = GameState.player_level
	player_exp = GameState.player_exp
	inventory_coins = GameState.coins
	inventory_pages = GameState.pages
	card_counts = GameState.card_counts.duplicate(true)
	prologue_completed = GameState.prologue_completed
	battle_kill_count = GameState.kill_count
	region_progress = GameState.region_progress
	region_reward_claimed = GameState.region_reward_claimed
	daily_task_refreshes = GameState.daily_task_refreshes
	weekly_task_refreshes = GameState.weekly_task_refreshes
	daily_task_reset_key = GameState.daily_task_reset_key
	weekly_task_reset_key = GameState.weekly_task_reset_key
	task_tracker_collapsed = GameState.task_tracker_collapsed
	for task in GameState.daily_tasks:
		if task is Dictionary:
			daily_tasks.append(task.duplicate(true))
	for task in GameState.weekly_tasks:
		if task is Dictionary:
			weekly_tasks.append(task.duplicate(true))
	for task in GameState.repeat_task_offers:
		if task is Dictionary:
			repeat_task_offers.append(task.duplicate(true))
	for task in GameState.active_repeat_tasks:
		if task is Dictionary:
			active_repeat_tasks.append(task.duplicate(true))
	repeat_task_refreshes = GameState.repeat_task_refreshes
	repeat_task_reset_key = GameState.repeat_task_reset_key
	_refresh_task_cycles()
	support_skill_exp = GameState.support_skill_exp
	event_debuff_hits = GameState.event_debuff_hits
	boss_policy = GameState.boss_policy
	escape_talismans = GameState.escape_talismans
	event_auto_policy = GameState.event_auto_policy
	battle_active_skill_auto = GameState.active_skill_auto
	skill_materials = GameState.skill_materials.duplicate(true)
	if not GameState.equipment.is_empty():
		inventory_equipment.clear()
		for saved_item in GameState.equipment:
			if saved_item is Dictionary:
				inventory_equipment.append(saved_item.duplicate(true))
	_normalize_inventory_items()
	if not GameState.skills.is_empty():
		novice_skills.clear()
		for saved_skill in GameState.skills:
			if saved_skill is Dictionary:
				novice_skills.append(saved_skill.duplicate(true))
	_normalize_skills()


func _normalize_skills() -> void:
	var required_skills: Array[Dictionary] = [
		{"name": "淨符", "level": 1, "books": 0, "need": 1, "quality": "普通", "profession": "引渡人", "type": "攻擊", "description": "以基礎淨符攻擊目前目標，對異變鬼怪造成少量額外傷害。", "unlocked": true},
		{"name": "引魂燈", "level": 1, "books": 0, "need": 1, "quality": "普通", "profession": "引渡人", "type": "輔助", "description": "伴生靈追加攻擊時，有小機率恢復主角 1 點生命。", "unlocked": true},
		{"name": "安魂咒", "level": 0, "books": 0, "need": 1, "quality": "普通", "profession": "引渡人", "type": "恢復", "description": "生命偏低時施放，恢復少量生命；需要取得安魂咒技能書。", "unlocked": false},
		{"name": "敕符・淨煞", "level": 1, "books": 0, "need": 1, "quality": "普通", "profession": "引渡人", "type": "主動", "description": "敕令淨符掃過敵陣，對所有存活鬼怪造成淨煞傷害。冷卻 12 秒。", "unlocked": true}
	]
	for required in required_skills:
		var existing_index := _skill_index(str(required["name"]))
		if existing_index == -1:
			novice_skills.append(required.duplicate(true))
		else:
			for field in required.keys():
				if field == "quality" or field == "profession":
					novice_skills[existing_index][field] = required[field]
				elif not novice_skills[existing_index].has(field):
					novice_skills[existing_index][field] = required[field]


func _normalize_inventory_items() -> void:
	for i in inventory_equipment.size():
		var item := inventory_equipment[i]
		if not item.has("slot"):
			item["slot"] = "防具" if "衣" in str(item.get("name", "")) or "鞋" in str(item.get("name", "")) else ("護符" if "符" in str(item.get("name", "")) or "鈴" in str(item.get("name", "")) else "武器")
		if not item.has("power"):
			item["power"] = 1
		if not item.has("equipped"):
			item["equipped"] = false
		inventory_equipment[i] = item


func _save_persistent_progress() -> void:
	GameState.update_inventory(player_level, player_exp, inventory_coins, inventory_pages, battle_kill_count, region_progress, region_reward_claimed, daily_task_refreshes, weekly_task_refreshes, daily_task_reset_key, weekly_task_reset_key, task_tracker_collapsed, daily_tasks, weekly_tasks, repeat_task_offers, active_repeat_tasks, repeat_task_refreshes, repeat_task_reset_key, support_skill_exp, event_debuff_hits, boss_policy, escape_talismans, event_auto_policy, battle_active_skill_auto, novice_skills, inventory_equipment, skill_materials, card_counts, prologue_completed)
	GameState.save_now()


func _enter_background_battle_mode() -> void:
	if is_instance_valid(battle_player_attack_timer):
		battle_player_attack_timer.stop()
	if is_instance_valid(battle_enemy_attack_timer):
		battle_enemy_attack_timer.stop()
	if is_instance_valid(battle_active_skill_timer):
		battle_active_skill_timer.stop()
	GameState.set_battle_view_active(false)


func _grant_player_exp(amount: int) -> int:
	if GameState.developer_test_mode or player_level >= 10:
		_refresh_battle_progress_labels()
		return 0
	player_exp += maxi(amount, 0)
	var levels_gained := 0
	while player_level < 10 and player_exp >= int(LEVEL_EXP_REQUIREMENTS[player_level]):
		player_level += 1
		levels_gained += 1
	_refresh_battle_progress_labels()
	return levels_gained


func _refresh_battle_progress_labels() -> void:
	if is_instance_valid(battle_player_level_label):
		battle_player_level_label.text = "霧隱古道・入口　Lv.%d" % player_level
	if is_instance_valid(battle_player_exp_label):
		battle_player_exp_label.text = _next_level_exp_text()
	_refresh_region_progress_label()


func _refresh_region_progress_label() -> void:
	if not is_instance_valid(region_progress_label):
		return
	if region_reward_claimed:
		region_progress_label.text = "古道調查完成"
	elif region_boss_pending:
		region_progress_label.text = "調查 %d／%d・凶兆" % [mini(region_progress, REGION_COMPLETION_KILLS), REGION_COMPLETION_KILLS]
	else:
		region_progress_label.text = "調查 %d／%d" % [mini(region_progress, REGION_COMPLETION_KILLS), REGION_COMPLETION_KILLS]


func _try_complete_first_region() -> bool:
	if region_reward_claimed or region_progress < REGION_COMPLETION_KILLS:
		return false
	_refresh_region_progress_label()
	return true


func _refresh_task_cycles() -> void:
	var date := Time.get_date_dict_from_system()
	var new_daily := "%04d-%02d-%02d" % [date.year, date.month, date.day]
	var new_weekly := str(int(Time.get_unix_time_from_system() / 604800.0))
	if daily_task_reset_key != new_daily:
		daily_task_reset_key = new_daily
		daily_task_refreshes = 0
		daily_tasks = _generate_task_set(false, 0)
	if weekly_task_reset_key != new_weekly:
		weekly_task_reset_key = new_weekly
		weekly_task_refreshes = 0
		weekly_tasks = _generate_task_set(true, 0)
	if daily_tasks.is_empty():
		daily_tasks = _generate_task_set(false, daily_task_refreshes)
	if weekly_tasks.is_empty():
		weekly_tasks = _generate_task_set(true, weekly_task_refreshes)
	if repeat_task_reset_key != new_daily:
		repeat_task_reset_key = new_daily
		repeat_task_refreshes = 0
		repeat_task_offers = _generate_repeat_task_offers()
	if repeat_task_offers.is_empty() and active_repeat_tasks.is_empty():
		repeat_task_offers = _generate_repeat_task_offers()


func _generate_task_set(weekly: bool, refreshes: int) -> Array[Dictionary]:
	var tasks: Array[Dictionary] = []
	var kinds := ["kill", "event", "boss"]
	var daily_names := ["鎮伏霧中遊魂", "完成民俗異聞", "擊退區域小頭目"]
	var weekly_names := ["平定古道鬼群", "追查七夜異聞", "鎮壓古道凶兆"]
	for i in 3:
		var difficulty := (refreshes + i) % 3
		var base_targets := [8, 1, 1]
		var target: int = int(base_targets[i]) + difficulty * (4 if i == 0 else 1)
		if weekly:
			target *= 5
		var reward_scale := (5 if weekly else 1) * (difficulty + 1)
		tasks.append({
			"kind": kinds[i], "name": weekly_names[i] if weekly else daily_names[i],
			"difficulty": difficulty, "target": target, "progress": 0, "claimed": false,
			"reward_coins": 120 * reward_scale, "reward_pages": 2 * reward_scale
		})
	return tasks


func _advance_rotating_tasks(kind: String, amount: int = 1) -> void:
	for task_list in [daily_tasks, weekly_tasks]:
		for i in task_list.size():
			var task: Dictionary = task_list[i]
			if str(task.get("kind", "")) == kind and not bool(task.get("claimed", false)):
				task["progress"] = mini(int(task.get("target", 1)), int(task.get("progress", 0)) + amount)
				task_list[i] = task


func _roll_repeat_difficulty() -> int:
	var roll := randf()
	if roll < 0.002:
		return 5
	if roll < 0.030:
		return 4
	if roll < 0.150:
		return 3
	if roll < 0.450:
		return 2
	return 1


func _generate_repeat_task_offers() -> Array[Dictionary]:
	var offers: Array[Dictionary] = []
	var active_names: Array[String] = []
	for task in active_repeat_tasks:
		active_names.append(str(task.get("name", "")))
	var normal_names := ["鎮伏霧中遊魂", "清掃紙灰邪祟", "巡查古道陰影", "驅散迷途鬼群", "封鎮腐燈邪物"]
	var attempts := 0
	while offers.size() < 3 and attempts < 40:
		attempts += 1
		var tier := _roll_repeat_difficulty()
		var name := "送煞紙將・地區懸賞" if tier == 5 else str(normal_names.pick_random())
		if name in active_names:
			continue
		var duplicate := false
		for offer in offers:
			if str(offer.get("name", "")) == name:
				duplicate = true
		if duplicate:
			continue
		var target: int = randi_range(1, 3) if tier == 5 else int([0, 12, 22, 38, 60][tier])
		offers.append({"name": name, "tier": tier, "kind": "boss" if tier == 5 else "kill", "boss_name": "送煞紙將" if tier == 5 else "", "target": target, "progress": 0, "claimed": false, "min_level": maxi(player_level - 5, 1), "reward_exp": (tier * 120) if tier < 5 else tier * 80, "reward_coins": tier * 180, "rare_material": tier == 5 and randf() < 0.25})
	return offers


func _advance_repeat_tasks(kind: String, monster_level: int, boss_name: String, amount: int = 1) -> void:
	for i in active_repeat_tasks.size():
		var task: Dictionary = active_repeat_tasks[i]
		if str(task.get("kind", "")) != kind or bool(task.get("claimed", false)):
			continue
		if kind == "kill" and monster_level < player_level - 5:
			continue
		if kind == "boss" and str(task.get("boss_name", "")) != boss_name:
			continue
		task["progress"] = mini(int(task.get("target", 1)), int(task.get("progress", 0)) + amount)
		active_repeat_tasks[i] = task


func _has_task_reward_ready() -> bool:
	if region_progress >= REGION_COMPLETION_KILLS and not region_reward_claimed:
		return true
	for task in active_repeat_tasks:
		if int(task.get("progress", 0)) >= int(task.get("target", 1)):
			return true
	return false


func _tracked_task_summary() -> Dictionary:
	for task in active_repeat_tasks:
		if int(task.get("progress", 0)) >= int(task.get("target", 1)):
			return {"title": str(task.get("name", "重複差事")), "status": "可領取獎勵", "tab": "進行中"}
	if not active_repeat_tasks.is_empty():
		var task: Dictionary = active_repeat_tasks[0]
		return {"title": str(task.get("name", "重複差事")), "status": "進度 %d／%d" % [int(task.get("progress", 0)), int(task.get("target", 1))], "tab": "進行中"}
	if not region_reward_claimed:
		return {"title": "主線・霧隱古道初探", "status": "可領取獎勵" if region_progress >= REGION_COMPLETION_KILLS else "進度 %d／%d" % [region_progress, REGION_COMPLETION_KILLS], "tab": "主線"}
	return {"title": "", "status": "", "tab": "可接差事"}


func _claim_region_reward() -> String:
	if region_reward_claimed or region_progress < REGION_COMPLETION_KILLS:
		return ""
	region_reward_claimed = true
	inventory_coins += 500
	inventory_pages += 20
	var skill_book_reward := _grant_random_bound_skill_book()
	_save_persistent_progress()
	_refresh_region_progress_label()
	return skill_book_reward


func _next_level_exp_text() -> String:
	if GameState.developer_test_mode:
		return "開發試煉角色"
	if player_level >= 10:
		return "Lv.10　已達轉職等級條件"
	return "Lv.%d　經驗 %d／%d" % [player_level, player_exp, int(LEVEL_EXP_REQUIREMENTS[player_level])]


func _grant_random_bound_skill_book() -> String:
	var available_skills := _skills_of_quality("普通", false, true)
	if available_skills.is_empty():
		return ""
	var skill_index: int = available_skills.pick_random()
	var skill: Dictionary = novice_skills[skill_index]
	skill["books"] = int(skill.get("books", 0)) + 1
	if not skill.get("unlocked", false) and int(skill["books"]) >= int(skill.get("need", 1)):
		skill["unlocked"] = true
		skill["level"] = 1
		skill["books"] = int(skill["books"]) - int(skill.get("need", 1))
	novice_skills[skill_index] = skill
	return "%s技能書（角色綁定）" % skill["name"]


func _resolve_background_battle_tick() -> void:
	if GameState.battle_view_active or GameState.selected_character_slot < 0:
		return
	var monster := _roll_region_monster()
	var coins := int(round(randi_range(14, 24) * float(monster.get("coin_mult", 1.0))))
	inventory_coins += coins
	battle_kill_count += 1
	_advance_rotating_tasks("kill")
	_advance_repeat_tasks("kill", maxi(player_level - 2, 1), "")
	region_progress += 1
	_try_complete_first_region()
	var gained_exp := randi_range(4, 7)
	_grant_player_exp(gained_exp)
	background_kills_since_view += 1
	background_exp_since_view += gained_exp
	background_coins_since_view += coins
	var gained_pages := 1
	if randf() < float(monster.get("page_chance", 0.10)):
		gained_pages += 1
	inventory_pages += gained_pages
	background_pages_since_view += gained_pages
	if randf() < SKILL_BOOK_DROP_CHANCE:
		_grant_random_bound_skill_book()
	var equipment_drop := _try_region_equipment_drop(str(monster.get("name", "")), false)
	if not equipment_drop.is_empty():
		inventory_equipment.append(equipment_drop)
		background_items_since_view += 1
	_try_drop_region_card(str(monster.get("name", "")), false)
	_save_persistent_progress()


func _show_character_select() -> void:
	GameState.set_battle_view_active(false)
	for child in get_children():
		child.queue_free()
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color("171816")
	add_child(background)
	var paper := Panel.new()
	paper.position = Vector2(18, 28)
	paper.size = Vector2(504, 904)
	paper.add_theme_stylebox_override("panel", _box(PAPER, Color("49382a"), 3, 14))
	add_child(paper)
	_add_label("陰司名冊", Rect2(38, 54, 240, 42), 28, RED)
	_add_label("選擇引渡人", Rect2(280, 64, 212, 28), 15, GREEN, HORIZONTAL_ALIGNMENT_RIGHT)
	var line := ColorRect.new()
	line.position = Vector2(38, 108)
	line.size = Vector2(464, 3)
	line.color = RED
	add_child(line)
	_add_label("每名角色擁有獨立任務、卡片、裝備與序章進度。", Rect2(44, 124, 452, 34), 13, GREEN, HORIZONTAL_ALIGNMENT_CENTER)
	for i in range(3):
		var entry: Dictionary = GameState.character_slots[i]
		var occupied := bool(entry.get("occupied", false))
		var card := Panel.new()
		card.position = Vector2(38, 178 + i * 205)
		card.size = Vector2(464, 174)
		card.add_theme_stylebox_override("panel", _box(Color("bba873"), RED if occupied else COPPER, 2, 10))
		add_child(card)
		_add_label("名冊 %d" % (i + 1), Rect2(56, 190 + i * 205, 110, 26), 14, GREEN)
		if occupied:
			_add_label(str(entry.get("name", "引渡人")), Rect2(56, 222 + i * 205, 250, 38), 22, RED)
			_add_label("職業　引渡人", Rect2(56, 264 + i * 205, 210, 28), 14, INK)
			var enter := Button.new()
			enter.position = Vector2(304, 214 + i * 205)
			enter.size = Vector2(174, 54)
			enter.text = "進入遊戲"
			enter.add_theme_color_override("font_color", PAPER)
			enter.add_theme_stylebox_override("normal", _box(GREEN, Color("22342b"), 2, 8))
			enter.pressed.connect(_enter_character_slot.bind(i))
			add_child(enter)
			var delete := Button.new()
			delete.position = Vector2(304, 282 + i * 205)
			delete.size = Vector2(174, 42)
			delete.text = "刪除角色"
			delete.add_theme_stylebox_override("normal", _box(Color("c5b17f"), RED, 2, 8))
			delete.pressed.connect(_request_delete_character.bind(i))
			add_child(delete)
		else:
			_add_label("尚未登記", Rect2(56, 230 + i * 205, 220, 34), 19, Color("665b50"))
			var create := Button.new()
			create.position = Vector2(304, 232 + i * 205)
			create.size = Vector2(174, 58)
			create.text = "建立角色"
			create.add_theme_color_override("font_color", PAPER)
			create.add_theme_stylebox_override("normal", _box(RED, Color("3a1815"), 2, 8))
			create.pressed.connect(_request_create_character.bind(i))
			add_child(create)
	_add_label("新角色會從住宅大樓的地基主序章開始。", Rect2(52, 824, 436, 38), 14, GREEN, HORIZONTAL_ALIGNMENT_CENTER)


func _add_quick_menu(force_open: bool = false, highlight_inventory: bool = false) -> void:
	var toggle := Button.new()
	toggle.position = Vector2(464, 18)
	toggle.size = Vector2(58, 54)
	toggle.text = "☰"
	toggle.z_index = 70
	toggle.add_theme_font_size_override("font_size", 25)
	toggle.add_theme_color_override("font_color", PAPER)
	toggle.add_theme_stylebox_override("normal", _box(Color("332a2a"), Color("b69a61"), 3, 12))
	add_child(toggle)
	var menu := Panel.new()
	menu.position = Vector2(342, 78)
	menu.size = Vector2(180, 426)
	menu.z_index = 69
	menu.visible = force_open
	menu.add_theme_stylebox_override("panel", _box(Color("2b2524e8"), Color("b69a61"), 3, 12))
	add_child(menu)
	toggle.pressed.connect(_toggle_quick_menu.bind(menu))
	var entries := [
		{"label": "▣\n行囊", "enabled": starter_equipment_tutorial_active or prologue_completed, "action": Callable(self, "_show_inventory")},
		{"label": "▤\n圖鑑", "enabled": int(card_counts.get("地基主", 0)) > 0, "action": Callable(self, "_return_to_collection")},
		{"label": "◇\n伴生靈", "enabled": prologue_completed, "action": Callable(self, "_show_companion")},
		{"label": "卷\n差事", "enabled": false, "action": Callable()},
		{"label": "符\n技能", "enabled": false, "action": Callable()},
		{"label": "城\n主城", "enabled": false, "action": Callable()},
		{"label": "⚙\n戰鬥設定", "enabled": prologue_completed, "action": Callable(self, "_show_battle_settings")}
	]
	for i in entries.size():
		var entry: Dictionary = entries[i]
		var button := Button.new()
		button.position = Vector2(10 + (i % 2) * 82, 12 + (i / 2) * 100)
		button.size = Vector2(76, 88)
		button.text = str(entry["label"])
		button.disabled = not bool(entry["enabled"])
		button.add_theme_font_size_override("font_size", 14)
		button.add_theme_color_override("font_color", PAPER)
		button.add_theme_color_override("font_disabled_color", Color("756d67"))
		button.add_theme_stylebox_override("normal", _box(Color("493733"), RED if highlight_inventory and i == 0 else Color("907653"), 2, 9))
		button.add_theme_stylebox_override("disabled", _box(Color("353130"), Color("55504c"), 2, 9))
		if bool(entry["enabled"]):
			button.pressed.connect(entry["action"])
		menu.add_child(button)


func _toggle_quick_menu(menu: Panel) -> void:
	if is_instance_valid(menu):
		menu.visible = not menu.visible


func _starter_equipment_complete() -> bool:
	for starter_name in ["舊短刀", "粗布衣", "香灰護符"]:
		var equipped := false
		for item in inventory_equipment:
			if str(item.get("name", "")) == starter_name and bool(item.get("equipped", false)):
				equipped = true
				break
		if not equipped:
			return false
	return true


func _request_create_character(slot_index: int) -> void:
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color("171713c7")
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	shade.z_index = 40
	add_child(shade)
	var panel := Panel.new()
	panel.position = Vector2(48, 254)
	panel.size = Vector2(444, 410)
	panel.z_index = 41
	panel.add_theme_stylebox_override("panel", _box(PAPER, RED, 4, 14))
	add_child(panel)
	_add_event_label(panel, "建立引渡人", Rect2(24, 22, 396, 42), 24, RED, HORIZONTAL_ALIGNMENT_CENTER)
	_add_event_label(panel, "初始職業固定為引渡人，Lv.10 後才能轉職。", Rect2(30, 74, 384, 50), 13, GREEN, HORIZONTAL_ALIGNMENT_CENTER)
	var name_input := LineEdit.new()
	name_input.position = Vector2(42, 142)
	name_input.size = Vector2(360, 56)
	name_input.placeholder_text = "輸入角色名稱（1～10字）"
	name_input.max_length = 10
	name_input.add_theme_font_size_override("font_size", 17)
	panel.add_child(name_input)
	var error_label := Label.new()
	error_label.position = Vector2(42, 204)
	error_label.size = Vector2(360, 34)
	error_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	error_label.add_theme_color_override("font_color", RED)
	panel.add_child(error_label)
	var cancel := Button.new()
	cancel.position = Vector2(30, 310)
	cancel.size = Vector2(176, 54)
	cancel.text = "取消"
	cancel.add_theme_stylebox_override("normal", _box(Color("c5b17f"), COPPER, 2, 8))
	cancel.pressed.connect(_dismiss_character_modal.bind(shade, panel))
	panel.add_child(cancel)
	var confirm := Button.new()
	confirm.position = Vector2(218, 310)
	confirm.size = Vector2(196, 54)
	confirm.text = "建立並進入"
	confirm.add_theme_color_override("font_color", PAPER)
	confirm.add_theme_stylebox_override("normal", _box(RED, Color("3a1815"), 3, 8))
	confirm.pressed.connect(_confirm_create_character.bind(slot_index, name_input, error_label))
	panel.add_child(confirm)
	name_input.grab_focus()


func _confirm_create_character(slot_index: int, name_input: LineEdit, error_label: Label) -> void:
	var clean_name := name_input.text.strip_edges()
	if clean_name == "":
		error_label.text = "請輸入角色名稱"
		return
	if not GameState.create_character(slot_index, clean_name):
		error_label.text = "無法建立角色，請確認名稱與欄位"
		return
	get_tree().reload_current_scene()


func _enter_character_slot(slot_index: int) -> void:
	if GameState.select_character(slot_index):
		get_tree().reload_current_scene()


func _request_delete_character(slot_index: int) -> void:
	var entry: Dictionary = GameState.character_slots[slot_index]
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color("171713c7")
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	shade.z_index = 40
	add_child(shade)
	var panel := Panel.new()
	panel.position = Vector2(48, 274)
	panel.size = Vector2(444, 360)
	panel.z_index = 41
	panel.add_theme_stylebox_override("panel", _box(PAPER, RED, 4, 14))
	add_child(panel)
	_add_event_label(panel, "確認刪除角色", Rect2(24, 22, 396, 42), 24, RED, HORIZONTAL_ALIGNMENT_CENTER)
	_add_event_label(panel, "「%s」的任務、卡片與裝備存檔將全部刪除。" % str(entry.get("name", "角色")), Rect2(34, 86, 376, 70), 15, INK, HORIZONTAL_ALIGNMENT_CENTER)
	_add_event_label(panel, "刪除後無法復原。", Rect2(34, 170, 376, 36), 15, RED, HORIZONTAL_ALIGNMENT_CENTER)
	var cancel := Button.new()
	cancel.position = Vector2(30, 268)
	cancel.size = Vector2(176, 54)
	cancel.text = "保留角色"
	cancel.add_theme_stylebox_override("normal", _box(Color("c5b17f"), COPPER, 2, 8))
	cancel.pressed.connect(_dismiss_character_modal.bind(shade, panel))
	panel.add_child(cancel)
	var confirm := Button.new()
	confirm.position = Vector2(218, 268)
	confirm.size = Vector2(196, 54)
	confirm.text = "確認刪除"
	confirm.add_theme_color_override("font_color", PAPER)
	confirm.add_theme_stylebox_override("normal", _box(RED, Color("3a1815"), 3, 8))
	confirm.pressed.connect(_confirm_delete_character.bind(slot_index, shade, panel))
	panel.add_child(confirm)


func _confirm_delete_character(slot_index: int, shade: ColorRect, panel: Panel) -> void:
	GameState.delete_character(slot_index)
	_dismiss_character_modal(shade, panel)
	_show_character_select()


func _dismiss_character_modal(shade: ColorRect, panel: Panel) -> void:
	if is_instance_valid(shade):
		shade.queue_free()
	if is_instance_valid(panel):
		panel.queue_free()


func _return_to_character_select() -> void:
	_save_persistent_progress()
	_show_character_select()


func _show_prologue_intro() -> void:
	GameState.set_battle_view_active(true)
	for child in get_children():
		child.queue_free()
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color("171816")
	add_child(background)
	var paper := Panel.new()
	paper.position = Vector2(18, 28)
	paper.size = Vector2(504, 904)
	paper.add_theme_stylebox_override("panel", _box(PAPER, Color("49382a"), 3, 14))
	add_child(paper)
	_add_label("序章・翠光入宅", Rect2(38, 54, 330, 42), 27, RED)
	_add_label("自家住宅大樓　深夜", Rect2(330, 62, 164, 28), 13, GREEN, HORIZONTAL_ALIGNMENT_RIGHT)
	var window_glow := Panel.new()
	window_glow.position = Vector2(48, 126)
	window_glow.size = Vector2(444, 260)
	window_glow.add_theme_stylebox_override("panel", _box(Color("243d31"), Color("89b477"), 3, 10))
	add_child(window_glow)
	_add_event_label(window_glow, "窗外沒有雷聲。\n整座城市卻被一道沒有溫度的翠綠異光照亮。", Rect2(28, 24, 388, 70), 17, Color("d8d2a8"), HORIZONTAL_ALIGNMENT_CENTER)
	var door := Panel.new()
	door.position = Vector2(156, 112)
	door.size = Vector2(132, 122)
	door.add_theme_stylebox_override("panel", _box(Color("514238"), Color("241d19"), 3, 8))
	window_glow.add_child(door)
	_add_event_label(window_glow, "廚房方向傳來碗筷輕碰聲……", Rect2(28, 218, 388, 30), 14, Color("d8c887"), HORIZONTAL_ALIGNMENT_CENTER)
	var intro_story := _make_label("你原本只是普通上班族。\n異光穿過牆壁後，掌心浮出陌生的引渡符紋。\n灶下守宅的氣息也變得混亂，像是已經認不出這間屋子的主人。", Rect2(52, 426, 436, 150), 16, INK, HORIZONTAL_ALIGNMENT_CENTER)
	intro_story.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var warning := Panel.new()
	warning.position = Vector2(48, 610)
	warning.size = Vector2(444, 108)
	warning.add_theme_stylebox_override("panel", _box(Color("baa673"), RED, 2, 9))
	add_child(warning)
	_add_event_label(warning, "新手任務\n前往灶下，安定受到翠光擾動的地基主。", Rect2(22, 14, 400, 78), 16, RED, HORIZONTAL_ALIGNMENT_CENTER)
	var investigate := Button.new()
	investigate.position = Vector2(92, 770)
	investigate.size = Vector2(356, 64)
	investigate.text = "查看灶下異動"
	investigate.add_theme_font_size_override("font_size", 18)
	investigate.add_theme_color_override("font_color", PAPER)
	investigate.add_theme_stylebox_override("normal", _box(RED, Color("3a1815"), 3, 10))
	investigate.pressed.connect(_show_first_dijizhu_defeat)
	add_child(investigate)
	_add_label("這場戰鬥的目的是淨化，不是消滅神靈。", Rect2(60, 852, 420, 30), 13, GREEN, HORIZONTAL_ALIGNMENT_CENTER)
	_reveal_story_text([intro_story], investigate)


func _show_first_dijizhu_defeat() -> void:
	for child in get_children():
		child.queue_free()
	GameState.set_battle_view_active(true)
	tutorial_player_hp = 36
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color("171816")
	add_child(background)
	var paper := Panel.new()
	paper.position = Vector2(18, 28)
	paper.size = Vector2(504, 904)
	paper.add_theme_stylebox_override("panel", _box(PAPER, Color("49382a"), 3, 14))
	add_child(paper)
	_add_label("灶下異動・無力抵抗", Rect2(38, 54, 360, 40), 25, RED)
	_add_label("尚未受職", Rect2(342, 62, 150, 25), 13, GREEN, HORIZONTAL_ALIGNMENT_RIGHT)
	var room := Panel.new()
	room.position = Vector2(42, 122)
	room.size = Vector2(456, 398)
	room.add_theme_stylebox_override("panel", _box(Color("26392f"), COPPER, 3, 12))
	add_child(room)
	_add_event_label(room, "翠光扭曲灶火，熟悉的守宅氣息變得陌生。", Rect2(24, 16, 408, 34), 14, Color("d8d2a8"), HORIZONTAL_ALIGNMENT_CENTER)
	var player := Panel.new()
	player.position = Vector2(76, 296)
	player.size = Vector2(84, 104)
	player.add_theme_stylebox_override("panel", _box(Color("66544a"), Color("171713"), 3, 38))
	add_child(player)
	_add_label("普通人", Rect2(58, 408, 120, 28), 15, Color("e1d6ae"), HORIZONTAL_ALIGNMENT_CENTER)
	var spirit := Panel.new()
	spirit.position = Vector2(342, 194)
	spirit.size = Vector2(126, 154)
	spirit.add_theme_stylebox_override("panel", _box(Color("41664d"), Color("a7bd8a"), 3, 52))
	add_child(spirit)
	_add_label("異變地基主", Rect2(324, 356, 162, 30), 16, Color("e0cc8c"), HORIZONTAL_ALIGNMENT_CENTER)
	var hp_back := ColorRect.new()
	hp_back.position = Vector2(58, 278)
	hp_back.size = Vector2(120, 9)
	hp_back.color = Color("2a211d")
	add_child(hp_back)
	tutorial_player_hp_bar = ColorRect.new()
	tutorial_player_hp_bar.position = Vector2(58, 278)
	tutorial_player_hp_bar.size = Vector2(120, 9)
	tutorial_player_hp_bar.color = Color("b43b31")
	add_child(tutorial_player_hp_bar)
	_add_battle_lane(Vector2(148, 330), Vector2(374, 270), 0.8)
	var log_panel := Panel.new()
	log_panel.position = Vector2(42, 548)
	log_panel.size = Vector2(456, 170)
	log_panel.add_theme_stylebox_override("panel", _box(Color("b9a36f"), RED, 2, 9))
	add_child(log_panel)
	tutorial_battle_log = _make_label("你還沒有引渡令，也不懂得使用淨符。\n這場戰鬥無法獲勝。", Rect2(64, 578, 412, 104), 15, INK, HORIZONTAL_ALIGNMENT_CENTER)
	var resist := Button.new()
	resist.position = Vector2(92, 766)
	resist.size = Vector2(356, 64)
	resist.text = "勉強抵抗"
	resist.add_theme_font_size_override("font_size", 18)
	resist.add_theme_color_override("font_color", PAPER)
	resist.add_theme_stylebox_override("normal", _box(RED, Color("3a1815"), 3, 10))
	resist.pressed.connect(_start_forced_defeat.bind(resist))
	add_child(resist)
	_add_label("劇情戰敗不會損失物品、經驗或挑戰次數。", Rect2(60, 852, 420, 32), 13, GREEN, HORIZONTAL_ALIGNMENT_CENTER)
	_reveal_story_text([tutorial_battle_log], resist)
	tutorial_attack_timer = Timer.new()
	tutorial_attack_timer.wait_time = 0.7
	tutorial_attack_timer.timeout.connect(_tutorial_forced_defeat_tick)
	add_child(tutorial_attack_timer)


func _start_forced_defeat(resist_button: Button) -> void:
	resist_button.disabled = true
	resist_button.text = "無法抵擋……"
	tutorial_battle_log.text = "異變靈壓逼近\n你手中的臨時符紙沒有任何反應。"
	tutorial_attack_timer.start()


func _tutorial_forced_defeat_tick() -> void:
	if tutorial_player_hp <= 0:
		return
	var damage := randi_range(9, 14)
	tutorial_player_hp = maxi(tutorial_player_hp - damage, 0)
	if is_instance_valid(tutorial_player_hp_bar):
		tutorial_player_hp_bar.size.x = 120.0 * float(tutorial_player_hp) / 36.0
	if is_instance_valid(tutorial_battle_log):
		tutorial_battle_log.text = "異變地基主造成 %d 點靈壓傷害\n生命 %d／36" % [damage, tutorial_player_hp]
	if tutorial_player_hp == 0:
		tutorial_attack_timer.stop()
		call_deferred("_show_soul_arrest_story")


func _show_story_transition(title_text: String, location_text: String, story_text: String, task_text: String, button_text: String, next_action: Callable) -> void:
	for child in get_children():
		child.queue_free()
	GameState.set_battle_view_active(true)
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color("171816")
	add_child(background)
	var paper := Panel.new()
	paper.position = Vector2(18, 28)
	paper.size = Vector2(504, 904)
	paper.add_theme_stylebox_override("panel", _box(PAPER, Color("49382a"), 3, 14))
	add_child(paper)
	_add_label(title_text, Rect2(38, 54, 350, 42), 26, RED)
	_add_label(location_text, Rect2(334, 64, 158, 26), 13, GREEN, HORIZONTAL_ALIGNMENT_RIGHT)
	var scene_panel := Panel.new()
	scene_panel.position = Vector2(42, 128)
	scene_panel.size = Vector2(456, 330)
	scene_panel.add_theme_stylebox_override("panel", _box(Color("28382f"), COPPER, 3, 12))
	add_child(scene_panel)
	var story_label := _add_event_label(scene_panel, story_text, Rect2(30, 34, 396, 262), 17, Color("ded4ad"), HORIZONTAL_ALIGNMENT_CENTER)
	var task_panel := Panel.new()
	task_panel.position = Vector2(42, 500)
	task_panel.size = Vector2(456, 166)
	task_panel.add_theme_stylebox_override("panel", _box(Color("b9a36f"), RED, 2, 9))
	add_child(task_panel)
	var task_label := _add_event_label(task_panel, task_text, Rect2(28, 24, 400, 118), 15, INK, HORIZONTAL_ALIGNMENT_CENTER)
	var next := Button.new()
	next.position = Vector2(92, 742)
	next.size = Vector2(356, 64)
	next.text = button_text
	next.add_theme_font_size_override("font_size", 18)
	next.add_theme_color_override("font_color", PAPER)
	next.add_theme_stylebox_override("normal", _box(RED, Color("3a1815"), 3, 10))
	next.pressed.connect(next_action)
	add_child(next)
	_reveal_story_text([story_label, task_label], next)


func _show_soul_arrest_story() -> void:
	_show_story_transition("生魂離體", "住宅・灶下", "視線沉入黑暗後，你看見自己的身體倒在廚房門口。\n\n兩道高瘦身影穿牆而入，鎖鏈準確纏住尚未斷氣的生魂。", "陰差：名冊記著陽壽未盡，卻已有枉死氣。\n先隨我們到城中查驗。", "隨陰差前往枉死城", _show_wrongful_death_registration)


func _show_wrongful_death_registration() -> void:
	_show_story_transition("陰司名冊登記", "枉死城・報到司", "城門後沒有日月，只有排不到盡頭的亡魂。\n\n判吏翻遍名冊，確認你的死亡不在原定命數之中。", "查驗結果：陽壽未盡。\n死因：翠光異變造成的異常離魂。", "完成登記，拜見行政長官", _show_underworld_appointment)


func _show_underworld_appointment() -> void:
	_show_story_transition("陰司臨時受職", "酆都城・行政殿", "陽間各地同時出現大量異變，陰差已無力處理所有生魂與怨靈。\n\n你仍與肉身相連，反而成為少數能往返陰陽的人。", "受職：引渡人\n職責：調查翠光、安定異變神怪、引渡無主亡魂。", "領取引渡令", _show_starter_equipment_lesson)


func _show_starter_equipment_lesson() -> void:
	starter_equipment_tutorial_active = true
	for i in inventory_equipment.size():
		if str(inventory_equipment[i].get("name", "")) in ["舊短刀", "粗布衣", "香灰護符"]:
			inventory_equipment[i]["equipped"] = false
	_show_story_transition("領取新手裝備", "酆都城・受領處", "引渡令刻下你的名字，一套供新任引渡人使用的器物也交到手中。\n\n取得舊短刀、粗布衣與香灰護符，三件器物已放入行囊。", "裝備教學：每個部位同時只能裝備一件器物。\n請親自前往行囊，依序裝備武器、防具與護符。", "開啟行囊", _show_starter_equipment_tutorial)
	_save_persistent_progress()


func _show_starter_equipment_tutorial() -> void:
	for child in get_children():
		child.queue_free()
	GameState.set_battle_view_active(true)
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color("171816")
	add_child(background)
	var paper := Panel.new()
	paper.position = Vector2(18, 28)
	paper.size = Vector2(504, 904)
	paper.add_theme_stylebox_override("panel", _box(PAPER, Color("49382a"), 3, 14))
	add_child(paper)
	_add_label("行囊・裝備教學", Rect2(38, 54, 330, 42), 26, RED)
	_add_label("親手裝備三個部位", Rect2(310, 64, 182, 26), 13, GREEN, HORIZONTAL_ALIGNMENT_RIGHT)
	_add_quick_menu(true, true)
	var starter_names := ["舊短刀", "粗布衣", "香灰護符"]
	var all_equipped := true
	for row in range(starter_names.size()):
		var item_index := -1
		for i in inventory_equipment.size():
			if str(inventory_equipment[i].get("name", "")) == starter_names[row]:
				item_index = i
				break
		if item_index < 0:
			continue
		var item: Dictionary = inventory_equipment[item_index]
		var equipped := bool(item.get("equipped", false))
		all_equipped = all_equipped and equipped
		var card := Panel.new()
		card.position = Vector2(42, 144 + row * 174)
		card.size = Vector2(456, 146)
		card.add_theme_stylebox_override("panel", _box(Color("b9a36f") if equipped else Color("8a8478"), GREEN if equipped else Color("5d625e"), 3, 9))
		add_child(card)
		if equipped:
			_add_label(str(item.get("name", "器物")), Rect2(62, 160 + row * 174, 220, 32), 19, RED)
			_add_label("%s　｜　%s" % [str(item.get("slot", "")), str(item.get("affix", ""))], Rect2(62, 202 + row * 174, 260, 28), 14, INK)
			_add_label("已裝備至%s欄位" % str(item.get("slot", "")), Rect2(62, 238 + row * 174, 270, 24), 12, GREEN)
			var equipped_badge := Button.new()
			equipped_badge.position = Vector2(350, 184 + row * 174)
			equipped_badge.size = Vector2(124, 56)
			equipped_badge.text = "✓ 已裝備"
			equipped_badge.disabled = true
			equipped_badge.add_theme_color_override("font_disabled_color", PAPER)
			equipped_badge.add_theme_stylebox_override("disabled", _box(GREEN, Color("22342b"), 2, 8))
			add_child(equipped_badge)
		else:
			_add_label("＋", Rect2(62, 172 + row * 174, 396, 54), 34, Color("66645f"), HORIZONTAL_ALIGNMENT_CENTER)
	var continue_button := Button.new()
	continue_button.position = Vector2(92, 726)
	continue_button.size = Vector2(356, 64)
	continue_button.text = "請點擊行囊穿著裝備" if not all_equipped else "裝備完成・返回住宅"
	continue_button.disabled = not all_equipped
	continue_button.add_theme_font_size_override("font_size", 17)
	continue_button.add_theme_color_override("font_color", PAPER)
	continue_button.add_theme_color_override("font_disabled_color", Color("817665"))
	continue_button.add_theme_stylebox_override("normal", _box(RED, Color("3a1815"), 3, 10))
	continue_button.pressed.connect(_return_home_for_dijizhu_purification)
	add_child(continue_button)
	_add_label("完成後，裝備能力會直接套用到接下來的淨化戰。", Rect2(60, 822, 420, 36), 13, GREEN, HORIZONTAL_ALIGNMENT_CENTER)


func _equip_starter_tutorial_item(item_index: int) -> void:
	if item_index < 0 or item_index >= inventory_equipment.size():
		return
	var slot_name := str(inventory_equipment[item_index].get("slot", ""))
	for i in inventory_equipment.size():
		if str(inventory_equipment[i].get("slot", "")) == slot_name:
			inventory_equipment[i]["equipped"] = false
	inventory_equipment[item_index]["equipped"] = true
	_save_persistent_progress()
	_show_starter_equipment_tutorial()


func _return_home_for_dijizhu_purification() -> void:
	starter_equipment_tutorial_active = false
	_show_dijizhu_tutorial_battle()


func _show_dijizhu_tutorial_battle() -> void:
	for child in get_children():
		child.queue_free()
	GameState.set_battle_view_active(true)
	tutorial_dijizhu_hp = 60
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color("171816")
	add_child(background)
	var paper := Panel.new()
	paper.position = Vector2(18, 28)
	paper.size = Vector2(504, 904)
	paper.add_theme_stylebox_override("panel", _box(PAPER, Color("49382a"), 3, 14))
	add_child(paper)
	_add_label("重返灶下・淨化教學", Rect2(38, 54, 360, 40), 25, RED)
	_add_label("目標：安定地基主", Rect2(312, 62, 180, 25), 13, GREEN, HORIZONTAL_ALIGNMENT_RIGHT)
	var room := Panel.new()
	room.position = Vector2(42, 122)
	room.size = Vector2(456, 398)
	room.add_theme_stylebox_override("panel", _box(Color("26392f"), COPPER, 3, 12))
	add_child(room)
	_add_event_label(room, "翠光從牆縫滲入，灶火忽明忽滅。", Rect2(24, 16, 408, 30), 14, Color("d8d2a8"), HORIZONTAL_ALIGNMENT_CENTER)
	var player := Panel.new()
	player.position = Vector2(76, 296)
	player.size = Vector2(92, 112)
	player.add_theme_stylebox_override("panel", _box(RED, Color("171713"), 3, 42))
	add_child(player)
	_add_label("引渡人", Rect2(58, 414, 128, 28), 15, Color("e1d6ae"), HORIZONTAL_ALIGNMENT_CENTER)
	var spirit := Panel.new()
	spirit.position = Vector2(350, 202)
	spirit.size = Vector2(112, 138)
	spirit.add_theme_stylebox_override("panel", _box(Color("4b6654"), Color("a7bd8a"), 3, 48))
	add_child(spirit)
	_add_label("受擾動的地基主", Rect2(320, 350, 172, 30), 15, Color("e0cc8c"), HORIZONTAL_ALIGNMENT_CENTER)
	var hp_back := ColorRect.new()
	hp_back.position = Vector2(338, 184)
	hp_back.size = Vector2(136, 9)
	hp_back.color = Color("2a211d")
	add_child(hp_back)
	tutorial_dijizhu_hp_bar = ColorRect.new()
	tutorial_dijizhu_hp_bar.position = Vector2(338, 184)
	tutorial_dijizhu_hp_bar.size = Vector2(136, 9)
	tutorial_dijizhu_hp_bar.color = Color("83a875")
	add_child(tutorial_dijizhu_hp_bar)
	_add_battle_lane(Vector2(158, 332), Vector2(382, 270), 0.8)
	var log_panel := Panel.new()
	log_panel.position = Vector2(42, 548)
	log_panel.size = Vector2(456, 170)
	log_panel.add_theme_stylebox_override("panel", _box(Color("b9a36f"), RED, 2, 9))
	add_child(log_panel)
	tutorial_battle_log = _make_label("引渡令讓你重新回到肉身。\n現在可使用陰司淨符，安定受到翠光刺激的地基主。", Rect2(64, 578, 412, 104), 15, INK, HORIZONTAL_ALIGNMENT_CENTER)
	var start := Button.new()
	start.position = Vector2(92, 766)
	start.size = Vector2(356, 64)
	start.text = "開始自動淨化"
	start.add_theme_font_size_override("font_size", 18)
	start.add_theme_color_override("font_color", PAPER)
	start.add_theme_stylebox_override("normal", _box(RED, Color("3a1815"), 3, 10))
	start.pressed.connect(_start_dijizhu_tutorial.bind(start))
	add_child(start)
	_add_label("淨化攻擊會自行持續，正式巡行也採即時自動戰鬥。", Rect2(56, 852, 428, 38), 13, GREEN, HORIZONTAL_ALIGNMENT_CENTER)
	_reveal_story_text([tutorial_battle_log], start)
	tutorial_attack_timer = Timer.new()
	tutorial_attack_timer.wait_time = 0.75
	tutorial_attack_timer.timeout.connect(_tutorial_dijizhu_battle_tick)
	add_child(tutorial_attack_timer)


func _start_dijizhu_tutorial(start_button: Button) -> void:
	start_button.disabled = true
	start_button.text = "淨化進行中……"
	tutorial_battle_log.text = "引渡符燃起微光\n正在安定地基主的靈息……"
	tutorial_attack_timer.start()


func _tutorial_dijizhu_battle_tick() -> void:
	if tutorial_dijizhu_hp <= 0:
		return
	var damage := randi_range(9, 13)
	tutorial_dijizhu_hp = maxi(tutorial_dijizhu_hp - damage, 0)
	if is_instance_valid(tutorial_dijizhu_hp_bar):
		tutorial_dijizhu_hp_bar.size.x = 136.0 * float(tutorial_dijizhu_hp) / 60.0
	if is_instance_valid(tutorial_battle_log):
		tutorial_battle_log.text = "淨符安定 %d 點擾動\n地基主靈息 %d／60" % [damage, tutorial_dijizhu_hp]
	if tutorial_dijizhu_hp == 0:
		tutorial_attack_timer.stop()
		call_deferred("_show_dijizhu_purified")


func _show_dijizhu_purified() -> void:
	for child in get_children():
		child.queue_free()
	GameState.set_battle_view_active(true)
	card_counts["地基主"] = maxi(int(card_counts.get("地基主", 0)), 1)
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color("171816")
	add_child(background)
	var paper := Panel.new()
	paper.position = Vector2(18, 28)
	paper.size = Vector2(504, 904)
	paper.add_theme_stylebox_override("panel", _box(PAPER, Color("49382a"), 3, 14))
	add_child(paper)
	_add_label("淨化完成・灶下守契", Rect2(38, 54, 430, 42), 26, RED, HORIZONTAL_ALIGNMENT_CENTER)
	var art := TextureRect.new()
	art.position = Vector2(142, 132)
	art.size = Vector2(256, 382)
	art.texture = load("res://assets/cards/dijizhu-card-v1.png")
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	add_child(art)
	_add_label("取得卡片「地基主」×1", Rect2(70, 542, 400, 38), 22, RED, HORIZONTAL_ALIGNMENT_CENTER)
	var contract_story := _make_label("祂恢復神智後認出屋主，願意締結守契。\n建立守契後，地基主將成為第一隻伴生靈。", Rect2(64, 598, 412, 90), 16, INK, HORIZONTAL_ALIGNMENT_CENTER)
	contract_story.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var contract := Button.new()
	contract.position = Vector2(92, 742)
	contract.size = Vector2(356, 64)
	contract.text = "建立守契"
	contract.add_theme_font_size_override("font_size", 18)
	contract.add_theme_color_override("font_color", PAPER)
	contract.add_theme_stylebox_override("normal", _box(RED, Color("3a1815"), 3, 10))
	contract.pressed.connect(_show_collection_summon_tutorial)
	add_child(contract)
	_add_label("下一步將進入伴生靈召喚與成長教學。", Rect2(60, 840, 420, 32), 13, GREEN, HORIZONTAL_ALIGNMENT_CENTER)
	_reveal_story_text([contract_story], contract)
	_save_persistent_progress()


func _show_collection_summon_tutorial() -> void:
	for child in get_children():
		child.queue_free()
	GameState.set_battle_view_active(true)
	_build_screen()
	var hint := Panel.new()
	hint.position = Vector2(40, 164)
	hint.size = Vector2(344, 44)
	hint.z_index = 15
	hint.add_theme_stylebox_override("panel", _box(Color("b9a36f"), RED, 2, 8))
	add_child(hint)
	_add_event_label(hint, "↓ 點選地基主卡片，進入伴生靈頁面", Rect2(10, 4, 324, 36), 13, RED, HORIZONTAL_ALIGNMENT_CENTER)


func _summon_dijizhu_from_companion_page() -> void:
	_complete_prologue_contract()


func _show_manual_summon_lesson() -> void:
	for child in get_children():
		child.queue_free()
	GameState.set_battle_view_active(true)
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color("171816")
	add_child(background)
	var paper := Panel.new()
	paper.position = Vector2(18, 28)
	paper.size = Vector2(504, 904)
	paper.add_theme_stylebox_override("panel", _box(PAPER, Color("49382a"), 3, 14))
	add_child(paper)
	_add_label("守契成立・召喚教學", Rect2(38, 54, 390, 42), 26, RED)
	var art := TextureRect.new()
	art.position = Vector2(54, 140)
	art.size = Vector2(210, 314)
	art.texture = load("res://assets/cards/dijizhu-card-v1.png")
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	add_child(art)
	var summon_area := Panel.new()
	summon_area.position = Vector2(292, 160)
	summon_area.size = Vector2(190, 274)
	summon_area.add_theme_stylebox_override("panel", _box(Color("304339"), COPPER, 2, 70))
	add_child(summon_area)
	var summon_status := _make_label("尚未召喚", Rect2(300, 448, 174, 30), 16, GREEN, HORIZONTAL_ALIGNMENT_CENTER)
	var lesson := _make_label("守契只代表取得召喚資格。\n伴生靈不會自行出現，請由玩家親手召喚。\n同一時間只能召喚一隻伴生靈。", Rect2(58, 506, 424, 112), 16, INK, HORIZONTAL_ALIGNMENT_CENTER)
	lesson.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var summon := Button.new()
	summon.position = Vector2(92, 660)
	summon.size = Vector2(356, 64)
	summon.text = "召喚地基主"
	summon.add_theme_font_size_override("font_size", 18)
	summon.add_theme_color_override("font_color", PAPER)
	summon.add_theme_stylebox_override("normal", _box(RED, Color("3a1815"), 3, 10))
	add_child(summon)
	var finish := Button.new()
	finish.position = Vector2(92, 758)
	finish.size = Vector2(356, 60)
	finish.text = "完成召喚教學"
	finish.visible = false
	finish.add_theme_font_size_override("font_size", 17)
	finish.add_theme_color_override("font_color", PAPER)
	finish.add_theme_stylebox_override("normal", _box(GREEN, Color("22342b"), 3, 10))
	finish.pressed.connect(_complete_prologue_contract)
	add_child(finish)
	summon.pressed.connect(_manual_summon_dijizhu.bind(summon, summon_status, summon_area, finish))
	_reveal_story_text([lesson], summon)


func _manual_summon_dijizhu(summon_button: Button, summon_status: Label, summon_area: Panel, finish_button: Button) -> void:
	summon_button.disabled = true
	summon_button.text = "✓ 地基主召喚中"
	summon_status.text = "召喚成功"
	summon_status.add_theme_color_override("font_color", RED)
	var spirit := _add_companion_spirit(summon_area.position + Vector2(44, 34), CURRENT_COMPANION_AWAKENING)
	spirit.modulate.a = 0.0
	var appear := create_tween()
	appear.tween_property(spirit, "modulate:a", 0.55, 0.8)
	appear.finished.connect(_show_story_action.bind(finish_button))


func _complete_prologue_contract() -> void:
	prologue_completed = true
	_save_persistent_progress()
	GameState.set_battle_view_active(false)
	_show_companion()
	_show_tutorial_complete_dialog()


func _show_tutorial_complete_dialog() -> void:
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.04, 0.04, 0.035, 0.68)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	shade.z_index = 79
	add_child(shade)
	var dialog := Panel.new()
	dialog.position = Vector2(54, 286)
	dialog.size = Vector2(432, 320)
	dialog.z_index = 80
	dialog.add_theme_stylebox_override("panel", _box(PAPER, RED, 4, 14))
	add_child(dialog)
	_add_event_label(dialog, "新手引導已完成", Rect2(24, 24, 384, 44), 25, RED, HORIZONTAL_ALIGNMENT_CENTER)
	_add_event_label(dialog, "地基主已加入圖鑑，並成為目前召喚中的伴生靈。\n\n請點擊下方按鈕返回戰鬥，繼續遊戲。", Rect2(38, 88, 356, 120), 16, INK, HORIZONTAL_ALIGNMENT_CENTER)
	var return_button := Button.new()
	return_button.position = Vector2(96, 238)
	return_button.size = Vector2(240, 54)
	return_button.text = "返回戰鬥"
	return_button.add_theme_font_size_override("font_size", 18)
	return_button.add_theme_color_override("font_color", PAPER)
	return_button.add_theme_stylebox_override("normal", _box(GREEN, Color("22342b"), 3, 9))
	return_button.pressed.connect(_finish_tutorial_to_battle.bind(shade, dialog))
	dialog.add_child(return_button)


func _finish_tutorial_to_battle(shade: ColorRect, dialog: Panel) -> void:
	if is_instance_valid(shade):
		shade.queue_free()
	if is_instance_valid(dialog):
		dialog.queue_free()
	_show_battle()


func _build_screen() -> void:
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = INK
	add_child(background)
	var paper := Panel.new()
	paper.position = Vector2(12, 12)
	paper.size = Vector2(516, 936)
	paper.add_theme_stylebox_override("panel", _box(PAPER, Color("49382a"), 3, 14))
	add_child(paper)
	_add_label("島嶼神怪誌", Rect2(30, 28, 300, 38), 28, RED)
	var back_to_battle := Button.new()
	back_to_battle.position = Vector2(30, 68)
	back_to_battle.size = Vector2(90, 30)
	back_to_battle.text = "← 戰鬥"
	back_to_battle.add_theme_font_size_override("font_size", 13)
	back_to_battle.add_theme_color_override("font_color", PAPER)
	back_to_battle.add_theme_stylebox_override("normal", _box(GREEN, Color("22342b"), 2, 7))
	back_to_battle.pressed.connect(_show_battle)
	add_child(back_to_battle)
	_add_label("靈脈殘響・神怪圖鑑", Rect2(128, 69, 210, 26), 13, GREEN)
	_add_label("總收錄 %d／12" % _discovered_card_count(), Rect2(330, 34, 170, 28), 18, RED, HORIZONTAL_ALIGNMENT_RIGHT)
	_add_label("圖鑑靈息加成　+3%", Rect2(300, 66, 200, 24), 13, GREEN, HORIZONTAL_ALIGNMENT_RIGHT)
	var characters_button := Button.new()
	characters_button.position = Vector2(300, 72)
	characters_button.size = Vector2(78, 28)
	characters_button.text = "角色"
	characters_button.add_theme_font_size_override("font_size", 12)
	characters_button.add_theme_stylebox_override("normal", _box(Color("c5b17f"), RED, 2, 7))
	characters_button.pressed.connect(_return_to_character_select)
	add_child(characters_button)
	var battle_button := Button.new()
	battle_button.position = Vector2(384, 72)
	battle_button.size = Vector2(78, 28)
	battle_button.text = "出陣"
	battle_button.add_theme_color_override("font_color", PAPER)
	battle_button.add_theme_font_size_override("font_size", 13)
	battle_button.add_theme_stylebox_override("normal", _box(GREEN, Color("22342b"), 2, 7))
	battle_button.pressed.connect(_show_battle)
	add_child(battle_button)
	_add_quick_menu()
	var line := ColorRect.new()
	line.position = Vector2(30, 103)
	line.size = Vector2(480, 3)
	line.color = RED
	add_child(line)
	var filters := ["全部", "異聞", "精怪", "凶煞", "神祇"]
	for i in filters.size():
		var button := Button.new()
		button.position = Vector2(30 + i * 96, 120)
		button.size = Vector2(88, 38)
		button.text = filters[i]
		button.add_theme_font_size_override("font_size", 14)
		button.add_theme_color_override("font_color", PAPER if i == 0 else INK)
		button.add_theme_stylebox_override("normal", _box(RED if i == 0 else Color("c5b17f"), RED, 2, 8))
		add_child(button)
	_add_label("重複卡累積至 100 張可進行首次覺醒", Rect2(30, 170, 360, 30), 14, GREEN, HORIZONTAL_ALIGNMENT_CENTER)
	var equipment_button := Button.new()
	equipment_button.position = Vector2(398, 166)
	equipment_button.size = Vector2(108, 38)
	equipment_button.text = "裝備強化"
	equipment_button.add_theme_color_override("font_color", PAPER)
	equipment_button.add_theme_stylebox_override("normal", _box(GREEN, Color("22342b"), 2, 8))
	equipment_button.pressed.connect(_show_equipment)
	add_child(equipment_button)
	for i in card_names.size():
		_create_card(i)
	var footer := Panel.new()
	footer.position = Vector2(26, 858)
	footer.size = Vector2(488, 70)
	footer.add_theme_stylebox_override("panel", _box(Color("b49d6d"), RED, 2, 10))
	add_child(footer)
	_add_label("卡片收集加成", Rect2(42, 868, 170, 24), 15, RED)
	_add_label("靈息收益 +3%　｜　古道怪影 %d／6" % _region_card_discovered_count(), Rect2(42, 894, 450, 25), 14, INK)


func _create_card(index: int) -> void:
	var col := index % 2
	var row := index / 2
	var origin := Vector2(30 + col * 244, 210 + row * 210)
	var frame := Panel.new()
	frame.position = origin
	frame.size = Vector2(226, 194)
	frame.add_theme_stylebox_override("panel", _box(Color("c9b681"), RED if index == 0 else COPPER, 3, 9))
	add_child(frame)
	if index == 0:
		var art := TextureRect.new()
		art.position = origin + Vector2(8, 8)
		art.size = Vector2(100, 140)
		art.texture = load("res://assets/cards/dijizhu-card-v1.png")
		art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		art.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(art)
	else:
		var locked := ColorRect.new()
		locked.position = origin + Vector2(8, 8)
		locked.size = Vector2(100, 140)
		locked.color = Color("332d28")
		add_child(locked)
		_add_label("？", Rect2(origin + Vector2(8, 41), Vector2(100, 70)), 42, Color("776956"), HORIZONTAL_ALIGNMENT_CENTER)
	_add_label(card_names[index], Rect2(origin + Vector2(116, 12), Vector2(100, 28)), 17, RED if index == 0 else INK)
	_add_label(card_types[index], Rect2(origin + Vector2(116, 42), Vector2(100, 23)), 13, GREEN)
	var owned_count := int(card_counts.get(card_names[index], 0))
	_add_label("已收錄" if owned_count > 0 else "尚未相遇", Rect2(origin + Vector2(116, 72), Vector2(100, 23)), 13, RED if owned_count > 0 else Color("665b50"))
	_add_label("靈息 +3%" if index == 0 else "能力未知", Rect2(origin + Vector2(116, 101), Vector2(100, 23)), 12, INK)
	_add_label("持有 %d／100・%s" % [owned_count, "覺醒Ⅰ" if owned_count >= 100 else "未覺醒"], Rect2(origin + Vector2(8, 158), Vector2(210, 25)), 13, GREEN, HORIZONTAL_ALIGNMENT_CENTER)
	if index == 0:
		var open_button := Button.new()
		open_button.position = origin
		open_button.size = Vector2(226, 194)
		open_button.flat = true
		open_button.tooltip_text = "查看地基主"
		open_button.pressed.connect(_show_companion)
		add_child(open_button)


func _show_companion() -> void:
	_enter_background_battle_mode()
	if not prologue_completed:
		GameState.set_battle_view_active(true)
	for child in get_children():
		child.queue_free()
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = INK
	add_child(background)
	var paper := Panel.new()
	paper.position = Vector2(12, 12)
	paper.size = Vector2(516, 936)
	paper.add_theme_stylebox_override("panel", _box(PAPER, Color("49382a"), 3, 14))
	add_child(paper)
	var back := Button.new()
	back.position = Vector2(28, 28)
	back.size = Vector2(70, 38)
	back.text = "← 圖鑑"
	back.add_theme_stylebox_override("normal", _box(Color("c5b17f"), RED, 2, 8))
	back.pressed.connect(_return_to_collection)
	add_child(back)
	_add_label("伴生靈・地基主", Rect2(112, 25, 300, 42), 26, RED)
	_add_label("沉默守宅者", Rect2(370, 27, 137, 24), 13, GREEN, HORIZONTAL_ALIGNMENT_RIGHT)
	var summon_badge := Button.new()
	summon_badge.position = Vector2(348, 55)
	summon_badge.size = Vector2(110, 34)
	summon_badge.text = "✓ 召喚中" if prologue_completed else "召喚地基主"
	summon_badge.disabled = prologue_completed
	summon_badge.add_theme_color_override("font_disabled_color", PAPER)
	summon_badge.add_theme_stylebox_override("disabled", _box(GREEN, Color("22342b"), 2, 8))
	if not prologue_completed:
		summon_badge.add_theme_color_override("font_color", PAPER)
		summon_badge.add_theme_stylebox_override("normal", _box(RED, Color("3a1815"), 2, 8))
		summon_badge.pressed.connect(_summon_dijizhu_from_companion_page)
	add_child(summon_badge)
	var art := TextureRect.new()
	art.position = Vector2(30, 88)
	art.size = Vector2(205, 305)
	art.texture = load("res://assets/cards/dijizhu-card-v1.png")
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	add_child(art)
	_add_label("Lv. 1", Rect2(258, 90, 100, 32), 22, RED)
	_add_label("經驗　12／100", Rect2(258, 126, 220, 26), 14, INK)
	_add_stat("守護", "18", Vector2(258, 172))
	_add_stat("靈息", "26", Vector2(382, 172))
	_add_stat("尋卡", "+2%", Vector2(258, 242))
	_add_stat("離線", "+4%", Vector2(382, 242))
	_add_label("升級點數　1", Rect2(258, 319, 220, 28), 16, GREEN)
	var upgrade := Button.new()
	upgrade.position = Vector2(258, 354)
	upgrade.size = Vector2(220, 40)
	upgrade.text = "＋ 提升守護（消耗 1 點）"
	upgrade.add_theme_stylebox_override("normal", _box(RED, Color("3a1815"), 2, 8))
	upgrade.add_theme_color_override("font_color", PAPER)
	add_child(upgrade)
	var skill_panel := Panel.new()
	skill_panel.position = Vector2(30, 418)
	skill_panel.size = Vector2(480, 138)
	skill_panel.add_theme_stylebox_override("panel", _box(Color("b9a36f"), RED, 2, 10))
	add_child(skill_panel)
	_add_label("專屬守契・灶下守契", Rect2(46, 430, 300, 28), 18, RED)
	_add_label("每 60 秒賜予一次護宅香火，提升離線收益與卡片發現率。", Rect2(46, 465, 440, 48), 14, INK)
	_add_label("下一次守契：00:42", Rect2(46, 520, 440, 24), 13, GREEN, HORIZONTAL_ALIGNMENT_RIGHT)
	_add_label("伴生靈裝備", Rect2(30, 574, 220, 30), 18, RED)
	_add_label("僅召喚中的伴生靈可裝配", Rect2(270, 578, 240, 24), 12, GREEN, HORIZONTAL_ALIGNMENT_RIGHT)
	var equipment_names := ["供品", "契物", "護符"]
	var equipment_effects := ["恢復／收益", "攻擊／技能", "防禦／休養"]
	for i in range(3):
		var slot := Panel.new()
		slot.position = Vector2(30 + i * 163, 620)
		slot.size = Vector2(152, 112)
		slot.add_theme_stylebox_override("panel", _box(Color("bbaa7c"), RED if i == 0 else COPPER, 2, 8))
		add_child(slot)
		_add_label(equipment_names[i], Rect2(slot.position + Vector2(8, 9), Vector2(136, 28)), 16, RED, HORIZONTAL_ALIGNMENT_CENTER)
		_add_label("＋", Rect2(slot.position + Vector2(8, 36), Vector2(136, 35)), 26, Color("5f5549"), HORIZONTAL_ALIGNMENT_CENTER)
		_add_label(equipment_effects[i], Rect2(slot.position + Vector2(8, 76), Vector2(136, 24)), 12, GREEN, HORIZONTAL_ALIGNMENT_CENTER)
	var combat_panel := Panel.new()
	combat_panel.position = Vector2(30, 752)
	combat_panel.size = Vector2(480, 78)
	combat_panel.add_theme_stylebox_override("panel", _box(Color("c4b17e"), COPPER, 2, 8))
	add_child(combat_panel)
	_add_label("戰鬥繼承", Rect2(44, 760, 110, 24), 15, RED)
	_add_label("取得角色攻擊力 12%　・　被擊殺後休養 60 秒", Rect2(44, 788, 445, 28), 14, INK)
	var footer := Panel.new()
	footer.position = Vector2(26, 850)
	footer.size = Vector2(488, 78)
	footer.add_theme_stylebox_override("panel", _box(Color("b49d6d"), RED, 2, 10))
	add_child(footer)
	_add_label("目前召喚加成", Rect2(42, 860, 170, 24), 15, RED)
	_add_label("離線收益 +4%　｜　尋卡 +2%　｜　守護 18", Rect2(42, 890, 450, 26), 13, INK)
	if not prologue_completed:
		var tutorial_hint := Panel.new()
		tutorial_hint.position = Vector2(245, 94)
		tutorial_hint.size = Vector2(264, 48)
		tutorial_hint.z_index = 12
		tutorial_hint.add_theme_stylebox_override("panel", _box(Color("b9a36f"), RED, 2, 8))
		add_child(tutorial_hint)
		_add_event_label(tutorial_hint, "請按右上角召喚地基主 ↑", Rect2(10, 6, 244, 36), 13, RED, HORIZONTAL_ALIGNMENT_CENTER)
	_add_quick_menu()


func _add_stat(stat_name: String, value: String, origin: Vector2) -> void:
	var panel := Panel.new()
	panel.position = origin
	panel.size = Vector2(108, 58)
	panel.add_theme_stylebox_override("panel", _box(Color("c4b17e"), COPPER, 2, 8))
	add_child(panel)
	_add_label(stat_name, Rect2(origin + Vector2(6, 4), Vector2(96, 22)), 12, GREEN, HORIZONTAL_ALIGNMENT_CENTER)
	_add_label(value, Rect2(origin + Vector2(6, 25), Vector2(96, 28)), 18, RED, HORIZONTAL_ALIGNMENT_CENTER)


func _return_to_collection() -> void:
	_enter_background_battle_mode()
	for child in get_children():
		child.queue_free()
	if prologue_completed:
		_build_screen()
	else:
		_show_collection_summon_tutorial()


func _show_equipment() -> void:
	_enter_background_battle_mode()
	for child in get_children():
		child.queue_free()
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = INK
	add_child(background)
	var paper := Panel.new()
	paper.position = Vector2(12, 12)
	paper.size = Vector2(516, 936)
	paper.add_theme_stylebox_override("panel", _box(PAPER, Color("49382a"), 3, 14))
	add_child(paper)
	var back := Button.new()
	back.position = Vector2(28, 28)
	back.size = Vector2(70, 38)
	back.text = "← 圖鑑"
	back.add_theme_stylebox_override("normal", _box(Color("c5b17f"), RED, 2, 8))
	back.pressed.connect(_return_to_collection)
	add_child(back)
	_add_label("器物・強化壇", Rect2(112, 25, 280, 42), 26, RED)
	_add_label("裝備是唯一可強化系統", Rect2(312, 31, 195, 28), 13, GREEN, HORIZONTAL_ALIGNMENT_RIGHT)

	var preview := Panel.new()
	preview.position = Vector2(30, 88)
	preview.size = Vector2(480, 250)
	preview.add_theme_stylebox_override("panel", _box(Color("b9a36f"), Color("4f9c9a"), 4, 12))
	add_child(preview)
	_add_label("＋7", Rect2(48, 108, 88, 42), 30, Color("d9f5df"), HORIZONTAL_ALIGNMENT_CENTER)
	_add_label("鎮煞的・烏鐵短刀", Rect2(150, 103, 320, 34), 22, RED)
	_add_label("稀有器物　｜　霧隱古道掉落", Rect2(151, 139, 300, 24), 13, GREEN)
	_add_label("基礎攻擊　+24", Rect2(48, 178, 200, 27), 15, INK)
	_add_label("鎮煞：對凶煞傷害 +4%", Rect2(48, 210, 300, 25), 14, RED)
	_add_label("引魂：卡片掉落率 +1.5%", Rect2(48, 239, 300, 25), 14, GREEN)
	_add_label("詞綴能力預算　5.5／6.0", Rect2(48, 278, 420, 24), 13, INK)
	_add_label("＋7 青藍靈火已啟用", Rect2(260, 304, 225, 23), 13, Color("275e5c"), HORIZONTAL_ALIGNMENT_RIGHT)

	_add_label("強化結果", Rect2(30, 360, 170, 30), 19, RED)
	var outcomes: Array = [
		["成功", "35%", "提升為 ＋8", GREEN],
		["沒有變化", "45%", "保留 ＋7", Color("655947")],
		["裝備消失", "20%", "轉為器魂碎片", RED]
	]
	for i in outcomes.size():
		var outcome: Array = outcomes[i]
		var panel := Panel.new()
		panel.position = Vector2(30 + i * 163, 402)
		panel.size = Vector2(152, 104)
		panel.add_theme_stylebox_override("panel", _box(Color("c3b07d"), outcome[3], 2, 9))
		add_child(panel)
		_add_label(outcome[0], Rect2(panel.position + Vector2(6, 7), Vector2(140, 25)), 15, outcome[3], HORIZONTAL_ALIGNMENT_CENTER)
		_add_label(outcome[1], Rect2(panel.position + Vector2(6, 33), Vector2(140, 31)), 20, INK, HORIZONTAL_ALIGNMENT_CENTER)
		_add_label(outcome[2], Rect2(panel.position + Vector2(6, 70), Vector2(140, 23)), 12, GREEN, HORIZONTAL_ALIGNMENT_CENTER)
	_add_label("需求：武器強化卷軸 ×1　・　銅錢 18,000", Rect2(30, 522, 480, 28), 14, INK, HORIZONTAL_ALIGNMENT_CENTER)
	var enhance := Button.new()
	enhance.position = Vector2(130, 562)
	enhance.size = Vector2(280, 48)
	enhance.text = "於強化壇進行強化"
	enhance.add_theme_color_override("font_color", PAPER)
	enhance.add_theme_stylebox_override("normal", _box(RED, Color("3a1815"), 3, 10))
	add_child(enhance)

	_add_label("近期取得器物", Rect2(30, 632, 220, 30), 19, RED)
	var drops: Array = [
		["護宅的・舊銅鈴", "＋3", "守護 +5・靈息恢復 +2%"],
		["引路的・草鞋", "＋0", "移動 +3%・尋卡 +1%"],
		["潮痕的・短褂", "＋2", "生命 +18・水抗 +4%"],
		["無詞綴・桃木劍", "＋0", "攻擊 +11"]
	]
	for i in drops.size():
		var item: Array = drops[i]
		var item_panel := Panel.new()
		item_panel.position = Vector2(30, 674 + i * 57)
		item_panel.size = Vector2(480, 48)
		item_panel.add_theme_stylebox_override("panel", _box(Color("c4b17e"), COPPER, 1, 7))
		add_child(item_panel)
		_add_label(item[1], Rect2(42, 680 + i * 57, 52, 28), 16, RED, HORIZONTAL_ALIGNMENT_CENTER)
		_add_label(item[0], Rect2(102, 678 + i * 57, 220, 25), 14, INK)
		_add_label(item[2], Rect2(102, 700 + i * 57, 380, 20), 12, GREEN)
	_add_label("高階強化不提供隱藏能力；光效僅代表器物強化程度。", Rect2(30, 908, 480, 25), 12, GREEN, HORIZONTAL_ALIGNMENT_CENTER)


func _show_battle() -> void:
	GameState.set_battle_view_active(true)
	for child in get_children():
		child.queue_free()
	region_boss_pending = false
	region_boss_active = false
	region_boss_target_index = -1
	region_event_active = false
	battle_spawn_sequence = 0
	battle_hit_counter = 0
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = INK
	add_child(background)
	var paper := Panel.new()
	paper.position = Vector2(12, 12)
	paper.size = Vector2(516, 936)
	paper.add_theme_stylebox_override("panel", _box(PAPER, Color("49382a"), 3, 14))
	add_child(paper)

	battle_player_level_label = _make_label("霧隱古道・入口　Lv.%d" % player_level, Rect2(28, 26, 300, 36), 25, RED)
	_add_label("異聞區域　建議等級 1～8", Rect2(29, 61, 250, 24), 13, GREEN)
	region_progress_label = _make_label("調查 %d／%d" % [mini(region_progress, REGION_COMPLETION_KILLS), REGION_COMPLETION_KILLS], Rect2(278, 61, 230, 24), 12, GREEN, HORIZONTAL_ALIGNMENT_RIGHT)
	_refresh_region_progress_label()
	_add_label("自動巡行中", Rect2(302, 30, 160, 28), 15, GREEN, HORIZONTAL_ALIGNMENT_RIGHT)
	_add_label("00:18:42", Rect2(342, 58, 120, 24), 13, RED, HORIZONTAL_ALIGNMENT_RIGHT)
	_add_quick_menu()
	var divider := ColorRect.new()
	divider.position = Vector2(28, 94)
	divider.size = Vector2(484, 3)
	divider.color = RED
	add_child(divider)

	var scene_panel := Panel.new()
	scene_panel.position = Vector2(28, 112)
	scene_panel.size = Vector2(484, 410)
	scene_panel.add_theme_stylebox_override("panel", _box(Color("26362e"), Color("4f6658"), 2, 10))
	add_child(scene_panel)
	_add_label("風穿過廢庄，紙灰沿著石階逆流。", Rect2(250, 123, 235, 28), 12, Color("c9c09b"), HORIZONTAL_ALIGNMENT_RIGHT)
	var scroll_button := Button.new()
	scroll_button.position = Vector2(38, 122)
	scroll_button.size = Vector2(48, 58)
	scroll_button.text = "卷"
	scroll_button.tooltip_text = "單擊展開／收合・雙擊開啟差事簿"
	scroll_button.add_theme_font_size_override("font_size", 20)
	scroll_button.add_theme_color_override("font_color", Color("f0df9b"))
	scroll_button.add_theme_stylebox_override("normal", _box(Color("6d241fcc"), Color("d2b85f"), 2, 9))
	var task_click_timer := Timer.new()
	task_click_timer.one_shot = true
	task_click_timer.wait_time = 0.28
	scroll_button.add_child(task_click_timer)
	var tracked_task := _tracked_task_summary()
	scroll_button.gui_input.connect(_on_task_scroll_input.bind(task_click_timer, str(tracked_task["tab"])))
	add_child(scroll_button)
	var reward_ready := _has_task_reward_ready()
	if reward_ready:
		var notice := Label.new()
		notice.position = Vector2(31, -7)
		notice.size = Vector2(22, 22)
		notice.text = "!"
		notice.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		notice.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		notice.add_theme_font_size_override("font_size", 14)
		notice.add_theme_color_override("font_color", PAPER)
		notice.add_theme_stylebox_override("normal", _box(RED, Color("f0df9b"), 2, 12))
		scroll_button.add_child(notice)
	var has_tracked_task := str(tracked_task["title"]) != ""
	var task_panel := Panel.new()
	task_panel.position = Vector2(90, 122)
	task_panel.size = Vector2(206, 58)
	task_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	task_panel.add_theme_stylebox_override("panel", _box(Color("293a32b8"), Color("d2b85f") if reward_ready else COPPER, 2, 7))
	task_panel.visible = not task_tracker_collapsed and has_tracked_task
	add_child(task_panel)
	var task_title := _make_label(str(tracked_task["title"]), Rect2(101, 126, 184, 24), 12, Color("f0df9b"))
	var task_status := _make_label(str(tracked_task["status"]), Rect2(101, 151, 184, 22), 12, PAPER)
	task_title.visible = not task_tracker_collapsed and has_tracked_task
	task_status.visible = not task_tracker_collapsed and has_tracked_task
	task_click_timer.timeout.connect(_toggle_task_tracker.bind(task_panel, task_title, task_status, has_tracked_task))
	region_boss_badge = _make_label("區域小頭目・送煞紙將", Rect2(238, 153, 250, 30), 17, Color("e0bd72"), HORIZONTAL_ALIGNMENT_RIGHT)
	region_boss_badge.visible = false

	var moon := Panel.new()
	moon.position = Vector2(400, 145)
	moon.size = Vector2(62, 62)
	moon.add_theme_stylebox_override("panel", _box(Color("b7aa75"), Color("897b55"), 1, 38))
	add_child(moon)
	var mist := ColorRect.new()
	mist.position = Vector2(45, 402)
	mist.size = Vector2(450, 68)
	mist.color = Color("53675c80")
	add_child(mist)
	_add_battle_lane(Vector2(72, 373), Vector2(418, 205), 0.9)
	_add_battle_lane(Vector2(88, 410), Vector2(450, 295), 0.65)

	var companion_spirit := _add_companion_spirit(Vector2(42, 286), CURRENT_COMPANION_AWAKENING)
	var player_body := _add_fighter("旅人", "HP 126／140", Vector2(72, 306), RED, "短刀")
	var player_live_hp := ColorRect.new()
	player_live_hp.position = Vector2(62, 282)
	player_live_hp.size = Vector2(112, 9)
	player_live_hp.color = Color("b43b31")
	player_live_hp.z_index = 3
	add_child(player_live_hp)
	var enemy_body := _add_fighter("無面紙僕", "HP 41／90", Vector2(360, 204), Color("6b7468"), "陰紙爪")
	enemy_body.scale = Vector2(0.82, 0.82)
	var live_hp := ColorRect.new()
	live_hp.position = Vector2(352, 187)
	live_hp.size = Vector2(76, 7)
	live_hp.color = Color("9a342b")
	add_child(live_hp)
	var enemy_two := _add_battle_enemy("吊頸鬼影", Vector2(286, 286), Color("4e5d55"), 0.94)
	var enemy_three := _add_battle_enemy("腐燈童子", Vector2(414, 334), Color("786248"), 0.94)
	var hp_two := _add_target_hp_bar(Vector2(282, 274), 58.0)
	var hp_three := _add_target_hp_bar(Vector2(411, 322), 50.0)
	var damage_label := _make_label("斬擊 －12", Rect2(240, 246, 110, 28), 17, Color("ead7a1"), HORIZONTAL_ALIGNMENT_CENTER)
	damage_label.modulate.a = 0.0
	_add_label("伴生靈・地基主　覺醒Ⅰ", Rect2(196, 427, 220, 25), 14, Color("d8c887"))
	var companion_status := _make_label("共鬥中　HP 60／60　・　分擔 20%", Rect2(196, 451, 270, 22), 12, Color("a9bcae"))
	var companion_hp_back := ColorRect.new()
	companion_hp_back.position = Vector2(196, 476)
	companion_hp_back.size = Vector2(178, 7)
	companion_hp_back.color = Color("2a211d")
	add_child(companion_hp_back)
	var companion_hp_bar := ColorRect.new()
	companion_hp_bar.position = Vector2(196, 476)
	companion_hp_bar.size = Vector2(178, 7)
	companion_hp_bar.color = Color("668f72")
	add_child(companion_hp_bar)
	var spirit_fire := Panel.new()
	spirit_fire.position = Vector2(164, 432)
	spirit_fire.size = Vector2(28, 28)
	spirit_fire.add_theme_stylebox_override("panel", _box(Color("b9aa63"), Color("e6d88e"), 2, 14))
	add_child(spirit_fire)

	var log_panel := Panel.new()
	log_panel.position = Vector2(28, 538)
	log_panel.size = Vector2(484, 186)
	log_panel.add_theme_stylebox_override("panel", _box(Color("b9a36f"), RED, 2, 9))
	add_child(log_panel)
	_add_label("巡行紀錄", Rect2(44, 548, 150, 26), 17, RED)
	var opening_log := "戰鬥開始　無面紙僕正在靠近……"
	if background_kills_since_view > 0:
		opening_log = "背景巡行持續進行\n消滅 %d 隻・經驗 %d・銅錢 %d・殘頁 %d%s\n返回可見戰場，沒有重複計算收益" % [background_kills_since_view, background_exp_since_view, background_coins_since_view, background_pages_since_view, "・器物 %d" % background_items_since_view if background_items_since_view > 0 else ""]
	var battle_log := _make_label(opening_log, Rect2(44, 579, 445, 128), 13, INK)
	battle_log.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	background_kills_since_view = 0
	background_exp_since_view = 0
	background_coins_since_view = 0
	background_pages_since_view = 0
	background_items_since_view = 0
	battle_active_skill_button = Button.new()
	battle_active_skill_button.position = Vector2(360, 544)
	battle_active_skill_button.size = Vector2(132, 32)
	battle_active_skill_button.text = "敕符・淨煞　可用"
	battle_active_skill_button.add_theme_font_size_override("font_size", 12)
	battle_active_skill_button.add_theme_color_override("font_color", PAPER)
	battle_active_skill_button.add_theme_stylebox_override("normal", _box(RED, Color("3a1815"), 2, 7))
	battle_active_skill_button.pressed.connect(_manual_cast_active_skill.bind(battle_log))
	add_child(battle_active_skill_button)

	var status := Panel.new()
	status.position = Vector2(28, 738)
	status.size = Vector2(484, 92)
	status.add_theme_stylebox_override("panel", _box(Color("c4b17e"), COPPER, 2, 9))
	add_child(status)
	_add_label("離線巡行上限　8 小時", Rect2(44, 748, 260, 25), 15, RED)
	battle_player_exp_label = _make_label(_next_level_exp_text(), Rect2(44, 778, 440, 28), 13, INK)
	_add_label("成長速度將以月為單位調整，不以一天畢業為目標。", Rect2(44, 805, 440, 20), 11, GREEN)

	_start_battle_motion(player_body, enemy_body, damage_label, spirit_fire)
	_start_companion_motion(companion_spirit)
	_start_enemy_idle(enemy_two, 7.0)
	_start_enemy_idle(enemy_three, -6.0)
	battle_targets.clear()
	battle_locked_target = -1
	_register_battle_target("無面紙僕", enemy_body, live_hp, 90, 8, Rect2(337, 188, 112, 142))
	_register_battle_target("吊頸鬼影", enemy_two, hp_two, 72, 7, Rect2(264, 268, 98, 112))
	_register_battle_target("腐燈童子", enemy_three, hp_three, 58, 6, Rect2(397, 314, 92, 100))
	_start_battle_loop(player_body, player_live_hp, companion_spirit, companion_hp_bar, companion_status, damage_label, battle_log)


func _add_fighter(fighter_name: String, hp_text: String, origin: Vector2, color: Color, weapon: String) -> Panel:
	var body := Panel.new()
	body.position = origin
	body.size = Vector2(92, 112)
	body.add_theme_stylebox_override("panel", _box(color, Color("171713"), 3, 42))
	add_child(body)
	var hp_back := ColorRect.new()
	hp_back.position = origin + Vector2(-10, -24)
	hp_back.size = Vector2(112, 9)
	hp_back.color = Color("2a211d")
	add_child(hp_back)
	if fighter_name == "旅人":
		_add_label(fighter_name, Rect2(origin + Vector2(-24, 116), Vector2(140, 25)), 14, Color("e1d6ae"), HORIZONTAL_ALIGNMENT_CENTER)
		_add_label(hp_text, Rect2(origin + Vector2(-24, 139), Vector2(140, 20)), 11, Color("aebcaf"), HORIZONTAL_ALIGNMENT_CENTER)
		_add_label(weapon, Rect2(origin + Vector2(-24, 162), Vector2(140, 20)), 11, Color("c4aa75"), HORIZONTAL_ALIGNMENT_CENTER)
	return body


func _add_battle_enemy(enemy_name: String, origin: Vector2, color: Color, size_scale: float) -> Panel:
	var shadow := Panel.new()
	shadow.position = origin + Vector2(-8, 70) * size_scale
	shadow.size = Vector2(108, 24) * size_scale
	shadow.add_theme_stylebox_override("panel", _box(Color("14181480"), Color("14181400"), 0, 14))
	add_child(shadow)
	var body := Panel.new()
	body.position = origin
	body.size = Vector2(78, 96) * size_scale
	body.add_theme_stylebox_override("panel", _box(color, Color("171713"), 2, int(34 * size_scale)))
	add_child(body)
	var hp_back := ColorRect.new()
	hp_back.position = origin + Vector2(-5, -14)
	hp_back.size = Vector2(88, 6) * size_scale
	hp_back.color = Color("2a211d")
	add_child(hp_back)
	return body


func _add_companion_spirit(origin: Vector2, awakening_rank: int) -> Control:
	var spirit := Control.new()
	spirit.position = origin
	spirit.size = Vector2(96, 150)
	spirit.z_index = 2
	var visual_scale := _companion_scale_for_rank(awakening_rank)
	spirit.scale = Vector2(visual_scale, visual_scale)
	spirit.rotation = -0.10
	spirit.pivot_offset = Vector2(48, 112)
	spirit.modulate = Color(0.64, 0.82, 0.68, 0.34)
	spirit.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(spirit)
	var aura := Panel.new()
	aura.position = Vector2(4, 18)
	aura.size = Vector2(88, 124)
	aura.add_theme_stylebox_override("panel", _box(Color("49695880"), Color("9ac19c80"), 2, 42))
	spirit.add_child(aura)
	var head := Panel.new()
	head.position = Vector2(28, 0)
	head.size = Vector2(44, 48)
	head.add_theme_stylebox_override("panel", _box(Color("365748"), Color("adc39d"), 2, 22))
	spirit.add_child(head)
	var eye := Panel.new()
	eye.position = Vector2(57, 16)
	eye.size = Vector2(8, 7)
	eye.add_theme_stylebox_override("panel", _box(Color("e7db97"), Color("e7db97"), 0, 4))
	spirit.add_child(eye)
	var guiding_arm := ColorRect.new()
	guiding_arm.position = Vector2(66, 61)
	guiding_arm.size = Vector2(42, 9)
	guiding_arm.rotation = -0.28
	guiding_arm.color = Color("78947d")
	spirit.add_child(guiding_arm)
	var lantern := Panel.new()
	lantern.position = Vector2(68, 42)
	lantern.size = Vector2(28, 34)
	lantern.add_theme_stylebox_override("panel", _box(Color("b79d55"), Color("eadb91"), 2, 10))
	spirit.add_child(lantern)
	return spirit


func _companion_scale_for_rank(awakening_rank: int) -> float:
	var rank_scales := [0.42, 0.55, 0.70, 0.88, 1.05, 1.20]
	return rank_scales[clampi(awakening_rank, 0, rank_scales.size() - 1)]


func _add_battle_lane(from: Vector2, to: Vector2, opacity: float) -> void:
	var lane := Line2D.new()
	lane.add_point(from)
	lane.add_point(to)
	lane.width = 2.0
	lane.default_color = Color(0.60, 0.67, 0.58, opacity)
	add_child(lane)


func _add_target_hp_bar(origin: Vector2, width: float) -> ColorRect:
	var hp_bar := ColorRect.new()
	hp_bar.position = origin
	hp_bar.size = Vector2(width, 6)
	hp_bar.color = Color("9a342b")
	add_child(hp_bar)
	return hp_bar


func _register_battle_target(target_name: String, body: Control, hp_bar: ColorRect, max_hp: int, monster_level: int, hit_rect: Rect2) -> void:
	var index := battle_targets.size()
	var spawn_order := battle_spawn_sequence
	battle_spawn_sequence += 1
	var name_label := Label.new()
	name_label.position = hit_rect.position + Vector2(-12, hit_rect.size.y - 14)
	name_label.size = Vector2(hit_rect.size.x + 24, 24)
	name_label.text = target_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 12)
	name_label.add_theme_color_override("font_color", Color("d5caa5"))
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_label.z_index = 3
	add_child(name_label)
	var marker := Label.new()
	marker.position = hit_rect.position - Vector2(8, 15)
	marker.size = hit_rect.size + Vector2(16, 24)
	marker.text = "◎"
	marker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	marker.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	marker.add_theme_font_size_override("font_size", 42)
	marker.add_theme_color_override("font_color", Color("e7d98e"))
	marker.z_index = 4
	marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	marker.visible = false
	add_child(marker)
	var touch_target := Button.new()
	touch_target.position = hit_rect.position
	touch_target.size = hit_rect.size
	touch_target.flat = true
	touch_target.z_index = 5
	touch_target.tooltip_text = "鎖定%s" % target_name
	touch_target.pressed.connect(_lock_battle_target.bind(index))
	add_child(touch_target)
	battle_targets.append({
		"name": target_name,
		"normal_name": target_name,
		"body": body,
		"hp_bar": hp_bar,
		"hp": max_hp,
		"level": monster_level,
		"max_hp": max_hp,
		"normal_max_hp": max_hp,
		"damage_min": 2,
		"damage_max": 5,
		"coin_mult": 1.0,
		"page_chance": 0.10,
		"trait": "普通近戰",
		"bar_width": hp_bar.size.x,
		"base_scale": body.scale,
		"normal_scale": body.scale,
		"name_label": name_label,
		"marker": marker,
		"button": touch_target,
		"alive": true
		,"spawn_order": spawn_order
	})


func _lock_battle_target(index: int) -> void:
	if index < 0 or index >= battle_targets.size() or not battle_targets[index]["alive"]:
		return
	battle_locked_target = index
	for i in battle_targets.size():
		battle_targets[i]["marker"].visible = i == index


func _start_enemy_idle(enemy: Control, distance: float) -> void:
	var start := enemy.position
	var idle := create_tween().set_loops()
	idle.tween_property(enemy, "position", start + Vector2(0, distance), 0.8).set_trans(Tween.TRANS_SINE)
	idle.tween_property(enemy, "position", start, 0.8).set_trans(Tween.TRANS_SINE)


func _start_companion_motion(spirit: Control) -> void:
	var start := spirit.position
	var breathe := create_tween().set_loops()
	battle_companion_tween = breathe
	breathe.tween_property(spirit, "position", start + Vector2(10, -8), 1.0).set_trans(Tween.TRANS_SINE)
	breathe.parallel().tween_property(spirit, "modulate:a", 0.48, 1.4)
	breathe.tween_property(spirit, "position", start, 1.0).set_trans(Tween.TRANS_SINE)
	breathe.parallel().tween_property(spirit, "modulate:a", 0.28, 1.4)


func _start_battle_loop(player_body: Control, player_hp_bar: ColorRect, companion: Control, companion_hp_bar: ColorRect, companion_status: Label, damage_label: Label, battle_log: Label) -> void:
	battle_player_hp = 140
	battle_player_hp_bar_ref = player_hp_bar
	battle_companion_hp = 60
	battle_companion_resting = false
	battle_player_attack_timer = Timer.new()
	battle_player_attack_timer.wait_time = 1.55
	battle_player_attack_timer.autostart = true
	battle_player_attack_timer.timeout.connect(_resolve_battle_hit.bind(battle_player_attack_timer, damage_label, battle_log))
	add_child(battle_player_attack_timer)
	battle_enemy_attack_timer = Timer.new()
	battle_enemy_attack_timer.wait_time = 2.2
	battle_enemy_attack_timer.autostart = true
	battle_enemy_attack_timer.timeout.connect(_resolve_enemy_attacks.bind(player_body, player_hp_bar, companion, companion_hp_bar, companion_status, battle_log))
	add_child(battle_enemy_attack_timer)
	battle_active_skill_timer = Timer.new()
	battle_active_skill_timer.wait_time = 12.0
	battle_active_skill_timer.one_shot = true
	add_child(battle_active_skill_timer)
	var cooldown_display := Timer.new()
	cooldown_display.wait_time = 0.2
	cooldown_display.autostart = true
	cooldown_display.timeout.connect(_update_active_skill_state.bind(battle_log))
	add_child(cooldown_display)


func _resolve_enemy_attacks(player_body: Control, player_hp_bar: ColorRect, companion: Control, companion_hp_bar: ColorRect, companion_status: Label, battle_log: Label) -> void:
	if battle_player_hp <= 0:
		return
	var attackers := 0
	var raw_damage := 0
	for target in battle_targets:
		if target["alive"]:
			attackers += 1
			raw_damage += randi_range(int(target.get("damage_min", 2)), int(target.get("damage_max", 5)))
	if attackers == 0:
		return
	var shared_damage := 0
	if not battle_companion_resting:
		shared_damage = maxi(1, int(round(raw_damage * 0.20)))
		if randf() < 0.35:
			shared_damage += randi_range(1, 3)
		shared_damage = maxi(1, shared_damage - _equipped_power("護符"))
		battle_companion_hp = maxi(0, battle_companion_hp - shared_damage)
		companion_hp_bar.size.x = 178.0 * float(battle_companion_hp) / 60.0
		companion_status.text = "共鬥中　HP %d／60　・　分擔 20%%" % battle_companion_hp
	var received := maxi(1, raw_damage - shared_damage)
	received = maxi(1, received - int(_equipped_power("防具") / 4.0))
	received = maxi(1, received - mini(3, int(support_skill_exp / 10.0)))
	if event_debuff_hits > 0:
		received += 2
		event_debuff_hits -= 1
		_save_persistent_progress()
	battle_player_hp = maxi(0, battle_player_hp - received)
	player_hp_bar.size.x = 112.0 * float(battle_player_hp) / 140.0
	battle_log.text = "%d 隻怪物同時逼近\n你受到 %d 點傷害\n地基主分擔 %d 點　・　生命 %d／140" % [attackers, received, shared_damage, battle_player_hp]
	if battle_companion_hp == 0 and not battle_companion_resting:
		_start_companion_rest(companion, companion_hp_bar, companion_status, battle_log)
	var hurt := create_tween()
	hurt.tween_property(player_body, "modulate", Color("d1766f"), 0.08)
	hurt.tween_property(player_body, "modulate", Color.WHITE, 0.18)
	if battle_player_hp == 0:
		battle_player_attack_timer.stop()
		battle_enemy_attack_timer.stop()
		if battle_motion_tween:
			battle_motion_tween.pause()
		battle_locked_target = -1
		for target in battle_targets:
			target["marker"].visible = false
		battle_log.text = "旅人力竭倒下\n地基主守住最後一縷魂火\n休養 5 秒後自動返回巡行"
		var fall := create_tween()
		fall.tween_property(player_body, "rotation", 1.25, 0.35)
		fall.parallel().tween_property(player_body, "modulate:a", 0.45, 0.35)
		get_tree().create_timer(5.0).timeout.connect(_revive_player.bind(player_body, player_hp_bar, battle_log))


func _start_companion_rest(companion: Control, companion_hp_bar: ColorRect, companion_status: Label, battle_log: Label) -> void:
	battle_companion_resting = true
	if battle_companion_tween:
		battle_companion_tween.pause()
	companion_status.text = "休養中 60 秒　・　被動加成仍生效"
	battle_log.text = "地基主靈體受創，返回神龕休養\n暫停共鬥與傷害分擔\n離線、尋卡等被動能力仍然生效"
	var fade := create_tween()
	fade.tween_property(companion, "modulate:a", 0.08, 0.4)
	get_tree().create_timer(60.0).timeout.connect(_return_companion.bind(companion, companion_hp_bar, companion_status, battle_log))


func _return_companion(companion: Control, companion_hp_bar: ColorRect, companion_status: Label, battle_log: Label) -> void:
	if not is_instance_valid(companion):
		return
	battle_companion_hp = 60
	battle_companion_resting = false
	companion_hp_bar.size.x = 178.0
	companion_status.text = "共鬥中　HP 60／60　・　分擔 20%"
	var appear := create_tween()
	appear.tween_property(companion, "modulate:a", 0.34, 0.6)
	appear.finished.connect(_resume_companion_motion)
	battle_log.text = "地基主休養完成\n靈體已自動返回戰場\n共鬥、守契與傷害分擔重新啟用"


func _resume_companion_motion() -> void:
	if battle_companion_tween:
		battle_companion_tween.play()


func _revive_player(player_body: Control, player_hp_bar: ColorRect, battle_log: Label) -> void:
	if not is_instance_valid(player_body) or not is_instance_valid(battle_player_attack_timer):
		return
	battle_player_hp = 140
	player_hp_bar.size.x = 112.0
	player_body.rotation = 0.0
	player_body.modulate = Color.WHITE
	battle_log.text = "休養完成，返回霧隱古道\n生命已恢復　140／140\n自動巡行重新開始"
	battle_player_attack_timer.start()
	battle_enemy_attack_timer.start()
	if battle_motion_tween:
		battle_motion_tween.play()


func _resolve_battle_hit(attack_timer: Timer, damage_label: Label, battle_log: Label) -> void:
	var target_index := _choose_battle_target()
	if target_index == -1:
		return
	var target: Dictionary = battle_targets[target_index]
	var player_damage := randi_range(9, 14) + _equipped_power("武器")
	var spirit_damage := 0 if battle_companion_resting else randi_range(2, 4)
	battle_hit_counter += 1
	var purify_damage := 0
	var purify_level := _skill_level("淨符")
	if purify_level > 0 and battle_hit_counter % 4 == 0:
		purify_damage = 2 + purify_level * 2
	if spirit_damage > 0 and _skill_level("引魂燈") > 0 and randf() < 0.15:
		battle_player_hp = mini(140, battle_player_hp + 1)
		if is_instance_valid(battle_player_hp_bar_ref):
			battle_player_hp_bar_ref.size.x = 112.0 * float(battle_player_hp) / 140.0
	target["hp"] = maxi(0, int(target["hp"]) - player_damage - spirit_damage - purify_damage)
	var hp_bar: ColorRect = target["hp_bar"]
	hp_bar.size.x = float(target["bar_width"]) * float(target["hp"]) / float(target["max_hp"])
	damage_label.text = "斬擊 －%d" % player_damage
	battle_log.text = "鎖定：%s%s\n你造成 %d，地基主 %d%s\n剩餘 HP %d／%d" % [target["name"], "（手動）" if battle_locked_target == target_index else "（自動）", player_damage, spirit_damage, "，淨符追加 %d" % purify_damage if purify_damage > 0 else "", target["hp"], target["max_hp"]]
	battle_targets[target_index] = target
	if int(target["hp"]) == 0:
		_defeat_battle_target(target_index, battle_log)


func _defeat_battle_target(target_index: int, battle_log: Label) -> void:
	if target_index < 0 or target_index >= battle_targets.size():
		return
	var target: Dictionary = battle_targets[target_index]
	if not target.get("alive", false):
		return
	battle_kill_count += 1
	var defeated_boss := region_boss_active and target_index == region_boss_target_index
	_advance_rotating_tasks("boss" if defeated_boss else "kill")
	_advance_repeat_tasks("boss" if defeated_boss else "kill", int(target.get("level", 1)), str(target.get("name", "")))
	var gained_exp := randi_range(25, 35) if defeated_boss else randi_range(4, 7)
	var levels_gained := _grant_player_exp(gained_exp)
	var coins := randi_range(80, 120) if defeated_boss else int(round(randi_range(14, 24) * float(target.get("coin_mult", 1.0))))
	inventory_coins += coins
	var gained_pages := 5 if defeated_boss else 1
	if not defeated_boss and randf() < float(target.get("page_chance", 0.10)):
		gained_pages += 1
	inventory_pages += gained_pages
	if defeated_boss:
		region_boss_active = false
		region_boss_target_index = -1
		region_boss_badge.visible = false
	else:
		region_progress += 1
		_try_complete_first_region()
		if not region_boss_active and not region_boss_pending and randf() < REGION_BOSS_CHANCE:
			region_boss_pending = true
	_refresh_region_progress_label()
	var equipment_drop := ""
	var skill_book_drop := ""
	var card_drop := ""
	if not defeated_boss and randf() < SKILL_BOOK_DROP_CHANCE:
		skill_book_drop = _grant_random_bound_skill_book()
	var dropped_item := _try_region_equipment_drop(str(target.get("name", "")), defeated_boss)
	if not dropped_item.is_empty():
		equipment_drop = str(dropped_item["name"])
		inventory_equipment.append(dropped_item)
	card_drop = _try_drop_region_card(str(target.get("name", "")), defeated_boss)
	_save_persistent_progress()
	target["alive"] = false
	target["button"].disabled = true
	target["marker"].visible = false
	target["name_label"].visible = false
	target["hp_bar"].visible = false
	if battle_locked_target == target_index:
		battle_locked_target = -1
	if defeated_boss:
		battle_log.text = "送煞紙將已被鎮伏\n經驗 %d・銅錢 %d・殘頁 5%s%s%s\n霧隱古道調查循環已完成" % [gained_exp, coins, "・器物「%s」" % equipment_drop if equipment_drop != "" else "", "・卡片「%s」" % card_drop if card_drop != "" else "", "・升至 Lv.%d" % player_level if levels_gained > 0 else ""]
	else:
		battle_log.text = "%s已消散，鎖定解除\n經驗 %d・銅錢 %d・殘頁 %d%s%s%s%s\n%s" % [target["name"], gained_exp, coins, gained_pages, "・器物「%s」" % equipment_drop if equipment_drop != "" else "", "・卡片「%s」" % card_drop if card_drop != "" else "", "・%s" % skill_book_drop if skill_book_drop != "" else "", "・升至 Lv.%d" % player_level if levels_gained > 0 else "", "霧中傳來沉重腳步……" if region_boss_pending else "本次未驚動區域小頭目"]
		if not region_boss_pending and randf() < REGION_EVENT_CHANCE:
			_show_random_region_event(battle_log)
	var enemy: Control = target["body"]
	var vanish := create_tween()
	vanish.tween_property(enemy, "modulate:a", 0.0, 0.35)
	vanish.parallel().tween_property(enemy, "scale", Vector2(0.45, 0.45), 0.35)
	get_tree().create_timer(3.0).timeout.connect(_respawn_battle_enemy.bind(target_index, battle_log))
	battle_targets[target_index] = target


func _manual_cast_active_skill(battle_log: Label) -> void:
	if is_instance_valid(battle_active_skill_timer) and battle_active_skill_timer.is_stopped():
		_cast_active_skill(battle_log)


func _update_active_skill_state(battle_log: Label) -> void:
	if not is_instance_valid(battle_active_skill_timer) or not is_instance_valid(battle_active_skill_button):
		return
	if battle_player_hp <= 0 or _skill_level("敕符・淨煞") <= 0:
		battle_active_skill_button.disabled = true
		return
	if battle_active_skill_timer.is_stopped():
		battle_active_skill_button.text = "敕符・淨煞　可用"
		battle_active_skill_button.disabled = false
		if battle_active_skill_auto and _choose_battle_target() != -1:
			_cast_active_skill(battle_log)
	else:
		battle_active_skill_button.text = "敕符・淨煞　%.1f秒" % battle_active_skill_timer.time_left
		battle_active_skill_button.disabled = true


func _cast_active_skill(battle_log: Label) -> void:
	if not is_instance_valid(battle_active_skill_timer) or not battle_active_skill_timer.is_stopped():
		return
	var skill_level := _skill_level("敕符・淨煞")
	if skill_level <= 0:
		return
	var damage := 10 + skill_level * 3
	var hit_count := 0
	var defeated_indices: Array[int] = []
	for i in battle_targets.size():
		var target: Dictionary = battle_targets[i]
		if not target.get("alive", false):
			continue
		hit_count += 1
		target["hp"] = maxi(0, int(target["hp"]) - damage)
		var hp_bar: ColorRect = target["hp_bar"]
		hp_bar.size.x = float(target["bar_width"]) * float(target["hp"]) / float(target["max_hp"])
		var body: Control = target["body"]
		var struck := create_tween()
		struck.tween_property(body, "modulate", Color("d9cf86"), 0.08)
		struck.tween_property(body, "modulate", Color.WHITE, 0.20)
		battle_targets[i] = target
		if int(target["hp"]) == 0:
			defeated_indices.append(i)
	if hit_count == 0:
		return
	var flash := ColorRect.new()
	flash.position = Vector2(28, 112)
	flash.size = Vector2(484, 410)
	flash.color = Color("d9cf8666")
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.z_index = 20
	add_child(flash)
	var sweep := create_tween()
	sweep.tween_property(flash, "modulate:a", 0.0, 0.38)
	sweep.finished.connect(flash.queue_free)
	for defeated_index in defeated_indices:
		_defeat_battle_target(defeated_index, battle_log)
	battle_log.text = "主動技能・敕符淨煞\n符光掃過 %d 名敵人，各造成 %d 點傷害\n%s" % [hit_count, damage, "鎮散 %d 名鬼怪" % defeated_indices.size() if not defeated_indices.is_empty() else "冷卻 12 秒"]
	battle_active_skill_timer.start()


func _choose_battle_target() -> int:
	if battle_locked_target >= 0 and battle_locked_target < battle_targets.size() and battle_targets[battle_locked_target]["alive"]:
		return battle_locked_target
	var chosen := -1
	var oldest_order := 2147483647
	for i in battle_targets.size():
		if battle_targets[i]["alive"] and int(battle_targets[i]["spawn_order"]) < oldest_order:
			chosen = i
			oldest_order = int(battle_targets[i]["spawn_order"])
	return chosen


func _respawn_battle_enemy(index: int, battle_log: Label) -> void:
	if index < 0 or index >= battle_targets.size():
		return
	var target: Dictionary = battle_targets[index]
	var enemy: Control = target["body"]
	if not is_instance_valid(enemy):
		return
	var spawned_boss := false
	var escaped_boss := false
	if region_boss_pending and not region_boss_active:
		region_boss_pending = false
		if boss_policy == "escape" and escape_talismans > 0:
			escaped_boss = true
			escape_talismans -= 1
			target["name"] = target["normal_name"]
			target["name_label"].text = target["normal_name"]
			target["max_hp"] = target["normal_max_hp"]
			target["base_scale"] = target["normal_scale"]
			target["hp"] = target["max_hp"]
			region_progress_label.text = "已使用遁走符"
			battle_log.text = "察覺小頭目靠近\n自動消耗遁走符 1 張，避開本次遭遇\n剩餘遁走符：%d" % escape_talismans
			_save_persistent_progress()
		else:
			region_boss_active = true
			region_boss_target_index = index
			spawned_boss = true
			target["name"] = "送煞紙將"
			target["name_label"].text = "送煞紙將"
			target["max_hp"] = 180
			target["hp"] = 180
			target["damage_min"] = 5
			target["damage_max"] = 8
			target["coin_mult"] = 2.0
			target["page_chance"] = 1.0
			target["trait"] = "送煞重擊"
			target["base_scale"] = target["normal_scale"] * 1.45
			enemy.add_theme_stylebox_override("panel", _box(Color("692c28"), Color("d4aa62"), 3, 34))
			target["name_label"].add_theme_color_override("font_color", Color("e1bd72"))
			region_boss_badge.visible = true
			region_progress_label.text = "小頭目出現中"
			battle_log.text = "紙灰聚成巨大人形……\n區域小頭目「送煞紙將」現身\n%s" % ("巡行設定：優先鎖定小頭目" if boss_policy == "fight" else "遁走符不足，改為迎戰")
	else:
		if index != region_boss_target_index:
			var monster := _roll_region_monster()
			target["name"] = monster["name"]
			target["normal_name"] = monster["name"]
			target["name_label"].text = monster["name"]
			target["max_hp"] = monster["hp"]
			target["normal_max_hp"] = monster["hp"]
			target["level"] = monster["level"]
			target["damage_min"] = monster["damage_min"]
			target["damage_max"] = monster["damage_max"]
			target["coin_mult"] = monster["coin_mult"]
			target["page_chance"] = monster["page_chance"]
			target["trait"] = monster["trait"]
			var monster_scale := float(monster["scale"])
			target["base_scale"] = Vector2(monster_scale, monster_scale) * target["normal_scale"]
			enemy.add_theme_stylebox_override("panel", _box(Color(monster["color"]), Color("171713"), 2, 32))
			target["name_label"].add_theme_color_override("font_color", Color(monster["color"]).lightened(0.42))
		target["hp"] = target["max_hp"]
	target["alive"] = true
	target["button"].disabled = false
	target["name_label"].visible = true
	target["hp_bar"].visible = true
	enemy.modulate.a = 1.0
	enemy.scale = target["base_scale"]
	target["hp_bar"].size.x = target["bar_width"]
	target["spawn_order"] = battle_spawn_sequence
	battle_spawn_sequence += 1
	battle_targets[index] = target
	if spawned_boss:
		_lock_battle_target(index)
	if not escaped_boss and not (index == region_boss_target_index and region_boss_active):
		battle_log.text = "霧氣重新聚攏……\n%s加入戰場　・　%s\n已排入自動攻擊順序" % [target["name"], target.get("trait", "未知")]


func _roll_region_monster() -> Dictionary:
	var total_weight := 0
	for monster in REGION_MONSTERS:
		total_weight += int(monster["weight"])
	var roll := randi_range(1, total_weight)
	var cursor := 0
	for monster in REGION_MONSTERS:
		cursor += int(monster["weight"])
		if roll <= cursor:
			return monster.duplicate(true)
	return REGION_MONSTERS[0].duplicate(true)


func _try_region_equipment_drop(monster_name: String, defeated_boss: bool) -> Dictionary:
	var chance := 0.0
	var item: Dictionary = {}
	if defeated_boss:
		chance = 0.35
		item = {"name": "送煞令旗", "level": 0, "affix": "陰煞抵禦 +2", "slot": "護符", "power": 2, "equipped": false}
	else:
		match monster_name:
			"無面紙僕":
				chance = 0.12
				item = {"name": "紙灰道袍", "level": 0, "affix": "生命 +16", "slot": "防具", "power": 16, "equipped": false}
			"吊頸鬼影":
				chance = 0.12
				item = {"name": "引魂草鞋", "level": 0, "affix": "閃避 +1%", "slot": "防具", "power": 1, "equipped": false}
			"腐燈童子":
				chance = 0.14
				item = {"name": "鎮宅銅鈴", "level": 0, "affix": "尋卡 +1%", "slot": "護符", "power": 1, "equipped": false}
			"迷路陰兵":
				chance = 0.10
				item = {"name": "霧蝕短刀", "level": 0, "affix": "攻擊 +7", "slot": "武器", "power": 7, "equipped": false}
			"紙轎倀":
				chance = 0.16
				item = {"name": "褪色轎鈴", "level": 0, "affix": "尋卡 +1%", "slot": "護符", "power": 1, "equipped": false}
	if item.is_empty() or randf() >= chance:
		return {}
	return item


func _try_drop_region_card(monster_name: String, defeated_boss: bool) -> String:
	if monster_name == "":
		return ""
	var chance := 0.12 if defeated_boss else 0.04
	if randf() >= chance:
		return ""
	card_counts[monster_name] = int(card_counts.get(monster_name, 0)) + 1
	return monster_name


func _discovered_card_count() -> int:
	var discovered := 0
	for amount in card_counts.values():
		if int(amount) > 0:
			discovered += 1
	return discovered


func _region_card_discovered_count() -> int:
	var discovered := 0
	for card_name in ["無面紙僕", "吊頸鬼影", "腐燈童子", "迷路陰兵", "紙轎倀", "送煞紙將"]:
		if int(card_counts.get(card_name, 0)) > 0:
			discovered += 1
	return discovered


func _show_battle_settings() -> void:
	_show_patrol_settings()


func _show_patrol_settings() -> void:
	_enter_background_battle_mode()
	for child in get_children():
		child.queue_free()
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = INK
	add_child(background)
	var paper := Panel.new()
	paper.position = Vector2(12, 12)
	paper.size = Vector2(516, 936)
	paper.add_theme_stylebox_override("panel", _box(PAPER, Color("49382a"), 3, 14))
	add_child(paper)
	var back := Button.new()
	back.position = Vector2(28, 28)
	back.size = Vector2(82, 38)
	back.text = "← 出陣"
	back.add_theme_stylebox_override("normal", _box(Color("c5b17f"), RED, 2, 8))
	back.pressed.connect(_show_battle)
	add_child(back)
	_add_label("戰鬥設定", Rect2(126, 25, 230, 42), 26, RED)
	_add_label("巡行・頭目・異聞・技能", Rect2(280, 31, 226, 28), 13, GREEN, HORIZONTAL_ALIGNMENT_RIGHT)
	var line := ColorRect.new()
	line.position = Vector2(28, 82)
	line.size = Vector2(484, 3)
	line.color = RED
	add_child(line)

	var boss_panel := Panel.new()
	boss_panel.position = Vector2(28, 108)
	boss_panel.size = Vector2(484, 190)
	boss_panel.add_theme_stylebox_override("panel", _box(Color("c4b17e"), COPPER, 2, 10))
	add_child(boss_panel)
	_add_label("小頭目", Rect2(46, 120, 180, 30), 19, RED)
	_add_label("遇到小頭目", Rect2(46, 166, 160, 34), 15, INK)
	var boss_select := OptionButton.new()
	boss_select.position = Vector2(270, 160)
	boss_select.size = Vector2(218, 46)
	boss_select.add_item("優先討伐")
	boss_select.add_item("遁走符逃離")
	boss_select.select(0 if boss_policy == "fight" else 1)
	boss_select.item_selected.connect(_boss_policy_selected)
	add_child(boss_select)
	_add_label("遁走符", Rect2(46, 225, 130, 30), 15, INK)
	_add_label("%d 張" % escape_talismans, Rect2(350, 225, 138, 30), 16, RED, HORIZONTAL_ALIGNMENT_RIGHT)
	_add_label("不足時自動改為迎戰", Rect2(46, 258, 442, 24), 12, GREEN)

	var event_panel := Panel.new()
	event_panel.position = Vector2(28, 320)
	event_panel.size = Vector2(484, 230)
	event_panel.add_theme_stylebox_override("panel", _box(Color("c4b17e"), COPPER, 2, 10))
	add_child(event_panel)
	_add_label("異聞事件", Rect2(46, 332, 180, 30), 19, RED)
	_add_label("自動策略", Rect2(46, 382, 160, 34), 15, INK)
	var event_select := OptionButton.new()
	event_select.position = Vector2(270, 376)
	event_select.size = Vector2(218, 46)
	event_select.add_item("手動優先")
	event_select.add_item("收益優先")
	event_select.add_item("安全優先")
	event_select.add_item("保留資源")
	var event_keys := ["manual", "reward", "safety", "conserve"]
	event_select.select(maxi(0, event_keys.find(event_auto_policy)))
	event_select.item_selected.connect(_event_policy_selected)
	add_child(event_select)
	var current_event_description: String = {
		"manual": "等待 8 秒，逾時保持距離",
		"reward": "有足夠銅錢便自動焚香",
		"safety": "避開事件，不觸發善惡結果",
		"conserve": "不花銅錢，保持距離觀察"
	}.get(event_auto_policy, "等待玩家選擇") as String
	_add_label(current_event_description, Rect2(46, 438, 442, 28), 13, GREEN)
	_add_label("事件不會停止戰鬥，逾時會依設定自動處理。", Rect2(46, 494, 442, 28), 12, INK)

	var assist_panel := Panel.new()
	assist_panel.position = Vector2(28, 574)
	assist_panel.size = Vector2(484, 190)
	assist_panel.add_theme_stylebox_override("panel", _box(Color("b9a36f"), COPPER, 2, 10))
	add_child(assist_panel)
	_add_label("戰鬥輔助", Rect2(46, 586, 180, 30), 19, RED)
	_add_label("敕符・淨煞", Rect2(46, 628, 160, 34), 15, INK)
	var skill_select := OptionButton.new()
	skill_select.position = Vector2(270, 622)
	skill_select.size = Vector2(218, 46)
	skill_select.add_item("冷卻完成自動施放")
	skill_select.add_item("保留手動施放")
	skill_select.select(0 if battle_active_skill_auto else 1)
	skill_select.item_selected.connect(_active_skill_policy_selected)
	add_child(skill_select)
	_add_label("✓ 依出現順序自動選敵", Rect2(46, 682, 300, 28), 14, GREEN)
	_add_label("✓ 手動鎖定優先", Rect2(46, 716, 300, 28), 14, GREEN)


func _set_boss_policy(policy: String) -> void:
	boss_policy = policy
	_save_persistent_progress()
	_show_patrol_settings()


func _set_event_policy(policy: String) -> void:
	event_auto_policy = policy
	_save_persistent_progress()
	_show_patrol_settings()


func _boss_policy_selected(index: int) -> void:
	_set_boss_policy("fight" if index == 0 else "escape")


func _active_skill_policy_selected(index: int) -> void:
	battle_active_skill_auto = index == 0
	_save_persistent_progress()
	_show_patrol_settings()


func _event_policy_selected(index: int) -> void:
	var policies := ["manual", "reward", "safety", "conserve"]
	_set_event_policy(policies[clampi(index, 0, policies.size() - 1)])


func _show_shrine_event(battle_log: Label) -> void:
	if region_event_active:
		return
	region_event_active = true
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color("14110e99")
	shade.z_index = 20
	add_child(shade)
	var event_panel := Panel.new()
	event_panel.position = Vector2(42, 210)
	event_panel.size = Vector2(456, 430)
	event_panel.z_index = 21
	event_panel.add_theme_stylebox_override("panel", _box(PAPER, RED, 3, 14))
	add_child(event_panel)
	_add_event_label(event_panel, "異聞・無主香爐", Rect2(24, 22, 408, 42), 24, RED, HORIZONTAL_ALIGNMENT_CENTER)
	_add_event_label(event_panel, "荒廢的石階旁，一只香爐仍冒著細煙。\n香灰裡壓著幾張看不清字跡的黃紙。", Rect2(32, 82, 392, 92), 15, INK, HORIZONTAL_ALIGNMENT_CENTER)
	_add_event_label(event_panel, "善靈較常回應，但無主之鬼並非全然可信。", Rect2(32, 174, 392, 28), 12, GREEN, HORIZONTAL_ALIGNMENT_CENTER)
	var offer := Button.new()
	offer.position = Vector2(42, 228)
	offer.size = Vector2(372, 62)
	offer.text = "奉上 12 銅錢焚香　（結果未知）"
	offer.disabled = inventory_coins < 12
	offer.add_theme_color_override("font_color", PAPER)
	offer.add_theme_color_override("font_disabled_color", Color("8b806b"))
	offer.add_theme_stylebox_override("normal", _box(RED, Color("3a1815"), 2, 9))
	offer.pressed.connect(_resolve_shrine_event.bind(true, shade, event_panel, battle_log))
	event_panel.add_child(offer)
	var leave := Button.new()
	leave.position = Vector2(42, 310)
	leave.size = Vector2(372, 62)
	leave.text = "保持距離觀察　（風險較低）"
	leave.add_theme_stylebox_override("normal", _box(Color("c5b17f"), COPPER, 2, 9))
	leave.pressed.connect(_resolve_shrine_event.bind(false, shade, event_panel, battle_log))
	event_panel.add_child(leave)
	var auto_delay := 8.0 if event_auto_policy == "manual" else 1.0
	var auto_timer := get_tree().create_timer(auto_delay)
	auto_timer.timeout.connect(_auto_resolve_shrine_event.bind(shade, event_panel, battle_log))


func _show_random_region_event(battle_log: Label) -> void:
	match randi_range(0, 2):
		0:
			_show_shrine_event(battle_log)
		1:
			_show_reverse_sedan_event(battle_log)
		_:
			_show_abandoned_mine_cart_event(battle_log)


func _show_abandoned_mine_cart_event(battle_log: Label) -> void:
	if region_event_active:
		return
	region_event_active = true
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color("14110e99")
	shade.z_index = 20
	add_child(shade)
	var event_panel := Panel.new()
	event_panel.position = Vector2(42, 210)
	event_panel.size = Vector2(456, 430)
	event_panel.z_index = 21
	event_panel.add_theme_stylebox_override("panel", _box(PAPER, RED, 3, 14))
	add_child(event_panel)
	_add_event_label(event_panel, "異聞・倒行礦車", Rect2(24, 22, 408, 42), 24, RED, HORIZONTAL_ALIGNMENT_CENTER)
	_add_event_label(event_panel, "封閉礦道傳來生鏽輪軸聲，一輛無人礦車逆著坡道緩緩爬升。\n車斗裡堆著礦石，底下卻伸出沾滿煤灰的手。", Rect2(32, 76, 392, 112), 15, INK, HORIZONTAL_ALIGNMENT_CENTER)
	_add_event_label(event_panel, "拉下煞車可能救出受困亡魂，也可能驚醒坑底的東西。", Rect2(32, 184, 392, 34), 12, GREEN, HORIZONTAL_ALIGNMENT_CENTER)
	var brake := Button.new()
	brake.position = Vector2(42, 238)
	brake.size = Vector2(372, 62)
	brake.text = "拉下煞車　（收益與危險較高）"
	brake.add_theme_color_override("font_color", PAPER)
	brake.add_theme_stylebox_override("normal", _box(RED, Color("3a1815"), 2, 9))
	brake.pressed.connect(_resolve_abandoned_mine_cart_event.bind(true, shade, event_panel, battle_log))
	event_panel.add_child(brake)
	var avoid := Button.new()
	avoid.position = Vector2(42, 320)
	avoid.size = Vector2(372, 62)
	avoid.text = "退回石階　（風險較低）"
	avoid.add_theme_stylebox_override("normal", _box(Color("c5b17f"), COPPER, 2, 9))
	avoid.pressed.connect(_resolve_abandoned_mine_cart_event.bind(false, shade, event_panel, battle_log))
	event_panel.add_child(avoid)
	var auto_delay := 8.0 if event_auto_policy == "manual" else 1.0
	get_tree().create_timer(auto_delay).timeout.connect(_auto_resolve_abandoned_mine_cart_event.bind(shade, event_panel, battle_log))


func _resolve_abandoned_mine_cart_event(stopped_cart: bool, shade: ColorRect, event_panel: Panel, battle_log: Label) -> void:
	if not region_event_active:
		return
	var roll := randf()
	var summoned_boss := false
	if stopped_cart and roll < 0.58:
		var gained_coins := randi_range(28, 52)
		inventory_coins += gained_coins
		battle_log.text = "礦車停下後，煤灰手掌安靜縮回黑暗\n從碎礦中找到舊銅錢 %d\n遠處傳來一句模糊的道謝" % gained_coins
	elif stopped_cart and roll < 0.78:
		inventory_pages += 2
		battle_log.text = "車底壓著失蹤礦工留下的點名簿\n取得異聞殘頁 2\n其中幾個名字仍滲著潮濕墨跡"
	elif stopped_cart and roll < 0.94:
		event_debuff_hits = maxi(event_debuff_hits, 4)
		battle_log.text = "煞車把手突然自行彈回，礦車衝入濃霧\n煤灰纏住旅人的手腳\n接下來 4 次受擊額外承受 2 點傷害"
	elif stopped_cart:
		if not region_boss_active and not region_boss_pending:
			region_boss_pending = true
			summoned_boss = true
		battle_log.text = "礦車深處傳來沉重敲擊聲\n送煞紙將循著廢棄鐵軌逼近\n鎮伏後可取得較高報酬"
	elif roll < 0.86:
		battle_log.text = "你退回石階，礦車在霧中自行駛過\n本次沒有獎勵，也沒有損失\n鐵軌上只留下逆向拖行的痕跡"
	else:
		escape_talismans += 1
		battle_log.text = "礦車經過後，一張完整黃符黏在鐵軌旁\n取得遁走符 1 張\n也許是某位調查隊員留下的警告"
	_save_persistent_progress()
	region_event_active = false
	shade.queue_free()
	event_panel.queue_free()
	_show_event_result(battle_log.text, summoned_boss)


func _auto_resolve_abandoned_mine_cart_event(shade: ColorRect, event_panel: Panel, battle_log: Label) -> void:
	if not region_event_active or not is_instance_valid(event_panel):
		return
	if event_auto_policy == "safety" or event_auto_policy == "conserve":
		_resolve_abandoned_mine_cart_event(false, shade, event_panel, battle_log)
	else:
		_resolve_abandoned_mine_cart_event(event_auto_policy == "reward", shade, event_panel, battle_log)


func _show_reverse_sedan_event(battle_log: Label) -> void:
	if region_event_active:
		return
	region_event_active = true
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color("14110e99")
	shade.z_index = 20
	add_child(shade)
	var event_panel := Panel.new()
	event_panel.position = Vector2(42, 210)
	event_panel.size = Vector2(456, 430)
	event_panel.z_index = 21
	event_panel.add_theme_stylebox_override("panel", _box(PAPER, RED, 3, 14))
	add_child(event_panel)
	_add_event_label(event_panel, "異聞・金童玉女", Rect2(24, 22, 408, 42), 24, RED, HORIZONTAL_ALIGNMENT_CENTER)
	_add_event_label(event_panel, "霧中站著一對褪色的紙紮金童玉女。\n兩張臉笑得一模一樣，地上卻只有一道影子。", Rect2(32, 82, 392, 92), 15, INK, HORIZONTAL_ALIGNMENT_CENTER)
	_add_event_label(event_panel, "回應招手可能得到指引，也可能被帶往不該去的地方。", Rect2(32, 174, 392, 28), 12, GREEN, HORIZONTAL_ALIGNMENT_CENTER)
	var follow := Button.new()
	follow.position = Vector2(42, 228)
	follow.size = Vector2(372, 62)
	follow.text = "回應招手　（收益與危險較高）"
	follow.add_theme_color_override("font_color", PAPER)
	follow.add_theme_stylebox_override("normal", _box(RED, Color("3a1815"), 2, 9))
	follow.pressed.connect(_resolve_reverse_sedan_event.bind(true, shade, event_panel, battle_log))
	event_panel.add_child(follow)
	var yield_way := Button.new()
	yield_way.position = Vector2(42, 310)
	yield_way.size = Vector2(372, 62)
	yield_way.text = "低頭避開　（風險較低）"
	yield_way.add_theme_stylebox_override("normal", _box(Color("c5b17f"), COPPER, 2, 9))
	yield_way.pressed.connect(_resolve_reverse_sedan_event.bind(false, shade, event_panel, battle_log))
	event_panel.add_child(yield_way)
	var auto_delay := 8.0 if event_auto_policy == "manual" else 1.0
	get_tree().create_timer(auto_delay).timeout.connect(_auto_resolve_reverse_sedan_event.bind(shade, event_panel, battle_log))


func _resolve_reverse_sedan_event(followed: bool, shade: ColorRect, event_panel: Panel, battle_log: Label) -> void:
	if not region_event_active:
		return
	var roll := randf()
	var summoned_boss := false
	if followed and roll < 0.60:
		escape_talismans += 1
		battle_log.text = "金童玉女帶你走到一座無名孤墳前\n取得遁走符 1 張\n回頭時，兩尊紙紮像已經不見"
	elif followed and roll < 0.80:
		inventory_pages += 2
		battle_log.text = "玉女袖中落下兩張染濕的黃紙\n取得異聞殘頁 2\n金童仍站在霧中對你微笑"
	elif followed and roll < 0.95:
		event_debuff_hits = maxi(event_debuff_hits, 4)
		battle_log.text = "兩尊紙紮像同時轉頭，紙僕從霧中圍上\n接下來 4 次受擊額外承受 2 點傷害\n撐過後可繼續巡行"
	elif followed:
		if not region_boss_active and not region_boss_pending:
			region_boss_pending = true
			summoned_boss = true
		battle_log.text = "金童玉女牽起彼此的手，讓出身後道路\n特殊小頭目正循著紙灰靠近\n擊敗後可取得較高報酬"
	elif roll < 0.82:
		battle_log.text = "你低頭避開目光，金童玉女安靜退入霧中\n本次沒有獎勵，也沒有損失\n身後只留下兩排細小腳印"
	elif roll < 0.97:
		inventory_pages += 1
		battle_log.text = "玉女經過時，悄悄把一張紙條放在路旁\n取得異聞殘頁 1\n似乎是在答謝你的避讓"
	else:
		event_debuff_hits = maxi(event_debuff_hits, 3)
		battle_log.text = "金童玉女離去後，那道多餘的影子留在腳邊\n接下來 3 次受擊額外承受 2 點傷害\n不會造成永久損失"
	_save_persistent_progress()
	region_event_active = false
	shade.queue_free()
	event_panel.queue_free()
	_show_event_result(battle_log.text, summoned_boss)


func _auto_resolve_reverse_sedan_event(shade: ColorRect, event_panel: Panel, battle_log: Label) -> void:
	if not region_event_active or not is_instance_valid(event_panel):
		return
	if event_auto_policy == "safety":
		region_event_active = false
		battle_log.text = "自動策略：安全優先\n旅人沒有回應金童玉女的招手\n本次事件平安結束"
		shade.queue_free()
		event_panel.queue_free()
		_show_event_result(battle_log.text, false)
		return
	_resolve_reverse_sedan_event(event_auto_policy == "reward", shade, event_panel, battle_log)


func _add_event_label(parent: Control, text_value: String, rect: Rect2, font_size: int, color: Color, alignment: int) -> Label:
	var label := Label.new()
	label.position = rect.position
	label.size = rect.size
	label.text = text_value
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label


func _reveal_story_text(labels: Array[Label], action_button: Button) -> void:
	action_button.visible = false
	var reveal := create_tween()
	for label in labels:
		label.visible_ratio = 0.0
		var duration := clampf(float(label.text.length()) * 0.035, 0.7, 6.0)
		reveal.tween_property(label, "visible_ratio", 1.0, duration)
	reveal.finished.connect(_show_story_action.bind(action_button))


func _show_story_action(action_button: Button) -> void:
	if is_instance_valid(action_button):
		action_button.visible = true


func _resolve_shrine_event(offered_incense: bool, shade: ColorRect, event_panel: Panel, battle_log: Label) -> void:
	if not region_event_active:
		return
	_advance_rotating_tasks("event")
	if offered_incense:
		inventory_coins -= 12
	var roll := randf()
	var summoned_boss := false
	var good_limit := 0.65 if offered_incense else 0.55
	var neutral_limit := 0.85 if offered_incense else 0.82
	var bad_limit := 0.95 if offered_incense else 0.94
	var boss_limit := 0.99
	if roll < good_limit:
		var gained_pages := randi_range(1, 3)
		inventory_pages += gained_pages
		battle_log.text = "善靈收下香火，留下幾張完整黃紙\n取得異聞殘頁 %d\n真正的技能仍需透過技能書學習與升級" % gained_pages
	elif roll < neutral_limit:
		battle_log.text = "香煙安靜散去，沒有任何回應\n你記下這段民俗異聞\n本次沒有獎勵，也沒有損失"
	elif roll < bad_limit:
		event_debuff_hits = maxi(event_debuff_hits, 5)
		battle_log.text = "陰風吹滅香火，惡意纏上旅人\n接下來 5 次受擊額外承受 2 點傷害\n效果結束後不會留下永久損失"
	elif roll < boss_limit:
		if not region_boss_active and not region_boss_pending:
			region_boss_pending = true
			summoned_boss = true
		battle_log.text = "香爐下傳來沉重刮擦聲\n一隻隨機小頭目正循著香火靠近\n危險提高，但擊敗獎勵也會增加"
	else:
		event_debuff_hits = maxi(event_debuff_hits, 10)
		if not region_boss_active and not region_boss_pending:
			region_boss_pending = true
			summoned_boss = true
		battle_log.text = "特殊異聞・厲鬼索命\n厲鬼追跡並附加 10 次受擊詛咒\n撐過追擊可取得稀有輔助技能線索"
	_save_persistent_progress()
	region_event_active = false
	shade.queue_free()
	event_panel.queue_free()
	_show_event_result(battle_log.text, summoned_boss)


func _auto_resolve_shrine_event(shade: ColorRect, event_panel: Panel, battle_log: Label) -> void:
	if not region_event_active or not is_instance_valid(event_panel):
		return
	if event_auto_policy == "safety":
		_advance_rotating_tasks("event")
		region_event_active = false
		battle_log.text = "自動策略：安全優先\n旅人沒有接近無主香爐\n本次事件平安結束"
		shade.queue_free()
		event_panel.queue_free()
		_show_event_result(battle_log.text, false)
		return
	var should_offer := event_auto_policy == "reward" and inventory_coins >= 12
	_resolve_shrine_event(should_offer, shade, event_panel, battle_log)


func _show_event_result(result_text: String, summoned_boss: bool) -> void:
	var result_panel := Panel.new()
	result_panel.position = Vector2(54, 286)
	result_panel.size = Vector2(432, 300)
	result_panel.z_index = 30
	result_panel.add_theme_stylebox_override("panel", _box(PAPER, Color("b78b55") if summoned_boss else RED, 4, 14))
	add_child(result_panel)
	_add_event_label(result_panel, "凶兆降臨" if summoned_boss else "異聞結果", Rect2(22, 18, 388, 42), 24, RED, HORIZONTAL_ALIGNMENT_CENTER)
	_add_event_label(result_panel, result_text, Rect2(32, 76, 368, 132), 14, INK, HORIZONTAL_ALIGNMENT_CENTER)
	var close := Button.new()
	close.position = Vector2(106, 226)
	close.size = Vector2(220, 48)
	close.text = "迎接凶兆" if summoned_boss else "收下結果"
	close.add_theme_color_override("font_color", PAPER)
	close.add_theme_stylebox_override("normal", _box(RED, Color("3a1815"), 2, 8))
	close.pressed.connect(_dismiss_event_result.bind(result_panel))
	result_panel.add_child(close)
	get_tree().create_timer(4.0).timeout.connect(_dismiss_event_result.bind(result_panel))
	if summoned_boss:
		_play_ghost_laugh()
		_show_ghost_rush()


func _dismiss_event_result(result_panel: Panel) -> void:
	if is_instance_valid(result_panel):
		result_panel.queue_free()


func _show_ghost_rush() -> void:
	var ghost := Panel.new()
	ghost.position = Vector2(545, 196)
	ghost.size = Vector2(126, 220)
	ghost.z_index = 31
	ghost.modulate = Color(0.65, 0.78, 0.68, 0.72)
	ghost.add_theme_stylebox_override("panel", _box(Color("233a31"), Color("b9c68c"), 3, 58))
	add_child(ghost)
	var eyes := Label.new()
	eyes.position = Vector2(18, 38)
	eyes.size = Vector2(90, 62)
	eyes.text = "◉　◉"
	eyes.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	eyes.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	eyes.add_theme_font_size_override("font_size", 24)
	eyes.add_theme_color_override("font_color", Color("e5d688"))
	ghost.add_child(eyes)
	var rush := create_tween()
	rush.tween_property(ghost, "position", Vector2(-145, 328), 0.52).set_trans(Tween.TRANS_EXPO)
	rush.parallel().tween_property(ghost, "rotation", -0.28, 0.52)
	rush.tween_property(ghost, "modulate:a", 0.0, 0.18)
	rush.finished.connect(ghost.queue_free)


func _play_ghost_laugh() -> void:
	var sample_rate := 22050
	var duration := 0.85
	var frame_count := int(sample_rate * duration)
	var audio_data := PackedByteArray()
	audio_data.resize(frame_count * 2)
	for i in frame_count:
		var time := float(i) / float(sample_rate)
		var pulse := 0.35 + 0.65 * maxf(0.0, sin(TAU * 5.2 * time))
		var wobble := 145.0 + 38.0 * sin(TAU * 2.7 * time)
		var envelope := (1.0 - time / duration) * 0.34
		var sample := int(clampf(sin(TAU * wobble * time) * pulse * envelope, -1.0, 1.0) * 32767.0)
		audio_data.encode_s16(i * 2, sample)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = audio_data
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = -5.0
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()


func _show_inventory() -> void:
	_enter_background_battle_mode()
	if starter_equipment_tutorial_active:
		GameState.set_battle_view_active(true)
	for child in get_children():
		child.queue_free()
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = INK
	add_child(background)
	var paper := Panel.new()
	paper.position = Vector2(12, 12)
	paper.size = Vector2(516, 936)
	paper.add_theme_stylebox_override("panel", _box(PAPER, Color("49382a"), 3, 14))
	add_child(paper)
	var back := Button.new()
	back.position = Vector2(28, 28)
	back.size = Vector2(82, 38)
	back.text = "← 教學" if starter_equipment_tutorial_active else "← 出陣"
	back.add_theme_stylebox_override("normal", _box(Color("c5b17f"), RED, 2, 8))
	back.pressed.connect(_show_starter_equipment_tutorial if starter_equipment_tutorial_active else _show_battle)
	add_child(back)
	_add_label("旅人行囊", Rect2(126, 25, 230, 42), 26, RED)
	_add_label("%d／40 格" % inventory_equipment.size(), Rect2(340, 31, 118, 28), 14, GREEN, HORIZONTAL_ALIGNMENT_RIGHT)
	var line := ColorRect.new()
	line.position = Vector2(28, 84)
	line.size = Vector2(484, 3)
	line.color = RED
	add_child(line)
	var currency := Panel.new()
	currency.position = Vector2(28, 106)
	currency.size = Vector2(484, 86)
	currency.add_theme_stylebox_override("panel", _box(Color("b9a36f"), COPPER, 2, 9))
	add_child(currency)
	_add_label("銅錢", Rect2(46, 116, 100, 24), 14, GREEN)
	_add_label("%d" % inventory_coins, Rect2(46, 140, 170, 34), 22, RED)
	_add_label("異聞殘頁", Rect2(282, 116, 120, 24), 14, GREEN)
	_add_label("%d" % inventory_pages, Rect2(282, 140, 170, 34), 22, RED)
	_add_label("器物", Rect2(28, 214, 180, 30), 20, RED)
	_add_label("戰鬥掉落會直接存入行囊", Rect2(250, 218, 260, 24), 12, GREEN, HORIZONTAL_ALIGNMENT_RIGHT)
	for i in mini(inventory_equipment.size(), 8):
		var item: Dictionary = inventory_equipment[i]
		var row := i / 2
		var col := i % 2
		var slot := Panel.new()
		slot.position = Vector2(28 + col * 244, 258 + row * 132)
		slot.size = Vector2(228, 114)
		slot.add_theme_stylebox_override("panel", _box(Color("c4b17e"), RED if i == 0 else COPPER, 2, 8))
		add_child(slot)
		_add_label("＋%d" % item["level"], Rect2(slot.position + Vector2(12, 12), Vector2(52, 30)), 18, RED, HORIZONTAL_ALIGNMENT_CENTER)
		_add_label(item["name"], Rect2(slot.position + Vector2(72, 10), Vector2(144, 30)), 16, INK)
		_add_label(item["affix"], Rect2(slot.position + Vector2(72, 43), Vector2(144, 25)), 13, GREEN)
		_add_label("已裝備" if item.get("equipped", false) else "點選查看／裝備", Rect2(slot.position + Vector2(12, 78), Vector2(204, 23)), 12, RED if item.get("equipped", false) else Color("665b50"), HORIZONTAL_ALIGNMENT_CENTER)
		var item_button := Button.new()
		item_button.position = slot.position
		item_button.size = slot.size
		item_button.flat = true
		item_button.pressed.connect(_show_item_detail.bind(i))
		add_child(item_button)
	var material_item := Panel.new()
	material_item.position = Vector2(28, 790)
	material_item.size = Vector2(484, 44)
	material_item.add_theme_stylebox_override("panel", _box(Color("c4b17e"), COPPER, 2, 8))
	add_child(material_item)
	_add_label("特殊道具", Rect2(44, 799, 100, 26), 13, GREEN)
	_add_label("Boss 法印", Rect2(160, 799, 180, 26), 15, INK)
	_add_label("× %d" % int(skill_materials.get("Boss法印", 0)), Rect2(380, 799, 108, 26), 15, RED, HORIZONTAL_ALIGNMENT_RIGHT)
	var note := Panel.new()
	note.position = Vector2(28, 850)
	note.size = Vector2(484, 78)
	note.add_theme_stylebox_override("panel", _box(Color("b49d6d"), RED, 2, 10))
	add_child(note)
	_add_label("行囊規則", Rect2(44, 859, 120, 24), 15, RED)
	_add_label("裝備才可強化；卡片殘頁只用於覺醒，不占行囊格。", Rect2(44, 887, 440, 26), 13, INK)
	if starter_equipment_tutorial_active:
		var guide := Panel.new()
		guide.position = Vector2(34, 842)
		guide.size = Vector2(472, 82)
		guide.z_index = 20
		guide.add_theme_stylebox_override("panel", _box(Color("b9a36f"), RED, 3, 9))
		add_child(guide)
		if _starter_equipment_complete():
			var continue_button := Button.new()
			continue_button.position = Vector2(34, 12)
			continue_button.size = Vector2(404, 58)
			continue_button.text = "三個部位完成・返回住宅"
			continue_button.add_theme_color_override("font_color", PAPER)
			continue_button.add_theme_stylebox_override("normal", _box(GREEN, Color("22342b"), 2, 8))
			continue_button.pressed.connect(_return_home_for_dijizhu_purification)
			guide.add_child(continue_button)
		else:
			_add_event_label(guide, "點選行囊中的器物 → 查看詳情 → 裝備此器物", Rect2(18, 12, 436, 58), 14, RED, HORIZONTAL_ALIGNMENT_CENTER)
	_add_quick_menu(false, starter_equipment_tutorial_active)


func _show_tasks(selected_tab: String = "主線") -> void:
	_enter_background_battle_mode()
	_refresh_task_cycles()
	for child in get_children():
		child.queue_free()
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = INK
	add_child(background)
	var paper := Panel.new()
	paper.position = Vector2(12, 12)
	paper.size = Vector2(516, 936)
	paper.add_theme_stylebox_override("panel", _box(PAPER, Color("49382a"), 3, 14))
	add_child(paper)
	var back := Button.new()
	back.position = Vector2(28, 28)
	back.size = Vector2(82, 38)
	back.text = "← 出陣"
	back.add_theme_stylebox_override("normal", _box(Color("c5b17f"), RED, 2, 8))
	back.pressed.connect(_show_battle)
	add_child(back)
	_add_label("陰司差事簿", Rect2(126, 25, 260, 42), 26, RED)
	_add_label("巡行不因查看任務停止", Rect2(316, 31, 190, 28), 12, GREEN, HORIZONTAL_ALIGNMENT_RIGHT)
	var divider := ColorRect.new()
	divider.position = Vector2(28, 84)
	divider.size = Vector2(484, 3)
	divider.color = RED
	add_child(divider)
	var tabs := ["主線", "可接差事", "進行中"]
	for i in tabs.size():
		var tab := Button.new()
		tab.position = Vector2(28 + i * 163, 106)
		tab.size = Vector2(154, 42)
		tab.text = tabs[i]
		tab.add_theme_color_override("font_color", PAPER if tabs[i] == selected_tab else INK)
		tab.add_theme_stylebox_override("normal", _box(RED if tabs[i] == selected_tab else Color("c5b17f"), RED, 2, 8))
		tab.pressed.connect(_show_tasks.bind(tabs[i]))
		add_child(tab)
	if selected_tab == "主線":
		_build_main_tasks()
	elif selected_tab == "可接差事":
		_build_repeat_task_offers()
	elif selected_tab == "進行中":
		_build_active_repeat_tasks()
	else:
		_build_repeat_task_offers()


func _on_task_scroll_input(event: InputEvent, click_timer: Timer, target_tab: String) -> void:
	if not event is InputEventMouseButton:
		return
	var mouse_event := event as InputEventMouseButton
	if mouse_event.button_index != MOUSE_BUTTON_LEFT or not mouse_event.pressed:
		return
	if mouse_event.double_click:
		click_timer.stop()
		_show_tasks(target_tab)
	else:
		click_timer.start()


func _toggle_task_tracker(task_panel: Panel, task_title: Label, task_status: Label, has_tracked_task: bool) -> void:
	task_tracker_collapsed = not task_tracker_collapsed
	task_panel.visible = not task_tracker_collapsed and has_tracked_task
	task_title.visible = not task_tracker_collapsed and has_tracked_task
	task_status.visible = not task_tracker_collapsed and has_tracked_task
	_save_persistent_progress()


func _build_main_tasks() -> void:
	var panel := Panel.new()
	panel.position = Vector2(28, 174)
	panel.size = Vector2(484, 238)
	panel.add_theme_stylebox_override("panel", _box(Color("c1ad78"), RED, 2, 10))
	add_child(panel)
	_add_label("第一章・翠光下的引渡人", Rect2(46, 192, 320, 30), 20, RED)
	_add_label("霧隱古道初探", Rect2(46, 232, 250, 28), 17, INK)
	_add_label("鎮伏受翠光侵染的鬼怪，查明紙灰逆流的源頭。", Rect2(46, 266, 430, 44), 13, GREEN)
	_add_label("進度　%d／%d" % [mini(region_progress, REGION_COMPLETION_KILLS), REGION_COMPLETION_KILLS], Rect2(46, 320, 220, 30), 16, RED)
	_add_label("獎勵　銅錢 500・殘頁 20・綁定技能書 1", Rect2(46, 354, 430, 28), 13, INK)
	var claim := Button.new()
	claim.position = Vector2(344, 316)
	claim.size = Vector2(142, 58)
	claim.text = "已領取" if region_reward_claimed else ("領取獎勵" if region_progress >= REGION_COMPLETION_KILLS else "尚未達成")
	claim.disabled = region_reward_claimed or region_progress < REGION_COMPLETION_KILLS
	claim.add_theme_color_override("font_color", PAPER)
	claim.add_theme_stylebox_override("normal", _box(RED, Color("3a1815"), 2, 8))
	claim.pressed.connect(_claim_region_reward_from_tasks)
	add_child(claim)
	_add_label("主線任務不刷新，會依等級、劇情與區域進度逐步開放。", Rect2(40, 438, 460, 32), 13, GREEN, HORIZONTAL_ALIGNMENT_CENTER)


func _claim_region_reward_from_tasks() -> void:
	var skill_book_reward := _claim_region_reward()
	if skill_book_reward == "":
		return
	_show_tasks("主線")
	_show_event_result("主線完成・霧隱古道初探\n獲得銅錢 500・殘頁 20\n%s" % skill_book_reward, false)


func _task_refresh_cost(refreshes: int, weekly: bool) -> int:
	if refreshes < 3:
		return 0
	return (500 if weekly else 100) * int(pow(2, mini(refreshes - 3, 6)))


func _build_repeat_task_offers() -> void:
	_add_label("重複差事・三選一", Rect2(30, 172, 280, 34), 20, RED)
	_add_label("進行中 %d／3" % active_repeat_tasks.size(), Rect2(330, 176, 172, 28), 13, GREEN, HORIZONTAL_ALIGNMENT_RIGHT)
	var tier_names := ["", "尋常", "進階", "凶險", "厄境", "異兆"]
	for i in repeat_task_offers.size():
		var offer: Dictionary = repeat_task_offers[i]
		var tier := int(offer.get("tier", 1))
		var card := Panel.new()
		card.position = Vector2(28, 220 + i * 150)
		card.size = Vector2(484, 130)
		card.add_theme_stylebox_override("panel", _box(Color("c1ad78"), RED if tier >= 4 else COPPER, 2, 9))
		add_child(card)
		_add_label(str(offer.get("name", "陰司差事")), Rect2(46, 232 + i * 150, 300, 28), 17, INK)
		_add_label("第五階・地區頭目" if tier == 5 else "難度・%s" % tier_names[tier], Rect2(330, 232 + i * 150, 155, 28), 13, RED, HORIZONTAL_ALIGNMENT_RIGHT)
		_add_label("目標數量 %d　有效怪物 Lv.%d 以上" % [int(offer.get("target", 1)), int(offer.get("min_level", 1))] if tier < 5 else "指定頭目 %s ×%d" % [str(offer.get("boss_name", "")), int(offer.get("target", 1))], Rect2(46, 268 + i * 150, 310, 25), 13, GREEN)
		_add_label("獎勵　經驗 %d・銅錢 %d%s" % [int(offer.get("reward_exp", 0)), int(offer.get("reward_coins", 0)), "・稀有材料機會" if bool(offer.get("rare_material", false)) else ""], Rect2(46, 300 + i * 150, 330, 25), 12, RED)
		var accept := Button.new()
		accept.position = Vector2(382, 274 + i * 150)
		accept.size = Vector2(104, 48)
		accept.text = "接取"
		accept.disabled = active_repeat_tasks.size() >= 3
		accept.add_theme_color_override("font_color", PAPER)
		accept.add_theme_stylebox_override("normal", _box(GREEN, Color("22342b"), 2, 7))
		accept.pressed.connect(_accept_repeat_task.bind(i))
		add_child(accept)
	var cost := _task_refresh_cost(repeat_task_refreshes, false)
	var refresh := Button.new()
	refresh.position = Vector2(120, 700)
	refresh.size = Vector2(300, 54)
	refresh.text = "刷新三個選項・免費" if cost == 0 else "刷新三個選項・銅錢 %d" % cost
	refresh.disabled = active_repeat_tasks.size() >= 3
	refresh.add_theme_color_override("font_color", PAPER)
	refresh.add_theme_stylebox_override("normal", _box(RED, Color("3a1815"), 2, 8))
	refresh.pressed.connect(_refresh_repeat_task_offers)
	add_child(refresh)
	_add_label("每日午夜重置刷新價格；高獎勵與頭目差事出現率極低。", Rect2(40, 778, 460, 38), 12, GREEN, HORIZONTAL_ALIGNMENT_CENTER)


func _accept_repeat_task(offer_index: int) -> void:
	if active_repeat_tasks.size() >= 3 or offer_index < 0 or offer_index >= repeat_task_offers.size():
		return
	active_repeat_tasks.append(repeat_task_offers[offer_index].duplicate(true))
	repeat_task_offers.clear()
	_save_persistent_progress()
	_show_tasks("進行中")


func _refresh_repeat_task_offers() -> void:
	var cost := _task_refresh_cost(repeat_task_refreshes, false)
	if inventory_coins < cost:
		_show_event_result("銅錢不足\n本次刷新需要銅錢 %d" % cost, false)
		return
	inventory_coins -= cost
	repeat_task_refreshes += 1
	repeat_task_offers = _generate_repeat_task_offers()
	_save_persistent_progress()
	_show_tasks("可接差事")


func _build_active_repeat_tasks() -> void:
	_add_label("進行中的重複差事", Rect2(30, 172, 300, 34), 20, RED)
	_add_label("%d／3" % active_repeat_tasks.size(), Rect2(400, 176, 100, 28), 14, GREEN, HORIZONTAL_ALIGNMENT_RIGHT)
	if active_repeat_tasks.is_empty():
		_add_label("目前沒有進行中的差事。\n前往「可接差事」刷新三個選項。", Rect2(60, 300, 420, 100), 16, GREEN, HORIZONTAL_ALIGNMENT_CENTER)
		return
	for i in active_repeat_tasks.size():
		var task: Dictionary = active_repeat_tasks[i]
		var card := Panel.new()
		card.position = Vector2(28, 220 + i * 170)
		card.size = Vector2(484, 150)
		card.add_theme_stylebox_override("panel", _box(Color("c1ad78"), RED, 2, 9))
		add_child(card)
		_add_label(str(task.get("name", "陰司差事")), Rect2(46, 232 + i * 170, 300, 28), 17, INK)
		_add_label("進度　%d／%d" % [int(task.get("progress", 0)), int(task.get("target", 1))], Rect2(46, 270 + i * 170, 220, 28), 15, GREEN)
		_add_label("獎勵　經驗 %d・銅錢 %d" % [int(task.get("reward_exp", 0)), int(task.get("reward_coins", 0))], Rect2(46, 306 + i * 170, 300, 25), 12, RED)
		var done := int(task.get("progress", 0)) >= int(task.get("target", 1))
		var action := Button.new()
		action.position = Vector2(370, 250 + i * 170)
		action.size = Vector2(116, 48)
		action.text = "領取" if done else "放棄"
		action.add_theme_color_override("font_color", PAPER)
		action.add_theme_stylebox_override("normal", _box(GREEN if done else RED, Color("3a1815"), 2, 7))
		action.pressed.connect((_claim_repeat_task if done else _request_abandon_repeat_task).bind(i))
		add_child(action)


func _claim_repeat_task(task_index: int) -> void:
	if task_index < 0 or task_index >= active_repeat_tasks.size(): return
	var task := active_repeat_tasks[task_index]
	if int(task.get("progress", 0)) < int(task.get("target", 1)): return
	var gained_exp := int(task.get("reward_exp", 0))
	var gained_coins := int(task.get("reward_coins", 0))
	_grant_player_exp(gained_exp)
	inventory_coins += gained_coins
	if bool(task.get("rare_material", false)):
		skill_materials["Boss法印"] = int(skill_materials.get("Boss法印", 0)) + 1
	active_repeat_tasks.remove_at(task_index)
	_save_persistent_progress()
	_show_tasks("進行中")
	_show_event_result("重複差事完成\n獲得經驗 %d・銅錢 %d%s" % [gained_exp, gained_coins, "・Boss 法印 1" if bool(task.get("rare_material", false)) else ""], false)


func _request_abandon_repeat_task(task_index: int) -> void:
	if task_index < 0 or task_index >= active_repeat_tasks.size():
		return
	var task: Dictionary = active_repeat_tasks[task_index]
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color("171713b8")
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	shade.z_index = 40
	add_child(shade)
	var confirm_panel := Panel.new()
	confirm_panel.position = Vector2(48, 264)
	confirm_panel.size = Vector2(444, 380)
	confirm_panel.z_index = 41
	confirm_panel.add_theme_stylebox_override("panel", _box(PAPER, RED, 4, 14))
	add_child(confirm_panel)
	_add_event_label(confirm_panel, "確認放棄差事", Rect2(24, 22, 396, 42), 24, RED, HORIZONTAL_ALIGNMENT_CENTER)
	_add_event_label(confirm_panel, str(task.get("name", "陰司差事")), Rect2(30, 88, 384, 36), 18, INK, HORIZONTAL_ALIGNMENT_CENTER)
	_add_event_label(confirm_panel, "目前進度　%d／%d" % [int(task.get("progress", 0)), int(task.get("target", 1))], Rect2(30, 132, 384, 30), 15, GREEN, HORIZONTAL_ALIGNMENT_CENTER)
	var warning_panel := Panel.new()
	warning_panel.position = Vector2(24, 184)
	warning_panel.size = Vector2(396, 92)
	warning_panel.add_theme_stylebox_override("panel", _box(Color("b9a36f"), COPPER, 2, 9))
	confirm_panel.add_child(warning_panel)
	_add_event_label(warning_panel, "放棄後目前進度將失去，且不退還刷新費用。", Rect2(18, 18, 360, 56), 14, RED, HORIZONTAL_ALIGNMENT_CENTER)
	var cancel := Button.new()
	cancel.position = Vector2(28, 300)
	cancel.size = Vector2(176, 54)
	cancel.text = "保留差事"
	cancel.add_theme_stylebox_override("normal", _box(Color("c5b17f"), COPPER, 2, 9))
	cancel.pressed.connect(_dismiss_skill_exchange_confirmation.bind(shade, confirm_panel))
	confirm_panel.add_child(cancel)
	var confirm := Button.new()
	confirm.position = Vector2(216, 300)
	confirm.size = Vector2(200, 54)
	confirm.text = "確認放棄"
	confirm.add_theme_color_override("font_color", PAPER)
	confirm.add_theme_stylebox_override("normal", _box(RED, Color("3a1815"), 3, 9))
	confirm.pressed.connect(_confirm_abandon_repeat_task.bind(task_index, shade, confirm_panel))
	confirm_panel.add_child(confirm)


func _confirm_abandon_repeat_task(task_index: int, shade: ColorRect, confirm_panel: Panel) -> void:
	if task_index < 0 or task_index >= active_repeat_tasks.size():
		_dismiss_skill_exchange_confirmation(shade, confirm_panel)
		return
	active_repeat_tasks.remove_at(task_index)
	_save_persistent_progress()
	_dismiss_skill_exchange_confirmation(shade, confirm_panel)
	_show_tasks("進行中")


func _build_rotating_tasks(task_type: String) -> void:
	var weekly := task_type == "每週"
	var refreshes := weekly_task_refreshes if weekly else daily_task_refreshes
	var cost := _task_refresh_cost(refreshes, weekly)
	var task_list: Array[Dictionary] = weekly_tasks if weekly else daily_tasks
	_add_label("%s差事・第 %d 批" % [task_type, refreshes + 1], Rect2(30, 172, 280, 34), 20, RED)
	_add_label("剩餘免費刷新 %d 次" % maxi(3 - refreshes, 0), Rect2(292, 176, 210, 28), 13, GREEN, HORIZONTAL_ALIGNMENT_RIGHT)
	var difficulty_names := ["尋常", "進階", "凶險"]
	for i in task_list.size():
		var task: Dictionary = task_list[i]
		var difficulty := int(task.get("difficulty", 0))
		var card := Panel.new()
		card.position = Vector2(28, 220 + i * 154)
		card.size = Vector2(484, 134)
		card.add_theme_stylebox_override("panel", _box(Color("c1ad78"), [COPPER, GREEN, RED][difficulty], 2, 9))
		add_child(card)
		_add_label(str(task.get("name", "陰司差事")), Rect2(46, 232 + i * 154, 300, 30), 17, INK)
		_add_label("難度・%s" % difficulty_names[difficulty], Rect2(350, 232 + i * 154, 135, 28), 14, [COPPER, GREEN, RED][difficulty], HORIZONTAL_ALIGNMENT_RIGHT)
		var progress := int(task.get("progress", 0))
		var target := int(task.get("target", 1))
		_add_label("進度　%d／%d" % [progress, target], Rect2(46, 272 + i * 154, 180, 26), 14, GREEN)
		_add_label("獎勵　銅錢 %d・殘頁 %d" % [int(task.get("reward_coins", 0)), int(task.get("reward_pages", 0))], Rect2(46, 304 + i * 154, 300, 26), 13, RED)
		var claim := Button.new()
		claim.position = Vector2(370, 276 + i * 154)
		claim.size = Vector2(116, 48)
		claim.text = "已領取" if bool(task.get("claimed", false)) else ("領取" if progress >= target else "進行中")
		claim.disabled = bool(task.get("claimed", false)) or progress < target
		claim.add_theme_color_override("font_color", PAPER)
		claim.add_theme_stylebox_override("normal", _box(RED, Color("3a1815"), 2, 7))
		claim.pressed.connect(_claim_rotating_task.bind(task_type, i))
		add_child(claim)
	var refresh := Button.new()
	refresh.position = Vector2(120, 712)
	refresh.size = Vector2(300, 54)
	refresh.text = "刷新差事・免費" if cost == 0 else "刷新差事・銅錢 %d" % cost
	refresh.add_theme_color_override("font_color", PAPER)
	refresh.add_theme_stylebox_override("normal", _box(GREEN, Color("22342b"), 2, 8))
	refresh.pressed.connect(_refresh_rotating_tasks.bind(task_type))
	add_child(refresh)
	_add_label("前三次免費；之後費用逐次提高，週期重置時恢復。", Rect2(40, 782, 460, 28), 13, GREEN, HORIZONTAL_ALIGNMENT_CENTER)
	_add_label("每日於隔日重置；每週於新週期重置。刷新會更換難度與獎勵。", Rect2(40, 816, 460, 44), 12, INK, HORIZONTAL_ALIGNMENT_CENTER)


func _refresh_rotating_tasks(task_type: String) -> void:
	var weekly := task_type == "每週"
	var refreshes := weekly_task_refreshes if weekly else daily_task_refreshes
	var cost := _task_refresh_cost(refreshes, weekly)
	if inventory_coins < cost:
		_show_event_result("銅錢不足\n本次刷新需要銅錢 %d" % cost, false)
		return
	inventory_coins -= cost
	if weekly:
		weekly_task_refreshes += 1
		weekly_tasks = _generate_task_set(true, weekly_task_refreshes)
	else:
		daily_task_refreshes += 1
		daily_tasks = _generate_task_set(false, daily_task_refreshes)
	_save_persistent_progress()
	_show_tasks(task_type)


func _claim_rotating_task(task_type: String, task_index: int) -> void:
	var weekly := task_type == "每週"
	var task_list: Array[Dictionary] = weekly_tasks if weekly else daily_tasks
	if task_index < 0 or task_index >= task_list.size():
		return
	var task: Dictionary = task_list[task_index]
	if bool(task.get("claimed", false)) or int(task.get("progress", 0)) < int(task.get("target", 1)):
		return
	var reward_coins := int(task.get("reward_coins", 0))
	var reward_pages := int(task.get("reward_pages", 0))
	inventory_coins += reward_coins
	inventory_pages += reward_pages
	task["claimed"] = true
	task_list[task_index] = task
	if weekly:
		weekly_tasks = task_list
	else:
		daily_tasks = task_list
	_save_persistent_progress()
	_show_tasks(task_type)
	_show_event_result("%s差事完成・%s\n獲得銅錢 %d・殘頁 %d" % [task_type, str(task.get("name", "")), reward_coins, reward_pages], false)


func _show_skills() -> void:
	_enter_background_battle_mode()
	for child in get_children():
		child.queue_free()
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = INK
	add_child(background)
	var paper := Panel.new()
	paper.position = Vector2(12, 12)
	paper.size = Vector2(516, 936)
	paper.add_theme_stylebox_override("panel", _box(PAPER, Color("49382a"), 3, 14))
	add_child(paper)
	var back := Button.new()
	back.position = Vector2(28, 28)
	back.size = Vector2(82, 38)
	back.text = "← 出陣"
	back.add_theme_stylebox_override("normal", _box(Color("c5b17f"), RED, 2, 8))
	back.pressed.connect(_show_battle)
	add_child(back)
	_add_label("引渡人・技能", Rect2(126, 25, 260, 42), 26, RED)
	var level_header := "Lv.80・開發試煉" if GameState.developer_test_mode else ("Lv.10・轉職條件達成" if player_level >= 10 else "Lv.%d・轉職條件 Lv.10" % player_level)
	_add_label(level_header, Rect2(300, 31, 206, 28), 13, RED if GameState.developer_test_mode or player_level >= 10 else GREEN, HORIZONTAL_ALIGNMENT_RIGHT)
	var line := ColorRect.new()
	line.position = Vector2(28, 84)
	line.size = Vector2(484, 3)
	line.color = RED
	add_child(line)
	_add_label("基礎淨化術", Rect2(30, 108, 220, 32), 20, RED)
	var developer_trial := Button.new()
	developer_trial.position = Vector2(374, 104)
	developer_trial.size = Vector2(132, 34)
	developer_trial.text = "開發試煉 Lv.80"
	developer_trial.add_theme_font_size_override("font_size", 12)
	developer_trial.add_theme_stylebox_override("normal", _box(Color("657265"), GREEN, 2, 7))
	developer_trial.pressed.connect(_show_developer_trial)
	add_child(developer_trial)
	var ink_exchange := Button.new()
	ink_exchange.position = Vector2(236, 104)
	ink_exchange.size = Vector2(132, 34)
	ink_exchange.text = "殘墨兌換所"
	ink_exchange.add_theme_font_size_override("font_size", 12)
	ink_exchange.add_theme_stylebox_override("normal", _box(Color("c5b17f"), RED, 2, 7))
	ink_exchange.pressed.connect(_show_skill_ink_exchange)
	add_child(ink_exchange)
	_add_label("同名技能書用於解鎖與升級，不累積戰鬥熟練度。", Rect2(30, 142, 470, 28), 13, GREEN)
	for i in novice_skills.size():
		var skill: Dictionary = novice_skills[i]
		var panel := Panel.new()
		panel.position = Vector2(30, 180 + i * 145)
		panel.size = Vector2(480, 132)
		panel.add_theme_stylebox_override("panel", _box(Color("c4b17e") if skill["unlocked"] else Color("aaa078"), RED if skill["unlocked"] else COPPER, 2, 10))
		add_child(panel)
		_add_label(skill["name"], Rect2(panel.position + Vector2(18, 12), Vector2(210, 34)), 21, RED if skill["unlocked"] else Color("665b50"))
		_add_label("%s　｜　Lv.%d" % [skill["type"], skill["level"]], Rect2(panel.position + Vector2(300, 14), Vector2(160, 30)), 14, GREEN, HORIZONTAL_ALIGNMENT_RIGHT)
		_add_label(skill["description"], Rect2(panel.position + Vector2(18, 48), Vector2(444, 44)), 12, INK)
		_add_label("技能書　%d／%d" % [skill["books"], skill["need"]], Rect2(panel.position + Vector2(18, 101), Vector2(210, 24)), 12, GREEN)
		var enhance_skill := Button.new()
		enhance_skill.position = panel.position + Vector2(350, 96)
		enhance_skill.size = Vector2(110, 29)
		enhance_skill.text = "前往強化" if skill["unlocked"] else "尚未學會"
		enhance_skill.disabled = not skill["unlocked"]
		enhance_skill.add_theme_font_size_override("font_size", 12)
		enhance_skill.add_theme_stylebox_override("normal", _box(RED, Color("3a1815"), 2, 7))
		enhance_skill.add_theme_color_override("font_color", PAPER)
		enhance_skill.pressed.connect(_show_skill_enhance.bind(i, ""))
		add_child(enhance_skill)
	var note := Panel.new()
	note.position = Vector2(30, 770)
	note.size = Vector2(480, 128)
	note.add_theme_stylebox_override("panel", _box(Color("b9a36f"), COPPER, 2, 10))
	add_child(note)
	_add_label("引渡人的責任", Rect2(46, 782, 180, 28), 17, RED)
	_add_label("先學會淨化、引魂與安魂。達到 Lv.10 並完成陰差試煉後，才可選擇正式職業。", Rect2(46, 818, 440, 58), 14, INK)


func _show_skill_ink_exchange() -> void:
	_enter_background_battle_mode()
	for child in get_children():
		child.queue_free()
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = INK
	add_child(background)
	var paper := Panel.new()
	paper.position = Vector2(12, 12)
	paper.size = Vector2(516, 936)
	paper.add_theme_stylebox_override("panel", _box(PAPER, Color("49382a"), 3, 14))
	add_child(paper)
	var back := Button.new()
	back.position = Vector2(28, 28)
	back.size = Vector2(82, 38)
	back.text = "← 技能"
	back.add_theme_stylebox_override("normal", _box(Color("c5b17f"), RED, 2, 8))
	back.pressed.connect(_show_skills)
	add_child(back)
	_add_label("法脈殘墨兌換所", Rect2(126, 25, 300, 42), 25, RED)
	_add_label("孟婆・殘卷回收", Rect2(348, 31, 158, 28), 13, GREEN, HORIZONTAL_ALIGNMENT_RIGHT)
	var line := ColorRect.new()
	line.position = Vector2(28, 84)
	line.size = Vector2(484, 3)
	line.color = RED
	add_child(line)
	_add_label("拆解 1 本同階技能書可得殘墨 ×1；隨機兌換 15，指定兌換 30。", Rect2(30, 104, 480, 46), 13, GREEN, HORIZONTAL_ALIGNMENT_CENTER)

	var qualities := ["普通", "稀有", "高階"]
	var tier_colors := [GREEN, Color("765a86"), RED]
	for tier_index in qualities.size():
		var quality: String = qualities[tier_index]
		var material_name := _material_for_quality(quality)
		var panel := Panel.new()
		panel.position = Vector2(28, 158 + tier_index * 184)
		panel.size = Vector2(484, 166)
		panel.add_theme_stylebox_override("panel", _box(Color("c4b17e"), tier_colors[tier_index], 2, 10))
		add_child(panel)
		_add_label("%s法脈" % quality, Rect2(panel.position + Vector2(18, 12), Vector2(160, 30)), 19, tier_colors[tier_index])
		_add_label("%s　%d" % [material_name, int(skill_materials.get(material_name, 0))], Rect2(panel.position + Vector2(180, 14), Vector2(280, 28)), 14, INK, HORIZONTAL_ALIGNMENT_RIGHT)
		var skill_select := OptionButton.new()
		skill_select.position = panel.position + Vector2(18, 52)
		skill_select.size = Vector2(190, 42)
		for skill_index in _skills_of_quality(quality, true, false):
			skill_select.add_item("%s（持有 %d）" % [novice_skills[skill_index]["name"], novice_skills[skill_index]["books"]])
			skill_select.set_item_metadata(skill_select.item_count - 1, skill_index)
		var remembered_index := int(exchange_selected_skill_by_quality.get(quality, -1))
		for option_index in skill_select.item_count:
			if int(skill_select.get_item_metadata(option_index)) == remembered_index:
				skill_select.select(option_index)
				break
		add_child(skill_select)
		var dismantle_amount := SpinBox.new()
		dismantle_amount.position = panel.position + Vector2(216, 52)
		dismantle_amount.size = Vector2(92, 42)
		dismantle_amount.min_value = 1
		dismantle_amount.max_value = maxi(1, _selected_skill_book_count(skill_select))
		dismantle_amount.value = 1
		dismantle_amount.step = 1
		dismantle_amount.allow_greater = false
		dismantle_amount.allow_lesser = false
		add_child(dismantle_amount)
		if skill_select.item_count > 0:
			exchange_selected_skill_by_quality[quality] = _selected_skill_index(skill_select)
		skill_select.item_selected.connect(_remember_exchange_skill_selection.bind(quality, skill_select, dismantle_amount))
		var dismantle := Button.new()
		dismantle.position = panel.position + Vector2(316, 52)
		dismantle.size = Vector2(150, 42)
		dismantle.text = "拆解所選數量"
		dismantle.disabled = skill_select.item_count == 0
		dismantle.pressed.connect(_dismantle_selected_skill_book.bind(quality, skill_select, dismantle_amount))
		add_child(dismantle)
		var random_exchange := Button.new()
		random_exchange.position = panel.position + Vector2(18, 108)
		random_exchange.size = Vector2(214, 42)
		random_exchange.text = "兌換隨機技能書（殘墨 15）"
		random_exchange.add_theme_font_size_override("font_size", 12)
		random_exchange.disabled = int(skill_materials.get(material_name, 0)) < 15
		random_exchange.pressed.connect(_exchange_random_skill_book.bind(quality))
		add_child(random_exchange)
		var specified := Button.new()
		specified.position = panel.position + Vector2(246, 108)
		specified.size = Vector2(220, 38)
		specified.text = "兌換指定技能書（殘墨 30）"
		specified.add_theme_font_size_override("font_size", 12)
		specified.disabled = _skills_of_quality(quality, false, true).is_empty() or int(skill_materials.get(material_name, 0)) < 30
		specified.pressed.connect(_show_specified_skill_exchange_list.bind(quality))
		add_child(specified)

	var result := Panel.new()
	result.position = Vector2(28, 720)
	result.size = Vector2(484, 186)
	result.add_theme_stylebox_override("panel", _box(Color("c4b17e"), RED if skill_exchange_message != "" else COPPER, 2, 9))
	add_child(result)
	_add_label("兌換結果", Rect2(48, 742, 160, 30), 17, RED)
	_add_label(skill_exchange_message if skill_exchange_message != "" else "孟婆正翻閱殘卷，等待你決定。", Rect2(48, 784, 444, 74), 14, RED if skill_exchange_message != "" else GREEN, HORIZONTAL_ALIGNMENT_CENTER)
	_add_label("此處只處理法脈殘墨；其他材料請至行囊查看。", Rect2(48, 866, 444, 24), 12, Color("665b50"), HORIZONTAL_ALIGNMENT_CENTER)


func _material_for_quality(quality: String) -> String:
	match quality:
		"普通":
			return "普通法脈殘墨"
		"稀有":
			return "稀有法脈殘墨"
		_:
			return "高級法脈殘墨"


func _current_profession() -> String:
	return "引渡人"


func _skills_of_quality(quality: String, owned_only: bool = false, current_profession_only: bool = false) -> Array[int]:
	var indices: Array[int] = []
	for i in novice_skills.size():
		var skill: Dictionary = novice_skills[i]
		if str(skill.get("quality", "普通")) != quality:
			continue
		if owned_only and int(skill.get("books", 0)) <= 0:
			continue
		if current_profession_only:
			var profession := str(skill.get("profession", "引渡人"))
			if profession != "引渡人" and profession != _current_profession():
				continue
		indices.append(i)
	return indices


func _selected_skill_index(skill_select: OptionButton) -> int:
	if not is_instance_valid(skill_select) or skill_select.item_count == 0:
		return -1
	return int(skill_select.get_item_metadata(skill_select.selected))


func _selected_skill_book_count(skill_select: OptionButton) -> int:
	var skill_index := _selected_skill_index(skill_select)
	if skill_index < 0:
		return 0
	return int(novice_skills[skill_index].get("books", 0))


func _remember_exchange_skill_selection(_option_index: int, quality: String, skill_select: OptionButton, amount_select: SpinBox) -> void:
	var skill_index := _selected_skill_index(skill_select)
	if skill_index < 0:
		return
	exchange_selected_skill_by_quality[quality] = skill_index
	amount_select.max_value = maxi(1, int(novice_skills[skill_index].get("books", 0)))
	amount_select.value = mini(amount_select.value, amount_select.max_value)


func _dismantle_selected_skill_book(quality: String, skill_select: OptionButton, amount_select: SpinBox) -> void:
	var skill_index := _selected_skill_index(skill_select)
	var owned := 0 if skill_index < 0 else int(novice_skills[skill_index].get("books", 0))
	var amount := mini(owned, maxi(1, int(amount_select.value)))
	if skill_index < 0 or owned <= 0:
		skill_exchange_message = "沒有可拆解的%s技能書。" % quality
		_show_skill_ink_exchange()
		return
	exchange_selected_skill_by_quality[quality] = skill_index
	_show_skill_exchange_confirmation("dismantle", quality, skill_index, amount)


func _exchange_random_skill_book(quality: String) -> void:
	var material_name := _material_for_quality(quality)
	if int(skill_materials.get(material_name, 0)) < 15:
		skill_exchange_message = "%s不足，隨機兌換需要 15 份。" % material_name
		_show_skill_ink_exchange()
		return
	var candidates := _skills_of_quality(quality, false, true)
	if candidates.is_empty():
		return
	_show_skill_exchange_confirmation("random", quality, -1, 1)


func _show_specified_skill_exchange_list(quality: String) -> void:
	var material_name := _material_for_quality(quality)
	var candidates := _skills_of_quality(quality, false, true)
	if candidates.is_empty() or int(skill_materials.get(material_name, 0)) < 30:
		skill_exchange_message = "%s不足，指定兌換需要 30 份。" % material_name
		_show_skill_ink_exchange()
		return
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color("171713b8")
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	shade.z_index = 38
	add_child(shade)
	var list_panel := Panel.new()
	list_panel.position = Vector2(48, 244)
	list_panel.size = Vector2(444, 404)
	list_panel.z_index = 39
	list_panel.add_theme_stylebox_override("panel", _box(PAPER, RED, 4, 14))
	add_child(list_panel)
	_add_event_label(list_panel, "選擇指定技能書", Rect2(24, 20, 396, 42), 23, RED, HORIZONTAL_ALIGNMENT_CENTER)
	_add_event_label(list_panel, "目前職業：%s\n只能選擇本職技能與引渡人共通技能。" % _current_profession(), Rect2(30, 72, 384, 58), 14, GREEN, HORIZONTAL_ALIGNMENT_CENTER)
	var specified_select := OptionButton.new()
	specified_select.position = Vector2(34, 150)
	specified_select.size = Vector2(376, 52)
	for skill_index in candidates:
		var skill: Dictionary = novice_skills[skill_index]
		specified_select.add_item("%s｜%s｜目前持有 %d" % [skill["name"], skill["profession"], skill["books"]])
		specified_select.set_item_metadata(specified_select.item_count - 1, skill_index)
	var remembered_index := int(exchange_selected_skill_by_quality.get(quality, -1))
	for option_index in specified_select.item_count:
		if int(specified_select.get_item_metadata(option_index)) == remembered_index:
			specified_select.select(option_index)
			break
	list_panel.add_child(specified_select)
	_add_event_label(list_panel, "消耗：%s ×30\n取得：所選技能書 ×1", Rect2(34, 220, 376, 58), 15, INK, HORIZONTAL_ALIGNMENT_CENTER)
	var cancel := Button.new()
	cancel.position = Vector2(28, 314)
	cancel.size = Vector2(176, 54)
	cancel.text = "取消"
	cancel.add_theme_stylebox_override("normal", _box(Color("c5b17f"), COPPER, 2, 9))
	cancel.pressed.connect(_dismiss_skill_exchange_confirmation.bind(shade, list_panel))
	list_panel.add_child(cancel)
	var next := Button.new()
	next.position = Vector2(216, 314)
	next.size = Vector2(200, 54)
	next.text = "選擇並查看確認"
	next.add_theme_color_override("font_color", PAPER)
	next.add_theme_stylebox_override("normal", _box(RED, Color("3a1815"), 3, 9))
	next.pressed.connect(_open_specified_skill_confirmation.bind(quality, specified_select))
	list_panel.add_child(next)


func _open_specified_skill_confirmation(quality: String, skill_select: OptionButton) -> void:
	var skill_index := _selected_skill_index(skill_select)
	if skill_index < 0:
		return
	exchange_selected_skill_by_quality[quality] = skill_index
	_show_skill_exchange_confirmation("specified", quality, skill_index, 1)


func _show_skill_exchange_confirmation(action: String, quality: String, skill_index: int, amount: int) -> void:
	var material_name := _material_for_quality(quality)
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color("171713b8")
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	shade.z_index = 40
	add_child(shade)
	var confirm_panel := Panel.new()
	confirm_panel.position = Vector2(48, 220)
	confirm_panel.size = Vector2(444, 472)
	confirm_panel.z_index = 41
	confirm_panel.add_theme_stylebox_override("panel", _box(PAPER, RED, 4, 14))
	add_child(confirm_panel)
	var title := "確認拆解" if action == "dismantle" else "確認兌換"
	_add_event_label(confirm_panel, title, Rect2(24, 20, 396, 42), 24, RED, HORIZONTAL_ALIGNMENT_CENTER)
	var description := ""
	var warning := ""
	var confirm_text := ""
	if action == "dismantle":
		var skill_name := str(novice_skills[skill_index]["name"])
		description = "消耗：%s技能書「%s」×%d\n取得：%s ×%d" % [quality, skill_name, amount, material_name, amount]
		warning = "拆解後技能書會消失，無法復原。\n已學會的技能與技能等級不受影響。"
		confirm_text = "確認拆解"
	elif action == "random":
		description = "消耗：%s ×15\n取得：隨機%s技能書 ×1" % [material_name, quality]
		warning = "結果會從同階技能書中隨機抽取。\n確認後不能更換或指定結果。"
		confirm_text = "確認隨機兌換"
	else:
		var selected_name := str(novice_skills[skill_index]["name"])
		description = "消耗：%s ×30\n取得：%s技能書「%s」×1" % [material_name, quality, selected_name]
		warning = "請再次確認技能名稱與品質。\n兌換完成後無法退還殘墨。"
		confirm_text = "確認指定兌換"
	_add_event_label(confirm_panel, "本次內容", Rect2(30, 78, 180, 30), 17, RED, HORIZONTAL_ALIGNMENT_LEFT)
	_add_event_label(confirm_panel, description, Rect2(30, 116, 384, 92), 15, INK, HORIZONTAL_ALIGNMENT_LEFT)
	var warning_panel := Panel.new()
	warning_panel.position = Vector2(24, 224)
	warning_panel.size = Vector2(396, 108)
	warning_panel.add_theme_stylebox_override("panel", _box(Color("b9a36f"), COPPER, 2, 9))
	confirm_panel.add_child(warning_panel)
	_add_event_label(warning_panel, "注意", Rect2(18, 10, 100, 26), 15, RED, HORIZONTAL_ALIGNMENT_LEFT)
	_add_event_label(warning_panel, warning, Rect2(18, 38, 360, 58), 13, INK, HORIZONTAL_ALIGNMENT_LEFT)
	var cancel := Button.new()
	cancel.position = Vector2(28, 374)
	cancel.size = Vector2(176, 54)
	cancel.text = "取消"
	cancel.add_theme_stylebox_override("normal", _box(Color("c5b17f"), COPPER, 2, 9))
	cancel.pressed.connect(_dismiss_skill_exchange_confirmation.bind(shade, confirm_panel))
	confirm_panel.add_child(cancel)
	var confirm := Button.new()
	confirm.position = Vector2(216, 374)
	confirm.size = Vector2(200, 54)
	confirm.text = confirm_text
	confirm.add_theme_color_override("font_color", PAPER)
	confirm.add_theme_stylebox_override("normal", _box(RED, Color("3a1815"), 3, 9))
	confirm.pressed.connect(_confirm_skill_exchange.bind(action, quality, skill_index, amount))
	confirm_panel.add_child(confirm)
	_add_event_label(confirm_panel, "只有按下右側確認按鈕才會扣除物品。", Rect2(28, 436, 388, 24), 11, GREEN, HORIZONTAL_ALIGNMENT_CENTER)


func _dismiss_skill_exchange_confirmation(shade: ColorRect, confirm_panel: Panel) -> void:
	if is_instance_valid(shade):
		shade.queue_free()
	if is_instance_valid(confirm_panel):
		confirm_panel.queue_free()


func _confirm_skill_exchange(action: String, quality: String, skill_index: int, amount: int) -> void:
	var material_name := _material_for_quality(quality)
	var revealed_skill_name := ""
	if action == "dismantle":
		if skill_index < 0 or amount <= 0 or int(novice_skills[skill_index].get("books", 0)) < amount:
			skill_exchange_message = "技能書數量已改變，拆解取消。"
		else:
			novice_skills[skill_index]["books"] = int(novice_skills[skill_index]["books"]) - amount
			skill_materials[material_name] = int(skill_materials.get(material_name, 0)) + amount
			skill_exchange_message = "拆解「%s」×%d：取得%s ×%d" % [novice_skills[skill_index]["name"], amount, material_name, amount]
	elif action == "random":
		var candidates := _skills_of_quality(quality, false, true)
		if int(skill_materials.get(material_name, 0)) < 15 or candidates.is_empty():
			skill_exchange_message = "材料數量已改變，隨機兌換取消。"
		else:
			skill_materials[material_name] = int(skill_materials[material_name]) - 15
			var random_index: int = candidates.pick_random()
			novice_skills[random_index]["books"] = int(novice_skills[random_index].get("books", 0)) + 1
			revealed_skill_name = str(novice_skills[random_index]["name"])
			skill_exchange_message = "隨機兌換完成：取得「%s」技能書 ×1" % novice_skills[random_index]["name"]
	else:
		if skill_index < 0 or int(skill_materials.get(material_name, 0)) < 30:
			skill_exchange_message = "材料數量已改變，指定兌換取消。"
		else:
			skill_materials[material_name] = int(skill_materials[material_name]) - 30
			novice_skills[skill_index]["books"] = int(novice_skills[skill_index].get("books", 0)) + 1
			skill_exchange_message = "指定兌換完成：取得「%s」技能書 ×1" % novice_skills[skill_index]["name"]
	_save_persistent_progress()
	_show_skill_ink_exchange()
	if revealed_skill_name != "":
		_show_random_skill_exchange_result(quality, revealed_skill_name)


func _show_random_skill_exchange_result(quality: String, skill_name: String) -> void:
	var quality_color := GREEN
	if quality == "稀有":
		quality_color = Color("765a86")
	elif quality == "高階":
		quality_color = Color("a85e35")
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color("171713c7")
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	shade.z_index = 60
	add_child(shade)
	var result_panel := Panel.new()
	result_panel.position = Vector2(54, 248)
	result_panel.size = Vector2(432, 424)
	result_panel.z_index = 61
	result_panel.modulate.a = 0.0
	result_panel.scale = Vector2(0.88, 0.88)
	result_panel.pivot_offset = result_panel.size * 0.5
	result_panel.add_theme_stylebox_override("panel", _box(PAPER, quality_color, 5, 16))
	add_child(result_panel)
	_add_event_label(result_panel, "隨機兌換結果", Rect2(24, 24, 384, 42), 25, RED, HORIZONTAL_ALIGNMENT_CENTER)
	_add_event_label(result_panel, "%s技能書" % quality, Rect2(34, 92, 364, 32), 17, quality_color, HORIZONTAL_ALIGNMENT_CENTER)
	var book_panel := Panel.new()
	book_panel.position = Vector2(48, 146)
	book_panel.size = Vector2(336, 126)
	book_panel.add_theme_stylebox_override("panel", _box(Color("b9a36f"), quality_color, 3, 10))
	result_panel.add_child(book_panel)
	_add_event_label(book_panel, "「%s」" % skill_name, Rect2(18, 18, 300, 48), 24, RED, HORIZONTAL_ALIGNMENT_CENTER)
	_add_event_label(book_panel, "技能書 ×1", Rect2(18, 70, 300, 34), 16, INK, HORIZONTAL_ALIGNMENT_CENTER)
	_add_event_label(result_panel, "技能書已存入法脈書冊。\n背景巡行仍在繼續。", Rect2(36, 292, 360, 52), 13, GREEN, HORIZONTAL_ALIGNMENT_CENTER)
	var collect := Button.new()
	collect.position = Vector2(106, 354)
	collect.size = Vector2(220, 48)
	collect.text = "收下技能書"
	collect.add_theme_color_override("font_color", PAPER)
	collect.add_theme_stylebox_override("normal", _box(RED, Color("3a1815"), 3, 9))
	collect.pressed.connect(_dismiss_skill_exchange_confirmation.bind(shade, result_panel))
	result_panel.add_child(collect)
	var reveal := create_tween()
	reveal.tween_property(result_panel, "modulate:a", 1.0, 0.22)
	reveal.parallel().tween_property(result_panel, "scale", Vector2.ONE, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _show_developer_trial() -> void:
	_enter_background_battle_mode()
	for child in get_children():
		child.queue_free()
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = INK
	add_child(background)
	var paper := Panel.new()
	paper.position = Vector2(12, 12)
	paper.size = Vector2(516, 936)
	paper.add_theme_stylebox_override("panel", _box(PAPER, Color("49382a"), 3, 14))
	add_child(paper)
	var back := Button.new()
	back.position = Vector2(28, 28)
	back.size = Vector2(82, 38)
	back.text = "← 技能"
	back.add_theme_stylebox_override("normal", _box(Color("c5b17f"), RED, 2, 8))
	back.pressed.connect(_show_skills)
	add_child(back)
	_add_label("開發試煉", Rect2(126, 25, 230, 42), 26, RED)
	_add_label("正式版本不顯示", Rect2(330, 31, 176, 28), 13, GREEN, HORIZONTAL_ALIGNMENT_RIGHT)
	var line := ColorRect.new()
	line.position = Vector2(28, 84)
	line.size = Vector2(484, 3)
	line.color = RED
	add_child(line)

	var identity := Panel.new()
	identity.position = Vector2(28, 112)
	identity.size = Vector2(484, 218)
	identity.add_theme_stylebox_override("panel", _box(Color("b9a36f"), RED if GameState.developer_test_mode else COPPER, 3, 12))
	add_child(identity)
	_add_label("法脈試煉角色", Rect2(50, 136, 280, 38), 24, RED)
	_add_label("Lv.80", Rect2(362, 132, 110, 46), 30, RED, HORIZONTAL_ALIGNMENT_RIGHT)
	_add_label("目前狀態：%s" % ("正在使用獨立測試存檔" if GameState.developer_test_mode else "一般角色，不會受到測試資料影響"), Rect2(50, 194, 420, 30), 14, GREEN)
	_add_label("技能＋15　・　同名技能書各 300 本\n銅錢 10,000,000　・　高階測試裝備\n後續加入各階殘墨、Boss 法印與四職業切換。", Rect2(50, 238, 430, 76), 14, INK)

	var warning := Panel.new()
	warning.position = Vector2(28, 360)
	warning.size = Vector2(484, 128)
	warning.add_theme_stylebox_override("panel", _box(Color("c4b17e"), COPPER, 2, 10))
	add_child(warning)
	_add_label("存檔隔離", Rect2(50, 378, 180, 30), 18, RED)
	_add_label("進入前會保存一般角色；試煉中的技能、銅錢與裝備只寫入測試存檔，退出後自動恢復一般角色。", Rect2(50, 420, 430, 54), 14, INK)

	var switch_profile := Button.new()
	switch_profile.position = Vector2(76, 536)
	switch_profile.size = Vector2(388, 58)
	switch_profile.text = "退出試煉，返回一般角色" if GameState.developer_test_mode else "進入 Lv.80 開發試煉"
	switch_profile.add_theme_font_size_override("font_size", 17)
	switch_profile.add_theme_color_override("font_color", PAPER)
	switch_profile.add_theme_stylebox_override("normal", _box(RED, Color("3a1815"), 3, 10))
	switch_profile.pressed.connect(_switch_developer_test_profile)
	add_child(switch_profile)
	var reset_profile := Button.new()
	reset_profile.position = Vector2(148, 626)
	reset_profile.size = Vector2(244, 46)
	reset_profile.text = "重設測試角色資源"
	reset_profile.disabled = not GameState.developer_test_mode
	reset_profile.add_theme_stylebox_override("normal", _box(Color("657265"), GREEN, 2, 8))
	reset_profile.pressed.connect(_reset_developer_test_profile)
	add_child(reset_profile)
	_add_label("重設只影響開發測試存檔，不會刪除一般角色。", Rect2(48, 690, 444, 28), 12, GREEN, HORIZONTAL_ALIGNMENT_CENTER)


func _switch_developer_test_profile() -> void:
	_save_persistent_progress()
	if GameState.developer_test_mode:
		GameState.exit_developer_test_profile()
	else:
		GameState.enter_developer_test_profile()
	get_tree().reload_current_scene()


func _reset_developer_test_profile() -> void:
	if not GameState.developer_test_mode:
		return
	GameState.reset_developer_test_profile()
	get_tree().reload_current_scene()


func _show_skill_enhance(index: int, result_message: String = "") -> void:
	if index < 0 or index >= novice_skills.size():
		return
	_enter_background_battle_mode()
	for child in get_children():
		child.queue_free()
	var skill: Dictionary = novice_skills[index]
	var level := int(skill.get("level", 0))
	var rates := _skill_enhance_rates(level)
	var book_cost := _skill_book_cost(level)
	var coin_cost := _skill_coin_cost(level)
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = INK
	add_child(background)
	var paper := Panel.new()
	paper.position = Vector2(12, 12)
	paper.size = Vector2(516, 936)
	paper.add_theme_stylebox_override("panel", _box(PAPER, Color("49382a"), 3, 14))
	add_child(paper)
	var back := Button.new()
	back.position = Vector2(28, 28)
	back.size = Vector2(82, 38)
	back.text = "← 技能"
	back.add_theme_stylebox_override("normal", _box(Color("c5b17f"), RED, 2, 8))
	back.pressed.connect(_show_skills)
	add_child(back)
	_add_label("法脈強化", Rect2(126, 25, 230, 42), 26, RED)
	_add_label("引渡法脈・轉職後保留", Rect2(310, 31, 196, 28), 13, GREEN, HORIZONTAL_ALIGNMENT_RIGHT)
	var line := ColorRect.new()
	line.position = Vector2(28, 84)
	line.size = Vector2(484, 3)
	line.color = RED
	add_child(line)

	var skill_panel := Panel.new()
	skill_panel.position = Vector2(28, 108)
	skill_panel.size = Vector2(484, 190)
	skill_panel.add_theme_stylebox_override("panel", _box(Color("b9a36f"), RED, 3, 12))
	add_child(skill_panel)
	_add_label(str(skill["name"]), Rect2(48, 128, 290, 38), 25, RED)
	_add_label("＋%d" % level, Rect2(360, 124, 120, 48), 32, RED, HORIZONTAL_ALIGNMENT_RIGHT)
	_add_label(str(skill["description"]), Rect2(48, 178, 438, 48), 13, INK)
	_add_label(_skill_effect_text(str(skill["name"]), level), Rect2(48, 244, 438, 30), 14, GREEN)

	_add_label("本次強化結果", Rect2(30, 328, 220, 30), 19, RED)
	var outcome_names := ["成功", "沒有變化", "法脈降級"]
	var outcome_colors := [GREEN, COPPER, RED]
	for i in 3:
		var outcome := Panel.new()
		outcome.position = Vector2(28 + i * 162, 374)
		outcome.size = Vector2(150, 124)
		outcome.add_theme_stylebox_override("panel", _box(Color("c4b17e"), outcome_colors[i], 2, 9))
		add_child(outcome)
		_add_label(outcome_names[i], Rect2(outcome.position + Vector2(8, 14), Vector2(134, 28)), 15, outcome_colors[i], HORIZONTAL_ALIGNMENT_CENTER)
		_add_label("%d%%" % int(round(float(rates[i]) * 100.0)), Rect2(outcome.position + Vector2(8, 51), Vector2(134, 38)), 25, INK, HORIZONTAL_ALIGNMENT_CENTER)
		_add_label("提升＋1" if i == 0 else ("維持等級" if i == 1 else ("降低－1" if level >= 4 else "初階免降")), Rect2(outcome.position + Vector2(8, 94), Vector2(134, 22)), 12, GREEN, HORIZONTAL_ALIGNMENT_CENTER)

	var cost_panel := Panel.new()
	cost_panel.position = Vector2(28, 526)
	cost_panel.size = Vector2(484, 128)
	cost_panel.add_theme_stylebox_override("panel", _box(Color("c4b17e"), COPPER, 2, 10))
	add_child(cost_panel)
	_add_label("持有同名技能書　%d　本次需要　%d" % [int(skill.get("books", 0)), book_cost], Rect2(48, 544, 438, 28), 15, INK)
	_add_label("持有銅錢　%d　本次需要　%d" % [inventory_coins, coin_cost], Rect2(48, 582, 438, 28), 15, INK)
	_add_label("技能只會成功、不變或降級，技能本身永遠不會消失。", Rect2(48, 618, 438, 24), 12, GREEN)

	var enhance := Button.new()
	enhance.position = Vector2(92, 684)
	enhance.size = Vector2(356, 54)
	enhance.text = "焚化同名技能書進行強化"
	enhance.disabled = int(skill.get("books", 0)) < book_cost or inventory_coins < coin_cost
	enhance.add_theme_font_size_override("font_size", 16)
	enhance.add_theme_color_override("font_color", PAPER)
	enhance.add_theme_stylebox_override("normal", _box(RED, Color("3a1815"), 3, 10))
	enhance.pressed.connect(_attempt_skill_enhance.bind(index))
	add_child(enhance)
	var result_panel := Panel.new()
	result_panel.position = Vector2(28, 762)
	result_panel.size = Vector2(484, 72)
	result_panel.add_theme_stylebox_override("panel", _box(Color("b9a36f"), RED if result_message != "" else COPPER, 2, 9))
	add_child(result_panel)
	_add_label(result_message if result_message != "" else "法壇尚未點燃。", Rect2(48, 782, 444, 32), 15, RED if result_message != "" else Color("665b50"), HORIZONTAL_ALIGNMENT_CENTER)

	if GameState.developer_test_mode:
		var test_supply := Button.new()
		test_supply.position = Vector2(148, 858)
		test_supply.size = Vector2(244, 42)
		test_supply.text = "測試補給：同名書＋10"
		test_supply.add_theme_font_size_override("font_size", 13)
		test_supply.add_theme_stylebox_override("normal", _box(Color("657265"), GREEN, 2, 8))
		test_supply.pressed.connect(_grant_skill_test_supply.bind(index))
		add_child(test_supply)
		_add_label("此按鈕只存在於開發試煉存檔。", Rect2(30, 908, 480, 24), 11, GREEN, HORIZONTAL_ALIGNMENT_CENTER)
	else:
		_add_label("普通技能書可由小怪、離線巡行、異聞與任務取得，取得後為角色綁定。", Rect2(42, 864, 456, 54), 12, GREEN, HORIZONTAL_ALIGNMENT_CENTER)


func _skill_enhance_rates(level: int) -> Array[float]:
	if level <= 3:
		return [1.0, 0.0, 0.0]
	if level <= 6:
		return [0.65, 0.35, 0.0]
	if level <= 9:
		return [0.35, 0.50, 0.15]
	if level <= 12:
		return [0.18, 0.52, 0.30]
	var success := maxf(0.02, 0.12 - float(level - 13) * 0.01)
	return [success, 0.48, 0.52 - success]


func _skill_book_cost(level: int) -> int:
	if level <= 3:
		return 1
	if level <= 6:
		return 2
	if level <= 9:
		return 3
	return 5 + maxi(0, int((level - 10) / 3.0))


func _skill_coin_cost(level: int) -> int:
	return 500 * level * level


func _skill_effect_text(skill_name: String, level: int) -> String:
	match skill_name:
		"淨符":
			return "目前效果：每第 4 次攻擊追加 %d 點淨化傷害" % (2 + level * 2)
		"引魂燈":
			return "目前效果：伴生靈共鬥時有機率引魂療傷"
		"安魂咒":
			return "目前效果：生命偏低時恢復少量生命"
		"敕符・淨煞":
			return "目前效果：對全體鬼怪造成 %d 點傷害" % (10 + level * 3)
	return "目前效果會隨法脈等級小幅提升"


func _attempt_skill_enhance(index: int) -> void:
	if index < 0 or index >= novice_skills.size():
		return
	var skill: Dictionary = novice_skills[index]
	var old_level := int(skill.get("level", 0))
	var book_cost := _skill_book_cost(old_level)
	var coin_cost := _skill_coin_cost(old_level)
	if int(skill.get("books", 0)) < book_cost or inventory_coins < coin_cost:
		_show_skill_enhance(index, "材料不足，法壇沒有回應。")
		return
	skill["books"] = int(skill.get("books", 0)) - book_cost
	inventory_coins -= coin_cost
	var rates := _skill_enhance_rates(old_level)
	var roll := randf()
	var result := ""
	if roll < rates[0]:
		skill["level"] = old_level + 1
		result = "符火轉為青金色：強化成功，＋%d → ＋%d" % [old_level, old_level + 1]
	elif roll < rates[0] + rates[1]:
		result = "符火熄滅：沒有變化，法脈維持＋%d" % old_level
	else:
		skill["level"] = maxi(1, old_level - 1)
		result = "法壇震動：強化失敗，＋%d → ＋%d" % [old_level, int(skill["level"])]
	skill["need"] = _skill_book_cost(int(skill["level"]))
	novice_skills[index] = skill
	_save_persistent_progress()
	_show_skill_enhance(index, result)


func _grant_skill_test_supply(index: int) -> void:
	if index < 0 or index >= novice_skills.size():
		return
	novice_skills[index]["books"] = int(novice_skills[index].get("books", 0)) + 10
	inventory_coins += 100000
	_save_persistent_progress()
	_show_skill_enhance(index, "測試補給已送達：同名技能書＋10、銅錢＋100,000")


func _show_item_detail(index: int) -> void:
	if index < 0 or index >= inventory_equipment.size():
		return
	_enter_background_battle_mode()
	if starter_equipment_tutorial_active:
		GameState.set_battle_view_active(true)
	for child in get_children():
		child.queue_free()
	var item: Dictionary = inventory_equipment[index]
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = INK
	add_child(background)
	var paper := Panel.new()
	paper.position = Vector2(12, 12)
	paper.size = Vector2(516, 936)
	paper.add_theme_stylebox_override("panel", _box(PAPER, Color("49382a"), 3, 14))
	add_child(paper)
	var back := Button.new()
	back.position = Vector2(28, 28)
	back.size = Vector2(82, 38)
	back.text = "← 行囊"
	back.add_theme_stylebox_override("normal", _box(Color("c5b17f"), RED, 2, 8))
	back.pressed.connect(_show_inventory)
	add_child(back)
	_add_label("器物詳情", Rect2(126, 25, 230, 42), 26, RED)
	var preview := Panel.new()
	preview.position = Vector2(28, 96)
	preview.size = Vector2(484, 310)
	preview.add_theme_stylebox_override("panel", _box(Color("b9a36f"), RED if item.get("equipped", false) else COPPER, 3, 12))
	add_child(preview)
	_add_label("＋%d" % item["level"], Rect2(52, 124, 110, 58), 38, RED, HORIZONTAL_ALIGNMENT_CENTER)
	_add_label(item["name"], Rect2(180, 120, 290, 42), 24, RED)
	_add_label("部位　%s" % item["slot"], Rect2(180, 168, 250, 28), 15, GREEN)
	_add_label(item["affix"], Rect2(52, 226, 410, 34), 18, INK)
	_add_label("實際能力值　%d" % item["power"], Rect2(52, 274, 410, 30), 15, GREEN)
	_add_label("目前狀態：%s" % ("已裝備" if item.get("equipped", false) else "放置於行囊"), Rect2(52, 338, 410, 30), 15, RED)
	var equip_button := Button.new()
	equip_button.position = Vector2(104, 438)
	equip_button.size = Vector2(332, 54)
	equip_button.text = "卸下器物" if item.get("equipped", false) else "裝備此器物"
	equip_button.add_theme_color_override("font_color", PAPER)
	equip_button.add_theme_stylebox_override("normal", _box(RED, Color("3a1815"), 3, 10))
	equip_button.pressed.connect(_toggle_item_equipped.bind(index))
	add_child(equip_button)
	var effect := Panel.new()
	effect.position = Vector2(28, 532)
	effect.size = Vector2(484, 150)
	effect.add_theme_stylebox_override("panel", _box(Color("c4b17e"), COPPER, 2, 9))
	add_child(effect)
	_add_label("裝備效果", Rect2(44, 542, 160, 28), 18, RED)
	var effect_text := "提高每次攻擊的傷害。" if item["slot"] == "武器" else ("降低主角受到的戰鬥傷害。" if item["slot"] == "防具" else "降低伴生靈分擔時承受的傷害。")
	_add_label(effect_text, Rect2(44, 580, 440, 34), 15, INK)
	_add_label("同一部位只能裝備一件；替換時會自動卸下原器物。", Rect2(44, 628, 440, 28), 13, GREEN)
	_add_quick_menu(false, starter_equipment_tutorial_active)


func _toggle_item_equipped(index: int) -> void:
	var item: Dictionary = inventory_equipment[index]
	var will_equip := not bool(item.get("equipped", false))
	if will_equip:
		for i in inventory_equipment.size():
			if inventory_equipment[i].get("slot", "") == item.get("slot", ""):
				inventory_equipment[i]["equipped"] = false
	item["equipped"] = will_equip
	inventory_equipment[index] = item
	_save_persistent_progress()
	if starter_equipment_tutorial_active:
		_show_inventory()
	else:
		_show_item_detail(index)


func _equipped_power(slot_name: String) -> int:
	for item in inventory_equipment:
		if item.get("slot", "") == slot_name and item.get("equipped", false):
			return int(item.get("power", 0)) + int(item.get("level", 0))
	return 0


func _skill_index(skill_name: String) -> int:
	for i in novice_skills.size():
		if novice_skills[i].get("name", "") == skill_name:
			return i
	return -1


func _skill_level(skill_name: String) -> int:
	var index := _skill_index(skill_name)
	if index >= 0 and novice_skills[index].get("unlocked", false):
		return int(novice_skills[index].get("level", 0))
	return 0


func _start_battle_motion(player_body: Control, enemy_body: Control, damage_label: Label, spirit_fire: Control) -> void:
	var player_start := player_body.position
	var enemy_start := enemy_body.position
	var attack := create_tween().set_loops()
	battle_motion_tween = attack
	attack.tween_interval(0.8)
	attack.tween_property(player_body, "position", player_start + Vector2(24, -8), 0.16).set_trans(Tween.TRANS_QUAD)
	attack.parallel().tween_property(damage_label, "modulate:a", 1.0, 0.08)
	attack.tween_property(enemy_body, "position", enemy_start + Vector2(8, 0), 0.06)
	attack.tween_property(enemy_body, "position", enemy_start - Vector2(6, 0), 0.06)
	attack.tween_property(enemy_body, "position", enemy_start, 0.06)
	attack.tween_property(player_body, "position", player_start, 0.22).set_trans(Tween.TRANS_QUAD)
	attack.parallel().tween_property(damage_label, "modulate:a", 0.0, 0.28)
	attack.tween_interval(1.1)
	var spirit := create_tween().set_loops()
	spirit.tween_property(spirit_fire, "scale", Vector2(1.35, 1.35), 0.65).set_trans(Tween.TRANS_SINE)
	spirit.parallel().tween_property(spirit_fire, "modulate:a", 0.45, 0.65)
	spirit.tween_property(spirit_fire, "scale", Vector2.ONE, 0.65).set_trans(Tween.TRANS_SINE)
	spirit.parallel().tween_property(spirit_fire, "modulate:a", 1.0, 0.65)


func _add_label(text_value: String, rect: Rect2, font_size: int, color: Color, alignment := HORIZONTAL_ALIGNMENT_LEFT) -> void:
	_make_label(text_value, rect, font_size, color, alignment)


func _make_label(text_value: String, rect: Rect2, font_size: int, color: Color, alignment := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.position = rect.position
	label.size = rect.size
	label.text = text_value
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	add_child(label)
	return label


func _box(fill: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(radius)
	return style
