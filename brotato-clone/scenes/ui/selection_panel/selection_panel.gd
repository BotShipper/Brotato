extends Panel
class_name SelectionPanel

signal on_selection_completed

@export var players: Array[UnitStats]
@export var start_weapons: Array[ItemWeapon]

@onready var player_container: HBoxContainer = %PlayerContainer
@onready var weapon_container: HBoxContainer = %WeaponContainer

@onready var player_icon: TextureRect = %PlayerIcon
@onready var player_name: Label = %PlayerName
@onready var player_title: Label = %PlayerTitle
@onready var player_description: RichTextLabel = %PlayerDescription
@onready var item_icon: TextureRect = %ItemIcon

func _ready() -> void:
	for child in player_container.get_children(): child.queue_free()
	for child in weapon_container.get_children(): child.queue_free()
	
	show_player_info(false)
	show_item_info(false)
	load_players()
	load_weapons()


func load_players() -> void:
	if players.is_empty():
		return
	
	#for player: UnitStats in players:
		#var card: SelectionCard = Global.SELECTION_CARD_SCENE.instantiate()
		#card.pressed.connect(_on_player_selected.bind(player))
		#player_container.add_child(card)
		#card.set_icon(player.icon)
	
	for i in players.size():
		var player: UnitStats = players[i]
		var card: SelectionCard = Global.SELECTION_CARD_SCENE.instantiate()
		
		# THAY ĐỔI: Thêm thông tin unlock
		var player_id = "character_%d" % (i + 1)
		card.item_type = "characters"
		card.item_id = player_id
		card.item_data = player  # Lưu data để dùng sau
		
		# Kiểm tra unlock
		var is_unlocked = UnlockManager.is_unlocked(GameManager.total_lifetime_kills,"characters", player_id)
		
		if is_unlocked:
			card.pressed.connect(_on_player_selected.bind(player))
		else:
			card.disabled = true
		
		player_container.add_child(card)
		card.set_icon(player.icon)
		
		# Setup lock state
		card.update_lock_state()


func load_weapons() -> void:
	if start_weapons.is_empty():
		return
	
	#for weapon: ItemWeapon in start_weapons:
		#var card: SelectionCard = Global.SELECTION_CARD_SCENE.instantiate()
		#card.pressed.connect(_on_weapon_selected.bind(weapon))
		#weapon_container.add_child(card)
		#card.icon = weapon.item_icon
	
	for i in start_weapons.size():
		var weapon: ItemWeapon = start_weapons[i]
		var card: SelectionCard = Global.SELECTION_CARD_SCENE.instantiate()
		
		# THAY ĐỔI: Thêm thông tin unlock
		var weapon_id = "weapon_%d" % (i + 1)
		card.item_type = "weapons"
		card.item_id = weapon_id
		card.item_data = weapon  # Lưu data để dùng sau
		
		# Kiểm tra unlock
		var is_unlocked = UnlockManager.is_unlocked(GameManager.total_lifetime_kills,"weapons", weapon_id)
		
		if is_unlocked:
			card.pressed.connect(_on_weapon_selected.bind(weapon))
		else:
			card.disabled = true
		
		weapon_container.add_child(card)
		card.icon = weapon.item_icon
		
		# Setup lock state
		card.update_lock_state()


func show_player_info(value: bool) -> void:
	player_icon.visible = value
	player_name.visible = value
	player_title.visible = value
	player_description.visible = value


func show_item_info(value: bool) -> void:
	item_icon.visible = value


func _on_player_selected(player: UnitStats) -> void:
	Global.main_player_selected = player
	show_player_info(true)
	
	player_icon.texture = player.icon
	player_name.text = player.name
	player_description.text = "[code]Health: [color=green]%s[/color]\nDamage: [color=green]%s[/color]\nSpeed: [color=green]%s[/color]\nLuck: [color=green]%s[/color]\nBlock Chance: [color=green]%s%%[/color][/code]" % [player.health, player.damage, player.speed, player.luck, player.block_chance]


func _on_weapon_selected(weapon: ItemWeapon) -> void:
	Global.main_weapon_selected = weapon
	
	show_item_info(true)
	item_icon.texture = weapon.item_icon


func _on_continue_buttom_pressed() -> void:
	SoundManager.play_sound(SoundManager.Sound.UI)
	
	if not Global.main_player_selected or not Global.main_weapon_selected:
		return
	
	on_selection_completed.emit()
	hide()
