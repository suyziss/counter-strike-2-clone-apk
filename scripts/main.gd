extends Node3D

const SAVE_PATH := "user://exploration.cfg"
const WALK_SPEED := 5.0
const INTERACT_DISTANCE := 3.2

var player: CharacterBody3D
var head: Node3D
var camera: Camera3D
var map_root: Node3D
var ui_layer: CanvasLayer
var ui_root: Control
var menu: Control
var hud_label: Label
var objective_label: Label
var prompt_label: Label
var map_name := "Foundry"
var sensitivity := 0.0035
var completed: Array = []
var interactables: Array[Dictionary] = []
var touch_state := {"forward": false, "back": false, "left": false, "right": false}
var look_touch_id := -1
var message_text := ""
var message_timer := 0.0
var is_running := false
var current_menu := "main"

func _ready() -> void:
	_load_settings()
	_load_progress()
	_build_world(map_name)
	_spawn_player()
	_build_ui()
	_show_main_menu()

func _process(delta: float) -> void:
	if message_timer > 0.0:
		message_timer = maxf(0.0, message_timer - delta)
	if menu != null and is_instance_valid(menu) and menu.visible:
		return
	if not is_running:
		return
	_handle_player(delta)
	_update_hud()

func _unhandled_input(event: InputEvent) -> void:
	if not is_running:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_rotate_view(event.relative)
	elif event is InputEventScreenDrag:
		if event.index == look_touch_id and event.position.x > get_viewport().get_visible_rect().size.x * 0.42:
			_rotate_view(event.relative)
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			_show_pause_menu()
		elif event.keycode == KEY_E:
			_interact()
	elif event is InputEventScreenTouch:
		if event.pressed:
			if event.position.x > get_viewport().get_visible_rect().size.x * 0.42:
				look_touch_id = event.index
		elif event.index == look_touch_id:
			look_touch_id = -1

func _rotate_view(delta: Vector2) -> void:
	if player == null or head == null:
		return
	player.rotate_y(-delta.x * sensitivity)
	head.rotation.x = clampf(head.rotation.x - delta.y * sensitivity, -1.25, 1.25)

func _load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		sensitivity = float(cfg.get_value("settings", "sensitivity", sensitivity))

func _load_progress() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		map_name = str(cfg.get_value("progress", "map", "Foundry"))
		var saved: Variant = cfg.get_value("progress", "completed", [])
		if saved is Array:
			completed = saved.duplicate()
	if map_name != "Foundry" and map_name != "Harbor":
		map_name = "Foundry"

func _save_data() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("settings", "sensitivity", sensitivity)
	cfg.set_value("progress", "map", map_name)
	cfg.set_value("progress", "completed", completed)
	cfg.save(SAVE_PATH)

func _build_world(selected_map: String) -> void:
	if map_root != null and is_instance_valid(map_root):
		map_root.queue_free()
	interactables.clear()
	map_root = Node3D.new()
	map_root.name = selected_map
	add_child(map_root)

	var world_env := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#10131d")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#b7b4d5")
	env.ambient_light_energy = 0.55
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.fog_enabled = true
	env.fog_light_color = Color("#85849c")
	env.fog_density = 0.006
	world_env.environment = env
	map_root.add_child(world_env)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48.0, -28.0, 0.0)
	sun.light_energy = 1.15
	sun.shadow_enabled = true
	map_root.add_child(sun)

	_box("Ground", Vector3(0, -1, 0), Vector3(60, 2, 40), Color("#30323d"))
	if selected_map == "Foundry":
		_build_foundry()
	else:
		_build_harbor()
	_add_interactable("Станция навигации", Vector3(-14, 0.0, -10), Color("#8f75ff"))
	_add_interactable("Архивный терминал", Vector3(14, 0.0, 10), Color("#69c5d8"))
	_add_interactable("Маяк связи", Vector3(0, 0.0, -14), Color("#d6a5ff"))

func _build_foundry() -> void:
	for p in [Vector3(-24, 2, 0), Vector3(24, 2, 0), Vector3(0, 2, -17), Vector3(0, 2, 17)]:
		var size := Vector3(2, 6, 32) if absf(p.x) > 20.0 else Vector3(32, 6, 2)
		_box("Foundry perimeter", p, size, Color("#555663"))
	for p in [Vector3(-10, 1, 0), Vector3(10, 1, 0), Vector3(0, 1, -7), Vector3(0, 1, 7), Vector3(-18, 1, -8), Vector3(18, 1, 8)]:
		_box("Storage block", p, Vector3(5, 3, 2.2), Color("#464957"))
	_box("Workshop platform", Vector3(17, 0.1, -10), Vector3(8, 0.2, 7), Color("#62543f"))
	_box("Cooling platform", Vector3(-17, 0.1, 10), Vector3(8, 0.2, 7), Color("#344f5c"))
	_box("Central structure", Vector3(0, 2, 0), Vector3(5, 4, 5), Color("#6a6878"))

func _build_harbor() -> void:
	_box("North wall", Vector3(0, 2, -18), Vector3(56, 6, 2), Color("#4d5965"))
	_box("South wall", Vector3(0, 2, 18), Vector3(56, 6, 2), Color("#4d5965"))
	_box("Crane base", Vector3(18, 4, 0), Vector3(3, 8, 3), Color("#786b50"))
	for x in [-22, -14, -6, 2, 10, 18]:
		_box("Container", Vector3(x, 1, -8), Vector3(6, 4, 3), Color("#4b5967"))
		_box("Container", Vector3(x, 1, 8), Vector3(6, 4, 3), Color("#46545f"))
	_box("Pier deck", Vector3(17, 0.1, -12), Vector3(9, 0.2, 6), Color("#62543f"))
	_box("Loading platform", Vector3(-17, 3.1, 12), Vector3(9, 0.2, 6), Color("#344f5c"))
	_box("Ramp", Vector3(-10, 1.5, 12), Vector3(12, 1, 4), Color("#606875"))

func _box(label: String, pos: Vector3, size: Vector3, color: Color) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = label
	body.position = pos
	var mesh := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = size
	mesh.mesh = box_mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.88
	mesh.material_override = material
	body.add_child(mesh)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	map_root.add_child(body)
	return body

func _add_interactable(label: String, pos: Vector3, color: Color) -> void:
	var marker := Node3D.new()
	marker.name = label
	marker.position = pos
	var pedestal := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.48
	cylinder.bottom_radius = 0.58
	cylinder.height = 1.05
	pedestal.mesh = cylinder
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color * 0.28
	pedestal.material_override = material
	pedestal.position.y = 0.55
	marker.add_child(pedestal)
	var beacon := OmniLight3D.new()
	beacon.light_color = color
	beacon.light_energy = 0.7
	beacon.omni_range = 4.5
	beacon.position.y = 1.25
	marker.add_child(beacon)
	var text_3d := Label3D.new()
	text_3d.text = label
	text_3d.position.y = 1.55
	text_3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	text_3d.font_size = 32
	text_3d.modulate = Color("#f0edff")
	marker.add_child(text_3d)
	map_root.add_child(marker)
	var is_done := completed.has(map_name + ":" + label)
	if is_done:
		var completed_material := StandardMaterial3D.new()
		completed_material.albedo_color = Color("#6bca9a")
		completed_material.emission_enabled = true
		completed_material.emission = Color("#6bca9a") * 0.35
		pedestal.material_override = completed_material
	interactables.append({"node": marker, "label": label, "done": is_done})

func _spawn_player() -> void:
	player = CharacterBody3D.new()
	player.name = "Explorer"
	player.position = Vector3(0, 1, 14)
	player.floor_snap_length = 0.25
	var collision := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.36
	capsule.height = 1.8
	collision.shape = capsule
	player.add_child(collision)
	head = Node3D.new()
	head.name = "Head"
	head.position.y = 0.62
	player.add_child(head)
	camera = Camera3D.new()
	camera.current = true
	camera.fov = 78.0
	camera.position = Vector3(0, 0.55, 0)
	head.add_child(camera)
	add_child(player)

func _build_ui() -> void:
	ui_layer = CanvasLayer.new()
	add_child(ui_layer)
	ui_root = Control.new()
	ui_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui_layer.add_child(ui_root)

	hud_label = Label.new()
	hud_label.position = Vector2(24, 20)
	hud_label.add_theme_font_size_override("font_size", 22)
	hud_label.add_theme_color_override("font_color", Color("#f3efff"))
	ui_root.add_child(hud_label)

	objective_label = Label.new()
	objective_label.position = Vector2(24, 58)
	objective_label.add_theme_font_size_override("font_size", 16)
	objective_label.add_theme_color_override("font_color", Color("#c6bddf"))
	ui_root.add_child(objective_label)

	prompt_label = Label.new()
	prompt_label.anchor_left = 0.25
	prompt_label.anchor_right = 0.75
	prompt_label.anchor_top = 0.82
	prompt_label.anchor_bottom = 0.91
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	prompt_label.add_theme_font_size_override("font_size", 20)
	prompt_label.add_theme_color_override("font_color", Color("#ffffff"))
	ui_root.add_child(prompt_label)

	_add_hold_button("↑", Vector2(76, -210), "forward")
	_add_hold_button("←", Vector2(8, -140), "left")
	_add_hold_button("↓", Vector2(76, -140), "back")
	_add_hold_button("→", Vector2(144, -140), "right")
	var interact_button := _make_button("ОСМОТРЕТЬ", Vector2(170, 74))
	interact_button.anchor_left = 1.0
	interact_button.anchor_right = 1.0
	interact_button.anchor_top = 1.0
	interact_button.anchor_bottom = 1.0
	interact_button.offset_left = -220
	interact_button.offset_right = -28
	interact_button.offset_top = -118
	interact_button.offset_bottom = -34
	interact_button.pressed.connect(_interact)
	ui_root.add_child(interact_button)

func _add_hold_button(text_value: String, offset: Vector2, direction: String) -> void:
	var button := _make_button(text_value, Vector2(64, 64))
	button.anchor_left = 0.0
	button.anchor_right = 0.0
	button.anchor_top = 1.0
	button.anchor_bottom = 1.0
	button.offset_left = offset.x
	button.offset_right = offset.x + 64.0
	button.offset_top = offset.y
	button.offset_bottom = offset.y + 64.0
	button.button_down.connect(func(): touch_state[direction] = true)
	button.button_up.connect(func(): touch_state[direction] = false)
	ui_root.add_child(button)

func _make_button(text_value: String, size: Vector2) -> Button:
	var button := Button.new()
	button.text = text_value
	button.custom_minimum_size = size
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 18)
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("#292536")
	normal.border_color = Color("#8d78d6")
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(12)
	button.add_theme_stylebox_override("normal", normal)
	var hover := normal.duplicate()
	hover.bg_color = Color("#3a3151")
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
	return button

func _show_main_menu() -> void:
	current_menu = "main"
	is_running = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_create_menu_panel()
	var column := _menu_column()
	_add_menu_title(column, "FOUNDRY EXPLORER", "Исследуй две процедурные локации и восстанови данные объектов")
	_menu_button(column, "ПРОДОЛЖИТЬ — " + map_name, func(): _resume_exploration())
	_menu_button(column, "НОВАЯ ЭКСПЕДИЦИЯ: FOUNDRY", func(): _start_exploration("Foundry", true))
	_menu_button(column, "НОВАЯ ЭКСПЕДИЦИЯ: HARBOR", func(): _start_exploration("Harbor", true))
	_menu_button(column, "НАСТРОЙКИ", _show_settings)
	_menu_button(column, "ВЫХОД", func(): get_tree().quit())

func _show_pause_menu() -> void:
	current_menu = "pause"
	is_running = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_create_menu_panel()
	var column := _menu_column()
	_add_menu_title(column, "ПАУЗА", "Прогресс сохраняется автоматически")
	_menu_button(column, "ПРОДОЛЖИТЬ", func(): _resume_exploration())
	_menu_button(column, "ВЫБРАТЬ ЛОКАЦИЮ", _show_map_select)
	_menu_button(column, "НАСТРОЙКИ", _show_settings)
	_menu_button(column, "ГЛАВНОЕ МЕНЮ", _show_main_menu)

func _create_menu_panel() -> void:
	if menu != null and is_instance_valid(menu):
		menu.queue_free()
	menu = Panel.new()
	menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.04, 0.065, 0.96)
	style.border_color = Color("#8d78d6")
	style.set_border_width_all(1)
	menu.add_theme_stylebox_override("panel", style)
	ui_root.add_child(menu)

func _menu_column() -> VBoxContainer:
	var column := VBoxContainer.new()
	column.anchor_left = 0.5
	column.anchor_right = 0.5
	column.anchor_top = 0.5
	column.anchor_bottom = 0.5
	column.offset_left = -220
	column.offset_right = 220
	column.offset_top = -245
	column.offset_bottom = 245
	column.add_theme_constant_override("separation", 12)
	menu.add_child(column)
	return column

func _add_menu_title(parent: VBoxContainer, title_text: String, subtitle: String) -> void:
	var title := Label.new()
	title.text = title_text
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color("#c9b9ff"))
	parent.add_child(title)
	var description := Label.new()
	description.text = subtitle
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.add_theme_font_size_override("font_size", 14)
	description.add_theme_color_override("font_color", Color("#c5c1d1"))
	parent.add_child(description)

func _menu_button(parent: VBoxContainer, text_value: String, callback: Callable) -> void:
	var button := _make_button(text_value, Vector2(420, 54))
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(callback)
	parent.add_child(button)

func _start_exploration(selected_map: String, reset_progress: bool) -> void:
	map_name = selected_map
	if reset_progress:
		completed.clear()
	_build_world(map_name)
	player.global_position = Vector3(0, 1, 14)
	player.velocity = Vector3.ZERO
	player.rotation = Vector3.ZERO
	head.rotation = Vector3.ZERO
	_save_data()
	_resume_exploration()

func _resume_exploration() -> void:
	if menu != null and is_instance_valid(menu):
		menu.hide()
	is_running = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if not OS.has_feature("mobile") else Input.MOUSE_MODE_VISIBLE
	_update_hud()

func _show_map_select() -> void:
	current_menu = "map_select"
	_create_menu_panel()
	var column := _menu_column()
	_add_menu_title(column, "ВЫБОР ЛОКАЦИИ", "Выбери площадку для исследования")
	_menu_button(column, "FOUNDRY", func(): _start_exploration("Foundry", false))
	_menu_button(column, "HARBOR", func(): _start_exploration("Harbor", false))
	_menu_button(column, "НАЗАД", _show_pause_menu)

func _show_settings() -> void:
	var return_screen := current_menu
	current_menu = "settings"
	_create_menu_panel()
	var column := _menu_column()
	_add_menu_title(column, "НАСТРОЙКИ", "Чувствительность камеры")
	var value_label := Label.new()
	value_label.text = "Чувствительность: %.4f" % sensitivity
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(value_label)
	var slider := HSlider.new()
	slider.min_value = 0.001
	slider.max_value = 0.009
	slider.step = 0.0005
	slider.value = sensitivity
	slider.value_changed.connect(func(value: float):
		sensitivity = value
		value_label.text = "Чувствительность: %.4f" % sensitivity
		_save_data()
	)
	column.add_child(slider)
	_menu_button(column, "ГОТОВО", func():
		match return_screen:
			"pause":
				_show_pause_menu()
			"map_select":
				_show_map_select()
			_:
				_show_main_menu()
	)

func _handle_player(delta: float) -> void:
	var direction := Vector3.ZERO
	if Input.is_action_pressed("move_forward") or touch_state["forward"]:
		direction.z -= 1.0
	if Input.is_action_pressed("move_back") or touch_state["back"]:
		direction.z += 1.0
	if Input.is_action_pressed("move_left") or touch_state["left"]:
		direction.x -= 1.0
	if Input.is_action_pressed("move_right") or touch_state["right"]:
		direction.x += 1.0
	direction = direction.normalized()
	var movement := (player.transform.basis * Vector3(direction.x, 0.0, direction.z)).normalized()
	player.velocity.x = movement.x * WALK_SPEED
	player.velocity.z = movement.z * WALK_SPEED
	if not player.is_on_floor():
		player.velocity.y -= 18.0 * delta
	else:
		player.velocity.y = -0.5
	player.move_and_slide()

func _interact() -> void:
	if not is_running:
		return
	var nearest_index := -1
	var nearest_distance := INTERACT_DISTANCE
	for i in range(interactables.size()):
		var item := interactables[i]
		if bool(item["done"]):
			continue
		var marker: Node3D = item["node"]
		var distance := player.global_position.distance_to(marker.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_index = i
	if nearest_index == -1:
		message_text = "Подойди ближе к активному объекту"
		message_timer = 2.0
		return
	interactables[nearest_index]["done"] = true
	var item_label := str(interactables[nearest_index]["label"])
	completed.append(map_name + ":" + item_label)
	var marker_node: Node3D = interactables[nearest_index]["node"]
	for child in marker_node.get_children():
		if child is MeshInstance3D:
			var mat := StandardMaterial3D.new()
			mat.albedo_color = Color("#6bca9a")
			mat.emission_enabled = true
			mat.emission = Color("#6bca9a") * 0.35
			child.material_override = mat
	message_text = "Данные получены: " + item_label
	message_timer = 3.0
	_save_data()
	_update_hud()

func _update_hud() -> void:
	if hud_label == null:
		return
	hud_label.text = map_name.to_upper() + "  •  ЭКСПЕДИЦИЯ"
	var count := 0
	for item in interactables:
		if bool(item["done"]):
			count += 1
	objective_label.text = "Объекты изучены: %d/%d   |   WASD / экран — движение   |   E — осмотр" % [count, interactables.size()]
	if message_timer > 0.0:
		prompt_label.text = message_text
	else:
		var nearest := _nearest_object_label()
		prompt_label.text = "Рядом: " + nearest if nearest != "" else "Исследуй локацию и найди светящиеся объекты"

func _nearest_object_label() -> String:
	if player == null:
		return ""
	var nearest_label := ""
	var nearest_distance := INTERACT_DISTANCE
	for item in interactables:
		if bool(item["done"]):
			continue
		var marker: Node3D = item["node"]
		var distance := player.global_position.distance_to(marker.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_label = str(item["label"]) + " — нажми E / ОСМОТРЕТЬ"
	return nearest_label
