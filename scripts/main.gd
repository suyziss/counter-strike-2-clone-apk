extends Node3D

const D := BPData
var rng := RandomNumberGenerator.new()
var player: CharacterBody3D
var bots: Array[CharacterBody3D] = []
var round_time := 115.0
var buy_time := 15.0
var bomb_time := -1.0
var round_no := 1
var attack_score := 0
var defense_score := 0
var credits := 999999999
var infinite_credits := true
var phase := "buy"
var bomb_planted := false
var bomb_site := "A"
var weapon_name := "Viper-9"
var ammo := 15
var reserve := 90
var sensitivity := 0.004
var touch_move := Vector2.ZERO
var touch_look := Vector2.ZERO
var fire_pressed := false
var ui: CanvasLayer
var hud: VBoxContainer
var status_label: Label
var money_label: Label
var weapon_label: Label
var crosshair: Label
var menu: Control
var menu_stack: Array[Control] = []
var map_root: Node3D
var world_env: WorldEnvironment

func _ready() -> void:
 rng.randomize()
 _build_world("Foundry")
 _spawn_player()
 _spawn_bots()
 _build_ui()
 _show_main_menu()

func _process(delta: float) -> void:
 if menu != null and menu.visible:
  return
 if phase == "buy":
  buy_time -= delta
  if buy_time <= 0.0:
   phase = "live"
   status_label.text = "РАУНД НАЧАЛСЯ"
 elif phase == "live":
  round_time -= delta
  if round_time <= 0.0:
   _end_round(false, "Время вышло")
 elif phase == "bomb":
  round_time -= delta
  bomb_time -= delta
  if bomb_time <= 0.0:
   _explode_bomb()
 _update_hud()
 _handle_player(delta)
 _update_bots(delta)

func _build_world(map_name: String) -> void:
 map_root = Node3D.new()
 map_root.name = map_name
 add_child(map_root)
 world_env = WorldEnvironment.new()
 var env := Environment.new()
 env.background_mode = Environment.BG_COLOR
 env.background_color = Color("#101821")
 env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
 env.ambient_light_color = Color("#b8c7d9")
 env.ambient_light_energy = 0.42
 env.fog_enabled = true
 env.fog_light_color = Color("#8793a0")
 env.fog_density = 0.008
 world_env.environment = env
 map_root.add_child(world_env)
 var sun := DirectionalLight3D.new()
 sun.rotation_degrees = Vector3(-52,-28,0)
 sun.light_energy = 1.2
 sun.shadow_enabled = true
 map_root.add_child(sun)
 _box("Floor", Vector3(0,-1,0), Vector3(60,2,40), Color("#30383e"))
 if map_name == "Foundry":
  _foundry()
 else:
  _harbor()
 _make_nav()

func _foundry() -> void:
 for p in [Vector3(-24,2,0),Vector3(24,2,0),Vector3(0,2,-17),Vector3(0,2,17)]:
  _box("Wall",p,Vector3(2,6,32) if abs(p.x)>20 else Vector3(32,6,2),Color("#59616a"))
 for p in [Vector3(-10,1,0),Vector3(10,1,0),Vector3(0,1,-7),Vector3(0,1,7),Vector3(-18,1,-8),Vector3(18,1,8)]:
  _box("Cover",p,Vector3(5,3,2.2),Color("#4b555d"))
 _box("A_Site",Vector3(17,0.1,-10),Vector3(8,0.2,7),Color("#5c4b2e"))
 _box("B_Site",Vector3(-17,0.1,10),Vector3(8,0.2,7),Color("#304e5c"))

func _harbor() -> void:
 _box("NorthWall",Vector3(0,2,-18),Vector3(56,6,2),Color("#4f5961"))
 _box("SouthWall",Vector3(0,2,18),Vector3(56,6,2),Color("#4f5961"))
 _box("Crane",Vector3(18,4,0),Vector3(3,8,3),Color("#7a6b45"))
 for x in [-22,-14,-6,2,10,18]:
  _box("Container",Vector3(x,1,-8),Vector3(6,4,3),Color("#4d5965"))
  _box("Container",Vector3(x,1,8),Vector3(6,4,3),Color("#465762"))
 _box("A_Site",Vector3(17,0.1,-12),Vector3(9,0.2,6),Color("#5c4b2e"))
 _box("B_Site",Vector3(-17,3.1,12),Vector3(9,0.2,6),Color("#304e5c"))
 _box("Ramp",Vector3(-10,1.5,12),Vector3(12,1,4),Color("#60686d"))

func _box(n:String, pos:Vector3, size:Vector3, color:Color) -> StaticBody3D:
 var body := StaticBody3D.new()
 body.name = n
 body.position = pos
 var mesh := MeshInstance3D.new()
 var bm := BoxMesh.new()
 bm.size = size
 mesh.mesh = bm
 var mat := StandardMaterial3D.new()
 mat.albedo_color = color
 mat.roughness = 0.85
 mesh.material_override = mat
 body.add_child(mesh)
 var cs := CollisionShape3D.new()
 var shape := BoxShape3D.new()
 shape.size = size
 cs.shape = shape
 body.add_child(cs)
 map_root.add_child(body)
 return body

func _make_nav() -> void:
 var region := NavigationRegion3D.new()
 var nav := NavigationMesh.new()
 nav.vertices = PackedVector3Array([
  Vector3(-28,0,-18),Vector3(28,0,-18),Vector3(28,0,18),Vector3(-28,0,18)
 ])
 nav.add_polygon(PackedInt32Array([0,1,2,3]))
 region.navigation_mesh = nav
 map_root.add_child(region)

func _spawn_player() -> void:
 player = CharacterBody3D.new()
 player.name = "Player"
 player.position = Vector3(0,1,14)
 player.collision_layer = 2
 player.collision_mask = 1
 var cs := CollisionShape3D.new()
 var capsule := CapsuleShape3D.new()
 capsule.radius = 0.35
 capsule.height = 1.8
 cs.shape = capsule
 player.add_child(cs)
 var head := Node3D.new()
 head.name = "Head"
 head.position.y = 0.65
 player.add_child(head)
 var cam := Camera3D.new()
 cam.current = true
 cam.position = Vector3(0,0.55,0)
 head.add_child(cam)
 _make_gun_model(head)
 add_child(player)

func _make_gun_model(parent:Node3D) -> void:
 var gun := Node3D.new()
 gun.name = "WeaponModel"
 gun.position = Vector3(0.34,-0.28,-0.55)
 parent.add_child(gun)
 _gun_box(gun,Vector3(0,0,0),Vector3(0.16,0.18,0.65),Color("#20252b"))
 _gun_box(gun,Vector3(0,-0.16,0.05),Vector3(0.13,0.34,0.18),Color("#161a1e"))
 _gun_box(gun,Vector3(0,0,-0.45),Vector3(0.08,0.08,0.45),Color("#8d969f"))

func _gun_box(parent:Node3D,pos:Vector3,size:Vector3,color:Color)->void:
 var m:=MeshInstance3D.new()
 var b:=BoxMesh.new()
 b.size=size
 m.mesh=b
 var mat:=StandardMaterial3D.new()
 mat.albedo_color=color
 m.material_override=mat
 m.position=pos
 parent.add_child(m)

func _spawn_bots() -> void:
 for i in 10:
  var b:=CharacterBody3D.new()
  b.name="Bot_%02d"%i
  b.position=Vector3(-20 + (i%5)*10,1,-10 + (i/5)*20)
  b.collision_layer=4
  b.collision_mask=1
  var cs:=CollisionShape3D.new()
  var sh:=CapsuleShape3D.new()
  sh.radius=.35
  sh.height=1.8
  cs.shape=sh
  b.add_child(cs)
  var body:=MeshInstance3D.new()
  var cm:=CapsuleMesh.new()
  cm.radius=.35
  cm.height=1.8
  body.mesh=cm
  var mat:=StandardMaterial3D.new()
  mat.albedo_color=Color("#4b6b7d") if i<5 else Color("#8a4f4f")
  body.material_override=mat
  b.add_child(body)
  var agent:=NavigationAgent3D.new()
  agent.path_height_offset=0.5
  b.add_child(agent)
  add_child(b)
  bots.append(b)

func _build_ui() -> void:
 ui=CanvasLayer.new()
 add_child(ui)
 var root:=Control.new()
 root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 ui.add_child(root)
 crosshair=Label.new()
 crosshair.text="+"
 crosshair.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 crosshair.add_theme_font_size_override("font_size",28)
 crosshair.position=Vector2(620,340)
 root.add_child(crosshair)
 hud=VBoxContainer.new()
 hud.position=Vector2(24,20)
 root.add_child(hud)
 status_label=Label.new()
 status_label.add_theme_font_size_override("font_size",22)
 hud.add_child(status_label)
 money_label=Label.new()
 hud.add_child(money_label)
 weapon_label=Label.new()
 hud.add_child(weapon_label)
 var touch:=TouchScreenButton.new()
 touch.position=Vector2(24,520)
 touch.size=Vector2(220,160)
 touch.action="move_forward"
 root.add_child(touch)
 var fire:=Button.new()
 fire.text="ОГОНЬ"
 fire.position=Vector2(1080,500)
 fire.size=Vector2(150,90)
 fire.pressed.connect(_fire)
 root.add_child(fire)
 var reload_b:=Button.new()
 reload_b.text="ПЕРЕЗАРЯДКА"
 reload_b.position=Vector2(900,600)
 reload_b.size=Vector2(170,70)
 reload_b.pressed.connect(_reload)
 root.add_child(reload_b)
 var buy_b:=Button.new()
 buy_b.text="МАГАЗИН"
 buy_b.position=Vector2(24,620)
 buy_b.size=Vector2(160,60)
 buy_b.pressed.connect(_show_buy)
 root.add_child(buy_b)

func _show_main_menu() -> void:
 menu=Panel.new()
 menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 menu.modulate=Color("#0b1118")
 ui.add_child(menu)
 var title:=Label.new()
 title.text="COUNTER STRIKE 2 CLONE"
 title.position=Vector2(0,80)
 title.size=Vector2(1280,80)
 title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 title.add_theme_font_size_override("font_size",48)
 menu.add_child(title)
 var subtitle:=Label.new()
 subtitle.text="Fan-made • unofficial • not affiliated with Valve"
 subtitle.position=Vector2(0,145)
 subtitle.size=Vector2(1280,35)
 subtitle.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 menu.add_child(subtitle)
 var buttons:=VBoxContainer.new()
 buttons.position=Vector2(450,220)
 buttons.size=Vector2(380,400)
 menu.add_child(buttons)
 _menu_button(buttons,"ИГРАТЬ",_start_match)
 _menu_button(buttons,"КЕЙСЫ",_show_cases)
 _menu_button(buttons,"ИНВЕНТАРЬ",_show_inventory)
 _menu_button(buttons,"МАГАЗИН",_show_buy)
 _menu_button(buttons,"НАСТРОЙКИ",_show_settings)
 _menu_button(buttons,"ВЫХОД",func(): get_tree().quit())

func _menu_button(parent:Container,text_value:String,cb:Callable)->void:
 var b:=Button.new()
 b.text=text_value
 b.custom_minimum_size=Vector2(360,55)
 b.add_theme_font_size_override("font_size",22)
 b.pressed.connect(cb)
 parent.add_child(b)

func _start_match()->void:
 menu.hide()
 phase="buy"
 buy_time=15.0
 round_time=115.0
 status_label.text="ЗАКУПКА 15"
 for b in bots:
  b.position=Vector3(-20 + (bots.find(b)%5)*10,1,-10 + (bots.find(b)/5)*20)

func _show_buy()->void:
 _open_panel("МАГАЗИН",true)
 var c:=menu_stack[-1]
 var box:=VBoxContainer.new()
 box.position=Vector2(300,120)
 box.size=Vector2(680,520)
 c.add_child(box)
 for n in D.WEAPONS.keys():
  var w=D.WEAPONS[n]
  var b:=Button.new()
  b.text="%s  |  %d cr | dmg %d | %d RPM"%[n,w.price,w.damage,w.rpm]
  b.custom_minimum_size=Vector2(650,48)
  b.pressed.connect(func(): _buy_weapon(n))
  box.add_child(b)
 var close:=Button.new()
 close.text="ЗАКРЫТЬ"
 close.pressed.connect(_close_panel)
 box.add_child(close)

func _buy_weapon(n:String)->void:
 if phase!="buy":
  return
 var price:int=D.WEAPONS[n].price
 if infinite_credits or credits>=price:
  if not infinite_credits: credits-=price
  weapon_name=n
  ammo=D.WEAPONS[n].mag
  reserve=D.WEAPONS[n].reserve
  _close_panel()

func _show_inventory()->void:
 _open_panel("ИНВЕНТАРЬ",false)
 var c:=menu_stack[-1]
 var grid:=GridContainer.new()
 grid.columns=4
 grid.position=Vector2(170,130)
 grid.size=Vector2(940,470)
 c.add_child(grid)
 for s in D.SKINS:
  var b:=Button.new()
  b.text=s[0]+"\n"+s[1]
  b.custom_minimum_size=Vector2(220,100)
  b.add_theme_color_override("font_color",D.rarity_color(s[1]))
  b.pressed.connect(func(): _apply_skin(s))
  grid.add_child(b)
 var close:=Button.new()
 close.text="ЗАКРЫТЬ"
 close.position=Vector2(560,620)
 close.pressed.connect(_close_panel)
 c.add_child(close)

func _apply_skin(s:Array)->void:
 status_label.text="Скин: "+s[0]

func _show_cases()->void:
 _open_panel("КЕЙСЫ",false)
 var c:=menu_stack[-1]
 var grid:=GridContainer.new()
 grid.columns=2
 grid.position=Vector2(300,130)
 c.add_child(grid)
 for case_name in D.CASES.keys():
  var b:=Button.new()
  b.text=case_name+"\nШансы: 48/28/15/7.5/2%"
  b.custom_minimum_size=Vector2(300,130)
  b.pressed.connect(func(): _open_case(case_name))
  grid.add_child(b)
 var close:=Button.new()
 close.text="ЗАКРЫТЬ"
 close.position=Vector2(560,600)
 close.pressed.connect(_close_panel)
 c.add_child(close)

func _open_case(case_name:String)->void:
 var ids:Array=D.CASES[case_name]
 var pick:int=ids[rng.randi_range(0,ids.size()-1)]
 var item:Array=D.SKINS[pick]
 var panel:=AcceptDialog.new()
 panel.title="Открытие кейса"
 panel.dialog_text="Прокрутка...  3... 2... 1...\n\nВыпало: %s [%s]"%[item[0],item[1]]
 ui.add_child(panel)
 panel.popup_centered(Vector2i(500,260))
 if not infinite_credits:
  credits=max(0,credits-500)

func _show_settings()->void:
 _open_panel("НАСТРОЙКИ",false)
 var c:=menu_stack[-1]
 var v:=VBoxContainer.new()
 v.position=Vector2(390,160)
 c.add_child(v)
 var inf:=CheckButton.new()
 inf.text="Бесконечные кредиты"
 inf.button_pressed=infinite_credits
 inf.toggled.connect(func(x): infinite_credits=x)
 v.add_child(inf)
 var vib:=CheckButton.new()
 vib.text="Вибрация"
 vib.button_pressed=false
 v.add_child(vib)
 var sens:=HSlider.new()
 sens.min_value=.001
 sens.max_value=.012
 sens.step=.001
 sens.value=sensitivity
 sens.value_changed.connect(func(x): sensitivity=x)
 v.add_child(Label.new())
 v.add_child(sens)
 var close:=Button.new()
 close.text="ЗАКРЫТЬ"
 close.pressed.connect(_close_panel)
 v.add_child(close)

func _open_panel(title_text:String,_buy:bool)->void:
 var p:=Panel.new()
 p.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 p.modulate=Color("#10161e")
 ui.add_child(p)
 var title:=Label.new()
 title.text=title_text
 title.position=Vector2(0,35)
 title.size=Vector2(1280,60)
 title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 title.add_theme_font_size_override("font_size",34)
 p.add_child(title)
 menu_stack.append(p)

func _close_panel()->void:
 if menu_stack.size()>0:
  var p:Control=menu_stack.pop_back()
  p.queue_free()

func _update_hud()->void:
 if status_label==null:return
 status_label.text="%s  |  %.0f s"%[phase.to_upper(),max(0.0,round_time)]
 money_label.text="КРЕДИТЫ: %s"%[("999 999 999" if infinite_credits else str(credits))]
 weapon_label.text="%s  %d/%d"%[weapon_name,ammo,reserve]

func _handle_player(delta:float)->void:
 if player==null:return
 var dir:=Vector3.ZERO
 if Input.is_action_pressed("move_forward"): dir.z-=1
 if Input.is_action_pressed("move_back"): dir.z+=1
 if Input.is_action_pressed("move_left"): dir.x-=1
 if Input.is_action_pressed("move_right"): dir.x+=1
 dir=dir.normalized()
 player.velocity.x=dir.x*5.0
 player.velocity.z=dir.z*5.0
 if not player.is_on_floor(): player.velocity.y-=18.0*delta
 else: player.velocity.y=0
 if Input.is_action_just_pressed("jump"): player.velocity.y=7.0
 player.move_and_slide()
 if fire_pressed: _fire()

func _fire()->void:
 if phase=="buy" or phase=="end" or ammo<=0:return
 ammo-=1
 var cam:Camera3D=player.get_node("Head/Camera3D")
 var origin:=cam.global_position
 var dir:= -cam.global_transform.basis.z
 var query:=PhysicsRayQueryParameters3D.create(origin,origin+dir*100.0)
 query.collision_mask=4
 var hit:=get_world_3d().direct_space_state.intersect_ray(query)
 if hit:
  var target=hit.collider
  if target in bots:
   _kill_bot(target)

func _reload()->void:
 var w=D.WEAPONS[weapon_name]
 var need=w.mag-ammo
 var take=min(need,reserve)
 ammo+=take
 reserve-=take

func _kill_bot(bot:CharacterBody3D)->void:
 var idx:=bots.find(bot)
 if idx<0:return
 bot.position=Vector3(-20+(idx%5)*10,1,-10+(idx/5)*20)
 credits+=300
 if bots.size()>0:
  var alive:=0
  for b in bots:
   if b.visible:alive+=1
  if alive<=0:_end_round(true,"Команда противника уничтожена")

func _update_bots(delta:float)->void:
 if player==null:return
 for i in bots.size():
  var b:=bots[i]
  var target:=player.global_position
  if i>=5:target=Vector3(0,1,0)
  var to:=target-b.global_position
  if to.length()>2.0:
   var vel:=to.normalized()*2.2
   b.velocity.x=vel.x
   b.velocity.z=vel.z
  else:
   b.velocity=Vector3.ZERO
   if rng.randf()<delta*0.5 and phase!="buy":
    _bot_shot(b)
  b.move_and_slide()

func _bot_shot(b:CharacterBody3D)->void:
 var reaction:=rng.randf_range(.3,.8)
 await get_tree().create_timer(reaction).timeout
 if phase=="buy" or player==null:return
 var distance:=b.global_position.distance_to(player.global_position)
 var chance:=.55
 if distance>20:chance=.28
 if distance>35:chance=.12
 if rng.randf()<chance:
  _end_round(false,"Бот попал")

func _end_round(attack_win:bool,reason:String)->void:
 if phase=="end":return
 phase="end"
 if attack_win:
  attack_score+=1
  credits+=3250
 else:
  defense_score+=1
  credits+=3000
 status_label.text="%s | Счёт %d:%d"%[reason,attack_score,defense_score]
 if attack_score>=13 or defense_score>=13:
  await get_tree().create_timer(3.0).timeout
  attack_score=0
  defense_score=0
  round_no=1
  phase="buy"
  buy_time=15
  round_time=115
 else:
  await get_tree().create_timer(2.5).timeout
  round_no+=1
  phase="buy"
  buy_time=15
  round_time=115

func _explode_bomb()->void:
 bomb_planted=false
 _end_round(true,"Бомба взорвалась")

func _input(event:InputEvent)->void:
 if event is InputEventMouseMotion and not menu.visible:
  player.rotate_y(-event.relative.x*sensitivity)
  var head:Node3D=player.get_node("Head")
  head.rotation.x=clamp(head.rotation.x-event.relative.y*sensitivity,-1.3,1.3)
 if event is InputEventKey and event.pressed and event.keycode==KEY_B:
  _show_buy()
 if event is InputEventKey and event.pressed and event.keycode==KEY_E and phase=="live":
  bomb_planted=true
  bomb_site="A"
  bomb_time=40
  phase="bomb"
  status_label.text="БОМБА УСТАНОВЛЕНА: A"
